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
		       s.survey_type_id, s.current_revision_no, s.current_reviewer_id,
		       reviewer.name AS current_reviewer_name, s.survey_result, s.submitted_at,
		       s.review_started_at, s.resubmitted_at, s.approved_at, s.rejected_at,
		       jo.job_order_no, jo.customer_id, jc.container_no, c.customer_name, l.location_name,
		       st.name AS survey_type_name, sp.full_name AS surveyor_name
		FROM surveys s
		JOIN job_orders jo ON jo.id=s.job_order_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN customers c ON c.id=jo.customer_id
		JOIN locations l ON l.id=jo.location_id
		JOIN survey_types st ON st.id=s.survey_type_id
		JOIN surveyor_profiles sp ON sp.id=s.surveyor_id
		LEFT JOIN users reviewer ON reviewer.id=s.current_reviewer_id
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
		if status == "submitted" {
			clauses = append(clauses, "s.status IN ('submitted','under_review','resubmitted')")
		} else {
			args = append(args, status)
			clauses = append(clauses, fmt.Sprintf("s.status=$%d", len(args)))
		}
	}
	if params.CustomerID != "" {
		args = append(args, params.CustomerID)
		clauses = append(clauses, fmt.Sprintf("jo.customer_id=$%d", len(args)))
	}
	if params.SurveyTypeID != "" {
		args = append(args, params.SurveyTypeID)
		clauses = append(clauses, fmt.Sprintf("s.survey_type_id=$%d", len(args)))
	}
	if params.SurveyorID != "" {
		args = append(args, params.SurveyorID)
		clauses = append(clauses, fmt.Sprintf("s.surveyor_id=$%d", len(args)))
	}
	if params.LocationID != "" {
		args = append(args, params.LocationID)
		clauses = append(clauses, fmt.Sprintf("jo.location_id=$%d", len(args)))
	}
	dateExpression := surveyDateExpression(status)
	if from, ok := parseFilterDate(params.DateFrom); ok && from != nil {
		args = append(args, *from)
		clauses = append(clauses, fmt.Sprintf("%s >= $%d", dateExpression, len(args)))
	}
	if to, ok := parseFilterDate(params.DateTo); ok && to != nil {
		args = append(args, to.AddDate(0, 0, 1))
		clauses = append(clauses, fmt.Sprintf("%s < $%d", dateExpression, len(args)))
	}
	if params.Search != "" {
		args = append(args, "%"+strings.TrimSpace(params.Search)+"%")
		clauses = append(clauses, fmt.Sprintf("(s.survey_no LIKE $%d OR jc.container_no LIKE $%d OR jo.job_order_no LIKE $%d OR c.customer_name LIKE $%d OR sp.full_name LIKE $%d)", len(args), len(args), len(args), len(args), len(args)))
	}
	return "WHERE " + strings.Join(clauses, " AND "), args
}

func surveyDateExpression(status string) string {
	switch normalizeSurveyListStatus(status) {
	case "draft":
		return "COALESCE(s.started_at, s.created_at)"
	case "submitted", "under_review", "resubmitted":
		return "COALESCE(s.resubmitted_at, s.review_started_at, s.submitted_at, s.created_at)"
	case "need_revision", "rejected":
		return "COALESCE(s.submitted_at, s.created_at)"
	case "approved":
		return "COALESCE(s.approved_at, s.created_at)"
	default:
		return "s.created_at"
	}
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
	if params.JobOrderID != "" {
		args = append(args, params.JobOrderID)
		clauses = append(clauses, fmt.Sprintf("r.job_order_id=$%d", len(args)))
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

func queryRowsTx(ctx context.Context, tx database.Tx, query string, args ...any) ([]map[string]any, error) {
	rows, err := tx.Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return rowsToMaps(rows)
}

func (r Repository) revisionSnapshotTx(ctx context.Context, tx database.Tx, surveyID uuid.UUID, _ map[string]any) (string, error) {
	surveyRows, err := queryRowsTx(ctx, tx, `SELECT * FROM surveys WHERE id=$1`, surveyID)
	if err != nil {
		return "", err
	}
	generalRows, err := queryRowsTx(ctx, tx, `SELECT * FROM survey_general_infos WHERE survey_id=$1`, surveyID)
	if err != nil {
		return "", err
	}
	checklist, err := queryRowsTx(ctx, tx, `
		SELECT * FROM survey_checklist_responses
		WHERE survey_id=$1 ORDER BY display_order, item_code
	`, surveyID)
	if err != nil {
		return "", err
	}
	damages, err := queryRowsTx(ctx, tx, `
		SELECT * FROM survey_damages
		WHERE survey_id=$1 AND deleted_at IS NULL ORDER BY damage_no
	`, surveyID)
	if err != nil {
		return "", err
	}
	photos, err := queryRowsTx(ctx, tx, `
		SELECT * FROM survey_photos
		WHERE survey_id=$1 AND deleted_at IS NULL ORDER BY created_at, id
	`, surveyID)
	if err != nil {
		return "", err
	}
	var survey any
	if len(surveyRows) > 0 {
		survey = surveyRows[0]
	}
	var general any
	if len(generalRows) > 0 {
		general = generalRows[0]
	}
	payload, err := json.Marshal(map[string]any{
		"survey": survey, "general_info": general, "checklist": checklist,
		"damages": damages, "photos": photos,
	})
	if err != nil {
		return "", err
	}
	return string(payload), nil
}

func reviewableStatus(status string) bool {
	return status == "under_review"
}

func requireCurrentReviewer(base map[string]any, actor Actor) error {
	if parseUUIDString(base["current_reviewer_id"]) != actor.UserID {
		return ErrReviewClaimed
	}
	return nil
}

func validateRevisionTargetTx(ctx context.Context, tx database.Tx, surveyID uuid.UUID, targetType, rawTargetID string) (any, error) {
	if targetType == "survey" {
		if strings.TrimSpace(rawTargetID) != "" {
			return nil, ErrInvalidInput
		}
		return nil, nil
	}
	tables := map[string]string{
		"finding":   "survey_damages",
		"checklist": "survey_checklist_responses",
		"photo":     "survey_photos",
	}
	table, ok := tables[targetType]
	if !ok {
		return nil, ErrInvalidInput
	}
	targetID, err := uuid.Parse(strings.TrimSpace(rawTargetID))
	if err != nil {
		return nil, ErrInvalidInput
	}
	var count int
	query := fmt.Sprintf("SELECT COUNT(*) FROM %s WHERE id=$1 AND survey_id=$2", table)
	if targetType == "finding" || targetType == "photo" {
		query += " AND deleted_at IS NULL"
	}
	if err := tx.QueryRow(ctx, query, targetID, surveyID).Scan(&count); err != nil {
		return nil, err
	}
	if count != 1 {
		return nil, ErrInvalidInput
	}
	return targetID, nil
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
