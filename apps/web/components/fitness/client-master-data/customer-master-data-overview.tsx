"use client";

import Link from "next/link";
import { ArrowLeft, Pencil } from "lucide-react";
import {
  fitnessMasterDataCategoryConfigs,
  fitnessMasterDataCategoryHref
} from "@/constants/fitness-master-data-client-first";
import { StatusBadge } from "@/components/ui/status-badge";
import type { FitnessMasterDataCategorySummary } from "@/types/fitness-admin";

export function CustomerMasterDataOverview({
  clientId,
  customerName,
  items,
  onEdit
}: {
  clientId: string;
  customerName: string;
  items: FitnessMasterDataCategorySummary[];
  onEdit: () => void;
}) {
  return (
    <section className="workspace-panel customer-master-data-overview" aria-labelledby="customer-master-data-title">
      <div className="fitness-section-header customer-master-data-overview-head">
        <div>
          <h2 id="customer-master-data-title">Master Data Customer</h2>
          <p>Ringkasan seluruh kategori yang dimiliki Customer aktif.</p>
        </div>
        <div className="customer-master-data-overview-actions">
          <button className="secondary-button" onClick={onEdit} type="button">
            <Pencil size={16} />
            <span>Edit Customer</span>
          </button>
          <Link className="secondary-button" href="/fitness/master-data/customers">
            <ArrowLeft size={16} />
            <span>Kembali ke daftar Customer</span>
          </Link>
        </div>
      </div>
      <div className="customer-master-data-grid">
        {items.map((summary) => {
          const config = fitnessMasterDataCategoryConfigs.find((item) => item.id === summary.category);
          if (!config || config.id === "customer") return null;
          return (
            <article className="customer-master-data-card" key={summary.category}>
              <div className="customer-master-data-card-head">
                <h3>{config.label}</h3>
                <StatusBadge tone={summary.completeness === "Lengkap" ? "success" : "warning"}>
                  {summary.completeness}
                </StatusBadge>
              </div>
              <dl>
                <div><dt>Jumlah data</dt><dd>{summary.count}</dd></div>
                <div><dt>Aktif</dt><dd>{summary.activeCount}</dd></div>
                <div><dt>Tidak aktif</dt><dd>{summary.inactiveCount}</dd></div>
                <div><dt>Pembaruan terakhir</dt><dd>{summary.updatedAt}</dd></div>
              </dl>
              <Link
                aria-label={`Kelola ${config.label} untuk Customer ${customerName}`}
                className="primary-button"
                href={fitnessMasterDataCategoryHref(config.id, clientId)}
              >
                Kelola {config.label}
              </Link>
            </article>
          );
        })}
      </div>
    </section>
  );
}
