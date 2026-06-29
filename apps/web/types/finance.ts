export type FinanceDashboard = {
  ready_to_invoice: number;
  invoice_count: number;
  paid_count: number;
  unpaid_count: number;
  overdue_count: number;
  outstanding_amount: number;
};

export type ReadyInvoice = {
  report_id: string;
  report_no: string;
  job_order_id: string;
  job_order_no: string;
  customer_id: string;
  customer_name: string;
  survey_type_name: string;
  container_count: number;
  status: string;
};

export type PriceList = {
  id: string;
  customer_name?: string | null;
  survey_type_id: string;
  survey_type_name: string;
  container_type_code?: string | null;
  unit_price: number;
  currency: string;
  tax_type?: string | null;
  effective_date: string;
  status: string;
};

export type InvoiceSummary = {
  id: string;
  invoice_no: string;
  invoice_date: string;
  customer_name: string;
  grand_total: number;
  paid_amount: number;
  outstanding_amount: number;
  status: string;
  due_date?: string | null;
};

export type InvoiceDetail = InvoiceSummary & {
  customer_id: string;
  billing_address?: string | null;
  currency: string;
  subtotal: number;
  tax_amount: number;
  discount_amount: number;
  items?: Array<Record<string, unknown>>;
};

export type PaymentSummary = {
  id: string;
  payment_no: string;
  invoice_no: string;
  payment_date: string;
  amount: number;
  payment_method?: string | null;
  bank_account?: string | null;
  note?: string | null;
};

export type CustomerFinanceSummary = {
  customer_id: string;
  customer_name: string;
  invoice_count: number;
  total_invoiced: number;
  total_paid: number;
  outstanding_amount: number;
};
