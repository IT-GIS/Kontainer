package masterdata

import (
	"context"
	"errors"
	"testing"

	"github.com/google/uuid"
)

func mustNormalize(t *testing.T, resource Resource, payload map[string]any, create bool) map[string]any {
	t.Helper()
	normalized, err := normalizePayload(resource, payload, create)
	if err != nil {
		t.Fatalf("normalize payload failed: %v", err)
	}
	return normalized
}

func TestValidateCustomerCreateRequiresCodeAndName(t *testing.T) {
	payload := mustNormalize(t, Resources["customers"], map[string]any{"customer_code": "CUST-001"}, true)
	err := validatePayload(Resources["customers"], payload, true)
	if err == nil {
		t.Fatal("expected validation error for missing customer_name")
	}
}

func TestNormalizeAliasedFields(t *testing.T) {
	payload := mustNormalize(t, Resources["container_types"], map[string]any{
		"code": "20GP",
		"size": "20 Feet",
		"type": "General Purpose",
	}, true)
	if payload["type_name"] != "General Purpose" {
		t.Fatalf("expected type alias to normalize into type_name, got %#v", payload)
	}
}

func TestValidateCedexLocationFilters(t *testing.T) {
	payload := mustNormalize(t, Resources["cedex_locations"], map[string]any{
		"code": "L1", "face": "invalid", "grid_code": "L1", "container_size": "all",
	}, true)
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
	payload := mustNormalize(t, Resources["container_manufacturers"], map[string]any{
		"manufacturer_code": "MFG-001", "manufacturer_name": "Container Maker", "pic_email": "not-email",
	}, true)
	if err := validatePayload(Resources["container_manufacturers"], payload, true); err == nil {
		t.Fatal("expected invalid manufacturer email to fail")
	}
}

func TestValidateFitnessApprovalCategoryLifecycle(t *testing.T) {
	payload := mustNormalize(t, Resources["fitness_approval_categories"], map[string]any{
		"code": "new_individual", "name": "Peti Kemas Baru Individual", "container_lifecycle": "future",
	}, true)
	if err := validatePayload(Resources["fitness_approval_categories"], payload, true); err == nil {
		t.Fatal("expected invalid approval category lifecycle to fail")
	}

	payload["container_lifecycle"] = "new"
	if err := validatePayload(Resources["fitness_approval_categories"], payload, true); err != nil {
		t.Fatalf("expected valid approval category payload, got %v", err)
	}
}

func TestValidateChecklistTemplateAllowsDraftStatus(t *testing.T) {
	payload := mustNormalize(t, Resources["fitness_checklist_templates"], map[string]any{
		"template_code": "CHK-001", "template_name": "Checklist Baru", "status": "draft",
	}, true)
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
	payload := mustNormalize(t, Resources["fitness_checklist_template_items"], map[string]any{
		"template_id": "00000000-0000-0000-0000-000000000111", "item_code": "ITM-001", "item_label": "Periksa corner post", "response_type": "bad_choice",
	}, true)
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
	payload := mustNormalize(t, Resources["customers"], map[string]any{"customer_name": ""}, false)
	if err := validatePayload(Resources["customers"], payload, false); err == nil {
		t.Fatal("expected empty required update value to fail")
	}
}

func TestNormalizeNullableEmptyValueToNilOnUpdate(t *testing.T) {
	payload := mustNormalize(t, Resources["customers"], map[string]any{"billing_address": ""}, false)
	if value, ok := payload["billing_address"]; !ok || value != nil {
		t.Fatalf("expected nullable empty billing_address to normalize to nil, got %#v", payload)
	}
}

func TestCreateDefaultFieldsAreOmittedWhenEmpty(t *testing.T) {
	cases := []struct {
		name     string
		resource Resource
		payload  map[string]any
		field    string
	}{
		{"inspection area display_order", Resources["inspection_areas"], map[string]any{"code": "AREA-1", "area_name": "Area", "display_order": ""}, "display_order"},
		{"approval category display_order", Resources["fitness_approval_categories"], map[string]any{"code": "APP-1", "name": "Approval", "container_lifecycle": "new", "display_order": ""}, "display_order"},
		{"damage criteria severity_default", Resources["structural_damage_criteria"], map[string]any{"code": "DMG-1", "criteria_name": "Damage", "severity_default": ""}, "severity_default"},
		{"inspection recommendation final result", Resources["inspection_recommendations"], map[string]any{"code": "REC-1", "name": "Recommendation", "final_fitness_result_mapping": ""}, "final_fitness_result_mapping"},
		{"checklist item display_order", Resources["fitness_checklist_template_items"], map[string]any{"template_id": "00000000-0000-0000-0000-000000000111", "item_code": "ITM-1", "item_label": "Item", "display_order": ""}, "display_order"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			payload := mustNormalize(t, tc.resource, tc.payload, true)
			if _, ok := payload[tc.field]; ok {
				t.Fatalf("expected %s to be omitted on create, got %#v", tc.field, payload)
			}
		})
	}
}

func TestUpdateDefaultFieldEmptyUsesConfiguredDefault(t *testing.T) {
	cases := []struct {
		name     string
		resource Resource
		field    string
		expected any
	}{
		{"inspection area display_order", Resources["inspection_areas"], "display_order", 0},
		{"approval category display_order", Resources["fitness_approval_categories"], "display_order", 0},
		{"damage criteria severity_default", Resources["structural_damage_criteria"], "severity_default", "minor"},
		{"recommendation final result", Resources["inspection_recommendations"], "final_fitness_result_mapping", "pending"},
		{"checklist item display_order", Resources["fitness_checklist_template_items"], "display_order", 0},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			payload := mustNormalize(t, tc.resource, map[string]any{tc.field: ""}, false)
			if payload[tc.field] != tc.expected {
				t.Fatalf("expected %s default %#v, got %#v", tc.field, tc.expected, payload[tc.field])
			}
		})
	}
}

func TestValidateUnknownFieldRejected(t *testing.T) {
	if err := validateKnownFields(Resources["customers"], map[string]any{"customer_code": "C-1", "bad_field": "x"}); err == nil {
		t.Fatal("expected unknown field to fail")
	}
}

func TestValidateURLField(t *testing.T) {
	payload := mustNormalize(t, Resources["container_manufacturers"], map[string]any{"manufacturer_code": "MFG-001", "manufacturer_name": "Maker", "website": "not-url"}, true)
	if err := validatePayload(Resources["container_manufacturers"], payload, true); err == nil {
		t.Fatal("expected invalid website to fail")
	}
	payload["website"] = "https://example.com"
	if err := validatePayload(Resources["container_manufacturers"], payload, true); err != nil {
		t.Fatalf("expected valid website, got %v", err)
	}
}

func TestValidateNumericMinMax(t *testing.T) {
	payload := mustNormalize(t, Resources["locations"], map[string]any{"location_code": "LOC-1", "location_name": "Yard", "location_type": "yard", "gps_latitude": -91}, true)
	if err := validatePayload(Resources["locations"], payload, true); err == nil {
		t.Fatal("expected latitude outside range to fail")
	}
}

func TestValidateForeignKeyUUID(t *testing.T) {
	payload := mustNormalize(t, Resources["structural_components"], map[string]any{"code": "C-1", "component_name": "Corner", "inspection_area_id": "not-uuid"}, true)
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
	payload := mustNormalize(t, Resources["customers"], map[string]any{"status": "active"}, false)
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

func TestAuditFailureRollsBackCreate(t *testing.T) {
	repo := newFakeMasterRepo()
	repo.failAudit = true
	service := NewServiceWithRepository(repo)
	_, err := service.Create(context.Background(), Resources["inspection_areas"], map[string]any{"code": "AREA-1", "area_name": "Area"}, testActor())
	if err == nil {
		t.Fatal("expected audit error")
	}
	if len(repo.records) != 0 {
		t.Fatalf("expected create rollback, got records=%#v", repo.records)
	}
	if repo.rollbackCount != 1 || repo.commitCount != 0 {
		t.Fatalf("expected one rollback and no commit, got rollback=%d commit=%d", repo.rollbackCount, repo.commitCount)
	}
}

func TestMutationFailureDoesNotInsertAudit(t *testing.T) {
	repo := newFakeMasterRepo()
	repo.failCreate = true
	service := NewServiceWithRepository(repo)
	_, err := service.Create(context.Background(), Resources["inspection_areas"], map[string]any{"code": "AREA-1", "area_name": "Area"}, testActor())
	if err == nil {
		t.Fatal("expected mutation error")
	}
	if len(repo.audits) != 0 {
		t.Fatalf("expected no audit on mutation failure, got %#v", repo.audits)
	}
	if repo.rollbackCount != 1 {
		t.Fatalf("expected rollback, got %d", repo.rollbackCount)
	}
}

func TestMutationAndAuditCommitTogether(t *testing.T) {
	repo := newFakeMasterRepo()
	service := NewServiceWithRepository(repo)
	_, err := service.Create(context.Background(), Resources["inspection_areas"], map[string]any{"code": "AREA-1", "area_name": "Area"}, testActor())
	if err != nil {
		t.Fatalf("expected create success, got %v", err)
	}
	if len(repo.records) != 1 || len(repo.audits) != 1 || repo.commitCount != 1 {
		t.Fatalf("expected record and audit commit, records=%d audits=%d commits=%d", len(repo.records), len(repo.audits), repo.commitCount)
	}
}

func TestCreateRetryAfterAuditFailureDoesNotDuplicateRecord(t *testing.T) {
	repo := newFakeMasterRepo()
	service := NewServiceWithRepository(repo)
	repo.failAudit = true
	_, err := service.Create(context.Background(), Resources["inspection_areas"], map[string]any{"code": "AREA-1", "area_name": "Area"}, testActor())
	if err == nil {
		t.Fatal("expected first create to fail")
	}
	repo.failAudit = false
	_, err = service.Create(context.Background(), Resources["inspection_areas"], map[string]any{"code": "AREA-1", "area_name": "Area"}, testActor())
	if err != nil {
		t.Fatalf("expected retry success, got %v", err)
	}
	if len(repo.records) != 1 || len(repo.audits) != 1 {
		t.Fatalf("expected one record and one audit after retry, records=%d audits=%d", len(repo.records), len(repo.audits))
	}
}

func TestInactiveRowDoesNotCreateRepeatedDeactivateAudit(t *testing.T) {
	repo := newFakeMasterRepo()
	id := uuid.New()
	repo.records[id.String()] = map[string]any{"id": id.String(), "code": "AREA-1", "area_name": "Area", "status": "inactive"}
	service := NewServiceWithRepository(repo)
	row, err := service.Delete(context.Background(), Resources["inspection_areas"], id, testActor())
	if err != nil {
		t.Fatalf("expected inactive delete to be no-op success, got %v", err)
	}
	if row["status"] != "inactive" {
		t.Fatalf("expected inactive row back, got %#v", row)
	}
	if len(repo.audits) != 0 {
		t.Fatalf("expected no repeated deactivate audit, got %#v", repo.audits)
	}
}

type errString string

func (e errString) Error() string { return string(e) }

type fakeMasterRepo struct {
	records       map[string]map[string]any
	audits        []AuditEntry
	failAudit     bool
	failCreate    bool
	commitCount   int
	rollbackCount int
}

func newFakeMasterRepo() *fakeMasterRepo {
	return &fakeMasterRepo{records: map[string]map[string]any{}}
}

func (r *fakeMasterRepo) List(context.Context, Resource, ListParams) (ListResult, error) {
	return ListResult{}, nil
}

func (r *fakeMasterRepo) Get(_ context.Context, _ Resource, id uuid.UUID) (map[string]any, error) {
	row, ok := r.records[id.String()]
	if !ok {
		return nil, ErrNotFound
	}
	return cloneMap(row), nil
}

func (r *fakeMasterRepo) Create(_ context.Context, _ Resource, payload map[string]any) (map[string]any, error) {
	if r.failCreate {
		return nil, errors.New("mutation failed")
	}
	id := uuid.New().String()
	row := cloneMap(payload)
	row["id"] = id
	r.records[id] = row
	return cloneMap(row), nil
}

func (r *fakeMasterRepo) Update(_ context.Context, _ Resource, id uuid.UUID, payload map[string]any) (map[string]any, error) {
	row, ok := r.records[id.String()]
	if !ok {
		return nil, ErrNotFound
	}
	for key, value := range payload {
		row[key] = value
	}
	return cloneMap(row), nil
}

func (r *fakeMasterRepo) Delete(_ context.Context, resource Resource, id uuid.UUID) (map[string]any, error) {
	row, ok := r.records[id.String()]
	if !ok {
		return nil, ErrNotFound
	}
	row[resource.statusField()] = resource.inactiveStatusValue()
	return cloneMap(row), nil
}

func (r *fakeMasterRepo) DuplicateExists(_ context.Context, resource Resource, payload map[string]any, excludeID *uuid.UUID) (bool, error) {
	if resource.CodeField == "" {
		return false, nil
	}
	candidate := stringValue(payload[resource.CodeField])
	for id, row := range r.records {
		if excludeID != nil && id == excludeID.String() {
			continue
		}
		if stringValue(row[resource.CodeField]) == candidate {
			return true, nil
		}
	}
	return false, nil
}

func (r *fakeMasterRepo) InsertAudit(_ context.Context, entry AuditEntry) error {
	if r.failAudit {
		return errors.New("audit failed")
	}
	r.audits = append(r.audits, entry)
	return nil
}

func (r *fakeMasterRepo) WithTx(ctx context.Context, fn func(repositoryPort) error) error {
	child := &fakeMasterRepo{records: cloneRecords(r.records), audits: append([]AuditEntry{}, r.audits...), failAudit: r.failAudit, failCreate: r.failCreate}
	if err := fn(child); err != nil {
		r.rollbackCount++
		return err
	}
	r.records = child.records
	r.audits = child.audits
	r.commitCount++
	_ = ctx
	return nil
}

func cloneRecords(input map[string]map[string]any) map[string]map[string]any {
	output := map[string]map[string]any{}
	for key, value := range input {
		output[key] = cloneMap(value)
	}
	return output
}

func cloneMap(input map[string]any) map[string]any {
	output := map[string]any{}
	for key, value := range input {
		output[key] = value
	}
	return output
}

func testActor() Actor {
	return Actor{UserID: uuid.New(), ActiveRole: "admin", RequestID: "req-test", IPAddress: "127.0.0.1", UserAgent: "test"}
}
