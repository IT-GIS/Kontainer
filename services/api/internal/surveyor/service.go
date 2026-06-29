package surveyor

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

func (s *Service) Dashboard(ctx context.Context, actor Actor) (Dashboard, error) {
	return s.repo.Dashboard(ctx, actor)
}

func (s *Service) ListJobs(ctx context.Context, params ListParams, actor Actor) (ListResult, error) {
	return s.repo.ListJobs(ctx, params, actor)
}

func (s *Service) GetJob(ctx context.Context, id uuid.UUID, actor Actor) (map[string]any, error) {
	return s.repo.GetJob(ctx, id, actor)
}

func (s *Service) ListContainers(ctx context.Context, jobID uuid.UUID, actor Actor) ([]map[string]any, error) {
	return s.repo.ListContainers(ctx, jobID, actor)
}

func (s *Service) StartSurvey(ctx context.Context, input StartSurveyInput, actor Actor) (map[string]any, error) {
	if strings.TrimSpace(input.JobContainerID) == "" {
		return nil, ErrInvalidInput
	}
	return s.repo.StartSurvey(ctx, input, actor)
}

func (s *Service) GetSurvey(ctx context.Context, id uuid.UUID, actor Actor) (map[string]any, error) {
	return s.repo.GetSurvey(ctx, id, actor)
}

func (s *Service) UpdateGeneralInfo(ctx context.Context, id uuid.UUID, input GeneralInfoInput, actor Actor) (map[string]any, error) {
	return s.repo.UpdateGeneralInfo(ctx, id, input, actor)
}

func (s *Service) Checklist(ctx context.Context, id uuid.UUID, actor Actor) ([]map[string]any, error) {
	return s.repo.Checklist(ctx, id, actor)
}

func (s *Service) UpdateChecklist(ctx context.Context, id uuid.UUID, input ChecklistInput, actor Actor) (map[string]any, error) {
	return s.repo.UpdateChecklist(ctx, id, input, actor)
}

func (s *Service) Sheet(ctx context.Context, id uuid.UUID, actor Actor) (map[string]any, error) {
	return s.repo.Sheet(ctx, id, actor)
}

func (s *Service) Damages(ctx context.Context, id uuid.UUID, actor Actor) ([]map[string]any, error) {
	return s.repo.Damages(ctx, id, actor)
}

func (s *Service) CreateDamage(ctx context.Context, surveyID uuid.UUID, input DamageInput, actor Actor) (map[string]any, error) {
	return s.repo.CreateDamage(ctx, surveyID, input, actor)
}

func (s *Service) UpdateDamage(ctx context.Context, damageID uuid.UUID, input DamageInput, actor Actor) (map[string]any, error) {
	return s.repo.UpdateDamage(ctx, damageID, input, actor)
}

func (s *Service) DeleteDamage(ctx context.Context, damageID uuid.UUID, actor Actor) (map[string]any, error) {
	return s.repo.DeleteDamage(ctx, damageID, actor)
}

func (s *Service) UploadPhoto(ctx context.Context, damageID uuid.UUID, input PhotoInput, actor Actor) (map[string]any, error) {
	if strings.TrimSpace(input.FileName) == "" {
		input.FileName = "photo"
	}
	return s.repo.UploadPhoto(ctx, damageID, input, actor)
}

func (s *Service) Photos(ctx context.Context, surveyID uuid.UUID, actor Actor) ([]map[string]any, error) {
	return s.repo.Photos(ctx, surveyID, actor)
}

func (s *Service) Preview(ctx context.Context, surveyID uuid.UUID, actor Actor) (map[string]any, error) {
	return s.repo.Preview(ctx, surveyID, actor)
}

func (s *Service) Submit(ctx context.Context, surveyID uuid.UUID, input SubmitInput, actor Actor) (map[string]any, error) {
	return s.repo.Submit(ctx, surveyID, input, actor)
}
