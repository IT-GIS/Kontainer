package jobs

import (
	"context"
	"errors"
	"io"
	"log/slog"
	"testing"
	"time"
)

type fakeDeletionQueue struct {
	records     []DeletionRecord
	canDelete   bool
	active      bool
	processed   int
	cancelled   int
	failed      int
	lastRetryAt time.Time
}

func (q *fakeDeletionQueue) Claim(context.Context, string, int, time.Duration) ([]DeletionRecord, error) {
	return q.records, nil
}
func (q *fakeDeletionQueue) CanDelete(context.Context, DeletionRecord, string) (bool, bool, error) {
	return q.canDelete, q.active, nil
}
func (q *fakeDeletionQueue) MarkProcessed(context.Context, DeletionRecord, string) error {
	q.processed++
	return nil
}
func (q *fakeDeletionQueue) MarkCancelled(context.Context, DeletionRecord, string, string) error {
	q.cancelled++
	return nil
}
func (q *fakeDeletionQueue) MarkFailed(_ context.Context, _ DeletionRecord, _ string, _ error, retryAt time.Time) error {
	q.failed++
	q.lastRetryAt = retryAt
	return nil
}

type fakeDeletionStore struct {
	err     error
	removed int
}

func (s *fakeDeletionStore) Remove(context.Context, string, string) error {
	s.removed++
	return s.err
}

func testProcessor(queue *fakeDeletionQueue, store *fakeDeletionStore) *ObjectDeletionProcessor {
	return &ObjectDeletionProcessor{
		queue: queue, store: store, logger: slog.New(slog.NewTextHandler(io.Discard, nil)),
		workerID: "worker-test", bucket: "gift-survey", objectPrefix: "uat/UAT",
		batchSize: 10, lockTTL: time.Minute, now: func() time.Time { return time.Date(2026, 8, 6, 10, 0, 0, 0, time.UTC) },
	}
}

func TestObjectDeletionProcessorProcessesEligibleObject(t *testing.T) {
	queue := &fakeDeletionQueue{records: []DeletionRecord{{ID: "q1", BucketName: "gift-survey", ObjectKey: "uat/UAT/surveys/a/original.jpg"}}, canDelete: true}
	store := &fakeDeletionStore{}
	result, err := testProcessor(queue, store).ProcessBatch(context.Background())
	if err != nil || result.Processed != 1 || queue.processed != 1 || store.removed != 1 {
		t.Fatalf("unexpected result=%+v processed=%d removed=%d err=%v", result, queue.processed, store.removed, err)
	}
}

func TestObjectDeletionProcessorCancelsActiveReference(t *testing.T) {
	queue := &fakeDeletionQueue{records: []DeletionRecord{{ID: "q1", BucketName: "gift-survey", ObjectKey: "uat/UAT/surveys/a/original.jpg"}}, canDelete: true, active: true}
	store := &fakeDeletionStore{}
	result, err := testProcessor(queue, store).ProcessBatch(context.Background())
	if err != nil || result.Cancelled != 1 || queue.cancelled != 1 || store.removed != 0 {
		t.Fatalf("active reference was not cancelled safely: %+v", result)
	}
}

func TestObjectDeletionProcessorStoresFailureAndRetry(t *testing.T) {
	now := time.Date(2026, 8, 6, 10, 0, 0, 0, time.UTC)
	queue := &fakeDeletionQueue{records: []DeletionRecord{{ID: "q1", BucketName: "gift-survey", ObjectKey: "uat/UAT/surveys/a/original.jpg", RetryCount: 2}}, canDelete: true}
	store := &fakeDeletionStore{err: errors.New("storage unavailable")}
	result, err := testProcessor(queue, store).ProcessBatch(context.Background())
	if err != nil || result.Failed != 1 || queue.failed != 1 || !queue.lastRetryAt.Equal(now.Add(4*time.Minute)) {
		t.Fatalf("retry was not recorded: result=%+v retry=%s err=%v", result, queue.lastRetryAt, err)
	}
}

func TestValidateDeletionTargetRejectsOutsideApplicationScope(t *testing.T) {
	for _, tc := range []struct{ bucket, key string }{
		{"other", "uat/UAT/surveys/a.jpg"},
		{"gift-survey", "other/a.jpg"},
		{"gift-survey", "uat/UAT/../secret"},
		{"gift-survey", "/uat/UAT/surveys/a.jpg"},
	} {
		if err := validateDeletionTarget(tc.bucket, tc.key, "gift-survey", "uat/UAT"); err == nil {
			t.Fatalf("unsafe target accepted: %#v", tc)
		}
	}
	if err := validateDeletionTarget("gift-survey", "surveys/a.jpg", "gift-survey", ""); err != nil {
		t.Fatalf("default application prefix rejected: %v", err)
	}
}
