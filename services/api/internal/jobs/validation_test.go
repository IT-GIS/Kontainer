package jobs

import "strings"
import "testing"

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
