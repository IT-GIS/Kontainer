package surveyor

import "testing"

func TestDecisionRuleMatches(t *testing.T) {
	depth := 8.0
	input := DamageInput{Depth: &depth, Unit: "mm"}
	rule := map[string]any{
		"measurement_field":   "depth",
		"comparison_operator": "gt",
		"minimum_value":       5.0,
		"unit":                "mm",
	}
	matched, measured := decisionRuleMatches(rule, input)
	if !matched || measured == nil || *measured != 8 {
		t.Fatalf("expected depth rule to match, matched=%v measured=%v", matched, measured)
	}
}

func TestDecisionRuleConvertsLengthUnit(t *testing.T) {
	depth := 0.8
	input := DamageInput{Depth: &depth, Unit: "cm"}
	rule := map[string]any{
		"measurement_field":   "depth",
		"comparison_operator": "gte",
		"minimum_value":       8.0,
		"unit":                "mm",
	}
	matched, measured := decisionRuleMatches(rule, input)
	if !matched || measured == nil || *measured != 8 {
		t.Fatalf("expected 0.8 cm to equal 8 mm, matched=%v measured=%v", matched, measured)
	}
}

func TestToleranceLabel(t *testing.T) {
	minimum, maximum := 2.0, 8.0
	if got := toleranceLabel("between", &minimum, &maximum, "mm"); got != "2 – 8 mm" {
		t.Fatalf("unexpected label %q", got)
	}
}
