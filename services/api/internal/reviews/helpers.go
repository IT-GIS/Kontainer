package reviews

import (
	"container-survey/services/api/internal/database"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"

	"github.com/google/uuid"
)

func (r Repository) surveyBase(ctx context.Context, surveyID uuid.UUID) (map[string]any, error) {
	return r.queryOne(ctx, surveyBaseQuery(), surveyID)
}

func (r Repository) surveyForUpdate(ctx context.Context, tx database.Tx, surveyID uuid.UUID) (map[string]any, error) {
	rows, err := tx.Query(ctx, surveyBaseQuery()+" FOR UPDATE", surveyID)
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

func surveyBaseQuery() string {
	return `
		SELECT s.id, s.survey_no, s.status, s.job_order_id, s.job_container_id, s.surveyor_id,
		       s.survey_type_id, s.current_revision_no, s.survey_result, s.submitted_at, s.approved_at,
		       jo.job_order_no, jo.customer_id, jc.container_no, c.customer_name, l.location_name,
		       st.name AS survey_type_name, sp.full_name AS surveyor_name
		FROM surveys s
		JOIN job_orders jo ON jo.id=s.job_order_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN customers c ON c.id=jo.customer_id
		JOIN locations l ON l.id=jo.location_id
		JOIN survey_types st ON st.id=s.survey_type_id
		JOIN surveyor_profiles sp ON sp.id=s.surveyor_id
		WHERE s.id=$1 AND s.deleted_at IS NULL
	`
}

func surveyWhere(params ListParams, status string) (string, []any) {
	args := []any{}
	clauses := []string{"s.deleted_at IS NULL"}
	if params.Status != "" {
		status = normalizeSurveyListStatus(params.Status)
	}
	if status != "" {
		args = append(args, status)
		clauses = append(clauses, fmt.Sprintf("s.status=$%d", len(args)))
	}
	if params.CustomerID != "" {
		args = append(args, params.CustomerID)
		clauses = append(clauses, fmt.Sprintf("jo.customer_id=$%d", len(args)))
	}
	if params.SurveyTypeID != "" {
		args = append(args, params.SurveyTypeID)
		clauses = append(clauses, fmt.Sprintf("s.survey_type_id=$%d", len(args)))
	}
	if params.Search != "" {
		args = append(args, "%"+strings.TrimSpace(params.Search)+"%")
		clauses = append(clauses, fmt.Sprintf("(s.survey_no LIKE $%d OR jc.container_no LIKE $%d OR jo.job_order_no LIKE $%d OR c.customer_name LIKE $%d OR sp.full_name LIKE $%d)", len(args), len(args), len(args), len(args), len(args)))
	}
	return "WHERE " + strings.Join(clauses, " AND "), args
}

func normalizeSurveyListStatus(status string) string {
	status = strings.TrimSpace(strings.ToLower(status))
	if status == "in_progress" {
		return "draft"
	}
	return status
}

func reportWhere(params ListParams) (string, []any) {
	args := []any{}
	clauses := []string{"1=1"}
	if params.Status != "" {
		args = append(args, params.Status)
		clauses = append(clauses, fmt.Sprintf("r.status=$%d", len(args)))
	}
	if params.CustomerID != "" {
		args = append(args, params.CustomerID)
		clauses = append(clauses, fmt.Sprintf("r.customer_id=$%d", len(args)))
	}
	if params.Search != "" {
		args = append(args, "%"+strings.TrimSpace(params.Search)+"%")
		clauses = append(clauses, fmt.Sprintf("(r.report_no LIKE $%d OR s.survey_no LIKE $%d OR jc.container_no LIKE $%d OR c.customer_name LIKE $%d)", len(args), len(args), len(args), len(args)))
	}
	return "WHERE " + strings.Join(clauses, " AND "), args
}

func (r Repository) count(ctx context.Context, where string, args []any) (int, error) {
	var total int
	err := r.pool.QueryRow(ctx, `
		SELECT COUNT(*)
		FROM surveys s
		JOIN job_orders jo ON jo.id=s.job_order_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN customers c ON c.id=jo.customer_id
		JOIN survey_types st ON st.id=s.survey_type_id
		JOIN surveyor_profiles sp ON sp.id=s.surveyor_id
	`+where, args...).Scan(&total)
	return total, err
}

func (r Repository) queryRows(ctx context.Context, query string, args ...any) ([]map[string]any, error) {
	rows, err := r.pool.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return rowsToMaps(rows)
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
			item[string(field.Name)] = normalizeValue(values[index])
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func scanRow(row database.Row, keys []string) (map[string]any, error) {
	values := make([]any, len(keys))
	ptrs := make([]any, len(keys))
	for i := range values {
		ptrs[i] = &values[i]
	}
	if err := row.Scan(ptrs...); err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	item := map[string]any{}
	for i, key := range keys {
		item[key] = normalizeValue(values[i])
	}
	return item, nil
}

func normalizeValue(value any) any {
	switch v := value.(type) {
	case time.Time:
		return v.UTC().Format(time.RFC3339)
	case uuid.UUID:
		return v.String()
	case []byte:
		return string(v)
	default:
		return v
	}
}

func normalizePagination(page, perPage int) (int, int) {
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

func parseUUIDString(value any) uuid.UUID {
	parsed, _ := uuid.Parse(fmt.Sprint(value))
	return parsed
}

func intFromAny(value any) int {
	switch v := value.(type) {
	case int:
		return v
	case int32:
		return int(v)
	case int64:
		return int(v)
	default:
		var out int
		_, _ = fmt.Sscan(fmt.Sprint(value), &out)
		return out
	}
}

func defaultString(value string, fallback string) string {
	if strings.TrimSpace(value) == "" {
		return fallback
	}
	return value
}

func recommendedResult(damages []map[string]any) string {
	if len(damages) == 0 {
		return "sound"
	}
	for _, damage := range damages {
		if fmt.Sprint(damage["severity"]) == "critical" || fmt.Sprint(damage["is_cargo_worthy_impact"]) == "true" {
			return "not_cargo_worthy"
		}
	}
	return "damage"
}

func (r Repository) insertJobEvent(ctx context.Context, tx database.Tx, jobID uuid.UUID, eventType, title, description string, actorID uuid.UUID, metadata any) error {
	bytes, _ := json.Marshal(metadata)
	_, err := tx.Exec(ctx, `INSERT INTO job_events (job_order_id,event_type,event_title,event_description,actor_id,metadata) VALUES ($1,$2,$3,$4,$5,$6)`, jobID, eventType, title, description, actorID, string(bytes))
	return err
}

func (r Repository) insertAudit(ctx context.Context, tx database.Tx, actor Actor, action, entityType string, entityID *uuid.UUID, oldValue any, newValue any) error {
	oldJSON, _ := json.Marshal(oldValue)
	newJSON, _ := json.Marshal(newValue)
	_, err := tx.Exec(ctx, `INSERT INTO audit_logs (user_id,active_role,action,entity_type,entity_id,old_value,new_value,request_id,ip_address,user_agent) VALUES ($1,$2,$3,$4,$5,NULLIF($6,'null'),NULLIF($7,'null'),NULLIF($8,''),NULLIF($9,''),NULLIF($10,''))`, actor.UserID, actor.ActiveRole, action, entityType, entityID, string(oldJSON), string(newJSON), actor.RequestID, actor.IPAddress, actor.UserAgent)
	return err
}
