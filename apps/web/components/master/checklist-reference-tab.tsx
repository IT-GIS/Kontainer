"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { MasterDataPage } from "@/components/master/master-data-page";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated } from "@/lib/api-client";

type CustomerRow = {
  id: string;
  customer_code: string;
  customer_name: string;
  status: string;
};

export function ChecklistReferenceTab({ customerId, baseHref }: { customerId?: string; baseHref: string }) {
  const { accessToken } = useAuth();
  const [customers, setCustomers] = useState<CustomerRow[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(!customerId);

  useEffect(() => {
    if (!accessToken || customerId) return;
    apiPaginated<CustomerRow>("/master/customers?page=1&per_page=100", { accessToken })
      .then((result) => setCustomers(result.rows))
      .catch((cause) => setError(cause instanceof Error ? cause.message : "Customer gagal dimuat."))
      .finally(() => setLoading(false));
  }, [accessToken, customerId]);

  if (customerId) {
    return (
      <MasterDataPage
        backHref={baseHref}
        checklistItemsBaseHref={"/fitness/master-data/checklist-templates/" + customerId}
        endpointOverride={"/customers/" + customerId + "/checklist-templates"}
        fixedValues={{ customer_id: customerId }}
        relationEndpointOverrides={{
          survey_type_id: "/customers/" + customerId + "/survey-types",
          container_type_id: "/customers/" + customerId + "/container-types"
        }}
        resourceId="fitness-checklist-templates"
      />
    );
  }

  return (
    <div className="page-stack master-data-customer-picker">
      <PageHeader title="Checklist" description="Pilih Customer sebelum mengelola template dan item checklist existing." />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      {loading ? <div className="workspace-panel" role="status">Memuat Customer...</div> : null}
      {!loading ? (
        <section className="customer-master-picker-grid" aria-label="Pilih Customer untuk Checklist">
          {customers.map((customer) => (
            <article className="master-customer-card" key={customer.id}>
              <div className="master-customer-card__content">
                <div className="master-customer-card__identity">
                  <h3 className="master-customer-card__name">{customer.customer_name}</h3>
                  <p className="master-customer-card__code"><span>Kode Customer</span><strong>{customer.customer_code}</strong></p>
                </div>
                <StatusBadge tone={customer.status === "active" ? "success" : "warning"}>{customer.status === "active" ? "Aktif" : "Tidak Aktif"}</StatusBadge>
              </div>
              <div className="master-customer-card__actions">
                <Link className="primary-button" href={baseHref + "&customerId=" + customer.id}>Kelola Checklist</Link>
              </div>
            </article>
          ))}
        </section>
      ) : null}
    </div>
  );
}
