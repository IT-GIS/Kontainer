package users

import (
	"strings"
	"testing"
)

func TestUserWhereReadOnlyFilters(t *testing.T) {
	where, args := userWhere(listParams{Status: "active", Role: "surveyor", WithoutSurveyorProfile: true, Search: "UAT"})
	for _, fragment := range []string{"u.status=$1", "r.code=$2", "NOT EXISTS", "u.name LIKE $3"} {
		if !strings.Contains(where, fragment) {
			t.Fatalf("missing %q in %s", fragment, where)
		}
	}
	if len(args) != 3 {
		t.Fatalf("unexpected args: %#v", args)
	}
}
