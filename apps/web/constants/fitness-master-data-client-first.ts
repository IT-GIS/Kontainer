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
  addLabel: string;
  emptyTitle: string;
  referenceCategory?: FitnessClientReferenceCategory;
  notice?: string;
};

export const fitnessMasterDataCategoryConfigs: readonly FitnessMasterDataCategoryConfig[] = [
  config("customer", "customers", "Customer", "Perusahaan atau organisasi pengguna jasa inspeksi GIFT.", "Nama atau kode Customer", "Tambah Customer", "Customer belum tersedia"),
  config("location", "locations", "Location", "Lokasi milik atau yang digunakan Customer untuk pemeriksaan.", "Kode, nama, kota, atau PIC", "Tambah Location", "Location belum tersedia"),
  config("surveyor", "surveyors", "Surveyor", "Surveyor Customer, bukan Surveyor GIFT.", "Kode, nama, jabatan, atau Location", "Tambah Surveyor", "Surveyor Customer belum tersedia", undefined, "Surveyor pada Master Data adalah pihak Customer. Surveyor GIFT tetap terpisah."),
  config("container-type", "container-types", "Container Type", "Referensi jenis peti kemas milik Customer.", "Kode, nama, ukuran, atau deskripsi", "Tambah Container Type", "Container Type belum tersedia"),
  config("survey-type", "survey-types", "Survey Type", "Referensi jenis layanan atau pemeriksaan milik Customer.", "Kode, nama, atau deskripsi", "Tambah Survey Type", "Survey Type belum tersedia", "survey-type", "Survey Type bukan status atau transisi workflow."),
  config("cedex-location", "cedex-locations", "CEDEX Location", "Referensi teknis CEDEX Location milik Customer.", "Kode, nama, atau deskripsi", "Tambah CEDEX Location", "CEDEX Location belum tersedia", "cedex-location"),
  config("cedex-component", "cedex-components", "CEDEX Component", "Referensi teknis CEDEX Component milik Customer.", "Kode, nama, atau deskripsi", "Tambah CEDEX Component", "CEDEX Component belum tersedia", "cedex-component"),
  config("cedex-damage", "cedex-damages", "CEDEX Damage", "Referensi teknis CEDEX Damage milik Customer.", "Kode, nama, atau deskripsi", "Tambah CEDEX Damage", "CEDEX Damage belum tersedia", "cedex-damage"),
  config("cedex-repair", "cedex-repairs", "CEDEX Repair", "Referensi teknis CEDEX Repair milik Customer.", "Kode, nama, atau deskripsi", "Tambah CEDEX Repair", "CEDEX Repair belum tersedia", "cedex-repair", "Referensi teknis saja; bukan workshop, biaya, spare part, atau operasional bengkel."),
  config("cedex-material", "cedex-materials", "CEDEX Material", "Referensi teknis CEDEX Material milik Customer.", "Kode, nama, atau deskripsi", "Tambah CEDEX Material", "CEDEX Material belum tersedia", "cedex-material", "Referensi teknis saja; bukan inventori, stok, harga, atau pembelian."),
  config("responsibility-code", "responsibility-codes", "Responsibility Code", "Referensi Responsibility Code milik Customer.", "Kode, nama, atau deskripsi", "Tambah Responsibility Code", "Responsibility Code belum tersedia", "responsibility-code", "Referensi frontend tanpa aturan keputusan, biaya, penagihan, atau tanggung jawab hukum.")
];

export function getFitnessMasterDataCategoryConfig(slug: string) {
  return fitnessMasterDataCategoryConfigs.find((item) => item.slug === slug);
}

export function getFitnessMasterDataCategoryConfigByID(category: FitnessMasterDataCategory) {
  return fitnessMasterDataCategoryConfigs.find((item) => item.id === category)!;
}

export function fitnessMasterDataCategoryHref(category: FitnessMasterDataCategory, clientId?: string) {
  const config = getFitnessMasterDataCategoryConfigByID(category);
  return "/fitness/master-data/" + config.slug + (clientId ? "/" + clientId : "");
}

function config(
  id: FitnessMasterDataCategory,
  slug: FitnessMasterDataCategorySlug,
  label: string,
  description: string,
  searchPlaceholder: string,
  addLabel: string,
  emptyTitle: string,
  referenceCategory?: FitnessClientReferenceCategory,
  notice?: string
): FitnessMasterDataCategoryConfig {
  return { id, slug, label, description, searchPlaceholder, addLabel, emptyTitle, referenceCategory, notice };
}
