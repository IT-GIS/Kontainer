-- MySQL dump 10.13  Distrib 8.4.3, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: kontainer_db
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
-- Table structure for table `cedex_components`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cedex_components` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(30) NOT NULL,
  `component_name` varchar(150) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_cedex_components_status` (`status`),
  CONSTRAINT `chk_cedex_components_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cedex_components`
--

LOCK TABLES `cedex_components` WRITE;
/*!40000 ALTER TABLE `cedex_components` DISABLE KEYS */;
INSERT INTO `cedex_components` (`id`, `code`, `component_name`, `description`, `status`, `created_at`, `updated_at`) VALUES ('3f2c9272-737f-11f1-ac50-002b67818c25','SP','Side Panel','Side panel','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c98e3-737f-11f1-ac50-002b67818c25','RP','Roof Panel','Roof panel','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c9ab8-737f-11f1-ac50-002b67818c25','FP','Front Panel','Front panel','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c9bb5-737f-11f1-ac50-002b67818c25','DP','Door Panel','Door panel','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c9ca0-737f-11f1-ac50-002b67818c25','DG','Door Gasket','Door gasket','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c9dd7-737f-11f1-ac50-002b67818c25','LB','Locking Bar','Locking bar','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c9ecb-737f-11f1-ac50-002b67818c25','CK','Cam Keeper','Cam keeper','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c9fbe-737f-11f1-ac50-002b67818c25','FB','Floor Board','Floor board','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca0b2-737f-11f1-ac50-002b67818c25','CM','Cross Member','Cross member','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca194-737f-11f1-ac50-002b67818c25','CP','Corner Post','Corner post','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca2ab-737f-11f1-ac50-002b67818c25','CC','Corner Casting','Corner casting','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca393-737f-11f1-ac50-002b67818c25','BSR','Bottom Side Rail','Bottom side rail','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca482-737f-11f1-ac50-002b67818c25','TSR','Top Side Rail','Top side rail','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca5b8-737f-11f1-ac50-002b67818c25','FKP','Forklift Pocket','Forklift pocket','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca695-737f-11f1-ac50-002b67818c25','VN','Ventilator','Ventilator','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca78d-737f-11f1-ac50-002b67818c25','CSC','CSC Plate','CSC plate','active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693');
/*!40000 ALTER TABLE `cedex_components` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cedex_damages`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cedex_damages` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(30) NOT NULL,
  `damage_name` varchar(150) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_cedex_damages_status` (`status`),
  CONSTRAINT `chk_cedex_damages_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cedex_damages`
--

LOCK TABLES `cedex_damages` WRITE;
/*!40000 ALTER TABLE `cedex_damages` DISABLE KEYS */;
INSERT INTO `cedex_damages` (`id`, `code`, `damage_name`, `description`, `status`, `created_at`, `updated_at`) VALUES ('3f2d67ba-737f-11f1-ac50-002b67818c25','DT','Dent','Dent','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d6c10-737f-11f1-ac50-002b67818c25','HL','Hole','Hole','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d6d75-737f-11f1-ac50-002b67818c25','CR','Crack','Crack','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d6e64-737f-11f1-ac50-002b67818c25','BN','Bent','Bent','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d6f5c-737f-11f1-ac50-002b67818c25','BR','Broken','Broken','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7095-737f-11f1-ac50-002b67818c25','MS','Missing','Missing','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7190-737f-11f1-ac50-002b67818c25','RS','Rust','Rust','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d72aa-737f-11f1-ac50-002b67818c25','CO','Corrosion','Corrosion','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7394-737f-11f1-ac50-002b67818c25','TO','Torn','Torn','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7472-737f-11f1-ac50-002b67818c25','LS','Loose','Loose','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d75c7-737f-11f1-ac50-002b67818c25','DY','Dirty','Dirty','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7711-737f-11f1-ac50-002b67818c25','WT','Wet','Wet','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d786f-737f-11f1-ac50-002b67818c25','OD','Odor','Odor','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d79ac-737f-11f1-ac50-002b67818c25','OS','Oil Stain','Oil stain','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7af6-737f-11f1-ac50-002b67818c25','BM','Burn Mark','Burn mark','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7c5a-737f-11f1-ac50-002b67818c25','DL','Delamination','Delamination','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7dad-737f-11f1-ac50-002b67818c25','LK','Leakage','Leakage','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7f06-737f-11f1-ac50-002b67818c25','IR','Improper Repair','Improper repair','active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187');
/*!40000 ALTER TABLE `cedex_damages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cedex_locations`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cedex_locations` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(30) NOT NULL,
  `face` varchar(50) NOT NULL,
  `grid_code` varchar(30) NOT NULL,
  `cedex_mapping_code` varchar(50) DEFAULT NULL,
  `container_size` varchar(20) DEFAULT NULL,
  `description` text,
  `display_order` int NOT NULL DEFAULT '0',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_cedex_locations_unique_scope` (`code`,`face`,`container_size`),
  KEY `idx_cedex_locations_face` (`face`),
  KEY `idx_cedex_locations_status` (`status`),
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
INSERT INTO `cedex_locations` (`id`, `code`, `face`, `grid_code`, `cedex_mapping_code`, `container_size`, `description`, `display_order`, `status`, `created_at`, `updated_at`) VALUES ('3f2bf1dd-737f-11f1-ac50-002b67818c25','L1','left','L1',NULL,'all','Left side section 1',1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bf6b4-737f-11f1-ac50-002b67818c25','L2','left','L2',NULL,'all','Left side section 2',2,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bf871-737f-11f1-ac50-002b67818c25','L3','left','L3',NULL,'all','Left side section 3',3,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bfa0f-737f-11f1-ac50-002b67818c25','R1','right','R1',NULL,'all','Right side section 1',1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bfb50-737f-11f1-ac50-002b67818c25','R2','right','R2',NULL,'all','Right side section 2',2,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bfca8-737f-11f1-ac50-002b67818c25','D1','door','D1',NULL,'all','Door end section 1',1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bfdde-737f-11f1-ac50-002b67818c25','F1','front','F1',NULL,'all','Front end section 1',1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bfef8-737f-11f1-ac50-002b67818c25','T1','roof','T1',NULL,'all','Roof section 1',1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2c003a-737f-11f1-ac50-002b67818c25','FL1','floor','FL1',NULL,'all','Floor section 1',1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2c0168-737f-11f1-ac50-002b67818c25','U1','understructure','U1',NULL,'all','Understructure section 1',1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557');
/*!40000 ALTER TABLE `cedex_locations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cedex_materials`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cedex_materials` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(30) NOT NULL,
  `material_name` varchar(150) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_cedex_materials_status` (`status`),
  CONSTRAINT `chk_cedex_materials_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cedex_materials`
--

LOCK TABLES `cedex_materials` WRITE;
/*!40000 ALTER TABLE `cedex_materials` DISABLE KEYS */;
INSERT INTO `cedex_materials` (`id`, `code`, `material_name`, `description`, `status`, `created_at`, `updated_at`) VALUES ('3f2f3f44-737f-11f1-ac50-002b67818c25','STL','Steel','Steel','active','2026-06-29 05:56:18.329122','2026-06-29 05:56:18.329122'),('3f2f4501-737f-11f1-ac50-002b67818c25','AL','Aluminium','Aluminium','active','2026-06-29 05:56:18.329122','2026-06-29 05:56:18.329122'),('3f2f4761-737f-11f1-ac50-002b67818c25','PLY','Plywood','Plywood','active','2026-06-29 05:56:18.329122','2026-06-29 05:56:18.329122'),('3f2f4928-737f-11f1-ac50-002b67818c25','RUB','Rubber','Rubber','active','2026-06-29 05:56:18.329122','2026-06-29 05:56:18.329122'),('3f2f4af7-737f-11f1-ac50-002b67818c25','PLS','Plastic','Plastic','active','2026-06-29 05:56:18.329122','2026-06-29 05:56:18.329122');
/*!40000 ALTER TABLE `cedex_materials` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cedex_repairs`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cedex_repairs` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(30) NOT NULL,
  `repair_name` varchar(150) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_cedex_repairs_status` (`status`),
  CONSTRAINT `chk_cedex_repairs_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cedex_repairs`
--

LOCK TABLES `cedex_repairs` WRITE;
/*!40000 ALTER TABLE `cedex_repairs` DISABLE KEYS */;
INSERT INTO `cedex_repairs` (`id`, `code`, `repair_name`, `description`, `status`, `created_at`, `updated_at`) VALUES ('3f2e0abd-737f-11f1-ac50-002b67818c25','NR','No Repair','No repair','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e10bc-737f-11f1-ac50-002b67818c25','ST','Straighten','Straighten','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1254-737f-11f1-ac50-002b67818c25','WD','Weld','Weld','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e135a-737f-11f1-ac50-002b67818c25','PT','Patch','Patch','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e144d-737f-11f1-ac50-002b67818c25','RP','Replace','Replace','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1542-737f-11f1-ac50-002b67818c25','RF','Refit','Refit','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1624-737f-11f1-ac50-002b67818c25','CL','Clean','Clean','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1705-737f-11f1-ac50-002b67818c25','DR','Drying','Drying','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e17ee-737f-11f1-ac50-002b67818c25','GR','Grinding','Grinding','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e18e2-737f-11f1-ac50-002b67818c25','PN','Painting','Painting','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e19c4-737f-11f1-ac50-002b67818c25','SL','Sealant','Sealant','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1aea-737f-11f1-ac50-002b67818c25','TG','Tighten','Tighten','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1bd7-737f-11f1-ac50-002b67818c25','RM','Remove','Remove','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1cc2-737f-11f1-ac50-002b67818c25','RI','Reinstall','Reinstall','active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362');
/*!40000 ALTER TABLE `cedex_repairs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_profiles`
--

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
INSERT INTO `company_profiles` (`id`, `company_name`, `brand_name`, `address`, `phone`, `email`, `website`, `tax_no`, `logo_file_id`, `default_signature_file_id`, `is_active`, `created_at`, `updated_at`) VALUES ('3f2932cb-737f-11f1-ac50-002b67818c25','PT Global Inspeksi Sertifikasi Group','GIFT',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-06-29 05:56:18.289455','2026-06-29 05:56:18.289455');
/*!40000 ALTER TABLE `company_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `container_import_batches`
--

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
  CONSTRAINT `chk_container_import_batches_status` CHECK ((`status` in (_utf8mb4'processed',_utf8mb4'failed',_utf8mb4'partial')))
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

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `container_types` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(30) NOT NULL,
  `iso_code` varchar(20) DEFAULT NULL,
  `size` varchar(50) NOT NULL,
  `type_name` varchar(100) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_container_types_status` (`status`),
  CONSTRAINT `chk_container_types_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `container_types`
--

LOCK TABLES `container_types` WRITE;
/*!40000 ALTER TABLE `container_types` DISABLE KEYS */;
INSERT INTO `container_types` (`id`, `code`, `iso_code`, `size`, `type_name`, `description`, `status`, `created_at`, `updated_at`) VALUES ('3f2a7725-737f-11f1-ac50-002b67818c25','20GP','22G1','20 Feet','General Purpose','Dry container 20 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a7dc9-737f-11f1-ac50-002b67818c25','40GP','42G1','40 Feet','General Purpose','Dry container 40 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a8082-737f-11f1-ac50-002b67818c25','40HC','45G1','40 Feet','High Cube','High cube dry container 40 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a822a-737f-11f1-ac50-002b67818c25','20RF','22R1','20 Feet','Reefer','Refrigerated container 20 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a83b5-737f-11f1-ac50-002b67818c25','40RF','45R1','40 Feet','Reefer','Refrigerated container 40 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a854b-737f-11f1-ac50-002b67818c25','20OT',NULL,'20 Feet','Open Top','Open top container 20 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a86c7-737f-11f1-ac50-002b67818c25','40OT',NULL,'40 Feet','Open Top','Open top container 40 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a8857-737f-11f1-ac50-002b67818c25','20FR',NULL,'20 Feet','Flat Rack','Flat rack container 20 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a89dc-737f-11f1-ac50-002b67818c25','40FR',NULL,'40 Feet','Flat Rack','Flat rack container 40 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a8b64-737f-11f1-ac50-002b67818c25','TANK',NULL,'Tank','Tank Container','Tank container','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704');
/*!40000 ALTER TABLE `container_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customers`
--

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
/*!40000 ALTER TABLE `customers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `evidence_photo_categories`
--

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
INSERT INTO `evidence_photo_categories` (`id`, `code`, `name`, `description`, `is_required_default`, `applies_to`, `display_order`, `status`, `created_at`, `updated_at`) VALUES ('48278e9f-79e5-11f1-a1f6-002b67818c25','general_container','General Container','Foto umum peti kemas.',1,'inspection',10,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('48279fb9-79e5-11f1-a1f6-002b67818c25','container_number','Container Number','Foto nomor peti kemas.',1,'inspection',20,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('4827a123-79e5-11f1-a1f6-002b67818c25','csc_plate','CSC Plate','Foto plate persetujuan keselamatan.',1,'inspection',30,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('4827a1f4-79e5-11f1-a1f6-002b67818c25','structural_component','Structural Component','Foto komponen struktur.',0,'inspection',40,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('4827a2e3-79e5-11f1-a1f6-002b67818c25','damage_finding','Damage Finding','Foto temuan kerusakan.',0,'finding',50,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('4827a3af-79e5-11f1-a1f6-002b67818c25','test_result','Test Result','Foto atau lampiran hasil pengujian.',0,'test',60,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('4827a476-79e5-11f1-a1f6-002b67818c25','repair_evidence','Repair Evidence','Evidence perbaikan.',0,'repair',70,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('4827a52d-79e5-11f1-a1f6-002b67818c25','reinspection_evidence','Reinspection Evidence','Evidence re-inspection.',0,'reinspection',80,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212');
/*!40000 ALTER TABLE `evidence_photo_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `file_objects`
--

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
INSERT INTO `finding_severities` (`id`, `code`, `name`, `description`, `level_no`, `affects_fitness_default`, `requires_supervisor_review`, `badge_tone`, `status`, `created_at`, `updated_at`) VALUES ('4821a7f4-79e5-11f1-a1f6-002b67818c25','minor','Minor','Temuan ringan.',1,0,0,'neutral','active','2026-07-07 16:21:48.980742','2026-07-07 16:21:48.980742'),('4821ae79-79e5-11f1-a1f6-002b67818c25','major','Major','Temuan signifikan yang perlu review.',2,1,1,'warning','active','2026-07-07 16:21:48.980742','2026-07-07 16:21:48.980742'),('4821b088-79e5-11f1-a1f6-002b67818c25','critical','Critical','Temuan kritikal yang memengaruhi kelaikan.',3,1,1,'danger','active','2026-07-07 16:21:48.980742','2026-07-07 16:21:48.980742');
/*!40000 ALTER TABLE `finding_severities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fitness_application_events`
--

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
INSERT INTO `fitness_approval_categories` (`id`, `code`, `name`, `description`, `container_lifecycle`, `is_mvp_active`, `display_order`, `status`, `created_at`, `updated_at`) VALUES ('4810596e-79e5-11f1-a1f6-002b67818c25','new_individual','Peti Kemas Baru Individual','Persetujuan kelaikan untuk peti kemas baru individual.','new',1,10,'active','2026-07-07 16:21:48.865067','2026-07-07 16:21:48.865067'),('48109af3-79e5-11f1-a1f6-002b67818c25','existing_used','Peti Kemas Lama yang Telah Digunakan','Persetujuan kelaikan untuk peti kemas lama yang telah digunakan.','existing',1,20,'active','2026-07-07 16:21:48.865067','2026-07-07 16:21:48.865067'),('4810a158-79e5-11f1-a1f6-002b67818c25','existing_produced_without_initial_approval','Peti Kemas yang Sudah Diproduksi dan Belum Mendapat Persetujuan Awal','Persetujuan kelaikan untuk peti kemas yang sudah diproduksi dan belum mendapat persetujuan awal.','existing',1,30,'active','2026-07-07 16:21:48.865067','2026-07-07 16:21:48.865067'),('4810a531-79e5-11f1-a1f6-002b67818c25','type_design','Peti Kemas Baru Type Design','Future scope; tidak aktif pada MVP.','new',0,90,'inactive','2026-07-07 16:21:48.865067','2026-07-07 16:21:48.865067');
/*!40000 ALTER TABLE `fitness_approval_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fitness_checklist_template_items`
--

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

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fitness_checklist_templates` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `template_code` varchar(80) NOT NULL,
  `template_name` varchar(180) NOT NULL,
  `approval_category_id` char(36) DEFAULT NULL,
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
  UNIQUE KEY `template_code` (`template_code`),
  KEY `idx_fitness_checklist_templates_category` (`approval_category_id`),
  KEY `idx_fitness_checklist_templates_container_type` (`container_type_id`),
  KEY `idx_fitness_checklist_templates_status` (`status`),
  KEY `idx_fitness_checklist_templates_deleted_at` (`deleted_at`),
  KEY `fk_fitness_checklist_templates_created_by` (`created_by`),
  KEY `fk_fitness_checklist_templates_approved_by` (`approved_by`),
  CONSTRAINT `fk_fitness_checklist_templates_approved_by` FOREIGN KEY (`approved_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_fitness_checklist_templates_category` FOREIGN KEY (`approval_category_id`) REFERENCES `fitness_approval_categories` (`id`),
  CONSTRAINT `fk_fitness_checklist_templates_container_type` FOREIGN KEY (`container_type_id`) REFERENCES `container_types` (`id`),
  CONSTRAINT `fk_fitness_checklist_templates_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`)
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
INSERT INTO `inspection_areas` (`id`, `code`, `area_name`, `description`, `display_order`, `status`, `created_at`, `updated_at`) VALUES ('48167e70-79e5-11f1-a1f6-002b67818c25','left_side','Left Side','Sisi kiri peti kemas.',10,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('481683e7-79e5-11f1-a1f6-002b67818c25','right_side','Right Side','Sisi kanan peti kemas.',20,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('481685b8-79e5-11f1-a1f6-002b67818c25','front_end','Front End','Bagian depan peti kemas.',30,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('48168684-79e5-11f1-a1f6-002b67818c25','door_end','Door End','Bagian pintu peti kemas.',40,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('4816874d-79e5-11f1-a1f6-002b67818c25','roof','Roof','Atap peti kemas.',50,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('48168812-79e5-11f1-a1f6-002b67818c25','floor','Floor','Lantai peti kemas.',60,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('481688cc-79e5-11f1-a1f6-002b67818c25','understructure','Understructure','Struktur bawah peti kemas.',70,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('4816899b-79e5-11f1-a1f6-002b67818c25','corner_area','Corner Area','Area corner post dan corner fitting.',80,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('48168a4f-79e5-11f1-a1f6-002b67818c25','csc_plate_area','CSC Plate Area','Area plate persetujuan keselamatan.',90,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592');
/*!40000 ALTER TABLE `inspection_areas` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inspection_recommendations`
--

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
INSERT INTO `inspection_recommendations` (`id`, `code`, `name`, `description`, `final_fitness_result_mapping`, `workflow_status_mapping`, `restriction_status_mapping`, `requires_supervisor_review`, `status`, `created_at`, `updated_at`) VALUES ('482b299f-79e5-11f1-a1f6-002b67818c25','fit','Layak','Direkomendasikan layak.','fit','under_review','none',1,'active','2026-07-07 16:21:49.043135','2026-07-07 16:21:49.043135'),('482b3372-79e5-11f1-a1f6-002b67818c25','need_repair','Perlu Perbaikan','Perlu perbaikan sebelum keputusan akhir.','pending','need_repair','suspended',1,'active','2026-07-07 16:21:49.043135','2026-07-07 16:21:49.043135'),('482b36bd-79e5-11f1-a1f6-002b67818c25','unfit','Tidak Layak','Direkomendasikan tidak layak.','unfit','under_review','prohibited',1,'active','2026-07-07 16:21:49.043135','2026-07-07 16:21:49.043135'),('482b3846-79e5-11f1-a1f6-002b67818c25','need_reinspection','Perlu Re-Inspection','Perlu pemeriksaan ulang.','pending','ready_for_reinspection','suspended',1,'active','2026-07-07 16:21:49.043135','2026-07-07 16:21:49.043135'),('482b39cb-79e5-11f1-a1f6-002b67818c25','suspend_use','Dilarang Digunakan Sementara','Penggunaan ditangguhkan sementara.','pending','need_repair','suspended',1,'active','2026-07-07 16:21:49.043135','2026-07-07 16:21:49.043135');
/*!40000 ALTER TABLE `inspection_recommendations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `inspection_test_parameters`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inspection_test_parameters` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(80) NOT NULL,
  `parameter_name` varchar(180) NOT NULL,
  `description` text,
  `unit` varchar(50) DEFAULT NULL,
  `standard_reference` varchar(200) DEFAULT NULL,
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
  KEY `idx_inspection_test_parameters_display_order` (`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inspection_test_parameters`
--

LOCK TABLES `inspection_test_parameters` WRITE;
/*!40000 ALTER TABLE `inspection_test_parameters` DISABLE KEYS */;
INSERT INTO `inspection_test_parameters` (`id`, `code`, `parameter_name`, `description`, `unit`, `standard_reference`, `applies_to_new_container`, `applies_to_existing_container`, `requires_numeric_result`, `requires_attachment`, `display_order`, `status`, `created_at`, `updated_at`) VALUES ('4824daef-79e5-11f1-a1f6-002b67818c25','lifting_test','Lifting Test','Pengujian lifting.',NULL,NULL,1,1,0,0,10,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824e229-79e5-11f1-a1f6-002b67818c25','stacking_test','Stacking Test','Pengujian stacking.',NULL,NULL,1,1,0,0,20,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824e594-79e5-11f1-a1f6-002b67818c25','concentrated_load_test','Concentrated Load Test','Pengujian concentrated load.',NULL,NULL,1,1,0,0,30,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824e734-79e5-11f1-a1f6-002b67818c25','transverse_racking_test','Transverse Racking Test','Pengujian transverse racking.',NULL,NULL,1,1,1,0,40,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824e9fd-79e5-11f1-a1f6-002b67818c25','longitudinal_restraint_test','Longitudinal Restraint Test','Pengujian longitudinal restraint.',NULL,NULL,1,1,0,0,50,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824ec3e-79e5-11f1-a1f6-002b67818c25','side_wall_strength','Side Wall Strength','Pemeriksaan kekuatan side wall.',NULL,NULL,1,1,0,0,60,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824ee28-79e5-11f1-a1f6-002b67818c25','end_wall_strength','End Wall Strength','Pemeriksaan kekuatan end wall.',NULL,NULL,1,1,0,0,70,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824ef92-79e5-11f1-a1f6-002b67818c25','one_door_off_operation','One Door Off Operation','Pemeriksaan operasi one door off.',NULL,NULL,1,0,0,0,80,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824f0f9-79e5-11f1-a1f6-002b67818c25','watertightness_test','Watertightness Test','Pengujian kedap air.',NULL,NULL,1,1,0,1,90,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824f25b-79e5-11f1-a1f6-002b67818c25','ndt_if_required','NDT If Required','NDT jika diperlukan.',NULL,NULL,1,1,0,1,100,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635');
/*!40000 ALTER TABLE `inspection_test_parameters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoice_items`
--

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

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_containers` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `job_order_id` char(36) NOT NULL,
  `container_no` varchar(20) NOT NULL,
  `owner_code` varchar(4) DEFAULT NULL,
  `serial_number` varchar(10) DEFAULT NULL,
  `check_digit` varchar(2) DEFAULT NULL,
  `check_digit_status` varchar(30) NOT NULL DEFAULT 'not_checked',
  `check_digit_override_reason` text,
  `container_type_id` char(36) DEFAULT NULL,
  `iso_type_code` varchar(20) DEFAULT NULL,
  `seal_no` varchar(100) DEFAULT NULL,
  `cargo_status` varchar(30) NOT NULL DEFAULT 'unknown',
  `gross_weight` decimal(12,2) DEFAULT NULL,
  `tare_weight` decimal(12,2) DEFAULT NULL,
  `payload` decimal(12,2) DEFAULT NULL,
  `manufacture_date` date DEFAULT NULL,
  `csc_plate_status` varchar(30) DEFAULT NULL,
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
  CONSTRAINT `fk_job_containers_container_type` FOREIGN KEY (`container_type_id`) REFERENCES `container_types` (`id`),
  CONSTRAINT `fk_job_containers_job_order` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`id`),
  CONSTRAINT `chk_job_containers_cargo_status` CHECK ((`cargo_status` in (_utf8mb4'empty',_utf8mb4'laden',_utf8mb4'unknown'))),
  CONSTRAINT `chk_job_containers_check_digit_status` CHECK ((`check_digit_status` in (_utf8mb4'valid',_utf8mb4'invalid',_utf8mb4'not_checked',_utf8mb4'override'))),
  CONSTRAINT `chk_job_containers_status` CHECK ((`status` in (_utf8mb4'not_started',_utf8mb4'assigned',_utf8mb4'in_progress',_utf8mb4'draft',_utf8mb4'submitted',_utf8mb4'need_revision',_utf8mb4'approved',_utf8mb4'rejected',_utf8mb4'reported',_utf8mb4'invoiced',_utf8mb4'closed',_utf8mb4'cancelled')))
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

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_orders` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `job_order_no` varchar(80) NOT NULL,
  `job_date` date NOT NULL,
  `customer_id` char(36) NOT NULL,
  `survey_type_id` char(36) NOT NULL,
  `location_id` char(36) NOT NULL,
  `pic_customer_name` varchar(150) DEFAULT NULL,
  `pic_customer_phone` varchar(50) DEFAULT NULL,
  `pic_customer_email` varchar(150) DEFAULT NULL,
  `reference_no` varchar(100) DEFAULT NULL,
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
  CONSTRAINT `fk_job_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_job_orders_location` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`),
  CONSTRAINT `fk_job_orders_survey_type` FOREIGN KEY (`survey_type_id`) REFERENCES `survey_types` (`id`),
  CONSTRAINT `chk_job_orders_priority` CHECK ((`priority` in (_utf8mb4'normal',_utf8mb4'urgent'))),
  CONSTRAINT `chk_job_orders_status` CHECK ((`status` in (_utf8mb4'draft',_utf8mb4'assigned',_utf8mb4'in_progress',_utf8mb4'all_survey_submitted',_utf8mb4'all_survey_approved',_utf8mb4'report_generated',_utf8mb4'ready_to_invoice',_utf8mb4'invoiced',_utf8mb4'paid',_utf8mb4'closed',_utf8mb4'cancelled')))
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

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `locations` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `location_code` varchar(50) NOT NULL,
  `location_name` varchar(200) NOT NULL,
  `location_type` varchar(50) NOT NULL,
  `address` text,
  `city` varchar(100) DEFAULT NULL,
  `gps_latitude` decimal(10,7) DEFAULT NULL,
  `gps_longitude` decimal(10,7) DEFAULT NULL,
  `pic_name` varchar(150) DEFAULT NULL,
  `pic_phone` varchar(50) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_locations_code` (`location_code`),
  KEY `idx_locations_name` (`location_name`),
  KEY `idx_locations_type` (`location_type`),
  KEY `idx_locations_status` (`status`),
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
INSERT INTO `maintenance_schemes` (`id`, `code`, `name`, `description`, `requires_next_examination_date`, `default_interval_months`, `status`, `created_at`, `updated_at`) VALUES ('48134d5d-79e5-11f1-a1f6-002b67818c25','ACEP','ACEP','Approved continuous examination program.',1,NULL,'active','2026-07-07 16:21:48.886903','2026-07-07 16:21:48.886903'),('4813573d-79e5-11f1-a1f6-002b67818c25','PES','PES','Periodic examination scheme.',1,30,'active','2026-07-07 16:21:48.886903','2026-07-07 16:21:48.886903'),('48135940-79e5-11f1-a1f6-002b67818c25','IICL','IICL','IICL-based maintenance reference.',0,NULL,'active','2026-07-07 16:21:48.886903','2026-07-07 16:21:48.886903'),('481359fe-79e5-11f1-a1f6-002b67818c25','ISO','ISO','ISO-based maintenance reference.',0,NULL,'active','2026-07-07 16:21:48.886903','2026-07-07 16:21:48.886903'),('48135aa9-79e5-11f1-a1f6-002b67818c25','NED','NED','Next examination date reference.',1,NULL,'active','2026-07-07 16:21:48.886903','2026-07-07 16:21:48.886903'),('48135b68-79e5-11f1-a1f6-002b67818c25','OTHER','Other','Other maintenance scheme.',0,NULL,'active','2026-07-07 16:21:48.886903','2026-07-07 16:21:48.886903');
/*!40000 ALTER TABLE `maintenance_schemes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `numbering_sequences`
--

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
INSERT INTO `numbering_sequences` (`id`, `document_type`, `period_key`, `last_number`, `created_at`, `updated_at`) VALUES ('a76c6711-7ab2-11f1-bf35-002b67818c25','fitness_application','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76cd868-7ab2-11f1-bf35-002b67818c25','fitness_container_import','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76cdbff-7ab2-11f1-bf35-002b67818c25','fitness_assignment','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76cdcf8-7ab2-11f1-bf35-002b67818c25','fitness_inspection','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76cddc5-7ab2-11f1-bf35-002b67818c25','repair_followup','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76cdea2-7ab2-11f1-bf35-002b67818c25','fitness_review','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76cdf68-7ab2-11f1-bf35-002b67818c25','fitness_approval','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76ce032-7ab2-11f1-bf35-002b67818c25','approval_document','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76ce0ea-7ab2-11f1-bf35-002b67818c25','release_letter','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('dcb0ae4d-75c3-11f1-9f38-002b67818c25','job_order','2026',0,'2026-07-02 10:12:30.680519','2026-07-02 10:12:30.680519'),('dcb391f6-75c3-11f1-9f38-002b67818c25','assignment','2026',0,'2026-07-02 10:12:30.701510','2026-07-02 10:12:30.701510'),('dcb6ecf3-75c3-11f1-9f38-002b67818c25','survey','2026',0,'2026-07-02 10:12:30.723760','2026-07-02 10:12:30.723760'),('dcba1e60-75c3-11f1-9f38-002b67818c25','report','2026',0,'2026-07-02 10:12:30.744778','2026-07-02 10:12:30.744778'),('dcbd4e99-75c3-11f1-9f38-002b67818c25','invoice','2026',0,'2026-07-02 10:12:30.765568','2026-07-02 10:12:30.765568'),('dcc00562-75c3-11f1-9f38-002b67818c25','payment_receipt','2026',0,'2026-07-02 10:12:30.783332','2026-07-02 10:12:30.783332');
/*!40000 ALTER TABLE `numbering_sequences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `numbering_settings`
--

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
INSERT INTO `numbering_settings` (`id`, `document_type`, `prefix`, `doc_code`, `year_format`, `running_digits`, `reset_period`, `format_preview`, `is_active`, `created_at`, `updated_at`) VALUES ('3f29c8ab-737f-11f1-ac50-002b67818c25','job_order','GIFT','JO','YYYY',6,'yearly','GIFT-JO-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('3f29cdbd-737f-11f1-ac50-002b67818c25','assignment','GIFT','ASG','YYYY',6,'yearly','GIFT-ASG-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('3f29cf0f-737f-11f1-ac50-002b67818c25','survey','GIFT','SVY','YYYY',6,'yearly','GIFT-SVY-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('3f29cff7-737f-11f1-ac50-002b67818c25','report','GIFT','RPT','YYYY',6,'yearly','GIFT-RPT-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('3f29d133-737f-11f1-ac50-002b67818c25','eir','GIFT','EIR','YYYY',6,'yearly','GIFT-EIR-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('3f29d20d-737f-11f1-ac50-002b67818c25','invoice','GIFT','INV','YYYY',6,'yearly','GIFT-INV-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('3f29d304-737f-11f1-ac50-002b67818c25','payment_receipt','GIFT','RCP','YYYY',6,'yearly','GIFT-RCP-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('482dffc8-79e5-11f1-a1f6-002b67818c25','fitness_application','GIFT','FAP','YYYY',6,'yearly','GIFT-FAP-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e08fc-79e5-11f1-a1f6-002b67818c25','fitness_container_import','GIFT','FCI','YYYY',6,'yearly','GIFT-FCI-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e0add-79e5-11f1-a1f6-002b67818c25','fitness_assignment','GIFT','FAS','YYYY',6,'yearly','GIFT-FAS-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e0bc9-79e5-11f1-a1f6-002b67818c25','fitness_inspection','GIFT','FIN','YYYY',6,'yearly','GIFT-FIN-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e0c99-79e5-11f1-a1f6-002b67818c25','repair_followup','GIFT','RFL','YYYY',6,'yearly','GIFT-RFL-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e0d67-79e5-11f1-a1f6-002b67818c25','fitness_review','GIFT','FRV','YYYY',6,'yearly','GIFT-FRV-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e0e3b-79e5-11f1-a1f6-002b67818c25','fitness_approval','GIFT','FAPV','YYYY',6,'yearly','GIFT-FAPV-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e0f19-79e5-11f1-a1f6-002b67818c25','approval_document','GIFT','ADOC','YYYY',6,'yearly','GIFT-ADOC-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e1002-79e5-11f1-a1f6-002b67818c25','release_letter','GIFT','REL','YYYY',6,'yearly','GIFT-REL-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483');
/*!40000 ALTER TABLE `numbering_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payments`
--

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
INSERT INTO `permissions` (`id`, `code`, `name`, `module`, `action`, `scope`, `description`) VALUES ('3f277c21-737f-11f1-ac50-002b67818c25','*.*.all',NULL,'*','*','all','Wildcard permission for super admin'),('3f2781d5-737f-11f1-ac50-002b67818c25','users.manage.all',NULL,'users','manage','all','Manage users'),('3f2783be-737f-11f1-ac50-002b67818c25','roles.manage.all',NULL,'roles','manage','all','Manage roles and permissions'),('3f2784b7-737f-11f1-ac50-002b67818c25','company_profiles.manage.all',NULL,'company_profiles','manage','all','Manage company profile'),('3f2785a1-737f-11f1-ac50-002b67818c25','numbering_settings.manage.all',NULL,'numbering_settings','manage','all','Manage numbering settings'),('3f278684-737f-11f1-ac50-002b67818c25','files.manage.all',NULL,'files','manage','all','Manage file metadata'),('3f278768-737f-11f1-ac50-002b67818c25','customers.manage.all',NULL,'customers','manage','all','Manage customers'),('3f278858-737f-11f1-ac50-002b67818c25','locations.manage.all',NULL,'locations','manage','all','Manage locations'),('3f27896c-737f-11f1-ac50-002b67818c25','surveyor_profiles.manage.all',NULL,'surveyor_profiles','manage','all','Manage surveyor profiles'),('3f278a4e-737f-11f1-ac50-002b67818c25','surveyor_profiles.view.own',NULL,'surveyor_profiles','view','own','View own surveyor profile'),('3f278b9f-737f-11f1-ac50-002b67818c25','container_types.manage.all',NULL,'container_types','manage','all','Manage container types'),('3f278c8d-737f-11f1-ac50-002b67818c25','survey_types.manage.all',NULL,'survey_types','manage','all','Manage survey types'),('3f278d74-737f-11f1-ac50-002b67818c25','cedex.manage.all',NULL,'cedex','manage','all','Manage CEDEX master data'),('3f278e50-737f-11f1-ac50-002b67818c25','master_data.view.all',NULL,'master_data','view','all','View master data'),('3f278f3f-737f-11f1-ac50-002b67818c25','dashboard.view.all',NULL,'dashboard','view','all','View dashboards'),('3f426ad5-737f-11f1-ac50-002b67818c25','customers.view.all',NULL,'customers','view','all','View customers'),('3f4270e3-737f-11f1-ac50-002b67818c25','customers.create.all',NULL,'customers','create','all','Create customers'),('3f4272f3-737f-11f1-ac50-002b67818c25','customers.update.all',NULL,'customers','update','all','Update customers'),('3f4274ea-737f-11f1-ac50-002b67818c25','customers.delete.all',NULL,'customers','delete','all','Deactivate customers'),('3f4276b0-737f-11f1-ac50-002b67818c25','locations.view.all',NULL,'locations','view','all','View locations'),('3f42781c-737f-11f1-ac50-002b67818c25','locations.create.all',NULL,'locations','create','all','Create locations'),('3f427971-737f-11f1-ac50-002b67818c25','locations.update.all',NULL,'locations','update','all','Update locations'),('3f427ad4-737f-11f1-ac50-002b67818c25','locations.delete.all',NULL,'locations','delete','all','Deactivate locations'),('3f427c3c-737f-11f1-ac50-002b67818c25','surveyors.view.all',NULL,'surveyors','view','all','View surveyor profiles'),('3f427e26-737f-11f1-ac50-002b67818c25','surveyors.create.all',NULL,'surveyors','create','all','Create surveyor profiles'),('3f428028-737f-11f1-ac50-002b67818c25','surveyors.update.all',NULL,'surveyors','update','all','Update surveyor profiles'),('3f4281cd-737f-11f1-ac50-002b67818c25','surveyors.delete.all',NULL,'surveyors','delete','all','Deactivate surveyor profiles'),('3f428365-737f-11f1-ac50-002b67818c25','container_types.view.all',NULL,'container_types','view','all','View container types'),('3f4284d5-737f-11f1-ac50-002b67818c25','container_types.create.all',NULL,'container_types','create','all','Create container types'),('3f42863f-737f-11f1-ac50-002b67818c25','container_types.update.all',NULL,'container_types','update','all','Update container types'),('3f4287a5-737f-11f1-ac50-002b67818c25','container_types.delete.all',NULL,'container_types','delete','all','Deactivate container types'),('3f42892f-737f-11f1-ac50-002b67818c25','survey_types.view.all',NULL,'survey_types','view','all','View survey types'),('3f428a67-737f-11f1-ac50-002b67818c25','survey_types.create.all',NULL,'survey_types','create','all','Create survey types'),('3f428b52-737f-11f1-ac50-002b67818c25','survey_types.update.all',NULL,'survey_types','update','all','Update survey types'),('3f428c36-737f-11f1-ac50-002b67818c25','survey_types.delete.all',NULL,'survey_types','delete','all','Deactivate survey types'),('3f428d2c-737f-11f1-ac50-002b67818c25','cedex_locations.view.all',NULL,'cedex_locations','view','all','View CEDEX locations'),('3f428fac-737f-11f1-ac50-002b67818c25','cedex_locations.create.all',NULL,'cedex_locations','create','all','Create CEDEX locations'),('3f4290f4-737f-11f1-ac50-002b67818c25','cedex_locations.update.all',NULL,'cedex_locations','update','all','Update CEDEX locations'),('3f429218-737f-11f1-ac50-002b67818c25','cedex_locations.delete.all',NULL,'cedex_locations','delete','all','Deactivate CEDEX locations'),('3f429301-737f-11f1-ac50-002b67818c25','cedex_components.view.all',NULL,'cedex_components','view','all','View CEDEX components'),('3f4293ea-737f-11f1-ac50-002b67818c25','cedex_components.create.all',NULL,'cedex_components','create','all','Create CEDEX components'),('3f4294d1-737f-11f1-ac50-002b67818c25','cedex_components.update.all',NULL,'cedex_components','update','all','Update CEDEX components'),('3f4295e8-737f-11f1-ac50-002b67818c25','cedex_components.delete.all',NULL,'cedex_components','delete','all','Deactivate CEDEX components'),('3f429730-737f-11f1-ac50-002b67818c25','cedex_damages.view.all',NULL,'cedex_damages','view','all','View CEDEX damages'),('3f429832-737f-11f1-ac50-002b67818c25','cedex_damages.create.all',NULL,'cedex_damages','create','all','Create CEDEX damages'),('3f429945-737f-11f1-ac50-002b67818c25','cedex_damages.update.all',NULL,'cedex_damages','update','all','Update CEDEX damages'),('3f429a6c-737f-11f1-ac50-002b67818c25','cedex_damages.delete.all',NULL,'cedex_damages','delete','all','Deactivate CEDEX damages'),('3f429b59-737f-11f1-ac50-002b67818c25','cedex_repairs.view.all',NULL,'cedex_repairs','view','all','View CEDEX repairs'),('3f429c43-737f-11f1-ac50-002b67818c25','cedex_repairs.create.all',NULL,'cedex_repairs','create','all','Create CEDEX repairs'),('3f429d21-737f-11f1-ac50-002b67818c25','cedex_repairs.update.all',NULL,'cedex_repairs','update','all','Update CEDEX repairs'),('3f429e2c-737f-11f1-ac50-002b67818c25','cedex_repairs.delete.all',NULL,'cedex_repairs','delete','all','Deactivate CEDEX repairs'),('3f429f1b-737f-11f1-ac50-002b67818c25','cedex_materials.view.all',NULL,'cedex_materials','view','all','View CEDEX materials'),('3f429ffd-737f-11f1-ac50-002b67818c25','cedex_materials.create.all',NULL,'cedex_materials','create','all','Create CEDEX materials'),('3f42a0f3-737f-11f1-ac50-002b67818c25','cedex_materials.update.all',NULL,'cedex_materials','update','all','Update CEDEX materials'),('3f42a1df-737f-11f1-ac50-002b67818c25','cedex_materials.delete.all',NULL,'cedex_materials','delete','all','Deactivate CEDEX materials'),('3f42a2cb-737f-11f1-ac50-002b67818c25','responsibility_codes.view.all',NULL,'responsibility_codes','view','all','View responsibility codes'),('3f42a435-737f-11f1-ac50-002b67818c25','responsibility_codes.create.all',NULL,'responsibility_codes','create','all','Create responsibility codes'),('3f42a533-737f-11f1-ac50-002b67818c25','responsibility_codes.update.all',NULL,'responsibility_codes','update','all','Update responsibility codes'),('3f42a628-737f-11f1-ac50-002b67818c25','responsibility_codes.delete.all',NULL,'responsibility_codes','delete','all','Deactivate responsibility codes'),('3f42a715-737f-11f1-ac50-002b67818c25','cedex_locations.manage.all',NULL,'cedex_locations','manage','all','Manage CEDEX locations'),('3f42a80d-737f-11f1-ac50-002b67818c25','cedex_components.manage.all',NULL,'cedex_components','manage','all','Manage CEDEX components'),('3f42a903-737f-11f1-ac50-002b67818c25','cedex_damages.manage.all',NULL,'cedex_damages','manage','all','Manage CEDEX damages'),('3f42a9ed-737f-11f1-ac50-002b67818c25','cedex_repairs.manage.all',NULL,'cedex_repairs','manage','all','Manage CEDEX repairs'),('3f42aaef-737f-11f1-ac50-002b67818c25','cedex_materials.manage.all',NULL,'cedex_materials','manage','all','Manage CEDEX materials'),('3f42abe3-737f-11f1-ac50-002b67818c25','responsibility_codes.manage.all',NULL,'responsibility_codes','manage','all','Manage responsibility codes'),('3f42acea-737f-11f1-ac50-002b67818c25','surveyors.manage.all',NULL,'surveyors','manage','all','Manage surveyor profiles'),('3fa60b5a-737f-11f1-ac50-002b67818c25','jobs.view.all',NULL,'jobs','view','all','View jobs'),('3fa60f39-737f-11f1-ac50-002b67818c25','jobs.create.all',NULL,'jobs','create','all','Create jobs'),('3fa610e1-737f-11f1-ac50-002b67818c25','jobs.update.all',NULL,'jobs','update','all','Update jobs'),('3fa611dc-737f-11f1-ac50-002b67818c25','jobs.cancel.all',NULL,'jobs','cancel','all','Cancel jobs'),('3fa612c5-737f-11f1-ac50-002b67818c25','jobs.manage.all',NULL,'jobs','manage','all','Manage jobs'),('3fa613ad-737f-11f1-ac50-002b67818c25','job_containers.view.all',NULL,'job_containers','view','all','View job containers'),('3fa6149e-737f-11f1-ac50-002b67818c25','job_containers.create.all',NULL,'job_containers','create','all','Create job containers'),('3fa61581-737f-11f1-ac50-002b67818c25','job_containers.import.all',NULL,'job_containers','import','all','Import job containers'),('3fa616b5-737f-11f1-ac50-002b67818c25','job_containers.update.all',NULL,'job_containers','update','all','Update job containers'),('3fa617a5-737f-11f1-ac50-002b67818c25','job_containers.delete.all',NULL,'job_containers','delete','all','Delete job containers'),('3fa6188d-737f-11f1-ac50-002b67818c25','job_containers.reassign.all',NULL,'job_containers','reassign','all','Reassign job containers'),('3fa61982-737f-11f1-ac50-002b67818c25','assignments.view.all',NULL,'assignments','view','all','View assignments'),('3fa61a5d-737f-11f1-ac50-002b67818c25','assignments.assign.all',NULL,'assignments','assign','all','Assign surveyors'),('3fa61b60-737f-11f1-ac50-002b67818c25','assignments.reassign.all',NULL,'assignments','reassign','all','Reassign surveyors'),('3fa61c4b-737f-11f1-ac50-002b67818c25','assignments.manage.all',NULL,'assignments','manage','all','Manage assignments'),('40377bc2-737f-11f1-ac50-002b67818c25','surveyor_jobs.view.assigned','View Assigned Surveyor Jobs','surveyor_jobs','view','assigned','Melihat job yang ditugaskan ke surveyor login'),('40378673-737f-11f1-ac50-002b67818c25','surveys.view.assigned','View Assigned Surveys','surveys','view','assigned','Melihat survey milik assignment sendiri'),('40378930-737f-11f1-ac50-002b67818c25','surveys.start.assigned','Start Assigned Survey','surveys','start','assigned','Memulai survey untuk container yang ditugaskan'),('40378b20-737f-11f1-ac50-002b67818c25','surveys.update.assigned','Update Assigned Survey','surveys','update','assigned','Mengubah draft/revisi survey sendiri'),('40378d25-737f-11f1-ac50-002b67818c25','surveys.submit.assigned','Submit Assigned Survey','surveys','submit','assigned','Submit survey sendiri untuk review'),('40378ed5-737f-11f1-ac50-002b67818c25','survey_damages.view.assigned','View Assigned Survey Damages','survey_damages','view','assigned','Melihat damage pada survey sendiri'),('40379102-737f-11f1-ac50-002b67818c25','survey_damages.create.assigned','Create Assigned Survey Damage','survey_damages','create','assigned','Membuat damage pada survey sendiri'),('403792f7-737f-11f1-ac50-002b67818c25','survey_damages.update.assigned','Update Assigned Survey Damage','survey_damages','update','assigned','Mengubah damage pada survey sendiri'),('403794be-737f-11f1-ac50-002b67818c25','survey_damages.delete.assigned','Delete Assigned Survey Damage','survey_damages','delete','assigned','Menghapus damage pada survey sendiri'),('4037966f-737f-11f1-ac50-002b67818c25','survey_photos.upload.assigned','Upload Assigned Survey Photo','survey_photos','upload','assigned','Upload foto evidence pada survey sendiri'),('40379833-737f-11f1-ac50-002b67818c25','survey_photos.view.assigned','View Assigned Survey Photos','survey_photos','view','assigned','Melihat foto evidence pada survey sendiri'),('40a3aee5-737f-11f1-ac50-002b67818c25','reviews.view.all','View Reviews','reviews','view','all','Melihat survey pending review'),('40a3b4bb-737f-11f1-ac50-002b67818c25','reviews.manage.all','Manage Reviews','reviews','manage','all','Approve, reject, dan need revision survey'),('40a3b75d-737f-11f1-ac50-002b67818c25','reports.view.all','View Reports','reports','view','all','Melihat arsip report'),('40a3b923-737f-11f1-ac50-002b67818c25','reports.generate.all','Generate Reports','reports','generate','all','Membuat report dari survey approved'),('40a3bb17-737f-11f1-ac50-002b67818c25','reports.version.all','Version Reports','reports','version','all','Membuat revisi report'),('40f9de5e-737f-11f1-ac50-002b67818c25','finance.view.all','View Finance','finance','view','all','Melihat dashboard finance, invoice, payment, outstanding'),('40f9e5e6-737f-11f1-ac50-002b67818c25','finance.manage.all','Manage Finance','finance','manage','all','Mengelola price list, invoice, dan payment'),('40f9e90f-737f-11f1-ac50-002b67818c25','finance.invoice.create.all','Create Invoice','finance.invoice','create','all','Membuat invoice draft'),('40f9eb1b-737f-11f1-ac50-002b67818c25','finance.payment.create.all','Create Payment','finance.payment','create','all','Mencatat payment'),('4831711a-79e5-11f1-a1f6-002b67818c25','container_manufacturers.view.all','View Container Manufacturers','container_manufacturers','view','all','Melihat master pabrik pembuat peti kemas'),('48318cc3-79e5-11f1-a1f6-002b67818c25','container_manufacturers.manage.all','Manage Container Manufacturers','container_manufacturers','manage','all','Mengelola master pabrik pembuat peti kemas'),('48318ebf-79e5-11f1-a1f6-002b67818c25','fitness_approval_categories.view.all','View Fitness Approval Categories','fitness_approval_categories','view','all','Melihat kategori persetujuan kelaikan'),('48318f9d-79e5-11f1-a1f6-002b67818c25','fitness_approval_categories.manage.all','Manage Fitness Approval Categories','fitness_approval_categories','manage','all','Mengelola kategori persetujuan kelaikan'),('4831f158-79e5-11f1-a1f6-002b67818c25','maintenance_schemes.view.all','View Maintenance Schemes','maintenance_schemes','view','all','Melihat skema pemeliharaan peti kemas'),('4831f29a-79e5-11f1-a1f6-002b67818c25','maintenance_schemes.manage.all','Manage Maintenance Schemes','maintenance_schemes','manage','all','Mengelola skema pemeliharaan peti kemas'),('4831f39b-79e5-11f1-a1f6-002b67818c25','inspection_areas.view.all','View Inspection Areas','inspection_areas','view','all','Melihat area pemeriksaan peti kemas'),('4831f454-79e5-11f1-a1f6-002b67818c25','inspection_areas.manage.all','Manage Inspection Areas','inspection_areas','manage','all','Mengelola area pemeriksaan peti kemas'),('4831f50d-79e5-11f1-a1f6-002b67818c25','structural_components.view.all','View Structural Components','structural_components','view','all','Melihat komponen struktur peti kemas'),('4831f5d2-79e5-11f1-a1f6-002b67818c25','structural_components.manage.all','Manage Structural Components','structural_components','manage','all','Mengelola komponen struktur peti kemas'),('4831f67e-79e5-11f1-a1f6-002b67818c25','structural_damage_criteria.view.all','View Structural Damage Criteria','structural_damage_criteria','view','all','Melihat kriteria kerusakan struktur'),('4831f72e-79e5-11f1-a1f6-002b67818c25','structural_damage_criteria.manage.all','Manage Structural Damage Criteria','structural_damage_criteria','manage','all','Mengelola kriteria kerusakan struktur'),('4831f81d-79e5-11f1-a1f6-002b67818c25','finding_severities.view.all','View Finding Severities','finding_severities','view','all','Melihat tingkat temuan'),('4831f927-79e5-11f1-a1f6-002b67818c25','finding_severities.manage.all','Manage Finding Severities','finding_severities','manage','all','Mengelola tingkat temuan'),('4831f9d7-79e5-11f1-a1f6-002b67818c25','inspection_test_parameters.view.all','View Inspection Test Parameters','inspection_test_parameters','view','all','Melihat parameter pengujian kelaikan'),('4831fa7e-79e5-11f1-a1f6-002b67818c25','inspection_test_parameters.manage.all','Manage Inspection Test Parameters','inspection_test_parameters','manage','all','Mengelola parameter pengujian kelaikan'),('4831fb21-79e5-11f1-a1f6-002b67818c25','fitness_checklist_templates.view.all','View Fitness Checklist Templates','fitness_checklist_templates','view','all','Melihat template checklist kelaikan'),('4831fbdf-79e5-11f1-a1f6-002b67818c25','fitness_checklist_templates.manage.all','Manage Fitness Checklist Templates','fitness_checklist_templates','manage','all','Mengelola template checklist kelaikan'),('4831fcae-79e5-11f1-a1f6-002b67818c25','evidence_photo_categories.view.all','View Evidence Photo Categories','evidence_photo_categories','view','all','Melihat kategori foto evidence'),('4831fd54-79e5-11f1-a1f6-002b67818c25','evidence_photo_categories.manage.all','Manage Evidence Photo Categories','evidence_photo_categories','manage','all','Mengelola kategori foto evidence'),('4831fdfc-79e5-11f1-a1f6-002b67818c25','inspection_recommendations.view.all','View Inspection Recommendations','inspection_recommendations','view','all','Melihat rekomendasi hasil pemeriksaan'),('4831feaf-79e5-11f1-a1f6-002b67818c25','inspection_recommendations.manage.all','Manage Inspection Recommendations','inspection_recommendations','manage','all','Mengelola rekomendasi hasil pemeriksaan'),('4831ff58-79e5-11f1-a1f6-002b67818c25','authorized_signers.view.all','View Authorized Signers','authorized_signers','view','all','Melihat pejabat penandatangan'),('48320000-79e5-11f1-a1f6-002b67818c25','authorized_signers.manage.all','Manage Authorized Signers','authorized_signers','manage','all','Mengelola pejabat penandatangan'),('483200b5-79e5-11f1-a1f6-002b67818c25','fitness_applications.view.all','View Fitness Applications','fitness_applications','view','all','Melihat permohonan kelaikan'),('48320163-79e5-11f1-a1f6-002b67818c25','fitness_applications.manage.all','Manage Fitness Applications','fitness_applications','manage','all','Mengelola permohonan kelaikan'),('48320221-79e5-11f1-a1f6-002b67818c25','application_containers.view.all','View Application Containers','application_containers','view','all','Melihat data peti kemas kelaikan'),('483202c5-79e5-11f1-a1f6-002b67818c25','application_containers.manage.all','Manage Application Containers','application_containers','manage','all','Mengelola data peti kemas kelaikan'),('4832037e-79e5-11f1-a1f6-002b67818c25','fitness_container_imports.view.all','View Fitness Container Imports','fitness_container_imports','view','all','Melihat import data peti kemas kelaikan'),('4832043a-79e5-11f1-a1f6-002b67818c25','fitness_container_imports.manage.all','Manage Fitness Container Imports','fitness_container_imports','manage','all','Mengelola import data peti kemas kelaikan'),('483204eb-79e5-11f1-a1f6-002b67818c25','fitness_assignments.view.all','View Fitness Assignments','fitness_assignments','view','all','Melihat assignment kelaikan'),('483205a3-79e5-11f1-a1f6-002b67818c25','fitness_assignments.manage.all','Manage Fitness Assignments','fitness_assignments','manage','all','Mengelola assignment kelaikan'),('4832064f-79e5-11f1-a1f6-002b67818c25','fitness_inspections.view.all','View Fitness Inspections','fitness_inspections','view','all','Melihat pemeriksaan kelaikan'),('483206fd-79e5-11f1-a1f6-002b67818c25','fitness_inspections.manage.assigned','Manage Assigned Fitness Inspections','fitness_inspections','manage','assigned','Mengelola pemeriksaan kelaikan yang ditugaskan'),('483207b3-79e5-11f1-a1f6-002b67818c25','structural_findings.view.all','View Structural Findings','structural_findings','view','all','Melihat temuan struktur'),('4832086c-79e5-11f1-a1f6-002b67818c25','structural_findings.manage.assigned','Manage Assigned Structural Findings','structural_findings','manage','assigned','Mengelola temuan struktur yang ditugaskan'),('4832093b-79e5-11f1-a1f6-002b67818c25','repair_followups.view.all','View Repair Followups','repair_followups','view','all','Melihat tindak lanjut perbaikan'),('483209ef-79e5-11f1-a1f6-002b67818c25','repair_followups.manage.all','Manage Repair Followups','repair_followups','manage','all','Mengelola tindak lanjut perbaikan'),('48320a97-79e5-11f1-a1f6-002b67818c25','fitness_reviews.view.all','View Fitness Reviews','fitness_reviews','view','all','Melihat review kelaikan'),('48320b44-79e5-11f1-a1f6-002b67818c25','fitness_reviews.manage.all','Manage Fitness Reviews','fitness_reviews','manage','all','Mengelola review kelaikan'),('48320bf9-79e5-11f1-a1f6-002b67818c25','fitness_approvals.view.all','View Fitness Approvals','fitness_approvals','view','all','Melihat persetujuan kelaikan'),('48320ca2-79e5-11f1-a1f6-002b67818c25','fitness_approvals.issue.all','Issue Fitness Approvals','fitness_approvals','issue','all','Menerbitkan persetujuan kelaikan'),('48324868-79e5-11f1-a1f6-002b67818c25','fitness_documents.view.all','View Fitness Documents','fitness_documents','view','all','Melihat dokumen kelaikan'),('48324a72-79e5-11f1-a1f6-002b67818c25','fitness_documents.manage.all','Manage Fitness Documents','fitness_documents','manage','all','Mengelola dokumen kelaikan'),('77ad877b-7a83-11f1-ab0b-002b67818c25','maintenance_schemes.create.all','Create Maintenance Schemes','maintenance_schemes','create','all','Membuat skema pemeliharaan peti kemas'),('77adc91d-7a83-11f1-ab0b-002b67818c25','maintenance_schemes.update.all','Update Maintenance Schemes','maintenance_schemes','update','all','Mengubah skema pemeliharaan peti kemas'),('77adcbbe-7a83-11f1-ab0b-002b67818c25','maintenance_schemes.delete.all','Delete Maintenance Schemes','maintenance_schemes','delete','all','Menonaktifkan skema pemeliharaan peti kemas'),('77ae7c50-7a83-11f1-ab0b-002b67818c25','inspection_areas.create.all','Create Inspection Areas','inspection_areas','create','all','Membuat area pemeriksaan peti kemas'),('77ae946c-7a83-11f1-ab0b-002b67818c25','inspection_areas.update.all','Update Inspection Areas','inspection_areas','update','all','Mengubah area pemeriksaan peti kemas'),('77ae9586-7a83-11f1-ab0b-002b67818c25','inspection_areas.delete.all','Delete Inspection Areas','inspection_areas','delete','all','Menonaktifkan area pemeriksaan peti kemas'),('77ae98e7-7a83-11f1-ab0b-002b67818c25','structural_components.create.all','Create Structural Components','structural_components','create','all','Membuat komponen struktur peti kemas'),('77ae9f69-7a83-11f1-ab0b-002b67818c25','structural_components.update.all','Update Structural Components','structural_components','update','all','Mengubah komponen struktur peti kemas'),('77aea080-7a83-11f1-ab0b-002b67818c25','structural_components.delete.all','Delete Structural Components','structural_components','delete','all','Menonaktifkan komponen struktur peti kemas'),('77aea46e-7a83-11f1-ab0b-002b67818c25','structural_damage_criteria.create.all','Create Structural Damage Criteria','structural_damage_criteria','create','all','Membuat kriteria kerusakan struktur'),('77aea8e3-7a83-11f1-ab0b-002b67818c25','structural_damage_criteria.update.all','Update Structural Damage Criteria','structural_damage_criteria','update','all','Mengubah kriteria kerusakan struktur'),('77aea9c5-7a83-11f1-ab0b-002b67818c25','structural_damage_criteria.delete.all','Delete Structural Damage Criteria','structural_damage_criteria','delete','all','Menonaktifkan kriteria kerusakan struktur'),('77aec591-7a83-11f1-ab0b-002b67818c25','finding_severities.create.all','Create Finding Severities','finding_severities','create','all','Membuat tingkat temuan'),('77aec696-7a83-11f1-ab0b-002b67818c25','finding_severities.update.all','Update Finding Severities','finding_severities','update','all','Mengubah tingkat temuan'),('77aec766-7a83-11f1-ab0b-002b67818c25','finding_severities.delete.all','Delete Finding Severities','finding_severities','delete','all','Menonaktifkan tingkat temuan'),('77aeca1f-7a83-11f1-ab0b-002b67818c25','inspection_test_parameters.create.all','Create Inspection Test Parameters','inspection_test_parameters','create','all','Membuat parameter pengujian kelaikan'),('77aecb21-7a83-11f1-ab0b-002b67818c25','inspection_test_parameters.update.all','Update Inspection Test Parameters','inspection_test_parameters','update','all','Mengubah parameter pengujian kelaikan'),('77aecbf0-7a83-11f1-ab0b-002b67818c25','inspection_test_parameters.delete.all','Delete Inspection Test Parameters','inspection_test_parameters','delete','all','Menonaktifkan parameter pengujian kelaikan'),('77aecea0-7a83-11f1-ab0b-002b67818c25','fitness_checklist_templates.create.all','Create Fitness Checklist Templates','fitness_checklist_templates','create','all','Membuat template checklist kelaikan'),('77aecfd0-7a83-11f1-ab0b-002b67818c25','fitness_checklist_templates.update.all','Update Fitness Checklist Templates','fitness_checklist_templates','update','all','Mengubah template checklist kelaikan'),('77aed0a4-7a83-11f1-ab0b-002b67818c25','fitness_checklist_templates.delete.all','Delete Fitness Checklist Templates','fitness_checklist_templates','delete','all','Menonaktifkan template checklist kelaikan'),('77aee013-7a83-11f1-ab0b-002b67818c25','evidence_photo_categories.create.all','Create Evidence Photo Categories','evidence_photo_categories','create','all','Membuat kategori foto evidence'),('77aee108-7a83-11f1-ab0b-002b67818c25','evidence_photo_categories.update.all','Update Evidence Photo Categories','evidence_photo_categories','update','all','Mengubah kategori foto evidence'),('77aee1de-7a83-11f1-ab0b-002b67818c25','evidence_photo_categories.delete.all','Delete Evidence Photo Categories','evidence_photo_categories','delete','all','Menonaktifkan kategori foto evidence'),('77aee477-7a83-11f1-ab0b-002b67818c25','inspection_recommendations.create.all','Create Inspection Recommendations','inspection_recommendations','create','all','Membuat rekomendasi hasil pemeriksaan'),('77aee54c-7a83-11f1-ab0b-002b67818c25','inspection_recommendations.update.all','Update Inspection Recommendations','inspection_recommendations','update','all','Mengubah rekomendasi hasil pemeriksaan'),('77aee622-7a83-11f1-ab0b-002b67818c25','inspection_recommendations.delete.all','Delete Inspection Recommendations','inspection_recommendations','delete','all','Menonaktifkan rekomendasi hasil pemeriksaan'),('77af1fd4-7a83-11f1-ab0b-002b67818c25','authorized_signers.create.all','Create Authorized Signers','authorized_signers','create','all','Membuat pejabat penandatangan'),('77af20dc-7a83-11f1-ab0b-002b67818c25','authorized_signers.update.all','Update Authorized Signers','authorized_signers','update','all','Mengubah pejabat penandatangan'),('77af2197-7a83-11f1-ab0b-002b67818c25','authorized_signers.delete.all','Delete Authorized Signers','authorized_signers','delete','all','Menonaktifkan pejabat penandatangan'),('77af23f5-7a83-11f1-ab0b-002b67818c25','company_profiles.create.all','Create Company Profiles','company_profiles','create','all','Membuat profil badan usaha'),('77af2f98-7a83-11f1-ab0b-002b67818c25','company_profiles.update.all','Update Company Profiles','company_profiles','update','all','Mengubah profil badan usaha'),('77af3122-7a83-11f1-ab0b-002b67818c25','company_profiles.delete.all','Delete Company Profiles','company_profiles','delete','all','Menonaktifkan profil badan usaha'),('84947ba5-7456-11f1-806f-002b67818c25','audit.view.all','View Audit Log','audit','view','all','Melihat audit log sistem'),('84955473-7456-11f1-806f-002b67818c25','checklist_templates.view.all','View Checklist Templates','checklist_templates','view','all','Melihat checklist template / data bootstrap'),('84955622-7456-11f1-806f-002b67818c25','settings.view.all','View Settings','settings','view','all','Melihat menu setting'),('849556d7-7456-11f1-806f-002b67818c25','users.view.all','View Users','users','view','all','Melihat user management'),('8495577e-7456-11f1-806f-002b67818c25','roles.view.all','View Roles','roles','view','all','Melihat role dan permission'),('8495581a-7456-11f1-806f-002b67818c25','company_profiles.view.all','View Company Profile','company_profiles','view','all','Melihat company profile'),('849558e0-7456-11f1-806f-002b67818c25','numbering_settings.view.all','View Numbering Settings','numbering_settings','view','all','Melihat numbering setting'),('baf0ca5c-7a77-11f1-ab0b-002b67818c25','container_manufacturers.create.all','Create Container Manufacturers','container_manufacturers','create','all','Membuat master pabrik pembuat peti kemas'),('baf1a831-7a77-11f1-ab0b-002b67818c25','container_manufacturers.update.all','Update Container Manufacturers','container_manufacturers','update','all','Mengubah master pabrik pembuat peti kemas'),('baf1ab1d-7a77-11f1-ab0b-002b67818c25','container_manufacturers.delete.all','Delete Container Manufacturers','container_manufacturers','delete','all','Menonaktifkan master pabrik pembuat peti kemas'),('baf1accf-7a77-11f1-ab0b-002b67818c25','fitness_approval_categories.create.all','Create Fitness Approval Categories','fitness_approval_categories','create','all','Membuat kategori persetujuan kelaikan'),('baf1ae00-7a77-11f1-ab0b-002b67818c25','fitness_approval_categories.update.all','Update Fitness Approval Categories','fitness_approval_categories','update','all','Mengubah kategori persetujuan kelaikan'),('baf1aee0-7a77-11f1-ab0b-002b67818c25','fitness_approval_categories.delete.all','Delete Fitness Approval Categories','fitness_approval_categories','delete','all','Menonaktifkan kategori persetujuan kelaikan'),('bb3770dd-751e-11f1-8fe5-002b67818c25','surveys.view.all','View All Surveys','surveys','view','all','Melihat seluruh survey untuk monitoring Admin');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `price_lists`
--

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

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `reports` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `report_no` varchar(80) NOT NULL,
  `report_type` varchar(50) NOT NULL DEFAULT 'container_inspection_report',
  `job_order_id` char(36) DEFAULT NULL,
  `survey_id` char(36) DEFAULT NULL,
  `customer_id` char(36) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'pending_generation',
  `current_version_no` int NOT NULL DEFAULT '0',
  `qr_token` varchar(120) DEFAULT NULL,
  `validated_publicly` tinyint(1) NOT NULL DEFAULT '1',
  `generated_by` char(36) DEFAULT NULL,
  `generated_at` datetime(6) DEFAULT NULL,
  `finalized_by` char(36) DEFAULT NULL,
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
  CONSTRAINT `fk_reports_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
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

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `responsibility_codes` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(30) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_responsibility_codes_status` (`status`),
  CONSTRAINT `chk_responsibility_codes_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `responsibility_codes`
--

LOCK TABLES `responsibility_codes` WRITE;
/*!40000 ALTER TABLE `responsibility_codes` DISABLE KEYS */;
INSERT INTO `responsibility_codes` (`id`, `code`, `name`, `description`, `status`, `created_at`, `updated_at`) VALUES ('3f2fe18e-737f-11f1-ac50-002b67818c25','C','Customer','Customer responsibility','active','2026-06-29 05:56:18.333391','2026-06-29 05:56:18.333391'),('3f2fe5c4-737f-11f1-ac50-002b67818c25','O','Owner','Owner responsibility','active','2026-06-29 05:56:18.333391','2026-06-29 05:56:18.333391'),('3f2fe71a-737f-11f1-ac50-002b67818c25','D','Depot','Depot responsibility','active','2026-06-29 05:56:18.333391','2026-06-29 05:56:18.333391'),('3f2fe80d-737f-11f1-ac50-002b67818c25','T','Trucker','Trucker responsibility','active','2026-06-29 05:56:18.333391','2026-06-29 05:56:18.333391'),('3f2fe8f7-737f-11f1-ac50-002b67818c25','U','Unknown','Unknown responsibility','active','2026-06-29 05:56:18.333391','2026-06-29 05:56:18.333391');
/*!40000 ALTER TABLE `responsibility_codes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_permissions`
--

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
INSERT INTO `role_permissions` (`id`, `role_id`, `permission_id`, `created_at`) VALUES ('3f282f02-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','3f277c21-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f2838e0-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278d74-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f283cf7-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278b9f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f284008-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278768-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f28472b-737f-11f1-ac50-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','3f278f3f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f284bbe-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278f3f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f285003-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278858-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f285c0a-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278e50-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f285f5a-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278c8d-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f2862e9-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f27896c-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f4365df-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42a80d-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3f436a4b-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42a903-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3f436c3a-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42a715-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3f436dd0-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42aaef-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3f436f85-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42a9ed-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3f437cda-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42abe3-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3f438189-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42acea-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3fa6b037-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa61c4b-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6b4d1-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa6149e-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6b6ba-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa617a5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6b889-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa61581-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6ba78-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa6188d-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6bc2d-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa616b5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6bd98-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa613ad-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6bef4-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa612c5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('403f8288-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40379102-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403f85d8-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40379102-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403f8ca9-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','403794be-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403f8f32-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','403794be-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403f95f7-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','403792f7-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403f9886-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','403792f7-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403f9f41-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40378ed5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fa1b3-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40378ed5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fa8d5-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4037966f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fabd9-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4037966f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fb49c-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40379833-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fb8ca-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40379833-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fc4da-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40377bc2-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fc8fe-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40377bc2-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fd3eb-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40378930-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fd709-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40378930-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fe088-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40378d25-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fe729-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40378d25-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403ff050-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40378b20-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403ff2f8-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40378b20-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('404041de-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40378673-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('404045ba-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40378673-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('40a46ac5-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40a3b923-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a46df0-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40a3b923-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a4742e-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40a3bb17-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a4774e-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40a3bb17-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a47d3f-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40a3b75d-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a47fe9-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40a3b75d-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a485ad-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40a3b4bb-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a48833-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40a3b4bb-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a48e62-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40a3aee5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a490aa-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40a3aee5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a549f9-737f-11f1-ac50-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','40a3b75d-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.780876'),('40fa9a26-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40f9e90f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:21.339139'),('40faaa6a-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40f9e5e6-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:21.339139'),('40fab1bd-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40f9eb1b-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:21.339139'),('40fab7f1-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40f9de5e-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:21.339139'),('40fb6995-737f-11f1-ac50-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','40f9de5e-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:21.345000'),('4834b32a-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483202c5-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4834f1b6-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320221-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4834f375-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320000-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48350c7f-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831ff58-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48350dec-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48318cc3-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48350f2d-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831711a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351066-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831fd54-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351186-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831fcae-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4835128c-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f927-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483513cf-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f81d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483514e0-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320163-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483515f0-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483200b5-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351705-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48318f9d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351873-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48318ebf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483519a6-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320ca2-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351abb-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320bf9-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351bd2-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483205a3-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351cff-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483204eb-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351e28-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831fbdf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351f3f-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831fb21-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48352065-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4832043a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48352188-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4832037e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4835229a-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48324a72-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483523bd-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48324868-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483524e6-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483206fd-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4835260a-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4832064f-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4835272a-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320b44-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4835283a-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320a97-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48352991-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f454-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48352aab-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f39b-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48352bc8-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831feaf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48352db1-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831fdfc-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483534cc-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831fa7e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48353696-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f9d7-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48353864-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f29a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48353a42-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f158-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48353c02-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483209ef-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48353dde-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4832093b-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48353fab-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f5d2-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48354197-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f50d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48354317-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f72e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48354499-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f67e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48354603-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4832086c-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48354729-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483207b3-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483758e7-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','483202c5-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48375e01-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48320221-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48375f4e-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48320000-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('4837606e-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831ff58-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483761a9-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48318cc3-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483762c4-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831711a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483763ca-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831fd54-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483764d1-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831fcae-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483765d2-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f927-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483766ef-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f81d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483767fa-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48320163-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48376919-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','483200b5-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48376a29-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48318f9d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48376b30-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48318ebf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48376e29-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','483205a3-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48376f48-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','483204eb-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('4837705d-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831fbdf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('4837716d-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831fb21-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377286-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4832043a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377396-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4832037e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('4837749d-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48324a72-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483775cb-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48324868-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377704-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f454-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377800-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f39b-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377901-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831feaf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377a02-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831fdfc-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377b1e-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831fa7e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377c30-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f9d7-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377d2c-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f29a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377e5b-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f158-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377f57-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','483209ef-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48378051-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4832093b-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('4837814d-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f5d2-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48378244-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f50d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48378343-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f72e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48378456-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f67e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483deba3-79e5-11f1-a1f6-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','483206fd-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.168251'),('483df426-79e5-11f1-a1f6-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','4832086c-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.168251'),('48409ddb-79e5-11f1-a1f6-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','48320bf9-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.185987'),('4840a37e-79e5-11f1-a1f6-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','48324868-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.185987'),('4840a4fc-79e5-11f1-a1f6-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','4832064f-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.185987'),('4840a629-79e5-11f1-a1f6-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','48320b44-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.185987'),('4840a784-79e5-11f1-a1f6-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','48320a97-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.185987'),('48435caf-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','48320221-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48436392-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831ff58-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484365b9-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831711a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484369a7-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831fcae-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48436beb-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831f81d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48436d75-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','483200b5-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48436f19-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','48318ebf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('4843708c-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','48320bf9-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484371db-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','483204eb-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48437337-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831fb21-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('4843d6a1-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4832037e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('4843d8ac-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','48324868-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('4843d9f6-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4832064f-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('4843db2d-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','48320a97-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('4843dc64-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831f39b-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48440236-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831fdfc-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48440393-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831f9d7-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484404a0-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831f158-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484405c4-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4832093b-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484406ec-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831f50d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484407f8-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831f67e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484408ff-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','483207b3-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('77af693e-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77af1fd4-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77af7e1f-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77af1fd4-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77af809a-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77af2197-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77af8410-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77af2197-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77af8b33-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77af20dc-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77af8c51-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77af20dc-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b01ab0-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77af23f5-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b01cf9-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77af23f5-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b01fef-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77af3122-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02281-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77af3122-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0241d-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77af2f98-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02535-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77af2f98-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02b17-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aee013-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02c27-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aee013-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02d8e-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aee1de-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02e78-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aee1de-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02fd7-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aee108-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b03154-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aee108-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b03655-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aec591-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b03763-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aec591-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b039ba-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aec766-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b03add-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aec766-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b03c40-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aec696-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b03db0-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aec696-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b042aa-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aecea0-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b04395-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aecea0-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b045a8-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aed0a4-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0469b-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aed0a4-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b047f8-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aecfd0-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b04a14-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aecfd0-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b04fc8-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77ae7c50-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b050d7-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77ae7c50-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05220-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77ae9586-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b052f5-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77ae9586-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05433-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77ae946c-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0551d-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77ae946c-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05a09-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aee477-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05af6-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aee477-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05c3a-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aee622-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05d15-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aee622-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05e68-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aee54c-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05f41-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aee54c-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b06455-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aeca1f-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b06540-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aeca1f-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b06697-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aecbf0-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0676e-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aecbf0-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b06a8a-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aecb21-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b06b6f-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aecb21-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b08d9e-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77ad877b-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b08ebc-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77ad877b-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09158-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77adcbbe-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0923a-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77adcbbe-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09404-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77adc91d-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b094f3-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77adc91d-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09a09-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77ae98e7-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09afe-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77ae98e7-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09c4a-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aea080-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09d34-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aea080-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09e83-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77ae9f69-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09f68-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77ae9f69-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0a44a-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aea46e-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0a561-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aea46e-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0a6b4-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aea9c5-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0a79b-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aea9c5-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0a8e7-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aea8e3-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0a9d4-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aea8e3-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('84980f0f-7456-11f1-806f-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','84947ba5-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.575296'),('84981fef-7456-11f1-806f-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','84955473-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.575296'),('8498219e-7456-11f1-806f-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','8495581a-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.575296'),('84982331-7456-11f1-806f-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','849558e0-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.575296'),('8498248f-7456-11f1-806f-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','84955622-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.575296'),('849a6e56-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','84947ba5-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('849a72a9-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','84955473-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('849a73ee-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','8495581a-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('849a7614-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','849558e0-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('849a77c8-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','8495577e-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('849a78ef-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','84955622-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('849a7a05-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','849556d7-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('b42347c3-751e-11f1-8fe5-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','40a3b923-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.687365'),('b4235107-751e-11f1-8fe5-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','40a3bb17-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.687365'),('b42355eb-751e-11f1-8fe5-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','40a3b75d-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.687365'),('b42359ee-751e-11f1-8fe5-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','40a3b4bb-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.687365'),('b4235d2f-751e-11f1-8fe5-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','40a3aee5-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.687365'),('b4283720-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','3f429301-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4283b46-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','3f429730-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4283d67-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','3f428d2c-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4283f46-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','3f429f1b-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4284851-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','3f429b59-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4284a6a-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','3f42a2cb-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4284c33-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40379102-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4284e09-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','403794be-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4284fe3-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','403792f7-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b42851c7-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40378ed5-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b428574e-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','4037966f-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4285966-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40379833-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4285b99-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40377bc2-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4285fe1-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40378930-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b42864c5-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40378d25-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b42867ae-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40378b20-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4286ae2-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40378673-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b42d39d2-751e-11f1-8fe5-002b67818c25','3f26bb58-737f-11f1-ac50-002b67818c25','40f9e90f-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.752531'),('b42d3e08-751e-11f1-8fe5-002b67818c25','3f26bb58-737f-11f1-ac50-002b67818c25','40f9e5e6-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.752531'),('b42d401e-751e-11f1-8fe5-002b67818c25','3f26bb58-737f-11f1-ac50-002b67818c25','40f9eb1b-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.752531'),('b42d41f9-751e-11f1-8fe5-002b67818c25','3f26bb58-737f-11f1-ac50-002b67818c25','40f9de5e-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.752531'),('b42d43fe-751e-11f1-8fe5-002b67818c25','3f26bb58-737f-11f1-ac50-002b67818c25','40a3b75d-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.752531'),('baf3dc1b-7a77-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','baf0ca5c-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf3f875-7a77-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','baf0ca5c-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf3fafe-7a77-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','baf1ab1d-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf3fc16-7a77-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','baf1ab1d-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf3fdab-7a77-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','baf1a831-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf3fed6-7a77-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','baf1a831-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf4002e-7a77-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','baf1accf-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf40136-7a77-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','baf1accf-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf402a4-7a77-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','baf1aee0-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf403e7-7a77-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','baf1aee0-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf47cbc-7a77-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','baf1ae00-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf47e54-7a77-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','baf1ae00-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('bb3d4e77-751e-11f1-8fe5-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','bb3770dd-751e-11f1-8fe5-002b67818c25','2026-07-01 14:30:27.600531'),('bb3d510e-751e-11f1-8fe5-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','849556d7-7456-11f1-806f-002b67818c25','2026-07-01 14:30:27.600531'),('bf5804b1-75f6-11f1-9f38-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','3f278f3f-737f-11f1-ac50-002b67818c25','2026-07-02 16:16:45.781230'),('bf5857be-75f6-11f1-9f38-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','bb3770dd-751e-11f1-8fe5-002b67818c25','2026-07-02 16:16:45.781230'),('bf5ebefb-75f6-11f1-9f38-002b67818c25','3f26bb58-737f-11f1-ac50-002b67818c25','3f278f3f-737f-11f1-ac50-002b67818c25','2026-07-02 16:16:45.825328'),('e311b0f6-75c3-11f1-9f38-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','40379833-737f-11f1-ac50-002b67818c25','2026-07-02 10:12:41.384461');
/*!40000 ALTER TABLE `role_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

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
INSERT INTO `roles` (`id`, `code`, `name`, `description`, `is_system_role`, `created_at`, `updated_at`) VALUES ('3f26a41f-737f-11f1-ac50-002b67818c25','super_admin','Super Admin','Highest system administrator',1,'2026-06-29 05:56:18.271615','2026-06-29 05:56:18.271615'),('3f26b6a0-737f-11f1-ac50-002b67818c25','admin','Admin / Operasional','Operational admin for master data and jobs',1,'2026-06-29 05:56:18.271615','2026-06-29 05:56:18.271615'),('3f26b8df-737f-11f1-ac50-002b67818c25','surveyor','Surveyor','Survey field user',1,'2026-06-29 05:56:18.271615','2026-06-29 05:56:18.271615'),('3f26ba11-737f-11f1-ac50-002b67818c25','supervisor','Supervisor / Approver','Survey reviewer and approver',1,'2026-06-29 05:56:18.271615','2026-06-29 05:56:18.271615'),('3f26bb58-737f-11f1-ac50-002b67818c25','finance','Finance','Finance and billing user',1,'2026-06-29 05:56:18.271615','2026-06-29 05:56:18.271615'),('3f26bccb-737f-11f1-ac50-002b67818c25','management','Management','Read-only dashboard and recap user',1,'2026-06-29 05:56:18.271615','2026-06-29 05:56:18.271615');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `structural_components`
--

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
INSERT INTO `structural_components` (`id`, `code`, `component_name`, `inspection_area_id`, `is_structural_critical`, `description`, `display_order`, `status`, `created_at`, `updated_at`) VALUES ('481afb0b-79e5-11f1-a1f6-002b67818c25','top_side_rail','Top Side Rail','4816874d-79e5-11f1-a1f6-002b67818c25',1,NULL,10,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b0ca1-79e5-11f1-a1f6-002b67818c25','bottom_side_rail','Bottom Side Rail','481688cc-79e5-11f1-a1f6-002b67818c25',1,NULL,20,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b100a-79e5-11f1-a1f6-002b67818c25','header','Header','481685b8-79e5-11f1-a1f6-002b67818c25',1,NULL,30,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b11f3-79e5-11f1-a1f6-002b67818c25','sill','Sill','48168684-79e5-11f1-a1f6-002b67818c25',1,NULL,40,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b13f3-79e5-11f1-a1f6-002b67818c25','corner_post','Corner Post','4816899b-79e5-11f1-a1f6-002b67818c25',1,NULL,50,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b15d2-79e5-11f1-a1f6-002b67818c25','corner_fitting','Corner Fitting','4816899b-79e5-11f1-a1f6-002b67818c25',1,NULL,60,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b17ea-79e5-11f1-a1f6-002b67818c25','intermediate_fitting','Intermediate Fitting','4816899b-79e5-11f1-a1f6-002b67818c25',1,NULL,70,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b1a55-79e5-11f1-a1f6-002b67818c25','cross_member','Cross Member','481688cc-79e5-11f1-a1f6-002b67818c25',1,NULL,80,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b1c58-79e5-11f1-a1f6-002b67818c25','understructure','Understructure','481688cc-79e5-11f1-a1f6-002b67818c25',1,NULL,90,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b1e4d-79e5-11f1-a1f6-002b67818c25','floor','Floor','48168812-79e5-11f1-a1f6-002b67818c25',0,NULL,100,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b200c-79e5-11f1-a1f6-002b67818c25','roof','Roof','4816874d-79e5-11f1-a1f6-002b67818c25',0,NULL,110,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b2222-79e5-11f1-a1f6-002b67818c25','side_wall','Side Wall','48167e70-79e5-11f1-a1f6-002b67818c25',0,NULL,120,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b23ff-79e5-11f1-a1f6-002b67818c25','end_wall','End Wall','481685b8-79e5-11f1-a1f6-002b67818c25',0,NULL,130,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b25d4-79e5-11f1-a1f6-002b67818c25','door_panel','Door Panel','48168684-79e5-11f1-a1f6-002b67818c25',0,NULL,140,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b27b5-79e5-11f1-a1f6-002b67818c25','door_locking_rod','Door Locking Rod','48168684-79e5-11f1-a1f6-002b67818c25',1,NULL,150,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b2994-79e5-11f1-a1f6-002b67818c25','csc_safety_approval_plate','CSC Safety Approval Plate','48168a4f-79e5-11f1-a1f6-002b67818c25',1,NULL,160,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298');
/*!40000 ALTER TABLE `structural_components` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `structural_damage_criteria`
--

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
INSERT INTO `structural_damage_criteria` (`id`, `code`, `criteria_name`, `description`, `component_id`, `severity_default`, `affects_fitness_default`, `repair_required_default`, `inspection_note`, `status`, `created_at`, `updated_at`) VALUES ('481e65eb-79e5-11f1-a1f6-002b67818c25','dent','Dent','Penyok pada komponen peti kemas.',NULL,'minor',0,0,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e6f50-79e5-11f1-a1f6-002b67818c25','crack','Crack','Retak pada komponen peti kemas.',NULL,'major',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e7201-79e5-11f1-a1f6-002b67818c25','hole','Hole','Lubang pada komponen peti kemas.',NULL,'major',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e7372-79e5-11f1-a1f6-002b67818c25','broken','Broken','Komponen patah atau rusak berat.',NULL,'critical',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e74dd-79e5-11f1-a1f6-002b67818c25','bent','Bent','Komponen bengkok atau berubah bentuk.',NULL,'major',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e7677-79e5-11f1-a1f6-002b67818c25','missing','Missing','Komponen hilang.',NULL,'critical',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e785b-79e5-11f1-a1f6-002b67818c25','corrosion','Corrosion','Korosi pada komponen.',NULL,'minor',0,0,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e79c0-79e5-11f1-a1f6-002b67818c25','severe_corrosion','Severe Corrosion','Korosi berat pada komponen.',NULL,'critical',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e7e2e-79e5-11f1-a1f6-002b67818c25','loose_locking_rod','Loose Locking Rod','Locking rod longgar.','481b27b5-79e5-11f1-a1f6-002b67818c25','major',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e81d9-79e5-11f1-a1f6-002b67818c25','csc_plate_missing','CSC Plate Missing','Plate persetujuan keselamatan tidak ada.','481b2994-79e5-11f1-a1f6-002b67818c25','critical',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e851e-79e5-11f1-a1f6-002b67818c25','csc_plate_unreadable','CSC Plate Unreadable','Plate persetujuan keselamatan tidak terbaca.','481b2994-79e5-11f1-a1f6-002b67818c25','major',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e86f8-79e5-11f1-a1f6-002b67818c25','deformation_affecting_structure','Deformation Affecting Structure','Deformasi yang memengaruhi struktur.',NULL,'critical',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e8879-79e5-11f1-a1f6-002b67818c25','watertightness_failure','Watertightness Failure','Kegagalan kedap air.',NULL,'major',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475');
/*!40000 ALTER TABLE `structural_damage_criteria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_approvals`
--

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

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_checklist_responses` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `survey_id` char(36) NOT NULL,
  `template_item_id` char(36) DEFAULT NULL,
  `item_code` varchar(80) NOT NULL,
  `item_label` varchar(200) NOT NULL,
  `response_value` varchar(50) DEFAULT NULL,
  `response_text` text,
  `is_required` tinyint(1) NOT NULL DEFAULT '1',
  `is_critical` tinyint(1) NOT NULL DEFAULT '0',
  `display_order` int NOT NULL DEFAULT '0',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `survey_id` (`survey_id`,`item_code`),
  KEY `idx_survey_checklist_survey` (`survey_id`)
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

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_damages` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `survey_id` char(36) NOT NULL,
  `damage_no` varchar(30) NOT NULL,
  `face` varchar(50) NOT NULL,
  `internal_location` varchar(30) NOT NULL,
  `cedex_location_id` char(36) DEFAULT NULL,
  `component_id` char(36) NOT NULL,
  `damage_id` char(36) NOT NULL,
  `repair_id` char(36) DEFAULT NULL,
  `material_id` char(36) DEFAULT NULL,
  `responsibility_id` char(36) DEFAULT NULL,
  `severity` varchar(30) NOT NULL DEFAULT 'minor',
  `quantity` int DEFAULT NULL,
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
  CONSTRAINT `fk_survey_damages_cedex_location` FOREIGN KEY (`cedex_location_id`) REFERENCES `cedex_locations` (`id`),
  CONSTRAINT `fk_survey_damages_component` FOREIGN KEY (`component_id`) REFERENCES `cedex_components` (`id`),
  CONSTRAINT `fk_survey_damages_damage` FOREIGN KEY (`damage_id`) REFERENCES `cedex_damages` (`id`),
  CONSTRAINT `fk_survey_damages_material` FOREIGN KEY (`material_id`) REFERENCES `cedex_materials` (`id`),
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

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_revision_items` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `approval_id` char(36) NOT NULL,
  `survey_id` char(36) NOT NULL,
  `target_type` varchar(50) NOT NULL,
  `target_id` char(36) DEFAULT NULL,
  `note` text NOT NULL,
  `is_resolved` tinyint(1) NOT NULL DEFAULT '0',
  `resolved_by` char(36) DEFAULT NULL,
  `resolved_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_survey_revision_items_survey` (`survey_id`),
  KEY `idx_survey_revision_items_resolved` (`is_resolved`)
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
-- Table structure for table `survey_types`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_types` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
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
  UNIQUE KEY `code` (`code`),
  KEY `idx_survey_types_status` (`status`),
  CONSTRAINT `chk_survey_types_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_types`
--

LOCK TABLES `survey_types` WRITE;
/*!40000 ALTER TABLE `survey_types` DISABLE KEYS */;
INSERT INTO `survey_types` (`id`, `code`, `name`, `description`, `requires_eir`, `requires_light_test`, `requires_cargo_worthy_result`, `status`, `created_at`, `updated_at`) VALUES ('3f2b441f-737f-11f1-ac50-002b67818c25','GI','Gate In Survey','Survey when container enters yard or depot',1,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b4c28-737f-11f1-ac50-002b67818c25','GO','Gate Out Survey','Survey when container leaves yard or depot',1,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b4eea-737f-11f1-ac50-002b67818c25','DS','Damage Survey','Specific survey for container damage',0,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b50fc-737f-11f1-ac50-002b67818c25','CW','Cargo Worthy Survey','Cargo worthy condition assessment',0,1,1,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b52e1-737f-11f1-ac50-002b67818c25','CL','Cleanliness Survey','Container cleanliness survey',0,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b5e33-737f-11f1-ac50-002b67818c25','ONH','On Hire Survey','Start of hire survey',0,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b6033-737f-11f1-ac50-002b67818c25','OFH','Off Hire Survey','End of hire survey',0,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b626d-737f-11f1-ac50-002b67818c25','STUF','Stuffing Survey','Survey during stuffing activity',0,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b63fa-737f-11f1-ac50-002b67818c25','STRP','Stripping Survey','Survey during stripping activity',0,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b65bf-737f-11f1-ac50-002b67818c25','PTI','Pre-Trip Inspection','Reefer pre-trip inspection',0,1,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441');
/*!40000 ALTER TABLE `survey_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `surveyor_profiles`
--

/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `surveyor_profiles` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `user_id` char(36) NOT NULL,
  `surveyor_code` varchar(50) NOT NULL,
  `full_name` varchar(150) NOT NULL,
  `phone` varchar(50) DEFAULT NULL,
  `area` varchar(150) DEFAULT NULL,
  `signature_file_id` char(36) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `deleted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  UNIQUE KEY `idx_surveyor_profiles_code` (`surveyor_code`),
  KEY `idx_surveyor_profiles_status` (`status`),
  CONSTRAINT `chk_surveyor_profiles_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `surveyor_profiles`
--

LOCK TABLES `surveyor_profiles` WRITE;
/*!40000 ALTER TABLE `surveyor_profiles` DISABLE KEYS */;
INSERT INTO `surveyor_profiles` (`id`, `user_id`, `surveyor_code`, `full_name`, `phone`, `area`, `signature_file_id`, `status`, `created_at`, `updated_at`, `deleted_at`) VALUES ('00000000-0000-0000-0000-000000000103','00000000-0000-0000-0000-000000000003','SVY-DEMO','Surveyor Demo',NULL,'Demo Area',NULL,'active','2026-07-01 14:30:22.051372','2026-07-01 14:30:22.051372',NULL);
/*!40000 ALTER TABLE `surveyor_profiles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `surveys`
--

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
  `status` varchar(50) NOT NULL DEFAULT 'draft',
  `survey_result` varchar(50) DEFAULT NULL,
  `system_recommendation_result` varchar(50) DEFAULT NULL,
  `started_at` datetime(6) DEFAULT NULL,
  `submitted_at` datetime(6) DEFAULT NULL,
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
  KEY `idx_surveys_container_type_active` (`job_container_id`,`survey_type_id`),
  KEY `idx_surveys_job` (`job_order_id`),
  KEY `idx_surveys_container` (`job_container_id`),
  KEY `idx_surveys_surveyor` (`surveyor_id`),
  KEY `idx_surveys_status` (`status`),
  KEY `idx_surveys_submitted_at` (`submitted_at`),
  KEY `fk_surveys_assignment` (`assignment_id`),
  KEY `fk_surveys_survey_type` (`survey_type_id`),
  CONSTRAINT `fk_surveys_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`),
  CONSTRAINT `fk_surveys_job_container` FOREIGN KEY (`job_container_id`) REFERENCES `job_containers` (`id`),
  CONSTRAINT `fk_surveys_job_order` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`id`),
  CONSTRAINT `fk_surveys_survey_type` FOREIGN KEY (`survey_type_id`) REFERENCES `survey_types` (`id`),
  CONSTRAINT `fk_surveys_surveyor` FOREIGN KEY (`surveyor_id`) REFERENCES `surveyor_profiles` (`id`)
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
INSERT INTO `user_roles` (`id`, `user_id`, `role_id`, `created_at`) VALUES ('3f418ea9-737f-11f1-ac50-002b67818c25','00000000-0000-0000-0000-000000000001','3f26a41f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.448821'),('b7ebacc3-751e-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000002','3f26b6a0-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:22.033497'),('b7ebbb17-751e-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000005','3f26bb58-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:22.033497'),('b7ebc0c6-751e-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000006','3f26bccb-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:22.033497'),('b7ebc781-751e-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000004','3f26ba11-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:22.033497'),('b7ebd074-751e-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000003','3f26b8df-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:22.033497');
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

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
INSERT INTO `users` (`id`, `name`, `email`, `username`, `password_hash`, `phone`, `avatar_file_id`, `status`, `last_login_at`, `password_changed_at`, `created_at`, `updated_at`, `deleted_at`) VALUES ('00000000-0000-0000-0000-000000000001','Super Admin Dev','superadmin@gift.local','superadmin','$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',NULL,NULL,'active','2026-07-03 10:03:17.132020','2026-06-29 05:56:18.000000','2026-06-29 05:56:18.440310','2026-07-03 10:03:17.132020',NULL),('00000000-0000-0000-0000-000000000002','Admin Demo','admin@gift.local','admin','$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',NULL,NULL,'active','2026-07-06 11:05:39.385988','2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622','2026-07-06 11:05:39.385988',NULL),('00000000-0000-0000-0000-000000000003','Surveyor Demo','surveyor@gift.local','surveyor','$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',NULL,NULL,'active',NULL,'2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622',NULL),('00000000-0000-0000-0000-000000000004','Supervisor Demo','supervisor@gift.local','supervisor','$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',NULL,NULL,'active',NULL,'2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622',NULL),('00000000-0000-0000-0000-000000000005','Finance Demo','finance@gift.local','finance','$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',NULL,NULL,'active',NULL,'2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622',NULL),('00000000-0000-0000-0000-000000000006','Management Demo','management@gift.local','management','$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',NULL,NULL,'active',NULL,'2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'kontainer_db'
--

--
-- Dumping routines for database 'kontainer_db'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-08 16:52:55
