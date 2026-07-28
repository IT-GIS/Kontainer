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

  if (roles && !roles.some((role) => user.roles.includes(role))) {
    return <div className="center-screen" role="alert"><div><strong>Akses ditolak</strong><p>Halaman ini tidak tersedia untuk peran aktif Anda.</p></div></div>;
  }

  return <>{children}</>;
}
