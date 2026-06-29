package main

import (
	"context"
	"log/slog"
	"os"
	"os/signal"
	"syscall"
	"time"

	"container-survey/services/worker/internal/config"
	"container-survey/services/worker/internal/jobs"
)

func main() {
	cfg := config.Load()
	logger := slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: cfg.LogLevel(),
	}))

	runner := jobs.NewRunner(cfg, logger)
	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer cancel()

	logger.Info("worker starting", "env", cfg.Environment)
	if err := runner.Run(ctx); err != nil {
		logger.Error("worker failed", "error", err)
		os.Exit(1)
	}

	logger.Info("worker stopped")
}
