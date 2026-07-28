package masterdata

import (
	"errors"
	"log/slog"
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
	handler.resource(master, authService, "/cedex/decision-rules", Resources["cedex_damage_decision_rules"])
	handler.resource(master, authService, "/cedex/repairs", Resources["cedex_repairs"])
	handler.resource(master, authService, "/cedex/materials", Resources["cedex_materials"])
	handler.resource(master, authService, "/cedex/code-proposals", Resources["cedex_code_proposals"])
	master.POST(
		"/cedex/code-proposals/:id/review",
		middleware.RequirePermission(authService, "cedex_code_proposals.review.all"),
		handler.ReviewCodeProposal,
	)
	handler.resource(master, authService, "/responsibility-codes", Resources["responsibility_codes"])
	v1.GET("/customers/readiness", middleware.RequirePermission(authService, "customers.view.all"), handler.ListCustomerReadiness)

	customerMaster := v1.Group("/customers/:id")
	customerMaster.GET("/readiness", middleware.RequirePermission(authService, "customers.view.all"), handler.GetCustomerReadiness)
	handler.resourceItems(customerMaster, authService, "/locations", customerScopedResource(Resources["locations"]), "customer_id")
	handler.resourceItems(customerMaster, authService, "/personnel", Resources["customer_personnel"], "customer_id")
	handler.resourceItems(customerMaster, authService, "/container-types", customerScopedResource(Resources["container_types"]), "customer_id")
	handler.resourceItems(customerMaster, authService, "/survey-types", customerScopedResource(Resources["survey_types"]), "customer_id")
	handler.resourceItems(customerMaster, authService, "/cedex/locations", customerScopedResource(Resources["cedex_locations"]), "customer_id")
	handler.resourceItems(customerMaster, authService, "/cedex/components", customerScopedResource(Resources["cedex_components"]), "customer_id")
	handler.resourceItems(customerMaster, authService, "/cedex/damages", customerScopedResource(Resources["cedex_damages"]), "customer_id")
	handler.resourceItems(customerMaster, authService, "/cedex/decision-rules", customerScopedResource(Resources["cedex_damage_decision_rules"]), "customer_id")
	handler.resourceItems(customerMaster, authService, "/cedex/repairs", customerScopedResource(Resources["cedex_repairs"]), "customer_id")
	handler.resourceItems(customerMaster, authService, "/cedex/materials", customerScopedResource(Resources["cedex_materials"]), "customer_id")
	handler.resourceItems(customerMaster, authService, "/responsibility-codes", customerScopedResource(Resources["responsibility_codes"]), "customer_id")
	handler.resourceItems(customerMaster, authService, "/checklist-templates", customerScopedResource(Resources["fitness_checklist_templates"]), "customer_id")
	customerMaster.GET("/personnel/:item_id/locations", middleware.RequirePermission(authService, "customers.view.all"), handler.GetPersonnelLocations)
	customerMaster.PUT("/personnel/:item_id/locations", middleware.RequirePermission(authService, "customers.update.all"), handler.SetPersonnelLocations)
	customerMaster.GET("/locations/:item_id/personnel", middleware.RequirePermission(authService, "customers.view.all"), handler.GetLocationPersonnel)
	customerMaster.GET("/survey-types/:item_id/reference-options", middleware.RequirePermission(authService, "survey_types.view.all"), handler.GetCustomerReferenceOptions)
	customerMaster.PUT("/survey-types/:item_id/reference-options", middleware.RequirePermission(authService, "survey_types.update.all"), handler.SetCustomerReferenceOptions)

	fitnessMaster := v1.Group("/fitness/master-data")
	handler.resource(fitnessMaster, authService, "/owners", fitnessAdminResource(Resources["customers"]))
	handler.resource(fitnessMaster, authService, "/manufacturers", fitnessAdminResource(Resources["container_manufacturers"]))
	handler.resource(fitnessMaster, authService, "/locations", fitnessAdminResource(Resources["locations"]))
	handler.resource(fitnessMaster, authService, "/surveyors", fitnessAdminResource(Resources["surveyors"]))
	handler.resource(fitnessMaster, authService, "/container-types", fitnessAdminResource(Resources["container_types"]))
	handler.resource(fitnessMaster, authService, "/approval-categories", fitnessAdminResource(Resources["fitness_approval_categories"]))
	handler.resource(fitnessMaster, authService, "/maintenance-schemes", fitnessAdminResource(Resources["maintenance_schemes"]))
	handler.resource(fitnessMaster, authService, "/inspection-areas", fitnessAdminResource(Resources["inspection_areas"]))
	handler.resource(fitnessMaster, authService, "/structural-components", fitnessAdminResource(Resources["structural_components"]))
	handler.resource(fitnessMaster, authService, "/damage-criteria", fitnessAdminResource(Resources["structural_damage_criteria"]))
	handler.resource(fitnessMaster, authService, "/finding-severities", fitnessAdminResource(Resources["finding_severities"]))
	handler.resource(fitnessMaster, authService, "/test-parameters", fitnessAdminResource(Resources["inspection_test_parameters"]))
	handler.resource(fitnessMaster, authService, "/checklist-templates", fitnessAdminResource(Resources["fitness_checklist_templates"]))
	checklistTemplateItems := fitnessAdminResource(Resources["fitness_checklist_template_items"])
	handler.resourceItems(fitnessMaster, authService, "/checklist-templates/:id/items", checklistTemplateItems, "template_id")
	handler.resource(fitnessMaster, authService, "/photo-categories", fitnessAdminResource(Resources["evidence_photo_categories"]))
	handler.resource(fitnessMaster, authService, "/inspection-recommendations", fitnessAdminResource(Resources["inspection_recommendations"]))
	handler.resource(fitnessMaster, authService, "/authorized-signers", fitnessAdminResource(Resources["authorized_signers"]))
	handler.resource(fitnessMaster, authService, "/company-profile", fitnessAdminResource(Resources["company_profiles"]))
}

func (h Handler) GetCustomerReferenceOptions(c *gin.Context) {
	customerID, ok := parseUUIDParam(c, "id")
	if !ok {
		return
	}
	surveyTypeID, ok := parseUUIDParam(c, "item_id")
	if !ok {
		return
	}
	item, err := h.service.GetCustomerReferenceOptions(c.Request.Context(), customerID, surveyTypeID)
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Konfigurasi referensi berhasil diambil.", item)
}

func (h Handler) ReviewCodeProposal(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input CodeProposalReviewInput
	if err := c.ShouldBindJSON(&input); err != nil {
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Validasi gagal.", "VALIDATION_ERROR", []apphttp.ErrorDetail{{Message: "Request body review tidak valid."}})
		return
	}
	item, err := h.service.ReviewCodeProposal(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Pengajuan ISO CEDEX berhasil direview.", item)
}

func (h Handler) SetCustomerReferenceOptions(c *gin.Context) {
	customerID, ok := parseUUIDParam(c, "id")
	if !ok {
		return
	}
	if err := h.service.EnsureActiveCustomer(c.Request.Context(), customerID); err != nil {
		h.writeError(c, err)
		return
	}
	surveyTypeID, ok := parseUUIDParam(c, "item_id")
	if !ok {
		return
	}
	var input CustomerReferenceOptionsInput
	if err := c.ShouldBindJSON(&input); err != nil {
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Validasi gagal.", "VALIDATION_ERROR", []apphttp.ErrorDetail{{Message: "Request body JSON tidak valid."}})
		return
	}
	item, err := h.service.SetCustomerReferenceOptions(c.Request.Context(), customerID, surveyTypeID, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Konfigurasi referensi berhasil disimpan.", item)
}

func (h Handler) ListCustomerReadiness(c *gin.Context) {
	items, err := h.service.ListCustomerReadiness(c.Request.Context())
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Kelengkapan Master Data Customer berhasil diambil.", items)
}

func (h Handler) GetCustomerReadiness(c *gin.Context) {
	customerID, ok := parseUUIDParam(c, "id")
	if !ok {
		return
	}
	item, err := h.service.CustomerReadiness(c.Request.Context(), customerID)
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Kelengkapan Master Data Customer berhasil diambil.", item)
}

func (h Handler) GetPersonnelLocations(c *gin.Context) {
	customerID, ok := parseUUIDParam(c, "id")
	if !ok {
		return
	}
	personnelID, ok := parseUUIDParam(c, "item_id")
	if !ok {
		return
	}
	item, err := h.service.PersonnelLocations(c.Request.Context(), customerID, personnelID)
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Mapping Location Personel/PIC berhasil diambil.", item)
}

func (h Handler) SetPersonnelLocations(c *gin.Context) {
	customerID, ok := parseUUIDParam(c, "id")
	if !ok {
		return
	}
	personnelID, ok := parseUUIDParam(c, "item_id")
	if !ok {
		return
	}
	var input PersonnelLocationInput
	if err := c.ShouldBindJSON(&input); err != nil {
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Validasi gagal.", "VALIDATION_ERROR", []apphttp.ErrorDetail{{Message: "Daftar Location tidak valid."}})
		return
	}
	item, err := h.service.SetPersonnelLocations(c.Request.Context(), customerID, personnelID, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Mapping Location Personel/PIC berhasil disimpan.", item)
}

func (h Handler) GetLocationPersonnel(c *gin.Context) {
	customerID, ok := parseUUIDParam(c, "id")
	if !ok {
		return
	}
	locationID, ok := parseUUIDParam(c, "item_id")
	if !ok {
		return
	}
	items, err := h.service.LocationPersonnel(c.Request.Context(), customerID, locationID)
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Personel/PIC Location berhasil diambil.", items)
}

func fitnessAdminResource(resource Resource) Resource {
	resource.SoftDelete = false
	return resource
}
func (h Handler) resource(group *gin.RouterGroup, authService *auth.Service, path string, resource Resource) {
	module := resource.permissionModule()
	view := middleware.RequirePermission(authService, module+".view.all")
	create := middleware.RequirePermission(authService, module+".create.all")
	update := middleware.RequirePermission(authService, module+".update.all")
	deletePermission := middleware.RequirePermission(authService, module+".delete.all")

	group.GET(path, view, h.List(resource))
	group.GET(path+"/:id", view, h.Get(resource))
	if resource.ReadOnly || (resource.LegacyOnly && !resource.AllowGlobalMutation) {
		return
	}
	group.POST(path, create, h.Create(resource))
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
		if parentField == "customer_id" {
			if err := h.service.EnsureActiveCustomer(c.Request.Context(), parentID); err != nil {
				h.writeError(c, err)
				return
			}
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
		if parentField == "customer_id" {
			if err := h.service.EnsureActiveCustomer(c.Request.Context(), parentID); err != nil {
				h.writeError(c, err)
				return
			}
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
		if parentField == "customer_id" {
			if err := h.service.EnsureActiveCustomer(c.Request.Context(), parentID); err != nil {
				h.writeError(c, err)
				return
			}
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
	case errors.Is(err, ErrForeignKey):
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Data referensi tidak valid.", "FOREIGN_KEY_INVALID", nil)
	case errors.Is(err, ErrInvalidInput):
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Validasi gagal.", "VALIDATION_ERROR", []apphttp.ErrorDetail{{Message: strings.TrimPrefix(err.Error(), ErrInvalidInput.Error()+": ")}})
	default:
		slog.Error("master data request failed", "error", err, "request_id", c.GetString("request_id"), "path", c.Request.URL.Path)
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
