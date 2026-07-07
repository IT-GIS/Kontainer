package masterdata

import "testing"

func TestValidateCustomerCreateRequiresCodeAndName(t *testing.T) {
	payload := normalizePayload(Resources["customers"], map[string]any{"customer_code": "CUST-001"})
	err := validatePayload(Resources["customers"], payload, true)
	if err == nil {
		t.Fatal("expected validation error for missing customer_name")
	}
}

func TestNormalizeAliasedFields(t *testing.T) {
	payload := normalizePayload(Resources["container_types"], map[string]any{
		"code": "20GP",
		"size": "20 Feet",
		"type": "General Purpose",
	})
	if payload["type_name"] != "General Purpose" {
		t.Fatalf("expected type alias to normalize into type_name, got %#v", payload)
	}
}

func TestValidateCedexLocationFilters(t *testing.T) {
	payload := normalizePayload(Resources["cedex_locations"], map[string]any{
		"code": "L1", "face": "invalid", "grid_code": "L1", "container_size": "all",
	})
	if err := validatePayload(Resources["cedex_locations"], payload, true); err == nil {
		t.Fatal("expected invalid face to fail")
	}

	payload["face"] = "left"
	if err := validatePayload(Resources["cedex_locations"], payload, true); err != nil {
		t.Fatalf("expected valid CEDEX location payload, got %v", err)
	}
}

func TestBuildWhereIncludesSearchStatusAndFilters(t *testing.T) {
	where, args := buildWhere(Resources["cedex_locations"], ListParams{
		Search:  "L1",
		Status:  "active",
		Filters: map[string]string{"face": "left", "container_size": "all"},
	})
	if where == "" || len(args) != 4 {
		t.Fatalf("expected where clause with 4 args, got where=%q args=%#v", where, args)
	}
}

func TestValidateFitnessManufacturerEmail(t *testing.T) {
	payload := normalizePayload(Resources["container_manufacturers"], map[string]any{
		"manufacturer_code": "MFG-001", "manufacturer_name": "Container Maker", "pic_email": "not-email",
	})
	if err := validatePayload(Resources["container_manufacturers"], payload, true); err == nil {
		t.Fatal("expected invalid manufacturer email to fail")
	}
}

func TestValidateFitnessApprovalCategoryLifecycle(t *testing.T) {
	payload := normalizePayload(Resources["fitness_approval_categories"], map[string]any{
		"code": "new_individual", "name": "Peti Kemas Baru Individual", "container_lifecycle": "future",
	})
	if err := validatePayload(Resources["fitness_approval_categories"], payload, true); err == nil {
		t.Fatal("expected invalid approval category lifecycle to fail")
	}

	payload["container_lifecycle"] = "new"
	if err := validatePayload(Resources["fitness_approval_categories"], payload, true); err != nil {
		t.Fatalf("expected valid approval category payload, got %v", err)
	}
}
