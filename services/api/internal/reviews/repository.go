package reviews

import (
	"container-survey/services/api/internal/database"
	"container-survey/services/api/internal/jobstatus"
	"container-survey/services/api/internal/numbering"
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

func (r Repository) Pending(ctx context.Context, params ListParams) (ListResult, error) {
	return r.listSurveys(ctx, params, "submitted")
}

func (r Repository) Monitoring(ctx context.Context, params ListParams) (ListResult, error) {
	return r.listSurveys(ctx, params, "")
}

func (r Repository) Reviews(ctx context.Context, params ListParams) (ListResult, error) {
	return r.listSurveys(ctx, params, "need_revision")
}

func (r Repository) listSurveys(ctx context.Context, params ListParams, defaultStatus string) (ListResult, error) {
	page, perPage := normalizePagination(params.Page, params.PerPage)
	where, args := surveyWhere(params, defaultStatus)
	total, err := r.count(ctx, where, args)
	if err != nil {
		return ListResult{}, err
	}
	args = append(args, perPage, (page-1)*perPage)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT s.id AS survey_id, s.survey_no, jo.job_order_no, jc.container_no,
		       c.customer_name, l.location_name, sp.full_name AS surveyor_name, st.name AS survey_type_name,
		       s.current_reviewer_id, reviewer.name AS current_reviewer_name, s.current_revision_no,
		       s.started_at, s.submitted_at, s.review_started_at, s.resubmitted_at, s.approved_at, s.rejected_at,
		       CASE WHEN s.status='draft' THEN 'in_progress' ELSE s.status END AS status
		FROM surveys s
		JOIN job_orders jo ON jo.id=s.job_order_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN customers c ON c.id=jo.customer_id
		JOIN locations l ON l.id=jo.location_id
		JOIN survey_types st ON st.id=s.survey_type_id
		JOIN surveyor_profiles sp ON sp.id=s.surveyor_id
		LEFT JOIN users reviewer ON reviewer.id=s.current_reviewer_id
		%s
		ORDER BY COALESCE(s.approved_at, s.resubmitted_at, s.review_started_at, s.submitted_at, s.started_at, s.updated_at) DESC
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

func (r Repository) Detail(ctx context.Context, surveyID uuid.UUID) (map[string]any, error) {
	base, err := r.surveyBase(ctx, surveyID)
	if err != nil {
		return nil, err
	}
	general, _ := r.queryOne(ctx, `SELECT *, id AS id, survey_id AS survey_id FROM survey_general_infos WHERE survey_id=$1`, surveyID)
	checklist, _ := r.queryRows(ctx, `SELECT id, item_code AS item_key, item_label, response_value AS value, response_text AS note, is_required, is_critical, display_order FROM survey_checklist_responses WHERE survey_id=$1 ORDER BY display_order, item_code`, surveyID)
	damages, _ := r.queryRows(ctx, `
		SELECT sd.id, sd.damage_no, sd.face, sd.internal_location,
		       sd.cedex_location_id, location.code AS cedex_location_code,
		       sd.checklist_response_id, checklist.item_code AS checklist_item_code,
		       checklist.item_label AS checklist_item_label,
		       cc.code AS component_code, cc.component_name AS component_name,
		       cd.code AS damage_code, cd.damage_name AS damage_name, cr.code AS repair_code, cr.repair_name AS repair_name,
		       cm.code AS material_code, cm.material_name, rc.code AS responsibility_code, rc.name AS responsibility_name,
		       sd.severity, sd.quantity, sd.length_value AS length, sd.width_value AS width, sd.depth_value AS depth,
		       sd.unit, sd.is_repair_required, sd.is_cargo_worthy_impact, sd.remark,
		       sd.decision_result, sd.finding_description, sd.dimension_profile,
		       sd.location_selection_snapshot,
		       COUNT(sp.id) AS photo_count
		FROM survey_damages sd
		LEFT JOIN survey_checklist_responses checklist ON checklist.id=sd.checklist_response_id
		LEFT JOIN cedex_locations location ON location.id=sd.cedex_location_id
		JOIN cedex_components cc ON cc.id=sd.component_id
		JOIN cedex_damages cd ON cd.id=sd.damage_id
		LEFT JOIN cedex_repairs cr ON cr.id=sd.repair_id
		LEFT JOIN cedex_materials cm ON cm.id=sd.material_id
		LEFT JOIN responsibility_codes rc ON rc.id=sd.responsibility_id
		LEFT JOIN survey_photos sp ON sp.damage_id=sd.id AND sp.deleted_at IS NULL
		WHERE sd.survey_id=$1 AND sd.deleted_at IS NULL
		GROUP BY sd.id, checklist.id, location.id, cc.id, cd.id, cr.id, cm.id, rc.id
		ORDER BY sd.damage_no
	`, surveyID)
	photos, _ := r.queryRows(ctx, `
		SELECT sp.id, sp.survey_id, sp.damage_id, sp.photo_type, sp.photo_category, sp.caption, sp.created_at,
		       fo.object_key, fo.original_file_name
		FROM survey_photos sp
		JOIN file_objects fo ON fo.id=sp.file_id
		WHERE sp.survey_id=$1 AND sp.deleted_at IS NULL
		ORDER BY sp.created_at DESC
	`, surveyID)
	approvals, _ := r.queryRows(ctx, `SELECT id, decision, review_note, final_result, revision_no, reviewed_at FROM survey_approvals WHERE survey_id=$1 ORDER BY reviewed_at DESC`, surveyID)
	revisions, _ := r.queryRows(ctx, `
		SELECT revision.id, revision.survey_id, revision.revision_no, revision.revision_reason,
		       revision.requested_by, requester.name AS requested_by_name, revision.requested_at,
		       revision.resubmitted_by, resubmitter.name AS resubmitted_by_name, revision.resubmitted_at,
		       revision.reviewer_note, revision.status,
		       revision.snapshot_before, revision.snapshot_after, revision.created_at, revision.updated_at
		FROM survey_revisions revision
		LEFT JOIN users requester ON requester.id=revision.requested_by
		LEFT JOIN users resubmitter ON resubmitter.id=revision.resubmitted_by
		WHERE revision.survey_id=$1
		ORDER BY revision.revision_no DESC
	`, surveyID)
	revisionItems, _ := r.queryRows(ctx, `
		SELECT item.id, item.target_type, item.target_id, item.category, item.target_snapshot,
		       item.note, item.due_at, item.is_resolved, item.resolved_by, resolver.name AS resolved_by_name,
		       item.resolved_at, item.created_at
		FROM survey_revision_items item
		LEFT JOIN users resolver ON resolver.id=item.resolved_by
		WHERE item.survey_id=$1
		ORDER BY item.is_resolved, item.created_at DESC
	`, surveyID)
	base["general_info"] = general
	base["checklist"] = checklist
	base["damages"] = damages
	base["photos"] = photos
	base["approval_history"] = approvals
	base["revision_history"] = revisions
	base["revision_items"] = revisionItems
	base["survey_result_recommendation"] = recommendedResult(damages)
	return base, nil
}

func (r Repository) StartReview(ctx context.Context, surveyID uuid.UUID, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	base, err := r.surveyForUpdate(ctx, tx, surveyID)
	if err != nil {
		return nil, err
	}
	previousStatus := fmt.Sprint(base["status"])
	currentReviewerID := parseUUIDString(base["current_reviewer_id"])
	if previousStatus == "under_review" {
		if currentReviewerID == actor.UserID {
			return map[string]any{
				"survey_id": surveyID.String(), "status": "under_review",
				"current_reviewer_id": actor.UserID.String(), "idempotent": true,
			}, tx.Commit(ctx)
		}
		return nil, ErrReviewClaimed
	}
	if previousStatus != "submitted" && previousStatus != "resubmitted" {
		return nil, ErrInvalidStatus
	}
	if _, err := tx.Exec(ctx, `
		UPDATE surveys
		SET status='under_review', review_started_by=$2, current_reviewer_id=$2,
		    review_started_at=now(), updated_at=now()
		WHERE id=$1
	`, surveyID, actor.UserID); err != nil {
		return nil, err
	}
	if _, err := jobstatus.RecalculateJobStatusTx(ctx, tx, parseUUIDString(base["job_order_id"]), &actor.UserID); err != nil {
		return nil, err
	}
	item := map[string]any{"survey_id": surveyID.String(), "status": "under_review", "previous_status": previousStatus, "current_reviewer_id": actor.UserID.String()}
	_ = r.insertAudit(ctx, tx, actor, "reviews.start", "surveys", &surveyID, base, item)
	_ = r.insertJobEvent(ctx, tx, parseUUIDString(base["job_order_id"]), "survey_under_review", "Review survey dimulai.", fmt.Sprint(base["container_no"]), actor.UserID, item)
	return item, tx.Commit(ctx)
}

func (r Repository) NeedRevision(ctx context.Context, surveyID uuid.UUID, input NeedRevisionInput, actor Actor) (map[string]any, error) {
	if strings.TrimSpace(input.RevisionNote) == "" {
		return nil, ErrInvalidInput
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	base, err := r.surveyForUpdate(ctx, tx, surveyID)
	if err != nil {
		return nil, err
	}
	if !reviewableStatus(fmt.Sprint(base["status"])) {
		return nil, ErrInvalidStatus
	}
	if err := requireCurrentReviewer(base, actor); err != nil {
		return nil, err
	}
	snapshotBefore, err := r.revisionSnapshotTx(ctx, tx, surveyID, base)
	if err != nil {
		return nil, err
	}
	approvalID := uuid.Nil
	revisionNo := intFromAny(base["current_revision_no"]) + 1
	if err := tx.QueryRow(ctx, `INSERT INTO survey_approvals (survey_id,reviewer_id,decision,review_note,revision_no) VALUES ($1,$2,'need_revision',$3,$4) RETURNING id`, surveyID, actor.UserID, input.RevisionNote, revisionNo).Scan(&approvalID); err != nil {
		return nil, err
	}
	items := input.Items
	if len(items) == 0 {
		items = []RevisionItemInput{{TargetType: "survey", Category: "general", Note: input.RevisionNote}}
	}
	for _, revisionItem := range items {
		targetType := strings.ToLower(strings.TrimSpace(revisionItem.TargetType))
		if targetType == "" {
			targetType = "survey"
		}
		targetID, err := validateRevisionTargetTx(ctx, tx, surveyID, targetType, revisionItem.TargetID)
		if err != nil {
			return nil, err
		}
		note := strings.TrimSpace(revisionItem.Note)
		if note == "" {
			note = strings.TrimSpace(input.RevisionNote)
		}
		if note == "" {
			return nil, ErrInvalidInput
		}
		category := strings.TrimSpace(revisionItem.Category)
		if category == "" {
			category = "general"
		}
		var dueAt any
		if revisionItem.DueAt != nil && strings.TrimSpace(*revisionItem.DueAt) != "" {
			parsed, parseErr := time.Parse(time.RFC3339, strings.TrimSpace(*revisionItem.DueAt))
			if parseErr != nil {
				return nil, ErrInvalidInput
			}
			dueAt = parsed
		}
		var targetSnapshot any
		if len(revisionItem.TargetSnapshot) > 0 {
			encoded, encodeErr := json.Marshal(revisionItem.TargetSnapshot)
			if encodeErr != nil {
				return nil, ErrInvalidInput
			}
			targetSnapshot = string(encoded)
		}
		if _, err := tx.Exec(ctx, `
			INSERT INTO survey_revision_items (
			  approval_id,survey_id,target_type,target_id,category,target_snapshot,due_at,note
			) VALUES ($1,$2,$3,$4,$5,$6,$7,$8)
		`, approvalID, surveyID, targetType, targetID, category, targetSnapshot, dueAt, note); err != nil {
			return nil, err
		}
	}
	_, _ = tx.Exec(ctx, `
		UPDATE survey_revisions
		SET status='superseded', reviewer_note=$3, updated_at=now()
		WHERE survey_id=$1 AND revision_no=$2 AND status IN ('resubmitted','under_review')
	`, surveyID, intFromAny(base["current_revision_no"]), input.RevisionNote)
	if _, err := tx.Exec(ctx, `
		INSERT INTO survey_revisions (
		  survey_id, revision_no, revision_reason, requested_by, reviewer_note, snapshot_before
		) VALUES ($1,$2,$3,$4,$3,$5)
	`, surveyID, revisionNo, input.RevisionNote, actor.UserID, snapshotBefore); err != nil {
		return nil, err
	}
	_, _ = tx.Exec(ctx, `UPDATE surveys SET status='need_revision', current_revision_no=$2, review_started_by=NULL, current_reviewer_id=NULL, review_started_at=NULL, updated_at=now() WHERE id=$1`, surveyID, revisionNo)
	if _, err := jobstatus.RecalculateJobStatusTx(ctx, tx, parseUUIDString(base["job_order_id"]), &actor.UserID); err != nil {
		return nil, err
	}
	item := map[string]any{"survey_id": surveyID.String(), "status": "need_revision", "revision_note": input.RevisionNote, "revision_items": len(items)}
	_ = r.insertAudit(ctx, tx, actor, "reviews.need_revision", "surveys", &surveyID, base, item)
	_ = r.insertJobEvent(ctx, tx, parseUUIDString(base["job_order_id"]), "survey_need_revision", "Survey perlu revisi.", input.RevisionNote, actor.UserID, item)
	return item, tx.Commit(ctx)
}

func (r Repository) Approve(ctx context.Context, surveyID uuid.UUID, input ApproveInput, actor Actor) (map[string]any, error) {
	if strings.TrimSpace(input.FinalResult) == "" {
		return nil, ErrInvalidInput
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	base, err := r.surveyForUpdate(ctx, tx, surveyID)
	if err != nil {
		return nil, err
	}
	if !reviewableStatus(fmt.Sprint(base["status"])) {
		return nil, ErrInvalidStatus
	}
	if err := requireCurrentReviewer(base, actor); err != nil {
		return nil, err
	}
	if _, err := tx.Exec(ctx, `INSERT INTO survey_approvals (survey_id,reviewer_id,decision,review_note,final_result,revision_no) VALUES ($1,$2,'approved',NULLIF($3,''),$4,$5)`, surveyID, actor.UserID, input.ApprovalNote, input.FinalResult, intFromAny(base["current_revision_no"])); err != nil {
		return nil, err
	}
	_, _ = tx.Exec(ctx, `UPDATE surveys SET status='approved', approved_at=now(), survey_result=$2, updated_at=now() WHERE id=$1`, surveyID, input.FinalResult)
	jobID := parseUUIDString(base["job_order_id"])
	_, _ = tx.Exec(ctx, `
		UPDATE survey_revisions SET status='approved', reviewer_note=NULLIF($3,''), updated_at=now()
		WHERE survey_id=$1 AND revision_no=$2
	`, surveyID, intFromAny(base["current_revision_no"]), input.ApprovalNote)
	report, err := r.createReportTx(ctx, tx, surveyID, base, actor, "container_inspection_report")
	if err != nil {
		return nil, err
	}
	if _, err := jobstatus.RecalculateJobStatusTx(ctx, tx, jobID, &actor.UserID); err != nil {
		return nil, err
	}
	item := map[string]any{
		"survey_id": surveyID.String(), "status": "approved",
		"report_id": report["id"], "report_no": report["report_no"],
		"report_generation_status": "metadata_ready",
	}
	_ = r.insertAudit(ctx, tx, actor, "reviews.approve", "surveys", &surveyID, base, item)
	_ = r.insertJobEvent(ctx, tx, jobID, "survey_approved", "Survey disetujui.", "Metadata laporan internal dibentuk.", actor.UserID, item)
	return item, tx.Commit(ctx)
}

func (r Repository) Reject(ctx context.Context, surveyID uuid.UUID, input RejectInput, actor Actor) (map[string]any, error) {
	if strings.TrimSpace(input.RejectionReason) == "" {
		return nil, ErrInvalidInput
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	base, err := r.surveyForUpdate(ctx, tx, surveyID)
	if err != nil {
		return nil, err
	}
	if !reviewableStatus(fmt.Sprint(base["status"])) {
		return nil, ErrInvalidStatus
	}
	if err := requireCurrentReviewer(base, actor); err != nil {
		return nil, err
	}
	if _, err := tx.Exec(ctx, `INSERT INTO survey_approvals (survey_id,reviewer_id,decision,review_note,revision_no) VALUES ($1,$2,'rejected',$3,$4)`, surveyID, actor.UserID, input.RejectionReason, intFromAny(base["current_revision_no"])); err != nil {
		return nil, err
	}
	_, _ = tx.Exec(ctx, `UPDATE surveys SET status='rejected', rejected_at=now(), updated_at=now() WHERE id=$1`, surveyID)
	_, _ = tx.Exec(ctx, `
		UPDATE survey_revisions SET status='rejected', reviewer_note=$3, updated_at=now()
		WHERE survey_id=$1 AND revision_no=$2
	`, surveyID, intFromAny(base["current_revision_no"]), input.RejectionReason)
	if _, err := jobstatus.RecalculateJobStatusTx(ctx, tx, parseUUIDString(base["job_order_id"]), &actor.UserID); err != nil {
		return nil, err
	}
	item := map[string]any{"survey_id": surveyID.String(), "status": "rejected", "rejection_reason": input.RejectionReason}
	_ = r.insertAudit(ctx, tx, actor, "reviews.reject", "surveys", &surveyID, base, item)
	_ = r.insertJobEvent(ctx, tx, parseUUIDString(base["job_order_id"]), "survey_rejected", "Survey ditolak.", input.RejectionReason, actor.UserID, item)
	return item, tx.Commit(ctx)
}

func (r Repository) ListReports(ctx context.Context, params ListParams) (ListResult, error) {
	page, perPage := normalizePagination(params.Page, params.PerPage)
	where, args := reportWhere(params)
	var total int
	if err := r.pool.QueryRow(ctx, "SELECT COUNT(*) FROM reports r JOIN surveys s ON s.id=r.survey_id JOIN job_orders jo ON jo.id=r.job_order_id JOIN job_containers jc ON jc.id=s.job_container_id JOIN customers c ON c.id=r.customer_id "+where, args...).Scan(&total); err != nil {
		return ListResult{}, err
	}
	args = append(args, perPage, (page-1)*perPage)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT r.id, r.report_no, r.current_version_no AS revision_no, jo.job_order_no, s.survey_no, jc.container_no,
		       c.customer_name, r.status, r.qr_token, r.created_at
		FROM reports r
		JOIN surveys s ON s.id=r.survey_id
		JOIN job_orders jo ON jo.id=r.job_order_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN customers c ON c.id=r.customer_id
		%s
		ORDER BY r.created_at DESC
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

func (r Repository) ReportDetail(ctx context.Context, reportID uuid.UUID) (map[string]any, error) {
	item, err := r.queryOne(ctx, `
		SELECT r.id, r.report_no, r.report_type, r.status, r.current_version_no,
		       r.current_version_no AS revision_no, r.qr_token, r.created_at, r.updated_at,
		       COALESCE(sgi.job_order_no_snapshot,jo.job_order_no) AS job_order_no,
		       s.id AS survey_id, s.survey_no, s.started_at, s.survey_result,
		       COALESCE(sgi.container_no,jc.container_no) AS container_no,
		       COALESCE(sgi.customer_name_snapshot,c.customer_name) AS customer_name,
		       COALESCE(sgi.location_name_snapshot,l.location_name) AS location_name,
		       COALESCE(sgi.survey_type_name_snapshot,st.name) AS survey_type_name,
		       COALESCE(sgi.container_type_code_snapshot,ct.code) AS container_type_code,
		       COALESCE(sgi.container_type_name_snapshot,ct.type_name) AS container_type_name,
		       COALESCE(sgi.container_size_snapshot,ct.size) AS container_size,
		       sgi.iso_type_code, sgi.manufacture_date, sgi.gross_weight, sgi.tare_weight, sgi.payload,
		       sgi.cargo_status_initial, sgi.cargo_status AS cargo_status_verified,
		       sgi.csc_plate_status_initial, sgi.csc_plate_status AS csc_plate_status_verified,
		       sgi.csc_plate_number, sgi.csc_approval_reference, sgi.csc_manufacture_date,
		       sgi.csc_next_examination_date, sgi.csc_program_type,
		       sgi.general_condition, sgi.cleanliness, sgi.general_remark
		FROM reports r
		JOIN surveys s ON s.id=r.survey_id
		JOIN job_orders jo ON jo.id=r.job_order_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN survey_general_infos sgi ON sgi.survey_id=s.id
		JOIN customers c ON c.id=r.customer_id
		JOIN locations l ON l.id=jo.location_id
		JOIN survey_types st ON st.id=s.survey_type_id
		LEFT JOIN container_types ct ON ct.id=sgi.container_type_id
		WHERE r.id=$1
	`, reportID)
	if err != nil {
		return nil, err
	}
	surveyID := parseUUIDString(item["survey_id"])
	checklist, _ := r.queryRows(ctx, `
		SELECT response.id, response.item_code AS item_key, response.item_label,
		       response.response_value AS value, response.response_numeric AS numeric_value,
		       response.response_text AS note, response.response_type, response.unit,
		       response.standard_reference, response.is_required, response.is_critical,
		       response.display_order
		FROM survey_checklist_responses response
		WHERE response.survey_id=$1
		ORDER BY response.display_order, response.item_code
	`, surveyID)
	damages, _ := r.queryRows(ctx, `
		SELECT sd.id, sd.damage_no, location.code AS cedex_location_code,
		       component.code AS component_code, component.component_name,
		       damage.code AS damage_code, damage.damage_name,
		       repair.code AS repair_code, repair.repair_name,
		       material.code AS material_code, material.material_name,
		       sd.finding_description, sd.decision_result, sd.severity,
		       sd.quantity, sd.quantity_unit, sd.length_value AS length,
		       sd.width_value AS width, sd.depth_value AS depth, sd.unit, sd.remark
		FROM survey_damages sd
		LEFT JOIN cedex_locations location ON location.id=sd.cedex_location_id
		JOIN cedex_components component ON component.id=sd.component_id
		JOIN cedex_damages damage ON damage.id=sd.damage_id
		LEFT JOIN cedex_repairs repair ON repair.id=sd.repair_id
		LEFT JOIN cedex_materials material ON material.id=sd.material_id
		WHERE sd.survey_id=$1 AND sd.deleted_at IS NULL
		ORDER BY sd.damage_no
	`, surveyID)
	photos, _ := r.queryRows(ctx, `
		SELECT photo.id, photo.damage_id, photo.photo_type, photo.photo_category,
		       photo.caption, fo.original_file_name, photo.created_at
		FROM survey_photos photo
		JOIN file_objects fo ON fo.id=photo.file_id
		WHERE photo.survey_id=$1 AND photo.deleted_at IS NULL
		ORDER BY photo.created_at
	`, surveyID)
	reviewHistory, _ := r.queryRows(ctx, `
		SELECT approval.id, approval.decision, approval.review_note, approval.final_result,
		       approval.revision_no, approval.reviewed_at, reviewer.name AS reviewer_name
		FROM survey_approvals approval
		JOIN users reviewer ON reviewer.id=approval.reviewer_id
		WHERE approval.survey_id=$1
		ORDER BY approval.reviewed_at, approval.id
	`, surveyID)
	versions, _ := r.ReportVersions(ctx, reportID)
	item["checklist"] = checklist
	item["damages"] = damages
	item["photos"] = photos
	item["review_history"] = reviewHistory
	item["versions"] = versions
	return item, nil
}

func (r Repository) ReportVersions(ctx context.Context, reportID uuid.UUID) ([]map[string]any, error) {
	return r.queryRows(ctx, `SELECT id, report_id, version_no, file_id, change_reason, status, created_at FROM report_versions WHERE report_id=$1 ORDER BY version_no DESC`, reportID)
}

func (r Repository) GenerateReport(ctx context.Context, surveyID uuid.UUID, input GenerateReportInput, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	base, err := r.surveyForUpdate(ctx, tx, surveyID)
	if err != nil {
		return nil, err
	}
	if fmt.Sprint(base["status"]) != "approved" && fmt.Sprint(base["status"]) != "report_generated" {
		return nil, ErrInvalidStatus
	}
	reportType := defaultString(input.ReportType, "container_inspection_report")
	report, err := r.createReportTx(ctx, tx, surveyID, base, actor, reportType)
	if err != nil {
		return nil, err
	}
	_, _ = tx.Exec(ctx, `UPDATE reports SET status='pending_generation', updated_at=now() WHERE id=$1 AND status IN ('failed','pending_generation')`, parseUUIDString(report["id"]))
	item := map[string]any{"survey_id": surveyID.String(), "report_no": report["report_no"], "status": "queued"}
	_ = r.insertAudit(ctx, tx, actor, "reports.generate", "reports", nil, nil, item)
	return item, tx.Commit(ctx)
}

func (r Repository) ValidateQR(ctx context.Context, token string) (map[string]any, error) {
	return r.queryOne(ctx, validateQRQuery, token)
}

const validateQRQuery = `
		SELECT r.report_no, r.current_version_no AS revision_no, jc.container_no, c.customer_name,
		       DATE(s.approved_at) AS survey_date, CASE WHEN r.status <> 'void' THEN 'valid' ELSE 'void' END AS status,
		       sp.full_name AS surveyor_name, u.name AS approver_name
		FROM reports r
		JOIN surveys s ON s.id=r.survey_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN customers c ON c.id=r.customer_id
		JOIN surveyor_profiles sp ON sp.id=s.surveyor_id
		LEFT JOIN users u ON u.id = (
		  SELECT sa.reviewer_id
		  FROM survey_approvals sa
		  WHERE sa.survey_id=s.id AND sa.decision='approved'
		  ORDER BY sa.reviewed_at DESC, sa.id DESC
		  LIMIT 1
		)
		WHERE r.qr_token=$1 AND r.validated_publicly=true
	`

func (r Repository) createReportTx(ctx context.Context, tx database.Tx, surveyID uuid.UUID, base map[string]any, actor Actor, reportType string) (map[string]any, error) {
	existing, err := scanRow(tx.QueryRow(ctx, `SELECT id, report_no, status FROM reports WHERE survey_id=$1 AND status <> 'void' LIMIT 1`, surveyID), []string{"id", "report_no", "status"})
	if err == nil {
		return existing, nil
	}
	if !errors.Is(err, ErrNotFound) {
		return nil, err
	}
	reportNo, err := numbering.Next(ctx, tx, "report")
	if err != nil {
		return nil, err
	}
	reportID := uuid.Nil
	err = tx.QueryRow(ctx, `
		INSERT INTO reports (
		  report_no, report_type, job_order_id, job_container_id, survey_id, customer_id,
		  status, current_version_no, qr_token, validated_publicly,
		  generated_by, created_by, approved_by, approved_at
		)
		VALUES ($1,$2,$3,$4,$5,$6,'pending_generation',1,NULL,0,$7,$7,$7,now())
		RETURNING id
	`, reportNo, reportType, parseUUIDString(base["job_order_id"]), parseUUIDString(base["job_container_id"]), surveyID, parseUUIDString(base["customer_id"]), actor.UserID).Scan(&reportID)
	if err != nil {
		return nil, err
	}
	versionID := uuid.Nil
	if err := tx.QueryRow(ctx, `INSERT INTO report_versions (report_id,version_no,status,created_by) VALUES ($1,1,'draft',$2) RETURNING id`, reportID, actor.UserID).Scan(&versionID); err != nil {
		return nil, err
	}
	snapshot, _ := json.Marshal(base)
	if _, err := tx.Exec(ctx, `INSERT INTO report_snapshots (report_version_id,snapshot_data) VALUES ($1,$2)`, versionID, string(snapshot)); err != nil {
		return nil, err
	}
	return map[string]any{"id": reportID.String(), "report_no": reportNo, "status": "pending_generation", "current_version_no": 1}, nil
}
