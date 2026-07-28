package masterdata

import "testing"

func TestValidateDecisionThreshold(t *testing.T) {
	tests := []struct {
		name    string
		payload map[string]any
		wantErr bool
	}{
		{name: "greater than uses minimum", payload: map[string]any{"comparison_operator": "gt", "minimum_value": 8.0}},
		{name: "less than uses maximum", payload: map[string]any{"comparison_operator": "lt", "maximum_value": 5.0}},
		{name: "between valid", payload: map[string]any{"comparison_operator": "between", "minimum_value": 2.0, "maximum_value": 4.0}},
		{name: "manual without numeric tolerance", payload: map[string]any{"comparison_operator": "manual"}},
		{name: "between inverted", payload: map[string]any{"comparison_operator": "between", "minimum_value": 4.0, "maximum_value": 2.0}, wantErr: true},
		{name: "greater than missing minimum", payload: map[string]any{"comparison_operator": "gt"}, wantErr: true},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			err := validateDecisionThreshold(test.payload)
			if (err != nil) != test.wantErr {
				t.Fatalf("validateDecisionThreshold() error = %v, wantErr %v", err, test.wantErr)
			}
		})
	}
}

func TestValidateDateRange(t *testing.T) {
	if err := validateDateRange(map[string]any{"valid_from": "2026-01-01", "valid_until": "2026-12-31"}, "valid_from", "valid_until", "Rule"); err != nil {
		t.Fatalf("expected valid range: %v", err)
	}
	if err := validateDateRange(map[string]any{"valid_from": "2026-12-31", "valid_until": "2026-01-01"}, "valid_from", "valid_until", "Rule"); err == nil {
		t.Fatal("expected inverted range to fail")
	}
}
