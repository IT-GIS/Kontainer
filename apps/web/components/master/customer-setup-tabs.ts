export type CustomerSetupTab =
  | "profile"
  | "location-pic"
  | "survey-sheet"
  | "checklist"
  | "references"
  | "photo-evidence"
  | "cedex"
  | "readiness";

export const customerSetupTabs: Array<{ id: CustomerSetupTab; label: string; description: string }> = [
  { id: "profile", label: "Profil", description: "Identitas dan status Customer" },
  { id: "location-pic", label: "Lokasi & PIC", description: "Location, Personel/PIC, dan mapping" },
  { id: "survey-sheet", label: "Konfigurasi Survey Sheet", description: "Survey Type, Container Type, lokasi, dan sumber field" },
  { id: "checklist", label: "Checklist", description: "Template dan item pemeriksaan" },
  { id: "references", label: "Referensi Pemeriksaan", description: "Mapping referensi per Survey Type" },
  { id: "photo-evidence", label: "Kebutuhan Foto / Evidence", description: "Requirement per Survey Type dari master aktif" },
  { id: "cedex", label: "Konfigurasi CEDEX Customer", description: "Override Customer dan Global fallback" },
  { id: "readiness", label: "Kesiapan", description: "Validasi backend dan CTA pekerjaan" }
];
