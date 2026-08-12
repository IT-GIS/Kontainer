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

func TestCalculateMixedStatuses(t *testing.T) {
	tests := []struct {
		name     string
		statuses []string
		want     string
	}{
		{"approved and submitted", []string{"approved", "submitted"}, "all_survey_submitted"},
		{"approved and resubmitted", []string{"approved", "resubmitted"}, "all_survey_submitted"},
		{"approved and under review", []string{"approved", "under_review"}, "under_review"},
		{"rejected and submitted", []string{"rejected", "submitted"}, "all_survey_submitted"},
		{"report and approved", []string{"report_generated", "approved"}, "all_survey_approved"},
		{"approved and rejected", []string{"approved", "rejected"}, "completed_with_rejection"},
		{"revision and review", []string{"need_revision", "under_review"}, "need_revision"},
		{"draft and approved", []string{"draft", "approved"}, "in_progress"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			states := make([]ContainerState, 0, len(tc.statuses))
			for _, status := range tc.statuses {
				states = append(states, ContainerState{ID: uuid.New(), SurveyStatus: status, HasAssignment: true})
			}
			if got := Calculate("in_progress", states).JobStatus; got != tc.want {
				t.Fatalf("status = %q, want %q", got, tc.want)
			}
		})
	}
}
