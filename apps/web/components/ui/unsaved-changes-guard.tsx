"use client";

import { useEffect } from "react";

type UnsavedChangesGuardProps = {
  active: boolean;
  message?: string;
};

export function UnsavedChangesGuard({
  active,
  message = "Perubahan belum disimpan."
}: UnsavedChangesGuardProps) {
  useEffect(() => {
    if (!active) return;

    const handleBeforeUnload = (event: BeforeUnloadEvent) => {
      event.preventDefault();
      event.returnValue = message;
      return message;
    };

    window.addEventListener("beforeunload", handleBeforeUnload);
    return () => window.removeEventListener("beforeunload", handleBeforeUnload);
  }, [active, message]);

  return null;
}
