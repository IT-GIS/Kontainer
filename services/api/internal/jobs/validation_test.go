package jobs

import (
	"bytes"
	"errors"
	"strings"
	"testing"
)

func TestValidateContainerNumber(t *testing.T) {
	result := ValidateContainerNumber("MSKU1234565")
	if !result.IsFormatValid || !result.IsCheckDigitValid || result.CheckDigitStatus != "valid" {
		t.Fatalf("expected valid container number, got %+v", result)
	}
}

func TestValidateContainerNumberInvalid(t *testing.T) {
	result := ValidateContainerNumber("MSKU1234560")
	if !result.IsFormatValid || result.IsCheckDigitValid || result.CheckDigitStatus != "invalid" {
		t.Fatalf("expected invalid check digit, got %+v", result)
	}
}

func TestParseImportCSV(t *testing.T) {
	rows, err := ParseImport(strings.NewReader("container_no,container_type_code,iso_type_code,seal_no,cargo_status,truck_no,driver_name,remark\nMSKU1234567,20GP,22G1,ABC,empty,B123,Driver,OK"))
	if err != nil {
		t.Fatal(err)
	}
	if len(rows) != 1 || rows[0].ContainerNo != "MSKU1234567" || rows[0].ContainerTypeCode != "20GP" {
		t.Fatalf("unexpected rows: %+v", rows)
	}
}

func TestBuildAndParseImportXLSXTemplate(t *testing.T) {
	body, contentType, filename, err := BuildImportTemplate("xlsx")
	if err != nil {
		t.Fatal(err)
	}
	if len(body) == 0 || filename != "container-import-template.xlsx" || !strings.Contains(contentType, "spreadsheetml") {
		t.Fatalf("unexpected template metadata: %s %s (%d bytes)", filename, contentType, len(body))
	}
	rows, err := ParseImportFile(bytes.NewReader(body), filename)
	if err != nil {
		t.Fatal(err)
	}
	if len(rows) != 1 || rows[0].GrossWeight == nil || *rows[0].GrossWeight != 30480 || rows[0].ManufactureDate == nil || *rows[0].ManufactureDate != "2020-01-01" {
		t.Fatalf("unexpected XLSX rows: %+v", rows)
	}
}

func TestValidateContainerInputRequiresOverrideReason(t *testing.T) {
	input := ContainerInput{ContainerNo: "MSKU1234560", CargoStatus: "empty"}
	if !errors.Is(validateContainerInput(input), ErrInvalidInput) {
		t.Fatal("expected invalid check digit without override reason to fail")
	}
	input.CheckDigitOverrideReason = "Verified against physical container"
	if err := validateContainerInput(input); err != nil {
		t.Fatalf("expected override reason to allow invalid check digit: %v", err)
	}
}

func TestValidateContainerInputRejectsNegativeWeightAndInvalidDate(t *testing.T) {
	negative := -1.0
	if err := validateContainerInput(ContainerInput{ContainerNo: "MSKU1234565", GrossWeight: &negative}); !errors.Is(err, ErrInvalidInput) {
		t.Fatal("expected negative gross weight to fail")
	}
	invalidDate := "2026-02-31"
	if err := validateContainerInput(ContainerInput{ContainerNo: "MSKU1234565", ManufactureDate: &invalidDate}); !errors.Is(err, ErrInvalidInput) {
		t.Fatal("expected invalid manufacture date to fail")
	}
}

func TestValidateAssignInputDateOrder(t *testing.T) {
	start := "2026-07-10"
	due := "2026-07-09"
	input := AssignInput{SurveyorID: "00000000-0000-0000-0000-000000000001", ContainerIDs: []string{"00000000-0000-0000-0000-000000000002"}, StartDate: &start, DueDate: &due}
	if !errors.Is(validateAssignInput(input), ErrInvalidInput) {
		t.Fatal("expected due date before start date to fail")
	}
	due = "2026-07-11"
	if err := validateAssignInput(input); err != nil {
		t.Fatalf("expected valid assignment period: %v", err)
	}
}
