import { FitnessPlaceholderPage } from "@/components/fitness/fitness-placeholder-page";
import { getFitnessPlaceholderByPath, type FitnessPlaceholder } from "@/constants/fitness-admin";

type FitnessRouteProps = {
  params: Promise<{ slug?: string[] }>;
};

const fallbackPlaceholder: FitnessPlaceholder = {
  path: "/fitness/dashboard",
  title: "Dashboard Kelaikan",
  purpose: "Halaman placeholder Sistem Kelaikan Peti Kemas.",
  fields: ["Pilih salah satu menu Admin Kelaikan dari sidebar"],
  validations: ["Placeholder — belum ada API/mutation pada tahap ini."],
  usedBy: ["Admin Kelaikan"],
  surveyorUsage: "Surveyor akan memakai data yang disiapkan Admin pada tahap berikutnya."
};

export default async function FitnessRoutePage({ params }: FitnessRouteProps) {
  const resolvedParams = await params;
  const slug = resolvedParams.slug ?? ["dashboard"];
  const path = `/fitness/${slug.join("/")}`;
  const item = getFitnessPlaceholderByPath(path) ?? fallbackPlaceholder;
  return <FitnessPlaceholderPage item={item} />;
}
