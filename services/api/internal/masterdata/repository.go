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

type queryExecutor interface {
	Exec(context.Context, string, ...any) (database.CommandTag, error)
	Query(context.Context, string, ...any) (database.Rows, error)
	QueryRow(context.Context, string, ...any) database.Row
}

type Repository struct {
	pool     *database.Pool
	executor queryExecutor
}

func NewRepository(pool *database.Pool) Repository {
	return Repository{pool: pool, executor: pool}
}

func (r Repository) runner() queryExecutor {
	if r.executor != nil {
		return r.executor
	}
	return r.pool
}

func (r Repository) WithTx(ctx context.Context, fn func(repositoryPort) error) error {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return err
	}
	txRepo := Repository{pool: r.pool, executor: tx}
	if err := fn(txRepo); err != nil {
		_ = tx.Rollback(ctx)
		return err
	}
	if err := tx.Commit(ctx); err != nil {
		_ = tx.Rollback(ctx)
		return err
	}
	return nil
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

	rows, err := r.runner().Query(ctx, query, args...)
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
	if resource.LegacyOnly {
		where += " AND customer_id IS NULL"
	}
	if resource.SoftDelete {
		where += " AND deleted_at IS NULL"
	}
	query := fmt.Sprintf("SELECT %s FROM %s %s LIMIT 1", resource.selectColumns(), resource.Table, where)
	rows, err := r.runner().Query(ctx, query, id)
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
	statusField := resource.statusField()
	if statusField != "" {
		if _, ok := payload[statusField]; !ok && resource.hasField(statusField) {
			columns = append(columns, statusField)
			args = append(args, resource.activeStatusValue())
			placeholders = append(placeholders, fmt.Sprintf("$%d", len(args)))
		}
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
	if resource.LegacyOnly {
		where += " AND customer_id IS NULL"
	}
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
	statusField := resource.statusField()
	if statusField == "" {
		return nil, ErrInvalidInput
	}

	var query string
	if resource.SoftDelete {
		legacyWhere := ""
		if resource.LegacyOnly {
			legacyWhere = " AND customer_id IS NULL"
		}
		query = fmt.Sprintf("UPDATE %s SET %s = $1, deleted_at = now(), updated_at = now() WHERE id = $2%s AND deleted_at IS NULL RETURNING %s", resource.Table, statusField, legacyWhere, resource.selectColumns())
	} else {
		legacyWhere := ""
		if resource.LegacyOnly {
			legacyWhere = " AND customer_id IS NULL"
		}
		query = fmt.Sprintf("UPDATE %s SET %s = $1, updated_at = now() WHERE id = $2%s RETURNING %s", resource.Table, statusField, legacyWhere, resource.selectColumns())
	}
	return r.queryOne(ctx, query, resource.inactiveStatusValue(), id)
}

func (r Repository) DuplicateExists(ctx context.Context, resource Resource, payload map[string]any, excludeID *uuid.UUID) (bool, error) {
	args := []any{}
	where := ""
	if len(resource.DuplicateFields) > 0 {
		parts := []string{}
		for _, field := range resource.DuplicateFields {
			args = append(args, stringValue(payload[field]))
			operator := "="
			if field == resource.CodeField || strings.HasSuffix(field, "_code") || field == "code" {
				operator = "LOWER"
			}
			if operator == "LOWER" {
				parts = append(parts, fmt.Sprintf("LOWER(%s) = LOWER($%d)", field, len(args)))
			} else {
				parts = append(parts, fmt.Sprintf("%s = $%d", field, len(args)))
			}
		}
		where = strings.Join(parts, " AND ")
	} else if resource.CodeField == "" {
		return false, nil
	} else if resource.ScopedCode {
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
	if resource.LegacyOnly {
		where += " AND customer_id IS NULL"
	}
	if excludeID != nil {
		args = append(args, *excludeID)
		where += fmt.Sprintf(" AND id <> $%d", len(args))
	}
	query := fmt.Sprintf("SELECT EXISTS (SELECT 1 FROM %s WHERE %s)", resource.Table, where)
	var exists bool
	if err := r.runner().QueryRow(ctx, query, args...).Scan(&exists); err != nil {
		return false, err
	}
	return exists, nil
}

func (r Repository) InsertAudit(ctx context.Context, entry AuditEntry) error {
	_, err := r.runner().Exec(ctx, `
		INSERT INTO audit_logs (
			user_id, active_role, action, entity_type, entity_id, old_value, new_value,
			request_id, ip_address, user_agent
		) VALUES ($1, $2, $3, $4, $5, NULLIF(NULLIF($6, ''), 'null'), NULLIF(NULLIF($7, ''), 'null'), NULLIF($8, ''), NULLIF($9, ''), NULLIF($10, ''))
	`, entry.UserID, entry.ActiveRole, entry.Action, entry.EntityType, entry.EntityID, string(entry.OldValue), string(entry.NewValue), entry.RequestID, entry.IPAddress, entry.UserAgent)
	return err
}

func (r Repository) ValidateDomainMutation(ctx context.Context, resource Resource, payload map[string]any, id *uuid.UUID) error {
	if resource.Name != "fitness_checklist_templates" || resource.LegacyOnly {
		return nil
	}
	customerID, err := uuid.Parse(stringValue(payload["customer_id"]))
	if err != nil {
		return fmt.Errorf("%w: customer_id wajib diisi", ErrInvalidInput)
	}
	surveyTypeID, err := uuid.Parse(stringValue(payload["survey_type_id"]))
	if err != nil {
		return fmt.Errorf("%w: survey_type_id wajib diisi", ErrInvalidInput)
	}
	containerTypeID, err := uuid.Parse(stringValue(payload["container_type_id"]))
	if err != nil {
		return fmt.Errorf("%w: container_type_id wajib diisi", ErrInvalidInput)
	}
	var customerCount, surveyTypeCount, containerTypeCount int
	if err := r.runner().QueryRow(ctx, `SELECT COUNT(*) FROM customers WHERE id=$1 AND status='active' AND deleted_at IS NULL`, customerID).Scan(&customerCount); err != nil {
		return err
	}
	if err := r.runner().QueryRow(ctx, `SELECT COUNT(*) FROM survey_types WHERE id=$1 AND customer_id=$2 AND status='active'`, surveyTypeID, customerID).Scan(&surveyTypeCount); err != nil {
		return err
	}
	if err := r.runner().QueryRow(ctx, `SELECT COUNT(*) FROM container_types WHERE id=$1 AND customer_id=$2 AND status='active'`, containerTypeID, customerID).Scan(&containerTypeCount); err != nil {
		return err
	}
	if customerCount != 1 || surveyTypeCount != 1 || containerTypeCount != 1 {
		return fmt.Errorf("%w: Customer, Survey Type, dan Container Type harus aktif dan berasal dari Customer yang sama", ErrInvalidInput)
	}
	if stringValue(payload["status"]) == "active" {
		if id == nil {
			return fmt.Errorf("%w: Template harus disimpan sebagai draft sebelum item aktif ditambahkan", ErrInvalidInput)
		}
		var activeItems int
		if err := r.runner().QueryRow(ctx, `SELECT COUNT(*) FROM fitness_checklist_template_items WHERE template_id=$1 AND status='active'`, *id).Scan(&activeItems); err != nil {
			return err
		}
		if activeItems == 0 {
			return fmt.Errorf("%w: Template aktif wajib mempunyai minimal satu item aktif", ErrInvalidInput)
		}
	}
	return nil
}

func (r Repository) count(ctx context.Context, resource Resource, where string, args []any) (int, error) {
	query := fmt.Sprintf("SELECT COUNT(*) FROM %s %s", resource.Table, where)
	var total int
	if err := r.runner().QueryRow(ctx, query, args...).Scan(&total); err != nil {
		return 0, err
	}
	return total, nil
}

func (r Repository) queryOne(ctx context.Context, query string, args ...any) (map[string]any, error) {
	rows, err := r.runner().Query(ctx, query, args...)
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
	if resource.LegacyOnly {
		clauses = append(clauses, "customer_id IS NULL")
	}
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
			column = resource.statusField()
		} else {
			value = params.Filters[queryKey]
		}
		if strings.TrimSpace(value) == "" || column == "" {
			continue
		}
		filterValue := any(value)
		if queryKey == "status" {
			converted, ok := resource.statusQueryValue(value)
			if !ok {
				continue
			}
			filterValue = converted
		}
		args = append(args, filterValue)
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
		if outputName != field.Name {
			columns = append(columns, fmt.Sprintf("%s AS %s", expression, outputName))
		} else {
			columns = append(columns, field.Name)
		}
	}
	for _, relation := range resource.RelationDisplays {
		columns = append(columns, relationDisplayExpression(resource, relation))
	}
	columns = append(columns, "created_at", "updated_at")
	return strings.Join(columns, ", ")
}

func relationDisplayExpression(resource Resource, relation RelationDisplay) string {
	alias := "rel_" + relation.Alias
	return fmt.Sprintf(
		"(SELECT CONCAT_WS(' - ', %s.%s, %s.%s) FROM %s %s WHERE %s.id = %s.%s) AS %s",
		alias, relation.CodeColumn, alias, relation.NameColumn, relation.Table, alias, alias, resource.Table, relation.Field, relation.Alias,
	)
}

func (resource Resource) hasField(name string) bool {
	for _, field := range resource.Fields {
		if field.Name == name {
			return true
		}
	}
	return false
}

func (resource Resource) statusField() string {
	if resource.StatusField != "" {
		return resource.StatusField
	}
	if resource.hasField("status") {
		return "status"
	}
	return ""
}

func (resource Resource) activeStatusValue() any {
	if resource.ActiveStatusValue != nil {
		return resource.ActiveStatusValue
	}
	if resource.statusField() == "is_active" {
		return true
	}
	return "active"
}

func (resource Resource) inactiveStatusValue() any {
	if resource.InactiveStatusValue != nil {
		return resource.InactiveStatusValue
	}
	if resource.statusField() == "is_active" {
		return false
	}
	return "inactive"
}

func (resource Resource) allowedStatusValues() []string {
	if len(resource.AllowedStatusValues) > 0 {
		return resource.AllowedStatusValues
	}
	return []string{"active", "inactive"}
}

func (resource Resource) statusQueryValue(status string) (any, bool) {
	status = strings.TrimSpace(status)
	if !oneOf(status, resource.allowedStatusValues()) {
		return nil, false
	}
	if resource.statusField() == "is_active" {
		return status == "active", true
	}
	return status, true
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
