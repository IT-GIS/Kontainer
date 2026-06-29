package auth_test

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	apphttp "container-survey/services/api/internal/apphttp"
	"container-survey/services/api/internal/auth"
	"container-survey/services/api/internal/config"
	"container-survey/services/api/internal/middleware"
)

type fakeRepo struct {
	usersByLogin map[string]auth.User
	contexts     map[uuid.UUID]auth.UserContext
	refresh      map[string]auth.RefreshToken
	audits       []auth.AuditEvent
}

func newFakeRepo(t *testing.T) *fakeRepo {
	t.Helper()
	passwordHash, err := auth.HashPassword("password")
	if err != nil {
		t.Fatal(err)
	}
	userID := uuid.MustParse("00000000-0000-0000-0000-000000000001")
	return &fakeRepo{
		usersByLogin: map[string]auth.User{
			"superadmin@gift.local": {
				ID:           userID,
				Name:         "Super Admin Dev",
				Email:        "superadmin@gift.local",
				PasswordHash: passwordHash,
				Status:       "active",
			},
		},
		contexts: map[uuid.UUID]auth.UserContext{
			userID: {
				ID:          userID,
				Name:        "Super Admin Dev",
				Email:       "superadmin@gift.local",
				Roles:       []string{"super_admin"},
				Permissions: []string{"*.*.all"},
			},
		},
		refresh: map[string]auth.RefreshToken{},
	}
}

func (r *fakeRepo) FindUserByLogin(ctx context.Context, login string) (auth.User, error) {
	user, ok := r.usersByLogin[strings.ToLower(login)]
	if !ok {
		return auth.User{}, auth.ErrInvalidCredentials
	}
	return user, nil
}

func (r *fakeRepo) GetUserContext(ctx context.Context, userID uuid.UUID) (auth.UserContext, error) {
	user, ok := r.contexts[userID]
	if !ok {
		return auth.UserContext{}, auth.ErrInvalidToken
	}
	return user, nil
}

func (r *fakeRepo) StoreRefreshToken(ctx context.Context, userID uuid.UUID, tokenHash string, expiresAt time.Time, deviceName string, ipAddress string, userAgent string) error {
	r.refresh[tokenHash] = auth.RefreshToken{ID: uuid.New(), UserID: userID, TokenHash: tokenHash, ExpiresAt: expiresAt}
	return nil
}

func (r *fakeRepo) FindRefreshToken(ctx context.Context, tokenHash string) (auth.RefreshToken, error) {
	token, ok := r.refresh[tokenHash]
	if !ok {
		return auth.RefreshToken{}, auth.ErrInvalidToken
	}
	return token, nil
}

func (r *fakeRepo) RevokeRefreshToken(ctx context.Context, tokenHash string, revokedAt time.Time) error {
	token, ok := r.refresh[tokenHash]
	if !ok {
		return nil
	}
	token.RevokedAt = &revokedAt
	r.refresh[tokenHash] = token
	return nil
}

func (r *fakeRepo) UpdateLastLogin(ctx context.Context, userID uuid.UUID, loggedInAt time.Time) error {
	return nil
}

func (r *fakeRepo) InsertAudit(ctx context.Context, event auth.AuditEvent) error {
	r.audits = append(r.audits, event)
	return nil
}

func testService(t *testing.T) (*auth.Service, *fakeRepo) {
	t.Helper()
	repo := newFakeRepo(t)
	cfg := config.Config{
		AccessSecret:  "test-access-secret",
		RefreshSecret: "test-refresh-secret",
		AccessTTL:     time.Hour,
		RefreshTTL:    24 * time.Hour,
	}
	service := auth.NewService(repo, auth.NewTokenManager(cfg))
	return service, repo
}

func TestPasswordHashVerify(t *testing.T) {
	hash, err := auth.HashPassword("secret")
	if err != nil {
		t.Fatal(err)
	}
	if !auth.VerifyPassword(hash, "secret") {
		t.Fatal("expected password to verify")
	}
	if auth.VerifyPassword(hash, "wrong") {
		t.Fatal("expected wrong password to fail")
	}
}

func TestTokenManagerCreateParse(t *testing.T) {
	cfg := config.Config{AccessSecret: "a-secret", RefreshSecret: "r-secret", AccessTTL: time.Hour, RefreshTTL: time.Hour}
	manager := auth.NewTokenManager(cfg)
	userID := uuid.New()
	token, err := manager.CreateAccessToken(userID, "super_admin", time.Now())
	if err != nil {
		t.Fatal(err)
	}
	claims, err := manager.ParseAccessToken(token)
	if err != nil {
		t.Fatal(err)
	}
	if claims.UserID != userID.String() || claims.ActiveRole != "super_admin" {
		t.Fatalf("unexpected claims: %+v", claims)
	}
	if _, err := manager.ParseRefreshToken(token); !errors.Is(err, auth.ErrInvalidToken) {
		t.Fatalf("expected invalid token for wrong token type, got %v", err)
	}
}

func TestLoginMeRefreshLogoutFlow(t *testing.T) {
	gin.SetMode(gin.TestMode)
	service, repo := testService(t)
	handler := auth.NewHandler(service)
	router := gin.New()
	requireAuth := middleware.RequireAuth(service)
	handler.Register(router.Group("/api/v1/auth"), requireAuth)
	router.GET("/api/v1/me", requireAuth, handler.Me)

	loginBody := `{"email":"superadmin@gift.local","password":"password"}`
	loginResp := perform(router, http.MethodPost, "/api/v1/auth/login", loginBody, "")
	if loginResp.Code != http.StatusOK {
		t.Fatalf("expected login 200, got %d: %s", loginResp.Code, loginResp.Body.String())
	}
	if len(repo.audits) == 0 || repo.audits[0].Action != "auth.login_success" {
		t.Fatalf("expected login audit, got %+v", repo.audits)
	}

	accessToken := extractJSONField(t, loginResp.Body.String(), "access_token")
	refreshToken := extractJSONField(t, loginResp.Body.String(), "refresh_token")

	meResp := perform(router, http.MethodGet, "/api/v1/me", "", accessToken)
	if meResp.Code != http.StatusOK {
		t.Fatalf("expected me 200, got %d: %s", meResp.Code, meResp.Body.String())
	}

	refreshResp := perform(router, http.MethodPost, "/api/v1/auth/refresh", `{"refresh_token":"`+refreshToken+`"}`, "")
	if refreshResp.Code != http.StatusOK {
		t.Fatalf("expected refresh 200, got %d: %s", refreshResp.Code, refreshResp.Body.String())
	}

	logoutResp := perform(router, http.MethodPost, "/api/v1/auth/logout", `{"refresh_token":"`+refreshToken+`"}`, accessToken)
	if logoutResp.Code != http.StatusOK {
		t.Fatalf("expected logout 200, got %d: %s", logoutResp.Code, logoutResp.Body.String())
	}
}

func TestLoginInvalidPassword(t *testing.T) {
	gin.SetMode(gin.TestMode)
	service, _ := testService(t)
	handler := auth.NewHandler(service)
	router := gin.New()
	handler.Register(router.Group("/api/v1/auth"), middleware.RequireAuth(service))

	resp := perform(router, http.MethodPost, "/api/v1/auth/login", `{"email":"superadmin@gift.local","password":"wrong"}`, "")
	if resp.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d: %s", resp.Code, resp.Body.String())
	}
}

func TestMeWithoutToken(t *testing.T) {
	gin.SetMode(gin.TestMode)
	service, _ := testService(t)
	handler := auth.NewHandler(service)
	router := gin.New()
	router.GET("/api/v1/me", middleware.RequireAuth(service), handler.Me)

	resp := perform(router, http.MethodGet, "/api/v1/me", "", "")
	if resp.Code != http.StatusUnauthorized {
		t.Fatalf("expected 401, got %d", resp.Code)
	}
}

func TestRequirePermission(t *testing.T) {
	gin.SetMode(gin.TestMode)
	service, _ := testService(t)
	router := gin.New()
	router.GET("/protected", middleware.RequireAuth(service), middleware.RequirePermission(service, "users.manage.all"), func(c *gin.Context) {
		apphttp.OK(c, "ok", nil)
	})

	pair, err := service.Login(context.Background(), auth.LoginInput{Email: "superadmin@gift.local", Password: "password"})
	if err != nil {
		t.Fatal(err)
	}
	resp := perform(router, http.MethodGet, "/protected", "", pair.AccessToken)
	if resp.Code != http.StatusOK {
		t.Fatalf("expected wildcard permission to pass, got %d: %s", resp.Code, resp.Body.String())
	}
}

func TestManagePermissionCoversCrudAction(t *testing.T) {
	service, _ := testService(t)
	principal := auth.Principal{UserContext: auth.UserContext{Permissions: []string{"customers.manage.all"}}}
	if !service.HasPermission(principal, "customers.create.all") {
		t.Fatal("expected manage permission to cover create action")
	}
	if service.HasPermission(principal, "locations.create.all") {
		t.Fatal("expected manage permission to stay scoped to its module")
	}
}
func TestRequirePermissionForbidden(t *testing.T) {
	gin.SetMode(gin.TestMode)
	service, repo := testService(t)
	userID := uuid.MustParse("00000000-0000-0000-0000-000000000001")
	repo.contexts[userID] = auth.UserContext{
		ID:          userID,
		Name:        "Limited User",
		Email:       "superadmin@gift.local",
		Roles:       []string{"management"},
		Permissions: []string{"dashboard.view.all"},
	}

	router := gin.New()
	router.GET("/protected", middleware.RequireAuth(service), middleware.RequirePermission(service, "users.manage.all"), func(c *gin.Context) {
		apphttp.OK(c, "ok", nil)
	})

	pair, err := service.Login(context.Background(), auth.LoginInput{Email: "superadmin@gift.local", Password: "password"})
	if err != nil {
		t.Fatal(err)
	}
	resp := perform(router, http.MethodGet, "/protected", "", pair.AccessToken)
	if resp.Code != http.StatusForbidden {
		t.Fatalf("expected insufficient permission to be forbidden, got %d: %s", resp.Code, resp.Body.String())
	}
}
func perform(router http.Handler, method string, path string, body string, token string) *httptest.ResponseRecorder {
	req := httptest.NewRequest(method, path, strings.NewReader(body))
	req.Header.Set("Content-Type", "application/json")
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	resp := httptest.NewRecorder()
	router.ServeHTTP(resp, req)
	return resp
}

func extractJSONField(t *testing.T, body string, field string) string {
	t.Helper()
	marker := `"` + field + `":"`
	idx := strings.Index(body, marker)
	if idx < 0 {
		t.Fatalf("field %s not found in body: %s", field, body)
	}
	start := idx + len(marker)
	end := strings.Index(body[start:], `"`)
	if end < 0 {
		t.Fatalf("unterminated field %s in body: %s", field, body)
	}
	return body[start : start+end]
}
