package jobs

import (
	"context"
	"fmt"
	"strings"

	"container-survey/services/api/internal/database"
	"container-survey/services/api/internal/masterdata"
	"github.com/google/uuid"
)

type inspectionReadinessFacts struct {
	JobID              string
	ContainerID        string
	ContainerNo        string
	JobValid           bool
	LocationValid      bool
	SurveyTypeValid    bool
	ContainerTypeValid bool
	ContainerSize      string
	CheckDigitStatus   string
	CheckDigitOverride string
	CSCPlateStatus     string
	CSCPlateNumber     string
	ManufactureDate    string
	GrossWeight        any
	TareWeight         any
	Payload            any
	ManufacturerName   string
	MaintenanceScheme  string
}

func (r Repository) InspectionReadiness(ctx context.Context, jobID uuid.UUID) (JobInspectionReadiness, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return JobInspectionReadiness{}, err
	}
	defer tx.Rollback(ctx)
	return r.inspectionReadinessTx(ctx, tx, jobID)
}

func (r Repository) inspectionReadinessTx(ctx context.Context, tx database.Tx, jobID uuid.UUID) (JobInspectionReadiness, error) {
	var customerID, surveyTypeID uuid.UUID
	var jobValid, locationValid, surveyTypeValid bool
	err := tx.QueryRow(ctx, `
		SELECT jo.customer_id, jo.survey_type_id,
		       (jo.deleted_at IS NULL AND jo.status <> 'cancelled'
		        AND jo.approval_category_id IS NOT NULL AND category.status='active' AND category.is_mvp_active=1
		        AND jo.owner_id IS NOT NULL AND owner.status='active' AND owner.deleted_at IS NULL
		        AND NULLIF(TRIM(jo.applicant_owner_relationship),'') IS NOT NULL),
		       (location.id IS NOT NULL AND location.customer_id=jo.customer_id AND location.status='active'),
		       (survey_type.id IS NOT NULL AND survey_type.customer_id=jo.customer_id AND survey_type.status='active')
		FROM job_orders jo
		LEFT JOIN fitness_approval_categories category ON category.id=jo.approval_category_id
		LEFT JOIN customers owner ON owner.id=jo.owner_id
		LEFT JOIN locations location ON location.id=jo.location_id
		LEFT JOIN survey_types survey_type ON survey_type.id=jo.survey_type_id
		WHERE jo.id=$1
	`, jobID).Scan(&customerID, &surveyTypeID, &jobValid, &locationValid, &surveyTypeValid)
	if err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "no rows") {
			return JobInspectionReadiness{}, ErrNotFound
		}
		return JobInspectionReadiness{}, err
	}
	customerGate, err := masterdata.EvaluateReadinessTx(ctx, tx, customerID, surveyTypeID)
	if err != nil {
		return JobInspectionReadiness{}, err
	}

	rows, err := tx.Query(ctx, `
		SELECT jc.id, jc.container_no, jc.check_digit_status, COALESCE(jc.check_digit_override_reason,''),
		       (ct.id IS NOT NULL AND ct.status='active'), COALESCE(ct.size,''),
		       COALESCE(jc.csc_plate_status,''), COALESCE(jc.csc_plate_number,''),
		       COALESCE(DATE_FORMAT(jc.manufacture_date,'%Y-%m-%d'),''),
		       jc.gross_weight, jc.tare_weight, jc.payload,
		       COALESCE(manufacturer.manufacturer_name,''), COALESCE(maintenance.name,'')
		FROM job_containers jc
		LEFT JOIN container_types ct ON ct.id=jc.container_type_id
		LEFT JOIN container_technical_specs specs ON specs.job_container_id=jc.id
		LEFT JOIN container_manufacturers manufacturer ON manufacturer.id=specs.manufacturer_id
		LEFT JOIN maintenance_schemes maintenance ON maintenance.id=specs.maintenance_scheme_id
		WHERE jc.job_order_id=$1 AND jc.deleted_at IS NULL AND jc.status <> 'cancelled'
		ORDER BY jc.created_at
	`, jobID)
	if err != nil {
		return JobInspectionReadiness{}, err
	}
	defer rows.Close()

	result := JobInspectionReadiness{JobID: jobID.String(), OverallReady: true, Containers: []InspectionReadiness{}}
	for rows.Next() {
		var facts inspectionReadinessFacts
		facts.JobID = jobID.String()
		facts.JobValid = jobValid
		facts.LocationValid = locationValid
		facts.SurveyTypeValid = surveyTypeValid
		if err := rows.Scan(
			&facts.ContainerID, &facts.ContainerNo, &facts.CheckDigitStatus, &facts.CheckDigitOverride,
			&facts.ContainerTypeValid, &facts.ContainerSize, &facts.CSCPlateStatus, &facts.CSCPlateNumber,
			&facts.ManufactureDate, &facts.GrossWeight, &facts.TareWeight, &facts.Payload,
			&facts.ManufacturerName, &facts.MaintenanceScheme,
		); err != nil {
			return JobInspectionReadiness{}, err
		}
		readiness := buildInspectionReadiness(facts, customerGate)
		if len(readiness.Blockers) == 0 {
			result.ReadyCount++
		} else {
			result.OverallReady = false
		}
		result.Containers = append(result.Containers, readiness)
	}
	if err := rows.Err(); err != nil {
		return JobInspectionReadiness{}, err
	}
	result.Total = len(result.Containers)
	if result.Total == 0 {
		result.OverallReady = false
	}
	return result, nil
}

func buildInspectionReadiness(facts inspectionReadinessFacts, customerGate masterdata.ReadinessGate) InspectionReadiness {
	result := InspectionReadiness{
		JobID: facts.JobID, ContainerID: facts.ContainerID, ContainerNo: facts.ContainerNo,
		Blockers: []InspectionReadinessCheck{}, Warnings: []InspectionReadinessCheck{},
	}
	block := func(ready bool, code, label string) {
		if !ready {
			result.Blockers = append(result.Blockers, InspectionReadinessCheck{Code: code, Label: label, Ready: false})
		}
	}
	warn := func(ready bool, code, label string) {
		if !ready {
			result.Warnings = append(result.Warnings, InspectionReadinessCheck{Code: code, Label: label, Ready: false})
		}
	}
	block(facts.JobValid, "JOB_APPLICATION", "Data Permohonan/Job, kategori persetujuan, dan pemilik wajib valid")
	customerLabel := "Master Data Customer belum siap"
	if len(customerGate.Missing) > 0 {
		labels := make([]string, 0, len(customerGate.Missing))
		for _, missing := range customerGate.Missing {
			labels = append(labels, missing.Label)
		}
		customerLabel += ": " + strings.Join(labels, "; ")
	}
	block(customerGate.Ready(), "CUSTOMER_READINESS", customerLabel)
	block(facts.LocationValid, "INSPECTION_LOCATION", "Location pemeriksaan wajib aktif dan milik Customer Job")
	block(facts.SurveyTypeValid, "SURVEY_TYPE", "Survey Type wajib aktif dan milik Customer Job")
	numberValidation := ValidateContainerNumber(facts.ContainerNo)
	block(numberValidation.IsFormatValid, "CONTAINER_NUMBER", "Nomor peti kemas wajib menggunakan format ISO 6346")
	checkDigitReady := facts.CheckDigitStatus == "valid" || (facts.CheckDigitStatus == "override" && strings.TrimSpace(facts.CheckDigitOverride) != "")
	block(checkDigitReady, "CHECK_DIGIT", "Check digit wajib valid atau memiliki alasan override yang diaudit")
	block(facts.ContainerTypeValid, "CONTAINER_TYPE", "Container Type Customer wajib dipilih")
	block(strings.TrimSpace(facts.ContainerSize) != "", "CONTAINER_SIZE", "Ukuran peti kemas wajib tersedia")

	cscPlateStatus := strings.ToLower(strings.TrimSpace(facts.CSCPlateStatus))
	warn(cscPlateStatus != "" && cscPlateStatus != "not_checked", "CSC_PLATE_STATUS", "Status CSC Plate belum diverifikasi")
	warn(strings.TrimSpace(facts.CSCPlateNumber) != "", "CSC_PLATE_NUMBER", "Nomor CSC Plate belum diisi")
	warn(strings.TrimSpace(facts.ManufactureDate) != "", "MANUFACTURE_DATE", "Tanggal produksi belum diisi")
	warn(facts.GrossWeight != nil, "MAX_GROSS_WEIGHT", "Maximum Operating Gross Mass (CSC) belum diisi")
	warn(facts.TareWeight != nil, "TARE_WEIGHT", "Tare Weight belum diisi")
	warn(facts.Payload != nil, "PAYLOAD", "Payload belum diisi")
	warn(strings.TrimSpace(facts.ManufacturerName) != "", "MANUFACTURER", "Manufacturer belum diisi")
	warn(strings.TrimSpace(facts.MaintenanceScheme) != "", "MAINTENANCE_SCHEME", "Maintenance Scheme belum diisi")

	switch {
	case len(result.Blockers) > 0:
		result.Status = "BLOCKED"
	case len(result.Warnings) > 0:
		result.Status = "READY_WITH_WARNINGS"
	default:
		result.Status = "READY"
	}
	return result
}

func readinessSelectionError(items []InspectionReadiness, selected map[string]bool) error {
	issues := []string{}
	for _, item := range items {
		if !selected[item.ContainerID] || len(item.Blockers) == 0 {
			continue
		}
		labels := make([]string, 0, len(item.Blockers))
		for _, blocker := range item.Blockers {
			labels = append(labels, blocker.Label)
		}
		issues = append(issues, fmt.Sprintf("%s: %s", item.ContainerNo, strings.Join(labels, "; ")))
	}
	if len(issues) == 0 {
		return nil
	}
	return FieldValidationError{Fields: map[string]string{"container_ids": "Inspection Readiness belum terpenuhi - " + strings.Join(issues, " | ")}}
}
