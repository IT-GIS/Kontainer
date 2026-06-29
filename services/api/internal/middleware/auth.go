package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"

	apphttp "container-survey/services/api/internal/apphttp"
	"container-survey/services/api/internal/auth"
)

func RequireAuth(service *auth.Service) gin.HandlerFunc {
	return func(c *gin.Context) {
		header := c.GetHeader("Authorization")
		if header == "" || !strings.HasPrefix(header, "Bearer ") {
			apphttp.Fail(c, http.StatusUnauthorized, "Token tidak ditemukan.", "UNAUTHORIZED", nil)
			c.Abort()
			return
		}

		rawToken := strings.TrimSpace(strings.TrimPrefix(header, "Bearer "))
		if rawToken == "" {
			apphttp.Fail(c, http.StatusUnauthorized, "Token tidak valid.", "UNAUTHORIZED", nil)
			c.Abort()
			return
		}

		principal, err := service.AuthenticateAccessToken(c.Request.Context(), rawToken)
		if err != nil {
			apphttp.Fail(c, http.StatusUnauthorized, "Token tidak valid.", "UNAUTHORIZED", nil)
			c.Abort()
			return
		}

		c.Set("principal", principal)
		c.Next()
	}
}

func RequirePermission(service *auth.Service, permission string) gin.HandlerFunc {
	return func(c *gin.Context) {
		principal, ok := auth.PrincipalFromContext(c)
		if !ok {
			apphttp.Fail(c, http.StatusUnauthorized, "Token tidak valid.", "UNAUTHORIZED", nil)
			c.Abort()
			return
		}

		if !service.HasPermission(principal, permission) {
			apphttp.Fail(c, http.StatusForbidden, "User tidak memiliki permission.", "FORBIDDEN", nil)
			c.Abort()
			return
		}

		c.Next()
	}
}
