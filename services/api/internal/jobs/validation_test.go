package jobs

import (
	"bytes"
	"errors"
	"strings"
	"testing"

	"container-survey/services/api/internal/masterdata"
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
	input := ContainerInput{ContainerNo: "MSKU1234560", ContainerTypeCode: "20GP", CargoStatus: "empty"}
	if !errors.Is(validateContainerInput(input), ErrInvalidInput) {
		t.Fatal("expected invalid check digit without override reason to fail")
	}
	input.CheckDigitOverrideReason = "Verified against physical container"
	if err := validateContainerInput(input); err != nil {
		t.Fatalf("expected override reason to allow invalid check digit: %v", err)
	}
}

func TestValidateContainerInputAllowsDraftWithoutContainerType(t *testing.T) {
	if err := validateContainerInput(ContainerInput{ContainerNo: "MSKU1234565"}); err != nil {
		t.Fatalf("expected draft with only a valid container number to be accepted: %v", err)
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

func TestInspectionReadinessBlocksMissingTypeAndSize(t *testing.T) {
	result := buildInspectionReadiness(inspectionReadinessFacts{
		JobID: "job", ContainerID: "container", ContainerNo: "MSKU1234565",
		JobValid: true, LocationValid: true, SurveyTypeValid: true, CheckDigitStatus: "valid",
	}, masterdata.ReadinessGate{Status: "READY"})
	if result.Status != "BLOCKED" || !hasReadinessCode(result.Blockers, "CONTAINER_TYPE") || !hasReadinessCode(result.Blockers, "CONTAINER_SIZE") {
		t.Fatalf("expected type and size blockers, got %+v", result)
	}
}

func TestInspectionReadinessAcceptsAuditedCheckDigitOverride(t *testing.T) {
	result := buildInspectionReadiness(inspectionReadinessFacts{
		JobID: "job", ContainerID: "container", ContainerNo: "MSKU1234560",
		JobValid: true, LocationValid: true, SurveyTypeValid: true, ContainerTypeValid: true, ContainerSize: "20",
		CheckDigitStatus: "override", CheckDigitOverride: "Diverifikasi pada fisik peti kemas",
	}, masterdata.ReadinessGate{Status: "READY"})
	if hasReadinessCode(result.Blockers, "CHECK_DIGIT") || result.Status == "BLOCKED" {
		t.Fatalf("expected audited override to pass hard readiness, got %+v", result)
	}
}

func TestInspectionReadinessTreatsNotCheckedCSCAsWarning(t *testing.T) {
	result := buildInspectionReadiness(inspectionReadinessFacts{
		JobID: "job", ContainerID: "container", ContainerNo: "MSKU1234565",
		JobValid: true, LocationValid: true, SurveyTypeValid: true, ContainerTypeValid: true, ContainerSize: "20",
		CheckDigitStatus: "valid", CSCPlateStatus: "not_checked",
	}, masterdata.ReadinessGate{Status: "READY"})
	if result.Status != "READY_WITH_WARNINGS" || !hasReadinessCode(result.Warnings, "CSC_PLATE_STATUS") {
		t.Fatalf("expected not-checked CSC to remain a warning, got %+v", result)
	}
}

func TestReadJobAttachmentValidatesMIMEAndSize(t *testing.T) {
	data, contentType, extension, err := readJobAttachment(strings.NewReader("%PDF-1.4\n1 0 obj\n"), 1024)
	if err != nil || len(data) == 0 || contentType != "application/pdf" || extension != ".pdf" {
		t.Fatalf("expected PDF to pass MIME validation: %s %s %v", contentType, extension, err)
	}
	if _, _, _, err := readJobAttachment(strings.NewReader("plain text"), 1024); err == nil {
		t.Fatal("expected unsupported MIME to fail")
	}
	if _, _, _, err := readJobAttachment(strings.NewReader("%PDF-1.4\n"), 4); err == nil {
		t.Fatal("expected oversized attachment to fail")
	}
	if got := safeAttachmentName("../surat<script>.pdf", ".pdf"); strings.ContainsAny(got, "<>/") {
		t.Fatalf("expected safe file name, got %q", got)
	}
}

func hasReadinessCode(checks []InspectionReadinessCheck, code string) bool {
	for _, check := range checks {
		if check.Code == code {
			return true
		}
	}
	return false
}
