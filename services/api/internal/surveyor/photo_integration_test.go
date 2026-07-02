package surveyor

import (
	"bytes"
	"context"
	"image"
	"io"
	"os"
	"testing"
	"time"

	"container-survey/services/api/internal/objectstorage"
)

func TestMinIOPhotoRoundTrip(t *testing.T) {
	endpoint := os.Getenv("MINIO_TEST_ENDPOINT")
	if endpoint == "" {
		t.Skip("MINIO_TEST_ENDPOINT is not configured")
	}
	store, err := objectstorage.NewMinIO(objectstorage.MinIOOptions{
		Endpoint: endpoint, AccessKey: os.Getenv("MINIO_TEST_ACCESS_KEY"),
		SecretKey: os.Getenv("MINIO_TEST_SECRET_KEY"), Region: "us-east-1",
	})
	if err != nil {
		t.Fatal(err)
	}
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	bucket := "kontainer-stage3-integration"
	originalKey := "tests/photo-original.png"
	watermarkedKey := "tests/photo-watermarked.jpg"
	defer store.Remove(context.Background(), bucket, originalKey)
	defer store.Remove(context.Background(), bucket, watermarkedKey)

	original := testPNG(t)
	watermarked, err := watermarkImage(original, "Container: MSKU1234565\nSurvey: TEST-001\nDamage: D-001")
	if err != nil {
		t.Fatal(err)
	}
	if err := store.Put(ctx, bucket, originalKey, bytes.NewReader(original), int64(len(original)), objectstorage.PutOptions{ContentType: "image/png"}); err != nil {
		t.Fatal(err)
	}
	if err := store.Put(ctx, bucket, watermarkedKey, bytes.NewReader(watermarked), int64(len(watermarked)), objectstorage.PutOptions{ContentType: "image/jpeg"}); err != nil {
		t.Fatal(err)
	}

	readOriginal := readStoredObject(t, ctx, store, bucket, originalKey)
	if !bytes.Equal(readOriginal, original) {
		t.Fatal("downloaded original bytes differ from upload")
	}
	readWatermarked := readStoredObject(t, ctx, store, bucket, watermarkedKey)
	if _, format, err := image.Decode(bytes.NewReader(readWatermarked)); err != nil || format != "jpeg" {
		t.Fatalf("watermarked derivative is not a valid JPEG: %s, %v", format, err)
	}
}

func readStoredObject(t *testing.T, ctx context.Context, store objectstorage.Store, bucket, key string) []byte {
	t.Helper()
	reader, err := store.Get(ctx, bucket, key)
	if err != nil {
		t.Fatal(err)
	}
	defer reader.Close()
	data, err := io.ReadAll(reader)
	if err != nil {
		t.Fatal(err)
	}
	return data
}
