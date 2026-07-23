package masterdata

import (
	"context"
	"errors"
	"fmt"

	"container-survey/services/api/internal/database"

	"github.com/google/uuid"
)

type CustomerReferenceOptionsInput struct {
	SeverityIDs      []string `json:"severity_ids"`
	TestParameterIDs []string `json:"test_parameter_ids"`
	PhotoCategoryIDs []string `json:"photo_category_ids"`
}

type customerReferenceOptionRepository interface {
	GetCustomerReferenceOptions(context.Context, uuid.UUID, uuid.UUID) (map[string]any, error)
	SetCustomerReferenceOptions(context.Context, uuid.UUID, uuid.UUID, CustomerReferenceOptionsInput, Actor) (map[string]any, error)
}

func (s *Service) GetCustomerReferenceOptions(ctx context.Context, customerID, surveyTypeID uuid.UUID) (map[string]any, error) {
	repo, ok := s.repo.(customerReferenceOptionRepository)
	if !ok {
		return nil, errors.New("customer reference options repository is unavailable")
	}
	return repo.GetCustomerReferenceOptions(ctx, customerID, surveyTypeID)
}

func (s *Service) SetCustomerReferenceOptions(ctx context.Context, customerID, surveyTypeID uuid.UUID, input CustomerReferenceOptionsInput, actor Actor) (map[string]any, error) {
	repo, ok := s.repo.(customerReferenceOptionRepository)
	if !ok {
		return nil, errors.New("customer reference options repository is unavailable")
	}
	return repo.SetCustomerReferenceOptions(ctx, customerID, surveyTypeID, input, actor)
}

func (r Repository) GetCustomerReferenceOptions(ctx context.Context, customerID, surveyTypeID uuid.UUID) (map[string]any, error) {
	if err := r.validateCustomerSurveyType(ctx, r.runner(), customerID, surveyTypeID); err != nil {
		return nil, err
	}
	severities, err := r.referenceOptionRows(ctx, `
		SELECT fs.id, fs.code, fs.name, fs.description, fs.status,
		       CASE WHEN map.severity_id IS NULL THEN 0 ELSE map.is_active END AS enabled
		FROM finding_severities fs
		LEFT JOIN customer_survey_type_severities map
		  ON map.severity_id=fs.id AND map.customer_id=$1 AND map.survey_type_id=$2
		WHERE fs.status='active' ORDER BY fs.level_no, fs.code
	`, customerID, surveyTypeID)
	if err != nil {
		return nil, err
	}
	tests, err := r.referenceOptionRows(ctx, `
		SELECT tp.id, tp.code, tp.parameter_name AS name, tp.description, tp.status,
		       CASE WHEN map.test_parameter_id IS NULL THEN 0 ELSE map.is_active END AS enabled
		FROM inspection_test_parameters tp
		LEFT JOIN customer_survey_type_test_parameters map
		  ON map.test_parameter_id=tp.id AND map.customer_id=$1 AND map.survey_type_id=$2
		WHERE tp.status='active' ORDER BY tp.display_order, tp.code
	`, customerID, surveyTypeID)
	if err != nil {
		return nil, err
	}
	photos, err := r.referenceOptionRows(ctx, `
		SELECT pc.id, pc.code, pc.name, pc.description, pc.status,
		       CASE WHEN map.photo_category_id IS NULL THEN 0 ELSE map.is_active END AS enabled
		FROM evidence_photo_categories pc
		LEFT JOIN customer_survey_type_photo_categories map
		  ON map.photo_category_id=pc.id AND map.customer_id=$1 AND map.survey_type_id=$2
		WHERE pc.status='active' ORDER BY pc.display_order, pc.code
	`, customerID, surveyTypeID)
	if err != nil {
		return nil, err
	}
	return map[string]any{
		"customer_id": customerID.String(), "survey_type_id": surveyTypeID.String(),
		"finding_severities": severities, "test_parameters": tests, "photo_categories": photos,
	}, nil
}

func (r Repository) SetCustomerReferenceOptions(ctx context.Context, customerID, surveyTypeID uuid.UUID, input CustomerReferenceOptionsInput, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	if err := r.validateCustomerSurveyType(ctx, tx, customerID, surveyTypeID); err != nil {
		return nil, err
	}
	type mapping struct {
		table       string
		column      string
		sourceTable string
		ids         []string
	}
	mappings := []mapping{
		{"customer_survey_type_severities", "severity_id", "finding_severities", input.SeverityIDs},
		{"customer_survey_type_test_parameters", "test_parameter_id", "inspection_test_parameters", input.TestParameterIDs},
		{"customer_survey_type_photo_categories", "photo_category_id", "evidence_photo_categories", input.PhotoCategoryIDs},
	}
	for _, item := range mappings {
		if _, err := tx.Exec(ctx, fmt.Sprintf("DELETE FROM %s WHERE customer_id=$1 AND survey_type_id=$2", item.table), customerID, surveyTypeID); err != nil {
			return nil, err
		}
		seen := map[uuid.UUID]bool{}
		for _, rawID := range item.ids {
			id, err := uuid.Parse(rawID)
			if err != nil || seen[id] {
				return nil, fmt.Errorf("%w: ID referensi tidak valid atau duplikat", ErrInvalidInput)
			}
			seen[id] = true
			var active int
			if err := tx.QueryRow(ctx, fmt.Sprintf("SELECT COUNT(*) FROM %s WHERE id=$1 AND status='active'", item.sourceTable), id).Scan(&active); err != nil {
				return nil, err
			}
			if active != 1 {
				return nil, fmt.Errorf("%w: referensi tidak aktif atau tidak ditemukan", ErrInvalidInput)
			}
			query := fmt.Sprintf("INSERT INTO %s (customer_id,survey_type_id,%s,is_active) VALUES ($1,$2,$3,1)", item.table, item.column)
			if _, err := tx.Exec(ctx, query, customerID, surveyTypeID, id); err != nil {
				return nil, err
			}
		}
	}
	newValue := map[string]any{
		"customer_id": customerID.String(), "survey_type_id": surveyTypeID.String(),
		"severity_ids": input.SeverityIDs, "test_parameter_ids": input.TestParameterIDs, "photo_category_ids": input.PhotoCategoryIDs,
	}
	entry := AuditEntry{UserID: &actor.UserID, ActiveRole: &actor.ActiveRole, Action: "survey_types.reference_options.update", EntityType: "survey_types", EntityID: &surveyTypeID, NewValue: mustJSON(newValue), RequestID: actor.RequestID, IPAddress: actor.IPAddress, UserAgent: actor.UserAgent}
	txRepo := Repository{pool: r.pool, executor: tx}
	if err := txRepo.InsertAudit(ctx, entry); err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return r.GetCustomerReferenceOptions(ctx, customerID, surveyTypeID)
}

func (r Repository) validateCustomerSurveyType(ctx context.Context, runner queryExecutor, customerID, surveyTypeID uuid.UUID) error {
	var id uuid.UUID
	err := runner.QueryRow(ctx, `SELECT id FROM survey_types WHERE id=$1 AND customer_id=$2 AND status='active' LIMIT 1`, surveyTypeID, customerID).Scan(&id)
	if errors.Is(err, database.ErrNoRows) {
		return ErrNotFound
	}
	return err
}

func (r Repository) referenceOptionRows(ctx context.Context, query string, args ...any) ([]map[string]any, error) {
	rows, err := r.runner().Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return rowsToMaps(rows)
}
