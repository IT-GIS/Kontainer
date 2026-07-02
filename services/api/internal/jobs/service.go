package jobs

import (
	"context"
	"io"
	"strings"

	"github.com/google/uuid"
)

type Service struct{ repo Repository }

func NewService(repo Repository) *Service { return &Service{repo: repo} }

func (s *Service) ListJobs(ctx context.Context, params ListParams) (ListResult, error) {
	return s.repo.ListJobs(ctx, params)
}
func (s *Service) GetJob(ctx context.Context, id uuid.UUID) (map[string]any, error) {
	return s.repo.GetJob(ctx, id)
}
func (s *Service) UpdateJob(ctx context.Context, id uuid.UUID, input JobInput, actor Actor) (map[string]any, error) {
	if err := validateJobInput(input); err != nil {
		return nil, err
	}
	return s.repo.UpdateJob(ctx, id, input, actor)
}
func (s *Service) CancelJob(ctx context.Context, id uuid.UUID, input CancelInput, actor Actor) (map[string]any, error) {
	return s.repo.CancelJob(ctx, id, input.Reason, actor)
}
func (s *Service) ListContainers(ctx context.Context, jobID uuid.UUID, params ListParams) (ListResult, error) {
	return s.repo.ListContainers(ctx, jobID, params)
}
func (s *Service) Timeline(ctx context.Context, jobID uuid.UUID) ([]map[string]any, error) {
	return s.repo.Timeline(ctx, jobID)
}
func (s *Service) ListAssignments(ctx context.Context, jobID uuid.UUID) ([]map[string]any, error) {
	return s.repo.ListAssignments(ctx, jobID)
}

func (s *Service) CreateJob(ctx context.Context, input JobInput, actor Actor) (map[string]any, error) {
	if err := validateJobInput(input); err != nil {
		return nil, err
	}
	return s.repo.CreateJob(ctx, input, actor)
}

func (s *Service) AddContainer(ctx context.Context, jobID uuid.UUID, input ContainerInput, actor Actor) (map[string]any, error) {
	if err := validateContainerInput(input); err != nil {
		return nil, ErrInvalidInput
	}
	return s.repo.AddContainer(ctx, jobID, input, actor)
}

func (s *Service) ImportContainers(ctx context.Context, jobID uuid.UUID, reader io.Reader, actor Actor) (ImportResult, error) {
	inputs, err := ParseImport(reader)
	if err != nil {
		return ImportResult{}, err
	}
	return s.repo.ImportContainers(ctx, jobID, inputs, actor)
}

func (s *Service) Assign(ctx context.Context, jobID uuid.UUID, input AssignInput, actor Actor) (map[string]any, error) {
	if err := validateAssignInput(input); err != nil {
		return nil, ErrInvalidInput
	}
	return s.repo.Assign(ctx, jobID, input, actor)
}

func validateContainerInput(input ContainerInput) error {
	validation := ValidateContainerNumber(input.ContainerNo)
	if !validation.IsFormatValid {
		return ErrInvalidInput
	}
	if input.CargoStatus != "" && input.CargoStatus != "empty" && input.CargoStatus != "laden" && input.CargoStatus != "unknown" {
		return ErrInvalidInput
	}
	for _, weight := range []*float64{input.GrossWeight, input.TareWeight, input.Payload} {
		if weight != nil && *weight < 0 {
			return ErrInvalidInput
		}
	}
	if _, err := parseOptionalDate(input.ManufactureDate); err != nil {
		return ErrInvalidInput
	}
	if !validation.IsCheckDigitValid && strings.TrimSpace(input.CheckDigitOverrideReason) == "" {
		return ErrInvalidInput
	}
	return nil
}

func validateAssignInput(input AssignInput) error {
	if strings.TrimSpace(input.SurveyorID) == "" || len(input.ContainerIDs) == 0 {
		return ErrInvalidInput
	}
	startDate, err := parseOptionalTime(input.StartDate)
	if err != nil {
		return ErrInvalidInput
	}
	dueDate, err := parseOptionalTime(input.DueDate)
	if err != nil {
		return ErrInvalidInput
	}
	if startDate != nil && dueDate != nil && dueDate.Before(*startDate) {
		return ErrInvalidInput
	}
	return nil
}

func (s *Service) Reassign(ctx context.Context, containerID uuid.UUID, input ReassignInput, actor Actor) (map[string]any, error) {
	if strings.TrimSpace(input.ToSurveyorID) == "" || strings.TrimSpace(input.Reason) == "" {
		return nil, ErrInvalidInput
	}
	return s.repo.Reassign(ctx, containerID, input, actor)
}

func validateJobInput(input JobInput) error {
	if strings.TrimSpace(input.JobDate) == "" || strings.TrimSpace(input.CustomerID) == "" || strings.TrimSpace(input.SurveyTypeID) == "" || strings.TrimSpace(input.LocationID) == "" {
		return ErrInvalidInput
	}
	if input.Priority != "" && input.Priority != "normal" && input.Priority != "urgent" {
		return ErrInvalidInput
	}
	return nil
}
