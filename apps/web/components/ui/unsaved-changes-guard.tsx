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