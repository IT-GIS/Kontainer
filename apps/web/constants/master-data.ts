export type MasterField = {
  name: string;
  label: string;
  type?: "text" | "number" | "select" | "checkbox" | "email";
  required?: boolean;
  options?: Array<{ label: string; value: string }>;
  defaultValue?: string | number | boolean;
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
      { name: "user_id", label: "User Surveyor", required: true },
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
      { name: "address", label: "Alamat" },
      { name: "npwp", label: "NPWP" },
      { name: "pic_name", label: "Nama PIC" },
      { name: "pic_phone", label: "Telepon PIC" },
      { name: "pic_email", label: "Email PIC", type: "email" },
      { name: "billing_address", label: "Alamat Billing" },
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
      { name: "address", label: "Alamat" },
      { name: "country", label: "Negara" },
      { name: "pic_name", label: "Nama PIC" },
      { name: "pic_phone", label: "Telepon PIC" },
      { name: "pic_email", label: "Email PIC", type: "email" },
      { name: "website", label: "Website" },
      { name: "note", label: "Catatan" },
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
      { name: "address", label: "Alamat" },
      { name: "city", label: "Kota" },
      { name: "gps_latitude", label: "Latitude", type: "number" },
      { name: "gps_longitude", label: "Longitude", type: "number" },
      { name: "pic_name", label: "Nama PIC" },
      { name: "pic_phone", label: "Telepon PIC" },
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
      { name: "user_id", label: "User Akun", required: true },
      { name: "surveyor_code", label: "Kode Surveyor", required: true },
      { name: "name", label: "Nama Lengkap", required: true },
      { name: "phone", label: "Telepon" },
      { name: "area", label: "Area Tugas" },
      { name: "signature_file_id", label: "ID File Tanda Tangan" },
      statusField
    ]
  },
  "fitness-container-types": {
    id: "fitness-container-types",
    title: "Jenis / Model Peti Kemas",
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
      { name: "iso_code", label: "ISO Code" },
      { name: "size", label: "Ukuran", required: true },
      { name: "type", label: "Nama Tipe", required: true },
      { name: "description", label: "Deskripsi" },
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
      { name: "description", label: "Deskripsi" },
      { name: "container_lifecycle", label: "Berlaku Untuk", type: "select", required: true, options: [{ label: "Peti Kemas Baru", value: "new" }, { label: "Peti Kemas Lama", value: "existing" }] },
      { name: "is_mvp_active", label: "Aktif di MVP", type: "checkbox" },
      { name: "display_order", label: "Display Order", type: "number" },
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
      { name: "description", label: "Deskripsi" },
      { name: "requires_next_examination_date", label: "Membutuhkan Next Examination Date", type: "checkbox" },
      { name: "default_interval_months", label: "Interval Pemeriksaan Default (bulan)", type: "number" },
      statusField
    ]
  },
  "fitness-inspection-areas": {
    id: "fitness-inspection-areas",
    title: "Area Pemeriksaan Peti Kemas",
    description: "Master area peti kemas untuk referensi temuan, checklist, dan foto evidence.",
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
      { name: "description", label: "Deskripsi" },
      { name: "display_order", label: "Urutan Tampil", type: "number" },
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
      { key: "inspection_area_id", label: "ID Area" },
      { key: "is_structural_critical", label: "Kritis", type: "boolean" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Kode Komponen", required: true },
      { name: "component_name", label: "Nama Komponen", required: true },
      { name: "inspection_area_id", label: "ID Area Pemeriksaan" },
      { name: "is_structural_critical", label: "Komponen Struktural Kritis", type: "checkbox" },
      { name: "description", label: "Deskripsi" },
      { name: "display_order", label: "Urutan Tampil", type: "number" },
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
      { key: "severity_default", label: "Severity" },
      { key: "affects_fitness_default", label: "Pengaruh Kelaikan", type: "boolean" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Kode Kriteria", required: true },
      { name: "criteria_name", label: "Nama Kriteria", required: true },
      { name: "component_id", label: "ID Komponen Terkait" },
      { name: "description", label: "Deskripsi" },
      { name: "severity_default", label: "Tingkat Temuan Default", type: "select", options: ["minor", "major", "critical"].map((value) => ({ label: value, value })) },
      { name: "affects_fitness_default", label: "Default Memengaruhi Kelaikan", type: "checkbox" },
      { name: "repair_required_default", label: "Default Perlu Perbaikan", type: "checkbox" },
      { name: "inspection_note", label: "Catatan Pemeriksaan" },
      statusField
    ]
  },
  "fitness-finding-severities": {
    id: "fitness-finding-severities",
    title: "Tingkat Temuan / Severity",
    description: "Master tingkat temuan untuk menentukan risiko, review, dan keputusan kelaikan.",
    endpoint: "/fitness/master-data/finding-severities",
    permissionModule: "finding_severities",
    columns: [
      { key: "code", label: "Kode" },
      { key: "name", label: "Severity" },
      { key: "level_no", label: "Level" },
      { key: "requires_supervisor_review", label: "Review", type: "boolean" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "code", label: "Kode Severity", required: true },
      { name: "name", label: "Nama Severity", required: true },
      { name: "description", label: "Deskripsi" },
      { name: "level_no", label: "Level Angka", type: "number", required: true },
      { name: "affects_fitness_default", label: "Default Memengaruhi Kelaikan", type: "checkbox" },
      { name: "requires_supervisor_review", label: "Default Perlu Review Supervisor", type: "checkbox" },
      { name: "badge_tone", label: "Warna Badge", type: "select", options: ["neutral", "success", "warning", "danger"].map((value) => ({ label: value, value })) },
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
      { name: "description", label: "Deskripsi" },
      { name: "unit", label: "Satuan" },
      { name: "standard_reference", label: "Referensi Standar" },
      { name: "applies_to_new_container", label: "Berlaku untuk Peti Kemas Baru", type: "checkbox", defaultValue: true },
      { name: "applies_to_existing_container", label: "Berlaku untuk Peti Kemas Lama", type: "checkbox", defaultValue: true },
      { name: "requires_numeric_result", label: "Wajib Hasil Angka", type: "checkbox" },
      { name: "requires_attachment", label: "Wajib Lampiran/Foto", type: "checkbox" },
      { name: "display_order", label: "Urutan Tampil", type: "number" },
      statusField
    ]
  },
  "fitness-checklist-templates": {
    id: "fitness-checklist-templates",
    title: "Template Checklist Kelaikan",
    description: "CRUD header template checklist kelaikan. Item checklist tetap menjadi placeholder terpisah untuk tahap berikutnya.",
    endpoint: "/fitness/master-data/checklist-templates",
    permissionModule: "fitness_checklist_templates",
    columns: [
      { key: "template_code", label: "Kode" },
      { key: "template_name", label: "Template" },
      { key: "version_no", label: "Versi" },
      { key: "status", label: "Status", type: "status" }
    ],
    fields: [
      { name: "template_code", label: "Kode Template", required: true },
      { name: "template_name", label: "Nama Template", required: true },
      { name: "approval_category_id", label: "ID Kategori Persetujuan" },
      { name: "container_type_id", label: "ID Jenis / Model Peti Kemas" },
      { name: "description", label: "Deskripsi" },
      { name: "version_no", label: "Versi", type: "number", defaultValue: 1 },
      { name: "status", label: "Status", type: "select", defaultValue: "draft", options: [{ label: "Draft", value: "draft" }, { label: "Active", value: "active" }, { label: "Inactive", value: "inactive" }] }
    ]
  },
  "fitness-photo-categories": {
    id: "fitness-photo-categories",
    title: "Kategori Foto Evidence",
    description: "Master kategori foto evidence untuk pemeriksaan, temuan, pengujian, repair, dan re-inspection.",
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
      { name: "code", label: "Kode Kategori Foto", required: true },
      { name: "name", label: "Nama Kategori Foto", required: true },
      { name: "description", label: "Deskripsi" },
      { name: "is_required_default", label: "Wajib Default", type: "checkbox" },
      { name: "applies_to", label: "Berlaku Untuk" },
      { name: "display_order", label: "Urutan Tampil", type: "number" },
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
      { name: "description", label: "Deskripsi" },
      { name: "final_fitness_result_mapping", label: "Final Fitness Result Mapping", type: "select", options: ["pending", "fit", "unfit"].map((value) => ({ label: value, value })) },
      { name: "workflow_status_mapping", label: "Workflow Status Mapping" },
      { name: "restriction_status_mapping", label: "Restriction Status Mapping", type: "select", options: ["none", "suspended", "prohibited"].map((value) => ({ label: value, value })) },
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
      { name: "employee_no", label: "NIP / ID Pegawai" },
      { name: "email", label: "Email", type: "email" },
      { name: "phone", label: "Nomor Telepon" },
      { name: "signature_file_id", label: "ID File Tanda Tangan" },
      { name: "valid_from", label: "Berlaku Mulai" },
      { name: "valid_until", label: "Berlaku Sampai" },
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
    fields: [
      { name: "company_name", label: "Nama Badan Usaha", required: true },
      { name: "brand_name", label: "Brand" },
      { name: "address", label: "Alamat" },
      { name: "phone", label: "Telepon" },
      { name: "email", label: "Email", type: "email" },
      { name: "website", label: "Website" },
      { name: "tax_no", label: "Nomor Pajak" },
      { name: "logo_file_id", label: "ID File Logo" },
      { name: "default_signature_file_id", label: "ID File Tanda Tangan Default" },
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
      { name: "description", label: "Description" },
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
      { name: "description", label: "Description" },
      { name: "display_order", label: "Display Order", type: "number", required: true },
      statusField
    ]
  },
  "cedex-components": codeNameResource("cedex-components", "Master CEDEX Component", "CEDEX component references for survey damage records.", "/master/cedex/components", "cedex_components", "component_name", "Component Name"),
  "cedex-damages": codeNameResource("cedex-damages", "Master CEDEX Damage", "Damage code references used by surveyors.", "/master/cedex/damages", "cedex_damages", "damage_name", "Damage Name"),
  "cedex-repairs": codeNameResource("cedex-repairs", "Master CEDEX Repair", "Repair action code references used in damage records.", "/master/cedex/repairs", "cedex_repairs", "repair_name", "Repair Name"),
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
      { name: "description", label: "Description" },
      statusField
    ]
  };
}
