package finance

import (
	"strings"
	"testing"
)

func TestPaymentListIncludesInvoiceID(t *testing.T) {
	if !strings.Contains(paymentListQuery, "i.id AS invoice_id") {
		t.Fatal("payment list must expose invoice_id for invoice navigation")
	}
}
