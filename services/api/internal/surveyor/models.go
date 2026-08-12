package surveyor

import (
	"errors"
	"io"
	"time"

	"github.com/google/uuid"
)

var (
	ErrNotFound      = errors.New("survey resource not found")
	ErrInvalidInput  = errors.New("invalid survey input")
	ErrInvalidStatus = errors.New("invalid survey status")
	ErrForbidden     = errors.New("survey access forbidden")
	ErrValidation    = errors.New("survey validation failed")
	ErrDuplicate     = errors.New("duplicate survey resource")
)

type Actor struct {
	UserID     uuid.UUID
	ActiveRole string
	RequestID  string
	IPAddress  string
	UserAgent  string
}

type ListParams struct {
	Page      int
	PerPage   int
	Search    string
	Status    string
	Date      string
	Customer  string
	Container string
	DateFrom  string
	DateTo    string
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

type Dashboard struct {
	TotalJobs          int `json:"total_jobs"`
	TotalAssignments   int `json:"total_assignments"`
	AssignedNotStarted int `json:"assigned_not_started"`
	NotStarted         int `json:"not_started"`
	Draft              int `json:"draft"`
	Submitted          int `json:"submitted"`
	UnderReview        int `json:"under_review"`
	NeedRevision       int `json:"need_revision"`
	Resubmitted        int `json:"resubmitted"`
	Approved           int `json:"approved"`
	Rejected           int `json:"rejected"`
}

type Profile struct {
	ID                    string `json:"id"`
	SurveyorCode          string `json:"surveyor_code"`
	FullName              string `json:"full_name"`
	Phone                 string `json:"phone"`
	Area                  string `json:"area"`
	CertificateNumber     string `json:"certificate_number"`
	CertificateValidUntil any    `json:"certificate_valid_until"`
	Competencies          string `json:"competencies"`
	AssignmentLocations   string `json:"assignment_locations"`
	Status                string `json:"status"`
}

type StartSurveyInput struct {
	JobContainerID string `json:"job_container_id"`
}

type GeneralInfoInput struct {
	SurveyDateTime     string   `json:"survey_date_time"`
	CargoStatus        string   `json:"cargo_status"`
	SealNo             string   `json:"seal_no"`
	TruckNo            string   `json:"truck_no"`
	DriverName         string   `json:"driver_name"`
	ChassisNo          string   `json:"chassis_no"`
	CSCPlateStatus     string   `json:"csc_plate_status"`
	DoorStatus         string   `json:"door_status"`
	GeneralCondition   string   `json:"general_condition"`
	ContainerLifecycle string   `json:"container_lifecycle"`
	Weather            string   `json:"weather"`
	GPSLatitude        *float64 `json:"gps_latitude"`
	GPSLongitude       *float64 `json:"gps_longitude"`
	GeneralRemark      string   `json:"general_remark"`
}

type ChecklistInput struct {
	Items []ChecklistItemInput `json:"items"`
}

type ChecklistItemInput struct {
	ItemKey          string   `json:"item_key"`
	Value            string   `json:"value"`
	NumericValue     *float64 `json:"numeric_value"`
	Note             string   `json:"note"`
	AttachmentFileID string   `json:"attachment_file_id"`
}

type DamageInput struct {
	ChecklistResponseID  string                     `json:"checklist_response_id"`
	Face                 string                     `json:"face"`
	InternalLocation     string                     `json:"internal_location"`
	CEDEXLocationID      string                     `json:"cedex_location_id"`
	CEDEXLocationCode    string                     `json:"cedex_location_code"`
	ManualLocationReason string                     `json:"manual_location_reason"`
	ComponentID          string                     `json:"component_code_id"`
	DamageID             string                     `json:"damage_code_id"`
	RepairID             string                     `json:"repair_code_id"`
	MaterialID           string                     `json:"material_code_id"`
	ResponsibilityID     string                     `json:"responsibility_code_id"`
	Severity             string                     `json:"severity"`
	Quantity             *int                       `json:"quantity"`
	QuantityUnit         string                     `json:"quantity_unit"`
	Length               *float64                   `json:"length"`
	Width                *float64                   `json:"width"`
	Depth                *float64                   `json:"depth"`
	Unit                 string                     `json:"unit"`
	IsRepairRequired     bool                       `json:"is_repair_required"`
	IsCargoWorthyImpact  bool                       `json:"is_cargo_worthy_impact"`
	IsPhotoOnly          bool                       `json:"is_photo_only"`
	Remark               string                     `json:"remark"`
	DimensionProfile     string                     `json:"dimension_profile"`
	LocationSelection    *LocationSelectionSnapshot `json:"location_selection_snapshot"`
}

type LocationSelectionSnapshot struct {
	ContainerSize      string `json:"container_size"`
	Face               string `json:"face"`
	VerticalPosition   string `json:"vertical_position"`
	SectionStart       string `json:"section_start"`
	SectionEnd         string `json:"section_end"`
	TransversePosition string `json:"transverse_position"`
	ViewDirection      string `json:"view_direction"`
}

type CodeProposalInput struct {
	CodeType       string `json:"code_type"`
	Code           string `json:"code"`
	Description    string `json:"description"`
	Reason         string `json:"reason"`
	EvidenceFileID string `json:"evidence_file_id"`
	Notes          string `json:"notes"`
}

type SurveyMasterOptions struct {
	Customer            map[string]any   `json:"customer"`
	SurveyType          map[string]any   `json:"survey_type"`
	ContainerType       map[string]any   `json:"container_type"`
	CEDEXLocations      []map[string]any `json:"cedex_locations"`
	CEDEXComponents     []map[string]any `json:"cedex_components"`
	CEDEXDamages        []map[string]any `json:"cedex_damages"`
	CEDEXRepairs        []map[string]any `json:"cedex_repairs"`
	CEDEXMaterials      []map[string]any `json:"cedex_materials"`
	ResponsibilityCodes []map[string]any `json:"responsibility_codes"`
	FindingSeverities   []map[string]any `json:"finding_severities"`
	TestParameters      []map[string]any `json:"test_parameters"`
	PhotoCategories     []map[string]any `json:"photo_categories"`
}

type SubmitInput struct {
	FinalRemark string `json:"final_remark"`
}

type PhotoInput struct {
	Reader        io.Reader
	FileName      string
	ContentType   string
	Size          int64
	Caption       string
	PhotoType     string
	PhotoCategory string
	TakenAt       *time.Time
}

type ValidationWarning struct {
	Code    string `json:"code"`
	Message string `json:"message"`
}

type SurveyValidationError struct {
	Warnings []ValidationWarning
}

func (e SurveyValidationError) Error() string {
	return "survey validation failed"
}
