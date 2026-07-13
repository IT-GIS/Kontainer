package masterdata

var Resources = map[string]Resource{
	"customers": {
		Name: "customers", Table: "customers", CodeField: "customer_code", SoftDelete: true,
		Fields: []Field{
			{Name: "customer_code", Required: true}, {Name: "customer_name", Required: true}, {Name: "address", Nullable: true}, {Name: "npwp", Nullable: true},
			{Name: "pic_name", Nullable: true}, {Name: "pic_phone", Nullable: true}, {Name: "pic_email", Type: "email", Nullable: true}, {Name: "billing_address", Nullable: true}, {Name: "payment_term_days", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"customer_code", "customer_name", "pic_name", "pic_phone", "pic_email"},
		Filters:       map[string]string{"status": "status"},
		DefaultSort:   "customer_name",
	},
	"container_manufacturers": {
		Name: "container_manufacturers", Table: "container_manufacturers", CodeField: "manufacturer_code", SoftDelete: true,
		Fields: []Field{
			{Name: "manufacturer_code", Required: true}, {Name: "manufacturer_name", Required: true}, {Name: "address", Nullable: true}, {Name: "country", Nullable: true},
			{Name: "pic_name", Nullable: true}, {Name: "pic_phone", Nullable: true}, {Name: "pic_email", Type: "email", Nullable: true}, {Name: "website", Type: "url", Nullable: true}, {Name: "note", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"manufacturer_code", "manufacturer_name", "country", "pic_name", "pic_phone", "pic_email"},
		Filters:       map[string]string{"status": "status"},
		DefaultSort:   "manufacturer_name",
	},
	"locations": {
		Name: "locations", Table: "locations", CodeField: "location_code", SoftDelete: true,
		Fields: []Field{
			{Name: "location_code", Required: true}, {Name: "location_name", Required: true}, {Name: "location_type", Required: true}, {Name: "address", Nullable: true},
			{Name: "city", Nullable: true}, {Name: "gps_latitude", Type: "decimal", Nullable: true}, {Name: "gps_longitude", Type: "decimal", Nullable: true}, {Name: "pic_name", Nullable: true}, {Name: "pic_phone", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"location_code", "location_name", "city", "pic_name", "pic_phone"},
		Filters:       map[string]string{"status": "status", "location_type": "location_type"},
		DefaultSort:   "location_name",
	},
	"surveyors": {
		Name: "surveyors", Table: "surveyor_profiles", CodeField: "surveyor_code", SoftDelete: true,
		Fields: []Field{
			{Name: "surveyor_code", Required: true}, {Name: "user_id", Required: true}, {Name: "full_name", APIName: "name", Required: true},
			{Name: "phone", Nullable: true}, {Name: "area", Nullable: true}, {Name: "signature_file_id", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"surveyor_code", "full_name", "phone", "area"},
		Filters:       map[string]string{"status": "status"},
		DefaultSort:   "full_name",
	},
	"container_types": {
		Name: "container_types", Table: "container_types", CodeField: "code",
		Fields:        []Field{{Name: "code", Required: true}, {Name: "iso_code", Nullable: true}, {Name: "size", Required: true}, {Name: "type_name", APIName: "type", Required: true}, {Name: "description", Nullable: true}, {Name: "status"}},
		SearchColumns: []string{"code", "iso_code", "size", "type_name"}, Filters: map[string]string{"status": "status"}, DefaultSort: "code",
	},
	"fitness_approval_categories": {
		Name: "fitness_approval_categories", Table: "fitness_approval_categories", CodeField: "code",
		Fields: []Field{
			{Name: "code", Required: true}, {Name: "name", Required: true}, {Name: "description", Nullable: true},
			{Name: "container_lifecycle", Required: true}, {Name: "is_mvp_active", UseDatabaseDefault: true, DefaultValue: true}, {Name: "display_order", UseDatabaseDefault: true, DefaultValue: 0}, {Name: "status"},
		},
		SearchColumns: []string{"code", "name", "container_lifecycle"},
		Filters:       map[string]string{"status": "status", "container_lifecycle": "container_lifecycle"},
		DefaultSort:   "display_order",
	},
	"maintenance_schemes": {
		Name: "maintenance_schemes", Table: "maintenance_schemes", CodeField: "code",
		Fields: []Field{
			{Name: "code", Required: true}, {Name: "name", Required: true}, {Name: "description", Nullable: true},
			{Name: "requires_next_examination_date", UseDatabaseDefault: true, DefaultValue: false}, {Name: "default_interval_months", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"code", "name", "description"},
		Filters:       map[string]string{"status": "status"},
		DefaultSort:   "code",
	},
	"inspection_areas": {
		Name: "inspection_areas", Table: "inspection_areas", CodeField: "code",
		Fields:        []Field{{Name: "code", Required: true}, {Name: "area_name", Required: true}, {Name: "description", Nullable: true}, {Name: "display_order", UseDatabaseDefault: true, DefaultValue: 0}, {Name: "status"}},
		SearchColumns: []string{"code", "area_name", "description"},
		Filters:       map[string]string{"status": "status"},
		DefaultSort:   "display_order",
	},
	"structural_components": {
		Name: "structural_components", Table: "structural_components", CodeField: "code",
		Fields: []Field{
			{Name: "code", Required: true}, {Name: "component_name", Required: true}, {Name: "inspection_area_id", Nullable: true},
			{Name: "is_structural_critical", UseDatabaseDefault: true, DefaultValue: false}, {Name: "description", Nullable: true}, {Name: "display_order", UseDatabaseDefault: true, DefaultValue: 0}, {Name: "status"},
		},
		SearchColumns: []string{"code", "component_name", "description"},
		Filters:       map[string]string{"status": "status", "inspection_area_id": "inspection_area_id"},
		DefaultSort:   "display_order",
	},
	"structural_damage_criteria": {
		Name: "structural_damage_criteria", Table: "structural_damage_criteria", CodeField: "code",
		Fields: []Field{
			{Name: "code", Required: true}, {Name: "criteria_name", Required: true}, {Name: "description", Nullable: true}, {Name: "component_id", Nullable: true},
			{Name: "severity_default", UseDatabaseDefault: true, DefaultValue: "minor"}, {Name: "affects_fitness_default", UseDatabaseDefault: true, DefaultValue: false}, {Name: "repair_required_default", UseDatabaseDefault: true, DefaultValue: false}, {Name: "inspection_note", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"code", "criteria_name", "description", "inspection_note"},
		Filters:       map[string]string{"status": "status", "severity_default": "severity_default", "component_id": "component_id"},
		DefaultSort:   "code",
	},
	"finding_severities": {
		Name: "finding_severities", Table: "finding_severities", CodeField: "code",
		Fields: []Field{
			{Name: "code", Required: true}, {Name: "name", Required: true}, {Name: "description", Nullable: true}, {Name: "level_no", Required: true},
			{Name: "affects_fitness_default", UseDatabaseDefault: true, DefaultValue: false}, {Name: "requires_supervisor_review", UseDatabaseDefault: true, DefaultValue: true}, {Name: "badge_tone", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"code", "name", "description", "badge_tone"},
		Filters:       map[string]string{"status": "status"},
		DefaultSort:   "level_no",
	},
	"inspection_test_parameters": {
		Name: "inspection_test_parameters", Table: "inspection_test_parameters", CodeField: "code",
		Fields: []Field{
			{Name: "code", Required: true}, {Name: "parameter_name", Required: true}, {Name: "description", Nullable: true}, {Name: "unit", Nullable: true}, {Name: "standard_reference", Nullable: true},
			{Name: "applies_to_new_container", UseDatabaseDefault: true, DefaultValue: true}, {Name: "applies_to_existing_container", UseDatabaseDefault: true, DefaultValue: true}, {Name: "requires_numeric_result", UseDatabaseDefault: true, DefaultValue: false}, {Name: "requires_attachment", UseDatabaseDefault: true, DefaultValue: false}, {Name: "display_order", UseDatabaseDefault: true, DefaultValue: 0}, {Name: "status"},
		},
		SearchColumns: []string{"code", "parameter_name", "description", "standard_reference"},
		Filters:       map[string]string{"status": "status"},
		DefaultSort:   "display_order",
	},
	"fitness_checklist_templates": {
		Name: "fitness_checklist_templates", Table: "fitness_checklist_templates", CodeField: "template_code", SoftDelete: true, ActiveStatusValue: "draft",
		AllowedStatusValues: []string{"draft", "active", "inactive"},
		Fields: []Field{
			{Name: "template_code", Required: true}, {Name: "template_name", Required: true}, {Name: "approval_category_id", Nullable: true}, {Name: "container_type_id", Nullable: true},
			{Name: "description", Nullable: true}, {Name: "version_no", UseDatabaseDefault: true, DefaultValue: 1}, {Name: "status"},
		},
		SearchColumns: []string{"template_code", "template_name", "description"},
		Filters:       map[string]string{"status": "status", "approval_category_id": "approval_category_id", "container_type_id": "container_type_id"},
		DefaultSort:   "template_name",
	},
	"fitness_checklist_template_items": {
		Name: "fitness_checklist_template_items", PermissionModule: "fitness_checklist_templates", Table: "fitness_checklist_template_items", CodeField: "item_code",
		DuplicateFields: []string{"template_id", "item_code"},
		Fields: []Field{
			{Name: "template_id", Required: true}, {Name: "item_code", Required: true}, {Name: "item_label", Required: true}, {Name: "description", Nullable: true},
			{Name: "inspection_area_id", Nullable: true}, {Name: "structural_component_id", Nullable: true}, {Name: "test_parameter_id", Nullable: true}, {Name: "response_type", UseDatabaseDefault: true, DefaultValue: "ok_not_ok"},
			{Name: "expected_value", Nullable: true}, {Name: "is_required", UseDatabaseDefault: true, DefaultValue: true}, {Name: "is_critical", UseDatabaseDefault: true, DefaultValue: false}, {Name: "fail_requires_repair", UseDatabaseDefault: true, DefaultValue: false}, {Name: "fail_marks_unfit", UseDatabaseDefault: true, DefaultValue: false},
			{Name: "display_order", UseDatabaseDefault: true, DefaultValue: 0}, {Name: "status"},
		},
		SearchColumns: []string{"item_code", "item_label", "description", "expected_value"},
		Filters:       map[string]string{"status": "status", "template_id": "template_id", "inspection_area_id": "inspection_area_id", "structural_component_id": "structural_component_id", "test_parameter_id": "test_parameter_id"},
		DefaultSort:   "display_order",
	},
	"evidence_photo_categories": {
		Name: "evidence_photo_categories", Table: "evidence_photo_categories", CodeField: "code",
		Fields: []Field{
			{Name: "code", Required: true}, {Name: "name", Required: true}, {Name: "description", Nullable: true}, {Name: "is_required_default", UseDatabaseDefault: true, DefaultValue: false},
			{Name: "applies_to", Nullable: true}, {Name: "display_order", UseDatabaseDefault: true, DefaultValue: 0}, {Name: "status"},
		},
		SearchColumns: []string{"code", "name", "description", "applies_to"},
		Filters:       map[string]string{"status": "status", "applies_to": "applies_to"},
		DefaultSort:   "display_order",
	},
	"inspection_recommendations": {
		Name: "inspection_recommendations", Table: "inspection_recommendations", CodeField: "code",
		Fields: []Field{
			{Name: "code", Required: true}, {Name: "name", Required: true}, {Name: "description", Nullable: true}, {Name: "final_fitness_result_mapping", UseDatabaseDefault: true, DefaultValue: "pending"},
			{Name: "workflow_status_mapping", Nullable: true}, {Name: "restriction_status_mapping", Nullable: true}, {Name: "requires_supervisor_review", UseDatabaseDefault: true, DefaultValue: true}, {Name: "status"},
		},
		SearchColumns: []string{"code", "name", "description", "final_fitness_result_mapping", "workflow_status_mapping", "restriction_status_mapping"},
		Filters:       map[string]string{"status": "status", "final_fitness_result_mapping": "final_fitness_result_mapping"},
		DefaultSort:   "code",
	},
	"authorized_signers": {
		Name: "authorized_signers", Table: "authorized_signers", SoftDelete: true,
		Fields: []Field{
			{Name: "signer_name", Required: true}, {Name: "position_title", Required: true}, {Name: "employee_no", Nullable: true}, {Name: "email", Type: "email", Nullable: true}, {Name: "phone", Nullable: true},
			{Name: "signature_file_id", Nullable: true}, {Name: "valid_from", Type: "date", Nullable: true}, {Name: "valid_until", Type: "date", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"signer_name", "position_title", "employee_no", "email", "phone"},
		Filters:       map[string]string{"status": "status"},
		DefaultSort:   "signer_name",
	},
	"company_profiles": {
		Name: "company_profiles", Table: "company_profiles", StatusField: "is_active", ActiveStatusValue: true, InactiveStatusValue: false,
		Fields: []Field{
			{Name: "company_name", Required: true}, {Name: "brand_name", Nullable: true}, {Name: "address", Nullable: true}, {Name: "phone", Nullable: true}, {Name: "email", Type: "email", Nullable: true},
			{Name: "website", Type: "url", Nullable: true}, {Name: "tax_no", Nullable: true}, {Name: "logo_file_id", Nullable: true}, {Name: "default_signature_file_id", Nullable: true}, {Name: "is_active", UseDatabaseDefault: true, DefaultValue: true},
		},
		SearchColumns: []string{"company_name", "brand_name", "address", "phone", "email", "website", "tax_no"},
		Filters:       map[string]string{"status": "is_active"},
		DefaultSort:   "company_name",
	},
	"survey_types": {
		Name: "survey_types", Table: "survey_types", CodeField: "code",
		Fields:        []Field{{Name: "code", Required: true}, {Name: "name", Required: true}, {Name: "description", Nullable: true}, {Name: "requires_eir"}, {Name: "requires_light_test"}, {Name: "requires_cargo_worthy_result"}, {Name: "status"}},
		SearchColumns: []string{"code", "name"}, Filters: map[string]string{"status": "status"}, DefaultSort: "code",
	},
	"cedex_locations": {
		Name: "cedex_locations", Table: "cedex_locations", CodeField: "code", ScopedCode: true,
		Fields:        []Field{{Name: "code", Required: true}, {Name: "face", Required: true}, {Name: "grid_code", Required: true}, {Name: "cedex_mapping_code"}, {Name: "container_size"}, {Name: "description", Nullable: true}, {Name: "display_order", UseDatabaseDefault: true, DefaultValue: 0}, {Name: "status"}},
		SearchColumns: []string{"code", "grid_code", "cedex_mapping_code", "description"}, Filters: map[string]string{"status": "status", "face": "face", "container_size": "container_size"}, DefaultSort: "display_order",
	},
	"cedex_components":     codeNameResource("cedex_components", "cedex_components", "component_name"),
	"cedex_damages":        codeNameResource("cedex_damages", "cedex_damages", "damage_name"),
	"cedex_repairs":        codeNameResource("cedex_repairs", "cedex_repairs", "repair_name"),
	"cedex_materials":      codeNameResource("cedex_materials", "cedex_materials", "material_name"),
	"responsibility_codes": codeNameResource("responsibility_codes", "responsibility_codes", "name"),
}

func codeNameResource(name string, table string, nameField string) Resource {
	return Resource{
		Name: name, Table: table, CodeField: "code",
		Fields:        []Field{{Name: "code", Required: true}, {Name: nameField, Required: true}, {Name: "description", Nullable: true}, {Name: "status"}},
		SearchColumns: []string{"code", nameField, "description"},
		Filters:       map[string]string{"status": "status"},
		DefaultSort:   "code",
	}
}
