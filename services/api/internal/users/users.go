package users

import (
	"context"
	"database/sql"
	"fmt"
	"math"
	"net/http"
	"strconv"
	"strings"

	"github.com/gin-gonic/gin"

	"container-survey/services/api/internal/apphttp"
	"container-survey/services/api/internal/auth"
	"container-survey/services/api/internal/database"
	"container-survey/services/api/internal/middleware"
)

type Handler struct{ pool *database.Pool }

type listParams struct {
	Page, PerPage          int
	Search, Status, Role   string
	WithoutSurveyorProfile bool
}

type userSummary struct {
	ID          string   `json:"id"`
	Name        string   `json:"name"`
	Email       string   `json:"email"`
	Username    string   `json:"username"`
	Status      string   `json:"status"`
	Roles       []string `json:"roles"`
	LastLoginAt any      `json:"last_login_at"`
}

func Register(v1 *gin.RouterGroup, authService *auth.Service, pool *database.Pool) {
	h := Handler{pool: pool}
	v1.GET("/users", middleware.RequirePermission(authService, "users.view.all"), h.List)
}

func (h Handler) List(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "20"))
	params := listParams{
		Page: page, PerPage: perPage, Search: c.Query("search"), Status: c.Query("status"), Role: c.Query("role"),
		WithoutSurveyorProfile: c.Query("without_surveyor_profile") == "true",
	}
	rows, meta, err := h.list(c.Request.Context(), params)
	if err != nil {
		apphttp.Fail(c, http.StatusInternalServerError, "Terjadi kesalahan internal.", "INTERNAL_ERROR", nil)
		return
	}
	apphttp.Paginated(c, "User berhasil diambil.", rows, meta)
}

func (h Handler) list(ctx context.Context, params listParams) ([]userSummary, apphttp.PaginationMeta, error) {
	page, perPage := normalizePagination(params.Page, params.PerPage)
	where, args := userWhere(params)
	var total int
	if err := h.pool.QueryRow(ctx, "SELECT COUNT(*) FROM users u "+where, args...).Scan(&total); err != nil {
		return nil, apphttp.PaginationMeta{}, err
	}
	args = append(args, perPage, (page-1)*perPage)
	rows, err := h.pool.Query(ctx, fmt.Sprintf(`
		SELECT u.id, u.name, u.email, COALESCE(u.username,''), u.status, u.last_login_at,
		       COALESCE((SELECT GROUP_CONCAT(DISTINCT r.code ORDER BY r.code SEPARATOR ',')
		                 FROM user_roles ur JOIN roles r ON r.id=ur.role_id WHERE ur.user_id=u.id), '') AS roles
		FROM users u %s ORDER BY u.name, u.email LIMIT $%d OFFSET $%d
	`, where, len(args)-1, len(args)), args...)
	if err != nil {
		return nil, apphttp.PaginationMeta{}, err
	}
	defer rows.Close()
	items := []userSummary{}
	for rows.Next() {
		var item userSummary
		var roleCodes string
		var lastLogin sql.NullTime
		if err := rows.Scan(&item.ID, &item.Name, &item.Email, &item.Username, &item.Status, &lastLogin, &roleCodes); err != nil {
			return nil, apphttp.PaginationMeta{}, err
		}
		if roleCodes != "" {
			item.Roles = strings.Split(roleCodes, ",")
		} else {
			item.Roles = []string{}
		}
		if lastLogin.Valid {
			item.LastLoginAt = lastLogin.Time
		}
		items = append(items, item)
	}
	totalPages := 0
	if total > 0 {
		totalPages = int(math.Ceil(float64(total) / float64(perPage)))
	}
	meta := apphttp.PaginationMeta{Page: page, PerPage: perPage, Total: total, TotalPages: totalPages, HasNext: page < totalPages, HasPrev: page > 1}
	return items, meta, rows.Err()
}

func userWhere(params listParams) (string, []any) {
	clauses := []string{"u.deleted_at IS NULL"}
	args := []any{}
	if params.Status != "" {
		args = append(args, params.Status)
		clauses = append(clauses, fmt.Sprintf("u.status=$%d", len(args)))
	}
	if params.Role != "" {
		args = append(args, params.Role)
		clauses = append(clauses, fmt.Sprintf("EXISTS (SELECT 1 FROM user_roles ur JOIN roles r ON r.id=ur.role_id WHERE ur.user_id=u.id AND r.code=$%d)", len(args)))
	}
	if params.WithoutSurveyorProfile {
		clauses = append(clauses, "NOT EXISTS (SELECT 1 FROM surveyor_profiles sp WHERE sp.user_id=u.id AND sp.deleted_at IS NULL)")
	}
	if strings.TrimSpace(params.Search) != "" {
		args = append(args, "%"+strings.TrimSpace(params.Search)+"%")
		clauses = append(clauses, fmt.Sprintf("(u.name LIKE $%d OR u.email LIKE $%d OR u.username LIKE $%d)", len(args), len(args), len(args)))
	}
	return "WHERE " + strings.Join(clauses, " AND "), args
}

func normalizePagination(page, perPage int) (int, int) {
	if page < 1 {
		page = 1
	}
	if perPage < 1 {
		perPage = 20
	}
	if perPage > 100 {
		perPage = 100
	}
	return page, perPage
}
