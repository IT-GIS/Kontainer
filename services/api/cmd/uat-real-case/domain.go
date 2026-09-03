package main

import (
	"context"
	"database/sql"
	"fmt"

	"github.com/google/uuid"
)

const (
	multiJobID        = "e2e00001-0000-4000-8000-000000000001"
	rejectionJobID    = "e2e00002-0000-4000-8000-000000000001"
	revisionJobID     = "e2e00003-0000-4000-8000-000000000001"
	isolationJobID    = "e2e00004-0000-4000-8000-000000000001"
	revisionSurveyID  = "e2e00003-0000-4000-8000-000000000301"
	rejectionSurveyID = "e2e00002-0000-4000-8000-000000000201"
	isolationSurveyID = "e2e00004-0000-4000-8000-000000000401"
)

type domainFixture struct {
	MultiContainerJobID string `json:"multi_container_job_id"`
	ContainerANo        string `json:"container_a_no"`
	ContainerBNo        string `json:"container_b_no"`
	RevisionSurveyID    string `json:"revision_survey_id"`
	RejectionSurveyID   string `json:"rejection_survey_id"`
	IsolationSurveyID   string `json:"isolation_survey_id"`
}

func fixtureManifest() domainFixture {
	return domainFixture{
		MultiContainerJobID: multiJobID,
		ContainerANo:        "GFTU1234560",
		ContainerBNo:        "NPKU7654323",
		RevisionSurveyID:    revisionSurveyID,
		RejectionSurveyID:   rejectionSurveyID,
		IsolationSurveyID:   isolationSurveyID,
	}
}

type primaryFixtureRefs struct {
	customerID, personnelID, surveyTypeID, containerTypeID, locationID, templateID, templateItemID string
	adminUserID, surveyorUserID, surveyorProfileID, otherSurveyorProfileID, reviewerUserID         string
	cedexLocationID, componentID, damageID, repairID, materialID, responsibilityID                 string
}

func bootstrapDomain(ctx context.Context, tx *sql.Tx, opt options) (domainFixture, error) {
	fixture := fixtureManifest()
	var existingJobs int
	if err := tx.QueryRowContext(ctx, `
		SELECT COUNT(*) FROM job_orders
		WHERE job_order_no IN ('UAT-JOB-2026-0805-001','UAT-JOB-2026-0805-002','UAT-JOB-2026-0805-003')
	`).Scan(&existingJobs); err != nil {
		return fixture, err
	}
	if existingJobs != 0 && existingJobs != 3 {
		return fixture, fmt.Errorf("partial UAT domain fixture detected: jobs=%d", existingJobs)
	}
	refs, err := loadPrimaryFixtureRefs(ctx, tx, opt.masterCustomer)
	if err != nil {
		return fixture, err
	}
	if err := ensurePrimaryFixtureCompatibility(ctx, tx, refs); err != nil {
		return fixture, err
	}
	if existingJobs == 3 {
		var fixtureRows int
		if err := tx.QueryRowContext(ctx, `
			SELECT COUNT(*) FROM surveys
			WHERE id IN (?,?,?) AND deleted_at IS NULL
		`, revisionSurveyID, rejectionSurveyID, isolationSurveyID).Scan(&fixtureRows); err != nil {
			return fixture, err
		}
		if fixtureRows != 3 {
			return fixture, fmt.Errorf("partial UAT survey fixture detected: surveys=%d", fixtureRows)
		}
		return fixture, nil
	}

	if err := insertPrimaryJobs(ctx, tx, refs); err != nil {
		return fixture, err
	}
	if err := insertIsolationFixture(ctx, tx, refs); err != nil {
		return fixture, err
	}
	return fixture, nil
}

func loadPrimaryFixtureRefs(ctx context.Context, tx *sql.Tx, customerCode string) (primaryFixtureRefs, error) {
	var refs primaryFixtureRefs
	err := tx.QueryRowContext(ctx, `
		SELECT customer.id, personnel.id, survey_type.id, container_type.id, location.id, template.id, item.id
		FROM customers customer
		JOIN customer_personnel personnel
		  ON personnel.customer_id=customer.id AND personnel.status='active' AND personnel.deleted_at IS NULL
		JOIN survey_types survey_type ON survey_type.customer_id=customer.id AND survey_type.status='active'
		JOIN container_types container_type ON container_type.customer_id=customer.id AND container_type.status='active'
		JOIN locations location ON location.customer_id=customer.id AND location.status='active' AND location.deleted_at IS NULL
		JOIN fitness_checklist_templates template
		  ON template.customer_id=customer.id AND template.survey_type_id=survey_type.id
		 AND template.container_type_id=container_type.id AND template.status='active' AND template.deleted_at IS NULL
		JOIN fitness_checklist_template_items item ON item.template_id=template.id AND item.status='active'
		WHERE customer.customer_code=? AND customer.status='active' AND customer.deleted_at IS NULL
		ORDER BY template.version_no DESC,item.display_order,item.item_code
		LIMIT 1
	`, customerCode).Scan(
		&refs.customerID, &refs.personnelID, &refs.surveyTypeID, &refs.containerTypeID,
		&refs.locationID, &refs.templateID, &refs.templateItemID,
	)
	if err != nil {
		return refs, fmt.Errorf("primary UAT master references unavailable: %w", err)
	}
	for username, targets := range map[string][]*string{
		"uat.admin":           {&refs.adminUserID},
		"uat.surveyor.raka":   {&refs.surveyorUserID, &refs.surveyorProfileID},
		"uat.surveyor.nabila": {nil, &refs.otherSurveyorProfileID},
		"uat.reviewer":        {&refs.reviewerUserID},
	} {
		if len(targets) == 2 {
			var ignoredUserID string
			userTarget := targets[0]
			if userTarget == nil {
				userTarget = &ignoredUserID
			}
			err = tx.QueryRowContext(ctx, `
				SELECT user.id,profile.id FROM users user
				JOIN surveyor_profiles profile ON profile.user_id=user.id AND profile.status='active' AND profile.deleted_at IS NULL
				WHERE user.username=? AND user.status='active' AND user.deleted_at IS NULL
			`, username).Scan(userTarget, targets[1])
		} else {
			err = tx.QueryRowContext(ctx, `SELECT id FROM users WHERE username=? AND status='active' AND deleted_at IS NULL`, username).Scan(targets[0])
		}
		if err != nil {
			return refs, fmt.Errorf("UAT actor %s unavailable: %w", username, err)
		}
	}
	err = tx.QueryRowContext(ctx, `
		SELECT
		 (SELECT id FROM cedex_locations WHERE customer_id=? AND code='L17B' AND status='active' LIMIT 1),
		 (SELECT id FROM cedex_components WHERE customer_id=? AND code='CMP17B' AND status='active' LIMIT 1),
		 (SELECT id FROM cedex_damages WHERE customer_id=? AND code='DMG17B' AND status='active' LIMIT 1),
		 (SELECT id FROM cedex_repairs WHERE customer_id=? AND code='RPR17B' AND status='active' LIMIT 1),
		 (SELECT id FROM cedex_materials WHERE customer_id=? AND code='MAT17B' AND status='active' LIMIT 1),
		 (SELECT id FROM responsibility_codes WHERE customer_id=? AND code='RESP17B' AND status='active' LIMIT 1)
	`, refs.customerID, refs.customerID, refs.customerID, refs.customerID, refs.customerID, refs.customerID).Scan(
		&refs.cedexLocationID, &refs.componentID, &refs.damageID,
		&refs.repairID, &refs.materialID, &refs.responsibilityID,
	)
	if err != nil {
		return refs, fmt.Errorf("primary UAT CEDEX references unavailable: %w", err)
	}
	return refs, nil
}

func ensurePrimaryFixtureCompatibility(ctx context.Context, tx *sql.Tx, refs primaryFixtureRefs) error {
	if _, err := tx.ExecContext(ctx, `
		INSERT IGNORE INTO customer_personnel_locations (customer_personnel_id,location_id)
		VALUES (?,?)
	`, refs.personnelID, refs.locationID); err != nil {
		return fmt.Errorf("ensure UAT Location-PIC mapping: %w", err)
	}
	if _, err := tx.ExecContext(ctx, `
		UPDATE survey_general_infos info
		JOIN surveys survey ON survey.id=info.survey_id
		JOIN job_orders job ON job.id=survey.job_order_id
		SET info.general_condition=CASE
		      WHEN info.general_condition IN ('DMG','AVL','AR') THEN info.general_condition
		      ELSE 'AVL'
		    END,
		    info.cleanliness=COALESCE(NULLIF(info.cleanliness,''),'DTY')
		WHERE job.instruction=?
	`, "Dataset "+datasetID+" - bukan data operasional"); err != nil {
		return fmt.Errorf("normalize canonical UAT Survey Sheet values: %w", err)
	}
	return nil
}

type jobFixtureSpec struct {
	jobID, jobNo, assignmentID, assignmentNo, assignmentStatus string
	containers                                                 []containerFixtureSpec
}

type containerFixtureSpec struct {
	id, number, status, surveyID, surveyNo, surveyStatus string
	withFinding                                          bool
}

func insertPrimaryJobs(ctx context.Context, tx *sql.Tx, refs primaryFixtureRefs) error {
	jobs := []jobFixtureSpec{
		{
			jobID: multiJobID, jobNo: "UAT-JOB-2026-0805-001",
			assignmentID: "e2e00001-0000-4000-8000-000000000101", assignmentNo: "UAT-ASG-2026-0805-001", assignmentStatus: "assigned",
			containers: []containerFixtureSpec{
				{id: "e2e00001-0000-4000-8000-000000000201", number: "GFTU1234560", status: "assigned"},
				{id: "e2e00001-0000-4000-8000-000000000202", number: "NPKU7654323", status: "assigned"},
			},
		},
		{
			jobID: rejectionJobID, jobNo: "UAT-JOB-2026-0805-002",
			assignmentID: "e2e00002-0000-4000-8000-000000000101", assignmentNo: "UAT-ASG-2026-0805-002", assignmentStatus: "in_progress",
			containers: []containerFixtureSpec{
				{id: "e2e00002-0000-4000-8000-000000000201", number: "NPKU1357903", status: "draft", surveyID: rejectionSurveyID, surveyNo: "UAT-SURVEY-2026-0805-002-A", surveyStatus: "draft"},
				{id: "e2e00002-0000-4000-8000-000000000202", number: "BCKU1122331", status: "approved", surveyID: "e2e00002-0000-4000-8000-000000000202", surveyNo: "UAT-SURVEY-2026-0805-002-B", surveyStatus: "approved"},
			},
		},
		{
			jobID: revisionJobID, jobNo: "UAT-JOB-2026-0805-003",
			assignmentID: "e2e00003-0000-4000-8000-000000000101", assignmentNo: "UAT-ASG-2026-0805-003", assignmentStatus: "in_progress",
			containers: []containerFixtureSpec{
				{id: "e2e00003-0000-4000-8000-000000000201", number: "BCKU2468102", status: "draft", surveyID: revisionSurveyID, surveyNo: "UAT-SURVEY-2026-0805-003-A", surveyStatus: "draft", withFinding: true},
				{id: "e2e00003-0000-4000-8000-000000000202", number: "GFTU6543216", status: "approved", surveyID: "e2e00003-0000-4000-8000-000000000302", surveyNo: "UAT-SURVEY-2026-0805-003-B", surveyStatus: "approved"},
			},
		},
	}
	for _, job := range jobs {
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO job_orders (
			 id,job_order_no,job_date,customer_id,survey_type_id,location_id,
			 pic_customer_name,reference_no,priority,deadline,instruction,status,created_by,updated_by
			) VALUES (?,?,CURRENT_DATE,?,?,?,'PIC UAT',?,'normal',DATE_ADD(NOW(),INTERVAL 14 DAY),?,'in_progress',?,?)
		`, job.jobID, job.jobNo, refs.customerID, refs.surveyTypeID, refs.locationID,
			"REF-"+job.jobNo, "Dataset "+datasetID+" - bukan data operasional", refs.adminUserID, refs.adminUserID); err != nil {
			return fmt.Errorf("insert job %s: %w", job.jobNo, err)
		}
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO assignments (id,assignment_no,job_order_id,surveyor_id,assigned_by,start_date,due_date,instruction,status)
			VALUES (?,?,?,?,?,NOW(),DATE_ADD(NOW(),INTERVAL 14 DAY),?,?)
		`, job.assignmentID, job.assignmentNo, job.jobID, refs.surveyorProfileID, refs.adminUserID, "Assignment "+datasetID, job.assignmentStatus); err != nil {
			return fmt.Errorf("insert assignment %s: %w", job.assignmentNo, err)
		}
		for _, container := range job.containers {
			if _, err := tx.ExecContext(ctx, `
				INSERT INTO job_containers (
				 id,job_order_id,container_no,container_number_input,container_type_id,iso_type_code,
				 cargo_status,status,remark
				) VALUES (?,?,?,?,?,'22G1','empty',?,?)
			`, container.id, job.jobID, container.number, container.number, refs.containerTypeID, container.status, datasetID); err != nil {
				return fmt.Errorf("insert container %s: %w", container.number, err)
			}
			if _, err := tx.ExecContext(ctx, `
				INSERT INTO assignment_containers (id,assignment_id,job_container_id)
				VALUES (UUID(),?,?)
			`, job.assignmentID, container.id); err != nil {
				return err
			}
			if container.surveyID != "" {
				if err := insertSurveyFixture(ctx, tx, refs, job, container); err != nil {
					return err
				}
			}
		}
	}
	return nil
}

func insertSurveyFixture(ctx context.Context, tx *sql.Tx, refs primaryFixtureRefs, job jobFixtureSpec, container containerFixtureSpec) error {
	approvedAt := any(nil)
	submittedAt := any(nil)
	surveyResult := any(nil)
	if container.surveyStatus == "approved" {
		approvedAt = "2026-08-05 10:00:00"
		submittedAt = "2026-08-05 09:00:00"
		surveyResult = "cargo_worthy"
	}
	if _, err := tx.ExecContext(ctx, `
		INSERT INTO surveys (
		 id,survey_no,job_order_id,job_container_id,assignment_id,surveyor_id,survey_type_id,
		 phase,survey_round,is_active,checklist_template_id,status,survey_result,started_at,submitted_at,approved_at
		) VALUES (?,?,?,?,?,?,?,'initial',1,1,?,?,?,DATE_SUB(NOW(),INTERVAL 1 DAY),?,?)
	`, container.surveyID, container.surveyNo, job.jobID, container.id, job.assignmentID,
		refs.surveyorProfileID, refs.surveyTypeID, refs.templateID, container.surveyStatus, surveyResult, submittedAt, approvedAt); err != nil {
		return fmt.Errorf("insert survey %s: %w", container.surveyNo, err)
	}
	if _, err := tx.ExecContext(ctx, `
		INSERT INTO survey_general_infos (
		 survey_id,container_no,container_type_id,iso_type_code,customer_id,location_id,
		 survey_date_time,cargo_status,general_condition,cleanliness,container_lifecycle,weather,general_remark
		) VALUES (?,?,?,'22G1',?,?,NOW(),'empty','AVL','DTY','existing','Cerah',?)
	`, container.surveyID, container.number, refs.containerTypeID, refs.customerID, refs.locationID, datasetID); err != nil {
		return err
	}
	checklistID := uuid.NewString()
	response := "yes"
	if container.withFinding {
		response = "no"
	}
	if _, err := tx.ExecContext(ctx, `
		INSERT INTO survey_checklist_responses (
		 id,survey_id,template_item_id,item_code,item_label,response_value,response_type,
		 is_required,is_critical,requires_attachment,display_order
		) SELECT ?,?,item.id,item.item_code,item.item_label,?,item.response_type,
		 item.is_required,item.is_critical,0,item.display_order
		 FROM fitness_checklist_template_items item WHERE item.id=?
	`, checklistID, container.surveyID, response, refs.templateItemID); err != nil {
		return err
	}
	if container.withFinding {
		damageFixtureID := "e2e00003-0000-4000-8000-000000000601"
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO survey_damages (
			 id,survey_id,checklist_response_id,damage_no,face,internal_location,cedex_location_id,
			 component_id,damage_id,repair_id,material_id,responsibility_id,finding_description,
			 location_selection_snapshot,severity,is_repair_required,is_cargo_worthy_impact,remark,created_by,updated_by
			) VALUES (?,?,?,'D-001','left','L1',?,?,?,?,?,?,?,
			 JSON_OBJECT('input_mode','manual','code','L17B','face','left','grid_code','L1','container_size','20'),
			 'minor',1,0,?,?,?)
		`, damageFixtureID, container.surveyID, checklistID, refs.cedexLocationID, refs.componentID,
			refs.damageID, refs.repairID, refs.materialID, refs.responsibilityID,
			"Temuan UAT pada panel kiri", datasetID, refs.surveyorUserID, refs.surveyorUserID); err != nil {
			return fmt.Errorf("insert UAT finding: %w", err)
		}
		if _, err := tx.ExecContext(ctx, `INSERT INTO survey_damage_counters (survey_id,last_number) VALUES (?,1)`, container.surveyID); err != nil {
			return err
		}
	}
	if container.surveyStatus == "approved" {
		if _, err := tx.ExecContext(ctx, `
			INSERT INTO survey_approvals (id,survey_id,reviewer_id,decision,review_note,final_result,revision_no,reviewed_at)
			VALUES (UUID(),?,?,'approved','Fixture terminal UAT','cargo_worthy',0,'2026-08-05 10:00:00')
		`, container.surveyID, refs.reviewerUserID); err != nil {
			return err
		}
	}
	return nil
}

func insertIsolationFixture(ctx context.Context, tx *sql.Tx, refs primaryFixtureRefs) error {
	const (
		customerID      = "e2e00004-0000-4000-8000-000000000010"
		locationID      = "e2e00004-0000-4000-8000-000000000020"
		surveyTypeID    = "e2e00004-0000-4000-8000-000000000030"
		containerTypeID = "e2e00004-0000-4000-8000-000000000040"
		templateID      = "e2e00004-0000-4000-8000-000000000050"
		templateItemID  = "e2e00004-0000-4000-8000-000000000060"
		assignmentID    = "e2e00004-0000-4000-8000-000000000101"
		containerID     = "e2e00004-0000-4000-8000-000000000201"
		checklistID     = "e2e00004-0000-4000-8000-000000000501"
	)
	statements := []struct {
		query string
		args  []any
	}{
		{`INSERT INTO customers (id,customer_code,customer_name,address,status,created_by,updated_by) VALUES (?,?,?,'UAT isolation only','active',?,?)`, []any{customerID, "UAT-ISOLATION-CROSS-20260811", "UAT Customer Isolation Cross Scope", refs.adminUserID, refs.adminUserID}},
		{`INSERT INTO locations (id,customer_id,location_code,location_name,location_type,address,status) VALUES (?,?,?,'Lokasi Isolation UAT','depot','UAT isolation only','active')`, []any{locationID, customerID, "UAT-ISO-LOC"}},
		{`INSERT INTO survey_types (id,customer_id,code,name,description,status) VALUES (?,?,?,'Survey Isolation UAT',?,'active')`, []any{surveyTypeID, customerID, "UAT-ISO-SURVEY", datasetID}},
		{`INSERT INTO container_types (id,customer_id,code,iso_code,size,type_name,description,status) VALUES (?,?,?,'22G1','20','Dry UAT Isolation',?,'active')`, []any{containerTypeID, customerID, "UAT-ISO-CT", datasetID}},
		{`INSERT INTO fitness_checklist_templates (id,customer_id,template_code,template_name,survey_type_id,container_type_id,description,version_no,status,created_by,approved_by,approved_at) VALUES (?,?,?,'Checklist Isolation UAT',?,?,?,1,'active',?,?,NOW())`, []any{templateID, customerID, "UAT-ISO-TPL", surveyTypeID, containerTypeID, datasetID, refs.adminUserID, refs.adminUserID}},
		{`INSERT INTO fitness_checklist_template_items (id,template_id,item_code,item_label,response_type,is_required,is_critical,display_order,status) VALUES (?,?,?,'Item Isolation UAT','ok_not_ok',1,0,1,'active')`, []any{templateItemID, templateID, "UAT-ISO-ITEM"}},
		{`INSERT INTO job_orders (id,job_order_no,job_date,customer_id,survey_type_id,location_id,reference_no,instruction,status,created_by,updated_by) VALUES (?,? ,CURRENT_DATE,?,?,?,'UAT-ISO-REF',?,'in_progress',?,?)`, []any{isolationJobID, "UAT-ISOLATION-20260811-001", customerID, surveyTypeID, locationID, datasetID, refs.adminUserID, refs.adminUserID}},
		{`INSERT INTO job_containers (id,job_order_id,container_no,container_number_input,container_type_id,iso_type_code,cargo_status,status,remark) VALUES (?,?,?, ?,?,'22G1','empty','draft',?)`, []any{containerID, isolationJobID, "UATU0000015", "UATU0000015", containerTypeID, datasetID}},
		{`INSERT INTO assignments (id,assignment_no,job_order_id,surveyor_id,assigned_by,start_date,due_date,instruction,status) VALUES (?,? ,?,?,?,NOW(),DATE_ADD(NOW(),INTERVAL 14 DAY),?,'in_progress')`, []any{assignmentID, "UAT-ASG-ISOLATION-001", isolationJobID, refs.otherSurveyorProfileID, refs.adminUserID, datasetID}},
		{`INSERT INTO assignment_containers (id,assignment_id,job_container_id) VALUES (UUID(),?,?)`, []any{assignmentID, containerID}},
		{`INSERT INTO surveys (id,survey_no,job_order_id,job_container_id,assignment_id,surveyor_id,survey_type_id,phase,survey_round,is_active,checklist_template_id,status,started_at) VALUES (?,? ,?,?,?,?,?,'initial',1,1,?,'draft',NOW())`, []any{isolationSurveyID, "UAT-SURVEY-ISOLATION-001", isolationJobID, containerID, assignmentID, refs.otherSurveyorProfileID, surveyTypeID, templateID}},
		{`INSERT INTO survey_general_infos (survey_id,container_no,container_type_id,iso_type_code,customer_id,location_id,cargo_status,general_condition,cleanliness,container_lifecycle,general_remark) VALUES (?,? ,?,'22G1',?,?,'empty','AVL','DTY','existing',?)`, []any{isolationSurveyID, "UATU0000015", containerTypeID, customerID, locationID, datasetID}},
		{`INSERT INTO survey_checklist_responses (id,survey_id,template_item_id,item_code,item_label,response_value,response_type,is_required,is_critical,requires_attachment,display_order) VALUES (?,?,?,'UAT-ISO-ITEM','Item Isolation UAT','yes','ok_not_ok',1,0,0,1)`, []any{checklistID, isolationSurveyID, templateItemID}},
	}
	for _, statement := range statements {
		if _, err := tx.ExecContext(ctx, statement.query, statement.args...); err != nil {
			return fmt.Errorf("insert customer isolation fixture: %w", err)
		}
	}
	return nil
}
