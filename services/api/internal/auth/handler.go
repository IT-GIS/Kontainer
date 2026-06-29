package auth

import (
	"errors"
	"net/http"

	"github.com/gin-gonic/gin"

	apphttp "container-survey/services/api/internal/apphttp"
)

type Handler struct {
	service *Service
}

type loginRequest struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type refreshRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

type logoutRequest struct {
	RefreshToken string `json:"refresh_token"`
}

func NewHandler(service *Service) Handler {
	return Handler{service: service}
}

func (h Handler) Register(group *gin.RouterGroup, requireAuth gin.HandlerFunc) {
	group.POST("/login", h.Login)
	group.POST("/refresh", h.Refresh)
	group.POST("/logout", requireAuth, h.Logout)
}

func (h Handler) Login(c *gin.Context) {
	var request loginRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Validasi gagal.", "VALIDATION_ERROR", []apphttp.ErrorDetail{
			{Field: "email", Message: "Email atau username wajib diisi."},
			{Field: "password", Message: "Password wajib diisi."},
		})
		return
	}

	result, err := h.service.Login(c.Request.Context(), LoginInput{
		Email:     request.Email,
		Password:  request.Password,
		RequestID: c.GetString("request_id"),
		IPAddress: c.ClientIP(),
		UserAgent: c.Request.UserAgent(),
	})
	if err != nil {
		h.writeAuthError(c, err)
		return
	}

	apphttp.OK(c, "Login berhasil.", gin.H{
		"access_token":  result.AccessToken,
		"refresh_token": result.RefreshToken,
		"token_type":    "Bearer",
		"expires_in":    result.ExpiresIn,
		"user": gin.H{
			"id":          result.User.ID,
			"name":        result.User.Name,
			"email":       result.User.Email,
			"roles":       result.User.Roles,
			"permissions": result.User.Permissions,
		},
	})
}

func (h Handler) Refresh(c *gin.Context) {
	var request refreshRequest
	if err := c.ShouldBindJSON(&request); err != nil {
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Validasi gagal.", "VALIDATION_ERROR", []apphttp.ErrorDetail{
			{Field: "refresh_token", Message: "Refresh token wajib diisi."},
		})
		return
	}

	result, err := h.service.Refresh(c.Request.Context(), RefreshInput{
		RefreshToken: request.RefreshToken,
		RequestID:    c.GetString("request_id"),
		IPAddress:    c.ClientIP(),
		UserAgent:    c.Request.UserAgent(),
	})
	if err != nil {
		h.writeAuthError(c, err)
		return
	}

	apphttp.OK(c, "Token berhasil diperbarui.", gin.H{
		"access_token":  result.AccessToken,
		"refresh_token": result.RefreshToken,
		"token_type":    "Bearer",
		"expires_in":    result.ExpiresIn,
	})
}

func (h Handler) Logout(c *gin.Context) {
	principal, ok := PrincipalFromContext(c)
	if !ok {
		apphttp.Fail(c, http.StatusUnauthorized, "Token tidak valid.", "UNAUTHORIZED", nil)
		return
	}

	var request logoutRequest
	_ = c.ShouldBindJSON(&request)

	if err := h.service.Logout(c.Request.Context(), LogoutInput{
		RefreshToken: request.RefreshToken,
		Principal:    principal,
		RequestID:    c.GetString("request_id"),
		IPAddress:    c.ClientIP(),
		UserAgent:    c.Request.UserAgent(),
	}); err != nil {
		h.writeAuthError(c, err)
		return
	}

	apphttp.OK(c, "Logout berhasil.", nil)
}

func (h Handler) Me(c *gin.Context) {
	principal, ok := PrincipalFromContext(c)
	if !ok {
		apphttp.Fail(c, http.StatusUnauthorized, "Token tidak valid.", "UNAUTHORIZED", nil)
		return
	}

	user, err := h.service.CurrentUser(c.Request.Context(), principal)
	if err != nil {
		h.writeAuthError(c, err)
		return
	}

	apphttp.OK(c, "User berhasil diambil.", gin.H{
		"id":          user.ID,
		"name":        user.Name,
		"email":       user.Email,
		"roles":       user.Roles,
		"permissions": user.Permissions,
		"profile": gin.H{
			"surveyor_profile_id": user.SurveyorProfileID,
		},
	})
}

func (h Handler) writeAuthError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, ErrInactiveUser):
		apphttp.Fail(c, http.StatusForbidden, "User tidak aktif.", "FORBIDDEN", nil)
	case errors.Is(err, ErrInvalidCredentials), errors.Is(err, ErrInvalidToken):
		apphttp.Fail(c, http.StatusUnauthorized, "Credential atau token tidak valid.", "UNAUTHORIZED", nil)
	default:
		apphttp.Fail(c, http.StatusInternalServerError, "Terjadi kesalahan internal.", "INTERNAL_ERROR", nil)
	}
}

func PrincipalFromContext(c *gin.Context) (Principal, bool) {
	value, exists := c.Get("principal")
	if !exists {
		return Principal{}, false
	}
	principal, ok := value.(Principal)
	return principal, ok
}
