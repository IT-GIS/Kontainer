"use client";

import { Download, ImageIcon } from "lucide-react";
import Image from "next/image";
import { useEffect, useState } from "react";
import { useAuth } from "@/hooks/use-auth";
import { apiBlob } from "@/lib/api-client";

type PhotoEvidenceProps = {
  id: string;
  name?: string | null;
  caption?: string | null;
};

export function PhotoEvidence({ id, name, caption }: PhotoEvidenceProps) {
  const { accessToken } = useAuth();
  const [source, setSource] = useState<string | null>(null);
  const [error, setError] = useState(false);

  useEffect(() => {
    if (!accessToken || !id) return;
    const controller = new AbortController();
    let objectURL = "";
    void apiBlob(`/survey-photos/${id}/content`, { accessToken, signal: controller.signal })
      .then((blob) => {
        objectURL = URL.createObjectURL(blob);
        setSource(objectURL);
        setError(false);
      })
      .catch(() => {
        if (!controller.signal.aborted) setError(true);
      });
    return () => {
      controller.abort();
      if (objectURL) URL.revokeObjectURL(objectURL);
    };
  }, [accessToken, id]);

  async function downloadOriginal() {
    if (!accessToken) return;
    try {
      const blob = await apiBlob(`/survey-photos/${id}/content?variant=original&download=1`, { accessToken });
      const url = URL.createObjectURL(blob);
      const anchor = document.createElement("a");
      anchor.href = url;
      anchor.download = name || "photo-evidence";
      anchor.click();
      URL.revokeObjectURL(url);
    } catch {
      setError(true);
    }
  }

  return (
    <article className="photo-card">
      <div className="photo-evidence-preview">
        {source ? <Image src={source} alt={name || "Photo evidence"} fill sizes="(max-width: 640px) 100vw, 320px" unoptimized /> : <div className="photo-evidence-empty"><ImageIcon size={24} /><span>{error ? "Preview gagal dimuat" : "Memuat foto..."}</span></div>}
      </div>
      <strong>{name || "Photo evidence"}</strong>
      <span>{caption || "Watermarked preview"}</span>
      <button className="secondary-button" type="button" onClick={() => void downloadOriginal()}><Download size={16} /><span>Original</span></button>
    </article>
  );
}
