import type { LucideIcon } from "lucide-react";
import { adminWorkspace } from "@/constants/navigation-admin";
import { financeWorkspace } from "@/constants/navigation-finance";
import { surveyorWorkspace } from "@/constants/navigation-surveyor";
import type { RoleCode } from "@/types/auth";

export type NavigationRouteMatch = {
  path: string;
  mode?: "exact" | "prefix" | "pattern";
  query?: Record<string, string>;
};

export type NavigationLink = {
  kind: "link";
  id: string;
  label: string;
  roleLabels?: Partial<Record<RoleCode, string>>;
  href: string;
  icon: LucideIcon;
  roles: RoleCode[];
  permissions: string[];
  matches?: NavigationRouteMatch[];
};

export type NavigationGroup = {
  kind: "group";
  id: string;
  label: string;
  icon: LucideIcon;
  roles: RoleCode[];
  children: NavigationLink[];
};

export type NavigationNode = NavigationLink | NavigationGroup;
export type NavigationWorkspace = {
  id: "admin" | "surveyor" | "finance";
  label: string;
  roles: RoleCode[];
  items: NavigationNode[];
};

export const navigationWorkspaces: NavigationWorkspace[] = [
  adminWorkspace,
  surveyorWorkspace,
  financeWorkspace
];
