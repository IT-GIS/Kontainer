package reviews

import (
	"strings"
	"testing"
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
