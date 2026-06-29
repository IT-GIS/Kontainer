import { apiPaginated } from "@/lib/api-client";
import type { OptionItem } from "@/types/jobs";

export async function loadOptions(accessToken: string, endpoint: string, labelKey: string, codeKey?: string): Promise<OptionItem[]> {
  const result = await apiPaginated<Record<string, string>>(`${endpoint}?page=1&per_page=100&status=active`, { accessToken });
  return result.rows.map((row) => ({
    id: row.id,
    label: row[labelKey] ?? row.name ?? row.code ?? row.id,
    code: codeKey ? row[codeKey] : row.code
  }));
}