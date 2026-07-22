export type MasterField = {
  name: string;
  label: string;
  type?: "text" | "textarea" | "number" | "decimal" | "email" | "tel" | "url" | "date" | "datetime-local" | "select" | "searchable-select" | "checkbox" | "hidden";
  required?: boolean;
  options?: Array<{ label: string; value: string }>;
  relation?: { endpoint: string; labelKeys: string[]; preload?: boolean; query?: Record<string, string> };
  helpText?: string;
  defaultValue?: string | number | boolean;
  nullable?: boolean;
  omitWhenEmpty?: boolean;
  clearValue?: string | number | boolean | null;
  trim?: boolean;
  min?: number;
  max?: number;
  step?: number | string;
  pattern?: string;
  maxLength?: number;
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
  statusOptions?: Array<{ label: string; value: string }>;
};

const commonStatusOptions = [
  { label: "Aktif", value: "active" },
  { label: "Tidak Aktif", value: "inactive" }
];

const checklistStatusOptions = [
  { label: "Draf", value: "draft" },
  { label: "Aktif", value: "active" },
  { label: "Tidak Aktif", value: "inactive" }
];

const statusField: MasterField = {
  name: "status",
  label: "Status",
  type: "select",
  options: commonStatusOptions
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
      { name: "address", label: "Address", type: "textarea", nullable: true },
      { name: "npwp", label: "NPWP", nullable: true },
      { name: "pic_name", label: "PIC Name", nullable: true },
      { name: "pic_phone", label: "PIC Phone", type: "tel", nullable: true, maxLength: 50 },
      { name: "pic_email", label: "PIC Email", type: "email", nullable: true },
      { name: "billing_address", label: "Billing Address", type: "textarea", nullable: true },
      { name: "payment_term_days", label: "Payment Term Days", type: "number", min: 0, step: 1, nullable: true },
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
      { name: "address", label: "Address", type: "textarea", nullable: true },
      { name: "city", label: "City", nullable: true },
      { name: "gps_latitude", label: "GPS Latitude", type: "decimal", min: -90, max: 90, step: "0.000001", nullable: true },
      { name: "gps_longitude", label: "GPS Longitude", type: "decimal", min: -180, max: 180, step: "0.000001", nullable: true },
      { name: "pic_name", label: "PIC Name", nullable: true },
      { name: "pic_phone", label: "PIC Phone", type: "tel", nullable: true, maxLength: 50 },
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
      { name: "user_id", label: "User Surveyor", type: "searchable-select", required: true, relation: { endpoint: "/users", labelKeys: ["name", "email"], query: { role: "surveyor", status: "active", without_surveyor_profile: "true" } } },
      { name: "name", label: "Full Name", required: true },
      { name: "phone", label: "Phone", type: "tel", nullable: true, maxLength: 50 },
      { name: "area", label: "Area", nullable: true },
      statusField
    ]
  },
  "customer-personnel": {
    id: "customer-personnel",
    title: "Personel/PIC Customer",
    description: "Personnel operasional milik Customer yang dapat dipilih sebagai PIC pekerjaan.",
    endpoint: "/master/customer-personnel",
    permissionModule: "customers",
    columns: [
      { key: "personnel_code", label: "Kode" },
      { key: "full_name", label: "Nama" },
      { key: "position_title", label: "Jabatan" },
      { key: "personnel_type", label: "Tipe" },
      { key: "phone", label: "Telepon" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "personnel_code", label: "Kode Personnel", required: true },
      { name: "full_name", label: "Nama Lengkap", required: true },
      { name: "position_title", label: "Jabatan", nullable: true },
      {
        name: "personnel_type",
        label: "Tipe Personnel",
        type: "select",
        required: true,
        options: ["pic", "surveyor", "approver", "billing", "other"].map((value) => ({ label: value, value }))
      },
      { name: "email", label: "Email", type: "email", nullable: true },
      { name: "phone", label: "Telepon", type: "tel", nullable: true, maxLength: 50 },
      { name: "notes", label: "Catatan", type: "textarea", nullable: true },
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
      { name: "iso_code", label: "ISO Code", nullable: true },
      { name: "size", label: "Size", required: true },
      { name: "type", label: "Type", required: true },
      { name: "description", label: "Description", type: "textarea", nullable: true },
      statusField
    ]
  },
  "fitness-owners": {
    id: "fitness-owners",
    title: "Pemilik Peti Kemas",
    description: "Master pemilik/client peti kemas untuk permohonan, dokumen, dan laporan kelaikan.",
    endpoint: "/fitness/master-data/owners",
    permissionModule: "customers",
    columns: [
      { key: "customer_code", label: "Kode" },
      { key: "customer_name", label: "Pemilik" },
      { key: "pic_name", label: "PIC" },
      { key: "pic_phone", label: "Telepon" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "customer_code", label: "Kode Pemilik", required: true },
      { name: "customer_name", label: "Nama Pemilik Peti Kemas", required: true },
      { name: "address", label: "Alamat", type: "textarea", nullable: true },
      { name: "npwp", label: "NPWP", nullable: true },
      { name: "pic_name", label: "Nama PIC", nullable: true },
      { name: "pic_phone", label: "Telepon PIC", type: "tel", nullable: true, maxLength: 50 },
      { name: "pic_email", label: "Email PIC", type: "email", nullable: true },
      { name: "billing_address", label: "Alamat Billing", type: "textarea", nullable: true },
      statusField
    ]
  },
  "fitness-manufacturers": {
    id: "fitness-manufacturers",
    title: "Pabrik Pembuat Peti Kemas",
    description: "Master pabrik pembuat peti kemas untuk data teknis dan dokumen persetujuan kelaikan.",
    endpoint: "/fitness/master-data/manufacturers",
    permissionModule: "container_manufacturers",
    columns: [
      { key: "manufacturer_code", label: "Kode" },
      { key: "manufacturer_name", label: "Pabrik" },
      { key: "country", label: "Negara" },
      { key: "pic_name", label: "PIC" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "manufacturer_code", label: "Kode Pabrik", required: true },
      { name: "manufacturer_name", label: "Nama Pabrik Pembuat", required: true },
      { name: "address", label: "Alamat", type: "textarea", nullable: true },
      { name: "country", label: "Negara", nullable: true },
      { name: "pic_name", label: "Nama PIC", nullable: true },
      { name: "pic_phone", label: "Telepon PIC", type: "tel", nullable: true, maxLength: 50 },
      { name: "pic_email", label: "Email PIC", type: "email", nullable: true },
      { name: "website", label: "Website", type: "url", nullable: true, maxLength: 150 },
      { name: "note", label: "Catatan", type: "textarea", nullable: true },
      statusField
    ]
  },
  "fitness-locations": {
    id: "fitness-locations",
    title: "Lokasi Pemeriksaan",
    description: "Master lokasi depo, pelabuhan, pabrik, gudang, dan lokasi lain untuk pemeriksaan kelaikan.",
    endpoint: "/fitness/master-data/locations",
    permissionModule: "locations",
    columns: [
      { key: "location_code", label: "Kode" },
      { key: "location_name", label: "Lokasi" },
      { key: "location_type", label: "Jenis" },
      { key: "city", label: "Kota" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "location_code", label: "Kode Lokasi", required: true },
      { name: "location_name", label: "Nama Lokasi", required: true },
      { name: "location_type", label: "Jenis Lokasi", type: "select", required: true, options: ["depot", "yard", "port", "warehouse", "factory", "customer_site", "other"].map((value) => ({ label: value, value })) },
      { name: "address", label: "Alamat", type: "textarea", nullable: true },
      { name: "city", label: "Kota", nullable: true },
      { name: "gps_latitude", label: "Latitude", type: "decimal", min: -90, max: 90, step: "0.000001", nullable: true },
      { name: "gps_longitude", label: "Longitude", type: "decimal", min: -180, max: 180, step: "0.000001", nullable: true },
      { name: "pic_name", label: "Nama PIC", nullable: true },
      { name: "pic_phone", label: "Telepon PIC", type: "tel", nullable: true, maxLength: 50 },
      statusField
    ]
  },
  "fitness-surveyors": {
    id: "fitness-surveyors",
    title: "Surveyor / Pemeriksa",
    description: "Master profil Surveyor atau Pemeriksa yang dapat dipakai pada assignment tahap berikutnya.",
    endpoint: "/fitness/master-data/surveyors",
    permissionModule: "surveyors",
    columns: [
      { key: "surveyor_code", label: "Kode" },
      { key: "name", label: "Nama" },
      { key: "phone", label: "Telepon" },
      { key: "area", label: "Area" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "user_id", label: "User Akun", type: "searchable-select", required: true, relation: { endpoint: "/users", labelKeys: ["name", "email"], query: { role: "surveyor", status: "active", without_surveyor_profile: "true" } } },
      { name: "surveyor_code", label: "Kode Surveyor", required: true },
      { name: "name", label: "Nama Lengkap", required: true },
      { name: "phone", label: "Telepon", type: "tel", nullable: true, maxLength: 50 },
      { name: "area", label: "Area Tugas", nullable: true },
      { name: "signature_file_id", label: "ID File Tanda Tangan", nullable: true, helpText: "Upload tanda tangan belum aktif - gunakan file ID sementara." },
      statusField
    ]
  },
  "fitness-container-types": {
    id: "fitness-container-types",
    title: "Jenis Peti Kemas",
    description: "Master jenis, ukuran, ISO code, dan model peti kemas untuk checklist dan dokumen kelaikan.",
    endpoint: "/fitness/master-data/container-types",
    permissionModule: "container_types",
    columns: [
      { key: "code", label: "Kode" },
      { key: "iso_code", label: "ISO" },
      { key: "size", label: "Ukuran" },
      { key: "type", label: "Nama Tipe" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Kode Jenis", required: true },
      { name: "iso_code", label: "ISO Code", nullable: true },
      { name: "size", label: "Ukuran", required: true },
      { name: "type", label: "Nama Tipe", required: true },
      { name: "description", label: "Deskripsi", type: "textarea", nullable: true },
      statusField
    ]
  },
  "fitness-approval-categories": {
    id: "fitness-approval-categories",
    title: "Kategori Persetujuan Kelaikan",
    description: "Master kategori proses kelaikan yang dapat dipakai pada scope MVP dan future scope.",
    endpoint: "/fitness/master-data/approval-categories",
    permissionModule: "fitness_approval_categories",
    columns: [
      { key: "code", label: "Kode" },
      { key: "name", label: "Kategori" },
      { key: "container_lifecycle", label: "Lifecycle" },
      { key: "is_mvp_active", label: "MVP", type: "boolean" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Kode Kategori", required: true },
      { name: "name", label: "Nama Kategori", required: true },
      { name: "description", label: "Deskripsi", type: "textarea", nullable: true },
      { name: "container_lifecycle", label: "Berlaku Untuk", type: "select", required: true, options: [{ label: "Peti Kemas Baru", value: "new" }, { label: "Peti Kemas Lama", value: "existing" }] },
      { name: "is_mvp_active", label: "Aktif di MVP", type: "checkbox", defaultValue: true },
      { name: "display_order", label: "Display Order", type: "number", min: 0, step: 1, omitWhenEmpty: true, defaultValue: 0 },
      statusField
    ]
  },
  "fitness-maintenance-schemes": {
    id: "fitness-maintenance-schemes",
    title: "Skema Pemeliharaan Peti Kemas",
    description: "Master skema pemeliharaan dan pemeriksaan berkala untuk data teknis dan dokumen kelaikan.",
    endpoint: "/fitness/master-data/maintenance-schemes",
    permissionModule: "maintenance_schemes",
    columns: [
      { key: "code", label: "Kode" },
      { key: "name", label: "Skema" },
      { key: "requires_next_examination_date", label: "Butuh NED", type: "boolean" },
      { key: "default_interval_months", label: "Interval" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Kode Skema", required: true },
      { name: "name", label: "Nama Skema", required: true },
      { name: "description", label: "Deskripsi", type: "textarea", nullable: true },
      { name: "requires_next_examination_date", label: "Membutuhkan Next Examination Date", type: "checkbox", defaultValue: false },
      { name: "default_interval_months", label: "Interval Pemeriksaan Default (bulan)", type: "number", min: 1, step: 1, nullable: true },
      statusField
    ]
  },
  "fitness-inspection-areas": {
    id: "fitness-inspection-areas",
    title: "Area Pemeriksaan Peti Kemas",
    description: "Master area peti kemas untuk referensi temuan, checklist, dan bukti foto.",
    endpoint: "/fitness/master-data/inspection-areas",
    permissionModule: "inspection_areas",
    columns: [
      { key: "code", label: "Kode" },
      { key: "area_name", label: "Area" },
      { key: "display_order", label: "Urutan" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Kode Area", required: true },
      { name: "area_name", label: "Nama Area", required: true },
      { name: "description", label: "Deskripsi", type: "textarea", nullable: true },
      { name: "display_order", label: "Urutan Tampil", type: "number", min: 0, step: 1, omitWhenEmpty: true, defaultValue: 0 },
      statusField
    ]
  },
  "fitness-structural-components": {
    id: "fitness-structural-components",
    title: "Komponen Struktur Peti Kemas",
    description: "Master komponen struktur yang akan dipakai sebagai referensi temuan pemeriksaan.",
    endpoint: "/fitness/master-data/structural-components",
    permissionModule: "structural_components",
    columns: [
      { key: "code", label: "Kode" },
      { key: "component_name", label: "Komponen" },
      { key: "inspection_area_label", label: "Area" },
      { key: "is_structural_critical", label: "Kritis", type: "boolean" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Kode Komponen", required: true },
      { name: "component_name", label: "Nama Komponen", required: true },
      { name: "inspection_area_id", label: "Area Pemeriksaan", type: "searchable-select", nullable: true, relation: { endpoint: "/fitness/master-data/inspection-areas", labelKeys: ["code", "area_name"] } },
      { name: "is_structural_critical", label: "Komponen Struktural Kritis", type: "checkbox", defaultValue: false },
      { name: "description", label: "Deskripsi", type: "textarea", nullable: true },
      { name: "display_order", label: "Urutan Tampil", type: "number", min: 0, step: 1, omitWhenEmpty: true, defaultValue: 0 },
      statusField
    ]
  },
  "fitness-damage-criteria": {
    id: "fitness-damage-criteria",
    title: "Kriteria Kerusakan / Ketidaksesuaian",
    description: "Master kriteria kerusakan atau ketidaksesuaian untuk referensi temuan pemeriksaan.",
    endpoint: "/fitness/master-data/damage-criteria",
    permissionModule: "structural_damage_criteria",
    columns: [
      { key: "code", label: "Kode" },
      { key: "criteria_name", label: "Kriteria" },
      { key: "severity_default", label: "Tingkat Keparahan" },
      { key: "affects_fitness_default", label: "Pengaruh Kelaikan", type: "boolean" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Kode Kriteria", required: true },
      { name: "criteria_name", label: "Nama Kriteria", required: true },
      { name: "component_id", label: "Komponen Terkait", type: "searchable-select", nullable: true, relation: { endpoint: "/fitness/master-data/structural-components", labelKeys: ["code", "component_name"] } },
      { name: "description", label: "Deskripsi", type: "textarea", nullable: true },
      { name: "severity_default", label: "Tingkat Keparahan Default", type: "select", omitWhenEmpty: true, defaultValue: "minor", options: ["minor", "major", "critical"].map((value) => ({ label: value, value })) },
      { name: "affects_fitness_default", label: "Default Memengaruhi Kelaikan", type: "checkbox", defaultValue: false },
      { name: "perbaikan_required_default", label: "Default Perlu Perbaikan", type: "checkbox", defaultValue: false },
      { name: "inspection_note", label: "Catatan Pemeriksaan", type: "textarea", nullable: true },
      statusField
    ]
  },
  "fitness-finding-severities": {
    id: "fitness-finding-severities",
    title: "Tingkat Keparahan",
    description: "Master tingkat temuan untuk menentukan risiko, review, dan keputusan kelaikan.",
    endpoint: "/fitness/master-data/finding-severities",
    permissionModule: "finding_severities",
    columns: [
      { key: "code", label: "Kode" },
      { key: "name", label: "Tingkat Keparahan" },
      { key: "level_no", label: "Level" },
      { key: "requires_supervisor_review", label: "Review", type: "boolean" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Kode Tingkat", required: true },
      { name: "name", label: "Nama Tingkat", required: true },
      { name: "description", label: "Deskripsi", type: "textarea", nullable: true },
      { name: "level_no", label: "Level Angka", type: "number", min: 1, step: 1, required: true },
      { name: "affects_fitness_default", label: "Default Memengaruhi Kelaikan", type: "checkbox", defaultValue: false },
      { name: "requires_supervisor_review", label: "Default Perlu Review Supervisor", type: "checkbox", defaultValue: false },
      { name: "badge_tone", label: "Warna Badge", type: "select", nullable: true, options: ["neutral", "success", "warning", "danger"].map((value) => ({ label: value, value })) },
      statusField
    ]
  },
  "fitness-test-parameters": {
    id: "fitness-test-parameters",
    title: "Parameter Pengujian Kelaikan",
    description: "Master parameter pengujian untuk referensi pemeriksaan dan dokumen kelaikan.",
    endpoint: "/fitness/master-data/test-parameters",
    permissionModule: "inspection_test_parameters",
    columns: [
      { key: "code", label: "Kode" },
      { key: "parameter_name", label: "Parameter" },
      { key: "requires_numeric_result", label: "Angka", type: "boolean" },
      { key: "requires_attachment", label: "Lampiran", type: "boolean" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Kode Parameter", required: true },
      { name: "parameter_name", label: "Nama Parameter", required: true },
      { name: "description", label: "Deskripsi", type: "textarea", nullable: true },
      { name: "unit", label: "Satuan", nullable: true },
      { name: "standard_reference", label: "Referensi Standar", nullable: true },
      { name: "applies_to_new_container", label: "Berlaku untuk Peti Kemas Baru", type: "checkbox", defaultValue: true },
      { name: "applies_to_existing_container", label: "Berlaku untuk Peti Kemas Lama", type: "checkbox", defaultValue: true },
      { name: "requires_numeric_result", label: "Wajib Hasil Angka", type: "checkbox", defaultValue: false },
      { name: "requires_attachment", label: "Wajib Lampiran/Foto", type: "checkbox", defaultValue: false },
      { name: "display_order", label: "Urutan Tampil", type: "number", min: 0, step: 1, omitWhenEmpty: true, defaultValue: 0 },
      statusField
    ]
  },
  "fitness-checklist-templates": {
    id: "fitness-checklist-templates",
    title: "Template Checklist Kelaikan",
    description: "Template checklist per Customer yang disnapshot saat Surveyor memulai pemeriksaan.",
    endpoint: "/fitness/master-data/checklist-templates",
    permissionModule: "fitness_checklist_templates",
    columns: [
      { key: "template_code", label: "Kode" },
      { key: "template_name", label: "Template" },
      { key: "version_no", label: "Versi" },
      { key: "approval_category_label", label: "Kategori" },
      { key: "container_type_label", label: "Jenis" },
      { key: "status", label: "Status", type: "status" }
    ],
    statusOptions: checklistStatusOptions,
    fields: [
      { name: "template_code", label: "Kode Template", required: true },
      { name: "template_name", label: "Nama Template", required: true },
      { name: "approval_category_id", label: "Kategori Persetujuan", type: "searchable-select", nullable: true, relation: { endpoint: "/fitness/master-data/approval-categories", labelKeys: ["code", "name"] } },
      { name: "survey_type_id", label: "Survey Type Customer", type: "searchable-select", required: true, relation: { endpoint: "/master/survey-types", labelKeys: ["code", "name"] } },
      { name: "container_type_id", label: "Container Type Customer", type: "searchable-select", required: true, relation: { endpoint: "/master/container-types", labelKeys: ["code", "type"] } },
      { name: "description", label: "Deskripsi", type: "textarea", nullable: true },
      { name: "version_no", label: "Versi", type: "number", min: 1, step: 1, omitWhenEmpty: true, defaultValue: 1 },
      { name: "status", label: "Status", type: "select", defaultValue: "draft", options: checklistStatusOptions }
    ]
  },
  "fitness-checklist-template-items": {
    id: "fitness-checklist-template-items",
    title: "Item Template Checklist Kelaikan",
    description: "CRUD item snapshot checklist yang dipakai pada flow Surveyor.",
    endpoint: "/fitness/master-data/checklist-templates",
    permissionModule: "fitness_checklist_templates",
    columns: [
      { key: "item_code", label: "Kode" },
      { key: "item_label", label: "Item" },
      { key: "inspection_area_label", label: "Area" },
      { key: "component_label", label: "Komponen" },
      { key: "response_type", label: "Response" },
      { key: "is_required", label: "Wajib", type: "boolean" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "template_id", label: "Template ID", type: "hidden" },
      { name: "item_code", label: "Kode Item", required: true },
      { name: "item_label", label: "Label Pertanyaan", required: true },
      { name: "description", label: "Deskripsi", type: "textarea", nullable: true },
      { name: "inspection_area_id", label: "Area Pemeriksaan", type: "searchable-select", nullable: true, relation: { endpoint: "/fitness/master-data/inspection-areas", labelKeys: ["code", "area_name"] } },
      { name: "structural_component_id", label: "Komponen Struktur", type: "searchable-select", nullable: true, relation: { endpoint: "/fitness/master-data/structural-components", labelKeys: ["code", "component_name"] } },
      { name: "test_parameter_id", label: "Parameter Pengujian", type: "searchable-select", nullable: true, relation: { endpoint: "/fitness/master-data/test-parameters", labelKeys: ["code", "parameter_name"] } },
      { name: "response_type", label: "Response Type", type: "select", required: true, defaultValue: "ok_not_ok", options: ["ok_not_ok", "yes_no", "text", "numeric", "date", "photo_required", "not_applicable"].map((value) => ({ label: value, value })) },
      { name: "expected_value", label: "Expected Value", nullable: true },
      { name: "is_required", label: "Wajib Diisi", type: "checkbox", defaultValue: true },
      { name: "is_critical", label: "Critical Item", type: "checkbox", defaultValue: false },
      { name: "fail_requires_repair", label: "Jika Gagal Perlu Perbaikan", type: "checkbox", defaultValue: false },
      { name: "fail_marks_unfit", label: "Jika Gagal Tidak Layak", type: "checkbox", defaultValue: false },
      { name: "display_order", label: "Urutan Tampil", type: "number", min: 0, step: 1, omitWhenEmpty: true, defaultValue: 0 },
      statusField
    ]
  },
  "fitness-photo-categories": {
    id: "fitness-photo-categories",
    title: "Kategori Bukti Foto",
    description: "Master kategori bukti foto untuk pemeriksaan, temuan, pengujian, perbaikan, dan pemeriksaan ulang.",
    endpoint: "/fitness/master-data/photo-categories",
    permissionModule: "evidence_photo_categories",
    columns: [
      { key: "code", label: "Kode" },
      { key: "name", label: "Kategori" },
      { key: "applies_to", label: "Berlaku Untuk" },
      { key: "is_required_default", label: "Wajib", type: "boolean" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Kode Kategori Bukti Foto", required: true },
      { name: "name", label: "Nama Kategori Bukti Foto", required: true },
      { name: "description", label: "Deskripsi", type: "textarea", nullable: true },
      { name: "is_required_default", label: "Wajib Default", type: "checkbox", defaultValue: false },
      { name: "applies_to", label: "Berlaku Untuk", type: "select", nullable: true, options: ["inspection", "finding", "test", "perbaikan", "reinspection", "document"].map((value) => ({ label: value, value })) },
      { name: "display_order", label: "Urutan Tampil", type: "number", min: 0, step: 1, omitWhenEmpty: true, defaultValue: 0 },
      statusField
    ]
  },
  "fitness-inspection-recommendations": {
    id: "fitness-inspection-recommendations",
    title: "Rekomendasi Hasil Pemeriksaan",
    description: "Master rekomendasi hasil pemeriksaan untuk referensi review kelaikan di tahap berikutnya.",
    endpoint: "/fitness/master-data/inspection-recommendations",
    permissionModule: "inspection_recommendations",
    columns: [
      { key: "code", label: "Kode" },
      { key: "name", label: "Rekomendasi" },
      { key: "final_fitness_result_mapping", label: "Hasil" },
      { key: "requires_supervisor_review", label: "Review", type: "boolean" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Kode Rekomendasi", required: true },
      { name: "name", label: "Nama Rekomendasi", required: true },
      { name: "description", label: "Deskripsi", type: "textarea", nullable: true },
      { name: "final_fitness_result_mapping", label: "Hasil Akhir Kelaikan Mapping", type: "select", omitWhenEmpty: true, defaultValue: "pending", options: ["pending", "fit", "unfit"].map((value) => ({ label: value, value })) },
      { name: "workflow_status_mapping", label: "Tahap Proses Mapping", nullable: true },
      { name: "restriction_status_mapping", label: "Status Pembatasan Mapping", type: "select", nullable: true, options: ["none", "suspended", "prohibited", "released"].map((value) => ({ label: value, value })) },
      { name: "requires_supervisor_review", label: "Perlu Review Supervisor", type: "checkbox", defaultValue: true },
      statusField
    ]
  },
  "fitness-authorized-signers": {
    id: "fitness-authorized-signers",
    title: "Pejabat Penandatangan",
    description: "Master pejabat yang berwenang menandatangani dokumen kelaikan.",
    endpoint: "/fitness/master-data/authorized-signers",
    permissionModule: "authorized_signers",
    columns: [
      { key: "signer_name", label: "Nama" },
      { key: "position_title", label: "Jabatan" },
      { key: "employee_no", label: "NIP / ID" },
      { key: "email", label: "Email" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "signer_name", label: "Nama Pejabat", required: true },
      { name: "position_title", label: "Jabatan", required: true },
      { name: "employee_no", label: "NIP / ID Pegawai", nullable: true },
      { name: "email", label: "Email", type: "email", nullable: true },
      { name: "phone", label: "Nomor Telepon", type: "tel", nullable: true, maxLength: 50 },
      { name: "signature_file_id", label: "ID File Tanda Tangan", nullable: true, helpText: "Upload tanda tangan belum aktif - gunakan file ID sementara." },
      { name: "valid_from", label: "Berlaku Mulai", type: "date", nullable: true },
      { name: "valid_until", label: "Berlaku Sampai", type: "date", nullable: true },
      statusField
    ]
  },
  "fitness-company-profile": {
    id: "fitness-company-profile",
    title: "Profil Badan Usaha",
    description: "Master profil badan usaha untuk header dokumen, surat persetujuan, validasi dokumen, dan laporan.",
    endpoint: "/fitness/master-data/company-profile",
    permissionModule: "company_profiles",
    columns: [
      { key: "company_name", label: "Badan Usaha" },
      { key: "brand_name", label: "Brand" },
      { key: "phone", label: "Telepon" },
      { key: "email", label: "Email" },
      { key: "is_active", label: "Aktif", type: "boolean" }
    ],
    statusOptions: commonStatusOptions,
    fields: [
      { name: "company_name", label: "Nama Badan Usaha", required: true },
      { name: "brand_name", label: "Brand", nullable: true },
      { name: "address", label: "Alamat", type: "textarea", nullable: true },
      { name: "phone", label: "Telepon", type: "tel", nullable: true, maxLength: 50 },
      { name: "email", label: "Email", type: "email", nullable: true },
      { name: "website", label: "Website", type: "url", nullable: true, maxLength: 150 },
      { name: "tax_no", label: "Nomor Pajak", nullable: true },
      { name: "logo_file_id", label: "ID File Logo", nullable: true, helpText: "Upload file belum aktif - gunakan file ID sementara." },
      { name: "default_signature_file_id", label: "ID File Tanda Tangan Default", nullable: true, helpText: "Upload file belum aktif - gunakan file ID sementara." },
      { name: "is_active", label: "Status Aktif", type: "checkbox", defaultValue: true }
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
      { name: "description", label: "Description", type: "textarea", nullable: true },
      { name: "requires_eir", label: "Requires EIR", type: "checkbox" },
      { name: "requires_light_test", label: "Requires Light Test", type: "checkbox" },
      { name: "requires_cargo_worthy_result", label: "Requires Cargo Worthy Result", type: "checkbox" },
      statusField
    ]
  },
  "cedex-locations": {
    id: "cedex-locations",
    title: "Master CEDEX Location",
    description: "Grid locations used to place container damage markers.",
    endpoint: "/master/cedex/locations",
    permissionModule: "cedex_locations",
    columns: [
      { key: "code", label: "Code" },
      { key: "face", label: "Face" },
      { key: "grid_code", label: "Grid" },
      { key: "container_size", label: "Container Size" },
      { key: "display_order", label: "Order" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Code", required: true },
      { name: "face", label: "Face", type: "select", required: true, options: ["left", "right", "front", "door", "roof", "floor", "understructure"].map((value) => ({ label: value, value })) },
      { name: "grid_code", label: "Grid Code", required: true },
      { name: "cedex_mapping_code", label: "CEDEX Mapping Code" },
      { name: "container_size", label: "Container Size", type: "select", options: ["all", "20", "40", "45"].map((value) => ({ label: value, value })) },
      { name: "description", label: "Description", type: "textarea", nullable: true },
      { name: "display_order", label: "Display Order", type: "number", required: true },
      statusField
    ]
  },
  "cedex-components": codeNameResource("cedex-components", "Master CEDEX Component", "CEDEX component references for survey damage records.", "/master/cedex/components", "cedex_components", "component_name", "Component Name"),
  "cedex-damages": codeNameResource("cedex-damages", "Master CEDEX Damage", "Damage code references used by surveyors.", "/master/cedex/damages", "cedex_damages", "damage_name", "Damage Name"),
  "cedex-repairs": codeNameResource("cedex-repairs", "Master Action Repair Code", "Action Repair hanya menjadi referensi teknis atau rekomendasi tindakan.", "/master/cedex/repairs", "cedex_repairs", "repair_name", "Action Name"),
  "cedex-materials": codeNameResource("cedex-materials", "Master CEDEX Material", "Material references used by survey damage records.", "/master/cedex/materials", "cedex_materials", "material_name", "Material Name"),
  "responsibility-codes": codeNameResource("responsibility-codes", "Master Responsibility Code", "Responsibility codes used by survey damage records.", "/master/responsibility-codes", "responsibility_codes", "name", "Name")
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
      { name: "description", label: "Description", type: "textarea", nullable: true },
      statusField
    ]
  };
}
