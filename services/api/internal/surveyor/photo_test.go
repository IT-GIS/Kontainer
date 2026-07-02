package surveyor

import (
	"bytes"
	"errors"
	"image"
	"image/color"
	"image/png"
	"strings"
	"testing"
	"time"
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
	}, time.Date(2026, 7, 1, 10, 30, 0, 0, time.UTC))
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
