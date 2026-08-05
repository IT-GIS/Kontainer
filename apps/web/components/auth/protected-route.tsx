"use client";

import { usePathname, useRouter } from "next/navigation";
import { useEffect } from "react";
import { useAuth } from "@/hooks/use-auth";
import type { RoleCode } from "@/types/auth";

export function ProtectedRoute({ children, roles }: { children: React.ReactNode; roles?: RoleCode[] }) {
  const { isLoading, user } = useAuth();
  const pathname = usePathname();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && !user) {
      router.replace(`/login?next=${encodeURIComponent(pathname)}`);
    }
  }, [isLoading, pathname, router, user]);

  if (isLoading) {
    return <div className="center-screen">Memuat sesi...</div>;
  }

  if (!user) {
    return <div className="center-screen">Mengalihkan ke login...</div>;
  }

	const allowedRoles = roles ?? rolesForPath(pathname);
	const activeRole = user.active_role;
	if (activeRole !== "super_admin" && allowedRoles && !allowedRoles.includes(activeRole)) {
    return <div className="center-screen" role="alert"><div><strong>Akses ditolak</strong><p>Halaman ini tidak tersedia untuk peran aktif Anda.</p></div></div>;
  }

  return <>{children}</>;
}

function rolesForPath(pathname: string): RoleCode[] | undefined {
	if (pathname.startsWith("/surveyor")) return ["surveyor"];
	if (pathname.startsWith("/review") || pathname.startsWith("/monitoring/surveys") || pathname.startsWith("/surveys/monitoring")) return ["supervisor", "admin", "management"];
	if (pathname.startsWith("/master/iso-cedex") || pathname.startsWith("/master/inspection-references")) return ["admin", "supervisor", "management"];
	if (pathname.startsWith("/master") || pathname.startsWith("/jobs") || pathname.startsWith("/settings")) return ["admin"];
	if (pathname.startsWith("/finance")) return ["finance"];
	if (pathname.startsWith("/reports")) return ["admin", "supervisor", "management"];
	return undefined;
}
