package config

import (
	"log/slog"
	"os"
	"strconv"
	"strings"
	"time"
)

type Config struct {
	Environment             string
	DatabaseURL             string
	RedisAddr               string
	S3Endpoint              string
	S3AccessKey             string
	S3SecretKey             string
	S3Bucket                string
	S3ObjectPrefix          string
	S3Region                string
	S3UseSSL                bool
	ObjectDeletionInterval  time.Duration
	ObjectDeletionBatchSize int
	ObjectDeletionLockTTL   time.Duration
	WorkerID                string
	PDFRenderTimeout        time.Duration
	ImageProcessingEnabled  bool
	NotificationQueueEnable bool
}

func Load() Config {
	return Config{
		Environment:             getenv("APP_ENV", "development"),
		DatabaseURL:             getenv("DATABASE_URL", ""),
		RedisAddr:               getenv("REDIS_ADDR", "localhost:6379"),
		S3Endpoint:              getenv("S3_ENDPOINT", "http://localhost:9000"),
		S3AccessKey:             getenv("S3_ACCESS_KEY", "minioadmin"),
		S3SecretKey:             getenv("S3_SECRET_KEY", "minioadmin"),
		S3Bucket:                getenv("S3_BUCKET", "gift-survey"),
		S3ObjectPrefix:          strings.Trim(getenv("S3_OBJECT_PREFIX", ""), "/"),
		S3Region:                getenv("S3_REGION", "us-east-1"),
		S3UseSSL:                getenvBool("S3_USE_SSL", false),
		ObjectDeletionInterval:  time.Duration(getenvInt("OBJECT_DELETION_INTERVAL_SECONDS", 30)) * time.Second,
		ObjectDeletionBatchSize: getenvInt("OBJECT_DELETION_BATCH_SIZE", 25),
		ObjectDeletionLockTTL:   time.Duration(getenvInt("OBJECT_DELETION_LOCK_TTL_SECONDS", 300)) * time.Second,
		WorkerID:                getenv("WORKER_ID", ""),
		PDFRenderTimeout:        time.Duration(getenvInt("PDF_RENDER_TIMEOUT_SECONDS", 120)) * time.Second,
		ImageProcessingEnabled:  getenvBool("IMAGE_PROCESSING_ENABLED", true),
		NotificationQueueEnable: getenvBool("NOTIFICATION_QUEUE_ENABLED", true),
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
