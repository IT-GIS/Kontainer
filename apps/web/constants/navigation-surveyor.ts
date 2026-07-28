import { ClipboardList, Gauge, History, RotateCcw } from "lucide-react";
import type { NavigationLink, NavigationWorkspace } from "@/constants/navigation";
import type { RoleCode } from "@/types/auth";

const roles: RoleCode[] = ["surveyor"];
const n = (label: string, href: string, icon: NavigationLink["icon"]): NavigationLink => ({
  kind: "link", id: href, label, href, icon, roles, permissions: ["surveys.view.assigned"]
});

export const surveyorWorkspace: NavigationWorkspace = {
  id: "surveyor",
  label: "Surveyor",
  roles,
  items: [
    { ...n("Dashboard Surveyor", "/surveyor/dashboard", Gauge), permissions: ["surveyor_jobs.view.assigned"] },
    {
      ...n("Pekerjaan Saya", "/surveyor/jobs", ClipboardList),
      permissions: ["surveyor_jobs.view.assigned"],
      matches: [{ path: "/surveyor/jobs" }, { path: "/surveyor/jobs/:id", mode: "pattern" }]
    },
    n("Perlu Revisi", "/surveyor/surveys/need-revision", RotateCcw),
    n("Riwayat Pemeriksaan", "/surveyor/surveys/history", History)
  ]
};
