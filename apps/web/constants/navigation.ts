import type { LucideIcon } from "lucide-react";
import {
  BarChart3,
  ClipboardCheck,
  ClipboardList,
  Container,
  CreditCard,
  Database,
  FileText,
  Gauge,
  Layers,
  MapPin,
  PackageCheck,
  Settings,
  ShieldCheck,
  Truck,
  UserRoundCheck,
  UsersRound,
  Wrench
} from "lucide-react";

export type NavigationItem = {
  label: string;
  href: string;
  icon: LucideIcon;
  permissions: string[];
  section: "Main" | "Master" | "Operations" | "System";
};

export const navigationItems: NavigationItem[] = [
  { label: "Dashboard", href: "/dashboard", icon: Gauge, permissions: ["dashboard.view.all", "*.*.all"], section: "Main" },
  { label: "Customer", href: "/master/customers", icon: UsersRound, permissions: ["customers.view.all"], section: "Master" },
  { label: "Location", href: "/master/locations", icon: MapPin, permissions: ["locations.view.all"], section: "Master" },
  { label: "Surveyor", href: "/master/surveyors", icon: UserRoundCheck, permissions: ["surveyors.view.all"], section: "Master" },
  { label: "Container Type", href: "/master/container-types", icon: Container, permissions: ["container_types.view.all"], section: "Master" },
  { label: "Survey Type", href: "/master/survey-types", icon: ClipboardCheck, permissions: ["survey_types.view.all"], section: "Master" },
  { label: "CEDEX Component", href: "/master/cedex/components", icon: PackageCheck, permissions: ["cedex_components.view.all"], section: "Master" },
  { label: "CEDEX Damage", href: "/master/cedex/damages", icon: Layers, permissions: ["cedex_damages.view.all"], section: "Master" },
  { label: "CEDEX Repair", href: "/master/cedex/repairs", icon: Wrench, permissions: ["cedex_repairs.view.all"], section: "Master" },
  { label: "Job Order", href: "/jobs", icon: Truck, permissions: ["jobs.view.all", "jobs.manage.all"], section: "Operations" },
  { label: "Job Saya", href: "/surveyor/jobs", icon: ClipboardList, permissions: ["surveyor_jobs.view.assigned"], section: "Operations" },
  { label: "Review", href: "/review/pending", icon: ShieldCheck, permissions: ["reviews.view.all", "reviews.manage.all"], section: "Operations" },
  { label: "Report", href: "/reports", icon: FileText, permissions: ["reports.view.all"], section: "Operations" },
  { label: "Finance", href: "/finance/dashboard", icon: CreditCard, permissions: ["finance.view.all", "finance.manage.all"], section: "Operations" },
  { label: "Settings", href: "/settings/users", icon: Settings, permissions: ["users.manage.all", "roles.manage.all"], section: "System" },
  { label: "Audit Log", href: "/settings/audit-log", icon: BarChart3, permissions: ["audit.view.all"], section: "System" },
  { label: "Data Bootstrap", href: "/master/checklist-templates", icon: Database, permissions: ["checklist_templates.view.all"], section: "System" }
];
