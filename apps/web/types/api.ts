export type ApiMeta = {
  page?: number;
  per_page?: number;
  total?: number;
  total_pages?: number;
  has_next?: boolean;
  has_prev?: boolean;
  [key: string]: unknown;
} | null;

export type ApiSuccess<T> = {
  success: true;
  message: string;
  data: T;
  meta: ApiMeta;
};

export type ApiFailure = {
  success: false;
  message: string;
  error: {
    code: string;
    details?: Array<{ field?: string; message: string }>;
  };
  meta: ApiMeta;
};

export type ApiResponse<T> = ApiSuccess<T> | ApiFailure;

export type PaginatedData<T> = {
  rows: T[];
  meta: NonNullable<ApiMeta>;
};