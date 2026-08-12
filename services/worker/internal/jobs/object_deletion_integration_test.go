package jobs

import (
	"bytes"
	"context"
	"database/sql"
	"os"
	"strings"
	"testing"
	"time"

	_ "github.com/go-sql-driver/mysql"
	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

func TestMinIODeletionRoundTrip(t *testing.T) {
	rawEndpoint := os.Getenv("MINIO_TEST_ENDPOINT")
	if rawEndpoint == "" {
		t.Skip("MINIO_TEST_ENDPOINT is not configured")
	}
	endpoint, secure, err := deletionEndpoint(rawEndpoint, false)
	if err != nil {
		t.Fatal(err)
	}
	client, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(os.Getenv("MINIO_TEST_ACCESS_KEY"), os.Getenv("MINIO_TEST_SECRET_KEY"), ""),
		Secure: secure,
		Region: "us-east-1",
	})
	if err != nil {
		t.Fatal(err)
	}
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	bucket := "kontainer-deletion-integration"
	if err := client.MakeBucket(ctx, bucket, minio.MakeBucketOptions{}); err != nil {
		response := minio.ToErrorResponse(err)
		if response.Code != "BucketAlreadyOwnedByYou" && response.Code != "BucketAlreadyExists" {
			t.Fatal(err)
		}
	}
	key := "tests/surveys/delete-me.txt"
	payload := []byte("object deletion integration")
	if _, err := client.PutObject(ctx, bucket, key, bytes.NewReader(payload), int64(len(payload)), minio.PutObjectOptions{ContentType: "text/plain"}); err != nil {
		t.Fatal(err)
	}
	queue := &fakeDeletionQueue{
		records:   []DeletionRecord{{ID: "minio-round-trip", BucketName: bucket, ObjectKey: key}},
		canDelete: true,
	}
	processor := &ObjectDeletionProcessor{
		queue:        queue,
		store:        minioDeletionStore{client: client},
		logger:       testProcessor(queue, &fakeDeletionStore{}).logger,
		workerID:     "minio-test",
		bucket:       bucket,
		objectPrefix: "tests",
		batchSize:    1,
		lockTTL:      time.Minute,
		now:          time.Now,
	}
	result, err := processor.ProcessBatch(ctx)
	if err != nil || result.Processed != 1 || queue.processed != 1 {
		t.Fatalf("processor did not delete object: result=%+v err=%v", result, err)
	}
	if _, err := client.StatObject(ctx, bucket, key, minio.StatObjectOptions{}); err == nil {
		t.Fatal("object still exists after deletion")
	}
}

func TestMySQLDeletionQueueRoundTrip(t *testing.T) {
	dsn := os.Getenv("WORKER_TEST_DSN")
	if dsn == "" {
		t.Skip("WORKER_TEST_DSN is not configured")
	}
	lowerDSN := strings.ToLower(dsn)
	if !strings.Contains(lowerDSN, "test") && !strings.Contains(lowerDSN, "_uat") {
		t.Fatalf("WORKER_TEST_DSN must point to a test or _uat database: %q", dsn)
	}
	db, err := sql.Open("mysql", dsn)
	if err != nil {
		t.Fatal(err)
	}
	defer db.Close()
	ctx, cancel := context.WithTimeout(context.Background(), 15*time.Second)
	defer cancel()
	id := "00000000-0000-0000-0000-000000000018"
	if _, err := db.ExecContext(ctx, `DELETE FROM object_deletion_queue WHERE id=?`, id); err != nil {
		t.Fatal(err)
	}
	defer db.ExecContext(context.Background(), `DELETE FROM object_deletion_queue WHERE id=?`, id)
	if _, err := db.ExecContext(ctx, `
		INSERT INTO object_deletion_queue (id,bucket_name,object_key,reason,eligible_after,status)
		VALUES (?,?,?,'integration_test',DATE_SUB(NOW(6), INTERVAL 1 SECOND),'pending')
	`, id, "kontainer-test", "tests/surveys/mysql.txt"); err != nil {
		t.Fatal(err)
	}
	queue := sqlDeletionQueue{db: db}
	records, err := queue.Claim(ctx, "worker-integration", 1, time.Minute)
	if err != nil || len(records) != 1 || records[0].ID != id {
		t.Fatalf("claim failed records=%+v err=%v", records, err)
	}
	canDelete, active, err := queue.CanDelete(ctx, records[0], "worker-integration")
	if err != nil || !canDelete || active {
		t.Fatalf("eligibility failed canDelete=%v active=%v err=%v", canDelete, active, err)
	}
	if err := queue.MarkProcessed(ctx, records[0], "worker-integration"); err != nil {
		t.Fatal(err)
	}
	var status string
	if err := db.QueryRowContext(ctx, `SELECT status FROM object_deletion_queue WHERE id=?`, id).Scan(&status); err != nil || status != "processed" {
		t.Fatalf("processed status=%q err=%v", status, err)
	}
}
