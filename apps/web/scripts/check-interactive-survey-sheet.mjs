import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import ts from "typescript";

const read = (path) => readFile(new URL(path, import.meta.url), "utf8");
const [source, component, route, styles, dataTable, navigation, repository, surveyorHandler, surveyorHelpers, reviewRepository, migration, workflowMigration, adminConfiguration, reviewRoute, reportRoute, readinessGate, snapshotMigration, createCustomerRoute, masterDataPage, customerSetupTabsSource, jobCreateRoute, customerSetupStepper, customerDetailWorkspace, personnelLocationMapping] = await Promise.all([
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
  read("../../../services/api/migrations/0016_survey_workflow_integrity.up.sql"),
  read("../components/master/survey-sheet-configuration.tsx"),
  read("../app/review/[id]/page.tsx"),
  read("../app/reports/[id]/page.tsx"),
  read("../../../services/api/internal/masterdata/readiness_gate.go"),
  read("../../../services/api/migrations/0019_survey_sheet_data_flow.up.sql"),
  read("../app/master/customers/create/page.tsx"),
  read("../components/master/master-data-page.tsx"),
  read("../components/master/customer-setup-tabs.ts"),
  read("../app/jobs/create/page.tsx"),
  read("../components/master/customer-setup-stepper.tsx"),
  read("../components/master/customer-detail-workspace.tsx"),
  read("../components/master/personnel-location-mapping.tsx")
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
const focused = sheet.focusSurveyDamage(0, { id: "damage-1", location_selection_snapshot: JSON.stringify(range) });
assert.equal(focused.activeFace, "right");
assert.equal(focused.focusedDamageId, "damage-1");
assert.equal(focused.focusRequestKey, 1);
assert.deepEqual(focused.selection, range);
assert.equal(sheet.focusSurveyDamage(focused.focusRequestKey, { id: "damage-1", location_selection_snapshot: range }).focusRequestKey, 2);
const legacyFocus = sheet.focusSurveyDamage(2, { id: "legacy-1", location_selection_snapshot: null });
assert.equal(legacyFocus.selection, null);
assert.equal(legacyFocus.legacyWithoutSnapshot, true);
assert.equal(legacyFocus.activeFace, null);
const categories = [
  { code: "general", applies_to: "inspection" },
  { code: "damage", applies_to: "finding" },
  { code: "other", applies_to: "report" },
  { code: "unset" }
];
assert.deepEqual(sheet.filterPhotoCategories(categories, "inspection").map((item) => item.code), ["general"]);
assert.deepEqual(sheet.filterPhotoCategories(categories, "finding").map((item) => item.code), ["damage"]);
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
assert.match(component, /focusRequestKey/);
assert.match(component, /focusedDamageId/);
assert.match(component, /onSelectionChange/);
assert.doesNotMatch(component, /initialSelection/);
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
assert.match(route, /role=\{isMobile \? "dialog"/);
assert.match(route, /aria-modal=\{isMobile \? true/);
assert.match(route, /useDialogBehavior/);
assert.match(route, /findingPhotoCategories/);
assert.match(route, /generalPhotoCategories/);
assert.match(route, /Customer \/ Client/);
assert.match(route, /Date of Survey/);
assert.match(route, /Condition \(DMG \/ AVL \/ AR\)/);
assert.match(route, /Cleanliness \(DTY \/ CTM\)/);
assert.match(route, /Cargo Status Awal/);
assert.match(route, /Cargo Status Verifikasi/);
assert.match(route, /SurveySheetFieldSourceBadge/);
assert.match(route, /MGM, TCT, 3rd Scty Sys, dan Cu-Cap/);
assert.match(dataTable, /onRowClick/);
assert.match(dataTable, /selectedRowKey/);
assert.match(dataTable, /aria-current/);
assert.match(styles, /survey-sheet-workspace[\s\S]*grid-template-columns: minmax\(0, 1\.65fr\) minmax\(340px, 1fr\)/);
assert.match(styles, /@media \(max-width: 960px\)[\s\S]*survey-damage-editor-panel[\s\S]*position: fixed/);
assert.match(styles, /survey-sheet-workspace[\s\S]*max-width: 100%/);
assert.match(styles, /survey-sheet-summary-grid/);
assert.doesNotMatch(route, /Lokasi manual \(fallback\)/);
assert.doesNotMatch(route, /Alasan Lokasi Manual/);

for (const label of [
  "Dashboard", "Pekerjaan Saya", "Belum Dimulai", "Sedang Dikerjakan",
	"Terkirim & Dalam Review", "Perlu Revisi", "Selesai", "Riwayat",
  "Pengajuan Kode CEDEX", "Profil"
]) {
  assert.match(navigation, new RegExp(label));
}
assert.match(navigation, /state=not_started/);
assert.doesNotMatch(navigation, /"(?:Master Data|User Management|Role|Permission|Audit Log)"/);

assert.match(repository, /survey_sheet\.location\.select/);
assert.match(repository, /location_selection_snapshot/);
assert.match(repository, /dimension_profile/);
assert.match(repository, /checklist_response_id/);
assert.match(repository, /CreateSurveyPhotoMetadata/);
assert.match(repository, /damageValue/);
assert.match(repository, /survey_photos\.upload_general/);
assert.match(repository, /VERIFICATION_MISMATCH_NOTE_REQUIRED/);
assert.match(repository, /"DMG", "AVL", "AR"/);
assert.match(surveyorHandler, /POST\("\/surveys\/:id\/photos"/);
assert.match(surveyorHandler, /survey_photos\.upload\.assigned/);
assert.match(surveyorHelpers, /CHECKLIST_FINDING_REQUIRED/);
assert.match(surveyorHelpers, /PHOTO_CATEGORY_REQUIRED/);
assert.match(surveyorHelpers, /DAMAGE_LOCATION_MASTER_REQUIRED/);
assert.match(reviewRepository, /status='under_review'/);
assert.match(reviewRepository, /survey_revisions/);
assert.match(reviewRepository, /cargo_status_initial/);
assert.match(reviewRepository, /csc_plate_status_initial/);
assert.match(reviewRepository, /sgi\.cleanliness/);
assert.match(reviewRepository, /item\["damages"\] = damages/);
assert.match(reviewRepository, /item\["photos"\] = photos/);
assert.match(reviewRepository, /item\["checklist"\] = checklist/);
assert.match(reviewRepository, /item\["review_history"\] = reviewHistory/);
assert.match(migration, /ADD COLUMN location_selection_snapshot JSON/);
assert.match(migration, /survey_photos\.delete\.assigned/);

assert.match(workflowMigration, /CREATE TABLE IF NOT EXISTS survey_revisions/);
assert.match(workflowMigration, /ADD COLUMN checklist_response_id/);
assert.match(adminConfiguration, /Konfigurasi Survey Sheet/);
assert.match(adminConfiguration, /Job .* Peti Kemas/);
assert.match(adminConfiguration, /Master CEDEX Global/);
assert.match(adminConfiguration, /Global \+ Override Customer/);
assert.match(adminConfiguration, /Kebutuhan Foto \/ Evidence/);
assert.match(adminConfiguration, /DOMAIN GAP/);
assert.match(reviewRoute, /Header Survey Sheet/);
assert.match(reviewRoute, /InteractiveSurveySheet/);
assert.match(reviewRoute, /Data Awal/);
assert.match(reviewRoute, /Status Verifikasi/);
assert.match(reviewRoute, /Mismatch data awal dan hasil verifikasi/);
assert.match(reportRoute, /Data Survey Sheet untuk Laporan/);
assert.match(reportRoute, /Tidak ada input ulang pada modul Reports/);
assert.match(reportRoute, /Checklist Pemeriksaan/);
assert.match(reportRoute, /Temuan Survey/);
assert.match(reportRoute, /Foto \/ Evidence/);
assert.match(reportRoute, /Keputusan Reviewer/);
assert.match(readinessGate, /LOCATION_PIC_MAPPING/);
assert.match(snapshotMigration, /customer_name_snapshot/);
assert.match(snapshotMigration, /cargo_status_initial/);
assert.match(snapshotMigration, /csc_plate_status_initial/);
assert.match(snapshotMigration, /ADD COLUMN cleanliness VARCHAR\(10\)/);
assert.match(createCustomerRoute, /onSaved=\{continueOnboarding\}/);
assert.match(createCustomerRoute, /router\.replace\(`\/master\/customers\/customer\/\$\{encodeURIComponent\(String\(row\.id\)\)\}\?tab=location-pic`\)/);
assert.match(createCustomerRoute, /submitLabelOverride="Simpan & Lanjut"/);
assert.match(masterDataPage, /submitLabelOverride/);
assert.match(customerSetupTabsSource, /Kebutuhan Foto \/ Evidence/);
assert.match(jobCreateRoute, /Lengkapi Customer/);
assert.doesNotMatch(customerSetupStepper, /"responsibility"/);
assert.equal((customerDetailWorkspace.match(/onSaved=\{refreshLocationAndPic\}/g) ?? []).length, 2);
assert.match(customerDetailWorkspace, /actionLabel="Lanjut ke Konfigurasi Survey Sheet"/);
assert.match(personnelLocationMapping, /\[accessToken, customerId, refreshKey\]/);
assert.match(personnelLocationMapping, /\[accessToken, customerId, personnelId, refreshKey\]/);
assert.match(personnelLocationMapping, /await onSaved\(\)/);
console.log("Interactive Survey Sheet contract checks passed.");
