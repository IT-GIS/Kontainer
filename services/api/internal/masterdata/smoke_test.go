package masterdata

import (
	"context"
	"fmt"
	"os"
	"strings"
	"testing"
	"time"

	"container-survey/services/api/internal/database"

	"github.com/google/uuid"
)

func TestMasterDataSmokeWithTestDatabase(t *testing.T) {
	dsn := strings.TrimSpace(os.Getenv("MASTERDATA_SMOKE_DSN"))
	if dsn == "" {
		t.Skip("MASTERDATA_SMOKE_DSN not set; smoke DB test skipped")
	}
	lowerDSN := strings.ToLower(dsn)
	if !strings.Contains(lowerDSN, "test") && !strings.Contains(lowerDSN, "_uat") {
		t.Fatalf("MASTERDATA_SMOKE_DSN must point to a test or _uat database, got %q", dsn)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	db, err := database.Connect(ctx, dsn)
	if err != nil {
		t.Fatalf("connect smoke DB: %v", err)
	}
	defer db.Close()

	repo := NewRepository(db.Pool)
	service := NewService(repo)
	suffix := strings.ToLower(strings.ReplaceAll(uuid.NewString()[:8], "-", ""))
	ownerCode := "T12-OWN-" + suffix
	areaCode := "T12-AREA-" + suffix
	componentCode := "T12-COMP-" + suffix
	rollbackCode := "T12-RB-" + suffix
	requestPrefix := "stage-1-2-smoke-" + suffix
	actor := Actor{UserID: uuid.New(), ActiveRole: "admin", RequestID: requestPrefix, IPAddress: "127.0.0.1", UserAgent: "masterdata-smoke-test"}

	cleanupSmokeRows(t, ctx, repo, ownerCode, areaCode, componentCode, rollbackCode, requestPrefix)
	defer cleanupSmokeRows(t, context.Background(), repo, ownerCode, areaCode, componentCode, rollbackCode, requestPrefix)

	owner, err := service.Create(ctx, fitnessAdminResource(Resources["customers"]), map[string]any{
		"customer_code": ownerCode,
		"customer_name": "Smoke Pemilik",
		"pic_email":     "smoke@example.test",
	}, actor)
	if err != nil {
		t.Fatalf("create owner: %v", err)
	}
	ownerID := mustRowUUID(t, owner)

	updatedOwner, err := service.Update(ctx, fitnessAdminResource(Resources["customers"]), ownerID, map[string]any{"pic_email": ""}, actor)
	if err != nil {
		t.Fatalf("clear owner pic_email: %v", err)
	}
	if updatedOwner["pic_email"] != nil {
		t.Fatalf("expected cleared pic_email to be nil, got %#v", updatedOwner["pic_email"])
	}
	if countRows(t, ctx, repo, "customers", "customer_code = $1 AND pic_email IS NULL", ownerCode) != 1 {
		t.Fatal("expected owner pic_email to be stored as NULL")
	}

	area, err := service.Create(ctx, fitnessAdminResource(Resources["inspection_areas"]), map[string]any{
		"code":      areaCode,
		"area_name": "Smoke Area",
	}, actor)
	if err != nil {
		t.Fatalf("create area without display_order: %v", err)
	}
	areaID := mustRowUUID(t, area)
	if countRows(t, ctx, repo, "inspection_areas", "code = $1 AND display_order = 0", areaCode) != 1 {
		t.Fatal("expected area display_order DB default 0")
	}

	if _, err := service.Delete(ctx, fitnessAdminResource(Resources["inspection_areas"]), areaID, actor); err != nil {
		t.Fatalf("deactivate area: %v", err)
	}
	inactiveList, err := service.List(ctx, fitnessAdminResource(Resources["inspection_areas"]), ListParams{Search: areaCode, Status: "inactive", Page: 1, PerPage: 10})
	if err != nil {
		t.Fatalf("filter inactive area: %v", err)
	}
	if len(inactiveList.Rows) != 1 {
		t.Fatalf("expected inactive area in filter, got %d rows", len(inactiveList.Rows))
	}
	if _, err := service.Update(ctx, fitnessAdminResource(Resources["inspection_areas"]), areaID, map[string]any{"status": "active"}, actor); err != nil {
		t.Fatalf("reactivate area: %v", err)
	}

	_, err = service.Create(ctx, fitnessAdminResource(Resources["structural_components"]), map[string]any{
		"code":               componentCode,
		"component_name":     "Smoke Component",
		"inspection_area_id": areaID.String(),
	}, actor)
	if err != nil {
		t.Fatalf("create component with area: %v", err)
	}
	componentList, err := service.List(ctx, fitnessAdminResource(Resources["structural_components"]), ListParams{Search: componentCode, Status: "active", Page: 1, PerPage: 10})
	if err != nil {
		t.Fatalf("list component: %v", err)
	}
	if len(componentList.Rows) != 1 {
		t.Fatalf("expected one component row, got %d", len(componentList.Rows))
	}
	label := fmt.Sprint(componentList.Rows[0]["inspection_area_label"])
	if !strings.Contains(label, areaCode) || !strings.Contains(label, "Smoke Area") {
		t.Fatalf("expected area label code + name, got %q", label)
	}
	if strings.Contains(label, areaID.String()) {
		t.Fatalf("area label must not expose UUID, got %q", label)
	}

	if countRows(t, ctx, repo, "audit_logs", "request_id = $1", requestPrefix) == 0 {
		t.Fatal("expected audit logs for smoke mutations")
	}

	failRepo := failingAuditRepository{Repository: repo}
	failService := NewServiceWithRepository(failRepo)
	_, err = failService.Create(ctx, fitnessAdminResource(Resources["customers"]), map[string]any{"customer_code": rollbackCode, "customer_name": "Rollback Owner"}, actor)
	if err == nil {
		t.Fatal("expected audit failure")
	}
	if countRows(t, ctx, repo, "customers", "customer_code = $1", rollbackCode) != 0 {
		t.Fatal("expected create rollback when audit insert fails")
	}
}

type failingAuditRepository struct{ Repository }

func (r failingAuditRepository) InsertAudit(context.Context, AuditEntry) error {
	return fmt.Errorf("forced audit failure")
}

func (r failingAuditRepository) WithTx(ctx context.Context, fn func(repositoryPort) error) error {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return err
	}
	txRepo := failingAuditRepository{Repository: Repository{pool: r.pool, executor: tx}}
	if err := fn(txRepo); err != nil {
		_ = tx.Rollback(ctx)
		return err
	}
	if err := tx.Commit(ctx); err != nil {
		_ = tx.Rollback(ctx)
		return err
	}
	return nil
}

func mustRowUUID(t *testing.T, row map[string]any) uuid.UUID {
	t.Helper()
	id, err := uuid.Parse(fmt.Sprint(row["id"]))
	if err != nil {
		t.Fatalf("row id is not UUID: %#v", row["id"])
	}
	return id
}

func countRows(t *testing.T, ctx context.Context, repo Repository, table string, where string, args ...any) int {
	t.Helper()
	var count int
	query := fmt.Sprintf("SELECT COUNT(*) FROM %s WHERE %s", table, where)
	if err := repo.runner().QueryRow(ctx, query, args...).Scan(&count); err != nil {
		t.Fatalf("count %s: %v", table, err)
	}
	return count
}

func cleanupSmokeRows(t *testing.T, ctx context.Context, repo Repository, ownerCode string, areaCode string, componentCode string, rollbackCode string, requestPrefix string) {
	t.Helper()
	commands := []struct {
		query string
		args  []any
	}{
		{"DELETE FROM structural_components WHERE code = $1", []any{componentCode}},
		{"DELETE FROM inspection_areas WHERE code = $1", []any{areaCode}},
		{"DELETE FROM customers WHERE customer_code IN ($1, $2)", []any{ownerCode, rollbackCode}},
		{"DELETE FROM audit_logs WHERE request_id = $1", []any{requestPrefix}},
	}
	for _, command := range commands {
		if _, err := repo.runner().Exec(ctx, command.query, command.args...); err != nil {
			t.Fatalf("cleanup smoke rows: %v", err)
		}
	}
}
