package surveyor

import (
	"context"
	"strings"

	"github.com/google/uuid"
)

func (r Repository) ListCodeProposals(ctx context.Context, actor Actor) ([]map[string]any, error) {
	rows, err := r.pool.Query(ctx, `
		SELECT proposal.id, proposal.survey_id, survey.survey_no, container.container_no,
		       customer.customer_name, proposal.code_type, proposal.code, proposal.description,
		       proposal.reason, proposal.notes, proposal.status, proposal.review_note,
		       proposal.created_at, proposal.reviewed_at
		FROM cedex_code_proposals proposal
		JOIN surveys survey ON survey.id=proposal.survey_id AND survey.deleted_at IS NULL
		JOIN job_containers container ON container.id=survey.job_container_id
		JOIN customers customer ON customer.id=proposal.customer_id
		WHERE proposal.proposed_by=$1
		ORDER BY proposal.created_at DESC
	`, actor.UserID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	return rowsToMaps(rows)
}

func (r Repository) CreateCodeProposal(ctx context.Context, surveyID uuid.UUID, input CodeProposalInput, actor Actor) (map[string]any, error) {
	codeType := strings.ToLower(strings.TrimSpace(input.CodeType))
	code := strings.ToUpper(strings.TrimSpace(input.Code))
	expectedLength, ok := surveyProposalCodeLength(codeType)
	if !ok {
		return nil, validationError("CEDEX_PROPOSAL_TYPE_INVALID", "Jenis Kode pengajuan tidak valid.")
	}
	if len(code) != expectedLength || !surveyProposalAlphaNumeric(code) {
		return nil, validationError("CEDEX_PROPOSAL_CODE_INVALID", "Code pengajuan tidak sesuai panjang dan format jenis kode.")
	}
	description := strings.TrimSpace(input.Description)
	reason := strings.TrimSpace(input.Reason)
	if description == "" || reason == "" {
		return nil, validationError("CEDEX_PROPOSAL_REQUIRED", "Description dan Alasan Pengajuan wajib diisi.")
	}
	var evidenceFileID *uuid.UUID
	if strings.TrimSpace(input.EvidenceFileID) != "" {
		parsed, err := uuid.Parse(strings.TrimSpace(input.EvidenceFileID))
		if err != nil {
			return nil, validationError("CEDEX_PROPOSAL_EVIDENCE_INVALID", "Foto / Bukti harus menggunakan File ID yang valid.")
		}
		evidenceFileID = &parsed
	}

	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	base, err := r.surveyBaseTx(ctx, tx, surveyID, actor)
	if err != nil {
		return nil, err
	}
	if evidenceFileID != nil {
		var fileCount int
		if err := tx.QueryRow(ctx, "SELECT COUNT(*) FROM file_objects WHERE id=$1", *evidenceFileID).Scan(&fileCount); err != nil {
			return nil, err
		}
		if fileCount != 1 {
			return nil, validationError("CEDEX_PROPOSAL_EVIDENCE_NOT_FOUND", "File Foto / Bukti tidak ditemukan.")
		}
	}
	proposalID := uuid.New()
	item, err := scanRow(tx.QueryRow(ctx, `
		INSERT INTO cedex_code_proposals (
		  id, survey_id, customer_id, proposed_by, code_type, code, description,
		  reason, evidence_file_id, notes, status
		) VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,NULLIF($10,''),'pending')
		RETURNING id, survey_id, customer_id, proposed_by, code_type, code, description,
		          reason, evidence_file_id, notes, status, created_at
	`, proposalID, surveyID, parseUUIDString(base["customer_id"]), actor.UserID, codeType, code, description, reason, evidenceFileID, strings.TrimSpace(input.Notes)), []string{
		"id", "survey_id", "customer_id", "proposed_by", "code_type", "code", "description",
		"reason", "evidence_file_id", "notes", "status", "created_at",
	})
	if err != nil {
		return nil, err
	}
	if err := r.insertAudit(ctx, tx, actor, "cedex_code_proposals.create", "cedex_code_proposals", &proposalID, nil, item); err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return item, nil
}

func surveyProposalCodeLength(codeType string) (int, bool) {
	switch codeType {
	case "location":
		return 4, true
	case "component":
		return 3, true
	case "damage", "action_repair", "material":
		return 2, true
	default:
		return 0, false
	}
}

func surveyProposalAlphaNumeric(value string) bool {
	if value == "" {
		return false
	}
	for _, character := range value {
		if !((character >= 'A' && character <= 'Z') || (character >= '0' && character <= '9')) {
			return false
		}
	}
	return true
}
