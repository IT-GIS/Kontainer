package surveyor

import (
	"context"
	"fmt"
	"strconv"
	"strings"

	"container-survey/services/api/internal/database"

	"github.com/google/uuid"
)

func (r Repository) buildFindingDescriptionTx(
	ctx context.Context,
	tx database.Tx,
	locationID *uuid.UUID,
	componentID uuid.UUID,
	damageID uuid.UUID,
	materialID *uuid.UUID,
	actionID *uuid.UUID,
	face string,
	internalLocation string,
	input DamageInput,
	evaluation DamageDecisionEvaluation,
) (string, error) {
	var locationDescription, componentName, damageName, materialName, actionName string
	err := tx.QueryRow(ctx, `
		SELECT COALESCE(location.description,''), component.component_name, damage.damage_name,
		       COALESCE(material.material_name,''), COALESCE(action.repair_name,'')
		FROM cedex_components component
		JOIN cedex_damages damage ON damage.id=$2
		LEFT JOIN cedex_materials material ON material.id=$3
		LEFT JOIN cedex_repairs action ON action.id=$4
		LEFT JOIN cedex_locations location ON location.id=$5
		WHERE component.id=$1
	`, componentID, damageID, materialID, actionID, locationID).Scan(&locationDescription, &componentName, &damageName, &materialName, &actionName)
	if err != nil {
		return "", err
	}

	unit := strings.TrimSpace(input.Unit)
	dimensions := []string{}
	appendMeasurement := func(label string, value *float64) {
		if value != nil {
			dimensions = append(dimensions, label+" "+formatMeasurement(*value)+" "+unit)
		}
	}
	appendMeasurement("panjang", input.Length)
	appendMeasurement("lebar", input.Width)
	appendMeasurement("kedalaman", input.Depth)
	if input.Quantity != nil {
		quantityUnit := strings.TrimSpace(input.QuantityUnit)
		if quantityUnit == "" {
			quantityUnit = "pc"
		}
		dimensions = append(dimensions, "jumlah "+strconv.Itoa(*input.Quantity)+" "+quantityUnit)
	}

	locationLabel := strings.TrimSpace(strings.Join([]string{face, internalLocation}, " "))
	if strings.TrimSpace(locationDescription) != "" {
		locationLabel = strings.TrimSpace(internalLocation + " - " + locationDescription)
	}
	parts := []string{fmt.Sprintf("Ditemukan %s pada %s di %s.", damageName, componentName, locationLabel)}
	if len(dimensions) > 0 {
		parts = append(parts, "Ukuran: "+strings.Join(dimensions, ", ")+".")
	}
	if materialName != "" {
		parts = append(parts, "Material: "+materialName+".")
	}
	if evaluation.InspectionReferenceName != "" || evaluation.InspectionStandardReference != "" {
		reference := strings.TrimSpace(strings.Join([]string{evaluation.InspectionReferenceCode, evaluation.InspectionReferenceName}, " - "))
		reference = strings.Trim(reference, " -")
		if evaluation.InspectionStandardReference != "" {
			reference += " (" + evaluation.InspectionStandardReference
			if evaluation.InspectionReferenceClause != "" {
				reference += ", " + evaluation.InspectionReferenceClause
			}
			reference += ")"
		}
		parts = append(parts, "Referensi: "+reference+".")
	}
	if evaluation.Tolerance != "" {
		parts = append(parts, "Tolerance: "+evaluation.Tolerance+".")
	}
	if evaluation.DecisionResult != "" {
		parts = append(parts, "Hasil evaluasi: "+decisionResultLabel(evaluation.DecisionResult)+".")
	}
	if actionName != "" {
		parts = append(parts, "Rekomendasi: "+actionName+".")
	}
	if evaluation.DecisionReason != "" {
		parts = append(parts, "Alasan keputusan: "+evaluation.DecisionReason)
	}
	return strings.Join(parts, "\n\n"), nil
}

func formatMeasurement(value float64) string {
	return strconv.FormatFloat(value, 'f', -1, 64)
}

func decisionResultLabel(value string) string {
	labels := map[string]string{
		"passed":            "Passed",
		"need_repair":       "Need Repair",
		"need_reinspection": "Need Reinspection",
		"not_passed":        "Not Passed",
		"manual_review":     "Manual Review",
	}
	if label := labels[value]; label != "" {
		return label
	}
	return value
}
