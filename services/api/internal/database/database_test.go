package database

import "testing"

func TestReturningWhereIndexSupportsMultilineUpdate(t *testing.T) {
	queries := []string{
		"UPDATE users SET status=$2 WHERE id=$1",
		"UPDATE users SET status=$2, updated_at=now()\n\tWHERE id=$1",
	}
	for _, query := range queries {
		prepared, args := prepare(query, []any{"id", "submitted"})
		table, where, setArgs, ok := updateReturningTarget(prepared)
		if !ok || table != "users" || where != "id=?" || setArgs != 1 || len(args) != 2 {
			t.Fatalf("unexpected target table=%q where=%q setArgs=%d args=%d", table, where, setArgs, len(args))
		}
	}
}

func TestReturningKeepsOuterWhereForNestedUpdate(t *testing.T) {
	query := "UPDATE jobs SET status=$2 WHERE id=$1 AND NOT EXISTS (SELECT 1 FROM containers WHERE containers.job_id=jobs.id)"
	prepared, _ := prepare(query, []any{"id", "done"})
	table, where, setArgs, ok := updateReturningTarget(prepared)
	if !ok || table != "jobs" || setArgs != 1 || where != "id=? AND NOT EXISTS (SELECT 1 FROM containers WHERE containers.job_id=jobs.id)" {
		t.Fatalf("unexpected nested target table=%q where=%q setArgs=%d", table, where, setArgs)
	}
}
