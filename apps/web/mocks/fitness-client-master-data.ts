import type {
  FitnessClientContainerType,
  FitnessClientDetail,
  FitnessClientInspectionReference,
  FitnessClientLocation,
  FitnessClientMasterDataReference,
  FitnessClientMasterSummary,
  FitnessClientPersonnel,
  FitnessClientReferenceCategory,
  FitnessClientSurveyor,
  FitnessLegacyMappingRecord
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
    legalIdentity: "Identitas perusahaan tersedia pada arsip klien.",
    adminNotes: "Klien aktif untuk demonstrasi UI-B.2.",
    accessInformation: "Akses lokasi mengikuti konfirmasi PIC klien."
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
  containerType("nl-type-1", "client-nusantara", "NL-20-GP", "General Purpose 20 ft", "20 ft", "Referensi jenis peti kemas milik Klien NL."),
  containerType("nl-type-2", "client-nusantara", "NL-40-HC", "High Cube 40 ft", "40 ft", "Referensi jenis peti kemas milik Klien NL."),
  containerType("nl-type-3", "client-nusantara", "NL-20-RF", "Reefer 20 ft", "20 ft", "Referensi jenis peti kemas berpendingin milik Klien NL."),
  containerType("sj-type-1", "client-samudra", "SJ-20-OT", "Open Top 20 ft", "20 ft", "Referensi jenis peti kemas milik Klien SJ."),
  containerType("sj-type-2", "client-samudra", "SJ-40-GP", "General Purpose 40 ft", "40 ft", "Referensi jenis peti kemas milik Klien SJ.")
];

export const fitnessClientSurveyors: FitnessClientSurveyor[] = [
  surveyor("nl-surveyor-1", "client-nusantara", "NL-SRV-01", "Nadia Putri", "Surveyor Internal Customer", ["nl-loc-1", "nl-loc-3"], ["Depo Nusantara Priok", "Area Pemeriksaan Cibitung"], "nadia.putri@example.test", "+62 21 555 0131"),
  surveyor("nl-surveyor-2", "client-nusantara", "NL-SRV-02", "Bagas Pratama", "Pemeriksa Teknis Customer", ["nl-loc-2"], ["Gudang Marunda"], "bagas.pratama@example.test", "+62 21 555 0132"),
  surveyor("sj-surveyor-1", "client-samudra", "SJ-SRV-01", "Maya Lestari", "Surveyor Internal Customer", ["sj-loc-1"], ["Terminal Samudra Perak"], "maya.lestari@example.test", "+62 31 555 0231")
];

export const fitnessClientMasterDataReferences: FitnessClientMasterDataReference[] = [
  masterReference("nl-survey-type-1", "client-nusantara", "survey-type", "NL-ST-01", "Pemeriksaan Berkala", "Jenis layanan pemeriksaan berkala milik Customer Nusantara."),
  masterReference("nl-survey-type-2", "client-nusantara", "survey-type", "NL-ST-02", "Pemeriksaan Kondisi", "Jenis layanan pemeriksaan kondisi milik Customer Nusantara."),
  masterReference("sj-survey-type-1", "client-samudra", "survey-type", "SJ-ST-01", "Pemeriksaan Awal", "Jenis layanan pemeriksaan awal milik Customer Samudra."),

  masterReference("nl-cedex-location-1", "client-nusantara", "cedex-location", "NL-CL-01", "Upper Structure", "Referensi teknis lokasi CEDEX Customer Nusantara."),
  masterReference("nl-cedex-location-2", "client-nusantara", "cedex-location", "NL-CL-02", "Lower Structure", "Referensi teknis lokasi CEDEX Customer Nusantara."),
  masterReference("sj-cedex-location-1", "client-samudra", "cedex-location", "SJ-CL-01", "Side Structure", "Referensi teknis lokasi CEDEX Customer Samudra."),

  masterReference("nl-cedex-component-1", "client-nusantara", "cedex-component", "NL-CC-01", "Roof Panel", "Referensi teknis komponen CEDEX Customer Nusantara."),
  masterReference("nl-cedex-component-2", "client-nusantara", "cedex-component", "NL-CC-02", "Corner Post", "Referensi teknis komponen CEDEX Customer Nusantara."),
  masterReference("sj-cedex-component-1", "client-samudra", "cedex-component", "SJ-CC-01", "Side Panel", "Referensi teknis komponen CEDEX Customer Samudra."),

  masterReference("nl-cedex-damage-1", "client-nusantara", "cedex-damage", "NL-CD-01", "Bent", "Referensi teknis damage CEDEX Customer Nusantara."),
  masterReference("nl-cedex-damage-2", "client-nusantara", "cedex-damage", "NL-CD-02", "Cracked", "Referensi teknis damage CEDEX Customer Nusantara."),
  masterReference("sj-cedex-damage-1", "client-samudra", "cedex-damage", "SJ-CD-01", "Dented", "Referensi teknis damage CEDEX Customer Samudra."),

  masterReference("nl-cedex-repair-1", "client-nusantara", "cedex-repair", "NL-CR-01", "Straighten", "Referensi teknis repair CEDEX Customer Nusantara."),
  masterReference("nl-cedex-repair-2", "client-nusantara", "cedex-repair", "NL-CR-02", "Weld", "Referensi teknis repair CEDEX Customer Nusantara."),
  masterReference("sj-cedex-repair-1", "client-samudra", "cedex-repair", "SJ-CR-01", "Patch", "Referensi teknis repair CEDEX Customer Samudra."),

  masterReference("nl-cedex-material-1", "client-nusantara", "cedex-material", "NL-CM-01", "Steel", "Referensi teknis material CEDEX Customer Nusantara."),
  masterReference("nl-cedex-material-2", "client-nusantara", "cedex-material", "NL-CM-02", "Aluminium", "Referensi teknis material CEDEX Customer Nusantara."),
  masterReference("sj-cedex-material-1", "client-samudra", "cedex-material", "SJ-CM-01", "Plywood", "Referensi teknis material CEDEX Customer Samudra."),

  masterReference("nl-responsibility-1", "client-nusantara", "responsibility-code", "NL-RC-01", "Customer Reference A", "Label Responsibility Code Customer Nusantara tanpa aturan bisnis tambahan."),
  masterReference("nl-responsibility-2", "client-nusantara", "responsibility-code", "NL-RC-02", "Customer Reference B", "Label Responsibility Code Customer Nusantara tanpa aturan bisnis tambahan."),
  masterReference("sj-responsibility-1", "client-samudra", "responsibility-code", "SJ-RC-01", "Customer Reference S", "Label Responsibility Code Customer Samudra tanpa aturan bisnis tambahan.")
];

export const fitnessClientInspectionReferences: FitnessClientInspectionReference[] = [
  reference("nl-ref-area", "client-nusantara", "inspection-areas", "NL-AREA-01", "Area Pemeriksaan Nusantara", "Referensi area milik Klien NL.", 1),
  reference("nl-ref-component", "client-nusantara", "structural-components", "NL-COMP-01", "Komponen Referensi Nusantara", "Referensi komponen milik Klien NL.", 2),
  reference("nl-ref-damage", "client-nusantara", "damage-criteria", "NL-DMG-01", "Kriteria Ketidaksesuaian Nusantara", "Label presentasi tanpa keputusan otomatis.", 3),
  reference("nl-ref-severity", "client-nusantara", "finding-severities", "NL-SEV-01", "Tingkat Referensi Nusantara", "Label visual tanpa dampak workflow backend.", 4),
  reference("nl-ref-test", "client-nusantara", "test-parameters", "NL-TEST-01", "Parameter Referensi Nusantara", "Tidak memuat nilai batas atau regulasi.", 5),
  reference("nl-ref-photo", "client-nusantara", "photo-categories", "NL-PHOTO-01", "Kategori Bukti Nusantara", "Kategori presentasi bukti foto.", 6, true),
  reference("nl-ref-recommendation", "client-nusantara", "inspection-recommendations", "NL-REC-01", "Rekomendasi Referensi Nusantara", "Teks referensi tanpa keputusan otomatis.", 7),
  reference("sj-ref-area", "client-samudra", "inspection-areas", "SJ-AREA-01", "Area Pemeriksaan Samudra", "Referensi area milik Klien SJ.", 1),
  reference("sj-ref-component", "client-samudra", "structural-components", "SJ-COMP-01", "Komponen Referensi Samudra", "Referensi komponen milik Klien SJ.", 2),
  reference("sj-ref-damage", "client-samudra", "damage-criteria", "SJ-DMG-01", "Kriteria Ketidaksesuaian Samudra", "Label presentasi tanpa keputusan otomatis.", 3),
  reference("sj-ref-severity", "client-samudra", "finding-severities", "SJ-SEV-01", "Tingkat Referensi Samudra", "Label visual tanpa dampak workflow backend.", 4),
  reference("sj-ref-test", "client-samudra", "test-parameters", "SJ-TEST-01", "Parameter Referensi Samudra", "Tidak memuat nilai batas atau regulasi.", 5),
  reference("sj-ref-photo", "client-samudra", "photo-categories", "SJ-PHOTO-01", "Kategori Bukti Samudra", "Kategori presentasi bukti foto.", 6, false),
  reference("sj-ref-recommendation", "client-samudra", "inspection-recommendations", "SJ-REC-01", "Rekomendasi Referensi Samudra", "Teks referensi tanpa keputusan otomatis.", 7)
];

export const fitnessLegacyMappings: FitnessLegacyMappingRecord[] = [
  legacy("nl-leg-location", "client-nusantara", "location", "NL-OLD-LOC", "Lokasi Lama Nusantara", "Depo Nusantara Priok"),
  legacy("nl-leg-component", "client-nusantara", "component", "NL-OLD-COMP", "Komponen Lama Nusantara", "Komponen Referensi Nusantara"),
  legacy("nl-leg-damage", "client-nusantara", "damage", "NL-OLD-DMG", "Damage Lama Nusantara", "Kriteria Ketidaksesuaian Nusantara"),
  legacy("nl-leg-material", "client-nusantara", "material", "NL-OLD-MAT", "Material Lama Nusantara", null),
  legacy("sj-leg-location", "client-samudra", "location", "SJ-OLD-LOC", "Lokasi Lama Samudra", "Terminal Samudra Perak"),
  legacy("sj-leg-component", "client-samudra", "component", "SJ-OLD-COMP", "Komponen Lama Samudra", "Komponen Referensi Samudra"),
  legacy("sj-leg-damage", "client-samudra", "damage", "SJ-OLD-DMG", "Damage Lama Samudra", null),
  legacy("sj-leg-material", "client-samudra", "material", "SJ-OLD-MAT", "Material Lama Samudra", null)
];

export const fitnessClientMasterSummaries: FitnessClientMasterSummary[] = fitnessClients.map((client) => ({
  clientId: client.id,
  activeLocationCount: fitnessClientLocations.filter((item) => item.clientId === client.id && item.status === "Aktif").length,
  activePersonnelCount: fitnessClientPersonnel.filter((item) => item.clientId === client.id && item.status === "Aktif").length,
  containerTypeCount: fitnessClientContainerTypes.filter((item) => item.clientId === client.id).length,
  inspectionReferenceCount: fitnessClientInspectionReferences.filter((item) => item.clientId === client.id).length,
  legacyMappingCount: fitnessLegacyMappings.filter((item) => item.clientId === client.id).length,
  completeness: client.completeness,
  updatedAt: client.updatedAt,
  activities: [{
    id: client.id + "-activity-1",
    clientId: client.id,
    title: "Master Data Klien diperbarui",
    description: "Data " + client.shortName + " diperiksa oleh Admin.",
    time: client.updatedAt,
    tone: client.completeness === "Lengkap" ? "success" : "warning"
  }]
}));

function location(id: string, clientId: string, code: string, name: string, type: FitnessClientLocation["type"], address: string, city: string, province: string, contactName: string, phone: string, status: FitnessClientLocation["status"] = "Aktif"): FitnessClientLocation {
  return { id, clientId, code, name, type, address, city, province, postalCode: "-", contactName, phone, email: code.toLowerCase() + "@example.test", accessNotes: "Konfirmasi akses melalui PIC klien.", status, updatedAt: "14 Juli 2026" };
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

function masterReference(
  id: string,
  clientId: string,
  category: FitnessClientReferenceCategory,
  code: string,
  name: string,
  description: string
): FitnessClientMasterDataReference {
  return { id, clientId, category, code, name, description, status: "Aktif", updatedAt: "14 Juli 2026" };
}

function reference(id: string, clientId: string, section: FitnessClientInspectionReference["section"], code: string, name: string, description: string, order: number, presentationRequired?: boolean): FitnessClientInspectionReference {
  return { id, clientId, section, code, name, description, order, presentationRequired, status: "Aktif", updatedAt: "14 Juli 2026" };
}

function legacy(id: string, clientId: string, section: FitnessLegacyMappingRecord["section"], legacyCode: string, legacyName: string, mappedTarget: string | null): FitnessLegacyMappingRecord {
  return { id, clientId, section, legacyCode, legacyName, mappedTarget, mappingStatus: mappedTarget ? "Terpetakan" : "Belum Terpetakan", updatedAt: "14 Juli 2026" };
}
