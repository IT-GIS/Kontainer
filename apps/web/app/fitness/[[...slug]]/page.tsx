import { Gauge } from "lucide-react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { FitnessMasterCompatibilityNotice, type CompatibilityNoticeProps } from "@/components/fitness/client-master-data/client-pages";
import { FitnessPlaceholderPage } from "@/components/fitness/fitness-placeholder-page";
import { AppShell } from "@/components/layout/app-shell";
import { getFitnessPlaceholderByPath, type FitnessPlaceholder } from "@/constants/fitness-admin";

type FitnessRouteProps = {
  params: Promise<{ slug?: string[] }>;
  searchParams: Promise<Record<string, string | string[] | undefined>>;
};

const fallbackPlaceholder: FitnessPlaceholder = {
  path: "/fitness/dashboard",
  title: "Dashboard",
  subtitle: "Ringkasan Admin Kelaikan",
  description: "Pilih salah satu menu Admin Kelaikan dari sidebar.",
  icon: Gauge,
  status: "Dalam Pengembangan",
  features: ["Navigasi Admin Kelaikan tersedia dari sidebar."],
  primaryCta: { label: "Kembali ke Dashboard", href: "/fitness/dashboard" },
  breadcrumbs: [
    { label: "Admin Kelaikan", href: "/fitness/dashboard" },
    { label: "Dashboard" }
  ]
};

export const fitnessMasterDataCompatibility: Record<string, CompatibilityNoticeProps> = {
  "/fitness/master-data": notice("Master Data lama", "Master Data global telah digantikan oleh Master Data berbasis klien.", "Pilih Klien", "/fitness/client-master-data"),
  "/fitness/master-data/owners": notice("Pemilik Peti Kemas lama", "Profil perusahaan pengguna jasa sekarang dikelola sebagai Klien.", "Buka Daftar Klien", "/fitness/clients"),
  "/fitness/master-data/manufacturers": notice("Pabrik Pembuat lama", "Referensi pabrik tidak diaktifkan sebagai Master Data Klien pada UI-B.2.", "Buka Peti Kemas", "/fitness/containers"),
  "/fitness/master-data/locations": notice("Lokasi lama", "Lokasi harus dibuka setelah memilih klien agar data tidak tercampur.", "Pilih Klien", "/fitness/client-master-data?targetTab=locations"),
  "/fitness/master-data/surveyors": { ...notice("Surveyor lama", "Personel/PIC Klien dipisahkan dari Surveyor GIFT.", "Pilih Klien untuk Personel/PIC", "/fitness/client-master-data?targetTab=personnel", "Buka Surveyor GIFT lama", "/master/surveyors"), internalGift: true },
  "/fitness/master-data/container-types": notice("Jenis Peti Kemas lama", "Jenis peti kemas sekarang dibatasi berdasarkan klien.", "Pilih Klien", "/fitness/client-master-data?targetTab=container-types"),
  "/fitness/master-data/approval-categories": notice("Kategori Persetujuan lama", "Master global ini tidak diaktifkan pada workflow UI-B.2.", "Kembali ke Master Data Klien", "/fitness/client-master-data"),
  "/fitness/master-data/maintenance-schemes": notice("Skema Pemeliharaan lama", "Master global ini tidak diaktifkan pada workflow UI-B.2.", "Kembali ke Master Data Klien", "/fitness/client-master-data"),
  "/fitness/master-data/inspection-areas": referenceNotice("Area Pemeriksaan", "inspection-areas"),
  "/fitness/master-data/structural-components": referenceNotice("Komponen Struktur", "structural-components"),
  "/fitness/master-data/damage-criteria": referenceNotice("Kriteria Kerusakan", "damage-criteria"),
  "/fitness/master-data/finding-severities": referenceNotice("Tingkat Keparahan", "finding-severities"),
  "/fitness/master-data/test-parameters": referenceNotice("Parameter Pengujian", "test-parameters"),
  "/fitness/master-data/photo-categories": referenceNotice("Kategori Bukti Foto", "photo-categories"),
  "/fitness/master-data/inspection-recommendations": referenceNotice("Rekomendasi Pemeriksaan", "inspection-recommendations"),
  "/fitness/master-data/checklist-templates": notice("Template Checklist lama", "Checklist seed dan workflow checklist tidak diaktifkan pada UI-B.2.", "Kembali ke Master Data Klien", "/fitness/client-master-data"),
  "/fitness/master-data/authorized-signers": { ...notice("Pejabat Penandatangan lama", "Pejabat penandatangan adalah data internal GIFT, bukan Master Data Klien.", "Buka Pengaturan Internal GIFT", "/settings/company-profile"), internalGift: true },
  "/fitness/master-data/company-profile": { ...notice("Profil Badan Usaha lama", "Profil badan usaha merupakan data internal GIFT.", "Buka Profil Badan Usaha", "/settings/company-profile"), internalGift: true }
};

export default async function FitnessRoutePage({ params, searchParams }: FitnessRouteProps) {
  const [resolvedParams, resolvedSearchParams] = await Promise.all([params, searchParams]);
  const slug = resolvedParams.slug ?? ["dashboard"];
  const path = "/fitness/" + slug.join("/");
  const activeHref = buildActiveHref(path, resolvedSearchParams);
  const compatibilityItem = fitnessMasterDataCompatibility[path] ?? (path.startsWith("/fitness/master-data/checklist-templates/") ? fitnessMasterDataCompatibility["/fitness/master-data/checklist-templates"] : undefined);

  if (compatibilityItem) {
    return (
      <ProtectedRoute>
        <AppShell
          title={compatibilityItem.title}
          subtitle="Compatibility route Admin Kelaikan"
          breadcrumbs={[{ label: "Admin Kelaikan", href: "/fitness/dashboard" }, { label: "Klien & Master Data", href: "/fitness/clients" }, { label: compatibilityItem.title }]}
        >
          <FitnessMasterCompatibilityNotice {...compatibilityItem} />
        </AppShell>
      </ProtectedRoute>
    );
  }

  const item = getFitnessPlaceholderByPath(activeHref) ?? getFitnessPlaceholderByPath(path) ?? fallbackPlaceholder;
  return <FitnessPlaceholderPage item={item} activeHref={activeHref} />;
}

function notice(title: string, description: string, primaryLabel: string, primaryHref: string, secondaryLabel?: string, secondaryHref?: string): CompatibilityNoticeProps {
  return {
    title,
    description,
    primary: { label: primaryLabel, href: primaryHref },
    secondary: secondaryLabel && secondaryHref ? { label: secondaryLabel, href: secondaryHref } : undefined
  };
}

function referenceNotice(title: string, section: string): CompatibilityNoticeProps {
  return notice(title + " lama", "Referensi pemeriksaan harus dibuka dalam konteks klien.", "Pilih Klien", "/fitness/client-master-data?targetTab=inspection-references&targetSection=" + section);
}

function buildActiveHref(path: string, searchParams: Record<string, string | string[] | undefined>) {
  const query = new URLSearchParams();
  for (const [key, value] of Object.entries(searchParams)) {
    if (Array.isArray(value)) value.forEach((item) => query.append(key, item));
    else if (value !== undefined) query.set(key, value);
  }
  const queryText = query.toString();
  return queryText ? path + "?" + queryText : path;
}
