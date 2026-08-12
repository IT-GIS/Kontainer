package jobs

import (
	"context"
	"log/slog"
	"time"

	"container-survey/services/worker/internal/config"
)

type Runner struct {
	cfg    config.Config
	logger *slog.Logger
}

func NewRunner(cfg config.Config, logger *slog.Logger) Runner {
	return Runner{cfg: cfg, logger: logger}
}

func (r Runner) Run(ctx context.Context) error {
	processor, closeResources, err := NewObjectDeletionProcessor(r.cfg, r.logger)
	if err != nil {
		return err
	}
	defer closeResources()

	interval := r.cfg.ObjectDeletionInterval
	if interval <= 0 {
		interval = 30 * time.Second
	}
	ticker := time.NewTicker(interval)
	defer ticker.Stop()

	r.logger.Info(
		"worker ready",
		"redis_addr", r.cfg.RedisAddr,
		"s3_endpoint", r.cfg.S3Endpoint,
		"s3_bucket", r.cfg.S3Bucket,
	)
	processor.ProcessAndLog(ctx)

	for {
		select {
		case <-ctx.Done():
			return nil
		case <-ticker.C:
			processor.ProcessAndLog(ctx)
		}
	}
}
