import { NavigationPlaceholderPage } from "@/components/navigation/navigation-placeholder-page";
import { notFound } from "next/navigation";

export default function DataBootstrapPage() {
	if (process.env.NODE_ENV !== "development" || process.env.NEXT_PUBLIC_ENABLE_DATA_BOOTSTRAP !== "true") {
		notFound();
	}
  return <NavigationPlaceholderPage title="Data Bootstrap" backHref="/dashboard" backLabel="Kembali ke Dashboard" />;
}
