package finance

import (
	"context"

	"github.com/google/uuid"
)

type Service struct{ repo Repository }

func NewService(repo Repository) *Service { return &Service{repo: repo} }

func (s *Service) Dashboard(ctx context.Context) (map[string]any, error) {
	return s.repo.Dashboard(ctx)
}
func (s *Service) ReadyToInvoice(ctx context.Context, params ListParams) (ListResult, error) {
	return s.repo.ReadyToInvoice(ctx, params)
}
func (s *Service) ListPriceLists(ctx context.Context, params ListParams) (ListResult, error) {
	return s.repo.ListPriceLists(ctx, params)
}
func (s *Service) PriceListDetail(ctx context.Context, id uuid.UUID) (map[string]any, error) {
	return s.repo.PriceListDetail(ctx, id)
}
func (s *Service) CreatePriceList(ctx context.Context, input PriceListInput, actor Actor) (map[string]any, error) {
	return s.repo.CreatePriceList(ctx, input, actor)
}
func (s *Service) UpdatePriceList(ctx context.Context, id uuid.UUID, input PriceListInput, actor Actor) (map[string]any, error) {
	return s.repo.UpdatePriceList(ctx, id, input, actor)
}
func (s *Service) DeletePriceList(ctx context.Context, id uuid.UUID, actor Actor) (map[string]any, error) {
	return s.repo.DeletePriceList(ctx, id, actor)
}
func (s *Service) CreateInvoice(ctx context.Context, input InvoiceInput, actor Actor) (map[string]any, error) {
	return s.repo.CreateInvoice(ctx, input, actor)
}
func (s *Service) ListInvoices(ctx context.Context, params ListParams) (ListResult, error) {
	return s.repo.ListInvoices(ctx, params)
}
func (s *Service) InvoiceDetail(ctx context.Context, id uuid.UUID) (map[string]any, error) {
	return s.repo.InvoiceDetail(ctx, id)
}
func (s *Service) IssueInvoice(ctx context.Context, id uuid.UUID, actor Actor) (map[string]any, error) {
	return s.repo.IssueInvoice(ctx, id, actor)
}
func (s *Service) CancelInvoice(ctx context.Context, id uuid.UUID, input CancelInput, actor Actor) (map[string]any, error) {
	return s.repo.CancelInvoice(ctx, id, input, actor)
}
func (s *Service) CreatePayment(ctx context.Context, input PaymentInput, actor Actor) (map[string]any, error) {
	return s.repo.CreatePayment(ctx, input, actor)
}
func (s *Service) ListPayments(ctx context.Context, params ListParams) (ListResult, error) {
	return s.repo.ListPayments(ctx, params)
}
func (s *Service) Outstanding(ctx context.Context, params ListParams) (ListResult, error) {
	return s.repo.Outstanding(ctx, params)
}
func (s *Service) CustomerSummary(ctx context.Context, params ListParams) (ListResult, error) {
	return s.repo.CustomerSummary(ctx, params)
}
