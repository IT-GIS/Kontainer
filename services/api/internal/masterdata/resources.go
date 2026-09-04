package masterdata

var Resources = map[string]Resource{
	"customers": {
		Name: "customers", Table: "customers", CodeField: "customer_code", SoftDelete: true,
		Fields: []Field{
			{Name: "customer_code", Required: true}, {Name: "customer_name", Required: true},
			{Name: "entity_type", Required: true, AllowedValues: []string{"business", "individual"}},
			{Name: "address", Required: true}, {Name: "country", Nullable: true}, {Name: "npwp", Nullable: true},
			{Name: "pic_name", Nullable: true}, {Name: "pic_phone", Nullable: true}, {Name: "pic_email", Type: "email", Nullable: true},
			{Name: "billing_address", Nullable: true}, {Name: "payment_term_days", Nullable: true}, {Name: "admin_notes", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"customer_code", "customer_name", "country", "pic_name", "pic_phone", "pic_email"},
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
		Name: "locations", Table: "locations", CodeField: "location_code", SoftDelete: true, LegacyOnly: true,
		Fields: []Field{
			{Name: "location_code", Required: true}, {Name: "location_name", Required: true}, {Name: "location_type", Required: true}, {Name: "address", Nullable: true},
			{Name: "city", Nullable: true}, {Name: "province", Nullable: true}, {Name: "postal_code", Nullable: true}, {Name: "gps_latitude", Type: "decimal", Nullable: true}, {Name: "gps_longitude", Type: "decimal", Nullable: true}, {Name: "pic_name", Nullable: true}, {Name: "pic_phone", Nullable: true}, {Name: "pic_email", Type: "email", Nullable: true}, {Name: "access_notes", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"location_code", "location_name", "city", "province", "pic_name", "pic_phone", "pic_email"},
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
		Name: "container_types", Table: "container_types", CodeField: "code", LegacyOnly: true,
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
		SearchColumns:    []string{"code", "component_name", "description"},
		Filters:          map[string]string{"status": "status", "inspection_area_id": "inspection_area_id"},
		RelationDisplays: []RelationDisplay{{Field: "inspection_area_id", Alias: "inspection_area_label", Table: "inspection_areas", CodeColumn: "code", NameColumn: "area_name"}},
		DefaultSort:      "display_order",
	},
	"structural_damage_criteria": {
		Name: "structural_damage_criteria", Table: "structural_damage_criteria", CodeField: "code",
		Fields: []Field{
			{Name: "code", Required: true}, {Name: "criteria_name", Required: true}, {Name: "description", Nullable: true}, {Name: "component_id", Nullable: true},
			{Name: "severity_default", UseDatabaseDefault: true, DefaultValue: "minor"}, {Name: "affects_fitness_default", UseDatabaseDefault: true, DefaultValue: false}, {Name: "repair_required_default", UseDatabaseDefault: true, DefaultValue: false}, {Name: "inspection_note", Nullable: true}, {Name: "status"},
		},
		SearchColumns:    []string{"code", "criteria_name", "description", "inspection_note"},
		Filters:          map[string]string{"status": "status", "severity_default": "severity_default", "component_id": "component_id"},
		RelationDisplays: []RelationDisplay{{Field: "component_id", Alias: "component_label", Table: "structural_components", CodeColumn: "code", NameColumn: "component_name"}},
		DefaultSort:      "code",
	},
	"finding_severities": {
		Name: "finding_severities", Table: "finding_severities", CodeField: "code",
		Fields: []Field{
			{Name: "code", Required: true}, {Name: "name", Required: true}, {Name: "description", Nullable: true}, {Name: "level_no", Required: true},
			{Name: "affects_fitness_default", UseDatabaseDefault: true, DefaultValue: false}, {Name: "requires_supervisor_review", UseDatabaseDefault: true, DefaultValue: false}, {Name: "badge_tone", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"code", "name", "description", "badge_tone"},
		Filters:       map[string]string{"status": "status"},
		DefaultSort:   "level_no",
	},
	"inspection_test_parameters": {
		Name: "inspection_test_parameters", Table: "inspection_test_parameters", CodeField: "code",
		Fields: []Field{
			{Name: "code", Required: true}, {Name: "parameter_name", Required: true},
			{Name: "reference_type", Nullable: true, AllowedValues: []string{"permenhub", "iso", "csc", "sni", "iicl", "sop_internal", "other"}},
			{Name: "description", Nullable: true}, {Name: "unit", Nullable: true}, {Name: "standard_reference", Required: true},
			{Name: "clause_section", Nullable: true}, {Name: "effective_date", Type: "date", Nullable: true},
			{Name: "expiry_date", Type: "date", Nullable: true}, {Name: "reference_attachment_file_id", Nullable: true},
			{Name: "applies_to_new_container", UseDatabaseDefault: true, DefaultValue: true}, {Name: "applies_to_existing_container", UseDatabaseDefault: true, DefaultValue: true}, {Name: "requires_numeric_result", UseDatabaseDefault: true, DefaultValue: false}, {Name: "requires_attachment", UseDatabaseDefault: true, DefaultValue: false}, {Name: "display_order", UseDatabaseDefault: true, DefaultValue: 0}, {Name: "status"},
		},
		SearchColumns: []string{"code", "parameter_name", "description", "standard_reference", "clause_section"},
		Filters:       map[string]string{"status": "status", "reference_type": "reference_type"},
		DefaultSort:   "display_order",
	},
	"fitness_checklist_templates": {
		Name: "fitness_checklist_templates", Table: "fitness_checklist_templates", CodeField: "template_code", SoftDelete: true, LegacyOnly: true, ActiveStatusValue: "draft",
		AllowedStatusValues: []string{"draft", "active", "inactive"},
		Fields: []Field{
			{Name: "template_code", Required: true}, {Name: "template_name", Required: true}, {Name: "approval_category_id", Nullable: true}, {Name: "container_type_id", Nullable: true},
			{Name: "description", Nullable: true}, {Name: "version_no", UseDatabaseDefault: true, DefaultValue: 1}, {Name: "status"},
		},
		SearchColumns: []string{"template_code", "template_name", "description"},
		Filters:       map[string]string{"status": "status", "approval_category_id": "approval_category_id", "container_type_id": "container_type_id"},
		RelationDisplays: []RelationDisplay{
			{Field: "approval_category_id", Alias: "approval_category_label", Table: "fitness_approval_categories", CodeColumn: "code", NameColumn: "name"},
			{Field: "container_type_id", Alias: "container_type_label", Table: "container_types", CodeColumn: "code", NameColumn: "type_name"},
		},
		DefaultSort: "template_name",
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
		RelationDisplays: []RelationDisplay{
			{Field: "inspection_area_id", Alias: "inspection_area_label", Table: "inspection_areas", CodeColumn: "code", NameColumn: "area_name"},
			{Field: "structural_component_id", Alias: "component_label", Table: "structural_components", CodeColumn: "code", NameColumn: "component_name"},
			{Field: "test_parameter_id", Alias: "test_parameter_label", Table: "inspection_test_parameters", CodeColumn: "code", NameColumn: "parameter_name"},
		},
		DefaultSort: "display_order",
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
		Name: "survey_types", Table: "survey_types", CodeField: "code", LegacyOnly: true,
		Fields:        []Field{{Name: "code", Required: true}, {Name: "name", Required: true}, {Name: "description", Nullable: true}, {Name: "requires_eir"}, {Name: "requires_light_test"}, {Name: "requires_cargo_worthy_result"}, {Name: "status"}},
		SearchColumns: []string{"code", "name"}, Filters: map[string]string{"status": "status"}, DefaultSort: "code",
	},
	"cedex_locations": {
		Name: "cedex_locations", Table: "cedex_locations", CodeField: "code", ScopedCode: true, LegacyOnly: true, AllowGlobalMutation: true,
		Fields: []Field{
			{Name: "input_mode", UseDatabaseDefault: true, DefaultValue: "manual", AllowedValues: []string{"structured", "manual"}},
			{Name: "sector_code", Nullable: true, MaxLength: 1}, {Name: "vertical_code", Nullable: true, MaxLength: 1},
			{Name: "start_section", Nullable: true, MaxLength: 1}, {Name: "end_section", Nullable: true, MaxLength: 1},
			{Name: "transverse_span", Nullable: true, MaxLength: 10},
			{Name: "code", Required: true, MaxLength: 4}, {Name: "face", Required: true}, {Name: "grid_code", Required: true, MaxLength: 30},
			{Name: "cedex_mapping_code", Nullable: true, MaxLength: 50}, {Name: "container_size", Nullable: true},
			{Name: "description", Required: true},
			{Name: "source_type", Required: true, UseDatabaseDefault: true, DefaultValue: "legacy", AllowedValues: []string{"standard_global", "customer_specific", "legacy"}},
			{Name: "source_reason", Nullable: true}, {Name: "display_order", UseDatabaseDefault: true, DefaultValue: 0}, {Name: "status"},
		},
		SearchColumns: []string{"code", "grid_code", "cedex_mapping_code", "description", "source_reason"}, Filters: map[string]string{"status": "status", "face": "face", "container_size": "container_size", "source": "source_type"}, DefaultSort: "display_order",
	},
	"cedex_components": {
		Name: "cedex_components", Table: "cedex_components", CodeField: "code", LegacyOnly: true, AllowGlobalMutation: true,
		Fields: []Field{
			{Name: "code", Required: true, MaxLength: 3}, {Name: "component_name", Required: true}, {Name: "assembly_group", Nullable: true},
			{Name: "applicable_face", Nullable: true, AllowedValues: []string{"left", "right", "front", "door", "roof", "floor", "understructure"}},
			{Name: "is_structural_critical", UseDatabaseDefault: true, DefaultValue: false},
			{Name: "description", Required: true},
			{Name: "source_type", Required: true, UseDatabaseDefault: true, DefaultValue: "legacy", AllowedValues: []string{"standard_global", "customer_specific", "legacy"}},
			{Name: "source_reason", Nullable: true}, {Name: "display_order", Type: "number", UseDatabaseDefault: true, DefaultValue: 0}, {Name: "status"},
		},
		SearchColumns: []string{"code", "component_name", "assembly_group", "description", "applicable_face", "source_reason"},
		Filters:       map[string]string{"status": "status", "applicable_face": "applicable_face", "source": "source_type"}, DefaultSort: "display_order",
	},
	"cedex_damages": {
		Name: "cedex_damages", Table: "cedex_damages", CodeField: "code", LegacyOnly: true, AllowGlobalMutation: true,
		Fields: []Field{
			{Name: "code", Required: true, MaxLength: 2}, {Name: "damage_name", Required: true},
			{Name: "damage_category", Nullable: true, AllowedValues: []string{"deformation", "crack_hole", "corrosion", "missing_component", "contamination", "water_tightness", "operational", "other"}},
			{Name: "default_severity", Required: true, UseDatabaseDefault: true, DefaultValue: "minor", AllowedValues: []string{"minor", "major", "critical", "manual_review"}},
			{Name: "requires_dimension", UseDatabaseDefault: true, DefaultValue: false},
			{Name: "default_action_id", Nullable: true}, {Name: "default_inspection_reference_id", Nullable: true},
			{Name: "description", Required: true},
			{Name: "source_type", Required: true, UseDatabaseDefault: true, DefaultValue: "legacy", AllowedValues: []string{"standard_global", "customer_specific", "legacy"}},
			{Name: "source_reason", Nullable: true}, {Name: "display_order", Type: "number", UseDatabaseDefault: true, DefaultValue: 0}, {Name: "status"},
		},
		SearchColumns: []string{"code", "damage_name", "damage_category", "description", "source_reason"},
		Filters:       map[string]string{"status": "status", "damage_category": "damage_category", "default_severity": "default_severity", "source": "source_type"},
		RelationDisplays: []RelationDisplay{
			{Field: "default_action_id", Alias: "default_action_label", Table: "cedex_repairs", CodeColumn: "code", NameColumn: "repair_name"},
			{Field: "default_inspection_reference_id", Alias: "default_inspection_reference_label", Table: "inspection_test_parameters", CodeColumn: "code", NameColumn: "parameter_name"},
		},
		DefaultSort: "display_order",
	},
	"cedex_repairs": {
		Name: "cedex_repairs", Table: "cedex_repairs", CodeField: "code", LegacyOnly: true, AllowGlobalMutation: true,
		Fields: []Field{
			{Name: "code", Required: true, MaxLength: 2}, {Name: "repair_name", Required: true},
			{Name: "result_mapping", Nullable: true, AllowedValues: []string{"no_status_change", "passed", "need_repair", "waiting_reinspection", "need_review", "not_passed"}},
			{Name: "requires_reinspection", UseDatabaseDefault: true, DefaultValue: false},
			{Name: "description", Required: true},
			{Name: "source_type", Required: true, UseDatabaseDefault: true, DefaultValue: "legacy", AllowedValues: []string{"standard_global", "customer_specific", "legacy"}},
			{Name: "source_reason", Nullable: true}, {Name: "display_order", Type: "number", UseDatabaseDefault: true, DefaultValue: 0}, {Name: "status"},
		},
		SearchColumns: []string{"code", "repair_name", "result_mapping", "description", "source_reason"},
		Filters:       map[string]string{"status": "status", "result_mapping": "result_mapping", "source": "source_type"}, DefaultSort: "display_order",
	},
	"cedex_damage_decision_rules": {
		Name: "cedex_damage_decision_rules", PermissionModule: "cedex_damages", Table: "cedex_damage_decision_rules", LegacyOnly: true, AllowGlobalMutation: true,
		Fields: []Field{
			{Name: "damage_id", Required: true}, {Name: "component_id", Nullable: true}, {Name: "location_id", Nullable: true},
			{Name: "material_id", Nullable: true}, {Name: "container_type_id", Nullable: true},
			{Name: "container_lifecycle", Nullable: true, AllowedValues: []string{"new", "existing"}},
			{Name: "inspection_reference_id", Required: true},
			{Name: "measurement_field", Required: true, AllowedValues: []string{"length", "width", "depth", "thickness", "quantity", "area", "manual_assessment"}},
			{Name: "comparison_operator", Required: true, AllowedValues: []string{"lt", "lte", "eq", "gt", "gte", "between", "manual"}},
			{Name: "minimum_value", Type: "decimal", Nullable: true}, {Name: "maximum_value", Type: "decimal", Nullable: true},
			{Name: "unit", Nullable: true}, {Name: "decision_result", Required: true, AllowedValues: []string{"passed", "need_repair", "need_reinspection", "not_passed", "manual_review"}},
			{Name: "recommended_action_id", Nullable: true}, {Name: "decision_note", Nullable: true},
			{Name: "priority", Type: "number", UseDatabaseDefault: true, DefaultValue: 0},
			{Name: "valid_from", Type: "date", Nullable: true}, {Name: "valid_until", Type: "date", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"decision_note", "measurement_field", "decision_result", "unit"},
		Filters: map[string]string{
			"status": "status", "damage_id": "damage_id", "component_id": "component_id", "location_id": "location_id",
			"material_id": "material_id", "container_type_id": "container_type_id", "container_lifecycle": "container_lifecycle",
			"inspection_reference_id": "inspection_reference_id", "measurement_field": "measurement_field", "decision_result": "decision_result",
		},
		RelationDisplays: []RelationDisplay{
			{Field: "damage_id", Alias: "damage_label", Table: "cedex_damages", CodeColumn: "code", NameColumn: "damage_name"},
			{Field: "component_id", Alias: "component_label", Table: "cedex_components", CodeColumn: "code", NameColumn: "component_name"},
			{Field: "location_id", Alias: "location_label", Table: "cedex_locations", CodeColumn: "code", NameColumn: "grid_code"},
			{Field: "material_id", Alias: "material_label", Table: "cedex_materials", CodeColumn: "code", NameColumn: "material_name"},
			{Field: "container_type_id", Alias: "container_type_label", Table: "container_types", CodeColumn: "code", NameColumn: "type_name"},
			{Field: "inspection_reference_id", Alias: "inspection_reference_label", Table: "inspection_test_parameters", CodeColumn: "code", NameColumn: "parameter_name"},
			{Field: "recommended_action_id", Alias: "recommended_action_label", Table: "cedex_repairs", CodeColumn: "code", NameColumn: "repair_name"},
		}, DefaultSort: "priority",
	},
	"cedex_materials": {
		Name: "cedex_materials", Table: "cedex_materials", CodeField: "code", LegacyOnly: true, AllowGlobalMutation: true,
		Fields: []Field{
			{Name: "code", Required: true, MaxLength: 2}, {Name: "material_name", Required: true}, {Name: "description", Required: true},
			{Name: "source_type", Required: true, UseDatabaseDefault: true, DefaultValue: "legacy", AllowedValues: []string{"standard_global", "customer_specific", "legacy"}},
			{Name: "source_reason", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"code", "material_name", "description", "source_reason"}, Filters: map[string]string{"status": "status", "source": "source_type"}, DefaultSort: "code",
	},
	"cedex_code_proposals": {
		Name: "cedex_code_proposals", PermissionModule: "cedex_code_proposals", Table: "cedex_code_proposals", ReadOnly: true,
		AllowedStatusValues: []string{"pending", "approved", "rejected"},
		Fields: []Field{
			{Name: "survey_id", Required: true}, {Name: "customer_id", Required: true}, {Name: "proposed_by", Required: true},
			{Name: "code_type", Required: true}, {Name: "code", Required: true}, {Name: "description", Required: true},
			{Name: "reason", Required: true}, {Name: "evidence_file_id", Nullable: true}, {Name: "notes", Nullable: true},
			{Name: "status", Required: true}, {Name: "review_note", Nullable: true}, {Name: "reviewed_by", Nullable: true},
			{Name: "reviewed_at", Nullable: true}, {Name: "master_entity_id", Nullable: true},
		},
		SearchColumns: []string{"code", "code_type", "description", "reason", "notes", "review_note"},
		Filters:       map[string]string{"status": "status", "code_type": "code_type", "customer_id": "customer_id", "proposed_by": "proposed_by"},
		RelationDisplays: []RelationDisplay{
			{Field: "customer_id", Alias: "customer_label", Table: "customers", CodeColumn: "customer_code", NameColumn: "customer_name"},
			{Field: "proposed_by", Alias: "proposed_by_label", Table: "users", CodeColumn: "email", NameColumn: "full_name"},
			{Field: "reviewed_by", Alias: "reviewed_by_label", Table: "users", CodeColumn: "email", NameColumn: "full_name"},
		}, DefaultSort: "created_at",
	},
	"responsibility_codes": legacyCodeNameResource("responsibility_codes", "responsibility_codes", "name"),
	"customer_personnel": {
		Name: "customer_personnel", PermissionModule: "customers", Table: "customer_personnel", CodeField: "personnel_code", SoftDelete: true,
		DuplicateFields: []string{"customer_id", "personnel_code"},
		Fields: []Field{
			{Name: "customer_id", Required: true}, {Name: "personnel_code", Required: true}, {Name: "full_name", APIName: "name", Required: true},
			{Name: "position_title", Nullable: true}, {Name: "personnel_type", Required: true}, {Name: "email", Type: "email", Nullable: true},
			{Name: "phone", Nullable: true}, {Name: "notes", Nullable: true}, {Name: "status"},
		},
		SearchColumns: []string{"personnel_code", "full_name", "position_title", "personnel_type", "email", "phone"},
		Filters:       map[string]string{"status": "status", "customer_id": "customer_id", "personnel_type": "personnel_type"}, DefaultSort: "full_name",
	},
}

func legacyCodeNameResource(name string, table string, nameField string) Resource {
	resource := codeNameResource(name, table, nameField)
	resource.LegacyOnly = true
	return resource
}

func customerScopedResource(resource Resource) Resource {
	resource.LegacyOnly = false
	resource.AllowGlobalMutation = false
	resource.ScopedCode = false
	if resource.hasField("customer_id") {
		for index := range resource.Fields {
			if resource.Fields[index].Name == "customer_id" {
				resource.Fields[index].Required = true
				resource.Fields[index].Nullable = false
			}
		}
	} else {
		resource.Fields = append([]Field{{Name: "customer_id", Required: true}}, resource.Fields...)
	}
	filters := map[string]string{}
	for key, value := range resource.Filters {
		filters[key] = value
	}
	filters["customer_id"] = "customer_id"
	if resource.Name == "fitness_checklist_templates" {
		resource.Fields = append(resource.Fields, Field{Name: "survey_type_id", Required: true})
		filters["survey_type_id"] = "survey_type_id"
		for index := range resource.Fields {
			if resource.Fields[index].Name == "container_type_id" {
				resource.Fields[index].Required = true
				resource.Fields[index].Nullable = false
			}
		}
		resource.RelationDisplays = append(resource.RelationDisplays, RelationDisplay{Field: "survey_type_id", Alias: "survey_type_label", Table: "survey_types", CodeColumn: "code", NameColumn: "name"})
	}
	resource.Filters = filters
	if resource.CodeField != "" {
		resource.DuplicateFields = []string{"customer_id", resource.CodeField}
	}
	return resource
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
