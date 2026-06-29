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
	JobDate          string  `json:"job_date"`
	CustomerID       string  `json:"customer_id"`
	SurveyTypeID     string  `json:"survey_type_id"`
	LocationID       string  `json:"location_id"`
	PICCustomerName  string  `json:"pic_customer_name"`
	PICCustomerPhone string  `json:"pic_customer_phone"`
	PICCustomerEmail string  `json:"pic_customer_email"`
	ReferenceNo      string  `json:"reference_no"`
	BookingNo        string  `json:"booking_no"`
	DONo             string  `json:"do_no"`
	BLNo             string  `json:"bl_no"`
	Vessel           string  `json:"vessel"`
	Voyage           string  `json:"voyage"`
	TruckingCompany  string  `json:"trucking_company"`
	Priority         string  `json:"priority"`
	Deadline         *string `json:"deadline"`
	Instruction      string  `json:"instruction"`
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
	ContainerNo         string `json:"container_no"`
	IsFormatValid       bool   `json:"is_format_valid"`
	IsCheckDigitValid   bool   `json:"is_check_digit_valid"`
	OwnerCode           string `json:"owner_code"`
	EquipmentIdentifier string `json:"equipment_identifier"`
	SerialNumber        string `json:"serial_number"`
	CheckDigit          string `json:"check_digit"`
	CheckDigitStatus    string `json:"check_digit_status"`
}

type ImportResult struct {
	TotalRows int              `json:"total_rows"`
	Imported  int              `json:"imported"`
	Failed    int              `json:"failed"`
	Errors    []map[string]any `json:"errors"`
	Rows      []ContainerInput `json:"-"`
	StartedAt time.Time        `json:"-"`
}
