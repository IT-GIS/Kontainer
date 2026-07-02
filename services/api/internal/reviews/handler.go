package reviews

import (
	"errors"
	"fmt"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	apphttp "container-survey/services/api/internal/apphttp"
	"container-survey/services/api/internal/auth"
	"container-survey/services/api/internal/middleware"
)

type Handler struct {
	service *Service
}

func NewHandler(service *Service) Handler {
	return Handler{service: service}
}

func Register(v1 *gin.RouterGroup, authService *auth.Service, service *Service) {
	h := NewHandler(service)
	v1.GET("/surveys/monitoring", middleware.RequirePermission(authService, "surveys.view.all"), h.Monitoring)
	v1.GET("/reviews", middleware.RequirePermission(authService, "reviews.view.all"), h.ListReviews)
	v1.GET("/reviews/:id", middleware.RequirePermission(authService, "reviews.view.all"), h.GetReviewOrPending)
	v1.POST("/reviews/:id/:action", middleware.RequirePermission(authService, "reviews.manage.all"), h.ReviewAction)

	v1.GET("/reports", middleware.RequirePermission(authService, "reports.view.all"), h.ListReports)
	v1.GET("/reports/:id", middleware.RequirePermission(authService, "reports.view.all"), h.ReportDetail)
	v1.GET("/reports/:id/versions", middleware.RequirePermission(authService, "reports.view.all"), h.ReportVersions)
	v1.GET("/reports/:id/download", middleware.RequirePermission(authService, "reports.view.all"), h.DownloadReport)
	v1.POST("/reports/generate/:id", middleware.RequirePermission(authService, "reports.generate.all"), h.GenerateReport)
}

func (h Handler) Monitoring(c *gin.Context) {
	result, err := h.service.Monitoring(c.Request.Context(), listParams(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Paginated(c, "Monitoring survey berhasil diambil.", result.Rows, apphttp.PaginationMeta{Page: result.Meta.Page, PerPage: result.Meta.PerPage, Total: result.Meta.Total, TotalPages: result.Meta.TotalPages, HasNext: result.Meta.HasNext, HasPrev: result.Meta.HasPrev})
}

func (h Handler) ListReviews(c *gin.Context) {
	result, err := h.service.Reviews(c.Request.Context(), listParams(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Paginated(c, "Riwayat review berhasil diambil.", result.Rows, apphttp.PaginationMeta{Page: result.Meta.Page, PerPage: result.Meta.PerPage, Total: result.Meta.Total, TotalPages: result.Meta.TotalPages, HasNext: result.Meta.HasNext, HasPrev: result.Meta.HasPrev})
}

func RegisterPublic(v1 *gin.RouterGroup, service *Service) {
	h := NewHandler(service)
	v1.GET("/reports/validate/:qr_token", h.ValidateQR)
}

func (h Handler) GetReviewOrPending(c *gin.Context) {
	if c.Param("id") == "pending" {
		result, err := h.service.Pending(c.Request.Context(), listParams(c))
		if err != nil {
			h.writeError(c, err)
			return
		}
		apphttp.Paginated(c, "Pending review berhasil diambil.", result.Rows, apphttp.PaginationMeta{Page: result.Meta.Page, PerPage: result.Meta.PerPage, Total: result.Meta.Total, TotalPages: result.Meta.TotalPages, HasNext: result.Meta.HasNext, HasPrev: result.Meta.HasPrev})
		return
	}
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.Detail(c.Request.Context(), id)
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Detail review berhasil diambil.", item)
}

func (h Handler) ReviewAction(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	switch c.Param("action") {
	case "need-revision":
		var input NeedRevisionInput
		if !bindJSON(c, &input) {
			return
		}
		item, err := h.service.NeedRevision(c.Request.Context(), id, input, actorFromContext(c))
		if err != nil {
			h.writeError(c, err)
			return
		}
		apphttp.OK(c, "Survey dikembalikan untuk revisi.", item)
	case "approve":
		var input ApproveInput
		if !bindJSON(c, &input) {
			return
		}
		item, err := h.service.Approve(c.Request.Context(), id, input, actorFromContext(c))
		if err != nil {
			h.writeError(c, err)
			return
		}
		apphttp.OK(c, "Survey berhasil disetujui.", item)
	case "reject":
		var input RejectInput
		if !bindJSON(c, &input) {
			return
		}
		item, err := h.service.Reject(c.Request.Context(), id, input, actorFromContext(c))
		if err != nil {
			h.writeError(c, err)
			return
		}
		apphttp.OK(c, "Survey berhasil ditolak.", item)
	default:
		apphttp.Fail(c, http.StatusNotFound, "Aksi review tidak ditemukan.", "NOT_FOUND", nil)
	}
}

func (h Handler) ListReports(c *gin.Context) {
	result, err := h.service.ListReports(c.Request.Context(), listParams(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Paginated(c, "Report archive berhasil diambil.", result.Rows, apphttp.PaginationMeta{Page: result.Meta.Page, PerPage: result.Meta.PerPage, Total: result.Meta.Total, TotalPages: result.Meta.TotalPages, HasNext: result.Meta.HasNext, HasPrev: result.Meta.HasPrev})
}

func (h Handler) ReportDetail(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.ReportDetail(c.Request.Context(), id)
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Detail report berhasil diambil.", item)
}

func (h Handler) ReportVersions(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	items, err := h.service.ReportVersions(c.Request.Context(), id)
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Versi report berhasil diambil.", items)
}

func (h Handler) DownloadReport(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.ReportDetail(c.Request.Context(), id)
	if err != nil {
		h.writeError(c, err)
		return
	}
	content := fmt.Sprintf("Report %s is queued for PDF generation.\n", item["report_no"])
	c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%s.pdf", item["report_no"]))
	c.Data(http.StatusOK, "application/pdf", []byte(content))
}

func (h Handler) GenerateReport(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input GenerateReportInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.GenerateReport(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Accepted(c, "Generate report masuk antrean.", item)
}

func (h Handler) ValidateQR(c *gin.Context) {
	item, err := h.service.ValidateQR(c.Request.Context(), c.Param("qr_token"))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Report valid.", item)
}

func (h Handler) writeError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, ErrNotFound):
		apphttp.Fail(c, http.StatusNotFound, "Data tidak ditemukan.", "NOT_FOUND", nil)
	case errors.Is(err, ErrInvalidStatus):
		apphttp.Fail(c, http.StatusConflict, "Status tidak valid untuk aksi ini.", "INVALID_STATUS_TRANSITION", nil)
	case errors.Is(err, ErrInvalidInput):
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Validasi gagal.", "VALIDATION_ERROR", nil)
	case errors.Is(err, ErrDuplicate):
		apphttp.Fail(c, http.StatusConflict, "Data duplikat.", "DUPLICATE_RESOURCE", nil)
	default:
		apphttp.Fail(c, http.StatusInternalServerError, "Terjadi kesalahan internal.", "INTERNAL_ERROR", nil)
	}
}

func listParams(c *gin.Context) ListParams {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "20"))
	return ListParams{Page: page, PerPage: perPage, Search: c.Query("search"), Status: c.Query("status"), CustomerID: c.Query("customer_id"), SurveyTypeID: c.Query("survey_type_id")}
}

func parseID(c *gin.Context) (uuid.UUID, bool) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		apphttp.Fail(c, http.StatusBadRequest, "ID tidak valid.", "VALIDATION_ERROR", nil)
		return uuid.Nil, false
	}
	return id, true
}

func bindJSON(c *gin.Context, out any) bool {
	if err := c.ShouldBindJSON(out); err != nil {
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Validasi gagal.", "VALIDATION_ERROR", nil)
		return false
	}
	return true
}

func actorFromContext(c *gin.Context) Actor {
	principal, _ := auth.PrincipalFromContext(c)
	return Actor{UserID: principal.ID, ActiveRole: principal.ActiveRole, RequestID: c.GetString("request_id"), IPAddress: c.ClientIP(), UserAgent: c.Request.UserAgent()}
}
