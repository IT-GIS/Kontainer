-- Tahap 2: initialize the transactional document sequences from existing data.
-- Safe to run repeatedly; sequence values only move forward.

START TRANSACTION;

INSERT INTO numbering_sequences (document_type, period_key, last_number)
SELECT ns.document_type,
       CASE ns.reset_period WHEN 'monthly' THEN DATE_FORMAT(CURRENT_DATE, '%Y%m') WHEN 'never' THEN 'global' ELSE DATE_FORMAT(CURRENT_DATE, '%Y') END,
       COALESCE(MAX(CAST(SUBSTRING_INDEX(jo.job_order_no, '-', -1) AS UNSIGNED)), 0)
FROM numbering_settings ns
LEFT JOIN job_orders jo ON ns.reset_period = 'never'
  OR (ns.reset_period = 'yearly' AND YEAR(jo.created_at) = YEAR(CURRENT_DATE))
  OR (ns.reset_period = 'monthly' AND DATE_FORMAT(jo.created_at, '%Y%m') = DATE_FORMAT(CURRENT_DATE, '%Y%m'))
WHERE ns.document_type = 'job_order'
GROUP BY ns.document_type, ns.reset_period
ON DUPLICATE KEY UPDATE last_number = GREATEST(numbering_sequences.last_number, VALUES(last_number));

INSERT INTO numbering_sequences (document_type, period_key, last_number)
SELECT ns.document_type,
       CASE ns.reset_period WHEN 'monthly' THEN DATE_FORMAT(CURRENT_DATE, '%Y%m') WHEN 'never' THEN 'global' ELSE DATE_FORMAT(CURRENT_DATE, '%Y') END,
       COALESCE(MAX(CAST(SUBSTRING_INDEX(a.assignment_no, '-', -1) AS UNSIGNED)), 0)
FROM numbering_settings ns
LEFT JOIN assignments a ON ns.reset_period = 'never'
  OR (ns.reset_period = 'yearly' AND YEAR(a.created_at) = YEAR(CURRENT_DATE))
  OR (ns.reset_period = 'monthly' AND DATE_FORMAT(a.created_at, '%Y%m') = DATE_FORMAT(CURRENT_DATE, '%Y%m'))
WHERE ns.document_type = 'assignment'
GROUP BY ns.document_type, ns.reset_period
ON DUPLICATE KEY UPDATE last_number = GREATEST(numbering_sequences.last_number, VALUES(last_number));

INSERT INTO numbering_sequences (document_type, period_key, last_number)
SELECT ns.document_type,
       CASE ns.reset_period WHEN 'monthly' THEN DATE_FORMAT(CURRENT_DATE, '%Y%m') WHEN 'never' THEN 'global' ELSE DATE_FORMAT(CURRENT_DATE, '%Y') END,
       COALESCE(MAX(CAST(SUBSTRING_INDEX(s.survey_no, '-', -1) AS UNSIGNED)), 0)
FROM numbering_settings ns
LEFT JOIN surveys s ON ns.reset_period = 'never'
  OR (ns.reset_period = 'yearly' AND YEAR(s.created_at) = YEAR(CURRENT_DATE))
  OR (ns.reset_period = 'monthly' AND DATE_FORMAT(s.created_at, '%Y%m') = DATE_FORMAT(CURRENT_DATE, '%Y%m'))
WHERE ns.document_type = 'survey'
GROUP BY ns.document_type, ns.reset_period
ON DUPLICATE KEY UPDATE last_number = GREATEST(numbering_sequences.last_number, VALUES(last_number));

INSERT INTO numbering_sequences (document_type, period_key, last_number)
SELECT ns.document_type,
       CASE ns.reset_period WHEN 'monthly' THEN DATE_FORMAT(CURRENT_DATE, '%Y%m') WHEN 'never' THEN 'global' ELSE DATE_FORMAT(CURRENT_DATE, '%Y') END,
       COALESCE(MAX(CAST(SUBSTRING_INDEX(r.report_no, '-', -1) AS UNSIGNED)), 0)
FROM numbering_settings ns
LEFT JOIN reports r ON ns.reset_period = 'never'
  OR (ns.reset_period = 'yearly' AND YEAR(r.created_at) = YEAR(CURRENT_DATE))
  OR (ns.reset_period = 'monthly' AND DATE_FORMAT(r.created_at, '%Y%m') = DATE_FORMAT(CURRENT_DATE, '%Y%m'))
WHERE ns.document_type = 'report'
GROUP BY ns.document_type, ns.reset_period
ON DUPLICATE KEY UPDATE last_number = GREATEST(numbering_sequences.last_number, VALUES(last_number));

INSERT INTO numbering_sequences (document_type, period_key, last_number)
SELECT ns.document_type,
       CASE ns.reset_period WHEN 'monthly' THEN DATE_FORMAT(CURRENT_DATE, '%Y%m') WHEN 'never' THEN 'global' ELSE DATE_FORMAT(CURRENT_DATE, '%Y') END,
       COALESCE(MAX(CAST(SUBSTRING_INDEX(i.invoice_no, '-', -1) AS UNSIGNED)), 0)
FROM numbering_settings ns
LEFT JOIN invoices i ON ns.reset_period = 'never'
  OR (ns.reset_period = 'yearly' AND YEAR(i.created_at) = YEAR(CURRENT_DATE))
  OR (ns.reset_period = 'monthly' AND DATE_FORMAT(i.created_at, '%Y%m') = DATE_FORMAT(CURRENT_DATE, '%Y%m'))
WHERE ns.document_type = 'invoice'
GROUP BY ns.document_type, ns.reset_period
ON DUPLICATE KEY UPDATE last_number = GREATEST(numbering_sequences.last_number, VALUES(last_number));

INSERT INTO numbering_sequences (document_type, period_key, last_number)
SELECT ns.document_type,
       CASE ns.reset_period WHEN 'monthly' THEN DATE_FORMAT(CURRENT_DATE, '%Y%m') WHEN 'never' THEN 'global' ELSE DATE_FORMAT(CURRENT_DATE, '%Y') END,
       COALESCE(MAX(CAST(SUBSTRING_INDEX(p.payment_no, '-', -1) AS UNSIGNED)), 0)
FROM numbering_settings ns
LEFT JOIN payments p ON ns.reset_period = 'never'
  OR (ns.reset_period = 'yearly' AND YEAR(p.created_at) = YEAR(CURRENT_DATE))
  OR (ns.reset_period = 'monthly' AND DATE_FORMAT(p.created_at, '%Y%m') = DATE_FORMAT(CURRENT_DATE, '%Y%m'))
WHERE ns.document_type = 'payment_receipt'
GROUP BY ns.document_type, ns.reset_period
ON DUPLICATE KEY UPDATE last_number = GREATEST(numbering_sequences.last_number, VALUES(last_number));

COMMIT;
