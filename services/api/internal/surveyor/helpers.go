package surveyor

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

func (r Repository) surveyorID(ctx context.Context, userID uuid.UUID) (uuid.UUID, error) {
	var id uuid.UUID
	err := r.pool.QueryRow(ctx, `SELECT id FROM surveyor_profiles WHERE user_id=$1 AND is_active=true AND deleted_at IS NULL LIMIT 1`, userID).Scan(&id)
	if err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return uuid.Nil, ErrForbidden
		}
		return uuid.Nil, err
	}
	return id, nil
}

func (r Repository) assignedContainerTx(ctx context.Context, tx database.Tx, containerID uuid.UUID, surveyorID uuid.UUID) (map[string]any, error) {
	item, err := scanRow(tx.QueryRow(ctx, `
		SELECT jc.id, jc.job_order_id, jc.container_no, jc.container_type_id, jc.iso_type_code, jc.seal_no,
		       jc.cargo_status, jc.truck_no, jc.driver_name, jc.csc_plate_status, jc.status,
		       jo.job_order_no, jo.customer_id, jo.location_id, jo.survey_type_id,
		       a.id AS assignment_id
		FROM assignment_containers ac
		JOIN assignments a ON a.id=ac.assignment_id
		JOIN job_containers jc ON jc.id=ac.job_container_id AND jc.deleted_at IS NULL
		JOIN job_orders jo ON jo.id=jc.job_order_id AND jo.deleted_at IS NULL
		WHERE ac.job_container_id=$1 AND ac.unassigned_at IS NULL AND a.surveyor_id=$2
		FOR UPDATE
	`, containerID, surveyorID), []string{"id", "job_order_id", "container_no", "container_type_id", "iso_type_code", "seal_no", "cargo_status", "truck_no", "driver_name", "csc_plate_status", "status", "job_order_no", "customer_id", "location_id", "survey_type_id", "assignment_id"})
	if err != nil {
		return nil, err
	}
	return item, nil
}

func (r Repository) existingSurveyTx(ctx context.Context, tx database.Tx, containerID uuid.UUID, surveyTypeID uuid.UUID) (map[string]any, error) {
	return scanRow(tx.QueryRow(ctx, `
		SELECT s.id, s.survey_no, s.status, jo.job_order_no, jc.container_no
		FROM surveys s
		JOIN job_orders jo ON jo.id=s.job_order_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		WHERE s.job_container_id=$1 AND s.survey_type_id=$2 AND s.deleted_at IS NULL
		LIMIT 1
	`, containerID, surveyTypeID), []string{"id", "survey_no", "status", "job_order_no", "container_no"})
}

func (r Repository) surveyBase(ctx context.Context, surveyID uuid.UUID, actor Actor) (map[string]any, error) {
	rows, err := r.pool.Query(ctx, surveyBaseQuery(), surveyID, actor.UserID)
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

func (r Repository) surveyBaseTx(ctx context.Context, tx database.Tx, surveyID uuid.UUID, actor Actor) (map[string]any, error) {
	rows, err := tx.Query(ctx, surveyBaseQuery()+" FOR UPDATE", surveyID, actor.UserID)
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
		       s.survey_type_id, s.started_at, s.submitted_at, s.final_remark,
		       jo.job_order_no, jc.container_no, c.customer_name, l.location_name, st.name AS survey_type_name,
		       sp.full_name AS surveyor_name
		FROM surveys s
		JOIN job_orders jo ON jo.id=s.job_order_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN customers c ON c.id=jo.customer_id
		JOIN locations l ON l.id=jo.location_id
		JOIN survey_types st ON st.id=s.survey_type_id
		JOIN surveyor_profiles sp ON sp.id=s.surveyor_id
		WHERE s.id=$1 AND s.deleted_at IS NULL
		  AND sp.user_id=$2
	`
}

func (r Repository) damageSurveyID(ctx context.Context, damageID uuid.UUID) (uuid.UUID, error) {
	var id uuid.UUID
	err := r.pool.QueryRow(ctx, `SELECT survey_id FROM survey_damages WHERE id=$1 AND deleted_at IS NULL`, damageID).Scan(&id)
	if err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return uuid.Nil, ErrNotFound
		}
		return uuid.Nil, err
	}
	return id, nil
}

func (r Repository) resolveCEDEXLocation(ctx context.Context, tx database.Tx, input DamageInput) (*uuid.UUID, error) {
	if input.CEDEXLocationID != "" {
		id, err := uuid.Parse(input.CEDEXLocationID)
		if err != nil {
			return nil, ErrInvalidInput
		}
		return &id, nil
	}
	if strings.TrimSpace(input.CEDEXLocationCode) == "" {
		return nil, nil
	}
	var id uuid.UUID
	err := tx.QueryRow(ctx, `SELECT id FROM cedex_locations WHERE LOWER(code)=LOWER($1) AND deleted_at IS NULL LIMIT 1`, input.CEDEXLocationCode).Scan(&id)
	if err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return nil, ErrInvalidInput
		}
		return nil, err
	}
	return &id, nil
}

func (r Repository) nextDamageNo(ctx context.Context, tx database.Tx, surveyID uuid.UUID) (string, error) {
	_, err := tx.Exec(ctx, `INSERT IGNORE INTO survey_damage_counters (survey_id,last_number) VALUES ($1,0)`, surveyID)
	if err != nil {
		return "", err
	}
	var next int
	err = tx.QueryRow(ctx, `UPDATE survey_damage_counters SET last_number=last_number+1, updated_at=now() WHERE survey_id=$1 RETURNING last_number`, surveyID).Scan(&next)
	if err != nil {
		return "", err
	}
	return fmt.Sprintf("D-%03d", next), nil
}

func (r Repository) nextDocNo(ctx context.Context, tx database.Tx, code string, table string) (string, error) {
	var total int
	query := fmt.Sprintf("SELECT COUNT(*) FROM %s", table)
	if err := tx.QueryRow(ctx, query).Scan(&total); err != nil {
		return "", err
	}
	return fmt.Sprintf("GIFT-%s-%d-%06d", code, time.Now().Year(), total+1), nil
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

func (r Repository) count(ctx context.Context, from string, where string, args []any, distinctJob bool) (int, error) {
	selector := "COUNT(*)"
	if distinctJob {
		selector = "COUNT(DISTINCT jo.id)"
	}
	var total int
	if err := r.pool.QueryRow(ctx, fmt.Sprintf("SELECT %s FROM %s %s", selector, from, where), args...).Scan(&total); err != nil {
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
	default:
		return v
	}
}

func assignedJobWhere(params ListParams, surveyorID uuid.UUID) (string, []any) {
	args := []any{surveyorID}
	clauses := []string{"jo.deleted_at IS NULL", "a.surveyor_id=$1"}
	if params.Search != "" {
		args = append(args, "%"+strings.TrimSpace(params.Search)+"%")
		clauses = append(clauses, fmt.Sprintf("(jo.job_order_no LIKE $%d OR jo.reference_no LIKE $%d)", len(args), len(args)))
	}
	if params.Status != "" {
		args = append(args, params.Status)
		clauses = append(clauses, fmt.Sprintf("jo.status=$%d", len(args)))
	}
	if params.Date != "" {
		args = append(args, params.Date)
		clauses = append(clauses, fmt.Sprintf("jo.job_date=$%d", len(args)))
	}
	return "WHERE " + strings.Join(clauses, " AND "), args
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

func parseOptionalTime(value string) (*time.Time, error) {
	if strings.TrimSpace(value) == "" {
		return nil, nil
	}
	parsed, err := time.Parse(time.RFC3339, value)
	if err != nil {
		return nil, err
	}
	return &parsed, nil
}

func parseUUIDString(value any) uuid.UUID {
	parsed, _ := uuid.Parse(fmt.Sprint(value))
	return parsed
}

func nullableUUID(value any) *uuid.UUID {
	text := strings.TrimSpace(fmt.Sprint(value))
	if text == "" || text == "<nil>" {
		return nil
	}
	parsed, err := uuid.Parse(text)
	if err != nil {
		return nil
	}
	return &parsed
}

func nullableUUIDString(value string) *uuid.UUID {
	if strings.TrimSpace(value) == "" {
		return nil
	}
	parsed, err := uuid.Parse(value)
	if err != nil {
		return nil
	}
	return &parsed
}

func defaultString(value any, fallback string) string {
	text := strings.TrimSpace(fmt.Sprint(value))
	if text == "" || text == "<nil>" {
		return fallback
	}
	return text
}

func editableStatus(status string) bool {
	return status == "draft" || status == "need_revision"
}

func validateDamageInput(input DamageInput) error {
	if strings.TrimSpace(input.Face) == "" || strings.TrimSpace(input.InternalLocation) == "" || strings.TrimSpace(input.ComponentID) == "" || strings.TrimSpace(input.DamageID) == "" {
		return ErrInvalidInput
	}
	severity := defaultString(input.Severity, "minor")
	if severity != "minor" && severity != "major" && severity != "critical" {
		return ErrInvalidInput
	}
	if (severity == "major" || severity == "critical") && (input.Length == nil || input.Width == nil) {
		return ErrInvalidInput
	}
	return nil
}

func (r Repository) validateSurvey(survey map[string]any) []ValidationWarning {
	warnings := []ValidationWarning{}
	general, _ := survey["general_info"].(map[string]any)
	if general == nil {
		warnings = append(warnings, ValidationWarning{Code: "GENERAL_REQUIRED", Message: "General info wajib dilengkapi."})
	} else {
		cargo := fmt.Sprint(general["cargo_status"])
		condition := fmt.Sprint(general["general_condition"])
		if cargo == "" || cargo == "<nil>" || cargo == "unknown" {
			warnings = append(warnings, ValidationWarning{Code: "CARGO_STATUS_REQUIRED", Message: "Cargo status wajib diisi."})
		}
		if condition == "" || condition == "<nil>" {
			warnings = append(warnings, ValidationWarning{Code: "GENERAL_CONDITION_REQUIRED", Message: "General condition wajib diisi."})
		}
		if cargo == "laden" && strings.TrimSpace(fmt.Sprint(general["seal_no"])) == "" {
			warnings = append(warnings, ValidationWarning{Code: "SEAL_REQUIRED", Message: "Seal no wajib untuk laden container."})
		}
	}
	checklist, _ := survey["checklist"].([]map[string]any)
	if len(checklist) == 0 {
		warnings = append(warnings, ValidationWarning{Code: "CHECKLIST_REQUIRED", Message: "Checklist wajib diisi."})
	} else {
		for _, item := range checklist {
			required, _ := item["is_required"].(bool)
			if required && strings.TrimSpace(fmt.Sprint(item["value"])) == "" {
				warnings = append(warnings, ValidationWarning{Code: "CHECKLIST_INCOMPLETE", Message: "Checklist wajib belum lengkap."})
				break
			}
		}
	}
	damages, _ := survey["damages"].([]map[string]any)
	for _, damage := range damages {
		damageNo := fmt.Sprint(damage["damage_no"])
		if strings.TrimSpace(fmt.Sprint(damage["component_code"])) == "" || strings.TrimSpace(fmt.Sprint(damage["damage_code"])) == "" {
			warnings = append(warnings, ValidationWarning{Code: "DAMAGE_CODE_REQUIRED", Message: "Damage " + damageNo + " wajib memiliki component dan damage type."})
		}
		if strings.TrimSpace(fmt.Sprint(damage["internal_location"])) == "" {
			warnings = append(warnings, ValidationWarning{Code: "DAMAGE_LOCATION_REQUIRED", Message: "Damage " + damageNo + " wajib memiliki location."})
		}
		severity := fmt.Sprint(damage["severity"])
		if severity == "major" || severity == "critical" {
			if damage["length"] == nil || damage["width"] == nil {
				warnings = append(warnings, ValidationWarning{Code: "DAMAGE_SIZE_REQUIRED", Message: "Damage " + damageNo + " major/critical wajib memiliki ukuran."})
			}
		}
		if fmt.Sprint(damage["photo_count"]) == "0" {
			warnings = append(warnings, ValidationWarning{Code: "DAMAGE_PHOTO_REQUIRED", Message: "Damage " + damageNo + " belum memiliki foto."})
		}
	}
	return warnings
}

func recommendedResult(survey map[string]any) string {
	damages, _ := survey["damages"].([]map[string]any)
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

func defaultChecklist() []map[string]any {
	keys := []string{"container_number_readable", "iso_code_readable", "csc_plate_available", "exterior_condition_ok", "interior_clean", "door_can_open_close", "floor_condition_ok", "roof_condition_ok", "light_test_pass"}
	items := []map[string]any{}
	for index, key := range keys {
		items = append(items, map[string]any{"item_key": key, "item_label": defaultChecklistLabel(key), "value": "", "note": "", "is_required": true, "is_critical": key == "light_test_pass", "display_order": index + 1})
	}
	return items
}

func defaultChecklistLabel(key string) string {
	labels := map[string]string{
		"container_number_readable": "Container number readable",
		"iso_code_readable":         "ISO code readable",
		"csc_plate_available":       "CSC plate available",
		"exterior_condition_ok":     "Exterior condition OK",
		"interior_clean":            "Interior clean",
		"door_can_open_close":       "Door can open/close",
		"floor_condition_ok":        "Floor condition OK",
		"roof_condition_ok":         "Roof condition OK",
		"light_test_pass":           "Light test pass",
	}
	if label, ok := labels[key]; ok {
		return label
	}
	return strings.ReplaceAll(key, "_", " ")
}

func faceLabel(face string) string {
	labels := map[string]string{"left": "Left Side", "right": "Right Side", "front": "Front", "door": "Door", "roof": "Roof", "floor": "Floor", "understructure": "Understructure"}
	if label, ok := labels[face]; ok {
		return label
	}
	return face
}

func sanitizeFileName(value string) string {
	value = strings.ReplaceAll(value, "\\", "-")
	value = strings.ReplaceAll(value, "/", "-")
	value = strings.TrimSpace(value)
	if value == "" {
		return "photo"
	}
	return value
}
