import type { LucideIcon } from "lucide-react";

export type BreadcrumbItem = {
  label: string;
  href?: string;
};

export type PageTabItem = {
  id: string;
  label: string;
  href: string;
  count?: number;
};

export type FitnessMockMode = "success" | "empty" | "error" | "loading";

export type FitnessMockState<T> =
  | { status: "success"; data: T; isLoading: false; error: null }
  | { status: "empty"; data: T; isLoading: false; error: null }
  | { status: "error"; data: null; isLoading: false; error: string }
  | { status: "loading"; data: null; isLoading: true; error: null };

export type FitnessNavigationSummary = {
  label: string;
  href: string;
  description: string;
  status: "Aktif" | "Dalam Pengembangan";
  icon: LucideIcon;
};

export type FitnessPlaceholder = {
  path: string;
  title: string;
  subtitle: string;
  description: string;
  icon: LucideIcon;
  status: "Dalam Pengembangan" | "Aktif";
  features: string[];
  primaryCta: { label: string; href: string };
  secondaryCta?: { label: string; href: string };
  tabs?: PageTabItem[];
  breadcrumbs: BreadcrumbItem[];
  compatibilityRoutes?: string[];
};

export type FitnessMasterDataCard = {
  label: string;
  href: string;
  description: string;
  status: "Aktif" | "Dalam Pengembangan";
  activeCount: number;
  inactiveCount: number;
  updatedAt: string;
  icon: LucideIcon;
};

export type FitnessMasterDataGroup = {
  title: string;
  description: string;
  items: FitnessMasterDataCard[];
};
