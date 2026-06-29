package surveyor

import (
	"container-survey/services/api/internal/database"
	"context"
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

func (r Repository) Dashboard(ctx context.Context, actor Actor) (Dashboard, error) {
	surveyorID, err := r.surveyorID(ctx, actor.UserID)
	if err != nil {
		return Dashboard{}, err
	}
	row := r.pool.QueryRow(ctx, `
		SELECT COUNT(DISTINCT jo.id),
		       COUNT(DISTINCT CASE WHEN s.id IS NULL THEN jc.id END),
		       COUNT(DISTINCT CASE WHEN s.status='draft' THEN s.id END),
		       COUNT(DISTINCT CASE WHEN s.status='submitted' THEN s.id END),
		       COUNT(DISTINCT CASE WHEN s.status='need_revision' THEN s.id END),
		       COUNT(DISTINCT CASE WHEN s.status='approved' THEN s.id END)
		FROM assignments a
		JOIN assignment_containers ac ON ac.assignment_id = a.id AND ac.unassigned_at IS NULL
		JOIN job_orders jo ON jo.id = a.job_order_id AND jo.deleted_at IS NULL
		JOIN job_containers jc ON jc.id = ac.job_container_id AND jc.deleted_at IS NULL
		LEFT JOIN surveys s ON s.job_container_id = jc.id AND s.surveyor_id = a.surveyor_id AND s.deleted_at IS NULL
		WHERE a.surveyor_id = $1
	`, surveyorID)
	var item Dashboard
	if err := row.Scan(&item.TotalJobs, &item.NotStarted, &item.Draft, &item.Submitted, &item.NeedRevision, &item.Approved); err != nil {
		return Dashboard{}, err
	}
	return item, nil
}

func (r Repository) ListJobs(ctx context.Context, params ListParams, actor Actor) (ListResult, error) {
	surveyorID, err := r.surveyorID(ctx, actor.UserID)
	if err != nil {
		return ListResult{}, err
	}
	page, perPage := normalizePagination(params.Page, params.PerPage)
	where, args := assignedJobWhere(params, surveyorID)
	total, err := r.count(ctx, "job_orders jo JOIN assignments a ON a.job_order_id=jo.id JOIN assignment_containers ac ON ac.assignment_id=a.id AND ac.unassigned_at IS NULL", where, args, true)
	if err != nil {
		return ListResult{}, err
	}
	args = append(args, perPage, (page-1)*perPage)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT jo.id, jo.job_order_no, c.customer_name, l.location_name, st.name AS survey_type_name,
		       COUNT(DISTINCT jc.id) AS total_containers,
		       COUNT(DISTINCT CASE WHEN COALESCE(s.status, jc.status) IN ('submitted','approved','report_generated') THEN jc.id END) AS completed_containers,
		       jo.status, jo.deadline
		FROM job_orders jo
		JOIN customers c ON c.id = jo.customer_id
		JOIN locations l ON l.id = jo.location_id
		JOIN survey_types st ON st.id = jo.survey_type_id
		JOIN assignments a ON a.job_order_id = jo.id
		JOIN assignment_containers ac ON ac.assignment_id = a.id AND ac.unassigned_at IS NULL
		JOIN job_containers jc ON jc.id = ac.job_container_id AND jc.deleted_at IS NULL
		LEFT JOIN surveys s ON s.job_container_id = jc.id AND s.deleted_at IS NULL
		%s
		GROUP BY jo.id, c.id, l.id, st.id
		ORDER BY jo.deadline IS NULL, jo.deadline, jo.created_at DESC
		LIMIT $%d OFFSET $%d
	`, where, len(args)-1, len(args)), args...)
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
	return ListResult{Rows: items, Meta: PaginationMeta{Page: page, PerPage: perPage, Total: total, TotalPages: totalPages, HasNext: page < totalPages, HasPrev: page > 1}}, nil
}

func (r Repository) GetJob(ctx context.Context, jobID uuid.UUID, actor Actor) (map[string]any, error) {
	surveyorID, err := r.surveyorID(ctx, actor.UserID)
	if err != nil {
		return nil, err
	}
	item, err := r.queryOne(ctx, `
		SELECT jo.id, jo.job_order_no, jo.job_date, jo.status, jo.priority, jo.deadline, jo.instruction,
		       c.customer_name, l.location_name, st.name AS survey_type_name
		FROM job_orders jo
		JOIN customers c ON c.id = jo.customer_id
		JOIN locations l ON l.id = jo.location_id
		JOIN survey_types st ON st.id = jo.survey_type_id
		WHERE jo.id=$1 AND jo.deleted_at IS NULL
		  AND EXISTS (
		    SELECT 1 FROM assignments a
		    JOIN assignment_containers ac ON ac.assignment_id=a.id AND ac.unassigned_at IS NULL
		    WHERE a.job_order_id=jo.id AND a.surveyor_id=$2
		  )
	`, jobID, surveyorID)
	if err != nil {
		return nil, err
	}
	containers, err := r.ListContainers(ctx, jobID, actor)
	if err != nil {
		return nil, err
	}
	item["containers"] = containers
	return item, nil
}

func (r Repository) ListContainers(ctx context.Context, jobID uuid.UUID, actor Actor) ([]map[string]any, error) {
	surveyorID, err := r.surveyorID(ctx, actor.UserID)
	if err != nil {
		return nil, err
	}
	rows, err := r.pool.Query(ctx, `
		SELECT jc.id, jc.container_no, ct.code AS container_type_code, jc.seal_no, jc.cargo_status,
		       s.id AS survey_id, s.survey_no, COALESCE(s.status, jc.status) AS status
		FROM assignments a
		JOIN assignment_containers ac ON ac.assignment_id = a.id AND ac.unassigned_at IS NULL
		JOIN job_containers jc ON jc.id = ac.job_container_id AND jc.deleted_at IS NULL
		LEFT JOIN container_types ct ON ct.id = jc.container_type_id
		LEFT JOIN surveys s ON s.job_container_id = jc.id AND s.surveyor_id = a.surveyor_id AND s.deleted_at IS NULL
		WHERE a.job_order_id=$1 AND a.surveyor_id=$2
		ORDER BY jc.container_no
	`, jobID, surveyorID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return rowsToMaps(rows)
}

func (r Repository) StartSurvey(ctx context.Context, input StartSurveyInput, actor Actor) (map[string]any, error) {
	containerID, err := uuid.Parse(input.JobContainerID)
	if err != nil {
		return nil, ErrInvalidInput
	}
	surveyorID, err := r.surveyorID(ctx, actor.UserID)
	if err != nil {
		return nil, err
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	container, err := r.assignedContainerTx(ctx, tx, containerID, surveyorID)
	if err != nil {
		return nil, err
	}
	existing, err := r.existingSurveyTx(ctx, tx, containerID, parseUUIDString(container["survey_type_id"]))
	if err == nil {
		return existing, tx.Commit(ctx)
	}
	if !errors.Is(err, ErrNotFound) {
		return nil, err
	}
	surveyNo, err := r.nextDocNo(ctx, tx, "SVY", "surveys")
	if err != nil {
		return nil, err
	}
	surveyID := uuid.Nil
	jobID := parseUUIDString(container["job_order_id"])
	assignmentID := parseUUIDString(container["assignment_id"])
	surveyTypeID := parseUUIDString(container["survey_type_id"])
	err = tx.QueryRow(ctx, `
		INSERT INTO surveys (survey_no, job_order_id, job_container_id, assignment_id, surveyor_id, survey_type_id, started_at)
		VALUES ($1,$2,$3,$4,$5,$6,now()) RETURNING id
	`, surveyNo, jobID, containerID, assignmentID, surveyorID, surveyTypeID).Scan(&surveyID)
	if err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "duplicate") {
			return nil, ErrDuplicate
		}
		return nil, err
	}
	_, err = tx.Exec(ctx, `
		INSERT INTO survey_general_infos (
		  survey_id, container_no, container_type_id, iso_type_code, customer_id, location_id,
		  cargo_status, seal_no, truck_no, driver_name, csc_plate_status
		) VALUES ($1,$2,$3,NULLIF($4,''),$5,$6,$7,NULLIF($8,''),NULLIF($9,''),NULLIF($10,''),NULLIF($11,''))
	`, surveyID, container["container_no"], nullableUUID(container["container_type_id"]), container["iso_type_code"], parseUUIDString(container["customer_id"]), parseUUIDString(container["location_id"]), defaultString(container["cargo_status"], "unknown"), container["seal_no"], container["truck_no"], container["driver_name"], container["csc_plate_status"])
	if err != nil {
		return nil, err
	}
	_, _ = tx.Exec(ctx, `UPDATE job_containers SET status='in_progress', updated_at=now() WHERE id=$1 AND status IN ('assigned','not_started')`, containerID)
	_, _ = tx.Exec(ctx, `UPDATE job_orders SET status='in_progress', updated_by=$2, updated_at=now() WHERE id=$1 AND status IN ('draft','assigned')`, jobID, actor.UserID)
	_, _ = tx.Exec(ctx, `UPDATE assignments SET status='in_progress', updated_at=now() WHERE id=$1 AND status IN ('assigned','accepted')`, assignmentID)
	item := map[string]any{"id": surveyID.String(), "survey_no": surveyNo, "status": "draft", "job_order_no": container["job_order_no"], "container_no": container["container_no"]}
	_ = r.insertJobEvent(ctx, tx, jobID, "survey_started", "Survey dimulai.", fmt.Sprint(container["container_no"]), actor.UserID, item)
	_ = r.insertAudit(ctx, tx, actor, "surveys.start", "surveys", &surveyID, nil, item)
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return item, nil
}

func (r Repository) GetSurvey(ctx context.Context, surveyID uuid.UUID, actor Actor) (map[string]any, error) {
	base, err := r.surveyBase(ctx, surveyID, actor)
	if err != nil {
		return nil, err
	}
	general, _ := r.queryOne(ctx, `
		SELECT sgi.*, sgi.id AS id, sgi.survey_id AS survey_id, sgi.container_type_id AS container_type_id,
		       sgi.customer_id AS customer_id, sgi.location_id AS location_id
		FROM survey_general_infos sgi WHERE sgi.survey_id=$1
	`, surveyID)
	checklist, _ := r.Checklist(ctx, surveyID, actor)
	damages, _ := r.Damages(ctx, surveyID, actor)
	photos, _ := r.Photos(ctx, surveyID, actor)
	base["general_info"] = general
	base["checklist"] = checklist
	base["damages"] = damages
	base["photos"] = photos
	return base, nil
}

func (r Repository) UpdateGeneralInfo(ctx context.Context, surveyID uuid.UUID, input GeneralInfoInput, actor Actor) (map[string]any, error) {
	if strings.TrimSpace(input.CargoStatus) == "" || strings.TrimSpace(input.GeneralCondition) == "" {
		return nil, ErrInvalidInput
	}
	surveyDate, err := parseOptionalTime(input.SurveyDateTime)
	if err != nil {
		return nil, ErrInvalidInput
	}
	if surveyDate == nil {
		now := time.Now().UTC()
		surveyDate = &now
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	base, err := r.surveyBaseTx(ctx, tx, surveyID, actor)
	if err != nil {
		return nil, err
	}
	if !editableStatus(fmt.Sprint(base["status"])) {
		return nil, ErrInvalidStatus
	}
	if input.CargoStatus == "laden" && strings.TrimSpace(input.SealNo) == "" {
		return nil, ErrInvalidInput
	}
	item, err := scanRow(tx.QueryRow(ctx, `
		UPDATE survey_general_infos SET survey_date_time=$2, cargo_status=$3, seal_no=NULLIF($4,''), truck_no=NULLIF($5,''), driver_name=NULLIF($6,''),
		  chassis_no=NULLIF($7,''), csc_plate_status=NULLIF($8,''), door_status=NULLIF($9,''), general_condition=NULLIF($10,''), weather=NULLIF($11,''),
		  gps_latitude=$12, gps_longitude=$13, general_remark=NULLIF($14,''), updated_at=now()
		WHERE survey_id=$1
		RETURNING id, survey_id, cargo_status, seal_no, general_condition, survey_date_time
	`, surveyID, surveyDate, input.CargoStatus, input.SealNo, input.TruckNo, input.DriverName, input.ChassisNo, input.CSCPlateStatus, input.DoorStatus, input.GeneralCondition, input.Weather, input.GPSLatitude, input.GPSLongitude, input.GeneralRemark), []string{"id", "survey_id", "cargo_status", "seal_no", "general_condition", "survey_date_time"})
	if err != nil {
		return nil, err
	}
	_, _ = tx.Exec(ctx, `UPDATE surveys SET status=CASE WHEN status='need_revision' THEN 'draft' ELSE status END, updated_at=now() WHERE id=$1`, surveyID)
	_ = r.insertAudit(ctx, tx, actor, "surveys.update_general", "surveys", &surveyID, base, item)
	return item, tx.Commit(ctx)
}

func (r Repository) Checklist(ctx context.Context, surveyID uuid.UUID, actor Actor) ([]map[string]any, error) {
	if _, err := r.surveyBase(ctx, surveyID, actor); err != nil {
		return nil, err
	}
	rows, err := r.pool.Query(ctx, `SELECT id, item_code AS item_key, item_label, response_value AS value, response_text AS note, is_required, is_critical, display_order FROM survey_checklist_responses WHERE survey_id=$1 ORDER BY display_order, item_code`, surveyID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	items, err := rowsToMaps(rows)
	if err != nil {
		return nil, err
	}
	if len(items) == 0 {
		return defaultChecklist(), nil
	}
	return items, nil
}

func (r Repository) UpdateChecklist(ctx context.Context, surveyID uuid.UUID, input ChecklistInput, actor Actor) (map[string]any, error) {
	if len(input.Items) == 0 {
		return nil, ErrInvalidInput
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	base, err := r.surveyBaseTx(ctx, tx, surveyID, actor)
	if err != nil {
		return nil, err
	}
	if !editableStatus(fmt.Sprint(base["status"])) {
		return nil, ErrInvalidStatus
	}
	completed := 0
	for index, item := range input.Items {
		key := strings.TrimSpace(item.ItemKey)
		if key == "" {
			return nil, ErrInvalidInput
		}
		label := defaultChecklistLabel(key)
		if strings.TrimSpace(item.Value) != "" {
			completed++
		}
		_, err := tx.Exec(ctx, `
			INSERT INTO survey_checklist_responses (survey_id,item_code,item_label,response_value,response_text,display_order)
			VALUES ($1,$2,$3,NULLIF($4,''),NULLIF($5,''),$6)
			ON DUPLICATE KEY UPDATE response_value=VALUES(response_value), response_text=VALUES(response_text), updated_at=now()
		`, surveyID, key, label, item.Value, item.Note, index+1)
		if err != nil {
			return nil, err
		}
	}
	_, _ = tx.Exec(ctx, `UPDATE surveys SET status=CASE WHEN status='need_revision' THEN 'draft' ELSE status END, updated_at=now() WHERE id=$1`, surveyID)
	result := map[string]any{"survey_id": surveyID.String(), "total_items": len(input.Items), "completed_items": completed}
	_ = r.insertAudit(ctx, tx, actor, "surveys.update_checklist", "surveys", &surveyID, base, result)
	return result, tx.Commit(ctx)
}

func (r Repository) Sheet(ctx context.Context, surveyID uuid.UUID, actor Actor) (map[string]any, error) {
	damages, err := r.Damages(ctx, surveyID, actor)
	if err != nil {
		return nil, err
	}
	faces := []map[string]any{}
	for _, face := range []string{"left", "right", "front", "door", "roof", "floor", "understructure"} {
		locations := []map[string]any{}
		for i := 1; i <= 8; i++ {
			code := strings.ToUpper(string(face[0])) + fmt.Sprint(i)
			markers := []map[string]any{}
			for _, damage := range damages {
				if fmt.Sprint(damage["face"]) == face && strings.EqualFold(fmt.Sprint(damage["internal_location"]), code) {
					markers = append(markers, map[string]any{"damage_id": damage["id"], "damage_no": damage["damage_no"], "severity": damage["severity"]})
				}
			}
			locations = append(locations, map[string]any{"code": code, "label": code, "has_damage": len(markers) > 0, "damage_markers": markers})
		}
		faces = append(faces, map[string]any{"face": face, "label": faceLabel(face), "locations": locations})
	}
	return map[string]any{"faces": faces}, nil
}

func (r Repository) Damages(ctx context.Context, surveyID uuid.UUID, actor Actor) ([]map[string]any, error) {
	if _, err := r.surveyBase(ctx, surveyID, actor); err != nil {
		return nil, err
	}
	rows, err := r.pool.Query(ctx, `
		SELECT sd.id, sd.damage_no, sd.face, sd.internal_location,
		       cl.code AS cedex_location_code,
		       cc.id AS component_id, cc.code AS component_code, cc.name AS component_name,
		       cd.id AS damage_code_id, cd.code AS damage_code, cd.name AS damage_name,
		       cr.code AS repair_code, cr.name AS repair_name,
		       sd.severity, sd.quantity, sd.length_value AS length, sd.width_value AS width, sd.depth_value AS depth,
		       sd.unit, sd.is_repair_required, sd.is_cargo_worthy_impact, sd.remark,
		       COUNT(sp.id) AS photo_count
		FROM survey_damages sd
		LEFT JOIN cedex_locations cl ON cl.id=sd.cedex_location_id
		JOIN cedex_components cc ON cc.id=sd.component_id
		JOIN cedex_damages cd ON cd.id=sd.damage_id
		LEFT JOIN cedex_repairs cr ON cr.id=sd.repair_id
		LEFT JOIN survey_photos sp ON sp.damage_id=sd.id AND sp.deleted_at IS NULL
		WHERE sd.survey_id=$1 AND sd.deleted_at IS NULL
		GROUP BY sd.id, cl.id, cc.id, cd.id, cr.id
		ORDER BY sd.damage_no
	`, surveyID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return rowsToMaps(rows)
}

func (r Repository) CreateDamage(ctx context.Context, surveyID uuid.UUID, input DamageInput, actor Actor) (map[string]any, error) {
	return r.saveDamage(ctx, uuid.Nil, surveyID, input, actor)
}

func (r Repository) UpdateDamage(ctx context.Context, damageID uuid.UUID, input DamageInput, actor Actor) (map[string]any, error) {
	surveyID, err := r.damageSurveyID(ctx, damageID)
	if err != nil {
		return nil, err
	}
	return r.saveDamage(ctx, damageID, surveyID, input, actor)
}

func (r Repository) DeleteDamage(ctx context.Context, damageID uuid.UUID, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	item, err := scanRow(tx.QueryRow(ctx, `SELECT id, survey_id, damage_no FROM survey_damages WHERE id=$1 AND deleted_at IS NULL FOR UPDATE`, damageID), []string{"id", "survey_id", "damage_no"})
	if err != nil {
		return nil, err
	}
	surveyID := parseUUIDString(item["survey_id"])
	base, err := r.surveyBaseTx(ctx, tx, surveyID, actor)
	if err != nil {
		return nil, err
	}
	if !editableStatus(fmt.Sprint(base["status"])) {
		return nil, ErrInvalidStatus
	}
	_, err = tx.Exec(ctx, `UPDATE survey_damages SET deleted_at=now(), updated_by=$2, updated_at=now() WHERE id=$1`, damageID, actor.UserID)
	if err != nil {
		return nil, err
	}
	_ = r.insertAudit(ctx, tx, actor, "survey_damages.delete", "survey_damages", &damageID, item, nil)
	return item, tx.Commit(ctx)
}

func (r Repository) UploadPhoto(ctx context.Context, damageID uuid.UUID, input PhotoInput, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	damage, err := scanRow(tx.QueryRow(ctx, `SELECT id, survey_id, damage_no FROM survey_damages WHERE id=$1 AND deleted_at IS NULL`, damageID), []string{"id", "survey_id", "damage_no"})
	if err != nil {
		return nil, err
	}
	surveyID := parseUUIDString(damage["survey_id"])
	base, err := r.surveyBaseTx(ctx, tx, surveyID, actor)
	if err != nil {
		return nil, err
	}
	if !editableStatus(fmt.Sprint(base["status"])) {
		return nil, ErrInvalidStatus
	}
	fileID := uuid.Nil
	objectKey := fmt.Sprintf("surveys/%s/%s-%s", surveyID.String(), uuid.NewString(), sanitizeFileName(input.FileName))
	err = tx.QueryRow(ctx, `
		INSERT INTO file_objects (bucket_name, object_key, original_file_name, mime_type, file_size, visibility, uploaded_by)
		VALUES ('survey-evidence',$1,NULLIF($2,''),NULLIF($3,''),$4,'private',$5) RETURNING id
	`, objectKey, input.FileName, input.ContentType, input.Size, actor.UserID).Scan(&fileID)
	if err != nil {
		return nil, err
	}
	photoType := defaultString(input.PhotoType, "damage")
	item, err := scanRow(tx.QueryRow(ctx, `
		INSERT INTO survey_photos (survey_id, damage_id, file_id, photo_type, photo_category, caption, taken_at, uploaded_by)
		VALUES ($1,$2,$3,$4,NULLIF($5,''),NULLIF($6,''),$7,$8)
		RETURNING id, survey_id, damage_id, file_id, photo_type, caption, created_at
	`, surveyID, damageID, fileID, photoType, input.PhotoCategory, input.Caption, input.TakenAt, actor.UserID), []string{"id", "survey_id", "damage_id", "file_id", "photo_type", "caption", "created_at"})
	if err != nil {
		return nil, err
	}
	item["object_key"] = objectKey
	_ = r.insertAudit(ctx, tx, actor, "survey_photos.upload", "survey_photos", &fileID, nil, item)
	return item, tx.Commit(ctx)
}

func (r Repository) Photos(ctx context.Context, surveyID uuid.UUID, actor Actor) ([]map[string]any, error) {
	if _, err := r.surveyBase(ctx, surveyID, actor); err != nil {
		return nil, err
	}
	rows, err := r.pool.Query(ctx, `
		SELECT sp.id, sp.survey_id, sp.damage_id, sp.photo_type, sp.photo_category, sp.caption, sp.created_at,
		       fo.id AS file_id, fo.object_key, fo.original_file_name, fo.mime_type, fo.file_size
		FROM survey_photos sp
		JOIN file_objects fo ON fo.id=sp.file_id
		WHERE sp.survey_id=$1 AND sp.deleted_at IS NULL
		ORDER BY sp.created_at DESC
	`, surveyID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return rowsToMaps(rows)
}

func (r Repository) Preview(ctx context.Context, surveyID uuid.UUID, actor Actor) (map[string]any, error) {
	survey, err := r.GetSurvey(ctx, surveyID, actor)
	if err != nil {
		return nil, err
	}
	warnings := r.validateSurvey(survey)
	survey["can_submit"] = len(warnings) == 0 && editableStatus(fmt.Sprint(survey["status"]))
	survey["warnings"] = warnings
	survey["survey_result_recommendation"] = recommendedResult(survey)
	return survey, nil
}

func (r Repository) Submit(ctx context.Context, surveyID uuid.UUID, input SubmitInput, actor Actor) (map[string]any, error) {
	preview, err := r.Preview(ctx, surveyID, actor)
	if err != nil {
		return nil, err
	}
	if !editableStatus(fmt.Sprint(preview["status"])) {
		return nil, ErrInvalidStatus
	}
	if warnings, ok := preview["warnings"].([]ValidationWarning); ok && len(warnings) > 0 {
		return nil, SurveyValidationError{Warnings: warnings}
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	base, err := r.surveyBaseTx(ctx, tx, surveyID, actor)
	if err != nil {
		return nil, err
	}
	item, err := scanRow(tx.QueryRow(ctx, `
		UPDATE surveys SET status='submitted', submitted_at=now(), final_remark=NULLIF($2,''), survey_result=$3, updated_at=now()
		WHERE id=$1 AND status IN ('draft','need_revision')
		RETURNING id, survey_no, status, submitted_at
	`, surveyID, input.FinalRemark, recommendedResult(preview)), []string{"id", "survey_no", "status", "submitted_at"})
	if err != nil {
		return nil, err
	}
	jobID := parseUUIDString(base["job_order_id"])
	containerID := parseUUIDString(base["job_container_id"])
	_, _ = tx.Exec(ctx, `UPDATE job_containers SET status='submitted', updated_at=now() WHERE id=$1`, containerID)
	_, _ = tx.Exec(ctx, `
		UPDATE job_orders SET status='all_survey_submitted', updated_by=$2, updated_at=now()
		WHERE id=$1 AND NOT EXISTS (
		  SELECT 1 FROM job_containers jc
		  WHERE jc.job_order_id=$1 AND jc.deleted_at IS NULL AND jc.status NOT IN ('submitted','approved','report_generated','cancelled')
		)
	`, jobID, actor.UserID)
	_ = r.insertJobEvent(ctx, tx, jobID, "survey_submitted", "Survey disubmit.", fmt.Sprint(base["container_no"]), actor.UserID, item)
	_ = r.insertAudit(ctx, tx, actor, "surveys.submit", "surveys", &surveyID, base, item)
	return item, tx.Commit(ctx)
}

func (r Repository) saveDamage(ctx context.Context, damageID uuid.UUID, surveyID uuid.UUID, input DamageInput, actor Actor) (map[string]any, error) {
	if err := validateDamageInput(input); err != nil {
		return nil, err
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	base, err := r.surveyBaseTx(ctx, tx, surveyID, actor)
	if err != nil {
		return nil, err
	}
	if !editableStatus(fmt.Sprint(base["status"])) {
		return nil, ErrInvalidStatus
	}
	cedexLocationID, err := r.resolveCEDEXLocation(ctx, tx, input)
	if err != nil {
		return nil, err
	}
	componentID, err := uuid.Parse(input.ComponentID)
	if err != nil {
		return nil, ErrInvalidInput
	}
	damageCodeID, err := uuid.Parse(input.DamageID)
	if err != nil {
		return nil, ErrInvalidInput
	}
	if damageID == uuid.Nil {
		damageNo, err := r.nextDamageNo(ctx, tx, surveyID)
		if err != nil {
			return nil, err
		}
		item, err := scanRow(tx.QueryRow(ctx, `
			INSERT INTO survey_damages (survey_id, damage_no, face, internal_location, cedex_location_id, component_id, damage_id, repair_id, material_id, responsibility_id, severity, quantity, length_value, width_value, depth_value, unit, is_repair_required, is_cargo_worthy_impact, is_photo_only, remark, created_by, updated_by)
			VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,NULLIF($20,''),$21,$21)
			RETURNING id, damage_no, face, internal_location, severity
		`, surveyID, damageNo, input.Face, input.InternalLocation, cedexLocationID, componentID, damageCodeID, nullableUUIDString(input.RepairID), nullableUUIDString(input.MaterialID), nullableUUIDString(input.ResponsibilityID), defaultString(input.Severity, "minor"), input.Quantity, input.Length, input.Width, input.Depth, defaultString(input.Unit, "cm"), input.IsRepairRequired, input.IsCargoWorthyImpact, input.IsPhotoOnly, input.Remark, actor.UserID), []string{"id", "damage_no", "face", "internal_location", "severity"})
		if err != nil {
			return nil, err
		}
		newID := parseUUIDString(item["id"])
		_ = r.insertAudit(ctx, tx, actor, "survey_damages.create", "survey_damages", &newID, nil, item)
		return item, tx.Commit(ctx)
	}
	item, err := scanRow(tx.QueryRow(ctx, `
		UPDATE survey_damages SET face=$2, internal_location=$3, cedex_location_id=$4, component_id=$5, damage_id=$6, repair_id=$7, material_id=$8,
		  responsibility_id=$9, severity=$10, quantity=$11, length_value=$12, width_value=$13, depth_value=$14, unit=$15, is_repair_required=$16,
		  is_cargo_worthy_impact=$17, is_photo_only=$18, remark=NULLIF($19,''), updated_by=$20, updated_at=now()
		WHERE id=$1 AND deleted_at IS NULL
		RETURNING id, damage_no, face, internal_location, severity
	`, damageID, input.Face, input.InternalLocation, cedexLocationID, componentID, damageCodeID, nullableUUIDString(input.RepairID), nullableUUIDString(input.MaterialID), nullableUUIDString(input.ResponsibilityID), defaultString(input.Severity, "minor"), input.Quantity, input.Length, input.Width, input.Depth, defaultString(input.Unit, "cm"), input.IsRepairRequired, input.IsCargoWorthyImpact, input.IsPhotoOnly, input.Remark, actor.UserID), []string{"id", "damage_no", "face", "internal_location", "severity"})
	if err != nil {
		return nil, err
	}
	_ = r.insertAudit(ctx, tx, actor, "survey_damages.update", "survey_damages", &damageID, nil, item)
	return item, tx.Commit(ctx)
}
