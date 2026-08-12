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

func TestEffectiveMasterWithMySQL(t *testing.T) {
	dsn := strings.TrimSpace(os.Getenv("MASTERDATA_SMOKE_DSN"))
	if dsn == "" {
		t.Skip("MASTERDATA_SMOKE_DSN not set; effective master integration skipped")
	}
	lowerDSN := strings.ToLower(dsn)
	if !strings.Contains(lowerDSN, "test") && !strings.Contains(lowerDSN, "_uat") {
		t.Fatalf("integration DSN must point to a test or _uat database: %q", dsn)
	}
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	db, err := database.Connect(ctx, dsn)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	customerID, globalID, overrideID := uuid.New(), uuid.New(), uuid.New()
	code := "R" + strings.ToUpper(strings.ReplaceAll(uuid.NewString()[:3], "-", ""))
	defer db.Pool.Exec(context.Background(), "DELETE FROM cedex_locations WHERE id IN ($1,$2)", globalID, overrideID)
	defer db.Pool.Exec(context.Background(), "DELETE FROM customers WHERE id=$1", customerID)
	if _, err := db.Pool.Exec(ctx, `INSERT INTO customers (id,customer_code,customer_name,address,status) VALUES ($1,$2,'Effective Master Test','UAT','active')`, customerID, "EFF-"+code); err != nil {
		t.Fatal(err)
	}
	if _, err := db.Pool.Exec(ctx, `INSERT INTO cedex_locations (id,customer_id,code,face,grid_code,container_size,status) VALUES ($1,NULL,$2,'right',$2,'40','active')`, globalID, code); err != nil {
		t.Fatal(err)
	}
	scope, _ := EffectiveMasterScopeSQL("cedex_locations", "location", "$1")
	query := fmt.Sprintf("SELECT location.id FROM cedex_locations location WHERE %s AND LOWER(location.code)=LOWER($2)", scope)
	assertEffectiveLocation(t, ctx, db, query, customerID, code, globalID)
	if _, err := db.Pool.Exec(ctx, `INSERT INTO cedex_locations (id,customer_id,code,face,grid_code,container_size,status) VALUES ($1,$2,$3,'right',$3,'40','active')`, overrideID, customerID, code); err != nil {
		t.Fatal(err)
	}
	assertEffectiveLocation(t, ctx, db, query, customerID, code, overrideID)
	if _, err := db.Pool.Exec(ctx, `UPDATE cedex_locations SET status='inactive' WHERE id=$1`, overrideID); err != nil {
		t.Fatal(err)
	}
	assertEffectiveLocation(t, ctx, db, query, customerID, code, globalID)
	if _, err := db.Pool.Exec(ctx, `UPDATE cedex_locations SET status='inactive' WHERE id=$1`, globalID); err != nil {
		t.Fatal(err)
	}
	var count int
	if err := db.Pool.QueryRow(ctx, "SELECT COUNT(*) FROM cedex_locations location WHERE "+scope+" AND LOWER(location.code)=LOWER($2)", customerID, code).Scan(&count); err != nil || count != 0 {
		t.Fatalf("missing effective master count=%d err=%v", count, err)
	}
}

func assertEffectiveLocation(t *testing.T, ctx context.Context, db *database.DB, query string, customerID uuid.UUID, code string, wantID uuid.UUID) {
	t.Helper()
	var got uuid.UUID
	if err := db.Pool.QueryRow(ctx, query, customerID, code).Scan(&got); err != nil || got != wantID {
		t.Fatalf("effective location=%s want=%s err=%v", got, wantID, err)
	}
}
