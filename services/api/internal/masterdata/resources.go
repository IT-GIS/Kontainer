package masterdata

var Resources = map[string]Resource{
	"customers": {
		Name: "customers", Table: "customers", CodeField: "customer_code", SoftDelete: true,
		Fields: []Field{
			{Name: "customer_code", Required: true}, {Name: "customer_name", Required: true}, {Name: "address"}, {Name: "npwp"},
			{Name: "pic_name"}, {Name: "pic_phone"}, {Name: "pic_email"}, {Name: "billing_address"}, {Name: "payment_term_days"}, {Name: "status"},
		},
		SearchColumns: []string{"customer_code", "customer_name", "pic_name", "pic_phone", "pic_email"},
		Filters:       map[string]string{"status": "status"},
		DefaultSort:   "customer_name",
	},
	"locations": {
		Name: "locations", Table: "locations", CodeField: "location_code", SoftDelete: true,
		Fields: []Field{
			{Name: "location_code", Required: true}, {Name: "location_name", Required: true}, {Name: "location_type", Required: true}, {Name: "address"},
			{Name: "city"}, {Name: "gps_latitude"}, {Name: "gps_longitude"}, {Name: "pic_name"}, {Name: "pic_phone"}, {Name: "status"},
		},
		SearchColumns: []string{"location_code", "location_name", "city", "pic_name", "pic_phone"},
		Filters:       map[string]string{"status": "status", "location_type": "location_type"},
		DefaultSort:   "location_name",
	},
	"surveyors": {
		Name: "surveyors", Table: "surveyor_profiles", CodeField: "surveyor_code", SoftDelete: true,
		Fields: []Field{
			{Name: "surveyor_code", Required: true}, {Name: "user_id", Required: true}, {Name: "full_name", APIName: "name", Required: true},
			{Name: "phone"}, {Name: "area"}, {Name: "signature_file_id"}, {Name: "status"},
		},
		SearchColumns: []string{"surveyor_code", "full_name", "phone", "area"},
		Filters:       map[string]string{"status": "status"},
		DefaultSort:   "full_name",
	},
	"container_types": {
		Name: "container_types", Table: "container_types", CodeField: "code",
		Fields:        []Field{{Name: "code", Required: true}, {Name: "iso_code"}, {Name: "size", Required: true}, {Name: "type_name", APIName: "type", Required: true}, {Name: "description"}, {Name: "status"}},
		SearchColumns: []string{"code", "iso_code", "size", "type_name"}, Filters: map[string]string{"status": "status"}, DefaultSort: "code",
	},
	"survey_types": {
		Name: "survey_types", Table: "survey_types", CodeField: "code",
		Fields:        []Field{{Name: "code", Required: true}, {Name: "name", Required: true}, {Name: "description"}, {Name: "requires_eir"}, {Name: "requires_light_test"}, {Name: "requires_cargo_worthy_result"}, {Name: "status"}},
		SearchColumns: []string{"code", "name"}, Filters: map[string]string{"status": "status"}, DefaultSort: "code",
	},
	"cedex_locations": {
		Name: "cedex_locations", Table: "cedex_locations", CodeField: "code", ScopedCode: true,
		Fields:        []Field{{Name: "code", Required: true}, {Name: "face", Required: true}, {Name: "grid_code", Required: true}, {Name: "cedex_mapping_code"}, {Name: "container_size"}, {Name: "description"}, {Name: "display_order"}, {Name: "status"}},
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
		Fields:        []Field{{Name: "code", Required: true}, {Name: nameField, Required: true}, {Name: "description"}, {Name: "status"}},
		SearchColumns: []string{"code", nameField, "description"},
		Filters:       map[string]string{"status": "status"},
		DefaultSort:   "code",
	}
}
