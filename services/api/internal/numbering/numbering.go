package numbering

import (
	"context"
	"fmt"
	"strings"
	"time"

	"container-survey/services/api/internal/database"
)

type Setting struct {
	DocumentType  string
	Prefix        string
	DocCode       string
	YearFormat    string
	RunningDigits int
	ResetPeriod   string
}

func Next(ctx context.Context, tx database.Tx, documentType string) (string, error) {
	var setting Setting
	err := tx.QueryRow(ctx, `
		SELECT document_type, prefix, doc_code, year_format, running_digits, reset_period
		FROM numbering_settings
		WHERE document_type=$1 AND is_active=1
		LIMIT 1 FOR UPDATE
	`, documentType).Scan(&setting.DocumentType, &setting.Prefix, &setting.DocCode, &setting.YearFormat, &setting.RunningDigits, &setting.ResetPeriod)
	if err != nil {
		return "", err
	}
	now := time.Now()
	period := PeriodKey(setting.ResetPeriod, now)
	if _, err := tx.Exec(ctx, `
		INSERT INTO numbering_sequences (document_type, period_key, last_number)
		VALUES ($1,$2,1)
		ON DUPLICATE KEY UPDATE last_number=last_number+1, updated_at=now()
	`, documentType, period); err != nil {
		return "", err
	}
	var next int64
	if err := tx.QueryRow(ctx, `
		SELECT last_number FROM numbering_sequences
		WHERE document_type=$1 AND period_key=$2
		FOR UPDATE
	`, documentType, period).Scan(&next); err != nil {
		return "", err
	}
	return Format(setting, next, now), nil
}

func PeriodKey(resetPeriod string, now time.Time) string {
	switch resetPeriod {
	case "monthly":
		return now.Format("200601")
	case "never":
		return "global"
	default:
		return now.Format("2006")
	}
}

func Format(setting Setting, number int64, now time.Time) string {
	segments := []string{}
	if strings.TrimSpace(setting.Prefix) != "" {
		segments = append(segments, strings.TrimSpace(setting.Prefix))
	}
	segments = append(segments, strings.TrimSpace(setting.DocCode))
	switch strings.ToUpper(strings.TrimSpace(setting.YearFormat)) {
	case "YY":
		segments = append(segments, now.Format("06"))
	case "", "NONE":
	default:
		segments = append(segments, now.Format("2006"))
	}
	digits := setting.RunningDigits
	if digits < 1 {
		digits = 6
	}
	segments = append(segments, fmt.Sprintf("%0*d", digits, number))
	return strings.Join(segments, "-")
}
