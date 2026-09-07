import { expect, type Page, test } from "@playwright/test";

function required(name: string): string {
  const value = process.env[name];
  if (!value) throw new Error(`Environment ${name} wajib tersedia untuk UAT final Customer Survey Sheet.`);
  return value;
}

async function login(page: Page, emailVariable: string, passwordVariable: string) {
  await page.goto("/login");
  await page.getByLabel("Email").fill(required(emailVariable));
  await page.getByLabel("Password").fill(required(passwordVariable));
  await page.getByRole("button", { name: "Masuk" }).click();
  await expect(page).not.toHaveURL(/\/login(?:\?|$)/, { timeout: 20_000 });
}

function containerNumber(): string {
  const letterValues: Record<string, number> = {
    A: 10, B: 12, C: 13, D: 14, E: 15, F: 16, G: 17, H: 18, I: 19, J: 20,
    K: 21, L: 23, M: 24, N: 25, O: 26, P: 27, Q: 28, R: 29, S: 30, T: 31,
    U: 32, V: 34, W: 35, X: 36, Y: 37, Z: 38
  };
  const stem = `UATU${String(Date.now()).slice(-6)}`;
  const sum = [...stem].reduce((total, character, index) => total + (letterValues[character] ?? Number(character)) * 2 ** index, 0);
  const remainder = sum % 11;
  return `${stem}${remainder === 10 ? 0 : remainder}`;
}

test.describe.serial("@final-customer-sheet onboarding dan provenance", () => {
  test("Customer baru langsung masuk onboarding terpadu", async ({ page }) => {
    test.setTimeout(120_000);
    await login(page, "E2E_ADMIN_EMAIL", "E2E_ADMIN_PASSWORD");
    await page.goto("/master/customers/create");
    const dialog = page.getByRole("dialog", { name: "Profil Customer" });
    await expect(dialog).toBeVisible();
    const suffix = String(Date.now()).slice(-9);
    await dialog.getByLabel("Customer Code").fill(`FNL${suffix}`);
    await dialog.getByLabel("Customer Name").fill(`Customer UAT Final ${suffix}`);
    await dialog.getByLabel("Alamat Utama").fill("Alamat sintetis khusus database UAT");
    await dialog.getByRole("button", { name: "Simpan & Lanjut" }).click();
    await expect(page).toHaveURL(/\/master\/customers\/customer\/[0-9a-f-]+\?tab=location-pic/i, { timeout: 20_000 });
    await expect(page.getByRole("heading", { name: "Lokasi & PIC", exact: true })).toBeVisible();
    await expect(page.getByRole("button", { name: /Kebutuhan Foto \/ Evidence/ })).toBeVisible();

    const locationCode = `LOC${suffix}`;
    const locationName = `Location UAT ${suffix}`;
    await page.getByRole("heading", { name: "Master Location" }).locator("xpath=../..").getByRole("button", { name: "Tambah" }).click();
    const locationDialog = page.getByRole("dialog", { name: "Tambah Master Location" });
    await locationDialog.getByLabel("Location Code").fill(locationCode);
    await locationDialog.getByLabel("Location Name").fill(locationName);
    await locationDialog.getByLabel("Location Type").selectOption("depot");
    await locationDialog.getByRole("button", { name: "Simpan", exact: true }).click();
    await expect(locationDialog).toBeHidden({ timeout: 20_000 });
    await expect(page.getByText("Location tersedia").locator("..").getByText(/Tersedia \(1\)/)).toBeVisible();

    const personnelCode = `PIC${suffix}`;
    const personnelName = `PIC UAT ${suffix}`;
    await page.getByRole("heading", { name: "Personel/PIC Customer" }).locator("xpath=../..").getByRole("button", { name: "Tambah" }).click();
    const personnelDialog = page.getByRole("dialog", { name: "Tambah Personel/PIC Customer" });
    await personnelDialog.getByLabel("Kode Personnel").fill(personnelCode);
    await personnelDialog.getByLabel("Nama Lengkap").fill(personnelName);
    await personnelDialog.getByLabel("Tipe Personnel").selectOption("pic");
    await personnelDialog.getByRole("button", { name: "Simpan", exact: true }).click();
    await expect(personnelDialog).toBeHidden({ timeout: 20_000 });

    const mappingPersonnel = page.getByRole("combobox", { name: "Personel/PIC Customer" }).last();
    await expect(mappingPersonnel.getByRole("option", { name: `${personnelCode} - ${personnelName}` })).toBeAttached({ timeout: 20_000 });
    await expect(page.getByLabel(`${locationCode} - ${locationName}`)).toBeVisible();

    const updatedLocationName = `${locationName} Updated`;
    await page.getByRole("button", { name: `Edit ${locationCode}` }).click();
    const editLocationDialog = page.getByRole("dialog", { name: "Edit Master Location" });
    await editLocationDialog.getByLabel("Location Name").fill(updatedLocationName);
    await editLocationDialog.getByRole("button", { name: "Update", exact: true }).click();
    await expect(editLocationDialog).toBeHidden({ timeout: 20_000 });
    await expect(page.getByLabel(`${locationCode} - ${updatedLocationName}`)).toBeVisible({ timeout: 20_000 });

    const updatedPersonnelName = `${personnelName} Updated`;
    await page.getByRole("button", { name: `Edit ${personnelCode}` }).click();
    const editPersonnelDialog = page.getByRole("dialog", { name: "Edit Personel/PIC Customer" });
    await editPersonnelDialog.getByLabel("Nama Lengkap").fill(updatedPersonnelName);
    await editPersonnelDialog.getByRole("button", { name: "Update", exact: true }).click();
    await expect(editPersonnelDialog).toBeHidden({ timeout: 20_000 });
    await expect(mappingPersonnel.getByRole("option", { name: `${personnelCode} - ${updatedPersonnelName}` })).toBeAttached({ timeout: 20_000 });

    await mappingPersonnel.selectOption({ label: `${personnelCode} - ${updatedPersonnelName}` });
    await page.getByLabel(`${locationCode} - ${updatedLocationName}`).check();
    await page.getByRole("button", { name: "Simpan Mapping" }).click();
    await expect(page.getByText("Mapping Location Personel/PIC berhasil disimpan.")).toBeVisible();
    await expect(page.getByText("Personel/PIC tersedia").locator("..").getByText(/Tersedia \(1\)/)).toBeVisible();
    await expect(page.getByText("Mapping tersedia").locator("..").getByText(/Tersedia \(1\)/)).toBeVisible();

    const continueButton = page.getByRole("link", { name: "Lanjut ke Konfigurasi Survey Sheet" });
    await expect(continueButton).toBeEnabled();
    await continueButton.click();
    await expect(page).toHaveURL(/\?tab=survey-sheet$/);
    await expect(page.getByRole("heading", { name: "Konfigurasi Survey Sheet" })).toBeVisible();
  });

  test("Customer siap menampilkan seluruh konfigurasi dan menghasilkan Job, Peti Kemas, serta Assignment", async ({ page }) => {
    test.setTimeout(120_000);
    const customerID = required("E2E_PRIMARY_CUSTOMER_ID");
    await login(page, "E2E_ADMIN_EMAIL", "E2E_ADMIN_PASSWORD");

    await page.goto(`/master/customers/customer/${customerID}?tab=survey-sheet`);
    await expect(page.getByRole("heading", { name: "Konfigurasi Survey Sheet" })).toBeVisible();
    await expect(page.getByText("Container Type / Size", { exact: true })).toBeVisible();
    await page.goto(`/master/customers/customer/${customerID}?tab=photo-evidence`);
    await expect(page.getByText("Admin hanya memilih requirement dari kategori master aktif.")).toBeVisible();
    await page.goto(`/master/customers/customer/${customerID}?tab=readiness`);
    await expect(page.getByText("Customer Siap", { exact: true })).toBeVisible();

    await page.goto(`/jobs/create?customerId=${customerID}`);
    const customerSelect = page.getByRole("combobox", { name: "Customer", exact: true });
    const locationSelect = page.getByRole("combobox", { name: "Location Pemeriksaan", exact: true });
    const personnelSelect = page.getByRole("combobox", { name: "Personel/PIC Customer", exact: true });
    const surveyTypeSelect = page.getByRole("combobox", { name: "Jenis Pemeriksaan", exact: true });
    await expect(customerSelect).toHaveValue(customerID, { timeout: 20_000 });
    await locationSelect.selectOption({ index: 1 });
    await expect(personnelSelect).toBeEnabled();
    await personnelSelect.selectOption({ index: 1 });
    await expect.poll(() => surveyTypeSelect.inputValue()).not.toBe("");
    const suffix = String(Date.now()).slice(-8);
    await page.getByLabel("Nomor Referensi").fill(`REF-FINAL-${suffix}`);
    await page.getByLabel("Nomor SPK").fill(`SPK-FINAL-${suffix}`);
    await page.getByLabel("Instruksi Admin").fill("UAT final alur Customer sampai Surveyor.");
    await page.getByRole("button", { name: "Simpan & Lanjut ke Peti Kemas" }).click();
    await expect(page).toHaveURL(/\/jobs\/[0-9a-f-]+\?tab=peti-kemas&wizard=1/i, { timeout: 20_000 });

    await page.getByRole("button", { name: "Tambah Peti Kemas" }).first().click();
    const containerDialog = page.getByRole("dialog", { name: "Tambah Peti Kemas" });
    const number = containerNumber();
    await containerDialog.getByLabel("Nomor Peti Kemas").fill(number);
    await containerDialog.getByLabel("Container Type").selectOption({ index: 1 });
    await containerDialog.getByLabel("Cargo Status").selectOption("empty");
    await containerDialog.getByLabel("Gross Weight").fill("30480");
    await containerDialog.getByLabel("Tare Weight").fill("2280");
    await containerDialog.getByLabel("Payload").fill("28200");
    await containerDialog.getByLabel("Tanggal Pembuatan").fill("2020-01-15");
    await containerDialog.getByLabel("CSC Plate Status").selectOption("available");
    await containerDialog.getByLabel("CSC Plate Number").fill(`CSC-${suffix}`);
    await containerDialog.getByLabel("CSC Approval Reference").fill(`APP-${suffix}`);
    await containerDialog.getByRole("button", { name: "Tambah", exact: true }).click();
    await expect(containerDialog).toBeHidden({ timeout: 20_000 });

    await page.getByLabel(`Pilih peti kemas ${number}`).check();
    await page.getByRole("button", { name: "Tugaskan 1 Peti Kemas" }).click();
    const assignmentDialog = page.getByRole("dialog", { name: "Tugaskan Surveyor GIFT" });
    await assignmentDialog.getByLabel("Surveyor GIFT").selectOption({ index: 1 });
    await assignmentDialog.getByLabel("Instruksi Penugasan").fill("Verifikasi identitas dan evidence secara aktual.");
    await assignmentDialog.getByRole("button", { name: "Tugaskan", exact: true }).click();
    await expect(page.getByRole("heading", { name: "Konfirmasi" })).toBeVisible({ timeout: 20_000 });
    await expect(page.getByText("Customer Ready", { exact: true })).toBeVisible();
    await expect(page.getByText("Container Valid", { exact: true })).toBeVisible();
    await expect(page.getByText("Surveyor Assigned", { exact: true })).toBeVisible();
  });

  test("Report membaca checklist, Temuan, evidence, dan keputusan Reviewer dari workflow", async ({ page }) => {
    await login(page, "E2E_ADMIN_EMAIL", "E2E_ADMIN_PASSWORD");
    await page.goto(`/reports/${required("E2E_APPROVED_REPORT_ID")}`);
    await expect(page.getByRole("heading", { name: "Data Survey Sheet untuk Laporan" })).toBeVisible();
    await expect(page.getByRole("heading", { name: "Checklist Pemeriksaan" })).toBeVisible();
    await expect(page.getByRole("heading", { name: "Temuan Survey" })).toBeVisible();
    await expect(page.getByRole("heading", { name: "Foto / Evidence" })).toBeVisible();
    await expect(page.getByRole("heading", { name: "Keputusan Reviewer" })).toBeVisible();
    await expect(page.getByText("Need Revision", { exact: true })).toBeVisible();
    await expect(page.getByText("Approved", { exact: true })).toBeVisible();
    await expect(page.getByText("AVL", { exact: true })).toBeVisible();
    await expect(page.getByText("DTY", { exact: true })).toBeVisible();
  });
});
