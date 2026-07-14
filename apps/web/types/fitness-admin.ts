import type { LucideIcon } from "lucide-react";

export type BreadcrumbItem = {
  label: string;
  href?: string;
};

export type PageTabItem = {
  id: string;
  label: string;
  href: string;
  count?: number;
};

export type FitnessMockMode = "success" | "empty" | "error" | "loading";

export type FitnessMockState<T> =
  | { status: "success"; data: T; isLoading: false; error: null }
  | { status: "empty"; data: T; isLoading: false; error: null }
  | { status: "error"; data: null; isLoading: false; error: string }
  | { status: "loading"; data: null; isLoading: true; error: null };

export type FitnessNavigationSummary = {
  label: string;
  href: string;
  description: string;
  status: "Aktif" | "Dalam Pengembangan";
  icon: LucideIcon;
};

export type FitnessPlaceholder = {
  path: string;
  title: string;
  subtitle: string;
  description: string;
  icon: LucideIcon;
  status: "Dalam Pengembangan" | "Aktif";
  features: string[];
  primaryCta: { label: string; href: string };
  secondaryCta?: { label: string; href: string };
  tabs?: PageTabItem[];
  breadcrumbs: BreadcrumbItem[];
  compatibilityRoutes?: string[];
};

export type FitnessMasterDataCard = {
  label: string;
  href: string;
  description: string;
  status: "Aktif" | "Dalam Pengembangan";
  activeCount: number;
  inactiveCount: number;
  updatedAt: string;
  icon: LucideIcon;
};

export type FitnessMasterDataGroup = {
  title: string;
  description: string;
  items: FitnessMasterDataCard[];
};

export type FitnessUiBTone = "neutral" | "success" | "warning" | "danger" | "info";

export type FitnessUiBMetric = {
  label: string;
  value: string;
  description: string;
  tone: FitnessUiBTone;
  trend: string;
  icon: LucideIcon;
};

export type FitnessUiBStep = {
  id: string;
  label: string;
  description: string;
  status: "complete" | "current" | "upcoming";
};

export type FitnessUiBProgressItem = {
  id: string;
  label: string;
  description: string;
  status: "done" | "current" | "waiting";
};

export type FitnessUiBActivity = {
  id: string;
  title: string;
  description: string;
  time: string;
  tone: "neutral" | "success" | "warning" | "danger";
};

export type FitnessUiBRecord = {
  id: string;
  code: string;
  owner: string;
  stage: string;
  status: string;
  complete: number;
  total: number;
};

export type FitnessUiBFilter = {
  id: string;
  label: string;
  value: string;
  placeholder: string;
};

export type FitnessUiBAttachment = {
  name: string;
  type: "image" | "document";
  sizeLabel: string;
};

export type FitnessUiBPreview = {
  metrics: FitnessUiBMetric[];
  steps: FitnessUiBStep[];
  progress: FitnessUiBProgressItem[];
  activities: FitnessUiBActivity[];
  records: FitnessUiBRecord[];
  filters: FitnessUiBFilter[];
  attachments: FitnessUiBAttachment[];
};

export type FitnessClientStatus = "Aktif" | "Tidak Aktif";
export type FitnessClientCompleteness = "Lengkap" | "Belum Lengkap";

export type FitnessClientSummary = {
  id: string;
  code: string;
  name: string;
  shortName: string;
  addressShort: string;
  city: string;
  province: string;
  primaryContactName: string;
  primaryContactTitle: string;
  email: string;
  phone: string;
  locationCount: number;
  personnelCount: number;
  containerTypeCount: number;
  referenceCount: number;
  containerCount: number;
  status: FitnessClientStatus;
  completeness: FitnessClientCompleteness;
  updatedAt: string;
};

export type FitnessClientDetail = FitnessClientSummary & {
  address: string;
  postalCode: string;
  legalIdentity: string;
  adminNotes: string;
  accessInformation: string;
};

export type FitnessClientActivity = {
  id: string;
  clientId: string;
  title: string;
  description: string;
  time: string;
  tone: "neutral" | "success" | "warning" | "danger";
};

export type FitnessClientMasterSummary = {
  clientId: string;
  activeLocationCount: number;
  activePersonnelCount: number;
  containerTypeCount: number;
  inspectionReferenceCount: number;
  legacyMappingCount: number;
  completeness: FitnessClientCompleteness;
  updatedAt: string;
  activities: FitnessClientActivity[];
};

export type FitnessClientLocationType =
  | "Depo"
  | "Gudang"
  | "Terminal"
  | "Pelabuhan"
  | "Lokasi Pemeriksaan"
  | "Lokasi Perbaikan Eksternal"
  | "Lainnya";

export type FitnessClientLocation = {
  id: string;
  clientId: string;
  code: string;
  name: string;
  type: FitnessClientLocationType;
  address: string;
  city: string;
  province: string;
  postalCode: string;
  contactName: string;
  phone: string;
  email: string;
  accessNotes: string;
  status: FitnessClientStatus;
  updatedAt: string;
};

export type FitnessClientPersonnelType =
  | "PIC Utama"
  | "PIC Lokasi"
  | "Penanggung Jawab Peti Kemas"
  | "Personel Teknis"
  | "Pendamping Pemeriksaan"
  | "Surveyor Internal Klien";

export type FitnessClientPersonnel = {
  id: string;
  clientId: string;
  name: string;
  title: string;
  type: FitnessClientPersonnelType;
  locationIds: string[];
  locationNames: string[];
  email: string;
  phone: string;
  status: FitnessClientStatus;
  updatedAt: string;
};

export type FitnessClientContainerType = {
  id: string;
  clientId: string;
  code: string;
  name: string;
  size: string;
  description: string;
  status: FitnessClientStatus;
  updatedAt: string;
};

export type FitnessInspectionReferenceSection =
  | "inspection-areas"
  | "structural-components"
  | "damage-criteria"
  | "finding-severities"
  | "test-parameters"
  | "photo-categories"
  | "inspection-recommendations";

export type FitnessClientInspectionReference = {
  id: string;
  clientId: string;
  section: FitnessInspectionReferenceSection;
  code: string;
  name: string;
  description: string;
  relatedTo?: string;
  unit?: string;
  presentationRequired?: boolean;
  order?: number;
  status: FitnessClientStatus;
  updatedAt: string;
};

export type FitnessLegacyMappingSection = "location" | "component" | "damage" | "material";

export type FitnessLegacyMappingRecord = {
  id: string;
  clientId: string;
  section: FitnessLegacyMappingSection;
  legacyCode: string;
  legacyName: string;
  mappedTarget: string | null;
  mappingStatus: "Terpetakan" | "Belum Terpetakan";
  updatedAt: string;
};

export type FitnessApplicationSummary = {
  id: string;
  clientId: string;
  applicationNumber: string;
  clientName: string;
  status: string;
  updatedAt: string;
};

export type FitnessContainerSummary = {
  id: string;
  clientId: string;
  containerNumber: string;
  clientName: string;
  containerTypeId: string;
  processStage: string;
  updatedAt: string;
};
