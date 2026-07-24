package masterdata

import (
	"context"
	"encoding/json"
	"errors"

	"container-survey/services/api/internal/database"
	"github.com/google/uuid"
)

type PersonnelLocationOption struct {
	ID           string `json:"id"`
	LocationCode string `json:"location_code"`
	LocationName string `json:"location_name"`
	Mapped       bool   `json:"mapped"`
}

type PersonnelLocationMapping struct {
	CustomerID  string                    `json:"customer_id"`
	PersonnelID string                    `json:"personnel_id"`
	Locations   []PersonnelLocationOption `json:"locations"`
}

type PersonnelLocationInput struct {
	LocationIDs []string `json:"location_ids"`
}

func (r Repository) PersonnelLocations(ctx context.Context, customerID, personnelID uuid.UUID) (PersonnelLocationMapping, error) {
	if err := r.validateCustomerPersonnel(ctx, r.runner(), customerID, personnelID, false); err != nil {
		return PersonnelLocationMapping{}, err
	}
	rows, err := r.runner().Query(ctx, `
		SELECT l.id, l.location_code, l.location_name, CASE WHEN mapping.location_id IS NULL THEN 0 ELSE 1 END
		FROM locations l
		LEFT JOIN customer_personnel_locations mapping
		  ON mapping.location_id=l.id AND mapping.customer_personnel_id=$2
		WHERE l.customer_id=$1 AND l.status='active'
		ORDER BY l.location_name
	`, customerID, personnelID)
	if err != nil {
		return PersonnelLocationMapping{}, err
	}
	defer rows.Close()
	locations := []PersonnelLocationOption{}
	for rows.Next() {
		var item PersonnelLocationOption
		if err := rows.Scan(&item.ID, &item.LocationCode, &item.LocationName, &item.Mapped); err != nil {
			return PersonnelLocationMapping{}, err
		}
		locations = append(locations, item)
	}
	return PersonnelLocationMapping{CustomerID: customerID.String(), PersonnelID: personnelID.String(), Locations: locations}, rows.Err()
}

func (r Repository) SetPersonnelLocations(ctx context.Context, customerID, personnelID uuid.UUID, locationIDs []uuid.UUID, actor Actor) (PersonnelLocationMapping, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return PersonnelLocationMapping{}, err
	}
	defer tx.Rollback(ctx)
	if err := r.validateCustomerPersonnel(ctx, tx, customerID, personnelID, true); err != nil {
		return PersonnelLocationMapping{}, err
	}

	unique := make([]uuid.UUID, 0, len(locationIDs))
	seen := map[uuid.UUID]bool{}
	for _, locationID := range locationIDs {
		if seen[locationID] {
			continue
		}
		seen[locationID] = true
		var count int
		if err := tx.QueryRow(ctx, `SELECT COUNT(*) FROM locations WHERE id=$1 AND customer_id=$2 AND status='active'`, locationID, customerID).Scan(&count); err != nil {
			return PersonnelLocationMapping{}, err
		}
		if count != 1 {
			return PersonnelLocationMapping{}, errors.Join(ErrInvalidInput, errors.New("Location tidak aktif atau bukan milik Customer"))
		}
		unique = append(unique, locationID)
	}

	oldIDs, err := mappedLocationIDs(ctx, tx, personnelID)
	if err != nil {
		return PersonnelLocationMapping{}, err
	}
	if _, err := tx.Exec(ctx, `DELETE FROM customer_personnel_locations WHERE customer_personnel_id=$1`, personnelID); err != nil {
		return PersonnelLocationMapping{}, err
	}
	for _, locationID := range unique {
		if _, err := tx.Exec(ctx, `INSERT INTO customer_personnel_locations (customer_personnel_id,location_id) VALUES ($1,$2)`, personnelID, locationID); err != nil {
			return PersonnelLocationMapping{}, err
		}
	}
	oldValue, _ := json.Marshal(map[string]any{"customer_id": customerID, "personnel_id": personnelID, "location_ids": oldIDs})
	newValue, _ := json.Marshal(map[string]any{"customer_id": customerID, "personnel_id": personnelID, "location_ids": unique})
	txRepo := Repository{pool: r.pool, executor: tx}
	userID, role := actor.UserID, actor.ActiveRole
	if err := txRepo.InsertAudit(ctx, AuditEntry{UserID: &userID, ActiveRole: &role, Action: "customer_personnel.locations.update", EntityType: "customer_personnel_locations", EntityID: &personnelID, OldValue: oldValue, NewValue: newValue, RequestID: actor.RequestID, IPAddress: actor.IPAddress, UserAgent: actor.UserAgent}); err != nil {
		return PersonnelLocationMapping{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return PersonnelLocationMapping{}, err
	}
	return r.PersonnelLocations(ctx, customerID, personnelID)
}

func (r Repository) LocationPersonnel(ctx context.Context, customerID, locationID uuid.UUID) ([]map[string]any, error) {
	rows, err := r.runner().Query(ctx, `
		SELECT p.id, p.personnel_code, p.full_name, p.phone, p.email, p.personnel_type, p.status
		FROM customer_personnel_locations mapping
		JOIN customer_personnel p ON p.id=mapping.customer_personnel_id
		JOIN locations l ON l.id=mapping.location_id
		WHERE l.id=$2 AND l.customer_id=$1 AND l.status='active'
		  AND p.customer_id=$1 AND p.status='active' AND p.deleted_at IS NULL
		ORDER BY p.full_name
	`, customerID, locationID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return rowsToMaps(rows)
}

func (r Repository) validateCustomerPersonnel(ctx context.Context, runner queryExecutor, customerID, personnelID uuid.UUID, requireActiveCustomer bool) error {
	customerStatus := ""
	if err := runner.QueryRow(ctx, `SELECT status FROM customers WHERE id=$1 AND deleted_at IS NULL`, customerID).Scan(&customerStatus); err != nil {
		if errors.Is(err, database.ErrNoRows) {
			return ErrNotFound
		}
		return err
	}
	if requireActiveCustomer && customerStatus != "active" {
		return errors.Join(ErrInvalidInput, errors.New("Customer tidak aktif dan hanya dapat dilihat"))
	}
	var count int
	if err := runner.QueryRow(ctx, `SELECT COUNT(*) FROM customer_personnel WHERE id=$1 AND customer_id=$2 AND status='active' AND deleted_at IS NULL`, personnelID, customerID).Scan(&count); err != nil {
		return err
	}
	if count != 1 {
		return errors.Join(ErrInvalidInput, errors.New("Personel/PIC tidak aktif atau bukan milik Customer"))
	}
	return nil
}

func mappedLocationIDs(ctx context.Context, runner queryExecutor, personnelID uuid.UUID) ([]string, error) {
	rows, err := runner.Query(ctx, `SELECT location_id FROM customer_personnel_locations WHERE customer_personnel_id=$1 ORDER BY location_id`, personnelID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	result := []string{}
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		result = append(result, id)
	}
	return result, rows.Err()
}

type customerLocationRepository interface {
	PersonnelLocations(context.Context, uuid.UUID, uuid.UUID) (PersonnelLocationMapping, error)
	SetPersonnelLocations(context.Context, uuid.UUID, uuid.UUID, []uuid.UUID, Actor) (PersonnelLocationMapping, error)
	LocationPersonnel(context.Context, uuid.UUID, uuid.UUID) ([]map[string]any, error)
}

func (s *Service) PersonnelLocations(ctx context.Context, customerID, personnelID uuid.UUID) (PersonnelLocationMapping, error) {
	repo, ok := s.repo.(customerLocationRepository)
	if !ok {
		return PersonnelLocationMapping{}, ErrInvalidInput
	}
	return repo.PersonnelLocations(ctx, customerID, personnelID)
}

func (s *Service) SetPersonnelLocations(ctx context.Context, customerID, personnelID uuid.UUID, input PersonnelLocationInput, actor Actor) (PersonnelLocationMapping, error) {
	repo, ok := s.repo.(customerLocationRepository)
	if !ok {
		return PersonnelLocationMapping{}, ErrInvalidInput
	}
	locationIDs := make([]uuid.UUID, 0, len(input.LocationIDs))
	for _, value := range input.LocationIDs {
		parsed, err := uuid.Parse(value)
		if err != nil {
			return PersonnelLocationMapping{}, ErrInvalidInput
		}
		locationIDs = append(locationIDs, parsed)
	}
	return repo.SetPersonnelLocations(ctx, customerID, personnelID, locationIDs, actor)
}

func (s *Service) LocationPersonnel(ctx context.Context, customerID, locationID uuid.UUID) ([]map[string]any, error) {
	repo, ok := s.repo.(customerLocationRepository)
	if !ok {
		return nil, ErrInvalidInput
	}
	return repo.LocationPersonnel(ctx, customerID, locationID)
}
