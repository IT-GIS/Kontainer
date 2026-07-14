"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import { ConfirmationDialog } from "@/components/ui/confirmation-dialog";

type UseUnsavedChangesGuardOptions = {
  active: boolean;
  message?: string;
};

export function useUnsavedChangesGuard({
  active,
  message = "Perubahan belum disimpan. Tinggalkan halaman?"
}: UseUnsavedChangesGuardOptions) {
  const pendingNavigationRef = useRef<(() => void) | null>(null);
  const [confirmationOpen, setConfirmationOpen] = useState(false);

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

  const requestNavigation = useCallback((callback: () => void) => {
    if (!active) {
      callback();
      return;
    }

    pendingNavigationRef.current = callback;
    setConfirmationOpen(true);
  }, [active]);

  useEffect(() => {
    if (!active) return;

    const handleInternalNavigation = (event: MouseEvent) => {
      if (event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
      const target = event.target;
      if (!(target instanceof Element)) return;
      const anchor = target.closest("a[href]");
      if (!(anchor instanceof HTMLAnchorElement) || anchor.target === "_blank" || anchor.hasAttribute("download")) return;

      const nextUrl = new URL(anchor.href, window.location.href);
      if (nextUrl.origin !== window.location.origin || nextUrl.href === window.location.href) return;

      event.preventDefault();
      requestNavigation(() => window.location.assign(nextUrl.href));
    };

    document.addEventListener("click", handleInternalNavigation, true);
    return () => document.removeEventListener("click", handleInternalNavigation, true);
  }, [active, requestNavigation]);

  const confirmLeave = useCallback(() => {
    const pending = pendingNavigationRef.current;
    pendingNavigationRef.current = null;
    setConfirmationOpen(false);
    pending?.();
  }, []);

  const cancelLeave = useCallback(() => {
    pendingNavigationRef.current = null;
    setConfirmationOpen(false);
  }, []);

  return {
    requestNavigation,
    confirmationOpen,
    confirmLeave,
    cancelLeave
  };
}

type UnsavedChangesGuardProps = UseUnsavedChangesGuardOptions & {
  title?: string;
  confirmLabel?: string;
  cancelLabel?: string;
  children?: (guard: ReturnType<typeof useUnsavedChangesGuard>) => React.ReactNode;
};

export function UnsavedChangesGuard({
  active,
  message = "Perubahan belum disimpan. Tinggalkan halaman?",
  title = "Tinggalkan halaman?",
  confirmLabel = "Tinggalkan",
  cancelLabel = "Tetap di halaman",
  children
}: UnsavedChangesGuardProps) {
  const guard = useUnsavedChangesGuard({ active, message });

  return (
    <>
      {children?.(guard)}
      <ConfirmationDialog
        cancelLabel={cancelLabel}
        confirmLabel={confirmLabel}
        description={message}
        onClose={guard.cancelLeave}
        onConfirm={guard.confirmLeave}
        open={guard.confirmationOpen}
        title={title}
        tone="danger"
      />
    </>
  );
}