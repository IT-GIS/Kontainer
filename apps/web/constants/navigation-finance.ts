import { Banknote, CreditCard, FilePlus2, Gauge, Receipt, Tags, WalletCards } from "lucide-react";
import type { NavigationLink, NavigationRouteMatch, NavigationWorkspace } from "@/constants/navigation";
import type { RoleCode } from "@/types/auth";

const finance: RoleCode[] = ["finance"];
const read: RoleCode[] = ["finance", "management"];
const n = (
  label: string, href: string, icon: NavigationLink["icon"], roles: RoleCode[],
  matches?: NavigationRouteMatch[]
): NavigationLink => ({
  kind: "link", id: href, label, href, icon, roles, permissions: ["finance.view.all"], matches
});

export const financeWorkspace: NavigationWorkspace = {
  id: "finance",
  label: "Finance",
  roles: read,
  items: [
    n("Dashboard Finance", "/finance/dashboard", Gauge, read),
    n("Ready to Invoice", "/finance/ready-to-invoice", FilePlus2, finance),
    n("Price List", "/finance/price-list", Tags, finance),
    n("Invoice List", "/finance/invoices", Receipt, finance, [
      { path: "/finance/invoices", mode: "prefix" }
    ]),
    n("Payment", "/finance/payments", CreditCard, finance),
    n("Outstanding", "/finance/outstanding", WalletCards, finance),
    n("Rekap Customer", "/finance/customers", Banknote, read)
  ]
};
