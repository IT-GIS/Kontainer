import { expect, type Page, test, type TestInfo } from "@playwright/test";

const operationalEnabled = process.env.E2E_OPERATIONAL === "1";

function required(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`Environment ${name} wajib tersedia untuk UAT operasional.`);
  return value;
}

async function login(page: Page, emailVariable: string, passwordVariable: string) {
  await page.goto("/login");
  const submit = page.getByRole("button", { name: "Masuk" });
  await expect(submit).toBeEnabled();
  await page.getByLabel("Email").fill(required(emailVariable));
  await page.getByLabel("Password").fill(required(passwordVariable));
  await submit.click();
  await expect(page).not.toHaveURL(/\/login(?:\?|$)/, { timeout: 20_000 });
}

async function switchUser(page: Page, emailVariable: string, passwordVariable: string) {
  await page.evaluate(() => localStorage.clear());
  await page.context().clearCookies();
  await login(page, emailVariable, passwordVariable);
}

async function attachScreenshot(page: Page, testInfo: TestInfo, name: string) {
  await testInfo.attach(name, { body: await page.screenshot({ fullPage: true }), contentType: "image/png" });
}

async function uploadGeneralPhoto(page: Page, caption: string) {
  await page.getByRole("button", { name: "Foto", exact: true }).click();
  await page.getByRole("button", { name: "Tambah Foto Umum" }).click();
  const photoDialog = page.getByRole("dialog", { name: "Unggah Foto Evidence Umum Survey" });
  await photoDialog.getByLabel("Kategori Foto *").selectOption({ index: 1 });
  await photoDialog.getByLabel("Pilih dari Galeri").setInputFiles(process.env.E2E_PHOTO_PATH ?? "public/images/gift-logo.png");
  await photoDialog.getByLabel("Caption (opsional)").fill(caption);
  await photoDialog.getByRole("button", { name: "Unggah", exact: true }).click();
  await expect(page.getByText("Foto Evidence umum Survey tersimpan.")).toBeVisible();
}

async function submitDraftSurvey(page: Page, expectedMessage: string) {
  await page.getByRole("button", { name: "Pratinjau & Submit" }).click();
  await expect(page.getByText("Survey siap dikirim ke Reviewer.")).toBeVisible();
  await page.getByRole("button", { name: "Submit ke Reviewer" }).click();
  await expect(page.getByText(expectedMessage)).toBeVisible();
}

test.describe("@operational workflow real-case", () => {
  test.skip(!operationalEnabled, "Aktifkan hanya terhadap database dan bucket UAT yang sudah di-seed.");
  test.beforeEach(({ browserName }, testInfo) => {
    test.skip(browserName !== "chromium" || testInfo.project.name !== "desktop-1366", "Workflow mutatif dijalankan satu kali pada desktop.");
  });

  test("satu peti kemas dapat dimulai tanpa memblokir peti kemas lain", async ({ page }, testInfo) => {
    test.setTimeout(240_000);
    await login(page, "E2E_SURVEYOR_EMAIL", "E2E_SURVEYOR_PASSWORD");
    await page.goto("/settings/users");
    await expect(page.getByRole("alert").filter({ hasText: "Akses ditolak" })).toBeVisible();
    await page.goto(`/surveyor/jobs/${required("E2E_MULTI_CONTAINER_JOB_ID")}`);

    const firstContainer = page.getByRole("row").filter({ hasText: required("E2E_CONTAINER_A_NO") });
    await firstContainer.getByRole("button", { name: "Mulai Survey" }).click();
    await expect(page).toHaveURL(/\/surveyor\/surveys\/[0-9a-f-]+/i);

    await page.goto(`/surveyor/jobs/${required("E2E_MULTI_CONTAINER_JOB_ID")}`);
    const secondContainer = page.getByRole("row").filter({ hasText: required("E2E_CONTAINER_B_NO") });
    await expect(secondContainer.getByRole("button", { name: "Mulai Survey" })).toBeEnabled();
    await attachScreenshot(page, testInfo, "multi-container-independent-start");
  });

  test("submit, revisi bertarget, resubmit, dan approve mempertahankan jejak", async ({ page }, testInfo) => {
    test.setTimeout(240_000);
    const surveyID = required("E2E_REVISION_SURVEY_ID");
    await login(page, "E2E_SURVEYOR_EMAIL", "E2E_SURVEYOR_PASSWORD");
    await page.goto(`/surveyor/surveys/${surveyID}`);
    await uploadGeneralPhoto(page, "Evidence UAT revisi otomatis");
    await submitDraftSurvey(page, "Survey berhasil disubmit ke Reviewer.");

    await switchUser(page, "E2E_SUPERVISOR_EMAIL", "E2E_SUPERVISOR_PASSWORD");
    await page.goto(`/review/${surveyID}`);
    await page.getByRole("button", { name: "Mulai Review" }).click();
    await page.getByRole("button", { name: "Perlu Revisi" }).click();
    const revisionDialog = page.getByRole("dialog", { name: "Perlu Revisi" });
    const firstItem = revisionDialog.locator("section.workspace-panel").nth(0);
    await firstItem.getByLabel("Target").selectOption("finding");
    await firstItem.getByLabel("Record Target").selectOption({ index: 1 });
    await firstItem.getByLabel("Catatan Item *").fill("Periksa kembali Temuan terpilih.");
    await revisionDialog.getByRole("button", { name: "Tambah Item" }).click();
    const secondItem = revisionDialog.locator("section.workspace-panel").nth(1);
    await secondItem.getByLabel("Target").selectOption("photo");
    await secondItem.getByLabel("Record Target").selectOption({ index: 1 });
    await secondItem.getByLabel("Catatan Item *").fill("Periksa kembali Foto Evidence terpilih.");
    await page.getByLabel("Catatan Revisi").fill("UAT revisi bertarget survey.");
    await page.getByRole("button", { name: "Submit", exact: true }).click();
    await attachScreenshot(page, testInfo, "review-need-revision");

    await switchUser(page, "E2E_SURVEYOR_EMAIL", "E2E_SURVEYOR_PASSWORD");
    await page.goto(`/surveyor/surveys/${surveyID}`);
    await expect(page.getByText("Catatan Perbaikan Reviewer")).toBeVisible();
    await page.locator(".alert-warning").filter({ hasText: "finding" }).getByRole("button", { name: "Buka Target" }).click();
    await expect(page).toHaveURL(/tab=findings&target_id=/);
    await page.getByRole("button", { name: "Pratinjau & Submit" }).click();
    await page.getByRole("button", { name: "Submit ke Reviewer" }).click();
    await expect(page.getByText("Survey berhasil disubmit ulang ke Reviewer.")).toBeVisible();

    await switchUser(page, "E2E_SUPERVISOR_EMAIL", "E2E_SUPERVISOR_PASSWORD");
    await page.goto(`/review/${surveyID}`);
    await page.getByRole("button", { name: "Mulai Review" }).click();
    await page.getByRole("button", { name: "Setujui" }).click();
    await page.getByLabel("Hasil Akhir").selectOption("cargo_worthy");
    await page.getByLabel("Catatan Persetujuan").fill("Disetujui pada UAT real-case.");
    await page.getByRole("button", { name: "Approve", exact: true }).click();
    await expect(page).toHaveURL(/\/review(?:\/history|\?view=history)/);
    await attachScreenshot(page, testInfo, "review-approved-history");
  });

  test("reject dan pembatasan role tetap berlaku", async ({ page }, testInfo) => {
    test.setTimeout(240_000);
    const surveyID = required("E2E_REJECTION_SURVEY_ID");
    await login(page, "E2E_SURVEYOR_EMAIL", "E2E_SURVEYOR_PASSWORD");
    await page.goto(`/surveyor/surveys/${surveyID}`);
    await uploadGeneralPhoto(page, "Evidence UAT reject otomatis");
    await submitDraftSurvey(page, "Survey berhasil disubmit ke Reviewer.");

    await page.goto(`/surveyor/surveys/${required("E2E_ISOLATION_SURVEY_ID")}`);
    const isolatedSurveyAlert = page.getByRole("alert").filter({ hasText: /Akses ditolak|Survey tidak dapat dimuat/ });
    await expect(isolatedSurveyAlert).toBeVisible();
    await expect(isolatedSurveyAlert).toContainText(/tidak ditugaskan|Data tidak ditemukan/);

    await switchUser(page, "E2E_SUPERVISOR_EMAIL", "E2E_SUPERVISOR_PASSWORD");
    await page.goto(`/review/${surveyID}`);
    await page.getByRole("button", { name: "Mulai Review" }).click();
    await page.getByRole("button", { name: "Tolak" }).click();
    await page.getByLabel("Alasan Penolakan").fill("Ditolak untuk pembuktian cabang UAT.");
    await page.getByRole("button", { name: "Submit", exact: true }).click();
    await expect(page.getByText("Ditolak")).toBeVisible();

    await switchUser(page, "E2E_MANAGEMENT_EMAIL", "E2E_MANAGEMENT_PASSWORD");
    await page.goto(`/review/${surveyID}`);
    await expect(page.getByText(/Mode read-only/)).toBeVisible();
    await expect(page.getByRole("button", { name: "Setujui" })).toHaveCount(0);

    await switchUser(page, "E2E_ADMIN_EMAIL", "E2E_ADMIN_PASSWORD");
    await page.goto(`/review/${surveyID}`);
    await expect(page.getByText(/Mode read-only/)).toBeVisible();
    await expect(page.getByRole("button", { name: "Setujui" })).toHaveCount(0);
    await attachScreenshot(page, testInfo, "role-boundary-read-only");
  });
});

test.describe("@operational mobile dan role menu", () => {
  test.skip(!operationalEnabled, "Aktifkan hanya terhadap database dan bucket UAT yang sudah di-seed.");

  test("workspace Surveyor nyata tidak overflow pada seluruh viewport", async ({ page }, testInfo) => {
    await login(page, "E2E_SURVEYOR_EMAIL", "E2E_SURVEYOR_PASSWORD");
    await page.goto("/surveyor/jobs");
    await expect(page.getByRole("heading", { name: "Job Saya", level: 1 })).toBeVisible();
    await expect(page.getByPlaceholder("Cari pekerjaan")).toBeVisible();
    const horizontalOverflow = await page.evaluate(() => document.documentElement.scrollWidth > document.documentElement.clientWidth);
    expect(horizontalOverflow, `overflow horizontal workspace UAT pada ${testInfo.project.name}`).toBe(false);
    await attachScreenshot(page, testInfo, `surveyor-workspace-${testInfo.project.name}`);
  });
});
