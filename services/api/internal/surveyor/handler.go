package surveyor

import (
	"errors"
	"fmt"
	"net/http"
	"path"
	"strconv"
	"time"

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
	v1.GET("/surveyor/dashboard", middleware.RequirePermission(authService, "surveyor_jobs.view.assigned"), h.Dashboard)
	v1.GET("/surveyor/jobs", middleware.RequirePermission(authService, "surveyor_jobs.view.assigned"), h.ListJobs)
	v1.GET("/surveyor/jobs/:id", middleware.RequirePermission(authService, "surveyor_jobs.view.assigned"), h.GetJob)
	v1.GET("/surveyor/jobs/:id/containers", middleware.RequirePermission(authService, "surveyor_jobs.view.assigned"), h.ListContainers)

	v1.POST("/surveys/:id", middleware.RequirePermission(authService, "surveys.start.assigned"), h.StartSurvey)
	v1.GET("/surveys/:id", middleware.RequirePermission(authService, "surveys.view.assigned"), h.GetSurvey)
	v1.PUT("/surveys/:id/general-info", middleware.RequirePermission(authService, "surveys.update.assigned"), h.UpdateGeneralInfo)
	v1.GET("/surveys/:id/checklist", middleware.RequirePermission(authService, "surveys.view.assigned"), h.Checklist)
	v1.PUT("/surveys/:id/checklist", middleware.RequirePermission(authService, "surveys.update.assigned"), h.UpdateChecklist)
	v1.GET("/surveys/:id/sheet", middleware.RequirePermission(authService, "surveys.view.assigned"), h.Sheet)
	v1.GET("/surveys/:id/damages", middleware.RequirePermission(authService, "survey_damages.view.assigned"), h.Damages)
	v1.POST("/surveys/:id/damages", middleware.RequirePermission(authService, "survey_damages.create.assigned"), h.CreateDamage)
	v1.GET("/surveys/:id/photos", middleware.RequirePermission(authService, "survey_photos.view.assigned"), h.Photos)
	v1.GET("/surveys/:id/preview", middleware.RequirePermission(authService, "surveys.view.assigned"), h.Preview)
	v1.POST("/surveys/:id/submit", middleware.RequirePermission(authService, "surveys.submit.assigned"), h.Submit)

	v1.PUT("/survey-damages/:id", middleware.RequirePermission(authService, "survey_damages.update.assigned"), h.UpdateDamage)
	v1.DELETE("/survey-damages/:id", middleware.RequirePermission(authService, "survey_damages.delete.assigned"), h.DeleteDamage)
	v1.POST("/survey-damages/:id/photos", middleware.RequirePermission(authService, "survey_photos.upload.assigned"), h.UploadPhoto)
	v1.GET("/survey-photos/:id/content", middleware.RequirePermission(authService, "survey_photos.view.assigned"), h.PhotoContent)
}

func (h Handler) Dashboard(c *gin.Context) {
	item, err := h.service.Dashboard(c.Request.Context(), actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Dashboard surveyor berhasil diambil.", item)
}

func (h Handler) ListJobs(c *gin.Context) {
	result, err := h.service.ListJobs(c.Request.Context(), listParams(c), actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Paginated(c, "Job saya berhasil diambil.", result.Rows, apphttp.PaginationMeta{Page: result.Meta.Page, PerPage: result.Meta.PerPage, Total: result.Meta.Total, TotalPages: result.Meta.TotalPages, HasNext: result.Meta.HasNext, HasPrev: result.Meta.HasPrev})
}

func (h Handler) GetJob(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.GetJob(c.Request.Context(), id, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Detail job saya berhasil diambil.", item)
}

func (h Handler) ListContainers(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	items, err := h.service.ListContainers(c.Request.Context(), id, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Container job saya berhasil diambil.", items)
}

func (h Handler) StartSurvey(c *gin.Context) {
	var input StartSurveyInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.StartSurvey(c.Request.Context(), input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Created(c, "Survey berhasil dimulai.", item)
}

func (h Handler) GetSurvey(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.GetSurvey(c.Request.Context(), id, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Survey berhasil diambil.", item)
}

func (h Handler) UpdateGeneralInfo(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input GeneralInfoInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.UpdateGeneralInfo(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "General info berhasil disimpan.", item)
}

func (h Handler) Checklist(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	items, err := h.service.Checklist(c.Request.Context(), id, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Checklist berhasil diambil.", items)
}

func (h Handler) UpdateChecklist(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input ChecklistInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.UpdateChecklist(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Checklist berhasil disimpan.", item)
}

func (h Handler) Sheet(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.Sheet(c.Request.Context(), id, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Survey sheet berhasil diambil.", item)
}

func (h Handler) Damages(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	items, err := h.service.Damages(c.Request.Context(), id, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Damage berhasil diambil.", items)
}

func (h Handler) CreateDamage(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input DamageInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.CreateDamage(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Created(c, "Damage berhasil ditambahkan.", item)
}

func (h Handler) UpdateDamage(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input DamageInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.UpdateDamage(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Damage berhasil diperbarui.", item)
}

func (h Handler) DeleteDamage(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.DeleteDamage(c.Request.Context(), id, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Damage berhasil dihapus.", item)
}

func (h Handler) UploadPhoto(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	maxBodyBytes := h.service.MaxUploadBytes() + 1024*1024
	c.Request.Body = http.MaxBytesReader(c.Writer, c.Request.Body, maxBodyBytes)
	file, err := c.FormFile("file")
	if err != nil {
		apphttp.Fail(c, http.StatusUnprocessableEntity, "File foto wajib diisi.", "VALIDATION_ERROR", nil)
		return
	}
	if file.Size <= 0 || file.Size > h.service.MaxUploadBytes() {
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Ukuran file foto tidak valid.", "VALIDATION_ERROR", nil)
		return
	}
	opened, err := file.Open()
	if err != nil {
		h.writeError(c, err)
		return
	}
	defer opened.Close()
	var takenAt *time.Time
	if value := c.PostForm("taken_at"); value != "" {
		parsed, parseErr := time.Parse(time.RFC3339, value)
		if parseErr != nil {
			apphttp.Fail(c, http.StatusUnprocessableEntity, "taken_at tidak valid.", "VALIDATION_ERROR", nil)
			return
		}
		takenAt = &parsed
	}
	input := PhotoInput{Reader: opened, FileName: file.Filename, ContentType: file.Header.Get("Content-Type"), Size: file.Size, Caption: c.PostForm("caption"), PhotoType: c.PostForm("photo_type"), PhotoCategory: c.PostForm("photo_category"), TakenAt: takenAt}
	item, err := h.service.UploadPhoto(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Created(c, "Foto evidence berhasil disimpan.", item)
}

func (h Handler) PhotoContent(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	content, err := h.service.PhotoContent(c.Request.Context(), id, c.DefaultQuery("variant", "watermarked"), actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	defer content.Reader.Close()
	disposition := "inline"
	if c.Query("download") == "1" {
		disposition = "attachment"
	}
	fileName := path.Base(content.FileName)
	c.Header("Content-Disposition", fmt.Sprintf(`%s; filename="%s"`, disposition, fileName))
	c.DataFromReader(http.StatusOK, content.Size, content.ContentType, content.Reader, nil)
}

func (h Handler) Photos(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	items, err := h.service.Photos(c.Request.Context(), id, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Foto evidence berhasil diambil.", items)
}

func (h Handler) Preview(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.Preview(c.Request.Context(), id, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Preview survey berhasil diambil.", item)
}

func (h Handler) Submit(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input SubmitInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.Submit(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Survey berhasil disubmit.", item)
}

func (h Handler) writeError(c *gin.Context, err error) {
	var validationErr SurveyValidationError
	switch {
	case errors.As(err, &validationErr):
		details := make([]apphttp.ErrorDetail, 0, len(validationErr.Warnings))
		for _, warning := range validationErr.Warnings {
			details = append(details, apphttp.ErrorDetail{Field: warning.Code, Message: warning.Message})
		}
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Validasi submit gagal.", "VALIDATION_ERROR", details)
	case errors.Is(err, ErrNotFound):
		apphttp.Fail(c, http.StatusNotFound, "Data tidak ditemukan.", "NOT_FOUND", nil)
	case errors.Is(err, ErrForbidden):
		apphttp.Fail(c, http.StatusForbidden, "Akses survey ditolak.", "FORBIDDEN", nil)
	case errors.Is(err, ErrInvalidStatus):
		apphttp.Fail(c, http.StatusConflict, "Status tidak valid untuk aksi ini.", "INVALID_STATUS_TRANSITION", nil)
	case errors.Is(err, ErrInvalidInput), errors.Is(err, ErrValidation):
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
	return ListParams{Page: page, PerPage: perPage, Search: c.Query("search"), Status: c.Query("status"), Date: c.Query("date")}
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
