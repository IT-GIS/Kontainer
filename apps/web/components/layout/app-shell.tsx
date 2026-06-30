"use client";

import {
  Bell, ChevronDown, ChevronLeft, ChevronRight, LogOut, Menu, ShieldCheck, X
} from "lucide-react";
import Link from "next/link";
import { usePathname, useSearchParams } from "next/navigation";
import { useMemo, useState } from "react";
import {
  navigationWorkspaces, type NavigationGroup, type NavigationLink
} from "@/constants/navigation";
import { useAuth } from "@/hooks/use-auth";
import {
  activeNavigationID, navigationLabel, visibleNavigation
} from "@/lib/navigation";
import type { CurrentUser, RoleCode } from "@/types/auth";

type AppShellProps = {
  title: string;
  children: React.ReactNode;
};

export function AppShell({ title, children }: AppShellProps) {
  const { user, logout } = useAuth();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [isOpen, setIsOpen] = useState(false);
  const [collapsed, setCollapsed] = useState(false);
  const [expandedGroups, setExpandedGroups] = useState<Record<string, boolean>>({});
  const workspaces = useMemo(() => visibleNavigation(navigationWorkspaces, user), [user]);
  const activeID = useMemo(
    () => activeNavigationID(workspaces, pathname, searchParams),
    [pathname, searchParams, workspaces]
  );
  const initials = (user?.name ?? "GIFT User")
    .split(" ")
    .map((part) => part[0])
    .slice(0, 2)
    .join("")
    .toUpperCase();
  const roleSummary = user?.roles.map(roleLabel).join(" / ") ?? "User";

  function renderLink(item: NavigationLink, nested = false) {
    const Icon = item.icon;
    const active = item.id === activeID;
    const label = navigationLabel(item, user);
    return (
      <Link
        className={`nav-link ${nested ? "nav-sublink" : ""} ${active ? "nav-link-active" : ""}`}
        href={item.href}
        key={item.id}
        onClick={() => setIsOpen(false)}
        title={collapsed ? label : undefined}
      >
        <Icon size={nested ? 15 : 17} />
        <span>{label}</span>
      </Link>
    );
  }

  function renderGroup(item: NavigationGroup) {
    const Icon = item.icon;
    const groupActive = item.children.some((child) => child.id === activeID);
    const expanded = expandedGroups[item.id] ?? groupActive;
    return (
      <div className={`nav-group ${groupActive ? "nav-group-active" : ""}`} key={item.id}>
        <button
          className="nav-group-trigger"
          type="button"
          aria-expanded={expanded}
          onClick={() => setExpandedGroups((current) => ({ ...current, [item.id]: !expanded }))}
          title={collapsed ? item.label : undefined}
        >
          <Icon size={17} />
          <span>{item.label}</span>
          <ChevronDown className={`nav-group-chevron ${expanded ? "nav-group-chevron-open" : ""}`} size={15} />
        </button>
        {expanded ? <div className="nav-submenu">{item.children.map((child) => renderLink(child, true))}</div> : null}
      </div>
    );
  }

  return (
    <div className={`app-layout source-app-layout ${collapsed ? "source-app-layout-collapsed" : ""}`}>
      <aside className={`sidebar source-sidebar ${isOpen ? "sidebar-open" : ""}`}>
        <div className="sidebar-head source-sidebar-head">
          <div className="source-shell-mark"><ShieldCheck size={20} /></div>
          <div className="source-sidebar-brand">
            <strong>PT. Global Inspeksi Sertifikasi</strong>
            <span>Container Survey Management</span>
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
          {workspaces.map((workspace) => (
            <div className="nav-section nav-workspace" key={workspace.id}>
              <p>{workspace.label}</p>
              {workspace.items.map((item) => item.kind === "group" ? renderGroup(item) : renderLink(item))}
            </div>
          ))}
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
            <span className="source-role-badge">{roleSummary}</span>
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
  return `${user.name} - ${user.roles.map(roleLabel).join(", ")}`;
}

function roleLabel(role: RoleCode) {
  const labels: Record<RoleCode, string> = {
    super_admin: "Super Admin",
    admin: "Admin",
    surveyor: "Surveyor",
    supervisor: "Supervisor",
    finance: "Finance",
    management: "Management"
  };
  return labels[role];
}
