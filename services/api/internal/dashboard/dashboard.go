package dashboard

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"

	apphttp "container-survey/services/api/internal/apphttp"
	"container-survey/services/api/internal/auth"
	"container-survey/services/api/internal/database"
	"container-survey/services/api/internal/middleware"
)

type AdminMetrics struct {
	NewJobs                  int             `json:"new_jobs"`
	UnassignedJobs           int             `json:"unassigned_jobs"`
	SurveyInProgress         int             `json:"survey_in_progress"`
	SubmittedSurveys         int             `json:"submitted_surveys"`
	NeedRevision             int             `json:"need_revision_surveys"`
	ApprovedSurveys          int             `json:"approved_surveys"`
	IncompleteCustomerMaster int             `json:"incomplete_customer_master"`
	RecentActivities         []AdminActivity `json:"recent_activities"`
}

type AdminActivity struct {
	ID          string    `json:"id"`
	JobOrderID  string    `json:"job_order_id"`
	Event       string    `json:"event"`
	Title       string    `json:"title"`
	Description string    `json:"description"`
	Actor       string    `json:"actor"`
	CreatedAt   time.Time `json:"created_at"`
}

type Repository struct{ pool *database.Pool }

func NewRepository(pool *database.Pool) Repository { return Repository{pool: pool} }

func (r Repository) Admin(ctx context.Context) (AdminMetrics, error) {
	var result AdminMetrics
	queries := []struct {
		target *int
		query  string
	}{
		{&result.NewJobs, "SELECT COUNT(*) FROM job_orders WHERE status='draft' AND deleted_at IS NULL"},
		{&result.UnassignedJobs, "SELECT COUNT(*) FROM job_orders jo WHERE jo.deleted_at IS NULL AND jo.status NOT IN ('cancelled','closed') AND NOT EXISTS (SELECT 1 FROM assignments a WHERE a.job_order_id=jo.id AND a.status<>'cancelled')"},
		{&result.SurveyInProgress, "SELECT COUNT(*) FROM surveys WHERE status IN ('draft','in_progress') AND deleted_at IS NULL"},
		{&result.SubmittedSurveys, "SELECT COUNT(*) FROM surveys WHERE status='submitted' AND deleted_at IS NULL"},
		{&result.NeedRevision, "SELECT COUNT(*) FROM surveys WHERE status='need_revision' AND deleted_at IS NULL"},
		{&result.ApprovedSurveys, "SELECT COUNT(*) FROM surveys WHERE status='approved' AND deleted_at IS NULL"},
		{&result.IncompleteCustomerMaster, `SELECT COUNT(*) FROM customers c WHERE c.status='active' AND c.deleted_at IS NULL AND (
			COALESCE(NULLIF(TRIM(c.address),''),'')='' OR
			NOT EXISTS (SELECT 1 FROM customer_personnel p WHERE p.customer_id=c.id AND p.status='active' AND p.deleted_at IS NULL) OR
			NOT EXISTS (SELECT 1 FROM locations l WHERE l.customer_id=c.id AND l.status='active') OR
			NOT EXISTS (SELECT 1 FROM survey_types st WHERE st.customer_id=c.id AND st.status='active') OR
			NOT EXISTS (SELECT 1 FROM container_types ct WHERE ct.customer_id=c.id AND ct.status='active') OR
			NOT EXISTS (SELECT 1 FROM fitness_checklist_templates t WHERE t.customer_id=c.id AND t.status='active' AND t.deleted_at IS NULL AND EXISTS (SELECT 1 FROM fitness_checklist_template_items i WHERE i.template_id=t.id AND i.status='active')) OR
			NOT EXISTS (SELECT 1 FROM customer_survey_type_severities m WHERE m.customer_id=c.id AND m.is_active=1) OR
			NOT EXISTS (SELECT 1 FROM customer_survey_type_test_parameters m WHERE m.customer_id=c.id AND m.is_active=1) OR
			NOT EXISTS (SELECT 1 FROM customer_survey_type_photo_categories m WHERE m.customer_id=c.id AND m.is_active=1) OR
			NOT EXISTS (SELECT 1 FROM cedex_locations x WHERE x.customer_id=c.id AND x.status='active') OR
			NOT EXISTS (SELECT 1 FROM cedex_components x WHERE x.customer_id=c.id AND x.status='active') OR
			NOT EXISTS (SELECT 1 FROM cedex_damages x WHERE x.customer_id=c.id AND x.status='active') OR
			NOT EXISTS (SELECT 1 FROM cedex_repairs x WHERE x.customer_id=c.id AND x.status='active') OR
			NOT EXISTS (SELECT 1 FROM cedex_materials x WHERE x.customer_id=c.id AND x.status='active') OR
			NOT EXISTS (SELECT 1 FROM responsibility_codes x WHERE x.customer_id=c.id AND x.status='active')
		)`},
	}
	for _, item := range queries {
		if err := r.pool.QueryRow(ctx, item.query).Scan(item.target); err != nil {
			return AdminMetrics{}, err
		}
	}
	rows, err := r.pool.Query(ctx, `
		SELECT event.id, event.job_order_id, event.event_type, event.event_title,
		       COALESCE(event.event_description,''), COALESCE(actor.name,'Sistem'), event.created_at
		FROM job_events event
		LEFT JOIN users actor ON actor.id=event.actor_id
		ORDER BY event.created_at DESC
		LIMIT 8
	`)
	if err != nil {
		return AdminMetrics{}, err
	}
	defer rows.Close()
	result.RecentActivities = []AdminActivity{}
	for rows.Next() {
		var item AdminActivity
		if err := rows.Scan(&item.ID, &item.JobOrderID, &item.Event, &item.Title, &item.Description, &item.Actor, &item.CreatedAt); err != nil {
			return AdminMetrics{}, err
		}
		result.RecentActivities = append(result.RecentActivities, item)
	}
	if err := rows.Err(); err != nil {
		return AdminMetrics{}, err
	}
	return result, nil
}

type Service struct{ repo Repository }

func NewService(repo Repository) *Service                          { return &Service{repo: repo} }
func (s *Service) Admin(ctx context.Context) (AdminMetrics, error) { return s.repo.Admin(ctx) }

func Register(v1 *gin.RouterGroup, authService *auth.Service, service *Service) {
	v1.GET("/dashboard/admin", middleware.RequirePermission(authService, "dashboard.view.all"), func(c *gin.Context) {
		result, err := service.Admin(c.Request.Context())
		if err != nil {
			apphttp.Fail(c, http.StatusInternalServerError, "Gagal mengambil dashboard Admin.", "INTERNAL_ERROR", nil)
			return
		}
		apphttp.OK(c, "Dashboard Admin berhasil diambil.", result)
	})
}
