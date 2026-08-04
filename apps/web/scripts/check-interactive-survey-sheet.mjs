import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import ts from "typescript";

const read = (path) => readFile(new URL(path, import.meta.url), "utf8");
const [source, component, route, styles, dataTable, navigation, repository, surveyorHandler, surveyorHelpers, reviewRepository, migration, workflowMigration] = await Promise.all([
  read("../lib/survey-sheet.ts"),
  read("../components/surveys/interactive-survey-sheet.tsx"),
  read("../app/surveyor/surveys/[id]/page.tsx"),
  read("../app/globals.css"),
  read("../components/ui/data-table.tsx"),
  read("../constants/navigation-surveyor.ts"),
  read("../../../services/api/internal/surveyor/repository.go"),
  read("../../../services/api/internal/surveyor/handler.go"),
  read("../../../services/api/internal/surveyor/helpers.go"),
  read("../../../services/api/internal/reviews/repository.go"),
  read("../../../services/api/migrations/0015_interactive_survey_sheet.up.sql"),
  read("../../../services/api/migrations/0016_survey_workflow_integrity.up.sql")
]);

const output = ts.transpileModule(source, {
  compilerOptions: { module: ts.ModuleKind.CommonJS, target: ts.ScriptTarget.ES2022 }
}).outputText;
const runtimeModule = { exports: {} };
new Function("exports", "module", "require", output)(runtimeModule.exports, runtimeModule, () => {
  throw new Error("survey-sheet.ts must not have runtime imports");
});
const sheet = runtimeModule.exports;

assert.equal(sheet.SURVEY_SHEET_FACES.length, 7);
assert.deepEqual(sheet.sectionsForTemplate("20", "R"), ["1", "2", "3", "4", "5"]);
assert.deepEqual(sheet.sectionsForTemplate("40", "R"), ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]);
assert.deepEqual(sheet.sectionsForTemplate("45", "R"), ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]);

const right = sheet.SURVEY_SHEET_FACES.find((face) => face.code === "R");
const areas = sheet.buildSheetAreas(right, "40").filter((area) => area.bandId === "bottom");
const single = sheet.createSelection(areas[0]);
const range = sheet.createSelection(areas[0], areas[3]);
assert.equal(single.section_start, "1");
assert.equal(single.section_end, "1");
assert.equal(range.section_start, "1");
assert.equal(range.section_end, "4");
assert.equal(range.view_direction, "rear_to_front");

const mapped = {
  id: "location-1", code: "RB14", name: "RB14", status: "active",
  input_mode: "structured", face: "right", container_size: "40",
  sector_code: "R", vertical_code: "B", start_section: "1",
  end_section: "4", transverse_span: "RANGE"
};
assert.equal(sheet.findStructuredLocation(range, [mapped])?.code, "RB14");
assert.equal(sheet.findStructuredLocation(range, [{ ...mapped, status: "inactive" }]), undefined);
assert.equal(sheet.findStructuredLocation(range, [{ ...mapped, end_section: "3" }]), undefined);
assert.equal(sheet.findStructuredLocation(range, [{ ...mapped, input_mode: "manual" }]), undefined);

assert.deepEqual(sheet.parseLocationSnapshot(JSON.stringify(range)), range);
assert.equal(sheet.selectionContainsArea(range, areas[2]), true);
assert.equal(sheet.selectionContainsArea(range, areas[5]), false);
assert.match(sheet.formatCedexDamage({
  cedex_location_code: "RB14", component_code: "PAA", damage_code: "DT",
  length: 20, width: 10, unit: "cm", quantity: 1, quantity_unit: "pc",
  repair_code: "RP", material_code: "ST"
}), /^RB14 - PAA - DT - 20 X 10 CM - 1 PC - RP - ST$/);
assert.match(sheet.buildFindingDescription({
  locationDescription: "Right bottom section 1-4",
  componentDescription: "Panel", damageDescription: "Dent",
  repairDescription: "Repair", length: 20, width: 10, unit: "cm"
}), /Panel.*Right bottom section 1-4.*Dent.*20.*10.*Repair/);

for (const label of [
  "Right Side", "Left Side", "Roof", "Base/Floor", "Understructure",
  "Door/Rear", "Front End"
]) {
  assert.match(source, new RegExp(label.replace("/", "\\/")));
}
assert.match(component, /Location Code/);
assert.match(component, /Ajukan Kode Lokasi/);
assert.match(component, /<svg/);
assert.match(component, /role="button"/);
assert.match(component, /onKeyDown/);
assert.match(component, /location_selection_snapshot/);
assert.match(component, /sidePanel/);
assert.match(component, /damage\.damage_no/);
assert.match(route, /Survey Sheet Interaktif/);
assert.match(route, /Pratinjau &amp; Submit/);
assert.match(route, /dimension_profile/);
assert.match(route, /location_selection_snapshot/);
assert.match(route, /checklist_response_id/);
assert.match(route, /capture="environment"/);
assert.match(route, /Informasi Pekerjaan &amp; Identitas Peti Kemas/);
assert.match(route, /Foto Evidence Umum Survey/);
assert.match(route, /Rekomendasi Tindakan/);
assert.match(route, /onRowClick/);
assert.match(dataTable, /onRowClick/);
assert.match(styles, /survey-sheet-workspace[\s\S]*grid-template-columns: minmax\(0, 1\.65fr\) minmax\(340px, 1fr\)/);
assert.match(styles, /@media \(max-width: 960px\)[\s\S]*survey-damage-editor-panel[\s\S]*position: fixed/);
assert.match(styles, /survey-sheet-workspace[\s\S]*max-width: 100%/);
assert.match(styles, /survey-sheet-summary-grid/);
assert.doesNotMatch(route, /Lokasi manual \(fallback\)/);
assert.doesNotMatch(route, /Alasan Lokasi Manual/);

for (const label of [
  "Dashboard", "Pekerjaan Saya", "Belum Dimulai", "Sedang Dikerjakan",
  "Perlu Revisi", "Menunggu Review", "Riwayat Inspeksi",
  "Pengajuan Kode CEDEX", "Profil"
]) {
  assert.match(navigation, new RegExp(label));
}
assert.doesNotMatch(navigation, /"(?:Master Data|User Management|Role|Permission|Audit Log)"/);

assert.match(repository, /survey_sheet\.location\.select/);
assert.match(repository, /location_selection_snapshot/);
assert.match(repository, /dimension_profile/);
assert.match(repository, /checklist_response_id/);
assert.match(repository, /CreateSurveyPhotoMetadata/);
assert.match(repository, /damageValue/);
assert.match(repository, /survey_photos\.upload_general/);
assert.match(surveyorHandler, /POST\("\/surveys\/:id\/photos"/);
assert.match(surveyorHandler, /survey_photos\.upload\.assigned/);
assert.match(surveyorHelpers, /CHECKLIST_FINDING_REQUIRED/);
assert.match(surveyorHelpers, /PHOTO_CATEGORY_REQUIRED/);
assert.match(surveyorHelpers, /DAMAGE_LOCATION_MASTER_REQUIRED/);
assert.match(reviewRepository, /status='under_review'/);
assert.match(reviewRepository, /survey_revisions/);
assert.match(migration, /ADD COLUMN location_selection_snapshot JSON/);
assert.match(migration, /survey_photos\.delete\.assigned/);

assert.match(workflowMigration, /CREATE TABLE IF NOT EXISTS survey_revisions/);
assert.match(workflowMigration, /ADD COLUMN checklist_response_id/);
console.log("Interactive Survey Sheet contract checks passed.");
