package users

import (
	"os"
	"strings"
	"testing"
)

func TestUATPermissionPatchIsIdempotentAndReadOnlyForAdmin(t *testing.T) {
	contents, err := os.ReadFile("../../../../database/patches/0014_uat_stabilization.sql")
	if err != nil {
		t.Fatal(err)
	}
	sql := string(contents)
	for _, expected := range []string{"INSERT IGNORE INTO role_permissions", "'users.view.all'", "'surveys.view.all'", "'users.manage.all'", "'roles.manage.all'"} {
		if !strings.Contains(sql, expected) {
			t.Fatalf("permission patch missing %s", expected)
		}
	}
}
