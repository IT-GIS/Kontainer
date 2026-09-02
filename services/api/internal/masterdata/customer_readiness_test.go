package masterdata

import "testing"

func TestCustomerReadinessRequiresActiveLocationPICMapping(t *testing.T) {
	counts := completeCustomerReadinessCounts()
	counts.locationPICMapping = 0

	readiness := buildCustomerReadiness(counts)
	check := readinessCheckByKey(t, readiness, "location_pic_mapping")
	if check.Ready || readiness.OverallReady {
		t.Fatal("customer without an active Location-PIC mapping must not be ready")
	}

	counts.locationPICMapping = 1
	readiness = buildCustomerReadiness(counts)
	if !readinessCheckByKey(t, readiness, "location_pic_mapping").Ready || !readiness.OverallReady {
		t.Fatal("active Location-PIC mapping must satisfy the readiness check")
	}
}

func TestCustomerReadinessExposesEffectiveCEDEXSource(t *testing.T) {
	counts := completeCustomerReadinessCounts()
	if source := buildCustomerReadiness(counts).CEDEXSource; source != "global" {
		t.Fatalf("unexpected CEDEX source without override: %s", source)
	}
	counts.cedexOverride = 2
	if source := buildCustomerReadiness(counts).CEDEXSource; source != "global_with_customer_override" {
		t.Fatalf("unexpected CEDEX source with override: %s", source)
	}
}

func completeCustomerReadinessCounts() customerReadinessCounts {
	return customerReadinessCounts{
		id: "customer-1", code: "CUST", name: "Customer", status: "active", address: "Jakarta",
		personnel: 1, location: 1, locationPICMapping: 1, surveyType: 1, containerType: 1,
		checklistTemplate: 1, checklistItem: 1, severityMapping: 1, testMapping: 1, photoMapping: 1,
		cedexLocation: 1, cedexComponent: 1, cedexDamage: 1, cedexRepair: 1, cedexMaterial: 1, responsibility: 1,
	}
}

func readinessCheckByKey(t *testing.T, readiness CustomerReadiness, key string) CustomerReadinessCheck {
	t.Helper()
	for _, check := range readiness.Checks {
		if check.Key == key {
			return check
		}
	}
	t.Fatalf("readiness check %q not found", key)
	return CustomerReadinessCheck{}
}
