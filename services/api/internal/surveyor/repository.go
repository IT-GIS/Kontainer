package surveyor

import (
	"container-survey/services/api/internal/database"
	"container-survey/services/api/internal/jobstatus"
	"container-survey/services/api/internal/masterdata"
	"container-survey/services/api/internal/numbering"
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
		       COUNT(DISTINCT a.id),
		       COUNT(DISTINCT CASE WHEN s.id IS NULL AND jc.status IN ('assigned','not_started') THEN jc.id END),
		       COUNT(DISTINCT CASE WHEN s.id IS NULL AND jc.status IN ('assigned','not_started') THEN jc.id END),
		       COUNT(DISTINCT CASE WHEN s.status='draft' THEN s.id END),
		       COUNT(DISTINCT CASE WHEN s.status='submitted' THEN s.id END),
		       COUNT(DISTINCT CASE WHEN s.status='under_review' THEN s.id END),
		       COUNT(DISTINCT CASE WHEN s.status='need_revision' THEN s.id END),
		       COUNT(DISTINCT CASE WHEN s.status='resubmitted' THEN s.id END),
		       COUNT(DISTINCT CASE WHEN s.status='approved' THEN s.id END),
		       COUNT(DISTINCT CASE WHEN s.status='rejected' THEN s.id END)
		FROM assignments a
		JOIN assignment_containers ac ON ac.assignment_id = a.id AND ac.unassigned_at IS NULL
		JOIN job_orders jo ON jo.id = a.job_order_id AND jo.deleted_at IS NULL
		JOIN job_containers jc ON jc.id = ac.job_container_id AND jc.deleted_at IS NULL
		LEFT JOIN surveys s ON s.job_container_id = jc.id AND s.surveyor_id = a.surveyor_id AND s.is_active=1 AND s.deleted_at IS NULL
		WHERE a.surveyor_id = $1
	`, surveyorID)
	var item Dashboard
	if err := row.Scan(&item.TotalJobs, &item.TotalAssignments, &item.AssignedNotStarted, &item.NotStarted, &item.Draft, &item.Submitted, &item.UnderReview, &item.NeedRevision, &item.Resubmitted, &item.Approved, &item.Rejected); err != nil {
		return Dashboard{}, err
	}
	return item, nil
}

func (r Repository) ListAssignedContainers(ctx context.Context, params ListParams, actor Actor) (ListResult, error) {
	surveyorID, err := r.surveyorID(ctx, actor.UserID)
	if err != nil {
		return ListResult{}, err
	}
	page, perPage := normalizePagination(params.Page, params.PerPage)
	args := []any{surveyorID}
	search := ""
	if strings.TrimSpace(params.Search) != "" {
		args = append(args, "%"+strings.TrimSpace(params.Search)+"%")
		search = fmt.Sprintf(" AND (jc.container_no LIKE $%d OR jo.job_order_no LIKE $%d OR c.customer_name LIKE $%d)", len(args), len(args), len(args))
	}
	var total int
	if err := r.pool.QueryRow(ctx, `
		SELECT COUNT(DISTINCT jc.id)
		FROM assignments a
		JOIN assignment_containers ac ON ac.assignment_id=a.id AND ac.unassigned_at IS NULL
		JOIN job_containers jc ON jc.id=ac.job_container_id AND jc.deleted_at IS NULL AND jc.status NOT IN ('cancelled','closed')
		JOIN job_orders jo ON jo.id=jc.job_order_id AND jo.deleted_at IS NULL AND jo.status<>'cancelled'
		JOIN customers c ON c.id=jo.customer_id
		WHERE a.surveyor_id=$1 AND a.status NOT IN ('cancelled','reassigned')
		  AND NOT EXISTS (SELECT 1 FROM surveys s WHERE s.job_container_id=jc.id AND s.is_active=1 AND s.deleted_at IS NULL)
		`+search, args...).Scan(&total); err != nil {
		return ListResult{}, err
	}
	args = append(args, perPage, (page-1)*perPage)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT DISTINCT jc.id AS job_container_id, jc.container_no, jc.status,
		       jo.id AS job_order_id, jo.job_order_no, jo.deadline,
		       c.customer_name, l.location_name, st.name AS survey_type_name,
		       ct.code AS container_type_code, a.assignment_no, a.due_date AS assignment_due_date,
		       COALESCE(a.due_date,jo.deadline) AS effective_due_at,
		       COALESCE(NULLIF(TRIM(a.instruction),''),jo.instruction) AS assignment_instruction
		FROM assignments a
		JOIN assignment_containers ac ON ac.assignment_id=a.id AND ac.unassigned_at IS NULL
		JOIN job_containers jc ON jc.id=ac.job_container_id AND jc.deleted_at IS NULL AND jc.status NOT IN ('cancelled','closed')
		JOIN job_orders jo ON jo.id=jc.job_order_id AND jo.deleted_at IS NULL AND jo.status<>'cancelled'
		JOIN customers c ON c.id=jo.customer_id
		JOIN locations l ON l.id=jo.location_id
		JOIN survey_types st ON st.id=jo.survey_type_id
		LEFT JOIN container_types ct ON ct.id=jc.container_type_id
		WHERE a.surveyor_id=$1 AND a.status NOT IN ('cancelled','reassigned')
		  AND NOT EXISTS (SELECT 1 FROM surveys s WHERE s.job_container_id=jc.id AND s.is_active=1 AND s.deleted_at IS NULL)
		  %s
		ORDER BY effective_due_at IS NULL, effective_due_at, jc.container_no
		LIMIT $%d OFFSET $%d
	`, search, len(args)-1, len(args)), args...)
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

func (r Repository) Profile(ctx context.Context, actor Actor) (map[string]any, error) {
	return r.queryOne(ctx, `
		SELECT sp.id, sp.surveyor_code, sp.full_name, COALESCE(sp.phone,'') AS phone,
		       COALESCE(sp.area,'') AS area, COALESCE(sp.certificate_number,'') AS certificate_number,
		       sp.certificate_valid_until, COALESCE(sp.competencies,'') AS competencies,
		       COALESCE(sp.assignment_locations,'') AS assignment_locations, sp.status
		FROM surveyor_profiles sp
		WHERE sp.user_id=$1 AND sp.deleted_at IS NULL
		LIMIT 1
	`, actor.UserID)
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
		       jo.status, jo.deadline,
		       latest_assignment.assignment_no,
		       latest_assignment.start_date AS assignment_start_date,
		       latest_assignment.due_date AS assignment_due_date,
		       COALESCE(NULLIF(TRIM(latest_assignment.instruction), ''), jo.instruction) AS assignment_instruction
		FROM job_orders jo
		JOIN customers c ON c.id = jo.customer_id
		JOIN locations l ON l.id = jo.location_id
		JOIN survey_types st ON st.id = jo.survey_type_id
		JOIN assignments a ON a.job_order_id = jo.id
		JOIN assignment_containers ac ON ac.assignment_id = a.id AND ac.unassigned_at IS NULL
		JOIN job_containers jc ON jc.id = ac.job_container_id AND jc.deleted_at IS NULL
		LEFT JOIN surveys s ON s.job_container_id = jc.id AND s.is_active=1 AND s.deleted_at IS NULL
		LEFT JOIN assignments latest_assignment ON latest_assignment.id = (
		  SELECT a2.id
		  FROM assignments a2
		  WHERE a2.job_order_id = jo.id AND a2.surveyor_id = $1
		    AND EXISTS (
		      SELECT 1 FROM assignment_containers ac2
		      WHERE ac2.assignment_id = a2.id AND ac2.unassigned_at IS NULL
		    )
		  ORDER BY a2.assigned_at DESC, a2.id DESC
		  LIMIT 1
		)
		%s
		GROUP BY jo.id, c.id, l.id, st.id, latest_assignment.id
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

func (r Repository) ListSurveys(ctx context.Context, params ListParams, actor Actor) (ListResult, error) {
	surveyorID, err := r.surveyorID(ctx, actor.UserID)
	if err != nil {
		return ListResult{}, err
	}
	page, perPage := normalizePagination(params.Page, params.PerPage)
	where, args := assignedSurveyWhere(params, surveyorID)
	var total int
	if err := r.pool.QueryRow(ctx, `
		SELECT COUNT(*) FROM surveys s
		JOIN job_orders jo ON jo.id=s.job_order_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN customers c ON c.id=jo.customer_id
	`+where, args...).Scan(&total); err != nil {
		return ListResult{}, err
	}
	args = append(args, perPage, (page-1)*perPage)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT s.id AS survey_id, s.survey_no, jo.id AS job_order_id, jo.job_order_no,
		       jc.id AS job_container_id, jc.container_no, c.customer_name, l.location_name,
		       st.name AS survey_type_name, s.status, s.phase, s.survey_round, s.current_revision_no,
		       s.current_reviewer_id, reviewer.name AS current_reviewer_name, s.review_started_at,
		       s.started_at, s.submitted_at, s.resubmitted_at, s.approved_at, s.rejected_at, s.created_at
		FROM surveys s
		JOIN job_orders jo ON jo.id=s.job_order_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN customers c ON c.id=jo.customer_id
		JOIN locations l ON l.id=jo.location_id
		JOIN survey_types st ON st.id=s.survey_type_id
		LEFT JOIN users reviewer ON reviewer.id=s.current_reviewer_id
		%s ORDER BY COALESCE(s.approved_at,s.submitted_at,s.started_at,s.created_at) DESC
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
		       c.customer_name, l.location_name, st.name AS survey_type_name,
		       latest_assignment.assignment_no,
		       latest_assignment.start_date AS assignment_start_date,
		       latest_assignment.due_date AS assignment_due_date,
		       COALESCE(NULLIF(TRIM(latest_assignment.instruction), ''), jo.instruction) AS assignment_instruction
		FROM job_orders jo
		JOIN customers c ON c.id = jo.customer_id
		JOIN locations l ON l.id = jo.location_id
		JOIN survey_types st ON st.id = jo.survey_type_id
		LEFT JOIN assignments latest_assignment ON latest_assignment.id = (
		  SELECT a2.id
		  FROM assignments a2
		  WHERE a2.job_order_id = jo.id AND a2.surveyor_id = $2
		    AND EXISTS (
		      SELECT 1 FROM assignment_containers ac2
		      WHERE ac2.assignment_id = a2.id AND ac2.unassigned_at IS NULL
		    )
		  ORDER BY a2.assigned_at DESC, a2.id DESC
		  LIMIT 1
		)
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
	if err := r.recordAudit(ctx, actor, "surveyor_jobs.open", "job_orders", jobID, map[string]any{"job_order_no": item["job_order_no"]}); err != nil {
		return nil, err
	}
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
		LEFT JOIN surveys s ON s.job_container_id = jc.id AND s.surveyor_id = a.surveyor_id AND s.is_active=1 AND s.deleted_at IS NULL
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
	readiness, err := masterdata.EvaluateReadinessTx(ctx, tx, parseUUIDString(container["customer_id"]), parseUUIDString(container["survey_type_id"]))
	if err != nil {
		return nil, err
	}
	if !readiness.Ready() {
		warnings := make([]ValidationWarning, 0, len(readiness.Missing))
		for _, missing := range readiness.Missing {
			warnings = append(warnings, ValidationWarning{Code: missing.Code, Message: missing.Label})
		}
		return nil, SurveyValidationError{Warnings: warnings}
	}
	existing, err := r.existingSurveyTx(ctx, tx, containerID, parseUUIDString(container["survey_type_id"]))
	if err == nil {
		return existing, tx.Commit(ctx)
	}
	if !errors.Is(err, ErrNotFound) {
		return nil, err
	}
	surveyNo, err := numbering.Next(ctx, tx, "survey")
	if err != nil {
		return nil, err
	}
	surveyID := uuid.Nil
	jobID := parseUUIDString(container["job_order_id"])
	assignmentID := parseUUIDString(container["assignment_id"])
	surveyTypeID := parseUUIDString(container["survey_type_id"])
	containerTypeID := parseUUIDString(container["container_type_id"])
	if containerTypeID == uuid.Nil {
		return nil, validationError("CONTAINER_TYPE_REQUIRED", "Container Type pada Job Container belum dikonfigurasi.")
	}
	if strings.TrimSpace(fmt.Sprint(container["container_size"])) == "" {
		return nil, validationError("CONTAINER_SIZE_REQUIRED", "Ukuran peti kemas belum dikonfigurasi.")
	}
	checkDigitStatus := strings.TrimSpace(fmt.Sprint(container["check_digit_status"]))
	if checkDigitStatus != "valid" && !(checkDigitStatus == "override" && strings.TrimSpace(fmt.Sprint(container["check_digit_override_reason"])) != "") {
		return nil, validationError("CONTAINER_CHECK_DIGIT_REQUIRED", "Check digit harus valid atau memiliki alasan override yang diaudit.")
	}
	checklistTemplateID, err := r.checklistTemplateTx(
		ctx,
		tx,
		parseUUIDString(container["customer_id"]),
		surveyTypeID,
		containerTypeID,
	)
	if err != nil {
		return nil, err
	}
	err = tx.QueryRow(ctx, `
		INSERT INTO surveys (
		  survey_no, job_order_id, job_container_id, assignment_id, surveyor_id,
		  survey_type_id, phase, survey_round, is_active, checklist_template_id, started_at
		)
		VALUES ($1,$2,$3,$4,$5,$6,'initial',1,1,$7,now()) RETURNING id
	`, surveyNo, jobID, containerID, assignmentID, surveyorID, surveyTypeID, checklistTemplateID).Scan(&surveyID)
	if err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "duplicate") {
			existing, existingErr := r.existingSurveyTx(ctx, tx, containerID, surveyTypeID)
			if existingErr == nil {
				return existing, tx.Commit(ctx)
			}
			return nil, ErrDuplicate
		}
		return nil, err
	}
	_, err = tx.Exec(ctx, `
		INSERT INTO survey_general_infos (
		  survey_id, container_no, container_type_id, iso_type_code, customer_id, location_id,
		  customer_name_snapshot, owner_name_snapshot, approval_category_name_snapshot,
		  manufacturer_name_snapshot, manufacturer_serial_no_snapshot, type_model_snapshot,
		  location_name_snapshot, survey_type_name_snapshot,
		  job_order_no_snapshot, spk_no_snapshot, container_type_code_snapshot,
		  container_type_name_snapshot, container_size_snapshot, manufacture_date,
		  gross_weight, tare_weight, payload, cube_capacity_m3_snapshot,
		  allowable_stacking_weight_kg_snapshot, racking_test_load_kg_snapshot,
		  cargo_status, cargo_status_initial,
		  seal_no, truck_no, driver_name, csc_plate_status, csc_plate_status_initial,
		  csc_plate_number, csc_approval_reference, csc_manufacture_date,
		  csc_next_examination_date, csc_program_type, maintenance_scheme_snapshot
		) VALUES (
		  $1,$2,$3,NULLIF($4,''),$5,$6,NULLIF($7,''),NULLIF($8,''),NULLIF($9,''),
		  NULLIF($10,''),NULLIF($11,''),NULLIF($12,''),NULLIF($13,''),NULLIF($14,''),
		  NULLIF($15,''),NULLIF($16,''),NULLIF($17,''),NULLIF($18,''),NULLIF($19,''),$20,
		  $21,$22,$23,$24,$25,$26,$27,$27,NULLIF($28,''),NULLIF($29,''),NULLIF($30,''),
		  NULLIF($31,''),NULLIF($31,''),NULLIF($32,''),NULLIF($33,''),$34,$35,NULLIF($36,''),NULLIF($37,'')
		)
	`, surveyID, container["container_no"], nullableUUID(container["container_type_id"]), container["iso_type_code"],
		parseUUIDString(container["customer_id"]), parseUUIDString(container["location_id"]),
		container["customer_name"], container["owner_name"], container["approval_category_name"],
		container["manufacturer_name"], container["manufacturer_serial_no"], container["type_model"],
		container["location_name"], container["survey_type_name"], container["job_order_no"], container["spk_no"],
		container["container_type_code"], container["container_type_name"], container["container_size"], container["manufacture_date"],
		container["gross_weight"], container["tare_weight"], container["payload"], container["cube_capacity_m3"],
		container["allowable_stacking_weight_kg"], container["racking_test_load_kg"],
		defaultString(container["cargo_status"], "unknown"), container["seal_no"], container["truck_no"],
		container["driver_name"], container["csc_plate_status"], container["csc_plate_number"],
		container["csc_approval_reference"], container["csc_manufacture_date"], container["csc_next_examination_date"],
		container["csc_program_type"], container["maintenance_scheme_name"])
	if err != nil {
		return nil, err
	}
	if err := r.instantiateChecklistTx(ctx, tx, surveyID, checklistTemplateID); err != nil {
		return nil, err
	}
	_, _ = tx.Exec(ctx, `UPDATE assignments SET status='in_progress', updated_at=now() WHERE id=$1 AND status IN ('assigned','accepted')`, assignmentID)
	if _, err := jobstatus.RecalculateJobStatusTx(ctx, tx, jobID, &actor.UserID); err != nil {
		return nil, err
	}
	item := map[string]any{
		"id": surveyID.String(), "survey_no": surveyNo, "status": "draft",
		"job_order_no": container["job_order_no"], "container_no": container["container_no"],
		"checklist_template_id": checklistTemplateID.String(),
	}
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
	revisionItems, err := r.optionRows(ctx, `
		SELECT item.id, item.target_type, item.target_id, item.category, item.target_snapshot,
		       item.note, item.due_at, item.is_resolved, item.resolved_at, item.created_at,
		       requester.name AS requested_by_name, resolver.name AS resolved_by_name
		FROM survey_revision_items item
		JOIN survey_approvals approval ON approval.id=item.approval_id
		LEFT JOIN users requester ON requester.id=approval.reviewer_id
		LEFT JOIN users resolver ON resolver.id=item.resolved_by
		WHERE item.survey_id=$1
		ORDER BY item.is_resolved, item.created_at DESC
	`, surveyID)
	if err != nil {
		return nil, err
	}
	requiredPhotoCategories, err := r.optionRows(ctx, `
		SELECT category.code, category.name, category.applies_to
		FROM customer_survey_type_photo_categories mapping
		JOIN evidence_photo_categories category
		  ON category.id=mapping.photo_category_id AND category.status='active'
		WHERE mapping.customer_id=$1 AND mapping.survey_type_id=$2
		  AND mapping.is_active=1 AND category.is_required_default=1
		ORDER BY category.display_order, category.code
	`, parseUUIDString(base["customer_id"]), parseUUIDString(base["survey_type_id"]))
	if err != nil {
		return nil, err
	}
	base["general_info"] = general
	base["checklist"] = checklist
	base["damages"] = damages
	base["photos"] = photos
	base["revision_items"] = revisionItems
	base["required_photo_categories"] = requiredPhotoCategories
	if err := r.recordAudit(ctx, actor, "surveys.open", "surveys", surveyID, map[string]any{"survey_no": base["survey_no"]}); err != nil {
		return nil, err
	}
	return base, nil
}

func (r Repository) UpdateGeneralInfo(ctx context.Context, surveyID uuid.UUID, input GeneralInfoInput, actor Actor) (map[string]any, error) {
	cargoStatus := strings.ToLower(strings.TrimSpace(input.CargoStatus))
	if cargoStatus == "" || strings.TrimSpace(input.GeneralCondition) == "" {
		return nil, ErrInvalidInput
	}
	if !oneOfString(cargoStatus, "empty", "laden", "unknown") {
		return nil, validationError("CARGO_STATUS_INVALID", "Cargo Status harus MTY, FULL, atau belum diverifikasi.")
	}
	condition := strings.ToUpper(strings.TrimSpace(input.GeneralCondition))
	if !oneOfString(condition, "DMG", "AVL", "AR") {
		return nil, validationError("SURVEY_CONDITION_INVALID", "Condition harus DMG, AVL, atau AR.")
	}
	cleanliness := strings.ToUpper(strings.TrimSpace(input.Cleanliness))
	if cleanliness != "" && !oneOfString(cleanliness, "DTY", "CTM") {
		return nil, validationError("CLEANLINESS_INVALID", "Cleanliness harus DTY atau CTM.")
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
	cscPlateStatus := strings.ToLower(strings.TrimSpace(input.CSCPlateStatus))
	if cscPlateStatus != "" && !oneOfString(cscPlateStatus, "available", "missing", "damaged", "not_checked") {
		return nil, validationError("CSC_PLATE_STATUS_INVALID", "CSC Plate Status verifikasi tidak valid.")
	}
	cscManufactureDate, err := parseOptionalSurveyDate(input.CSCManufactureDate)
	if err != nil {
		return nil, validationError("CSC_MANUFACTURE_DATE_INVALID", "Tanggal produksi CSC tidak valid.")
	}
	cscNextExaminationDate, err := parseOptionalSurveyDate(input.CSCNextExaminationDate)
	if err != nil {
		return nil, validationError("CSC_NEXT_EXAMINATION_DATE_INVALID", "Tanggal pemeriksaan CSC berikutnya tidak valid.")
	}
	if cscManufactureDate != nil && cscNextExaminationDate != nil && cscNextExaminationDate.Before(*cscManufactureDate) {
		return nil, validationError("CSC_DATE_ORDER_INVALID", "Tanggal pemeriksaan CSC berikutnya tidak boleh sebelum tanggal produksi CSC.")
	}
	verificationDiffers := verificationMismatch(base["cargo_status_initial"], cargoStatus) ||
		verificationMismatch(base["csc_plate_status_initial"], cscPlateStatus) ||
		verificationMismatch(base["csc_plate_number_initial"], input.CSCPlateNumber) ||
		verificationMismatch(base["csc_approval_reference_initial"], input.CSCApprovalReference) ||
		verificationDateMismatch(base["csc_manufacture_date_initial"], input.CSCManufactureDate) ||
		verificationDateMismatch(base["csc_next_examination_date_initial"], input.CSCNextExaminationDate) ||
		verificationMismatch(base["csc_program_type_initial"], input.CSCProgramType)
	if verificationDiffers && strings.TrimSpace(input.GeneralRemark) == "" {
		return nil, validationError("VERIFICATION_MISMATCH_NOTE_REQUIRED", "Catatan verifikasi wajib diisi ketika hasil Surveyor berbeda dari data awal Admin.")
	}
	lifecycle := strings.ToLower(strings.TrimSpace(input.ContainerLifecycle))
	if lifecycle != "" && lifecycle != "new" && lifecycle != "existing" {
		return nil, validationError("CONTAINER_LIFECYCLE_INVALID", "Kategori peti kemas harus New atau Existing.")
	}
	if cargoStatus == "laden" && strings.TrimSpace(input.SealNo) == "" {
		return nil, ErrInvalidInput
	}
	item, err := scanRow(tx.QueryRow(ctx, `
		UPDATE survey_general_infos SET survey_date_time=$2, cargo_status=$3, seal_no=NULLIF($4,''), truck_no=NULLIF($5,''), driver_name=NULLIF($6,''),
		  chassis_no=NULLIF($7,''), csc_plate_status=NULLIF($8,''), door_status=NULLIF($9,''), general_condition=NULLIF($10,''),
		  cleanliness=NULLIF($11,''), container_lifecycle=NULLIF($12,''), weather=NULLIF($13,''),
		  gps_latitude=$14, gps_longitude=$15, general_remark=NULLIF($16,''),
		  csc_plate_number_verified=NULLIF($17,''), csc_approval_reference_verified=NULLIF($18,''),
		  csc_manufacture_date_verified=$19, csc_next_examination_date_verified=$20,
		  csc_program_type_verified=NULLIF($21,''), updated_at=now()
		WHERE survey_id=$1
		RETURNING id, survey_id, cargo_status, cargo_status_initial, csc_plate_status, csc_plate_status_initial,
		          csc_plate_number_verified, csc_approval_reference_verified, csc_manufacture_date_verified,
		          csc_next_examination_date_verified, csc_program_type_verified,
		          general_condition, cleanliness, general_remark, survey_date_time
	`, surveyID, surveyDate, cargoStatus, input.SealNo, input.TruckNo, input.DriverName, input.ChassisNo, cscPlateStatus, input.DoorStatus, condition, cleanliness, lifecycle, input.Weather, input.GPSLatitude, input.GPSLongitude, input.GeneralRemark,
		input.CSCPlateNumber, input.CSCApprovalReference, cscManufactureDate, cscNextExaminationDate, input.CSCProgramType), []string{"id", "survey_id", "cargo_status", "cargo_status_initial", "csc_plate_status", "csc_plate_status_initial", "csc_plate_number_verified", "csc_approval_reference_verified", "csc_manufacture_date_verified", "csc_next_examination_date_verified", "csc_program_type_verified", "general_condition", "cleanliness", "general_remark", "survey_date_time"})
	if err != nil {
		return nil, err
	}
	_ = r.insertAudit(ctx, tx, actor, "surveys.update_general", "surveys", &surveyID, base, item)
	return item, tx.Commit(ctx)
}

func (r Repository) Checklist(ctx context.Context, surveyID uuid.UUID, actor Actor) ([]map[string]any, error) {
	if _, err := r.surveyBase(ctx, surveyID, actor); err != nil {
		return nil, err
	}
	rows, err := r.pool.Query(ctx, `
		SELECT id, template_item_id, item_code AS item_key, item_label,
		       response_value AS value, response_numeric AS numeric_value, response_text AS note,
		       response_type, unit, standard_reference, is_required, is_critical,
		       requires_attachment, attachment_file_id, display_order
		FROM survey_checklist_responses
		WHERE survey_id=$1
		ORDER BY display_order, item_code
	`, surveyID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	items, err := rowsToMaps(rows)
	if err != nil {
		return nil, err
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
	for _, item := range input.Items {
		key := strings.TrimSpace(item.ItemKey)
		if key == "" {
			return nil, ErrInvalidInput
		}
		var existingID uuid.UUID
		if err := tx.QueryRow(ctx, `
			SELECT id FROM survey_checklist_responses
			WHERE survey_id=$1 AND item_code=$2
			LIMIT 1
		`, surveyID, key).Scan(&existingID); errors.Is(err, database.ErrNoRows) {
			return nil, validationError("CHECKLIST_ITEM_SCOPE", "Item checklist tidak berasal dari snapshot template survei.")
		} else if err != nil {
			return nil, err
		}
		var attachmentID *uuid.UUID
		if strings.TrimSpace(item.AttachmentFileID) != "" {
			parsed, err := uuid.Parse(item.AttachmentFileID)
			if err != nil {
				return nil, validationError("CHECKLIST_ATTACHMENT_INVALID", "Attachment checklist tidak valid.")
			}
			attachmentID = &parsed
			var count int
			if err := tx.QueryRow(ctx, `SELECT COUNT(*) FROM file_objects WHERE id=$1 AND deleted_at IS NULL`, parsed).Scan(&count); err != nil {
				return nil, err
			}
			if count != 1 {
				return nil, validationError("CHECKLIST_ATTACHMENT_NOT_FOUND", "Attachment checklist tidak ditemukan.")
			}
		}
		if strings.TrimSpace(item.Value) != "" || item.NumericValue != nil {
			completed++
		}
		_, err := tx.Exec(ctx, `
			UPDATE survey_checklist_responses
			SET response_value=NULLIF($3,''), response_numeric=$4, response_text=NULLIF($5,''),
			    attachment_file_id=$6, updated_at=now()
			WHERE survey_id=$1 AND item_code=$2
		`, surveyID, key, item.Value, item.NumericValue, item.Note, attachmentID)
		if err != nil {
			return nil, err
		}
	}
	result := map[string]any{"survey_id": surveyID.String(), "total_items": len(input.Items), "completed_items": completed}
	_ = r.insertAudit(ctx, tx, actor, "surveys.update_checklist", "surveys", &surveyID, base, result)
	return result, tx.Commit(ctx)
}

func (r Repository) Sheet(ctx context.Context, surveyID uuid.UUID, actor Actor) (map[string]any, error) {
	if _, err := r.surveyBase(ctx, surveyID, actor); err != nil {
		return nil, err
	}
	damages, err := r.Damages(ctx, surveyID, actor)
	if err != nil {
		return nil, err
	}
	rows, err := r.pool.Query(ctx, `
		SELECT cl.id, cl.code, cl.face, cl.grid_code, cl.description, cl.display_order
		FROM surveys s
		JOIN job_orders jo ON jo.id=s.job_order_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		LEFT JOIN container_types ct ON ct.id=jc.container_type_id
		JOIN cedex_locations cl ON cl.status='active'
		  AND (cl.customer_id=jo.customer_id OR (
		    cl.customer_id IS NULL AND NOT EXISTS (
		      SELECT 1 FROM cedex_locations override
		      WHERE override.customer_id=jo.customer_id AND override.status='active'
		        AND LOWER(override.code)=LOWER(cl.code)
		    )
		  ))
		  AND (
		    cl.container_size IS NULL OR cl.container_size='all'
		    OR cl.container_size=CASE
		      WHEN ct.size LIKE '20%' THEN '20'
		      WHEN ct.size LIKE '40%' THEN '40'
		      WHEN ct.size LIKE '45%' THEN '45'
		      ELSE ct.size
		    END
		  )
		WHERE s.id=$1 AND s.deleted_at IS NULL
		ORDER BY FIELD(cl.face,'left','right','front','door','roof','floor','understructure'), cl.display_order, cl.code
	`, surveyID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	locations, err := rowsToMaps(rows)
	if err != nil {
		return nil, err
	}
	faceRows := map[string][]map[string]any{}
	faceOrder := []string{}
	for _, location := range locations {
		face := fmt.Sprint(location["face"])
		if _, exists := faceRows[face]; !exists {
			faceOrder = append(faceOrder, face)
		}
		markers := []map[string]any{}
		for _, damage := range damages {
			internalLocation := fmt.Sprint(damage["internal_location"])
			if fmt.Sprint(damage["face"]) == face && (strings.EqualFold(internalLocation, fmt.Sprint(location["code"])) || strings.EqualFold(internalLocation, fmt.Sprint(location["grid_code"]))) {
				markers = append(markers, map[string]any{"damage_id": damage["id"], "damage_no": damage["damage_no"], "severity": damage["severity"]})
			}
		}
		faceRows[face] = append(faceRows[face], map[string]any{
			"id": location["id"], "code": location["code"], "grid_code": location["grid_code"],
			"label": location["grid_code"], "description": location["description"],
			"has_damage": len(markers) > 0, "damage_markers": markers,
		})
	}
	faces := []map[string]any{}
	for _, face := range faceOrder {
		faces = append(faces, map[string]any{"face": face, "label": faceLabel(face), "locations": faceRows[face]})
	}
	return map[string]any{"faces": faces}, nil
}

func (r Repository) Damages(ctx context.Context, surveyID uuid.UUID, actor Actor) ([]map[string]any, error) {
	if _, err := r.surveyBase(ctx, surveyID, actor); err != nil {
		return nil, err
	}
	rows, err := r.pool.Query(ctx, `
		SELECT sd.id, sd.damage_no, sd.face, sd.internal_location, sd.manual_location_reason,
		       sd.checklist_response_id, checklist.item_code AS checklist_item_code,
		       checklist.item_label AS checklist_item_label,
		       cl.id AS cedex_location_id, cl.code AS cedex_location_code,
		       cc.id AS component_id, cc.code AS component_code, cc.component_name AS component_name,
		       cd.id AS damage_code_id, cd.code AS damage_code, cd.damage_name AS damage_name,
		       cr.id AS repair_code_id, cr.code AS repair_code, cr.repair_name AS repair_name,
		       cm.id AS material_code_id, cm.code AS material_code, cm.material_name,
		       rc.id AS responsibility_code_id, rc.code AS responsibility_code, rc.name AS responsibility_name,
		       sd.decision_rule_id, sd.decision_result, sd.decision_reason, sd.tolerance_snapshot,
		       sd.finding_description, sd.dimension_profile, sd.location_selection_snapshot,
		       ir.id AS inspection_reference_id,
		       ir.code AS inspection_reference_code, ir.parameter_name AS inspection_reference_name,
		       ir.standard_reference AS inspection_standard_reference, ir.clause_section AS inspection_reference_clause,
		       sd.severity, sd.quantity, sd.quantity_unit, sd.length_value AS length, sd.width_value AS width, sd.depth_value AS depth,
		       sd.unit, sd.is_repair_required, sd.is_cargo_worthy_impact, sd.remark,
		       COUNT(sp.id) AS photo_count
		FROM survey_damages sd
		LEFT JOIN survey_checklist_responses checklist ON checklist.id=sd.checklist_response_id
		LEFT JOIN cedex_locations cl ON cl.id=sd.cedex_location_id
		JOIN cedex_components cc ON cc.id=sd.component_id
		JOIN cedex_damages cd ON cd.id=sd.damage_id
		LEFT JOIN cedex_repairs cr ON cr.id=sd.repair_id
		LEFT JOIN cedex_materials cm ON cm.id=sd.material_id
		LEFT JOIN responsibility_codes rc ON rc.id=sd.responsibility_id
		LEFT JOIN survey_photos sp ON sp.damage_id=sd.id AND sp.deleted_at IS NULL
		LEFT JOIN inspection_test_parameters ir ON ir.id=sd.inspection_reference_id
		WHERE sd.survey_id=$1 AND sd.deleted_at IS NULL
		GROUP BY sd.id, checklist.id, cl.id, cc.id, cd.id, cr.id, cm.id, rc.id, ir.id
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

func (r Repository) PhotoContext(ctx context.Context, damageID uuid.UUID, actor Actor) (PhotoContext, error) {
	var info PhotoContext
	err := r.pool.QueryRow(ctx, `
		SELECT s.id, jo.customer_id, s.survey_type_id, s.survey_no, jc.container_no, sd.damage_no,
		       l.location_name, sp.full_name,
		       sgi.gps_latitude, sgi.gps_longitude
		FROM survey_damages sd
		JOIN surveys s ON s.id=sd.survey_id AND s.deleted_at IS NULL
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN job_orders jo ON jo.id=s.job_order_id
		JOIN locations l ON l.id=jo.location_id
		JOIN surveyor_profiles sp ON sp.id=s.surveyor_id
		LEFT JOIN survey_general_infos sgi ON sgi.survey_id=s.id
		WHERE sd.id=$1 AND sd.deleted_at IS NULL
	`, damageID).Scan(&info.SurveyID, &info.CustomerID, &info.SurveyTypeID, &info.SurveyNo, &info.ContainerNo, &info.DamageNo, &info.LocationName, &info.SurveyorName, &info.GPSLatitude, &info.GPSLongitude)
	if err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return PhotoContext{}, ErrNotFound
		}
		return PhotoContext{}, err
	}
	base, err := r.surveyBase(ctx, info.SurveyID, actor)
	if err != nil {
		return PhotoContext{}, err
	}
	if !editableStatus(fmt.Sprint(base["status"])) {
		return PhotoContext{}, ErrInvalidStatus
	}
	return info, nil
}

func (r Repository) SurveyPhotoContext(ctx context.Context, surveyID uuid.UUID, actor Actor) (PhotoContext, error) {
	var info PhotoContext
	err := r.pool.QueryRow(ctx, `
		SELECT s.id, jo.customer_id, s.survey_type_id, s.survey_no, jc.container_no,
		       l.location_name, sp.full_name,
		       sgi.gps_latitude, sgi.gps_longitude
		FROM surveys s
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN job_orders jo ON jo.id=s.job_order_id
		JOIN locations l ON l.id=jo.location_id
		JOIN surveyor_profiles sp ON sp.id=s.surveyor_id
		LEFT JOIN survey_general_infos sgi ON sgi.survey_id=s.id
		WHERE s.id=$1 AND s.deleted_at IS NULL
	`, surveyID).Scan(&info.SurveyID, &info.CustomerID, &info.SurveyTypeID, &info.SurveyNo, &info.ContainerNo, &info.LocationName, &info.SurveyorName, &info.GPSLatitude, &info.GPSLongitude)
	if err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return PhotoContext{}, ErrNotFound
		}
		return PhotoContext{}, err
	}
	base, err := r.surveyBase(ctx, surveyID, actor)
	if err != nil {
		return PhotoContext{}, err
	}
	if !editableStatus(fmt.Sprint(base["status"])) {
		return PhotoContext{}, ErrInvalidStatus
	}
	info.DamageNo = "General Evidence"
	return info, nil
}

func (r Repository) CreatePhotoMetadata(ctx context.Context, damageID uuid.UUID, input PhotoRecordInput, actor Actor) (map[string]any, error) {
	var surveyID uuid.UUID
	if err := r.pool.QueryRow(ctx, `SELECT survey_id FROM survey_damages WHERE id=$1 AND deleted_at IS NULL`, damageID).Scan(&surveyID); err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return r.createPhotoMetadata(ctx, surveyID, &damageID, input, actor)
}

func (r Repository) CreateSurveyPhotoMetadata(ctx context.Context, surveyID uuid.UUID, input PhotoRecordInput, actor Actor) (map[string]any, error) {
	return r.createPhotoMetadata(ctx, surveyID, nil, input, actor)
}

func (r Repository) createPhotoMetadata(ctx context.Context, surveyID uuid.UUID, damageID *uuid.UUID, input PhotoRecordInput, actor Actor) (map[string]any, error) {
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
	var damageValue any
	if damageID != nil {
		var found uuid.UUID
		if err := tx.QueryRow(ctx, `SELECT id FROM survey_damages WHERE id=$1 AND survey_id=$2 AND deleted_at IS NULL`, *damageID, surveyID).Scan(&found); err != nil {
			if errors.Is(err, database.ErrNoRows) {
				return nil, ErrNotFound
			}
			return nil, err
		}
		damageValue = found
	}
	expectedScope := "inspection"
	photoType := "general"
	if damageID != nil {
		expectedScope = "finding"
		photoType = "damage"
	}
	if err := r.validatePhotoCategoryTx(
		ctx,
		tx,
		parseUUIDString(base["customer_id"]),
		parseUUIDString(base["survey_type_id"]),
		input.PhotoCategory,
		expectedScope,
	); err != nil {
		return nil, err
	}
	fileID := uuid.Nil
	err = tx.QueryRow(ctx, `
		INSERT INTO file_objects (bucket_name, object_key, original_file_name, mime_type, file_size, checksum_sha256, visibility, uploaded_by)
		VALUES ($1,$2,NULLIF($3,''),$4,$5,$6,'private',$7) RETURNING id
	`, input.Original.Bucket, input.Original.ObjectKey, input.Original.FileName, input.Original.ContentType, input.Original.Size, input.Original.Checksum, actor.UserID).Scan(&fileID)
	if err != nil {
		return nil, err
	}
	watermarkedFileID := uuid.Nil
	err = tx.QueryRow(ctx, `
		INSERT INTO file_objects (bucket_name, object_key, original_file_name, mime_type, file_size, checksum_sha256, visibility, uploaded_by)
		VALUES ($1,$2,NULLIF($3,''),$4,$5,$6,'private',$7) RETURNING id
	`, input.Watermarked.Bucket, input.Watermarked.ObjectKey, input.Watermarked.FileName, input.Watermarked.ContentType, input.Watermarked.Size, input.Watermarked.Checksum, actor.UserID).Scan(&watermarkedFileID)
	if err != nil {
		return nil, err
	}
	item, err := scanRow(tx.QueryRow(ctx, `
		INSERT INTO survey_photos (
			survey_id, damage_id, file_id, watermarked_file_id, photo_type, photo_category,
			caption, taken_at, gps_latitude, gps_longitude, watermark_text, uploaded_by
		) VALUES ($1,$2,$3,$4,$5,NULLIF($6,''),NULLIF($7,''),$8,$9,$10,$11,$12)
		RETURNING id, survey_id, damage_id, file_id, watermarked_file_id, photo_type, photo_category, caption, created_at
	`, surveyID, damageValue, fileID, watermarkedFileID, photoType, input.PhotoCategory, input.Caption, input.TakenAt, input.GPSLatitude, input.GPSLongitude, input.WatermarkText, actor.UserID), []string{"id", "survey_id", "damage_id", "file_id", "watermarked_file_id", "photo_type", "photo_category", "caption", "created_at"})
	if err != nil {
		return nil, err
	}
	photoID := parseUUIDString(item["id"])
	item["object_key"] = input.Original.ObjectKey
	item["watermarked_object_key"] = input.Watermarked.ObjectKey
	item["original_file_name"] = input.Original.FileName
	item["content_url"] = fmt.Sprintf("/survey-photos/%s/content", photoID)
	item["original_url"] = fmt.Sprintf("/survey-photos/%s/content?variant=original", photoID)
	auditAction := "survey_photos.upload"
	if damageID == nil {
		auditAction = "survey_photos.upload_general"
	}
	_ = r.insertAudit(ctx, tx, actor, auditAction, "survey_photos", &photoID, nil, item)
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return item, nil
}

func (r Repository) Photos(ctx context.Context, surveyID uuid.UUID, actor Actor) ([]map[string]any, error) {
	if _, err := r.surveyBase(ctx, surveyID, actor); err != nil {
		return nil, err
	}
	rows, err := r.pool.Query(ctx, `
		SELECT sp.id, sp.survey_id, sp.damage_id, sp.photo_type, sp.photo_category, sp.caption, sp.created_at,
		       fo.id AS file_id, fo.object_key, fo.original_file_name, fo.mime_type, fo.file_size,
		       wf.id AS watermarked_file_id, wf.object_key AS watermarked_object_key
		FROM survey_photos sp
		JOIN file_objects fo ON fo.id=sp.file_id
		LEFT JOIN file_objects wf ON wf.id=sp.watermarked_file_id
		WHERE sp.survey_id=$1 AND sp.deleted_at IS NULL
		ORDER BY sp.created_at DESC
	`, surveyID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	items, err := rowsToMaps(rows)
	if err != nil {
		return nil, err
	}
	for _, item := range items {
		photoID := fmt.Sprint(item["id"])
		item["content_url"] = "/survey-photos/" + photoID + "/content"
		item["original_url"] = "/survey-photos/" + photoID + "/content?variant=original"
	}
	return items, nil
}

func (r Repository) DeletePhoto(ctx context.Context, photoID uuid.UUID, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	item, err := scanRow(tx.QueryRow(ctx, `
		SELECT photo.id, photo.survey_id, photo.damage_id, photo.photo_category, photo.caption,
		       photo.file_id, original.bucket_name, original.object_key AS original_object_key,
		       photo.watermarked_file_id, watermarked.object_key AS watermarked_object_key
		FROM survey_photos photo
		JOIN file_objects original ON original.id=photo.file_id
		LEFT JOIN file_objects watermarked ON watermarked.id=photo.watermarked_file_id
		WHERE photo.id=$1 AND photo.deleted_at IS NULL FOR UPDATE
	`, photoID), []string{"id", "survey_id", "damage_id", "photo_category", "caption", "file_id", "bucket_name", "original_object_key", "watermarked_file_id", "watermarked_object_key"})
	if err != nil {
		return nil, err
	}
	base, err := r.surveyBaseTx(ctx, tx, parseUUIDString(item["survey_id"]), actor)
	if err != nil {
		return nil, err
	}
	if !editableStatus(fmt.Sprint(base["status"])) {
		return nil, ErrInvalidStatus
	}
	if _, err := tx.Exec(ctx, `UPDATE survey_photos SET deleted_at=now() WHERE id=$1`, photoID); err != nil {
		return nil, err
	}
	if _, err := tx.Exec(ctx, `UPDATE file_objects SET deleted_at=now() WHERE id=$1 OR id=$2`, item["file_id"], item["watermarked_file_id"]); err != nil {
		return nil, err
	}
	for _, field := range []string{"original_object_key", "watermarked_object_key"} {
		objectKey := strings.TrimSpace(fmt.Sprint(item[field]))
		if objectKey == "" || objectKey == "<nil>" {
			continue
		}
		if _, err := tx.Exec(ctx, `
			INSERT IGNORE INTO object_deletion_queue (
			  bucket_name,object_key,reason,requested_by,eligible_after,status
			) VALUES ($1,$2,'survey_photo_soft_deleted',$3,DATE_ADD(now(), INTERVAL 7 DAY),'pending')
		`, item["bucket_name"], objectKey, actor.UserID); err != nil {
			return nil, err
		}
	}
	_ = r.insertAudit(ctx, tx, actor, "survey_photos.delete", "survey_photos", &photoID, item, nil)
	return item, tx.Commit(ctx)
}

func (r Repository) RestorePhoto(ctx context.Context, photoID uuid.UUID, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	item, err := scanRow(tx.QueryRow(ctx, `
		SELECT photo.id,photo.survey_id,photo.file_id,photo.watermarked_file_id,
		       original.bucket_name,original.object_key AS original_object_key,
		       watermarked.object_key AS watermarked_object_key,photo.deleted_at
		FROM survey_photos photo
		JOIN file_objects original ON original.id=photo.file_id
		LEFT JOIN file_objects watermarked ON watermarked.id=photo.watermarked_file_id
		WHERE photo.id=$1 AND photo.deleted_at IS NOT NULL
		  AND photo.deleted_at>DATE_SUB(NOW(6), INTERVAL 7 DAY)
		FOR UPDATE
	`, photoID), []string{"id", "survey_id", "file_id", "watermarked_file_id", "bucket_name", "original_object_key", "watermarked_object_key", "deleted_at"})
	if err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	base, err := r.surveyBaseTx(ctx, tx, parseUUIDString(item["survey_id"]), actor)
	if err != nil {
		return nil, err
	}
	if !editableStatus(fmt.Sprint(base["status"])) {
		return nil, ErrInvalidStatus
	}
	keys := []string{strings.TrimSpace(fmt.Sprint(item["original_object_key"])), strings.TrimSpace(fmt.Sprint(item["watermarked_object_key"]))}
	var processed, claimed int
	if err := tx.QueryRow(ctx, `
		SELECT
		  COALESCE(SUM(status='processed'),0),
		  COALESCE(SUM(status IN ('pending','failed') AND locked_at IS NOT NULL),0)
		FROM object_deletion_queue
		WHERE bucket_name=$1 AND object_key IN ($2,$3)
		FOR UPDATE
	`, item["bucket_name"], keys[0], keys[1]).Scan(&processed, &claimed); err != nil {
		return nil, err
	}
	if processed > 0 || claimed > 0 {
		return nil, ErrInvalidStatus
	}
	if _, err := tx.Exec(ctx, `UPDATE survey_photos SET deleted_at=NULL WHERE id=$1`, photoID); err != nil {
		return nil, err
	}
	if _, err := tx.Exec(ctx, `UPDATE file_objects SET deleted_at=NULL WHERE id=$1 OR id=$2`, item["file_id"], item["watermarked_file_id"]); err != nil {
		return nil, err
	}
	if _, err := tx.Exec(ctx, `
		UPDATE object_deletion_queue
		SET status='cancelled',error_message='foto dipulihkan dalam masa retensi',next_retry_at=NULL,locked_at=NULL,locked_by=NULL
		WHERE bucket_name=$1 AND object_key IN ($2,$3) AND status IN ('pending','failed')
	`, item["bucket_name"], keys[0], keys[1]); err != nil {
		return nil, err
	}
	_ = r.insertAudit(ctx, tx, actor, "survey_photos.restore", "survey_photos", &photoID, nil, item)
	return item, tx.Commit(ctx)
}

func (r Repository) PhotoFile(ctx context.Context, photoID uuid.UUID, variant string, actor Actor) (PhotoFile, error) {
	fileReference := "COALESCE(sp.watermarked_file_id, sp.file_id)"
	if strings.EqualFold(strings.TrimSpace(variant), "original") {
		fileReference = "sp.file_id"
	}
	var surveyID uuid.UUID
	var file PhotoFile
	err := r.pool.QueryRow(ctx, fmt.Sprintf(`
		SELECT sp.survey_id, fo.bucket_name, fo.object_key, COALESCE(fo.original_file_name,'photo'),
		       COALESCE(fo.mime_type,'application/octet-stream'), COALESCE(fo.file_size,0)
		FROM survey_photos sp
		JOIN file_objects fo ON fo.id=%s
		WHERE sp.id=$1 AND sp.deleted_at IS NULL AND fo.deleted_at IS NULL
	`, fileReference), photoID).Scan(&surveyID, &file.Bucket, &file.ObjectKey, &file.FileName, &file.ContentType, &file.Size)
	if err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return PhotoFile{}, ErrNotFound
		}
		return PhotoFile{}, err
	}
	if actor.ActiveRole != "admin" && actor.ActiveRole != "supervisor" && actor.ActiveRole != "super_admin" {
		if _, err := r.surveyBase(ctx, surveyID, actor); err != nil {
			return PhotoFile{}, err
		}
	}
	return file, nil
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
	nextStatus := "submitted"
	auditAction := "surveys.submit"
	eventType := "survey_submitted"
	eventTitle := "Survey disubmit."
	if fmt.Sprint(base["status"]) == "need_revision" {
		nextStatus = "resubmitted"
		auditAction = "surveys.resubmit"
		eventType = "survey_resubmitted"
		eventTitle = "Survey disubmit ulang."
	}
	item, err := scanRow(tx.QueryRow(ctx, `
		UPDATE surveys
		SET status=$2,
		    submitted_at=CASE WHEN $2='submitted' THEN now() ELSE submitted_at END,
		    resubmitted_at=CASE WHEN $2='resubmitted' THEN now() ELSE resubmitted_at END,
		    review_started_by=NULL, current_reviewer_id=NULL, review_started_at=NULL,
		    final_remark=NULLIF($3,''), survey_result=$4, updated_at=now()
		WHERE id=$1 AND status IN ('draft','need_revision')
		RETURNING id, survey_no, status, submitted_at, resubmitted_at
	`, surveyID, nextStatus, input.FinalRemark, recommendedResult(preview)), []string{"id", "survey_no", "status", "submitted_at", "resubmitted_at"})
	if err != nil {
		return nil, err
	}
	if nextStatus == "resubmitted" {
		snapshotAfter, snapshotErr := r.revisionSnapshotTx(ctx, tx, surveyID)
		if snapshotErr != nil {
			return nil, snapshotErr
		}
		result, updateErr := tx.Exec(ctx, `
			UPDATE survey_revisions
			SET status='resubmitted', resubmitted_by=$3, resubmitted_at=now(),
			    snapshot_after=$4, updated_at=now()
			WHERE survey_id=$1 AND revision_no=$2 AND status='requested'
		`, surveyID, intFromValue(base["current_revision_no"]), actor.UserID, snapshotAfter)
		if updateErr != nil {
			return nil, updateErr
		}
		if result.RowsAffected() != 1 {
			return nil, validationError("SURVEY_REVISION_HISTORY_MISSING", "Histori revisi aktif tidak ditemukan.")
		}
		_, _ = tx.Exec(ctx, `
			UPDATE survey_revision_items
			SET is_resolved=1, resolved_by=$2, resolved_at=now()
			WHERE survey_id=$1 AND is_resolved=0
		`, surveyID, actor.UserID)
	}
	jobID := parseUUIDString(base["job_order_id"])
	if _, err := jobstatus.RecalculateJobStatusTx(ctx, tx, jobID, &actor.UserID); err != nil {
		return nil, err
	}
	_ = r.insertJobEvent(ctx, tx, jobID, eventType, eventTitle, fmt.Sprint(base["container_no"]), actor.UserID, item)
	_ = r.insertAudit(ctx, tx, actor, auditAction, "surveys", &surveyID, base, item)
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
	checklistResponseID, err := parseOptionalReferenceID(
		input.ChecklistResponseID,
		"CHECKLIST_RESPONSE_INVALID",
		"Referensi checklist tidak valid.",
	)
	if err != nil {
		return nil, err
	}
	if checklistResponseID != nil {
		var found uuid.UUID
		err := tx.QueryRow(ctx, `
			SELECT id FROM survey_checklist_responses
			WHERE id=$1 AND survey_id=$2 AND response_value='no'
			LIMIT 1
		`, *checklistResponseID, surveyID).Scan(&found)
		if errors.Is(err, database.ErrNoRows) {
			return nil, validationError("CHECKLIST_RESPONSE_SCOPE", "Temuan hanya dapat ditautkan ke checklist Tidak Baik pada survey yang sama.")
		}
		if err != nil {
			return nil, err
		}
	}
	customerID := parseUUIDString(base["customer_id"])
	surveyTypeID := parseUUIDString(base["survey_type_id"])
	if input.LocationSelection != nil && !strings.HasPrefix(strings.TrimSpace(fmt.Sprint(base["container_size"])), input.LocationSelection.ContainerSize) {
		return nil, validationError("LOCATION_SELECTION_CONTAINER_SIZE_MISMATCH", "Ukuran template Survey Sheet tidak sesuai Container Type pekerjaan.")
	}
	cedexLocationID, face, internalLocation, err := r.resolveCEDEXLocation(ctx, tx, customerID, input)
	if err != nil {
		return nil, err
	}
	if err := r.validateSelectionMappingTx(ctx, tx, customerID, cedexLocationID, input.LocationSelection); err != nil {
		return nil, err
	}
	locationSelectionSnapshot, err := locationSelectionJSON(input.LocationSelection)
	if err != nil {
		return nil, err
	}
	componentID, err := uuid.Parse(input.ComponentID)
	if err != nil {
		return nil, validationError("COMPONENT_INVALID", "Component tidak valid.")
	}
	damageCodeID, err := uuid.Parse(input.DamageID)
	if err != nil {
		return nil, validationError("DAMAGE_CODE_INVALID", "Damage type tidak valid.")
	}
	if err := r.validateScopedReferenceTx(ctx, tx, "cedex_components", componentID, customerID, "COMPONENT_SCOPE"); err != nil {
		return nil, err
	}
	if err := r.validateScopedReferenceTx(ctx, tx, "cedex_damages", damageCodeID, customerID, "DAMAGE_CODE_SCOPE"); err != nil {
		return nil, err
	}
	repairID, err := parseOptionalReferenceID(input.RepairID, "REPAIR_INVALID", "Repair code tidak valid.")
	if err != nil {
		return nil, err
	}
	if repairID != nil {
		if err := r.validateScopedReferenceTx(ctx, tx, "cedex_repairs", *repairID, customerID, "REPAIR_SCOPE"); err != nil {
			return nil, err
		}
	}
	materialID, err := parseOptionalReferenceID(input.MaterialID, "MATERIAL_INVALID", "Material code tidak valid.")
	if err != nil {
		return nil, err
	}
	if materialID != nil {
		if err := r.validateScopedReferenceTx(ctx, tx, "cedex_materials", *materialID, customerID, "MATERIAL_SCOPE"); err != nil {
			return nil, err
		}
	}
	responsibilityID, err := parseOptionalReferenceID(input.ResponsibilityID, "RESPONSIBILITY_INVALID", "Responsibility code tidak valid.")
	if err != nil {
		return nil, err
	}
	if responsibilityID != nil {
		if err := r.validateScopedReferenceTx(ctx, tx, "responsibility_codes", *responsibilityID, customerID, "RESPONSIBILITY_SCOPE"); err != nil {
			return nil, err
		}
	}
	severity := strings.ToLower(strings.TrimSpace(input.Severity))
	if err := r.validateSeverityTx(ctx, tx, customerID, surveyTypeID, severity); err != nil {
		return nil, err
	}
	evaluation, err := r.evaluateDamageDecisionTx(ctx, tx, base, input, damageCodeID, componentID, cedexLocationID, materialID)
	if err != nil {
		return nil, err
	}
	effectiveActionID := repairID
	if evaluation.RecommendedActionID != "" {
		parsed := nullableUUIDString(evaluation.RecommendedActionID)
		if parsed != nil {
			effectiveActionID = parsed
		}
	}
	if effectiveActionID == nil && evaluation.DefaultActionID != "" {
		parsed := nullableUUIDString(evaluation.DefaultActionID)
		if parsed != nil {
			effectiveActionID = parsed
		}
	}
	if repairID == nil {
		repairID = effectiveActionID
	}
	if effectiveActionID != nil {
		if err := r.validateScopedReferenceTx(ctx, tx, "cedex_repairs", *effectiveActionID, customerID, "RECOMMENDED_ACTION_SCOPE"); err != nil {
			return nil, err
		}
	}
	decisionRuleID := nullableUUIDString(evaluation.DecisionRuleID)
	inspectionReferenceID := nullableUUIDString(evaluation.InspectionReferenceID)
	isRepairRequired := input.IsRepairRequired || evaluation.DecisionResult == "need_repair" || evaluation.DecisionResult == "need_reinspection"
	isCargoWorthyImpact := input.IsCargoWorthyImpact || evaluation.DecisionResult == "not_passed"
	findingDescription, err := r.buildFindingDescriptionTx(ctx, tx, cedexLocationID, componentID, damageCodeID, materialID, effectiveActionID, face, internalLocation, input, evaluation)
	if err != nil {
		return nil, err
	}
	toleranceSnapshot := evaluation.snapshotJSON()
	if damageID == uuid.Nil {
		damageNo, err := r.nextDamageNo(ctx, tx, surveyID)
		if err != nil {
			return nil, err
		}
		item, err := scanRow(tx.QueryRow(ctx, `
			INSERT INTO survey_damages (
			  survey_id, damage_no, face, internal_location, cedex_location_id, manual_location_reason,
			  component_id, damage_id, repair_id, material_id, responsibility_id,
			  decision_rule_id, inspection_reference_id, recommended_action_id,
			  decision_result, decision_reason, tolerance_snapshot, finding_description,
			  severity, quantity, quantity_unit, length_value, width_value, depth_value, unit,
			  is_repair_required, is_cargo_worthy_impact, is_photo_only, remark,
			  dimension_profile, location_selection_snapshot, created_by, updated_by, checklist_response_id
			)
			VALUES ($1,$2,$3,$4,$5,NULLIF($6,''),$7,$8,$9,$10,$11,$12,$13,$14,
			  NULLIF($15,''),NULLIF($16,''),NULLIF($17,''),NULLIF($18,''),
			  $19,$20,NULLIF($21,''),$22,$23,$24,$25,$26,$27,$28,NULLIF($29,''),
			  NULLIF($30,''),NULLIF($31,''),$32,$32,$33)
			RETURNING id, damage_no, face, internal_location, severity, decision_result, finding_description, dimension_profile, location_selection_snapshot, checklist_response_id
		`, surveyID, damageNo, face, internalLocation, cedexLocationID, input.ManualLocationReason,
			componentID, damageCodeID, repairID, materialID, responsibilityID,
			decisionRuleID, inspectionReferenceID, effectiveActionID,
			evaluation.DecisionResult, evaluation.DecisionReason, toleranceSnapshot, findingDescription,
			severity, input.Quantity, defaultString(input.QuantityUnit, "pc"), input.Length, input.Width, input.Depth, defaultString(input.Unit, "cm"),
			isRepairRequired, isCargoWorthyImpact, input.IsPhotoOnly, input.Remark,
			strings.ToLower(strings.TrimSpace(input.DimensionProfile)), locationSelectionSnapshot, actor.UserID, checklistResponseID,
		), []string{"id", "damage_no", "face", "internal_location", "severity", "decision_result", "finding_description", "dimension_profile", "location_selection_snapshot", "checklist_response_id"})
		if err != nil {
			return nil, err
		}
		newID := parseUUIDString(item["id"])
		_ = r.insertAudit(ctx, tx, actor, "survey_damages.create", "survey_damages", &newID, nil, item)
		if input.LocationSelection != nil {
			_ = r.insertAudit(ctx, tx, actor, "survey_sheet.location.select", "survey_damages", &newID, nil, input.LocationSelection)
		}
		if decisionRuleID != nil {
			if err := r.insertAudit(ctx, tx, actor, "cedex_damage_decision_rules.apply", "cedex_damage_decision_rules", decisionRuleID, nil, map[string]any{"survey_damage_id": newID.String(), "snapshot": toleranceSnapshot}); err != nil {
				return nil, err
			}
		}
		return item, tx.Commit(ctx)
	}
	item, err := scanRow(tx.QueryRow(ctx, `
		UPDATE survey_damages
		SET face=$2, internal_location=$3, cedex_location_id=$4, manual_location_reason=NULLIF($5,''),
		  component_id=$6, damage_id=$7, repair_id=$8, material_id=$9, responsibility_id=$10,
		  decision_rule_id=$11, inspection_reference_id=$12, recommended_action_id=$13,
		  decision_result=NULLIF($14,''), decision_reason=NULLIF($15,''),
		  tolerance_snapshot=NULLIF($16,''), finding_description=NULLIF($17,''),
		  severity=$18, quantity=$19, quantity_unit=NULLIF($20,''), length_value=$21, width_value=$22, depth_value=$23, unit=$24,
		  is_repair_required=$25, is_cargo_worthy_impact=$26, is_photo_only=$27,
		  remark=NULLIF($28,''), dimension_profile=NULLIF($29,''),
		  location_selection_snapshot=NULLIF($30,''), updated_by=$31, checklist_response_id=$32, updated_at=now()
		WHERE id=$1 AND deleted_at IS NULL
		RETURNING id, damage_no, face, internal_location, severity, decision_result, finding_description, dimension_profile, location_selection_snapshot, checklist_response_id
	`, damageID, face, internalLocation, cedexLocationID, input.ManualLocationReason,
		componentID, damageCodeID, repairID, materialID, responsibilityID,
		decisionRuleID, inspectionReferenceID, effectiveActionID,
		evaluation.DecisionResult, evaluation.DecisionReason, toleranceSnapshot, findingDescription,
		severity, input.Quantity, defaultString(input.QuantityUnit, "pc"), input.Length, input.Width, input.Depth, defaultString(input.Unit, "cm"),
		isRepairRequired, isCargoWorthyImpact, input.IsPhotoOnly, input.Remark,
		strings.ToLower(strings.TrimSpace(input.DimensionProfile)), locationSelectionSnapshot, actor.UserID, checklistResponseID,
	), []string{"id", "damage_no", "face", "internal_location", "severity", "decision_result", "finding_description", "dimension_profile", "location_selection_snapshot", "checklist_response_id"})
	if err != nil {
		return nil, err
	}
	_ = r.insertAudit(ctx, tx, actor, "survey_damages.update", "survey_damages", &damageID, nil, item)
	if input.LocationSelection != nil {
		_ = r.insertAudit(ctx, tx, actor, "survey_sheet.location.select", "survey_damages", &damageID, nil, input.LocationSelection)
	}
	if decisionRuleID != nil {
		if err := r.insertAudit(ctx, tx, actor, "cedex_damage_decision_rules.apply", "cedex_damage_decision_rules", decisionRuleID, nil, map[string]any{"survey_damage_id": damageID.String(), "snapshot": toleranceSnapshot}); err != nil {
			return nil, err
		}
	}
	return item, tx.Commit(ctx)
}
