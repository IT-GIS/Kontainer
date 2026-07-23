package masterdata

import (
	"encoding/json"
	"errors"
	"time"

	"github.com/google/uuid"
)

var (
	ErrNotFound     = errors.New("master data not found")
	ErrDuplicate    = errors.New("master data duplicate")
	ErrInvalidInput = errors.New("master data invalid input")
	ErrForeignKey   = errors.New("master data foreign key invalid")
)

type Field struct {
	Name               string
	APIName            string
	Type               string
	Required           bool
	Nullable           bool
	UseDatabaseDefault bool
	DefaultValue       any
	Min                *float64
	Max                *float64
	MaxLength          int
	AllowedValues      []string
}

func (f Field) RequestName() string {
	if f.APIName != "" {
		return f.APIName
	}
	return f.Name
}

type Resource struct {
	Name                string
	PermissionModule    string
	Table               string
	CodeField           string
	DuplicateFields     []string
	ScopedCode          bool
	LegacyOnly          bool
	SoftDelete          bool
	StatusField         string
	ActiveStatusValue   any
	InactiveStatusValue any
	AllowedStatusValues []string
	Fields              []Field
	SearchColumns       []string
	Filters             map[string]string
	RelationDisplays    []RelationDisplay
	DefaultSort         string
}

type RelationDisplay struct {
	Field      string
	Alias      string
	Table      string
	CodeColumn string
	NameColumn string
}

type ListParams struct {
	Page      int
	PerPage   int
	Search    string
	Status    string
	SortBy    string
	SortOrder string
	Filters   map[string]string
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

type AuditEntry struct {
	UserID     *uuid.UUID
	ActiveRole *string
	Action     string
	EntityType string
	EntityID   *uuid.UUID
	OldValue   json.RawMessage
	NewValue   json.RawMessage
	RequestID  string
	IPAddress  string
	UserAgent  string
	CreatedAt  time.Time
}
