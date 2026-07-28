import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const read = (path) => readFile(new URL(path, import.meta.url), "utf8");
const [workspace, resources, route, legacyRoute, surveyor, jobCreate] = await Promise.all([
  read("../components/master/iso-cedex-workspace.tsx"),
  read("../constants/master-data.ts"),
  read("../app/master/iso-cedex/page.tsx"),
  read("../app/master/[...route]/page.tsx"),
  read("../app/surveyor/surveys/[id]/page.tsx"),
  read("../app/jobs/create/page.tsx")
]);

for (const tab of ["location", "component", "damage", "material", "action", "reference"]) {
  assert.match(workspace, new RegExp(`id: "${tab}"`), `Missing ISO CEDEX tab: ${tab}`);
}

assert.match(resources, /"cedex-actions"[\s\S]*endpoint: "\/master\/cedex\/repairs"/);
assert.match(resources, /"cedex-references"[\s\S]*endpoint: "\/fitness\/master-data\/test-parameters"/);
assert.doesNotMatch(resources, /endpoint: "\/master\/cedex\/(?:actions|references)"/);
assert.match(route, /requestedTab === "action-repair"[\s\S]*canonicalHref\(customerId, "action"\)/);
assert.match(legacyRoute, /"responsibility-codes": "\/master\/iso-cedex\?legacy=responsibility"/);
assert.doesNotMatch(surveyor, /label="Perbaikan"/);
assert.match(surveyor, /label="Rekomendasi Tindakan"/);
assert.match(surveyor, /Tolerance belum dikonfigurasi/);
assert.match(surveyor, /Reinspection: DECISION_REQUIRED/);
assert.match(jobCreate, /nextSurveyTypes\.length === 1 \? nextSurveyTypes\[0\]\.id : ""/);
assert.match(jobCreate, /tepat satu Survey Type aktif/);

console.log("ISO CEDEX and Admin Kelaikan contract checks passed.");
