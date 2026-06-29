package auth

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

var (
	ErrInvalidCredentials = errors.New("invalid credentials")
	ErrInactiveUser       = errors.New("inactive user")
	ErrInvalidToken       = errors.New("invalid token")
	ErrForbidden          = errors.New("forbidden")
)

type User struct {
	ID           uuid.UUID
	Name         string
	Email        string
	Username     string
	PasswordHash string
	Status       string
}

type UserContext struct {
	ID                uuid.UUID  `json:"id"`
	Name              string     `json:"name"`
	Email             string     `json:"email"`
	Roles             []string   `json:"roles"`
	Permissions       []string   `json:"permissions"`
	SurveyorProfileID *uuid.UUID `json:"surveyor_profile_id,omitempty"`
}

type Principal struct {
	UserContext
	ActiveRole string `json:"active_role"`
}

type RefreshToken struct {
	ID        uuid.UUID
	UserID    uuid.UUID
	TokenHash string
	ExpiresAt time.Time
	RevokedAt *time.Time
}

type AuditEvent struct {
	UserID     *uuid.UUID
	ActiveRole *string
	Action     string
	EntityType string
	EntityID   *uuid.UUID
	OldState   *string
	NewState   *string
	Reason     *string
	RequestID  string
	IPAddress  string
	UserAgent  string
}

type LoginInput struct {
	Email     string
	Password  string
	RequestID string
	IPAddress string
	UserAgent string
}

type LogoutInput struct {
	RefreshToken string
	Principal    Principal
	RequestID    string
	IPAddress    string
	UserAgent    string
}

type RefreshInput struct {
	RefreshToken string
	RequestID    string
	IPAddress    string
	UserAgent    string
}

type TokenPair struct {
	AccessToken  string
	RefreshToken string
	ExpiresIn    int
	User         UserContext
}
