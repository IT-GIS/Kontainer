import { UploadCloud } from "lucide-react";

type AttachmentUploaderPlaceholderProps = {
  title: string;
  description: string;
  acceptLabel?: string;
};

export function AttachmentUploaderPlaceholder({
  title,
  description,
  acceptLabel = "PDF, JPG, PNG"
}: AttachmentUploaderPlaceholderProps) {
  return (
    <div className="ui-upload-placeholder">
      <UploadCloud aria-hidden="true" size={22} />
      <div>
        <strong>{title}</strong>
        <span>{description}</span>
      </div>
      <small>{acceptLabel}</small>
    </div>
  );
}
