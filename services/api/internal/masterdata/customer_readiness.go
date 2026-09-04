package masterdata

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"container-survey/services/api/internal/database"
	"github.com/google/uuid"
)

type CustomerReadinessCheck struct {
	Key   string `json:"key"`
	Label string `json:"label"`
	Count int    `json:"count"`
	Ready bool   `json:"ready"`
}

type CustomerReadiness struct {
	ID                      string                   `json:"id"`
	CustomerCode            string                   `json:"customer_code"`
	CustomerName            string                   `json:"customer_name"`
	Status                  string                   `json:"status"`
	PersonnelCount          int                      `json:"personnel_count"`
	LocationCount           int                      `json:"location_count"`
	LocationPICMappingCount int                      `json:"location_pic_mapping_count"`
	CEDEXOverrideCount      int                      `json:"cedex_override_count"`
	CEDEXSource             string                   `json:"cedex_source"`
	JobCount                int                      `json:"job_count"`
	ReadyCount              int                      `json:"ready_count"`
	TotalChecks             int                      `json:"total_checks"`
	OverallReady            bool                     `json:"overall_ready"`
	Checks                  []CustomerReadinessCheck `json:"checks"`
}

type customerReadinessCounts struct {
	id, code, name, status, address                                        string
	personnel, location, locationPICMapping, surveyType, containerType     int
	checklistTemplate, checklistItem                                       int
	severityMapping, testMapping, photoMapping                             int
	cedexLocation, cedexComponent, cedexDamage, cedexRepair, cedexMaterial int
	cedexOverride, jobs                                                    int
}

func (r Repository) ListCustomerReadiness(ctx context.Context, customerID *uuid.UUID) ([]CustomerReadiness, error) {
	where := "WHERE c.deleted_at IS NULL"
	args := []any{}
	if customerID != nil {
		where += " AND c.id=$1"
		args = append(args, *customerID)
	}
	query := fmt.Sprintf(`
		SELECT c.id, c.customer_code, c.customer_name, c.status, COALESCE(c.address,''),
		  (SELECT COUNT(*) FROM customer_personnel p WHERE p.customer_id=c.id AND p.status='active' AND p.deleted_at IS NULL),
		  (SELECT COUNT(*) FROM locations l WHERE l.customer_id=c.id AND l.status='active'),
		  (SELECT COUNT(*) FROM customer_personnel_locations mapping
		    JOIN customer_personnel p ON p.id=mapping.customer_personnel_id
		      AND p.customer_id=c.id AND p.status='active' AND p.deleted_at IS NULL
		    JOIN locations l ON l.id=mapping.location_id AND l.customer_id=c.id AND l.status='active'),
		  (SELECT COUNT(*) FROM survey_types st WHERE st.customer_id=c.id AND st.status='active'),
		  (SELECT COUNT(*) FROM container_types ct WHERE ct.customer_id=c.id AND ct.status='active'),
		  (SELECT COUNT(*) FROM fitness_checklist_templates t WHERE t.customer_id=c.id AND t.status='active' AND t.deleted_at IS NULL
		    AND EXISTS (SELECT 1 FROM fitness_checklist_template_items i WHERE i.template_id=t.id AND i.status='active')),
		  (SELECT COUNT(*) FROM fitness_checklist_template_items i JOIN fitness_checklist_templates t ON t.id=i.template_id
		    WHERE t.customer_id=c.id AND t.status='active' AND t.deleted_at IS NULL AND i.status='active'),
		  (SELECT COUNT(*) FROM customer_survey_type_severities m JOIN survey_types st ON st.id=m.survey_type_id
		    WHERE m.customer_id=c.id AND st.customer_id=c.id AND st.status='active' AND m.is_active=1),
		  (SELECT COUNT(*) FROM customer_survey_type_test_parameters m JOIN survey_types st ON st.id=m.survey_type_id
		    WHERE m.customer_id=c.id AND st.customer_id=c.id AND st.status='active' AND m.is_active=1),
		  (SELECT COUNT(*) FROM customer_survey_type_photo_categories m JOIN survey_types st ON st.id=m.survey_type_id
		    WHERE m.customer_id=c.id AND st.customer_id=c.id AND st.status='active' AND m.is_active=1),
		  %s,
		  %s,
		  %s,
		  %s,
		  %s,
		  ((SELECT COUNT(*) FROM cedex_locations x WHERE x.customer_id=c.id AND x.status='active') +
		   (SELECT COUNT(*) FROM cedex_components x WHERE x.customer_id=c.id AND x.status='active') +
		   (SELECT COUNT(*) FROM cedex_damages x WHERE x.customer_id=c.id AND x.status='active') +
		   (SELECT COUNT(*) FROM cedex_repairs x WHERE x.customer_id=c.id AND x.status='active') +
		   (SELECT COUNT(*) FROM cedex_materials x WHERE x.customer_id=c.id AND x.status='active')),
		  (SELECT COUNT(*) FROM job_orders jo WHERE jo.customer_id=c.id AND jo.deleted_at IS NULL)
		FROM customers c
		`+where+`
		ORDER BY c.customer_name
	`,
		effectiveMasterCountSQL("cedex_locations", "x", "c.id"),
		effectiveMasterCountSQL("cedex_components", "x", "c.id"),
		effectiveMasterCountSQL("cedex_damages", "x", "c.id"),
		effectiveMasterCountSQL("cedex_repairs", "x", "c.id"),
		effectiveMasterCountSQL("cedex_materials", "x", "c.id"),
	)
	rows, err := r.runner().Query(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	result := []CustomerReadiness{}
	for rows.Next() {
		var item customerReadinessCounts
		if err := rows.Scan(
			&item.id, &item.code, &item.name, &item.status, &item.address,
			&item.personnel, &item.location, &item.locationPICMapping, &item.surveyType, &item.containerType,
			&item.checklistTemplate, &item.checklistItem,
			&item.severityMapping, &item.testMapping, &item.photoMapping,
			&item.cedexLocation, &item.cedexComponent, &item.cedexDamage, &item.cedexRepair, &item.cedexMaterial,
			&item.cedexOverride,
			&item.jobs,
		); err != nil {
			return nil, err
		}
		result = append(result, buildCustomerReadiness(item))
	}
	return result, rows.Err()
}

func buildCustomerReadiness(item customerReadinessCounts) CustomerReadiness {
	checks := []CustomerReadinessCheck{
		readinessCheck("profile", "Profil", boolCount(strings.TrimSpace(item.code) != "" && strings.TrimSpace(item.name) != "" && strings.TrimSpace(item.address) != "")),
		readinessCheck("personnel", "Personel/PIC aktif", item.personnel),
		readinessCheck("location", "Location aktif", item.location),
		readinessCheck("location_pic_mapping", "Mapping Location–PIC aktif", item.locationPICMapping),
		readinessCheck("survey_type", "Survey Type aktif", item.surveyType),
		readinessCheck("container_type", "Container Type aktif", item.containerType),
		readinessCheck("checklist_template", "Checklist Template siap", item.checklistTemplate),
		readinessCheck("checklist_item", "Checklist Item aktif", item.checklistItem),
		readinessCheck("severity_mapping", "Mapping Severity", item.severityMapping),
		readinessCheck("test_parameter_mapping", "Mapping Test Parameter", item.testMapping),
		readinessCheck("photo_category_mapping", "Mapping Photo Category", item.photoMapping),
		readinessCheck("cedex_location", "CEDEX Location", item.cedexLocation),
		readinessCheck("cedex_component", "CEDEX Component", item.cedexComponent),
		readinessCheck("cedex_damage", "CEDEX Damage", item.cedexDamage),
		readinessCheck("cedex_action_repair", "CEDEX Action Repair", item.cedexRepair),
		readinessCheck("cedex_material", "CEDEX Material", item.cedexMaterial),
	}
	ready := 0
	for _, check := range checks {
		if check.Ready {
			ready++
		}
	}
	cedexSource := "global"
	if item.cedexOverride > 0 {
		cedexSource = "global_with_customer_override"
	}
	return CustomerReadiness{
		ID: item.id, CustomerCode: item.code, CustomerName: item.name, Status: item.status,
		PersonnelCount: item.personnel, LocationCount: item.location, LocationPICMappingCount: item.locationPICMapping,
		CEDEXOverrideCount: item.cedexOverride, CEDEXSource: cedexSource, JobCount: item.jobs,
		ReadyCount: ready, TotalChecks: len(checks), OverallReady: ready == len(checks), Checks: checks,
	}
}

func readinessCheck(key, label string, count int) CustomerReadinessCheck {
	return CustomerReadinessCheck{Key: key, Label: label, Count: count, Ready: count > 0}
}

func boolCount(value bool) int {
	if value {
		return 1
	}
	return 0
}

type customerReadinessRepository interface {
	ListCustomerReadiness(context.Context, *uuid.UUID) ([]CustomerReadiness, error)
}

func (s *Service) ListCustomerReadiness(ctx context.Context) ([]CustomerReadiness, error) {
	repo, ok := s.repo.(customerReadinessRepository)
	if !ok {
		return nil, ErrInvalidInput
	}
	return repo.ListCustomerReadiness(ctx, nil)
}

func (s *Service) CustomerReadiness(ctx context.Context, customerID uuid.UUID) (CustomerReadiness, error) {
	repo, ok := s.repo.(customerReadinessRepository)
	if !ok {
		return CustomerReadiness{}, ErrInvalidInput
	}
	items, err := repo.ListCustomerReadiness(ctx, &customerID)
	if err != nil {
		return CustomerReadiness{}, err
	}
	if len(items) == 0 {
		return CustomerReadiness{}, ErrNotFound
	}
	return items[0], nil
}

func (s *Service) EnsureActiveCustomer(ctx context.Context, customerID uuid.UUID) error {
	item, err := s.repo.Get(ctx, Resources["customers"], customerID)
	if err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return ErrNotFound
		}
		return err
	}
	if strings.ToLower(strings.TrimSpace(stringValue(item["status"]))) != "active" {
		return errors.Join(ErrInvalidInput, errors.New("Customer tidak aktif dan hanya dapat dilihat"))
	}
	return nil
}
