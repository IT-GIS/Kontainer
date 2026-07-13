-- 0018_container_fitness_deploy_readiness.sql
-- Deploy readiness seed for Sistem Kelaikan Peti Kemas numbering sequences.
-- Safe to run repeatedly after 0015, 0016, and 0017.
-- This patch does not enable workflow features and does not clean runtime tables.

START TRANSACTION;

INSERT INTO numbering_sequences (document_type, period_key, last_number)
SELECT ns.document_type, '2026', 0
FROM numbering_settings ns
WHERE ns.document_type IN (
  'fitness_application',
  'fitness_container_import',
  'fitness_assignment',
  'fitness_inspection',
  'repair_followup',
  'fitness_review',
  'fitness_approval',
  'approval_document',
  'release_letter'
)
  AND ns.reset_period = 'yearly'
ON DUPLICATE KEY UPDATE
  last_number = GREATEST(numbering_sequences.last_number, VALUES(last_number));

COMMIT;
