import { redirect } from "next/navigation";
export default function LegacyLocationsPage() { redirect("/master/customers?tab=location&compat=locations"); }
