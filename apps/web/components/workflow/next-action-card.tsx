"use client";

import { ArrowRight, Compass } from "lucide-react";
import Link from "next/link";

export function NextActionCard({
  eyebrow = "Langkah berikutnya",
  title,
  description,
  actionLabel,
  href,
  onClick,
  disabled = false
}: {
  eyebrow?: string;
  title: string;
  description: string;
  actionLabel: string;
  href?: string;
  onClick?: () => void;
  disabled?: boolean;
}) {
  const content = <><span>{actionLabel}</span><ArrowRight size={17} /></>;
  return (
    <aside className="next-action-card" aria-label={eyebrow}>
      <span className="next-action-icon"><Compass size={20} /></span>
      <div>
        <p>{eyebrow}</p>
        <h3>{title}</h3>
        <span>{description}</span>
      </div>
      {href && !disabled ? <Link className="primary-button" href={href}>{content}</Link> : <button className="primary-button" disabled={disabled} onClick={onClick} type="button">{content}</button>}
    </aside>
  );
}
