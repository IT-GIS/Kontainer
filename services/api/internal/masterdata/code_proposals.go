package masterdata

import (
	"context"
	"errors"
	"fmt"
	"strings"

	"container-survey/services/api/internal/database"

	"github.com/google/uuid"
)

type CodeProposalReviewInput struct {
	Decision   string `json:"decision"`
	ReviewNote string `json:"review_note"`
}

type codeProposalReviewer interface {
	ReviewCodeProposal(context.Context, uuid.UUID, CodeProposalReviewInput, Actor) (map[string]any, error)
}

func (s *Service) ReviewCodeProposal(ctx context.Context, id uuid.UUID, input CodeProposalReviewInput, actor Actor) (map[string]any, error) {
	decision := strings.ToLower(strings.TrimSpace(input.Decision))
	if decision != "approved" && decision != "rejected" {
		return nil, fmt.Errorf("%w: keputusan review harus approved atau rejected", ErrInvalidInput)
	}
	if decision == "rejected" && strings.TrimSpace(input.ReviewNote) == "" {
		return nil, fmt.Errorf("%w: Catatan review wajib diisi saat pengajuan ditolak", ErrInvalidInput)
	}
	reviewer, ok := s.repo.(codeProposalReviewer)
	if !ok {
		return nil, errors.New("repository pengajuan ISO CEDEX tidak tersedia")
	}
	return reviewer.ReviewCodeProposal(ctx, id, CodeProposalReviewInput{Decision: decision, ReviewNote: strings.TrimSpace(input.ReviewNote)}, actor)
}

func (r Repository) ReviewCodeProposal(ctx context.Context, id uuid.UUID, input CodeProposalReviewInput, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)

	rows, err := tx.Query(ctx, `
		SELECT id, survey_id, customer_id, proposed_by, code_type, code, description,
		       reason, evidence_file_id, notes, status, review_note, reviewed_by,
		       reviewed_at, master_entity_id, created_at, updated_at
		FROM cedex_code_proposals
		WHERE id=$1
		LIMIT 1
		FOR UPDATE
	`, id)
	if err != nil {
		return nil, err
	}
	items, err := rowsToMaps(rows)
	rows.Close()
	if err != nil {
		return nil, err
	}
	if len(items) == 0 {
		return nil, ErrNotFound
	}
	proposal := items[0]
	if stringValue(proposal["status"]) != "pending" {
		return nil, fmt.Errorf("%w: pengajuan ini sudah direview", ErrInvalidInput)
	}

	var masterID *uuid.UUID
	if input.Decision == "approved" {
		createdID, err := createMasterFromProposal(ctx, tx, proposal)
		if err != nil {
			return nil, classifyMutationError(err)
		}
		masterID = &createdID
	}

	_, err = tx.Exec(ctx, `
		UPDATE cedex_code_proposals
		SET status=$2, review_note=NULLIF($3,''), reviewed_by=$4, reviewed_at=now(),
		    master_entity_id=$5, updated_at=now()
		WHERE id=$1 AND status='pending'
	`, id, input.Decision, input.ReviewNote, actor.UserID, masterID)
	if err != nil {
		return nil, err
	}
	updated := map[string]any{}
	for key, value := range proposal {
		updated[key] = value
	}
	updated["status"] = input.Decision
	updated["review_note"] = input.ReviewNote
	updated["reviewed_by"] = actor.UserID.String()
	if masterID != nil {
		updated["master_entity_id"] = masterID.String()
	}

	txRepo := Repository{pool: r.pool, executor: tx}
	if err := txRepo.InsertAudit(ctx, AuditEntry{
		UserID: &actor.UserID, ActiveRole: &actor.ActiveRole, Action: "cedex_code_proposals." + input.Decision,
		EntityType: "cedex_code_proposals", EntityID: &id, OldValue: mustJSON(proposal), NewValue: mustJSON(updated),
		RequestID: actor.RequestID, IPAddress: actor.IPAddress, UserAgent: actor.UserAgent,
	}); err != nil {
		return nil, err
	}
	if masterID != nil {
		if err := txRepo.InsertAudit(ctx, AuditEntry{
			UserID: &actor.UserID, ActiveRole: &actor.ActiveRole, Action: proposalMasterEntityType(stringValue(proposal["code_type"])) + ".create_from_proposal",
			EntityType: proposalMasterEntityType(stringValue(proposal["code_type"])), EntityID: masterID,
			OldValue: mustJSON(nil), NewValue: mustJSON(map[string]any{"proposal_id": id.String(), "code": proposal["code"], "customer_id": proposal["customer_id"]}),
			RequestID: actor.RequestID, IPAddress: actor.IPAddress, UserAgent: actor.UserAgent,
		}); err != nil {
			return nil, err
		}
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return updated, nil
}

func createMasterFromProposal(ctx context.Context, tx database.Tx, proposal map[string]any) (uuid.UUID, error) {
	codeType := stringValue(proposal["code_type"])
	code := strings.ToUpper(stringValue(proposal["code"]))
	expectedLength, _, ok := proposalCodeSpec(codeType)
	if !ok || len(code) != expectedLength || !isASCIIAlphaNumeric(code) {
		return uuid.Nil, fmt.Errorf("%w: format kode pengajuan tidak valid", ErrInvalidInput)
	}
	customerID, err := uuid.Parse(stringValue(proposal["customer_id"]))
	if err != nil {
		return uuid.Nil, fmt.Errorf("%w: Customer pengajuan tidak valid", ErrInvalidInput)
	}
	table, nameColumn := proposalMasterTarget(codeType)
	if table == "" {
		return uuid.Nil, fmt.Errorf("%w: Jenis Kode tidak valid", ErrInvalidInput)
	}
	var duplicate int
	if err := tx.QueryRow(ctx, fmt.Sprintf("SELECT COUNT(*) FROM %s WHERE customer_id=$1 AND LOWER(code)=LOWER($2)", table), customerID, code).Scan(&duplicate); err != nil {
		return uuid.Nil, err
	}
	if duplicate > 0 {
		return uuid.Nil, ErrDuplicate
	}

	masterID := uuid.New()
	description := stringValue(proposal["description"])
	reason := stringValue(proposal["reason"])
	if codeType == "location" {
		face, ok := proposalLocationFace(code[:1])
		if !ok {
			return uuid.Nil, fmt.Errorf("%w: Sector Location Code tidak valid", ErrInvalidInput)
		}
		_, err = tx.Exec(ctx, `
			INSERT INTO cedex_locations (
			  id, customer_id, input_mode, code, face, grid_code, description,
			  source_type, source_reason, status
			) VALUES ($1,$2,'manual',$3,$4,$3,$5,'customer_specific',$6,'active')
		`, masterID, customerID, code, face, description, reason)
		return masterID, err
	}
	_, err = tx.Exec(ctx, fmt.Sprintf(`
		INSERT INTO %s (
		  id, customer_id, code, %s, description, source_type, source_reason, status
		) VALUES ($1,$2,$3,$4,$5,'customer_specific',$6,'active')
	`, table, nameColumn), masterID, customerID, code, description, description, reason)
	return masterID, err
}

func proposalCodeSpec(codeType string) (int, string, bool) {
	switch codeType {
	case "location":
		return 4, "Location Code", true
	case "component":
		return 3, "Component Code", true
	case "damage":
		return 2, "Damage Code", true
	case "action_repair":
		return 2, "Action Repair Code", true
	case "material":
		return 2, "Material Code", true
	default:
		return 0, "", false
	}
}

func proposalMasterTarget(codeType string) (string, string) {
	switch codeType {
	case "component":
		return "cedex_components", "component_name"
	case "damage":
		return "cedex_damages", "damage_name"
	case "action_repair":
		return "cedex_repairs", "repair_name"
	case "material":
		return "cedex_materials", "material_name"
	default:
		return "", ""
	}
}

func proposalMasterEntityType(codeType string) string {
	if codeType == "location" {
		return "cedex_locations"
	}
	table, _ := proposalMasterTarget(codeType)
	return table
}

func proposalLocationFace(sector string) (string, bool) {
	faces := map[string]string{
		"D": "door", "L": "left", "R": "right", "F": "front",
		"U": "understructure", "T": "roof", "B": "floor",
	}
	face, ok := faces[strings.ToUpper(sector)]
	return face, ok
}
