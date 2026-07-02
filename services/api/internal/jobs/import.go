package jobs

import (
	"bytes"
	"context"
	"encoding/csv"
	"encoding/json"
	"io"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/google/uuid"
	"github.com/xuri/excelize/v2"
)

var ImportHeaders = []string{
	"container_no", "container_type_code", "iso_type_code", "seal_no", "cargo_status",
	"gross_weight", "tare_weight", "payload", "manufacture_date", "csc_plate_status",
	"truck_no", "driver_name", "remark", "check_digit_override_reason",
}

func (s *Service) PreviewImport(ctx context.Context, jobID uuid.UUID, reader io.Reader, filename string) (ImportPreview, error) {
	inputs, err := ParseImportFile(reader, filename)
	if err != nil {
		return ImportPreview{}, err
	}
	numbers := make([]string, 0, len(inputs))
	for _, input := range inputs {
		numbers = append(numbers, ValidateContainerNumber(input.ContainerNo).ContainerNo)
	}
	existing, err := s.repo.ExistingContainerNumbers(ctx, jobID, numbers)
	if err != nil {
		return ImportPreview{}, err
	}
	result := ImportPreview{TotalRows: len(inputs), Rows: []ImportPreviewRow{}}
	seen := map[string]bool{}
	for index, input := range inputs {
		validation := ValidateContainerNumber(input.ContainerNo)
		input.ContainerNo = validation.ContainerNo
		row := ImportPreviewRow{Row: index + 2, Data: input, Errors: []string{}}
		if input.ContainerNo == "" {
			row.Errors = append(row.Errors, "container_no wajib diisi")
			result.MissingRequired++
		} else if !validation.IsFormatValid {
			row.Errors = append(row.Errors, "format container_no tidak valid")
		}
		if input.ContainerNo != "" && (seen[input.ContainerNo] || existing[input.ContainerNo]) {
			row.Errors = append(row.Errors, "container duplicate")
			result.DuplicateRows++
		}
		seen[input.ContainerNo] = true
		if validation.IsFormatValid && !validation.IsCheckDigitValid {
			result.InvalidCheckDigit++
			if strings.TrimSpace(input.CheckDigitOverrideReason) == "" {
				row.Errors = append(row.Errors, "check digit tidak valid; override reason wajib")
			}
		}
		if input.CargoStatus != "" && input.CargoStatus != "empty" && input.CargoStatus != "laden" && input.CargoStatus != "unknown" {
			row.Errors = append(row.Errors, "cargo_status tidak valid")
		}
		for _, weight := range []*float64{input.GrossWeight, input.TareWeight, input.Payload} {
			if weight != nil && *weight < 0 {
				row.Errors = append(row.Errors, "weight/payload tidak boleh negatif")
				break
			}
		}
		if _, err := parseOptionalDate(input.ManufactureDate); err != nil {
			row.Errors = append(row.Errors, "manufacture_date tidak valid")
		}
		row.Valid = len(row.Errors) == 0
		if row.Valid {
			result.ValidRows++
		} else {
			result.FailedRows++
		}
		result.Rows = append(result.Rows, row)
	}
	return result, nil
}

func (s *Service) ConfirmImport(ctx context.Context, jobID uuid.UUID, input ImportConfirmInput, actor Actor) (ImportResult, error) {
	if len(input.Rows) == 0 {
		return ImportResult{}, ErrInvalidInput
	}
	for _, row := range input.Rows {
		if err := validateContainerInput(row); err != nil {
			return ImportResult{}, ErrInvalidInput
		}
	}
	return s.repo.ImportContainers(ctx, jobID, input.Rows, actor)
}

func ParseImportFile(reader io.Reader, filename string) ([]ContainerInput, error) {
	if strings.EqualFold(filepath.Ext(filename), ".xlsx") {
		workbook, err := excelize.OpenReader(reader)
		if err != nil {
			return nil, ErrInvalidInput
		}
		defer workbook.Close()
		sheets := workbook.GetSheetList()
		if len(sheets) == 0 {
			return nil, ErrInvalidInput
		}
		records, err := workbook.GetRows(sheets[0])
		if err != nil {
			return nil, ErrInvalidInput
		}
		return parseImportRecords(records)
	}
	return ParseImport(reader)
}

func ParseImport(reader io.Reader) ([]ContainerInput, error) {
	body, err := io.ReadAll(reader)
	if err != nil {
		return nil, err
	}
	trimmed := strings.TrimSpace(string(body))
	if trimmed == "" {
		return nil, ErrInvalidInput
	}
	if strings.HasPrefix(trimmed, "[") {
		var rows []ContainerInput
		if err := json.Unmarshal([]byte(trimmed), &rows); err != nil {
			return nil, ErrInvalidInput
		}
		return rows, nil
	}
	csvReader := csv.NewReader(strings.NewReader(trimmed))
	csvReader.TrimLeadingSpace = true
	records, err := csvReader.ReadAll()
	if err != nil {
		return nil, ErrInvalidInput
	}
	return parseImportRecords(records)
}

func parseImportRecords(records [][]string) ([]ContainerInput, error) {
	if len(records) < 2 {
		return nil, ErrInvalidInput
	}
	headers := map[string]int{}
	for index, header := range records[0] {
		headers[strings.ToLower(strings.TrimSpace(header))] = index
	}
	rows := []ContainerInput{}
	for _, record := range records[1:] {
		get := func(key string) string {
			if index, ok := headers[key]; ok && index < len(record) {
				return strings.TrimSpace(record[index])
			}
			return ""
		}
		gross, err := optionalFloat(get("gross_weight"))
		if err != nil {
			return nil, ErrInvalidInput
		}
		tare, err := optionalFloat(get("tare_weight"))
		if err != nil {
			return nil, ErrInvalidInput
		}
		payload, err := optionalFloat(get("payload"))
		if err != nil {
			return nil, ErrInvalidInput
		}
		manufactureDate := optionalString(get("manufacture_date"))
		rows = append(rows, ContainerInput{
			ContainerNo: get("container_no"), ContainerTypeCode: get("container_type_code"), ISOTypeCode: get("iso_type_code"),
			SealNo: get("seal_no"), CargoStatus: get("cargo_status"), GrossWeight: gross, TareWeight: tare, Payload: payload,
			ManufactureDate: manufactureDate, CSCPlateStatus: get("csc_plate_status"), TruckNo: get("truck_no"),
			DriverName: get("driver_name"), Remark: get("remark"), CheckDigitOverrideReason: get("check_digit_override_reason"),
		})
	}
	if len(rows) == 0 {
		return nil, ErrInvalidInput
	}
	return rows, nil
}

func optionalFloat(value string) (*float64, error) {
	if strings.TrimSpace(value) == "" {
		return nil, nil
	}
	parsed, err := strconv.ParseFloat(strings.TrimSpace(value), 64)
	if err != nil {
		return nil, err
	}
	return &parsed, nil
}

func optionalString(value string) *string {
	if strings.TrimSpace(value) == "" {
		return nil
	}
	value = strings.TrimSpace(value)
	return &value
}

func BuildImportTemplate(format string) ([]byte, string, string, error) {
	sample := []string{"MSKU1234565", "20GP", "22G1", "SEAL001", "empty", "30480", "2200", "28280", "2020-01-01", "valid", "B1234ABC", "Driver Name", "Sample", ""}
	if format == "xlsx" {
		workbook := excelize.NewFile()
		defer workbook.Close()
		sheet := workbook.GetSheetName(0)
		headerValues := make([]any, len(ImportHeaders))
		sampleValues := make([]any, len(sample))
		for i := range ImportHeaders {
			headerValues[i] = ImportHeaders[i]
		}
		for i := range sample {
			sampleValues[i] = sample[i]
		}
		_ = workbook.SetSheetRow(sheet, "A1", &headerValues)
		_ = workbook.SetSheetRow(sheet, "A2", &sampleValues)
		buffer, err := workbook.WriteToBuffer()
		return buffer.Bytes(), "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "container-import-template.xlsx", err
	}
	var buffer bytes.Buffer
	writer := csv.NewWriter(&buffer)
	_ = writer.Write(ImportHeaders)
	_ = writer.Write(sample)
	writer.Flush()
	return buffer.Bytes(), "text/csv; charset=utf-8", "container-import-template.csv", writer.Error()
}
