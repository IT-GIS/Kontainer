-- MySQL dump 10.13  Distrib 8.4.3, for Win64 (x86_64)
--
-- Host: localhost    Database: kontainer_final_ci2_20260811_uat
-- ------------------------------------------------------
-- Server version	8.4.3

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `application_containers`
--

DROP TABLE IF EXISTS `application_containers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `application_containers` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `fitness_application_id` char(36) NOT NULL,
  `container_no` varchar(20) NOT NULL,
  `owner_code` varchar(4) DEFAULT NULL,
  `serial_number` varchar(10) DEFAULT NULL,
  `check_digit` varchar(2) DEFAULT NULL,
  `check_digit_status` varchar(30) NOT NULL DEFAULT 'not_checked',
  `check_digit_override_reason` text,
  `container_type_id` char(36) DEFAULT NULL,
  `iso_type_code` varchar(20) DEFAULT NULL,
  `workflow_status` varchar(50) NOT NULL DEFAULT 'draft',
  `final_fitness_result` varchar(50) NOT NULL DEFAULT 'pending',
  `restriction_status` varchar(50) NOT NULL DEFAULT 'none',
  `approval_status` varchar(50) NOT NULL DEFAULT 'not_ready',
  `remark` text,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_application_containers_application_container_no` (`fitness_application_id`,`container_no`),
  KEY `idx_application_containers_application` (`fitness_application_id`),
  KEY `idx_application_containers_container_type` (`container_type_id`),
  KEY `idx_application_containers_container_no` (`container_no`),
  KEY `idx_application_containers_workflow_status` (`workflow_status`),
  KEY `idx_application_containers_final_result` (`final_fitness_result`),
  KEY `idx_application_containers_deleted_at` (`deleted_at`),
  CONSTRAINT `fk_application_containers_application` FOREIGN KEY (`fitness_application_id`) REFERENCES `fitness_applications` (`id`),
  CONSTRAINT `fk_application_containers_container_type` FOREIGN KEY (`container_type_id`) REFERENCES `container_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application_containers`
--

LOCK TABLES `application_containers` WRITE;
/*!40000 ALTER TABLE `application_containers` DISABLE KEYS */;
/*!40000 ALTER TABLE `application_containers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assignment_containers`
--

DROP TABLE IF EXISTS `assignment_containers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assignment_containers` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `assignment_id` char(36) NOT NULL,
  `job_container_id` char(36) NOT NULL,
  `assigned_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `unassigned_at` datetime(6) DEFAULT NULL,
  `unassigned_reason` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `assignment_id` (`assignment_id`,`job_container_id`),
  KEY `idx_assignment_containers_active_container` (`job_container_id`),
  KEY `idx_assignment_containers_assignment` (`assignment_id`),
  CONSTRAINT `fk_assignment_containers_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`),
  CONSTRAINT `fk_assignment_containers_job_container` FOREIGN KEY (`job_container_id`) REFERENCES `job_containers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignment_containers`
--

LOCK TABLES `assignment_containers` WRITE;
/*!40000 ALTER TABLE `assignment_containers` DISABLE KEYS */;
/*!40000 ALTER TABLE `assignment_containers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `assignments`
--

DROP TABLE IF EXISTS `assignments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `assignments` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `assignment_no` varchar(80) NOT NULL,
  `job_order_id` char(36) NOT NULL,
  `surveyor_id` char(36) NOT NULL,
  `assigned_by` char(36) NOT NULL,
  `assigned_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `start_date` datetime(6) DEFAULT NULL,
  `due_date` datetime(6) DEFAULT NULL,
  `instruction` text,
  `status` varchar(50) NOT NULL DEFAULT 'assigned',
  `cancel_reason` text,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `assignment_no` (`assignment_no`),
  KEY `idx_assignments_job` (`job_order_id`),
  KEY `idx_assignments_surveyor` (`surveyor_id`),
  KEY `idx_assignments_status` (`status`),
  KEY `fk_assignments_assigned_by` (`assigned_by`),
  CONSTRAINT `fk_assignments_assigned_by` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_assignments_job_order` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`id`),
  CONSTRAINT `fk_assignments_surveyor` FOREIGN KEY (`surveyor_id`) REFERENCES `surveyor_profiles` (`id`),
  CONSTRAINT `chk_assignments_status` CHECK ((`status` in (_utf8mb4'assigned',_utf8mb4'accepted',_utf8mb4'in_progress',_utf8mb4'completed',_utf8mb4'cancelled',_utf8mb4'reassigned')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `assignments`
--

LOCK TABLES `assignments` WRITE;
/*!40000 ALTER TABLE `assignments` DISABLE KEYS */;
/*!40000 ALTER TABLE `assignments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `audit_logs` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `user_id` char(36) DEFAULT NULL,
  `active_role` varchar(50) DEFAULT NULL,
  `action` varchar(120) NOT NULL,
  `entity_type` varchar(100) NOT NULL,
  `entity_id` char(36) DEFAULT NULL,
  `old_state` varchar(50) DEFAULT NULL,
  `new_state` varchar(50) DEFAULT NULL,
  `old_value` json DEFAULT NULL,
  `new_value` json DEFAULT NULL,
  `reason` text,
  `request_id` varchar(80) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_audit_logs_user` (`user_id`),
  KEY `idx_audit_logs_entity` (`entity_type`,`entity_id`),
  KEY `idx_audit_logs_action` (`action`),
  KEY `idx_audit_logs_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `authorized_signers`
--

DROP TABLE IF EXISTS `authorized_signers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `authorized_signers` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `signer_name` varchar(180) NOT NULL,
  `position_title` varchar(180) NOT NULL,
  `employee_no` varchar(80) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `signature_file_id` char(36) DEFAULT NULL,
  `valid_from` date DEFAULT NULL,
  `valid_until` date DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_authorized_signers_status` (`status`),
  KEY `idx_authorized_signers_deleted_at` (`deleted_at`),
  KEY `fk_authorized_signers_signature_file` (`signature_file_id`),
  CONSTRAINT `fk_authorized_signers_signature_file` FOREIGN KEY (`signature_file_id`) REFERENCES `file_objects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `authorized_signers`
--

LOCK TABLES `authorized_signers` WRITE;
/*!40000 ALTER TABLE `authorized_signers` DISABLE KEYS */;
/*!40000 ALTER TABLE `authorized_signers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cedex_code_proposals`
--

DROP TABLE IF EXISTS `cedex_code_proposals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cedex_code_proposals` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `survey_id` char(36) NOT NULL,
  `customer_id` char(36) NOT NULL,
  `proposed_by` char(36) NOT NULL,
  `code_type` varchar(30) NOT NULL,
  `code` varchar(4) NOT NULL,
  `description` text NOT NULL,
  `reason` text NOT NULL,
  `evidence_file_id` char(36) DEFAULT NULL,
  `notes` text,
  `status` varchar(30) NOT NULL DEFAULT 'pending',
  `review_note` text,
  `reviewed_by` char(36) DEFAULT NULL,
  `reviewed_at` datetime(6) DEFAULT NULL,
  `master_entity_id` char(36) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `fk_cedex_code_proposals_evidence` (`evidence_file_id`),
  KEY `fk_cedex_code_proposals_reviewed_by` (`reviewed_by`),
  KEY `idx_cedex_code_proposals_customer_status` (`customer_id`,`status`),
  KEY `idx_cedex_code_proposals_survey` (`survey_id`),
  KEY `idx_cedex_code_proposals_proposed_by` (`proposed_by`),
  KEY `idx_cedex_code_proposals_created_at` (`created_at`),
  CONSTRAINT `fk_cedex_code_proposals_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_cedex_code_proposals_evidence` FOREIGN KEY (`evidence_file_id`) REFERENCES `file_objects` (`id`),
  CONSTRAINT `fk_cedex_code_proposals_proposed_by` FOREIGN KEY (`proposed_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_cedex_code_proposals_reviewed_by` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_cedex_code_proposals_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`),
  CONSTRAINT `chk_cedex_code_proposals_status` CHECK ((`status` in (_cp850'pending',_cp850'approved',_cp850'rejected'))),
  CONSTRAINT `chk_cedex_code_proposals_type` CHECK ((`code_type` in (_cp850'location',_cp850'component',_cp850'damage',_cp850'action_repair',_cp850'material')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cedex_code_proposals`
--

LOCK TABLES `cedex_code_proposals` WRITE;
/*!40000 ALTER TABLE `cedex_code_proposals` DISABLE KEYS */;
/*!40000 ALTER TABLE `cedex_code_proposals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cedex_components`
--

DROP TABLE IF EXISTS `cedex_components`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cedex_components` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_id` char(36) DEFAULT NULL,
  `code` varchar(30) NOT NULL,
  `component_name` varchar(150) NOT NULL,
  `assembly_group` varchar(100) DEFAULT NULL,
  `applicable_face` varchar(50) DEFAULT NULL,
  `is_structural_critical` tinyint(1) NOT NULL DEFAULT '0',
  `description` text,
  `source_type` varchar(30) NOT NULL DEFAULT 'legacy',
  `source_reason` text,
  `display_order` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cedex_components_customer_code` (`customer_id`,`code`),
  KEY `idx_cedex_components_status` (`status`),
  KEY `idx_cedex_components_customer` (`customer_id`),
  KEY `idx_cedex_components_customer_status` (`customer_id`,`status`),
  KEY `idx_cedex_components_customer_order` (`customer_id`,`display_order`),
  KEY `idx_cedex_components_source` (`source_type`),
  CONSTRAINT `fk_cedex_components_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `chk_cedex_components_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cedex_components`
--

LOCK TABLES `cedex_components` WRITE;
/*!40000 ALTER TABLE `cedex_components` DISABLE KEYS */;
INSERT INTO `cedex_components` VALUES ('8ad5a28d-9541-11f1-9595-002b67818c25',NULL,'SP','Side Panel',NULL,NULL,0,'Side panel','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5a7c0-9541-11f1-9595-002b67818c25',NULL,'RP','Roof Panel',NULL,NULL,0,'Roof panel','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5a96c-9541-11f1-9595-002b67818c25',NULL,'FP','Front Panel',NULL,NULL,0,'Front panel','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5aaeb-9541-11f1-9595-002b67818c25',NULL,'DP','Door Panel',NULL,NULL,0,'Door panel','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5ac44-9541-11f1-9595-002b67818c25',NULL,'DG','Door Gasket',NULL,NULL,0,'Door gasket','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5ad96-9541-11f1-9595-002b67818c25',NULL,'LB','Locking Bar',NULL,NULL,0,'Locking bar','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5af2c-9541-11f1-9595-002b67818c25',NULL,'CK','Cam Keeper',NULL,NULL,0,'Cam keeper','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5b078-9541-11f1-9595-002b67818c25',NULL,'FB','Floor Board',NULL,NULL,0,'Floor board','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5b197-9541-11f1-9595-002b67818c25',NULL,'CM','Cross Member',NULL,NULL,0,'Cross member','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5b259-9541-11f1-9595-002b67818c25',NULL,'CP','Corner Post',NULL,NULL,0,'Corner post','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5b322-9541-11f1-9595-002b67818c25',NULL,'CC','Corner Casting',NULL,NULL,0,'Corner casting','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5b44f-9541-11f1-9595-002b67818c25',NULL,'BSR','Bottom Side Rail',NULL,NULL,0,'Bottom side rail','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5b5c8-9541-11f1-9595-002b67818c25',NULL,'TSR','Top Side Rail',NULL,NULL,0,'Top side rail','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5b70a-9541-11f1-9595-002b67818c25',NULL,'FKP','Forklift Pocket',NULL,NULL,0,'Forklift pocket','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5b834-9541-11f1-9595-002b67818c25',NULL,'VN','Ventilator',NULL,NULL,0,'Ventilator','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883'),('8ad5b9be-9541-11f1-9595-002b67818c25',NULL,'CSC','CSC Plate',NULL,NULL,0,'CSC plate','legacy',NULL,0,'active','2026-08-11 12:00:15.985883','2026-08-11 12:00:15.985883');
/*!40000 ALTER TABLE `cedex_components` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cedex_damage_decision_rules`
--

DROP TABLE IF EXISTS `cedex_damage_decision_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cedex_damage_decision_rules` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_id` char(36) DEFAULT NULL,
  `damage_id` char(36) NOT NULL,
  `component_id` char(36) DEFAULT NULL,
  `location_id` char(36) DEFAULT NULL,
  `material_id` char(36) DEFAULT NULL,
  `container_type_id` char(36) DEFAULT NULL,
  `container_lifecycle` varchar(30) DEFAULT NULL,
  `inspection_reference_id` char(36) NOT NULL,
  `measurement_field` varchar(30) NOT NULL,
  `comparison_operator` varchar(20) NOT NULL,
  `minimum_value` decimal(14,4) DEFAULT NULL,
  `maximum_value` decimal(14,4) DEFAULT NULL,
  `unit` varchar(30) DEFAULT NULL,
  `decision_result` varchar(40) NOT NULL,
  `recommended_action_id` char(36) DEFAULT NULL,
  `decision_note` text,
  `priority` int NOT NULL DEFAULT '0',
  `valid_from` date DEFAULT NULL,
  `valid_until` date DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_cedex_decision_rules_customer_damage` (`customer_id`,`damage_id`,`status`),
  KEY `idx_cedex_decision_rules_component` (`component_id`),
  KEY `idx_cedex_decision_rules_location` (`location_id`),
  KEY `idx_cedex_decision_rules_material` (`material_id`),
  KEY `idx_cedex_decision_rules_container_type` (`container_type_id`),
  KEY `idx_cedex_decision_rules_reference` (`inspection_reference_id`),
  KEY `idx_cedex_decision_rules_action` (`recommended_action_id`),
  KEY `idx_cedex_decision_rules_validity` (`valid_from`,`valid_until`),
  KEY `fk_cedex_decision_rules_damage` (`damage_id`),
  CONSTRAINT `fk_cedex_decision_rules_action` FOREIGN KEY (`recommended_action_id`) REFERENCES `cedex_repairs` (`id`),
  CONSTRAINT `fk_cedex_decision_rules_component` FOREIGN KEY (`component_id`) REFERENCES `cedex_components` (`id`),
  CONSTRAINT `fk_cedex_decision_rules_container_type` FOREIGN KEY (`container_type_id`) REFERENCES `container_types` (`id`),
  CONSTRAINT `fk_cedex_decision_rules_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_cedex_decision_rules_damage` FOREIGN KEY (`damage_id`) REFERENCES `cedex_damages` (`id`),
  CONSTRAINT `fk_cedex_decision_rules_location` FOREIGN KEY (`location_id`) REFERENCES `cedex_locations` (`id`),
  CONSTRAINT `fk_cedex_decision_rules_material` FOREIGN KEY (`material_id`) REFERENCES `cedex_materials` (`id`),
  CONSTRAINT `fk_cedex_decision_rules_reference` FOREIGN KEY (`inspection_reference_id`) REFERENCES `inspection_test_parameters` (`id`),
  CONSTRAINT `chk_cedex_decision_rules_lifecycle` CHECK (((`container_lifecycle` is null) or (`container_lifecycle` in (_utf8mb4'new',_utf8mb4'existing')))),
  CONSTRAINT `chk_cedex_decision_rules_measurement` CHECK ((`measurement_field` in (_cp850'length',_cp850'width',_cp850'depth',_cp850'thickness',_cp850'quantity',_cp850'area',_cp850'manual_assessment'))),
  CONSTRAINT `chk_cedex_decision_rules_operator` CHECK ((`comparison_operator` in (_utf8mb4'lt',_utf8mb4'lte',_utf8mb4'eq',_utf8mb4'gt',_utf8mb4'gte',_utf8mb4'between',_utf8mb4'manual'))),
  CONSTRAINT `chk_cedex_decision_rules_priority` CHECK ((`priority` >= 0)),
  CONSTRAINT `chk_cedex_decision_rules_result` CHECK ((`decision_result` in (_utf8mb4'passed',_utf8mb4'need_repair',_utf8mb4'need_reinspection',_utf8mb4'not_passed',_utf8mb4'manual_review'))),
  CONSTRAINT `chk_cedex_decision_rules_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cedex_damage_decision_rules`
--

LOCK TABLES `cedex_damage_decision_rules` WRITE;
/*!40000 ALTER TABLE `cedex_damage_decision_rules` DISABLE KEYS */;
/*!40000 ALTER TABLE `cedex_damage_decision_rules` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cedex_damages`
--

DROP TABLE IF EXISTS `cedex_damages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cedex_damages` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_id` char(36) DEFAULT NULL,
  `code` varchar(30) NOT NULL,
  `damage_name` varchar(150) NOT NULL,
  `damage_category` varchar(50) DEFAULT NULL,
  `default_severity` varchar(30) NOT NULL DEFAULT 'minor',
  `requires_dimension` tinyint(1) NOT NULL DEFAULT '0',
  `default_action_id` char(36) DEFAULT NULL,
  `default_inspection_reference_id` char(36) DEFAULT NULL,
  `description` text,
  `source_type` varchar(30) NOT NULL DEFAULT 'legacy',
  `source_reason` text,
  `display_order` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cedex_damages_customer_code` (`customer_id`,`code`),
  KEY `idx_cedex_damages_status` (`status`),
  KEY `idx_cedex_damages_customer` (`customer_id`),
  KEY `idx_cedex_damages_customer_status` (`customer_id`,`status`),
  KEY `idx_cedex_damages_customer_order` (`customer_id`,`display_order`),
  KEY `idx_cedex_damages_default_action` (`default_action_id`),
  KEY `idx_cedex_damages_default_reference` (`default_inspection_reference_id`),
  KEY `idx_cedex_damages_source` (`source_type`),
  CONSTRAINT `fk_cedex_damages_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_cedex_damages_default_action` FOREIGN KEY (`default_action_id`) REFERENCES `cedex_repairs` (`id`),
  CONSTRAINT `fk_cedex_damages_default_reference` FOREIGN KEY (`default_inspection_reference_id`) REFERENCES `inspection_test_parameters` (`id`),
  CONSTRAINT `chk_cedex_damages_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cedex_damages`
--

LOCK TABLES `cedex_damages` WRITE;
/*!40000 ALTER TABLE `cedex_damages` DISABLE KEYS */;
INSERT INTO `cedex_damages` VALUES ('8ad64755-9541-11f1-9595-002b67818c25',NULL,'DT','Dent',NULL,'minor',0,NULL,NULL,'Dent','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad659de-9541-11f1-9595-002b67818c25',NULL,'HL','Hole',NULL,'minor',0,NULL,NULL,'Hole','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad65c68-9541-11f1-9595-002b67818c25',NULL,'CR','Crack',NULL,'minor',0,NULL,NULL,'Crack','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad65ddc-9541-11f1-9595-002b67818c25',NULL,'BN','Bent',NULL,'minor',0,NULL,NULL,'Bent','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad65f89-9541-11f1-9595-002b67818c25',NULL,'BR','Broken',NULL,'minor',0,NULL,NULL,'Broken','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad66103-9541-11f1-9595-002b67818c25',NULL,'MS','Missing',NULL,'minor',0,NULL,NULL,'Missing','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad6626f-9541-11f1-9595-002b67818c25',NULL,'RS','Rust',NULL,'minor',0,NULL,NULL,'Rust','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad663bd-9541-11f1-9595-002b67818c25',NULL,'CO','Corrosion',NULL,'minor',0,NULL,NULL,'Corrosion','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad664e5-9541-11f1-9595-002b67818c25',NULL,'TO','Torn',NULL,'minor',0,NULL,NULL,'Torn','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad66620-9541-11f1-9595-002b67818c25',NULL,'LS','Loose',NULL,'minor',0,NULL,NULL,'Loose','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad667d2-9541-11f1-9595-002b67818c25',NULL,'DY','Dirty',NULL,'minor',0,NULL,NULL,'Dirty','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad66908-9541-11f1-9595-002b67818c25',NULL,'WT','Wet',NULL,'minor',0,NULL,NULL,'Wet','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad66a5d-9541-11f1-9595-002b67818c25',NULL,'OD','Odor',NULL,'minor',0,NULL,NULL,'Odor','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad66ba1-9541-11f1-9595-002b67818c25',NULL,'OS','Oil Stain',NULL,'minor',0,NULL,NULL,'Oil stain','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad66d1c-9541-11f1-9595-002b67818c25',NULL,'BM','Burn Mark',NULL,'minor',0,NULL,NULL,'Burn mark','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad66e78-9541-11f1-9595-002b67818c25',NULL,'DL','Delamination',NULL,'minor',0,NULL,NULL,'Delamination','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad66fba-9541-11f1-9595-002b67818c25',NULL,'LK','Leakage',NULL,'minor',0,NULL,NULL,'Leakage','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091'),('8ad6710c-9541-11f1-9595-002b67818c25',NULL,'IR','Improper Repair',NULL,'minor',0,NULL,NULL,'Improper repair','legacy',NULL,0,'active','2026-08-11 12:00:15.990091','2026-08-11 12:00:15.990091');
/*!40000 ALTER TABLE `cedex_damages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cedex_locations`
--

DROP TABLE IF EXISTS `cedex_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cedex_locations` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_id` char(36) DEFAULT NULL,
  `input_mode` varchar(20) NOT NULL DEFAULT 'manual',
  `sector_code` varchar(1) DEFAULT NULL,
  `vertical_code` varchar(1) DEFAULT NULL,
  `start_section` varchar(1) DEFAULT NULL,
  `end_section` varchar(1) DEFAULT NULL,
  `transverse_span` varchar(10) DEFAULT NULL,
  `code` varchar(30) NOT NULL,
  `face` varchar(50) NOT NULL,
  `grid_code` varchar(30) NOT NULL,
  `cedex_mapping_code` varchar(50) DEFAULT NULL,
  `container_size` varchar(20) DEFAULT NULL,
  `description` text,
  `source_type` varchar(30) NOT NULL DEFAULT 'legacy',
  `source_reason` text,
  `display_order` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cedex_locations_customer_code` (`customer_id`,`code`),
  KEY `idx_cedex_locations_face` (`face`),
  KEY `idx_cedex_locations_status` (`status`),
  KEY `idx_cedex_locations_customer` (`customer_id`),
  KEY `idx_cedex_locations_customer_status` (`customer_id`,`status`),
  KEY `idx_cedex_locations_source` (`source_type`),
  CONSTRAINT `fk_cedex_locations_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `chk_cedex_locations_container_size` CHECK (((`container_size` is null) or (`container_size` in (_utf8mb4'all',_utf8mb4'20',_utf8mb4'40',_utf8mb4'45')))),
  CONSTRAINT `chk_cedex_locations_display_order` CHECK ((`display_order` >= 0)),
  CONSTRAINT `chk_cedex_locations_face` CHECK ((`face` in (_utf8mb4'left',_utf8mb4'right',_utf8mb4'front',_utf8mb4'door',_utf8mb4'roof',_utf8mb4'floor',_utf8mb4'understructure'))),
  CONSTRAINT `chk_cedex_locations_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cedex_locations`
--

LOCK TABLES `cedex_locations` WRITE;
/*!40000 ALTER TABLE `cedex_locations` DISABLE KEYS */;
INSERT INTO `cedex_locations` VALUES ('8ad515e7-9541-11f1-9595-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'L1','left','L1',NULL,'all','Left side section 1','legacy',NULL,1,'active','2026-08-11 12:00:15.982308','2026-08-11 12:00:15.982308'),('8ad51abc-9541-11f1-9595-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'L2','left','L2',NULL,'all','Left side section 2','legacy',NULL,2,'active','2026-08-11 12:00:15.982308','2026-08-11 12:00:15.982308'),('8ad51c8c-9541-11f1-9595-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'L3','left','L3',NULL,'all','Left side section 3','legacy',NULL,3,'active','2026-08-11 12:00:15.982308','2026-08-11 12:00:15.982308'),('8ad51e4a-9541-11f1-9595-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'R1','right','R1',NULL,'all','Right side section 1','legacy',NULL,1,'active','2026-08-11 12:00:15.982308','2026-08-11 12:00:15.982308'),('8ad52019-9541-11f1-9595-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'R2','right','R2',NULL,'all','Right side section 2','legacy',NULL,2,'active','2026-08-11 12:00:15.982308','2026-08-11 12:00:15.982308'),('8ad521d3-9541-11f1-9595-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'D1','door','D1',NULL,'all','Door end section 1','legacy',NULL,1,'active','2026-08-11 12:00:15.982308','2026-08-11 12:00:15.982308'),('8ad5236c-9541-11f1-9595-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'F1','front','F1',NULL,'all','Front end section 1','legacy',NULL,1,'active','2026-08-11 12:00:15.982308','2026-08-11 12:00:15.982308'),('8ad524da-9541-11f1-9595-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'T1','roof','T1',NULL,'all','Roof section 1','legacy',NULL,1,'active','2026-08-11 12:00:15.982308','2026-08-11 12:00:15.982308'),('8ad52633-9541-11f1-9595-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'FL1','floor','FL1',NULL,'all','Floor section 1','legacy',NULL,1,'active','2026-08-11 12:00:15.982308','2026-08-11 12:00:15.982308'),('8ad52734-9541-11f1-9595-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'U1','understructure','U1',NULL,'all','Understructure section 1','legacy',NULL,1,'active','2026-08-11 12:00:15.982308','2026-08-11 12:00:15.982308');
/*!40000 ALTER TABLE `cedex_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cedex_materials`
--

DROP TABLE IF EXISTS `cedex_materials`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cedex_materials` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_id` char(36) DEFAULT NULL,
  `code` varchar(30) NOT NULL,
  `material_name` varchar(150) NOT NULL,
  `description` text,
  `source_type` varchar(30) NOT NULL DEFAULT 'legacy',
  `source_reason` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cedex_materials_customer_code` (`customer_id`,`code`),
  KEY `idx_cedex_materials_status` (`status`),
  KEY `idx_cedex_materials_customer` (`customer_id`),
  KEY `idx_cedex_materials_customer_status` (`customer_id`,`status`),
  KEY `idx_cedex_materials_source` (`source_type`),
  CONSTRAINT `fk_cedex_materials_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `chk_cedex_materials_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cedex_materials`
--

LOCK TABLES `cedex_materials` WRITE;
/*!40000 ALTER TABLE `cedex_materials` DISABLE KEYS */;
INSERT INTO `cedex_materials` VALUES ('8ad7d420-9541-11f1-9595-002b67818c25',NULL,'STL','Steel','Steel','legacy',NULL,'active','2026-08-11 12:00:16.000345','2026-08-11 12:00:16.000345'),('8ad7d8c9-9541-11f1-9595-002b67818c25',NULL,'AL','Aluminium','Aluminium','legacy',NULL,'active','2026-08-11 12:00:16.000345','2026-08-11 12:00:16.000345'),('8ad7db55-9541-11f1-9595-002b67818c25',NULL,'PLY','Plywood','Plywood','legacy',NULL,'active','2026-08-11 12:00:16.000345','2026-08-11 12:00:16.000345'),('8ad7dd00-9541-11f1-9595-002b67818c25',NULL,'RUB','Rubber','Rubber','legacy',NULL,'active','2026-08-11 12:00:16.000345','2026-08-11 12:00:16.000345'),('8ad7de7a-9541-11f1-9595-002b67818c25',NULL,'PLS','Plastic','Plastic','legacy',NULL,'active','2026-08-11 12:00:16.000345','2026-08-11 12:00:16.000345');
/*!40000 ALTER TABLE `cedex_materials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cedex_repairs`
--

DROP TABLE IF EXISTS `cedex_repairs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cedex_repairs` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_id` char(36) DEFAULT NULL,
  `code` varchar(30) NOT NULL,
  `repair_name` varchar(150) NOT NULL,
  `result_mapping` varchar(50) DEFAULT NULL,
  `requires_reinspection` tinyint(1) NOT NULL DEFAULT '0',
  `description` text,
  `source_type` varchar(30) NOT NULL DEFAULT 'legacy',
  `source_reason` text,
  `display_order` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cedex_repairs_customer_code` (`customer_id`,`code`),
  KEY `idx_cedex_repairs_status` (`status`),
  KEY `idx_cedex_repairs_customer` (`customer_id`),
  KEY `idx_cedex_repairs_customer_status` (`customer_id`,`status`),
  KEY `idx_cedex_repairs_customer_order` (`customer_id`,`display_order`),
  KEY `idx_cedex_repairs_source` (`source_type`),
  CONSTRAINT `fk_cedex_repairs_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `chk_cedex_repairs_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cedex_repairs`
--

LOCK TABLES `cedex_repairs` WRITE;
/*!40000 ALTER TABLE `cedex_repairs` DISABLE KEYS */;
INSERT INTO `cedex_repairs` VALUES ('8ad73b12-9541-11f1-9595-002b67818c25',NULL,'NR','No Repair',NULL,0,'No repair','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313'),('8ad7419c-9541-11f1-9595-002b67818c25',NULL,'ST','Straighten',NULL,0,'Straighten','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313'),('8ad743d9-9541-11f1-9595-002b67818c25',NULL,'WD','Weld',NULL,0,'Weld','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313'),('8ad74532-9541-11f1-9595-002b67818c25',NULL,'PT','Patch',NULL,0,'Patch','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313'),('8ad7465a-9541-11f1-9595-002b67818c25',NULL,'RP','Replace',NULL,0,'Replace','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313'),('8ad74781-9541-11f1-9595-002b67818c25',NULL,'RF','Refit',NULL,0,'Refit','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313'),('8ad74891-9541-11f1-9595-002b67818c25',NULL,'CL','Clean',NULL,0,'Clean','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313'),('8ad749a0-9541-11f1-9595-002b67818c25',NULL,'DR','Drying',NULL,0,'Drying','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313'),('8ad74af7-9541-11f1-9595-002b67818c25',NULL,'GR','Grinding',NULL,0,'Grinding','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313'),('8ad74c05-9541-11f1-9595-002b67818c25',NULL,'PN','Painting',NULL,0,'Painting','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313'),('8ad74d1c-9541-11f1-9595-002b67818c25',NULL,'SL','Sealant',NULL,0,'Sealant','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313'),('8ad74e59-9541-11f1-9595-002b67818c25',NULL,'TG','Tighten',NULL,0,'Tighten','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313'),('8ad74fac-9541-11f1-9595-002b67818c25',NULL,'RM','Remove',NULL,0,'Remove','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313'),('8ad75102-9541-11f1-9595-002b67818c25',NULL,'RI','Reinstall',NULL,0,'Reinstall','legacy',NULL,0,'active','2026-08-11 12:00:15.996313','2026-08-11 12:00:15.996313');
/*!40000 ALTER TABLE `cedex_repairs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_profiles`
--

DROP TABLE IF EXISTS `company_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `company_profiles` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `company_name` varchar(200) NOT NULL,
  `brand_name` varchar(100) DEFAULT NULL,
  `address` text,
  `phone` varchar(50) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `website` varchar(150) DEFAULT NULL,
  `tax_no` varchar(80) DEFAULT NULL,
  `logo_file_id` char(36) DEFAULT NULL,
  `default_signature_file_id` char(36) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_company_profiles_single_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_profiles`
--

LOCK TABLES `company_profiles` WRITE;
/*!40000 ALTER TABLE `company_profiles` DISABLE KEYS */;
INSERT INTO `company_profiles` VALUES ('8ad2ca4e-9541-11f1-9595-002b67818c25','PT Global Inspeksi Sertifikasi Group','GIFT',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-08-11 12:00:15.967502','2026-08-11 12:00:15.967502');
/*!40000 ALTER TABLE `company_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `container_import_batches`
--

DROP TABLE IF EXISTS `container_import_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `container_import_batches` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `job_order_id` char(36) NOT NULL,
  `file_id` char(36) DEFAULT NULL,
  `total_rows` int NOT NULL DEFAULT '0',
  `success_rows` int NOT NULL DEFAULT '0',
  `failed_rows` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'processed',
  `error_summary` json DEFAULT NULL,
  `imported_by` char(36) DEFAULT NULL,
  `imported_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  CONSTRAINT `chk_container_import_batches_status` CHECK ((`status` in (_cp850'processed',_cp850'failed',_cp850'partial')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `container_import_batches`
--

LOCK TABLES `container_import_batches` WRITE;
/*!40000 ALTER TABLE `container_import_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `container_import_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `container_manufacturers`
--

DROP TABLE IF EXISTS `container_manufacturers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `container_manufacturers` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `manufacturer_code` varchar(50) NOT NULL,
  `manufacturer_name` varchar(200) NOT NULL,
  `address` text,
  `country` varchar(100) DEFAULT NULL,
  `pic_name` varchar(150) DEFAULT NULL,
  `pic_phone` varchar(50) DEFAULT NULL,
  `pic_email` varchar(150) DEFAULT NULL,
  `website` varchar(150) DEFAULT NULL,
  `note` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `manufacturer_code` (`manufacturer_code`),
  KEY `idx_container_manufacturers_code` (`manufacturer_code`),
  KEY `idx_container_manufacturers_name` (`manufacturer_name`),
  KEY `idx_container_manufacturers_status` (`status`),
  KEY `idx_container_manufacturers_deleted_at` (`deleted_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `container_manufacturers`
--

LOCK TABLES `container_manufacturers` WRITE;
/*!40000 ALTER TABLE `container_manufacturers` DISABLE KEYS */;
/*!40000 ALTER TABLE `container_manufacturers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `container_technical_specs`
--

DROP TABLE IF EXISTS `container_technical_specs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `container_technical_specs` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `application_container_id` char(36) NOT NULL,
  `csc_no` varchar(120) DEFAULT NULL,
  `manufacture_date` date DEFAULT NULL,
  `manufacturer_serial_no` varchar(120) DEFAULT NULL,
  `type_model` varchar(150) DEFAULT NULL,
  `iso_code` varchar(20) DEFAULT NULL,
  `max_gross_weight_kg` decimal(12,2) DEFAULT NULL,
  `max_gross_weight_lbs` decimal(12,2) DEFAULT NULL,
  `tare_weight_kg` decimal(12,2) DEFAULT NULL,
  `tare_weight_lbs` decimal(12,2) DEFAULT NULL,
  `payload_weight_kg` decimal(12,2) DEFAULT NULL,
  `payload_weight_lbs` decimal(12,2) DEFAULT NULL,
  `cube_capacity_m3` decimal(12,3) DEFAULT NULL,
  `cube_capacity_ft3` decimal(12,3) DEFAULT NULL,
  `allowable_stacking_weight_kg` decimal(12,2) DEFAULT NULL,
  `allowable_stacking_weight_lbs` decimal(12,2) DEFAULT NULL,
  `racking_test_load_value_kg` decimal(12,2) DEFAULT NULL,
  `racking_test_load_value_lbs` decimal(12,2) DEFAULT NULL,
  `end_wall_strength` varchar(100) DEFAULT NULL,
  `side_wall_strength` varchar(100) DEFAULT NULL,
  `next_examination_date` date DEFAULT NULL,
  `maintenance_scheme_id` char(36) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `application_container_id` (`application_container_id`),
  KEY `idx_container_technical_specs_csc_no` (`csc_no`),
  KEY `idx_container_technical_specs_maintenance_scheme` (`maintenance_scheme_id`),
  CONSTRAINT `fk_container_technical_specs_application_container` FOREIGN KEY (`application_container_id`) REFERENCES `application_containers` (`id`),
  CONSTRAINT `fk_container_technical_specs_maintenance_scheme` FOREIGN KEY (`maintenance_scheme_id`) REFERENCES `maintenance_schemes` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `container_technical_specs`
--

LOCK TABLES `container_technical_specs` WRITE;
/*!40000 ALTER TABLE `container_technical_specs` DISABLE KEYS */;
/*!40000 ALTER TABLE `container_technical_specs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `container_types`
--

DROP TABLE IF EXISTS `container_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `container_types` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_id` char(36) DEFAULT NULL,
  `code` varchar(30) NOT NULL,
  `iso_code` varchar(20) DEFAULT NULL,
  `size` varchar(50) NOT NULL,
  `type_name` varchar(100) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_container_types_customer_code` (`customer_id`,`code`),
  KEY `idx_container_types_status` (`status`),
  KEY `idx_container_types_customer` (`customer_id`),
  KEY `idx_container_types_customer_status` (`customer_id`,`status`),
  CONSTRAINT `fk_container_types_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `chk_container_types_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `container_types`
--

LOCK TABLES `container_types` WRITE;
/*!40000 ALTER TABLE `container_types` DISABLE KEYS */;
INSERT INTO `container_types` VALUES ('8ad3c259-9541-11f1-9595-002b67818c25',NULL,'20GP','22G1','20 Feet','General Purpose','Dry container 20 feet','active','2026-08-11 12:00:15.973833','2026-08-11 12:00:15.973833'),('8ad3c5b1-9541-11f1-9595-002b67818c25',NULL,'40GP','42G1','40 Feet','General Purpose','Dry container 40 feet','active','2026-08-11 12:00:15.973833','2026-08-11 12:00:15.973833'),('8ad3c705-9541-11f1-9595-002b67818c25',NULL,'40HC','45G1','40 Feet','High Cube','High cube dry container 40 feet','active','2026-08-11 12:00:15.973833','2026-08-11 12:00:15.973833'),('8ad3c7e2-9541-11f1-9595-002b67818c25',NULL,'20RF','22R1','20 Feet','Reefer','Refrigerated container 20 feet','active','2026-08-11 12:00:15.973833','2026-08-11 12:00:15.973833'),('8ad3c8be-9541-11f1-9595-002b67818c25',NULL,'40RF','45R1','40 Feet','Reefer','Refrigerated container 40 feet','active','2026-08-11 12:00:15.973833','2026-08-11 12:00:15.973833'),('8ad3c98e-9541-11f1-9595-002b67818c25',NULL,'20OT',NULL,'20 Feet','Open Top','Open top container 20 feet','active','2026-08-11 12:00:15.973833','2026-08-11 12:00:15.973833'),('8ad3ca4b-9541-11f1-9595-002b67818c25',NULL,'40OT',NULL,'40 Feet','Open Top','Open top container 40 feet','active','2026-08-11 12:00:15.973833','2026-08-11 12:00:15.973833'),('8ad3cb07-9541-11f1-9595-002b67818c25',NULL,'20FR',NULL,'20 Feet','Flat Rack','Flat rack container 20 feet','active','2026-08-11 12:00:15.973833','2026-08-11 12:00:15.973833'),('8ad3cc05-9541-11f1-9595-002b67818c25',NULL,'40FR',NULL,'40 Feet','Flat Rack','Flat rack container 40 feet','active','2026-08-11 12:00:15.973833','2026-08-11 12:00:15.973833'),('8ad3cccf-9541-11f1-9595-002b67818c25',NULL,'TANK',NULL,'Tank','Tank Container','Tank container','active','2026-08-11 12:00:15.973833','2026-08-11 12:00:15.973833');
/*!40000 ALTER TABLE `container_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_personnel`
--

DROP TABLE IF EXISTS `customer_personnel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_personnel` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_id` char(36) NOT NULL,
  `personnel_code` varchar(80) NOT NULL,
  `full_name` varchar(180) NOT NULL,
  `position_title` varchar(150) DEFAULT NULL,
  `personnel_type` varchar(80) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `notes` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_customer_personnel_customer_code` (`customer_id`,`personnel_code`),
  KEY `idx_customer_personnel_customer` (`customer_id`),
  KEY `idx_customer_personnel_customer_status` (`customer_id`,`status`),
  KEY `idx_customer_personnel_deleted_at` (`deleted_at`),
  CONSTRAINT `fk_customer_personnel_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_personnel`
--

LOCK TABLES `customer_personnel` WRITE;
/*!40000 ALTER TABLE `customer_personnel` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_personnel` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_personnel_locations`
--

DROP TABLE IF EXISTS `customer_personnel_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_personnel_locations` (
  `customer_personnel_id` char(36) NOT NULL,
  `location_id` char(36) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`customer_personnel_id`,`location_id`),
  KEY `idx_customer_personnel_locations_location` (`location_id`),
  CONSTRAINT `fk_customer_personnel_locations_location` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`),
  CONSTRAINT `fk_customer_personnel_locations_personnel` FOREIGN KEY (`customer_personnel_id`) REFERENCES `customer_personnel` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_personnel_locations`
--

LOCK TABLES `customer_personnel_locations` WRITE;
/*!40000 ALTER TABLE `customer_personnel_locations` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_personnel_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_survey_type_photo_categories`
--

DROP TABLE IF EXISTS `customer_survey_type_photo_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_survey_type_photo_categories` (
  `customer_id` char(36) NOT NULL,
  `survey_type_id` char(36) NOT NULL,
  `photo_category_id` char(36) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`customer_id`,`survey_type_id`,`photo_category_id`),
  KEY `fk_customer_survey_type_photos_survey_type` (`survey_type_id`),
  KEY `fk_customer_survey_type_photos_category` (`photo_category_id`),
  KEY `idx_customer_survey_type_photos_lookup` (`customer_id`,`survey_type_id`,`is_active`),
  CONSTRAINT `fk_customer_survey_type_photos_category` FOREIGN KEY (`photo_category_id`) REFERENCES `evidence_photo_categories` (`id`),
  CONSTRAINT `fk_customer_survey_type_photos_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_customer_survey_type_photos_survey_type` FOREIGN KEY (`survey_type_id`) REFERENCES `survey_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_survey_type_photo_categories`
--

LOCK TABLES `customer_survey_type_photo_categories` WRITE;
/*!40000 ALTER TABLE `customer_survey_type_photo_categories` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_survey_type_photo_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_survey_type_severities`
--

DROP TABLE IF EXISTS `customer_survey_type_severities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_survey_type_severities` (
  `customer_id` char(36) NOT NULL,
  `survey_type_id` char(36) NOT NULL,
  `severity_id` char(36) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`customer_id`,`survey_type_id`,`severity_id`),
  KEY `fk_customer_survey_type_severities_survey_type` (`survey_type_id`),
  KEY `fk_customer_survey_type_severities_severity` (`severity_id`),
  KEY `idx_customer_survey_type_severities_lookup` (`customer_id`,`survey_type_id`,`is_active`),
  CONSTRAINT `fk_customer_survey_type_severities_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_customer_survey_type_severities_severity` FOREIGN KEY (`severity_id`) REFERENCES `finding_severities` (`id`),
  CONSTRAINT `fk_customer_survey_type_severities_survey_type` FOREIGN KEY (`survey_type_id`) REFERENCES `survey_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_survey_type_severities`
--

LOCK TABLES `customer_survey_type_severities` WRITE;
/*!40000 ALTER TABLE `customer_survey_type_severities` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_survey_type_severities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_survey_type_test_parameters`
--

DROP TABLE IF EXISTS `customer_survey_type_test_parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_survey_type_test_parameters` (
  `customer_id` char(36) NOT NULL,
  `survey_type_id` char(36) NOT NULL,
  `test_parameter_id` char(36) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`customer_id`,`survey_type_id`,`test_parameter_id`),
  KEY `fk_customer_survey_type_tests_survey_type` (`survey_type_id`),
  KEY `fk_customer_survey_type_tests_parameter` (`test_parameter_id`),
  KEY `idx_customer_survey_type_tests_lookup` (`customer_id`,`survey_type_id`,`is_active`),
  CONSTRAINT `fk_customer_survey_type_tests_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_customer_survey_type_tests_parameter` FOREIGN KEY (`test_parameter_id`) REFERENCES `inspection_test_parameters` (`id`),
  CONSTRAINT `fk_customer_survey_type_tests_survey_type` FOREIGN KEY (`survey_type_id`) REFERENCES `survey_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_survey_type_test_parameters`
--

LOCK TABLES `customer_survey_type_test_parameters` WRITE;
/*!40000 ALTER TABLE `customer_survey_type_test_parameters` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_survey_type_test_parameters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_code` varchar(50) NOT NULL,
  `customer_name` varchar(200) NOT NULL,
  `address` text,
  `npwp` varchar(80) DEFAULT NULL,
  `pic_name` varchar(150) DEFAULT NULL,
  `pic_phone` varchar(50) DEFAULT NULL,
  `pic_email` varchar(150) DEFAULT NULL,
  `billing_address` text,
  `payment_term_days` int DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_by` char(36) DEFAULT NULL,
  `updated_by` char(36) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_customers_code` (`customer_code`),
  KEY `idx_customers_name` (`customer_name`),
  KEY `idx_customers_status` (`status`),
  CONSTRAINT `chk_customers_payment_term` CHECK (((`payment_term_days` is null) or (`payment_term_days` >= 0))),
  CONSTRAINT `chk_customers_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customers`
--

LOCK TABLES `customers` WRITE;
/*!40000 ALTER TABLE `customers` DISABLE KEYS */;
INSERT INTO `customers` VALUES ('9d317262-71c2-485c-a841-5d0918905d56','EFF-RDE3','Effective Master Test','UAT',NULL,NULL,NULL,NULL,NULL,NULL,'active',NULL,NULL,'2026-08-11 12:03:34.266943','2026-08-11 12:03:34.266943',NULL);
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evidence_photo_categories`
--

DROP TABLE IF EXISTS `evidence_photo_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `evidence_photo_categories` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(80) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text,
  `is_required_default` tinyint(1) NOT NULL DEFAULT '0',
  `applies_to` varchar(80) DEFAULT NULL,
  `display_order` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_evidence_photo_categories_status` (`status`),
  KEY `idx_evidence_photo_categories_display_order` (`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `evidence_photo_categories`
--

LOCK TABLES `evidence_photo_categories` WRITE;
/*!40000 ALTER TABLE `evidence_photo_categories` DISABLE KEYS */;
INSERT INTO `evidence_photo_categories` VALUES ('8eb0b959-9541-11f1-9595-002b67818c25','general_container','General Container','Foto umum peti kemas.',1,'inspection',10,'active','2026-08-11 12:00:22.454100','2026-08-11 12:00:22.454100'),('8eb0bc74-9541-11f1-9595-002b67818c25','container_number','Container Number','Foto nomor peti kemas.',1,'inspection',20,'active','2026-08-11 12:00:22.454100','2026-08-11 12:00:22.454100'),('8eb0bec2-9541-11f1-9595-002b67818c25','csc_plate','CSC Plate','Foto plate persetujuan keselamatan.',1,'inspection',30,'active','2026-08-11 12:00:22.454100','2026-08-11 12:00:22.454100'),('8eb0bfbb-9541-11f1-9595-002b67818c25','structural_component','Structural Component','Foto komponen struktur.',0,'inspection',40,'active','2026-08-11 12:00:22.454100','2026-08-11 12:00:22.454100'),('8eb0c0ab-9541-11f1-9595-002b67818c25','damage_finding','Damage Finding','Foto temuan kerusakan.',0,'finding',50,'active','2026-08-11 12:00:22.454100','2026-08-11 12:00:22.454100'),('8eb0c190-9541-11f1-9595-002b67818c25','test_result','Test Result','Foto atau lampiran hasil pengujian.',0,'test',60,'active','2026-08-11 12:00:22.454100','2026-08-11 12:00:22.454100'),('8eb0c265-9541-11f1-9595-002b67818c25','repair_evidence','Repair Evidence','Evidence perbaikan.',0,'repair',70,'active','2026-08-11 12:00:22.454100','2026-08-11 12:00:22.454100'),('8eb0c335-9541-11f1-9595-002b67818c25','reinspection_evidence','Reinspection Evidence','Evidence re-inspection.',0,'reinspection',80,'active','2026-08-11 12:00:22.454100','2026-08-11 12:00:22.454100');
/*!40000 ALTER TABLE `evidence_photo_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file_objects`
--

DROP TABLE IF EXISTS `file_objects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `file_objects` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `bucket_name` varchar(100) NOT NULL,
  `object_key` varchar(768) NOT NULL,
  `original_file_name` varchar(255) DEFAULT NULL,
  `mime_type` varchar(100) DEFAULT NULL,
  `file_size` bigint DEFAULT NULL,
  `checksum_sha256` varchar(128) DEFAULT NULL,
  `visibility` varchar(30) NOT NULL DEFAULT 'private',
  `public_token` varchar(120) DEFAULT NULL,
  `uploaded_by` char(36) DEFAULT NULL,
  `uploaded_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `public_token` (`public_token`),
  KEY `idx_file_objects_object_key` (`object_key`),
  KEY `idx_file_objects_uploaded_by` (`uploaded_by`),
  CONSTRAINT `fk_file_objects_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_file_objects_file_size` CHECK (((`file_size` is null) or (`file_size` >= 0))),
  CONSTRAINT `chk_file_objects_visibility` CHECK ((`visibility` in (_utf8mb4'private',_utf8mb4'internal',_utf8mb4'public_token')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `file_objects`
--

LOCK TABLES `file_objects` WRITE;
/*!40000 ALTER TABLE `file_objects` DISABLE KEYS */;
/*!40000 ALTER TABLE `file_objects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `finding_severities`
--

DROP TABLE IF EXISTS `finding_severities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `finding_severities` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `level_no` int NOT NULL,
  `affects_fitness_default` tinyint(1) NOT NULL DEFAULT '0',
  `requires_supervisor_review` tinyint(1) NOT NULL DEFAULT '0',
  `badge_tone` varchar(30) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_finding_severities_level` (`level_no`),
  KEY `idx_finding_severities_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `finding_severities`
--

LOCK TABLES `finding_severities` WRITE;
/*!40000 ALTER TABLE `finding_severities` DISABLE KEYS */;
INSERT INTO `finding_severities` VALUES ('8eaf31b4-9541-11f1-9595-002b67818c25','minor','Minor','Temuan ringan.',1,0,0,'neutral','active','2026-08-11 12:00:22.443438','2026-08-11 12:00:22.443438'),('8eaf3572-9541-11f1-9595-002b67818c25','major','Major','Temuan signifikan yang perlu review.',2,1,1,'warning','active','2026-08-11 12:00:22.443438','2026-08-11 12:00:22.443438'),('8eaf38aa-9541-11f1-9595-002b67818c25','critical','Critical','Temuan kritikal yang memengaruhi kelaikan.',3,1,1,'danger','active','2026-08-11 12:00:22.443438','2026-08-11 12:00:22.443438');
/*!40000 ALTER TABLE `finding_severities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fitness_application_events`
--

DROP TABLE IF EXISTS `fitness_application_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fitness_application_events` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `fitness_application_id` char(36) NOT NULL,
  `application_container_id` char(36) DEFAULT NULL,
  `event_type` varchar(100) NOT NULL,
  `event_title` varchar(200) NOT NULL,
  `event_description` text,
  `old_status` varchar(50) DEFAULT NULL,
  `new_status` varchar(50) DEFAULT NULL,
  `actor_id` char(36) DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_fitness_application_events_application` (`fitness_application_id`),
  KEY `idx_fitness_application_events_container` (`application_container_id`),
  KEY `idx_fitness_application_events_actor` (`actor_id`),
  KEY `idx_fitness_application_events_type` (`event_type`),
  CONSTRAINT `fk_fitness_application_events_actor` FOREIGN KEY (`actor_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_fitness_application_events_application` FOREIGN KEY (`fitness_application_id`) REFERENCES `fitness_applications` (`id`),
  CONSTRAINT `fk_fitness_application_events_container` FOREIGN KEY (`application_container_id`) REFERENCES `application_containers` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fitness_application_events`
--

LOCK TABLES `fitness_application_events` WRITE;
/*!40000 ALTER TABLE `fitness_application_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `fitness_application_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fitness_applications`
--

DROP TABLE IF EXISTS `fitness_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fitness_applications` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `application_no` varchar(80) NOT NULL,
  `application_date` date NOT NULL,
  `owner_id` char(36) NOT NULL,
  `manufacturer_id` char(36) DEFAULT NULL,
  `location_id` char(36) NOT NULL,
  `approval_category_id` char(36) NOT NULL,
  `client_letter_no` varchar(120) DEFAULT NULL,
  `client_letter_date` date DEFAULT NULL,
  `pic_name` varchar(150) DEFAULT NULL,
  `pic_phone` varchar(50) DEFAULT NULL,
  `pic_email` varchar(150) DEFAULT NULL,
  `instruction` text,
  `workflow_status` varchar(50) NOT NULL DEFAULT 'draft',
  `created_by` char(36) DEFAULT NULL,
  `updated_by` char(36) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `application_no` (`application_no`),
  KEY `idx_fitness_applications_owner` (`owner_id`),
  KEY `idx_fitness_applications_manufacturer` (`manufacturer_id`),
  KEY `idx_fitness_applications_location` (`location_id`),
  KEY `idx_fitness_applications_category` (`approval_category_id`),
  KEY `idx_fitness_applications_workflow_status` (`workflow_status`),
  KEY `idx_fitness_applications_deleted_at` (`deleted_at`),
  KEY `fk_fitness_applications_created_by` (`created_by`),
  KEY `fk_fitness_applications_updated_by` (`updated_by`),
  CONSTRAINT `fk_fitness_applications_category` FOREIGN KEY (`approval_category_id`) REFERENCES `fitness_approval_categories` (`id`),
  CONSTRAINT `fk_fitness_applications_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_fitness_applications_location` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`),
  CONSTRAINT `fk_fitness_applications_manufacturer` FOREIGN KEY (`manufacturer_id`) REFERENCES `container_manufacturers` (`id`),
  CONSTRAINT `fk_fitness_applications_owner` FOREIGN KEY (`owner_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_fitness_applications_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fitness_applications`
--

LOCK TABLES `fitness_applications` WRITE;
/*!40000 ALTER TABLE `fitness_applications` DISABLE KEYS */;
/*!40000 ALTER TABLE `fitness_applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fitness_approval_categories`
--

DROP TABLE IF EXISTS `fitness_approval_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fitness_approval_categories` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(80) NOT NULL,
  `name` varchar(180) NOT NULL,
  `description` text,
  `container_lifecycle` varchar(50) NOT NULL,
  `is_mvp_active` tinyint(1) NOT NULL DEFAULT '1',
  `display_order` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_fitness_approval_categories_lifecycle` (`container_lifecycle`),
  KEY `idx_fitness_approval_categories_mvp` (`is_mvp_active`),
  KEY `idx_fitness_approval_categories_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fitness_approval_categories`
--

LOCK TABLES `fitness_approval_categories` WRITE;
/*!40000 ALTER TABLE `fitness_approval_categories` DISABLE KEYS */;
INSERT INTO `fitness_approval_categories` VALUES ('8ea6b222-9541-11f1-9595-002b67818c25','new_individual','Peti Kemas Baru Individual','Persetujuan kelaikan untuk peti kemas baru individual.','new',1,10,'active','2026-08-11 12:00:22.388213','2026-08-11 12:00:22.388213'),('8ea6b695-9541-11f1-9595-002b67818c25','existing_used','Peti Kemas Lama yang Telah Digunakan','Persetujuan kelaikan untuk peti kemas lama yang telah digunakan.','existing',1,20,'active','2026-08-11 12:00:22.388213','2026-08-11 12:00:22.388213'),('8ea6b8ab-9541-11f1-9595-002b67818c25','existing_produced_without_initial_approval','Peti Kemas yang Sudah Diproduksi dan Belum Mendapat Persetujuan Awal','Persetujuan kelaikan untuk peti kemas yang sudah diproduksi dan belum mendapat persetujuan awal.','existing',1,30,'active','2026-08-11 12:00:22.388213','2026-08-11 12:00:22.388213'),('8ea6b9ce-9541-11f1-9595-002b67818c25','type_design','Peti Kemas Baru Type Design','Future scope; tidak aktif pada MVP.','new',0,90,'inactive','2026-08-11 12:00:22.388213','2026-08-11 12:00:22.388213');
/*!40000 ALTER TABLE `fitness_approval_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fitness_checklist_template_items`
--

DROP TABLE IF EXISTS `fitness_checklist_template_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fitness_checklist_template_items` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `template_id` char(36) NOT NULL,
  `item_code` varchar(80) NOT NULL,
  `item_label` varchar(255) NOT NULL,
  `description` text,
  `inspection_area_id` char(36) DEFAULT NULL,
  `structural_component_id` char(36) DEFAULT NULL,
  `test_parameter_id` char(36) DEFAULT NULL,
  `response_type` varchar(50) NOT NULL DEFAULT 'ok_not_ok',
  `expected_value` varchar(150) DEFAULT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT '1',
  `is_critical` tinyint(1) NOT NULL DEFAULT '0',
  `fail_requires_repair` tinyint(1) NOT NULL DEFAULT '0',
  `fail_marks_unfit` tinyint(1) NOT NULL DEFAULT '0',
  `display_order` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_fitness_checklist_template_items_code` (`template_id`,`item_code`),
  KEY `idx_fitness_checklist_template_items_area` (`inspection_area_id`),
  KEY `idx_fitness_checklist_template_items_component` (`structural_component_id`),
  KEY `idx_fitness_checklist_template_items_test_parameter` (`test_parameter_id`),
  KEY `idx_fitness_checklist_template_items_status` (`status`),
  CONSTRAINT `fk_fitness_checklist_template_items_area` FOREIGN KEY (`inspection_area_id`) REFERENCES `inspection_areas` (`id`),
  CONSTRAINT `fk_fitness_checklist_template_items_component` FOREIGN KEY (`structural_component_id`) REFERENCES `structural_components` (`id`),
  CONSTRAINT `fk_fitness_checklist_template_items_template` FOREIGN KEY (`template_id`) REFERENCES `fitness_checklist_templates` (`id`),
  CONSTRAINT `fk_fitness_checklist_template_items_test_parameter` FOREIGN KEY (`test_parameter_id`) REFERENCES `inspection_test_parameters` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fitness_checklist_template_items`
--

LOCK TABLES `fitness_checklist_template_items` WRITE;
/*!40000 ALTER TABLE `fitness_checklist_template_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `fitness_checklist_template_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fitness_checklist_templates`
--

DROP TABLE IF EXISTS `fitness_checklist_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fitness_checklist_templates` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_id` char(36) DEFAULT NULL,
  `template_code` varchar(80) NOT NULL,
  `template_name` varchar(180) NOT NULL,
  `approval_category_id` char(36) DEFAULT NULL,
  `survey_type_id` char(36) DEFAULT NULL,
  `container_type_id` char(36) DEFAULT NULL,
  `description` text,
  `version_no` int NOT NULL DEFAULT '1',
  `status` varchar(30) NOT NULL DEFAULT 'draft',
  `created_by` char(36) DEFAULT NULL,
  `approved_by` char(36) DEFAULT NULL,
  `approved_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_fitness_checklist_templates_customer_code` (`customer_id`,`template_code`),
  KEY `idx_fitness_checklist_templates_category` (`approval_category_id`),
  KEY `idx_fitness_checklist_templates_container_type` (`container_type_id`),
  KEY `idx_fitness_checklist_templates_status` (`status`),
  KEY `idx_fitness_checklist_templates_deleted_at` (`deleted_at`),
  KEY `fk_fitness_checklist_templates_created_by` (`created_by`),
  KEY `fk_fitness_checklist_templates_approved_by` (`approved_by`),
  KEY `idx_fitness_checklist_templates_customer` (`customer_id`),
  KEY `idx_fitness_checklist_templates_customer_status` (`customer_id`,`status`),
  KEY `idx_fitness_checklist_templates_survey_type` (`survey_type_id`),
  CONSTRAINT `fk_fitness_checklist_templates_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_fitness_checklist_templates_category` FOREIGN KEY (`approval_category_id`) REFERENCES `fitness_approval_categories` (`id`),
  CONSTRAINT `fk_fitness_checklist_templates_container_type` FOREIGN KEY (`container_type_id`) REFERENCES `container_types` (`id`),
  CONSTRAINT `fk_fitness_checklist_templates_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_fitness_checklist_templates_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_fitness_checklist_templates_survey_type` FOREIGN KEY (`survey_type_id`) REFERENCES `survey_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fitness_checklist_templates`
--

LOCK TABLES `fitness_checklist_templates` WRITE;
/*!40000 ALTER TABLE `fitness_checklist_templates` DISABLE KEYS */;
/*!40000 ALTER TABLE `fitness_checklist_templates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fitness_container_import_batches`
--

DROP TABLE IF EXISTS `fitness_container_import_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fitness_container_import_batches` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `fitness_application_id` char(36) NOT NULL,
  `file_id` char(36) DEFAULT NULL,
  `original_file_name` varchar(255) DEFAULT NULL,
  `total_rows` int NOT NULL DEFAULT '0',
  `success_rows` int NOT NULL DEFAULT '0',
  `failed_rows` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'draft',
  `error_summary` json DEFAULT NULL,
  `imported_by` char(36) DEFAULT NULL,
  `imported_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_fitness_container_import_batches_application` (`fitness_application_id`),
  KEY `idx_fitness_container_import_batches_file` (`file_id`),
  KEY `idx_fitness_container_import_batches_status` (`status`),
  KEY `idx_fitness_container_import_batches_imported_by` (`imported_by`),
  CONSTRAINT `fk_fitness_container_import_batches_application` FOREIGN KEY (`fitness_application_id`) REFERENCES `fitness_applications` (`id`),
  CONSTRAINT `fk_fitness_container_import_batches_file` FOREIGN KEY (`file_id`) REFERENCES `file_objects` (`id`),
  CONSTRAINT `fk_fitness_container_import_batches_imported_by` FOREIGN KEY (`imported_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fitness_container_import_batches`
--

LOCK TABLES `fitness_container_import_batches` WRITE;
/*!40000 ALTER TABLE `fitness_container_import_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `fitness_container_import_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fitness_container_import_rows`
--

DROP TABLE IF EXISTS `fitness_container_import_rows`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fitness_container_import_rows` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `import_batch_id` char(36) NOT NULL,
  `row_no` int NOT NULL,
  `raw_data` json DEFAULT NULL,
  `container_no` varchar(20) DEFAULT NULL,
  `container_type` varchar(80) DEFAULT NULL,
  `iso_type_code` varchar(20) DEFAULT NULL,
  `csc_no` varchar(120) DEFAULT NULL,
  `manufacture_date` date DEFAULT NULL,
  `manufacturer_serial_no` varchar(120) DEFAULT NULL,
  `type_model` varchar(150) DEFAULT NULL,
  `max_gross_weight_kg` decimal(12,2) DEFAULT NULL,
  `tare_weight_kg` decimal(12,2) DEFAULT NULL,
  `payload_weight_kg` decimal(12,2) DEFAULT NULL,
  `validation_status` varchar(30) NOT NULL DEFAULT 'pending',
  `validation_errors` json DEFAULT NULL,
  `application_container_id` char(36) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_fitness_container_import_rows_batch_row` (`import_batch_id`,`row_no`),
  KEY `idx_fitness_container_import_rows_batch` (`import_batch_id`),
  KEY `idx_fitness_container_import_rows_container_no` (`container_no`),
  KEY `idx_fitness_container_import_rows_status` (`validation_status`),
  KEY `idx_fitness_container_import_rows_application_container` (`application_container_id`),
  CONSTRAINT `fk_fitness_container_import_rows_application_container` FOREIGN KEY (`application_container_id`) REFERENCES `application_containers` (`id`),
  CONSTRAINT `fk_fitness_container_import_rows_batch` FOREIGN KEY (`import_batch_id`) REFERENCES `fitness_container_import_batches` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fitness_container_import_rows`
--

LOCK TABLES `fitness_container_import_rows` WRITE;
/*!40000 ALTER TABLE `fitness_container_import_rows` DISABLE KEYS */;
/*!40000 ALTER TABLE `fitness_container_import_rows` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inspection_areas`
--

DROP TABLE IF EXISTS `inspection_areas`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inspection_areas` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(50) NOT NULL,
  `area_name` varchar(150) NOT NULL,
  `description` text,
  `display_order` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_inspection_areas_status` (`status`),
  KEY `idx_inspection_areas_display_order` (`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inspection_areas`
--

LOCK TABLES `inspection_areas` WRITE;
/*!40000 ALTER TABLE `inspection_areas` DISABLE KEYS */;
INSERT INTO `inspection_areas` VALUES ('8ea83b84-9541-11f1-9595-002b67818c25','left_side','Left Side','Sisi kiri peti kemas.',10,'active','2026-08-11 12:00:22.397754','2026-08-11 12:00:22.397754'),('8ea83ef7-9541-11f1-9595-002b67818c25','right_side','Right Side','Sisi kanan peti kemas.',20,'active','2026-08-11 12:00:22.397754','2026-08-11 12:00:22.397754'),('8ea840d1-9541-11f1-9595-002b67818c25','front_end','Front End','Bagian depan peti kemas.',30,'active','2026-08-11 12:00:22.397754','2026-08-11 12:00:22.397754'),('8ea841b4-9541-11f1-9595-002b67818c25','door_end','Door End','Bagian pintu peti kemas.',40,'active','2026-08-11 12:00:22.397754','2026-08-11 12:00:22.397754'),('8ea842b7-9541-11f1-9595-002b67818c25','roof','Roof','Atap peti kemas.',50,'active','2026-08-11 12:00:22.397754','2026-08-11 12:00:22.397754'),('8ea84393-9541-11f1-9595-002b67818c25','floor','Floor','Lantai peti kemas.',60,'active','2026-08-11 12:00:22.397754','2026-08-11 12:00:22.397754'),('8ea84468-9541-11f1-9595-002b67818c25','understructure','Understructure','Struktur bawah peti kemas.',70,'active','2026-08-11 12:00:22.397754','2026-08-11 12:00:22.397754'),('8ea8453f-9541-11f1-9595-002b67818c25','corner_area','Corner Area','Area corner post dan corner fitting.',80,'active','2026-08-11 12:00:22.397754','2026-08-11 12:00:22.397754'),('8ea84610-9541-11f1-9595-002b67818c25','csc_plate_area','CSC Plate Area','Area plate persetujuan keselamatan.',90,'active','2026-08-11 12:00:22.397754','2026-08-11 12:00:22.397754');
/*!40000 ALTER TABLE `inspection_areas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inspection_recommendations`
--

DROP TABLE IF EXISTS `inspection_recommendations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inspection_recommendations` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(80) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text,
  `final_fitness_result_mapping` varchar(50) NOT NULL DEFAULT 'pending',
  `workflow_status_mapping` varchar(50) DEFAULT NULL,
  `restriction_status_mapping` varchar(50) DEFAULT NULL,
  `requires_supervisor_review` tinyint(1) NOT NULL DEFAULT '1',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_inspection_recommendations_result` (`final_fitness_result_mapping`),
  KEY `idx_inspection_recommendations_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inspection_recommendations`
--

LOCK TABLES `inspection_recommendations` WRITE;
/*!40000 ALTER TABLE `inspection_recommendations` DISABLE KEYS */;
INSERT INTO `inspection_recommendations` VALUES ('8eb1a2e3-9541-11f1-9595-002b67818c25','fit','Layak','Direkomendasikan layak.','fit','under_review','none',1,'active','2026-08-11 12:00:22.458576','2026-08-11 12:00:22.458576'),('8eb1a759-9541-11f1-9595-002b67818c25','need_repair','Perlu Perbaikan','Perlu perbaikan sebelum keputusan akhir.','pending','need_repair','suspended',1,'active','2026-08-11 12:00:22.458576','2026-08-11 12:00:22.458576'),('8eb1a924-9541-11f1-9595-002b67818c25','unfit','Tidak Layak','Direkomendasikan tidak layak.','unfit','under_review','prohibited',1,'active','2026-08-11 12:00:22.458576','2026-08-11 12:00:22.458576'),('8eb1aa36-9541-11f1-9595-002b67818c25','need_reinspection','Perlu Re-Inspection','Perlu pemeriksaan ulang.','pending','ready_for_reinspection','suspended',1,'active','2026-08-11 12:00:22.458576','2026-08-11 12:00:22.458576'),('8eb1ab6d-9541-11f1-9595-002b67818c25','suspend_use','Dilarang Digunakan Sementara','Penggunaan ditangguhkan sementara.','pending','need_repair','suspended',1,'active','2026-08-11 12:00:22.458576','2026-08-11 12:00:22.458576');
/*!40000 ALTER TABLE `inspection_recommendations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inspection_test_parameters`
--

DROP TABLE IF EXISTS `inspection_test_parameters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inspection_test_parameters` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(80) NOT NULL,
  `parameter_name` varchar(180) NOT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `description` text,
  `unit` varchar(50) DEFAULT NULL,
  `standard_reference` varchar(200) DEFAULT NULL,
  `clause_section` varchar(150) DEFAULT NULL,
  `effective_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `reference_attachment_file_id` char(36) DEFAULT NULL,
  `applies_to_new_container` tinyint(1) NOT NULL DEFAULT '1',
  `applies_to_existing_container` tinyint(1) NOT NULL DEFAULT '1',
  `requires_numeric_result` tinyint(1) NOT NULL DEFAULT '0',
  `requires_attachment` tinyint(1) NOT NULL DEFAULT '0',
  `display_order` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_inspection_test_parameters_status` (`status`),
  KEY `idx_inspection_test_parameters_display_order` (`display_order`),
  KEY `idx_inspection_test_parameters_reference_type` (`reference_type`),
  KEY `idx_inspection_test_parameters_validity` (`effective_date`,`expiry_date`),
  KEY `idx_inspection_test_parameters_attachment` (`reference_attachment_file_id`),
  CONSTRAINT `fk_inspection_test_parameters_attachment` FOREIGN KEY (`reference_attachment_file_id`) REFERENCES `file_objects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inspection_test_parameters`
--

LOCK TABLES `inspection_test_parameters` WRITE;
/*!40000 ALTER TABLE `inspection_test_parameters` DISABLE KEYS */;
INSERT INTO `inspection_test_parameters` VALUES ('8eaffde7-9541-11f1-9595-002b67818c25','lifting_test','Lifting Test',NULL,'Pengujian lifting.',NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,10,'active','2026-08-11 12:00:22.448990','2026-08-11 12:00:22.448990'),('8eb0013f-9541-11f1-9595-002b67818c25','stacking_test','Stacking Test',NULL,'Pengujian stacking.',NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,20,'active','2026-08-11 12:00:22.448990','2026-08-11 12:00:22.448990'),('8eb00315-9541-11f1-9595-002b67818c25','concentrated_load_test','Concentrated Load Test',NULL,'Pengujian concentrated load.',NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,30,'active','2026-08-11 12:00:22.448990','2026-08-11 12:00:22.448990'),('8eb0041b-9541-11f1-9595-002b67818c25','transverse_racking_test','Transverse Racking Test',NULL,'Pengujian transverse racking.',NULL,NULL,NULL,NULL,NULL,NULL,1,1,1,0,40,'active','2026-08-11 12:00:22.448990','2026-08-11 12:00:22.448990'),('8eb00517-9541-11f1-9595-002b67818c25','longitudinal_restraint_test','Longitudinal Restraint Test',NULL,'Pengujian longitudinal restraint.',NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,50,'active','2026-08-11 12:00:22.448990','2026-08-11 12:00:22.448990'),('8eb00606-9541-11f1-9595-002b67818c25','side_wall_strength','Side Wall Strength',NULL,'Pemeriksaan kekuatan side wall.',NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,60,'active','2026-08-11 12:00:22.448990','2026-08-11 12:00:22.448990'),('8eb006e7-9541-11f1-9595-002b67818c25','end_wall_strength','End Wall Strength',NULL,'Pemeriksaan kekuatan end wall.',NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,70,'active','2026-08-11 12:00:22.448990','2026-08-11 12:00:22.448990'),('8eb007c0-9541-11f1-9595-002b67818c25','one_door_off_operation','One Door Off Operation',NULL,'Pemeriksaan operasi one door off.',NULL,NULL,NULL,NULL,NULL,NULL,1,0,0,0,80,'active','2026-08-11 12:00:22.448990','2026-08-11 12:00:22.448990'),('8eb008a6-9541-11f1-9595-002b67818c25','watertightness_test','Watertightness Test',NULL,'Pengujian kedap air.',NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,1,90,'active','2026-08-11 12:00:22.448990','2026-08-11 12:00:22.448990'),('8eb0097d-9541-11f1-9595-002b67818c25','ndt_if_required','NDT If Required',NULL,'NDT jika diperlukan.',NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,1,100,'active','2026-08-11 12:00:22.448990','2026-08-11 12:00:22.448990');
/*!40000 ALTER TABLE `inspection_test_parameters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoice_items`
--

DROP TABLE IF EXISTS `invoice_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoice_items` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `invoice_id` char(36) NOT NULL,
  `job_order_id` char(36) DEFAULT NULL,
  `report_id` char(36) DEFAULT NULL,
  `survey_id` char(36) DEFAULT NULL,
  `price_list_id` char(36) DEFAULT NULL,
  `description` varchar(255) NOT NULL,
  `quantity` decimal(12,2) NOT NULL DEFAULT '1.00',
  `unit_price` decimal(15,2) NOT NULL DEFAULT '0.00',
  `tax_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `discount_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `total` decimal(15,2) NOT NULL DEFAULT '0.00',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_invoice_items_invoice` (`invoice_id`),
  KEY `idx_invoice_items_report` (`report_id`),
  KEY `fk_invoice_items_survey` (`survey_id`),
  CONSTRAINT `fk_invoice_items_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_invoice_items_report` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`),
  CONSTRAINT `fk_invoice_items_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoice_items`
--

LOCK TABLES `invoice_items` WRITE;
/*!40000 ALTER TABLE `invoice_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoice_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invoices` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `invoice_no` varchar(80) NOT NULL,
  `invoice_date` date NOT NULL,
  `customer_id` char(36) NOT NULL,
  `billing_address` text,
  `payment_term_days` int DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'IDR',
  `subtotal` decimal(15,2) NOT NULL DEFAULT '0.00',
  `tax_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `discount_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `grand_total` decimal(15,2) NOT NULL DEFAULT '0.00',
  `paid_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `outstanding_amount` decimal(15,2) NOT NULL DEFAULT '0.00',
  `status` varchar(30) NOT NULL DEFAULT 'draft',
  `issued_at` datetime(6) DEFAULT NULL,
  `issued_by` char(36) DEFAULT NULL,
  `cancel_reason` text,
  `cancelled_at` datetime(6) DEFAULT NULL,
  `cancelled_by` char(36) DEFAULT NULL,
  `created_by` char(36) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_no` (`invoice_no`),
  UNIQUE KEY `idx_invoices_no` (`invoice_no`),
  KEY `idx_invoices_customer` (`customer_id`),
  KEY `idx_invoices_status` (`status`),
  KEY `idx_invoices_date` (`invoice_date`),
  KEY `idx_invoices_due_date` (`due_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_containers`
--

DROP TABLE IF EXISTS `job_containers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_containers` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `job_order_id` char(36) NOT NULL,
  `container_no` varchar(20) NOT NULL,
  `container_number_input` varchar(20) DEFAULT NULL,
  `owner_code` varchar(4) DEFAULT NULL,
  `serial_number` varchar(10) DEFAULT NULL,
  `check_digit` varchar(2) DEFAULT NULL,
  `container_check_digit_calculated` varchar(2) DEFAULT NULL,
  `container_check_digit_valid` tinyint(1) DEFAULT NULL,
  `check_digit_status` varchar(30) NOT NULL DEFAULT 'not_checked',
  `check_digit_override_reason` text,
  `check_digit_override_by` char(36) DEFAULT NULL,
  `check_digit_override_at` datetime(6) DEFAULT NULL,
  `container_type_id` char(36) DEFAULT NULL,
  `iso_type_code` varchar(20) DEFAULT NULL,
  `seal_no` varchar(100) DEFAULT NULL,
  `cargo_status` varchar(30) NOT NULL DEFAULT 'unknown',
  `gross_weight` decimal(12,2) DEFAULT NULL,
  `tare_weight` decimal(12,2) DEFAULT NULL,
  `payload` decimal(12,2) DEFAULT NULL,
  `manufacture_date` date DEFAULT NULL,
  `csc_plate_status` varchar(30) DEFAULT NULL,
  `csc_plate_number` varchar(100) DEFAULT NULL,
  `csc_approval_reference` varchar(150) DEFAULT NULL,
  `csc_manufacture_date` date DEFAULT NULL,
  `csc_next_examination_date` date DEFAULT NULL,
  `csc_program_type` varchar(50) DEFAULT NULL,
  `truck_no` varchar(80) DEFAULT NULL,
  `driver_name` varchar(150) DEFAULT NULL,
  `remark` text,
  `status` varchar(50) NOT NULL DEFAULT 'not_started',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_job_containers_job_container_no` (`job_order_id`,`container_no`),
  KEY `idx_job_containers_job` (`job_order_id`),
  KEY `idx_job_containers_container_no` (`container_no`),
  KEY `idx_job_containers_status` (`status`),
  KEY `fk_job_containers_container_type` (`container_type_id`),
  KEY `fk_job_containers_check_digit_override_by` (`check_digit_override_by`),
  CONSTRAINT `fk_job_containers_check_digit_override_by` FOREIGN KEY (`check_digit_override_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_job_containers_container_type` FOREIGN KEY (`container_type_id`) REFERENCES `container_types` (`id`),
  CONSTRAINT `fk_job_containers_job_order` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`id`),
  CONSTRAINT `chk_job_containers_cargo_status` CHECK ((`cargo_status` in (_utf8mb4'empty',_utf8mb4'laden',_utf8mb4'unknown'))),
  CONSTRAINT `chk_job_containers_check_digit_status` CHECK ((`check_digit_status` in (_utf8mb4'valid',_utf8mb4'invalid',_utf8mb4'not_checked',_utf8mb4'override'))),
  CONSTRAINT `chk_job_containers_status` CHECK ((`status` in (_cp850'not_started',_cp850'unassigned',_cp850'assigned',_cp850'in_progress',_cp850'draft',_cp850'submitted',_cp850'under_review',_cp850'need_revision',_cp850'resubmitted',_cp850'approved',_cp850'rejected',_cp850'report_generated',_cp850'reported',_cp850'invoiced',_cp850'closed',_cp850'cancelled')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_containers`
--

LOCK TABLES `job_containers` WRITE;
/*!40000 ALTER TABLE `job_containers` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_containers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_events`
--

DROP TABLE IF EXISTS `job_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_events` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `job_order_id` char(36) NOT NULL,
  `event_type` varchar(100) NOT NULL,
  `event_title` varchar(200) NOT NULL,
  `event_description` text,
  `actor_id` char(36) DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_job_events_job` (`job_order_id`),
  KEY `idx_job_events_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_events`
--

LOCK TABLES `job_events` WRITE;
/*!40000 ALTER TABLE `job_events` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_events` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_orders`
--

DROP TABLE IF EXISTS `job_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_orders` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `job_order_no` varchar(80) NOT NULL,
  `job_date` date NOT NULL,
  `customer_id` char(36) NOT NULL,
  `survey_type_id` char(36) NOT NULL,
  `location_id` char(36) NOT NULL,
  `pic_customer_personnel_id` char(36) DEFAULT NULL,
  `pic_customer_name` varchar(150) DEFAULT NULL,
  `pic_customer_phone` varchar(50) DEFAULT NULL,
  `pic_customer_email` varchar(150) DEFAULT NULL,
  `reference_no` varchar(100) DEFAULT NULL,
  `spk_no` varchar(100) DEFAULT NULL,
  `spk_date` date DEFAULT NULL,
  `spk_file_id` char(36) DEFAULT NULL,
  `spk_notes` text,
  `booking_no` varchar(100) DEFAULT NULL,
  `do_no` varchar(100) DEFAULT NULL,
  `bl_no` varchar(100) DEFAULT NULL,
  `vessel` varchar(150) DEFAULT NULL,
  `voyage` varchar(100) DEFAULT NULL,
  `trucking_company` varchar(150) DEFAULT NULL,
  `priority` varchar(30) NOT NULL DEFAULT 'normal',
  `deadline` datetime(6) DEFAULT NULL,
  `instruction` text,
  `status` varchar(50) NOT NULL DEFAULT 'draft',
  `cancel_reason` text,
  `cancelled_at` datetime(6) DEFAULT NULL,
  `cancelled_by` char(36) DEFAULT NULL,
  `created_by` char(36) DEFAULT NULL,
  `updated_by` char(36) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_order_no` (`job_order_no`),
  UNIQUE KEY `idx_job_orders_no` (`job_order_no`),
  KEY `idx_job_orders_customer` (`customer_id`),
  KEY `idx_job_orders_status` (`status`),
  KEY `idx_job_orders_date` (`job_date`),
  KEY `idx_job_orders_survey_type` (`survey_type_id`),
  KEY `idx_job_orders_deleted` (`deleted_at`),
  KEY `fk_job_orders_location` (`location_id`),
  KEY `idx_job_orders_pic_customer_personnel` (`pic_customer_personnel_id`),
  KEY `idx_job_orders_spk_file` (`spk_file_id`),
  CONSTRAINT `fk_job_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_job_orders_location` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`),
  CONSTRAINT `fk_job_orders_pic_customer_personnel` FOREIGN KEY (`pic_customer_personnel_id`) REFERENCES `customer_personnel` (`id`),
  CONSTRAINT `fk_job_orders_spk_file` FOREIGN KEY (`spk_file_id`) REFERENCES `file_objects` (`id`),
  CONSTRAINT `fk_job_orders_survey_type` FOREIGN KEY (`survey_type_id`) REFERENCES `survey_types` (`id`),
  CONSTRAINT `chk_job_orders_priority` CHECK ((`priority` in (_utf8mb4'normal',_utf8mb4'urgent'))),
  CONSTRAINT `chk_job_orders_status` CHECK ((`status` in (_cp850'draft',_cp850'assigned',_cp850'in_progress',_cp850'all_survey_submitted',_cp850'under_review',_cp850'need_revision',_cp850'all_survey_decided',_cp850'all_survey_approved',_cp850'completed_with_rejection',_cp850'report_generated',_cp850'ready_to_invoice',_cp850'invoiced',_cp850'paid',_cp850'closed',_cp850'cancelled')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_orders`
--

LOCK TABLES `job_orders` WRITE;
/*!40000 ALTER TABLE `job_orders` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_orders` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `locations`
--

DROP TABLE IF EXISTS `locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locations` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_id` char(36) DEFAULT NULL,
  `location_code` varchar(50) NOT NULL,
  `location_name` varchar(200) NOT NULL,
  `location_type` varchar(50) NOT NULL,
  `address` text,
  `city` varchar(100) DEFAULT NULL,
  `province` varchar(100) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `gps_latitude` decimal(10,7) DEFAULT NULL,
  `gps_longitude` decimal(10,7) DEFAULT NULL,
  `pic_name` varchar(150) DEFAULT NULL,
  `pic_phone` varchar(50) DEFAULT NULL,
  `pic_email` varchar(150) DEFAULT NULL,
  `access_notes` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_locations_customer_code` (`customer_id`,`location_code`),
  KEY `idx_locations_name` (`location_name`),
  KEY `idx_locations_type` (`location_type`),
  KEY `idx_locations_status` (`status`),
  KEY `idx_locations_customer` (`customer_id`),
  KEY `idx_locations_customer_status` (`customer_id`,`status`),
  CONSTRAINT `fk_locations_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `chk_locations_latitude` CHECK (((`gps_latitude` is null) or ((`gps_latitude` >= -(90)) and (`gps_latitude` <= 90)))),
  CONSTRAINT `chk_locations_longitude` CHECK (((`gps_longitude` is null) or ((`gps_longitude` >= -(180)) and (`gps_longitude` <= 180)))),
  CONSTRAINT `chk_locations_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive'))),
  CONSTRAINT `chk_locations_type` CHECK ((`location_type` in (_utf8mb4'depot',_utf8mb4'yard',_utf8mb4'port',_utf8mb4'warehouse',_utf8mb4'factory',_utf8mb4'customer_site',_utf8mb4'other')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `locations`
--

LOCK TABLES `locations` WRITE;
/*!40000 ALTER TABLE `locations` DISABLE KEYS */;
/*!40000 ALTER TABLE `locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `maintenance_schemes`
--

DROP TABLE IF EXISTS `maintenance_schemes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `maintenance_schemes` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(50) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text,
  `requires_next_examination_date` tinyint(1) NOT NULL DEFAULT '0',
  `default_interval_months` int DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_maintenance_schemes_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `maintenance_schemes`
--

LOCK TABLES `maintenance_schemes` WRITE;
/*!40000 ALTER TABLE `maintenance_schemes` DISABLE KEYS */;
INSERT INTO `maintenance_schemes` VALUES ('8ea76c89-9541-11f1-9595-002b67818c25','ACEP','ACEP','Approved continuous examination program.',1,NULL,'active','2026-08-11 12:00:22.392648','2026-08-11 12:00:22.392648'),('8ea77134-9541-11f1-9595-002b67818c25','PES','PES','Periodic examination scheme.',1,30,'active','2026-08-11 12:00:22.392648','2026-08-11 12:00:22.392648'),('8ea772f3-9541-11f1-9595-002b67818c25','IICL','IICL','IICL-based maintenance reference.',0,NULL,'active','2026-08-11 12:00:22.392648','2026-08-11 12:00:22.392648'),('8ea773dd-9541-11f1-9595-002b67818c25','ISO','ISO','ISO-based maintenance reference.',0,NULL,'active','2026-08-11 12:00:22.392648','2026-08-11 12:00:22.392648'),('8ea774cf-9541-11f1-9595-002b67818c25','NED','NED','Next examination date reference.',1,NULL,'active','2026-08-11 12:00:22.392648','2026-08-11 12:00:22.392648'),('8ea775b6-9541-11f1-9595-002b67818c25','OTHER','Other','Other maintenance scheme.',0,NULL,'active','2026-08-11 12:00:22.392648','2026-08-11 12:00:22.392648');
/*!40000 ALTER TABLE `maintenance_schemes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `numbering_sequences`
--

DROP TABLE IF EXISTS `numbering_sequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `numbering_sequences` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `document_type` varchar(50) NOT NULL,
  `period_key` varchar(20) NOT NULL,
  `last_number` bigint NOT NULL DEFAULT '0',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `document_type` (`document_type`,`period_key`),
  CONSTRAINT `chk_numbering_sequences_last_number` CHECK ((`last_number` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `numbering_sequences`
--

LOCK TABLES `numbering_sequences` WRITE;
/*!40000 ALTER TABLE `numbering_sequences` DISABLE KEYS */;
/*!40000 ALTER TABLE `numbering_sequences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `numbering_settings`
--

DROP TABLE IF EXISTS `numbering_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `numbering_settings` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `document_type` varchar(50) NOT NULL,
  `prefix` varchar(20) NOT NULL DEFAULT 'GIFT',
  `doc_code` varchar(20) NOT NULL,
  `year_format` varchar(10) NOT NULL DEFAULT 'YYYY',
  `running_digits` int NOT NULL DEFAULT '6',
  `reset_period` varchar(20) NOT NULL DEFAULT 'yearly',
  `format_preview` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_numbering_settings_active` (`document_type`),
  CONSTRAINT `chk_numbering_settings_reset_period` CHECK ((`reset_period` in (_utf8mb4'yearly',_utf8mb4'monthly',_utf8mb4'never'))),
  CONSTRAINT `chk_numbering_settings_running_digits` CHECK ((`running_digits` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `numbering_settings`
--

LOCK TABLES `numbering_settings` WRITE;
/*!40000 ALTER TABLE `numbering_settings` DISABLE KEYS */;
INSERT INTO `numbering_settings` VALUES ('8ad34175-9541-11f1-9595-002b67818c25','job_order','GIFT','JO','YYYY',6,'yearly','GIFT-JO-2026-000001',1,'2026-08-11 12:00:15.970530','2026-08-11 12:00:15.970530'),('8ad344f1-9541-11f1-9595-002b67818c25','assignment','GIFT','ASG','YYYY',6,'yearly','GIFT-ASG-2026-000001',1,'2026-08-11 12:00:15.970530','2026-08-11 12:00:15.970530'),('8ad3462f-9541-11f1-9595-002b67818c25','survey','GIFT','SVY','YYYY',6,'yearly','GIFT-SVY-2026-000001',1,'2026-08-11 12:00:15.970530','2026-08-11 12:00:15.970530'),('8ad34740-9541-11f1-9595-002b67818c25','report','GIFT','RPT','YYYY',6,'yearly','GIFT-RPT-2026-000001',1,'2026-08-11 12:00:15.970530','2026-08-11 12:00:15.970530'),('8ad34800-9541-11f1-9595-002b67818c25','eir','GIFT','EIR','YYYY',6,'yearly','GIFT-EIR-2026-000001',1,'2026-08-11 12:00:15.970530','2026-08-11 12:00:15.970530'),('8ad348a5-9541-11f1-9595-002b67818c25','invoice','GIFT','INV','YYYY',6,'yearly','GIFT-INV-2026-000001',1,'2026-08-11 12:00:15.970530','2026-08-11 12:00:15.970530'),('8ad3494c-9541-11f1-9595-002b67818c25','payment_receipt','GIFT','RCP','YYYY',6,'yearly','GIFT-RCP-2026-000001',1,'2026-08-11 12:00:15.970530','2026-08-11 12:00:15.970530'),('8eb23f37-9541-11f1-9595-002b67818c25','fitness_application','GIFT','FAP','YYYY',6,'yearly','GIFT-FAP-2026-000001',1,'2026-08-11 12:00:22.465216','2026-08-11 12:00:22.465216'),('8eb242ff-9541-11f1-9595-002b67818c25','fitness_container_import','GIFT','FCI','YYYY',6,'yearly','GIFT-FCI-2026-000001',1,'2026-08-11 12:00:22.465216','2026-08-11 12:00:22.465216'),('8eb244f5-9541-11f1-9595-002b67818c25','fitness_assignment','GIFT','FAS','YYYY',6,'yearly','GIFT-FAS-2026-000001',1,'2026-08-11 12:00:22.465216','2026-08-11 12:00:22.465216'),('8eb245bf-9541-11f1-9595-002b67818c25','fitness_inspection','GIFT','FIN','YYYY',6,'yearly','GIFT-FIN-2026-000001',1,'2026-08-11 12:00:22.465216','2026-08-11 12:00:22.465216'),('8eb24675-9541-11f1-9595-002b67818c25','repair_followup','GIFT','RFL','YYYY',6,'yearly','GIFT-RFL-2026-000001',1,'2026-08-11 12:00:22.465216','2026-08-11 12:00:22.465216'),('8eb2472a-9541-11f1-9595-002b67818c25','fitness_review','GIFT','FRV','YYYY',6,'yearly','GIFT-FRV-2026-000001',1,'2026-08-11 12:00:22.465216','2026-08-11 12:00:22.465216'),('8eb247dd-9541-11f1-9595-002b67818c25','fitness_approval','GIFT','FAPV','YYYY',6,'yearly','GIFT-FAPV-2026-000001',1,'2026-08-11 12:00:22.465216','2026-08-11 12:00:22.465216'),('8eb2488d-9541-11f1-9595-002b67818c25','approval_document','GIFT','ADOC','YYYY',6,'yearly','GIFT-ADOC-2026-000001',1,'2026-08-11 12:00:22.465216','2026-08-11 12:00:22.465216'),('8eb24937-9541-11f1-9595-002b67818c25','release_letter','GIFT','REL','YYYY',6,'yearly','GIFT-REL-2026-000001',1,'2026-08-11 12:00:22.465216','2026-08-11 12:00:22.465216');
/*!40000 ALTER TABLE `numbering_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `object_deletion_queue`
--

DROP TABLE IF EXISTS `object_deletion_queue`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `object_deletion_queue` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `bucket_name` varchar(160) NOT NULL,
  `object_key` varchar(700) NOT NULL,
  `reason` varchar(100) NOT NULL,
  `requested_by` char(36) DEFAULT NULL,
  `requested_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `eligible_after` datetime(6) NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'pending',
  `processed_at` datetime(6) DEFAULT NULL,
  `error_message` text,
  `retry_count` int unsigned NOT NULL DEFAULT '0',
  `last_attempt_at` datetime(6) DEFAULT NULL,
  `next_retry_at` datetime(6) DEFAULT NULL,
  `locked_at` datetime(6) DEFAULT NULL,
  `locked_by` varchar(160) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_object_deletion_queue_key_status` (`object_key`,`status`),
  KEY `idx_object_deletion_queue_eligible` (`status`,`eligible_after`),
  KEY `fk_object_deletion_queue_requested_by` (`requested_by`),
  KEY `idx_object_deletion_queue_retry` (`status`,`next_retry_at`,`eligible_after`,`locked_at`),
  CONSTRAINT `fk_object_deletion_queue_requested_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`),
  CONSTRAINT `chk_object_deletion_queue_retry_count` CHECK ((`retry_count` >= 0)),
  CONSTRAINT `chk_object_deletion_queue_status` CHECK ((`status` in (_utf8mb4'pending',_utf8mb4'cancelled',_utf8mb4'processed',_utf8mb4'failed')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `object_deletion_queue`
--

LOCK TABLES `object_deletion_queue` WRITE;
/*!40000 ALTER TABLE `object_deletion_queue` DISABLE KEYS */;
/*!40000 ALTER TABLE `object_deletion_queue` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

DROP TABLE IF EXISTS `payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `payments` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `payment_no` varchar(80) DEFAULT NULL,
  `invoice_id` char(36) NOT NULL,
  `payment_date` date NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `payment_method` varchar(50) DEFAULT NULL,
  `bank_account` varchar(150) DEFAULT NULL,
  `proof_file_id` char(36) DEFAULT NULL,
  `note` text,
  `created_by` char(36) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `cancelled_at` datetime(6) DEFAULT NULL,
  `cancelled_by` char(36) DEFAULT NULL,
  `cancel_reason` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `payment_no` (`payment_no`),
  KEY `idx_payments_invoice` (`invoice_id`),
  KEY `idx_payments_date` (`payment_date`),
  CONSTRAINT `fk_payments_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payments`
--

LOCK TABLES `payments` WRITE;
/*!40000 ALTER TABLE `payments` DISABLE KEYS */;
/*!40000 ALTER TABLE `payments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(120) NOT NULL,
  `name` varchar(150) DEFAULT NULL,
  `module` varchar(80) NOT NULL,
  `action` varchar(50) NOT NULL,
  `scope` varchar(50) NOT NULL DEFAULT 'all',
  `description` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_permissions_module_action` (`module`,`action`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES ('8ad16350-9541-11f1-9595-002b67818c25','*.*.all',NULL,'*','*','all','Wildcard permission for super admin'),('8ad167b7-9541-11f1-9595-002b67818c25','users.manage.all',NULL,'users','manage','all','Manage users'),('8ad1696a-9541-11f1-9595-002b67818c25','roles.manage.all',NULL,'roles','manage','all','Manage roles and permissions'),('8ad16a59-9541-11f1-9595-002b67818c25','company_profiles.manage.all',NULL,'company_profiles','manage','all','Manage company profile'),('8ad16b3f-9541-11f1-9595-002b67818c25','numbering_settings.manage.all',NULL,'numbering_settings','manage','all','Manage numbering settings'),('8ad16c24-9541-11f1-9595-002b67818c25','files.manage.all',NULL,'files','manage','all','Manage file metadata'),('8ad16d2f-9541-11f1-9595-002b67818c25','customers.manage.all',NULL,'customers','manage','all','Manage customers'),('8ad16e3c-9541-11f1-9595-002b67818c25','locations.manage.all',NULL,'locations','manage','all','Manage locations'),('8ad16f4c-9541-11f1-9595-002b67818c25','surveyor_profiles.manage.all',NULL,'surveyor_profiles','manage','all','Manage surveyor profiles'),('8ad1706d-9541-11f1-9595-002b67818c25','surveyor_profiles.view.own',NULL,'surveyor_profiles','view','own','View own surveyor profile'),('8ad1718a-9541-11f1-9595-002b67818c25','container_types.manage.all',NULL,'container_types','manage','all','Manage container types'),('8ad17262-9541-11f1-9595-002b67818c25','survey_types.manage.all',NULL,'survey_types','manage','all','Manage survey types'),('8ad17339-9541-11f1-9595-002b67818c25','cedex.manage.all',NULL,'cedex','manage','all','Manage CEDEX master data'),('8ad17409-9541-11f1-9595-002b67818c25','master_data.view.all',NULL,'master_data','view','all','View master data'),('8ad174ed-9541-11f1-9595-002b67818c25','dashboard.view.all',NULL,'dashboard','view','all','View dashboards'),('8b193e4e-9541-11f1-9595-002b67818c25','customers.view.all',NULL,'customers','view','all','View customers'),('8b19483a-9541-11f1-9595-002b67818c25','customers.create.all',NULL,'customers','create','all','Create customers'),('8b194ab8-9541-11f1-9595-002b67818c25','customers.update.all',NULL,'customers','update','all','Update customers'),('8b194ddf-9541-11f1-9595-002b67818c25','customers.delete.all',NULL,'customers','delete','all','Deactivate customers'),('8b19500f-9541-11f1-9595-002b67818c25','locations.view.all',NULL,'locations','view','all','View locations'),('8b1951db-9541-11f1-9595-002b67818c25','locations.create.all',NULL,'locations','create','all','Create locations'),('8b195411-9541-11f1-9595-002b67818c25','locations.update.all',NULL,'locations','update','all','Update locations'),('8b1955e7-9541-11f1-9595-002b67818c25','locations.delete.all',NULL,'locations','delete','all','Deactivate locations'),('8b195787-9541-11f1-9595-002b67818c25','surveyors.view.all',NULL,'surveyors','view','all','View surveyor profiles'),('8b1959aa-9541-11f1-9595-002b67818c25','surveyors.create.all',NULL,'surveyors','create','all','Create surveyor profiles'),('8b195b93-9541-11f1-9595-002b67818c25','surveyors.update.all',NULL,'surveyors','update','all','Update surveyor profiles'),('8b195dcf-9541-11f1-9595-002b67818c25','surveyors.delete.all',NULL,'surveyors','delete','all','Deactivate surveyor profiles'),('8b19605c-9541-11f1-9595-002b67818c25','container_types.view.all',NULL,'container_types','view','all','View container types'),('8b19623a-9541-11f1-9595-002b67818c25','container_types.create.all',NULL,'container_types','create','all','Create container types'),('8b196453-9541-11f1-9595-002b67818c25','container_types.update.all',NULL,'container_types','update','all','Update container types'),('8b19661a-9541-11f1-9595-002b67818c25','container_types.delete.all',NULL,'container_types','delete','all','Deactivate container types'),('8b1967f7-9541-11f1-9595-002b67818c25','survey_types.view.all',NULL,'survey_types','view','all','View survey types'),('8b1969b5-9541-11f1-9595-002b67818c25','survey_types.create.all',NULL,'survey_types','create','all','Create survey types'),('8b196b58-9541-11f1-9595-002b67818c25','survey_types.update.all',NULL,'survey_types','update','all','Update survey types'),('8b196d5c-9541-11f1-9595-002b67818c25','survey_types.delete.all',NULL,'survey_types','delete','all','Deactivate survey types'),('8b196f4b-9541-11f1-9595-002b67818c25','cedex_locations.view.all',NULL,'cedex_locations','view','all','View CEDEX locations'),('8b1970e5-9541-11f1-9595-002b67818c25','cedex_locations.create.all',NULL,'cedex_locations','create','all','Create CEDEX locations'),('8b197213-9541-11f1-9595-002b67818c25','cedex_locations.update.all',NULL,'cedex_locations','update','all','Update CEDEX locations'),('8b197337-9541-11f1-9595-002b67818c25','cedex_locations.delete.all',NULL,'cedex_locations','delete','all','Deactivate CEDEX locations'),('8b197454-9541-11f1-9595-002b67818c25','cedex_components.view.all',NULL,'cedex_components','view','all','View CEDEX components'),('8b197595-9541-11f1-9595-002b67818c25','cedex_components.create.all',NULL,'cedex_components','create','all','Create CEDEX components'),('8b1976c1-9541-11f1-9595-002b67818c25','cedex_components.update.all',NULL,'cedex_components','update','all','Update CEDEX components'),('8b1977e5-9541-11f1-9595-002b67818c25','cedex_components.delete.all',NULL,'cedex_components','delete','all','Deactivate CEDEX components'),('8b197927-9541-11f1-9595-002b67818c25','cedex_damages.view.all',NULL,'cedex_damages','view','all','View CEDEX damages'),('8b197a85-9541-11f1-9595-002b67818c25','cedex_damages.create.all',NULL,'cedex_damages','create','all','Create CEDEX damages'),('8b197c30-9541-11f1-9595-002b67818c25','cedex_damages.update.all',NULL,'cedex_damages','update','all','Update CEDEX damages'),('8b197e53-9541-11f1-9595-002b67818c25','cedex_damages.delete.all',NULL,'cedex_damages','delete','all','Deactivate CEDEX damages'),('8b1980a4-9541-11f1-9595-002b67818c25','cedex_repairs.view.all',NULL,'cedex_repairs','view','all','View CEDEX repairs'),('8b19828d-9541-11f1-9595-002b67818c25','cedex_repairs.create.all',NULL,'cedex_repairs','create','all','Create CEDEX repairs'),('8b198485-9541-11f1-9595-002b67818c25','cedex_repairs.update.all',NULL,'cedex_repairs','update','all','Update CEDEX repairs'),('8b1986c7-9541-11f1-9595-002b67818c25','cedex_repairs.delete.all',NULL,'cedex_repairs','delete','all','Deactivate CEDEX repairs'),('8b1988e6-9541-11f1-9595-002b67818c25','cedex_materials.view.all',NULL,'cedex_materials','view','all','View CEDEX materials'),('8b198ad2-9541-11f1-9595-002b67818c25','cedex_materials.create.all',NULL,'cedex_materials','create','all','Create CEDEX materials'),('8b198ce5-9541-11f1-9595-002b67818c25','cedex_materials.update.all',NULL,'cedex_materials','update','all','Update CEDEX materials'),('8b198e6e-9541-11f1-9595-002b67818c25','cedex_materials.delete.all',NULL,'cedex_materials','delete','all','Deactivate CEDEX materials'),('8b199096-9541-11f1-9595-002b67818c25','responsibility_codes.view.all',NULL,'responsibility_codes','view','all','View responsibility codes'),('8b19927c-9541-11f1-9595-002b67818c25','responsibility_codes.create.all',NULL,'responsibility_codes','create','all','Create responsibility codes'),('8b199458-9541-11f1-9595-002b67818c25','responsibility_codes.update.all',NULL,'responsibility_codes','update','all','Update responsibility codes'),('8b1995de-9541-11f1-9595-002b67818c25','responsibility_codes.delete.all',NULL,'responsibility_codes','delete','all','Deactivate responsibility codes'),('8b199719-9541-11f1-9595-002b67818c25','cedex_locations.manage.all',NULL,'cedex_locations','manage','all','Manage CEDEX locations'),('8b199853-9541-11f1-9595-002b67818c25','cedex_components.manage.all',NULL,'cedex_components','manage','all','Manage CEDEX components'),('8b199994-9541-11f1-9595-002b67818c25','cedex_damages.manage.all',NULL,'cedex_damages','manage','all','Manage CEDEX damages'),('8b199ae7-9541-11f1-9595-002b67818c25','cedex_repairs.manage.all',NULL,'cedex_repairs','manage','all','Manage CEDEX repairs'),('8b199c69-9541-11f1-9595-002b67818c25','cedex_materials.manage.all',NULL,'cedex_materials','manage','all','Manage CEDEX materials'),('8b199e39-9541-11f1-9595-002b67818c25','responsibility_codes.manage.all',NULL,'responsibility_codes','manage','all','Manage responsibility codes'),('8b19a077-9541-11f1-9595-002b67818c25','surveyors.manage.all',NULL,'surveyors','manage','all','Manage surveyor profiles'),('8b92d09a-9541-11f1-9595-002b67818c25','jobs.view.all',NULL,'jobs','view','all','View jobs'),('8b92d476-9541-11f1-9595-002b67818c25','jobs.create.all',NULL,'jobs','create','all','Create jobs'),('8b92d62d-9541-11f1-9595-002b67818c25','jobs.update.all',NULL,'jobs','update','all','Update jobs'),('8b92d72f-9541-11f1-9595-002b67818c25','jobs.cancel.all',NULL,'jobs','cancel','all','Cancel jobs'),('8b92d84f-9541-11f1-9595-002b67818c25','jobs.manage.all',NULL,'jobs','manage','all','Manage jobs'),('8b92d954-9541-11f1-9595-002b67818c25','job_containers.view.all',NULL,'job_containers','view','all','View job containers'),('8b92da56-9541-11f1-9595-002b67818c25','job_containers.create.all',NULL,'job_containers','create','all','Create job containers'),('8b92db56-9541-11f1-9595-002b67818c25','job_containers.import.all',NULL,'job_containers','import','all','Import job containers'),('8b92dc86-9541-11f1-9595-002b67818c25','job_containers.update.all',NULL,'job_containers','update','all','Update job containers'),('8b92dd89-9541-11f1-9595-002b67818c25','job_containers.delete.all',NULL,'job_containers','delete','all','Delete job containers'),('8b92debc-9541-11f1-9595-002b67818c25','job_containers.reassign.all',NULL,'job_containers','reassign','all','Reassign job containers'),('8b92dfc6-9541-11f1-9595-002b67818c25','assignments.view.all',NULL,'assignments','view','all','View assignments'),('8b92e0b4-9541-11f1-9595-002b67818c25','assignments.assign.all',NULL,'assignments','assign','all','Assign surveyors'),('8b92e1a1-9541-11f1-9595-002b67818c25','assignments.reassign.all',NULL,'assignments','reassign','all','Reassign surveyors'),('8b92e299-9541-11f1-9595-002b67818c25','assignments.manage.all',NULL,'assignments','manage','all','Manage assignments'),('8bfed8ec-9541-11f1-9595-002b67818c25','surveyor_jobs.view.assigned','View Assigned Surveyor Jobs','surveyor_jobs','view','assigned','Melihat job yang ditugaskan ke surveyor login'),('8bfedd88-9541-11f1-9595-002b67818c25','surveys.view.assigned','View Assigned Surveys','surveys','view','assigned','Melihat survey milik assignment sendiri'),('8bfedf46-9541-11f1-9595-002b67818c25','surveys.start.assigned','Start Assigned Survey','surveys','start','assigned','Memulai survey untuk container yang ditugaskan'),('8bfee05f-9541-11f1-9595-002b67818c25','surveys.update.assigned','Update Assigned Survey','surveys','update','assigned','Mengubah draft/revisi survey sendiri'),('8bfee17f-9541-11f1-9595-002b67818c25','surveys.submit.assigned','Submit Assigned Survey','surveys','submit','assigned','Submit survey sendiri untuk review'),('8bfee28a-9541-11f1-9595-002b67818c25','survey_damages.view.assigned','View Assigned Survey Damages','survey_damages','view','assigned','Melihat damage pada survey sendiri'),('8bfee37f-9541-11f1-9595-002b67818c25','survey_damages.create.assigned','Create Assigned Survey Damage','survey_damages','create','assigned','Membuat damage pada survey sendiri'),('8bfee4b6-9541-11f1-9595-002b67818c25','survey_damages.update.assigned','Update Assigned Survey Damage','survey_damages','update','assigned','Mengubah damage pada survey sendiri'),('8bfee5ca-9541-11f1-9595-002b67818c25','survey_damages.delete.assigned','Delete Assigned Survey Damage','survey_damages','delete','assigned','Menghapus damage pada survey sendiri'),('8bfee6c8-9541-11f1-9595-002b67818c25','survey_photos.upload.assigned','Upload Assigned Survey Photo','survey_photos','upload','assigned','Upload foto evidence pada survey sendiri'),('8bfee8b5-9541-11f1-9595-002b67818c25','survey_photos.view.assigned','View Assigned Survey Photos','survey_photos','view','assigned','Melihat foto evidence pada survey sendiri'),('8c6ebe7d-9541-11f1-9595-002b67818c25','surveys.view.all','View All Surveys','surveys','view','all','Melihat seluruh survey untuk monitoring Admin'),('8c6ec336-9541-11f1-9595-002b67818c25','reviews.view.all','View Reviews','reviews','view','all','Melihat survey pending review'),('8c6ec50a-9541-11f1-9595-002b67818c25','reviews.manage.all','Manage Reviews','reviews','manage','all','Approve, reject, dan need revision survey'),('8c6ec66c-9541-11f1-9595-002b67818c25','reports.view.all','View Reports','reports','view','all','Melihat arsip report'),('8c6ec77d-9541-11f1-9595-002b67818c25','reports.generate.all','Generate Reports','reports','generate','all','Membuat report dari survey approved'),('8c6ec894-9541-11f1-9595-002b67818c25','reports.version.all','Version Reports','reports','version','all','Membuat revisi report'),('8cc0e74d-9541-11f1-9595-002b67818c25','finance.view.all','View Finance','finance','view','all','Melihat dashboard finance, invoice, payment, outstanding'),('8cc0f185-9541-11f1-9595-002b67818c25','finance.manage.all','Manage Finance','finance','manage','all','Mengelola price list, invoice, dan payment'),('8cc0f4bc-9541-11f1-9595-002b67818c25','finance.invoice.create.all','Create Invoice','finance.invoice','create','all','Membuat invoice draft'),('8cc0f678-9541-11f1-9595-002b67818c25','finance.payment.create.all','Create Payment','finance.payment','create','all','Mencatat payment'),('8eb2e926-9541-11f1-9595-002b67818c25','container_manufacturers.view.all','View Container Manufacturers','container_manufacturers','view','all','Melihat master pabrik pembuat peti kemas'),('8eb2ed4d-9541-11f1-9595-002b67818c25','container_manufacturers.manage.all','Manage Container Manufacturers','container_manufacturers','manage','all','Mengelola master pabrik pembuat peti kemas'),('8eb2ffbc-9541-11f1-9595-002b67818c25','fitness_approval_categories.view.all','View Fitness Approval Categories','fitness_approval_categories','view','all','Melihat kategori persetujuan kelaikan'),('8eb30106-9541-11f1-9595-002b67818c25','fitness_approval_categories.manage.all','Manage Fitness Approval Categories','fitness_approval_categories','manage','all','Mengelola kategori persetujuan kelaikan'),('8eb30228-9541-11f1-9595-002b67818c25','maintenance_schemes.view.all','View Maintenance Schemes','maintenance_schemes','view','all','Melihat skema pemeliharaan peti kemas'),('8eb30341-9541-11f1-9595-002b67818c25','maintenance_schemes.manage.all','Manage Maintenance Schemes','maintenance_schemes','manage','all','Mengelola skema pemeliharaan peti kemas'),('8eb3045f-9541-11f1-9595-002b67818c25','inspection_areas.view.all','View Inspection Areas','inspection_areas','view','all','Melihat area pemeriksaan peti kemas'),('8eb30541-9541-11f1-9595-002b67818c25','inspection_areas.manage.all','Manage Inspection Areas','inspection_areas','manage','all','Mengelola area pemeriksaan peti kemas'),('8eb3062e-9541-11f1-9595-002b67818c25','structural_components.view.all','View Structural Components','structural_components','view','all','Melihat komponen struktur peti kemas'),('8eb345ea-9541-11f1-9595-002b67818c25','structural_components.manage.all','Manage Structural Components','structural_components','manage','all','Mengelola komponen struktur peti kemas'),('8eb3474d-9541-11f1-9595-002b67818c25','structural_damage_criteria.view.all','View Structural Damage Criteria','structural_damage_criteria','view','all','Melihat kriteria kerusakan struktur'),('8eb3485b-9541-11f1-9595-002b67818c25','structural_damage_criteria.manage.all','Manage Structural Damage Criteria','structural_damage_criteria','manage','all','Mengelola kriteria kerusakan struktur'),('8eb3497c-9541-11f1-9595-002b67818c25','finding_severities.view.all','View Finding Severities','finding_severities','view','all','Melihat tingkat temuan'),('8eb34a7c-9541-11f1-9595-002b67818c25','finding_severities.manage.all','Manage Finding Severities','finding_severities','manage','all','Mengelola tingkat temuan'),('8eb34b6c-9541-11f1-9595-002b67818c25','inspection_test_parameters.view.all','View Inspection Test Parameters','inspection_test_parameters','view','all','Melihat parameter pengujian kelaikan'),('8eb34c55-9541-11f1-9595-002b67818c25','inspection_test_parameters.manage.all','Manage Inspection Test Parameters','inspection_test_parameters','manage','all','Mengelola parameter pengujian kelaikan'),('8eb34d48-9541-11f1-9595-002b67818c25','fitness_checklist_templates.view.all','View Fitness Checklist Templates','fitness_checklist_templates','view','all','Melihat template checklist kelaikan'),('8eb34e3e-9541-11f1-9595-002b67818c25','fitness_checklist_templates.manage.all','Manage Fitness Checklist Templates','fitness_checklist_templates','manage','all','Mengelola template checklist kelaikan'),('8eb34f6b-9541-11f1-9595-002b67818c25','evidence_photo_categories.view.all','View Evidence Photo Categories','evidence_photo_categories','view','all','Melihat kategori foto evidence'),('8eb3505e-9541-11f1-9595-002b67818c25','evidence_photo_categories.manage.all','Manage Evidence Photo Categories','evidence_photo_categories','manage','all','Mengelola kategori foto evidence'),('8eb3514f-9541-11f1-9595-002b67818c25','inspection_recommendations.view.all','View Inspection Recommendations','inspection_recommendations','view','all','Melihat rekomendasi hasil pemeriksaan'),('8eb3523a-9541-11f1-9595-002b67818c25','inspection_recommendations.manage.all','Manage Inspection Recommendations','inspection_recommendations','manage','all','Mengelola rekomendasi hasil pemeriksaan'),('8eb35325-9541-11f1-9595-002b67818c25','authorized_signers.view.all','View Authorized Signers','authorized_signers','view','all','Melihat pejabat penandatangan'),('8eb35414-9541-11f1-9595-002b67818c25','authorized_signers.manage.all','Manage Authorized Signers','authorized_signers','manage','all','Mengelola pejabat penandatangan'),('8eb35512-9541-11f1-9595-002b67818c25','fitness_applications.view.all','View Fitness Applications','fitness_applications','view','all','Melihat permohonan kelaikan'),('8eb35617-9541-11f1-9595-002b67818c25','fitness_applications.manage.all','Manage Fitness Applications','fitness_applications','manage','all','Mengelola permohonan kelaikan'),('8eb3571f-9541-11f1-9595-002b67818c25','application_containers.view.all','View Application Containers','application_containers','view','all','Melihat data peti kemas kelaikan'),('8eb35848-9541-11f1-9595-002b67818c25','application_containers.manage.all','Manage Application Containers','application_containers','manage','all','Mengelola data peti kemas kelaikan'),('8eb35933-9541-11f1-9595-002b67818c25','fitness_container_imports.view.all','View Fitness Container Imports','fitness_container_imports','view','all','Melihat import data peti kemas kelaikan'),('8eb35a28-9541-11f1-9595-002b67818c25','fitness_container_imports.manage.all','Manage Fitness Container Imports','fitness_container_imports','manage','all','Mengelola import data peti kemas kelaikan'),('8eb35b21-9541-11f1-9595-002b67818c25','fitness_assignments.view.all','View Fitness Assignments','fitness_assignments','view','all','Melihat assignment kelaikan'),('8eb35c33-9541-11f1-9595-002b67818c25','fitness_assignments.manage.all','Manage Fitness Assignments','fitness_assignments','manage','all','Mengelola assignment kelaikan'),('8eb35d28-9541-11f1-9595-002b67818c25','fitness_inspections.view.all','View Fitness Inspections','fitness_inspections','view','all','Melihat pemeriksaan kelaikan'),('8eb35e42-9541-11f1-9595-002b67818c25','fitness_inspections.manage.assigned','Manage Assigned Fitness Inspections','fitness_inspections','manage','assigned','Mengelola pemeriksaan kelaikan yang ditugaskan'),('8eb35f5c-9541-11f1-9595-002b67818c25','structural_findings.view.all','View Structural Findings','structural_findings','view','all','Melihat temuan struktur'),('8eb36056-9541-11f1-9595-002b67818c25','structural_findings.manage.assigned','Manage Assigned Structural Findings','structural_findings','manage','assigned','Mengelola temuan struktur yang ditugaskan'),('8eb36194-9541-11f1-9595-002b67818c25','repair_followups.view.all','View Repair Followups','repair_followups','view','all','Melihat tindak lanjut perbaikan'),('8eb36283-9541-11f1-9595-002b67818c25','repair_followups.manage.all','Manage Repair Followups','repair_followups','manage','all','Mengelola tindak lanjut perbaikan'),('8eb3636a-9541-11f1-9595-002b67818c25','fitness_reviews.view.all','View Fitness Reviews','fitness_reviews','view','all','Melihat review kelaikan'),('8eb36465-9541-11f1-9595-002b67818c25','fitness_reviews.manage.all','Manage Fitness Reviews','fitness_reviews','manage','all','Mengelola review kelaikan'),('8eb36564-9541-11f1-9595-002b67818c25','fitness_approvals.view.all','View Fitness Approvals','fitness_approvals','view','all','Melihat persetujuan kelaikan'),('8eb36654-9541-11f1-9595-002b67818c25','fitness_approvals.issue.all','Issue Fitness Approvals','fitness_approvals','issue','all','Menerbitkan persetujuan kelaikan'),('8eb3675d-9541-11f1-9595-002b67818c25','fitness_documents.view.all','View Fitness Documents','fitness_documents','view','all','Melihat dokumen kelaikan'),('8eb36851-9541-11f1-9595-002b67818c25','fitness_documents.manage.all','Manage Fitness Documents','fitness_documents','manage','all','Mengelola dokumen kelaikan'),('91d321c5-9541-11f1-9595-002b67818c25','cedex_code_proposals.view.all',NULL,'cedex_code_proposals','view','all','View ISO CEDEX code proposals'),('91d32695-9541-11f1-9595-002b67818c25','cedex_code_proposals.review.all',NULL,'cedex_code_proposals','review','all','Review ISO CEDEX code proposals'),('91e3129d-9541-11f1-9595-002b67818c25','survey_photos.delete.assigned','Delete Assigned Survey Photo','survey_photos','delete','assigned','Hapus lunak foto evidence pada survey sendiri');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `price_lists`
--

DROP TABLE IF EXISTS `price_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `price_lists` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_id` char(36) DEFAULT NULL,
  `survey_type_id` char(36) NOT NULL,
  `container_type_id` char(36) DEFAULT NULL,
  `description` varchar(200) DEFAULT NULL,
  `unit_price` decimal(15,2) NOT NULL,
  `currency` varchar(10) NOT NULL DEFAULT 'IDR',
  `tax_type` varchar(50) DEFAULT NULL,
  `effective_date` date NOT NULL,
  `expired_date` date DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_price_lists_customer` (`customer_id`),
  KEY `idx_price_lists_survey_type` (`survey_type_id`),
  KEY `idx_price_lists_effective` (`effective_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `price_lists`
--

LOCK TABLES `price_lists` WRITE;
/*!40000 ALTER TABLE `price_lists` DISABLE KEYS */;
/*!40000 ALTER TABLE `price_lists` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `refresh_tokens`
--

DROP TABLE IF EXISTS `refresh_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `refresh_tokens` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `user_id` char(36) NOT NULL,
  `token_hash` text NOT NULL,
  `device_name` varchar(150) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `expires_at` datetime(6) NOT NULL,
  `revoked_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_refresh_tokens_user` (`user_id`),
  KEY `idx_refresh_tokens_expires` (`expires_at`),
  KEY `idx_refresh_tokens_revoked` (`revoked_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `refresh_tokens`
--

LOCK TABLES `refresh_tokens` WRITE;
/*!40000 ALTER TABLE `refresh_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `refresh_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_snapshots`
--

DROP TABLE IF EXISTS `report_snapshots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_snapshots` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `report_version_id` char(36) NOT NULL,
  `snapshot_data` json NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `report_version_id` (`report_version_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_snapshots`
--

LOCK TABLES `report_snapshots` WRITE;
/*!40000 ALTER TABLE `report_snapshots` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_snapshots` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `report_versions`
--

DROP TABLE IF EXISTS `report_versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `report_versions` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `report_id` char(36) NOT NULL,
  `version_no` int NOT NULL,
  `file_id` char(36) DEFAULT NULL,
  `change_reason` text,
  `status` varchar(30) NOT NULL DEFAULT 'draft',
  `created_by` char(36) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `report_id` (`report_id`,`version_no`),
  KEY `idx_report_versions_report` (`report_id`),
  KEY `idx_report_versions_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `report_versions`
--

LOCK TABLES `report_versions` WRITE;
/*!40000 ALTER TABLE `report_versions` DISABLE KEYS */;
/*!40000 ALTER TABLE `report_versions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `reports`
--

DROP TABLE IF EXISTS `reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reports` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `report_no` varchar(80) NOT NULL,
  `report_type` varchar(50) NOT NULL DEFAULT 'container_inspection_report',
  `job_order_id` char(36) DEFAULT NULL,
  `job_container_id` char(36) DEFAULT NULL,
  `survey_id` char(36) DEFAULT NULL,
  `customer_id` char(36) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'pending_generation',
  `current_version_no` int NOT NULL DEFAULT '0',
  `qr_token` varchar(120) DEFAULT NULL,
  `validated_publicly` tinyint(1) NOT NULL DEFAULT '1',
  `generated_by` char(36) DEFAULT NULL,
  `created_by` char(36) DEFAULT NULL,
  `generated_at` datetime(6) DEFAULT NULL,
  `finalized_by` char(36) DEFAULT NULL,
  `approved_by` char(36) DEFAULT NULL,
  `approved_at` datetime(6) DEFAULT NULL,
  `notes` text,
  `finalized_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `report_no` (`report_no`),
  UNIQUE KEY `idx_reports_no` (`report_no`),
  UNIQUE KEY `qr_token` (`qr_token`),
  KEY `idx_reports_survey_active` (`survey_id`),
  KEY `idx_reports_job` (`job_order_id`),
  KEY `idx_reports_survey` (`survey_id`),
  KEY `idx_reports_status` (`status`),
  KEY `idx_reports_qr_token` (`qr_token`),
  KEY `fk_reports_customer` (`customer_id`),
  KEY `fk_reports_created_by` (`created_by`),
  KEY `fk_reports_approved_by` (`approved_by`),
  KEY `idx_reports_job_container` (`job_container_id`),
  CONSTRAINT `fk_reports_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_reports_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_reports_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_reports_job_container` FOREIGN KEY (`job_container_id`) REFERENCES `job_containers` (`id`),
  CONSTRAINT `fk_reports_job_order` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`id`),
  CONSTRAINT `fk_reports_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `reports`
--

LOCK TABLES `reports` WRITE;
/*!40000 ALTER TABLE `reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `responsibility_codes`
--

DROP TABLE IF EXISTS `responsibility_codes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `responsibility_codes` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_id` char(36) DEFAULT NULL,
  `code` varchar(30) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_responsibility_codes_customer_code` (`customer_id`,`code`),
  KEY `idx_responsibility_codes_status` (`status`),
  KEY `idx_responsibility_codes_customer` (`customer_id`),
  KEY `idx_responsibility_codes_customer_status` (`customer_id`,`status`),
  CONSTRAINT `fk_responsibility_codes_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `chk_responsibility_codes_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `responsibility_codes`
--

LOCK TABLES `responsibility_codes` WRITE;
/*!40000 ALTER TABLE `responsibility_codes` DISABLE KEYS */;
INSERT INTO `responsibility_codes` VALUES ('8ad85dad-9541-11f1-9595-002b67818c25',NULL,'C','Customer','Customer responsibility','active','2026-08-11 12:00:16.003906','2026-08-11 12:00:16.003906'),('8ad86177-9541-11f1-9595-002b67818c25',NULL,'O','Owner','Owner responsibility','active','2026-08-11 12:00:16.003906','2026-08-11 12:00:16.003906'),('8ad862c1-9541-11f1-9595-002b67818c25',NULL,'D','Depot','Depot responsibility','active','2026-08-11 12:00:16.003906','2026-08-11 12:00:16.003906'),('8ad86392-9541-11f1-9595-002b67818c25',NULL,'T','Trucker','Trucker responsibility','active','2026-08-11 12:00:16.003906','2026-08-11 12:00:16.003906'),('8ad86457-9541-11f1-9595-002b67818c25',NULL,'U','Unknown','Unknown responsibility','active','2026-08-11 12:00:16.003906','2026-08-11 12:00:16.003906');
/*!40000 ALTER TABLE `responsibility_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permissions`
--

DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `role_id` char(36) NOT NULL,
  `permission_id` char(36) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `role_id` (`role_id`,`permission_id`),
  KEY `idx_role_permissions_role` (`role_id`),
  KEY `idx_role_permissions_permission` (`permission_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_permissions`
--

LOCK TABLES `role_permissions` WRITE;
/*!40000 ALTER TABLE `role_permissions` DISABLE KEYS */;
INSERT INTO `role_permissions` VALUES ('8ad208b1-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8ad16350-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad21189-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8ad17339-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad21535-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8ad1718a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad21847-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8ad16d2f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad21a76-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8ad174ed-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad21c44-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8ad174ed-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad21df4-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8ad174ed-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad21ffa-9541-11f1-9595-002b67818c25','8ad0af90-9541-11f1-9595-002b67818c25','8ad174ed-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad22227-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8ad174ed-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad22547-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8ad16e3c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad227e6-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8ad17409-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad229c1-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8ad17409-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad22b97-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8ad17409-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad22dad-9541-11f1-9595-002b67818c25','8ad0af90-9541-11f1-9595-002b67818c25','8ad17409-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad22f3a-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8ad17409-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad23102-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8ad17262-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad23395-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8ad16f4c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8ad235eb-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8ad1706d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:15.961573'),('8b1a5607-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b199853-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.435928'),('8b1a5cd7-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b199994-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.435928'),('8b1a5f1e-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b199719-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.435928'),('8b1a60c0-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b199c69-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.435928'),('8b1a62a0-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b199ae7-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.435928'),('8b1a735c-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b199e39-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.435928'),('8b1a7aba-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b19a077-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.435928'),('8b1b1089-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b197454-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b14fa-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b197454-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b171e-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b197927-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b18b3-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b197927-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b1ac1-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b196f4b-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b1c3e-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b196f4b-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b1e14-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b1988e6-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b1f7f-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b1988e6-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b2177-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b1980a4-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b243f-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b1980a4-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b276c-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b19605c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b2978-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b19605c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b2b2f-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b193e4e-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b2c86-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b193e4e-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b2e10-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b19500f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b2f82-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b19500f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b3127-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b199096-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b3280-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b199096-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b3496-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b1967f7-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b35ef-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b1967f7-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b37a5-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b195787-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1b390d-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b195787-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.441058'),('8b1bd7e9-9541-11f1-9595-002b67818c25','8ad0af90-9541-11f1-9595-002b67818c25','8b19605c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.446144'),('8b1bdf8a-9541-11f1-9595-002b67818c25','8ad0af90-9541-11f1-9595-002b67818c25','8b193e4e-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.446144'),('8b1be2e6-9541-11f1-9595-002b67818c25','8ad0af90-9541-11f1-9595-002b67818c25','8b1967f7-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.446144'),('8b93708a-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b92e299-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.229503'),('8b9376b3-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b92da56-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.229503'),('8b9379b7-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b92dd89-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.229503'),('8b937cbc-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b92db56-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.229503'),('8b93803c-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b92debc-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.229503'),('8b938359-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b92dc86-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.229503'),('8b93862d-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b92d954-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.229503'),('8b9388ae-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8b92d84f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.229503'),('8b940634-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b92dfc6-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.233883'),('8b940a78-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b92dfc6-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.233883'),('8b940c60-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b92d954-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.233883'),('8b940dad-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b92d954-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.233883'),('8b940f4d-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8b92d09a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.233883'),('8b9410a8-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8b92d09a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.233883'),('8c00d2a8-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8bfee37f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.944785'),('8c00d716-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8bfee5ca-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.944785'),('8c00d8bf-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8bfee4b6-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.944785'),('8c00da3c-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8bfee28a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.944785'),('8c00dbb2-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8bfee6c8-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.944785'),('8c00dd38-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8bfee8b5-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.944785'),('8c00df0f-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8bfed8ec-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.944785'),('8c00e04c-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8bfedf46-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.944785'),('8c00e194-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8bfee17f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.944785'),('8c00e2e1-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8bfee05f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.944785'),('8c00e424-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8bfedd88-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.944785'),('8c015969-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8b197454-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.950501'),('8c015d01-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8b197927-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.950501'),('8c015ec2-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8b196f4b-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.950501'),('8c016021-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8b1988e6-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.950501'),('8c016174-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8b1980a4-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.950501'),('8c0162c8-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8b199096-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.950501'),('8c01cc7e-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8bfee37f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01d061-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8bfee37f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01d1f1-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8bfee37f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01d38f-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8bfee5ca-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01d4f7-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8bfee5ca-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01d613-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8bfee5ca-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01d786-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8bfee4b6-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01d918-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8bfee4b6-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01da36-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8bfee4b6-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01dbc1-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8bfee28a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01dd2e-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8bfee28a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01de51-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8bfee28a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01dff6-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8bfee6c8-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01e142-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8bfee6c8-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01e281-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8bfee6c8-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01e409-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8bfee8b5-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01e56a-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8bfee8b5-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01e6be-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8bfee8b5-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01e874-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8bfed8ec-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01e9a3-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8bfed8ec-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01eac1-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8bfed8ec-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01ec6c-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8bfedf46-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01eda8-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8bfedf46-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01eed0-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8bfedf46-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01f044-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8bfee17f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01f181-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8bfee17f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01f2c1-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8bfee17f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01f41e-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8bfee05f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01f565-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8bfee05f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c01f68d-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8bfee05f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c022c26-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8bfedd88-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c022e26-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8bfedd88-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c022f6f-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8bfedd88-9541-11f1-9595-002b67818c25','2026-08-11 12:00:17.953336'),('8c6f4c4d-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8c6ec77d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6f5334-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8c6ec77d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6f559b-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8c6ec77d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6f57d3-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8c6ec894-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6f59ba-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8c6ec894-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6f5b8d-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8c6ec894-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6f5d7c-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8c6ec66c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6f5f67-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8c6ec66c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6f60d6-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8c6ec66c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6f62a3-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8c6ec50a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6f6414-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8c6ec50a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6f6736-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8c6ec336-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6f688f-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8c6ec336-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6f6a1a-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8c6ec336-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.670447'),('8c6feeca-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8c6ebe7d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.675155'),('8c706cf0-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8c6ec66c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:18.678405'),('8cc18c39-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8cc0f4bc-9541-11f1-9595-002b67818c25','2026-08-11 12:00:19.209248'),('8cc1927c-9541-11f1-9595-002b67818c25','8ad0af90-9541-11f1-9595-002b67818c25','8cc0f4bc-9541-11f1-9595-002b67818c25','2026-08-11 12:00:19.209248'),('8cc195a2-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8cc0f185-9541-11f1-9595-002b67818c25','2026-08-11 12:00:19.209248'),('8cc197ce-9541-11f1-9595-002b67818c25','8ad0af90-9541-11f1-9595-002b67818c25','8cc0f185-9541-11f1-9595-002b67818c25','2026-08-11 12:00:19.209248'),('8cc19aa4-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8cc0f678-9541-11f1-9595-002b67818c25','2026-08-11 12:00:19.209248'),('8cc19d54-9541-11f1-9595-002b67818c25','8ad0af90-9541-11f1-9595-002b67818c25','8cc0f678-9541-11f1-9595-002b67818c25','2026-08-11 12:00:19.209248'),('8cc19fd8-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8cc0e74d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:19.209248'),('8cc1a24a-9541-11f1-9595-002b67818c25','8ad0af90-9541-11f1-9595-002b67818c25','8cc0e74d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:19.209248'),('8cc1aa6f-9541-11f1-9595-002b67818c25','8ad0af90-9541-11f1-9595-002b67818c25','8c6ec66c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:19.209248'),('8cc29411-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8cc0e74d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:19.216688'),('8eb3f405-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb35848-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb3f92e-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb3571f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb3fafa-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb35414-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb3fc78-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb35325-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb3fdf2-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb2ed4d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb3ff71-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb2e926-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb400b2-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb3505e-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb40226-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb34f6b-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb404da-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb34a7c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb408db-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb3497c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb40c5e-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb35617-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb40ec1-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb35512-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb41119-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb30106-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb4135a-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb2ffbc-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb4157a-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb36654-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb41835-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb36564-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb41a9f-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb35c33-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb41cd3-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb35b21-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb41f49-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb34e3e-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb42185-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb34d48-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb423a0-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb35a28-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb425e2-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb35933-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb42842-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb36851-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb42aa8-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb3675d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb42d0a-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb35e42-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb48374-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb35d28-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb48552-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb36465-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb486ad-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb3636a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb487f5-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb30541-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb4898d-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb3045f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb48ad5-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb3523a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb48c1f-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb3514f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb48d70-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb34c55-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb48ebc-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb34b6c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb48ff6-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb30341-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb4913f-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb30228-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb4926f-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb36283-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb49974-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb36194-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb49ae5-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb345ea-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb49c27-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb3062e-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb49d88-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb3485b-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb49edc-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb3474d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb4a019-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb36056-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb4a152-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','8eb35f5c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.475936'),('8eb50fbb-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb35848-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb51354-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb3571f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb51508-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb35414-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb51685-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb35325-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb51804-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb2ed4d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb51996-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb2e926-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb51ae0-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb3505e-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb51c89-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb34f6b-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb51ddb-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb34a7c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb51f30-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb3497c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb52083-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb35617-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb521cc-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb35512-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb52317-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb30106-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb52473-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb2ffbc-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb525e2-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb35c33-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb5274b-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb35b21-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb528bb-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb34e3e-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb52a0c-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb34d48-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb52b63-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb35a28-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb52cbb-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb35933-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb5e9b1-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb36851-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb5ebe1-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb3675d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb5eda2-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb30541-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb5ef6a-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb3045f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb618b2-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb3523a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb61a7c-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb3514f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb61bf7-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb34c55-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb61d80-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb34b6c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb61ee8-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb30341-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb6202d-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb30228-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb62166-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb36283-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb622ac-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb36194-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb62411-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb345ea-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb6255d-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb3062e-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb626a8-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb3485b-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb6280a-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','8eb3474d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.483589'),('8eb6ae49-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8eb35e42-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.494312'),('8eb6b2db-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','8eb36056-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.494312'),('8eb7213d-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8eb36564-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.497210'),('8eb7264c-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8eb3675d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.497210'),('8eb72829-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8eb35d28-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.497210'),('8eb729b4-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8eb36465-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.497210'),('8eb72b8c-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','8eb3636a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.497210'),('8eb79d6f-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb3571f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7a1c7-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb35325-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7a39d-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb2e926-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7a590-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb34f6b-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7a72b-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb3497c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7a8cc-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb35512-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7aa44-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb2ffbc-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7aba2-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb36564-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7ad34-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb35b21-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7aeb7-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb34d48-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7b03d-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb35933-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7b1a3-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb3675d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7b313-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb35d28-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7b482-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb3636a-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7b5f6-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb3045f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7b755-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb3514f-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7b8b1-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb34b6c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7ba19-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb30228-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7bb6c-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb36194-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7bccb-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb3062e-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7be15-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb3474d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('8eb7bf5c-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8eb35f5c-9541-11f1-9595-002b67818c25','2026-08-11 12:00:22.500319'),('91d39e4a-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','91d32695-9541-11f1-9595-002b67818c25','2026-08-11 12:00:27.716698'),('91d3a23b-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','91d32695-9541-11f1-9595-002b67818c25','2026-08-11 12:00:27.716698'),('91d3a447-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','91d321c5-9541-11f1-9595-002b67818c25','2026-08-11 12:00:27.716698'),('91d3a5a8-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','91d321c5-9541-11f1-9595-002b67818c25','2026-08-11 12:00:27.716698'),('91d417b4-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','91d321c5-9541-11f1-9595-002b67818c25','2026-08-11 12:00:27.720237'),('91d41c7d-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','91d321c5-9541-11f1-9595-002b67818c25','2026-08-11 12:00:27.720237'),('91e3c9af-9541-11f1-9595-002b67818c25','8ad0aa19-9541-11f1-9595-002b67818c25','91e3129d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:27.822574'),('91e3ce55-9541-11f1-9595-002b67818c25','8ad0a5f9-9541-11f1-9595-002b67818c25','91e3129d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:27.822574'),('91e3d029-9541-11f1-9595-002b67818c25','8ad0aee4-9541-11f1-9595-002b67818c25','91e3129d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:27.822574'),('91e3d1d0-9541-11f1-9595-002b67818c25','8ad0ad71-9541-11f1-9595-002b67818c25','91e3129d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:27.822574'),('937b5c5e-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8c6ec336-9541-11f1-9595-002b67818c25','2026-08-11 12:00:30.493889'),('937b5fda-9541-11f1-9595-002b67818c25','8ad0b03f-9541-11f1-9595-002b67818c25','8c6ebe7d-9541-11f1-9595-002b67818c25','2026-08-11 12:00:30.493889');
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `is_system_role` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES ('8ad0a5f9-9541-11f1-9595-002b67818c25','super_admin','Super Admin','Highest system administrator',1,'2026-08-11 12:00:15.952390','2026-08-11 12:00:15.952390'),('8ad0aa19-9541-11f1-9595-002b67818c25','admin','Admin / Operasional','Operational admin for master data and jobs',1,'2026-08-11 12:00:15.952390','2026-08-11 12:00:15.952390'),('8ad0ad71-9541-11f1-9595-002b67818c25','surveyor','Surveyor','Survey field user',1,'2026-08-11 12:00:15.952390','2026-08-11 12:00:15.952390'),('8ad0aee4-9541-11f1-9595-002b67818c25','supervisor','Supervisor / Approver','Survey reviewer and approver',1,'2026-08-11 12:00:15.952390','2026-08-11 12:00:15.952390'),('8ad0af90-9541-11f1-9595-002b67818c25','finance','Finance','Finance and billing user',1,'2026-08-11 12:00:15.952390','2026-08-11 12:00:15.952390'),('8ad0b03f-9541-11f1-9595-002b67818c25','management','Management','Read-only dashboard and recap user',1,'2026-08-11 12:00:15.952390','2026-08-11 12:00:15.952390');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `structural_components`
--

DROP TABLE IF EXISTS `structural_components`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `structural_components` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(50) NOT NULL,
  `component_name` varchar(180) NOT NULL,
  `inspection_area_id` char(36) DEFAULT NULL,
  `is_structural_critical` tinyint(1) NOT NULL DEFAULT '0',
  `description` text,
  `display_order` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_structural_components_area` (`inspection_area_id`),
  KEY `idx_structural_components_status` (`status`),
  KEY `idx_structural_components_display_order` (`display_order`),
  CONSTRAINT `fk_structural_components_area` FOREIGN KEY (`inspection_area_id`) REFERENCES `inspection_areas` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `structural_components`
--

LOCK TABLES `structural_components` WRITE;
/*!40000 ALTER TABLE `structural_components` DISABLE KEYS */;
INSERT INTO `structural_components` VALUES ('8ea96e12-9541-11f1-9595-002b67818c25','top_side_rail','Top Side Rail','8ea842b7-9541-11f1-9595-002b67818c25',1,NULL,10,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea972d9-9541-11f1-9595-002b67818c25','bottom_side_rail','Bottom Side Rail','8ea84468-9541-11f1-9595-002b67818c25',1,NULL,20,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea97615-9541-11f1-9595-002b67818c25','header','Header','8ea840d1-9541-11f1-9595-002b67818c25',1,NULL,30,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea9782a-9541-11f1-9595-002b67818c25','sill','Sill','8ea841b4-9541-11f1-9595-002b67818c25',1,NULL,40,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea97a1f-9541-11f1-9595-002b67818c25','corner_post','Corner Post','8ea8453f-9541-11f1-9595-002b67818c25',1,NULL,50,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea97d48-9541-11f1-9595-002b67818c25','corner_fitting','Corner Fitting','8ea8453f-9541-11f1-9595-002b67818c25',1,NULL,60,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea98056-9541-11f1-9595-002b67818c25','intermediate_fitting','Intermediate Fitting','8ea8453f-9541-11f1-9595-002b67818c25',1,NULL,70,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea98446-9541-11f1-9595-002b67818c25','cross_member','Cross Member','8ea84468-9541-11f1-9595-002b67818c25',1,NULL,80,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea987e0-9541-11f1-9595-002b67818c25','understructure','Understructure','8ea84468-9541-11f1-9595-002b67818c25',1,NULL,90,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea99259-9541-11f1-9595-002b67818c25','floor','Floor','8ea84393-9541-11f1-9595-002b67818c25',0,NULL,100,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea9961a-9541-11f1-9595-002b67818c25','roof','Roof','8ea842b7-9541-11f1-9595-002b67818c25',0,NULL,110,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea99991-9541-11f1-9595-002b67818c25','side_wall','Side Wall','8ea83b84-9541-11f1-9595-002b67818c25',0,NULL,120,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea99d48-9541-11f1-9595-002b67818c25','end_wall','End Wall','8ea840d1-9541-11f1-9595-002b67818c25',0,NULL,130,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea9a104-9541-11f1-9595-002b67818c25','door_panel','Door Panel','8ea841b4-9541-11f1-9595-002b67818c25',0,NULL,140,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea9a46e-9541-11f1-9595-002b67818c25','door_locking_rod','Door Locking Rod','8ea841b4-9541-11f1-9595-002b67818c25',1,NULL,150,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715'),('8ea9a835-9541-11f1-9595-002b67818c25','csc_safety_approval_plate','CSC Safety Approval Plate','8ea84610-9541-11f1-9595-002b67818c25',1,NULL,160,'active','2026-08-11 12:00:22.403715','2026-08-11 12:00:22.403715');
/*!40000 ALTER TABLE `structural_components` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `structural_damage_criteria`
--

DROP TABLE IF EXISTS `structural_damage_criteria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `structural_damage_criteria` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(80) NOT NULL,
  `criteria_name` varchar(180) NOT NULL,
  `description` text,
  `component_id` char(36) DEFAULT NULL,
  `severity_default` varchar(30) NOT NULL DEFAULT 'minor',
  `affects_fitness_default` tinyint(1) NOT NULL DEFAULT '0',
  `repair_required_default` tinyint(1) NOT NULL DEFAULT '0',
  `inspection_note` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_structural_damage_criteria_component` (`component_id`),
  KEY `idx_structural_damage_criteria_severity` (`severity_default`),
  KEY `idx_structural_damage_criteria_status` (`status`),
  CONSTRAINT `fk_structural_damage_criteria_component` FOREIGN KEY (`component_id`) REFERENCES `structural_components` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `structural_damage_criteria`
--

LOCK TABLES `structural_damage_criteria` WRITE;
/*!40000 ALTER TABLE `structural_damage_criteria` DISABLE KEYS */;
INSERT INTO `structural_damage_criteria` VALUES ('8eae4d9e-9541-11f1-9595-002b67818c25','dent','Dent','Penyok pada komponen peti kemas.',NULL,'minor',0,0,NULL,'active','2026-08-11 12:00:22.436399','2026-08-11 12:00:22.436399'),('8eae512d-9541-11f1-9595-002b67818c25','crack','Crack','Retak pada komponen peti kemas.',NULL,'major',1,1,NULL,'active','2026-08-11 12:00:22.436399','2026-08-11 12:00:22.436399'),('8eae53d9-9541-11f1-9595-002b67818c25','hole','Hole','Lubang pada komponen peti kemas.',NULL,'major',1,1,NULL,'active','2026-08-11 12:00:22.436399','2026-08-11 12:00:22.436399'),('8eae5553-9541-11f1-9595-002b67818c25','broken','Broken','Komponen patah atau rusak berat.',NULL,'critical',1,1,NULL,'active','2026-08-11 12:00:22.436399','2026-08-11 12:00:22.436399'),('8eae5666-9541-11f1-9595-002b67818c25','bent','Bent','Komponen bengkok atau berubah bentuk.',NULL,'major',1,1,NULL,'active','2026-08-11 12:00:22.436399','2026-08-11 12:00:22.436399'),('8eae5782-9541-11f1-9595-002b67818c25','missing','Missing','Komponen hilang.',NULL,'critical',1,1,NULL,'active','2026-08-11 12:00:22.436399','2026-08-11 12:00:22.436399'),('8eae5888-9541-11f1-9595-002b67818c25','corrosion','Corrosion','Korosi pada komponen.',NULL,'minor',0,0,NULL,'active','2026-08-11 12:00:22.436399','2026-08-11 12:00:22.436399'),('8eae598b-9541-11f1-9595-002b67818c25','severe_corrosion','Severe Corrosion','Korosi berat pada komponen.',NULL,'critical',1,1,NULL,'active','2026-08-11 12:00:22.436399','2026-08-11 12:00:22.436399'),('8eae5c56-9541-11f1-9595-002b67818c25','loose_locking_rod','Loose Locking Rod','Locking rod longgar.','8ea9a46e-9541-11f1-9595-002b67818c25','major',1,1,NULL,'active','2026-08-11 12:00:22.436399','2026-08-11 12:00:22.436399'),('8eae5ed0-9541-11f1-9595-002b67818c25','csc_plate_missing','CSC Plate Missing','Plate persetujuan keselamatan tidak ada.','8ea9a835-9541-11f1-9595-002b67818c25','critical',1,1,NULL,'active','2026-08-11 12:00:22.436399','2026-08-11 12:00:22.436399'),('8eae60ee-9541-11f1-9595-002b67818c25','csc_plate_unreadable','CSC Plate Unreadable','Plate persetujuan keselamatan tidak terbaca.','8ea9a835-9541-11f1-9595-002b67818c25','major',1,1,NULL,'active','2026-08-11 12:00:22.436399','2026-08-11 12:00:22.436399'),('8eae627b-9541-11f1-9595-002b67818c25','deformation_affecting_structure','Deformation Affecting Structure','Deformasi yang memengaruhi struktur.',NULL,'critical',1,1,NULL,'active','2026-08-11 12:00:22.436399','2026-08-11 12:00:22.436399'),('8eae6396-9541-11f1-9595-002b67818c25','watertightness_failure','Watertightness Failure','Kegagalan kedap air.',NULL,'major',1,1,NULL,'active','2026-08-11 12:00:22.436399','2026-08-11 12:00:22.436399');
/*!40000 ALTER TABLE `structural_damage_criteria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_approvals`
--

DROP TABLE IF EXISTS `survey_approvals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_approvals` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `survey_id` char(36) NOT NULL,
  `reviewer_id` char(36) NOT NULL,
  `decision` varchar(30) NOT NULL,
  `review_note` text,
  `final_result` varchar(50) DEFAULT NULL,
  `revision_no` int NOT NULL DEFAULT '0',
  `reviewed_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_survey_approvals_survey` (`survey_id`),
  KEY `idx_survey_approvals_decision` (`decision`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_approvals`
--

LOCK TABLES `survey_approvals` WRITE;
/*!40000 ALTER TABLE `survey_approvals` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_approvals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_checklist_responses`
--

DROP TABLE IF EXISTS `survey_checklist_responses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_checklist_responses` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `survey_id` char(36) NOT NULL,
  `template_item_id` char(36) DEFAULT NULL,
  `item_code` varchar(80) NOT NULL,
  `item_label` varchar(200) NOT NULL,
  `response_value` varchar(50) DEFAULT NULL,
  `response_numeric` decimal(14,4) DEFAULT NULL,
  `response_text` text,
  `response_type` varchar(50) NOT NULL DEFAULT 'ok_not_ok',
  `unit` varchar(50) DEFAULT NULL,
  `standard_reference` varchar(200) DEFAULT NULL,
  `is_required` tinyint(1) NOT NULL DEFAULT '1',
  `is_critical` tinyint(1) NOT NULL DEFAULT '0',
  `requires_attachment` tinyint(1) NOT NULL DEFAULT '0',
  `attachment_file_id` char(36) DEFAULT NULL,
  `display_order` int NOT NULL DEFAULT '0',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `survey_id` (`survey_id`,`item_code`),
  KEY `idx_survey_checklist_survey` (`survey_id`),
  KEY `idx_survey_checklist_attachment` (`attachment_file_id`),
  KEY `idx_survey_checklist_template_item` (`template_item_id`),
  CONSTRAINT `fk_survey_checklist_attachment` FOREIGN KEY (`attachment_file_id`) REFERENCES `file_objects` (`id`),
  CONSTRAINT `fk_survey_checklist_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_survey_checklist_template_item` FOREIGN KEY (`template_item_id`) REFERENCES `fitness_checklist_template_items` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_checklist_responses`
--

LOCK TABLES `survey_checklist_responses` WRITE;
/*!40000 ALTER TABLE `survey_checklist_responses` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_checklist_responses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_damage_counters`
--

DROP TABLE IF EXISTS `survey_damage_counters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_damage_counters` (
  `survey_id` char(36) NOT NULL,
  `last_number` int NOT NULL DEFAULT '0',
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`survey_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_damage_counters`
--

LOCK TABLES `survey_damage_counters` WRITE;
/*!40000 ALTER TABLE `survey_damage_counters` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_damage_counters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_damages`
--

DROP TABLE IF EXISTS `survey_damages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_damages` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `survey_id` char(36) NOT NULL,
  `checklist_response_id` char(36) DEFAULT NULL,
  `damage_no` varchar(30) NOT NULL,
  `face` varchar(50) NOT NULL,
  `internal_location` varchar(30) NOT NULL,
  `cedex_location_id` char(36) DEFAULT NULL,
  `manual_location_reason` text,
  `component_id` char(36) NOT NULL,
  `damage_id` char(36) NOT NULL,
  `repair_id` char(36) DEFAULT NULL,
  `material_id` char(36) DEFAULT NULL,
  `responsibility_id` char(36) DEFAULT NULL,
  `decision_rule_id` char(36) DEFAULT NULL,
  `inspection_reference_id` char(36) DEFAULT NULL,
  `recommended_action_id` char(36) DEFAULT NULL,
  `decision_result` varchar(40) DEFAULT NULL,
  `decision_reason` text,
  `tolerance_snapshot` json DEFAULT NULL,
  `finding_description` text,
  `dimension_profile` varchar(30) DEFAULT NULL,
  `location_selection_snapshot` json DEFAULT NULL,
  `severity` varchar(30) NOT NULL DEFAULT 'minor',
  `quantity` int DEFAULT NULL,
  `quantity_unit` varchar(20) DEFAULT NULL,
  `length_value` decimal(10,2) DEFAULT NULL,
  `width_value` decimal(10,2) DEFAULT NULL,
  `depth_value` decimal(10,2) DEFAULT NULL,
  `unit` varchar(10) NOT NULL DEFAULT 'cm',
  `is_repair_required` tinyint(1) NOT NULL DEFAULT '0',
  `is_cargo_worthy_impact` tinyint(1) NOT NULL DEFAULT '0',
  `is_photo_only` tinyint(1) NOT NULL DEFAULT '0',
  `remark` text,
  `created_by` char(36) DEFAULT NULL,
  `updated_by` char(36) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_survey_damages_no_active` (`survey_id`,`damage_no`),
  KEY `idx_survey_damages_survey` (`survey_id`),
  KEY `idx_survey_damages_location` (`face`,`internal_location`),
  KEY `idx_survey_damages_severity` (`severity`),
  KEY `idx_survey_damages_component` (`component_id`),
  KEY `idx_survey_damages_damage` (`damage_id`),
  KEY `fk_survey_damages_cedex_location` (`cedex_location_id`),
  KEY `fk_survey_damages_repair` (`repair_id`),
  KEY `fk_survey_damages_material` (`material_id`),
  KEY `fk_survey_damages_responsibility` (`responsibility_id`),
  KEY `idx_survey_damages_decision_rule` (`decision_rule_id`),
  KEY `idx_survey_damages_inspection_reference` (`inspection_reference_id`),
  KEY `idx_survey_damages_recommended_action` (`recommended_action_id`),
  KEY `idx_survey_damages_decision_result` (`decision_result`),
  KEY `idx_survey_damages_checklist_response` (`checklist_response_id`),
  CONSTRAINT `fk_survey_damages_cedex_location` FOREIGN KEY (`cedex_location_id`) REFERENCES `cedex_locations` (`id`),
  CONSTRAINT `fk_survey_damages_checklist_response` FOREIGN KEY (`checklist_response_id`) REFERENCES `survey_checklist_responses` (`id`),
  CONSTRAINT `fk_survey_damages_component` FOREIGN KEY (`component_id`) REFERENCES `cedex_components` (`id`),
  CONSTRAINT `fk_survey_damages_damage` FOREIGN KEY (`damage_id`) REFERENCES `cedex_damages` (`id`),
  CONSTRAINT `fk_survey_damages_decision_rule` FOREIGN KEY (`decision_rule_id`) REFERENCES `cedex_damage_decision_rules` (`id`),
  CONSTRAINT `fk_survey_damages_inspection_reference` FOREIGN KEY (`inspection_reference_id`) REFERENCES `inspection_test_parameters` (`id`),
  CONSTRAINT `fk_survey_damages_material` FOREIGN KEY (`material_id`) REFERENCES `cedex_materials` (`id`),
  CONSTRAINT `fk_survey_damages_recommended_action` FOREIGN KEY (`recommended_action_id`) REFERENCES `cedex_repairs` (`id`),
  CONSTRAINT `fk_survey_damages_repair` FOREIGN KEY (`repair_id`) REFERENCES `cedex_repairs` (`id`),
  CONSTRAINT `fk_survey_damages_responsibility` FOREIGN KEY (`responsibility_id`) REFERENCES `responsibility_codes` (`id`),
  CONSTRAINT `fk_survey_damages_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_damages`
--

LOCK TABLES `survey_damages` WRITE;
/*!40000 ALTER TABLE `survey_damages` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_damages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_general_infos`
--

DROP TABLE IF EXISTS `survey_general_infos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_general_infos` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `survey_id` char(36) NOT NULL,
  `container_no` varchar(20) NOT NULL,
  `container_type_id` char(36) DEFAULT NULL,
  `iso_type_code` varchar(20) DEFAULT NULL,
  `customer_id` char(36) NOT NULL,
  `location_id` char(36) NOT NULL,
  `survey_date_time` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `cargo_status` varchar(30) NOT NULL DEFAULT 'unknown',
  `seal_no` varchar(100) DEFAULT NULL,
  `truck_no` varchar(80) DEFAULT NULL,
  `driver_name` varchar(150) DEFAULT NULL,
  `chassis_no` varchar(100) DEFAULT NULL,
  `csc_plate_status` varchar(30) DEFAULT NULL,
  `door_status` varchar(30) DEFAULT NULL,
  `general_condition` varchar(50) DEFAULT NULL,
  `container_lifecycle` varchar(30) DEFAULT NULL,
  `weather` varchar(100) DEFAULT NULL,
  `gps_latitude` decimal(10,7) DEFAULT NULL,
  `gps_longitude` decimal(10,7) DEFAULT NULL,
  `general_remark` text,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `survey_id` (`survey_id`),
  KEY `fk_survey_general_infos_customer` (`customer_id`),
  KEY `fk_survey_general_infos_location` (`location_id`),
  KEY `fk_survey_general_infos_container_type` (`container_type_id`),
  CONSTRAINT `fk_survey_general_infos_container_type` FOREIGN KEY (`container_type_id`) REFERENCES `container_types` (`id`),
  CONSTRAINT `fk_survey_general_infos_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_survey_general_infos_location` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`),
  CONSTRAINT `fk_survey_general_infos_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_general_infos`
--

LOCK TABLES `survey_general_infos` WRITE;
/*!40000 ALTER TABLE `survey_general_infos` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_general_infos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_photos`
--

DROP TABLE IF EXISTS `survey_photos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_photos` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `survey_id` char(36) NOT NULL,
  `damage_id` char(36) DEFAULT NULL,
  `file_id` char(36) NOT NULL,
  `watermarked_file_id` char(36) DEFAULT NULL,
  `photo_type` varchar(30) NOT NULL DEFAULT 'general',
  `photo_category` varchar(80) DEFAULT NULL,
  `caption` text,
  `taken_at` datetime(6) DEFAULT NULL,
  `gps_latitude` decimal(10,7) DEFAULT NULL,
  `gps_longitude` decimal(10,7) DEFAULT NULL,
  `watermark_text` text,
  `display_order` int NOT NULL DEFAULT '0',
  `uploaded_by` char(36) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_survey_photos_survey` (`survey_id`),
  KEY `idx_survey_photos_damage` (`damage_id`),
  KEY `idx_survey_photos_type` (`photo_type`),
  KEY `idx_survey_photos_watermarked_file` (`watermarked_file_id`),
  KEY `fk_survey_photos_file` (`file_id`),
  KEY `fk_survey_photos_uploaded_by` (`uploaded_by`),
  CONSTRAINT `fk_survey_photos_damage` FOREIGN KEY (`damage_id`) REFERENCES `survey_damages` (`id`),
  CONSTRAINT `fk_survey_photos_file` FOREIGN KEY (`file_id`) REFERENCES `file_objects` (`id`),
  CONSTRAINT `fk_survey_photos_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_survey_photos_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_survey_photos_watermarked_file` FOREIGN KEY (`watermarked_file_id`) REFERENCES `file_objects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_photos`
--

LOCK TABLES `survey_photos` WRITE;
/*!40000 ALTER TABLE `survey_photos` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_photos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_revision_items`
--

DROP TABLE IF EXISTS `survey_revision_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_revision_items` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `approval_id` char(36) NOT NULL,
  `survey_id` char(36) NOT NULL,
  `target_type` varchar(50) NOT NULL,
  `category` varchar(50) NOT NULL DEFAULT 'general',
  `target_id` char(36) DEFAULT NULL,
  `target_snapshot` json DEFAULT NULL,
  `due_at` datetime(6) DEFAULT NULL,
  `note` text NOT NULL,
  `is_resolved` tinyint(1) NOT NULL DEFAULT '0',
  `resolved_by` char(36) DEFAULT NULL,
  `resolved_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_survey_revision_items_survey` (`survey_id`),
  KEY `idx_survey_revision_items_resolved` (`is_resolved`),
  KEY `idx_survey_revision_items_target` (`survey_id`,`target_type`,`target_id`),
  CONSTRAINT `chk_survey_revision_items_target` CHECK ((`target_type` in (_cp850'survey',_cp850'finding',_cp850'checklist',_cp850'photo')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_revision_items`
--

LOCK TABLES `survey_revision_items` WRITE;
/*!40000 ALTER TABLE `survey_revision_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_revision_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_revisions`
--

DROP TABLE IF EXISTS `survey_revisions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_revisions` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `survey_id` char(36) NOT NULL,
  `revision_no` int NOT NULL,
  `revision_reason` text NOT NULL,
  `requested_by` char(36) NOT NULL,
  `requested_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `resubmitted_by` char(36) DEFAULT NULL,
  `resubmitted_at` datetime(6) DEFAULT NULL,
  `reviewer_note` text,
  `status` varchar(30) NOT NULL DEFAULT 'requested',
  `snapshot_before` json NOT NULL,
  `snapshot_after` json DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_survey_revisions_no` (`survey_id`,`revision_no`),
  KEY `idx_survey_revisions_survey` (`survey_id`),
  KEY `idx_survey_revisions_status` (`status`),
  KEY `idx_survey_revisions_requested_at` (`requested_at`),
  KEY `fk_survey_revisions_requested_by` (`requested_by`),
  KEY `fk_survey_revisions_resubmitted_by` (`resubmitted_by`),
  CONSTRAINT `fk_survey_revisions_requested_by` FOREIGN KEY (`requested_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_survey_revisions_resubmitted_by` FOREIGN KEY (`resubmitted_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_survey_revisions_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_revisions`
--

LOCK TABLES `survey_revisions` WRITE;
/*!40000 ALTER TABLE `survey_revisions` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_revisions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_types`
--

DROP TABLE IF EXISTS `survey_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_types` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `customer_id` char(36) DEFAULT NULL,
  `code` varchar(30) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text,
  `requires_eir` tinyint(1) NOT NULL DEFAULT '0',
  `requires_light_test` tinyint(1) NOT NULL DEFAULT '0',
  `requires_cargo_worthy_result` tinyint(1) NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_survey_types_customer_code` (`customer_id`,`code`),
  KEY `idx_survey_types_status` (`status`),
  KEY `idx_survey_types_customer` (`customer_id`),
  KEY `idx_survey_types_customer_status` (`customer_id`,`status`),
  CONSTRAINT `fk_survey_types_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `chk_survey_types_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_types`
--

LOCK TABLES `survey_types` WRITE;
/*!40000 ALTER TABLE `survey_types` DISABLE KEYS */;
INSERT INTO `survey_types` VALUES ('8ad47284-9541-11f1-9595-002b67818c25',NULL,'GI','Gate In Survey','Survey when container enters yard or depot',1,0,0,'active','2026-08-11 12:00:15.977987','2026-08-11 12:00:15.977987'),('8ad479e1-9541-11f1-9595-002b67818c25',NULL,'GO','Gate Out Survey','Survey when container leaves yard or depot',1,0,0,'active','2026-08-11 12:00:15.977987','2026-08-11 12:00:15.977987'),('8ad47c2a-9541-11f1-9595-002b67818c25',NULL,'DS','Damage Survey','Specific survey for container damage',0,0,0,'active','2026-08-11 12:00:15.977987','2026-08-11 12:00:15.977987'),('8ad47d8a-9541-11f1-9595-002b67818c25',NULL,'CW','Cargo Worthy Survey','Cargo worthy condition assessment',0,1,1,'active','2026-08-11 12:00:15.977987','2026-08-11 12:00:15.977987'),('8ad47f17-9541-11f1-9595-002b67818c25',NULL,'CL','Cleanliness Survey','Container cleanliness survey',0,0,0,'active','2026-08-11 12:00:15.977987','2026-08-11 12:00:15.977987'),('8ad480eb-9541-11f1-9595-002b67818c25',NULL,'ONH','On Hire Survey','Start of hire survey',0,0,0,'active','2026-08-11 12:00:15.977987','2026-08-11 12:00:15.977987'),('8ad48230-9541-11f1-9595-002b67818c25',NULL,'OFH','Off Hire Survey','End of hire survey',0,0,0,'active','2026-08-11 12:00:15.977987','2026-08-11 12:00:15.977987'),('8ad483ec-9541-11f1-9595-002b67818c25',NULL,'STUF','Stuffing Survey','Survey during stuffing activity',0,0,0,'active','2026-08-11 12:00:15.977987','2026-08-11 12:00:15.977987'),('8ad48544-9541-11f1-9595-002b67818c25',NULL,'STRP','Stripping Survey','Survey during stripping activity',0,0,0,'active','2026-08-11 12:00:15.977987','2026-08-11 12:00:15.977987'),('8ad48692-9541-11f1-9595-002b67818c25',NULL,'PTI','Pre-Trip Inspection','Reefer pre-trip inspection',0,1,0,'active','2026-08-11 12:00:15.977987','2026-08-11 12:00:15.977987');
/*!40000 ALTER TABLE `survey_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `surveyor_profiles`
--

DROP TABLE IF EXISTS `surveyor_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `surveyor_profiles` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `user_id` char(36) NOT NULL,
  `surveyor_code` varchar(50) NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `area` varchar(150) DEFAULT NULL,
  `certificate_number` varchar(100) DEFAULT NULL,
  `certificate_valid_until` date DEFAULT NULL,
  `competencies` text,
  `assignment_locations` text,
  `signature_file_id` char(36) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `idx_surveyor_profiles_code` (`surveyor_code`),
  KEY `idx_surveyor_profiles_status` (`status`),
  KEY `idx_surveyor_profiles_certificate_valid_until` (`certificate_valid_until`),
  CONSTRAINT `chk_surveyor_profiles_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `surveyor_profiles`
--

LOCK TABLES `surveyor_profiles` WRITE;
/*!40000 ALTER TABLE `surveyor_profiles` DISABLE KEYS */;
/*!40000 ALTER TABLE `surveyor_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `surveys`
--

DROP TABLE IF EXISTS `surveys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `surveys` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `survey_no` varchar(80) NOT NULL,
  `job_order_id` char(36) NOT NULL,
  `job_container_id` char(36) NOT NULL,
  `assignment_id` char(36) DEFAULT NULL,
  `surveyor_id` char(36) NOT NULL,
  `survey_type_id` char(36) NOT NULL,
  `phase` varchar(30) NOT NULL DEFAULT 'initial',
  `survey_round` int NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `checklist_template_id` char(36) DEFAULT NULL,
  `status` varchar(50) NOT NULL DEFAULT 'draft',
  `survey_result` varchar(50) DEFAULT NULL,
  `system_recommendation_result` varchar(50) DEFAULT NULL,
  `started_at` datetime(6) DEFAULT NULL,
  `submitted_at` datetime(6) DEFAULT NULL,
  `review_started_by` char(36) DEFAULT NULL,
  `current_reviewer_id` char(36) DEFAULT NULL,
  `review_started_at` datetime(6) DEFAULT NULL,
  `resubmitted_at` datetime(6) DEFAULT NULL,
  `approved_at` datetime(6) DEFAULT NULL,
  `rejected_at` datetime(6) DEFAULT NULL,
  `current_revision_no` int NOT NULL DEFAULT '0',
  `final_remark` text,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `survey_no` (`survey_no`),
  UNIQUE KEY `idx_surveys_no` (`survey_no`),
  UNIQUE KEY `uq_surveys_active_container_phase_round` (`job_container_id`,`survey_type_id`,`phase`,`survey_round`,`is_active`),
  KEY `idx_surveys_container_type_active` (`job_container_id`,`survey_type_id`),
  KEY `idx_surveys_job` (`job_order_id`),
  KEY `idx_surveys_container` (`job_container_id`),
  KEY `idx_surveys_surveyor` (`surveyor_id`),
  KEY `idx_surveys_status` (`status`),
  KEY `idx_surveys_submitted_at` (`submitted_at`),
  KEY `fk_surveys_assignment` (`assignment_id`),
  KEY `fk_surveys_survey_type` (`survey_type_id`),
  KEY `idx_surveys_checklist_template` (`checklist_template_id`),
  KEY `fk_surveys_review_started_by` (`review_started_by`),
  KEY `idx_surveys_review_started_at` (`review_started_at`),
  KEY `idx_surveys_resubmitted_at` (`resubmitted_at`),
  KEY `idx_surveys_active_status` (`is_active`,`status`),
  KEY `idx_surveys_current_reviewer` (`current_reviewer_id`),
  CONSTRAINT `fk_surveys_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`),
  CONSTRAINT `fk_surveys_checklist_template` FOREIGN KEY (`checklist_template_id`) REFERENCES `fitness_checklist_templates` (`id`),
  CONSTRAINT `fk_surveys_current_reviewer` FOREIGN KEY (`current_reviewer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_surveys_job_container` FOREIGN KEY (`job_container_id`) REFERENCES `job_containers` (`id`),
  CONSTRAINT `fk_surveys_job_order` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`id`),
  CONSTRAINT `fk_surveys_review_started_by` FOREIGN KEY (`review_started_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_surveys_survey_type` FOREIGN KEY (`survey_type_id`) REFERENCES `survey_types` (`id`),
  CONSTRAINT `fk_surveys_surveyor` FOREIGN KEY (`surveyor_id`) REFERENCES `surveyor_profiles` (`id`),
  CONSTRAINT `chk_surveys_phase` CHECK ((`phase` in (_cp850'initial',_cp850'reinspection'))),
  CONSTRAINT `chk_surveys_round` CHECK ((`survey_round` > 0)),
  CONSTRAINT `chk_surveys_status` CHECK ((`status` in (_cp850'draft',_cp850'submitted',_cp850'under_review',_cp850'need_revision',_cp850'resubmitted',_cp850'approved',_cp850'rejected',_cp850'cancelled')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `surveys`
--

LOCK TABLES `surveys` WRITE;
/*!40000 ALTER TABLE `surveys` DISABLE KEYS */;
/*!40000 ALTER TABLE `surveys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `user_id` char(36) NOT NULL,
  `role_id` char(36) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`,`role_id`),
  KEY `idx_user_roles_user` (`user_id`),
  KEY `idx_user_roles_role` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES ('8b0b6507-9541-11f1-9595-002b67818c25','00000000-0000-0000-0000-000000000001','8ad0a5f9-9541-11f1-9595-002b67818c25','2026-08-11 12:00:16.338037');
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `name` varchar(150) NOT NULL,
  `email` varchar(150) NOT NULL,
  `username` varchar(80) DEFAULT NULL,
  `password_hash` text NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `avatar_file_id` char(36) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `last_login_at` datetime(6) DEFAULT NULL,
  `password_changed_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_users_email` (`email`),
  UNIQUE KEY `idx_users_username` (`username`),
  KEY `idx_users_status` (`status`),
  CONSTRAINT `chk_users_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive',_utf8mb4'suspended')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES ('00000000-0000-0000-0000-000000000001','Super Admin Dev','superadmin@gift.local','superadmin','$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',NULL,NULL,'active',NULL,'2026-08-11 12:00:16.000000','2026-08-11 12:00:16.306711','2026-08-11 12:00:16.306711',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'kontainer_final_ci2_20260811_uat'
--

--
-- Dumping routines for database 'kontainer_final_ci2_20260811_uat'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
