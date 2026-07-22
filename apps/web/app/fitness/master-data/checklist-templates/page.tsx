"use client";

import Link from "next/link";
import { useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { PageHeader } from "@/components/ui/page-header";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated } from "@/lib/api-client";

type CustomerRow = { id: string; customer_code: string; customer_name: string };

export default function ChecklistTemplateCustomerPage() {
  const { accessToken } = useAuth();
  const [customers, setCustomers] = useState<CustomerRow[]>([]);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!accessToken) return;
    apiPaginated<CustomerRow>("/master/customers?page=1&per_page=100&status=active", { accessToken })
      .then((result) => setCustomers(result.rows))
      .catch((cause) => setError(cause instanceof Error ? cause.message : "Customer gagal dimuat."));
  }, [accessToken]);

  return <ProtectedRoute><AppShell title="Template Checklist" subtitle="Checklist Surveyor per Customer.">
    <div className="page-stack">
      <PageHeader title="Template Checklist per Customer" description="Pilih Customer sebelum mengelola header dan item checklist." />
      {error ? <div className="alert alert-danger">{error}</div> : null}
      <section className="workspace-panel customer-master-picker-grid">
        {customers.map((customer) => <Link className="workspace-panel" key={customer.id} href={`/fitness/master-data/checklist-templates/${customer.id}`}>
          <strong>{customer.customer_name}</strong><span>{customer.customer_code}</span><span>Kelola Template Checklist</span>
        </Link>)}
      </section>
    </div>
  </AppShell></ProtectedRoute>;
}
