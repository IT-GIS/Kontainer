import type {
  FitnessClientReferenceCategory,
  FitnessMasterDataCategory,
  FitnessMasterDataCategorySlug
} from "@/types/fitness-admin";

export type FitnessMasterDataCategoryConfig = {
  id: FitnessMasterDataCategory;
  slug: FitnessMasterDataCategorySlug;
  label: string;
  description: string;
  searchPlaceholder: string;
  codeLabel: string;
  nameLabel: string;
  descriptionLabel: string;
  addLabel: string;
  emptyTitle: string;
  permissionModule: string;
  referenceCategory?: FitnessClientReferenceCategory;
  referenceVariant?: "survey-type" | "cedex-location" | "named";
  notice?: string;
};

export type MasterDataRouteFamily = "fitness" | "actual";

const actualMasterDataPaths: Record<FitnessMasterDataCategory, string> = {
  customer: "customers",
  location: "locations",
  surveyor: "surveyors",
  "container-type": "container-types",
  "survey-type": "survey-types",
  "cedex-location": "cedex/locations",
  "cedex-component": "cedex/components",
  "cedex-damage": "cedex/damages",
  "cedex-action": "iso-cedex?tab=action",
  "cedex-reference": "iso-cedex?tab=reference",
  "cedex-material": "cedex/materials",
  "responsibility-code": "responsibility-codes"
};

export const fitnessMasterDataCategoryConfigs: readonly FitnessMasterDataCategoryConfig[] = [
  config({ id: "customer", slug: "customers", label: "Customer", description: "Customer adalah perusahaan atau organisasi pengguna jasa inspeksi GIFT.", searchPlaceholder: "Nama atau kode Customer", codeLabel: "Kode Customer", nameLabel: "Nama Perusahaan/Organisasi", descriptionLabel: "Catatan Admin", addLabel: "Tambah Customer", emptyTitle: "Customer belum tersedia", permissionModule: "customers" }),
  config({ id: "location", slug: "locations", label: "Location", description: "Location Customer yang digunakan untuk pemeriksaan.", searchPlaceholder: "Kode, nama, kota, atau PIC", codeLabel: "Kode Location", nameLabel: "Nama Location", descriptionLabel: "Catatan Akses", addLabel: "Tambah Location", emptyTitle: "Location Customer belum tersedia", permissionModule: "locations" }),
  config({ id: "surveyor", slug: "surveyors", label: "Personel/PIC Customer", description: "Personel operasional atau PIC milik Customer, bukan Surveyor GIFT.", searchPlaceholder: "Kode, nama, jabatan, atau Location", codeLabel: "Kode Personel", nameLabel: "Nama Lengkap", descriptionLabel: "Jabatan", addLabel: "Tambah Personel/PIC Customer", emptyTitle: "Personel/PIC Customer belum tersedia", permissionModule: "surveyors", notice: "Surveyor GIFT dikelola terpisah pada Pengaturan dan Penugasan Surveyor GIFT." }),
  config({ id: "container-type", slug: "container-types", label: "Container Type", description: "Referensi Container Type Customer, bukan peti kemas individual.", searchPlaceholder: "Kode, nama, ukuran, atau deskripsi", codeLabel: "Kode Container Type", nameLabel: "Nama Container Type", descriptionLabel: "Deskripsi", addLabel: "Tambah Container Type", emptyTitle: "Container Type Customer belum tersedia", permissionModule: "container_types" }),
  config({ id: "survey-type", slug: "survey-types", label: "Survey Type", description: "Referensi jenis pemeriksaan legacy milik Customer.", searchPlaceholder: "Kode, nama, atau deskripsi", codeLabel: "Kode Survey Type", nameLabel: "Nama Survey Type", descriptionLabel: "Deskripsi", addLabel: "Tambah Survey Type", emptyTitle: "Survey Type Customer belum tersedia", permissionModule: "survey_types", referenceCategory: "survey-type", referenceVariant: "survey-type", notice: "Survey Type lama dipertahankan baca-saja. Job memilih otomatis hanya bila tersedia tepat satu tipe aktif." }),
  config({ id: "cedex-location", slug: "cedex-locations", label: "CEDEX Location", description: "Referensi teknis CEDEX Location milik Customer.", searchPlaceholder: "Kode, face, grid, mapping, atau ukuran", codeLabel: "Kode CEDEX Location", nameLabel: "Grid Code", descriptionLabel: "Deskripsi", addLabel: "Tambah CEDEX Location", emptyTitle: "CEDEX Location Customer belum tersedia", permissionModule: "cedex_locations", referenceCategory: "cedex-location", referenceVariant: "cedex-location", notice: "Gunakan kode lokasi yang telah disahkan dalam referensi teknis GIFT." }),
  config({ id: "cedex-component", slug: "cedex-components", label: "CEDEX Component", description: "Referensi teknis CEDEX Component milik Customer.", searchPlaceholder: "Kode, nama Component, atau deskripsi", codeLabel: "Kode CEDEX Component", nameLabel: "Nama Component", descriptionLabel: "Deskripsi", addLabel: "Tambah CEDEX Component", emptyTitle: "CEDEX Component Customer belum tersedia", permissionModule: "cedex_components", referenceCategory: "cedex-component", referenceVariant: "named" }),
  config({ id: "cedex-damage", slug: "cedex-damages", label: "CEDEX Damage", description: "Referensi teknis CEDEX Damage milik Customer.", searchPlaceholder: "Kode, nama Damage, atau deskripsi", codeLabel: "Kode CEDEX Damage", nameLabel: "Nama Damage", descriptionLabel: "Deskripsi", addLabel: "Tambah CEDEX Damage", emptyTitle: "CEDEX Damage Customer belum tersedia", permissionModule: "cedex_damages", referenceCategory: "cedex-damage", referenceVariant: "named" }),
  config({ id: "cedex-action", slug: "cedex-actions", label: "Action Code", description: "Referensi teknis tindakan atau rekomendasi inspeksi milik Customer.", searchPlaceholder: "Kode, nama Action, atau deskripsi", codeLabel: "Action Code", nameLabel: "Rekomendasi Tindakan", descriptionLabel: "Deskripsi", addLabel: "Tambah Action Code", emptyTitle: "Action Code Customer belum tersedia", permissionModule: "cedex_repairs", referenceCategory: "cedex-action", referenceVariant: "named", notice: "Action Code menggunakan resource CEDEX Repair existing sebagai penyimpanan internal." }),
  config({ id: "cedex-reference", slug: "cedex-references", label: "Inspection Reference", description: "Presentasi master global Test Parameter untuk referensi inspeksi.", searchPlaceholder: "Kode, parameter, standard reference, atau deskripsi", codeLabel: "Reference Code", nameLabel: "Inspection Parameter", descriptionLabel: "Standard Reference", addLabel: "Tambah Inspection Reference", emptyTitle: "Inspection Reference belum tersedia", permissionModule: "inspection_test_parameters", referenceCategory: "cedex-reference", referenceVariant: "named", notice: "Ketersediaan bagi Surveyor mengikuti mapping Customer dan Survey Type existing." }),
  config({ id: "cedex-material", slug: "cedex-materials", label: "CEDEX Material", description: "Referensi teknis CEDEX Material milik Customer.", searchPlaceholder: "Kode, nama Material, atau deskripsi", codeLabel: "Kode CEDEX Material", nameLabel: "Nama Material", descriptionLabel: "Deskripsi", addLabel: "Tambah CEDEX Material", emptyTitle: "CEDEX Material Customer belum tersedia", permissionModule: "cedex_materials", referenceCategory: "cedex-material", referenceVariant: "named", notice: "CEDEX Material hanya referensi teknis; bukan inventori, stok, harga, pembelian, atau pengeluaran material." }),
  config({ id: "responsibility-code", slug: "responsibility-codes", label: "Responsibility Code (Legacy)", description: "Referensi legacy yang hanya dipertahankan untuk membaca hasil pemeriksaan lama.", searchPlaceholder: "Code, nama/label, atau deskripsi", codeLabel: "Responsibility Code", nameLabel: "Nama/Label Responsibility", descriptionLabel: "Deskripsi", addLabel: "Tambah Responsibility Code", emptyTitle: "Responsibility Code legacy belum tersedia", permissionModule: "responsibility_codes", referenceCategory: "responsibility-code", referenceVariant: "named", notice: "Temuan baru tidak lagi meminta Responsibility Code." })
];

export function getFitnessMasterDataCategoryConfig(slug: string) {
  return fitnessMasterDataCategoryConfigs.find((item) => item.slug === slug);
}

export function getFitnessMasterDataCategoryConfigByID(category: FitnessMasterDataCategory) {
  return fitnessMasterDataCategoryConfigs.find((item) => item.id === category)!;
}

export function fitnessMasterDataIndexHref(category: FitnessMasterDataCategory) {
  return masterDataIndexHref(category, "fitness");
}

export function fitnessMasterDataDetailHref(category: FitnessMasterDataCategory, clientId: string) {
  return masterDataDetailHref(category, clientId, "fitness");
}

export function masterDataIndexHref(category: FitnessMasterDataCategory, routeFamily: MasterDataRouteFamily = "fitness") {
  const config = getFitnessMasterDataCategoryConfigByID(category);
  return routeFamily === "actual"
    ? "/master/" + actualMasterDataPaths[category]
    : "/fitness/master-data/" + config.slug;
}

export function masterDataDetailHref(category: FitnessMasterDataCategory, customerId: string, routeFamily: MasterDataRouteFamily = "fitness") {
  const indexHref = masterDataIndexHref(category, routeFamily);
  if (routeFamily === "actual" && indexHref.includes("?")) {
    return `${indexHref}&customerId=${encodeURIComponent(customerId)}`;
  }
  return routeFamily === "actual" ? `${indexHref}/customer/${customerId}` : `${indexHref}/${customerId}`;
}

export function customerCreateHref(routeFamily: MasterDataRouteFamily = "fitness") {
  return masterDataIndexHref("customer", routeFamily) + "/create";
}

function config(value: FitnessMasterDataCategoryConfig): FitnessMasterDataCategoryConfig {
  return value;
}
