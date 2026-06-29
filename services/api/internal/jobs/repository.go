package jobs

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

func (r Repository) ListJobs(ctx context.Context, params ListParams) (ListResult, error) {
	where, args := jobWhere(params)
	total, err := r.count(ctx, "job_orders jo", where, args)
	if err != nil {
		return ListResult{}, err
	}
	page, perPage := normalizePagination(params.Page, params.PerPage)
	args = append(args, perPage, (page-1)*perPage)
	query := fmt.Sprintf(`
		SELECT jo.id, jo.job_order_no, jo.job_date, jo.priority, jo.status,
		       jo.created_at, c.id AS customer_id, c.customer_name,
		       st.id AS survey_type_id, st.name AS survey_type_name,
		       l.id AS location_id, l.location_name,
		       COUNT(jc.id) AS total_containers
		FROM job_orders jo
		JOIN customers c ON c.id = jo.customer_id
		JOIN survey_types st ON st.id = jo.survey_type_id
		JOIN locations l ON l.id = jo.location_id
		LEFT JOIN job_containers jc ON jc.job_order_id = jo.id AND jc.deleted_at IS NULL
		%s
		GROUP BY jo.id, c.id, st.id, l.id
		ORDER BY jo.job_date DESC, jo.created_at DESC
		LIMIT $%d OFFSET $%d
	`, where, len(args)-1, len(args))
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
	return ListResult{Rows: items, Meta: PaginationMeta{Page: page, PerPage: perPage, Total: total, TotalPages: totalPages, HasNext: page < totalPages, HasPrev: page > 1}}, nil
}

func (r Repository) CreateJob(ctx context.Context, input JobInput, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	jobNo, err := r.nextDocNo(ctx, tx, "JO", "job_orders")
	if err != nil {
		return nil, err
	}
	jobDate, err := parseDate(input.JobDate)
	if err != nil {
		return nil, ErrInvalidInput
	}
	customerID, err := uuid.Parse(input.CustomerID)
	if err != nil {
		return nil, ErrInvalidInput
	}
	surveyTypeID, err := uuid.Parse(input.SurveyTypeID)
	if err != nil {
		return nil, ErrInvalidInput
	}
	locationID, err := uuid.Parse(input.LocationID)
	if err != nil {
		return nil, ErrInvalidInput
	}
	deadline, err := parseOptionalTime(input.Deadline)
	if err != nil {
		return nil, ErrInvalidInput
	}
	priority := normalizePriority(input.Priority)
	row := tx.QueryRow(ctx, `
		INSERT INTO job_orders (
			job_order_no, job_date, customer_id, survey_type_id, location_id,
			pic_customer_name, pic_customer_phone, pic_customer_email, reference_no, booking_no,
			do_no, bl_no, vessel, voyage, trucking_company, priority, deadline, instruction,
			created_by, updated_by
		) VALUES ($1,$2,$3,$4,$5,NULLIF($6,''),NULLIF($7,''),NULLIF($8,''),NULLIF($9,''),NULLIF($10,''),NULLIF($11,''),NULLIF($12,''),NULLIF($13,''),NULLIF($14,''),NULLIF($15,''),$16,$17,NULLIF($18,''),$19,$19)
		RETURNING id, job_order_no, status
	`, jobNo, jobDate, customerID, surveyTypeID, locationID, input.PICCustomerName, input.PICCustomerPhone, input.PICCustomerEmail, input.ReferenceNo, input.BookingNo, input.DONo, input.BLNo, input.Vessel, input.Voyage, input.TruckingCompany, priority, deadline, input.Instruction, actor.UserID)
	item, err := scanRow(row, []string{"id", "job_order_no", "status"})
	if err != nil {
		return nil, err
	}
	jobID, _ := uuid.Parse(fmt.Sprint(item["id"]))
	if err := r.insertJobEvent(ctx, tx, jobID, "job_created", "Job order dibuat.", "Job order "+jobNo+" dibuat.", actor.UserID, item); err != nil {
		return nil, err
	}
	if err := r.insertAudit(ctx, tx, actor, "jobs.create", "jobs", &jobID, nil, item); err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return item, nil
}

func (r Repository) GetJob(ctx context.Context, id uuid.UUID) (map[string]any, error) {
	job, err := r.queryOne(ctx, `
		SELECT jo.*, jo.id AS id_text, jo.customer_id AS customer_id_text, jo.survey_type_id AS survey_type_id_text, jo.location_id AS location_id_text,
		       c.customer_name, st.name AS survey_type_name, l.location_name
		FROM job_orders jo
		JOIN customers c ON c.id = jo.customer_id
		JOIN survey_types st ON st.id = jo.survey_type_id
		JOIN locations l ON l.id = jo.location_id
		WHERE jo.id = $1 AND jo.deleted_at IS NULL
		LIMIT 1
	`, id)
	if err != nil {
		return nil, err
	}
	containers, _ := r.ListContainers(ctx, id, ListParams{Page: 1, PerPage: 200})
	assignments, _ := r.ListAssignments(ctx, id)
	timeline, _ := r.Timeline(ctx, id)
	job["id"] = job["id_text"]
	job["customer"] = map[string]any{"id": job["customer_id_text"], "customer_name": job["customer_name"]}
	job["survey_type"] = map[string]any{"id": job["survey_type_id_text"], "name": job["survey_type_name"]}
	job["location"] = map[string]any{"id": job["location_id_text"], "location_name": job["location_name"]}
	job["containers"] = containers.Rows
	job["assignments"] = assignments
	job["timeline"] = timeline
	return job, nil
}

func (r Repository) UpdateJob(ctx context.Context, id uuid.UUID, input JobInput, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	oldValue, err := r.getJobForUpdate(ctx, tx, id)
	if err != nil {
		return nil, err
	}
	status := fmt.Sprint(oldValue["status"])
	if status != "draft" && status != "assigned" {
		return nil, ErrInvalidStatus
	}
	jobDate, err := parseDate(input.JobDate)
	if err != nil {
		return nil, ErrInvalidInput
	}
	customerID, err := uuid.Parse(input.CustomerID)
	if err != nil {
		return nil, ErrInvalidInput
	}
	surveyTypeID, err := uuid.Parse(input.SurveyTypeID)
	if err != nil {
		return nil, ErrInvalidInput
	}
	locationID, err := uuid.Parse(input.LocationID)
	if err != nil {
		return nil, ErrInvalidInput
	}
	deadline, err := parseOptionalTime(input.Deadline)
	if err != nil {
		return nil, ErrInvalidInput
	}
	item, err := scanRow(tx.QueryRow(ctx, `
		UPDATE job_orders SET job_date=$2, customer_id=$3, survey_type_id=$4, location_id=$5,
		pic_customer_name=NULLIF($6,''), pic_customer_phone=NULLIF($7,''), pic_customer_email=NULLIF($8,''), reference_no=NULLIF($9,''), booking_no=NULLIF($10,''),
		do_no=NULLIF($11,''), bl_no=NULLIF($12,''), vessel=NULLIF($13,''), voyage=NULLIF($14,''), trucking_company=NULLIF($15,''), priority=$16, deadline=$17, instruction=NULLIF($18,''), updated_by=$19, updated_at=now()
		WHERE id=$1 AND deleted_at IS NULL RETURNING id, job_order_no, status
	`, id, jobDate, customerID, surveyTypeID, locationID, input.PICCustomerName, input.PICCustomerPhone, input.PICCustomerEmail, input.ReferenceNo, input.BookingNo, input.DONo, input.BLNo, input.Vessel, input.Voyage, input.TruckingCompany, normalizePriority(input.Priority), deadline, input.Instruction, actor.UserID), []string{"id", "job_order_no", "status"})
	if err != nil {
		return nil, err
	}
	if err := r.insertJobEvent(ctx, tx, id, "job_updated", "Job order diperbarui.", "Job order diperbarui.", actor.UserID, item); err != nil {
		return nil, err
	}
	if err := r.insertAudit(ctx, tx, actor, "jobs.update", "jobs", &id, oldValue, item); err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return item, nil
}

func (r Repository) CancelJob(ctx context.Context, id uuid.UUID, reason string, actor Actor) (map[string]any, error) {
	if strings.TrimSpace(reason) == "" {
		return nil, ErrInvalidInput
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	oldValue, err := r.getJobForUpdate(ctx, tx, id)
	if err != nil {
		return nil, err
	}
	status := fmt.Sprint(oldValue["status"])
	if status == "closed" || status == "paid" || status == "cancelled" {
		return nil, ErrInvalidStatus
	}
	item, err := scanRow(tx.QueryRow(ctx, `
		UPDATE job_orders SET status='cancelled', cancel_reason=$2, cancelled_at=now(), cancelled_by=$3, updated_by=$3, updated_at=now()
		WHERE id=$1 RETURNING id, job_order_no, status, cancel_reason
	`, id, reason, actor.UserID), []string{"id", "job_order_no", "status", "cancel_reason"})
	if err != nil {
		return nil, err
	}
	_, _ = tx.Exec(ctx, `UPDATE job_containers SET status='cancelled', updated_at=now() WHERE job_order_id=$1 AND status IN ('not_started','assigned','draft') AND deleted_at IS NULL`, id)
	if err := r.insertJobEvent(ctx, tx, id, "job_cancelled", "Job order dibatalkan.", reason, actor.UserID, item); err != nil {
		return nil, err
	}
	if err := r.insertAudit(ctx, tx, actor, "jobs.cancel", "jobs", &id, oldValue, item); err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return item, nil
}

func (r Repository) ListContainers(ctx context.Context, jobID uuid.UUID, params ListParams) (ListResult, error) {
	page, perPage := normalizePagination(params.Page, params.PerPage)
	where := "WHERE jc.job_order_id=$1 AND jc.deleted_at IS NULL"
	args := []any{jobID}
	if params.Status != "" {
		args = append(args, params.Status)
		where += fmt.Sprintf(" AND jc.status=$%d", len(args))
	}
	total, err := r.count(ctx, "job_containers jc", where, args)
	if err != nil {
		return ListResult{}, err
	}
	args = append(args, perPage, (page-1)*perPage)
	rows, err := r.pool.Query(ctx, fmt.Sprintf(`
		SELECT jc.id, jc.container_no, jc.check_digit_status, jc.iso_type_code, jc.seal_no, jc.cargo_status, jc.truck_no, jc.driver_name, jc.status,
		       ct.id AS container_type_id, ct.code AS container_type_code
		FROM job_containers jc
		LEFT JOIN container_types ct ON ct.id = jc.container_type_id
		%s ORDER BY jc.created_at ASC LIMIT $%d OFFSET $%d
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

func (r Repository) AddContainer(ctx context.Context, jobID uuid.UUID, input ContainerInput, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	if _, err := r.getJobForUpdate(ctx, tx, jobID); err != nil {
		return nil, err
	}
	item, err := r.addContainerTx(ctx, tx, jobID, input)
	if err != nil {
		return nil, err
	}
	containerID, _ := uuid.Parse(fmt.Sprint(item["id"]))
	if err := r.insertJobEvent(ctx, tx, jobID, "container_added", "Container ditambahkan.", fmt.Sprint(item["container_no"]), actor.UserID, item); err != nil {
		return nil, err
	}
	if err := r.insertAudit(ctx, tx, actor, "job_containers.create", "job_containers", &containerID, nil, item); err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return item, nil
}

func (r Repository) ImportContainers(ctx context.Context, jobID uuid.UUID, inputs []ContainerInput, actor Actor) (ImportResult, error) {
	result := ImportResult{TotalRows: len(inputs), Errors: []map[string]any{}, StartedAt: time.Now().UTC()}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return result, err
	}
	defer tx.Rollback(ctx)
	if _, err := r.getJobForUpdate(ctx, tx, jobID); err != nil {
		return result, err
	}
	for index, input := range inputs {
		item, err := r.addContainerTx(ctx, tx, jobID, input)
		if err != nil {
			result.Failed++
			result.Errors = append(result.Errors, map[string]any{"row": index + 1, "field": "container_no", "message": err.Error()})
			continue
		}
		result.Imported++
		containerID, _ := uuid.Parse(fmt.Sprint(item["id"]))
		_ = r.insertAudit(ctx, tx, actor, "job_containers.import", "job_containers", &containerID, nil, item)
	}
	status := "processed"
	if result.Failed > 0 && result.Imported > 0 {
		status = "partial"
	}
	if result.Failed > 0 && result.Imported == 0 {
		status = "failed"
	}
	errorJSON, _ := json.Marshal(result.Errors)
	_, err = tx.Exec(ctx, `INSERT INTO container_import_batches (job_order_id,total_rows,success_rows,failed_rows,status,error_summary,imported_by) VALUES ($1,$2,$3,$4,$5,$6,$7)`, jobID, result.TotalRows, result.Imported, result.Failed, status, string(errorJSON), actor.UserID)
	if err != nil {
		return result, err
	}
	_ = r.insertJobEvent(ctx, tx, jobID, "containers_imported", "Container diimport.", fmt.Sprintf("%d berhasil, %d gagal", result.Imported, result.Failed), actor.UserID, result)
	if err := tx.Commit(ctx); err != nil {
		return result, err
	}
	return result, nil
}

func (r Repository) Assign(ctx context.Context, jobID uuid.UUID, input AssignInput, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	if _, err := r.getJobForUpdate(ctx, tx, jobID); err != nil {
		return nil, err
	}
	surveyorID, err := uuid.Parse(input.SurveyorID)
	if err != nil {
		return nil, ErrInvalidInput
	}
	containerIDs, err := parseUUIDs(input.ContainerIDs)
	if err != nil || len(containerIDs) == 0 {
		return nil, ErrInvalidInput
	}
	assignmentNo, err := r.nextDocNo(ctx, tx, "ASG", "assignments")
	if err != nil {
		return nil, err
	}
	startDate, err := parseOptionalTime(input.StartDate)
	if err != nil {
		return nil, ErrInvalidInput
	}
	dueDate, err := parseOptionalTime(input.DueDate)
	if err != nil {
		return nil, ErrInvalidInput
	}
	assignmentID := uuid.Nil
	err = tx.QueryRow(ctx, `INSERT INTO assignments (assignment_no,job_order_id,surveyor_id,assigned_by,start_date,due_date,instruction) VALUES ($1,$2,$3,$4,$5,$6,NULLIF($7,'')) RETURNING id`, assignmentNo, jobID, surveyorID, actor.UserID, startDate, dueDate, input.Instruction).Scan(&assignmentID)
	if err != nil {
		return nil, err
	}
	for _, containerID := range containerIDs {
		if _, err := tx.Exec(ctx, `INSERT INTO assignment_containers (assignment_id,job_container_id) VALUES ($1,$2)`, assignmentID, containerID); err != nil {
			return nil, ErrDuplicate
		}
		if _, err := tx.Exec(ctx, `UPDATE job_containers SET status='assigned', updated_at=now() WHERE id=$1 AND job_order_id=$2 AND status IN ('not_started','assigned') AND deleted_at IS NULL`, containerID, jobID); err != nil {
			return nil, err
		}
	}
	_, _ = tx.Exec(ctx, `UPDATE job_orders SET status='assigned', updated_by=$2, updated_at=now() WHERE id=$1 AND status='draft'`, jobID, actor.UserID)
	item := map[string]any{"id": assignmentID.String(), "assignment_no": assignmentNo, "status": "assigned", "assigned_containers": len(containerIDs)}
	_ = r.insertJobEvent(ctx, tx, jobID, "surveyor_assigned", "Surveyor ditugaskan.", fmt.Sprintf("%d container ditugaskan", len(containerIDs)), actor.UserID, item)
	_ = r.insertAudit(ctx, tx, actor, "assignments.assign", "assignments", &assignmentID, nil, item)
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return item, nil
}

func (r Repository) Reassign(ctx context.Context, containerID uuid.UUID, input ReassignInput, actor Actor) (map[string]any, error) {
	if strings.TrimSpace(input.Reason) == "" {
		return nil, ErrInvalidInput
	}
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	container, err := scanRow(tx.QueryRow(ctx, `SELECT id, job_order_id, status FROM job_containers WHERE id=$1 AND deleted_at IS NULL FOR UPDATE`, containerID), []string{"id", "job_order_id", "status"})
	if err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	if fmt.Sprint(container["status"]) == "approved" || fmt.Sprint(container["status"]) == "reported" {
		return nil, ErrInvalidStatus
	}
	jobID, _ := uuid.Parse(fmt.Sprint(container["job_order_id"]))
	toSurveyorID, err := uuid.Parse(input.ToSurveyorID)
	if err != nil {
		return nil, ErrInvalidInput
	}
	_, _ = tx.Exec(ctx, `UPDATE assignment_containers SET unassigned_at=now(), unassigned_reason=$2 WHERE job_container_id=$1 AND unassigned_at IS NULL`, containerID, input.Reason)
	assignmentNo, err := r.nextDocNo(ctx, tx, "ASG", "assignments")
	if err != nil {
		return nil, err
	}
	assignmentID := uuid.Nil
	if err := tx.QueryRow(ctx, `INSERT INTO assignments (assignment_no,job_order_id,surveyor_id,assigned_by,instruction) VALUES ($1,$2,$3,$4,$5) RETURNING id`, assignmentNo, jobID, toSurveyorID, actor.UserID, input.Reason).Scan(&assignmentID); err != nil {
		return nil, err
	}
	if _, err := tx.Exec(ctx, `INSERT INTO assignment_containers (assignment_id,job_container_id) VALUES ($1,$2)`, assignmentID, containerID); err != nil {
		return nil, err
	}
	item := map[string]any{"assignment_no": assignmentNo, "status": "assigned", "container_id": containerID.String()}
	_ = r.insertJobEvent(ctx, tx, jobID, "container_reassigned", "Container dialihkan.", input.Reason, actor.UserID, item)
	_ = r.insertAudit(ctx, tx, actor, "job_containers.reassign", "job_containers", &containerID, container, item)
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return item, nil
}

func (r Repository) ListAssignments(ctx context.Context, jobID uuid.UUID) ([]map[string]any, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT a.id, a.assignment_no, sp.id AS surveyor_id, sp.full_name AS surveyor_name, a.status, a.assigned_at,
		       COUNT(ac.id) AS total_containers
		FROM assignments a
		JOIN surveyor_profiles sp ON sp.id = a.surveyor_id
		LEFT JOIN assignment_containers ac ON ac.assignment_id = a.id AND ac.unassigned_at IS NULL
		WHERE a.job_order_id=$1
		GROUP BY a.id, sp.id
		ORDER BY a.assigned_at DESC
	`, jobID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return rowsToMaps(rows)
}

func (r Repository) Timeline(ctx context.Context, jobID uuid.UUID) ([]map[string]any, error) {
	rows, err := r.pool.Query(ctx, `SELECT je.id, je.event_type AS event, je.event_title, je.event_description AS description, u.name AS actor, je.created_at FROM job_events je LEFT JOIN users u ON u.id=je.actor_id WHERE je.job_order_id=$1 ORDER BY je.created_at DESC`, jobID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return rowsToMaps(rows)
}

func (r Repository) addContainerTx(ctx context.Context, tx database.Tx, jobID uuid.UUID, input ContainerInput) (map[string]any, error) {
	validation := ValidateContainerNumber(input.ContainerNo)
	if !validation.IsFormatValid {
		return nil, ErrInvalidInput
	}
	checkStatus := validation.CheckDigitStatus
	if checkStatus == "invalid" && strings.TrimSpace(input.CheckDigitOverrideReason) != "" {
		checkStatus = "override"
	}
	containerTypeID, err := r.resolveContainerType(ctx, tx, input)
	if err != nil {
		return nil, err
	}
	manufactureDate, err := parseOptionalDate(input.ManufactureDate)
	if err != nil {
		return nil, ErrInvalidInput
	}
	cargoStatus := input.CargoStatus
	if cargoStatus == "" {
		cargoStatus = "unknown"
	}
	item, err := scanRow(tx.QueryRow(ctx, `
		INSERT INTO job_containers (job_order_id,container_no,owner_code,serial_number,check_digit,check_digit_status,check_digit_override_reason,container_type_id,iso_type_code,seal_no,cargo_status,gross_weight,tare_weight,payload,manufacture_date,csc_plate_status,truck_no,driver_name,remark)
		VALUES ($1,$2,$3,$4,$5,$6,NULLIF($7,''),$8,NULLIF($9,''),NULLIF($10,''),$11,$12,$13,$14,$15,NULLIF($16,''),NULLIF($17,''),NULLIF($18,''),NULLIF($19,''))
		RETURNING id, container_no, check_digit_status, status
	`, jobID, validation.ContainerNo, validation.OwnerCode+validation.EquipmentIdentifier, validation.SerialNumber, validation.CheckDigit, checkStatus, input.CheckDigitOverrideReason, containerTypeID, input.ISOTypeCode, input.SealNo, cargoStatus, input.GrossWeight, input.TareWeight, input.Payload, manufactureDate, input.CSCPlateStatus, input.TruckNo, input.DriverName, input.Remark), []string{"id", "container_no", "check_digit_status", "status"})
	if err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "duplicate") {
			return nil, ErrDuplicate
		}
		return nil, err
	}
	return item, nil
}

func (r Repository) resolveContainerType(ctx context.Context, tx database.Tx, input ContainerInput) (*uuid.UUID, error) {
	if input.ContainerTypeID != nil && strings.TrimSpace(*input.ContainerTypeID) != "" {
		parsed, err := uuid.Parse(*input.ContainerTypeID)
		if err != nil {
			return nil, ErrInvalidInput
		}
		return &parsed, nil
	}
	if strings.TrimSpace(input.ContainerTypeCode) == "" {
		return nil, nil
	}
	var id uuid.UUID
	if err := tx.QueryRow(ctx, `SELECT id FROM container_types WHERE LOWER(code)=LOWER($1) LIMIT 1`, input.ContainerTypeCode).Scan(&id); err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return nil, ErrInvalidInput
		}
		return nil, err
	}
	return &id, nil
}

func (r Repository) nextDocNo(ctx context.Context, tx database.Tx, code string, table string) (string, error) {
	var total int
	query := fmt.Sprintf("SELECT COUNT(*) FROM %s", table)
	if err := tx.QueryRow(ctx, query).Scan(&total); err != nil {
		return "", err
	}
	return nextNumber(code, total), nil
}

func (r Repository) getJobForUpdate(ctx context.Context, tx database.Tx, id uuid.UUID) (map[string]any, error) {
	item, err := scanRow(tx.QueryRow(ctx, `SELECT id, job_order_no, status FROM job_orders WHERE id=$1 AND deleted_at IS NULL FOR UPDATE`, id), []string{"id", "job_order_no", "status"})
	if err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return item, nil
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

func (r Repository) count(ctx context.Context, from string, where string, args []any) (int, error) {
	var total int
	if err := r.pool.QueryRow(ctx, fmt.Sprintf("SELECT COUNT(*) FROM %s %s", from, where), args...).Scan(&total); err != nil {
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

func jobWhere(params ListParams) (string, []any) {
	clauses := []string{"jo.deleted_at IS NULL"}
	args := []any{}
	if params.Status != "" {
		args = append(args, params.Status)
		clauses = append(clauses, fmt.Sprintf("jo.status=$%d", len(args)))
	}
	if params.CustomerID != "" {
		args = append(args, params.CustomerID)
		clauses = append(clauses, fmt.Sprintf("jo.customer_id=$%d", len(args)))
	}
	if params.SurveyTypeID != "" {
		args = append(args, params.SurveyTypeID)
		clauses = append(clauses, fmt.Sprintf("jo.survey_type_id=$%d", len(args)))
	}
	if params.LocationID != "" {
		args = append(args, params.LocationID)
		clauses = append(clauses, fmt.Sprintf("jo.location_id=$%d", len(args)))
	}
	if params.DateFrom != "" {
		args = append(args, params.DateFrom)
		clauses = append(clauses, fmt.Sprintf("jo.job_date >= $%d", len(args)))
	}
	if params.DateTo != "" {
		args = append(args, params.DateTo)
		clauses = append(clauses, fmt.Sprintf("jo.job_date <= $%d", len(args)))
	}
	if strings.TrimSpace(params.Search) != "" {
		args = append(args, "%"+strings.TrimSpace(params.Search)+"%")
		clauses = append(clauses, fmt.Sprintf("(jo.job_order_no LIKE $%d OR jo.reference_no LIKE $%d)", len(args), len(args)))
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

func parseDate(value string) (time.Time, error) {
	return time.Parse("2006-01-02", strings.TrimSpace(value))
}
func parseOptionalDate(value *string) (*time.Time, error) {
	if value == nil || strings.TrimSpace(*value) == "" {
		return nil, nil
	}
	parsed, err := time.Parse("2006-01-02", strings.TrimSpace(*value))
	return &parsed, err
}
func parseOptionalTime(value *string) (*time.Time, error) {
	if value == nil || strings.TrimSpace(*value) == "" {
		return nil, nil
	}
	parsed, err := time.Parse(time.RFC3339, strings.TrimSpace(*value))
	return &parsed, err
}
func normalizePriority(value string) string {
	if value == "urgent" {
		return "urgent"
	}
	return "normal"
}
func parseUUIDs(values []string) ([]uuid.UUID, error) {
	result := []uuid.UUID{}
	for _, value := range values {
		parsed, err := uuid.Parse(value)
		if err != nil {
			return nil, err
		}
		result = append(result, parsed)
	}
	return result, nil
}
