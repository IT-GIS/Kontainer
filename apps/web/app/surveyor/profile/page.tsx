"use client";

import { useCallback, useEffect, useState } from "react";

import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PageHeader } from "@/components/ui/page-header";
import { useAuth } from "@/hooks/use-auth";
import { apiData } from "@/lib/api-client";
import type { SurveyorProfile } from "@/types/surveyor";

export default function SurveyorProfilePage() {
  return <ProtectedRoute><AppShell title="Profil"><SurveyorProfileContent /></AppShell></ProtectedRoute>;
}

function SurveyorProfileContent() {
	const { accessToken, user } = useAuth();
	const [profile, setProfile] = useState<SurveyorProfile | null>(null);
	const [error, setError] = useState<string | null>(null);
	const [certificateWarning, setCertificateWarning] = useState<string | null>(null);
	const loadProfile = useCallback(async () => {
		if (!accessToken) return;
		try {
			const result = await apiData<SurveyorProfile>("/surveyor/profile", { accessToken });
			setProfile(result);
			setCertificateWarning(buildCertificateWarning(result.certificate_valid_until));
		} catch (err) {
			setError(err instanceof Error ? err.message : "Profil Surveyor gagal dimuat.");
		}
	}, [accessToken]);
	useEffect(() => { const timer = window.setTimeout(() => void loadProfile(), 0); return () => window.clearTimeout(timer); }, [loadProfile]);
  return <div className="page-stack">
	<PageHeader title="Profil Surveyor" description="Data ini bersifat read-only dan dikelola oleh Admin." />
	{error ? <div className="alert alert-danger">{error}</div> : null}
	{certificateWarning ? <div className="alert alert-warning">{certificateWarning}</div> : null}
    <section className="workspace-panel">
      <div className="detail-grid">
		<div><span>Kode Surveyor</span><strong>{profile?.surveyor_code ?? "-"}</strong></div>
		<div><span>Nama</span><strong>{profile?.full_name ?? user?.name ?? "-"}</strong></div>
        <div><span>Email</span><strong>{user?.email ?? "-"}</strong></div>
		<div><span>Telepon</span><strong>{profile?.phone || "-"}</strong></div>
		<div><span>Area</span><strong>{profile?.area || "-"}</strong></div>
		<div><span>Nomor Sertifikat</span><strong>{profile?.certificate_number || "-"}</strong></div>
		<div><span>Berlaku Sampai</span><strong>{profile?.certificate_valid_until || "-"}</strong></div>
		<div><span>Kompetensi</span><strong>{profile?.competencies || "-"}</strong></div>
		<div><span>Lokasi Penugasan</span><strong>{profile?.assignment_locations || "-"}</strong></div>
		<div><span>Role Aktif</span><strong>{user?.active_role ?? "-"}</strong></div>
		<div><span>Status</span><strong>{profile?.status ?? "-"}</strong></div>
      </div>
    </section>
  </div>;
}

function buildCertificateWarning(validUntil?: string | null) {
	if (!validUntil) return "Masa berlaku sertifikat belum dicatat oleh Admin.";
	const remainingDays = Math.ceil((new Date(validUntil).getTime() - Date.now()) / 86_400_000);
	if (remainingDays < 0) return "Sertifikat Surveyor sudah kedaluwarsa. Hubungi Admin.";
	if (remainingDays <= 30) return `Sertifikat Surveyor akan kedaluwarsa dalam ${remainingDays} hari.`;
	return null;
}
