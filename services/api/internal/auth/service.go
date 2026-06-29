package auth

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"
)

type Service struct {
	repo   Repository
	tokens TokenManager
	now    func() time.Time
}

func NewService(repo Repository, tokens TokenManager) *Service {
	return &Service{
		repo:   repo,
		tokens: tokens,
		now:    func() time.Time { return time.Now().UTC() },
	}
}

func (s *Service) Login(ctx context.Context, input LoginInput) (TokenPair, error) {
	login := strings.TrimSpace(input.Email)
	user, err := s.repo.FindUserByLogin(ctx, login)
	if err != nil {
		s.audit(ctx, AuditEvent{Action: "auth.login_failed", EntityType: "auth", RequestID: input.RequestID, IPAddress: input.IPAddress, UserAgent: input.UserAgent})
		return TokenPair{}, ErrInvalidCredentials
	}

	userID := user.ID
	if user.Status != "active" {
		s.audit(ctx, AuditEvent{UserID: &userID, Action: "auth.login_failed", EntityType: "auth", Reason: strPtr("inactive_user"), RequestID: input.RequestID, IPAddress: input.IPAddress, UserAgent: input.UserAgent})
		return TokenPair{}, ErrInactiveUser
	}

	if !VerifyPassword(user.PasswordHash, input.Password) {
		s.audit(ctx, AuditEvent{UserID: &userID, Action: "auth.login_failed", EntityType: "auth", Reason: strPtr("invalid_password"), RequestID: input.RequestID, IPAddress: input.IPAddress, UserAgent: input.UserAgent})
		return TokenPair{}, ErrInvalidCredentials
	}

	userContext, err := s.repo.GetUserContext(ctx, user.ID)
	if err != nil {
		return TokenPair{}, err
	}

	activeRole := firstRole(userContext.Roles)
	now := s.now()
	accessToken, err := s.tokens.CreateAccessToken(user.ID, activeRole, now)
	if err != nil {
		return TokenPair{}, err
	}
	refreshToken, err := s.tokens.CreateRefreshToken(user.ID, activeRole, now)
	if err != nil {
		return TokenPair{}, err
	}

	if err := s.repo.StoreRefreshToken(ctx, user.ID, HashRefreshToken(refreshToken), now.Add(s.tokens.RefreshTTL()), "", input.IPAddress, input.UserAgent); err != nil {
		return TokenPair{}, err
	}
	if err := s.repo.UpdateLastLogin(ctx, user.ID, now); err != nil {
		return TokenPair{}, err
	}

	s.audit(ctx, AuditEvent{UserID: &userID, ActiveRole: &activeRole, Action: "auth.login_success", EntityType: "auth", RequestID: input.RequestID, IPAddress: input.IPAddress, UserAgent: input.UserAgent})

	return TokenPair{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    int(s.tokens.AccessTTL().Seconds()),
		User:         userContext,
	}, nil
}

func (s *Service) Logout(ctx context.Context, input LogoutInput) error {
	if strings.TrimSpace(input.RefreshToken) != "" {
		claims, err := s.tokens.ParseRefreshToken(input.RefreshToken)
		if err == nil && claims.UserID == input.Principal.ID.String() {
			tokenHash := HashRefreshToken(input.RefreshToken)
			_ = s.repo.RevokeRefreshToken(ctx, tokenHash, s.now())
		}
	}

	userID := input.Principal.ID
	activeRole := input.Principal.ActiveRole
	s.audit(ctx, AuditEvent{UserID: &userID, ActiveRole: &activeRole, Action: "auth.logout", EntityType: "auth", RequestID: input.RequestID, IPAddress: input.IPAddress, UserAgent: input.UserAgent})
	return nil
}

func (s *Service) Refresh(ctx context.Context, input RefreshInput) (TokenPair, error) {
	claims, err := s.tokens.ParseRefreshToken(input.RefreshToken)
	if err != nil {
		return TokenPair{}, ErrInvalidToken
	}

	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		return TokenPair{}, ErrInvalidToken
	}

	oldHash := HashRefreshToken(input.RefreshToken)
	stored, err := s.repo.FindRefreshToken(ctx, oldHash)
	if err != nil {
		return TokenPair{}, ErrInvalidToken
	}
	if stored.RevokedAt != nil || stored.ExpiresAt.Before(s.now()) || stored.UserID != userID {
		return TokenPair{}, ErrInvalidToken
	}

	userContext, err := s.repo.GetUserContext(ctx, userID)
	if err != nil {
		return TokenPair{}, err
	}

	activeRole := firstRole(userContext.Roles)
	now := s.now()
	accessToken, err := s.tokens.CreateAccessToken(userID, activeRole, now)
	if err != nil {
		return TokenPair{}, err
	}
	refreshToken, err := s.tokens.CreateRefreshToken(userID, activeRole, now)
	if err != nil {
		return TokenPair{}, err
	}

	if err := s.repo.RevokeRefreshToken(ctx, oldHash, now); err != nil {
		return TokenPair{}, err
	}
	if err := s.repo.StoreRefreshToken(ctx, userID, HashRefreshToken(refreshToken), now.Add(s.tokens.RefreshTTL()), "", input.IPAddress, input.UserAgent); err != nil {
		return TokenPair{}, err
	}

	return TokenPair{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		ExpiresIn:    int(s.tokens.AccessTTL().Seconds()),
		User:         userContext,
	}, nil
}

func (s *Service) AuthenticateAccessToken(ctx context.Context, rawToken string) (Principal, error) {
	claims, err := s.tokens.ParseAccessToken(rawToken)
	if err != nil {
		return Principal{}, ErrInvalidToken
	}

	userID, err := uuid.Parse(claims.UserID)
	if err != nil {
		return Principal{}, ErrInvalidToken
	}

	userContext, err := s.repo.GetUserContext(ctx, userID)
	if err != nil {
		return Principal{}, ErrInvalidToken
	}

	activeRole := claims.ActiveRole
	if activeRole == "" {
		activeRole = firstRole(userContext.Roles)
	}

	return Principal{UserContext: userContext, ActiveRole: activeRole}, nil
}

func (s *Service) CurrentUser(ctx context.Context, principal Principal) (UserContext, error) {
	return s.repo.GetUserContext(ctx, principal.ID)
}

func (s *Service) HasPermission(principal Principal, permission string) bool {
	if permission == "" {
		return true
	}
	requiredParts := strings.Split(permission, ".")
	for _, p := range principal.Permissions {
		if p == "*.*.all" || p == permission {
			return true
		}
		parts := strings.Split(p, ".")
		if len(requiredParts) == 3 && len(parts) == 3 && parts[0] == requiredParts[0] && parts[1] == "manage" && (parts[2] == requiredParts[2] || parts[2] == "all") {
			return true
		}
	}
	return false
}

func (s *Service) IsAuthError(err error) bool {
	return errors.Is(err, ErrInvalidCredentials) || errors.Is(err, ErrInactiveUser) || errors.Is(err, ErrInvalidToken)
}

func (s *Service) audit(ctx context.Context, event AuditEvent) {
	_ = s.repo.InsertAudit(ctx, event)
}

func firstRole(roles []string) string {
	if len(roles) == 0 {
		return ""
	}
	return roles[0]
}

func strPtr(value string) *string {
	return &value
}
