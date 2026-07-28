"use client";

import { Scale, X } from "lucide-react";
import { MasterDataPage } from "@/components/master/master-data-page";

export type DamageRuleTarget = {
  id: string;
  code: string;
  name: string;
};

export function IsoCedexDecisionRules({
  customerId,
  damage,
  readOnly,
  onClose
}: {
  customerId?: string;
  damage: DamageRuleTarget;
  readOnly: boolean;
  onClose: () => void;
}) {
  return (
    <section className="workspace-panel iso-decision-rule-panel" aria-label={`Decision Rule ${damage.code}`}>
      <div className="section-title-row">
        <div>
          <span className="iso-form-step">2</span>
          <div>
            <p className="eyebrow">Tolerance &amp; Decision Rule</p>
            <h2>{damage.code} - {damage.name}</h2>
            <p className="muted-text">Tambahkan satu atau beberapa rule. Nilai tolerance harus berasal dari referensi teknis yang tervalidasi.</p>
          </div>
        </div>
        <button aria-label="Tutup pengelolaan Decision Rule" className="icon-button" onClick={onClose} title="Tutup" type="button">
          <X size={17} />
        </button>
      </div>

      <div className="alert alert-warning">
        <Scale size={17} />
        Aplikasi tidak mengisi angka tolerance secara otomatis. Admin bertanggung jawab memastikan standard, klausul, nilai, unit, dan masa berlaku telah disetujui.
      </div>

      <MasterDataPage
        resourceId="cedex-decision-rules"
        endpointOverride={customerId ? `/customers/${customerId}/cedex/decision-rules` : "/master/cedex/decision-rules"}
        fixedValues={{ damage_id: damage.id }}
        relationEndpointOverrides={{
          component_id: customerId ? `/customers/${customerId}/cedex/components` : "/master/cedex/components",
          location_id: customerId ? `/customers/${customerId}/cedex/locations` : "/master/cedex/locations",
          material_id: customerId ? `/customers/${customerId}/cedex/materials` : "/master/cedex/materials",
          container_type_id: customerId ? `/customers/${customerId}/container-types` : "/master/container-types",
          recommended_action_id: customerId ? `/customers/${customerId}/cedex/repairs` : "/master/cedex/repairs"
        }}
        readOnly={readOnly}
        readOnlyMessage="Decision Rule tersedia dalam mode baca-saja untuk peran ini."
        showResourceHeader={false}
        showToolbarAdd
        showRichEmptyState
        enableExport
        enableSaveAndNew
        enableSorting
        responsiveCards
        dialogSize="large"
        addButtonLabelOverride="+ Tambah Decision Rule"
        dialogTitleOverride="Decision Rule"
        actionIdPrefix="iso-cedex-damage-rule"
        emptyTitle="Belum ada Decision Rule"
        emptyDescription="Tambahkan rule tervalidasi agar sistem dapat mengevaluasi dimension Surveyor."
        filters={[
          {
            key: "measurement_field",
            label: "Measurement Field",
            options: ["length", "width", "depth", "thickness", "quantity", "area", "manual_assessment"].map((value) => ({ label: value, value }))
          },
          {
            key: "decision_result",
            label: "Decision Result",
            options: ["passed", "need_repair", "need_reinspection", "not_passed", "manual_review"].map((value) => ({ label: value, value }))
          }
        ]}
      />
    </section>
  );
}
