package jobs

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	apphttp "container-survey/services/api/internal/apphttp"
	"container-survey/services/api/internal/auth"
	"container-survey/services/api/internal/middleware"
)

type Handler struct{ service *Service }

func NewHandler(service *Service) Handler { return Handler{service: service} }

func Register(v1 *gin.RouterGroup, authService *auth.Service, service *Service) {
	h := NewHandler(service)
	v1.GET("/jobs", middleware.RequirePermission(authService, "jobs.view.all"), h.ListJobs)
	v1.POST("/jobs", middleware.RequirePermission(authService, "jobs.create.all"), h.CreateJob)
	v1.GET("/jobs/:id", middleware.RequirePermission(authService, "jobs.view.all"), h.GetJob)
	v1.PUT("/jobs/:id", middleware.RequirePermission(authService, "jobs.update.all"), h.UpdateJob)
	v1.POST("/jobs/:id/cancel", middleware.RequirePermission(authService, "jobs.cancel.all"), h.CancelJob)
	v1.GET("/jobs/:id/timeline", middleware.RequirePermission(authService, "jobs.view.all"), h.Timeline)
	v1.GET("/jobs/:id/containers", middleware.RequirePermission(authService, "job_containers.view.all"), h.ListContainers)
	v1.POST("/jobs/:id/containers", middleware.RequirePermission(authService, "job_containers.create.all"), h.AddContainer)
	v1.POST("/jobs/:id/containers/import", middleware.RequirePermission(authService, "job_containers.import.all"), h.ImportContainers)
	v1.POST("/jobs/:id/containers/import/preview", middleware.RequirePermission(authService, "job_containers.import.all"), h.PreviewImport)
	v1.POST("/jobs/:id/containers/import/confirm", middleware.RequirePermission(authService, "job_containers.import.all"), h.ConfirmImport)
	v1.POST("/jobs/:id/assign", middleware.RequirePermission(authService, "assignments.assign.all"), h.Assign)
	v1.GET("/jobs/:id/assignments", middleware.RequirePermission(authService, "assignments.view.all"), h.ListAssignments)
	v1.POST("/job-containers/validate-container-no", middleware.RequirePermission(authService, "job_containers.view.all"), h.ValidateContainerNo)
	v1.GET("/job-containers/import/template", middleware.RequirePermission(authService, "job_containers.import.all"), h.ImportTemplate)
	v1.POST("/job-containers/:id/reassign", middleware.RequirePermission(authService, "job_containers.reassign.all"), h.Reassign)
}

func (h Handler) PreviewImport(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	file, err := c.FormFile("file")
	if err != nil {
		apphttp.Fail(c, http.StatusUnprocessableEntity, "File CSV/XLSX wajib diisi.", "VALIDATION_ERROR", nil)
		return
	}
	opened, err := file.Open()
	if err != nil {
		h.writeError(c, err)
		return
	}
	defer opened.Close()
	result, err := h.service.PreviewImport(c.Request.Context(), id, opened, file.Filename)
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Preview import berhasil dibuat.", result)
}

func (h Handler) ConfirmImport(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input ImportConfirmInput
	if !bindJSON(c, &input) {
		return
	}
	result, err := h.service.ConfirmImport(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Import container selesai.", result)
}

func (h Handler) ImportTemplate(c *gin.Context) {
	data, contentType, filename, err := BuildImportTemplate(c.DefaultQuery("format", "csv"))
	if err != nil {
		h.writeError(c, err)
		return
	}
	c.Header("Content-Disposition", "attachment; filename="+filename)
	c.Data(http.StatusOK, contentType, data)
}

func (h Handler) ListJobs(c *gin.Context) {
	result, err := h.service.ListJobs(c.Request.Context(), listParams(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Paginated(c, "Job order berhasil diambil.", result.Rows, apphttp.PaginationMeta{Page: result.Meta.Page, PerPage: result.Meta.PerPage, Total: result.Meta.Total, TotalPages: result.Meta.TotalPages, HasNext: result.Meta.HasNext, HasPrev: result.Meta.HasPrev})
}

func (h Handler) CreateJob(c *gin.Context) {
	var input JobInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.CreateJob(c.Request.Context(), input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Created(c, "Job order berhasil dibuat.", item)
}

func (h Handler) GetJob(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.GetJob(c.Request.Context(), id)
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Job order berhasil diambil.", item)
}
func (h Handler) Timeline(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	items, err := h.service.Timeline(c.Request.Context(), id)
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Timeline berhasil diambil.", items)
}
func (h Handler) ListAssignments(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	items, err := h.service.ListAssignments(c.Request.Context(), id)
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Assignment berhasil diambil.", items)
}

func (h Handler) UpdateJob(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input JobInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.UpdateJob(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Job order berhasil diperbarui.", item)
}

func (h Handler) CancelJob(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input CancelInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.CancelJob(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Job order berhasil dibatalkan.", item)
}

func (h Handler) ListContainers(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	result, err := h.service.ListContainers(c.Request.Context(), id, listParams(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Paginated(c, "Container berhasil diambil.", result.Rows, apphttp.PaginationMeta{Page: result.Meta.Page, PerPage: result.Meta.PerPage, Total: result.Meta.Total, TotalPages: result.Meta.TotalPages, HasNext: result.Meta.HasNext, HasPrev: result.Meta.HasPrev})
}

func (h Handler) AddContainer(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input ContainerInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.AddContainer(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Created(c, "Container berhasil ditambahkan.", item)
}

func (h Handler) ImportContainers(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	file, err := c.FormFile("file")
	if err != nil {
		apphttp.Fail(c, http.StatusUnprocessableEntity, "File import wajib diisi.", "VALIDATION_ERROR", nil)
		return
	}
	opened, err := file.Open()
	if err != nil {
		h.writeError(c, err)
		return
	}
	defer opened.Close()
	result, err := h.service.ImportContainers(c.Request.Context(), id, opened, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Import selesai.", result)
}

func (h Handler) Assign(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input AssignInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.Assign(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Surveyor berhasil ditugaskan.", item)
}

func (h Handler) Reassign(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input ReassignInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.Reassign(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Container berhasil dialihkan.", item)
}

func (h Handler) ValidateContainerNo(c *gin.Context) {
	var input struct {
		ContainerNo string `json:"container_no"`
	}
	if !bindJSON(c, &input) {
		return
	}
	apphttp.OK(c, "Validasi selesai.", ValidateContainerNumber(input.ContainerNo))
}

func (h Handler) writeError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, ErrNotFound):
		apphttp.Fail(c, http.StatusNotFound, "Data tidak ditemukan.", "NOT_FOUND", nil)
	case errors.Is(err, ErrDuplicate):
		apphttp.Fail(c, http.StatusConflict, "Data duplikat.", "DUPLICATE_RESOURCE", nil)
	case errors.Is(err, ErrInvalidStatus), errors.Is(err, ErrForbiddenState):
		apphttp.Fail(c, http.StatusConflict, "Status tidak valid untuk aksi ini.", "INVALID_STATUS_TRANSITION", nil)
	case errors.Is(err, ErrInvalidInput):
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Validasi gagal.", "VALIDATION_ERROR", nil)
	default:
		apphttp.Fail(c, http.StatusInternalServerError, "Terjadi kesalahan internal.", "INTERNAL_ERROR", nil)
	}
}

func listParams(c *gin.Context) ListParams {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "20"))
	return ListParams{Page: page, PerPage: perPage, Search: c.Query("search"), Status: c.Query("status"), CustomerID: c.Query("customer_id"), SurveyTypeID: c.Query("survey_type_id"), LocationID: c.Query("location_id"), DateFrom: c.Query("date_from"), DateTo: c.Query("date_to")}
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
