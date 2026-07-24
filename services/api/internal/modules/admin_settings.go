package modules

import (
	"fmt"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/gin-gonic/gin"

	apphttp "container-survey/services/api/internal/apphttp"
	"container-survey/services/api/internal/database"
	"container-survey/services/api/internal/numbering"
)

type adminSettingsHandler struct{ pool *database.Pool }

type numberingSetting struct {
	ID            string `json:"id"`
	DocumentType  string `json:"document_type"`
	Prefix        string `json:"prefix"`
	DocCode       string `json:"doc_code"`
	YearFormat    string `json:"year_format"`
	RunningDigits int    `json:"running_digits"`
	ResetPeriod   string `json:"reset_period"`
	StoredPreview string `json:"stored_preview"`
	NextPreview   string `json:"next_preview"`
	CurrentNumber int64  `json:"current_number"`
	NextNumber    int64  `json:"next_number"`
	CurrentPeriod string `json:"current_period"`
	IsActive      bool   `json:"is_active"`
}

type auditLogRow struct {
	ID         string    `json:"id"`
	CreatedAt  time.Time `json:"created_at"`
	UserID     string    `json:"user_id,omitempty"`
	UserName   string    `json:"user_name"`
	ActiveRole string    `json:"active_role"`
	Action     string    `json:"action"`
	EntityType string    `json:"entity_type"`
	EntityID   string    `json:"entity_id,omitempty"`
	OldState   string    `json:"old_state,omitempty"`
	NewState   string    `json:"new_state,omitempty"`
	OldValue   string    `json:"old_value,omitempty"`
	NewValue   string    `json:"new_value,omitempty"`
	Reason     string    `json:"reason,omitempty"`
	RequestID  string    `json:"request_id,omitempty"`
	IPAddress  string    `json:"ip_address,omitempty"`
	UserAgent  string    `json:"user_agent,omitempty"`
}

func (h adminSettingsHandler) listNumbering(c *gin.Context) {
	rows, err := h.pool.Query(c.Request.Context(), `
		SELECT id, document_type, prefix, doc_code, year_format, running_digits,
		       reset_period, COALESCE(format_preview,''), is_active
		FROM numbering_settings
		ORDER BY document_type
	`)
	if err != nil {
		apphttp.Fail(c, http.StatusInternalServerError, "Gagal mengambil pengaturan penomoran.", "INTERNAL_ERROR", nil)
		return
	}
	defer rows.Close()

	now := time.Now()
	items := []numberingSetting{}
	for rows.Next() {
		var item numberingSetting
		if err := rows.Scan(&item.ID, &item.DocumentType, &item.Prefix, &item.DocCode, &item.YearFormat, &item.RunningDigits, &item.ResetPeriod, &item.StoredPreview, &item.IsActive); err != nil {
			apphttp.Fail(c, http.StatusInternalServerError, "Gagal membaca pengaturan penomoran.", "INTERNAL_ERROR", nil)
			return
		}
		item.CurrentPeriod = numbering.PeriodKey(item.ResetPeriod, now)
		if err := h.pool.QueryRow(c.Request.Context(), `
			SELECT COALESCE(MAX(last_number),0)
			FROM numbering_sequences
			WHERE document_type=$1 AND period_key=$2
		`, item.DocumentType, item.CurrentPeriod).Scan(&item.CurrentNumber); err != nil {
			apphttp.Fail(c, http.StatusInternalServerError, "Gagal membaca sequence penomoran.", "INTERNAL_ERROR", nil)
			return
		}
		item.NextNumber = item.CurrentNumber + 1
		item.NextPreview = numbering.Format(numbering.Setting{
			DocumentType:  item.DocumentType,
			Prefix:        item.Prefix,
			DocCode:       item.DocCode,
			YearFormat:    item.YearFormat,
			RunningDigits: item.RunningDigits,
			ResetPeriod:   item.ResetPeriod,
		}, item.NextNumber, now)
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		apphttp.Fail(c, http.StatusInternalServerError, "Gagal membaca pengaturan penomoran.", "INTERNAL_ERROR", nil)
		return
	}
	apphttp.OK(c, "Pengaturan penomoran berhasil diambil tanpa menaikkan sequence.", items)
}

func (h adminSettingsHandler) listAuditLogs(c *gin.Context) {
	page := positiveInt(c.DefaultQuery("page", "1"), 1)
	perPage := positiveInt(c.DefaultQuery("per_page", "20"), 20)
	if perPage > 100 {
		perPage = 100
	}
	search := strings.TrimSpace(c.Query("search"))
	where := ""
	args := []any{}
	if search != "" {
		where = ` WHERE al.action LIKE $1 OR al.entity_type LIKE $1 OR COALESCE(u.name,'') LIKE $1 OR COALESCE(al.active_role,'') LIKE $1 OR COALESCE(al.request_id,'') LIKE $1`
		args = append(args, "%"+search+"%")
	}
	var total int
	if err := h.pool.QueryRow(c.Request.Context(), "SELECT COUNT(*) FROM audit_logs al LEFT JOIN users u ON u.id=al.user_id"+where, args...).Scan(&total); err != nil {
		apphttp.Fail(c, http.StatusInternalServerError, "Gagal menghitung Audit Log.", "INTERNAL_ERROR", nil)
		return
	}

	offset := (page - 1) * perPage
	limitPosition := len(args) + 1
	query := `
		SELECT al.id, al.created_at, COALESCE(al.user_id,''), COALESCE(u.name,'Sistem'),
		       COALESCE(al.active_role,''), al.action, al.entity_type, COALESCE(al.entity_id,''),
		       COALESCE(al.old_state,''), COALESCE(al.new_state,''),
		       COALESCE(CAST(al.old_value AS CHAR),''), COALESCE(CAST(al.new_value AS CHAR),''),
		       COALESCE(al.reason,''), COALESCE(al.request_id,''), COALESCE(al.ip_address,''), COALESCE(al.user_agent,'')
		FROM audit_logs al
		LEFT JOIN users u ON u.id=al.user_id` + where + fmt.Sprintf(" ORDER BY al.created_at DESC LIMIT $%d OFFSET $%d", limitPosition, limitPosition+1)
	args = append(args, perPage, offset)
	rows, err := h.pool.Query(c.Request.Context(), query, args...)
	if err != nil {
		apphttp.Fail(c, http.StatusInternalServerError, "Gagal mengambil Audit Log.", "INTERNAL_ERROR", nil)
		return
	}
	defer rows.Close()
	items := []auditLogRow{}
	for rows.Next() {
		var item auditLogRow
		if err := rows.Scan(&item.ID, &item.CreatedAt, &item.UserID, &item.UserName, &item.ActiveRole, &item.Action, &item.EntityType, &item.EntityID, &item.OldState, &item.NewState, &item.OldValue, &item.NewValue, &item.Reason, &item.RequestID, &item.IPAddress, &item.UserAgent); err != nil {
			apphttp.Fail(c, http.StatusInternalServerError, "Gagal membaca Audit Log.", "INTERNAL_ERROR", nil)
			return
		}
		items = append(items, item)
	}
	if err := rows.Err(); err != nil {
		apphttp.Fail(c, http.StatusInternalServerError, "Gagal membaca Audit Log.", "INTERNAL_ERROR", nil)
		return
	}
	totalPages := 0
	if total > 0 {
		totalPages = (total + perPage - 1) / perPage
	}
	apphttp.Paginated(c, "Audit Log berhasil diambil dalam mode baca-saja.", items, apphttp.PaginationMeta{
		Page: page, PerPage: perPage, Total: total, TotalPages: totalPages,
		HasNext: page < totalPages, HasPrev: page > 1,
	})
}

func positiveInt(value string, fallback int) int {
	parsed, err := strconv.Atoi(value)
	if err != nil || parsed < 1 {
		return fallback
	}
	return parsed
}
