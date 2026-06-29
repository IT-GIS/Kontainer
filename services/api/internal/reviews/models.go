package reviews

import (
	"errors"

	"github.com/google/uuid"
)

var (
	ErrNotFound      = errors.New("review resource not found")
	ErrInvalidInput  = errors.New("invalid review input")
	ErrInvalidStatus = errors.New("invalid review status")
	ErrDuplicate     = errors.New("duplicate review resource")
)

type Actor struct {
	UserID     uuid.UUID
	ActiveRole string
	RequestID  string
	IPAddress  string
	UserAgent  string
}

type ListParams struct {
	Page         int
	PerPage      int
	Search       string
	Status       string
	CustomerID   string
	SurveyTypeID string
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

type NeedRevisionInput struct {
	RevisionNote string `json:"revision_note"`
}

type ApproveInput struct {
	FinalResult    string `json:"final_result"`
	ApprovalNote   string `json:"approval_note"`
	GenerateReport bool   `json:"generate_report"`
}

type RejectInput struct {
	RejectionReason string `json:"rejection_reason"`
}

type GenerateReportInput struct {
	ReportType string `json:"report_type"`
}
