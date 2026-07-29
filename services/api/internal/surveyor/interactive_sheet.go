package surveyor

import (
	"container-survey/services/api/internal/database"
	"context"
	"encoding/json"
	"errors"
	"strings"

	"github.com/google/uuid"
)

var dimensionProfiles = map[string]struct{}{
	"length_width":       {},
	"length_width_depth": {},
	"depth_only":         {},
	"quantity_only":      {},
	"linear_length":      {},
	"area":               {},
	"none":               {},
	"manual_review":      {},
}

func validateDimensionProfile(input DamageInput, required bool) error {
	profile := strings.ToLower(strings.TrimSpace(input.DimensionProfile))
	if profile == "" {
		if required {
			return validationError("DAMAGE_DIMENSION_PROFILE_REQUIRED", "Dimension Profile wajib dipilih untuk Damage ini.")
		}
		if (input.Length != nil || input.Width != nil || input.Depth != nil) && strings.TrimSpace(input.Unit) == "" {
			return validationError("DAMAGE_DIMENSION_UNIT_REQUIRED", "Dimension Unit wajib saat pengukuran dimensi diisi.")
		}
		return nil
	}
	if _, ok := dimensionProfiles[profile]; !ok {
		return validationError("DAMAGE_DIMENSION_PROFILE_INVALID", "Dimension Profile tidak valid.")
	}
	requireLength := profile == "length_width" || profile == "length_width_depth" || profile == "linear_length" || profile == "area"
	requireWidth := profile == "length_width" || profile == "length_width_depth" || profile == "area"
	requireDepth := profile == "length_width_depth" || profile == "depth_only"
	if requireLength && input.Length == nil {
		return validationError("DAMAGE_LENGTH_REQUIRED", "Length wajib untuk Dimension Profile yang dipilih.")
	}
	if requireWidth && input.Width == nil {
		return validationError("DAMAGE_WIDTH_REQUIRED", "Width wajib untuk Dimension Profile yang dipilih.")
	}
	if requireDepth && input.Depth == nil {
		return validationError("DAMAGE_DEPTH_REQUIRED", "Depth wajib untuk Dimension Profile yang dipilih.")
	}
	if profile == "quantity_only" && (input.Quantity == nil || strings.TrimSpace(input.QuantityUnit) == "") {
		return validationError("DAMAGE_QUANTITY_REQUIRED", "Quantity dan Quantity Unit wajib untuk Dimension Profile Quantity saja.")
	}
	if (input.Length != nil || input.Width != nil || input.Depth != nil) && strings.TrimSpace(input.Unit) == "" {
		return validationError("DAMAGE_DIMENSION_UNIT_REQUIRED", "Dimension Unit wajib saat pengukuran dimensi diisi.")
	}
	return nil
}

func validateLocationSelection(selection *LocationSelectionSnapshot) error {
	if selection == nil {
		return nil
	}
	selection.ContainerSize = strings.TrimSpace(selection.ContainerSize)
	selection.Face = strings.ToUpper(strings.TrimSpace(selection.Face))
	selection.VerticalPosition = strings.ToUpper(strings.TrimSpace(selection.VerticalPosition))
	selection.SectionStart = strings.ToUpper(strings.TrimSpace(selection.SectionStart))
	selection.SectionEnd = strings.ToUpper(strings.TrimSpace(selection.SectionEnd))
	selection.TransversePosition = strings.ToUpper(strings.TrimSpace(selection.TransversePosition))
	selection.ViewDirection = strings.ToLower(strings.TrimSpace(selection.ViewDirection))
	if !oneOfString(selection.ContainerSize, "20", "40", "45") ||
		!oneOfString(selection.Face, "D", "L", "R", "F", "U", "T", "B") ||
		!oneOfString(selection.VerticalPosition, "G", "B", "T", "H", "X") ||
		!oneOfString(selection.TransversePosition, "L", "R", "X") ||
		selection.ViewDirection != "rear_to_front" {
		return validationError("LOCATION_SELECTION_INVALID", "Snapshot pilihan lokasi Survey Sheet tidak valid.")
	}
	sections := "12345"
	if selection.ContainerSize == "40" || selection.ContainerSize == "45" {
		sections = "1234567890"
	}
	if len(selection.SectionStart) != 1 || len(selection.SectionEnd) != 1 {
		return validationError("LOCATION_SELECTION_SECTION_INVALID", "Rentang section tidak sesuai ukuran peti kemas.")
	}
	start := strings.Index(sections, selection.SectionStart)
	end := strings.Index(sections, selection.SectionEnd)
	if start < 0 || end < start {
		return validationError("LOCATION_SELECTION_SECTION_INVALID", "Rentang section tidak sesuai ukuran peti kemas.")
	}
	return nil
}

func (r Repository) validateSelectionMappingTx(
	ctx context.Context,
	tx database.Tx,
	customerID uuid.UUID,
	locationID *uuid.UUID,
	selection *LocationSelectionSnapshot,
) error {
	if selection == nil {
		return nil
	}
	if locationID == nil {
		return validationError("LOCATION_SELECTION_UNMAPPED", "Area Survey Sheet belum memiliki mapping CEDEX aktif.")
	}
	span := "N"
	end := ""
	if selection.SectionStart != selection.SectionEnd {
		span = "RANGE"
		end = selection.SectionEnd
	}
	var matched int
	err := tx.QueryRow(ctx, `
		SELECT COUNT(*)
		FROM cedex_locations
		WHERE id=$1 AND status='active' AND input_mode='structured'
		  AND (customer_id=$2 OR customer_id IS NULL)
		  AND UPPER(COALESCE(sector_code,''))=$3
		  AND UPPER(COALESCE(vertical_code,''))=$4
		  AND UPPER(COALESCE(start_section,''))=$5
		  AND (($7='RANGE' AND UPPER(COALESCE(end_section,''))=$6)
		    OR ($7='N' AND UPPER(COALESCE(end_section,'')) IN ('',$5)))
		  AND UPPER(COALESCE(transverse_span,''))=$7
		  AND container_size=$8
		  AND LOWER(COALESCE(face,''))=$9
	`, *locationID, customerID, selection.Face, selection.VerticalPosition, selection.SectionStart, end, span, selection.ContainerSize, faceName(selection.Face)).Scan(&matched)
	if err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return validationError("LOCATION_SELECTION_MAPPING_MISMATCH", "Mapping Location Code tidak sesuai snapshot pilihan Survey Sheet.")
		}
		return err
	}
	if matched != 1 {
		return validationError("LOCATION_SELECTION_MAPPING_MISMATCH", "Mapping Location Code tidak sesuai snapshot pilihan Survey Sheet.")
	}
	return nil
}

func faceName(code string) string {
	return map[string]string{
		"R": "right", "L": "left", "T": "roof", "B": "floor",
		"U": "understructure", "D": "door", "F": "front",
	}[code]
}

func locationSelectionJSON(selection *LocationSelectionSnapshot) (string, error) {
	if selection == nil {
		return "", nil
	}
	payload, err := json.Marshal(selection)
	if err != nil {
		return "", err
	}
	return string(payload), nil
}

func oneOfString(value string, allowed ...string) bool {
	for _, item := range allowed {
		if value == item {
			return true
		}
	}
	return false
}
