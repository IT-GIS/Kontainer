package reviews

import (
	"context"
	"strings"

	"github.com/google/uuid"
)

type Service struct {
	repo Repository
}

func NewService(repo Repository) *Service {
	return &Service{repo: repo}
}

func (s *Service) Pending(ctx context.Context, params ListParams) (ListResult, error) {
	return s.repo.Pending(ctx, params)
}

func (s *Service) Monitoring(ctx context.Context, params ListParams) (ListResult, error) {
	if !validMonitoringStatus(params.Status) {
		return ListResult{}, ErrInvalidInput
	}
	return s.repo.Monitoring(ctx, params)
}

func (s *Service) Reviews(ctx context.Context, params ListParams) (ListResult, error) {
	if params.Status == "" {
		params.Status = "need_revision"
	}
	if params.Status != "need_revision" && params.Status != "rejected" && params.Status != "approved" {
		return ListResult{}, ErrInvalidInput
	}
	return s.repo.Reviews(ctx, params)
}

func validMonitoringStatus(status string) bool {
	switch status {
	case "", "in_progress", "draft", "submitted", "need_revision", "approved", "rejected":
		return true
	default:
		return false
	}
}

func (s *Service) Detail(ctx context.Context, surveyID uuid.UUID) (map[string]any, error) {
	return s.repo.Detail(ctx, surveyID)
}

func (s *Service) NeedRevision(ctx context.Context, surveyID uuid.UUID, input NeedRevisionInput, actor Actor) (map[string]any, error) {
	if strings.TrimSpace(input.RevisionNote) == "" {
		return nil, ErrInvalidInput
	}
	return s.repo.NeedRevision(ctx, surveyID, input, actor)
}

func (s *Service) Approve(ctx context.Context, surveyID uuid.UUID, input ApproveInput, actor Actor) (map[string]any, error) {
	if strings.TrimSpace(input.FinalResult) == "" {
		return nil, ErrInvalidInput
	}
	return s.repo.Approve(ctx, surveyID, input, actor)
}

func (s *Service) Reject(ctx context.Context, surveyID uuid.UUID, input RejectInput, actor Actor) (map[string]any, error) {
	if strings.TrimSpace(input.RejectionReason) == "" {
		return nil, ErrInvalidInput
	}
	return s.repo.Reject(ctx, surveyID, input, actor)
}

func (s *Service) ListReports(ctx context.Context, params ListParams) (ListResult, error) {
	return s.repo.ListReports(ctx, params)
}

func (s *Service) ReportDetail(ctx context.Context, reportID uuid.UUID) (map[string]any, error) {
	return s.repo.ReportDetail(ctx, reportID)
}

func (s *Service) ReportVersions(ctx context.Context, reportID uuid.UUID) ([]map[string]any, error) {
	return s.repo.ReportVersions(ctx, reportID)
}

func (s *Service) GenerateReport(ctx context.Context, surveyID uuid.UUID, input GenerateReportInput, actor Actor) (map[string]any, error) {
	return s.repo.GenerateReport(ctx, surveyID, input, actor)
}

func (s *Service) ValidateQR(ctx context.Context, token string) (map[string]any, error) {
	return s.repo.ValidateQR(ctx, token)
}
