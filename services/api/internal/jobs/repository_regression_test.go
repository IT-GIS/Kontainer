package jobs

import (
	"reflect"
	"regexp"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"
)

func TestJobContainerInsertColumnsAndArgumentsStayAligned(t *testing.T) {
	jobID := uuid.New()
	containerTypeID := uuid.New()
	grossWeight := 30480.0
	tareWeight := 2200.0
	payload := 28280.0
	manufactureDate := time.Date(2020, time.January, 1, 0, 0, 0, 0, time.UTC)
	input := ContainerInput{
		ContainerNo: "MSKU1234560", CheckDigitOverrideReason: "Diverifikasi pada peti kemas",
		SealNo: "SEAL-01", CargoStatus: "laden", GrossWeight: &grossWeight,
		TareWeight: &tareWeight, Payload: &payload, CSCPlateStatus: "valid",
		TruckNo: "B 1234 CD", DriverName: "Pengemudi", Remark: "Catatan",
	}
	validation := ValidateContainerNumber(input.ContainerNo)
	containerType := resolvedContainerType{ID: containerTypeID, ISOCode: "22G1"}
	actorID := uuid.New()

	args := jobContainerInsertArgs(jobID, validation, "override", input, containerType, &manufactureDate, nil, nil, input.CargoStatus, actorID)
	wantArgs := []any{
		jobID,
		validation.ContainerNo,
		input.ContainerNo,
		validation.OwnerCode + validation.EquipmentIdentifier,
		validation.SerialNumber,
		validation.CheckDigit,
		validation.CalculatedCheckDigit,
		validation.IsCheckDigitValid,
		"override",
		input.CheckDigitOverrideReason,
		actorID,
		args[11],
		containerTypeID,
		"22G1",
		input.SealNo,
		input.CargoStatus,
		&grossWeight,
		&tareWeight,
		&payload,
		&manufactureDate,
		input.CSCPlateStatus,
		input.CSCPlateNumber,
		input.CSCApprovalReference,
		(*time.Time)(nil),
		(*time.Time)(nil),
		input.CSCProgramType,
		input.TruckNo,
		input.DriverName,
		input.Remark,
	}
	if !reflect.DeepEqual(args, wantArgs) {
		t.Fatalf("job container insert arguments shifted:\n got: %#v\nwant: %#v", args, wantArgs)
	}

	wantColumns := []string{
		"job_order_id", "container_no", "container_number_input", "owner_code", "serial_number", "check_digit",
		"container_check_digit_calculated", "container_check_digit_valid", "check_digit_status",
		"check_digit_override_reason", "check_digit_override_by", "check_digit_override_at",
		"container_type_id", "iso_type_code", "seal_no", "cargo_status", "gross_weight", "tare_weight", "payload",
		"manufacture_date", "csc_plate_status", "csc_plate_number", "csc_approval_reference", "csc_manufacture_date",
		"csc_next_examination_date", "csc_program_type", "truck_no", "driver_name", "remark",
	}
	if got := insertColumnNames(jobContainerInsertQuery); !reflect.DeepEqual(got, wantColumns) {
		t.Fatalf("job container insert columns changed:\n got: %#v\nwant: %#v", got, wantColumns)
	}

	placeholders := regexp.MustCompile(`\$(\d+)`).FindAllStringSubmatch(jobContainerInsertQuery, -1)
	if len(placeholders) != len(args) {
		t.Fatalf("placeholder count %d does not match argument count %d", len(placeholders), len(args))
	}
	for index, placeholder := range placeholders {
		got, err := strconv.Atoi(placeholder[1])
		if err != nil || got != index+1 {
			t.Fatalf("placeholder %q at position %d is not sequential", placeholder[0], index)
		}
	}
}

func insertColumnNames(query string) []string {
	start := strings.Index(query, "(")
	end := strings.Index(query[start+1:], ")")
	if start < 0 || end < 0 {
		return nil
	}
	parts := strings.Split(query[start+1:start+1+end], ",")
	for index := range parts {
		parts[index] = strings.TrimSpace(parts[index])
	}
	return parts
}
