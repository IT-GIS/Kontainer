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

func TestValidateChecklistTemplateAllowsDraftStatus(t *testing.T) {
	payload := normalizePayload(Resources["fitness_checklist_templates"], map[string]any{
		"template_code": "CHK-001", "template_name": "Checklist Baru", "status": "draft",
	})
	if err := validatePayload(Resources["fitness_checklist_templates"], payload, true); err != nil {
		t.Fatalf("expected draft checklist template status to be valid, got %v", err)
	}
}

func TestCompanyProfileUsesIsActiveAsStatusFilter(t *testing.T) {
	where, args := buildWhere(Resources["company_profiles"], ListParams{Status: "inactive"})
	if where != "WHERE is_active = $1" {
		t.Fatalf("expected is_active status filter, got %q", where)
	}
	if len(args) != 1 || args[0] != false {
		t.Fatalf("expected inactive status to map to false, got %#v", args)
	}
}
func TestValidateChecklistTemplateItemResponseType(t *testing.T) {
	payload := normalizePayload(Resources["fitness_checklist_template_items"], map[string]any{
		"template_id": "00000000-0000-0000-0000-000000000111", "item_code": "ITM-001", "item_label": "Periksa corner post", "response_type": "bad_choice",
	})
	if err := validatePayload(Resources["fitness_checklist_template_items"], payload, true); err == nil {
		t.Fatal("expected invalid response_type to fail")
	}

	payload["response_type"] = "ok_not_ok"
	if err := validatePayload(Resources["fitness_checklist_template_items"], payload, true); err != nil {
		t.Fatalf("expected valid checklist item payload, got %v", err)
	}
}

func TestChecklistTemplateItemBuildWhereIncludesTemplateFilter(t *testing.T) {
	where, args := buildWhere(Resources["fitness_checklist_template_items"], ListParams{
		Status:  "active",
		Filters: map[string]string{"template_id": "00000000-0000-0000-0000-000000000111"},
	})
	if where == "" || len(args) != 2 {
		t.Fatalf("expected status and template_id filters, got where=%q args=%#v", where, args)
	}
}

func TestValidateRequiredUpdateRejectsEmptyValue(t *testing.T) {
	payload := normalizePayload(Resources["customers"], map[string]any{"customer_name": ""})
	if err := validatePayload(Resources["customers"], payload, false); err == nil {
		t.Fatal("expected empty required update value to fail")
	}
}

func TestNormalizeOptionalEmptyValueToNil(t *testing.T) {
	payload := normalizePayload(Resources["customers"], map[string]any{"billing_address": ""})
	if value, ok := payload["billing_address"]; !ok || value != nil {
		t.Fatalf("expected optional empty billing_address to normalize to nil, got %#v", payload)
	}
}

func TestValidateUnknownFieldRejected(t *testing.T) {
	if err := validateKnownFields(Resources["customers"], map[string]any{"customer_code": "C-1", "bad_field": "x"}); err == nil {
		t.Fatal("expected unknown field to fail")
	}
}

func TestValidateURLField(t *testing.T) {
	payload := normalizePayload(Resources["container_manufacturers"], map[string]any{"manufacturer_code": "MFG-001", "manufacturer_name": "Maker", "website": "not-url"})
	if err := validatePayload(Resources["container_manufacturers"], payload, true); err == nil {
		t.Fatal("expected invalid website to fail")
	}
	payload["website"] = "https://example.com"
	if err := validatePayload(Resources["container_manufacturers"], payload, true); err != nil {
		t.Fatalf("expected valid website, got %v", err)
	}
}

func TestValidateNumericMinMax(t *testing.T) {
	payload := normalizePayload(Resources["locations"], map[string]any{"location_code": "LOC-1", "location_name": "Yard", "location_type": "yard", "gps_latitude": -91})
	if err := validatePayload(Resources["locations"], payload, true); err == nil {
		t.Fatal("expected latitude outside range to fail")
	}
}

func TestValidateForeignKeyUUID(t *testing.T) {
	payload := normalizePayload(Resources["structural_components"], map[string]any{"code": "C-1", "component_name": "Corner", "inspection_area_id": "not-uuid"})
	if err := validatePayload(Resources["structural_components"], payload, true); err == nil {
		t.Fatal("expected invalid UUID relation to fail")
	}
}

func TestFitnessAdminResourceDoesNotSoftDelete(t *testing.T) {
	resource := fitnessAdminResource(Resources["customers"])
	if resource.SoftDelete {
		t.Fatal("expected fitness admin resource to deactivate by status without deleted_at")
	}
	where, args := buildWhere(resource, ListParams{Status: "inactive"})
	if where != "WHERE status = $1" || len(args) != 1 || args[0] != "inactive" {
		t.Fatalf("expected inactive filter without deleted_at clause, got where=%q args=%#v", where, args)
	}
}

func TestReactivatePayloadAccepted(t *testing.T) {
	payload := normalizePayload(Resources["customers"], map[string]any{"status": "active"})
	if err := validatePayload(Resources["customers"], payload, false); err != nil {
		t.Fatalf("expected status active update to be valid, got %v", err)
	}
}

func TestForeignKeyDBErrorDetection(t *testing.T) {
	err := errString("Cannot add or update a child row: a foreign key constraint fails")
	if !isForeignKeyDBError(err) {
		t.Fatal("expected foreign key DB error to be detected")
	}
}

type errString string

func (e errString) Error() string { return string(e) }
