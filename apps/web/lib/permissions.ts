import type { CurrentUser } from "@/types/auth";

export function can(user: CurrentUser | null, permission: string): boolean {
  if (!user) {
    return false;
  }
  if (permission === "") {
    return true;
  }
  const required = permission.split(".");
  return user.permissions.some((owned) => {
    if (owned === "*.*.all" || owned === permission) {
      return true;
    }
    const current = owned.split(".");
    return (
      required.length === 3 &&
      current.length === 3 &&
      current[0] === required[0] &&
      current[1] === "manage" &&
      (current[2] === required[2] || current[2] === "all")
    );
  });
}

export function canAny(user: CurrentUser | null, permissions: string[]): boolean {
  return permissions.some((permission) => can(user, permission));
}

export function hasRole(user: CurrentUser | null, role: CurrentUser["roles"][number]): boolean {
  return Boolean(user?.roles.includes(role));
}