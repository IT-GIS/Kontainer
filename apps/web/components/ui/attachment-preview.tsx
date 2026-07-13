import { FileText, ImageIcon } from "lucide-react";
import { StatusBadge } from "@/components/ui/status-badge";

type AttachmentPreviewProps = {
  name: string;
  type?: "image" | "document";
  sizeLabel?: string;
  status?: string;
};

export function AttachmentPreview({
  name,
  type = "document",
  sizeLabel,
  status = "Siap"
}: AttachmentPreviewProps) {
  const Icon = type === "image" ? ImageIcon : FileText;

  return (
    <article className="ui-attachment-preview">
      <span className="ui-card-icon">
        <Icon size={20} />
      </span>
      <span>
        <strong>{name}</strong>
        {sizeLabel ? <small>{sizeLabel}</small> : null}
      </span>
      <StatusBadge tone="success">{status}</StatusBadge>
    </article>
  );
}
