package objectstorage

import "testing"

func TestParseEndpoint(t *testing.T) {
	tests := []struct {
		input  string
		ssl    bool
		host   string
		secure bool
	}{
		{"http://127.0.0.1:9000", true, "127.0.0.1:9000", false},
		{"https://storage.example.com", false, "storage.example.com", true},
		{"minio:9000", false, "minio:9000", false},
	}
	for _, test := range tests {
		host, secure, err := parseEndpoint(test.input, test.ssl)
		if err != nil || host != test.host || secure != test.secure {
			t.Fatalf("parseEndpoint(%q) = %q, %v, %v", test.input, host, secure, err)
		}
	}
}
