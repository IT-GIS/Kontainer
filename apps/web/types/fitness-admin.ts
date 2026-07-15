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
  | "Surveyor Internal Customer";

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

export type FitnessMasterDataCategory =
  | "customer"
  | "location"
  | "surveyor"
  | "container-type"
  | "survey-type"
  | "cedex-location"
  | "cedex-component"
  | "cedex-damage"
  | "cedex-repair"
  | "cedex-material"
  | "responsibility-code";

export type FitnessMasterDataCategorySlug =
  | "customers"
  | "locations"
  | "surveyors"
  | "container-types"
  | "survey-types"
  | "cedex-locations"
  | "cedex-components"
  | "cedex-damages"
  | "cedex-repairs"
  | "cedex-materials"
  | "responsibility-codes";

export type FitnessClientSurveyor = {
  id: string;
  clientId: string;
  code: string;
  name: string;
  title: string;
  locationIds: string[];
  locationNames: string[];
  email: string;
  phone: string;
  status: FitnessClientStatus;
  updatedAt: string;
};

export type FitnessClientReferenceCategory = Exclude<
  FitnessMasterDataCategory,
  "customer" | "location" | "surveyor" | "container-type"
>;

type FitnessClientMasterDataReferenceBase = {
  id: string;
  clientId: string;
  category: FitnessClientReferenceCategory;
  code: string;
  description: string;
  status: FitnessClientStatus;
  updatedAt: string;
};

export type FitnessClientSurveyTypeReference = FitnessClientMasterDataReferenceBase & {
  category: "survey-type";
  name: string;
  requiresEir: boolean;
  requiresLightTest: boolean;
  requiresCargoWorthyResult: boolean;
};

export type FitnessCedexFace = "left" | "right" | "front" | "door" | "roof" | "floor" | "understructure";
export type FitnessCedexContainerSize = "all" | "20" | "40" | "45";

export type FitnessClientCedexLocationReference = FitnessClientMasterDataReferenceBase & {
  category: "cedex-location";
  face: FitnessCedexFace;
  gridCode: string;
  cedexMappingCode: string;
  containerSize: FitnessCedexContainerSize;
  displayOrder: number;
};

export type FitnessClientNamedReferenceCategory = Exclude<FitnessClientReferenceCategory, "survey-type" | "cedex-location">;

export type FitnessClientNamedMasterDataReference = FitnessClientMasterDataReferenceBase & {
  category: FitnessClientNamedReferenceCategory;
  name: string;
};

export type FitnessClientMasterDataReference =
  | FitnessClientSurveyTypeReference
  | FitnessClientCedexLocationReference
  | FitnessClientNamedMasterDataReference;

export type FitnessClientMasterDataRecord =
  | FitnessClientLocation
  | FitnessClientSurveyor
  | FitnessClientContainerType
  | FitnessClientMasterDataReference;

export type FitnessMasterDataCategorySummary = {
  clientId: string;
  category: FitnessMasterDataCategory;
  count: number;
  activeCount: number;
  inactiveCount: number;
  updatedAt: string;
  completeness: FitnessClientCompleteness;
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

export type FitnessApplicationStatus = "Draf" | "Diajukan" | "Berjalan" | "Menunggu Review" | "Perlu Perbaikan" | "Selesai";

export type FitnessApplicationSummary = {
  id: string;
  clientId: string;
  applicationNumber: string;
  applicationDate: string;
  clientName: string;
  applicantName: string;
  ownerUserName: string;
  locationId: string;
  locationName: string;
  containerCount: number;
  completeness: { complete: number; total: number };
  processStage: string;
  status: FitnessApplicationStatus;
  updatedAt: string;
};

export type FitnessApplicationContainerDraft = {
  id: string;
  containerNumber: string;
  containerTypeId: string;
  containerTypeName?: string;
  numberValid: boolean;
  technicalComplete: boolean;
};

export type FitnessApplicationAttachment = {
  id: string;
  category: "Surat Permohonan" | "Daftar Peti Kemas" | "Kepemilikan/Penguasaan" | "Teknis" | "Lainnya";
  name: string;
  sizeLabel: string;
};

export type FitnessApplicationDraft = {
  applicationNumber: string;
  clientId: string;
  applicantName: string;
  ownerUserName: string;
  ownerUserAddress: string;
  ownerUserPic: string;
  ownerUserPhone: string;
  ownerUserEmail: string;
  applicationDate: string;
  serviceCategory: string;
  letterNumber: string;
  letterDate: string;
  locationId: string;
  picPersonnelId: string;
  plannedInspectionDate: string;
  containers: FitnessApplicationContainerDraft[];
  specialInstructions: string;
  adminNotes: string;
  referenceIds: string[];
  attachments: FitnessApplicationAttachment[];
};

export type FitnessApplicationReadinessItem = { id: string; label: string; ready: boolean; detail: string };
export type FitnessApplicationReadiness = {
  applicationId: string; clientId: string; ready: boolean; readyCount: number; totalCount: number;
  items: FitnessApplicationReadinessItem[];
};

export type FitnessApplicationDetail = FitnessApplicationSummary & {
  applicantAddress: string;
  applicantPicName: string;
  applicantPhone: string;
  applicantEmail: string;
  serviceCategory: string;
  letterNumber: string;
  letterDate: string;
  picPersonnelId: string;
  picName: string;
  picPhone: string;
  plannedInspectionDate: string;
  specialInstructions: string;
  adminNotes: string;
  containers: FitnessApplicationContainerDraft[];
  referenceIds: string[];
  attachments: FitnessApplicationAttachment[];
  progress: Array<{ id: string; label: string; description: string; status: "complete" | "current" | "incomplete" | "warning" | "error" }>;
  readiness: FitnessApplicationReadiness;
  history: FitnessClientActivity[];
};

export type FitnessDashboardMetric = {
  id: string; clientId?: string; label: string; value: number; description: string; tone: FitnessUiBTone;
  icon: "clients" | "applications" | "inspection" | "repair" | "reinspection" | "fit" | "unfit";
};
export type FitnessDashboardAction = {
  id: string; clientId?: string; label: string; count: number; description: string; href: string;
  tone: "neutral" | "success" | "warning" | "danger" | "info";
  icon: "client" | "application" | "container" | "assignment" | "review" | "repair" | "reinspection" | "document";
};
export type FitnessDashboardActivity = {
  id: string; clientId?: string; title: string; description: string; time: string; period: "7-days" | "30-days" | "quarter";
  tone: "neutral" | "success" | "warning" | "danger";
};
export type FitnessDashboardQuickAction = {
  id: string;
  label: string;
  description: string;
  href: string;
  icon: "client" | "master" | "application" | "import" | "assignment" | "review";
};
export type FitnessDashboardSnapshot = {
  metrics: FitnessDashboardMetric[];
  actions: FitnessDashboardAction[];
  activities: FitnessDashboardActivity[];
  quickActions: FitnessDashboardQuickAction[];
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
