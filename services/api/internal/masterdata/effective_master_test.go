package masterdata

import (
	"strings"
	"testing"
)

func TestEffectiveMasterScopeUsesGlobalFallbackAndActiveOverride(t *testing.T) {
	scope, err := EffectiveMasterScopeSQL("cedex_locations", "location", "$1")
	if err != nil {
		t.Fatal(err)
	}
	for _, fragment := range []string{
		"location.customer_id=$1",
		"location.customer_id IS NULL",
		"override.customer_id=$1",
		"override.status='active'",
		"LOWER(override.code)=LOWER(location.code)",
	} {
		if !strings.Contains(scope, fragment) {
			t.Fatalf("effective scope missing %q: %s", fragment, scope)
		}
	}
	if strings.Contains(scope, "override.status<>'active'") {
		t.Fatal("inactive override must not hide an active global master")
	}
}

func TestEffectiveMasterScopeRejectsUntrustedTable(t *testing.T) {
	if _, err := EffectiveMasterScopeSQL("cedex_locations; DROP TABLE customers", "x", "$1"); err == nil {
		t.Fatal("unsupported table must be rejected")
	}
}

func TestEffectiveDecisionRuleScopePrefersMatchingCustomerIdentity(t *testing.T) {
	scope := EffectiveDecisionRuleScopeSQL("rule", "$1")
	for _, fragment := range []string{
		"rule.customer_id=$1",
		"rule.customer_id IS NULL",
		"override.customer_id=$1",
		"override.damage_id=rule.damage_id",
		"override.measurement_field=rule.measurement_field",
	} {
		if !strings.Contains(scope, fragment) {
			t.Fatalf("decision rule scope missing %q: %s", fragment, scope)
		}
	}
}
