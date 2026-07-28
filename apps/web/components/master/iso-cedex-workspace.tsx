"use client";

import { Box, Hammer, History, MapPinned, PackageOpen, Settings2, ShieldAlert, UserRoundCog } from "lucide-react";
import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { CustomerScopedMasterDetail } from "@/components/master/customer-scoped-master-data";
import { IsoCedexDecisionRules, type DamageRuleTarget } from "@/components/master/iso-cedex-decision-rules";
import { MasterDataPage, type MasterDataPageProps, type MasterRow } from "@/components/master/master-data-page";
import { WorkspaceTabs } from "@/components/ui/workspace-tabs";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated } from "@/lib/api-client";
import type { FitnessMasterDataCategory } from "@/types/fitness-admin";
import { masterResources } from "@/constants/master-data";

export type IsoCedexTab = "location" | "component" | "damage" | "action" | "material";

type TabDefinition = {
  id: IsoCedexTab;
  label: string;
  summary: string;
  category: FitnessMasterDataCategory;
  resourceId: keyof typeof masterResources;
  globalEndpoint: string;
  customerEndpoint: string;
  addLabel: string;
  icon: typeof MapPinned;
};

const tabs: TabDefinition[] = [
  { id: "location", label: "Location", summary: "Location Code", category: "cedex-location", resourceId: "cedex-locations", globalEndpoint: "/master/cedex/locations", customerEndpoint: "cedex/locations", addLabel: "+ Tambah Location Code", icon: MapPinned },
  { id: "component", label: "Component", summary: "Component Code", category: "cedex-component", resourceId: "cedex-components", globalEndpoint: "/master/cedex/components", customerEndpoint: "cedex/components", addLabel: "+ Tambah Component Code", icon: Box },
  { id: "damage", label: "Damage", summary: "Damage Code", category: "cedex-damage", resourceId: "cedex-damages", globalEndpoint: "/master/cedex/damages", customerEndpoint: "cedex/damages", addLabel: "+ Tambah Damage Code", icon: ShieldAlert },
  { id: "action", label: "Action Repair", summary: "Action Repair Code", category: "cedex-action", resourceId: "cedex-actions", globalEndpoint: "/master/cedex/repairs", customerEndpoint: "cedex/repairs", addLabel: "+ Tambah Action Repair Code", icon: Hammer },
  { id: "material", label: "Material", summary: "Material Code", category: "cedex-material", resourceId: "cedex-materials", globalEndpoint: "/master/cedex/materials", customerEndpoint: "cedex/materials", addLabel: "+ Tambah Material Code", icon: PackageOpen }
];

export function IsoCedexWorkspace({
  customerId,
  initialTab,
  showLegacyResponsibility = false
}: {
  customerId?: string;
  initialTab: IsoCedexTab;
  showLegacyResponsibility?: boolean;
}) {
  const { accessToken, user } = useAuth();
  const [counts, setCounts] = useState<Partial<Record<IsoCedexTab, number>>>({});
  const [countsLoading, setCountsLoading] = useState(true);
  const [countsError, setCountsError] = useState(false);
  const [damageRuleTarget, setDamageRuleTarget] = useState<DamageRuleTarget | null>(null);
  const active = tabs.find((tab) => tab.id === initialTab) ?? tabs[0];
  const isEditor = Boolean(user?.roles.some((role) => role === "admin" || role === "super_admin"));
  const readOnly = !isEditor;
  const customerMode = Boolean(customerId);

  const countEndpoints = useMemo<Record<IsoCedexTab, string>>(() => Object.fromEntries(tabs.map((tab) => [
    tab.id,
    customerId ? `/customers/${customerId}/${tab.customerEndpoint}` : tab.globalEndpoint
  ])) as Record<IsoCedexTab, string>, [customerId]);

  useEffect(() => {
    if (!accessToken || showLegacyResponsibility) return;
    let activeRequest = true;
    const timer = window.setTimeout(() => {
      setCountsLoading(true);
      setCountsError(false);
      Promise.all(tabs.map(async (tab) => {
        const result = await apiPaginated<Record<string, unknown>>(`${countEndpoints[tab.id]}?page=1&per_page=1&status=active`, { accessToken });
        return [tab.id, Number(result.meta.total ?? result.rows.length)] as const;
      }))
        .then((entries) => {
          if (activeRequest) setCounts(Object.fromEntries(entries));
        })
        .catch(() => {
          if (activeRequest) {
            setCounts({});
            setCountsError(true);
          }
        })
        .finally(() => {
          if (activeRequest) setCountsLoading(false);
        });
    }, 0);
    return () => {
      activeRequest = false;
      window.clearTimeout(timer);
    };
  }, [accessToken, countEndpoints, showLegacyResponsibility]);

  if (showLegacyResponsibility && customerId) {
    return (
      <div className="page-stack">
        <Link className="secondary-button iso-cedex-back" href={isoHref("location", customerId)}>&larr; Kembali ke ISO CEDEX</Link>
        <section className="iso-cedex-heading"><div><p className="eyebrow">Legacy</p><h1>Responsibility Code</h1><p>Referensi lama dipertahankan hanya untuk membaca temuan historis.</p></div></section>
        <CustomerScopedMasterDetail
          category="responsibility-code"
          customerId={customerId}
          routeFamily="actual"
          forceReadOnly
          forceReadOnlyMessage="Responsibility Code adalah referensi legacy dan hanya dapat dibaca."
          hideBackLink
          masterDataProps={{ enableSorting: true, responsiveCards: true, enableExport: true, showRichEmptyState: true, actionIdPrefix: "iso-cedex-responsibility" }}
        />
      </div>
    );
  }

  const relationEndpointOverrides = active.id === "damage" ? {
    default_action_id: customerId ? `/customers/${customerId}/cedex/repairs` : "/master/cedex/repairs"
  } : undefined;
  const sharedProps: Omit<MasterDataPageProps, "resourceId"> = {
    showResourceHeader: false,
    showToolbarAdd: true,
    showRichEmptyState: true,
    enableExport: true,
    enableSaveAndNew: true,
    enableSorting: true,
    responsiveCards: true,
    dialogSize: active.id === "damage" || active.id === "location" ? "large" : "medium",
    actionIdPrefix: `iso-cedex-${active.id}`,
    relationEndpointOverrides,
    locationGenerator: active.id === "location",
    showHistoryAction: true,
    canMutateRow: (row) => String(row.source_type ?? "legacy") !== "legacy",
    onSaved: active.id === "damage" ? (row: MasterRow) => setDamageRuleTarget(damageTarget(row)) : undefined,
    renderRowActions: active.id === "damage" ? (row: MasterRow) => (
      <button className="icon-button" aria-label={`Kelola Decision Rule ${String(row.code ?? "")}`} onClick={() => setDamageRuleTarget(damageTarget(row))} title="Tolerance & Decision Rule" type="button">
        <Settings2 size={16} />
      </button>
    ) : undefined,
    filters: sourceFilters(active),
    emptyTitle: `Belum ada ${active.summary}`,
    emptyDescription: readOnly ? "Belum ada data yang dapat ditampilkan." : `Tambahkan ${active.summary} agar Surveyor dapat memilihnya saat mencatat temuan.`
  };

  return (
    <div className="page-stack iso-cedex-workspace">
      {customerMode ? <Link className="secondary-button iso-cedex-back" href="/master/iso-cedex?scope=customer">&larr; Pilih Customer Lain</Link> : null}

      <section className="iso-cedex-heading">
        <div>
          <p className="eyebrow">MASTER DATA</p>
          <h1>ISO CEDEX Code</h1>
          <p>Kelola kode lokasi, komponen, kerusakan, tindakan, dan material yang digunakan Surveyor saat mencatat temuan Inspeksi Kelaikan.</p>
        </div>
        <div className="iso-cedex-heading-actions">
          <Link className="secondary-button" href="/master/inspection-references?tab=test-parameter">Buka Acuan &amp; Kriteria Pemeriksaan</Link>
          <Link className="secondary-button" href="/master/iso-cedex/proposals"><UserRoundCog size={16} />Review Pengajuan</Link>
          <Link className="secondary-button" href="/settings/audit-log"><History size={16} />Riwayat Perubahan</Link>
          <Link className="secondary-button" href={customerMode ? "/master/iso-cedex" : "/master/iso-cedex?scope=customer"}>{customerMode ? "Kode Standar Global" : "Mode Lanjutan: Kode Khusus Customer"}</Link>
        </div>
      </section>

      <div className="alert alert-info iso-cedex-how-it-works"><strong>Cara kerja:</strong><span>Admin menyiapkan kode CEDEX. Surveyor memilih kode tersebut saat inspeksi. Deskripsi lengkap akan dibuat otomatis oleh sistem untuk laporan.</span></div>
      <div className="iso-scope-banner"><strong>{customerMode ? "Kode Khusus Customer" : "Kode Standar Global"}</strong><span>{customerMode ? "Override tambahan hanya berlaku pada pekerjaan Customer terpilih dan wajib memiliki alasan." : "Kamus standar dipakai lintas Customer. Data legacy tetap terbaca tetapi tidak dapat diubah."}</span></div>

      {readOnly ? <div className="alert alert-warning">Halaman dibuka dalam mode baca-saja. Perubahan hanya dapat dilakukan oleh Admin yang berwenang.</div> : null}
      {countsError ? <div className="alert alert-danger">Ringkasan ISO CEDEX gagal dimuat. Gunakan tombol Refresh pada tabel untuk mencoba lagi.</div> : null}

      <section aria-label="Ringkasan ISO CEDEX" className="iso-cedex-summary-grid">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          return (
            <Link className={`iso-cedex-summary-card${active.id === tab.id ? " is-active" : ""}`} href={isoHref(tab.id, customerId)} key={tab.id}>
              <span className="iso-cedex-summary-icon"><Icon size={19} /></span>
              <span><strong>{tab.summary}</strong><small>{countsLoading ? "Memuat..." : `${counts[tab.id] ?? 0} data aktif`}</small></span>
            </Link>
          );
        })}
      </section>

      <WorkspaceTabs activeID={active.id} label="ISO CEDEX Code" tabs={tabs.map((tab) => ({ id: tab.id, label: tab.label, href: isoHref(tab.id, customerId) }))} />

      {active.id === "action" ? <div className="alert alert-warning">Compatibility backend tetap menggunakan resource CEDEX Repair, sedangkan UI memakai istilah Action Repair Code dan Rekomendasi Tindakan.</div> : null}
      {active.id === "damage" ? <div className="iso-form-stage"><span className="iso-form-step">1</span><div><strong>Informasi Damage</strong><p>Simpan metadata Damage, lalu kelola Tolerance &amp; Decision Rule tanpa mengarang nilai tolerance.</p></div></div> : null}

      {customerId ? (
        <CustomerScopedMasterDetail
          category={active.category}
          customerId={customerId}
          routeFamily="actual"
          hideBackLink
          forceReadOnly={readOnly}
          forceReadOnlyMessage="ISO CEDEX tersedia dalam mode baca-saja untuk peran ini."
          addButtonLabelOverride={active.addLabel}
          dialogTitleOverride={active.summary}
          masterDataProps={sharedProps}
        />
      ) : (
        <MasterDataPage
          {...sharedProps}
          resourceId={active.resourceId}
          endpointOverride={active.globalEndpoint}
          fixedValues={{ source_type: "standard_global" }}
          readOnly={readOnly}
          readOnlyMessage="ISO CEDEX tersedia dalam mode baca-saja untuk peran ini."
          addButtonLabelOverride={active.addLabel}
          dialogTitleOverride={active.summary}
        />
      )}

      {active.id === "damage" && damageRuleTarget ? (
        <IsoCedexDecisionRules customerId={customerId} damage={damageRuleTarget} readOnly={readOnly} onClose={() => setDamageRuleTarget(null)} />
      ) : null}
    </div>
  );
}

function sourceFilters(active: TabDefinition): MasterDataPageProps["filters"] {
  const filters: NonNullable<MasterDataPageProps["filters"]> = [{
    key: "source",
    label: "Sumber",
    options: [
      { label: "Standar Global", value: "standard_global" },
      { label: "Khusus Customer", value: "customer_specific" },
      { label: "Legacy", value: "legacy" }
    ]
  }];
  if (active.id === "location") {
    filters.push({ key: "container_size", label: "Container Size", options: ["all", "20", "40", "45"].map((value) => ({ label: value, value })) });
  }
  return filters;
}

function isoHref(tab: IsoCedexTab, customerId?: string) {
  const customer = customerId ? `scope=customer&customerId=${encodeURIComponent(customerId)}&` : "";
  return `/master/iso-cedex?${customer}tab=${tab}`;
}

function damageTarget(row: MasterRow): DamageRuleTarget {
  return { id: String(row.id ?? ""), code: String(row.code ?? "Damage"), name: String(row.damage_name ?? "") };
}
