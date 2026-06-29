package surveyor

import (
	"errors"
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
	Page    int
	PerPage int
	Search  string
	Status  string
	Date    string
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
	TotalJobs    int `json:"total_jobs"`
	NotStarted   int `json:"not_started"`
	Draft        int `json:"draft"`
	Submitted    int `json:"submitted"`
	NeedRevision int `json:"need_revision"`
	Approved     int `json:"approved"`
}

type StartSurveyInput struct {
	JobContainerID string `json:"job_container_id"`
}

type GeneralInfoInput struct {
	SurveyDateTime   string   `json:"survey_date_time"`
	CargoStatus      string   `json:"cargo_status"`
	SealNo           string   `json:"seal_no"`
	TruckNo          string   `json:"truck_no"`
	DriverName       string   `json:"driver_name"`
	ChassisNo        string   `json:"chassis_no"`
	CSCPlateStatus   string   `json:"csc_plate_status"`
	DoorStatus       string   `json:"door_status"`
	GeneralCondition string   `json:"general_condition"`
	Weather          string   `json:"weather"`
	GPSLatitude      *float64 `json:"gps_latitude"`
	GPSLongitude     *float64 `json:"gps_longitude"`
	GeneralRemark    string   `json:"general_remark"`
}

type ChecklistInput struct {
	Items []ChecklistItemInput `json:"items"`
}

type ChecklistItemInput struct {
	ItemKey string `json:"item_key"`
	Value   string `json:"value"`
	Note    string `json:"note"`
}

type DamageInput struct {
	Face                string   `json:"face"`
	InternalLocation    string   `json:"internal_location"`
	CEDEXLocationID     string   `json:"cedex_location_id"`
	CEDEXLocationCode   string   `json:"cedex_location_code"`
	ComponentID         string   `json:"component_code_id"`
	DamageID            string   `json:"damage_code_id"`
	RepairID            string   `json:"repair_code_id"`
	MaterialID          string   `json:"material_code_id"`
	ResponsibilityID    string   `json:"responsibility_code_id"`
	Severity            string   `json:"severity"`
	Quantity            *int     `json:"quantity"`
	Length              *float64 `json:"length"`
	Width               *float64 `json:"width"`
	Depth               *float64 `json:"depth"`
	Unit                string   `json:"unit"`
	IsRepairRequired    bool     `json:"is_repair_required"`
	IsCargoWorthyImpact bool     `json:"is_cargo_worthy_impact"`
	IsPhotoOnly         bool     `json:"is_photo_only"`
	Remark              string   `json:"remark"`
}

type SubmitInput struct {
	FinalRemark string `json:"final_remark"`
}

type PhotoInput struct {
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
