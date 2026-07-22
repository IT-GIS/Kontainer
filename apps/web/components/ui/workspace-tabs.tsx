import Link from "next/link";

export type WorkspaceTab = {
  id: string;
  label: string;
  href: string;
};

export function WorkspaceTabs({
  tabs,
  activeID,
  label
}: {
  tabs: WorkspaceTab[];
  activeID: string;
  label: string;
}) {
  return (
    <nav aria-label={label} className="tab-list workspace-tab-list" role="tablist">
      {tabs.map((tab) => (
        <Link
          aria-selected={tab.id === activeID}
          className={tab.id === activeID ? "tab-active" : undefined}
          href={tab.href}
          key={tab.id}
          role="tab"
        >
          {tab.label}
        </Link>
      ))}
    </nav>
  );
}
