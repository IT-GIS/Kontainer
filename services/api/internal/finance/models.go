package finance

import (
	"errors"

	"github.com/google/uuid"
)

var (
	ErrNotFound      = errors.New("finance resource not found")
	ErrInvalidInput  = errors.New("invalid finance input")
	ErrInvalidStatus = errors.New("invalid finance status")
	ErrDuplicate     = errors.New("duplicate finance resource")
)

type Actor struct {
	UserID     uuid.UUID
	ActiveRole string
	RequestID  string
	IPAddress  string
	UserAgent  string
}

type ListParams struct {
	Page       int
	PerPage    int
	Search     string
	Status     string
	CustomerID string
	InvoiceID  string
}

type PaginationMeta struct {
	Page       int  `json:"page"`
	PerPage    int  `json:"per_page"`
	Total      int  `json:"total"`
	TotalPages int  `json:"total_pages"`
	HasNext    bool `json:"has_next"`
	HasPrev    bool `json:"has_prev"`
}

type ListResult struct {
	Rows []map[string]any
	Meta PaginationMeta
}

type PriceListInput struct {
	CustomerID      *string `json:"customer_id"`
	SurveyTypeID    string  `json:"survey_type_id"`
	ContainerTypeID *string `json:"container_type_id"`
	Description     string  `json:"description"`
	UnitPrice       float64 `json:"unit_price"`
	Currency        string  `json:"currency"`
	TaxType         string  `json:"tax_type"`
	EffectiveDate   string  `json:"effective_date"`
	ExpiredDate     *string `json:"expired_date"`
	Status          string  `json:"status"`
}

type InvoiceInput struct {
	CustomerID      string             `json:"customer_id"`
	InvoiceDate     string             `json:"invoice_date"`
	PaymentTermDays int                `json:"payment_term_days"`
	BillingAddress  string             `json:"billing_address"`
	Currency        string             `json:"currency"`
	DiscountAmount  float64            `json:"discount_amount"`
	Note            string             `json:"note"`
	Items           []InvoiceItemInput `json:"items"`
}

type InvoiceItemInput struct {
	JobOrderID  string  `json:"job_order_id"`
	ReportID    string  `json:"report_id"`
	SurveyID    string  `json:"survey_id"`
	PriceListID string  `json:"price_list_id"`
	Description string  `json:"description"`
	Quantity    float64 `json:"quantity"`
	UnitPrice   float64 `json:"unit_price"`
	Taxable     bool    `json:"taxable"`
}

type CancelInput struct {
	Reason string `json:"reason"`
}

type PaymentInput struct {
	InvoiceID     string  `json:"invoice_id"`
	PaymentDate   string  `json:"payment_date"`
	Amount        float64 `json:"amount"`
	PaymentMethod string  `json:"payment_method"`
	BankAccount   string  `json:"bank_account"`
	Note          string  `json:"note"`
}
