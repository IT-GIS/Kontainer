import type {
  FitnessCedexContainerSize,
  FitnessCedexFace,
  FitnessClientCedexLocationReference,
  FitnessClientContainerType,
  FitnessClientDetail,
  FitnessClientInspectionReference,
  FitnessClientLocation,
  FitnessClientMasterDataReference,
  FitnessClientNamedMasterDataReference,
  FitnessClientNamedReferenceCategory,
  FitnessClientPersonnel,
  FitnessClientSurveyTypeReference,
  FitnessClientSurveyor
} from "@/types/fitness-admin";

export const fitnessClients: FitnessClientDetail[] = [
  {
    id: "client-nusantara",
    code: "CL-001",
    name: "PT Nusantara Logistik",
    shortName: "Nusantara Logistik",
    addressShort: "Tanjung Priok, Jakarta Utara",
    city: "Jakarta Utara",
    province: "DKI Jakarta",
    primaryContactName: "Rina Prameswari",
    primaryContactTitle: "Manajer Operasional",
    email: "rina.prameswari@example.test",
    phone: "+62 21 555 0101",
    locationCount: 3,
    personnelCount: 2,
    containerTypeCount: 3,
    referenceCount: 7,
    containerCount: 18,
    status: "Aktif",
    completeness: "Lengkap",
    updatedAt: "14 Juli 2026, 09.15 WIB",
    address: "Jl. Pelabuhan Nusantara No. 18, Tanjung Priok, Jakarta Utara",
    postalCode: "14310",
    legalIdentity: "Identitas perusahaan tersedia pada arsip Customer.",
    adminNotes: "Customer aktif untuk demonstrasi frontend.",
    accessInformation: "Akses Location mengikuti konfirmasi PIC Customer."
  },
  {
    id: "client-samudra",
    code: "CL-002",
    name: "PT Samudra Jaya Terminal",
    shortName: "Samudra Jaya",
    addressShort: "Tanjung Perak, Surabaya",
    city: "Surabaya",
    province: "Jawa Timur",
    primaryContactName: "Arief Setiawan",
    primaryContactTitle: "Kepala Terminal",
    email: "arief.setiawan@example.test",
    phone: "+62 31 555 0202",
    locationCount: 2,
    personnelCount: 2,
    containerTypeCount: 2,
    referenceCount: 7,
    containerCount: 11,
    status: "Aktif",
    completeness: "Belum Lengkap",
    updatedAt: "13 Juli 2026, 16.40 WIB",
    address: "Jl. Terminal Samudra No. 27, Tanjung Perak, Surabaya",
    postalCode: "60165",
    legalIdentity: "Identitas perusahaan menunggu verifikasi Admin.",
    adminNotes: "Lengkapi catatan akses lokasi kedua.",
    accessInformation: "Konfirmasi kedatangan melalui PIC utama."
  },
  {
    id: "client-arsip",
    code: "CL-003",
    name: "PT Arsip Kontainer Indonesia",
    shortName: "Arsip Kontainer",
    addressShort: "Cakung, Jakarta Timur",
    city: "Jakarta Timur",
    province: "DKI Jakarta",
    primaryContactName: "Dewi Lestari",
    primaryContactTitle: "PIC Arsip",
    email: "dewi.lestari@example.test",
    phone: "+62 21 555 0303",
    locationCount: 0,
    personnelCount: 0,
    containerTypeCount: 0,
    referenceCount: 0,
    containerCount: 0,
    status: "Tidak Aktif",
    completeness: "Belum Lengkap",
    updatedAt: "17 Juli 2026, 10.00 WIB",
    address: "Jl. Arsip Kontainer No. 3, Cakung, Jakarta Timur",
    postalCode: "13910",
    legalIdentity: "Customer dinonaktifkan untuk skenario read-only frontend.",
    adminNotes: "Fixture frontend untuk verifikasi Customer tidak aktif.",
    accessInformation: "Akses operasional dinonaktifkan."
  }
];

export const fitnessClientLocations: FitnessClientLocation[] = [
  location("nl-loc-1", "client-nusantara", "NL-JKT-01", "Depo Nusantara Priok", "Depo", "Tanjung Priok", "Jakarta Utara", "DKI Jakarta", "Rina Prameswari", "+62 21 555 0111"),
  location("nl-loc-2", "client-nusantara", "NL-JKT-02", "Gudang Marunda", "Gudang", "Marunda", "Jakarta Utara", "DKI Jakarta", "Dimas Kurnia", "+62 21 555 0112"),
  location("nl-loc-3", "client-nusantara", "NL-BKS-01", "Area Pemeriksaan Cibitung", "Lokasi Pemeriksaan", "Cibitung", "Bekasi", "Jawa Barat", "Nadia Putri", "+62 21 555 0113"),
  location("sj-loc-1", "client-samudra", "SJ-SBY-01", "Terminal Samudra Perak", "Terminal", "Tanjung Perak", "Surabaya", "Jawa Timur", "Arief Setiawan", "+62 31 555 0211"),
  location("sj-loc-2", "client-samudra", "SJ-SBY-02", "Lokasi Pemeriksaan Margomulyo", "Lokasi Pemeriksaan", "Margomulyo", "Surabaya", "Jawa Timur", "Maya Lestari", "+62 31 555 0212", "Tidak Aktif")
];

export const fitnessClientPersonnel: FitnessClientPersonnel[] = [
  personnel("nl-pic-1", "client-nusantara", "Rina Prameswari", "Manajer Operasional", "PIC Utama", ["nl-loc-1", "nl-loc-2"], ["Depo Nusantara Priok", "Gudang Marunda"], "rina.prameswari@example.test", "+62 21 555 0101"),
  personnel("nl-pic-2", "client-nusantara", "Dimas Kurnia", "Koordinator Depo", "PIC Lokasi", ["nl-loc-2"], ["Gudang Marunda"], "dimas.kurnia@example.test", "+62 21 555 0102"),
  personnel("sj-pic-1", "client-samudra", "Arief Setiawan", "Kepala Terminal", "PIC Utama", ["sj-loc-1"], ["Terminal Samudra Perak"], "arief.setiawan@example.test", "+62 31 555 0202"),
  personnel("sj-pic-2", "client-samudra", "Maya Lestari", "Koordinator Teknis", "Personel Teknis", ["sj-loc-2"], ["Lokasi Pemeriksaan Margomulyo"], "maya.lestari@example.test", "+62 31 555 0203")
];

export const fitnessClientContainerTypes: FitnessClientContainerType[] = [
  containerType("nl-type-1", "client-nusantara", "NL-20-GP", "General Purpose 20 ft", "20 ft", "Referensi Container Type Customer NL."),
  containerType("nl-type-2", "client-nusantara", "NL-40-HC", "High Cube 40 ft", "40 ft", "Referensi Container Type Customer NL."),
  containerType("nl-type-3", "client-nusantara", "NL-20-RF", "Reefer 20 ft", "20 ft", "Referensi Container Type berpendingin Customer NL."),
  containerType("sj-type-1", "client-samudra", "SJ-20-OT", "Open Top 20 ft", "20 ft", "Referensi Container Type Customer SJ."),
  containerType("sj-type-2", "client-samudra", "SJ-40-GP", "General Purpose 40 ft", "40 ft", "Referensi Container Type Customer SJ.")
];

export const fitnessClientSurveyors: FitnessClientSurveyor[] = [
  surveyor("nl-surveyor-1", "client-nusantara", "NL-SRV-01", "Nadia Putri", "Surveyor Internal Customer", ["nl-loc-1", "nl-loc-3"], ["Depo Nusantara Priok", "Area Pemeriksaan Cibitung"], "nadia.putri@example.test", "+62 21 555 0131"),
  surveyor("nl-surveyor-2", "client-nusantara", "NL-SRV-02", "Bagas Pratama", "Pemeriksa Teknis Customer", ["nl-loc-2"], ["Gudang Marunda"], "bagas.pratama@example.test", "+62 21 555 0132"),
  surveyor("sj-surveyor-1", "client-samudra", "SJ-SRV-01", "Maya Lestari", "Surveyor Internal Customer", ["sj-loc-1"], ["Terminal Samudra Perak"], "maya.lestari@example.test", "+62 31 555 0231")
];

export const fitnessClientMasterDataReferences: FitnessClientMasterDataReference[] = [
  surveyTypeReference("nl-survey-type-1", "client-nusantara", "NL-ST-01", "Pemeriksaan Berkala", "Jenis layanan pemeriksaan berkala Customer Nusantara.", true, false, true),
  surveyTypeReference("nl-survey-type-2", "client-nusantara", "NL-ST-02", "Pemeriksaan Kondisi", "Jenis layanan pemeriksaan kondisi Customer Nusantara.", false, true, false, "Tidak Aktif"),
  surveyTypeReference("sj-survey-type-1", "client-samudra", "SJ-ST-01", "Pemeriksaan Awal", "Jenis layanan pemeriksaan awal Customer Samudra.", true, true, false),

  cedexLocationReference("nl-cedex-location-1", "client-nusantara", "NL-CL-01", "roof", "R1", "UR", "all", "Grid struktur atas Customer Nusantara.", 1),
  cedexLocationReference("nl-cedex-location-2", "client-nusantara", "NL-CL-02", "floor", "F1", "LR", "40", "Grid struktur bawah Customer Nusantara.", 2, "Tidak Aktif"),
  cedexLocationReference("sj-cedex-location-1", "client-samudra", "SJ-CL-01", "left", "L1", "SS", "20", "Grid sisi Customer Samudra.", 1),

  namedReference("nl-cedex-component-1", "client-nusantara", "cedex-component", "NL-CC-01", "Roof Panel", "Komponen CEDEX Customer Nusantara."),
  namedReference("nl-cedex-component-2", "client-nusantara", "cedex-component", "NL-CC-02", "Corner Post", "Komponen CEDEX Customer Nusantara."),
  namedReference("sj-cedex-component-1", "client-samudra", "cedex-component", "SJ-CC-01", "Side Panel", "Komponen CEDEX Customer Samudra."),

  namedReference("nl-cedex-damage-1", "client-nusantara", "cedex-damage", "NL-CD-01", "Bent", "Damage CEDEX Customer Nusantara."),
  namedReference("nl-cedex-damage-2", "client-nusantara", "cedex-damage", "NL-CD-02", "Cracked", "Damage CEDEX Customer Nusantara.", "Tidak Aktif"),
  namedReference("sj-cedex-damage-1", "client-samudra", "cedex-damage", "SJ-CD-01", "Dented", "Damage CEDEX Customer Samudra."),

  namedReference("nl-cedex-action-1", "client-nusantara", "cedex-action", "NL-CR-01", "Straighten", "Referensi repair CEDEX Customer Nusantara."),
  namedReference("nl-cedex-action-2", "client-nusantara", "cedex-action", "NL-CR-02", "Weld", "Referensi repair CEDEX Customer Nusantara."),
  namedReference("sj-cedex-action-1", "client-samudra", "cedex-action", "SJ-CR-01", "Patch", "Referensi repair CEDEX Customer Samudra."),

  namedReference("nl-cedex-material-1", "client-nusantara", "cedex-material", "NL-CM-01", "Steel", "Referensi material CEDEX Customer Nusantara."),
  namedReference("nl-cedex-material-2", "client-nusantara", "cedex-material", "NL-CM-02", "Aluminium", "Referensi material CEDEX Customer Nusantara."),
  namedReference("sj-cedex-material-1", "client-samudra", "cedex-material", "SJ-CM-01", "Plywood", "Referensi material CEDEX Customer Samudra."),

  namedReference("nl-responsibility-1", "client-nusantara", "responsibility-code", "NL-RC-01", "Customer Reference A", "Label Responsibility Code Customer Nusantara tanpa aturan bisnis tambahan."),
  namedReference("nl-responsibility-2", "client-nusantara", "responsibility-code", "NL-RC-02", "Customer Reference B", "Label Responsibility Code Customer Nusantara tanpa aturan bisnis tambahan.", "Tidak Aktif"),
  namedReference("sj-responsibility-1", "client-samudra", "responsibility-code", "SJ-RC-01", "Customer Reference S", "Label Responsibility Code Customer Samudra tanpa aturan bisnis tambahan.")
];

export const fitnessClientInspectionReferences: FitnessClientInspectionReference[] = [
  reference("nl-ref-area", "client-nusantara", "inspection-areas", "NL-AREA-01", "Area Pemeriksaan Nusantara", "Referensi area Customer NL.", 1),
  reference("nl-ref-component", "client-nusantara", "structural-components", "NL-COMP-01", "Komponen Referensi Nusantara", "Referensi komponen Customer NL.", 2),
  reference("nl-ref-damage", "client-nusantara", "damage-criteria", "NL-DMG-01", "Kriteria Ketidaksesuaian Nusantara", "Label presentasi tanpa keputusan otomatis.", 3),
  reference("nl-ref-severity", "client-nusantara", "finding-severities", "NL-SEV-01", "Tingkat Referensi Nusantara", "Label visual tanpa dampak workflow backend.", 4),
  reference("nl-ref-test", "client-nusantara", "test-parameters", "NL-TEST-01", "Parameter Referensi Nusantara", "Tidak memuat nilai batas atau regulasi.", 5),
  reference("nl-ref-photo", "client-nusantara", "photo-categories", "NL-PHOTO-01", "Kategori Bukti Nusantara", "Kategori presentasi bukti foto.", 6, true),
  reference("nl-ref-recommendation", "client-nusantara", "inspection-recommendations", "NL-REC-01", "Rekomendasi Referensi Nusantara", "Teks referensi tanpa keputusan otomatis.", 7),
  reference("sj-ref-area", "client-samudra", "inspection-areas", "SJ-AREA-01", "Area Pemeriksaan Samudra", "Referensi area Customer SJ.", 1),
  reference("sj-ref-component", "client-samudra", "structural-components", "SJ-COMP-01", "Komponen Referensi Samudra", "Referensi komponen Customer SJ.", 2),
  reference("sj-ref-damage", "client-samudra", "damage-criteria", "SJ-DMG-01", "Kriteria Ketidaksesuaian Samudra", "Label presentasi tanpa keputusan otomatis.", 3),
  reference("sj-ref-severity", "client-samudra", "finding-severities", "SJ-SEV-01", "Tingkat Referensi Samudra", "Label visual tanpa dampak workflow backend.", 4),
  reference("sj-ref-test", "client-samudra", "test-parameters", "SJ-TEST-01", "Parameter Referensi Samudra", "Tidak memuat nilai batas atau regulasi.", 5),
  reference("sj-ref-photo", "client-samudra", "photo-categories", "SJ-PHOTO-01", "Kategori Bukti Samudra", "Kategori presentasi bukti foto.", 6, false),
  reference("sj-ref-recommendation", "client-samudra", "inspection-recommendations", "SJ-REC-01", "Rekomendasi Referensi Samudra", "Teks referensi tanpa keputusan otomatis.", 7)
];

function location(id: string, clientId: string, code: string, name: string, type: FitnessClientLocation["type"], address: string, city: string, province: string, contactName: string, phone: string, status: FitnessClientLocation["status"] = "Aktif"): FitnessClientLocation {
  return { id, clientId, code, name, type, address, city, province, postalCode: "-", contactName, phone, email: code.toLowerCase() + "@example.test", accessNotes: "Konfirmasi akses melalui PIC Customer.", status, updatedAt: "14 Juli 2026" };
}

function personnel(id: string, clientId: string, name: string, title: string, type: FitnessClientPersonnel["type"], locationIds: string[], locationNames: string[], email: string, phone: string): FitnessClientPersonnel {
  return { id, clientId, name, title, type, locationIds, locationNames, email, phone, status: "Aktif", updatedAt: "14 Juli 2026" };
}

function containerType(id: string, clientId: string, code: string, name: string, size: string, description: string): FitnessClientContainerType {
  return { id, clientId, code, name, size, description, status: "Aktif", updatedAt: "14 Juli 2026" };
}

function surveyor(
  id: string,
  clientId: string,
  code: string,
  name: string,
  title: string,
  locationIds: string[],
  locationNames: string[],
  email: string,
  phone: string
): FitnessClientSurveyor {
  return { id, clientId, code, name, title, locationIds, locationNames, email, phone, status: "Aktif", updatedAt: "14 Juli 2026" };
}

function surveyTypeReference(
  id: string,
  clientId: string,
  code: string,
  name: string,
  description: string,
  requiresEir: boolean,
  requiresLightTest: boolean,
  requiresCargoWorthyResult: boolean,
  status: FitnessClientSurveyTypeReference["status"] = "Aktif"
): FitnessClientSurveyTypeReference {
  return { id, clientId, category: "survey-type", code, name, description, requiresEir, requiresLightTest, requiresCargoWorthyResult, status, updatedAt: "14 Juli 2026" };
}

function cedexLocationReference(
  id: string,
  clientId: string,
  code: string,
  face: FitnessCedexFace,
  gridCode: string,
  cedexMappingCode: string,
  containerSize: FitnessCedexContainerSize,
  description: string,
  displayOrder: number,
  status: FitnessClientCedexLocationReference["status"] = "Aktif"
): FitnessClientCedexLocationReference {
  return { id, clientId, category: "cedex-location", code, face, gridCode, cedexMappingCode, containerSize, description, displayOrder, status, updatedAt: "14 Juli 2026" };
}

function namedReference(
  id: string,
  clientId: string,
  category: FitnessClientNamedReferenceCategory,
  code: string,
  name: string,
  description: string,
  status: FitnessClientNamedMasterDataReference["status"] = "Aktif"
): FitnessClientNamedMasterDataReference {
  return { id, clientId, category, code, name, description, status, updatedAt: "14 Juli 2026" };
}

function reference(id: string, clientId: string, section: FitnessClientInspectionReference["section"], code: string, name: string, description: string, order: number, presentationRequired?: boolean): FitnessClientInspectionReference {
  return { id, clientId, section, code, name, description, order, presentationRequired, status: "Aktif", updatedAt: "14 Juli 2026" };
}
