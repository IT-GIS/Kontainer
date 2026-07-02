package reviews

import (
	"strings"
	"testing"
	"time"
)

func TestSurveyWhereNormalizesInProgress(t *testing.T) {
	where, args := surveyWhere(ListParams{Status: "in_progress", Search: "MSKU"}, "")
	if len(args) != 2 || args[0] != "draft" || args[1] != "%MSKU%" {
		t.Fatalf("unexpected args: %#v", args)
	}
	if !strings.Contains(where, "s.status=$1") || !strings.Contains(where, "c.customer_name LIKE $2") {
		t.Fatalf("unexpected where clause: %s", where)
	}
}

func TestValidMonitoringStatus(t *testing.T) {
	for _, status := range []string{"", "in_progress", "submitted", "need_revision", "approved", "rejected"} {
		if !validMonitoringStatus(status) {
			t.Fatalf("expected status %q to be valid", status)
		}
	}
	if validMonitoringStatus("paid") {
		t.Fatal("expected unrelated status to be rejected")
	}
}

func TestSurveyDateExpression(t *testing.T) {
	tests := map[string]string{
		"":              "s.created_at",
		"in_progress":   "COALESCE(s.started_at, s.created_at)",
		"draft":         "COALESCE(s.started_at, s.created_at)",
		"submitted":     "COALESCE(s.submitted_at, s.created_at)",
		"need_revision": "COALESCE(s.submitted_at, s.created_at)",
		"rejected":      "COALESCE(s.submitted_at, s.created_at)",
		"approved":      "COALESCE(s.approved_at, s.created_at)",
	}
	for status, want := range tests {
		if got := surveyDateExpression(status); got != want {
			t.Errorf("surveyDateExpression(%q) = %q, want %q", status, got, want)
		}
	}
}

func TestSurveyWhereMonitoringFilters(t *testing.T) {
	params := ListParams{
		Status:     "approved",
		SurveyorID: "11111111-1111-1111-1111-111111111111",
		LocationID: "22222222-2222-2222-2222-222222222222",
		DateFrom:   "2026-07-01",
		DateTo:     "2026-07-02",
	}
	where, args := surveyWhere(params, "")
	for _, fragment := range []string{"s.surveyor_id=$2", "jo.location_id=$3", "COALESCE(s.approved_at, s.created_at) >= $4", "COALESCE(s.approved_at, s.created_at) < $5"} {
		if !strings.Contains(where, fragment) {
			t.Fatalf("expected %q in where clause: %s", fragment, where)
		}
	}
	if len(args) != 5 || args[0] != "approved" || args[1] != params.SurveyorID || args[2] != params.LocationID {
		t.Fatalf("unexpected args: %#v", args)
	}
	if from, ok := args[3].(time.Time); !ok || from.Format("2006-01-02") != params.DateFrom {
		t.Fatalf("unexpected date_from arg: %#v", args[3])
	}
	if to, ok := args[4].(time.Time); !ok || to.Format("2006-01-02") != "2026-07-03" {
		t.Fatalf("unexpected exclusive date_to arg: %#v", args[4])
	}
}

func TestValidMonitoringFilters(t *testing.T) {
	valid := ListParams{
		SurveyorID: "11111111-1111-1111-1111-111111111111",
		LocationID: "22222222-2222-2222-2222-222222222222",
		DateFrom:   "2026-07-01",
		DateTo:     "2026-07-02",
	}
	if !validMonitoringFilters(valid) {
		t.Fatal("expected valid monitoring filters")
	}
	for _, invalid := range []ListParams{
		{SurveyorID: "invalid"},
		{LocationID: "invalid"},
		{DateFrom: "01-07-2026"},
		{DateFrom: "2026-07-03", DateTo: "2026-07-02"},
	} {
		if validMonitoringFilters(invalid) {
			t.Fatalf("expected invalid monitoring filters: %#v", invalid)
		}
	}
}

func TestReportWhereJobOrderID(t *testing.T) {
	jobID := "33333333-3333-3333-3333-333333333333"
	where, args := reportWhere(ListParams{JobOrderID: jobID})
	if !strings.Contains(where, "r.job_order_id=$1") || len(args) != 1 || args[0] != jobID {
		t.Fatalf("unexpected report filter: where=%s args=%#v", where, args)
	}
}

func TestValidateQRQueryIsMySQLCompatible(t *testing.T) {
	lower := strings.ToLower(validateQRQuery)
	if strings.Contains(lower, "::date") || strings.Contains(lower, "lateral") {
		t.Fatalf("query still contains PostgreSQL-only syntax: %s", validateQRQuery)
	}
	for _, fragment := range []string{"date(s.approved_at)", "select sa.reviewer_id", "order by sa.reviewed_at desc, sa.id desc"} {
		if !strings.Contains(lower, fragment) {
			t.Fatalf("expected %q in QR query: %s", fragment, validateQRQuery)
		}
	}
}
