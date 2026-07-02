# MinIO

Local object storage for survey photos, reports, invoice PDFs, payment proof,
company logos, and signatures.

The API stores private survey evidence in the configured `S3_BUCKET`:

- `surveys/{survey_id}/photos/original/*` keeps the uploaded bytes.
- `surveys/{survey_id}/photos/watermarked/*` keeps the review derivative.

Both objects have separate rows in `file_objects`. `survey_photos.file_id`
references the original and `survey_photos.watermarked_file_id` references the
derivative. Access is streamed through the authenticated API; the bucket does
not need a public policy.

