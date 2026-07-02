package dashboard

import (
	"context"
	"net/http"

	"github.com/gin-gonic/gin"

	apphttp "container-survey/services/api/internal/apphttp"
	"container-survey/services/api/internal/auth"
	"container-survey/services/api/internal/database"
	"container-survey/services/api/internal/middleware"
)

type AdminMetrics struct {
	TotalJobs        int `json:"total_jobs"`
	DraftJobs        int `json:"draft_jobs"`
	AssignedJobs     int `json:"assigned_jobs"`
	SurveyInProgress int `json:"survey_in_progress"`
	SubmittedSurveys int `json:"submitted_surveys"`
	NeedRevision     int `json:"need_revision_surveys"`
	ApprovedSurveys  int `json:"approved_surveys"`
	ReportGenerated  int `json:"report_generated"`
	ReadyToInvoice   int `json:"ready_to_invoice"`
	OverdueJobs      int `json:"overdue_jobs"`
}

type Repository struct{ pool *database.Pool }

func NewRepository(pool *database.Pool) Repository { return Repository{pool: pool} }

func (r Repository) Admin(ctx context.Context) (AdminMetrics, error) {
	var result AdminMetrics
	queries := []struct {
		target *int
		query  string
	}{
		{&result.TotalJobs, "SELECT COUNT(*) FROM job_orders WHERE deleted_at IS NULL"},
		{&result.DraftJobs, "SELECT COUNT(*) FROM job_orders WHERE status='draft' AND deleted_at IS NULL"},
		{&result.AssignedJobs, "SELECT COUNT(*) FROM job_orders WHERE status='assigned' AND deleted_at IS NULL"},
		{&result.SurveyInProgress, "SELECT COUNT(*) FROM surveys WHERE status='draft' AND deleted_at IS NULL"},
		{&result.SubmittedSurveys, "SELECT COUNT(*) FROM surveys WHERE status='submitted' AND deleted_at IS NULL"},
		{&result.NeedRevision, "SELECT COUNT(*) FROM surveys WHERE status='need_revision' AND deleted_at IS NULL"},
		{&result.ApprovedSurveys, "SELECT COUNT(*) FROM surveys WHERE status='approved' AND deleted_at IS NULL"},
		{&result.ReportGenerated, "SELECT COUNT(*) FROM reports WHERE status IN ('generated','finalized')"},
		{&result.ReadyToInvoice, "SELECT COUNT(*) FROM reports r JOIN surveys s ON s.id=r.survey_id WHERE s.status='approved' AND r.status NOT IN ('void','superseded') AND NOT EXISTS (SELECT 1 FROM invoice_items ii JOIN invoices i ON i.id=ii.invoice_id WHERE ii.report_id=r.id AND i.status NOT IN ('cancelled','void'))"},
		{&result.OverdueJobs, "SELECT COUNT(*) FROM job_orders WHERE deadline < NOW() AND deleted_at IS NULL AND status NOT IN ('paid','closed','cancelled')"},
	}
	for _, item := range queries {
		if err := r.pool.QueryRow(ctx, item.query).Scan(item.target); err != nil {
			return AdminMetrics{}, err
		}
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
