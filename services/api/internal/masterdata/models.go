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
)

type Field struct {
	Name     string
	APIName  string
	Required bool
}

func (f Field) RequestName() string {
	if f.APIName != "" {
		return f.APIName
	}
	return f.Name
}

type Resource struct {
	Name          string
	Table         string
	CodeField     string
	ScopedCode    bool
	SoftDelete    bool
	Fields        []Field
	SearchColumns []string
	Filters       map[string]string
	DefaultSort   string
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
