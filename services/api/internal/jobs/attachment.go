package jobs

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"net/http"
	"path/filepath"
	"regexp"
	"strings"

	"container-survey/services/api/internal/database"
	"container-survey/services/api/internal/objectstorage"
	"github.com/google/uuid"
)

var unsafeFileNameCharacters = regexp.MustCompile(`[^A-Za-z0-9._ -]+`)

type jobAttachment struct {
	Bucket      string
	ObjectKey   string
	FileName    string
	ContentType string
	Size        int64
	Checksum    string
}

type AttachmentContent struct {
	FileName    string
	ContentType string
	Size        int64
	Reader      io.ReadCloser
}

func (s *Service) MaxUploadBytes() int64 { return s.maxUploadBytes }

func (s *Service) UploadSPKAttachment(ctx context.Context, jobID uuid.UUID, reader io.Reader, fileName string, actor Actor) (map[string]any, error) {
	if s.store == nil || strings.TrimSpace(s.bucket) == "" {
		return nil, ErrInvalidInput
	}
	data, contentType, extension, err := readJobAttachment(reader, s.maxUploadBytes)
	if err != nil {
		return nil, err
	}
	safeName := safeAttachmentName(fileName, extension)
	objectKey := fmt.Sprintf("jobs/%s/spk/%s%s", jobID, uuid.NewString(), extension)
	if s.objectPrefix != "" {
		objectKey = s.objectPrefix + "/" + objectKey
	}
	attachment := jobAttachment{
		Bucket: s.bucket, ObjectKey: objectKey, FileName: safeName, ContentType: contentType,
		Size: int64(len(data)), Checksum: attachmentChecksum(data),
	}
	if err := s.store.Put(ctx, attachment.Bucket, attachment.ObjectKey, bytes.NewReader(data), attachment.Size, objectstorage.PutOptions{
		ContentType: contentType,
		Metadata:    map[string]string{"job-id": jobID.String(), "purpose": "spk-attachment", "sha256": attachment.Checksum},
	}); err != nil {
		return nil, err
	}
	item, err := s.repo.AttachSPK(ctx, jobID, attachment, actor)
	if err != nil {
		_ = s.store.Remove(ctx, attachment.Bucket, attachment.ObjectKey)
		return nil, err
	}
	return item, nil
}

func (s *Service) SPKAttachment(ctx context.Context, jobID uuid.UUID) (AttachmentContent, error) {
	if s.store == nil {
		return AttachmentContent{}, ErrNotFound
	}
	attachment, err := s.repo.SPKAttachment(ctx, jobID)
	if err != nil {
		return AttachmentContent{}, err
	}
	reader, err := s.store.Get(ctx, attachment.Bucket, attachment.ObjectKey)
	if err != nil {
		return AttachmentContent{}, err
	}
	return AttachmentContent{FileName: attachment.FileName, ContentType: attachment.ContentType, Size: attachment.Size, Reader: reader}, nil
}

func readJobAttachment(reader io.Reader, maxBytes int64) ([]byte, string, string, error) {
	if reader == nil || maxBytes <= 0 {
		return nil, "", "", ErrInvalidInput
	}
	data, err := io.ReadAll(io.LimitReader(reader, maxBytes+1))
	if err != nil || len(data) == 0 || int64(len(data)) > maxBytes {
		return nil, "", "", FieldValidationError{Fields: map[string]string{"spk_attachment": "Ukuran lampiran harus lebih dari 0 dan tidak melebihi batas unggah."}}
	}
	contentType := http.DetectContentType(data)
	extension := ""
	switch contentType {
	case "application/pdf":
		extension = ".pdf"
	case "image/jpeg":
		extension = ".jpg"
	case "image/png":
		extension = ".png"
	default:
		return nil, "", "", FieldValidationError{Fields: map[string]string{"spk_attachment": "Lampiran hanya mendukung PDF, JPG, atau PNG berdasarkan MIME file."}}
	}
	return data, contentType, extension, nil
}

func safeAttachmentName(raw, extension string) string {
	name := filepath.Base(strings.TrimSpace(raw))
	name = unsafeFileNameCharacters.ReplaceAllString(name, "_")
	name = strings.Trim(name, ". ")
	if name == "" {
		name = "lampiran-spk" + extension
	}
	if !strings.EqualFold(filepath.Ext(name), extension) {
		name = strings.TrimSuffix(name, filepath.Ext(name)) + extension
	}
	if len(name) > 180 {
		name = name[:180-len(extension)] + extension
	}
	return name
}

func attachmentChecksum(data []byte) string {
	sum := sha256.Sum256(data)
	return hex.EncodeToString(sum[:])
}

func (r Repository) AttachSPK(ctx context.Context, jobID uuid.UUID, attachment jobAttachment, actor Actor) (map[string]any, error) {
	tx, err := r.pool.Begin(ctx)
	if err != nil {
		return nil, err
	}
	defer tx.Rollback(ctx)
	oldJob, err := scanRow(tx.QueryRow(ctx, `SELECT id, job_order_no, spk_file_id FROM job_orders WHERE id=$1 AND deleted_at IS NULL FOR UPDATE`, jobID), []string{"id", "job_order_no", "spk_file_id"})
	if err != nil {
		return nil, err
	}
	fileID := uuid.Nil
	if err := tx.QueryRow(ctx, `
		INSERT INTO file_objects (bucket_name, object_key, original_file_name, mime_type, file_size, checksum_sha256, visibility, uploaded_by)
		VALUES ($1,$2,$3,$4,$5,$6,'private',$7) RETURNING id
	`, attachment.Bucket, attachment.ObjectKey, attachment.FileName, attachment.ContentType, attachment.Size, attachment.Checksum, actor.UserID).Scan(&fileID); err != nil {
		return nil, err
	}
	if _, err := tx.Exec(ctx, `UPDATE job_orders SET spk_file_id=$2, updated_by=$3, updated_at=now() WHERE id=$1`, jobID, fileID, actor.UserID); err != nil {
		return nil, err
	}
	item := map[string]any{
		"id": fileID.String(), "job_id": jobID.String(), "original_file_name": attachment.FileName,
		"mime_type": attachment.ContentType, "file_size": attachment.Size, "checksum_sha256": attachment.Checksum,
		"download_url": fmt.Sprintf("/jobs/%s/spk-attachment", jobID),
	}
	if err := r.insertJobEvent(ctx, tx, jobID, "spk_attachment_uploaded", "Lampiran SPK diperbarui.", attachment.FileName, actor.UserID, item); err != nil {
		return nil, err
	}
	if err := r.insertAudit(ctx, tx, actor, "jobs.spk_attachment.upload", "jobs", &jobID, oldJob, item); err != nil {
		return nil, err
	}
	if err := tx.Commit(ctx); err != nil {
		return nil, err
	}
	return item, nil
}

func (r Repository) SPKAttachment(ctx context.Context, jobID uuid.UUID) (jobAttachment, error) {
	var item jobAttachment
	err := r.pool.QueryRow(ctx, `
		SELECT file.bucket_name, file.object_key, file.original_file_name, file.mime_type, file.file_size, file.checksum_sha256
		FROM job_orders job
		JOIN file_objects file ON file.id=job.spk_file_id AND file.deleted_at IS NULL
		WHERE job.id=$1 AND job.deleted_at IS NULL
	`, jobID).Scan(&item.Bucket, &item.ObjectKey, &item.FileName, &item.ContentType, &item.Size, &item.Checksum)
	if err != nil {
		if strings.Contains(strings.ToLower(err.Error()), "no rows") || err == database.ErrNoRows {
			return jobAttachment{}, ErrNotFound
		}
		return jobAttachment{}, err
	}
	return item, nil
}
