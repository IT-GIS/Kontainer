package reviews

import (
	"container-survey/services/api/internal/database"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"strings"

	"github.com/google/uuid"
)

type Repository struct {
	pool *database.Pool
}

func NewRepository(pool *database.Pool) Repository {
	return Repository{pool: pool}
}

func (r Repository) Pending(ctx context.Context, params ListParams) (ListResult, error) {
	page, perPage := normalizePagination(params.Page, params.PerPage)
	where, args := surveyWhere(params, "submitted")
	total, err := r.count(ctx, where, args)
	if err != nil {
		return ListResult{}, err
	}
	args = append(args, perPage, (page-1)*perPage)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT s.id AS survey_id, s.survey_no, jo.job_order_no, jc.container_no,
		       c.customer_name, sp.full_name AS surveyor_name, st.name AS survey_type_name,
		       s.submitted_at, s.status
		FROM surveys s
		JOIN job_orders jo ON jo.id=s.job_order_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN customers c ON c.id=jo.customer_id
		JOIN survey_types st ON st.id=s.survey_type_id
		JOIN surveyor_profiles sp ON sp.id=s.surveyor_id
		%s
		ORDER BY s.submitted_at IS NULL, s.submitted_at ASC, s.updated_at ASC
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
		SELECT sd.id, sd.damage_no, sd.face, sd.internal_location, cc.code AS component_code, cc.name AS component_name,
		       cd.code AS damage_code, cd.name AS damage_name, cr.code AS repair_code, cr.name AS repair_name,
		       sd.severity, sd.quantity, sd.length_value AS length, sd.width_value AS width, sd.depth_value AS depth,
		       sd.unit, sd.is_repair_required, sd.is_cargo_worthy_impact, sd.remark,
		       COUNT(sp.id) AS photo_count
		FROM survey_damages sd
		JOIN cedex_components cc ON cc.id=sd.component_id
		JOIN cedex_damages cd ON cd.id=sd.damage_id
		LEFT JOIN cedex_repairs cr ON cr.id=sd.repair_id
		LEFT JOIN survey_photos sp ON sp.damage_id=sd.id AND sp.deleted_at IS NULL
		WHERE sd.survey_id=$1 AND sd.deleted_at IS NULL
		GROUP BY sd.id, cc.id, cd.id, cr.id
		ORDER BY sd.damage_no
	`, surveyID)
	photos, _ := r.queryRows(ctx, `
		SELECT sp.id, sp.survey_id, sp.damage_id, sp.photo_type, sp.caption, sp.created_at,
		       fo.object_key, fo.original_file_name
		FROM survey_photos sp
		JOIN file_objects fo ON fo.id=sp.file_id
		WHERE sp.survey_id=$1 AND sp.deleted_at IS NULL
		ORDER BY sp.created_at DESC
	`, surveyID)
	approvals, _ := r.queryRows(ctx, `SELECT id, decision, review_note, final_result, revision_no, reviewed_at FROM survey_approvals WHERE survey_id=$1 ORDER BY reviewed_at DESC`, surveyID)
	base["general_info"] = general
	base["checklist"] = checklist
	base["damages"] = damages
	base["photos"] = photos
	base["approval_history"] = approvals
	base["survey_result_recommendation"] = recommendedResult(damages)
	return base, nil
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
	if fmt.Sprint(base["status"]) != "submitted" {
		return nil, ErrInvalidStatus
	}
	approvalID := uuid.Nil
	revisionNo := intFromAny(base["current_revision_no"]) + 1
	if err := tx.QueryRow(ctx, `INSERT INTO survey_approvals (survey_id,reviewer_id,decision,review_note,revision_no) VALUES ($1,$2,'need_revision',$3,$4) RETURNING id`, surveyID, actor.UserID, input.RevisionNote, revisionNo).Scan(&approvalID); err != nil {
		return nil, err
	}
	if _, err := tx.Exec(ctx, `INSERT INTO survey_revision_items (approval_id,survey_id,target_type,note) VALUES ($1,$2,'survey',$3)`, approvalID, surveyID, input.RevisionNote); err != nil {
		return nil, err
	}
	_, _ = tx.Exec(ctx, `UPDATE surveys SET status='need_revision', current_revision_no=$2, updated_at=now() WHERE id=$1`, surveyID, revisionNo)
	_, _ = tx.Exec(ctx, `UPDATE job_containers SET status='need_revision', updated_at=now() WHERE id=$1`, parseUUIDString(base["job_container_id"]))
	_, _ = tx.Exec(ctx, `UPDATE job_orders SET status='in_progress', updated_by=$2, updated_at=now() WHERE id=$1`, parseUUIDString(base["job_order_id"]), actor.UserID)
	item := map[string]any{"survey_id": surveyID.String(), "status": "need_revision", "revision_note": input.RevisionNote}
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
	if fmt.Sprint(base["status"]) != "submitted" {
		return nil, ErrInvalidStatus
	}
	if _, err := tx.Exec(ctx, `INSERT INTO survey_approvals (survey_id,reviewer_id,decision,review_note,final_result,revision_no) VALUES ($1,$2,'approved',NULLIF($3,''),$4,$5)`, surveyID, actor.UserID, input.ApprovalNote, input.FinalResult, intFromAny(base["current_revision_no"])); err != nil {
		return nil, err
	}
	_, _ = tx.Exec(ctx, `UPDATE surveys SET status='approved', approved_at=now(), survey_result=$2, updated_at=now() WHERE id=$1`, surveyID, input.FinalResult)
	containerID := parseUUIDString(base["job_container_id"])
	jobID := parseUUIDString(base["job_order_id"])
	_, _ = tx.Exec(ctx, `UPDATE job_containers SET status='approved', updated_at=now() WHERE id=$1`, containerID)
	_, _ = tx.Exec(ctx, `
		UPDATE job_orders SET status='all_survey_approved', updated_by=$2, updated_at=now()
		WHERE id=$1 AND NOT EXISTS (
		  SELECT 1 FROM job_containers jc
		  WHERE jc.job_order_id=$1 AND jc.deleted_at IS NULL AND jc.status NOT IN ('approved','report_generated','cancelled')
		)
	`, jobID, actor.UserID)
	report, err := r.createReportTx(ctx, tx, surveyID, base, actor, "container_inspection_report")
	if err != nil {
		return nil, err
	}
	item := map[string]any{"survey_id": surveyID.String(), "status": "approved", "report_no": report["report_no"], "report_generation_status": "queued"}
	_ = r.insertAudit(ctx, tx, actor, "reviews.approve", "surveys", &surveyID, base, item)
	_ = r.insertJobEvent(ctx, tx, jobID, "survey_approved", "Survey disetujui.", fmt.Sprint(report["report_no"]), actor.UserID, item)
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
	if fmt.Sprint(base["status"]) != "submitted" {
		return nil, ErrInvalidStatus
	}
	if _, err := tx.Exec(ctx, `INSERT INTO survey_approvals (survey_id,reviewer_id,decision,review_note,revision_no) VALUES ($1,$2,'rejected',$3,$4)`, surveyID, actor.UserID, input.RejectionReason, intFromAny(base["current_revision_no"])); err != nil {
		return nil, err
	}
	_, _ = tx.Exec(ctx, `UPDATE surveys SET status='rejected', rejected_at=now(), updated_at=now() WHERE id=$1`, surveyID)
	_, _ = tx.Exec(ctx, `UPDATE job_containers SET status='rejected', updated_at=now() WHERE id=$1`, parseUUIDString(base["job_container_id"]))
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
		SELECT r.id, r.report_no, r.report_type, r.status, r.current_version_no, r.qr_token, r.created_at, r.updated_at,
		       jo.job_order_no, s.id AS survey_id, s.survey_no, jc.container_no, c.customer_name
		FROM reports r
		JOIN surveys s ON s.id=r.survey_id
		JOIN job_orders jo ON jo.id=r.job_order_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN customers c ON c.id=r.customer_id
		WHERE r.id=$1
	`, reportID)
	if err != nil {
		return nil, err
	}
	versions, _ := r.ReportVersions(ctx, reportID)
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
	return r.queryOne(ctx, `
		SELECT r.report_no, r.current_version_no AS revision_no, jc.container_no, c.customer_name,
		       s.approved_at::date AS survey_date, CASE WHEN r.status <> 'void' THEN 'valid' ELSE 'void' END AS status,
		       sp.full_name AS surveyor_name, u.name AS approver_name
		FROM reports r
		JOIN surveys s ON s.id=r.survey_id
		JOIN job_containers jc ON jc.id=s.job_container_id
		JOIN customers c ON c.id=r.customer_id
		JOIN surveyor_profiles sp ON sp.id=s.surveyor_id
		LEFT JOIN LATERAL (
		  SELECT reviewer_id FROM survey_approvals sa WHERE sa.survey_id=s.id AND sa.decision='approved' ORDER BY reviewed_at DESC LIMIT 1
		) approver ON true
		LEFT JOIN users u ON u.id=approver.reviewer_id
		WHERE r.qr_token=$1 AND r.validated_publicly=true
	`, token)
}

func (r Repository) createReportTx(ctx context.Context, tx database.Tx, surveyID uuid.UUID, base map[string]any, actor Actor, reportType string) (map[string]any, error) {
	existing, err := scanRow(tx.QueryRow(ctx, `SELECT id, report_no, status FROM reports WHERE survey_id=$1 AND status <> 'void' LIMIT 1`, surveyID), []string{"id", "report_no", "status"})
	if err == nil {
		return existing, nil
	}
	if !errors.Is(err, ErrNotFound) {
		return nil, err
	}
	reportNo, err := r.nextDocNo(ctx, tx, "RPT", "reports")
	if err != nil {
		return nil, err
	}
	reportID := uuid.Nil
	qrToken := uuid.NewString()
	err = tx.QueryRow(ctx, `
		INSERT INTO reports (report_no, report_type, job_order_id, survey_id, customer_id, status, current_version_no, qr_token, generated_by)
		VALUES ($1,$2,$3,$4,$5,'pending_generation',0,$6,$7)
		RETURNING id
	`, reportNo, reportType, parseUUIDString(base["job_order_id"]), surveyID, parseUUIDString(base["customer_id"]), qrToken, actor.UserID).Scan(&reportID)
	if err != nil {
		return nil, err
	}
	versionID := uuid.Nil
	if err := tx.QueryRow(ctx, `INSERT INTO report_versions (report_id,version_no,status,created_by) VALUES ($1,0,'draft',$2) RETURNING id`, reportID, actor.UserID).Scan(&versionID); err != nil {
		return nil, err
	}
	snapshot, _ := json.Marshal(base)
	if _, err := tx.Exec(ctx, `INSERT INTO report_snapshots (report_version_id,snapshot_data) VALUES ($1,$2)`, versionID, string(snapshot)); err != nil {
		return nil, err
	}
	return map[string]any{"id": reportID.String(), "report_no": reportNo, "status": "pending_generation", "qr_token": qrToken}, nil
}
