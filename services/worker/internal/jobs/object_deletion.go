package jobs

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"log/slog"
	"net/url"
	"os"
	"strings"
	"time"

	"container-survey/services/worker/internal/config"
	_ "github.com/go-sql-driver/mysql"
	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

type DeletionRecord struct {
	ID         string
	BucketName string
	ObjectKey  string
	RetryCount int
}

type deletionQueue interface {
	Claim(context.Context, string, int, time.Duration) ([]DeletionRecord, error)
	CanDelete(context.Context, DeletionRecord, string) (bool, bool, error)
	MarkProcessed(context.Context, DeletionRecord, string) error
	MarkCancelled(context.Context, DeletionRecord, string, string) error
	MarkFailed(context.Context, DeletionRecord, string, error, time.Time) error
}

type deletionObjectStore interface {
	Remove(context.Context, string, string) error
}

type ObjectDeletionProcessor struct {
	queue        deletionQueue
	store        deletionObjectStore
	logger       *slog.Logger
	workerID     string
	bucket       string
	objectPrefix string
	batchSize    int
	lockTTL      time.Duration
	now          func() time.Time
}

type DeletionBatchResult struct {
	Claimed   int
	Processed int
	Cancelled int
	Failed    int
}

func (p *ObjectDeletionProcessor) ProcessBatch(ctx context.Context) (DeletionBatchResult, error) {
	records, err := p.queue.Claim(ctx, p.workerID, p.batchSize, p.lockTTL)
	if err != nil {
		return DeletionBatchResult{}, err
	}
	result := DeletionBatchResult{Claimed: len(records)}
	for _, record := range records {
		if err := p.processRecord(ctx, record); err != nil {
			result.Failed++
			continue
		}
		canDelete, activeReference, err := p.queue.CanDelete(ctx, record, p.workerID)
		if err != nil {
			retryAt := p.now().UTC().Add(retryDelay(record.RetryCount + 1))
			_ = p.queue.MarkFailed(ctx, record, p.workerID, err, retryAt)
			result.Failed++
			continue
		}
		if !canDelete {
			continue
		}
		if activeReference {
			if err := p.queue.MarkCancelled(ctx, record, p.workerID, "object masih dipakai foto/file aktif"); err != nil {
				result.Failed++
				continue
			}
			result.Cancelled++
			continue
		}
		if err := p.store.Remove(ctx, record.BucketName, record.ObjectKey); err != nil {
			retryAt := p.now().UTC().Add(retryDelay(record.RetryCount + 1))
			_ = p.queue.MarkFailed(ctx, record, p.workerID, err, retryAt)
			result.Failed++
			continue
		}
		if err := p.queue.MarkProcessed(ctx, record, p.workerID); err != nil {
			result.Failed++
			continue
		}
		result.Processed++
	}
	return result, nil
}

func (p *ObjectDeletionProcessor) processRecord(ctx context.Context, record DeletionRecord) error {
	if err := validateDeletionTarget(record.BucketName, record.ObjectKey, p.bucket, p.objectPrefix); err != nil {
		retryAt := p.now().UTC().Add(retryDelay(record.RetryCount + 1))
		_ = p.queue.MarkFailed(ctx, record, p.workerID, err, retryAt)
		return err
	}
	return nil
}

func (p *ObjectDeletionProcessor) ProcessAndLog(ctx context.Context) {
	result, err := p.ProcessBatch(ctx)
	if err != nil {
		p.logger.Error("object deletion queue batch failed", "error", err)
		return
	}
	if result.Claimed > 0 {
		p.logger.Info("object deletion queue batch processed", "claimed", result.Claimed, "processed", result.Processed, "cancelled", result.Cancelled, "failed", result.Failed)
	}
}

func retryDelay(attempt int) time.Duration {
	if attempt < 1 {
		attempt = 1
	}
	if attempt > 8 {
		attempt = 8
	}
	return time.Duration(1<<(attempt-1)) * time.Minute
}

func validateDeletionTarget(bucket, objectKey, configuredBucket, configuredPrefix string) error {
	key := strings.TrimSpace(objectKey)
	if strings.TrimSpace(bucket) == "" || bucket != configuredBucket {
		return errors.New("bucket object tidak sesuai konfigurasi aplikasi")
	}
	if key == "" || strings.HasPrefix(key, "/") || strings.Contains(key, "\\") || strings.Contains(key, "../") || strings.Contains(key, "/..") {
		return errors.New("object key tidak aman")
	}
	prefix := strings.Trim(configuredPrefix, "/")
	if prefix == "" {
		prefix = "surveys"
	}
	if key != prefix && !strings.HasPrefix(key, prefix+"/") {
		return errors.New("object key berada di luar prefix aplikasi")
	}
	return nil
}

type sqlDeletionQueue struct{ db *sql.DB }

func (q sqlDeletionQueue) Claim(ctx context.Context, workerID string, batchSize int, lockTTL time.Duration) ([]DeletionRecord, error) {
	if batchSize < 1 {
		batchSize = 25
	}
	lockSeconds := int(lockTTL.Seconds())
	if lockSeconds < 30 {
		lockSeconds = 300
	}
	tx, err := q.db.BeginTx(ctx, nil)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback()
	rows, err := tx.QueryContext(ctx, `
		SELECT id,bucket_name,object_key,retry_count
		FROM object_deletion_queue
		WHERE status IN ('pending','failed')
		  AND eligible_after<=NOW(6)
		  AND (next_retry_at IS NULL OR next_retry_at<=NOW(6))
		  AND (locked_at IS NULL OR locked_at<DATE_SUB(NOW(6), INTERVAL ? SECOND))
		ORDER BY eligible_after,id
		LIMIT ? FOR UPDATE SKIP LOCKED
	`, lockSeconds, batchSize)
	if err != nil {
		return nil, err
	}
	records := []DeletionRecord{}
	for rows.Next() {
		var record DeletionRecord
		if err := rows.Scan(&record.ID, &record.BucketName, &record.ObjectKey, &record.RetryCount); err != nil {
			rows.Close()
			return nil, err
		}
		records = append(records, record)
	}
	if err := rows.Close(); err != nil {
		return nil, err
	}
	for _, record := range records {
		if _, err := tx.ExecContext(ctx, `UPDATE object_deletion_queue SET locked_at=NOW(6),locked_by=?,last_attempt_at=NOW(6) WHERE id=?`, workerID, record.ID); err != nil {
			return nil, err
		}
	}
	if err := tx.Commit(); err != nil {
		return nil, err
	}
	return records, nil
}

func (q sqlDeletionQueue) CanDelete(ctx context.Context, record DeletionRecord, workerID string) (bool, bool, error) {
	var claimed, activeReference int
	err := q.db.QueryRowContext(ctx, `
		SELECT
		  EXISTS(SELECT 1 FROM object_deletion_queue queue WHERE queue.id=? AND queue.status IN ('pending','failed') AND queue.locked_by=?),
		  EXISTS(SELECT 1 FROM file_objects file WHERE file.bucket_name=? AND file.object_key=? AND file.deleted_at IS NULL)
	`, record.ID, workerID, record.BucketName, record.ObjectKey).Scan(&claimed, &activeReference)
	return claimed == 1, activeReference == 1, err
}

func (q sqlDeletionQueue) MarkProcessed(ctx context.Context, record DeletionRecord, workerID string) error {
	_, err := q.db.ExecContext(ctx, `
		UPDATE object_deletion_queue
		SET status='processed',processed_at=NOW(6),error_message=NULL,next_retry_at=NULL,locked_at=NULL,locked_by=NULL
		WHERE id=? AND status IN ('pending','failed') AND locked_by=?
	`, record.ID, workerID)
	return err
}

func (q sqlDeletionQueue) MarkCancelled(ctx context.Context, record DeletionRecord, workerID, reason string) error {
	_, err := q.db.ExecContext(ctx, `
		UPDATE object_deletion_queue
		SET status='cancelled',error_message=?,next_retry_at=NULL,locked_at=NULL,locked_by=NULL
		WHERE id=? AND status IN ('pending','failed') AND locked_by=?
	`, reason, record.ID, workerID)
	return err
}

func (q sqlDeletionQueue) MarkFailed(ctx context.Context, record DeletionRecord, workerID string, processErr error, retryAt time.Time) error {
	message := processErr.Error()
	if len(message) > 4000 {
		message = message[:4000]
	}
	_, err := q.db.ExecContext(ctx, `
		UPDATE object_deletion_queue
		SET status='failed',retry_count=retry_count+1,error_message=?,next_retry_at=?,locked_at=NULL,locked_by=NULL
		WHERE id=? AND status IN ('pending','failed') AND locked_by=?
	`, message, retryAt, record.ID, workerID)
	return err
}

type minioDeletionStore struct{ client *minio.Client }

func (s minioDeletionStore) Remove(ctx context.Context, bucket, objectKey string) error {
	if err := s.client.RemoveObject(ctx, bucket, objectKey, minio.RemoveObjectOptions{}); err != nil {
		return fmt.Errorf("hapus object %s: %w", objectKey, err)
	}
	return nil
}

func NewObjectDeletionProcessor(cfg config.Config, logger *slog.Logger) (*ObjectDeletionProcessor, func(), error) {
	if strings.TrimSpace(cfg.DatabaseURL) == "" {
		return nil, nil, errors.New("DATABASE_URL is required for object deletion worker")
	}
	db, err := sql.Open("mysql", cfg.DatabaseURL)
	if err != nil {
		return nil, nil, fmt.Errorf("open worker database: %w", err)
	}
	db.SetMaxOpenConns(4)
	db.SetMaxIdleConns(1)
	db.SetConnMaxLifetime(time.Hour)
	pingCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := db.PingContext(pingCtx); err != nil {
		db.Close()
		return nil, nil, fmt.Errorf("ping worker database: %w", err)
	}
	endpoint, secure, err := deletionEndpoint(cfg.S3Endpoint, cfg.S3UseSSL)
	if err != nil {
		db.Close()
		return nil, nil, err
	}
	client, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(cfg.S3AccessKey, cfg.S3SecretKey, ""),
		Secure: secure,
		Region: cfg.S3Region,
	})
	if err != nil {
		db.Close()
		return nil, nil, fmt.Errorf("create worker object storage client: %w", err)
	}
	workerID := strings.TrimSpace(cfg.WorkerID)
	if workerID == "" {
		hostname, _ := os.Hostname()
		workerID = fmt.Sprintf("%s-%d", hostname, os.Getpid())
	}
	batchSize := cfg.ObjectDeletionBatchSize
	if batchSize < 1 {
		batchSize = 25
	}
	processor := &ObjectDeletionProcessor{
		queue: sqlDeletionQueue{db: db}, store: minioDeletionStore{client: client}, logger: logger,
		workerID: workerID, bucket: cfg.S3Bucket, objectPrefix: cfg.S3ObjectPrefix,
		batchSize: batchSize, lockTTL: cfg.ObjectDeletionLockTTL, now: time.Now,
	}
	return processor, func() { _ = db.Close() }, nil
}

func deletionEndpoint(raw string, useSSL bool) (string, bool, error) {
	value := strings.TrimSpace(raw)
	if value == "" {
		return "", false, errors.New("S3_ENDPOINT is required")
	}
	if !strings.Contains(value, "://") {
		return strings.TrimSuffix(value, "/"), useSSL, nil
	}
	parsed, err := url.Parse(value)
	if err != nil || parsed.Host == "" {
		return "", false, fmt.Errorf("invalid S3 endpoint %q", raw)
	}
	return parsed.Host, parsed.Scheme == "https", nil
}
