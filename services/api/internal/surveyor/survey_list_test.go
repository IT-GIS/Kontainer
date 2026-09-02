package surveyor

import (
	"strings"
	"testing"

	"github.com/google/uuid"
)

func TestAssignedSurveyWhereScopesOwner(t *testing.T) {
	id := uuid.MustParse("11111111-1111-1111-1111-111111111111")
	where, args := assignedSurveyWhere(ListParams{Status: "need_revision", Search: "UAT"}, id)
	for _, fragment := range []string{"s.is_active=1", "s.surveyor_id=$1", "s.status=$2", "s.survey_no LIKE $3"} {
		if !strings.Contains(where, fragment) {
			t.Fatalf("missing %q in %s", fragment, where)
		}
	}
	if len(args) != 3 || args[0] != id {
		t.Fatalf("unexpected args: %#v", args)
	}
}

func TestValidSurveyListStatus(t *testing.T) {
	for _, status := range []string{"", "draft", "need_revision", "submitted", "under_review", "resubmitted", "approved", "rejected", "cancelled", "terminal"} {
		if !validSurveyListStatus(status) {
			t.Fatalf("expected %s valid", status)
		}
	}
	if validSurveyListStatus("paid") {
		t.Fatal("unexpected status accepted")
	}
}

func TestAssignedSurveyWhereSupportsTerminalHistoryFilters(t *testing.T) {
	id := uuid.MustParse("11111111-1111-1111-1111-111111111111")
	where, args := assignedSurveyWhere(ListParams{
		Status: "terminal", Customer: "Nusantara", Container: "MSKU",
		DateFrom: "2026-08-01", DateTo: "2026-08-31",
	}, id)
	for _, fragment := range []string{
		"s.status IN ('approved','rejected','cancelled')",
		"c.customer_name LIKE $2", "jc.container_no LIKE $3",
		">= $4", "<= $5",
	} {
		if !strings.Contains(where, fragment) {
			t.Fatalf("missing %q in %s", fragment, where)
		}
	}
	if len(args) != 5 {
		t.Fatalf("unexpected filter args: %#v", args)
	}
}

func TestValidSurveyHistoryDates(t *testing.T) {
	if !validSurveyHistoryDates("2026-08-01", "2026-08-31") {
		t.Fatal("valid date range rejected")
	}
	if validSurveyHistoryDates("2026-09-01", "2026-08-31") || validSurveyHistoryDates("not-a-date", "") {
		t.Fatal("invalid date range accepted")
	}
}

func TestDamageValidationAcceptsCedexMaterialAndResponsibility(t *testing.T) {
	length, width := 12.0, 6.0
	input := DamageInput{
		CEDEXLocationID: uuid.NewString(), ComponentID: uuid.NewString(),
		DamageID: uuid.NewString(), RepairID: uuid.NewString(), MaterialID: uuid.NewString(), ResponsibilityID: uuid.NewString(),
		Severity: "major", Length: &length, Width: &width, Unit: "cm",
	}
	if err := validateDamageInput(input); err != nil {
		t.Fatalf("expected complete CEDEX damage valid: %v", err)
	}
}

func TestAssignedSubmittedListIncludesActiveReviewStates(t *testing.T) {
	id := uuid.MustParse("11111111-1111-1111-1111-111111111111")
	where, args := assignedSurveyWhere(ListParams{Status: "submitted"}, id)
	if len(args) != 1 || args[0] != id {
		t.Fatalf("unexpected args: %#v", args)
	}
	if !strings.Contains(where, "s.status IN ('submitted','under_review','resubmitted')") {
		t.Fatalf("submitted list must include review states: %s", where)
	}
}

func TestDamageValidationRejectsManualLocationFallback(t *testing.T) {
	input := DamageInput{
		Face: "right", InternalLocation: "bottom-1-4", ManualLocationReason: "temporary",
		ComponentID: uuid.NewString(), DamageID: uuid.NewString(), RepairID: uuid.NewString(),
		Severity: "major",
	}
	err := validateDamageInput(input)
	if err == nil {
		t.Fatal("manual location fallback must not bypass active CEDEX Location Code")
	}
	validation, ok := err.(SurveyValidationError)
	if !ok || len(validation.Warnings) == 0 || validation.Warnings[0].Code != "DAMAGE_LOCATION_REQUIRED" {
		t.Fatalf("unexpected validation error: %#v", err)
	}
}

func TestSubmitValidationRequiresConfiguredPhotoCategory(t *testing.T) {
	repo := Repository{}
	survey := map[string]any{
		"required_photo_categories": []map[string]any{{
			"code": "general_container", "name": "General Container", "applies_to": "inspection",
		}},
		"photos": []map[string]any{},
	}
	if !hasWarningCode(repo.validateSurvey(survey), "PHOTO_CATEGORY_REQUIRED") {
		t.Fatal("configured required photo category must block submit")
	}
	survey["photos"] = []map[string]any{{"photo_category": "general_container"}}
	if hasWarningCode(repo.validateSurvey(survey), "PHOTO_CATEGORY_REQUIRED") {
		t.Fatal("matching photo category must satisfy submit validation")
	}
}

func TestSubmitValidationLinksFailedChecklistToFinding(t *testing.T) {
	repo := Repository{}
	survey := map[string]any{
		"checklist": []map[string]any{{
			"id": "check-1", "item_label": "Right Side Bottom", "value": "no",
		}},
		"damages": []map[string]any{},
	}
	if !hasWarningCode(repo.validateSurvey(survey), "CHECKLIST_FINDING_REQUIRED") {
		t.Fatal("failed checklist item without finding must block submit")
	}
	survey["damages"] = []map[string]any{{
		"id": "damage-1", "damage_no": "D-001", "checklist_response_id": "check-1",
		"component_code": "PAA", "damage_code": "DT", "internal_location": "RB1N", "repair_code": "RP",
	}}
	if hasWarningCode(repo.validateSurvey(survey), "CHECKLIST_FINDING_REQUIRED") {
		t.Fatal("linked finding must satisfy failed checklist validation")
	}
}

func TestFindingPhotoRequirementIsScopedPerDamage(t *testing.T) {
	repo := Repository{}
	survey := map[string]any{
		"required_photo_categories": []map[string]any{{
			"code": "damage_finding", "name": "Damage Finding", "applies_to": "finding",
		}},
		"damages": []map[string]any{{"id": "damage-1", "damage_no": "D-001"}},
		"photos":  []map[string]any{{"damage_id": "damage-2", "photo_category": "damage_finding"}},
	}
	if !hasWarningCode(repo.validateSurvey(survey), "DAMAGE_PHOTO_CATEGORY_REQUIRED") {
		t.Fatal("photo from another finding must not satisfy a per-finding requirement")
	}
}

func TestSubmitValidationIgnoresUnrelatedPhotoScope(t *testing.T) {
	repo := Repository{}
	survey := map[string]any{
		"required_photo_categories": []map[string]any{{
			"code": "report_only", "name": "Report Only", "applies_to": "report",
		}},
		"photos": []map[string]any{},
	}
	warnings := repo.validateSurvey(survey)
	if hasWarningCode(warnings, "PHOTO_CATEGORY_REQUIRED") || hasWarningCode(warnings, "DAMAGE_PHOTO_CATEGORY_REQUIRED") {
		t.Fatalf("unrelated scope must not be treated as general or finding: %#v", warnings)
	}
}

func TestSubmitValidationRequiresCanonicalConditionAndCleanliness(t *testing.T) {
	repo := Repository{}
	survey := map[string]any{
		"customer_name": "PT Example", "container_no": "MSKU1234567",
		"survey_type_name": "Container Fitness", "location_name": "Jakarta",
		"container_type_id": uuid.NewString(), "container_size": "20", "started_at": "2026-09-02T08:00:00Z",
		"general_info": map[string]any{
			"cargo_status": "empty", "general_condition": "DMG", "cleanliness": "DTY",
		},
		"checklist": []map[string]any{{"item_key": "identity", "is_required": false}},
	}
	warnings := repo.validateSurvey(survey)
	if hasWarningCode(warnings, "SURVEY_CONDITION_REQUIRED") || hasWarningCode(warnings, "CLEANLINESS_REQUIRED") {
		t.Fatalf("canonical Survey Sheet values must pass: %#v", warnings)
	}

	survey["general_info"] = map[string]any{
		"cargo_status": "empty", "general_condition": "damage", "cleanliness": "dirty",
	}
	warnings = repo.validateSurvey(survey)
	if !hasWarningCode(warnings, "SURVEY_CONDITION_REQUIRED") || !hasWarningCode(warnings, "CLEANLINESS_REQUIRED") {
		t.Fatalf("legacy/general values must not satisfy canonical Survey Sheet fields: %#v", warnings)
	}
}

func hasWarningCode(warnings []ValidationWarning, code string) bool {
	for _, warning := range warnings {
		if warning.Code == code {
			return true
		}
	}
	return false
}
