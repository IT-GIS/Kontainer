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

	fitnessMaster := v1.Group("/fitness/master-data")
	handler.resource(fitnessMaster, authService, "/owners", Resources["customers"])
	handler.resource(fitnessMaster, authService, "/manufacturers", Resources["container_manufacturers"])
	handler.resource(fitnessMaster, authService, "/locations", Resources["locations"])
	handler.resource(fitnessMaster, authService, "/surveyors", Resources["surveyors"])
	handler.resource(fitnessMaster, authService, "/container-types", Resources["container_types"])
	handler.resource(fitnessMaster, authService, "/approval-categories", Resources["fitness_approval_categories"])
	handler.resource(fitnessMaster, authService, "/maintenance-schemes", Resources["maintenance_schemes"])
	handler.resource(fitnessMaster, authService, "/inspection-areas", Resources["inspection_areas"])
	handler.resource(fitnessMaster, authService, "/structural-components", Resources["structural_components"])
	handler.resource(fitnessMaster, authService, "/damage-criteria", Resources["structural_damage_criteria"])
	handler.resource(fitnessMaster, authService, "/finding-severities", Resources["finding_severities"])
	handler.resource(fitnessMaster, authService, "/test-parameters", Resources["inspection_test_parameters"])
	handler.resource(fitnessMaster, authService, "/checklist-templates", Resources["fitness_checklist_templates"])
	checklistTemplateItems := Resources["fitness_checklist_template_items"]
	handler.resourceItems(fitnessMaster, authService, "/checklist-templates/:id/items", checklistTemplateItems, "template_id")
	handler.resource(fitnessMaster, authService, "/photo-categories", Resources["evidence_photo_categories"])
	handler.resource(fitnessMaster, authService, "/inspection-recommendations", Resources["inspection_recommendations"])
	handler.resource(fitnessMaster, authService, "/authorized-signers", Resources["authorized_signers"])
	handler.resource(fitnessMaster, authService, "/company-profile", Resources["company_profiles"])
}

func (h Handler) resource(group *gin.RouterGroup, authService *auth.Service, path string, resource Resource) {
	module := resource.permissionModule()
	view := middleware.RequirePermission(authService, module+".view.all")
	create := middleware.RequirePermission(authService, module+".create.all")
	update := middleware.RequirePermission(authService, module+".update.all")
	deletePermission := middleware.RequirePermission(authService, module+".delete.all")

	group.GET(path, view, h.List(resource))
	group.POST(path, create, h.Create(resource))
	group.GET(path+"/:id", view, h.Get(resource))
	group.PUT(path+"/:id", update, h.Update(resource))
	group.DELETE(path+"/:id", deletePermission, h.Delete(resource))
}

func (h Handler) resourceItems(group *gin.RouterGroup, authService *auth.Service, path string, resource Resource, parentField string) {
	module := resource.permissionModule()
	view := middleware.RequirePermission(authService, module+".view.all")
	create := middleware.RequirePermission(authService, module+".create.all")
	update := middleware.RequirePermission(authService, module+".update.all")
	deletePermission := middleware.RequirePermission(authService, module+".delete.all")

	group.GET(path, view, h.ListForParent(resource, parentField))
	group.POST(path, create, h.CreateForParent(resource, parentField))
	group.GET(path+"/:item_id", view, h.GetForParent(resource, parentField))
	group.PUT(path+"/:item_id", update, h.UpdateForParent(resource, parentField))
	group.DELETE(path+"/:item_id", deletePermission, h.DeleteForParent(resource, parentField))
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

func (h Handler) ListForParent(resource Resource, parentField string) gin.HandlerFunc {
	return func(c *gin.Context) {
		parentID, ok := parseUUIDParam(c, "id")
		if !ok {
			return
		}
		params := listParams(c, resource)
		params.Filters[parentField] = parentID.String()
		result, err := h.service.List(c.Request.Context(), resource, params)
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

func (h Handler) GetForParent(resource Resource, parentField string) gin.HandlerFunc {
	return func(c *gin.Context) {
		parentID, ok := parseUUIDParam(c, "id")
		if !ok {
			return
		}
		id, ok := parseUUIDParam(c, "item_id")
		if !ok {
			return
		}
		item, err := h.service.Get(c.Request.Context(), resource, id)
		if err != nil {
			h.writeError(c, err)
			return
		}
		if !belongsToParent(item, parentField, parentID) {
			h.writeError(c, ErrNotFound)
			return
		}
		apphttp.OK(c, "Data berhasil diambil.", item)
	}
}

func (h Handler) CreateForParent(resource Resource, parentField string) gin.HandlerFunc {
	return func(c *gin.Context) {
		parentID, ok := parseUUIDParam(c, "id")
		if !ok {
			return
		}
		payload, ok := parsePayload(c)
		if !ok {
			return
		}
		payload[parentField] = parentID.String()
		item, err := h.service.Create(c.Request.Context(), resource, payload, actorFromContext(c))
		if err != nil {
			h.writeError(c, err)
			return
		}
		apphttp.Created(c, "Data berhasil dibuat.", item)
	}
}

func (h Handler) UpdateForParent(resource Resource, parentField string) gin.HandlerFunc {
	return func(c *gin.Context) {
		parentID, ok := parseUUIDParam(c, "id")
		if !ok {
			return
		}
		id, ok := parseUUIDParam(c, "item_id")
		if !ok {
			return
		}
		current, err := h.service.Get(c.Request.Context(), resource, id)
		if err != nil {
			h.writeError(c, err)
			return
		}
		if !belongsToParent(current, parentField, parentID) {
			h.writeError(c, ErrNotFound)
			return
		}
		payload, ok := parsePayload(c)
		if !ok {
			return
		}
		payload[parentField] = parentID.String()
		item, err := h.service.Update(c.Request.Context(), resource, id, payload, actorFromContext(c))
		if err != nil {
			h.writeError(c, err)
			return
		}
		apphttp.OK(c, "Data berhasil diperbarui.", item)
	}
}

func (h Handler) DeleteForParent(resource Resource, parentField string) gin.HandlerFunc {
	return func(c *gin.Context) {
		parentID, ok := parseUUIDParam(c, "id")
		if !ok {
			return
		}
		id, ok := parseUUIDParam(c, "item_id")
		if !ok {
			return
		}
		current, err := h.service.Get(c.Request.Context(), resource, id)
		if err != nil {
			h.writeError(c, err)
			return
		}
		if !belongsToParent(current, parentField, parentID) {
			h.writeError(c, ErrNotFound)
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

func parseUUIDParam(c *gin.Context, name string) (uuid.UUID, bool) {
	id, err := uuid.Parse(c.Param(name))
	if err != nil {
		apphttp.Fail(c, http.StatusBadRequest, "ID tidak valid.", "VALIDATION_ERROR", []apphttp.ErrorDetail{{Field: name, Message: "ID harus UUID."}})
		return uuid.Nil, false
	}
	return id, true
}

func belongsToParent(item map[string]any, parentField string, parentID uuid.UUID) bool {
	return strings.EqualFold(strings.TrimSpace(stringValue(item[parentField])), parentID.String())
}

func (resource Resource) permissionModule() string {
	if strings.TrimSpace(resource.PermissionModule) != "" {
		return resource.PermissionModule
	}
	return resource.Name
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
