package masterdata

import (
	"errors"
	"net/http"
	"strconv"
	"strings"

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
	handler := NewHandler(service)
	master := v1.Group("/master")

	handler.resource(master, authService, "/customers", Resources["customers"])
	handler.resource(master, authService, "/locations", Resources["locations"])
	handler.resource(master, authService, "/surveyors", Resources["surveyors"])
	handler.resource(master, authService, "/container-types", Resources["container_types"])
	handler.resource(master, authService, "/survey-types", Resources["survey_types"])
	handler.resource(master, authService, "/cedex/locations", Resources["cedex_locations"])
	handler.resource(master, authService, "/cedex/components", Resources["cedex_components"])
	handler.resource(master, authService, "/cedex/damages", Resources["cedex_damages"])
	handler.resource(master, authService, "/cedex/repairs", Resources["cedex_repairs"])
	handler.resource(master, authService, "/cedex/materials", Resources["cedex_materials"])
	handler.resource(master, authService, "/responsibility-codes", Resources["responsibility_codes"])
}

func (h Handler) resource(group *gin.RouterGroup, authService *auth.Service, path string, resource Resource) {
	view := middleware.RequirePermission(authService, resource.Name+".view.all")
	create := middleware.RequirePermission(authService, resource.Name+".create.all")
	update := middleware.RequirePermission(authService, resource.Name+".update.all")
	deletePermission := middleware.RequirePermission(authService, resource.Name+".delete.all")

	group.GET(path, view, h.List(resource))
	group.POST(path, create, h.Create(resource))
	group.GET(path+"/:id", view, h.Get(resource))
	group.PUT(path+"/:id", update, h.Update(resource))
	group.DELETE(path+"/:id", deletePermission, h.Delete(resource))
}

func (h Handler) List(resource Resource) gin.HandlerFunc {
	return func(c *gin.Context) {
		result, err := h.service.List(c.Request.Context(), resource, listParams(c, resource))
		if err != nil {
			h.writeError(c, err)
			return
		}
		apphttp.Paginated(c, "Data berhasil diambil.", result.Rows, apphttp.PaginationMeta{
			Page: result.Meta.Page, PerPage: result.Meta.PerPage, Total: result.Meta.Total,
			TotalPages: result.Meta.TotalPages, HasNext: result.Meta.HasNext, HasPrev: result.Meta.HasPrev,
		})
	}
}

func (h Handler) Get(resource Resource) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, ok := parseID(c)
		if !ok {
			return
		}
		item, err := h.service.Get(c.Request.Context(), resource, id)
		if err != nil {
			h.writeError(c, err)
			return
		}
		apphttp.OK(c, "Data berhasil diambil.", item)
	}
}

func (h Handler) Create(resource Resource) gin.HandlerFunc {
	return func(c *gin.Context) {
		payload, ok := parsePayload(c)
		if !ok {
			return
		}
		item, err := h.service.Create(c.Request.Context(), resource, payload, actorFromContext(c))
		if err != nil {
			h.writeError(c, err)
			return
		}
		apphttp.Created(c, "Data berhasil dibuat.", item)
	}
}

func (h Handler) Update(resource Resource) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, ok := parseID(c)
		if !ok {
			return
		}
		payload, ok := parsePayload(c)
		if !ok {
			return
		}
		item, err := h.service.Update(c.Request.Context(), resource, id, payload, actorFromContext(c))
		if err != nil {
			h.writeError(c, err)
			return
		}
		apphttp.OK(c, "Data berhasil diperbarui.", item)
	}
}

func (h Handler) Delete(resource Resource) gin.HandlerFunc {
	return func(c *gin.Context) {
		id, ok := parseID(c)
		if !ok {
			return
		}
		item, err := h.service.Delete(c.Request.Context(), resource, id, actorFromContext(c))
		if err != nil {
			h.writeError(c, err)
			return
		}
		apphttp.OK(c, "Data berhasil dinonaktifkan.", item)
	}
}

func (h Handler) writeError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, ErrNotFound):
		apphttp.Fail(c, http.StatusNotFound, "Data tidak ditemukan.", "NOT_FOUND", nil)
	case errors.Is(err, ErrDuplicate):
		apphttp.Fail(c, http.StatusConflict, "Kode sudah digunakan.", "DUPLICATE_RESOURCE", nil)
	case errors.Is(err, ErrInvalidInput):
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Validasi gagal.", "VALIDATION_ERROR", []apphttp.ErrorDetail{{Message: strings.TrimPrefix(err.Error(), ErrInvalidInput.Error()+": ")}})
	default:
		apphttp.Fail(c, http.StatusInternalServerError, "Terjadi kesalahan internal.", "INTERNAL_ERROR", nil)
	}
}

func listParams(c *gin.Context, resource Resource) ListParams {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "20"))
	filters := map[string]string{}
	for key := range resource.Filters {
		if key == "status" {
			continue
		}
		filters[key] = c.Query(key)
	}
	return ListParams{
		Page: page, PerPage: perPage, Search: c.Query("search"), Status: c.Query("status"),
		SortBy: c.Query("sort_by"), SortOrder: c.Query("sort_order"), Filters: filters,
	}
}

func parseID(c *gin.Context) (uuid.UUID, bool) {
	id, err := uuid.Parse(c.Param("id"))
	if err != nil {
		apphttp.Fail(c, http.StatusBadRequest, "ID tidak valid.", "VALIDATION_ERROR", []apphttp.ErrorDetail{{Field: "id", Message: "ID harus UUID."}})
		return uuid.Nil, false
	}
	return id, true
}

func parsePayload(c *gin.Context) (map[string]any, bool) {
	payload := map[string]any{}
	if err := c.ShouldBindJSON(&payload); err != nil {
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Validasi gagal.", "VALIDATION_ERROR", []apphttp.ErrorDetail{{Message: "Request body JSON tidak valid."}})
		return nil, false
	}
	return payload, true
}

func actorFromContext(c *gin.Context) Actor {
	principal, _ := auth.PrincipalFromContext(c)
	return Actor{UserID: principal.ID, ActiveRole: principal.ActiveRole, RequestID: c.GetString("request_id"), IPAddress: c.ClientIP(), UserAgent: c.Request.UserAgent()}
}
