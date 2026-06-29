# Worker Jobs

Planned queues:

- `report`: generate and regenerate report PDFs.
- `invoice`: generate invoice PDFs.
- `image`: compress images, create thumbnails, and apply optional watermark.
- `notification`: create/send in-app and email notifications.
- `finance`: scheduled overdue invoice checks.
- `cleanup`: remove temporary files.

The MVP starts with a runner scaffold so queue wiring can be added after the API
state machine and report records are implemented.
