-- Apply the application migration:
-- services/api/migrations/0013_iso_cedex_decision_rules.up.sql
--
-- This patch is intentionally seed-free. Tolerance and regulation values must
-- only be entered by an authorized Admin from validated technical references.
SOURCE ../../services/api/migrations/0013_iso_cedex_decision_rules.up.sql;
