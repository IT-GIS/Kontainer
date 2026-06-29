package masterdata

import (
	"container-survey/services/api/internal/database"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"strings"
	"time"

	"github.com/google/uuid"
)

type Repository struct {
	pool *database.Pool
}

func NewRepository(pool *database.Pool) Repository {
	return Repository{pool: pool}
}

func (r Repository) List(ctx context.Context, resource Resource, params ListParams) (ListResult, error) {
	where, args := buildWhere(resource, params)
	total, err := r.count(ctx, resource, where, args)
	if err != nil {
		return ListResult{}, err
	}

	page, perPage := normalizePagination(params.Page, params.PerPage)
	sortBy := resource.columnForRequest(params.SortBy)
	if sortBy == "" {
		sortBy = resource.DefaultSort
	}
	if sortBy == "" {
		sortBy = "created_at"
	}
	sortOrder := "ASC"
	if strings.EqualFold(params.SortOrder, "desc") || params.SortOrder == "" {
		sortOrder = "DESC"
	}

	args = append(args, perPage, (page-1)*perPage)
	query := fmt.Sprintf(
		"SELECT %s FROM %s %s ORDER BY %s %s LIMIT $%d OFFSET $%d",
		resource.selectColumns(), resource.Table, where, sortBy, sortOrder, len(args)-1, len(args),
	)

	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return ListResult{}, err
	}
	defer rows.Close()

	items, err := rowsToMaps(rows)
	if err != nil {
		return ListResult{}, err
	}

	totalPages := 0
	if total > 0 {
		totalPages = int(math.Ceil(float64(total) / float64(perPage)))
	}

	return ListResult{
		Rows: items,
		Meta: PaginationMeta{Page: page, PerPage: perPage, Total: total, TotalPages: totalPages, HasNext: page < totalPages, HasPrev: page > 1},
	}, nil
}

func (r Repository) Get(ctx context.Context, resource Resource, id uuid.UUID) (map[string]any, error) {
	where := "WHERE id = $1"
	if resource.SoftDelete {
		where += " AND deleted_at IS NULL"
	}
	query := fmt.Sprintf("SELECT %s FROM %s %s LIMIT 1", resource.selectColumns(), resource.Table, where)
	rows, err := r.pool.Query(ctx, query, id)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	items, err := rowsToMaps(rows)
	if err != nil {
		return nil, err
	}
	if len(items) == 0 {
		return nil, ErrNotFound
	}
	return items[0], nil
}

func (r Repository) Create(ctx context.Context, resource Resource, payload map[string]any) (map[string]any, error) {
	columns := []string{}
	placeholders := []string{}
	args := []any{}

	for _, field := range resource.Fields {
		value, ok := payload[field.Name]
		if !ok && field.APIName != "" {
			value, ok = payload[field.APIName]
		}
		if !ok {
			continue
		}
		columns = append(columns, field.Name)
		args = append(args, value)
		placeholders = append(placeholders, fmt.Sprintf("$%d", len(args)))
	}
	if _, ok := payload["status"]; !ok && resource.hasField("status") {
		columns = append(columns, "status")
		args = append(args, "active")
		placeholders = append(placeholders, fmt.Sprintf("$%d", len(args)))
	}

	query := fmt.Sprintf(
		"INSERT INTO %s (%s) VALUES (%s) RETURNING %s",
		resource.Table, strings.Join(columns, ", "), strings.Join(placeholders, ", "), resource.selectColumns(),
	)
	return r.queryOne(ctx, query, args...)
}

func (r Repository) Update(ctx context.Context, resource Resource, id uuid.UUID, payload map[string]any) (map[string]any, error) {
	sets := []string{}
	args := []any{}

	for _, field := range resource.Fields {
		value, ok := payload[field.Name]
		if !ok && field.APIName != "" {
			value, ok = payload[field.APIName]
		}
		if !ok {
			continue
		}
		args = append(args, value)
		sets = append(sets, fmt.Sprintf("%s = $%d", field.Name, len(args)))
	}
	if len(sets) == 0 {
		return nil, ErrInvalidInput
	}
	args = append(args, id)
	sets = append(sets, "updated_at = now()")

	where := fmt.Sprintf("WHERE id = $%d", len(args))
	if resource.SoftDelete {
		where += " AND deleted_at IS NULL"
	}
	query := fmt.Sprintf("UPDATE %s SET %s %s RETURNING %s", resource.Table, strings.Join(sets, ", "), where, resource.selectColumns())
	item, err := r.queryOne(ctx, query, args...)
	if err != nil && errors.Is(err, ErrNotFound) {
		return nil, ErrNotFound
	}
	return item, err
}

func (r Repository) Delete(ctx context.Context, resource Resource, id uuid.UUID) (map[string]any, error) {
	var query string
	if resource.SoftDelete {
		query = fmt.Sprintf("UPDATE %s SET status = 'inactive', deleted_at = now(), updated_at = now() WHERE id = $1 AND deleted_at IS NULL RETURNING %s", resource.Table, resource.selectColumns())
	} else {
		query = fmt.Sprintf("UPDATE %s SET status = 'inactive', updated_at = now() WHERE id = $1 RETURNING %s", resource.Table, resource.selectColumns())
	}
	return r.queryOne(ctx, query, id)
}

func (r Repository) DuplicateExists(ctx context.Context, resource Resource, payload map[string]any, excludeID *uuid.UUID) (bool, error) {
	if resource.CodeField == "" {
		return false, nil
	}
	args := []any{}
	where := ""
	if resource.ScopedCode {
		code := stringValue(payload["code"])
		face := stringValue(payload["face"])
		containerSize := stringValue(payload["container_size"])
		args = append(args, code, face, containerSize)
		where = "LOWER(code) = LOWER($1) AND face = $2 AND COALESCE(container_size, 'all') = COALESCE(NULLIF($3, ''), 'all')"
	} else {
		value := stringValue(payload[resource.CodeField])
		args = append(args, value)
		where = fmt.Sprintf("LOWER(%s) = LOWER($1)", resource.CodeField)
	}
	if resource.SoftDelete {
		where += " AND deleted_at IS NULL"
	}
	if excludeID != nil {
		args = append(args, *excludeID)
		where += fmt.Sprintf(" AND id <> $%d", len(args))
	}
	query := fmt.Sprintf("SELECT EXISTS (SELECT 1 FROM %s WHERE %s)", resource.Table, where)
	var exists bool
	if err := r.pool.QueryRow(ctx, query, args...).Scan(&exists); err != nil {
		return false, err
	}
	return exists, nil
}

func (r Repository) InsertAudit(ctx context.Context, entry AuditEntry) error {
	_, err := r.pool.Exec(ctx, `
		INSERT INTO audit_logs (
			user_id, active_role, action, entity_type, entity_id, old_value, new_value,
			request_id, ip_address, user_agent
		) VALUES ($1, $2, $3, $4, $5, NULLIF($6, 'null'), NULLIF($7, 'null'), NULLIF($8, ''), NULLIF($9, ''), NULLIF($10, ''))
	`, entry.UserID, entry.ActiveRole, entry.Action, entry.EntityType, entry.EntityID, string(entry.OldValue), string(entry.NewValue), entry.RequestID, entry.IPAddress, entry.UserAgent)
	return err
}

func (r Repository) count(ctx context.Context, resource Resource, where string, args []any) (int, error) {
	query := fmt.Sprintf("SELECT COUNT(*) FROM %s %s", resource.Table, where)
	var total int
	if err := r.pool.QueryRow(ctx, query, args...).Scan(&total); err != nil {
		return 0, err
	}
	return total, nil
}

func (r Repository) queryOne(ctx context.Context, query string, args ...any) (map[string]any, error) {
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	items, err := rowsToMaps(rows)
	if err != nil {
		return nil, err
	}
	if len(items) == 0 {
		return nil, ErrNotFound
	}
	return items[0], nil
}

func buildWhere(resource Resource, params ListParams) (string, []any) {
	clauses := []string{}
	args := []any{}
	if resource.SoftDelete {
		clauses = append(clauses, "deleted_at IS NULL")
	}
	if strings.TrimSpace(params.Search) != "" && len(resource.SearchColumns) > 0 {
		args = append(args, "%"+strings.TrimSpace(params.Search)+"%")
		searchParts := []string{}
		for _, column := range resource.SearchColumns {
			searchParts = append(searchParts, fmt.Sprintf("%s LIKE $%d", column, len(args)))
		}
		clauses = append(clauses, "("+strings.Join(searchParts, " OR ")+")")
	}
	for queryKey, column := range resource.Filters {
		value := ""
		if queryKey == "status" {
			value = params.Status
		} else {
			value = params.Filters[queryKey]
		}
		if strings.TrimSpace(value) == "" {
			continue
		}
		args = append(args, value)
		clauses = append(clauses, fmt.Sprintf("%s = $%d", column, len(args)))
	}
	if len(clauses) == 0 {
		return "", args
	}
	return "WHERE " + strings.Join(clauses, " AND "), args
}

func rowsToMaps(rows database.Rows) ([]map[string]any, error) {
	fields := rows.FieldDescriptions()
	items := []map[string]any{}
	for rows.Next() {
		values, err := rows.Values()
		if err != nil {
			return nil, err
		}
		item := map[string]any{}
		for index, field := range fields {
			item[string(field.Name)] = normalizeDBValue(values[index])
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func normalizeDBValue(value any) any {
	switch v := value.(type) {
	case time.Time:
		return v.UTC().Format(time.RFC3339)
	default:
		return v
	}
}

func normalizePagination(page int, perPage int) (int, int) {
	if page < 1 {
		page = 1
	}
	if perPage < 1 {
		perPage = 20
	}
	if perPage > 100 {
		perPage = 100
	}
	return page, perPage
}

func (resource Resource) selectColumns() string {
	columns := []string{"id AS id"}
	for _, field := range resource.Fields {
		outputName := field.Name
		if field.APIName != "" {
			outputName = field.APIName
		}
		expression := field.Name
		if strings.HasSuffix(field.Name, "_id") {
			expression = field.Name + ""
		}
		if field.Name == "gps_latitude" || field.Name == "gps_longitude" {
			expression = field.Name + ""
		}
		if outputName != field.Name || expression != field.Name {
			columns = append(columns, fmt.Sprintf("%s AS %s", expression, outputName))
		} else {
			columns = append(columns, field.Name)
		}
	}
	columns = append(columns, "created_at", "updated_at")
	return strings.Join(columns, ", ")
}

func (resource Resource) hasField(name string) bool {
	for _, field := range resource.Fields {
		if field.Name == name {
			return true
		}
	}
	return false
}

func (resource Resource) columnForRequest(requested string) string {
	requested = strings.TrimSpace(requested)
	if requested == "" {
		return ""
	}
	allowed := map[string]string{"id": "id", "created_at": "created_at", "updated_at": "updated_at"}
	for _, field := range resource.Fields {
		allowed[field.Name] = field.Name
		if field.APIName != "" {
			allowed[field.APIName] = field.Name
		}
	}
	return allowed[requested]
}

func stringValue(value any) string {
	if value == nil {
		return ""
	}
	return strings.TrimSpace(fmt.Sprint(value))
}

func mustJSON(value any) json.RawMessage {
	bytes, err := json.Marshal(value)
	if err != nil {
		return json.RawMessage("null")
	}
	return bytes
}
