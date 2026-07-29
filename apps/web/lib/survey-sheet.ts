import type { SurveyDamage, SurveyMasterOption } from "@/types/surveyor";

export type SurveyContainerSize = "20" | "40" | "45";
export type SurveySheetFaceCode = "R" | "L" | "T" | "B" | "U" | "D" | "F";
export type SurveySheetFaceKey = "right" | "left" | "roof" | "floor" | "understructure" | "door" | "front";
export type SurveySheetVerticalCode = "H" | "T" | "X" | "B" | "G";
export type SurveySheetTransverseCode = "L" | "R" | "X";

export type SurveySheetBand = {
  id: string;
  label: string;
  verticalPosition: SurveySheetVerticalCode;
  transversePosition: SurveySheetTransverseCode;
};

export type SurveySheetFaceConfig = {
  code: SurveySheetFaceCode;
  face: SurveySheetFaceKey;
  label: string;
  shortLabel: string;
  layout: "side" | "roof" | "floor" | "understructure" | "end";
  bands: SurveySheetBand[];
};

export type LocationSelectionSnapshot = {
  container_size: SurveyContainerSize;
  face: SurveySheetFaceCode;
  vertical_position: SurveySheetVerticalCode;
  section_start: string;
  section_end: string;
  transverse_position: SurveySheetTransverseCode;
  view_direction: "rear_to_front";
};

export type SurveySheetArea = {
  id: string;
  face: SurveySheetFaceCode;
  faceKey: SurveySheetFaceKey;
  verticalPosition: SurveySheetVerticalCode;
  transversePosition: SurveySheetTransverseCode;
  section: string;
  containerSize: SurveyContainerSize;
  bandId: string;
  bandLabel: string;
};

const SIDE_BANDS: SurveySheetBand[] = [
  { id: "header", label: "Header", verticalPosition: "H", transversePosition: "X" },
  { id: "top", label: "Top", verticalPosition: "T", transversePosition: "X" },
  { id: "bottom", label: "Bottom", verticalPosition: "B", transversePosition: "X" },
  { id: "ground", label: "Bottom Rail", verticalPosition: "G", transversePosition: "X" }
];

const TRANSVERSE_BANDS: SurveySheetBand[] = [
  { id: "left", label: "Left", verticalPosition: "X", transversePosition: "L" },
  { id: "right", label: "Right", verticalPosition: "X", transversePosition: "R" }
];

const FLOOR_BANDS: SurveySheetBand[] = [
  { id: "left", label: "Left", verticalPosition: "X", transversePosition: "L" },
  { id: "center", label: "Center", verticalPosition: "X", transversePosition: "X" },
  { id: "right", label: "Right", verticalPosition: "X", transversePosition: "R" }
];

const END_BANDS: SurveySheetBand[] = [
  { id: "header", label: "Header", verticalPosition: "H", transversePosition: "X" },
  { id: "top", label: "Top", verticalPosition: "T", transversePosition: "X" },
  { id: "middle", label: "Middle", verticalPosition: "X", transversePosition: "X" },
  { id: "bottom", label: "Bottom", verticalPosition: "B", transversePosition: "X" },
  { id: "ground", label: "Sill", verticalPosition: "G", transversePosition: "X" }
];

export const SURVEY_SHEET_FACES: SurveySheetFaceConfig[] = [
  { code: "R", face: "right", label: "Right Side (R)", shortLabel: "Right Side", layout: "side", bands: SIDE_BANDS },
  { code: "L", face: "left", label: "Left Side (L)", shortLabel: "Left Side", layout: "side", bands: SIDE_BANDS },
  { code: "T", face: "roof", label: "Roof (T)", shortLabel: "Roof", layout: "roof", bands: TRANSVERSE_BANDS },
  { code: "B", face: "floor", label: "Base/Floor (B)", shortLabel: "Base/Floor", layout: "floor", bands: FLOOR_BANDS },
  { code: "U", face: "understructure", label: "Understructure (U)", shortLabel: "Understructure", layout: "understructure", bands: FLOOR_BANDS },
  { code: "D", face: "door", label: "Door/Rear Assembly (D)", shortLabel: "Door/Rear", layout: "end", bands: END_BANDS },
  { code: "F", face: "front", label: "Front End (F)", shortLabel: "Front End", layout: "end", bands: END_BANDS }
];

export function normalizeContainerSize(value?: string | null): SurveyContainerSize | null {
  const normalized = String(value ?? "").trim();
  if (normalized.startsWith("20")) return "20";
  if (normalized.startsWith("40")) return "40";
  if (normalized.startsWith("45")) return "45";
  return null;
}

export function sectionsForTemplate(size: SurveyContainerSize, face: SurveySheetFaceCode): string[] {
  if (face === "D" || face === "F") return ["1", "2", "3", "4"];
  return size === "20" ? ["1", "2", "3", "4", "5"] : ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"];
}

export function buildSheetAreas(config: SurveySheetFaceConfig, size: SurveyContainerSize): SurveySheetArea[] {
  const sections = sectionsForTemplate(size, config.code);
  return config.bands.flatMap((band) => sections.map((section) => ({
    id: `${config.code}-${band.id}-${section}-${size}`,
    face: config.code,
    faceKey: config.face,
    verticalPosition: band.verticalPosition,
    transversePosition: band.transversePosition,
    section,
    containerSize: size,
    bandId: band.id,
    bandLabel: band.label
  })));
}

export function createSelection(start: SurveySheetArea, end: SurveySheetArea = start): LocationSelectionSnapshot {
  if (start.face !== end.face || start.bandId !== end.bandId || start.containerSize !== end.containerSize) {
    throw new Error("Rentang Survey Sheet harus berada pada sisi dan band yang sama.");
  }
  const sections = sectionsForTemplate(start.containerSize, start.face);
  const startIndex = sections.indexOf(start.section);
  const endIndex = sections.indexOf(end.section);
  if (startIndex < 0 || endIndex < 0) throw new Error("Section Survey Sheet tidak valid.");
  const first = startIndex <= endIndex ? start.section : end.section;
  const last = startIndex <= endIndex ? end.section : start.section;
  return {
    container_size: start.containerSize,
    face: start.face,
    vertical_position: start.verticalPosition,
    section_start: first,
    section_end: last,
    transverse_position: start.transversePosition,
    view_direction: "rear_to_front"
  };
}

export function findStructuredLocation(
  selection: LocationSelectionSnapshot,
  locations: SurveyMasterOption[]
): SurveyMasterOption | undefined {
  const isRange = selection.section_start !== selection.section_end;
  const config = SURVEY_SHEET_FACES.find((item) => item.code === selection.face);
  return locations.find((location) => {
    if (location.status && location.status !== "active") return false;
    if (location.input_mode !== "structured") return false;
    if (String(location.container_size ?? "") !== selection.container_size) return false;
    if (String(location.face ?? "").toLowerCase() !== config?.face) return false;
    if (String(location.sector_code ?? "").toUpperCase() !== selection.face) return false;
    if (String(location.vertical_code ?? "").toUpperCase() !== selection.vertical_position) return false;
    if (String(location.start_section ?? "").toUpperCase() !== selection.section_start) return false;
    if (isRange) {
      return String(location.transverse_span ?? "").toUpperCase() === "RANGE"
        && String(location.end_section ?? "").toUpperCase() === selection.section_end;
    }
    return String(location.transverse_span ?? "").toUpperCase() === "N"
      && (!location.end_section || String(location.end_section).toUpperCase() === selection.section_end);
  });
}

export function parseLocationSnapshot(value: unknown): LocationSelectionSnapshot | null {
  let parsed = value;
  if (typeof value === "string") {
    try {
      parsed = JSON.parse(value);
    } catch {
      return null;
    }
  }
  if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) return null;
  const item = parsed as Partial<LocationSelectionSnapshot>;
  const size = normalizeContainerSize(item.container_size);
  const face = SURVEY_SHEET_FACES.find((entry) => entry.code === item.face);
  if (!size || !face || !item.vertical_position || !item.section_start || !item.section_end) return null;
  return {
    container_size: size,
    face: face.code,
    vertical_position: item.vertical_position,
    section_start: String(item.section_start),
    section_end: String(item.section_end),
    transverse_position: item.transverse_position ?? "X",
    view_direction: "rear_to_front"
  };
}

export function selectionContainsArea(selection: LocationSelectionSnapshot | null, area: SurveySheetArea): boolean {
  if (!selection || selection.face !== area.face || selection.container_size !== area.containerSize) return false;
  if (selection.vertical_position !== area.verticalPosition || selection.transverse_position !== area.transversePosition) return false;
  const sections = sectionsForTemplate(area.containerSize, area.face);
  const sectionIndex = sections.indexOf(area.section);
  const startIndex = sections.indexOf(selection.section_start);
  const endIndex = sections.indexOf(selection.section_end);
  return sectionIndex >= startIndex && sectionIndex <= endIndex;
}

export function selectionDescription(selection: LocationSelectionSnapshot): string {
  const face = SURVEY_SHEET_FACES.find((item) => item.code === selection.face);
  const band = face?.bands.find((item) => (
    item.verticalPosition === selection.vertical_position
    && item.transversePosition === selection.transverse_position
  ));
  const section = selection.section_start === selection.section_end
    ? selection.section_start
    : `${selection.section_start}-${selection.section_end}`;
  return `${face?.shortLabel ?? selection.face}, ${band?.label ?? selection.vertical_position}, Section ${section}`;
}

export function areaAriaLabel(area: SurveySheetArea): string {
  return `${SURVEY_SHEET_FACES.find((item) => item.code === area.face)?.shortLabel ?? area.face}, ${area.bandLabel}, Section ${area.section}`;
}

export function formatCedexDamage(damage: Pick<SurveyDamage,
  "cedex_location_code" | "internal_location" | "component_code" | "damage_code" |
  "length" | "width" | "depth" | "unit" | "quantity" | "quantity_unit" |
  "repair_code" | "material_code"
>): string {
  const dimensions = [damage.length, damage.width, damage.depth]
    .filter((value): value is number => value !== null && value !== undefined)
    .map(formatNumber)
    .join(" X ");
  const dimensionPart = dimensions ? `${dimensions} ${String(damage.unit ?? "").toUpperCase()}`.trim() : "";
  const quantityPart = damage.quantity !== null && damage.quantity !== undefined
    ? `${formatNumber(damage.quantity)} ${String(damage.quantity_unit ?? "").toUpperCase()}`.trim()
    : "";
  return [
    damage.cedex_location_code || damage.internal_location,
    damage.component_code,
    damage.damage_code,
    dimensionPart,
    quantityPart,
    damage.repair_code,
    damage.material_code
  ].filter((part) => String(part ?? "").trim()).join(" - ");
}

export function buildFindingDescription(input: {
  locationDescription?: string | null;
  locationFallback?: string;
  componentDescription?: string | null;
  componentFallback?: string;
  damageDescription?: string | null;
  damageFallback?: string;
  materialDescription?: string | null;
  materialFallback?: string;
  repairDescription?: string | null;
  repairFallback?: string;
  length?: string | number | null;
  width?: string | number | null;
  depth?: string | number | null;
  unit?: string | null;
  quantity?: string | number | null;
  quantityUnit?: string | null;
}): string {
  const location = input.locationDescription || input.locationFallback || "lokasi terpilih";
  const component = input.componentDescription || input.componentFallback || "komponen";
  const damage = input.damageDescription || input.damageFallback || "kerusakan";
  const values = [input.length, input.width, input.depth].filter(hasValue).map((value) => String(value));
  const dimension = values.length > 0 ? ` berukuran ${values.join(" × ")} ${input.unit ?? ""}`.trimEnd() : "";
  const quantity = hasValue(input.quantity) ? `, jumlah ${input.quantity} ${input.quantityUnit ?? ""}`.trimEnd() : "";
  const material = input.materialDescription || input.materialFallback;
  const repair = input.repairDescription || input.repairFallback;
  return [
    `${component} pada ${location} mengalami ${damage}${dimension}${quantity}.`,
    material ? `Material ${material}.` : "",
    repair ? `Rekomendasi tindakan ${repair}.` : ""
  ].filter(Boolean).join(" ");
}

function hasValue(value: unknown): value is string | number {
  return value !== null && value !== undefined && String(value).trim() !== "";
}

function formatNumber(value: number): string {
  return Number.isInteger(value) ? String(value) : String(value).replace(/\.0+$/, "");
}
