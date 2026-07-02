package surveyor

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"image"
	"image/color"
	"image/draw"
	"image/jpeg"
	_ "image/png"
	"io"
	"net/http"
	"path"
	"strings"
	"time"

	"github.com/google/uuid"
	"golang.org/x/image/font"
	"golang.org/x/image/font/basicfont"
	"golang.org/x/image/math/fixed"
	_ "golang.org/x/image/webp"

	"container-survey/services/api/internal/objectstorage"
)

var supportedPhotoTypes = map[string]string{
	"image/jpeg": ".jpg",
	"image/png":  ".png",
	"image/webp": ".webp",
}

const maxPhotoPixels int64 = 40_000_000

type PhotoContext struct {
	SurveyID     uuid.UUID
	SurveyNo     string
	ContainerNo  string
	DamageNo     string
	SurveyorName string
	GPSLatitude  *float64
	GPSLongitude *float64
}

type StoredFile struct {
	Bucket      string
	ObjectKey   string
	FileName    string
	ContentType string
	Size        int64
	Checksum    string
}

type PhotoRecordInput struct {
	Original      StoredFile
	Watermarked   StoredFile
	Caption       string
	PhotoType     string
	PhotoCategory string
	TakenAt       time.Time
	GPSLatitude   *float64
	GPSLongitude  *float64
	WatermarkText string
}

type PhotoFile struct {
	Bucket      string
	ObjectKey   string
	FileName    string
	ContentType string
	Size        int64
}

type PhotoContent struct {
	PhotoFile
	Reader io.ReadCloser
}

func (s *Service) uploadPhoto(ctx context.Context, damageID uuid.UUID, input PhotoInput, actor Actor) (map[string]any, error) {
	original, contentType, err := readPhoto(input.Reader, s.maxUploadBytes)
	if err != nil {
		return nil, err
	}
	photoContext, err := s.repo.PhotoContext(ctx, damageID, actor)
	if err != nil {
		return nil, err
	}
	takenAt := time.Now().UTC()
	if input.TakenAt != nil {
		takenAt = input.TakenAt.UTC()
	}
	watermarkText := buildWatermarkText(photoContext, takenAt)
	watermarked, err := watermarkImage(original, watermarkText)
	if err != nil {
		return nil, ErrInvalidInput
	}

	objectID := uuid.NewString()
	originalExtension := supportedPhotoTypes[contentType]
	originalKey := fmt.Sprintf("surveys/%s/photos/original/%s%s", photoContext.SurveyID, objectID, originalExtension)
	watermarkedKey := fmt.Sprintf("surveys/%s/photos/watermarked/%s.jpg", photoContext.SurveyID, objectID)
	baseName := strings.TrimSuffix(sanitizeFileName(input.FileName), path.Ext(input.FileName))
	if baseName == "" {
		baseName = "photo"
	}
	originalFile := StoredFile{
		Bucket: s.bucket, ObjectKey: originalKey, FileName: baseName + originalExtension,
		ContentType: contentType, Size: int64(len(original)), Checksum: checksum(original),
	}
	watermarkedFile := StoredFile{
		Bucket: s.bucket, ObjectKey: watermarkedKey, FileName: baseName + "-watermarked.jpg",
		ContentType: "image/jpeg", Size: int64(len(watermarked)), Checksum: checksum(watermarked),
	}

	if err := s.store.Put(ctx, s.bucket, originalKey, bytes.NewReader(original), int64(len(original)), objectstorage.PutOptions{ContentType: contentType, Metadata: map[string]string{"variant": "original"}}); err != nil {
		return nil, err
	}
	if err := s.store.Put(ctx, s.bucket, watermarkedKey, bytes.NewReader(watermarked), int64(len(watermarked)), objectstorage.PutOptions{ContentType: "image/jpeg", Metadata: map[string]string{"variant": "watermarked"}}); err != nil {
		s.cleanupObjects(originalKey)
		return nil, err
	}

	item, err := s.repo.CreatePhotoMetadata(ctx, damageID, PhotoRecordInput{
		Original: originalFile, Watermarked: watermarkedFile, Caption: input.Caption,
		PhotoType: input.PhotoType, PhotoCategory: input.PhotoCategory, TakenAt: takenAt,
		GPSLatitude: photoContext.GPSLatitude, GPSLongitude: photoContext.GPSLongitude,
		WatermarkText: watermarkText,
	}, actor)
	if err != nil {
		s.cleanupObjects(originalKey, watermarkedKey)
		return nil, err
	}
	return item, nil
}

func (s *Service) photoContent(ctx context.Context, photoID uuid.UUID, variant string, actor Actor) (PhotoContent, error) {
	file, err := s.repo.PhotoFile(ctx, photoID, variant, actor)
	if err != nil {
		return PhotoContent{}, err
	}
	reader, err := s.store.Get(ctx, file.Bucket, file.ObjectKey)
	if err != nil {
		return PhotoContent{}, err
	}
	return PhotoContent{PhotoFile: file, Reader: reader}, nil
}

func (s *Service) cleanupObjects(keys ...string) {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	for _, key := range keys {
		_ = s.store.Remove(ctx, s.bucket, key)
	}
}

func readPhoto(reader io.Reader, maxBytes int64) ([]byte, string, error) {
	if reader == nil || maxBytes <= 0 {
		return nil, "", ErrInvalidInput
	}
	data, err := io.ReadAll(io.LimitReader(reader, maxBytes+1))
	if err != nil || len(data) == 0 || int64(len(data)) > maxBytes {
		return nil, "", ErrInvalidInput
	}
	contentType := http.DetectContentType(data)
	if _, supported := supportedPhotoTypes[contentType]; !supported {
		return nil, "", ErrInvalidInput
	}
	configuration, _, err := image.DecodeConfig(bytes.NewReader(data))
	if err != nil || configuration.Width <= 0 || configuration.Height <= 0 || int64(configuration.Width)*int64(configuration.Height) > maxPhotoPixels {
		return nil, "", ErrInvalidInput
	}
	return data, contentType, nil
}

func watermarkImage(source []byte, watermarkText string) ([]byte, error) {
	decoded, _, err := image.Decode(bytes.NewReader(source))
	if err != nil {
		return nil, err
	}
	bounds := decoded.Bounds()
	canvas := image.NewRGBA(bounds)
	draw.Draw(canvas, bounds, decoded, bounds.Min, draw.Src)
	lines := strings.Split(watermarkText, "\n")
	bandHeight := len(lines)*16 + 16
	if bandHeight > bounds.Dy() {
		bandHeight = bounds.Dy()
	}
	band := image.Rect(bounds.Min.X, bounds.Max.Y-bandHeight, bounds.Max.X, bounds.Max.Y)
	draw.Draw(canvas, band, &image.Uniform{C: color.RGBA{A: 190}}, image.Point{}, draw.Over)
	drawer := font.Drawer{Dst: canvas, Src: image.White, Face: basicfont.Face7x13}
	baseline := band.Min.Y + 17
	for _, line := range lines {
		if baseline > bounds.Max.Y-3 {
			break
		}
		drawer.Dot = fixedPoint(band.Min.X+10, baseline)
		drawer.DrawString(line)
		baseline += 16
	}
	var output bytes.Buffer
	if err := jpeg.Encode(&output, canvas, &jpeg.Options{Quality: 88}); err != nil {
		return nil, err
	}
	return output.Bytes(), nil
}

func fixedPoint(x, y int) fixed.Point26_6 {
	return fixed.P(x, y)
}

func buildWatermarkText(info PhotoContext, takenAt time.Time) string {
	lines := []string{
		"Container: " + info.ContainerNo,
		"Survey: " + info.SurveyNo,
		"Damage: " + info.DamageNo,
		"Taken: " + takenAt.Format("2006-01-02 15:04:05 MST"),
		"Surveyor: " + info.SurveyorName,
	}
	if info.GPSLatitude != nil && info.GPSLongitude != nil {
		lines = append(lines, fmt.Sprintf("GPS: %.7f, %.7f", *info.GPSLatitude, *info.GPSLongitude))
	}
	return strings.Join(lines, "\n")
}

func checksum(data []byte) string {
	sum := sha256.Sum256(data)
	return hex.EncodeToString(sum[:])
}
