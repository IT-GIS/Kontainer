import type { ApiResponse, PaginatedData } from "@/types/api";

const API_BASE_URL = process.env.NEXT_PUBLIC_API_BASE_URL ?? "http://localhost:8080/api/v1";

export class ApiClientError extends Error {
  code: string;
  status: number;
  details?: Array<{ field?: string; message: string }>;

  constructor(message: string, code: string, status: number, details?: Array<{ field?: string; message: string }>) {
    super(message);
    this.name = "ApiClientError";
    this.code = code;
    this.status = status;
    this.details = details;
  }
}

export async function apiRequest<T>(
  path: string,
  init: RequestInit & { accessToken?: string } = {}
): Promise<ApiResponse<T>> {
  const headers = new Headers(init.headers);
  headers.set("Accept", "application/json");

  if (!(init.body instanceof FormData)) {
    headers.set("Content-Type", "application/json");
  }

  if (init.accessToken) {
    headers.set("Authorization", `Bearer ${init.accessToken}`);
  }

  const response = await fetch(`${API_BASE_URL}${path}`, {
    ...init,
    headers,
    cache: "no-store"
  });

  const contentType = response.headers.get("content-type") ?? "";
  if (!contentType.includes("application/json")) {
    throw new ApiClientError("API response tidak valid.", "INVALID_RESPONSE", response.status);
  }

  return response.json() as Promise<ApiResponse<T>>;
}

export async function apiData<T>(
  path: string,
  init: RequestInit & { accessToken?: string } = {}
): Promise<T> {
  const result = await apiRequest<T>(path, init);
  if (!result.success) {
    throw new ApiClientError(result.message, result.error.code, 400, result.error.details);
  }
  return result.data;
}

export async function apiPaginated<T>(
  path: string,
  init: RequestInit & { accessToken?: string } = {}
): Promise<PaginatedData<T>> {
  const result = await apiRequest<T[]>(path, init);
  if (!result.success) {
    throw new ApiClientError(result.message, result.error.code, 400, result.error.details);
  }
  return { rows: result.data, meta: result.meta ?? {} };
}

export async function apiBlob(
  path: string,
  init: RequestInit & { accessToken?: string } = {}
): Promise<Blob> {
  const headers = new Headers(init.headers);
  if (init.accessToken) headers.set("Authorization", `Bearer ${init.accessToken}`);
  const response = await fetch(`${API_BASE_URL}${path}`, { ...init, headers, cache: "no-store" });
  if (!response.ok) {
    throw new ApiClientError("File tidak dapat diambil.", "FILE_REQUEST_FAILED", response.status);
  }
  return response.blob();
}

export function buildQuery(params: Record<string, string | number | undefined | null>) {
  const search = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value === undefined || value === null || value === "") {
      continue;
    }
    search.set(key, String(value));
  }
  const query = search.toString();
  return query ? `?${query}` : "";
}
