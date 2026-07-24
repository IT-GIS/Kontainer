import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const navigationSource = await readFile(new URL("../constants/navigation.ts", import.meta.url), "utf8");
const adminSource = await readFile(new URL("../constants/navigation-admin.ts", import.meta.url), "utf8");

assert.match(navigationSource, /navigationWorkspaces:[\s\S]*adminWorkspace/);
assert.doesNotMatch(navigationSource, /containerFitnessAdminWorkspace/);

const requiredGroups = [
  "Dashboard",
  "Pekerjaan Inspeksi",
  "Master Data",
  "Review & Keputusan",
  "Dokumen & Laporan",
  "Pengaturan"
];
for (const label of requiredGroups) {
  assert.ok(adminSource.includes(`"${label}"`), `Missing canonical label: ${label}`);
}

const forbiddenCanonicalLabels = [
  "Finance",
  "Ready to Invoice",
  "Price List",
  "Invoice",
  "Payment",
  "Outstanding",
  "Tindak Lanjut Perbaikan",
  "Workshop",
  "Gate-Out",
  "Arsip Lama"
];
for (const label of forbiddenCanonicalLabels) {
  assert.ok(!adminSource.includes(`"${label}"`), `Forbidden canonical label: ${label}`);
}

assert.match(adminSource, /"Referensi Pemeriksaan", "\/master\/inspection-references"/);
assert.match(adminSource, /"ISO CEDEX", "\/master\/iso-cedex"/);
assert.match(adminSource, /"Surveyor GIFT", "\/master\/surveyors"/);

console.log("Admin canonical navigation checks passed.");
