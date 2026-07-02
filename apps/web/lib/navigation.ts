import type {
  NavigationGroup, NavigationLink, NavigationNode, NavigationRouteMatch, NavigationWorkspace
} from "@/constants/navigation";
import { canAny } from "@/lib/permissions";
import type { CurrentUser, RoleCode } from "@/types/auth";

export type VisibleNavigationWorkspace = Omit<NavigationWorkspace, "items"> & {
  items: NavigationNode[];
};

export function visibleNavigation(
  workspaces: NavigationWorkspace[],
  user: CurrentUser | null
): VisibleNavigationWorkspace[] {
  return workspaces
    .filter((workspace) => hasAllowedRole(user, workspace.roles))
    .map((workspace) => {
      const items: NavigationNode[] = [];
      for (const item of workspace.items) {
        if (item.kind === "link") {
          if (canSeeLink(user, item)) items.push(item);
          continue;
        }
        if (!hasAllowedRole(user, item.roles)) {
          continue;
        }
        const children = item.children.filter((child) => canSeeLink(user, child));
        if (children.length > 0) items.push({ ...item, children } satisfies NavigationGroup);
      }
      return { ...workspace, items };
    })
    .filter((workspace) => workspace.items.length > 0);
}

export function activeNavigationID(
  workspaces: VisibleNavigationWorkspace[],
  pathname: string,
  searchParams: Pick<URLSearchParams, "get">
): string | null {
  let active: { id: string; score: number } | null = null;
  for (const workspace of workspaces) {
    for (const item of workspace.items) {
      const links = item.kind === "group" ? item.children : [item];
      for (const link of links) {
        const score = linkScore(link, pathname, searchParams);
        if (score >= 0 && (!active || score > active.score)) {
          active = { id: link.id, score };
        }
      }
    }
  }
  return active?.id ?? null;
}

export function navigationLabel(link: NavigationLink, user: CurrentUser | null): string {
  if (!user || user.roles.includes("super_admin") || user.roles.includes("admin")) {
    return link.label;
  }
  const role = user.roles.find((item) => link.roleLabels?.[item]);
  return role ? link.roleLabels?.[role] ?? link.label : link.label;
}

export function hasAllowedRole(user: CurrentUser | null, allowed: RoleCode[]): boolean {
  if (!user) return false;
  if (user.roles.includes("super_admin")) return true;
  return allowed.some((role) => user.roles.includes(role));
}

function canSeeLink(user: CurrentUser | null, link: NavigationLink): boolean {
  if (link.exactRoles && (!user || !link.exactRoles.some((role) => user.roles.includes(role)))) {
    return false;
  }
  return hasAllowedRole(user, link.roles) && canAny(user, link.permissions);
}

function linkScore(link: NavigationLink, pathname: string, searchParams: Pick<URLSearchParams, "get">): number {
  const matches = link.matches ?? [{ path: link.href }];
  return matches.reduce((best, match) => Math.max(best, matchScore(match, pathname, searchParams)), -1);
}

function matchScore(match: NavigationRouteMatch, pathname: string, searchParams: Pick<URLSearchParams, "get">): number {
  if (match.query && !Object.entries(match.query).every(([key, value]) => searchParams.get(key) === value)) {
    return -1;
  }

  const mode = match.mode ?? "exact";
  const pathMatches = mode === "prefix"
    ? pathname === match.path || pathname.startsWith(match.path + "/")
    : mode === "pattern"
      ? patternMatches(match.path, pathname)
      : pathname === match.path;
  if (!pathMatches) return -1;

  const staticSegments = match.path.split("/").filter((part) => part && !part.startsWith(":")).length;
  const modeScore = mode === "exact" ? 3000 : mode === "pattern" ? 2000 : 1000;
  const queryScore = match.query ? 1500 : 0;
  return modeScore + queryScore + staticSegments * 100 + match.path.length;
}

function patternMatches(pattern: string, pathname: string): boolean {
  const expected = pattern.split("/").filter(Boolean);
  const actual = pathname.split("/").filter(Boolean);
  return expected.length === actual.length
    && expected.every((part, index) => part.startsWith(":") || part === actual[index]);
}
