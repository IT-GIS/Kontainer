package jobs

import (
	"context"
	"encoding/csv"
	"encoding/json"
	"fmt"
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
	if strings.TrimSpace(input.ContainerNo) == "" {
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
	if strings.TrimSpace(input.SurveyorID) == "" || len(input.ContainerIDs) == 0 {
		return nil, ErrInvalidInput
	}
	return s.repo.Assign(ctx, jobID, input, actor)
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

func ParseImport(reader io.Reader) ([]ContainerInput, error) {
	body, err := io.ReadAll(reader)
	if err != nil {
		return nil, err
	}
	trimmed := strings.TrimSpace(string(body))
	if trimmed == "" {
		return nil, ErrInvalidInput
	}
	if strings.HasPrefix(trimmed, "[") {
		var rows []ContainerInput
		if err := json.Unmarshal([]byte(trimmed), &rows); err != nil {
			return nil, ErrInvalidInput
		}
		return rows, nil
	}
	csvReader := csv.NewReader(strings.NewReader(trimmed))
	csvReader.TrimLeadingSpace = true
	records, err := csvReader.ReadAll()
	if err != nil || len(records) < 2 {
		return nil, ErrInvalidInput
	}
	headers := map[string]int{}
	for i, header := range records[0] {
		headers[strings.TrimSpace(header)] = i
	}
	rows := []ContainerInput{}
	for _, record := range records[1:] {
		get := func(key string) string {
			if index, ok := headers[key]; ok && index < len(record) {
				return strings.TrimSpace(record[index])
			}
			return ""
		}
		rows = append(rows, ContainerInput{ContainerNo: get("container_no"), ContainerTypeCode: get("container_type_code"), ISOTypeCode: get("iso_type_code"), SealNo: get("seal_no"), CargoStatus: get("cargo_status"), TruckNo: get("truck_no"), DriverName: get("driver_name"), Remark: get("remark")})
	}
	if len(rows) == 0 {
		return nil, fmt.Errorf("%w: no import rows", ErrInvalidInput)
	}
	return rows, nil
}
