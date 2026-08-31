import { Suspense } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { ReviewWorkspace } from "@/components/reviews/review-workspace";

export default function ReviewIndexPage() {
  return <ProtectedRoute><AppShell title="Review & Keputusan" breadcrumbs={[{ label: "Review & Keputusan" }]}><Suspense fallback={<div className="center-screen">Memuat Review & Keputusan...</div>}><ReviewWorkspace /></Suspense></AppShell></ProtectedRoute>;
}
