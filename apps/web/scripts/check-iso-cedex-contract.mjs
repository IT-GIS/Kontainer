import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const read = (path) => readFile(new URL(path, import.meta.url), "utf8");
const [workspace, resources, route, legacyRoute, masterService, surveyorScope, surveyorPage] = await Promise.all([
  read("../components/master/iso-cedex-workspace.tsx"),
  read("../constants/master-data.ts"),
  read("../app/master/iso-cedex/page.tsx"),
  read("../app/master/[...route]/page.tsx"),
  read("../../../services/api/internal/masterdata/service.go"),
  read("../../../services/api/internal/surveyor/customer_scope.go"),
  read("../app/surveyor/surveys/[id]/page.tsx")
]);

for (const section of [
  ["location", "Damage Location", 4],
  ["component", "Component / Part", 3],
  ["damage", "Damage Type", 2],
  ["action", "Action Repair", 2],
  ["material", "Material Type", 2]
]) {
  assert.match(workspace, new RegExp(`id: "${section[0]}"[\\s\\S]*?title: "${section[1].replace("/", "\\/")}"[\\s\\S]*?codeLength: ${section[2]}`), `Missing section contract: ${section[0]}`);
}

assert.match(workspace, /ISO CEDEX Code Master/);
assert.match(workspace, /Buka Acuan Pemeriksaan/);
assert.match(workspace, /source_type = "standard_global"/);
assert.match(workspace, /Simpan Perubahan/);
assert.match(workspace, /Batal Edit/);
assert.match(workspace, /value="legacy">Legacy/);
assert.doesNotMatch(workspace, /WorkspaceTabs|iso-cedex-summary-grid|Pilih Customer|Pilih Customer Lain|Inspection Reference/);

assert.match(resources, /"cedex-actions"[\s\S]*endpoint: "\/master\/cedex\/repairs"/);
assert.doesNotMatch(resources, /endpoint: "\/master\/cedex\/(?:actions|references)"/);
assert.match(route, /requestedTab === "reference"[\s\S]*redirect\("\/master\/inspection-references/);
assert.match(route, /query\.scope[\s\S]*redirect\(canonicalHref\(activeTab\)\)/);
assert.match(legacyRoute, /"responsibility-codes": "\/master\/iso-cedex\?legacy=responsibility"/);

for (const spec of [["cedex_locations", 4], ["cedex_components", 3], ["cedex_damages", 2], ["cedex_repairs", 2], ["cedex_materials", 2]]) {
  assert.match(masterService, new RegExp(`case "${spec[0]}":[\\s\\S]*?return ${spec[1]},`), `Missing server validation: ${spec[0]}`);
}
assert.match(masterService, /strings\.ToUpper/);
assert.match(surveyorScope, /customer_id IS NULL/);
assert.match(surveyorScope, /WHERE (?:location|component|damage|repair|material)\.status='active'/);
assert.doesNotMatch(surveyorPage, /label="Perbaikan"/);
assert.match(surveyorPage, /header: "Rekomendasi Tindakan"/);
assert.match(surveyorPage, /label="Rekomendasi Tindakan \*"/);

console.log("ISO CEDEX one-page master contract checks passed.");
