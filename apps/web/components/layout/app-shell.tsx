"use client";

import { Bell, ChevronLeft, ChevronRight, LogOut, Menu, ShieldCheck, X } from "lucide-react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useMemo, useState } from "react";
import { navigationItems } from "@/constants/navigation";
import { useAuth } from "@/hooks/use-auth";
import { canAny } from "@/lib/permissions";
import type { CurrentUser } from "@/types/auth";

type AppShellProps = {
  title: string;
  children: React.ReactNode;
};

export function AppShell({ title, children }: AppShellProps) {
  const { user, logout } = useAuth();
  const pathname = usePathname();
  const [isOpen, setIsOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const visibleItems = useMemo(() => navigationItems.filter((item) => canAny(user, item.permissions)), [user]);
  const sections = ["Main", "Master", "Operations", "System"] as const;
  const initials = (user?.name ?? "GIFT User")
    .split(" ")
    .map((part) => part[0])
    .slice(0, 2)
    .join("")
    .toUpperCase();
  const role = user?.roles[0] ?? "user";

  return (
    <div className={`app-layout source-app-layout ${collapsed ? "source-app-layout-collapsed" : ""}`}>
      <aside className={`sidebar source-sidebar ${isOpen ? "sidebar-open" : ""}`}>
        <div className="sidebar-head source-sidebar-head">
          <div className="source-shell-mark"><ShieldCheck size={20} /></div>
          <div className="source-sidebar-brand">
            <strong>PT. Global Inspeksi Forensik Teknik</strong>
            <span>Dashboard Internal</span>
          </div>
          <button className="icon-button sidebar-close" onClick={() => setIsOpen(false)} title="Tutup menu">
            <X size={18} />
          </button>
        </div>

        <button
          className="source-collapse-button"
          type="button"
          onClick={() => setCollapsed((value) => !value)}
          aria-label={collapsed ? "Perluas sidebar" : "Ciutkan sidebar"}
        >
          {collapsed ? <ChevronRight size={15} /> : <ChevronLeft size={15} />}
        </button>

        <nav className="sidebar-nav source-sidebar-nav">
          {sections.map((section) => {
            const items = visibleItems.filter((item) => item.section === section);
            if (items.length === 0) return null;
            return (
              <div className="nav-section" key={section}>
                <p>{section}</p>
                {items.map((item) => {
                  const Icon = item.icon;
                  const active = pathname === item.href || pathname.startsWith(item.href + "/");
                  return (
                    <Link
                      className={`nav-link ${active ? "nav-link-active" : ""}`}
                      href={item.href}
                      key={item.href}
                      onClick={() => setIsOpen(false)}
                      title={collapsed ? item.label : undefined}
                    >
                      <Icon size={17} />
                      <span>{item.label}</span>
                    </Link>
                  );
                })}
              </div>
            );
          })}
        </nav>

        <div className="source-sidebar-footer">
          <button className="source-logout-button" onClick={() => void logout()} type="button">
            <LogOut size={17} />
            <span>Keluar</span>
          </button>
        </div>
      </aside>

      <div className="main-area source-main-area">
        <header className="topbar source-topbar">
          <button className="icon-button menu-button" onClick={() => setIsOpen(true)} title="Buka menu">
            <Menu size={19} />
          </button>
          <div className="topbar-title source-topbar-copy">
            <h1>{title}</h1>
            <p>Selamat datang kembali, kelola inspeksi &amp; sertifikasi kontainer Anda.</p>
          </div>
          <div className="topbar-actions source-profile-actions">
            <span className="source-role-badge">{roleLabel(role)}</span>
            <button className="source-notification-button" type="button" title="Notifikasi"><Bell size={17} /></button>
            <div className="source-profile">
              <div className="source-avatar">{initials}</div>
              <div className="source-profile-copy">
                <strong>{user?.name ?? "GIFT User"}</strong>
                <span>{user?.email ?? dashboardSubtitle(user)}</span>
              </div>
            </div>
          </div>
        </header>
        <main className="content-area source-content-area">{children}</main>
      </div>
    </div>
  );
}

function dashboardSubtitle(user: CurrentUser | null) {
  if (!user) return "Protected workspace";
  return `${user.name} - ${user.roles.join(", ")}`;
}

function roleLabel(role: string) {
  const labels: Record<string, string> = {
    super_admin: "Super Admin",
    admin: "Admin",
    surveyor: "Surveyor",
    supervisor: "Supervisor",
    finance: "Finance",
    management: "Management"
  };
  return labels[role] ?? role;
}
