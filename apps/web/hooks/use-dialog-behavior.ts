"use client";

import { useEffect, useId, useRef } from "react";

type UseDialogBehaviorOptions = {
  open: boolean;
  onClose: () => void;
  closeOnEscape?: boolean;
  closeOnBackdrop?: boolean;
  preventClose?: boolean;
  enabled?: boolean;
};

const focusableSelector = [
  "a[href]",
  "button:not([disabled])",
  "textarea:not([disabled])",
  "input:not([disabled])",
  "select:not([disabled])",
  "[tabindex]:not([tabindex='-1'])"
].join(",");

export function useDialogBehavior({
  open,
  onClose,
  closeOnEscape = true,
  closeOnBackdrop = true,
  preventClose = false,
  enabled = true
}: UseDialogBehaviorOptions) {
  const dialogRef = useRef<HTMLElement | null>(null);
  const previouslyFocusedRef = useRef<HTMLElement | null>(null);
  const titleId = useId();
  const descriptionId = useId();

  useEffect(() => {
    if (!open || !enabled) return;

    previouslyFocusedRef.current = document.activeElement instanceof HTMLElement ? document.activeElement : null;
    const originalOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";

    window.setTimeout(() => {
      const dialog = dialogRef.current;
      const focusable = getFocusable(dialog);
      (focusable[0] ?? dialog)?.focus();
    }, 0);

    return () => {
      document.body.style.overflow = originalOverflow;
      previouslyFocusedRef.current?.focus();
    };
  }, [enabled, open]);

  useEffect(() => {
    if (!open || !enabled) return;

    const handleKeyDown = (event: KeyboardEvent) => {
      if (event.key === "Escape" && closeOnEscape) {
        event.preventDefault();
        if (!preventClose) onClose();
        return;
      }

      if (event.key !== "Tab") return;

      const focusable = getFocusable(dialogRef.current);
      if (focusable.length === 0) {
        event.preventDefault();
        dialogRef.current?.focus();
        return;
      }

      const first = focusable[0];
      const last = focusable[focusable.length - 1];

      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    };

    document.addEventListener("keydown", handleKeyDown);
    return () => document.removeEventListener("keydown", handleKeyDown);
  }, [closeOnEscape, enabled, onClose, open, preventClose]);

  const requestClose = () => {
    if (!preventClose) onClose();
  };

  const handleBackdropMouseDown = (event: React.MouseEvent<HTMLElement>) => {
    if (!closeOnBackdrop || preventClose) return;
    if (event.target === event.currentTarget) onClose();
  };

  return {
    dialogRef,
    titleId,
    descriptionId,
    requestClose,
    handleBackdropMouseDown
  };
}

function getFocusable(root: HTMLElement | null) {
  if (!root) return [];
  return Array.from(root.querySelectorAll<HTMLElement>(focusableSelector)).filter((element) => {
    return !element.hasAttribute("disabled") && element.getAttribute("aria-hidden") !== "true";
  });
}
