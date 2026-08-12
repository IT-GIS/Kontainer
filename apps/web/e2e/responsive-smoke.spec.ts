import { expect, test } from "@playwright/test";

test("@smoke halaman login tetap dapat dipakai tanpa overflow horizontal", async ({ page }, testInfo) => {
  await page.goto("/login");

  await expect(page.getByRole("heading", { name: "Sistem Kelaikan Peti Kemas Terintegrasi" })).toBeVisible();
  await expect(page.getByLabel("Email")).toBeVisible();
  await expect(page.getByLabel("Password")).toBeVisible();
  await expect(page.getByRole("button", { name: "Masuk" })).toBeVisible();

  const horizontalOverflow = await page.evaluate(() => document.documentElement.scrollWidth > document.documentElement.clientWidth);
  expect(horizontalOverflow, `overflow horizontal pada viewport ${testInfo.project.name}`).toBe(false);
});
