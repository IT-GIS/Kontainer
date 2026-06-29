package finance

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

type Handler struct{ service *Service }

func NewHandler(service *Service) Handler { return Handler{service: service} }

func Register(v1 *gin.RouterGroup, authService *auth.Service, service *Service) {
	h := NewHandler(service)
	view := middleware.RequirePermission(authService, "finance.view.all")
	manage := middleware.RequirePermission(authService, "finance.manage.all")
	createInvoice := middleware.RequirePermission(authService, "finance.invoice.create.all")
	createPayment := middleware.RequirePermission(authService, "finance.payment.create.all")
	v1.GET("/finance/dashboard", view, h.Dashboard)
	v1.GET("/finance/ready-to-invoice", view, h.ReadyToInvoice)
	v1.GET("/finance/customer-summary", view, h.CustomerSummary)
	v1.GET("/finance/price-list", view, h.ListPriceLists)
	v1.GET("/finance/price-list/:id", view, h.PriceListDetail)
	v1.POST("/finance/price-list", manage, h.CreatePriceList)
	v1.PUT("/finance/price-list/:id", manage, h.UpdatePriceList)
	v1.DELETE("/finance/price-list/:id", manage, h.DeletePriceList)
	v1.POST("/finance/invoices", createInvoice, h.CreateInvoice)
	v1.GET("/finance/invoices", view, h.ListInvoices)
	v1.GET("/finance/invoices/:id", view, h.InvoiceDetail)
	v1.POST("/finance/invoices/:id/issue", manage, h.IssueInvoice)
	v1.POST("/finance/invoices/:id/cancel", manage, h.CancelInvoice)
	v1.GET("/finance/invoices/:id/download", view, h.DownloadInvoice)
	v1.POST("/finance/payments", createPayment, h.CreatePayment)
	v1.GET("/finance/payments", view, h.ListPayments)
	v1.GET("/finance/outstanding", view, h.Outstanding)
}

func (h Handler) Dashboard(c *gin.Context) {
	item, err := h.service.Dashboard(c.Request.Context())
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Dashboard finance berhasil diambil.", item)
}
func (h Handler) ReadyToInvoice(c *gin.Context) {
	result, err := h.service.ReadyToInvoice(c.Request.Context(), listParams(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	paginated(c, "Ready to invoice berhasil diambil.", result)
}
func (h Handler) ListPriceLists(c *gin.Context) {
	result, err := h.service.ListPriceLists(c.Request.Context(), listParams(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	paginated(c, "Price list berhasil diambil.", result)
}
func (h Handler) CustomerSummary(c *gin.Context) {
	result, err := h.service.CustomerSummary(c.Request.Context(), listParams(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	paginated(c, "Rekap customer berhasil diambil.", result)
}
func (h Handler) ListInvoices(c *gin.Context) {
	result, err := h.service.ListInvoices(c.Request.Context(), listParams(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	paginated(c, "Invoice berhasil diambil.", result)
}
func (h Handler) ListPayments(c *gin.Context) {
	result, err := h.service.ListPayments(c.Request.Context(), listParams(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	paginated(c, "Payment berhasil diambil.", result)
}
func (h Handler) Outstanding(c *gin.Context) {
	result, err := h.service.Outstanding(c.Request.Context(), listParams(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	paginated(c, "Outstanding berhasil diambil.", result)
}

func (h Handler) CreatePriceList(c *gin.Context) {
	var input PriceListInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.CreatePriceList(c.Request.Context(), input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Created(c, "Price list berhasil dibuat.", item)
}
func (h Handler) PriceListDetail(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.PriceListDetail(c.Request.Context(), id)
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Detail price list berhasil diambil.", item)
}
func (h Handler) UpdatePriceList(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input PriceListInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.UpdatePriceList(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Price list berhasil diperbarui.", item)
}
func (h Handler) DeletePriceList(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.DeletePriceList(c.Request.Context(), id, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Price list berhasil dinonaktifkan.", item)
}
func (h Handler) CreateInvoice(c *gin.Context) {
	var input InvoiceInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.CreateInvoice(c.Request.Context(), input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Created(c, "Invoice berhasil dibuat.", item)
}
func (h Handler) InvoiceDetail(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.InvoiceDetail(c.Request.Context(), id)
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Detail invoice berhasil diambil.", item)
}
func (h Handler) IssueInvoice(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.IssueInvoice(c.Request.Context(), id, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Invoice berhasil diterbitkan.", item)
}
func (h Handler) CancelInvoice(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	var input CancelInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.CancelInvoice(c.Request.Context(), id, input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.OK(c, "Invoice berhasil dibatalkan.", item)
}
func (h Handler) CreatePayment(c *gin.Context) {
	var input PaymentInput
	if !bindJSON(c, &input) {
		return
	}
	item, err := h.service.CreatePayment(c.Request.Context(), input, actorFromContext(c))
	if err != nil {
		h.writeError(c, err)
		return
	}
	apphttp.Created(c, "Payment berhasil dicatat.", item)
}

func (h Handler) DownloadInvoice(c *gin.Context) {
	id, ok := parseID(c)
	if !ok {
		return
	}
	item, err := h.service.InvoiceDetail(c.Request.Context(), id)
	if err != nil {
		h.writeError(c, err)
		return
	}
	content := fmt.Sprintf("Invoice %s\nGrand total: %v\nStatus: %v\n", item["invoice_no"], item["grand_total"], item["status"])
	c.Header("Content-Disposition", fmt.Sprintf("attachment; filename=%s.pdf", item["invoice_no"]))
	c.Data(http.StatusOK, "application/pdf", []byte(content))
}

func (h Handler) writeError(c *gin.Context, err error) {
	switch {
	case errors.Is(err, ErrNotFound):
		apphttp.Fail(c, http.StatusNotFound, "Data tidak ditemukan.", "NOT_FOUND", nil)
	case errors.Is(err, ErrDuplicate):
		apphttp.Fail(c, http.StatusConflict, "Report sudah masuk invoice aktif.", "DUPLICATE_RESOURCE", nil)
	case errors.Is(err, ErrInvalidStatus):
		apphttp.Fail(c, http.StatusConflict, "Status tidak valid untuk aksi ini.", "INVALID_STATUS_TRANSITION", nil)
	case errors.Is(err, ErrInvalidInput):
		apphttp.Fail(c, http.StatusUnprocessableEntity, "Validasi gagal.", "VALIDATION_ERROR", nil)
	default:
		apphttp.Fail(c, http.StatusInternalServerError, "Terjadi kesalahan internal.", "INTERNAL_ERROR", nil)
	}
}

func paginated(c *gin.Context, message string, result ListResult) {
	apphttp.Paginated(c, message, result.Rows, apphttp.PaginationMeta{Page: result.Meta.Page, PerPage: result.Meta.PerPage, Total: result.Meta.Total, TotalPages: result.Meta.TotalPages, HasNext: result.Meta.HasNext, HasPrev: result.Meta.HasPrev})
}

func listParams(c *gin.Context) ListParams {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	perPage, _ := strconv.Atoi(c.DefaultQuery("per_page", "20"))
	return ListParams{Page: page, PerPage: perPage, Search: c.Query("search"), Status: c.Query("status"), CustomerID: c.Query("customer_id"), InvoiceID: c.Query("invoice_id")}
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
