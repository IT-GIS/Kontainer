"use client";

import { Crosshair, FilePlus2, LocateFixed, Minus, Plus, RotateCcw, ZoomIn } from "lucide-react";
import { useEffect, useMemo, useRef, useState } from "react";
import {
  areaAriaLabel,
  buildSheetAreas,
  createSelection,
  findStructuredLocation,
  normalizeContainerSize,
  parseLocationSnapshot,
  selectionContainsArea,
  selectionDescription,
  sectionsForTemplate,
  SURVEY_SHEET_FACES,
  type LocationSelectionSnapshot,
  type SurveyContainerSize,
  type SurveySheetArea,
  type SurveySheetFaceConfig
} from "@/lib/survey-sheet";
import type { SurveyDamage, SurveyMasterOption } from "@/types/surveyor";

type InteractiveSurveySheetProps = {
  containerSize?: string | null;
  activeFace: string;
  locations: SurveyMasterOption[];
  damages: SurveyDamage[];
  readonly?: boolean;
  preview?: boolean;
  sidePanel?: React.ReactNode;
  selection: LocationSelectionSnapshot | null;
  focusedDamageId?: string | null;
  focusRequestKey?: number;
  onFace: (face: string) => void;
  onSelectionChange?: (selection: LocationSelectionSnapshot | null) => void;
  onUseLocation?: (selection: LocationSelectionSnapshot, location: SurveyMasterOption) => void;
  onProposeLocation?: (selection: LocationSelectionSnapshot) => void;
  onEditDamage?: (damage: SurveyDamage) => void;
};

type GridGeometry = {
  x: number;
  y: number;
  width: number;
  height: number;
  cellWidth: number;
  cellHeight: number;
};

export function InteractiveSurveySheet({
  containerSize,
  activeFace,
  locations,
  damages,
  readonly = false,
  preview = false,
  sidePanel,
  selection,
  focusedDamageId = null,
  focusRequestKey = 0,
  onFace,
  onSelectionChange,
  onUseLocation,
  onProposeLocation,
  onEditDamage
}: InteractiveSurveySheetProps) {
  const size = normalizeContainerSize(containerSize);
  const config = SURVEY_SHEET_FACES.find((item) => item.face === activeFace) ?? SURVEY_SHEET_FACES[0];
  const areas = useMemo(() => size ? buildSheetAreas(config, size) : [], [config, size]);
  const [anchor, setAnchor] = useState<SurveySheetArea | null>(null);
  const [zoom, setZoom] = useState(1);
  const scrollRef = useRef<HTMLDivElement | null>(null);
  const mappedLocation = useMemo(
    () => selection ? findStructuredLocation(selection, locations) : undefined,
    [locations, selection]
  );

  function selectArea(area: SurveySheetArea) {
    if (readonly || preview) return;
    if (!anchor || anchor.face !== area.face || anchor.bandId !== area.bandId || anchor.containerSize !== area.containerSize) {
      setAnchor(area);
      onSelectionChange?.(createSelection(area));
      return;
    }
    onSelectionChange?.(createSelection(anchor, area));
    setAnchor(null);
  }

  function resetSelection() {
    setAnchor(null);
    onSelectionChange?.(null);
  }

  useEffect(() => {
    if (!selection || !focusRequestKey) return;
    const timer = window.setTimeout(() => {
      const scroll = scrollRef.current;
      const bandId = config.bands.find((band) => (
        band.verticalPosition === selection.vertical_position
        && band.transversePosition === selection.transverse_position
      ))?.id;
      const areaId = bandId ? [selection.face, bandId, selection.section_start, selection.container_size].join("-") : "";
      const area = scroll?.querySelector<SVGGElement>(`[data-area-id="${areaId}"]`);
      if (!scroll || !area) return;
      const scrollBox = scroll.getBoundingClientRect();
      const areaBox = area.getBoundingClientRect();
      scroll.scrollTo({
        left: Math.max(0, scroll.scrollLeft + areaBox.left - scrollBox.left - (scroll.clientWidth - areaBox.width) / 2),
        behavior: "smooth"
      });
    }, 0);
    return () => window.clearTimeout(timer);
  }, [activeFace, config.bands, focusRequestKey, selection, zoom]);

  if (!size) {
    return (
      <section className="workspace-panel survey-sheet-layout">
        <div className="alert alert-danger" role="alert">
          Ukuran peti kemas belum tersedia. Survey Sheet tidak akan memakai template asumsi. Lengkapi Container Type 20, 40, atau 45 feet dari data pekerjaan.
        </div>
      </section>
    );
  }

  return (
    <section className={`workspace-panel survey-sheet-layout ${preview ? "survey-sheet-preview" : ""}`}>
      <div className="survey-sheet-heading">
        <div>
          <h2>{preview ? "Pratinjau Survey Sheet" : "Survey Sheet Interaktif"}</h2>
          <p className="muted-text">
            Template {size} feet · Rear di kiri · Front di kanan. Klik/tap pertama memilih awal, klik/tap kedua pada band yang sama memilih akhir rentang.
          </p>
        </div>
        <div className="survey-sheet-zoom" aria-label="Kontrol zoom Survey Sheet">
          <button className="secondary-button table-action" disabled={!selection} type="button" onClick={resetSelection}><RotateCcw size={16} /><span>Reset Pilihan</span></button>
          <button className="icon-button" type="button" onClick={() => setZoom((value) => Math.max(1, value - 0.2))} aria-label="Perkecil diagram">
            <Minus size={17} />
          </button>
          <button className="secondary-button table-action" type="button" onClick={() => setZoom(1)} aria-label="Reset zoom">
            <ZoomIn size={16} /><span>{Math.round(zoom * 100)}%</span>
          </button>
          <button className="icon-button" type="button" onClick={() => setZoom((value) => Math.min(2, value + 0.2))} aria-label="Perbesar diagram">
            <Plus size={17} />
          </button>
        </div>
      </div>

      <div className="face-selector" role="tablist" aria-label="Sisi peti kemas">
        {SURVEY_SHEET_FACES.map((face) => (
          <button
            aria-selected={config.face === face.face}
            className={config.face === face.face ? "selected" : ""}
            key={face.face}
            onClick={() => onFace(face.face)}
            role="tab"
            type="button"
          >
            {face.label}
          </button>
        ))}
      </div>

      <div className="interactive-sheet-stage">
        <div className="interactive-sheet-scroll" ref={scrollRef}>
          <div className="interactive-sheet-canvas" style={{ width: `${zoom * 100}%` }}>
            <ContainerFaceSvg
              areas={areas}
              config={config}
              damages={damages}
              locations={locations}
              readonly={readonly || preview}
              selection={selection}
              focusedDamageId={focusedDamageId}
              size={size}
              onArea={selectArea}
              onDamage={onEditDamage}
            />
          </div>
        </div>

        {!preview ? (
          sidePanel ?? (
            <SelectedLocationPanel
              selection={selection}
              location={mappedLocation}
              readonly={readonly}
              waitingForRange={Boolean(anchor)}
              onReset={resetSelection}
              onUse={() => selection && mappedLocation && onUseLocation?.(selection, mappedLocation)}
              onPropose={() => selection && onProposeLocation?.(selection)}
            />
          )
        ) : null}
      </div>

      <div className="survey-sheet-legend" aria-label="Legenda Survey Sheet">
        <span><i className="legend-swatch legend-select" /> Area dipilih</span>
        <span><i className="legend-swatch legend-mapped" /> Mapping aktif tersedia</span>
        <span><i className="legend-swatch legend-unmapped" /> Belum dipetakan</span>
        <span><i className="legend-marker">01</i> Marker temuan tersimpan</span>
        <span><i className="legend-marker legend-marker-active">01</i> Marker/baris aktif</span>
        <span>Status mapping juga ditulis pada panel, tidak hanya dibedakan dengan warna.</span>
      </div>
    </section>
  );
}

function ContainerFaceSvg({
  areas,
  config,
  damages,
  locations,
  readonly,
  selection,
  focusedDamageId,
  size,
  onArea,
  onDamage
}: {
  areas: SurveySheetArea[];
  config: SurveySheetFaceConfig;
  damages: SurveyDamage[];
  locations: SurveyMasterOption[];
  readonly: boolean;
  selection: LocationSelectionSnapshot | null;
  focusedDamageId?: string | null;
  size: SurveyContainerSize;
  onArea: (area: SurveySheetArea) => void;
  onDamage?: (damage: SurveyDamage) => void;
}) {
  const sections = sectionsForTemplate(size, config.code);
  const geometry = gridGeometry(config, sections.length);
  const markerRows = damages.map((damage) => ({ damage, snapshot: parseLocationSnapshot(damage.location_selection_snapshot) }));
  const visibleMarkers = markerRows.filter((item) => item.snapshot?.face === config.code && item.snapshot.container_size === size);
  const unplacedCount = damages.length - markerRows.filter((item) => item.snapshot).length;

  return (
    <>
      <svg
        aria-label={`${config.label}, template ${size} feet`}
        className={`container-face-svg layout-${config.layout}`}
        role="group"
        viewBox="0 0 1000 440"
      >
        <title>{config.label}, template peti kemas {size} feet</title>
        <text className="svg-face-title" x="72" y="36">{config.label}</text>
        <text className="svg-orientation" x={geometry.x} y="420">Rear</text>
        <text className="svg-orientation" textAnchor="end" x={geometry.x + geometry.width} y="420">Front</text>
        <line className="svg-orientation-line" x1={geometry.x + 45} x2={geometry.x + geometry.width - 45} y1="411" y2="411" />

        <FrameDecoration config={config} geometry={geometry} />

        {areas.map((area) => {
          const sectionIndex = sections.indexOf(area.section);
          const bandIndex = config.bands.findIndex((band) => band.id === area.bandId);
          const x = geometry.x + sectionIndex * geometry.cellWidth;
          const y = geometry.y + bandIndex * geometry.cellHeight;
          const selected = selectionContainsArea(selection, area);
          const mappedArea = findStructuredLocation(createSelection(area), locations);
          return (
            <g
              aria-label={areaAriaLabel(area)}
              className={`svg-area ${mappedArea ? "is-mapped" : "is-unmapped"} ${selected ? "is-selected" : ""}`}
              data-area-id={area.id}
              data-container-size={area.containerSize}
              data-face={area.face}
              data-location-code-id={mappedArea?.id}
              data-section-end={area.section}
              data-section-start={area.section}
              data-transverse-position={area.transversePosition}
              data-vertical-position={area.verticalPosition}
              key={area.id}
              onClick={() => onArea(area)}
              onKeyDown={(event) => {
                if (readonly || (event.key !== "Enter" && event.key !== " ")) return;
                event.preventDefault();
                onArea(area);
              }}
              role="button"
              tabIndex={readonly ? -1 : 0}
            >
              <title>{areaAriaLabel(area)}</title>
              <rect
                height={Math.max(geometry.cellHeight - 2, 10)}
                rx="2"
                width={Math.max(geometry.cellWidth - 2, 10)}
                x={x + 1}
                y={y + 1}
              />
            </g>
          );
        })}

        {config.bands.map((band, index) => (
          <text
            className="svg-band-label"
            key={band.id}
            textAnchor="end"
            x={geometry.x - 15}
            y={geometry.y + index * geometry.cellHeight + geometry.cellHeight / 2 + 5}
          >
            {band.verticalPosition === "X" ? band.transversePosition : band.verticalPosition}
          </text>
        ))}
        {sections.map((section, index) => (
          <text
            className="svg-section-label"
            key={section}
            textAnchor="middle"
            x={geometry.x + index * geometry.cellWidth + geometry.cellWidth / 2}
            y={geometry.y + geometry.height + 27}
          >
            {section}
          </text>
        ))}

        {visibleMarkers.map(({ damage, snapshot }, index) => {
          const point = markerPoint(snapshot!, config, sections, geometry, index);
          return (
            <g
              aria-label={`Temuan ${damage.damage_no}, ${selectionDescription(snapshot!)}`}
              aria-current={damage.id === focusedDamageId ? "true" : undefined}
              className={`svg-damage-marker ${damage.id === focusedDamageId ? "is-active" : ""}`}
              key={damage.id}
              onClick={(event) => {
                event.stopPropagation();
                if (!readonly) onDamage?.(damage);
              }}
              onKeyDown={(event) => {
                if (readonly || (event.key !== "Enter" && event.key !== " ")) return;
                event.preventDefault();
                onDamage?.(damage);
              }}
              role="button"
              tabIndex={readonly ? -1 : 0}
              transform={`translate(${point.x} ${point.y})`}
            >
              <title>Temuan {damage.damage_no}</title>
              <rect height="34" rx="17" width="64" x="-32" y="-17" />
              <text dominantBaseline="middle" textAnchor="middle">{damage.damage_no}</text>
            </g>
          );
        })}
      </svg>
      {unplacedCount > 0 ? (
        <p className="interactive-sheet-note">
          {unplacedCount} temuan legacy belum mempunyai snapshot area, sehingga tetap tampil di Daftar Temuan tetapi tidak ditempatkan secara fiktif pada SVG.
        </p>
      ) : null}
    </>
  );
}

function FrameDecoration({ config, geometry }: { config: SurveySheetFaceConfig; geometry: GridGeometry }) {
  const { x, y, width, height } = geometry;
  return (
    <g aria-hidden="true" className={`svg-frame svg-frame-${config.layout}`}>
      <rect height={height + 20} rx="3" width={width + 20} x={x - 10} y={y - 10} />
      <rect className="svg-frame-inner" height={height} width={width} x={x} y={y} />
      {(config.layout === "side" || config.layout === "roof") ? (
        <>
          <rect className="svg-corner-post" height={height + 30} width="18" x={x - 18} y={y - 15} />
          <rect className="svg-corner-post" height={height + 30} width="18" x={x + width} y={y - 15} />
        </>
      ) : null}
      {config.layout === "understructure" ? (
        <line className="svg-center-line" x1={x + width / 2} x2={x + width / 2} y1={y - 20} y2={y + height + 20} />
      ) : null}
      {config.layout === "floor" ? (
        <rect className="svg-floor-door" height={height * 0.42} width={width * 0.23} x={x + width * 0.75} y={y + height * 0.29} />
      ) : null}
      {config.layout === "end" ? (
        <line className="svg-end-split" x1={x + width / 2} x2={x + width / 2} y1={y} y2={y + height} />
      ) : null}
    </g>
  );
}

function SelectedLocationPanel({
  selection,
  location,
  readonly,
  waitingForRange,
  onReset,
  onUse,
  onPropose
}: {
  selection: LocationSelectionSnapshot | null;
  location?: SurveyMasterOption;
  readonly: boolean;
  waitingForRange: boolean;
  onReset: () => void;
  onUse: () => void;
  onPropose: () => void;
}) {
  if (!selection) {
    return (
      <aside className="selected-location-panel">
        <Crosshair size={24} />
        <h3>Lokasi Dipilih</h3>
        <p className="muted-text">Pilih satu area pada SVG untuk memulai. Pilihan tidak akan menghasilkan kode sebelum ada mapping structured aktif di master Admin.</p>
      </aside>
    );
  }
  const face = SURVEY_SHEET_FACES.find((item) => item.code === selection.face);
  const band = face?.bands.find((item) => item.verticalPosition === selection.vertical_position && item.transversePosition === selection.transverse_position);
  const section = selection.section_start === selection.section_end
    ? selection.section_start
    : `${selection.section_start}-${selection.section_end}`;
  return (
    <aside className="selected-location-panel" aria-live="polite">
      <div className="section-title-row">
        <div><span className="eyebrow">Lokasi Dipilih</span><h3>{selectionDescription(selection)}</h3></div>
        <button aria-label="Reset pilihan lokasi" className="icon-button" onClick={onReset} type="button"><RotateCcw size={16} /></button>
      </div>
      {waitingForRange ? <div className="alert alert-info">Klik area akhir pada band yang sama, atau langsung gunakan pilihan satu section.</div> : null}
      <dl className="selection-detail-list">
        <div><dt>Sisi</dt><dd>{face?.shortLabel ?? selection.face}</dd></div>
        <div><dt>Posisi Vertikal</dt><dd>{band?.label ?? selection.vertical_position}</dd></div>
        <div><dt>Posisi Transversal</dt><dd>{selection.transverse_position}</dd></div>
        <div><dt>Section</dt><dd>{section}</dd></div>
        <div><dt>Ukuran Kontainer</dt><dd>{selection.container_size} feet</dd></div>
        <div><dt>Location Code</dt><dd>{location?.code ?? "Belum dipetakan"}</dd></div>
        <div><dt>Description</dt><dd>{location?.description ?? "Location Code untuk area ini belum tersedia."}</dd></div>
      </dl>
      {location ? (
        <div className="alert alert-success"><LocateFixed size={17} /> Exact active structured mapping ditemukan dari master.</div>
      ) : (
        <div className="alert alert-warning">Location Code untuk area ini belum tersedia. Ajukan kode baru atau hubungi Admin.</div>
      )}
      <div className="selected-location-actions">
        <button className="secondary-button" onClick={onReset} type="button">Batalkan</button>
        {location ? (
          <button className="primary-button" disabled={readonly} onClick={onUse} type="button"><LocateFixed size={17} /><span>Gunakan Lokasi</span></button>
        ) : (
          <button className="primary-button" disabled={readonly} onClick={onPropose} type="button"><FilePlus2 size={17} /><span>Ajukan Kode Lokasi</span></button>
        )}
      </div>
    </aside>
  );
}

function gridGeometry(config: SurveySheetFaceConfig, sectionCount: number): GridGeometry {
  const x = config.layout === "end" ? 180 : 82;
  const width = config.layout === "end" ? 640 : 836;
  const y = 72;
  const height = 285;
  return {
    x,
    y,
    width,
    height,
    cellWidth: width / sectionCount,
    cellHeight: height / config.bands.length
  };
}

function markerPoint(
  snapshot: LocationSelectionSnapshot,
  config: SurveySheetFaceConfig,
  sections: string[],
  geometry: GridGeometry,
  offset: number
) {
  const startIndex = Math.max(0, sections.indexOf(snapshot.section_start));
  const endIndex = Math.max(startIndex, sections.indexOf(snapshot.section_end));
  const bandIndex = Math.max(0, config.bands.findIndex((band) => (
    band.verticalPosition === snapshot.vertical_position
    && band.transversePosition === snapshot.transverse_position
  )));
  return {
    x: geometry.x + ((startIndex + endIndex + 1) / 2) * geometry.cellWidth + (offset % 3) * 5,
    y: geometry.y + (bandIndex + 0.5) * geometry.cellHeight + (offset % 2) * 5
  };
}
