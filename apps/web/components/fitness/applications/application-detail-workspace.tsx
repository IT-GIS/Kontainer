import Link from "next/link";
import { CheckCircle2, CircleAlert, ClipboardCheck, UserRoundCheck } from "lucide-react";
import { ActivityTimeline } from "@/components/ui/activity-timeline";
import { CompletionBadge } from "@/components/ui/completion-badge";
import { EmptyState } from "@/components/ui/empty-state";
import { PageHeader } from "@/components/ui/page-header";
import { PageTabs } from "@/components/ui/page-tabs";
import { ProgressTracker } from "@/components/ui/progress-tracker";
import { ResponsiveTableCards, type ResponsiveColumn } from "@/components/ui/responsive-table-cards";
import { StatusBadge } from "@/components/ui/status-badge";
import type { FitnessApplicationContainerDraft, FitnessApplicationDetail, PageTabItem } from "@/types/fitness-admin";

export type FitnessApplicationDetailTab = "summary" | "containers" | "assignment" | "inspection" | "review" | "documents" | "history";

export function FitnessApplicationDetailWorkspace({ application, activeTab }: { application: FitnessApplicationDetail; activeTab: FitnessApplicationDetailTab }) {
  const base = "/fitness/applications/" + application.id;
  const tabs: PageTabItem[] = [
    { id: "summary", label: "Ringkasan", href: base + "?tab=summary" },
    { id: "containers", label: "Peti Kemas", href: base + "?tab=containers", count: application.containerCount },
    { id: "assignment", label: "Penugasan", href: base + "?tab=assignment" },
    { id: "inspection", label: "Pemeriksaan", href: base + "?tab=inspection" },
    { id: "review", label: "Review", href: base + "?tab=review" },
    { id: "documents", label: "Dokumen", href: base + "?tab=documents" },
    { id: "history", label: "Riwayat", href: base + "?tab=history", count: application.history.length }
  ];

  return <div className="page-stack application-detail-page">
    <PageHeader
      eyebrow={application.applicationNumber}
      title="Detail Permohonan"
      description="Ringkasan workflow dan kesiapan penugasan tanpa mengaktifkan modul tahap lanjutan."
      meta={<span className="client-header-meta"><StatusBadge tone={statusTone(application.status)}>{application.status}</StatusBadge><span>{application.clientName}</span><span>Diperbarui: {application.updatedAt}</span></span>}
      secondaryAction={{ label: "Kembali ke Daftar", href: "/fitness/applications" }}
    />
    <div className="client-context-strip" role="status" aria-label={"Klien aktif " + application.clientName}>
      <strong>Klien aktif:</strong><span>{application.clientName}</span><span>clientId: {application.clientId}</span><span>{application.locationName}</span>
    </div>
    <section className="workspace-panel">
      <div className="fitness-section-header"><div><h2>Progress Permohonan</h2><p>Tahap setelah Penugasan tetap berupa ringkasan status pada UI-C.</p></div><CompletionBadge complete={application.completeness.complete} total={application.completeness.total} /></div>
      <ProgressTracker items={application.progress} />
    </section>
    <PageTabs tabs={tabs} activeHref={base + "?tab=" + activeTab} />
    {activeTab === "summary" ? <ApplicationSummary application={application} /> : null}
    {activeTab === "containers" ? <ApplicationContainers application={application} /> : null}
    {activeTab === "assignment" ? <AssignmentSummary application={application} /> : null}
    {activeTab === "history" ? <section className="workspace-panel"><SectionTitle title="Riwayat Permohonan" /><ActivityTimeline items={application.history} /></section> : null}
    {activeTab === "inspection" ? <StagePlaceholder title="Pemeriksaan" description="UI Pemeriksaan penuh belum dikerjakan pada UI-C." /> : null}
    {activeTab === "review" ? <StagePlaceholder title="Review" description="UI Review dan Keputusan penuh belum dikerjakan pada UI-C." /> : null}
    {activeTab === "documents" ? <StagePlaceholder title="Dokumen" description="PDF final, QR, dan verifikasi publik tidak diaktifkan pada UI-C." /> : null}
  </div>;
}

function ApplicationSummary({ application }: { application: FitnessApplicationDetail }) {
  return <div className="application-detail-grid">
    <section className="workspace-panel">
      <SectionTitle title="Ringkasan Data" />
      <dl className="application-detail-facts">
        <Fact label="Nomor Permohonan" value={application.applicationNumber} />
        <Fact label="Tanggal" value={application.applicationDate} />
        <Fact label="Klien" value={application.clientName} />
        <Fact label="Pemohon" value={application.applicantName} />
        <Fact label="Pemilik/Pengguna Peti Kemas" value={application.ownerUserName} />
        <Fact label="Kategori Layanan" value={application.serviceCategory} />
        <Fact label="Nomor Surat" value={application.letterNumber} />
        <Fact label="Lokasi" value={application.locationName} />
        <Fact label="PIC Lokasi" value={application.picName + " · " + application.picPhone} />
        <Fact label="Rencana Pemeriksaan" value={application.plannedInspectionDate || "Belum ditentukan"} />
      </dl>
    </section>
    <ReadinessPanel application={application} />
  </div>;
}

function ReadinessPanel({ application }: { application: FitnessApplicationDetail }) {
  const readiness = application.readiness;
  return <section className="workspace-panel application-readiness">
    <div className="fitness-section-header">
      <div><h2>Kesiapan Penugasan</h2><p>{readiness.readyCount} dari {readiness.totalCount} persyaratan siap.</p></div>
      <StatusBadge tone={readiness.ready ? "success" : "warning"}>{readiness.ready ? "Siap Ditugaskan" : "Belum Siap"}</StatusBadge>
    </div>
    <ul>
      {readiness.items.map((item) => <li key={item.id} className={item.ready ? "application-ready" : "application-not-ready"}>
        {item.ready ? <CheckCircle2 aria-hidden="true" size={18} /> : <CircleAlert aria-hidden="true" size={18} />}
        <span><strong>{item.label}</strong><small>{item.detail}</small></span>
      </li>)}
    </ul>
    {readiness.ready ? (
      <Link className="primary-button" href={"/fitness/assignments?applicationId=" + application.id}><UserRoundCheck size={16} />Buka Penugasan</Link>
    ) : (
      <button className="primary-button" disabled title="Lengkapi seluruh kesiapan sebelum Penugasan" type="button"><UserRoundCheck size={16} />Penugasan belum tersedia</button>
    )}
  </section>;
}

function ApplicationContainers({ application }: { application: FitnessApplicationDetail }) {
  const columns: ResponsiveColumn<FitnessApplicationContainerDraft>[] = [
    { key: "number", header: "Nomor Peti Kemas", render: (row) => <strong>{row.containerNumber}</strong> },
    { key: "type", header: "Jenis", render: (row) => row.containerTypeName ?? row.containerTypeId },
    { key: "numberValid", header: "Validasi Nomor", render: (row) => <StatusBadge tone={row.numberValid ? "success" : "danger"}>{row.numberValid ? "Valid" : "Belum Valid"}</StatusBadge> },
    { key: "technical", header: "Data Teknis Minimum", render: (row) => <StatusBadge tone={row.technicalComplete ? "success" : "warning"}>{row.technicalComplete ? "Lengkap" : "Belum Lengkap"}</StatusBadge> }
  ];
  return <section className="workspace-panel">
    <SectionTitle title="Peti Kemas Permohonan" />
    {application.containers.length ? <ResponsiveTableCards columns={columns} rows={application.containers} getRowId={(row) => row.id} getRowTitle={(row) => row.containerNumber} /> : <EmptyState title="Belum ada peti kemas" description="Tambahkan peti kemas pada draf Permohonan. Form teknis penuh berada pada UI-D." />}
  </section>;
}

function AssignmentSummary({ application }: { application: FitnessApplicationDetail }) {
  return <div className="application-detail-grid">
    <ReadinessPanel application={application} />
    <section className="workspace-panel">
      <SectionTitle title="Penugasan" />
      <div className="application-stage-note"><ClipboardCheck size={20} /><p>UI-C hanya menyediakan readiness gate dan CTA. Pemilihan Surveyor GIFT, jadwal, dan instruksi penugasan tetap menjadi scope UI-E.</p></div>
    </section>
  </div>;
}

function StagePlaceholder({ title, description }: { title: string; description: string }) {
  return <section className="workspace-panel"><EmptyState title={title + " belum diaktifkan"} description={description} /></section>;
}

function SectionTitle({ title }: { title: string }) {
  return <div className="fitness-section-header"><div><h2>{title}</h2></div></div>;
}

function Fact({ label, value }: { label: string; value: string }) {
  return <div><dt>{label}</dt><dd>{value}</dd></div>;
}

function statusTone(status: FitnessApplicationDetail["status"]) {
  if (status === "Selesai") return "success" as const;
  if (status === "Perlu Perbaikan") return "danger" as const;
  if (status === "Draf") return "warning" as const;
  return "info" as const;
}
