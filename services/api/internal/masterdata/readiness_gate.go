package masterdata

import (
	"context"
	"fmt"

	"container-survey/services/api/internal/database"
	"github.com/google/uuid"
)

type ReadinessMissing struct {
	Code  string `json:"code"`
	Label string `json:"label"`
}

type ReadinessGate struct {
	CustomerID string             `json:"customer_id"`
	Status     string             `json:"status"`
	Missing    []ReadinessMissing `json:"missing"`
}

// EvaluateReadinessTx is the backend hard gate used by Job creation,
// assignment, and Survey start. It is intentionally survey-type aware.
func EvaluateReadinessTx(ctx context.Context, tx database.Tx, customerID, surveyTypeID uuid.UUID) (ReadinessGate, error) {
	var profile, personnel, location, locationPICMapping, surveyType, containerType int
	var checklistTemplate, checklistItem, inspectionReference, photoCategory int
	var cedexLocation, cedexComponent, cedexDamage, cedexRepair, cedexMaterial, responsibility int
	var decisionRuleRequired, decisionRule int
	query := fmt.Sprintf(`
		SELECT
		  (SELECT COUNT(*) FROM customers c WHERE c.id=$1 AND c.status='active' AND c.deleted_at IS NULL
		    AND NULLIF(TRIM(c.customer_code),'') IS NOT NULL AND NULLIF(TRIM(c.customer_name),'') IS NOT NULL
		    AND NULLIF(TRIM(c.address),'') IS NOT NULL),
		  (SELECT COUNT(*) FROM customer_personnel p WHERE p.customer_id=$1 AND p.status='active' AND p.deleted_at IS NULL),
		  (SELECT COUNT(*) FROM locations l WHERE l.customer_id=$1 AND l.status='active'),
		  (SELECT COUNT(*) FROM customer_personnel_locations mapping
		    JOIN customer_personnel p ON p.id=mapping.customer_personnel_id
		      AND p.customer_id=$1 AND p.status='active' AND p.deleted_at IS NULL
		    JOIN locations l ON l.id=mapping.location_id AND l.customer_id=$1 AND l.status='active'),
		  (SELECT COUNT(*) FROM survey_types st WHERE st.id=$2 AND st.customer_id=$1 AND st.status='active'),
		  (SELECT COUNT(*) FROM container_types ct WHERE ct.customer_id=$1 AND ct.status='active'),
		  (SELECT COUNT(*) FROM fitness_checklist_templates template
		    WHERE template.customer_id=$1 AND template.survey_type_id=$2 AND template.status='active' AND template.deleted_at IS NULL),
		  (SELECT COUNT(*) FROM fitness_checklist_template_items item
		    JOIN fitness_checklist_templates template ON template.id=item.template_id
		    WHERE template.customer_id=$1 AND template.survey_type_id=$2 AND template.status='active'
		      AND template.deleted_at IS NULL AND item.status='active'),
		  (SELECT COUNT(*) FROM customer_survey_type_test_parameters mapping
		    JOIN inspection_test_parameters reference ON reference.id=mapping.test_parameter_id AND reference.status='active'
		    WHERE mapping.customer_id=$1 AND mapping.survey_type_id=$2 AND mapping.is_active=1),
		  (SELECT COUNT(*) FROM customer_survey_type_photo_categories mapping
		    JOIN evidence_photo_categories category ON category.id=mapping.photo_category_id AND category.status='active'
		    WHERE mapping.customer_id=$1 AND mapping.survey_type_id=$2 AND mapping.is_active=1),
		  %s,
		  %s,
		  %s,
		  %s,
		  %s,
		  %s,
		  %s,
		  (SELECT COUNT(*) FROM cedex_damage_decision_rules rule WHERE %s)
	`,
		effectiveMasterCountSQL("cedex_locations", "x", "$1"),
		effectiveMasterCountSQL("cedex_components", "x", "$1"),
		effectiveMasterCountSQL("cedex_damages", "x", "$1"),
		effectiveMasterCountSQL("cedex_repairs", "x", "$1"),
		effectiveMasterCountSQL("cedex_materials", "x", "$1"),
		effectiveMasterCountSQL("responsibility_codes", "x", "$1"),
		effectiveMasterCountSQL("cedex_damages", "x", "$1", "x.requires_dimension=1"),
		EffectiveDecisionRuleScopeSQL("rule", "$1"),
	)
	err := tx.QueryRow(ctx, query, customerID, surveyTypeID).Scan(
		&profile, &personnel, &location, &locationPICMapping, &surveyType, &containerType,
		&checklistTemplate, &checklistItem, &inspectionReference, &photoCategory,
		&cedexLocation, &cedexComponent, &cedexDamage, &cedexRepair, &cedexMaterial, &responsibility,
		&decisionRuleRequired, &decisionRule,
	)
	if err != nil {
		return ReadinessGate{}, err
	}

	missing := []ReadinessMissing{}
	add := func(count int, code, label string) {
		if count == 0 {
			missing = append(missing, ReadinessMissing{Code: code, Label: label})
		}
	}
	add(profile, "CUSTOMER_PROFILE", "Profil Customer aktif belum lengkap")
	add(personnel, "CUSTOMER_PIC", "Personel/PIC Customer aktif belum tersedia")
	add(location, "INSPECTION_LOCATION", "Location pemeriksaan aktif belum tersedia")
	add(locationPICMapping, "LOCATION_PIC_MAPPING", "Mapping aktif antara Location pemeriksaan dan Personel/PIC belum tersedia")
	add(surveyType, "SURVEY_TYPE", "Survey Type aktif tidak valid untuk Customer")
	add(containerType, "CONTAINER_TYPE", "Container Type aktif belum tersedia")
	add(checklistTemplate, "CHECKLIST_TEMPLATE", "Checklist Template aktif belum tersedia")
	add(checklistItem, "CHECKLIST_ITEM", "Checklist Item aktif belum tersedia")
	add(inspectionReference, "INSPECTION_REFERENCE", "Referensi Pemeriksaan aktif belum dipetakan")
	add(photoCategory, "PHOTO_CATEGORY", "Kategori foto aktif belum dipetakan")
	add(cedexLocation, "CEDEX_LOCATION", "CEDEX Location aktif belum tersedia")
	add(cedexComponent, "CEDEX_COMPONENT", "CEDEX Component aktif belum tersedia")
	add(cedexDamage, "CEDEX_DAMAGE", "CEDEX Damage aktif belum tersedia")
	add(cedexRepair, "CEDEX_ACTION_REPAIR", "CEDEX Action/Repair aktif belum tersedia")
	add(cedexMaterial, "CEDEX_MATERIAL", "CEDEX Material aktif belum tersedia")
	add(responsibility, "RESPONSIBILITY_CODE", "Responsibility Code aktif belum tersedia")
	if decisionRuleRequired > 0 {
		add(decisionRule, "DECISION_RULE", "Decision Rule aktif belum tersedia untuk damage berdimensi")
	}
	status := "READY"
	if profile == 0 || surveyType == 0 {
		status = "BLOCKED"
	} else if len(missing) > 0 {
		status = "INCOMPLETE"
	}
	return ReadinessGate{CustomerID: customerID.String(), Status: status, Missing: missing}, nil
}

func (gate ReadinessGate) Ready() bool { return gate.Status == "READY" && len(gate.Missing) == 0 }
