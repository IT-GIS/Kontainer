package jobstatus

import (
	"context"
	"errors"
	"strings"

	"container-survey/services/api/internal/database"
	"github.com/google/uuid"
)

type ContainerState struct {
	ID              uuid.UUID
	CurrentStatus   string
	SurveyStatus    string
	HasAssignment   bool
	ReportFinalized bool
}

type Result struct {
	JobStatus       string
	ContainerStatus map[uuid.UUID]string
}

// Calculate is the single, deterministic status policy for Job and container
// state. Database repositories only collect child state and persist this result.
func Calculate(currentJobStatus string, containers []ContainerState) Result {
	result := Result{JobStatus: "draft", ContainerStatus: map[uuid.UUID]string{}}
	if currentJobStatus == "cancelled" {
		result.JobStatus = "cancelled"
		for _, container := range containers {
			result.ContainerStatus[container.ID] = "cancelled"
		}
		return result
	}

	active := make([]ContainerState, 0, len(containers))
	for _, container := range containers {
		status := containerStatus(container)
		result.ContainerStatus[container.ID] = status
		if status != "cancelled" {
			container.CurrentStatus = status
			active = append(active, container)
		}
	}
	if len(active) == 0 {
		return result
	}

	allReports := true
	allApproved := true
	allTerminal := true
	allSubmitted := true
	hasRejected := false
	hasNeedRevision := false
	hasUnderReview := false
	hasSubmitted := false
	hasDraft := false
	hasSurvey := false
	hasAssignment := false
	for _, container := range active {
		status := container.CurrentStatus
		allReports = allReports && status == "report_generated"
		allApproved = allApproved && (status == "approved" || status == "report_generated")
		allTerminal = allTerminal && (status == "approved" || status == "rejected" || status == "report_generated")
		allSubmitted = allSubmitted && (status == "submitted" || status == "resubmitted")
		hasRejected = hasRejected || status == "rejected"
		hasNeedRevision = hasNeedRevision || status == "need_revision"
		hasUnderReview = hasUnderReview || status == "under_review"
		hasSubmitted = hasSubmitted || status == "submitted" || status == "resubmitted"
		hasDraft = hasDraft || status == "draft" || status == "in_progress"
		hasSurvey = hasSurvey || strings.TrimSpace(container.SurveyStatus) != ""
		hasAssignment = hasAssignment || container.HasAssignment
	}

	switch {
	case allReports:
		result.JobStatus = "report_generated"
	case allApproved:
		result.JobStatus = "all_survey_approved"
	case allTerminal && hasRejected:
		result.JobStatus = "completed_with_rejection"
	case hasNeedRevision:
		result.JobStatus = "need_revision"
	case hasUnderReview:
		result.JobStatus = "under_review"
	case allSubmitted || (hasSubmitted && !hasDraft):
		result.JobStatus = "all_survey_submitted"
	case hasSurvey:
		result.JobStatus = "in_progress"
	case hasAssignment:
		result.JobStatus = "assigned"
	}
	return result
}

func containerStatus(container ContainerState) string {
	if container.CurrentStatus == "cancelled" {
		return "cancelled"
	}
	if container.ReportFinalized {
		return "report_generated"
	}
	if status := strings.TrimSpace(container.SurveyStatus); status != "" {
		return status
	}
	if container.HasAssignment {
		return "assigned"
	}
	return "unassigned"
}

// RecalculateJobStatusTx locks the Job and its children, persists container
// state first, then persists the aggregate Job state in the same transaction.
func RecalculateJobStatusTx(ctx context.Context, tx database.Tx, jobID uuid.UUID, actorID *uuid.UUID) (Result, error) {
	var current string
	if err := tx.QueryRow(ctx, `SELECT status FROM job_orders WHERE id=$1 AND deleted_at IS NULL FOR UPDATE`, jobID).Scan(&current); err != nil {
		return Result{}, err
	}
	rows, err := tx.Query(ctx, `
		SELECT jc.id, jc.status,
		       COALESCE((
		         SELECT s.status FROM surveys s
		         WHERE s.job_container_id=jc.id AND s.is_active=1 AND s.deleted_at IS NULL
		         ORDER BY s.survey_round DESC, s.created_at DESC LIMIT 1
		       ), '') AS survey_status,
		       EXISTS(
		         SELECT 1 FROM assignment_containers ac
		         JOIN assignments a ON a.id=ac.assignment_id
		         WHERE ac.job_container_id=jc.id AND ac.unassigned_at IS NULL
		           AND a.status NOT IN ('cancelled','reassigned')
		       ) AS has_assignment,
		       EXISTS(
		         SELECT 1 FROM reports report
		         WHERE report.job_container_id=jc.id
		           AND report.status IN ('generated','finalized','archived')
		       ) AS report_finalized
		FROM job_containers jc
		WHERE jc.job_order_id=$1 AND jc.deleted_at IS NULL
		ORDER BY jc.created_at, jc.id
		FOR UPDATE
	`, jobID)
	if err != nil {
		return Result{}, err
	}
	defer rows.Close()
	states := []ContainerState{}
	for rows.Next() {
		var state ContainerState
		if err := rows.Scan(&state.ID, &state.CurrentStatus, &state.SurveyStatus, &state.HasAssignment, &state.ReportFinalized); err != nil {
			return Result{}, err
		}
		states = append(states, state)
	}
	if err := rows.Err(); err != nil {
		return Result{}, err
	}

	result := Calculate(current, states)
	for _, state := range states {
		next := result.ContainerStatus[state.ID]
		if next == "" || next == state.CurrentStatus {
			continue
		}
		if _, err := tx.Exec(ctx, `UPDATE job_containers SET status=$2, updated_at=now() WHERE id=$1`, state.ID, next); err != nil {
			return Result{}, err
		}
	}
	if strings.TrimSpace(result.JobStatus) == "" {
		return Result{}, errors.New("job status calculation returned an empty status")
	}
	if _, err := tx.Exec(ctx, `
		UPDATE job_orders
		SET status=$2, updated_by=COALESCE($3,updated_by), updated_at=now()
		WHERE id=$1
	`, jobID, result.JobStatus, actorID); err != nil {
		return Result{}, err
	}
	return result, nil
}
