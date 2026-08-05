package surveyor

import (
	"bytes"
	"context"
	"errors"
	"image"
	"image/color"
	"image/png"
	"strings"
	"testing"
	"time"

	"github.com/google/uuid"

	"container-survey/services/api/internal/database"
)

func TestReadPhotoAndWatermark(t *testing.T) {
	imageData := testPNG(t)
	original, contentType, err := readPhoto(bytes.NewReader(imageData), int64(len(imageData)+10))
	if err != nil || contentType != "image/png" {
		t.Fatalf("readPhoto() = %s, %v", contentType, err)
	}
	latitude, longitude := -6.2, 106.8
	text := buildWatermarkText(PhotoContext{
		ContainerNo: "MSKU1234565", SurveyNo: "GIFT-SVY-2026-000001", DamageNo: "D-001",
		SurveyorName: "Surveyor Demo", GPSLatitude: &latitude, GPSLongitude: &longitude,
	}, "damage_overview", time.Date(2026, 7, 1, 10, 30, 0, 0, time.UTC))
	if !strings.Contains(text, "MSKU1234565") || !strings.Contains(text, "GPS: -6.2000000, 106.8000000") {
		t.Fatalf("watermark text is incomplete: %s", text)
	}
	watermarked, err := watermarkImage(original, text)
	if err != nil {
		t.Fatal(err)
	}
	_, format, err := image.Decode(bytes.NewReader(watermarked))
	if err != nil || format != "jpeg" {
		t.Fatalf("watermarked output = %s, %v", format, err)
	}
}

func TestReadPhotoRejectsInvalidAndOversizedFiles(t *testing.T) {
	if _, _, err := readPhoto(strings.NewReader("not an image"), 1024); !errors.Is(err, ErrInvalidInput) {
		t.Fatal("expected non-image content to fail")
	}
	imageData := testPNG(t)
	if _, _, err := readPhoto(bytes.NewReader(imageData), int64(len(imageData)-1)); !errors.Is(err, ErrInvalidInput) {
		t.Fatal("expected oversized image to fail")
	}
}

func TestGeneralSurveyPhotoWatermark(t *testing.T) {
	text := buildWatermarkText(PhotoContext{
		ContainerNo: "MSKU1234565", SurveyNo: "GIFT-SVY-2026-000001", DamageNo: "General Evidence",
		SurveyorName: "Surveyor Demo",
	}, "general", time.Date(2026, 8, 4, 9, 15, 0, 0, time.UTC))
	if !strings.Contains(text, "Damage: General Evidence") || !strings.Contains(text, "Surveyor: Surveyor Demo") {
		t.Fatalf("general photo watermark is incomplete: %s", text)
	}
}

func TestObjectKeyPrefixIsOptionalAndNormalized(t *testing.T) {
	withoutPrefix := NewService(Repository{}, nil, "bucket", 1024)
	if got := withoutPrefix.objectKey("surveys/id/photo.jpg"); got != "surveys/id/photo.jpg" {
		t.Fatalf("default object key changed: %s", got)
	}
	withPrefix := NewService(Repository{}, nil, "bucket", 1024, "/uat/UAT-REAL-CASE-2026-08/")
	if got := withPrefix.objectKey("/surveys/id/photo.jpg"); got != "uat/UAT-REAL-CASE-2026-08/surveys/id/photo.jpg" {
		t.Fatalf("prefixed object key = %s", got)
	}
}

func TestPhotoCategoryScopeMismatchHasSpecificContext(t *testing.T) {
	err := validatePhotoCategoryQuery(context.Background(), photoCategoryQuery{appliesTo: "finding"}, uuid.New(), uuid.New(), "damage_finding", "inspection")
	validation, ok := err.(SurveyValidationError)
	if !ok || len(validation.Warnings) != 1 || validation.Warnings[0].Code != "PHOTO_CATEGORY_APPLIES_TO" {
		t.Fatalf("unexpected scope mismatch: %#v", err)
	}
	if err := validatePhotoCategoryQuery(context.Background(), photoCategoryQuery{appliesTo: "inspection"}, uuid.New(), uuid.New(), "general_container", "inspection"); err != nil {
		t.Fatalf("matching scope rejected: %v", err)
	}
}

type photoCategoryQuery struct {
	appliesTo string
	err       error
}

func (query photoCategoryQuery) QueryRow(context.Context, string, ...any) database.Row {
	return photoCategoryRow{appliesTo: query.appliesTo, err: query.err}
}

type photoCategoryRow struct {
	appliesTo string
	err       error
}

func (row photoCategoryRow) Scan(dest ...any) error {
	if row.err != nil {
		return row.err
	}
	*(dest[0].(*string)) = "category"
	*(dest[1].(*string)) = row.appliesTo
	return nil
}

func testPNG(t *testing.T) []byte {
	t.Helper()
	canvas := image.NewRGBA(image.Rect(0, 0, 320, 240))
	for y := 0; y < 240; y++ {
		for x := 0; x < 320; x++ {
			canvas.Set(x, y, color.RGBA{R: 80, G: 140, B: 190, A: 255})
		}
	}
	var output bytes.Buffer
	if err := png.Encode(&output, canvas); err != nil {
		t.Fatal(err)
	}
	return output.Bytes()
}
