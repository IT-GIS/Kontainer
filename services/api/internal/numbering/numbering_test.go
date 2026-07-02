package numbering

import (
	"testing"
	"time"
)

func TestPeriodKey(t *testing.T) {
	now := time.Date(2026, 7, 1, 0, 0, 0, 0, time.UTC)
	if PeriodKey("yearly", now) != "2026" || PeriodKey("monthly", now) != "202607" || PeriodKey("never", now) != "global" {
		t.Fatal("unexpected period key")
	}
}

func TestFormat(t *testing.T) {
	now := time.Date(2026, 7, 1, 0, 0, 0, 0, time.UTC)
	value := Format(Setting{Prefix: "GIFT", DocCode: "JO", YearFormat: "YYYY", RunningDigits: 6}, 12, now)
	if value != "GIFT-JO-2026-000012" {
		t.Fatalf("unexpected number: %s", value)
	}
}
