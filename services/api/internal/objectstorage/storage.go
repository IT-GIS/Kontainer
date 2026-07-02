package objectstorage

import (
	"context"
	"fmt"
	"io"
	"net/url"
	"strings"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

type PutOptions struct {
	ContentType string
	Metadata    map[string]string
}

type Store interface {
	Put(context.Context, string, string, io.Reader, int64, PutOptions) error
	Get(context.Context, string, string) (io.ReadCloser, error)
	Remove(context.Context, string, string) error
}

type MinIOOptions struct {
	Endpoint  string
	AccessKey string
	SecretKey string
	Region    string
	UseSSL    bool
}

type MinIOStore struct {
	client *minio.Client
	region string
}

func NewMinIO(options MinIOOptions) (*MinIOStore, error) {
	endpoint, secure, err := parseEndpoint(options.Endpoint, options.UseSSL)
	if err != nil {
		return nil, err
	}
	client, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(options.AccessKey, options.SecretKey, ""),
		Secure: secure,
		Region: options.Region,
	})
	if err != nil {
		return nil, fmt.Errorf("create object storage client: %w", err)
	}
	return &MinIOStore{client: client, region: options.Region}, nil
}

func (s *MinIOStore) Put(ctx context.Context, bucket, key string, reader io.Reader, size int64, options PutOptions) error {
	if err := s.ensureBucket(ctx, bucket); err != nil {
		return err
	}
	_, err := s.client.PutObject(ctx, bucket, key, reader, size, minio.PutObjectOptions{
		ContentType:  options.ContentType,
		UserMetadata: options.Metadata,
	})
	if err != nil {
		return fmt.Errorf("put object %s: %w", key, err)
	}
	return nil
}

func (s *MinIOStore) Get(ctx context.Context, bucket, key string) (io.ReadCloser, error) {
	object, err := s.client.GetObject(ctx, bucket, key, minio.GetObjectOptions{})
	if err != nil {
		return nil, fmt.Errorf("get object %s: %w", key, err)
	}
	if _, err := object.Stat(); err != nil {
		_ = object.Close()
		return nil, fmt.Errorf("stat object %s: %w", key, err)
	}
	return object, nil
}

func (s *MinIOStore) Remove(ctx context.Context, bucket, key string) error {
	if strings.TrimSpace(key) == "" {
		return nil
	}
	if err := s.client.RemoveObject(ctx, bucket, key, minio.RemoveObjectOptions{}); err != nil {
		return fmt.Errorf("remove object %s: %w", key, err)
	}
	return nil
}

func (s *MinIOStore) ensureBucket(ctx context.Context, bucket string) error {
	exists, err := s.client.BucketExists(ctx, bucket)
	if err != nil {
		return fmt.Errorf("check bucket %s: %w", bucket, err)
	}
	if exists {
		return nil
	}
	if err := s.client.MakeBucket(ctx, bucket, minio.MakeBucketOptions{Region: s.region}); err != nil {
		response := minio.ToErrorResponse(err)
		if response.Code != "BucketAlreadyOwnedByYou" && response.Code != "BucketAlreadyExists" {
			return fmt.Errorf("create bucket %s: %w", bucket, err)
		}
	}
	return nil
}

func parseEndpoint(raw string, useSSL bool) (string, bool, error) {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" {
		return "", false, fmt.Errorf("S3 endpoint is required")
	}
	if !strings.Contains(trimmed, "://") {
		return strings.TrimSuffix(trimmed, "/"), useSSL, nil
	}
	parsed, err := url.Parse(trimmed)
	if err != nil || parsed.Host == "" {
		return "", false, fmt.Errorf("invalid S3 endpoint %q", raw)
	}
	return parsed.Host, parsed.Scheme == "https", nil
}
