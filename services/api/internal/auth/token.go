package auth

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"

	"container-survey/services/api/internal/config"
)

type TokenManager struct {
	accessSecret  []byte
	refreshSecret []byte
	accessTTL     time.Duration
	refreshTTL    time.Duration
}

type Claims struct {
	UserID     string `json:"user_id"`
	ActiveRole string `json:"active_role"`
	TokenType  string `json:"token_type"`
	jwt.RegisteredClaims
}

func NewTokenManager(cfg config.Config) TokenManager {
	return TokenManager{
		accessSecret:  []byte(cfg.AccessSecret),
		refreshSecret: []byte(cfg.RefreshSecret),
		accessTTL:     cfg.AccessTTL,
		refreshTTL:    cfg.RefreshTTL,
	}
}

func (m TokenManager) AccessTTL() time.Duration {
	return m.accessTTL
}

func (m TokenManager) RefreshTTL() time.Duration {
	return m.refreshTTL
}

func (m TokenManager) CreateAccessToken(userID uuid.UUID, activeRole string, now time.Time) (string, error) {
	return m.createToken(userID, activeRole, "access", m.accessTTL, m.accessSecret, now)
}

func (m TokenManager) CreateRefreshToken(userID uuid.UUID, activeRole string, now time.Time) (string, error) {
	return m.createToken(userID, activeRole, "refresh", m.refreshTTL, m.refreshSecret, now)
}

func (m TokenManager) ParseAccessToken(token string) (*Claims, error) {
	return m.parseToken(token, "access", m.accessSecret)
}

func (m TokenManager) ParseRefreshToken(token string) (*Claims, error) {
	return m.parseToken(token, "refresh", m.refreshSecret)
}

func HashRefreshToken(token string) string {
	sum := sha256.Sum256([]byte(token))
	return hex.EncodeToString(sum[:])
}

func (m TokenManager) createToken(userID uuid.UUID, activeRole string, tokenType string, ttl time.Duration, secret []byte, now time.Time) (string, error) {
	claims := Claims{
		UserID:     userID.String(),
		ActiveRole: activeRole,
		TokenType:  tokenType,
		RegisteredClaims: jwt.RegisteredClaims{
			ID:        randomID(),
			Subject:   userID.String(),
			IssuedAt:  jwt.NewNumericDate(now),
			ExpiresAt: jwt.NewNumericDate(now.Add(ttl)),
		},
	}

	return jwt.NewWithClaims(jwt.SigningMethodHS256, claims).SignedString(secret)
}

func (m TokenManager) parseToken(token string, expectedType string, secret []byte) (*Claims, error) {
	parsed, err := jwt.ParseWithClaims(token, &Claims{}, func(token *jwt.Token) (any, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method")
		}
		return secret, nil
	})
	if err != nil {
		return nil, ErrInvalidToken
	}

	claims, ok := parsed.Claims.(*Claims)
	if !ok || !parsed.Valid || claims.TokenType != expectedType {
		return nil, ErrInvalidToken
	}

	if _, err := uuid.Parse(claims.UserID); err != nil {
		return nil, ErrInvalidToken
	}

	return claims, nil
}

func randomID() string {
	bytes := make([]byte, 16)
	if _, err := rand.Read(bytes); err != nil {
		return uuid.NewString()
	}
	return hex.EncodeToString(bytes)
}
