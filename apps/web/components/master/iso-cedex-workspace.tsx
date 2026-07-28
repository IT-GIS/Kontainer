"use client";

import { Box, ClipboardCheck, Hammer, MapPinned, PackageOpen, ShieldAlert } from "lucide-react";
import Link from "next/link";
import { useEffect, useMemo, useState } from "react";
import { CustomerScopedMasterDetail } from "@/components/master/customer-scoped-master-data";
import { WorkspaceTabs } from "@/components/ui/workspace-tabs";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated } from "@/lib/api-client";
import type { FitnessMasterDataCategory } from "@/types/fitness-admin";

export type IsoCedexTab = "location" | "component" | "damage" | "material" | "action" | "reference";

type TabDefinition = {
  id: IsoCedexTab;
  label: string;
  summary: string;
  category: FitnessMasterDataCategory;
  addLabel: string;
  icon: typeof MapPinned;
};

const tabs: TabDefinition[] = [
  { id: "location", label: "Location", summary: "Location Code", category: "cedex-location", addLabel: "+ Add Location", icon: MapPinned },
  { id: "component", label: "Component", summary: "Component Code", category: "cedex-component", addLabel: "+ Add Component", icon: Box },
  { id: "damage", label: "Damage", summary: "Damage Code", category: "cedex-damage", addLabel: "+ Add Damage", icon: ShieldAlert },
  { id: "material", label: "Material", summary: "Material Code", category: "cedex-material", addLabel: "+ Add Material", icon: PackageOpen },
  { id: "action", label: "Action", summary: "Action Code", category: "cedex-action", addLabel: "+ Add Action", icon: Hammer },
  { id: "reference", label: "Inspection Reference", summary: "Inspection Reference", category: "cedex-reference", addLabel: "+ Add Reference", icon: ClipboardCheck }
];

export function IsoCedexWorkspace({
  customerId,
  initialTab,
  showLegacyResponsibility = false
}: {
  customerId: string;
  initialTab: IsoCedexTab;
  showLegacyResponsibility?: boolean;
}) {
  const { accessToken, user } = useAuth();
  const [counts, setCounts] = useState<Partial<Record<IsoCedexTab, number>>>({});
  const [countsLoading, setCountsLoading] = useState(true);
  const active = tabs.find((tab) => tab.id === initialTab) ?? tabs[0];
  const isEditor = Boolean(user?.roles.some((role) => role === "admin" || role === "super_admin"));
  const readOnly = !isEditor;
  const customerQuery = `customerId=${encodeURIComponent(customerId)}`;

  const countEndpoints = useMemo<Record<IsoCedexTab, string>>(() => ({
    location: `/customers/${customerId}/cedex/locations`,
    component: `/customers/${customerId}/cedex/components`,
    damage: `/customers/${customerId}/cedex/damages`,
    material: `/customers/${customerId}/cedex/materials`,
    action: `/customers/${customerId}/cedex/repairs`,
    reference: "/fitness/master-data/test-parameters"
  }), [customerId]);

  useEffect(() => {
    if (!accessToken || showLegacyResponsibility) return;
    let activeRequest = true;
    Promise.all(tabs.map(async (tab) => {
      const result = await apiPaginated<Record<string, unknown>>(`${countEndpoints[tab.id]}?page=1&per_page=1`, { accessToken });
      return [tab.id, Number(result.meta.total ?? result.rows.length)] as const;
    }))
      .then((entries) => {
        if (activeRequest) setCounts(Object.fromEntries(entries));
      })
      .catch(() => {
        if (activeRequest) setCounts({});
      })
      .finally(() => {
        if (activeRequest) setCountsLoading(false);
      });
    return () => {
      activeRequest = false;
    };
  }, [accessToken, countEndpoints, showLegacyResponsibility]);

  if (showLegacyResponsibility) {
    return (
      <div className="page-stack">
        <Link className="secondary-button iso-cedex-back" href={`/master/iso-cedex?${customerQuery}&tab=location`}>← Kembali ke ISO CEDEX</Link>
        <section className="iso-cedex-heading">
          <div>
            <p className="eyebrow">Legacy</p>
            <h1>Responsibility Code</h1>
            <p>Referensi lama dipertahankan untuk membaca temuan historis. Data baru tidak lagi meminta Responsibility.</p>
          </div>
        </section>
        <CustomerScopedMasterDetail
          category="responsibility-code"
          customerId={customerId}
          routeFamily="actual"
          forceReadOnly
          forceReadOnlyMessage="Responsibility Code adalah referensi legacy dan hanya dapat dibaca."
          hideBackLink
          masterDataProps={{ enableSorting: true, responsiveCards: true, showImportUnavailable: true, enableExport: true, showRichEmptyState: true, actionIdPrefix: "iso-cedex-responsibility" }}
        />
      </div>
    );
  }

  return (
    <div className="page-stack iso-cedex-workspace">
      <Link className="secondary-button iso-cedex-back" href="/master/iso-cedex">← Pilih Customer Lain</Link>

      <section className="iso-cedex-heading">
        <div>
          <p className="eyebrow">Master Data</p>
          <h1>ISO CEDEX</h1>
          <p>Kelola kode inspeksi sesuai Customer. Inspection Reference memakai master global dan tetap tersedia bagi Surveyor melalui mapping Customer dan Survey Type.</p>
        </div>
      </section>

      {readOnly ? (
        <div className="alert alert-warning">Anda membuka ISO CEDEX dalam mode baca-saja. Perubahan hanya dapat dilakukan oleh Admin atau Super Admin.</div>
      ) : null}

      <section aria-label="Ringkasan ISO CEDEX" className="iso-cedex-summary-grid">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          return (
            <Link className={`iso-cedex-summary-card${active.id === tab.id ? " is-active" : ""}`} href={`/master/iso-cedex?${customerQuery}&tab=${tab.id}`} key={tab.id}>
              <span className="iso-cedex-summary-icon"><Icon size={19} /></span>
              <span><strong>{tab.summary}</strong><small>{countsLoading ? "Memuat..." : `${counts[tab.id] ?? "—"} data`}</small></span>
            </Link>
          );
        })}
      </section>

      <WorkspaceTabs
        activeID={active.id}
        label="ISO CEDEX"
        tabs={tabs.map((tab) => ({ id: tab.id, label: tab.label, href: `/master/iso-cedex?${customerQuery}&tab=${tab.id}` }))}
      />

      {active.id === "reference" ? (
        <div className="alert alert-warning">Inspection Reference adalah presentasi master global Test Parameter. Ketersediaan checklist tetap mengikuti mapping Customer dan Survey Type.</div>
      ) : null}
      {active.id === "action" ? (
        <div className="alert alert-warning">Action Code disimpan melalui resource legacy CEDEX Repair; istilah UI dan lembar Surveyor tetap “Rekomendasi Tindakan”.</div>
      ) : null}

      <CustomerScopedMasterDetail
        category={active.category}
        customerId={customerId}
        routeFamily="actual"
        hideBackLink
        forceReadOnly={readOnly}
        forceReadOnlyMessage="ISO CEDEX tersedia dalam mode baca-saja untuk Supervisor dan Management."
        addButtonLabelOverride={active.addLabel}
        dialogTitleOverride={active.summary}
        masterDataProps={{
          showResourceHeader: false,
          showToolbarAdd: true,
          showRichEmptyState: true,
          showImportUnavailable: true,
          enableExport: true,
          enableSaveAndNew: true,
          enableSorting: true,
          responsiveCards: true,
          dialogSize: active.id === "damage" || active.id === "reference" ? "large" : "medium",
          actionIdPrefix: `iso-cedex-${active.id}`,
          filters: active.id === "location" ? [
            { key: "face", label: "Face", options: ["front", "rear", "left", "right", "top", "bottom", "understructure"].map((value) => ({ label: value, value })) },
            { key: "container_size", label: "Container Size", options: ["all", "20", "40", "45"].map((value) => ({ label: value, value })) }
          ] : undefined,
          emptyTitle: `${active.summary} belum tersedia`,
          emptyDescription: readOnly ? "Belum ada data yang dapat ditampilkan." : `Tambahkan ${active.summary} pertama untuk Customer ini.`
        }}
      />
    </div>
  );
}
