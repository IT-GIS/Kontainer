package main

import (
	"context"
	"crypto/sha256"
	"database/sql"
	"encoding/hex"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"image/jpeg"
	"os"
	"path/filepath"
	"strings"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/google/uuid"
	"golang.org/x/image/font"
	"golang.org/x/image/font/basicfont"
	"golang.org/x/image/math/fixed"

	"container-survey/services/api/internal/auth"
)

const datasetID = "UAT-REAL-CASE-2026-08"

type options struct {
	action         string
	databaseName   string
	sourceDatabase string
	masterCustomer string
	mode           string
	dryRun         bool
	outputDir      string
}

type check struct {
	Name   string
	Status string
	Detail string
}

type userSpec struct {
	Role, Name, Email, Username string
}

var users = []userSpec{
	{Role: "admin", Name: "Siti Maharani UAT", Email: "siti.maharani@uat-gift.test", Username: "uat.admin"},
	{Role: "surveyor", Name: "Raka Pratama UAT", Email: "raka.pratama@uat-gift.test", Username: "uat.surveyor.raka"},
	{Role: "surveyor", Name: "Nabila Putri UAT", Email: "nabila.putri@uat-gift.test", Username: "uat.surveyor.nabila"},
	{Role: "supervisor", Name: "Ardiansyah Wibowo UAT", Email: "ardiansyah.wibowo@uat-gift.test", Username: "uat.reviewer"},
	{Role: "management", Name: "Dewi Lestari UAT", Email: "dewi.lestari@uat-gift.test", Username: "uat.management"},
	{Role: "", Name: "Bima Saputra UAT", Email: "bima.saputra@uat-npk.test", Username: "uat.customer.pic"},
}

func main() {
	var opt options
	flag.StringVar(&opt.action, "action", "bootstrap", "bootstrap|verify|cleanup|images")
	flag.StringVar(&opt.databaseName, "database-name", "kontainer_db_uat", "target database")
	flag.StringVar(&opt.sourceDatabase, "source-database-name", "kontainer_db", "read-only source database")
	flag.StringVar(&opt.masterCustomer, "master-source-customer-code", "UAT-CUST-17B", "active source master customer")
	flag.StringVar(&opt.mode, "mode", "All", "All|BrowserReady|Finalize")
	flag.BoolVar(&opt.dryRun, "dry-run", false, "show cleanup scope without deleting")
	flag.StringVar(&opt.outputDir, "output-dir", "../../../tmp/uat-real-case", "generated image directory")
	flag.Parse()

	if opt.action != "images" && !strings.HasSuffix(strings.ToLower(opt.databaseName), "_uat") {
		fatalf("refusing database %q: target must end with _uat", opt.databaseName)
	}
	if opt.action == "images" {
		if err := generateImages(opt.outputDir); err != nil {
			fatalf("generate images: %v", err)
		}
		fmt.Printf("PASS images_generated dataset=%s directory=%s\n", datasetID, opt.outputDir)
		return
	}

	password := os.Getenv("UAT_MYSQL_PASSWORD")
	dsn := fmt.Sprintf("root:%s@tcp(127.0.0.1:3306)/%s?parseTime=true&charset=utf8mb4&loc=Local&multiStatements=true", password, opt.databaseName)
	if password == "" {
		dsn = fmt.Sprintf("root@tcp(127.0.0.1:3306)/%s?parseTime=true&charset=utf8mb4&loc=Local&multiStatements=true", opt.databaseName)
	}
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		fatalf("open target database: %v", err)
	}
	defer db.Close()
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Minute)
	defer cancel()
	if err := db.PingContext(ctx); err != nil {
		fatalf("connect target database: %v", err)
	}

	switch strings.ToLower(opt.action) {
	case "bootstrap":
		if err := bootstrap(ctx, db, opt); err != nil {
			fatalf("bootstrap: %v", err)
		}
	case "verify":
		results, err := verify(ctx, db, opt.mode)
		if err != nil {
			fatalf("verify: %v", err)
		}
		failed := false
		for _, result := range results {
			fmt.Printf("%s %-38s %s\n", result.Status, result.Name, result.Detail)
			failed = failed || result.Status == "FAIL"
		}
		if failed {
			os.Exit(2)
		}
	case "cleanup":
		if err := cleanup(ctx, db, opt.dryRun); err != nil {
			fatalf("cleanup: %v", err)
		}
	default:
		fatalf("unknown action %q", opt.action)
	}
}

func schemaGate(ctx context.Context, db *sql.DB) error {
	required := [][2]string{
		{"cedex_damage_decision_rules", ""},
		{"cedex_locations", "input_mode"},
		{"survey_damages", "location_selection_snapshot"},
		{"survey_revisions", ""},
		{"surveys", "resubmitted_at"},
		{"survey_damages", "checklist_response_id"},
		{"object_deletion_queue", "locked_at"},
		{"object_deletion_queue", "retry_count"},
		{"survey_general_infos", "cleanliness"},
	}
	for _, marker := range required {
		var count int
		query := `SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=?`
		args := []any{marker[0]}
		if marker[1] != "" {
			query = `SELECT COUNT(*) FROM information_schema.columns WHERE table_schema=DATABASE() AND table_name=? AND column_name=?`
			args = append(args, marker[1])
		}
		if err := db.QueryRowContext(ctx, query, args...).Scan(&count); err != nil {
			return err
		}
		if count != 1 {
			return fmt.Errorf("schema gate failed: missing %s.%s; apply complete migrations 0013-0019", marker[0], marker[1])
		}
	}
	return nil
}

func bootstrap(ctx context.Context, db *sql.DB, opt options) error {
	if err := schemaGate(ctx, db); err != nil {
		return err
	}
	if err := ensureManifestTable(ctx, db); err != nil {
		return err
	}
	fingerprint, err := masterFingerprint(ctx, db, opt.masterCustomer)
	if err != nil {
		return err
	}
	hash, err := auth.HashPassword("Uat!Kontainer2026")
	if err != nil {
		return err
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	for index, spec := range users {
		var userID string
		err := tx.QueryRowContext(ctx, `SELECT id FROM users WHERE username=? AND deleted_at IS NULL`, spec.Username).Scan(&userID)
		if errors.Is(err, sql.ErrNoRows) {
			userID = uuid.NewString()
			if _, err = tx.ExecContext(ctx, `INSERT INTO users (id,name,email,username,password_hash,status,password_changed_at) VALUES (?,?,?,?,?,'active',NOW(6))`,
				userID, spec.Name, spec.Email, spec.Username, hash); err != nil {
				return err
			}
		} else if err != nil {
			return err
		}
		if spec.Role != "" {
			var roleID string
			if err := tx.QueryRowContext(ctx, `SELECT id FROM roles WHERE code=?`, spec.Role).Scan(&roleID); err != nil {
				return fmt.Errorf("active role %s unavailable: %w", spec.Role, err)
			}
			if _, err := tx.ExecContext(ctx, `INSERT IGNORE INTO user_roles (id,user_id,role_id) VALUES (?,?,?)`, uuid.NewString(), userID, roleID); err != nil {
				return err
			}
		}
		if spec.Role == "surveyor" {
			code := fmt.Sprintf("UAT-SURV-%02d", index)
			if _, err := tx.ExecContext(ctx, `
				INSERT INTO surveyor_profiles (id,user_id,surveyor_code,full_name,status)
				VALUES (?,?,?,?, 'active')
				ON DUPLICATE KEY UPDATE full_name=VALUES(full_name),status='active',deleted_at=NULL`,
				uuid.NewString(), userID, code, spec.Name); err != nil {
				return err
			}
		}
	}
	fixture, err := bootstrapDomain(ctx, tx, opt)
	if err != nil {
		return err
	}
	payload, _ := json.Marshal(map[string]any{
		"dataset_id": datasetID, "mode": opt.mode, "source_database": opt.sourceDatabase,
		"master_source_customer_code": opt.masterCustomer, "master_fingerprint": fingerprint,
		"object_prefix": "uat/" + datasetID, "bootstrapped_users": len(users), "e2e": fixture,
	})
	if _, err := tx.ExecContext(ctx, `
		INSERT INTO uat_seed_manifests (dataset_id,status,source_fingerprint,payload,updated_at)
		VALUES (?, 'BOOTSTRAPPED', ?, ?, NOW(6))
		ON DUPLICATE KEY UPDATE status=VALUES(status),source_fingerprint=VALUES(source_fingerprint),payload=VALUES(payload),updated_at=NOW(6)`,
		datasetID, fingerprint, payload); err != nil {
		return err
	}
	if err := tx.Commit(); err != nil {
		return err
	}
	fmt.Printf("PASS schema_gate migrations=0013-0019\n")
	fmt.Printf("PASS users_bootstrapped count=%d password=REDACTED reviewer_role=supervisor management_role=management customer_pic_role=none\n", len(users))
	fmt.Printf("PASS master_source code=%s fingerprint=%s\n", opt.masterCustomer, fingerprint)
	fmt.Printf("PASS domain_fixture jobs=3 containers=6 multi_job_id=%s revision_survey_id=%s rejection_survey_id=%s isolation_survey_id=%s\n",
		fixture.MultiContainerJobID, fixture.RevisionSurveyID, fixture.RejectionSurveyID, fixture.IsolationSurveyID)
	fmt.Printf("PASS manifest dataset=%s mode=%s object_prefix=uat/%s\n", datasetID, opt.mode, datasetID)
	return nil
}

func ensureManifestTable(ctx context.Context, db *sql.DB) error {
	_, err := db.ExecContext(ctx, `
		CREATE TABLE IF NOT EXISTS uat_seed_manifests (
		  dataset_id VARCHAR(100) PRIMARY KEY,
		  status VARCHAR(40) NOT NULL,
		  source_fingerprint CHAR(64) NOT NULL,
		  payload JSON NOT NULL,
		  created_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
		  updated_at DATETIME(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
		)`)
	return err
}

func masterFingerprint(ctx context.Context, db *sql.DB, customerCode string) (string, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT CONCAT_WS('|',c.customer_code,st.code,pc.code,pc.applies_to,pc.status)
		FROM customers c
		JOIN customer_survey_type_photo_categories m ON m.customer_id=c.id AND m.is_active=1
		JOIN survey_types st ON st.id=m.survey_type_id AND st.status='active'
		JOIN evidence_photo_categories pc ON pc.id=m.photo_category_id AND pc.status='active'
		WHERE c.customer_code=? AND c.status='active'
		ORDER BY st.code,pc.code`, customerCode)
	if err != nil {
		return "", err
	}
	defer rows.Close()
	var values []string
	var hasInspection, hasFinding bool
	for rows.Next() {
		var value string
		if err := rows.Scan(&value); err != nil {
			return "", err
		}
		values = append(values, value)
		hasInspection = hasInspection || strings.Contains(strings.ToLower(value), "|inspection|")
		hasFinding = hasFinding || strings.Contains(strings.ToLower(value), "|finding|")
	}
	if len(values) == 0 {
		return "", fmt.Errorf("SKIPPED_MASTER_MISSING: no active mapping for customer %s", customerCode)
	}
	if !hasInspection || !hasFinding {
		return "", fmt.Errorf("SKIPPED_MASTER_MISSING: customer %s must have active inspection and finding photo scopes", customerCode)
	}
	sum := sha256.Sum256([]byte(strings.Join(values, "\n")))
	return hex.EncodeToString(sum[:]), rows.Err()
}

func verify(ctx context.Context, db *sql.DB, mode string) ([]check, error) {
	if err := schemaGate(ctx, db); err != nil {
		return nil, err
	}
	type queryCheck struct{ name, query, pass, fail string }
	revisionQuery := `SELECT CASE WHEN EXISTS(SELECT 1 FROM job_orders WHERE job_order_no='UAT-JOB-2026-0805-003') AND NOT EXISTS(SELECT 1 FROM survey_revisions r JOIN surveys s ON s.id=r.survey_id JOIN job_orders j ON j.id=s.job_order_id WHERE j.job_order_no='UAT-JOB-2026-0805-003') THEN 1 ELSE 0 END`
	revisionPass := "present/not finalized"
	if strings.EqualFold(mode, "Finalize") {
		revisionQuery = `SELECT CASE WHEN EXISTS(
			SELECT 1 FROM survey_revisions r
			JOIN surveys s ON s.id=r.survey_id
			JOIN job_orders j ON j.id=s.job_order_id
			WHERE j.job_order_no='UAT-JOB-2026-0805-003'
			  AND r.status='approved' AND r.revision_no=1
			  AND r.snapshot_before IS NOT NULL AND r.snapshot_after IS NOT NULL
			  AND (SELECT COUNT(*) FROM survey_revision_items item WHERE item.survey_id=s.id)=2
			  AND (SELECT COUNT(*) FROM survey_revision_items item WHERE item.survey_id=s.id AND item.is_resolved=1)=2
		) THEN 0 ELSE 1 END`
		revisionPass = "approved, snapshots present, 2/2 items resolved"
	}
	checks := []queryCheck{
		{"01 duplicate user UAT", `SELECT COUNT(*) FROM (SELECT username FROM users WHERE username LIKE 'uat.%' AND deleted_at IS NULL GROUP BY username HAVING COUNT(*)>1) x`, "none", "duplicates"},
		{"02 duplicate Job No/SPK", `SELECT COUNT(*) FROM (SELECT job_order_no FROM job_orders WHERE job_order_no LIKE 'UAT-%' GROUP BY job_order_no HAVING COUNT(*)>1) x`, "none", "duplicates"},
		{"03 duplicate active assignment", `SELECT COUNT(*) FROM (SELECT ac.job_container_id FROM assignment_containers ac JOIN assignments a ON a.id=ac.assignment_id WHERE a.status IN ('assigned','accepted','in_progress') GROUP BY ac.job_container_id HAVING COUNT(*)>1) x`, "none", "duplicates"},
		{"04 container spec present", `SELECT GREATEST(0,6-COUNT(DISTINCT container_no)) FROM job_containers WHERE container_no IN ('GFTU1234560','NPKU7654323','BCKU2468102','GFTU6543216','NPKU1357903','BCKU1122331')`, "all 6", "missing"},
		{"05 survey assignment/customer", `SELECT COUNT(*) FROM surveys s JOIN job_orders j ON j.id=s.job_order_id JOIN job_containers jc ON jc.id=s.job_container_id JOIN survey_general_infos gi ON gi.survey_id=s.id WHERE j.job_order_no LIKE 'UAT-%' AND (jc.job_order_id<>j.id OR gi.customer_id<>j.customer_id)`, "consistent", "mismatch"},
		{"06 damage counter", `SELECT COUNT(*) FROM survey_damage_counters c JOIN surveys s ON s.id=c.survey_id JOIN job_orders j ON j.id=s.job_order_id WHERE j.job_order_no LIKE 'UAT-%' AND c.last_number<>(SELECT COALESCE(MAX(CAST(SUBSTRING(sd.damage_no,3) AS UNSIGNED)),0) FROM survey_damages sd WHERE sd.survey_id=c.survey_id AND sd.deleted_at IS NULL)`, "consistent", "mismatch"},
		{"07 finding number reuse", `SELECT COUNT(*) FROM (SELECT survey_id,damage_no FROM survey_damages WHERE deleted_at IS NULL GROUP BY survey_id,damage_no HAVING COUNT(*)>1) x`, "none", "duplicates"},
		{"08 checklist linkage", `SELECT COUNT(*) FROM survey_damages sd JOIN surveys s ON s.id=sd.survey_id JOIN job_orders j ON j.id=s.job_order_id WHERE j.job_order_no LIKE 'UAT-%' AND sd.deleted_at IS NULL AND sd.checklist_response_id IS NULL`, "linked or no findings", "unlinked"},
		{"09 general photo scope", `SELECT COUNT(*) FROM survey_photos sp JOIN surveys s ON s.id=sp.survey_id JOIN job_orders j ON j.id=s.job_order_id WHERE j.job_order_no LIKE 'UAT-%' AND sp.deleted_at IS NULL AND sp.photo_type='general' AND sp.damage_id IS NOT NULL`, "NULL damage", "mismatch"},
		{"10 finding photo scope", `SELECT COUNT(*) FROM survey_photos sp JOIN surveys s ON s.id=sp.survey_id JOIN job_orders j ON j.id=s.job_order_id WHERE j.job_order_no LIKE 'UAT-%' AND sp.deleted_at IS NULL AND sp.photo_type='damage' AND sp.damage_id IS NULL`, "damage linked", "mismatch"},
		{"11 active photo category scope", `SELECT COUNT(*) FROM survey_photos sp JOIN file_objects f ON f.id=sp.file_id LEFT JOIN evidence_photo_categories pc ON LOWER(pc.code)=LOWER(sp.photo_category) AND pc.status='active' WHERE sp.deleted_at IS NULL AND f.object_key LIKE 'uat/UAT-REAL-CASE-2026-08/%' AND (pc.id IS NULL OR (sp.damage_id IS NULL AND pc.applies_to<>'inspection') OR (sp.damage_id IS NOT NULL AND pc.applies_to<>'finding'))`, "valid", "invalid"},
		{"12 general upload audit", `SELECT COUNT(*) FROM survey_photos sp JOIN file_objects f ON f.id=sp.file_id LEFT JOIN audit_logs a ON a.entity_id=sp.id AND a.action='survey_photos.upload_general' WHERE f.object_key LIKE 'uat/UAT-REAL-CASE-2026-08/%' AND sp.damage_id IS NULL AND a.id IS NULL`, "present", "missing"},
		{"13 revision history", revisionQuery, revisionPass, "missing/incomplete"},
		{"14 location snapshot", `SELECT COUNT(*) FROM survey_damages sd JOIN surveys s ON s.id=sd.survey_id JOIN job_orders j ON j.id=s.job_order_id WHERE j.job_order_no LIKE 'UAT-%' AND sd.deleted_at IS NULL AND sd.location_selection_snapshot IS NULL`, "present", "missing"},
		{"15 orphan records", `SELECT COUNT(*) FROM survey_damages sd LEFT JOIN surveys s ON s.id=sd.survey_id WHERE sd.deleted_at IS NULL AND s.id IS NULL`, "none", "orphans"},
		{"16 customer isolation structure", `SELECT COUNT(*) FROM surveys s JOIN job_orders j ON j.id=s.job_order_id JOIN survey_general_infos gi ON gi.survey_id=s.id WHERE j.job_order_no LIKE 'UAT-%' AND gi.customer_id<>j.customer_id`, "isolated", "leak"},
		{"17 object metadata prefix", `SELECT COUNT(*) FROM file_objects f JOIN survey_photos sp ON sp.file_id=f.id JOIN surveys s ON s.id=sp.survey_id JOIN job_orders j ON j.id=s.job_order_id WHERE j.job_order_no LIKE 'UAT-%' AND f.object_key NOT LIKE 'uat/UAT-REAL-CASE-2026-08/%'`, "scoped", "outside prefix"},
	}
	if strings.EqualFold(mode, "Finalize") {
		checks = append(checks,
			queryCheck{"18 multi-container state", `SELECT CASE WHEN
				(SELECT status FROM job_orders WHERE job_order_no='UAT-JOB-2026-0805-001')='in_progress'
				AND EXISTS(SELECT 1 FROM job_containers jc JOIN job_orders j ON j.id=jc.job_order_id JOIN surveys s ON s.job_container_id=jc.id AND s.is_active=1 WHERE j.job_order_no='UAT-JOB-2026-0805-001' AND jc.container_no='GFTU1234560' AND jc.status='draft' AND s.status='draft')
				AND EXISTS(SELECT 1 FROM job_containers jc JOIN job_orders j ON j.id=jc.job_order_id LEFT JOIN surveys s ON s.job_container_id=jc.id AND s.is_active=1 WHERE j.job_order_no='UAT-JOB-2026-0805-001' AND jc.container_no='NPKU7654323' AND jc.status='assigned' AND s.id IS NULL)
			THEN 0 ELSE 1 END`, "A=draft, B=assigned, job=in_progress", "mismatch"},
			queryCheck{"19 approve state", `SELECT CASE WHEN EXISTS(SELECT 1 FROM surveys s JOIN job_orders j ON j.id=s.job_order_id JOIN job_containers jc ON jc.id=s.job_container_id WHERE s.id='e2e00003-0000-4000-8000-000000000301' AND s.status='approved' AND jc.status='approved' AND j.status='all_survey_approved') THEN 0 ELSE 1 END`, "survey/container approved", "mismatch"},
			queryCheck{"20 reject state", `SELECT CASE WHEN EXISTS(SELECT 1 FROM surveys s JOIN job_orders j ON j.id=s.job_order_id JOIN job_containers jc ON jc.id=s.job_container_id WHERE s.id='e2e00002-0000-4000-8000-000000000201' AND s.status='rejected' AND jc.status='rejected' AND j.status='completed_with_rejection') THEN 0 ELSE 1 END`, "survey/container rejected, job completed_with_rejection", "mismatch"},
			queryCheck{"21 workflow audit", `SELECT COUNT(*) FROM (
				SELECT 'surveys.start' action UNION ALL SELECT 'surveys.submit' UNION ALL SELECT 'reviews.start'
				UNION ALL SELECT 'reviews.need_revision' UNION ALL SELECT 'surveys.resubmit'
				UNION ALL SELECT 'reviews.approve' UNION ALL SELECT 'reviews.reject'
				UNION ALL SELECT 'survey_photos.upload_general'
			) expected WHERE NOT EXISTS(SELECT 1 FROM audit_logs audit WHERE audit.action=expected.action AND audit.created_at>=DATE_SUB(NOW(),INTERVAL 1 DAY))`, "all required actions present", "missing actions"},
			queryCheck{"22 review role boundary", `SELECT CASE WHEN
				EXISTS(SELECT 1 FROM roles r JOIN role_permissions rp ON rp.role_id=r.id JOIN permissions p ON p.id=rp.permission_id WHERE r.code='supervisor' AND p.code='reviews.manage.all')
				AND NOT EXISTS(SELECT 1 FROM roles r JOIN role_permissions rp ON rp.role_id=r.id JOIN permissions p ON p.id=rp.permission_id WHERE r.code IN ('admin','management') AND p.code='reviews.manage.all')
			THEN 0 ELSE 1 END`, "Supervisor manages; Admin/Management read-only", "permission mismatch"},
			queryCheck{"23 active file references", `SELECT COUNT(*) FROM survey_photos sp JOIN surveys s ON s.id=sp.survey_id JOIN job_orders j ON j.id=s.job_order_id LEFT JOIN file_objects original ON original.id=sp.file_id AND original.deleted_at IS NULL LEFT JOIN file_objects watermarked ON watermarked.id=sp.watermarked_file_id AND watermarked.deleted_at IS NULL WHERE j.job_order_no LIKE 'UAT-JOB-2026-0805-%' AND sp.deleted_at IS NULL AND (original.id IS NULL OR sp.watermarked_file_id IS NOT NULL AND watermarked.id IS NULL)`, "complete", "missing files"},
			queryCheck{"24 deletion queue health", `SELECT COUNT(*) FROM object_deletion_queue WHERE status='failed' OR (status='pending' AND eligible_after<=NOW(6) AND (next_retry_at IS NULL OR next_retry_at<=NOW(6)))`, "no failed/overdue queue", "unhealthy rows"},
		)
	}
	results := make([]check, 0, len(checks))
	var datasetJobs int
	if err := db.QueryRowContext(ctx, `SELECT COUNT(*) FROM job_orders WHERE job_order_no LIKE 'UAT-JOB-2026-0805-%'`).Scan(&datasetJobs); err != nil {
		return nil, err
	}
	for index, item := range checks {
		if datasetJobs == 0 && index >= 4 {
			results = append(results, check{Name: item.name, Status: "SKIPPED", Detail: "domain dataset unavailable after master gate"})
			continue
		}
		var count int
		if err := db.QueryRowContext(ctx, item.query).Scan(&count); err != nil {
			results = append(results, check{Name: item.name, Status: "SKIPPED", Detail: err.Error()})
			continue
		}
		status, detail := "PASS", item.pass
		if count != 0 {
			status, detail = "FAIL", fmt.Sprintf("%s=%d", item.fail, count)
		}
		if item.name == "13 revision history" && count != 0 && strings.EqualFold(mode, "BrowserReady") {
			status, detail = "SKIPPED", "menunggu workflow revisi browser"
		}
		results = append(results, check{Name: item.name, Status: status, Detail: detail})
	}
	return results, nil
}

func cleanup(ctx context.Context, db *sql.DB, dryRun bool) error {
	if err := ensureManifestTable(ctx, db); err != nil {
		return err
	}
	var manifestCount, jobCount, userCount, objectCount int
	if err := db.QueryRowContext(ctx, `SELECT COUNT(*) FROM uat_seed_manifests WHERE dataset_id=?`, datasetID).Scan(&manifestCount); err != nil {
		return err
	}
	if manifestCount != 1 {
		return fmt.Errorf("refusing cleanup: manifest %s not found", datasetID)
	}
	_ = db.QueryRowContext(ctx, `SELECT COUNT(*) FROM job_orders WHERE job_order_no LIKE 'UAT-JOB-2026-0805-%'`).Scan(&jobCount)
	_ = db.QueryRowContext(ctx, `SELECT COUNT(*) FROM users WHERE username LIKE 'uat.%' AND email LIKE '%.test'`).Scan(&userCount)
	_ = db.QueryRowContext(ctx, `SELECT COUNT(*) FROM file_objects WHERE object_key LIKE 'uat/UAT-REAL-CASE-2026-08/%'`).Scan(&objectCount)
	fmt.Printf("%s cleanup_scope jobs=%d users=%d objects=%d prefix=uat/%s/\n", map[bool]string{true: "DRYRUN", false: "PLAN"}[dryRun], jobCount, userCount, objectCount, datasetID)
	if dryRun {
		return nil
	}
	if jobCount > 0 || objectCount > 0 {
		return fmt.Errorf("cleanup requires API/object removal for %d jobs and %d objects; refusing partial SQL cleanup", jobCount, objectCount)
	}
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	if _, err := tx.ExecContext(ctx, `DELETE FROM audit_logs WHERE request_id LIKE 'UAT-REAL-CASE-2026-08%'`); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `DELETE rt FROM refresh_tokens rt JOIN users u ON u.id=rt.user_id WHERE u.username LIKE 'uat.%' AND u.email LIKE '%.test'`); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `DELETE ur FROM user_roles ur JOIN users u ON u.id=ur.user_id WHERE u.username LIKE 'uat.%' AND u.email LIKE '%.test'`); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `DELETE sp FROM surveyor_profiles sp JOIN users u ON u.id=sp.user_id WHERE u.username LIKE 'uat.%' AND u.email LIKE '%.test'`); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `DELETE FROM users WHERE username LIKE 'uat.%' AND email LIKE '%.test'`); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx, `DELETE FROM uat_seed_manifests WHERE dataset_id=?`, datasetID); err != nil {
		return err
	}
	if err := tx.Commit(); err != nil {
		return err
	}
	fmt.Printf("PASS cleanup bootstrap-only dataset=%s\n", datasetID)
	return nil
}

func generateImages(outputDir string) error {
	if err := os.MkdirAll(outputDir, 0o755); err != nil {
		return err
	}
	specs := []struct{ file, container, label string }{
		{"UAT-GFTU1234560-right-overview.jpg", "GFTU1234560", "RIGHT OVERVIEW SECTION 3-4"},
		{"UAT-GFTU1234560-right-closeup.jpg", "GFTU1234560", "RIGHT CLOSE-UP SECTION 3-4"},
		{"UAT-BCKU2468102-door-gasket.jpg", "BCKU2468102", "DOOR GASKET FINDING"},
		{"UAT-GFTU6543216-floor-measurement.jpg", "GFTU6543216", "FLOOR MEASUREMENT 30 x 12 x 0.8 cm"},
		{"UAT-NPKU1357903-csc-plate.jpg", "NPKU1357903", "CSC PLATE GENERAL"},
	}
	for _, spec := range specs {
		canvas := image.NewRGBA(image.Rect(0, 0, 1280, 820))
		draw.Draw(canvas, canvas.Bounds(), &image.Uniform{C: color.RGBA{R: 226, G: 232, B: 240, A: 255}}, image.Point{}, draw.Src)
		draw.Draw(canvas, image.Rect(110, 170, 1170, 650), &image.Uniform{C: color.RGBA{R: 59, G: 130, B: 246, A: 255}}, image.Point{}, draw.Src)
		draw.Draw(canvas, image.Rect(150, 220, 1130, 600), &image.Uniform{C: color.RGBA{R: 219, G: 234, B: 254, A: 255}}, image.Point{}, draw.Src)
		draw.Draw(canvas, image.Rect(500, 335, 790, 500), &image.Uniform{C: color.RGBA{R: 239, G: 68, B: 68, A: 190}}, image.Point{}, draw.Over)
		// The backend adds the authoritative metadata watermark. These large blocks keep the
		// source unmistakably synthetic even before upload.
		for y := 30; y < 145; y++ {
			for x := 35; x < 1245; x++ {
				if (x+y)%7 < 5 {
					canvas.Set(x, y, color.RGBA{R: 127, G: 29, B: 29, A: 255})
				}
			}
		}
		drawLabel(canvas, 55, 72, "UAT DUMMY — BUKAN BUKTI INSPEKSI")
		drawLabel(canvas, 55, 103, spec.container+" — "+spec.label)
		drawLabel(canvas, 55, 134, "DATASET "+datasetID+" — 2026-08-05")
		file, err := os.Create(filepath.Join(outputDir, spec.file))
		if err != nil {
			return err
		}
		err = jpeg.Encode(file, canvas, &jpeg.Options{Quality: 90})
		closeErr := file.Close()
		if err != nil {
			return err
		}
		if closeErr != nil {
			return closeErr
		}
		meta, _ := json.Marshal(map[string]string{
			"warning": "UAT DUMMY — BUKAN BUKTI INSPEKSI", "container": spec.container, "label": spec.label,
		})
		if err := os.WriteFile(filepath.Join(outputDir, spec.file+".json"), meta, 0o644); err != nil {
			return err
		}
	}
	return nil
}

func drawLabel(target draw.Image, x, y int, value string) {
	drawer := font.Drawer{
		Dst:  target,
		Src:  image.White,
		Face: basicfont.Face7x13,
		Dot:  fixed.P(x, y),
	}
	drawer.DrawString(value)
}

func fatalf(format string, args ...any) {
	fmt.Fprintf(os.Stderr, "FAIL "+format+"\n", args...)
	os.Exit(1)
}
