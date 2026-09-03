package surveyor

import (
	"container-survey/services/api/internal/database"
	"context"
	"errors"
	"strings"
	"testing"

	"github.com/google/uuid"
)

func TestSurveyBaseQueryUsesActualMySQLColumns(t *testing.T) {
	query := surveyBaseQuery()
	for _, expected := range []string{
		"COALESCE(sgi.container_type_name_snapshot,ct.type_name) AS container_type_name",
		"a.due_date AS assignment_due_at",
	} {
		if !strings.Contains(query, expected) {
			t.Fatalf("survey base query must contain %q", expected)
		}
	}
	for _, invalid := range []string{"ct.name", "a.due_at"} {
		if strings.Contains(query, invalid) {
			t.Fatalf("survey base query must not use nonexistent column %q", invalid)
		}
	}
}

func TestSurveyMutationRoleRejectsNonSurveyor(t *testing.T) {
	for _, role := range []string{"", "admin", "supervisor", "super_admin", "management", "finance"} {
		if err := requireSurveyorMutationRole(Actor{ActiveRole: role}); !errors.Is(err, ErrForbidden) {
			t.Fatalf("role %q error = %v, want ErrForbidden", role, err)
		}
	}
	if err := requireSurveyorMutationRole(Actor{ActiveRole: "surveyor"}); err != nil {
		t.Fatalf("surveyor role error = %v, want nil", err)
	}
}

func TestVerificationMismatchOnlyComparesKnownValues(t *testing.T) {
	if !verificationMismatch("empty", "laden") {
		t.Fatal("different known cargo values must be marked as mismatch")
	}
	if !verificationMismatch("available", "missing") {
		t.Fatal("different known CSC values must be marked as mismatch")
	}
	for _, test := range []struct {
		initial  any
		verified string
	}{
		{initial: "empty", verified: "empty"},
		{initial: "unknown", verified: "laden"},
		{initial: nil, verified: "laden"},
		{initial: "available", verified: "not_checked"},
	} {
		if verificationMismatch(test.initial, test.verified) {
			t.Fatalf("values must not be marked as mismatch: initial=%v verified=%q", test.initial, test.verified)
		}
	}
}

func TestNextDamageNoUsesMySQLCounterSequenceWithoutIDColumn(t *testing.T) {
	tx := &damageCounterTx{next: 7}
	number, err := (Repository{}).nextDamageNo(context.Background(), tx, uuid.New())
	if err != nil {
		t.Fatal(err)
	}
	if number != "D-007" {
		t.Fatalf("unexpected damage number %q", number)
	}
	if len(tx.queries) != 3 {
		t.Fatalf("expected three counter queries, got %d: %#v", len(tx.queries), tx.queries)
	}
	assertCounterQuery(t, tx.queries[0], "INSERT IGNORE INTO survey_damage_counters", "survey_id,last_number")
	assertCounterQuery(t, tx.queries[1], "UPDATE survey_damage_counters", "WHERE survey_id=$1")
	assertCounterQuery(t, tx.queries[2], "SELECT last_number FROM survey_damage_counters", "WHERE survey_id=$1")
	for _, query := range tx.queries {
		if strings.Contains(strings.ToUpper(query), "RETURNING") || strings.Contains(query, " id") {
			t.Fatalf("damage counter query must not depend on RETURNING or an id column: %s", query)
		}
	}
}

func assertCounterQuery(t *testing.T, query string, fragments ...string) {
	t.Helper()
	for _, fragment := range fragments {
		if !strings.Contains(query, fragment) {
			t.Fatalf("query %q does not contain %q", query, fragment)
		}
	}
}

type damageCounterTx struct {
	queries []string
	next    int
}

func (tx *damageCounterTx) Exec(_ context.Context, query string, _ ...any) (database.CommandTag, error) {
	tx.queries = append(tx.queries, compactSQL(query))
	return database.CommandTag{}, nil
}

func (tx *damageCounterTx) Query(_ context.Context, _ string, _ ...any) (database.Rows, error) {
	return nil, errors.New("unexpected Query call")
}

func (tx *damageCounterTx) QueryRow(_ context.Context, query string, _ ...any) database.Row {
	tx.queries = append(tx.queries, compactSQL(query))
	return damageCounterRow{value: tx.next}
}

func (tx *damageCounterTx) Commit(context.Context) error   { return nil }
func (tx *damageCounterTx) Rollback(context.Context) error { return nil }

type damageCounterRow struct{ value int }

func (row damageCounterRow) Scan(dest ...any) error {
	if len(dest) != 1 {
		return errors.New("unexpected scan destination count")
	}
	value, ok := dest[0].(*int)
	if !ok {
		return errors.New("unexpected scan destination type")
	}
	*value = row.value
	return nil
}

func compactSQL(query string) string {
	return strings.Join(strings.Fields(query), " ")
}
