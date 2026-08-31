import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const navigationSource = await readFile(new URL("../constants/navigation.ts", import.meta.url), "utf8");
const adminSource = await readFile(new URL("../constants/navigation-admin.ts", import.meta.url), "utf8");
const effectiveAdminSource = adminSource.replace(/\/\/.*$/gm, "");

assert.match(navigationSource, /navigationWorkspaces:[\s\S]*adminWorkspace/);
assert.doesNotMatch(navigationSource, /containerFitnessAdminWorkspace/);

const requiredMainItems = [
  "Dashboard",
  "Customer & Master",
  "Pekerjaan Inspeksi",
  "Review & Keputusan",
  "Laporan",
  "Pengaturan"
];
for (const label of requiredMainItems) {
  assert.ok(effectiveAdminSource.includes(`"${label}"`), `Missing canonical label: ${label}`);
}

const forbiddenSidebarItems = [
  "Semua Pekerjaan",
  "Buat Job/SPK",
  "Monitoring Survey",
  "Master Data",
  "Menunggu Review",
  "Riwayat Keputusan",
  "Dokumen & Laporan",
  "Arsip Laporan"
];
for (const label of forbiddenSidebarItems) {
  assert.ok(!effectiveAdminSource.includes(`"${label}"`), `Nested workflow item must not remain in Admin sidebar: ${label}`);
}

assert.match(effectiveAdminSource, /"Customer & Master", "\/master\/customers"/);
assert.match(effectiveAdminSource, /"Pekerjaan Inspeksi", "\/jobs"/);
assert.match(effectiveAdminSource, /"Review & Keputusan", "\/review"/);
assert.match(effectiveAdminSource, /"Laporan", "\/reports"/);
assert.match(effectiveAdminSource, /"Pengaturan", "\/settings"/);
assert.match(effectiveAdminSource, /"\/monitoring\/surveys"/);
assert.match(effectiveAdminSource, /"\/master\/iso-cedex"/);
assert.match(effectiveAdminSource, /"\/master\/inspection-references"/);

const mainLinkCount = (effectiveAdminSource.match(/\bn\("/g) ?? []).length;
assert.equal(mainLinkCount, 6, `Admin sidebar must contain exactly six high-level links, found ${mainLinkCount}`);

console.log("Admin process-based navigation checks passed.");
