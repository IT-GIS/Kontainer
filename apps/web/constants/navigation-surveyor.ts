import { ClipboardCheck, ClipboardList, FileQuestion, Gauge, History, RotateCcw, Send, UserRound } from "lucide-react";
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
    { ...n("Dashboard", "/surveyor/dashboard", Gauge), permissions: ["surveyor_jobs.view.assigned"] },
    {
      kind: "group",
      id: "surveyor-my-work",
      label: "Pekerjaan Saya",
      icon: ClipboardList,
      roles,
      children: [
		{ ...n("Belum Dimulai", "/surveyor/jobs?state=not_started", ClipboardCheck), permissions: ["surveyor_jobs.view.assigned"], matches: [{ path: "/surveyor/jobs", query: { state: "not_started" } }, { path: "/surveyor/jobs/:id", mode: "pattern" }] },
        n("Sedang Dikerjakan", "/surveyor/surveys/draft", ClipboardList),
		n("Terkirim & Dalam Review", "/surveyor/surveys/submitted", Send),
        n("Perlu Revisi", "/surveyor/surveys/need-revision", RotateCcw),
		n("Selesai", "/surveyor/surveys/approved", ClipboardCheck)
      ]
    },
	n("Riwayat Survey", "/surveyor/surveys/history", History),
    n("Pengajuan Kode CEDEX", "/surveyor/cedex-code-proposals", FileQuestion),
    n("Profil", "/surveyor/profile", UserRound)
  ]
};
