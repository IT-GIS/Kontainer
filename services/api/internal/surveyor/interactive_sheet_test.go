package surveyor

import "testing"

func TestValidateDimensionProfile(t *testing.T) {
	length, width, depth := 10.0, 20.0, 2.0
	quantity := 1
	tests := []struct {
		name     string
		input    DamageInput
		required bool
		wantErr  bool
	}{
		{name: "optional empty", input: DamageInput{}, required: false},
		{name: "required empty", input: DamageInput{}, required: true, wantErr: true},
		{name: "length width", input: DamageInput{DimensionProfile: "length_width", Length: &length, Width: &width, Unit: "cm"}, required: true},
		{name: "length width missing width", input: DamageInput{DimensionProfile: "length_width", Length: &length, Unit: "cm"}, required: true, wantErr: true},
		{name: "depth only", input: DamageInput{DimensionProfile: "depth_only", Depth: &depth, Unit: "mm"}, required: true},
		{name: "quantity only", input: DamageInput{DimensionProfile: "quantity_only", Quantity: &quantity, QuantityUnit: "pc"}, required: true},
		{name: "none", input: DamageInput{DimensionProfile: "none"}, required: true},
		{name: "manual review", input: DamageInput{DimensionProfile: "manual_review"}, required: true},
	}
	for _, test := range tests {
		t.Run(test.name, func(t *testing.T) {
			err := validateDimensionProfile(test.input, test.required)
			if (err != nil) != test.wantErr {
				t.Fatalf("validateDimensionProfile() error = %v, wantErr %v", err, test.wantErr)
			}
		})
	}
}

func TestValidateLocationSelection(t *testing.T) {
	valid := &LocationSelectionSnapshot{
		ContainerSize: "40", Face: "R", VerticalPosition: "B",
		SectionStart: "1", SectionEnd: "4", TransversePosition: "X",
		ViewDirection: "rear_to_front",
	}
	if err := validateLocationSelection(valid); err != nil {
		t.Fatalf("valid range rejected: %v", err)
	}
	invalidSection := *valid
	invalidSection.SectionEnd = "5"
	invalidSection.SectionStart = "7"
	if err := validateLocationSelection(&invalidSection); err == nil {
		t.Fatal("reversed section range must be rejected")
	}
	invalidSize := *valid
	invalidSize.ContainerSize = "30"
	if err := validateLocationSelection(&invalidSize); err == nil {
		t.Fatal("unsupported container size must be rejected")
	}
}
