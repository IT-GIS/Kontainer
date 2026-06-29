package config

import (
	"log/slog"
	"os"
	"strconv"
	"strings"
	"time"
)

type Config struct {
	Environment       string
	AppName           string
	Port              string
	DatabaseURL       string
	RedisAddr         string
	AccessSecret      string
	RefreshSecret     string
	AccessTTL         time.Duration
	RefreshTTL        time.Duration
	S3Endpoint        string
	S3Bucket          string
	MaxUploadBytes    int64
	WorkerEnabled     bool
	AllowedWebOrigins []string
}

func Load() Config {
	loadDotEnv()
	return Config{
		Environment:       getenv("APP_ENV", "development"),
		AppName:           getenv("APP_NAME", "gift-survey-api"),
		Port:              getenv("APP_PORT", "8080"),
		DatabaseURL:       getenv("DATABASE_URL", ""),
		RedisAddr:         getenv("REDIS_ADDR", "localhost:6379"),
		AccessSecret:      getenv("JWT_ACCESS_SECRET", "change_me_access_secret"),
		RefreshSecret:     getenv("JWT_REFRESH_SECRET", "change_me_refresh_secret"),
		AccessTTL:         time.Duration(getenvInt("JWT_ACCESS_TTL_MINUTES", 60)) * time.Minute,
		RefreshTTL:        time.Duration(getenvInt("JWT_REFRESH_TTL_DAYS", 14)) * 24 * time.Hour,
		S3Endpoint:        getenv("S3_ENDPOINT", "http://localhost:9000"),
		S3Bucket:          getenv("S3_BUCKET", "gift-survey"),
		MaxUploadBytes:    int64(getenvInt("MAX_UPLOAD_MB", 10)) * 1024 * 1024,
		WorkerEnabled:     getenvBool("WORKER_ENABLED", true),
		AllowedWebOrigins: splitCSV(getenv("WEB_ALLOWED_ORIGINS", "http://localhost:3000")),
	}
}

func loadDotEnv() {
	for _, path := range []string{".env", "../../.env"} {
		contents, err := os.ReadFile(path)
		if err != nil {
			continue
		}
		for _, line := range strings.Split(string(contents), "\n") {
			line = strings.TrimSpace(line)
			if line == "" || strings.HasPrefix(line, "#") {
				continue
			}
			key, value, found := strings.Cut(line, "=")
			if !found || os.Getenv(strings.TrimSpace(key)) != "" {
				continue
			}
			value = strings.Trim(strings.TrimSpace(value), "\"'")
			_ = os.Setenv(strings.TrimSpace(key), value)
		}
		return
	}
}

func (c Config) LogLevel() slog.Level {
	if strings.EqualFold(c.Environment, "development") {
		return slog.LevelDebug
	}

	return slog.LevelInfo
}

func getenv(key string, fallback string) string {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}
	return value
}

func getenvInt(key string, fallback int) int {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}

	parsed, err := strconv.Atoi(value)
	if err != nil {
		return fallback
	}
	return parsed
}

func getenvBool(key string, fallback bool) bool {
	value := os.Getenv(key)
	if value == "" {
		return fallback
	}

	parsed, err := strconv.ParseBool(value)
	if err != nil {
		return fallback
	}
	return parsed
}

func splitCSV(value string) []string {
	parts := strings.Split(value, ",")
	result := make([]string, 0, len(parts))
	for _, part := range parts {
		trimmed := strings.TrimSpace(part)
		if trimmed != "" {
			result = append(result, trimmed)
		}
	}
	return result
}
