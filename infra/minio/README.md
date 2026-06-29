# MinIO

Local object storage for survey photos, reports, invoice PDFs, payment proof,
company logos, and signatures.

The MVP stores file metadata in MySQL table `file_objects`; binary files
belong in MinIO/S3 and should be private by default.

