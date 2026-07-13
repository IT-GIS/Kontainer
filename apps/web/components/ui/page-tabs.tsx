import Link from "next/link";
import type { PageTabItem } from "@/types/fitness-admin";

type PageTabsProps = {
  tabs: PageTabItem[];
  activeHref?: string;
};

export function PageTabs({ tabs, activeHref }: PageTabsProps) {
  if (tabs.length === 0) return null;

  return (
    <div className="page-tabs" role="tablist" aria-label="Filter halaman">
      {tabs.map((tab) => {
        const active = normalize(tab.href) === normalize(activeHref ?? tabs[0]?.href ?? "");
        return (
          <Link
            aria-selected={active}
            className={`page-tab ${active ? "page-tab-active" : ""}`}
            href={tab.href}
            key={tab.id}
            role="tab"
          >
            <span>{tab.label}</span>
            {typeof tab.count === "number" ? <strong>{tab.count}</strong> : null}
          </Link>
        );
      })}
    </div>
  );
}

function normalize(href: string) {
  const [path, query = ""] = href.split("?");
  const search = new URLSearchParams(query);
  const orderedQuery = Array.from(search.entries())
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([key, value]) => `${key}=${value}`)
    .join("&");
  return orderedQuery ? `${path}?${orderedQuery}` : path;
}
