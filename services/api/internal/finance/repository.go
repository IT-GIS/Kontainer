package finance

import (
	"container-survey/services/api/internal/database"
	"container-survey/services/api/internal/numbering"
	"context"
	"fmt"
	"strings"

	"github.com/google/uuid"
)

type Repository struct {
	pool *database.Pool
}

func NewRepository(pool *database.Pool) Repository {
	return Repository{pool: pool}
}

func (r Repository) Dashboard(ctx context.Context) (map[string]any, error) {
	var readyToInvoice int
	var invoiceCount int
	var paidCount int
	var unpaidCount int
	var overdueCount int
	var outstandingAmount float64

	_ = r.pool.QueryRow(ctx, `SELECT COUNT(*) FROM reports r JOIN surveys s ON s.id=r.survey_id WHERE s.status='approved' AND r.status NOT IN ('void','superseded') AND NOT EXISTS (SELECT 1 FROM invoice_items ii JOIN invoices i ON i.id=ii.invoice_id WHERE ii.report_id=r.id AND i.status NOT IN ('cancelled','void'))`).Scan(&readyToInvoice)
	_ = r.pool.QueryRow(ctx, `SELECT COUNT(*) FROM invoices`).Scan(&invoiceCount)
	_ = r.pool.QueryRow(ctx, `SELECT COUNT(*) FROM invoices WHERE status='paid'`).Scan(&paidCount)
	_ = r.pool.QueryRow(ctx, `SELECT COUNT(*) FROM invoices WHERE status IN ('unpaid','partial_paid')`).Scan(&unpaidCount)
	_ = r.pool.QueryRow(ctx, `SELECT COUNT(*) FROM invoices WHERE due_date < CURRENT_DATE AND status IN ('unpaid','partial_paid')`).Scan(&overdueCount)
	_ = r.pool.QueryRow(ctx, `SELECT COALESCE(SUM(outstanding_amount),0) FROM invoices WHERE status IN ('unpaid','partial_paid','overdue')`).Scan(&outstandingAmount)

	return map[string]any{
		"ready_to_invoice":   readyToInvoice,
		"invoice_count":      invoiceCount,
		"paid_count":         paidCount,
		"unpaid_count":       unpaidCount,
		"overdue_count":      overdueCount,
		"outstanding_amount": outstandingAmount,
	}, nil
}

func (r Repository) ReadyToInvoice(ctx context.Context, params ListParams) (ListResult, error) {
	page, perPage := normalizePagination(params.Page, params.PerPage)
	where, args := readyWhere(params)
	var total int
	if err := r.pool.QueryRow(ctx, "SELECT COUNT(*) FROM reports r JOIN surveys s ON s.id=r.survey_id JOIN job_orders jo ON jo.id=r.job_order_id JOIN customers c ON c.id=r.customer_id JOIN survey_types st ON st.id=s.survey_type_id "+where, args...).Scan(&total); err != nil {
		return ListResult{}, err
	}
	args = append(args, perPage, (page-1)*perPage)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT r.id AS report_id, r.report_no, jo.id AS job_order_id, jo.job_order_no, r.customer_id,
		       c.customer_name, st.name AS survey_type_name, 1 AS container_count, 'ready_to_invoice' AS status
		FROM reports r
		JOIN surveys s ON s.id=r.survey_id
		JOIN job_orders jo ON jo.id=r.job_order_id
		JOIN customers c ON c.id=r.customer_id
		JOIN survey_types st ON st.id=s.survey_type_id
		%s
		ORDER BY r.created_at DESC
		LIMIT $%d OFFSET $%d
	`, where, len(args)-1, len(args)), args...)
	if err != nil {
		return ListResult{}, err
	}
	defer rows.Close()
	items, err := rowsToMaps(rows)
	if err != nil {
		return ListResult{}, err
	}
	return ListResult{Rows: items, Meta: listMeta(page, perPage, total)}, nil
}

func (r Repository) ListPriceLists(ctx context.Context, params ListParams) (ListResult, error) {
	page, perPage := normalizePagination(params.Page, params.PerPage)
	where, args := priceWhere(params)
	var total int
	if err := r.pool.QueryRow(ctx, "SELECT COUNT(*) FROM price_lists pl "+where, args...).Scan(&total); err != nil {
		return ListResult{}, err
	}
	args = append(args, perPage, (page-1)*perPage)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT pl.id, pl.customer_id, c.customer_name, pl.survey_type_id, st.name AS survey_type_name,
		       pl.container_type_id, ct.code AS container_type_code, pl.description, pl.unit_price, pl.currency, pl.tax_type,
		       pl.effective_date, pl.expired_date, pl.status
		FROM price_lists pl
		LEFT JOIN customers c ON c.id=pl.customer_id
		JOIN survey_types st ON st.id=pl.survey_type_id
		LEFT JOIN container_types ct ON ct.id=pl.container_type_id
		%s ORDER BY pl.effective_date DESC LIMIT $%d OFFSET $%d
	`, where, len(args)-1, len(args)), args...)
	if err != nil {
		return ListResult{}, err
	}
	defer rows.Close()
	items, err := rowsToMaps(rows)
	if err != nil {
		return ListResult{}, err
	}
	return ListResult{Rows: items, Meta: listMeta(page, perPage, total)}, nil
}
func (r Repository) PriceListDetail(ctx context.Context, id uuid.UUID) (map[string]any, error) {
	return scanRow(r.pool.QueryRow(ctx, `
		SELECT pl.id, pl.customer_id, c.customer_name, pl.survey_type_id, st.name AS survey_type_name,
		       pl.container_type_id, ct.code AS container_type_code, pl.description, pl.unit_price, pl.currency, pl.tax_type,
		       pl.effective_date, pl.expired_date, pl.status
		FROM price_lists pl
		LEFT JOIN customers c ON c.id=pl.customer_id
		JOIN survey_types st ON st.id=pl.survey_type_id
		LEFT JOIN container_types ct ON ct.id=pl.container_type_id
		WHERE pl.id=$1 AND pl.deleted_at IS NULL
	`, id), []string{"id", "customer_id", "customer_name", "survey_type_id", "survey_type_name", "container_type_id", "container_type_code", "description", "unit_price", "currency", "tax_type", "effective_date", "expired_date", "status"})
}

func (r Repository) CreatePriceList(ctx context.Context, input PriceListInput, actor Actor) (map[string]any, error) {
	return r.savePriceList(ctx, uuid.Nil, input, actor)
}

func (r Repository) UpdatePriceList(ctx context.Context, id uuid.UUID, input PriceListInput, actor Actor) (map[string]any, error) {
	return r.savePriceList(ctx, id, input, actor)
}

func (r Repository) DeletePriceList(ctx context.Context, id uuid.UUID, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	item, err := scanRow(tx.QueryRow(ctx, `UPDATE price_lists SET deleted_at=now(), status='inactive', updated_at=now() WHERE id=$1 AND deleted_at IS NULL RETURNING id, status`, id), []string{"id", "status"})
	if err != nil {
		return nil, err
	}
	_ = insertAudit(ctx, tx, actor, "finance.price_list.delete", "price_lists", &id, nil, item)
	return item, tx.Commit(ctx)
}

func (r Repository) savePriceList(ctx context.Context, id uuid.UUID, input PriceListInput, actor Actor) (map[string]any, error) {
	surveyTypeID, err := parseUUIDString(input.SurveyTypeID)
	if err != nil || surveyTypeID == nil || input.UnitPrice <= 0 {
		return nil, ErrInvalidInput
	}
	customerID, err := optionalUUIDPtr(input.CustomerID)
	if err != nil {
		return nil, err
	}
	containerTypeID, err := optionalUUIDPtr(input.ContainerTypeID)
	if err != nil {
		return nil, err
	}
	effectiveDate, err := parseDate(input.EffectiveDate)
	if err != nil {
		return nil, ErrInvalidInput
	}
	expiredDate, err := parseOptionalDate(input.ExpiredDate)
	if err != nil {
		return nil, ErrInvalidInput
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	status := defaultString(input.Status, "active")
	currency := defaultString(input.Currency, "IDR")
	var item map[string]any
	if id == uuid.Nil {
		item, err = scanRow(tx.QueryRow(ctx, `INSERT INTO price_lists (customer_id,survey_type_id,container_type_id,description,unit_price,currency,tax_type,effective_date,expired_date,status) VALUES ($1,$2,$3,NULLIF($4,''),$5,$6,NULLIF($7,''),$8,$9,$10) RETURNING id, status, unit_price`, customerID, surveyTypeID, containerTypeID, input.Description, input.UnitPrice, currency, input.TaxType, effectiveDate, expiredDate, status), []string{"id", "status", "unit_price"})
	} else {
		item, err = scanRow(tx.QueryRow(ctx, `UPDATE price_lists SET customer_id=$2,survey_type_id=$3,container_type_id=$4,description=NULLIF($5,''),unit_price=$6,currency=$7,tax_type=NULLIF($8,''),effective_date=$9,expired_date=$10,status=$11,updated_at=now() WHERE id=$1 AND deleted_at IS NULL RETURNING id, status, unit_price`, id, customerID, surveyTypeID, containerTypeID, input.Description, input.UnitPrice, currency, input.TaxType, effectiveDate, expiredDate, status), []string{"id", "status", "unit_price"})
	}
	if err != nil {
		return nil, err
	}
	entityID := uuidFromAny(item["id"])
	_ = insertAudit(ctx, tx, actor, "finance.price_list.save", "price_lists", &entityID, nil, item)
	return item, tx.Commit(ctx)
}

func (r Repository) CreateInvoice(ctx context.Context, input InvoiceInput, actor Actor) (map[string]any, error) {
	if len(input.Items) == 0 {
		return nil, ErrInvalidInput
	}
	customerID, err := uuid.Parse(input.CustomerID)
	if err != nil {
		return nil, ErrInvalidInput
	}
	invoiceDate, err := parseDate(input.InvoiceDate)
	if err != nil {
		return nil, ErrInvalidInput
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	invoiceNo, err := numbering.Next(ctx, tx, "invoice")
	if err != nil {
		return nil, err
	}
	dueDate := invoiceDate.AddDate(0, 0, input.PaymentTermDays)
	if input.PaymentTermDays <= 0 {
		dueDate = invoiceDate
	}
	subtotal := 0.0
	taxAmount := 0.0
	for _, item := range input.Items {
		if item.ReportID == "" || item.Description == "" || item.UnitPrice <= 0 {
			return nil, ErrInvalidInput
		}
		reportID, err := uuid.Parse(item.ReportID)
		if err != nil {
			return nil, ErrInvalidInput
		}
		if err := r.ensureReportInvoiceable(ctx, tx, reportID, customerID); err != nil {
			return nil, err
		}
		qty := item.Quantity
		if qty <= 0 {
			qty = 1
		}
		line := qty * item.UnitPrice
		subtotal += line
		if item.Taxable {
			taxAmount += line * 0.11
		}
	}
	grandTotal := subtotal + taxAmount - input.DiscountAmount
	if grandTotal < 0 {
		return nil, ErrInvalidInput
	}
	invoiceID := uuid.Nil
	if err := tx.QueryRow(ctx, `INSERT INTO invoices (invoice_no,invoice_date,customer_id,billing_address,payment_term_days,due_date,currency,subtotal,tax_amount,discount_amount,grand_total,outstanding_amount,created_by) VALUES ($1,$2,$3,NULLIF($4,''),$5,$6,$7,$8,$9,$10,$11,$11,$12) RETURNING id`, invoiceNo, invoiceDate, customerID, input.BillingAddress, input.PaymentTermDays, dueDate, defaultString(input.Currency, "IDR"), subtotal, taxAmount, input.DiscountAmount, grandTotal, actor.UserID).Scan(&invoiceID); err != nil {
		return nil, err
	}
	for _, row := range input.Items {
		reportID, _ := uuid.Parse(row.ReportID)
		priceListID, err := optionalUUIDPtr(&row.PriceListID)
		if err != nil {
			return nil, err
		}
		qty := row.Quantity
		if qty <= 0 {
			qty = 1
		}
		line := qty * row.UnitPrice
		lineTax := 0.0
		if row.Taxable {
			lineTax = line * 0.11
		}
		report, _ := r.reportInfo(ctx, tx, reportID)
		jobID := uuidFromAny(report["job_order_id"])
		surveyID := uuidFromAny(report["survey_id"])
		_, err = tx.Exec(ctx, `INSERT INTO invoice_items (invoice_id,job_order_id,report_id,survey_id,price_list_id,description,quantity,unit_price,tax_amount,total) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)`, invoiceID, jobID, reportID, surveyID, priceListID, row.Description, qty, row.UnitPrice, lineTax, line+lineTax)
		if err != nil {
			return nil, err
		}
	}
	item := map[string]any{"id": invoiceID.String(), "invoice_no": invoiceNo, "status": "draft", "grand_total": grandTotal}
	_ = insertAudit(ctx, tx, actor, "finance.invoice.create", "invoices", &invoiceID, nil, item)
	return item, tx.Commit(ctx)
}

func (r Repository) ListInvoices(ctx context.Context, params ListParams) (ListResult, error) {
	page, perPage := normalizePagination(params.Page, params.PerPage)
	where, args := invoiceWhere(params)
	var total int
	if err := r.pool.QueryRow(ctx, "SELECT COUNT(*) FROM invoices i JOIN customers c ON c.id=i.customer_id "+where, args...).Scan(&total); err != nil {
		return ListResult{}, err
	}
	args = append(args, perPage, (page-1)*perPage)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`SELECT i.id, i.invoice_no, i.invoice_date, c.customer_name, i.grand_total, i.paid_amount, i.outstanding_amount, i.status, i.due_date FROM invoices i JOIN customers c ON c.id=i.customer_id %s ORDER BY i.created_at DESC LIMIT $%d OFFSET $%d`, where, len(args)-1, len(args)), args...)
	if err != nil {
		return ListResult{}, err
	}
	defer rows.Close()
	items, err := rowsToMaps(rows)
	if err != nil {
		return ListResult{}, err
	}
	return ListResult{Rows: items, Meta: listMeta(page, perPage, total)}, nil
}

func (r Repository) InvoiceDetail(ctx context.Context, id uuid.UUID) (map[string]any, error) {
	item, err := scanRow(r.pool.QueryRow(ctx, `SELECT i.id, i.invoice_no, i.invoice_date, i.customer_id, c.customer_name, i.billing_address, i.payment_term_days, i.due_date, i.currency, i.subtotal, i.tax_amount, i.discount_amount, i.grand_total, i.paid_amount, i.outstanding_amount, i.status FROM invoices i JOIN customers c ON c.id=i.customer_id WHERE i.id=$1`, id), []string{"id", "invoice_no", "invoice_date", "customer_id", "customer_name", "billing_address", "payment_term_days", "due_date", "currency", "subtotal", "tax_amount", "discount_amount", "grand_total", "paid_amount", "outstanding_amount", "status"})
	if err != nil {
		return nil, err
	}
	rows, _ := r.pool.Query(ctx, `SELECT ii.id, ii.report_id, r.report_no, ii.description, ii.quantity, ii.unit_price, ii.tax_amount, ii.total FROM invoice_items ii LEFT JOIN reports r ON r.id=ii.report_id WHERE ii.invoice_id=$1 ORDER BY ii.created_at`, id)
	if rows != nil {
		defer rows.Close()
		items, _ := rowsToMaps(rows)
		item["items"] = items
	}
	return item, nil
}

func (r Repository) IssueInvoice(ctx context.Context, id uuid.UUID, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	invoice, err := scanRow(tx.QueryRow(ctx, `SELECT id, invoice_no, status, due_date FROM invoices WHERE id=$1 FOR UPDATE`, id), []string{"id", "invoice_no", "status", "due_date"})
	if err != nil {
		return nil, err
	}
	if fmt.Sprint(invoice["status"]) != "draft" {
		return nil, ErrInvalidStatus
	}
	var itemCount int
	if err := tx.QueryRow(ctx, `SELECT COUNT(*) FROM invoice_items WHERE invoice_id=$1`, id).Scan(&itemCount); err != nil {
		return nil, err
	}
	if itemCount == 0 {
		return nil, ErrInvalidInput
	}
	item, err := scanRow(tx.QueryRow(ctx, `UPDATE invoices SET status='unpaid', issued_at=now(), issued_by=$2, updated_at=now() WHERE id=$1 RETURNING invoice_no, status, due_date`, id, actor.UserID), []string{"invoice_no", "status", "due_date"})
	if err != nil {
		return nil, err
	}
	_, _ = tx.Exec(ctx, `UPDATE job_orders SET status='invoiced', updated_by=$2, updated_at=now() WHERE id IN (SELECT DISTINCT job_order_id FROM invoice_items WHERE invoice_id=$1 AND job_order_id IS NOT NULL)`, id, actor.UserID)
	_ = insertAudit(ctx, tx, actor, "finance.invoice.issue", "invoices", &id, invoice, item)
	return item, tx.Commit(ctx)
}

func (r Repository) CancelInvoice(ctx context.Context, id uuid.UUID, input CancelInput, actor Actor) (map[string]any, error) {
	if strings.TrimSpace(input.Reason) == "" {
		return nil, ErrInvalidInput
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	old, err := scanRow(tx.QueryRow(ctx, `SELECT id, invoice_no, status FROM invoices WHERE id=$1 FOR UPDATE`, id), []string{"id", "invoice_no", "status"})
	if err != nil {
		return nil, err
	}
	status := fmt.Sprint(old["status"])
	if status == "paid" || status == "cancelled" || status == "void" {
		return nil, ErrInvalidStatus
	}
	newStatus := "cancelled"
	if status != "draft" {
		newStatus = "void"
	}
	item, err := scanRow(tx.QueryRow(ctx, `UPDATE invoices SET status=$2,cancel_reason=$3,cancelled_at=now(),cancelled_by=$4,updated_at=now() WHERE id=$1 RETURNING id, invoice_no, status`, id, newStatus, input.Reason, actor.UserID), []string{"id", "invoice_no", "status"})
	if err != nil {
		return nil, err
	}
	_ = insertAudit(ctx, tx, actor, "finance.invoice.cancel", "invoices", &id, old, item)
	return item, tx.Commit(ctx)
}

func (r Repository) CreatePayment(ctx context.Context, input PaymentInput, actor Actor) (map[string]any, error) {
	if input.Amount <= 0 {
		return nil, ErrInvalidInput
	}
	invoiceID, err := uuid.Parse(input.InvoiceID)
	if err != nil {
		return nil, ErrInvalidInput
	}
	paymentDate, err := parseDate(input.PaymentDate)
	if err != nil {
		return nil, ErrInvalidInput
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	invoice, err := scanRow(tx.QueryRow(ctx, `SELECT id, invoice_no, status, outstanding_amount FROM invoices WHERE id=$1 FOR UPDATE`, invoiceID), []string{"id", "invoice_no", "status", "outstanding_amount"})
	if err != nil {
		return nil, err
	}
	status := fmt.Sprint(invoice["status"])
	if status == "draft" || status == "paid" || status == "cancelled" || status == "void" {
		return nil, ErrInvalidStatus
	}
	outstanding := floatFromAny(invoice["outstanding_amount"])
	if input.Amount > outstanding {
		return nil, ErrInvalidInput
	}
	paymentNo, err := numbering.Next(ctx, tx, "payment_receipt")
	if err != nil {
		return nil, err
	}
	paymentID := uuid.Nil
	if err := tx.QueryRow(ctx, `INSERT INTO payments (payment_no,invoice_id,payment_date,amount,payment_method,bank_account,note,created_by) VALUES ($1,$2,$3,$4,NULLIF($5,''),NULLIF($6,''),NULLIF($7,''),$8) RETURNING id`, paymentNo, invoiceID, paymentDate, input.Amount, input.PaymentMethod, input.BankAccount, input.Note, actor.UserID).Scan(&paymentID); err != nil {
		return nil, err
	}
	newPaid := r.sumPayments(ctx, tx, invoiceID)
	grand := 0.0
	_ = tx.QueryRow(ctx, `SELECT grand_total FROM invoices WHERE id=$1`, invoiceID).Scan(&grand)
	newOutstanding := grand - newPaid
	newStatus := "partial_paid"
	if newOutstanding <= 0 {
		newStatus = "paid"
		newOutstanding = 0
	}
	if newPaid == 0 {
		newStatus = "unpaid"
	}
	_, _ = tx.Exec(ctx, `UPDATE invoices SET paid_amount=$2,outstanding_amount=$3,status=$4,updated_at=now() WHERE id=$1`, invoiceID, newPaid, newOutstanding, newStatus)
	item := map[string]any{"id": paymentID.String(), "payment_no": paymentNo, "invoice_status": newStatus}
	_ = insertAudit(ctx, tx, actor, "finance.payment.create", "payments", &paymentID, nil, item)
	return item, tx.Commit(ctx)
}

func (r Repository) ListPayments(ctx context.Context, params ListParams) (ListResult, error) {
	page, perPage := normalizePagination(params.Page, params.PerPage)
	where, args := paymentWhere(params)
	var total int
	if err := r.pool.QueryRow(ctx, "SELECT COUNT(*) FROM payments p JOIN invoices i ON i.id=p.invoice_id "+where, args...).Scan(&total); err != nil {
		return ListResult{}, err
	}
	args = append(args, perPage, (page-1)*perPage)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`SELECT p.id, p.payment_no, i.invoice_no, p.payment_date, p.amount, p.payment_method, p.bank_account, p.note, p.created_at FROM payments p JOIN invoices i ON i.id=p.invoice_id %s ORDER BY p.created_at DESC LIMIT $%d OFFSET $%d`, where, len(args)-1, len(args)), args...)
	if err != nil {
		return ListResult{}, err
	}
	defer rows.Close()
	items, err := rowsToMaps(rows)
	if err != nil {
		return ListResult{}, err
	}
	return ListResult{Rows: items, Meta: listMeta(page, perPage, total)}, nil
}

func (r Repository) CustomerSummary(ctx context.Context, params ListParams) (ListResult, error) {
	page, perPage := normalizePagination(params.Page, params.PerPage)
	args := []any{}
	where := "WHERE 1=1"
	if params.Search != "" {
		args = append(args, "%"+strings.TrimSpace(params.Search)+"%")
		where += fmt.Sprintf(" AND c.customer_name LIKE $%d", len(args))
	}
	var total int
	if err := r.pool.QueryRow(ctx, "SELECT COUNT(*) FROM customers c "+where, args...).Scan(&total); err != nil {
		return ListResult{}, err
	}
	args = append(args, perPage, (page-1)*perPage)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT c.id AS customer_id, c.customer_name,
		       COUNT(i.id) AS invoice_count,
		       COALESCE(SUM(i.grand_total),0) AS total_invoiced,
		       COALESCE(SUM(i.paid_amount),0) AS total_paid,
		       COALESCE(SUM(i.outstanding_amount),0) AS outstanding_amount
		FROM customers c
		LEFT JOIN invoices i ON i.customer_id=c.id AND i.status NOT IN ('cancelled','void')
		%s
		GROUP BY c.id, c.customer_name
		ORDER BY outstanding_amount DESC, c.customer_name ASC
		LIMIT $%d OFFSET $%d
	`, where, len(args)-1, len(args)), args...)
	if err != nil {
		return ListResult{}, err
	}
	defer rows.Close()
	items, err := rowsToMaps(rows)
	if err != nil {
		return ListResult{}, err
	}
	return ListResult{Rows: items, Meta: listMeta(page, perPage, total)}, nil
}
func (r Repository) Outstanding(ctx context.Context, params ListParams) (ListResult, error) {
	params.Status = "open"
	return r.ListInvoices(ctx, params)
}

func (r Repository) ensureReportInvoiceable(ctx context.Context, tx database.Tx, reportID uuid.UUID, customerID uuid.UUID) error {
	report, err := r.reportInfo(ctx, tx, reportID)
	if err != nil {
		return err
	}
	if uuidFromAny(report["customer_id"]) != customerID {
		return ErrInvalidInput
	}
	if fmt.Sprint(report["survey_status"]) != "approved" || fmt.Sprint(report["status"]) == "void" || fmt.Sprint(report["status"]) == "superseded" {
		return ErrInvalidStatus
	}
	var active int
	if err := tx.QueryRow(ctx, `SELECT COUNT(*) FROM invoice_items ii JOIN invoices i ON i.id=ii.invoice_id WHERE ii.report_id=$1 AND i.status NOT IN ('cancelled','void')`, reportID).Scan(&active); err != nil {
		return err
	}
	if active > 0 {
		return ErrDuplicate
	}
	return nil
}

func (r Repository) reportInfo(ctx context.Context, tx database.Tx, reportID uuid.UUID) (map[string]any, error) {
	return scanRow(tx.QueryRow(ctx, `SELECT r.id, r.status, r.customer_id, r.job_order_id, r.survey_id, s.status AS survey_status FROM reports r JOIN surveys s ON s.id=r.survey_id WHERE r.id=$1`, reportID), []string{"id", "status", "customer_id", "job_order_id", "survey_id", "survey_status"})
}

func (r Repository) sumPayments(ctx context.Context, tx database.Tx, invoiceID uuid.UUID) float64 {
	var total float64
	_ = tx.QueryRow(ctx, `SELECT COALESCE(SUM(amount),0) FROM payments WHERE invoice_id=$1 AND cancelled_at IS NULL`, invoiceID).Scan(&total)
	return total
}
