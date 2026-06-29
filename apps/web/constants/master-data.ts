export type MasterField = {
  name: string;
  label: string;
  type?: "text" | "number" | "select" | "checkbox" | "email";
  required?: boolean;
  options?: Array<{ label: string; value: string }>;
};

export type MasterColumn = {
  key: string;
  label: string;
  type?: "status" | "boolean";
};

export type MasterResource = {
  id: string;
  title: string;
  description: string;
  endpoint: string;
  permissionModule: string;
  columns: MasterColumn[];
  fields: MasterField[];
};

const statusField: MasterField = {
  name: "status",
  label: "Status",
  type: "select",
  options: [
    { label: "Active", value: "active" },
    { label: "Inactive", value: "inactive" }
  ]
};

export const masterResources: Record<string, MasterResource> = {
  customers: {
    id: "customers",
    title: "Master Customer",
    description: "Customer, billing, and contact references for job orders and finance.",
    endpoint: "/master/customers",
    permissionModule: "customers",
    columns: [
      { key: "customer_code", label: "Code" },
      { key: "customer_name", label: "Customer" },
      { key: "pic_name", label: "PIC" },
      { key: "pic_phone", label: "Phone" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "customer_code", label: "Customer Code", required: true },
      { name: "customer_name", label: "Customer Name", required: true },
      { name: "address", label: "Address" },
      { name: "npwp", label: "NPWP" },
      { name: "pic_name", label: "PIC Name" },
      { name: "pic_phone", label: "PIC Phone" },
      { name: "pic_email", label: "PIC Email", type: "email" },
      { name: "billing_address", label: "Billing Address" },
      { name: "payment_term_days", label: "Payment Term Days", type: "number" },
      statusField
    ]
  },
  locations: {
    id: "locations",
    title: "Master Location",
    description: "Depots, yards, ports, and customer sites used in survey operations.",
    endpoint: "/master/locations",
    permissionModule: "locations",
    columns: [
      { key: "location_code", label: "Code" },
      { key: "location_name", label: "Location" },
      { key: "location_type", label: "Type" },
      { key: "city", label: "City" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "location_code", label: "Location Code", required: true },
      { name: "location_name", label: "Location Name", required: true },
      {
        name: "location_type",
        label: "Location Type",
        type: "select",
        required: true,
        options: ["depot", "yard", "port", "warehouse", "factory", "customer_site", "other"].map((value) => ({ label: value, value }))
      },
      { name: "address", label: "Address" },
      { name: "city", label: "City" },
      { name: "gps_latitude", label: "GPS Latitude", type: "number" },
      { name: "gps_longitude", label: "GPS Longitude", type: "number" },
      { name: "pic_name", label: "PIC Name" },
      { name: "pic_phone", label: "PIC Phone" },
      statusField
    ]
  },
  surveyors: {
    id: "surveyors",
    title: "Master Surveyor",
    description: "Surveyor profile registry linked to user accounts.",
    endpoint: "/master/surveyors",
    permissionModule: "surveyors",
    columns: [
      { key: "surveyor_code", label: "Code" },
      { key: "name", label: "Name" },
      { key: "phone", label: "Phone" },
      { key: "area", label: "Area" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "surveyor_code", label: "Surveyor Code", required: true },
      { name: "user_id", label: "User ID", required: true },
      { name: "name", label: "Full Name", required: true },
      { name: "phone", label: "Phone" },
      { name: "area", label: "Area" },
      statusField
    ]
  },
  "container-types": {
    id: "container-types",
    title: "Master Container Type",
    description: "Container ISO type references used by job containers and pricing.",
    endpoint: "/master/container-types",
    permissionModule: "container_types",
    columns: [
      { key: "code", label: "Code" },
      { key: "iso_code", label: "ISO" },
      { key: "size", label: "Size" },
      { key: "type", label: "Type" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Code", required: true },
      { name: "iso_code", label: "ISO Code" },
      { name: "size", label: "Size", required: true },
      { name: "type", label: "Type", required: true },
      { name: "description", label: "Description" },
      statusField
    ]
  },
  "survey-types": {
    id: "survey-types",
    title: "Master Survey Type",
    description: "Survey type behavior and document requirements.",
    endpoint: "/master/survey-types",
    permissionModule: "survey_types",
    columns: [
      { key: "code", label: "Code" },
      { key: "name", label: "Name" },
      { key: "requires_eir", label: "EIR", type: "boolean" },
      { key: "requires_light_test", label: "Light Test", type: "boolean" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Code", required: true },
      { name: "name", label: "Name", required: true },
      { name: "description", label: "Description" },
      { name: "requires_eir", label: "Requires EIR", type: "checkbox" },
      { name: "requires_light_test", label: "Requires Light Test", type: "checkbox" },
      { name: "requires_cargo_worthy_result", label: "Requires Cargo Worthy Result", type: "checkbox" },
      statusField
    ]
  },
  "cedex-components": codeNameResource("cedex-components", "Master CEDEX Component", "CEDEX component references for survey damage records.", "/master/cedex/components", "cedex_components", "component_name", "Component Name"),
  "cedex-damages": codeNameResource("cedex-damages", "Master CEDEX Damage", "Damage code references used by surveyors.", "/master/cedex/damages", "cedex_damages", "damage_name", "Damage Name"),
  "cedex-repairs": codeNameResource("cedex-repairs", "Master CEDEX Repair", "Repair action code references used in damage records.", "/master/cedex/repairs", "cedex_repairs", "repair_name", "Repair Name")
};

function codeNameResource(id: string, title: string, description: string, endpoint: string, permissionModule: string, nameField: string, nameLabel: string): MasterResource {
  return {
    id,
    title,
    description,
    endpoint,
    permissionModule,
    columns: [
      { key: "code", label: "Code" },
      { key: nameField, label: nameLabel },
      { key: "description", label: "Description" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Code", required: true },
      { name: nameField, label: nameLabel, required: true },
      { name: "description", label: "Description" },
      statusField
    ]
  };
}