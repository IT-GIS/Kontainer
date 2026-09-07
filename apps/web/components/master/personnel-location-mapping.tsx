"use client";

import { useEffect, useState } from "react";
import { useAuth } from "@/hooks/use-auth";
import { apiData, apiPaginated } from "@/lib/api-client";

type Personnel = { id: string; personnel_code: string; name: string };
type Mapping = {
  customer_id: string;
  personnel_id: string;
  locations: Array<{ id: string; location_code: string; location_name: string; mapped: boolean }>;
};

export function PersonnelLocationMapping({
  customerId,
  readOnly,
  refreshKey,
  onSaved
}: {
  customerId: string;
  readOnly: boolean;
  refreshKey: number;
  onSaved: () => Promise<void> | void;
}) {
  const { accessToken } = useAuth();
  const [personnel, setPersonnel] = useState<Personnel[]>([]);
  const [personnelId, setPersonnelId] = useState("");
  const [mapping, setMapping] = useState<Mapping | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [message, setMessage] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    if (!accessToken) return;
    apiPaginated<Personnel>(`/customers/${customerId}/personnel?page=1&per_page=100&status=active`, { accessToken })
      .then((result) => {
        setPersonnel(result.rows);
        setPersonnelId((current) => result.rows.some((item) => item.id === current) ? current : result.rows[0]?.id || "");
      })
      .catch((cause) => setError(cause instanceof Error ? cause.message : "Personel/PIC gagal dimuat."));
  }, [accessToken, customerId, refreshKey]);

  useEffect(() => {
    const timer = window.setTimeout(() => {
      if (!accessToken || !personnelId) {
        setMapping(null);
        return;
      }
      apiData<Mapping>(`/customers/${customerId}/personnel/${personnelId}/locations`, { accessToken })
        .then(setMapping)
        .catch((cause) => setError(cause instanceof Error ? cause.message : "Mapping Location gagal dimuat."));
    }, 0);
    return () => window.clearTimeout(timer);
  }, [accessToken, customerId, personnelId, refreshKey]);

  function toggle(locationId: string) {
    if (readOnly) return;
    setMapping((current) => current ? { ...current, locations: current.locations.map((location) => location.id === locationId ? { ...location, mapped: !location.mapped } : location) } : current);
  }

  async function save() {
    if (!accessToken || !personnelId || !mapping || readOnly) return;
    setSaving(true);
    setError(null);
    setMessage(null);
    try {
      const updated = await apiData<Mapping>(`/customers/${customerId}/personnel/${personnelId}/locations`, {
        method: "PUT",
        accessToken,
        body: JSON.stringify({ location_ids: mapping.locations.filter((location) => location.mapped).map((location) => location.id) })
      });
      setMapping(updated);
      setMessage("Mapping Location Personel/PIC berhasil disimpan.");
      await onSaved();
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : "Mapping Location gagal disimpan.");
    } finally {
      setSaving(false);
    }
  }

  return <section className="workspace-panel page-stack" aria-labelledby="personnel-location-title">
    <div className="section-title-row"><div><h2 id="personnel-location-title">Mapping Personel/PIC ke Location</h2><p className="muted-text">PIC yang tersedia saat membuat Job/SPK difilter berdasarkan mapping Location ini.</p></div>{!readOnly ? <button className="primary-button" disabled={saving || !mapping} onClick={() => void save()} type="button">{saving ? "Menyimpan..." : "Simpan Mapping"}</button> : null}</div>
    {readOnly ? <div className="alert alert-warning">Customer tidak aktif. Mapping hanya dapat dilihat.</div> : null}
    {error ? <div className="alert alert-danger" role="alert">{error}</div> : null}
    {message ? <div className="alert alert-success">{message}</div> : null}
    <label className="field"><span>Personel/PIC Customer</span><select value={personnelId} onChange={(event) => setPersonnelId(event.target.value)}><option value="">Pilih Personel/PIC aktif</option>{personnel.map((item) => <option value={item.id} key={item.id}>{item.personnel_code} - {item.name}</option>)}</select></label>
    {personnel.length === 0 ? <p className="muted-text">Personel/PIC aktif belum tersedia. Tambahkan Personel/PIC sebelum membuat mapping.</p> : null}
    {mapping && mapping.locations.length === 0 ? <p className="muted-text">Location aktif belum tersedia. Tambahkan Location Pemeriksaan terlebih dahulu.</p> : null}
    {mapping && mapping.locations.length > 0 ? <div className="detail-grid">{mapping.locations.map((location) => <label className="field form-check" key={location.id}><input checked={location.mapped} disabled={readOnly} onChange={() => toggle(location.id)} type="checkbox" /><span>{location.location_code} - {location.location_name}</span></label>)}</div> : null}
  </section>;
}
