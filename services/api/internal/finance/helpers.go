package finance

import (
	"container-survey/services/api/internal/database"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"strings"
	"time"

	"github.com/google/uuid"
)

func normalizePagination(page, perPage int) (int, int) {
	if page < 1 {
		page = 1
	}
	if perPage < 1 {
		perPage = 20
	}
	if perPage > 100 {
		perPage = 100
	}
	return page, perPage
}

func totalPages(total, perPage int) int {
	if total == 0 {
		return 0
	}
	return int(math.Ceil(float64(total) / float64(perPage)))
}

func rowsToMaps(rows database.Rows) ([]map[string]any, error) {
	fields := rows.FieldDescriptions()
	items := []map[string]any{}
	for rows.Next() {
		values, err := rows.Values()
		if err != nil {
			return nil, err
		}
		item := map[string]any{}
		for index, field := range fields {
			item[string(field.Name)] = normalizeValue(values[index])
		}
		items = append(items, item)
	}
	return items, rows.Err()
}

func scanRow(row database.Row, keys []string) (map[string]any, error) {
	values := make([]any, len(keys))
	ptrs := make([]any, len(keys))
	for i := range values {
		ptrs[i] = &values[i]
	}
	if err := row.Scan(ptrs...); err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	item := map[string]any{}
	for i, key := range keys {
		item[key] = normalizeValue(values[i])
	}
	return item, nil
}

func normalizeValue(value any) any {
	switch v := value.(type) {
	case time.Time:
		return v.UTC().Format(time.RFC3339)
	case uuid.UUID:
		return v.String()
	default:
		return v
	}
}

func parseDate(value string) (time.Time, error) {
	if strings.TrimSpace(value) == "" {
		return time.Time{}, ErrInvalidInput
	}
	return time.Parse("2006-01-02", value)
}

func parseOptionalDate(value *string) (*time.Time, error) {
	if value == nil || strings.TrimSpace(*value) == "" {
		return nil, nil
	}
	parsed, err := time.Parse("2006-01-02", *value)
	if err != nil {
		return nil, err
	}
	return &parsed, nil
}

func parseUUIDString(value string) (*uuid.UUID, error) {
	if strings.TrimSpace(value) == "" {
		return nil, nil
	}
	parsed, err := uuid.Parse(value)
	if err != nil {
		return nil, ErrInvalidInput
	}
	return &parsed, nil
}

func uuidFromAny(value any) uuid.UUID {
	parsed, _ := uuid.Parse(fmt.Sprint(value))
	return parsed
}

func defaultString(value string, fallback string) string {
	if strings.TrimSpace(value) == "" {
		return fallback
	}
	return value
}

func nextDocNo(ctx context.Context, tx database.Tx, code string, table string) (string, error) {
	var total int
	if err := tx.QueryRow(ctx, fmt.Sprintf("SELECT COUNT(*) FROM %s", table)).Scan(&total); err != nil {
		return "", err
	}
	return fmt.Sprintf("GIFT-%s-%d-%06d", code, time.Now().Year(), total+1), nil
}

func insertAudit(ctx context.Context, tx database.Tx, actor Actor, action, entityType string, entityID *uuid.UUID, oldValue any, newValue any) error {
	oldJSON, _ := json.Marshal(oldValue)
	newJSON, _ := json.Marshal(newValue)
	_, err := tx.Exec(ctx, `INSERT INTO audit_logs (user_id,active_role,action,entity_type,entity_id,old_value,new_value,request_id,ip_address,user_agent) VALUES ($1,$2,$3,$4,$5,NULLIF($6,'null'),NULLIF($7,'null'),NULLIF($8,''),NULLIF($9,''),NULLIF($10,''))`, actor.UserID, actor.ActiveRole, action, entityType, entityID, string(oldJSON), string(newJSON), actor.RequestID, actor.IPAddress, actor.UserAgent)
	return err
}

func listMeta(page, perPage, total int) PaginationMeta {
	pages := totalPages(total, perPage)
	return PaginationMeta{Page: page, PerPage: perPage, Total: total, TotalPages: pages, HasNext: page < pages, HasPrev: page > 1}
}
