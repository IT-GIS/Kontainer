CREATE TABLE IF NOT EXISTS price_lists (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  customer_id CHAR(36) NULL REFERENCES customers(id),
  survey_type_id CHAR(36) NOT NULL REFERENCES survey_types(id),
  container_type_id CHAR(36) NULL REFERENCES container_types(id),
  description VARCHAR(200) NULL,
  unit_price DECIMAL(15,2) NOT NULL,
  currency VARCHAR(10) NOT NULL DEFAULT 'IDR',
  tax_type VARCHAR(50) NULL,
  effective_date DATE NOT NULL,
  expired_date DATE NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  deleted_at DATETIME(6) NULL
);

CREATE INDEX idx_price_lists_customer ON price_lists(customer_id);
CREATE INDEX idx_price_lists_survey_type ON price_lists(survey_type_id);
CREATE INDEX idx_price_lists_effective ON price_lists(effective_date);

CREATE TABLE IF NOT EXISTS invoices (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  invoice_no VARCHAR(80) UNIQUE NOT NULL,
  invoice_date DATE NOT NULL,
  customer_id CHAR(36) NOT NULL REFERENCES customers(id),
  billing_address TEXT NULL,
  payment_term_days INT NULL,
  due_date DATE NULL,
  currency VARCHAR(10) NOT NULL DEFAULT 'IDR',
  subtotal DECIMAL(15,2) NOT NULL DEFAULT 0,
  tax_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  grand_total DECIMAL(15,2) NOT NULL DEFAULT 0,
  paid_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  outstanding_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  status VARCHAR(30) NOT NULL DEFAULT 'draft',
  issued_at DATETIME(6) NULL,
  issued_by CHAR(36) NULL REFERENCES users(id),
  cancel_reason TEXT NULL,
  cancelled_at DATETIME(6) NULL,
  cancelled_by CHAR(36) NULL REFERENCES users(id),
  created_by CHAR(36) NULL REFERENCES users(id),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE UNIQUE INDEX idx_invoices_no ON invoices(invoice_no);
CREATE INDEX idx_invoices_customer ON invoices(customer_id);
CREATE INDEX idx_invoices_status ON invoices(status);
CREATE INDEX idx_invoices_date ON invoices(invoice_date);
CREATE INDEX idx_invoices_due_date ON invoices(due_date);

CREATE TABLE IF NOT EXISTS invoice_items (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  invoice_id CHAR(36) NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
  job_order_id CHAR(36) NULL REFERENCES job_orders(id),
  report_id CHAR(36) NULL REFERENCES reports(id),
  survey_id CHAR(36) NULL REFERENCES surveys(id),
  price_list_id CHAR(36) NULL REFERENCES price_lists(id),
  description VARCHAR(255) NOT NULL,
  quantity DECIMAL(12,2) NOT NULL DEFAULT 1,
  unit_price DECIMAL(15,2) NOT NULL DEFAULT 0,
  tax_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  discount_amount DECIMAL(15,2) NOT NULL DEFAULT 0,
  total DECIMAL(15,2) NOT NULL DEFAULT 0,
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
);

CREATE INDEX idx_invoice_items_invoice ON invoice_items(invoice_id);
CREATE INDEX idx_invoice_items_report ON invoice_items(report_id);
CREATE TABLE IF NOT EXISTS payments (
  id CHAR(36) PRIMARY KEY DEFAULT (UUID()),
  payment_no VARCHAR(80) UNIQUE NULL,
  invoice_id CHAR(36) NOT NULL REFERENCES invoices(id),
  payment_date DATE NOT NULL,
  amount DECIMAL(15,2) NOT NULL,
  payment_method VARCHAR(50) NULL,
  bank_account VARCHAR(150) NULL,
  proof_file_id CHAR(36) NULL REFERENCES file_objects(id),
  note TEXT NULL,
  created_by CHAR(36) NOT NULL REFERENCES users(id),
  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  cancelled_at DATETIME(6) NULL,
  cancelled_by CHAR(36) NULL REFERENCES users(id),
  cancel_reason TEXT NULL
);

CREATE INDEX idx_payments_invoice ON payments(invoice_id);
CREATE INDEX idx_payments_date ON payments(payment_date);

INSERT IGNORE INTO permissions (code, name, module, action, scope, description)
VALUES
  ('finance.view.all', 'View Finance', 'finance', 'view', 'all', 'Melihat dashboard finance, invoice, payment, outstanding'),
  ('finance.manage.all', 'Manage Finance', 'finance', 'manage', 'all', 'Mengelola price list, invoice, dan payment'),
  ('finance.invoice.create.all', 'Create Invoice', 'finance.invoice', 'create', 'all', 'Membuat invoice draft'),
  ('finance.payment.create.all', 'Create Payment', 'finance.payment', 'create', 'all', 'Mencatat payment');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('finance.view.all', 'finance.manage.all', 'finance.invoice.create.all', 'finance.payment.create.all', 'reports.view.all')
WHERE r.code IN ('super_admin', 'finance');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN ('finance.view.all', 'reports.view.all')
WHERE r.code IN ('management');







