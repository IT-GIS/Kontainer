import { defineConfig } from "@playwright/test";

const baseURL = process.env.PLAYWRIGHT_BASE_URL ?? "http://127.0.0.1:3000";
const useExternalServer = process.env.PLAYWRIGHT_EXTERNAL_SERVER === "1";
const localChromium = process.env.PLAYWRIGHT_USE_EDGE === "1" ? { channel: "msedge" as const } : {};

export default defineConfig({
  testDir: "./e2e",
  outputDir: "../../tmp/playwright-results",
  fullyParallel: false,
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 1 : 0,
  reporter: [
    ["list"],
    ["html", { outputFolder: "../../tmp/playwright-report", open: "never" }]
  ],
  use: {
    baseURL,
    screenshot: "only-on-failure",
    trace: "retain-on-failure",
    video: process.env.PLAYWRIGHT_USE_EDGE === "1" ? "off" : "retain-on-failure"
  },
  webServer: useExternalServer ? undefined : {
    command: "npm run dev",
    url: baseURL,
    reuseExistingServer: !process.env.CI,
    timeout: 120_000
  },
  projects: [
    { name: "mobile-360", use: { browserName: "chromium", ...localChromium, viewport: { width: 360, height: 800 } } },
    { name: "mobile-390", use: { browserName: "chromium", ...localChromium, viewport: { width: 390, height: 844 } } },
    { name: "mobile-412", use: { browserName: "chromium", ...localChromium, viewport: { width: 412, height: 915 } } },
    { name: "tablet-768", use: { browserName: "chromium", ...localChromium, viewport: { width: 768, height: 1024 } } },
    { name: "desktop-1366", use: { browserName: "chromium", ...localChromium, viewport: { width: 1366, height: 768 } } },
    { name: "desktop-1920", use: { browserName: "chromium", ...localChromium, viewport: { width: 1920, height: 1080 } } }
  ]
});
