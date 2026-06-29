package finance

import (
	"fmt"
	"strings"

	"github.com/google/uuid"
)

func readyWhere(params ListParams) (string, []any) {
	args := []any{}
	clauses := []string{"s.status='approved'", "r.status NOT IN ('void','superseded')", "NOT EXISTS (SELECT 1 FROM invoice_items ii JOIN invoices i ON i.id=ii.invoice_id WHERE ii.report_id=r.id AND i.status NOT IN ('cancelled','void'))"}
	if params.CustomerID != "" {
		args = append(args, params.CustomerID)
		clauses = append(clauses, fmt.Sprintf("r.customer_id=$%d", len(args)))
	}
	if params.Search != "" {
		args = append(args, "%"+strings.TrimSpace(params.Search)+"%")
		clauses = append(clauses, fmt.Sprintf("(r.report_no LIKE $%d OR jo.job_order_no LIKE $%d OR c.customer_name LIKE $%d)", len(args), len(args), len(args)))
	}
	return "WHERE " + strings.Join(clauses, " AND "), args
}

func priceWhere(params ListParams) (string, []any) {
	args := []any{}
	clauses := []string{"pl.deleted_at IS NULL"}
	if params.Status != "" {
		args = append(args, params.Status)
		clauses = append(clauses, fmt.Sprintf("pl.status=$%d", len(args)))
	}
	if params.CustomerID != "" {
		args = append(args, params.CustomerID)
		clauses = append(clauses, fmt.Sprintf("pl.customer_id=$%d", len(args)))
	}
	return "WHERE " + strings.Join(clauses, " AND "), args
}

func invoiceWhere(params ListParams) (string, []any) {
	args := []any{}
	clauses := []string{"1=1"}
	if params.Status == "open" {
		clauses = append(clauses, "i.status IN ('issued','unpaid','partial_paid','overdue')")
	} else if params.Status != "" {
		args = append(args, params.Status)
		clauses = append(clauses, fmt.Sprintf("i.status=$%d", len(args)))
	}
	if params.CustomerID != "" {
		args = append(args, params.CustomerID)
		clauses = append(clauses, fmt.Sprintf("i.customer_id=$%d", len(args)))
	}
	if params.Search != "" {
		args = append(args, "%"+strings.TrimSpace(params.Search)+"%")
		clauses = append(clauses, fmt.Sprintf("(i.invoice_no LIKE $%d OR c.customer_name LIKE $%d)", len(args), len(args)))
	}
	return "WHERE " + strings.Join(clauses, " AND "), args
}

func paymentWhere(params ListParams) (string, []any) {
	args := []any{}
	clauses := []string{"p.cancelled_at IS NULL"}
	if params.InvoiceID != "" {
		args = append(args, params.InvoiceID)
		clauses = append(clauses, fmt.Sprintf("p.invoice_id=$%d", len(args)))
	}
	if params.Search != "" {
		args = append(args, "%"+strings.TrimSpace(params.Search)+"%")
		clauses = append(clauses, fmt.Sprintf("(p.payment_no LIKE $%d OR i.invoice_no LIKE $%d)", len(args), len(args)))
	}
	return "WHERE " + strings.Join(clauses, " AND "), args
}

func optionalUUIDPtr(value *string) (*uuid.UUID, error) {
	if value == nil || strings.TrimSpace(*value) == "" {
		return nil, nil
	}
	parsed, err := parseUUIDString(*value)
	if err != nil {
		return nil, err
	}
	return parsed, nil
}

func floatFromAny(value any) float64 {
	var out float64
	_, _ = fmt.Sscan(fmt.Sprint(value), &out)
	return out
}
