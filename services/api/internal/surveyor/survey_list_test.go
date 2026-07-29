package surveyor

import (
	"strings"
	"testing"

	"github.com/google/uuid"
)

func TestAssignedSurveyWhereScopesOwner(t *testing.T) {
	id := uuid.MustParse("11111111-1111-1111-1111-111111111111")
	where, args := assignedSurveyWhere(ListParams{Status: "need_revision", Search: "UAT"}, id)
	for _, fragment := range []string{"s.surveyor_id=$1", "s.status=$2", "s.survey_no LIKE $3"} {
		if !strings.Contains(where, fragment) {
			t.Fatalf("missing %q in %s", fragment, where)
		}
	}
	if len(args) != 3 || args[0] != id {
		t.Fatalf("unexpected args: %#v", args)
	}
}

func TestValidSurveyListStatus(t *testing.T) {
	for _, status := range []string{"", "draft", "need_revision", "submitted", "approved", "rejected"} {
		if !validSurveyListStatus(status) {
			t.Fatalf("expected %s valid", status)
		}
	}
	if validSurveyListStatus("paid") {
		t.Fatal("unexpected status accepted")
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
