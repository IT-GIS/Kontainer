import Link from "next/link";
import { ChevronRight, Home } from "lucide-react";
import type { BreadcrumbItem } from "@/types/fitness-admin";

type BreadcrumbProps = {
  items: BreadcrumbItem[];
};

export function Breadcrumb({ items }: BreadcrumbProps) {
  if (items.length === 0) return null;

  return (
    <nav className="breadcrumb" aria-label="Breadcrumb">
      <ol>
        {items.map((item, index) => {
          const isLast = index === items.length - 1;
          return (
            <li key={`${item.label}-${index}`} className={isLast ? "breadcrumb-current" : undefined}>
              {index > 0 ? <ChevronRight aria-hidden="true" size={14} /> : null}
              {item.href && !isLast ? (
                <Link href={item.href}>
                  {index === 0 ? <Home aria-hidden="true" size={14} /> : null}
                  <span>{item.label}</span>
                </Link>
              ) : (
                <span aria-current={isLast ? "page" : undefined}>{item.label}</span>
              )}
            </li>
          );
        })}
      </ol>
    </nav>
  );
}
