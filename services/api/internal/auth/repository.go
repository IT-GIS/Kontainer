package auth

import (
	"container-survey/services/api/internal/database"
	"context"
	"errors"
	"time"

	"github.com/google/uuid"
)

type Repository interface {
	FindUserByLogin(ctx context.Context, login string) (User, error)
	GetUserContext(ctx context.Context, userID uuid.UUID) (UserContext, error)
	StoreRefreshToken(ctx context.Context, userID uuid.UUID, tokenHash string, expiresAt time.Time, deviceName string, ipAddress string, userAgent string) error
	FindRefreshToken(ctx context.Context, tokenHash string) (RefreshToken, error)
	RevokeRefreshToken(ctx context.Context, tokenHash string, revokedAt time.Time) error
	UpdateLastLogin(ctx context.Context, userID uuid.UUID, loggedInAt time.Time) error
	InsertAudit(ctx context.Context, event AuditEvent) error
}

type MySQLRepository struct {
	pool *database.Pool
}

func NewMySQLRepository(pool *database.Pool) MySQLRepository {
	return MySQLRepository{pool: pool}
}

func (r MySQLRepository) FindUserByLogin(ctx context.Context, login string) (User, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT id, name, email, COALESCE(username, ''), password_hash, status
		FROM users
		WHERE deleted_at IS NULL
		  AND (LOWER(email) = LOWER($1) OR LOWER(username) = LOWER($1))
		LIMIT 1
	`, login)

	var user User
	if err := row.Scan(&user.ID, &user.Name, &user.Email, &user.Username, &user.PasswordHash, &user.Status); err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return User{}, ErrInvalidCredentials
		}
		return User{}, err
	}

	return user, nil
}

func (r MySQLRepository) GetUserContext(ctx context.Context, userID uuid.UUID) (UserContext, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT u.id, u.name, u.email, sp.id
		FROM users u
		LEFT JOIN surveyor_profiles sp ON sp.user_id = u.id AND sp.deleted_at IS NULL
		WHERE u.id = $1 AND u.deleted_at IS NULL AND u.status = 'active'
	`, userID)

	var user UserContext
	if err := row.Scan(&user.ID, &user.Name, &user.Email, &user.SurveyorProfileID); err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return UserContext{}, ErrInvalidToken
		}
		return UserContext{}, err
	}

	roles, err := r.loadRoles(ctx, userID)
	if err != nil {
		return UserContext{}, err
	}
	permissions, err := r.loadPermissions(ctx, userID)
	if err != nil {
		return UserContext{}, err
	}

	user.Roles = roles
	user.Permissions = permissions
	return user, nil
}

func (r MySQLRepository) StoreRefreshToken(ctx context.Context, userID uuid.UUID, tokenHash string, expiresAt time.Time, deviceName string, ipAddress string, userAgent string) error {
	_, err := r.pool.Exec(ctx, `
		INSERT INTO refresh_tokens (user_id, token_hash, device_name, ip_address, user_agent, expires_at)
		VALUES ($1, $2, NULLIF($3, ''), NULLIF($4, ''), NULLIF($5, ''), $6)
	`, userID, tokenHash, deviceName, ipAddress, userAgent, expiresAt)
	return err
}

func (r MySQLRepository) FindRefreshToken(ctx context.Context, tokenHash string) (RefreshToken, error) {
	row := r.pool.QueryRow(ctx, `
		SELECT id, user_id, token_hash, expires_at, revoked_at
		FROM refresh_tokens
		WHERE token_hash = $1
		LIMIT 1
	`, tokenHash)

	var refresh RefreshToken
	if err := row.Scan(&refresh.ID, &refresh.UserID, &refresh.TokenHash, &refresh.ExpiresAt, &refresh.RevokedAt); err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return RefreshToken{}, ErrInvalidToken
		}
		return RefreshToken{}, err
	}
	return refresh, nil
}

func (r MySQLRepository) RevokeRefreshToken(ctx context.Context, tokenHash string, revokedAt time.Time) error {
	_, err := r.pool.Exec(ctx, `
		UPDATE refresh_tokens
		SET revoked_at = COALESCE(revoked_at, $2)
		WHERE token_hash = $1
	`, tokenHash, revokedAt)
	return err
}

func (r MySQLRepository) UpdateLastLogin(ctx context.Context, userID uuid.UUID, loggedInAt time.Time) error {
	_, err := r.pool.Exec(ctx, `
		UPDATE users
		SET last_login_at = $2, updated_at = $2
		WHERE id = $1
	`, userID, loggedInAt)
	return err
}

func (r MySQLRepository) InsertAudit(ctx context.Context, event AuditEvent) error {
	_, err := r.pool.Exec(ctx, `
		INSERT INTO audit_logs (
			user_id, active_role, action, entity_type, entity_id, old_state, new_state,
			reason, request_id, ip_address, user_agent
		) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NULLIF($9, ''), NULLIF($10, ''), NULLIF($11, ''))
	`, event.UserID, event.ActiveRole, event.Action, event.EntityType, event.EntityID, event.OldState, event.NewState, event.Reason, event.RequestID, event.IPAddress, event.UserAgent)
	return err
}

func (r MySQLRepository) loadRoles(ctx context.Context, userID uuid.UUID) ([]string, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT r.code
		FROM user_roles ur
		JOIN roles r ON r.id = ur.role_id
		WHERE ur.user_id = $1
		ORDER BY r.is_system_role DESC, r.code ASC
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	roles := []string{}
	for rows.Next() {
		var role string
		if err := rows.Scan(&role); err != nil {
			return nil, err
		}
		roles = append(roles, role)
	}
	return roles, rows.Err()
}

func (r MySQLRepository) loadPermissions(ctx context.Context, userID uuid.UUID) ([]string, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT DISTINCT p.code
		FROM user_roles ur
		JOIN role_permissions rp ON rp.role_id = ur.role_id
		JOIN permissions p ON p.id = rp.permission_id
		WHERE ur.user_id = $1
		ORDER BY p.code ASC
	`, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	permissions := []string{}
	for rows.Next() {
		var permission string
		if err := rows.Scan(&permission); err != nil {
			return nil, err
		}
		permissions = append(permissions, permission)
	}
	return permissions, rows.Err()
}
