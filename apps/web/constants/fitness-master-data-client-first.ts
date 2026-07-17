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
  "cedex-repair": "cedex/repairs",
  "cedex-material": "cedex/materials",
  "responsibility-code": "responsibility-codes"
};

export const fitnessMasterDataCategoryConfigs: readonly FitnessMasterDataCategoryConfig[] = [
  config({ id: "customer", slug: "customers", label: "Customer", description: "Customer adalah perusahaan atau organisasi pengguna jasa inspeksi GIFT.", searchPlaceholder: "Nama atau kode Customer", codeLabel: "Kode Customer", nameLabel: "Nama Perusahaan/Organisasi", descriptionLabel: "Catatan Admin", addLabel: "Tambah Customer", emptyTitle: "Customer belum tersedia" }),
  config({ id: "location", slug: "locations", label: "Location", description: "Location Customer yang digunakan untuk pemeriksaan.", searchPlaceholder: "Kode, nama, kota, atau PIC", codeLabel: "Kode Location", nameLabel: "Nama Location", descriptionLabel: "Catatan Akses", addLabel: "Tambah Location", emptyTitle: "Location Customer belum tersedia" }),
  config({ id: "surveyor", slug: "surveyors", label: "Surveyor", description: "Surveyor Customer, bukan Surveyor GIFT.", searchPlaceholder: "Kode, nama, jabatan, atau Location", codeLabel: "Kode Surveyor", nameLabel: "Nama Lengkap", descriptionLabel: "Jabatan", addLabel: "Tambah Surveyor", emptyTitle: "Surveyor Customer belum tersedia", notice: "Surveyor GIFT dikelola pada Pengaturan Internal GIFT dan Penugasan Surveyor GIFT." }),
  config({ id: "container-type", slug: "container-types", label: "Container Type", description: "Referensi Container Type Customer, bukan peti kemas individual.", searchPlaceholder: "Kode, nama, ukuran, atau deskripsi", codeLabel: "Kode Container Type", nameLabel: "Nama Container Type", descriptionLabel: "Deskripsi", addLabel: "Tambah Container Type", emptyTitle: "Container Type Customer belum tersedia" }),
  config({ id: "survey-type", slug: "survey-types", label: "Survey Type", description: "Referensi jenis layanan atau pemeriksaan milik Customer.", searchPlaceholder: "Kode, nama, atau deskripsi", codeLabel: "Kode Survey Type", nameLabel: "Nama Survey Type", descriptionLabel: "Deskripsi", addLabel: "Tambah Survey Type", emptyTitle: "Survey Type Customer belum tersedia", referenceCategory: "survey-type", referenceVariant: "survey-type", notice: "Survey Type hanya menjadi referensi pemilihan. Status proses dikendalikan sistem." }),
  config({ id: "cedex-location", slug: "cedex-locations", label: "CEDEX Location", description: "Referensi teknis CEDEX Location milik Customer.", searchPlaceholder: "Kode, face, grid, mapping, atau ukuran", codeLabel: "Kode CEDEX Location", nameLabel: "Grid Code", descriptionLabel: "Deskripsi", addLabel: "Tambah CEDEX Location", emptyTitle: "CEDEX Location Customer belum tersedia", referenceCategory: "cedex-location", referenceVariant: "cedex-location", notice: "Field teknis mengikuti struktur CEDEX Location legacy yang terverifikasi." }),
  config({ id: "cedex-component", slug: "cedex-components", label: "CEDEX Component", description: "Referensi teknis CEDEX Component milik Customer.", searchPlaceholder: "Kode, nama Component, atau deskripsi", codeLabel: "Kode CEDEX Component", nameLabel: "Nama Component", descriptionLabel: "Deskripsi", addLabel: "Tambah CEDEX Component", emptyTitle: "CEDEX Component Customer belum tersedia", referenceCategory: "cedex-component", referenceVariant: "named" }),
  config({ id: "cedex-damage", slug: "cedex-damages", label: "CEDEX Damage", description: "Referensi teknis CEDEX Damage milik Customer.", searchPlaceholder: "Kode, nama Damage, atau deskripsi", codeLabel: "Kode CEDEX Damage", nameLabel: "Nama Damage", descriptionLabel: "Deskripsi", addLabel: "Tambah CEDEX Damage", emptyTitle: "CEDEX Damage Customer belum tersedia", referenceCategory: "cedex-damage", referenceVariant: "named" }),
  config({ id: "cedex-repair", slug: "cedex-repairs", label: "CEDEX Repair", description: "Referensi teknis CEDEX Repair milik Customer.", searchPlaceholder: "Kode, nama Repair, atau deskripsi", codeLabel: "Kode CEDEX Repair", nameLabel: "Nama Repair", descriptionLabel: "Deskripsi", addLabel: "Tambah CEDEX Repair", emptyTitle: "CEDEX Repair Customer belum tersedia", referenceCategory: "cedex-repair", referenceVariant: "named", notice: "CEDEX Repair hanya referensi teknis; bukan workshop, proses perbaikan, biaya, invoice, spare part, inventori, atau vendor billing." }),
  config({ id: "cedex-material", slug: "cedex-materials", label: "CEDEX Material", description: "Referensi teknis CEDEX Material milik Customer.", searchPlaceholder: "Kode, nama Material, atau deskripsi", codeLabel: "Kode CEDEX Material", nameLabel: "Nama Material", descriptionLabel: "Deskripsi", addLabel: "Tambah CEDEX Material", emptyTitle: "CEDEX Material Customer belum tersedia", referenceCategory: "cedex-material", referenceVariant: "named", notice: "CEDEX Material hanya referensi teknis; bukan inventori, stok, harga, pembelian, atau pengeluaran material." }),
  config({ id: "responsibility-code", slug: "responsibility-codes", label: "Responsibility Code", description: "Referensi Responsibility Code Customer.", searchPlaceholder: "Code, nama/label, atau deskripsi", codeLabel: "Responsibility Code", nameLabel: "Nama/Label Responsibility", descriptionLabel: "Deskripsi", addLabel: "Tambah Responsibility Code", emptyTitle: "Responsibility Code Customer belum tersedia", referenceCategory: "responsibility-code", referenceVariant: "named", notice: "Responsibility Code pada tahap ini hanya referensi Master Data Customer." })
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
  return routeFamily === "actual" ? `${indexHref}/customer/${customerId}` : `${indexHref}/${customerId}`;
}

export function customerCreateHref(routeFamily: MasterDataRouteFamily = "fitness") {
  return masterDataIndexHref("customer", routeFamily) + "/create";
}

function config(value: FitnessMasterDataCategoryConfig): FitnessMasterDataCategoryConfig {
  return value;
}
