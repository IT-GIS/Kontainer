"use client";

import { Search } from "lucide-react";
import { useCallback, useEffect, useState } from "react";
import { ProtectedRoute } from "@/components/auth/protected-route";
import { AppShell } from "@/components/layout/app-shell";
import { DataTable } from "@/components/ui/data-table";
import { PageHeader } from "@/components/ui/page-header";
import { StatusBadge } from "@/components/ui/status-badge";
import { useAuth } from "@/hooks/use-auth";
import { apiPaginated, buildQuery } from "@/lib/api-client";

type UserRow = {
  id: string;
  name: string;
  email: string;
  username: string;
  status: string;
  roles: string[];
  last_login_at?: string | null;
};

export default function UsersPage() {
  return <ProtectedRoute><AppShell title="User & Hak Akses"><UsersContent /></AppShell></ProtectedRoute>;
}

function UsersContent() {
  const { accessToken } = useAuth();
  const [rows, setRows] = useState<UserRow[]>([]);
  const [page, setPage] = useState(1);
  const [totalPages, setTotalPages] = useState(1);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const [role, setRole] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(false);

  const load = useCallback(async () => {
    if (!accessToken) return;
    setIsLoading(true);
    setError(null);
    try {
      const result = await apiPaginated<UserRow>(`/users${buildQuery({ page, per_page: 10, search, status, role })}`, { accessToken });
      setRows(result.rows);
      setTotalPages(Math.max(1, Number(result.meta.total_pages ?? 1)));
    } catch (err) {
      setError(err instanceof Error ? err.message : "Gagal mengambil user.");
    } finally {
      setIsLoading(false);
    }
  }, [accessToken, page, role, search, status]);

  useEffect(() => {
    const timer = window.setTimeout(() => void load(), 0);
    return () => window.clearTimeout(timer);
  }, [load]);

  return <div className="page-stack">
    <PageHeader title="User & Hak Akses" description="Kelola daftar akun serta tinjau Role dan Permission pengguna." />
    <div className="toolbar">
      <label className="search-box"><Search size={17} /><span className="sr-only">Cari user</span><input value={search} onChange={(event) => { setPage(1); setSearch(event.target.value); }} placeholder="Cari nama, email, username" /></label>
      <label><span className="sr-only">Filter role user</span><select value={role} onChange={(event) => { setPage(1); setRole(event.target.value); }}><option value="">Semua Role</option>{["super_admin", "admin", "surveyor", "supervisor", "finance", "management"].map((item) => <option value={item} key={item}>{item.replaceAll("_", " ")}</option>)}</select></label>
      <label><span className="sr-only">Filter status user</span><select value={status} onChange={(event) => { setPage(1); setStatus(event.target.value); }}><option value="">Semua Status</option><option value="active">Active</option><option value="inactive">Inactive</option><option value="locked">Locked</option></select></label>
    </div>
    {error ? <div className="alert alert-danger" role="alert">{error}</div> : null}
    <DataTable rows={rows} isLoading={isLoading} page={page} totalPages={totalPages} onPageChange={setPage} emptyText="User tidak ditemukan." columns={[
      { key: "name", header: "Name", render: (row) => row.name },
      { key: "email", header: "Email", render: (row) => row.email },
      { key: "username", header: "Username", render: (row) => row.username || "-" },
      { key: "roles", header: "Roles", render: (row) => row.roles.join(", ") || "-" },
      { key: "status", header: "Status", render: (row) => <StatusBadge tone={row.status === "active" ? "success" : row.status === "locked" ? "danger" : "neutral"}>{row.status.toUpperCase()}</StatusBadge> },
      { key: "last_login", header: "Last Login", render: (row) => row.last_login_at ?? "-" }
    ]} />
    <section className="workspace-panel page-stack" id="role-permission" aria-labelledby="role-permission-heading">
      <div>
        <h2 id="role-permission-heading">Role & Permission</h2>
        <p className="muted-text">Role dan Permission menentukan akses setiap pengguna di dalam aplikasi.</p>
      </div>
      <div className="alert alert-warning">Pastikan setiap pengguna hanya memperoleh akses yang sesuai dengan tanggung jawabnya.</div>
    </section>
  </div>;
}
