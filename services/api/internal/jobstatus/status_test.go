package jobstatus

import (
	"testing"

	"github.com/google/uuid"
)

func TestCalculateMultiContainerKeepsNotStartedContainerAssigned(t *testing.T) {
	draftID, assignedID := uuid.New(), uuid.New()
	result := Calculate("assigned", []ContainerState{
		{ID: draftID, CurrentStatus: "in_progress", SurveyStatus: "draft", HasAssignment: true},
		{ID: assignedID, CurrentStatus: "assigned", HasAssignment: true},
	})
	if result.JobStatus != "in_progress" || result.ContainerStatus[assignedID] != "assigned" {
		t.Fatalf("unexpected multi-container result: %#v", result)
	}
}

func TestCalculateMixedDecisionCompletesWithRejection(t *testing.T) {
	result := Calculate("under_review", []ContainerState{
		{ID: uuid.New(), SurveyStatus: "approved", HasAssignment: true},
		{ID: uuid.New(), SurveyStatus: "rejected", HasAssignment: true},
	})
	if result.JobStatus != "completed_with_rejection" {
		t.Fatalf("mixed decision status = %q", result.JobStatus)
	}
}

func TestCalculateRevisionAndReviewPrecedence(t *testing.T) {
	result := Calculate("all_survey_submitted", []ContainerState{
		{ID: uuid.New(), SurveyStatus: "under_review", HasAssignment: true},
		{ID: uuid.New(), SurveyStatus: "need_revision", HasAssignment: true},
	})
	if result.JobStatus != "need_revision" {
		t.Fatalf("revision status = %q", result.JobStatus)
	}
}

func TestCalculateCancelledJobCannotBeReopened(t *testing.T) {
	id := uuid.New()
	result := Calculate("cancelled", []ContainerState{{ID: id, SurveyStatus: "draft", HasAssignment: true}})
	if result.JobStatus != "cancelled" || result.ContainerStatus[id] != "cancelled" {
		t.Fatalf("cancelled status changed: %#v", result)
	}
}
