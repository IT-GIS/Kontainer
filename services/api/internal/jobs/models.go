package jobs

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

var (
	ErrNotFound       = errors.New("job not found")
	ErrInvalidInput   = errors.New("invalid job input")
	ErrInvalidStatus  = errors.New("invalid job status")
	ErrDuplicate      = errors.New("duplicate resource")
	ErrForbiddenState = errors.New("forbidden state")
)

type FieldValidationError struct {
	Fields map[string]string
}

func (e FieldValidationError) Error() string { return "job field validation failed" }

type Actor struct {
	UserID     uuid.UUID
	ActiveRole string
	RequestID  string
	IPAddress  string
	UserAgent  string
}

type ListParams struct {
	Page         int
	PerPage      int
	Search       string
	Status       string
	CustomerID   string
	SurveyTypeID string
	LocationID   string
	DateFrom     string
	DateTo       string
}

type PaginationMeta struct {
	Page       int  `json:"page"`
	PerPage    int  `json:"per_page"`
	Total      int  `json:"total"`
	TotalPages int  `json:"total_pages"`
	HasNext    bool `json:"has_next"`
	HasPrev    bool `json:"has_prev"`
}

type ListResult struct {
	Rows []map[string]any
	Meta PaginationMeta
}

type JobInput struct {
	JobDate                string  `json:"job_date"`
	CustomerID             string  `json:"customer_id"`
	ApprovalCategoryID     string  `json:"approval_category_id"`
	OwnerID                string  `json:"owner_id"`
	ApplicantOwnerRelation string  `json:"applicant_owner_relationship"`
	ManufacturerID         *string `json:"manufacturer_id"`
	SurveyTypeID           string  `json:"survey_type_id"`
	LocationID             string  `json:"location_id"`
	PICCustomerPersonnelID string  `json:"pic_customer_personnel_id"`
	PICCustomerName        string  `json:"pic_customer_name"`
	PICCustomerPhone       string  `json:"pic_customer_phone"`
	PICCustomerEmail       string  `json:"pic_customer_email"`
	ReferenceNo            string  `json:"reference_no"`
	SPKNo                  string  `json:"spk_no"`
	SPKDate                *string `json:"spk_date"`
	SPKFileID              *string `json:"spk_file_id"`
	SPKNotes               string  `json:"spk_notes"`
	BookingNo              string  `json:"booking_no"`
	DONo                   string  `json:"do_no"`
	BLNo                   string  `json:"bl_no"`
	Vessel                 string  `json:"vessel"`
	Voyage                 string  `json:"voyage"`
	TruckingCompany        string  `json:"trucking_company"`
	Priority               string  `json:"priority"`
	Deadline               *string `json:"deadline"`
	PlannedInspectionDate  *string `json:"planned_inspection_date"`
	Instruction            string  `json:"instruction"`
	SpecialNotes           string  `json:"special_notes"`
}

type ContainerInput struct {
	ContainerNo              string   `json:"container_no"`
	ContainerTypeID          *string  `json:"container_type_id"`
	ContainerTypeCode        string   `json:"container_type_code"`
	ISOTypeCode              string   `json:"iso_type_code"`
	SealNo                   string   `json:"seal_no"`
	CargoStatus              string   `json:"cargo_status"`
	GrossWeight              *float64 `json:"gross_weight"`
	TareWeight               *float64 `json:"tare_weight"`
	Payload                  *float64 `json:"payload"`
	ManufactureDate          *string  `json:"manufacture_date"`
	CSCPlateStatus           string   `json:"csc_plate_status"`
	CSCPlateNumber           string   `json:"csc_plate_number"`
	CSCApprovalReference     string   `json:"csc_approval_reference"`
	CSCManufactureDate       *string  `json:"csc_manufacture_date"`
	CSCNextExaminationDate   *string  `json:"csc_next_examination_date"`
	CSCProgramType           string   `json:"csc_program_type"`
	ManufacturerID           *string  `json:"manufacturer_id"`
	ManufacturerSerialNo     string   `json:"manufacturer_serial_no"`
	TypeModel                string   `json:"type_model"`
	CubeCapacityM3           *float64 `json:"cube_capacity_m3"`
	AllowableStackingWeight  *float64 `json:"allowable_stacking_weight_kg"`
	RackingTestLoad          *float64 `json:"racking_test_load_kg"`
	MaintenanceSchemeID      *string  `json:"maintenance_scheme_id"`
	TruckNo                  string   `json:"truck_no"`
	DriverName               string   `json:"driver_name"`
	Remark                   string   `json:"remark"`
	CheckDigitOverrideReason string   `json:"check_digit_override_reason"`
}

type AssignInput struct {
	SurveyorID   string   `json:"surveyor_id"`
	ContainerIDs []string `json:"container_ids"`
	StartDate    *string  `json:"start_date"`
	DueDate      *string  `json:"due_date"`
	Instruction  string   `json:"instruction"`
}

type ReassignInput struct {
	FromSurveyorID string `json:"from_surveyor_id"`
	ToSurveyorID   string `json:"to_surveyor_id"`
	Reason         string `json:"reason"`
}

type CancelInput struct {
	Reason string `json:"reason"`
}

type ContainerValidation struct {
	ContainerNo          string `json:"container_no"`
	IsFormatValid        bool   `json:"is_format_valid"`
	IsCheckDigitValid    bool   `json:"is_check_digit_valid"`
	OwnerCode            string `json:"owner_code"`
	EquipmentIdentifier  string `json:"equipment_identifier"`
	SerialNumber         string `json:"serial_number"`
	CheckDigit           string `json:"check_digit"`
	CalculatedCheckDigit string `json:"calculated_check_digit"`
	CheckDigitStatus     string `json:"check_digit_status"`
}

type ImportResult struct {
	TotalRows int              `json:"total_rows"`
	Imported  int              `json:"imported"`
	Failed    int              `json:"failed"`
	Errors    []map[string]any `json:"errors"`
	Rows      []ContainerInput `json:"-"`
	StartedAt time.Time        `json:"-"`
}

type ImportPreviewRow struct {
	Row    int            `json:"row"`
	Data   ContainerInput `json:"data"`
	Valid  bool           `json:"valid"`
	Errors []string       `json:"errors"`
}

type ImportPreview struct {
	TotalRows         int                `json:"total_rows"`
	ValidRows         int                `json:"valid_rows"`
	FailedRows        int                `json:"failed_rows"`
	DuplicateRows     int                `json:"duplicate_rows"`
	InvalidCheckDigit int                `json:"invalid_check_digit_rows"`
	MissingRequired   int                `json:"missing_required_rows"`
	Rows              []ImportPreviewRow `json:"rows"`
}

type ImportConfirmInput struct {
	Rows []ContainerInput `json:"rows"`
}

type InspectionReadinessCheck struct {
	Code  string `json:"code"`
	Label string `json:"label"`
	Ready bool   `json:"ready"`
}

type InspectionReadiness struct {
	JobID       string                     `json:"job_id"`
	ContainerID string                     `json:"container_id"`
	ContainerNo string                     `json:"container_no"`
	Status      string                     `json:"status"`
	Blockers    []InspectionReadinessCheck `json:"blockers"`
	Warnings    []InspectionReadinessCheck `json:"warnings"`
}

type JobInspectionReadiness struct {
	JobID        string                `json:"job_id"`
	OverallReady bool                  `json:"overall_ready"`
	ReadyCount   int                   `json:"ready_count"`
	Total        int                   `json:"total"`
	Containers   []InspectionReadiness `json:"containers"`
}
