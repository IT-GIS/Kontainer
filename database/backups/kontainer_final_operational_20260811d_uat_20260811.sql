-- MySQL dump 10.13  Distrib 8.4.3, for Win64 (x86_64)
--
-- Host: localhost    Database: kontainer_final_operational_20260811d_uat
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
  `active_job_container_id` char(36) GENERATED ALWAYS AS ((case when (`unassigned_at` is null) then `job_container_id` else NULL end)) STORED,
  PRIMARY KEY (`id`),
  UNIQUE KEY `assignment_id` (`assignment_id`,`job_container_id`),
  UNIQUE KEY `uq_assignment_containers_active_container` (`active_job_container_id`),
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
INSERT INTO `assignment_containers` (`id`, `assignment_id`, `job_container_id`, `assigned_at`, `unassigned_at`, `unassigned_reason`) VALUES ('01baf778-8652-11f1-a160-002b67818c25','de85f1b5-14b7-4233-972e-16800b5461de','c31da96a-53ce-4a1c-a194-c441fea1a43d','2026-07-23 11:50:19.966601',NULL,NULL),('0bdebf6a-8663-11f1-a160-002b67818c25','4a946427-7d4d-41ab-8a84-e8576c80801f','b517fda0-6324-4bbe-9d9e-4ac166232d53','2026-07-23 13:52:18.422727',NULL,NULL),('0bdf1bba-8663-11f1-a160-002b67818c25','4a946427-7d4d-41ab-8a84-e8576c80801f','fd058dbe-7585-43f8-bc5a-a96fc0c102cf','2026-07-23 13:52:18.425101',NULL,NULL),('17d168cb-8663-11f1-a160-002b67818c25','de3eeefb-9df3-465e-a137-0da41de4a3e9','d52f27a5-6060-41f6-aaad-a9d3deaa837b','2026-07-23 13:52:38.467952',NULL,NULL),('17d1b711-8663-11f1-a160-002b67818c25','de3eeefb-9df3-465e-a137-0da41de4a3e9','30956aa8-4a29-4628-b5a2-2d297cd4208e','2026-07-23 13:52:38.469979',NULL,NULL),('20ea8f11-9542-11f1-9595-002b67818c25','e2e00001-0000-4000-8000-000000000101','e2e00001-0000-4000-8000-000000000201','2026-08-11 12:04:27.781869',NULL,NULL),('20eac438-9542-11f1-9595-002b67818c25','e2e00001-0000-4000-8000-000000000101','e2e00001-0000-4000-8000-000000000202','2026-08-11 12:04:27.783242',NULL,NULL),('20eb3203-9542-11f1-9595-002b67818c25','e2e00002-0000-4000-8000-000000000101','e2e00002-0000-4000-8000-000000000201','2026-08-11 12:04:27.786051',NULL,NULL),('20ed6c77-9542-11f1-9595-002b67818c25','e2e00002-0000-4000-8000-000000000101','e2e00002-0000-4000-8000-000000000202','2026-08-11 12:04:27.800647',NULL,NULL),('20ef522e-9542-11f1-9595-002b67818c25','e2e00003-0000-4000-8000-000000000101','e2e00003-0000-4000-8000-000000000201','2026-08-11 12:04:27.813089',NULL,NULL),('20f134a7-9542-11f1-9595-002b67818c25','e2e00003-0000-4000-8000-000000000101','e2e00003-0000-4000-8000-000000000202','2026-08-11 12:04:27.825401',NULL,NULL),('20f3fc9b-9542-11f1-9595-002b67818c25','e2e00004-0000-4000-8000-000000000101','e2e00004-0000-4000-8000-000000000201','2026-08-11 12:04:27.843652',NULL,NULL),('397fb024-864e-11f1-a160-002b67818c25','14c3da84-9072-4fdd-a806-9f0dfe9d012f','37e74fda-ed4b-499a-a6a0-849adfeb99b7','2026-07-23 11:23:15.543632',NULL,NULL),('3c8df181-8652-11f1-a160-002b67818c25','77196b64-3748-429f-ad4f-083fdb122e61','82b50221-7114-4dce-8544-c0508885094b','2026-07-23 11:51:58.657127',NULL,NULL),('cc425d86-864c-11f1-a160-002b67818c25','0af0234c-cf48-4860-9b19-f9943b638a4f','ef3108a3-5d1e-4832-af0b-eb174edc0675','2026-07-23 11:13:02.773347',NULL,NULL);
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
INSERT INTO `assignments` VALUES ('0af0234c-cf48-4860-9b19-f9943b638a4f','GIFT-ASG-2026-000001','ba973397-9eee-4cf9-b987-9a2e4e727195','00000000-0000-0000-0000-000000000103','00000000-0000-0000-0000-000000000002','2026-07-23 11:13:02.757401',NULL,NULL,'UAT audit','in_progress',NULL,'2026-07-23 11:13:02.757401','2026-07-23 11:13:25.000000'),('14c3da84-9072-4fdd-a806-9f0dfe9d012f','GIFT-ASG-2026-000002','1b39e6d9-c766-41ae-bdfb-24b53e76eaa9','00000000-0000-0000-0000-000000000103','00000000-0000-0000-0000-000000000002','2026-07-23 11:23:15.542592',NULL,NULL,'UAT-ISO-CEDEX-20260723112314 synthetic reject','in_progress',NULL,'2026-07-23 11:23:15.542592','2026-07-23 11:23:15.000000'),('4a946427-7d4d-41ab-8a84-e8576c80801f','GIFT-ASG-2026-000005','daf62320-72ab-42ed-b509-dd6b0a2ba413','00000000-0000-0000-0000-000000000103','00000000-0000-0000-0000-000000000002','2026-07-23 13:52:18.418748','2026-07-23 07:00:00.000000','2026-07-30 07:00:00.000000','Assignment UAT','in_progress',NULL,'2026-07-23 13:52:18.418748','2026-07-23 13:52:18.000000'),('77196b64-3748-429f-ad4f-083fdb122e61','GIFT-ASG-2026-000004','e8438630-bfbf-4861-be6f-73611a3f479c','00000000-0000-0000-0000-000000000103','00000000-0000-0000-0000-000000000002','2026-07-23 11:51:58.655229',NULL,NULL,'UAT-ISO-CEDEX-20260723115158-DAMAGE','in_progress',NULL,'2026-07-23 11:51:58.655229','2026-07-23 11:51:58.000000'),('de3eeefb-9df3-465e-a137-0da41de4a3e9','GIFT-ASG-2026-000006','9cb28aad-c5f8-4a6e-93c6-7718905972fe','00000000-0000-0000-0000-000000000103','00000000-0000-0000-0000-000000000002','2026-07-23 13:52:38.465999','2026-07-23 07:00:00.000000','2026-07-30 07:00:00.000000','Assignment UAT','in_progress',NULL,'2026-07-23 13:52:38.465999','2026-07-23 13:52:38.000000'),('de85f1b5-14b7-4233-972e-16800b5461de','GIFT-ASG-2026-000003','4f3589d9-1d31-4063-bf92-06e06a966fc0','00000000-0000-0000-0000-000000000103','00000000-0000-0000-0000-000000000002','2026-07-23 11:50:19.961234',NULL,NULL,'UAT audit','assigned',NULL,'2026-07-23 11:50:19.961234','2026-07-23 11:50:19.961234'),('e2e00001-0000-4000-8000-000000000101','UAT-ASG-2026-0805-001','e2e00001-0000-4000-8000-000000000001','9ac88126-eacc-4256-8f8b-efd594725b10','16d75d68-b6c2-43de-97c6-ec099ae08ce0','2026-08-11 12:04:27.776285','2026-08-11 12:04:27.000000','2026-08-25 12:04:27.000000','Assignment UAT-REAL-CASE-2026-08','in_progress',NULL,'2026-08-11 12:04:27.776285','2026-08-11 12:09:16.000000'),('e2e00002-0000-4000-8000-000000000101','UAT-ASG-2026-0805-002','e2e00002-0000-4000-8000-000000000001','9ac88126-eacc-4256-8f8b-efd594725b10','16d75d68-b6c2-43de-97c6-ec099ae08ce0','2026-08-11 12:04:27.784971','2026-08-11 12:04:27.000000','2026-08-25 12:04:27.000000','Assignment UAT-REAL-CASE-2026-08','in_progress',NULL,'2026-08-11 12:04:27.784971','2026-08-11 12:04:27.784971'),('e2e00003-0000-4000-8000-000000000101','UAT-ASG-2026-0805-003','e2e00003-0000-4000-8000-000000000001','9ac88126-eacc-4256-8f8b-efd594725b10','16d75d68-b6c2-43de-97c6-ec099ae08ce0','2026-08-11 12:04:27.811594','2026-08-11 12:04:27.000000','2026-08-25 12:04:27.000000','Assignment UAT-REAL-CASE-2026-08','in_progress',NULL,'2026-08-11 12:04:27.811594','2026-08-11 12:04:27.811594'),('e2e00004-0000-4000-8000-000000000101','UAT-ASG-ISOLATION-001','e2e00004-0000-4000-8000-000000000001','47527587-fe0f-4b52-b87c-d3866beffbdf','16d75d68-b6c2-43de-97c6-ec099ae08ce0','2026-08-11 12:04:27.842992','2026-08-11 12:04:27.000000','2026-08-25 12:04:27.000000','UAT-REAL-CASE-2026-08','in_progress',NULL,'2026-08-11 12:04:27.842992','2026-08-11 12:04:27.842992');
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
INSERT INTO `audit_logs` VALUES ('00095a13-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'8fb80b8a08c38ff0ba7812b8694921a5','127.0.0.1','node','2026-07-23 13:51:58.569232'),('0019f3f8-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'fb289f46216f151373f6f9704b1c6e6d','127.0.0.1','node','2026-07-23 13:51:58.678056'),('00288c4a-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'020fd6148f645805cbe868964ce4741c','127.0.0.1','node','2026-07-23 13:51:58.773703'),('003691b0-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'2210e043e14996563bdd2ddb7f82a1c3','127.0.0.1','node','2026-07-23 13:51:58.865604'),('003a962c-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.create','customers','5581423d-c969-43b4-ba9b-b427ac1511ed',NULL,NULL,NULL,'{\"id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89518363@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:51:58Z\", \"customer_code\": \"UAT89518363\", \"customer_name\": \"UAT Admin Finalisasi 89518363\", \"billing_address\": null, \"payment_term_days\": 14}',NULL,'61e73ef4288568551719c5d72782ee4a','127.0.0.1','node','2026-07-23 13:51:58.889780'),('003d1804-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.create','customers','16473014-ae6c-4ee8-8f7f-a34cfc63ab3a',NULL,NULL,NULL,'{\"id\": \"16473014-ae6c-4ee8-8f7f-a34cfc63ab3a\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-iso-89518363@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:51:58Z\", \"customer_code\": \"U289518363\", \"customer_name\": \"UAT Isolation 89518363\", \"billing_address\": null, \"payment_term_days\": 14}',NULL,'4eefa02b68a69cb7bfea67f12e6b6ddd','127.0.0.1','node','2026-07-23 13:51:58.908346'),('00400900-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.update','customers','5581423d-c969-43b4-ba9b-b427ac1511ed',NULL,NULL,'{\"id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89518363@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:51:58Z\", \"customer_code\": \"UAT89518363\", \"customer_name\": \"UAT Admin Finalisasi 89518363\", \"billing_address\": null, \"payment_term_days\": 14}','{\"id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89518363@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:51:58Z\", \"customer_code\": \"UAT89518363\", \"customer_name\": \"UAT Admin Finalisasi 89518363\", \"billing_address\": \"Alamat penagihan UAT\", \"payment_term_days\": 14}',NULL,'dd2122498e5c88ef46083afc91ef9a93','127.0.0.1','node','2026-07-23 13:51:58.927611'),('00448a4a-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.create','customer_personnel','a3b99189-db38-4f31-a441-982d51f6199a',NULL,NULL,NULL,'{\"id\": \"a3b99189-db38-4f31-a441-982d51f6199a\", \"name\": \"Personel UAT\", \"email\": \"pic-89518363@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:51:58Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"personnel_code\": \"PIC89518363\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}',NULL,'3601009a805bf5de722c429d90420f79','127.0.0.1','node','2026-07-23 13:51:58.957130'),('0046f370-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.update','customer_personnel','a3b99189-db38-4f31-a441-982d51f6199a',NULL,NULL,'{\"id\": \"a3b99189-db38-4f31-a441-982d51f6199a\", \"name\": \"Personel UAT\", \"email\": \"pic-89518363@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:51:58Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"personnel_code\": \"PIC89518363\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}','{\"id\": \"a3b99189-db38-4f31-a441-982d51f6199a\", \"name\": \"Personel UAT\", \"email\": \"pic-89518363@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:51:58Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"personnel_code\": \"PIC89518363\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}',NULL,'11301ff56533fc6d1b82ec0e322317d5','127.0.0.1','node','2026-07-23 13:51:58.972922'),('0048d4c1-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.update','customer_personnel','a3b99189-db38-4f31-a441-982d51f6199a',NULL,NULL,'{\"id\": \"a3b99189-db38-4f31-a441-982d51f6199a\", \"name\": \"Personel UAT\", \"email\": \"pic-89518363@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:51:58Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"personnel_code\": \"PIC89518363\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}','{\"id\": \"a3b99189-db38-4f31-a441-982d51f6199a\", \"name\": \"Personel UAT\", \"email\": \"pic-89518363@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:51:58Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"personnel_code\": \"PIC89518363\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}',NULL,'df9b90cae91479c5a09a431afe0f06f7','127.0.0.1','node','2026-07-23 13:51:58.985269'),('004a923c-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.create','customer_personnel','0b831a5e-3726-4bf9-b034-3a8d9cb92f0e',NULL,NULL,NULL,'{\"id\": \"0b831a5e-3726-4bf9-b034-3a8d9cb92f0e\", \"name\": \"Personel UAT\", \"email\": \"pic2-89518363@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:51:58Z\", \"customer_id\": \"16473014-ae6c-4ee8-8f7f-a34cfc63ab3a\", \"personnel_code\": \"P289518363\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}',NULL,'f86e079d6943da83248e33ae2e7c21cd','127.0.0.1','node','2026-07-23 13:51:58.996684'),('004cd2bc-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','locations.create','locations','776399d2-3b5f-4235-bfa4-b884ae0d19e1',NULL,NULL,NULL,'{\"id\": \"776399d2-3b5f-4235-bfa4-b884ae0d19e1\", \"city\": \"Jakarta\", \"status\": \"active\", \"address\": \"Area uji lokal\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T06:51:59Z\", \"updated_at\": \"2026-07-23T06:51:59Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"L89518363\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"location_type\": \"depot\"}',NULL,'012c65467ae9ec45589181b6112a71aa','127.0.0.1','node','2026-07-23 13:51:59.011417'),('004f316c-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','locations.create','locations','2f624b63-93c7-43c4-8da0-047d1660e91f',NULL,NULL,NULL,'{\"id\": \"2f624b63-93c7-43c4-8da0-047d1660e91f\", \"city\": \"Jakarta\", \"status\": \"active\", \"address\": \"Area uji lokal\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T06:51:59Z\", \"updated_at\": \"2026-07-23T06:51:59Z\", \"customer_id\": \"16473014-ae6c-4ee8-8f7f-a34cfc63ab3a\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"L289518363\", \"location_name\": \"Lokasi Isolation UAT\", \"location_type\": \"depot\"}',NULL,'d9392bb9cf484d918914093f5fe2b2bd','127.0.0.1','node','2026-07-23 13:51:59.026963'),('0050d51e-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','container_types.create','container_types','380639b0-d41b-48f6-ac6a-b43f2cfbb732',NULL,NULL,NULL,'{\"id\": \"380639b0-d41b-48f6-ac6a-b43f2cfbb732\", \"code\": \"CT89518363\", \"size\": \"20\", \"type\": \"General Purpose UAT\", \"status\": \"active\", \"iso_code\": \"22G1\", \"created_at\": \"2026-07-23T06:51:59Z\", \"updated_at\": \"2026-07-23T06:51:59Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"description\": \"Data uji lokal\"}',NULL,'f001ea076ae16dcd85da63a316cb3313','127.0.0.1','node','2026-07-23 13:51:59.037716'),('0052a5df-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','survey_types.create','survey_types','f811c4a3-df8c-4ab7-af5a-fa4b736ca7df',NULL,NULL,NULL,'{\"id\": \"f811c4a3-df8c-4ab7-af5a-fa4b736ca7df\", \"code\": \"ST89518363\", \"name\": \"Survey UAT\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:51:59Z\", \"updated_at\": \"2026-07-23T06:51:59Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"description\": \"Data uji lokal\", \"requires_eir\": 0, \"requires_light_test\": 0, \"requires_cargo_worthy_result\": 1}',NULL,'aa0ce8505896bf2b493e483a35b0407e','127.0.0.1','node','2026-07-23 13:51:59.049605'),('00548e66-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_locations.create','cedex_locations','12eb4fe2-1254-47f2-90d2-7accbd156825',NULL,NULL,NULL,'{\"id\": \"12eb4fe2-1254-47f2-90d2-7accbd156825\", \"code\": \"CL89518363\", \"face\": \"left\", \"status\": \"active\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-23T06:51:59Z\", \"updated_at\": \"2026-07-23T06:51:59Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"description\": \"Lokasi UAT\", \"display_order\": 1, \"container_size\": \"20\", \"cedex_mapping_code\": \"M89518363\"}',NULL,'41df29a3320e4da4109447deff430b46','127.0.0.1','node','2026-07-23 13:51:59.062118'),('00565002-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_components.create','cedex_components','c402bede-d7f0-43ed-81be-1ecad86d4b27',NULL,NULL,NULL,'{\"id\": \"c402bede-d7f0-43ed-81be-1ecad86d4b27\", \"code\": \"CC89518363\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:51:59Z\", \"updated_at\": \"2026-07-23T06:51:59Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"description\": \"Data uji lokal\", \"component_name\": \"Component UAT\"}',NULL,'b0384b2d5b6c13a409ce1b67c9abfde9','127.0.0.1','node','2026-07-23 13:51:59.073613'),('0058228c-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_damages.create','cedex_damages','47c6fba5-7864-4b26-850a-6ca428902416',NULL,NULL,NULL,'{\"id\": \"47c6fba5-7864-4b26-850a-6ca428902416\", \"code\": \"CD89518363\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:51:59Z\", \"updated_at\": \"2026-07-23T06:51:59Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"damage_name\": \"Damage UAT\", \"description\": \"Data uji lokal\"}',NULL,'4275fa518e5c4e966403ae17fa1f6133','127.0.0.1','node','2026-07-23 13:51:59.085543'),('0059fa2e-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.create','cedex_repairs','85c941ce-e3f0-4d4b-a451-dad95ad5e971',NULL,NULL,NULL,'{\"id\": \"85c941ce-e3f0-4d4b-a451-dad95ad5e971\", \"code\": \"CR89518363\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:51:59Z\", \"updated_at\": \"2026-07-23T06:51:59Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}',NULL,'31f878ad7fc5bceda68c13c49f413377','127.0.0.1','node','2026-07-23 13:51:59.097637'),('005bd50e-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.update','cedex_repairs','85c941ce-e3f0-4d4b-a451-dad95ad5e971',NULL,NULL,'{\"id\": \"85c941ce-e3f0-4d4b-a451-dad95ad5e971\", \"code\": \"CR89518363\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:51:59Z\", \"updated_at\": \"2026-07-23T06:51:59Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}','{\"id\": \"85c941ce-e3f0-4d4b-a451-dad95ad5e971\", \"code\": \"CR89518363\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T06:51:59Z\", \"updated_at\": \"2026-07-23T06:51:59Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}',NULL,'61a8123a19b25a647a897ecded219a35','127.0.0.1','node','2026-07-23 13:51:59.109777'),('005db0dd-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.update','cedex_repairs','85c941ce-e3f0-4d4b-a451-dad95ad5e971',NULL,NULL,'{\"id\": \"85c941ce-e3f0-4d4b-a451-dad95ad5e971\", \"code\": \"CR89518363\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T06:51:59Z\", \"updated_at\": \"2026-07-23T06:51:59Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}','{\"id\": \"85c941ce-e3f0-4d4b-a451-dad95ad5e971\", \"code\": \"CR89518363\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:51:59Z\", \"updated_at\": \"2026-07-23T06:51:59Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}',NULL,'234281c65d5434ef041dab681f1fbbc2','127.0.0.1','node','2026-07-23 13:51:59.121918'),('00656e17-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_materials.create','cedex_materials','75e15d58-f90a-4e19-bf43-f85d9538d5b6',NULL,NULL,NULL,'{\"id\": \"75e15d58-f90a-4e19-bf43-f85d9538d5b6\", \"code\": \"CM89518363\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:51:59Z\", \"updated_at\": \"2026-07-23T06:51:59Z\", \"customer_id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"description\": \"Data uji lokal\", \"material_name\": \"Material UAT\"}',NULL,'d090964ac45aea568c263801a673ce00','127.0.0.1','node','2026-07-23 13:51:59.172692'),('00c5bf3a-8a6f-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'ddc36f517218a7d7058b2d913d286f55','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 17:27:58.415803'),('0148686a-8a5a-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'51f21bd90d6faf30a99a57809e630837','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 14:57:39.840415'),('01563234-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'a09eac4419e2c27e2892aa567b96dbb2','127.0.0.1',NULL,'2026-07-23 11:50:19.305588'),('0166b901-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.create','customers','42aee823-b9d1-4788-9fd6-cdce2cb732f8',NULL,NULL,NULL,'{\"id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"npwp\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_code\": \"UAT-ISO-CEDEX-20260723115019-A\", \"customer_name\": \"UAT ISO CEDEX UAT-ISO-CEDEX-20260723115019 Customer A\", \"billing_address\": null, \"payment_term_days\": null}',NULL,'827d09b2269692c365cba6a94fe422b2','127.0.0.1',NULL,'2026-07-23 11:50:19.414320'),('016870b9-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.create','customers','5d275989-b5f8-4f56-abb7-1e6cf8630449',NULL,NULL,NULL,'{\"id\": \"5d275989-b5f8-4f56-abb7-1e6cf8630449\", \"npwp\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_code\": \"UAT-ISO-CEDEX-20260723115019-B\", \"customer_name\": \"UAT ISO CEDEX UAT-ISO-CEDEX-20260723115019 Customer B\", \"billing_address\": null, \"payment_term_days\": null}',NULL,'18d59177899121dee1bc7e8358a2e1f5','127.0.0.1',NULL,'2026-07-23 11:50:19.425741'),('017065c2-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','locations.create','locations','e256852a-9e06-448e-bc45-2f2f35712069',NULL,NULL,NULL,'{\"id\": \"e256852a-9e06-448e-bc45-2f2f35712069\", \"city\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"LCUAT-ISO-CEDEX-20260723115019\", \"location_name\": \"UAT Location UAT-ISO-CEDEX-20260723115019\", \"location_type\": \"depot\"}',NULL,'2333bee149eb426b63e53eba00a987c5','127.0.0.1',NULL,'2026-07-23 11:50:19.477865'),('01721190-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','locations.create','locations','406e10ef-c678-406f-9da6-c6013120c832',NULL,NULL,NULL,'{\"id\": \"406e10ef-c678-406f-9da6-c6013120c832\", \"city\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"5d275989-b5f8-4f56-abb7-1e6cf8630449\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"LCUAT-ISO-CEDEX-20260723115019\", \"location_name\": \"UAT Location UAT-ISO-CEDEX-20260723115019\", \"location_type\": \"depot\"}',NULL,'04ef36ad05c0b134be1bdfa6b31a45c3','127.0.0.1',NULL,'2026-07-23 11:50:19.488821'),('0179958c-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.create','customer_personnel','aac61537-a165-4cd0-97e0-1a3a27fdad87',NULL,NULL,NULL,'{\"id\": \"aac61537-a165-4cd0-97e0-1a3a27fdad87\", \"name\": \"UAT Personel UAT-ISO-CEDEX-20260723115019\", \"email\": \"uat.uat-iso-cedex-20260723115019@example.test\", \"notes\": null, \"phone\": null, \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"personnel_code\": \"PICUAT-ISO-CEDEX-20260723115019\", \"personnel_type\": \"pic\", \"position_title\": \"PIC UAT\"}',NULL,'694f570deadf4c196048617691363f4f','127.0.0.1',NULL,'2026-07-23 11:50:19.538111'),('017b3515-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.create','customer_personnel','273b4f3e-fe58-4c0e-b5a5-61130ff4077d',NULL,NULL,NULL,'{\"id\": \"273b4f3e-fe58-4c0e-b5a5-61130ff4077d\", \"name\": \"UAT Personel UAT-ISO-CEDEX-20260723115019\", \"email\": \"uat.uat-iso-cedex-20260723115019@example.test\", \"notes\": null, \"phone\": null, \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"5d275989-b5f8-4f56-abb7-1e6cf8630449\", \"personnel_code\": \"PICUAT-ISO-CEDEX-20260723115019\", \"personnel_type\": \"pic\", \"position_title\": \"PIC UAT\"}',NULL,'14900ef966e26ff9f2969436ae10500b','127.0.0.1',NULL,'2026-07-23 11:50:19.548726'),('017f5b15-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','container_types.create','container_types','a9e4829b-c6d4-4fe0-b58b-ee05390713ac',NULL,NULL,NULL,'{\"id\": \"a9e4829b-c6d4-4fe0-b58b-ee05390713ac\", \"code\": \"CTUAT-ISO-CEDEX-20260723115019\", \"size\": \"20\", \"type\": \"Dry General\", \"status\": \"active\", \"iso_code\": \"22G1\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\"}',NULL,'f3286203e17d1403781bfc5aeebb3564','127.0.0.1',NULL,'2026-07-23 11:50:19.575938'),('01809c3a-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','container_types.create','container_types','1ff41f1c-0e68-44f3-b029-e6a4041d0790',NULL,NULL,NULL,'{\"id\": \"1ff41f1c-0e68-44f3-b029-e6a4041d0790\", \"code\": \"CTUAT-ISO-CEDEX-20260723115019\", \"size\": \"20\", \"type\": \"Dry General\", \"status\": \"active\", \"iso_code\": \"22G1\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"5d275989-b5f8-4f56-abb7-1e6cf8630449\", \"description\": \"UAT\"}',NULL,'893e31c33a97f8b3b59fe2dc614fbc59','127.0.0.1',NULL,'2026-07-23 11:50:19.584140'),('0184fe45-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','survey_types.create','survey_types','62581b70-cf5f-4d2b-b01e-e3367fb5493a',NULL,NULL,NULL,'{\"id\": \"62581b70-cf5f-4d2b-b01e-e3367fb5493a\", \"code\": \"STUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Survey UAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"requires_eir\": 0, \"requires_light_test\": 0, \"requires_cargo_worthy_result\": 0}',NULL,'82dcc47bd7462a3495268600a2e5223d','127.0.0.1',NULL,'2026-07-23 11:50:19.612860'),('01865c65-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','survey_types.create','survey_types','d0daeabd-1e41-4bd8-8666-09a8cb66a782',NULL,NULL,NULL,'{\"id\": \"d0daeabd-1e41-4bd8-8666-09a8cb66a782\", \"code\": \"STUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Survey UAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"5d275989-b5f8-4f56-abb7-1e6cf8630449\", \"description\": \"UAT\", \"requires_eir\": 0, \"requires_light_test\": 0, \"requires_cargo_worthy_result\": 0}',NULL,'0b5232e87e3730e785981818cb7096a1','127.0.0.1',NULL,'2026-07-23 11:50:19.621836'),('018adcbb-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_locations.create','cedex_locations','4a2a1e52-434d-4014-91a7-c5cb2851d826',NULL,NULL,NULL,'{\"id\": \"4a2a1e52-434d-4014-91a7-c5cb2851d826\", \"code\": \"CLUAT-ISO-CEDEX-20260723115019\", \"face\": \"left\", \"status\": \"active\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"display_order\": 999, \"container_size\": \"all\", \"cedex_mapping_code\": \"CLUAT-ISO-CEDEX-20260723115019\"}',NULL,'2b7b833a0639db47af59351ec400245e','127.0.0.1',NULL,'2026-07-23 11:50:19.651341'),('018c0c7e-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_locations.create','cedex_locations','f37cdf8b-142b-41f6-ba38-49495df609a9',NULL,NULL,NULL,'{\"id\": \"f37cdf8b-142b-41f6-ba38-49495df609a9\", \"code\": \"CLUAT-ISO-CEDEX-20260723115019\", \"face\": \"left\", \"status\": \"active\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"5d275989-b5f8-4f56-abb7-1e6cf8630449\", \"description\": \"UAT\", \"display_order\": 999, \"container_size\": \"all\", \"cedex_mapping_code\": \"CLUAT-ISO-CEDEX-20260723115019\"}',NULL,'31d4ee14d95806a7bbc6a9585420ebc7','127.0.0.1',NULL,'2026-07-23 11:50:19.659123'),('019029f7-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_components.create','cedex_components','68631952-439f-4c3f-8e9d-41834303e762',NULL,NULL,NULL,'{\"id\": \"68631952-439f-4c3f-8e9d-41834303e762\", \"code\": \"CCUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"component_name\": \"UAT Component UAT-ISO-CEDEX-20260723115019\"}',NULL,'e3c1bee58a9626b3add61ffdfa527b97','127.0.0.1',NULL,'2026-07-23 11:50:19.686091'),('01927061-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_components.create','cedex_components','c7401f89-12b7-4c74-a71e-f48dc1e879a3',NULL,NULL,NULL,'{\"id\": \"c7401f89-12b7-4c74-a71e-f48dc1e879a3\", \"code\": \"CCUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"5d275989-b5f8-4f56-abb7-1e6cf8630449\", \"description\": \"UAT\", \"component_name\": \"UAT Component UAT-ISO-CEDEX-20260723115019\"}',NULL,'e7607248b68f8279cd503c9ff4ad0da5','127.0.0.1',NULL,'2026-07-23 11:50:19.700977'),('0196c3af-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_damages.create','cedex_damages','ba52b394-9f86-4a31-a50d-baaf50b47f01',NULL,NULL,NULL,'{\"id\": \"ba52b394-9f86-4a31-a50d-baaf50b47f01\", \"code\": \"CDUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"damage_name\": \"UAT Damage UAT-ISO-CEDEX-20260723115019\", \"description\": \"UAT\"}',NULL,'6abff48c0000326be90fe4a1f36414d9','127.0.0.1',NULL,'2026-07-23 11:50:19.729347'),('0198252a-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_damages.create','cedex_damages','d32ea6ef-4bae-4625-b9b9-3dbba1d67514',NULL,NULL,NULL,'{\"id\": \"d32ea6ef-4bae-4625-b9b9-3dbba1d67514\", \"code\": \"CDUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"5d275989-b5f8-4f56-abb7-1e6cf8630449\", \"damage_name\": \"UAT Damage UAT-ISO-CEDEX-20260723115019\", \"description\": \"UAT\"}',NULL,'f223e1a8bcf9a36ae4b6254729099948','127.0.0.1',NULL,'2026-07-23 11:50:19.738402'),('019bd998-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.create','cedex_repairs','a246d224-9e03-4056-96fd-d33663dcaf11',NULL,NULL,NULL,'{\"id\": \"a246d224-9e03-4056-96fd-d33663dcaf11\", \"code\": \"CRUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"repair_name\": \"UAT Repair UAT-ISO-CEDEX-20260723115019\"}',NULL,'4fd6f37dfcbca949af4a0a98daf6b684','127.0.0.1',NULL,'2026-07-23 11:50:19.762676'),('019d3479-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.create','cedex_repairs','082f144a-d94a-4f8b-8c7f-6503ec258f1f',NULL,NULL,NULL,'{\"id\": \"082f144a-d94a-4f8b-8c7f-6503ec258f1f\", \"code\": \"CRUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"5d275989-b5f8-4f56-abb7-1e6cf8630449\", \"description\": \"UAT\", \"repair_name\": \"UAT Repair UAT-ISO-CEDEX-20260723115019\"}',NULL,'ba9e4d322905239bb4e9cf685ba3335e','127.0.0.1',NULL,'2026-07-23 11:50:19.771557'),('01a1005b-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_materials.create','cedex_materials','bdd643fb-ea2e-4db6-b523-df046fc80cf1',NULL,NULL,NULL,'{\"id\": \"bdd643fb-ea2e-4db6-b523-df046fc80cf1\", \"code\": \"CMUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"material_name\": \"UAT Material UAT-ISO-CEDEX-20260723115019\"}',NULL,'9802efb647fc12a7e6818143dda44eb2','127.0.0.1',NULL,'2026-07-23 11:50:19.796431'),('01a257f7-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_materials.create','cedex_materials','660863cf-8d29-4981-9652-1dc219e95260',NULL,NULL,NULL,'{\"id\": \"660863cf-8d29-4981-9652-1dc219e95260\", \"code\": \"CMUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"5d275989-b5f8-4f56-abb7-1e6cf8630449\", \"description\": \"UAT\", \"material_name\": \"UAT Material UAT-ISO-CEDEX-20260723115019\"}',NULL,'c17e65d04f6c72a383256d9d52f6203b','127.0.0.1',NULL,'2026-07-23 11:50:19.805239'),('01a5eaca-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','responsibility_codes.create','responsibility_codes','97b0c491-26b5-45d9-a79f-08b9aa304696',NULL,NULL,NULL,'{\"id\": \"97b0c491-26b5-45d9-a79f-08b9aa304696\", \"code\": \"RCUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Responsibility UAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\"}',NULL,'965e29dca7c18740848cb2d085f71cd0','127.0.0.1',NULL,'2026-07-23 11:50:19.828647'),('01a75bea-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','responsibility_codes.create','responsibility_codes','e080d7fe-ebfd-4496-9d0d-4ca247d52440',NULL,NULL,NULL,'{\"id\": \"e080d7fe-ebfd-4496-9d0d-4ca247d52440\", \"code\": \"RCUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Responsibility UAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"5d275989-b5f8-4f56-abb7-1e6cf8630449\", \"description\": \"UAT\"}',NULL,'ecfa2673e6d1d25594c1bde73bba6f2e','127.0.0.1',NULL,'2026-07-23 11:50:19.838102'),('01acdb9c-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','fitness_checklist_templates.create','fitness_checklist_templates','545482cc-7dba-40b4-8558-d33de2382d8d',NULL,NULL,NULL,'{\"id\": \"545482cc-7dba-40b4-8558-d33de2382d8d\", \"status\": \"draft\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"version_no\": 1, \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"template_code\": \"TPLUAT-ISO-CEDEX-20260723115019\", \"template_name\": \"UAT Checklist UAT-ISO-CEDEX-20260723115019\", \"survey_type_id\": \"62581b70-cf5f-4d2b-b01e-e3367fb5493a\", \"container_type_id\": \"a9e4829b-c6d4-4fe0-b58b-ee05390713ac\", \"survey_type_label\": \"STUAT-ISO-CEDEX-20260723115019 - UAT Survey UAT-ISO-CEDEX-20260723115019\", \"approval_category_id\": null, \"container_type_label\": \"CTUAT-ISO-CEDEX-20260723115019 - Dry General\", \"approval_category_label\": null}',NULL,'c69ea85eea610195be8c7219d1712397','127.0.0.1',NULL,'2026-07-23 11:50:19.874121'),('01b04032-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','fitness_checklist_template_items.create','fitness_checklist_template_items','79da1452-157f-4335-8780-a27115d270ae',NULL,NULL,NULL,'{\"id\": \"79da1452-157f-4335-8780-a27115d270ae\", \"status\": \"active\", \"item_code\": \"ITMUAT-ISO-CEDEX-20260723115019\", \"created_at\": \"2026-07-23T04:50:19Z\", \"item_label\": \"UAT Checklist Item UAT-ISO-CEDEX-20260723115019\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"description\": null, \"is_critical\": 0, \"is_required\": 1, \"template_id\": \"545482cc-7dba-40b4-8558-d33de2382d8d\", \"display_order\": 1, \"response_type\": \"ok_not_ok\", \"expected_value\": null, \"component_label\": null, \"fail_marks_unfit\": 0, \"test_parameter_id\": null, \"inspection_area_id\": null, \"fail_requires_repair\": 0, \"test_parameter_label\": null, \"inspection_area_label\": null, \"structural_component_id\": null}',NULL,'d8261bbe4d095c0d96b5c85e155ddf44','127.0.0.1',NULL,'2026-07-23 11:50:19.896359'),('01b35fbd-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','jobs.create','jobs','4f3589d9-1d31-4063-bf92-06e06a966fc0',NULL,NULL,NULL,'{\"id\": \"4f3589d9-1d31-4063-bf92-06e06a966fc0\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000005\"}',NULL,'381c017cdc2a2dc2e7cecc270e72b788','127.0.0.1',NULL,'2026-07-23 11:50:19.916856'),('01b7001e-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','job_containers.create','job_containers','c31da96a-53ce-4a1c-a194-c441fea1a43d',NULL,NULL,NULL,'{\"id\": \"c31da96a-53ce-4a1c-a194-c441fea1a43d\", \"status\": \"not_started\", \"container_no\": \"MSKU1234565\", \"check_digit_status\": \"valid\"}',NULL,'220907e2cfed8ba1aae8064305b5b4f5','127.0.0.1',NULL,'2026-07-23 11:50:19.940610'),('01bbbd1d-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','assignments.assign','assignments','de85f1b5-14b7-4233-972e-16800b5461de',NULL,NULL,NULL,'{\"id\": \"de85f1b5-14b7-4233-972e-16800b5461de\", \"status\": \"assigned\", \"due_date\": null, \"start_date\": null, \"instruction\": \"UAT audit\", \"assignment_no\": \"GIFT-ASG-2026-000003\", \"assigned_containers\": 1}',NULL,'9235edeea563bc35df3612bdf5dfe3f4','127.0.0.1',NULL,'2026-07-23 11:50:19.971676'),('01bdff00-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_components.create','cedex_components','65e70d98-eadb-4080-b2f8-80ab593d6434',NULL,NULL,NULL,'{\"id\": \"65e70d98-eadb-4080-b2f8-80ab593d6434\", \"code\": \"TCUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"component_name\": \"Tamper Route\"}',NULL,'fc5729f56a60daec069cb2686509c88e','127.0.0.1',NULL,'2026-07-23 11:50:19.986426'),('01ca6c66-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'cf422a2eb6ca38a1ad419370c7b97f99','127.0.0.1',NULL,'2026-07-23 11:50:20.067908'),('01d17504-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','inspection_test_parameters.create','inspection_test_parameters','c02838f6-4057-4e88-b203-65323eea97f9',NULL,NULL,NULL,'{\"id\": \"c02838f6-4057-4e88-b203-65323eea97f9\", \"code\": \"TPUAT-ISO-CEDEX-20260723115019\", \"unit\": null, \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:20Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"description\": \"UAT\", \"display_order\": 999, \"parameter_name\": \"UAT Parameter UAT-ISO-CEDEX-20260723115019\", \"standard_reference\": null, \"requires_attachment\": 0, \"requires_numeric_result\": 0, \"applies_to_new_container\": 1, \"applies_to_existing_container\": 1}',NULL,'0dd90057c330fd48913fd488e0138713','127.0.0.1',NULL,'2026-07-23 11:50:20.113825'),('01d32e0f-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','inspection_test_parameters.update','inspection_test_parameters','c02838f6-4057-4e88-b203-65323eea97f9',NULL,NULL,'{\"id\": \"c02838f6-4057-4e88-b203-65323eea97f9\", \"code\": \"TPUAT-ISO-CEDEX-20260723115019\", \"unit\": null, \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:20Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"description\": \"UAT\", \"display_order\": 999, \"parameter_name\": \"UAT Parameter UAT-ISO-CEDEX-20260723115019\", \"standard_reference\": null, \"requires_attachment\": 0, \"requires_numeric_result\": 0, \"applies_to_new_container\": 1, \"applies_to_existing_container\": 1}','{\"id\": \"c02838f6-4057-4e88-b203-65323eea97f9\", \"code\": \"TPUAT-ISO-CEDEX-20260723115019\", \"unit\": null, \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:50:20Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"description\": \"UAT\", \"display_order\": 999, \"parameter_name\": \"UAT Parameter UAT-ISO-CEDEX-20260723115019\", \"standard_reference\": null, \"requires_attachment\": 0, \"requires_numeric_result\": 0, \"applies_to_new_container\": 1, \"applies_to_existing_container\": 1}',NULL,'b777066f2c4092a2810627571892d890','127.0.0.1',NULL,'2026-07-23 11:50:20.125250'),('01d5f2c4-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','evidence_photo_categories.create','evidence_photo_categories','8b1b5b9a-dfb1-4758-8916-d27b45801ff0',NULL,NULL,NULL,'{\"id\": \"8b1b5b9a-dfb1-4758-8916-d27b45801ff0\", \"code\": \"PCUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Photo UAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"applies_to\": \"inspection\", \"created_at\": \"2026-07-23T04:50:20Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"description\": \"UAT\", \"display_order\": 999, \"is_required_default\": 0}',NULL,'ecb5c72ea9b76d831e28e3bf4890be80','127.0.0.1',NULL,'2026-07-23 11:50:20.143409'),('01d7898c-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','evidence_photo_categories.update','evidence_photo_categories','8b1b5b9a-dfb1-4758-8916-d27b45801ff0',NULL,NULL,'{\"id\": \"8b1b5b9a-dfb1-4758-8916-d27b45801ff0\", \"code\": \"PCUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Photo UAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"applies_to\": \"inspection\", \"created_at\": \"2026-07-23T04:50:20Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"description\": \"UAT\", \"display_order\": 999, \"is_required_default\": 0}','{\"id\": \"8b1b5b9a-dfb1-4758-8916-d27b45801ff0\", \"code\": \"PCUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Photo UAT-ISO-CEDEX-20260723115019\", \"status\": \"inactive\", \"applies_to\": \"inspection\", \"created_at\": \"2026-07-23T04:50:20Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"description\": \"UAT\", \"display_order\": 999, \"is_required_default\": 0}',NULL,'6f4e046c72cd9a833e6165406d12aacc','127.0.0.1',NULL,'2026-07-23 11:50:20.153833'),('01da03e2-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','finding_severities.create','finding_severities','d981b0ce-416c-498d-8b94-eebbb0bc34eb',NULL,NULL,NULL,'{\"id\": \"d981b0ce-416c-498d-8b94-eebbb0bc34eb\", \"code\": \"FSUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Severity UAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"level_no\": 99, \"badge_tone\": \"neutral\", \"created_at\": \"2026-07-23T04:50:20Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"description\": \"UAT\", \"affects_fitness_default\": 0, \"requires_supervisor_review\": 0}',NULL,'1a6cee1298fca1184ff9fa9767f77798','127.0.0.1',NULL,'2026-07-23 11:50:20.170082'),('01db7968-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','finding_severities.update','finding_severities','d981b0ce-416c-498d-8b94-eebbb0bc34eb',NULL,NULL,'{\"id\": \"d981b0ce-416c-498d-8b94-eebbb0bc34eb\", \"code\": \"FSUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Severity UAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"level_no\": 99, \"badge_tone\": \"neutral\", \"created_at\": \"2026-07-23T04:50:20Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"description\": \"UAT\", \"affects_fitness_default\": 0, \"requires_supervisor_review\": 0}','{\"id\": \"d981b0ce-416c-498d-8b94-eebbb0bc34eb\", \"code\": \"FSUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Severity UAT-ISO-CEDEX-20260723115019\", \"status\": \"inactive\", \"level_no\": 99, \"badge_tone\": \"neutral\", \"created_at\": \"2026-07-23T04:50:20Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"description\": \"UAT\", \"affects_fitness_default\": 0, \"requires_supervisor_review\": 0}',NULL,'50c115b4ee0b54f8cd4943436fa35f95','127.0.0.1',NULL,'2026-07-23 11:50:20.179623'),('01df2113-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_components.update','cedex_components','68631952-439f-4c3f-8e9d-41834303e762',NULL,NULL,'{\"id\": \"68631952-439f-4c3f-8e9d-41834303e762\", \"code\": \"CCUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"component_name\": \"UAT Component UAT-ISO-CEDEX-20260723115019\"}','{\"id\": \"68631952-439f-4c3f-8e9d-41834303e762\", \"code\": \"CCUAT-ISO-CEDEX-20260723115019\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"component_name\": \"UAT Component UAT-ISO-CEDEX-20260723115019\"}',NULL,'1d16485ca65e98301f0bfee545b409d3','127.0.0.1',NULL,'2026-07-23 11:50:20.203567'),('01e19617-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','fitness_checklist_templates.update','fitness_checklist_templates','545482cc-7dba-40b4-8558-d33de2382d8d',NULL,NULL,'{\"id\": \"545482cc-7dba-40b4-8558-d33de2382d8d\", \"status\": \"draft\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"version_no\": 1, \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"template_code\": \"TPLUAT-ISO-CEDEX-20260723115019\", \"template_name\": \"UAT Checklist UAT-ISO-CEDEX-20260723115019\", \"survey_type_id\": \"62581b70-cf5f-4d2b-b01e-e3367fb5493a\", \"container_type_id\": \"a9e4829b-c6d4-4fe0-b58b-ee05390713ac\", \"survey_type_label\": \"STUAT-ISO-CEDEX-20260723115019 - UAT Survey UAT-ISO-CEDEX-20260723115019\", \"approval_category_id\": null, \"container_type_label\": \"CTUAT-ISO-CEDEX-20260723115019 - Dry General\", \"approval_category_label\": null}','{\"id\": \"545482cc-7dba-40b4-8558-d33de2382d8d\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"version_no\": 1, \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"template_code\": \"TPLUAT-ISO-CEDEX-20260723115019\", \"template_name\": \"UAT Checklist UAT-ISO-CEDEX-20260723115019\", \"survey_type_id\": \"62581b70-cf5f-4d2b-b01e-e3367fb5493a\", \"container_type_id\": \"a9e4829b-c6d4-4fe0-b58b-ee05390713ac\", \"survey_type_label\": \"STUAT-ISO-CEDEX-20260723115019 - UAT Survey UAT-ISO-CEDEX-20260723115019\", \"approval_category_id\": null, \"container_type_label\": \"CTUAT-ISO-CEDEX-20260723115019 - Dry General\", \"approval_category_label\": null}',NULL,'b9a55b61fdb75e087ce05c3b58ef7aab','127.0.0.1',NULL,'2026-07-23 11:50:20.219605'),('01e34ff2-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','container_types.update','container_types','a9e4829b-c6d4-4fe0-b58b-ee05390713ac',NULL,NULL,'{\"id\": \"a9e4829b-c6d4-4fe0-b58b-ee05390713ac\", \"code\": \"CTUAT-ISO-CEDEX-20260723115019\", \"size\": \"20\", \"type\": \"Dry General\", \"status\": \"active\", \"iso_code\": \"22G1\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\"}','{\"id\": \"a9e4829b-c6d4-4fe0-b58b-ee05390713ac\", \"code\": \"CTUAT-ISO-CEDEX-20260723115019\", \"size\": \"20\", \"type\": \"Dry General\", \"status\": \"inactive\", \"iso_code\": \"22G1\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\"}',NULL,'ee273e1d92d818b4d2716af78081eb68','127.0.0.1',NULL,'2026-07-23 11:50:20.230961'),('01e560ef-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','responsibility_codes.update','responsibility_codes','97b0c491-26b5-45d9-a79f-08b9aa304696',NULL,NULL,'{\"id\": \"97b0c491-26b5-45d9-a79f-08b9aa304696\", \"code\": \"RCUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Responsibility UAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\"}','{\"id\": \"97b0c491-26b5-45d9-a79f-08b9aa304696\", \"code\": \"RCUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Responsibility UAT-ISO-CEDEX-20260723115019\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\"}',NULL,'6cc1cd5308c905210065376316888440','127.0.0.1',NULL,'2026-07-23 11:50:20.244547'),('01e6e0bd-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','survey_types.update','survey_types','62581b70-cf5f-4d2b-b01e-e3367fb5493a',NULL,NULL,'{\"id\": \"62581b70-cf5f-4d2b-b01e-e3367fb5493a\", \"code\": \"STUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Survey UAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"requires_eir\": 0, \"requires_light_test\": 0, \"requires_cargo_worthy_result\": 0}','{\"id\": \"62581b70-cf5f-4d2b-b01e-e3367fb5493a\", \"code\": \"STUAT-ISO-CEDEX-20260723115019\", \"name\": \"UAT Survey UAT-ISO-CEDEX-20260723115019\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"requires_eir\": 0, \"requires_light_test\": 0, \"requires_cargo_worthy_result\": 0}',NULL,'d6c51bae62a91967be5b73079d894cc8','127.0.0.1',NULL,'2026-07-23 11:50:20.254358'),('01e85028-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_locations.update','cedex_locations','4a2a1e52-434d-4014-91a7-c5cb2851d826',NULL,NULL,'{\"id\": \"4a2a1e52-434d-4014-91a7-c5cb2851d826\", \"code\": \"CLUAT-ISO-CEDEX-20260723115019\", \"face\": \"left\", \"status\": \"active\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"display_order\": 999, \"container_size\": \"all\", \"cedex_mapping_code\": \"CLUAT-ISO-CEDEX-20260723115019\"}','{\"id\": \"4a2a1e52-434d-4014-91a7-c5cb2851d826\", \"code\": \"CLUAT-ISO-CEDEX-20260723115019\", \"face\": \"left\", \"status\": \"inactive\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"display_order\": 999, \"container_size\": \"all\", \"cedex_mapping_code\": \"CLUAT-ISO-CEDEX-20260723115019\"}',NULL,'b2842a1c0688f3e0fc5559d256f25f96','127.0.0.1',NULL,'2026-07-23 11:50:20.263713'),('01e9e8a6-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_damages.update','cedex_damages','ba52b394-9f86-4a31-a50d-baaf50b47f01',NULL,NULL,'{\"id\": \"ba52b394-9f86-4a31-a50d-baaf50b47f01\", \"code\": \"CDUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"damage_name\": \"UAT Damage UAT-ISO-CEDEX-20260723115019\", \"description\": \"UAT\"}','{\"id\": \"ba52b394-9f86-4a31-a50d-baaf50b47f01\", \"code\": \"CDUAT-ISO-CEDEX-20260723115019\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"damage_name\": \"UAT Damage UAT-ISO-CEDEX-20260723115019\", \"description\": \"UAT\"}',NULL,'2f387cc57461ac1f39d77d2d7ac41d27','127.0.0.1',NULL,'2026-07-23 11:50:20.274230'),('01ebaf45-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.update','cedex_repairs','a246d224-9e03-4056-96fd-d33663dcaf11',NULL,NULL,'{\"id\": \"a246d224-9e03-4056-96fd-d33663dcaf11\", \"code\": \"CRUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"repair_name\": \"UAT Repair UAT-ISO-CEDEX-20260723115019\"}','{\"id\": \"a246d224-9e03-4056-96fd-d33663dcaf11\", \"code\": \"CRUAT-ISO-CEDEX-20260723115019\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"repair_name\": \"UAT Repair UAT-ISO-CEDEX-20260723115019\"}',NULL,'99b3eaf79071a37c03c27fa399de28b7','127.0.0.1',NULL,'2026-07-23 11:50:20.285878'),('01ee652a-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','locations.update','locations','e256852a-9e06-448e-bc45-2f2f35712069',NULL,NULL,'{\"id\": \"e256852a-9e06-448e-bc45-2f2f35712069\", \"city\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"LCUAT-ISO-CEDEX-20260723115019\", \"location_name\": \"UAT Location UAT-ISO-CEDEX-20260723115019\", \"location_type\": \"depot\"}','{\"id\": \"e256852a-9e06-448e-bc45-2f2f35712069\", \"city\": null, \"status\": \"inactive\", \"address\": \"UAT only\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"LCUAT-ISO-CEDEX-20260723115019\", \"location_name\": \"UAT Location UAT-ISO-CEDEX-20260723115019\", \"location_type\": \"depot\"}',NULL,'44e423709b2fb4a1dc5e0f46563c26b0','127.0.0.1',NULL,'2026-07-23 11:50:20.303625'),('01f02f56-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.update','customer_personnel','aac61537-a165-4cd0-97e0-1a3a27fdad87',NULL,NULL,'{\"id\": \"aac61537-a165-4cd0-97e0-1a3a27fdad87\", \"name\": \"UAT Personel UAT-ISO-CEDEX-20260723115019\", \"email\": \"uat.uat-iso-cedex-20260723115019@example.test\", \"notes\": null, \"phone\": null, \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"personnel_code\": \"PICUAT-ISO-CEDEX-20260723115019\", \"personnel_type\": \"pic\", \"position_title\": \"PIC UAT\"}','{\"id\": \"aac61537-a165-4cd0-97e0-1a3a27fdad87\", \"name\": \"UAT Personel UAT-ISO-CEDEX-20260723115019\", \"email\": \"uat.uat-iso-cedex-20260723115019@example.test\", \"notes\": null, \"phone\": null, \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"personnel_code\": \"PICUAT-ISO-CEDEX-20260723115019\", \"personnel_type\": \"pic\", \"position_title\": \"PIC UAT\"}',NULL,'c1274f37ba0a1cb71c6245039da742a2','127.0.0.1',NULL,'2026-07-23 11:50:20.315350'),('01f1cd37-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_materials.update','cedex_materials','bdd643fb-ea2e-4db6-b523-df046fc80cf1',NULL,NULL,'{\"id\": \"bdd643fb-ea2e-4db6-b523-df046fc80cf1\", \"code\": \"CMUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"material_name\": \"UAT Material UAT-ISO-CEDEX-20260723115019\"}','{\"id\": \"bdd643fb-ea2e-4db6-b523-df046fc80cf1\", \"code\": \"CMUAT-ISO-CEDEX-20260723115019\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"material_name\": \"UAT Material UAT-ISO-CEDEX-20260723115019\"}',NULL,'15e2177d8ff2b6f6c590649967267d10','127.0.0.1',NULL,'2026-07-23 11:50:20.325961'),('01f3b0d9-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_components.update','cedex_components','65e70d98-eadb-4080-b2f8-80ab593d6434',NULL,NULL,'{\"id\": \"65e70d98-eadb-4080-b2f8-80ab593d6434\", \"code\": \"TCUAT-ISO-CEDEX-20260723115019\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"component_name\": \"Tamper Route\"}','{\"id\": \"65e70d98-eadb-4080-b2f8-80ab593d6434\", \"code\": \"TCUAT-ISO-CEDEX-20260723115019\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"customer_id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"description\": \"UAT\", \"component_name\": \"Tamper Route\"}',NULL,'c5db937b24c534ea5990621997926eff','127.0.0.1',NULL,'2026-07-23 11:50:20.338335'),('01f5379e-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.update','customers','42aee823-b9d1-4788-9fd6-cdce2cb732f8',NULL,NULL,'{\"id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"npwp\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_code\": \"UAT-ISO-CEDEX-20260723115019-A\", \"customer_name\": \"UAT ISO CEDEX UAT-ISO-CEDEX-20260723115019 Customer A\", \"billing_address\": null, \"payment_term_days\": null}','{\"id\": \"42aee823-b9d1-4788-9fd6-cdce2cb732f8\", \"npwp\": null, \"status\": \"inactive\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"customer_code\": \"UAT-ISO-CEDEX-20260723115019-A\", \"customer_name\": \"UAT ISO CEDEX UAT-ISO-CEDEX-20260723115019 Customer A\", \"billing_address\": null, \"payment_term_days\": null}',NULL,'3d8e63e69e7eea0796b7c86047cc40ee','127.0.0.1',NULL,'2026-07-23 11:50:20.348323'),('01f6a613-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.update','customers','5d275989-b5f8-4f56-abb7-1e6cf8630449',NULL,NULL,'{\"id\": \"5d275989-b5f8-4f56-abb7-1e6cf8630449\", \"npwp\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:19Z\", \"customer_code\": \"UAT-ISO-CEDEX-20260723115019-B\", \"customer_name\": \"UAT ISO CEDEX UAT-ISO-CEDEX-20260723115019 Customer B\", \"billing_address\": null, \"payment_term_days\": null}','{\"id\": \"5d275989-b5f8-4f56-abb7-1e6cf8630449\", \"npwp\": null, \"status\": \"inactive\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:50:19Z\", \"updated_at\": \"2026-07-23T04:50:20Z\", \"customer_code\": \"UAT-ISO-CEDEX-20260723115019-B\", \"customer_name\": \"UAT ISO CEDEX UAT-ISO-CEDEX-20260723115019 Customer B\", \"billing_address\": null, \"payment_term_days\": null}',NULL,'b2f92adc4a69f9328a34828f600675b6','127.0.0.1',NULL,'2026-07-23 11:50:20.357726'),('039b0722-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'78491612eaec0c16a527ec0bb1a37dad','127.0.0.1',NULL,'2026-07-23 11:21:45.125825'),('03aedb20-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'086c0e69dcf054eafcbb8051057a51c7','127.0.0.1',NULL,'2026-07-23 11:21:45.255756'),('03ba18f5-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'54d8becd46acebb04ee04c9038306d66','127.0.0.1',NULL,'2026-07-23 11:21:45.329430'),('03f3c70f-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.update_general','surveys','293e4859-83eb-4e36-9ab5-48fbe2f33bbf',NULL,NULL,'{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"started_at\": \"2026-07-23T04:13:25Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"MSKU1234565\", \"final_remark\": null, \"job_deadline\": null, \"job_order_id\": \"ba973397-9eee-4cf9-b987-9a2e4e727195\", \"job_order_no\": \"GIFT-JO-2026-000002\", \"submitted_at\": null, \"customer_code\": \"UAT-CUST-17B\", \"customer_name\": \"UAT Customer Scope 17B\", \"iso_type_code\": \"22G1\", \"location_code\": \"LOC-17B\", \"location_name\": \"Depot UAT 17B\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_instruction\": \"UAT fix verification\", \"job_container_id\": \"ef3108a3-5d1e-4832-af0b-eb174edc0675\", \"survey_type_code\": \"SV-17B\", \"survey_type_name\": \"Survey UAT 17B\", \"assignment_due_at\": null, \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"container_type_code\": \"CT-17B\", \"container_type_name\": \"Dry UAT\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"assignment_instruction\": \"UAT audit\"}','{\"id\": \"d9f784d4-864c-11f1-a160-002b67818c25\", \"seal_no\": \"UAT-ISO-CEDEX-SEAL\", \"survey_id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"cargo_status\": \"empty\", \"survey_date_time\": \"2026-07-23T04:21:45Z\", \"general_condition\": \"good\"}',NULL,'100ab32d40967f3e91acd574c8084951','127.0.0.1',NULL,'2026-07-23 11:21:45.707398'),('03f8626f-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.update_checklist','surveys','293e4859-83eb-4e36-9ab5-48fbe2f33bbf',NULL,NULL,'{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"started_at\": \"2026-07-23T04:13:25Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"MSKU1234565\", \"final_remark\": null, \"job_deadline\": null, \"job_order_id\": \"ba973397-9eee-4cf9-b987-9a2e4e727195\", \"job_order_no\": \"GIFT-JO-2026-000002\", \"submitted_at\": null, \"customer_code\": \"UAT-CUST-17B\", \"customer_name\": \"UAT Customer Scope 17B\", \"iso_type_code\": \"22G1\", \"location_code\": \"LOC-17B\", \"location_name\": \"Depot UAT 17B\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_instruction\": \"UAT fix verification\", \"job_container_id\": \"ef3108a3-5d1e-4832-af0b-eb174edc0675\", \"survey_type_code\": \"SV-17B\", \"survey_type_name\": \"Survey UAT 17B\", \"assignment_due_at\": null, \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"container_type_code\": \"CT-17B\", \"container_type_name\": \"Dry UAT\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"assignment_instruction\": \"UAT audit\"}','{\"survey_id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"total_items\": 1, \"completed_items\": 1}',NULL,'4d7acc4a24f43ccc4932f35aea48676c','127.0.0.1',NULL,'2026-07-23 11:21:45.737579'),('04080170-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.submit','surveys','293e4859-83eb-4e36-9ab5-48fbe2f33bbf',NULL,NULL,'{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"started_at\": \"2026-07-23T04:13:25Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"MSKU1234565\", \"final_remark\": null, \"job_deadline\": null, \"job_order_id\": \"ba973397-9eee-4cf9-b987-9a2e4e727195\", \"job_order_no\": \"GIFT-JO-2026-000002\", \"submitted_at\": null, \"customer_code\": \"UAT-CUST-17B\", \"customer_name\": \"UAT Customer Scope 17B\", \"iso_type_code\": \"22G1\", \"location_code\": \"LOC-17B\", \"location_name\": \"Depot UAT 17B\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_instruction\": \"UAT fix verification\", \"job_container_id\": \"ef3108a3-5d1e-4832-af0b-eb174edc0675\", \"survey_type_code\": \"SV-17B\", \"survey_type_name\": \"Survey UAT 17B\", \"assignment_due_at\": null, \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"container_type_code\": \"CT-17B\", \"container_type_name\": \"Dry UAT\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"assignment_instruction\": \"UAT audit\"}','{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"submitted_at\": \"2026-07-23T04:21:45Z\"}',NULL,'cfad9fcae5590c6af7478d1b9ca09194','127.0.0.1',NULL,'2026-07-23 11:21:45.839915'),('040fd33d-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','reviews.need_revision','surveys','293e4859-83eb-4e36-9ab5-48fbe2f33bbf',NULL,NULL,'{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"approved_at\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"MSKU1234565\", \"job_order_id\": \"ba973397-9eee-4cf9-b987-9a2e4e727195\", \"job_order_no\": \"GIFT-JO-2026-000002\", \"submitted_at\": \"2026-07-23T04:21:45Z\", \"customer_name\": \"UAT Customer Scope 17B\", \"location_name\": \"Depot UAT 17B\", \"survey_result\": \"sound\", \"surveyor_name\": \"Surveyor Demo\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_container_id\": \"ef3108a3-5d1e-4832-af0b-eb174edc0675\", \"survey_type_name\": \"Survey UAT 17B\", \"current_revision_no\": 0}','{\"status\": \"need_revision\", \"survey_id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"revision_note\": \"UAT ISO CEDEX synthetic need revision\"}',NULL,'81810dd1f9672e32d523f5f3398d5bec','127.0.0.1',NULL,'2026-07-23 11:21:45.891220'),('04fbbcbd-751c-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.logout','auth',NULL,NULL,NULL,NULL,NULL,NULL,'c17c26b3f4fad014bd80ef27c5fb37cb','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:11:02.833630'),('09ba0902-751c-11f1-8fe5-002b67818c25',NULL,NULL,'auth.login_failed','auth',NULL,NULL,NULL,NULL,NULL,NULL,'ba727dae07d485fb644983aa928e6086','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:11:10.791673'),('0b68848c-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'0e47872a9b86b630e8b8b03f09af5b76','127.0.0.1','node','2026-07-23 13:52:17.647881'),('0b7758a8-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'00b51f102677bd821a4c712689b683ff','127.0.0.1','node','2026-07-23 13:52:17.745030'),('0b851157-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'a45b8bd14d48514f1775687a5e32b559','127.0.0.1','node','2026-07-23 13:52:17.834993'),('0b92c4c6-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'c1da6696e23988e80ca6e8a0e72dd09f','127.0.0.1','node','2026-07-23 13:52:17.924783'),('0b94c7a0-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.create','customers','cd0c0678-86f8-4f29-a44b-db12a4e481ec',NULL,NULL,NULL,'{\"id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89537506@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:17Z\", \"updated_at\": \"2026-07-23T06:52:17Z\", \"customer_code\": \"UAT89537506\", \"customer_name\": \"UAT Admin Finalisasi 89537506\", \"billing_address\": null, \"payment_term_days\": 14}',NULL,'a08aa22942abf97cffa3d6496d155b51','127.0.0.1','node','2026-07-23 13:52:17.937946'),('0b967beb-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.create','customers','af4d13f9-693e-4ded-8009-a43ef878741a',NULL,NULL,NULL,'{\"id\": \"af4d13f9-693e-4ded-8009-a43ef878741a\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-iso-89537506@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:17Z\", \"updated_at\": \"2026-07-23T06:52:17Z\", \"customer_code\": \"U289537506\", \"customer_name\": \"UAT Isolation 89537506\", \"billing_address\": null, \"payment_term_days\": 14}',NULL,'826a6996dde40b1276c3e19be281305b','127.0.0.1','node','2026-07-23 13:52:17.949113'),('0b98a96f-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.update','customers','cd0c0678-86f8-4f29-a44b-db12a4e481ec',NULL,NULL,'{\"id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89537506@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:17Z\", \"updated_at\": \"2026-07-23T06:52:17Z\", \"customer_code\": \"UAT89537506\", \"customer_name\": \"UAT Admin Finalisasi 89537506\", \"billing_address\": null, \"payment_term_days\": 14}','{\"id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89537506@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:17Z\", \"updated_at\": \"2026-07-23T06:52:17Z\", \"customer_code\": \"UAT89537506\", \"customer_name\": \"UAT Admin Finalisasi 89537506\", \"billing_address\": \"Alamat penagihan UAT\", \"payment_term_days\": 14}',NULL,'4e7fcd5125ea62371b7345bc3fb5fbec','127.0.0.1','node','2026-07-23 13:52:17.963348'),('0b9beae5-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.create','customer_personnel','58c6bdc2-6922-4cbe-beac-93c26a94659b',NULL,NULL,NULL,'{\"id\": \"58c6bdc2-6922-4cbe-beac-93c26a94659b\", \"name\": \"Personel UAT\", \"email\": \"pic-89537506@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:17Z\", \"updated_at\": \"2026-07-23T06:52:17Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"personnel_code\": \"PIC89537506\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}',NULL,'89396b55adc583de890a6a2f2685b00d','127.0.0.1','node','2026-07-23 13:52:17.984721'),('0b9e0f63-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.update','customer_personnel','58c6bdc2-6922-4cbe-beac-93c26a94659b',NULL,NULL,'{\"id\": \"58c6bdc2-6922-4cbe-beac-93c26a94659b\", \"name\": \"Personel UAT\", \"email\": \"pic-89537506@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:17Z\", \"updated_at\": \"2026-07-23T06:52:17Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"personnel_code\": \"PIC89537506\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}','{\"id\": \"58c6bdc2-6922-4cbe-beac-93c26a94659b\", \"name\": \"Personel UAT\", \"email\": \"pic-89537506@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T06:52:17Z\", \"updated_at\": \"2026-07-23T06:52:17Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"personnel_code\": \"PIC89537506\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}',NULL,'b6403dda4ca9d38e60a0fba6ba2e5d7f','127.0.0.1','node','2026-07-23 13:52:17.998753'),('0ba01686-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.update','customer_personnel','58c6bdc2-6922-4cbe-beac-93c26a94659b',NULL,NULL,'{\"id\": \"58c6bdc2-6922-4cbe-beac-93c26a94659b\", \"name\": \"Personel UAT\", \"email\": \"pic-89537506@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T06:52:17Z\", \"updated_at\": \"2026-07-23T06:52:17Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"personnel_code\": \"PIC89537506\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}','{\"id\": \"58c6bdc2-6922-4cbe-beac-93c26a94659b\", \"name\": \"Personel UAT\", \"email\": \"pic-89537506@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:17Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"personnel_code\": \"PIC89537506\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}',NULL,'310094e193daaaad1b81bcda64989762','127.0.0.1','node','2026-07-23 13:52:18.011986'),('0ba1e47e-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.create','customer_personnel','19316e14-bbe4-4ff5-b25d-d6f2ab1e22e9',NULL,NULL,NULL,'{\"id\": \"19316e14-bbe4-4ff5-b25d-d6f2ab1e22e9\", \"name\": \"Personel UAT\", \"email\": \"pic2-89537506@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"af4d13f9-693e-4ded-8009-a43ef878741a\", \"personnel_code\": \"P289537506\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}',NULL,'02e6f9d62dcaf6d49905c02322f70526','127.0.0.1','node','2026-07-23 13:52:18.023888'),('0ba376a9-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','locations.create','locations','a55a583c-7dbf-4e18-b255-f41c5d82e445',NULL,NULL,NULL,'{\"id\": \"a55a583c-7dbf-4e18-b255-f41c5d82e445\", \"city\": \"Jakarta\", \"status\": \"active\", \"address\": \"Area uji lokal\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"L89537506\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"location_type\": \"depot\"}',NULL,'0253b13c9c130b3be4eae96b53e5758c','127.0.0.1','node','2026-07-23 13:52:18.034168'),('0ba4ffb7-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','locations.create','locations','0ae32257-a243-4690-a780-5c55a9a15735',NULL,NULL,NULL,'{\"id\": \"0ae32257-a243-4690-a780-5c55a9a15735\", \"city\": \"Jakarta\", \"status\": \"active\", \"address\": \"Area uji lokal\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"af4d13f9-693e-4ded-8009-a43ef878741a\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"L289537506\", \"location_name\": \"Lokasi Isolation UAT\", \"location_type\": \"depot\"}',NULL,'f283ce5d99699e049e00f49c82964f69','127.0.0.1','node','2026-07-23 13:52:18.044195'),('0ba6d987-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','container_types.create','container_types','a49affc2-b9d4-497d-a617-d25fd1d68300',NULL,NULL,NULL,'{\"id\": \"a49affc2-b9d4-497d-a617-d25fd1d68300\", \"code\": \"CT89537506\", \"size\": \"20\", \"type\": \"General Purpose UAT\", \"status\": \"active\", \"iso_code\": \"22G1\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Data uji lokal\"}',NULL,'ff4dac87d2836ddfd6f8a265d73397ef','127.0.0.1','node','2026-07-23 13:52:18.056381'),('0ba899d3-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','survey_types.create','survey_types','14fcb920-2d27-4903-b6ae-c8c21cbd1c81',NULL,NULL,NULL,'{\"id\": \"14fcb920-2d27-4903-b6ae-c8c21cbd1c81\", \"code\": \"ST89537506\", \"name\": \"Survey UAT\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Data uji lokal\", \"requires_eir\": 0, \"requires_light_test\": 0, \"requires_cargo_worthy_result\": 1}',NULL,'e7af60f78d582fdf59ca354ec297a58c','127.0.0.1','node','2026-07-23 13:52:18.067851'),('0baa893f-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_locations.create','cedex_locations','41d79ecb-ec82-461d-96f5-8d90e7f7441f',NULL,NULL,NULL,'{\"id\": \"41d79ecb-ec82-461d-96f5-8d90e7f7441f\", \"code\": \"CL89537506\", \"face\": \"left\", \"status\": \"active\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Lokasi UAT\", \"display_order\": 1, \"container_size\": \"20\", \"cedex_mapping_code\": \"M89537506\"}',NULL,'aafdd3118ccbdb380b0796f451e9738f','127.0.0.1','node','2026-07-23 13:52:18.080523'),('0babe248-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_components.create','cedex_components','26b126b9-d1ef-490a-bfee-eb7174b2519c',NULL,NULL,NULL,'{\"id\": \"26b126b9-d1ef-490a-bfee-eb7174b2519c\", \"code\": \"CC89537506\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Data uji lokal\", \"component_name\": \"Component UAT\"}',NULL,'6fa8b4c97c8a8efc251bfba03c3d55b1','127.0.0.1','node','2026-07-23 13:52:18.089364'),('0bad784c-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_damages.create','cedex_damages','4ee9a6f0-ac55-4921-b12c-1c997b7df2a1',NULL,NULL,NULL,'{\"id\": \"4ee9a6f0-ac55-4921-b12c-1c997b7df2a1\", \"code\": \"CD89537506\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"damage_name\": \"Damage UAT\", \"description\": \"Data uji lokal\"}',NULL,'63928cf6384c5f7ae9ae06faa2558e40','127.0.0.1','node','2026-07-23 13:52:18.099766'),('0baec7e2-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.create','cedex_repairs','901027ac-8088-4682-bbc7-31d789561552',NULL,NULL,NULL,'{\"id\": \"901027ac-8088-4682-bbc7-31d789561552\", \"code\": \"CR89537506\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}',NULL,'7805e6541b4189691d05a7a738393a88','127.0.0.1','node','2026-07-23 13:52:18.108351'),('0bb0644a-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.update','cedex_repairs','901027ac-8088-4682-bbc7-31d789561552',NULL,NULL,'{\"id\": \"901027ac-8088-4682-bbc7-31d789561552\", \"code\": \"CR89537506\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}','{\"id\": \"901027ac-8088-4682-bbc7-31d789561552\", \"code\": \"CR89537506\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}',NULL,'73df02a72ff7a5e38fa4ba4330a99287','127.0.0.1','node','2026-07-23 13:52:18.118907'),('0bb20ad0-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.update','cedex_repairs','901027ac-8088-4682-bbc7-31d789561552',NULL,NULL,'{\"id\": \"901027ac-8088-4682-bbc7-31d789561552\", \"code\": \"CR89537506\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}','{\"id\": \"901027ac-8088-4682-bbc7-31d789561552\", \"code\": \"CR89537506\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}',NULL,'1163b99ac173a41097db9942c0775260','127.0.0.1','node','2026-07-23 13:52:18.129718'),('0bb3d485-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_materials.create','cedex_materials','6f4014c5-58f7-4654-9e5f-8b5c0c854c4a',NULL,NULL,NULL,'{\"id\": \"6f4014c5-58f7-4654-9e5f-8b5c0c854c4a\", \"code\": \"CM89537506\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Data uji lokal\", \"material_name\": \"Material UAT\"}',NULL,'a2dc4b324a3592e0e6d30896ab017049','127.0.0.1','node','2026-07-23 13:52:18.141433'),('0bb55c12-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','responsibility_codes.create','responsibility_codes','6e244cb0-3287-4f4d-9be4-74ae9a59b640',NULL,NULL,NULL,'{\"id\": \"6e244cb0-3287-4f4d-9be4-74ae9a59b640\", \"code\": \"RC89537506\", \"name\": \"Responsibility UAT\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Data uji lokal\"}',NULL,'35f30b69492d2751ecc99a6ea3f106c7','127.0.0.1','node','2026-07-23 13:52:18.151470'),('0bb9c00d-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_locations.create','cedex_locations','f80e9e2b-7203-4a5a-b03d-3f6c5c457081',NULL,NULL,NULL,'{\"id\": \"f80e9e2b-7203-4a5a-b03d-3f6c5c457081\", \"code\": \"CL89537506\", \"face\": \"left\", \"status\": \"active\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"customer_id\": \"af4d13f9-693e-4ded-8009-a43ef878741a\", \"description\": \"Lokasi UAT\", \"display_order\": 1, \"container_size\": \"20\", \"cedex_mapping_code\": \"M89537506\"}',NULL,'79d7046775408a0457f07c398604b202','127.0.0.1','node','2026-07-23 13:52:18.180232'),('0bbe3fff-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','finding_severities.create','finding_severities','81b8cb6c-9b80-4336-bb2f-df19035bb7b7',NULL,NULL,NULL,'{\"id\": \"81b8cb6c-9b80-4336-bb2f-df19035bb7b7\", \"code\": \"sv89537506\", \"name\": \"Severity UAT\", \"status\": \"active\", \"level_no\": 1, \"badge_tone\": \"neutral\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"description\": \"Data uji lokal\", \"affects_fitness_default\": 0, \"requires_supervisor_review\": 0}',NULL,'eda266fc807a1470c82f9a1bc6446ae2','127.0.0.1','node','2026-07-23 13:52:18.209727'),('0bc030d0-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','inspection_test_parameters.create','inspection_test_parameters','6c8619be-d563-4dea-a527-c3c8e7148911',NULL,NULL,NULL,'{\"id\": \"6c8619be-d563-4dea-a527-c3c8e7148911\", \"code\": \"TP89537506\", \"unit\": null, \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"description\": \"Tanpa ambang atau standar rekaan\", \"display_order\": 1, \"parameter_name\": \"Test Parameter UAT\", \"standard_reference\": null, \"requires_attachment\": 0, \"requires_numeric_result\": 0, \"applies_to_new_container\": 1, \"applies_to_existing_container\": 1}',NULL,'0d95f3ecf9fd35a7a3943a3b036b5da9','127.0.0.1','node','2026-07-23 13:52:18.222446'),('0bc21de4-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','evidence_photo_categories.create','evidence_photo_categories','7e6dafb6-7f8f-481f-b197-b22c1746e539',NULL,NULL,NULL,'{\"id\": \"7e6dafb6-7f8f-481f-b197-b22c1746e539\", \"code\": \"PC89537506\", \"name\": \"Photo Category UAT\", \"status\": \"active\", \"applies_to\": \"inspection\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"description\": \"Data uji lokal\", \"display_order\": 1, \"is_required_default\": 0}',NULL,'173229b69375315e6d60ae341349feb0','127.0.0.1','node','2026-07-23 13:52:18.235049'),('0bc57c2c-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','survey_types.reference_options.update','survey_types','14fcb920-2d27-4903-b6ae-c8c21cbd1c81',NULL,NULL,NULL,'{\"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"severity_ids\": [\"81b8cb6c-9b80-4336-bb2f-df19035bb7b7\"], \"survey_type_id\": \"14fcb920-2d27-4903-b6ae-c8c21cbd1c81\", \"photo_category_ids\": [\"7e6dafb6-7f8f-481f-b197-b22c1746e539\"], \"test_parameter_ids\": [\"6c8619be-d563-4dea-a527-c3c8e7148911\"]}',NULL,'d5602d3c622d7522a02214476047e83f','127.0.0.1','node','2026-07-23 13:52:18.257134'),('0bc90e52-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','fitness_checklist_templates.create','fitness_checklist_templates','40c67324-02f0-4cbe-8d94-8f4b71008693',NULL,NULL,NULL,'{\"id\": \"40c67324-02f0-4cbe-8d94-8f4b71008693\", \"status\": \"draft\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"version_no\": 1, \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Checklist uji lokal\", \"template_code\": \"CK89537506\", \"template_name\": \"Checklist UAT\", \"survey_type_id\": \"14fcb920-2d27-4903-b6ae-c8c21cbd1c81\", \"container_type_id\": \"a49affc2-b9d4-497d-a617-d25fd1d68300\", \"survey_type_label\": \"ST89537506 - Survey UAT\", \"approval_category_id\": null, \"container_type_label\": \"CT89537506 - General Purpose UAT\", \"approval_category_label\": null}',NULL,'b6259978733be8b6d4b3b99708e14cd2','127.0.0.1','node','2026-07-23 13:52:18.280516'),('0bcbd855-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','fitness_checklist_template_items.create','fitness_checklist_template_items','c94111b5-592a-4334-9d24-085933082e45',NULL,NULL,NULL,'{\"id\": \"c94111b5-592a-4334-9d24-085933082e45\", \"status\": \"active\", \"item_code\": \"IT89537506\", \"created_at\": \"2026-07-23T06:52:18Z\", \"item_label\": \"Kondisi umum sesuai\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"description\": \"Item uji lokal\", \"is_critical\": 0, \"is_required\": 1, \"template_id\": \"40c67324-02f0-4cbe-8d94-8f4b71008693\", \"display_order\": 1, \"response_type\": \"yes_no\", \"expected_value\": \"yes\", \"component_label\": null, \"fail_marks_unfit\": 0, \"test_parameter_id\": \"6c8619be-d563-4dea-a527-c3c8e7148911\", \"inspection_area_id\": null, \"fail_requires_repair\": 0, \"test_parameter_label\": \"TP89537506 - Test Parameter UAT\", \"inspection_area_label\": null, \"structural_component_id\": null}',NULL,'6f6b7b354f622d6a1be202667d184a2c','127.0.0.1','node','2026-07-23 13:52:18.298485'),('0bce1d2a-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','fitness_checklist_templates.update','fitness_checklist_templates','40c67324-02f0-4cbe-8d94-8f4b71008693',NULL,NULL,'{\"id\": \"40c67324-02f0-4cbe-8d94-8f4b71008693\", \"status\": \"draft\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"version_no\": 1, \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Checklist uji lokal\", \"template_code\": \"CK89537506\", \"template_name\": \"Checklist UAT\", \"survey_type_id\": \"14fcb920-2d27-4903-b6ae-c8c21cbd1c81\", \"container_type_id\": \"a49affc2-b9d4-497d-a617-d25fd1d68300\", \"survey_type_label\": \"ST89537506 - Survey UAT\", \"approval_category_id\": null, \"container_type_label\": \"CT89537506 - General Purpose UAT\", \"approval_category_label\": null}','{\"id\": \"40c67324-02f0-4cbe-8d94-8f4b71008693\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:18Z\", \"updated_at\": \"2026-07-23T06:52:18Z\", \"version_no\": 1, \"customer_id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"description\": \"Checklist uji lokal\", \"template_code\": \"CK89537506\", \"template_name\": \"Checklist UAT\", \"survey_type_id\": \"14fcb920-2d27-4903-b6ae-c8c21cbd1c81\", \"container_type_id\": \"a49affc2-b9d4-497d-a617-d25fd1d68300\", \"survey_type_label\": \"ST89537506 - Survey UAT\", \"approval_category_id\": null, \"container_type_label\": \"CT89537506 - General Purpose UAT\", \"approval_category_label\": null}',NULL,'214e6046cb6fe58355acb95a7ba2c988','127.0.0.1','node','2026-07-23 13:52:18.313657'),('0bd434e2-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','jobs.create','jobs','daf62320-72ab-42ed-b509-dd6b0a2ba413',NULL,NULL,NULL,'{\"id\": \"daf62320-72ab-42ed-b509-dd6b0a2ba413\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000006\"}',NULL,'fb9739ef1e964bdf41a47513beda01db','127.0.0.1','node','2026-07-23 13:52:18.353601'),('0bd67f79-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','job_containers.create','job_containers','b517fda0-6324-4bbe-9d9e-4ac166232d53',NULL,NULL,NULL,'{\"id\": \"b517fda0-6324-4bbe-9d9e-4ac166232d53\", \"status\": \"not_started\", \"container_no\": \"TSTU9537506\", \"check_digit_status\": \"override\"}',NULL,'31c80a573e80929f5031e827c7904212','127.0.0.1','node','2026-07-23 13:52:18.368639'),('0bda4f69-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','job_containers.import','job_containers','fd058dbe-7585-43f8-bc5a-a96fc0c102cf',NULL,NULL,NULL,'{\"id\": \"fd058dbe-7585-43f8-bc5a-a96fc0c102cf\", \"status\": \"not_started\", \"container_no\": \"TSTU9537507\", \"check_digit_status\": \"override\"}',NULL,'3ee31e1f98967634fca3bf069cefb264','127.0.0.1','node','2026-07-23 13:52:18.393630'),('0bdf8b64-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','assignments.assign','assignments','4a946427-7d4d-41ab-8a84-e8576c80801f',NULL,NULL,NULL,'{\"id\": \"4a946427-7d4d-41ab-8a84-e8576c80801f\", \"status\": \"assigned\", \"due_date\": \"2026-07-30T00:00:00Z\", \"start_date\": \"2026-07-23T00:00:00Z\", \"instruction\": \"Assignment UAT\", \"assignment_no\": \"GIFT-ASG-2026-000005\", \"assigned_containers\": 2}',NULL,'1419b5c70d0d4660797ccc8d4bf100f3','127.0.0.1','node','2026-07-23 13:52:18.427886'),('0be3cd3d-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.start','surveys','3bde18bd-5822-4531-8e90-ba16f508c162',NULL,NULL,NULL,'{\"id\": \"3bde18bd-5822-4531-8e90-ba16f508c162\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000004\", \"container_no\": \"TSTU9537506\", \"job_order_no\": \"GIFT-JO-2026-000006\", \"checklist_template_id\": \"40c67324-02f0-4cbe-8d94-8f4b71008693\"}',NULL,'66cc2faa28003134692ca501b02b976e','127.0.0.1','node','2026-07-23 13:52:18.455822'),('0be7616b-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.start','surveys','c8cfacf2-cacf-43de-91a5-57c7bcb5c1d7',NULL,NULL,NULL,'{\"id\": \"c8cfacf2-cacf-43de-91a5-57c7bcb5c1d7\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000005\", \"container_no\": \"TSTU9537507\", \"job_order_no\": \"GIFT-JO-2026-000006\", \"checklist_template_id\": \"40c67324-02f0-4cbe-8d94-8f4b71008693\"}',NULL,'06e77fd3fd8945509779170c38598836','127.0.0.1','node','2026-07-23 13:52:18.479243'),('0ce5c787-751c-11f1-8fe5-002b67818c25',NULL,NULL,'auth.login_failed','auth',NULL,NULL,NULL,NULL,NULL,NULL,'5f3e35a45060d51e2f1478067d8d649a','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:11:16.111521'),('0d33da76-751c-11f1-8fe5-002b67818c25',NULL,NULL,'auth.login_failed','auth',NULL,NULL,NULL,NULL,NULL,NULL,'a9ad73c453d4dca6bc8164cce2e33ef6','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:11:16.623155'),('1090c939-8651-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'ace729e1bcbe20762f572ffdb1ef7421','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:43:35.359211'),('10b019f4-8651-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','jobs.create','jobs','e8438630-bfbf-4861-be6f-73611a3f479c',NULL,NULL,NULL,'{\"id\": \"e8438630-bfbf-4861-be6f-73611a3f479c\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000004\"}',NULL,'fdbcf27c28e80d12ac4e23f7231b6dbf','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:43:35.564475'),('10bd29a8-8651-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','job_containers.import','job_containers','82b50221-7114-4dce-8544-c0508885094b',NULL,NULL,NULL,'{\"id\": \"82b50221-7114-4dce-8544-c0508885094b\", \"status\": \"not_started\", \"container_no\": \"MSKU1234567\", \"check_digit_status\": \"override\"}',NULL,'30ca54915503cd155c11f0ee6435aaea','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:43:35.650074'),('12df52db-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'248a44cf4a305d1f78148d29fa962924','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:05:51.687453'),('132820bd-8662-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'a37875b51b317f86a754683749e9ba7f','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 13:45:21.150905'),('1368cf8e-751c-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'fb9d12b7994472ba16482bc48352c994','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:11:27.036570'),('14cd6c31-751c-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.logout','auth',NULL,NULL,NULL,NULL,NULL,NULL,'1f5b541e6772cfe06d2caed85f7b474b','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:11:29.373632'),('159e88ac-81c7-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'e3cd7a3d30913236bb3e17f1ed107e7a','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 17:05:48.638114'),('175f1f61-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'91fec47c7957682276f456f57d801d93','127.0.0.1','node','2026-07-23 13:52:37.718920'),('176e950c-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'c1d4a0e3114fa43240921322d53c100b','127.0.0.1','node','2026-07-23 13:52:37.820278'),('177dcb1f-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'e838ec8a22c02d1ab42e766891283901','127.0.0.1','node','2026-07-23 13:52:37.919978'),('178c163d-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'4cc57ab4792ec4e238a7829642ea9f82','127.0.0.1','node','2026-07-23 13:52:38.013643'),('178e8612-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.create','customers','1e95fb79-ee0d-41aa-b26a-99f07e50976c',NULL,NULL,NULL,'{\"id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89557566@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_code\": \"UAT89557566\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"billing_address\": null, \"payment_term_days\": 14}',NULL,'1a811d25d4d87c3bc569e0e42487878c','127.0.0.1','node','2026-07-23 13:52:38.029549'),('17909738-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.create','customers','4d388157-406a-47e6-9343-8ad39bbf6700',NULL,NULL,NULL,'{\"id\": \"4d388157-406a-47e6-9343-8ad39bbf6700\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-iso-89557566@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_code\": \"U289557566\", \"customer_name\": \"UAT Isolation 89557566\", \"billing_address\": null, \"payment_term_days\": 14}',NULL,'0e7e16c3d903e1b33d28d390ab783c9b','127.0.0.1','node','2026-07-23 13:52:38.043108'),('1792d614-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.update','customers','1e95fb79-ee0d-41aa-b26a-99f07e50976c',NULL,NULL,'{\"id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89557566@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_code\": \"UAT89557566\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"billing_address\": null, \"payment_term_days\": 14}','{\"id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89557566@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_code\": \"UAT89557566\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"billing_address\": \"Alamat penagihan UAT\", \"payment_term_days\": 14}',NULL,'a650255ccca67c2b2f428e1515e80578','127.0.0.1','node','2026-07-23 13:52:38.057768'),('1795cb4f-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.create','customer_personnel','78654527-4834-48d5-9339-48d3eb97d4f6',NULL,NULL,NULL,'{\"id\": \"78654527-4834-48d5-9339-48d3eb97d4f6\", \"name\": \"Personel UAT\", \"email\": \"pic-89557566@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"personnel_code\": \"PIC89557566\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}',NULL,'d1c2de0856919c58e1435dd9d38594c5','127.0.0.1','node','2026-07-23 13:52:38.077222'),('179852f2-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.update','customer_personnel','78654527-4834-48d5-9339-48d3eb97d4f6',NULL,NULL,'{\"id\": \"78654527-4834-48d5-9339-48d3eb97d4f6\", \"name\": \"Personel UAT\", \"email\": \"pic-89557566@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"personnel_code\": \"PIC89557566\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}','{\"id\": \"78654527-4834-48d5-9339-48d3eb97d4f6\", \"name\": \"Personel UAT\", \"email\": \"pic-89557566@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"personnel_code\": \"PIC89557566\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}',NULL,'c53ed7d6d742eb1c86edd1dd53f9dfc2','127.0.0.1','node','2026-07-23 13:52:38.093807'),('179aa63b-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.update','customer_personnel','78654527-4834-48d5-9339-48d3eb97d4f6',NULL,NULL,'{\"id\": \"78654527-4834-48d5-9339-48d3eb97d4f6\", \"name\": \"Personel UAT\", \"email\": \"pic-89557566@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"personnel_code\": \"PIC89557566\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}','{\"id\": \"78654527-4834-48d5-9339-48d3eb97d4f6\", \"name\": \"Personel UAT\", \"email\": \"pic-89557566@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"personnel_code\": \"PIC89557566\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}',NULL,'c5f997adf703425d2c90021c3e110607','127.0.0.1','node','2026-07-23 13:52:38.109052'),('179c886b-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.create','customer_personnel','ca66d226-f8fd-4f8f-8e42-f87efbfa14b4',NULL,NULL,NULL,'{\"id\": \"ca66d226-f8fd-4f8f-8e42-f87efbfa14b4\", \"name\": \"Personel UAT\", \"email\": \"pic2-89557566@example.test\", \"notes\": null, \"phone\": \"0811000000\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"4d388157-406a-47e6-9343-8ad39bbf6700\", \"personnel_code\": \"P289557566\", \"personnel_type\": \"inspection\", \"position_title\": \"PIC Pemeriksaan\"}',NULL,'1b7d3adb9cb68ce54f06aabdf0f0c29f','127.0.0.1','node','2026-07-23 13:52:38.121408'),('179e0ed8-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','locations.create','locations','34275f3a-6e39-4224-998f-4c06aa4869cc',NULL,NULL,NULL,'{\"id\": \"34275f3a-6e39-4224-998f-4c06aa4869cc\", \"city\": \"Jakarta\", \"status\": \"active\", \"address\": \"Area uji lokal\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"L89557566\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"location_type\": \"depot\"}',NULL,'074926fbe552d534f44c152ca5312243','127.0.0.1','node','2026-07-23 13:52:38.131398'),('179fcef3-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','locations.create','locations','79a8279e-1d29-4f2b-9d59-92b471e4e52e',NULL,NULL,NULL,'{\"id\": \"79a8279e-1d29-4f2b-9d59-92b471e4e52e\", \"city\": \"Jakarta\", \"status\": \"active\", \"address\": \"Area uji lokal\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"4d388157-406a-47e6-9343-8ad39bbf6700\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"L289557566\", \"location_name\": \"Lokasi Isolation UAT\", \"location_type\": \"depot\"}',NULL,'3c3430a846ff81b74727f981ae3eecb6','127.0.0.1','node','2026-07-23 13:52:38.142878'),('17a1781f-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','container_types.create','container_types','c3a0e586-8fda-40de-bd9c-4e5689ffe647',NULL,NULL,NULL,'{\"id\": \"c3a0e586-8fda-40de-bd9c-4e5689ffe647\", \"code\": \"CT89557566\", \"size\": \"20\", \"type\": \"General Purpose UAT\", \"status\": \"active\", \"iso_code\": \"22G1\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Data uji lokal\"}',NULL,'067a82319515387959ebcbe4080eb265','127.0.0.1','node','2026-07-23 13:52:38.153767'),('17a30bad-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','survey_types.create','survey_types','79589597-afe5-42ba-bd7d-e9d7df2f2c68',NULL,NULL,NULL,'{\"id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"code\": \"ST89557566\", \"name\": \"Survey UAT\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Data uji lokal\", \"requires_eir\": 0, \"requires_light_test\": 0, \"requires_cargo_worthy_result\": 1}',NULL,'b8186a78c4351c3f2ef96cde684e3d65','127.0.0.1','node','2026-07-23 13:52:38.164087'),('17a4837d-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_locations.create','cedex_locations','876c2246-4992-4fd2-a749-3d223f4c9e6f',NULL,NULL,NULL,'{\"id\": \"876c2246-4992-4fd2-a749-3d223f4c9e6f\", \"code\": \"CL89557566\", \"face\": \"left\", \"status\": \"active\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Lokasi UAT\", \"display_order\": 1, \"container_size\": \"20\", \"cedex_mapping_code\": \"M89557566\"}',NULL,'190b5bc3c8758fbe9f30a78dda010fbf','127.0.0.1','node','2026-07-23 13:52:38.173693'),('17a629a6-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_components.create','cedex_components','72120964-15d2-493b-9794-b7f85560c39d',NULL,NULL,NULL,'{\"id\": \"72120964-15d2-493b-9794-b7f85560c39d\", \"code\": \"CC89557566\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Data uji lokal\", \"component_name\": \"Component UAT\"}',NULL,'104fe3132ee51c6cd6daeeca225fa793','127.0.0.1','node','2026-07-23 13:52:38.184498'),('17a7cf88-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_damages.create','cedex_damages','003fc685-001a-40c2-9455-d6f5c0df6c2d',NULL,NULL,NULL,'{\"id\": \"003fc685-001a-40c2-9455-d6f5c0df6c2d\", \"code\": \"CD89557566\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"damage_name\": \"Damage UAT\", \"description\": \"Data uji lokal\"}',NULL,'8b18b4091b262ccbff147659c6a89842','127.0.0.1','node','2026-07-23 13:52:38.195299'),('17ab64aa-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.create','cedex_repairs','dd311dc0-d26c-450f-bdac-22848504252f',NULL,NULL,NULL,'{\"id\": \"dd311dc0-d26c-450f-bdac-22848504252f\", \"code\": \"CR89557566\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}',NULL,'9073727a0e10a5ba43e6ce9ebb3db5a8','127.0.0.1','node','2026-07-23 13:52:38.218775'),('17aefb34-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.update','cedex_repairs','dd311dc0-d26c-450f-bdac-22848504252f',NULL,NULL,'{\"id\": \"dd311dc0-d26c-450f-bdac-22848504252f\", \"code\": \"CR89557566\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}','{\"id\": \"dd311dc0-d26c-450f-bdac-22848504252f\", \"code\": \"CR89557566\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}',NULL,'ea9e8e91753cb53f06280f5488697735','127.0.0.1','node','2026-07-23 13:52:38.242310'),('17b0f1cc-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.update','cedex_repairs','dd311dc0-d26c-450f-bdac-22848504252f',NULL,NULL,'{\"id\": \"dd311dc0-d26c-450f-bdac-22848504252f\", \"code\": \"CR89557566\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}','{\"id\": \"dd311dc0-d26c-450f-bdac-22848504252f\", \"code\": \"CR89557566\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Referensi tindakan teknis\", \"repair_name\": \"Action Repair UAT\"}',NULL,'67d59cb18da3f2f7fe5f4e651dbcf3c5','127.0.0.1','node','2026-07-23 13:52:38.255177'),('17b1ad9d-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'302852d5437e1dbdbf225d19c4795a35','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-22 14:08:08.410767'),('17b25f58-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_materials.create','cedex_materials','2e96b899-49a5-49d6-927a-1c7fe096e0e0',NULL,NULL,NULL,'{\"id\": \"2e96b899-49a5-49d6-927a-1c7fe096e0e0\", \"code\": \"CM89557566\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Data uji lokal\", \"material_name\": \"Material UAT\"}',NULL,'7e6f03a75a323e79182cd48870c939c3','127.0.0.1','node','2026-07-23 13:52:38.264547'),('17b407da-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','responsibility_codes.create','responsibility_codes','7bf864f9-91a4-4825-a3de-3c534c69e7e3',NULL,NULL,NULL,'{\"id\": \"7bf864f9-91a4-4825-a3de-3c534c69e7e3\", \"code\": \"RC89557566\", \"name\": \"Responsibility UAT\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Data uji lokal\"}',NULL,'32d76097ab5c606fa6cf4c9ead093b36','127.0.0.1','node','2026-07-23 13:52:38.275418'),('17b64bdb-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_locations.create','cedex_locations','6371a90e-1b0c-4e6a-854a-9a07a46f285f',NULL,NULL,NULL,'{\"id\": \"6371a90e-1b0c-4e6a-854a-9a07a46f285f\", \"code\": \"CL89557566\", \"face\": \"left\", \"status\": \"active\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"4d388157-406a-47e6-9343-8ad39bbf6700\", \"description\": \"Lokasi UAT\", \"display_order\": 1, \"container_size\": \"20\", \"cedex_mapping_code\": \"M89557566\"}',NULL,'64d46a95167f5210c10167255f58e6aa','127.0.0.1','node','2026-07-23 13:52:38.290260'),('17b8c9c8-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','finding_severities.create','finding_severities','903e0508-30db-405c-8f36-e6dfc8f0fb10',NULL,NULL,NULL,'{\"id\": \"903e0508-30db-405c-8f36-e6dfc8f0fb10\", \"code\": \"sv89557566\", \"name\": \"Severity UAT\", \"status\": \"active\", \"level_no\": 1, \"badge_tone\": \"neutral\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"description\": \"Data uji lokal\", \"affects_fitness_default\": 0, \"requires_supervisor_review\": 0}',NULL,'f5e8b9490e9eb223f18641bcd91a171f','127.0.0.1','node','2026-07-23 13:52:38.306583'),('17ba6bed-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','inspection_test_parameters.create','inspection_test_parameters','61b24416-1880-4d7f-a97a-e0429cc21ecf',NULL,NULL,NULL,'{\"id\": \"61b24416-1880-4d7f-a97a-e0429cc21ecf\", \"code\": \"TP89557566\", \"unit\": null, \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"description\": \"Tanpa ambang atau standar rekaan\", \"display_order\": 1, \"parameter_name\": \"Test Parameter UAT\", \"standard_reference\": null, \"requires_attachment\": 0, \"requires_numeric_result\": 0, \"applies_to_new_container\": 1, \"applies_to_existing_container\": 1}',NULL,'2835393e8ae051db94ee37e3a6d00349','127.0.0.1','node','2026-07-23 13:52:38.317220'),('17bbd9cc-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','evidence_photo_categories.create','evidence_photo_categories','18bf2745-3dae-4b30-85a1-af359690d6af',NULL,NULL,NULL,'{\"id\": \"18bf2745-3dae-4b30-85a1-af359690d6af\", \"code\": \"PC89557566\", \"name\": \"Photo Category UAT\", \"status\": \"active\", \"applies_to\": \"inspection\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"description\": \"Data uji lokal\", \"display_order\": 1, \"is_required_default\": 0}',NULL,'d51ea45157f6ed2e358e41215b5f91e7','127.0.0.1','node','2026-07-23 13:52:38.326667'),('17bdfb67-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','survey_types.reference_options.update','survey_types','79589597-afe5-42ba-bd7d-e9d7df2f2c68',NULL,NULL,NULL,'{\"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"severity_ids\": [\"903e0508-30db-405c-8f36-e6dfc8f0fb10\"], \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"photo_category_ids\": [\"18bf2745-3dae-4b30-85a1-af359690d6af\"], \"test_parameter_ids\": [\"61b24416-1880-4d7f-a97a-e0429cc21ecf\"]}',NULL,'ff2d9b38488c4d3e9095d21af77a0cce','127.0.0.1','node','2026-07-23 13:52:38.340632'),('17c06092-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','fitness_checklist_templates.create','fitness_checklist_templates','0b56a5b1-d55d-47bd-a00e-26654be2a956',NULL,NULL,NULL,'{\"id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\", \"status\": \"draft\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"version_no\": 1, \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Checklist uji lokal\", \"template_code\": \"CK89557566\", \"template_name\": \"Checklist UAT\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"container_type_id\": \"c3a0e586-8fda-40de-bd9c-4e5689ffe647\", \"survey_type_label\": \"ST89557566 - Survey UAT\", \"approval_category_id\": null, \"container_type_label\": \"CT89557566 - General Purpose UAT\", \"approval_category_label\": null}',NULL,'c85406ad326f3ea9e25157cfd8a1ea1b','127.0.0.1','node','2026-07-23 13:52:38.356273'),('17c257c1-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','fitness_checklist_template_items.create','fitness_checklist_template_items','5665a85b-983b-4764-b230-d698bd4f3ae5',NULL,NULL,NULL,'{\"id\": \"5665a85b-983b-4764-b230-d698bd4f3ae5\", \"status\": \"active\", \"item_code\": \"IT89557566\", \"created_at\": \"2026-07-23T06:52:38Z\", \"item_label\": \"Kondisi umum sesuai\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"description\": \"Item uji lokal\", \"is_critical\": 0, \"is_required\": 1, \"template_id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\", \"display_order\": 1, \"response_type\": \"yes_no\", \"expected_value\": \"yes\", \"component_label\": null, \"fail_marks_unfit\": 0, \"test_parameter_id\": \"61b24416-1880-4d7f-a97a-e0429cc21ecf\", \"inspection_area_id\": null, \"fail_requires_repair\": 0, \"test_parameter_label\": \"TP89557566 - Test Parameter UAT\", \"inspection_area_label\": null, \"structural_component_id\": null}',NULL,'1c58ef309f773683d7c4c0e59eeaa9b1','127.0.0.1','node','2026-07-23 13:52:38.369189'),('17c45301-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','fitness_checklist_templates.update','fitness_checklist_templates','0b56a5b1-d55d-47bd-a00e-26654be2a956',NULL,NULL,'{\"id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\", \"status\": \"draft\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"version_no\": 1, \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Checklist uji lokal\", \"template_code\": \"CK89557566\", \"template_name\": \"Checklist UAT\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"container_type_id\": \"c3a0e586-8fda-40de-bd9c-4e5689ffe647\", \"survey_type_label\": \"ST89557566 - Survey UAT\", \"approval_category_id\": null, \"container_type_label\": \"CT89557566 - General Purpose UAT\", \"approval_category_label\": null}','{\"id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\", \"status\": \"active\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"version_no\": 1, \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"description\": \"Checklist uji lokal\", \"template_code\": \"CK89557566\", \"template_name\": \"Checklist UAT\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"container_type_id\": \"c3a0e586-8fda-40de-bd9c-4e5689ffe647\", \"survey_type_label\": \"ST89557566 - Survey UAT\", \"approval_category_id\": null, \"container_type_label\": \"CT89557566 - General Purpose UAT\", \"approval_category_label\": null}',NULL,'0aefc6d6b4aac01de4686d0400b71971','127.0.0.1','node','2026-07-23 13:52:38.382164'),('17c836e4-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','jobs.create','jobs','9cb28aad-c5f8-4a6e-93c6-7718905972fe',NULL,NULL,NULL,'{\"id\": \"9cb28aad-c5f8-4a6e-93c6-7718905972fe\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000007\"}',NULL,'c120092b82c5bc22cae47fc2f92bc2f8','127.0.0.1','node','2026-07-23 13:52:38.407709'),('17ca32e7-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','job_containers.create','job_containers','d52f27a5-6060-41f6-aaad-a9d3deaa837b',NULL,NULL,NULL,'{\"id\": \"d52f27a5-6060-41f6-aaad-a9d3deaa837b\", \"status\": \"not_started\", \"container_no\": \"TSTU9557566\", \"check_digit_status\": \"override\"}',NULL,'8ae11531c60a0ae789bc01fc882de319','127.0.0.1','node','2026-07-23 13:52:38.420711'),('17cda76a-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','job_containers.import','job_containers','30956aa8-4a29-4628-b5a2-2d297cd4208e',NULL,NULL,NULL,'{\"id\": \"30956aa8-4a29-4628-b5a2-2d297cd4208e\", \"status\": \"not_started\", \"container_no\": \"TSTU9557567\", \"check_digit_status\": \"valid\"}',NULL,'790946f2f60f500542c6aa5b6266a510','127.0.0.1','node','2026-07-23 13:52:38.443349'),('17d218e2-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','assignments.assign','assignments','de3eeefb-9df3-465e-a137-0da41de4a3e9',NULL,NULL,NULL,'{\"id\": \"de3eeefb-9df3-465e-a137-0da41de4a3e9\", \"status\": \"assigned\", \"due_date\": \"2026-07-30T00:00:00Z\", \"start_date\": \"2026-07-23T00:00:00Z\", \"instruction\": \"Assignment UAT\", \"assignment_no\": \"GIFT-ASG-2026-000006\", \"assigned_containers\": 2}',NULL,'002491c7056120d08d9e9635b9976db5','127.0.0.1','node','2026-07-23 13:52:38.472469'),('17d4e2cc-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.start','surveys','b3b96ed8-8308-4a83-af84-e5d488d1260e',NULL,NULL,NULL,'{\"id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000006\", \"container_no\": \"TSTU9557566\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"checklist_template_id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\"}',NULL,'8d56e794ee5e75490fe3bee876b33f71','127.0.0.1','node','2026-07-23 13:52:38.490735'),('17d805f8-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.start','surveys','5905e03b-cc89-45cd-a99a-94f57871239c',NULL,NULL,NULL,'{\"id\": \"5905e03b-cc89-45cd-a99a-94f57871239c\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000007\", \"container_no\": \"TSTU9557567\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"checklist_template_id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\"}',NULL,'0e519504d200ee59a9cea27f241c1655','127.0.0.1','node','2026-07-23 13:52:38.511290'),('17de4266-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','survey_damages.create','survey_damages','43a36e7d-5d9c-464f-833d-1f5b6b925faa',NULL,NULL,NULL,'{\"id\": \"43a36e7d-5d9c-464f-833d-1f5b6b925faa\", \"face\": \"left\", \"severity\": \"sv89557566\", \"damage_no\": \"D-001\", \"internal_location\": \"L1\"}',NULL,'955b1e708de0a7d13ac73d651a12a088','127.0.0.1','node','2026-07-23 13:52:38.552162'),('17e0f08d-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','survey_damages.update','survey_damages','43a36e7d-5d9c-464f-833d-1f5b6b925faa',NULL,NULL,NULL,'{\"id\": \"43a36e7d-5d9c-464f-833d-1f5b6b925faa\", \"face\": \"left\", \"severity\": \"sv89557566\", \"damage_no\": \"D-001\", \"internal_location\": \"L1\"}',NULL,'43cc45de9b0829cd8240fff5d2184d60','127.0.0.1','node','2026-07-23 13:52:38.569725'),('17e290ef-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','survey_damages.delete','survey_damages','43a36e7d-5d9c-464f-833d-1f5b6b925faa',NULL,NULL,'{\"id\": \"43a36e7d-5d9c-464f-833d-1f5b6b925faa\", \"damage_no\": \"D-001\", \"survey_id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\"}',NULL,NULL,'111631ffa86170ead5f6098ed584c34f','127.0.0.1','node','2026-07-23 13:52:38.580391'),('17e50c67-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.update_checklist','surveys','b3b96ed8-8308-4a83-af84-e5d488d1260e',NULL,NULL,'{\"id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000006\", \"started_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"location_id\": \"34275f3a-6e39-4224-998f-4c06aa4869cc\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"TSTU9557566\", \"final_remark\": null, \"job_deadline\": null, \"job_order_id\": \"9cb28aad-c5f8-4a6e-93c6-7718905972fe\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"submitted_at\": null, \"customer_code\": \"UAT89557566\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"iso_type_code\": \"22G1\", \"location_code\": \"L89557566\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"job_instruction\": \"Data uji lokal finalisasi menu Admin\", \"job_container_id\": \"d52f27a5-6060-41f6-aaad-a9d3deaa837b\", \"survey_type_code\": \"ST89557566\", \"survey_type_name\": \"Survey UAT\", \"assignment_due_at\": \"2026-07-30T00:00:00Z\", \"container_type_id\": \"c3a0e586-8fda-40de-bd9c-4e5689ffe647\", \"container_type_code\": \"CT89557566\", \"container_type_name\": \"General Purpose UAT\", \"checklist_template_id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\", \"assignment_instruction\": \"Assignment UAT\"}','{\"survey_id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"total_items\": 1, \"completed_items\": 1}',NULL,'deb0190f45684d3242ce6a9abcf0a0fb','127.0.0.1','node','2026-07-23 13:52:38.596554'),('17e6b705-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.update_general','surveys','b3b96ed8-8308-4a83-af84-e5d488d1260e',NULL,NULL,'{\"id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000006\", \"started_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"location_id\": \"34275f3a-6e39-4224-998f-4c06aa4869cc\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"TSTU9557566\", \"final_remark\": null, \"job_deadline\": null, \"job_order_id\": \"9cb28aad-c5f8-4a6e-93c6-7718905972fe\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"submitted_at\": null, \"customer_code\": \"UAT89557566\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"iso_type_code\": \"22G1\", \"location_code\": \"L89557566\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"job_instruction\": \"Data uji lokal finalisasi menu Admin\", \"job_container_id\": \"d52f27a5-6060-41f6-aaad-a9d3deaa837b\", \"survey_type_code\": \"ST89557566\", \"survey_type_name\": \"Survey UAT\", \"assignment_due_at\": \"2026-07-30T00:00:00Z\", \"container_type_id\": \"c3a0e586-8fda-40de-bd9c-4e5689ffe647\", \"container_type_code\": \"CT89557566\", \"container_type_name\": \"General Purpose UAT\", \"checklist_template_id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\", \"assignment_instruction\": \"Assignment UAT\"}','{\"id\": \"17d43f7a-8663-11f1-a160-002b67818c25\", \"seal_no\": null, \"survey_id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"cargo_status\": \"empty\", \"survey_date_time\": \"2026-07-23T06:00:00Z\", \"general_condition\": \"sound\"}',NULL,'5ec6f2df72bc10b56f5c16f9c763b3f3','127.0.0.1','node','2026-07-23 13:52:38.607547'),('17ec3055-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.submit','surveys','b3b96ed8-8308-4a83-af84-e5d488d1260e',NULL,NULL,'{\"id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000006\", \"started_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"location_id\": \"34275f3a-6e39-4224-998f-4c06aa4869cc\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"TSTU9557566\", \"final_remark\": null, \"job_deadline\": null, \"job_order_id\": \"9cb28aad-c5f8-4a6e-93c6-7718905972fe\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"submitted_at\": null, \"customer_code\": \"UAT89557566\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"iso_type_code\": \"22G1\", \"location_code\": \"L89557566\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"job_instruction\": \"Data uji lokal finalisasi menu Admin\", \"job_container_id\": \"d52f27a5-6060-41f6-aaad-a9d3deaa837b\", \"survey_type_code\": \"ST89557566\", \"survey_type_name\": \"Survey UAT\", \"assignment_due_at\": \"2026-07-30T00:00:00Z\", \"container_type_id\": \"c3a0e586-8fda-40de-bd9c-4e5689ffe647\", \"container_type_code\": \"CT89557566\", \"container_type_name\": \"General Purpose UAT\", \"checklist_template_id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\", \"assignment_instruction\": \"Assignment UAT\"}','{\"id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000006\", \"submitted_at\": \"2026-07-23T06:52:38Z\"}',NULL,'309750f86c6d553244939c8f5a89071e','127.0.0.1','node','2026-07-23 13:52:38.643366'),('17ee9c28-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','reviews.need_revision','surveys','b3b96ed8-8308-4a83-af84-e5d488d1260e',NULL,NULL,'{\"id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000006\", \"approved_at\": null, \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"TSTU9557566\", \"job_order_id\": \"9cb28aad-c5f8-4a6e-93c6-7718905972fe\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"submitted_at\": \"2026-07-23T06:52:38Z\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"survey_result\": \"sound\", \"surveyor_name\": \"Surveyor Demo\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"job_container_id\": \"d52f27a5-6060-41f6-aaad-a9d3deaa837b\", \"survey_type_name\": \"Survey UAT\", \"current_revision_no\": 0}','{\"status\": \"need_revision\", \"survey_id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"revision_note\": \"Lengkapi verifikasi UAT\"}',NULL,'3c5825225a5d9a9c12a672cbfb17b1b5','127.0.0.1','node','2026-07-23 13:52:38.659305'),('17f1f231-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.submit','surveys','b3b96ed8-8308-4a83-af84-e5d488d1260e',NULL,NULL,'{\"id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"status\": \"need_revision\", \"survey_no\": \"GIFT-SVY-2026-000006\", \"started_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"location_id\": \"34275f3a-6e39-4224-998f-4c06aa4869cc\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"TSTU9557566\", \"final_remark\": \"Submit awal UAT\", \"job_deadline\": null, \"job_order_id\": \"9cb28aad-c5f8-4a6e-93c6-7718905972fe\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"submitted_at\": \"2026-07-23T06:52:38Z\", \"customer_code\": \"UAT89557566\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"iso_type_code\": \"22G1\", \"location_code\": \"L89557566\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"job_instruction\": \"Data uji lokal finalisasi menu Admin\", \"job_container_id\": \"d52f27a5-6060-41f6-aaad-a9d3deaa837b\", \"survey_type_code\": \"ST89557566\", \"survey_type_name\": \"Survey UAT\", \"assignment_due_at\": \"2026-07-30T00:00:00Z\", \"container_type_id\": \"c3a0e586-8fda-40de-bd9c-4e5689ffe647\", \"container_type_code\": \"CT89557566\", \"container_type_name\": \"General Purpose UAT\", \"checklist_template_id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\", \"assignment_instruction\": \"Assignment UAT\"}','{\"id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000006\", \"submitted_at\": \"2026-07-23T06:52:38Z\"}',NULL,'795feec5171ced8fbc50f322b1ca11fe','127.0.0.1','node','2026-07-23 13:52:38.681086'),('17f55c68-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','reviews.approve','surveys','b3b96ed8-8308-4a83-af84-e5d488d1260e',NULL,NULL,'{\"id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000006\", \"approved_at\": null, \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"TSTU9557566\", \"job_order_id\": \"9cb28aad-c5f8-4a6e-93c6-7718905972fe\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"submitted_at\": \"2026-07-23T06:52:38Z\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"survey_result\": \"sound\", \"surveyor_name\": \"Surveyor Demo\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"job_container_id\": \"d52f27a5-6060-41f6-aaad-a9d3deaa837b\", \"survey_type_name\": \"Survey UAT\", \"current_revision_no\": 1}','{\"status\": \"approved\", \"report_no\": \"GIFT-RPT-2026-000002\", \"survey_id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"report_generation_status\": \"queued\"}',NULL,'44ce8539169fbdf72293e0d7f0d6ed4a','127.0.0.1','node','2026-07-23 13:52:38.703530'),('17f843aa-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.update_checklist','surveys','5905e03b-cc89-45cd-a99a-94f57871239c',NULL,NULL,'{\"id\": \"5905e03b-cc89-45cd-a99a-94f57871239c\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000007\", \"started_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"location_id\": \"34275f3a-6e39-4224-998f-4c06aa4869cc\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"TSTU9557567\", \"final_remark\": null, \"job_deadline\": null, \"job_order_id\": \"9cb28aad-c5f8-4a6e-93c6-7718905972fe\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"submitted_at\": null, \"customer_code\": \"UAT89557566\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"iso_type_code\": \"22G1\", \"location_code\": \"L89557566\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"job_instruction\": \"Data uji lokal finalisasi menu Admin\", \"job_container_id\": \"30956aa8-4a29-4628-b5a2-2d297cd4208e\", \"survey_type_code\": \"ST89557566\", \"survey_type_name\": \"Survey UAT\", \"assignment_due_at\": \"2026-07-30T00:00:00Z\", \"container_type_id\": \"c3a0e586-8fda-40de-bd9c-4e5689ffe647\", \"container_type_code\": \"CT89557566\", \"container_type_name\": \"General Purpose UAT\", \"checklist_template_id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\", \"assignment_instruction\": \"Assignment UAT\"}','{\"survey_id\": \"5905e03b-cc89-45cd-a99a-94f57871239c\", \"total_items\": 1, \"completed_items\": 1}',NULL,'560b5b286567ee160d028e90dbef767d','127.0.0.1','node','2026-07-23 13:52:38.722552'),('17f9dbcd-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.update_general','surveys','5905e03b-cc89-45cd-a99a-94f57871239c',NULL,NULL,'{\"id\": \"5905e03b-cc89-45cd-a99a-94f57871239c\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000007\", \"started_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"location_id\": \"34275f3a-6e39-4224-998f-4c06aa4869cc\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"TSTU9557567\", \"final_remark\": null, \"job_deadline\": null, \"job_order_id\": \"9cb28aad-c5f8-4a6e-93c6-7718905972fe\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"submitted_at\": null, \"customer_code\": \"UAT89557566\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"iso_type_code\": \"22G1\", \"location_code\": \"L89557566\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"job_instruction\": \"Data uji lokal finalisasi menu Admin\", \"job_container_id\": \"30956aa8-4a29-4628-b5a2-2d297cd4208e\", \"survey_type_code\": \"ST89557566\", \"survey_type_name\": \"Survey UAT\", \"assignment_due_at\": \"2026-07-30T00:00:00Z\", \"container_type_id\": \"c3a0e586-8fda-40de-bd9c-4e5689ffe647\", \"container_type_code\": \"CT89557566\", \"container_type_name\": \"General Purpose UAT\", \"checklist_template_id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\", \"assignment_instruction\": \"Assignment UAT\"}','{\"id\": \"17d775b7-8663-11f1-a160-002b67818c25\", \"seal_no\": null, \"survey_id\": \"5905e03b-cc89-45cd-a99a-94f57871239c\", \"cargo_status\": \"empty\", \"survey_date_time\": \"2026-07-23T06:00:00Z\", \"general_condition\": \"sound\"}',NULL,'41e0191fe6667b44694e8debf230e636','127.0.0.1','node','2026-07-23 13:52:38.732955'),('17fed1e7-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.submit','surveys','5905e03b-cc89-45cd-a99a-94f57871239c',NULL,NULL,'{\"id\": \"5905e03b-cc89-45cd-a99a-94f57871239c\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000007\", \"started_at\": \"2026-07-23T06:52:38Z\", \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"location_id\": \"34275f3a-6e39-4224-998f-4c06aa4869cc\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"TSTU9557567\", \"final_remark\": null, \"job_deadline\": null, \"job_order_id\": \"9cb28aad-c5f8-4a6e-93c6-7718905972fe\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"submitted_at\": null, \"customer_code\": \"UAT89557566\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"iso_type_code\": \"22G1\", \"location_code\": \"L89557566\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"job_instruction\": \"Data uji lokal finalisasi menu Admin\", \"job_container_id\": \"30956aa8-4a29-4628-b5a2-2d297cd4208e\", \"survey_type_code\": \"ST89557566\", \"survey_type_name\": \"Survey UAT\", \"assignment_due_at\": \"2026-07-30T00:00:00Z\", \"container_type_id\": \"c3a0e586-8fda-40de-bd9c-4e5689ffe647\", \"container_type_code\": \"CT89557566\", \"container_type_name\": \"General Purpose UAT\", \"checklist_template_id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\", \"assignment_instruction\": \"Assignment UAT\"}','{\"id\": \"5905e03b-cc89-45cd-a99a-94f57871239c\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000007\", \"submitted_at\": \"2026-07-23T06:52:38Z\"}',NULL,'170dc2fb0866df09f374dc53a8c7a044','127.0.0.1','node','2026-07-23 13:52:38.765511'),('1800750d-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','reviews.reject','surveys','5905e03b-cc89-45cd-a99a-94f57871239c',NULL,NULL,'{\"id\": \"5905e03b-cc89-45cd-a99a-94f57871239c\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000007\", \"approved_at\": null, \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"TSTU9557567\", \"job_order_id\": \"9cb28aad-c5f8-4a6e-93c6-7718905972fe\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"submitted_at\": \"2026-07-23T06:52:38Z\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"survey_result\": \"sound\", \"surveyor_name\": \"Surveyor Demo\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"job_container_id\": \"30956aa8-4a29-4628-b5a2-2d297cd4208e\", \"survey_type_name\": \"Survey UAT\", \"current_revision_no\": 0}','{\"status\": \"rejected\", \"survey_id\": \"5905e03b-cc89-45cd-a99a-94f57871239c\", \"rejection_reason\": \"Skenario reject UAT\"}',NULL,'1d9bbbd77855302ffc5e94e64eadc96f','127.0.0.1','node','2026-07-23 13:52:38.776266'),('18059360-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','evidence_photo_categories.create','evidence_photo_categories','85d7a58e-5b30-41d8-bdc1-e141d2be7629',NULL,NULL,NULL,'{\"id\": \"85d7a58e-5b30-41d8-bdc1-e141d2be7629\", \"code\": \"PX89557566\", \"name\": \"Photo Delete UAT\", \"status\": \"active\", \"applies_to\": \"inspection\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"description\": \"Data uji lokal\", \"display_order\": 1, \"is_required_default\": 0}',NULL,'40def069bb1282aab4d62018bb032ac5','127.0.0.1','node','2026-07-23 13:52:38.809828'),('18072813-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','evidence_photo_categories.deactivate','evidence_photo_categories','85d7a58e-5b30-41d8-bdc1-e141d2be7629',NULL,NULL,'{\"id\": \"85d7a58e-5b30-41d8-bdc1-e141d2be7629\", \"code\": \"PX89557566\", \"name\": \"Photo Delete UAT\", \"status\": \"active\", \"applies_to\": \"inspection\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"description\": \"Data uji lokal\", \"display_order\": 1, \"is_required_default\": 0}','{\"id\": \"85d7a58e-5b30-41d8-bdc1-e141d2be7629\", \"code\": \"PX89557566\", \"name\": \"Photo Delete UAT\", \"status\": \"inactive\", \"applies_to\": \"inspection\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"description\": \"Data uji lokal\", \"display_order\": 1, \"is_required_default\": 0}',NULL,'6f13a5b9d592d2d921f1d23c5a021ef3','127.0.0.1','node','2026-07-23 13:52:38.820165'),('1808d308-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.update','customers','1e95fb79-ee0d-41aa-b26a-99f07e50976c',NULL,NULL,'{\"id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89557566@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_code\": \"UAT89557566\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"billing_address\": \"Alamat penagihan UAT\", \"payment_term_days\": 14}','{\"id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"npwp\": null, \"status\": \"inactive\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89557566@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_code\": \"UAT89557566\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"billing_address\": \"Alamat penagihan UAT\", \"payment_term_days\": 14}',NULL,'a7ea1fb29ef67f47fa966fa8f6a6f686','127.0.0.1','node','2026-07-23 13:52:38.831019'),('180acc93-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.update','customers','4d388157-406a-47e6-9343-8ad39bbf6700',NULL,NULL,'{\"id\": \"4d388157-406a-47e6-9343-8ad39bbf6700\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-iso-89557566@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_code\": \"U289557566\", \"customer_name\": \"UAT Isolation 89557566\", \"billing_address\": null, \"payment_term_days\": 14}','{\"id\": \"4d388157-406a-47e6-9343-8ad39bbf6700\", \"npwp\": null, \"status\": \"inactive\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-iso-89557566@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:38Z\", \"updated_at\": \"2026-07-23T06:52:38Z\", \"customer_code\": \"U289557566\", \"customer_name\": \"UAT Isolation 89557566\", \"billing_address\": null, \"payment_term_days\": 14}',NULL,'6804cdae6ec375690c2934468c07f883','127.0.0.1','node','2026-07-23 13:52:38.844035'),('184fa1c7-751c-11f1-8fe5-002b67818c25',NULL,NULL,'auth.login_failed','auth',NULL,NULL,NULL,NULL,NULL,NULL,'45b26f1e14f7bd16ffb2715ff7483812','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:11:35.260112'),('18e9a474-751c-11f1-8fe5-002b67818c25',NULL,NULL,'auth.login_failed','auth',NULL,NULL,NULL,NULL,NULL,NULL,'4258fd44e1ac9cb03c4f88bd94c2c1b6','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:11:36.269476'),('18f28570-8651-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'27023f8203d59562c9b2148b57c27d11','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:43:49.421549'),('19278f39-751c-11f1-8fe5-002b67818c25',NULL,NULL,'auth.login_failed','auth',NULL,NULL,NULL,NULL,NULL,NULL,'27c3a6c15ec06a88d623f647475e9013','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:11:36.675253'),('1956e10f-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'7913144526fa349f4595d41063a8ee48','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:06:02.537319'),('1c39b66c-841c-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'f632b847ceb1c417f5caaf51763ea20a','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-20 16:19:29.268842'),('1da14b7e-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'680988f05c1d39cf7fdb7ec87d1233ef','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 13:52:48.218971'),('1ed1c647-864f-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'1a13f8900c9edfcd6424001779c34cac','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-23 11:29:40.279797'),('1eff573a-8961-11f1-b28f-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'a7aa0188bacc7e0c8f5b1435c9ee2140','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-27 09:16:05.007907'),('1fb2b6d2-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'d4fd9fad01cf790cd60fb375987c4e25','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:06:13.205431'),('1fd71825-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.open','surveys','3bde18bd-5822-4531-8e90-ba16f508c162',NULL,NULL,NULL,'{\"survey_no\": \"GIFT-SVY-2026-000004\"}',NULL,'23c7e53391aba0527008ebc008a4bc57','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:06:13.441766'),('22eab6d9-864f-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'33a1cde72b37df7d697e3481212ba105','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-23 11:29:47.154149'),('230b6580-8664-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'d85e25c646a2566b21fdf5108d125ac9','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 14:00:06.799616'),('245bf4b3-864f-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'e10e4ae65d432490b0da37fc247f4c33','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-23 11:29:49.573934'),('25e5bf93-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'3d541c8342f733859f4ec0f2773e90c4','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:06:23.606322'),('25edaaa5-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.open','surveys','3bde18bd-5822-4531-8e90-ba16f508c162',NULL,NULL,NULL,'{\"survey_no\": \"GIFT-SVY-2026-000004\"}',NULL,'6c36f84718f09e47b0d77263269b2baa','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:06:23.658208'),('25f86937-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.open','surveys','c8cfacf2-cacf-43de-91a5-57c7bcb5c1d7',NULL,NULL,NULL,'{\"survey_no\": \"GIFT-SVY-2026-000005\"}',NULL,'470527fbe1bb9f66f3af66c0ffeadee5','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:06:23.728624'),('25fb1531-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.open','surveys','829ea486-456b-44e3-883d-5cc97b7c6dc9',NULL,NULL,NULL,'{\"survey_no\": \"GIFT-SVY-2026-000003\"}',NULL,'587675d6ceed5ca24c41f1a17f1ac3da','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:06:23.746135'),('26e02118-8664-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'bf23afcce4f1b345d165ffa393de7e3e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 14:00:13.226987'),('274b023a-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'505ba0970ff6f5967cf9a1dc4927ecc3','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 13:53:04.430695'),('275ef6f5-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.update','customers','af4d13f9-693e-4ded-8009-a43ef878741a',NULL,NULL,'{\"id\": \"af4d13f9-693e-4ded-8009-a43ef878741a\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-iso-89537506@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:17Z\", \"updated_at\": \"2026-07-23T06:52:17Z\", \"customer_code\": \"U289537506\", \"customer_name\": \"UAT Isolation 89537506\", \"billing_address\": null, \"payment_term_days\": 14}','{\"id\": \"af4d13f9-693e-4ded-8009-a43ef878741a\", \"npwp\": null, \"status\": \"inactive\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-iso-89537506@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:17Z\", \"updated_at\": \"2026-07-23T06:53:04Z\", \"customer_code\": \"U289537506\", \"customer_name\": \"UAT Isolation 89537506\", \"billing_address\": null, \"payment_term_days\": 14}',NULL,'3633a25e044b120473c4415956f14ab1','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 13:53:04.561407'),('27624992-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.update','customers','16473014-ae6c-4ee8-8f7f-a34cfc63ab3a',NULL,NULL,'{\"id\": \"16473014-ae6c-4ee8-8f7f-a34cfc63ab3a\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-iso-89518363@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:51:58Z\", \"customer_code\": \"U289518363\", \"customer_name\": \"UAT Isolation 89518363\", \"billing_address\": null, \"payment_term_days\": 14}','{\"id\": \"16473014-ae6c-4ee8-8f7f-a34cfc63ab3a\", \"npwp\": null, \"status\": \"inactive\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-iso-89518363@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:53:04Z\", \"customer_code\": \"U289518363\", \"customer_name\": \"UAT Isolation 89518363\", \"billing_address\": null, \"payment_term_days\": 14}',NULL,'8a87ef9fa9b9fe95c32e26ddc1bda3aa','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 13:53:04.583217'),('2764a8ff-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.update','customers','cd0c0678-86f8-4f29-a44b-db12a4e481ec',NULL,NULL,'{\"id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89537506@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:17Z\", \"updated_at\": \"2026-07-23T06:52:17Z\", \"customer_code\": \"UAT89537506\", \"customer_name\": \"UAT Admin Finalisasi 89537506\", \"billing_address\": \"Alamat penagihan UAT\", \"payment_term_days\": 14}','{\"id\": \"cd0c0678-86f8-4f29-a44b-db12a4e481ec\", \"npwp\": null, \"status\": \"inactive\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89537506@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:52:17Z\", \"updated_at\": \"2026-07-23T06:53:04Z\", \"customer_code\": \"UAT89537506\", \"customer_name\": \"UAT Admin Finalisasi 89537506\", \"billing_address\": \"Alamat penagihan UAT\", \"payment_term_days\": 14}',NULL,'a8a37cf0b581cc61140f879b4313b5ab','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 13:53:04.598712'),('2766f852-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.update','customers','5581423d-c969-43b4-ba9b-b427ac1511ed',NULL,NULL,'{\"id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"npwp\": null, \"status\": \"active\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89518363@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:51:58Z\", \"customer_code\": \"UAT89518363\", \"customer_name\": \"UAT Admin Finalisasi 89518363\", \"billing_address\": \"Alamat penagihan UAT\", \"payment_term_days\": 14}','{\"id\": \"5581423d-c969-43b4-ba9b-b427ac1511ed\", \"npwp\": null, \"status\": \"inactive\", \"address\": \"Data uji lokal finalisasi menu Admin\", \"pic_name\": \"PIC UAT\", \"pic_email\": \"uat-89518363@example.test\", \"pic_phone\": \"0800000000\", \"created_at\": \"2026-07-23T06:51:58Z\", \"updated_at\": \"2026-07-23T06:53:04Z\", \"customer_code\": \"UAT89518363\", \"customer_name\": \"UAT Admin Finalisasi 89518363\", \"billing_address\": \"Alamat penagihan UAT\", \"payment_term_days\": 14}',NULL,'9d464c850b32b61d2d89157ef26989bf','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 13:53:04.613866'),('28d8d6cd-841c-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'c16ff4cc09854fc4ce40bb35e4298604','127.0.0.1','node','2026-07-20 16:19:50.444509'),('2aaf986c-841e-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'efabba6ecca179974321a6a7e2dac561','127.0.0.1','node','2026-07-20 16:34:12.523154'),('2bdc5205-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'efa94176066f46598bdd166e4364d422','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-28 10:41:09.392144'),('2c3d75d1-8664-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'3d6ff03157ea15e95110d1c7fc9299c2','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 14:00:22.227236'),('2d9ff607-81c6-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'369c11c9b4da6df2f61262bf29ca582a','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:59:19.416117'),('30f6e33d-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'e07bbc90757509e69ea21381bde005cd','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 10:41:17.954837'),('35b95996-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'c94d1e7a5fd2b8718be142ae40511f79','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 13:53:28.641918'),('38393f3f-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'757855e82346fbd9d53096a284de08ff','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-28 10:41:30.133834'),('384a3be2-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'c79331a11d8d2720a7df834c8cc9c3db','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-28 10:41:30.245103'),('38564586-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'b16c54d5abd5d11c295c990422e9c9b6','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-28 10:41:30.324053'),('38625bd1-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'97568f6d831fe2a260fe2449a32a2afd','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-28 10:41:30.403271'),('3931c25a-81c6-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'23bf44ebe960c75ff7e033d8948607d1','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:59:38.826525'),('393429d6-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'5ef2ad07c1db1ca4805799db2d924e1a','127.0.0.1',NULL,'2026-07-23 11:23:15.048644'),('39467cd6-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'d431e1c387023d4596112fe82a380521','127.0.0.1',NULL,'2026-07-23 11:23:15.168738'),('3957848a-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'3cd0a79f05aab6b79d27f1c28b173fc2','127.0.0.1',NULL,'2026-07-23 11:23:15.280340'),('39617afa-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.update_general','surveys','293e4859-83eb-4e36-9ab5-48fbe2f33bbf',NULL,NULL,'{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"need_revision\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"started_at\": \"2026-07-23T04:13:25Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"MSKU1234565\", \"final_remark\": \"UAT ISO CEDEX submit\", \"job_deadline\": null, \"job_order_id\": \"ba973397-9eee-4cf9-b987-9a2e4e727195\", \"job_order_no\": \"GIFT-JO-2026-000002\", \"submitted_at\": \"2026-07-23T04:21:45Z\", \"customer_code\": \"UAT-CUST-17B\", \"customer_name\": \"UAT Customer Scope 17B\", \"iso_type_code\": \"22G1\", \"location_code\": \"LOC-17B\", \"location_name\": \"Depot UAT 17B\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_instruction\": \"UAT fix verification\", \"job_container_id\": \"ef3108a3-5d1e-4832-af0b-eb174edc0675\", \"survey_type_code\": \"SV-17B\", \"survey_type_name\": \"Survey UAT 17B\", \"assignment_due_at\": null, \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"container_type_code\": \"CT-17B\", \"container_type_name\": \"Dry UAT\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"assignment_instruction\": \"UAT audit\"}','{\"id\": \"d9f784d4-864c-11f1-a160-002b67818c25\", \"seal_no\": \"UAT-ISO-CEDEX-20260723112314-APPROVE-SEAL\", \"survey_id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"cargo_status\": \"empty\", \"survey_date_time\": \"2026-07-23T04:23:15Z\", \"general_condition\": \"good\"}',NULL,'acac81578ecd3f26f93c6c4dfe2dcc08','127.0.0.1',NULL,'2026-07-23 11:23:15.345585'),('396662bc-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.update_checklist','surveys','293e4859-83eb-4e36-9ab5-48fbe2f33bbf',NULL,NULL,'{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"started_at\": \"2026-07-23T04:13:25Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"MSKU1234565\", \"final_remark\": \"UAT ISO CEDEX submit\", \"job_deadline\": null, \"job_order_id\": \"ba973397-9eee-4cf9-b987-9a2e4e727195\", \"job_order_no\": \"GIFT-JO-2026-000002\", \"submitted_at\": \"2026-07-23T04:21:45Z\", \"customer_code\": \"UAT-CUST-17B\", \"customer_name\": \"UAT Customer Scope 17B\", \"iso_type_code\": \"22G1\", \"location_code\": \"LOC-17B\", \"location_name\": \"Depot UAT 17B\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_instruction\": \"UAT fix verification\", \"job_container_id\": \"ef3108a3-5d1e-4832-af0b-eb174edc0675\", \"survey_type_code\": \"SV-17B\", \"survey_type_name\": \"Survey UAT 17B\", \"assignment_due_at\": null, \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"container_type_code\": \"CT-17B\", \"container_type_name\": \"Dry UAT\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"assignment_instruction\": \"UAT audit\"}','{\"survey_id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"total_items\": 1, \"completed_items\": 1}',NULL,'281d61bf094e8288cee3ecfaab5accc5','127.0.0.1',NULL,'2026-07-23 11:23:15.377729'),('396b9b4f-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.submit','surveys','293e4859-83eb-4e36-9ab5-48fbe2f33bbf',NULL,NULL,'{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"started_at\": \"2026-07-23T04:13:25Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"MSKU1234565\", \"final_remark\": \"UAT ISO CEDEX submit\", \"job_deadline\": null, \"job_order_id\": \"ba973397-9eee-4cf9-b987-9a2e4e727195\", \"job_order_no\": \"GIFT-JO-2026-000002\", \"submitted_at\": \"2026-07-23T04:21:45Z\", \"customer_code\": \"UAT-CUST-17B\", \"customer_name\": \"UAT Customer Scope 17B\", \"iso_type_code\": \"22G1\", \"location_code\": \"LOC-17B\", \"location_name\": \"Depot UAT 17B\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_instruction\": \"UAT fix verification\", \"job_container_id\": \"ef3108a3-5d1e-4832-af0b-eb174edc0675\", \"survey_type_code\": \"SV-17B\", \"survey_type_name\": \"Survey UAT 17B\", \"assignment_due_at\": null, \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"container_type_code\": \"CT-17B\", \"container_type_name\": \"Dry UAT\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"assignment_instruction\": \"UAT audit\"}','{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"submitted_at\": \"2026-07-23T04:23:15Z\"}',NULL,'08c14a68fe08269476cbe6acbfc72d6d','127.0.0.1',NULL,'2026-07-23 11:23:15.411961'),('3972dbe9-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','reviews.approve','surveys','293e4859-83eb-4e36-9ab5-48fbe2f33bbf',NULL,NULL,'{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"approved_at\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"MSKU1234565\", \"job_order_id\": \"ba973397-9eee-4cf9-b987-9a2e4e727195\", \"job_order_no\": \"GIFT-JO-2026-000002\", \"submitted_at\": \"2026-07-23T04:23:15Z\", \"customer_name\": \"UAT Customer Scope 17B\", \"location_name\": \"Depot UAT 17B\", \"survey_result\": \"sound\", \"surveyor_name\": \"Surveyor Demo\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_container_id\": \"ef3108a3-5d1e-4832-af0b-eb174edc0675\", \"survey_type_name\": \"Survey UAT 17B\", \"current_revision_no\": 1}','{\"status\": \"approved\", \"report_no\": \"GIFT-RPT-2026-000001\", \"survey_id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"report_generation_status\": \"queued\"}',NULL,'c77eb686d868ec6afb3c25a1ac490d78','127.0.0.1',NULL,'2026-07-23 11:23:15.459467'),('397c64d3-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','jobs.create','jobs','1b39e6d9-c766-41ae-bdfb-24b53e76eaa9',NULL,NULL,NULL,'{\"id\": \"1b39e6d9-c766-41ae-bdfb-24b53e76eaa9\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000003\"}',NULL,'89edc9ff48b721def5282df65e13dd0a','127.0.0.1',NULL,'2026-07-23 11:23:15.522029'),('397dffc2-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','job_containers.create','job_containers','37e74fda-ed4b-499a-a6a0-849adfeb99b7',NULL,NULL,NULL,'{\"id\": \"37e74fda-ed4b-499a-a6a0-849adfeb99b7\", \"status\": \"not_started\", \"container_no\": \"CSQU3054383\", \"check_digit_status\": \"valid\"}',NULL,'0079413ce59e76ed3c4386340e3298b9','127.0.0.1',NULL,'2026-07-23 11:23:15.532545'),('397feb80-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','assignments.assign','assignments','14c3da84-9072-4fdd-a806-9f0dfe9d012f',NULL,NULL,NULL,'{\"id\": \"14c3da84-9072-4fdd-a806-9f0dfe9d012f\", \"status\": \"assigned\", \"due_date\": null, \"start_date\": null, \"instruction\": \"UAT-ISO-CEDEX-20260723112314 synthetic reject\", \"assignment_no\": \"GIFT-ASG-2026-000002\", \"assigned_containers\": 1}',NULL,'22d38efeccd2e330bdc264e2ad01184e','127.0.0.1',NULL,'2026-07-23 11:23:15.545129'),('39820567-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.start','surveys','724d3aea-49fb-41de-82ce-05d35a394925',NULL,NULL,NULL,'{\"id\": \"724d3aea-49fb-41de-82ce-05d35a394925\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000002\", \"container_no\": \"CSQU3054383\", \"job_order_no\": \"GIFT-JO-2026-000003\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\"}',NULL,'62f85ef289336c36053960b18e10a2c1','127.0.0.1',NULL,'2026-07-23 11:23:15.558905'),('39845dfd-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.update_general','surveys','724d3aea-49fb-41de-82ce-05d35a394925',NULL,NULL,'{\"id\": \"724d3aea-49fb-41de-82ce-05d35a394925\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000002\", \"started_at\": \"2026-07-23T04:23:15Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"CSQU3054383\", \"final_remark\": null, \"job_deadline\": null, \"job_order_id\": \"1b39e6d9-c766-41ae-bdfb-24b53e76eaa9\", \"job_order_no\": \"GIFT-JO-2026-000003\", \"submitted_at\": null, \"customer_code\": \"UAT-CUST-17B\", \"customer_name\": \"UAT Customer Scope 17B\", \"iso_type_code\": \"22G1\", \"location_code\": \"LOC-17B\", \"location_name\": \"Depot UAT 17B\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_instruction\": \"UAT-ISO-CEDEX-20260723112314 synthetic reject\", \"job_container_id\": \"37e74fda-ed4b-499a-a6a0-849adfeb99b7\", \"survey_type_code\": \"SV-17B\", \"survey_type_name\": \"Survey UAT 17B\", \"assignment_due_at\": null, \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"container_type_code\": \"CT-17B\", \"container_type_name\": \"Dry UAT\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"assignment_instruction\": \"UAT-ISO-CEDEX-20260723112314 synthetic reject\"}','{\"id\": \"398193a5-864e-11f1-a160-002b67818c25\", \"seal_no\": \"UAT-ISO-CEDEX-20260723112314-REJECT-SEAL\", \"survey_id\": \"724d3aea-49fb-41de-82ce-05d35a394925\", \"cargo_status\": \"empty\", \"survey_date_time\": \"2026-07-23T04:23:15Z\", \"general_condition\": \"good\"}',NULL,'31c65f02c45b332319db77b825bc62c6','127.0.0.1',NULL,'2026-07-23 11:23:15.574233'),('3986216d-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.update_checklist','surveys','724d3aea-49fb-41de-82ce-05d35a394925',NULL,NULL,'{\"id\": \"724d3aea-49fb-41de-82ce-05d35a394925\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000002\", \"started_at\": \"2026-07-23T04:23:15Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"CSQU3054383\", \"final_remark\": null, \"job_deadline\": null, \"job_order_id\": \"1b39e6d9-c766-41ae-bdfb-24b53e76eaa9\", \"job_order_no\": \"GIFT-JO-2026-000003\", \"submitted_at\": null, \"customer_code\": \"UAT-CUST-17B\", \"customer_name\": \"UAT Customer Scope 17B\", \"iso_type_code\": \"22G1\", \"location_code\": \"LOC-17B\", \"location_name\": \"Depot UAT 17B\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_instruction\": \"UAT-ISO-CEDEX-20260723112314 synthetic reject\", \"job_container_id\": \"37e74fda-ed4b-499a-a6a0-849adfeb99b7\", \"survey_type_code\": \"SV-17B\", \"survey_type_name\": \"Survey UAT 17B\", \"assignment_due_at\": null, \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"container_type_code\": \"CT-17B\", \"container_type_name\": \"Dry UAT\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"assignment_instruction\": \"UAT-ISO-CEDEX-20260723112314 synthetic reject\"}','{\"survey_id\": \"724d3aea-49fb-41de-82ce-05d35a394925\", \"total_items\": 1, \"completed_items\": 1}',NULL,'12ff3742e94104b7ff1dcfc29ad5e253','127.0.0.1',NULL,'2026-07-23 11:23:15.585800'),('398a8139-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.submit','surveys','724d3aea-49fb-41de-82ce-05d35a394925',NULL,NULL,'{\"id\": \"724d3aea-49fb-41de-82ce-05d35a394925\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000002\", \"started_at\": \"2026-07-23T04:23:15Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"CSQU3054383\", \"final_remark\": null, \"job_deadline\": null, \"job_order_id\": \"1b39e6d9-c766-41ae-bdfb-24b53e76eaa9\", \"job_order_no\": \"GIFT-JO-2026-000003\", \"submitted_at\": null, \"customer_code\": \"UAT-CUST-17B\", \"customer_name\": \"UAT Customer Scope 17B\", \"iso_type_code\": \"22G1\", \"location_code\": \"LOC-17B\", \"location_name\": \"Depot UAT 17B\", \"surveyor_name\": \"Surveyor Demo\", \"container_size\": \"20\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_instruction\": \"UAT-ISO-CEDEX-20260723112314 synthetic reject\", \"job_container_id\": \"37e74fda-ed4b-499a-a6a0-849adfeb99b7\", \"survey_type_code\": \"SV-17B\", \"survey_type_name\": \"Survey UAT 17B\", \"assignment_due_at\": null, \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"container_type_code\": \"CT-17B\", \"container_type_name\": \"Dry UAT\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"assignment_instruction\": \"UAT-ISO-CEDEX-20260723112314 synthetic reject\"}','{\"id\": \"724d3aea-49fb-41de-82ce-05d35a394925\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000002\", \"submitted_at\": \"2026-07-23T04:23:15Z\"}',NULL,'727de240ffb0eda4d70a2e4d1d2a9386','127.0.0.1',NULL,'2026-07-23 11:23:15.614464'),('398e4686-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','reviews.reject','surveys','724d3aea-49fb-41de-82ce-05d35a394925',NULL,NULL,'{\"id\": \"724d3aea-49fb-41de-82ce-05d35a394925\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000002\", \"approved_at\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"CSQU3054383\", \"job_order_id\": \"1b39e6d9-c766-41ae-bdfb-24b53e76eaa9\", \"job_order_no\": \"GIFT-JO-2026-000003\", \"submitted_at\": \"2026-07-23T04:23:15Z\", \"customer_name\": \"UAT Customer Scope 17B\", \"location_name\": \"Depot UAT 17B\", \"survey_result\": \"sound\", \"surveyor_name\": \"Surveyor Demo\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_container_id\": \"37e74fda-ed4b-499a-a6a0-849adfeb99b7\", \"survey_type_name\": \"Survey UAT 17B\", \"current_revision_no\": 0}','{\"status\": \"rejected\", \"survey_id\": \"724d3aea-49fb-41de-82ce-05d35a394925\", \"rejection_reason\": \"UAT-ISO-CEDEX-20260723112314 synthetic reject\"}',NULL,'d654312b8a1623c13ab40eae0615df66','127.0.0.1',NULL,'2026-07-23 11:23:15.639181'),('39eba4a1-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'95fb04edbf12eea74f04e2466c153416','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:06:57.199365'),('3a049e2b-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'483bc375c91b886edd863a836a9a7bea','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:06:57.363047'),('3c2c23e3-7385-11f1-ac50-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'971018841986695fe355b950296994c1','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 13:39:10.256537'),('3c7662b4-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'4739da93940303f8fd48e0f69ae03185','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:51:58.502736'),('3c887f90-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'9d19dddb193961a9437a9363ac3b5f87','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:51:58.621426'),('3c8e3ed0-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','assignments.assign','assignments','77196b64-3748-429f-ad4f-083fdb122e61',NULL,NULL,NULL,'{\"id\": \"77196b64-3748-429f-ad4f-083fdb122e61\", \"status\": \"assigned\", \"due_date\": null, \"start_date\": null, \"instruction\": \"UAT-ISO-CEDEX-20260723115158-DAMAGE\", \"assignment_no\": \"GIFT-ASG-2026-000004\", \"assigned_containers\": 1}',NULL,'5b315a63a9e8ca0d8a8a603f72e10907','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:51:58.659098'),('3c9238cb-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.start','surveys','829ea486-456b-44e3-883d-5cc97b7c6dc9',NULL,NULL,NULL,'{\"id\": \"829ea486-456b-44e3-883d-5cc97b7c6dc9\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000003\", \"container_no\": \"MSKU1234567\", \"job_order_no\": \"GIFT-JO-2026-000004\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\"}',NULL,'916674e3fd0c955b216b4bd48e2f1e5c','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:51:58.685159'),('3fbb1b9d-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'dfeaf6317d6c5e9edbbb05e4ec7b5ad8','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:52:40.296283'),('400b11e6-8fd2-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'3f0b6c8f9f00315b6c509dcaaa760de8','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-04 14:01:00.556669'),('4020d75b-81c6-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'28c3e139ee4aa5303337a39a9d830276','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:59:50.459735'),('42200c80-8b34-11f1-b11f-002b67818c25',NULL,NULL,'auth.login_failed','auth',NULL,NULL,NULL,NULL,NULL,NULL,'78ed03d3cebd0465711accf4174c6ec6','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-29 16:59:58.904022'),('472f7809-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'dbd57387bda18b491a7f1e1bd67a6960','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:07:19.454269'),('47820e97-89a2-11f1-b52d-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'8df5934d5a0e04b079fc9ca82f2b1bf4','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-27 17:02:30.260862'),('484d252e-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'8492a28970339102e40022b28b0a5739','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:52:18.365109'),('4b42ca91-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'f9163cbf4909a381c794beabb297abd0','127.0.0.1',NULL,'2026-07-23 11:09:26.350035'),('4b571de2-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.create','customers','1b36b739-2080-451a-9092-64b5b771167a',NULL,NULL,NULL,'{\"id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"npwp\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_code\": \"A0723110926-A\", \"customer_name\": \"UAT ISO CEDEX A0723110926 Customer A\", \"billing_address\": null, \"payment_term_days\": null}',NULL,'3dc5c40eb09c855f3eca46f289bed499','127.0.0.1',NULL,'2026-07-23 11:09:26.481977'),('4b587220-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.create','customers','9eaabd4d-581a-4c1d-811a-4e3253300088',NULL,NULL,NULL,'{\"id\": \"9eaabd4d-581a-4c1d-811a-4e3253300088\", \"npwp\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_code\": \"A0723110926-B\", \"customer_name\": \"UAT ISO CEDEX A0723110926 Customer B\", \"billing_address\": null, \"payment_term_days\": null}',NULL,'262d9f59122d9d23f5ce3efac8e6ff42','127.0.0.1',NULL,'2026-07-23 11:09:26.491948'),('4b5c9dac-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','locations.create','locations','125db3af-9ece-4614-81a2-ae151bccadb4',NULL,NULL,NULL,'{\"id\": \"125db3af-9ece-4614-81a2-ae151bccadb4\", \"city\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"LCA0723110926\", \"location_name\": \"UAT Location A0723110926\", \"location_type\": \"depot\"}',NULL,'35badcc379dc804bdd4006781183de1d','127.0.0.1',NULL,'2026-07-23 11:09:26.519270'),('4b5f0663-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','locations.create','locations','a13b6587-4a4c-488b-ba09-91b7c6023b75',NULL,NULL,NULL,'{\"id\": \"a13b6587-4a4c-488b-ba09-91b7c6023b75\", \"city\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"9eaabd4d-581a-4c1d-811a-4e3253300088\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"LCA0723110926\", \"location_name\": \"UAT Location A0723110926\", \"location_type\": \"depot\"}',NULL,'497c2e0dac029c57f2b50eabaae6bef5','127.0.0.1',NULL,'2026-07-23 11:09:26.535049'),('4b68da27-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.create','customer_personnel','a11cea62-7e88-46d3-be07-fed3d7920b43',NULL,NULL,NULL,'{\"id\": \"a11cea62-7e88-46d3-be07-fed3d7920b43\", \"name\": \"UAT Personel A0723110926\", \"email\": \"uat.a0723110926@example.test\", \"notes\": null, \"phone\": null, \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"personnel_code\": \"PICA0723110926\", \"personnel_type\": \"pic\", \"position_title\": \"PIC UAT\"}',NULL,'f0c8898a382c780986eb0df4b64b61cb','127.0.0.1',NULL,'2026-07-23 11:09:26.599472'),('4b6a4694-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.create','customer_personnel','649cbf15-be94-4625-a3a9-51e2ca35bd93',NULL,NULL,NULL,'{\"id\": \"649cbf15-be94-4625-a3a9-51e2ca35bd93\", \"name\": \"UAT Personel A0723110926\", \"email\": \"uat.a0723110926@example.test\", \"notes\": null, \"phone\": null, \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"9eaabd4d-581a-4c1d-811a-4e3253300088\", \"personnel_code\": \"PICA0723110926\", \"personnel_type\": \"pic\", \"position_title\": \"PIC UAT\"}',NULL,'d41dab6aa92b190f1df67e1a4cf364e7','127.0.0.1',NULL,'2026-07-23 11:09:26.608795'),('4b6b85ed-8662-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'413354463c322d281dd20698ae95aeeb','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 13:46:55.544880'),('4b6d9700-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','container_types.create','container_types','53b504da-35d4-49f7-a1cc-3ea76aef2642',NULL,NULL,NULL,'{\"id\": \"53b504da-35d4-49f7-a1cc-3ea76aef2642\", \"code\": \"CTA0723110926\", \"size\": \"20\", \"type\": \"Dry General\", \"status\": \"active\", \"iso_code\": \"22G1\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\"}',NULL,'0e664285b97757cf0067f44787aa4715','127.0.0.1',NULL,'2026-07-23 11:09:26.630532'),('4b6f2e26-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','container_types.create','container_types','34d2298d-dbe3-465c-8117-ae7217269e31',NULL,NULL,NULL,'{\"id\": \"34d2298d-dbe3-465c-8117-ae7217269e31\", \"code\": \"CTA0723110926\", \"size\": \"20\", \"type\": \"Dry General\", \"status\": \"active\", \"iso_code\": \"22G1\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"9eaabd4d-581a-4c1d-811a-4e3253300088\", \"description\": \"UAT\"}',NULL,'f6b562cd5be19fc539bdefef7484fc64','127.0.0.1',NULL,'2026-07-23 11:09:26.640953'),('4b72f5de-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','survey_types.create','survey_types','fe6f2dac-a29e-4350-85ad-7ee437030687',NULL,NULL,NULL,'{\"id\": \"fe6f2dac-a29e-4350-85ad-7ee437030687\", \"code\": \"STA0723110926\", \"name\": \"UAT Survey A0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"requires_eir\": 0, \"requires_light_test\": 0, \"requires_cargo_worthy_result\": 0}',NULL,'0d8d60124f9dfe58c1ef9a7a4b7b5e81','127.0.0.1',NULL,'2026-07-23 11:09:26.665722'),('4b742325-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','survey_types.create','survey_types','7a3da078-9a7e-4cfa-bed4-a3283eab1023',NULL,NULL,NULL,'{\"id\": \"7a3da078-9a7e-4cfa-bed4-a3283eab1023\", \"code\": \"STA0723110926\", \"name\": \"UAT Survey A0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"9eaabd4d-581a-4c1d-811a-4e3253300088\", \"description\": \"UAT\", \"requires_eir\": 0, \"requires_light_test\": 0, \"requires_cargo_worthy_result\": 0}',NULL,'fa3b3bc18f8e28fe43e4c575e8a88fe3','127.0.0.1',NULL,'2026-07-23 11:09:26.673439'),('4b777e8d-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_locations.create','cedex_locations','2c3418aa-0e5a-4a04-adb9-6fa60c75e402',NULL,NULL,NULL,'{\"id\": \"2c3418aa-0e5a-4a04-adb9-6fa60c75e402\", \"code\": \"CLA0723110926\", \"face\": \"left\", \"status\": \"active\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"display_order\": 999, \"container_size\": \"all\", \"cedex_mapping_code\": \"CLA0723110926\"}',NULL,'0ce05c82bb25aaa6abf5c619305dc938','127.0.0.1',NULL,'2026-07-23 11:09:26.695437'),('4b78ad88-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_locations.create','cedex_locations','443fab73-cf3e-4125-a50e-8861d40a4d04',NULL,NULL,NULL,'{\"id\": \"443fab73-cf3e-4125-a50e-8861d40a4d04\", \"code\": \"CLA0723110926\", \"face\": \"left\", \"status\": \"active\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"9eaabd4d-581a-4c1d-811a-4e3253300088\", \"description\": \"UAT\", \"display_order\": 999, \"container_size\": \"all\", \"cedex_mapping_code\": \"CLA0723110926\"}',NULL,'c9d9015527d8bb34afe367c42ca263ca','127.0.0.1',NULL,'2026-07-23 11:09:26.703193'),('4b7be5ac-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_components.create','cedex_components','2c6cec18-e5fd-49fa-a8f4-4696de377640',NULL,NULL,NULL,'{\"id\": \"2c6cec18-e5fd-49fa-a8f4-4696de377640\", \"code\": \"CCA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"component_name\": \"UAT Component A0723110926\"}',NULL,'2a1f2a372656c88b28f74934ba007e69','127.0.0.1',NULL,'2026-07-23 11:09:26.724283'),('4b7cfa4c-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_components.create','cedex_components','aeed8eb9-bcc3-4d4a-b6af-65be7210837e',NULL,NULL,NULL,'{\"id\": \"aeed8eb9-bcc3-4d4a-b6af-65be7210837e\", \"code\": \"CCA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"9eaabd4d-581a-4c1d-811a-4e3253300088\", \"description\": \"UAT\", \"component_name\": \"UAT Component A0723110926\"}',NULL,'b67e25bf2dfebb7ecb0beffae685f6a4','127.0.0.1',NULL,'2026-07-23 11:09:26.731380'),('4b808b96-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_damages.create','cedex_damages','e2274dde-56f4-4551-9344-e7dfbd509399',NULL,NULL,NULL,'{\"id\": \"e2274dde-56f4-4551-9344-e7dfbd509399\", \"code\": \"CDA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"damage_name\": \"UAT Damage A0723110926\", \"description\": \"UAT\"}',NULL,'54ed622021135e69f64d7245ccd5e2f2','127.0.0.1',NULL,'2026-07-23 11:09:26.754757'),('4b81be15-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_damages.create','cedex_damages','f7b86ee5-6b34-4fb3-8acf-255626e80629',NULL,NULL,NULL,'{\"id\": \"f7b86ee5-6b34-4fb3-8acf-255626e80629\", \"code\": \"CDA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"9eaabd4d-581a-4c1d-811a-4e3253300088\", \"damage_name\": \"UAT Damage A0723110926\", \"description\": \"UAT\"}',NULL,'d6ec8e1836b566cc8d495b8ce593907c','127.0.0.1',NULL,'2026-07-23 11:09:26.762603'),('4b854b22-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.create','cedex_repairs','6fdb8cd5-3074-4cb1-a694-4e9225a67923',NULL,NULL,NULL,'{\"id\": \"6fdb8cd5-3074-4cb1-a694-4e9225a67923\", \"code\": \"CRA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"repair_name\": \"UAT Repair A0723110926\"}',NULL,'987e28371551854715aaa1393acd2434','127.0.0.1',NULL,'2026-07-23 11:09:26.785874'),('4b868b1d-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.create','cedex_repairs','54ec9f74-3ea5-4d51-a161-01cc9706d8b7',NULL,NULL,NULL,'{\"id\": \"54ec9f74-3ea5-4d51-a161-01cc9706d8b7\", \"code\": \"CRA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"9eaabd4d-581a-4c1d-811a-4e3253300088\", \"description\": \"UAT\", \"repair_name\": \"UAT Repair A0723110926\"}',NULL,'bde935fdea6deaa94b53769beb846183','127.0.0.1',NULL,'2026-07-23 11:09:26.794052'),('4b8de737-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_materials.create','cedex_materials','8fb913ce-25f7-4085-8059-0629d2667c50',NULL,NULL,NULL,'{\"id\": \"8fb913ce-25f7-4085-8059-0629d2667c50\", \"code\": \"CMA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"material_name\": \"UAT Material A0723110926\"}',NULL,'af53e3206a669a04b3671e709d634251','127.0.0.1',NULL,'2026-07-23 11:09:26.842296'),('4b8f2d00-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_materials.create','cedex_materials','1dcd6e09-e845-413f-8011-f4f82a4861d5',NULL,NULL,NULL,'{\"id\": \"1dcd6e09-e845-413f-8011-f4f82a4861d5\", \"code\": \"CMA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"9eaabd4d-581a-4c1d-811a-4e3253300088\", \"description\": \"UAT\", \"material_name\": \"UAT Material A0723110926\"}',NULL,'9dec042f984dcb39abe76ebf35bc23da','127.0.0.1',NULL,'2026-07-23 11:09:26.850637'),('4b92da49-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','responsibility_codes.create','responsibility_codes','a2b618be-967b-41a6-8c82-23008363d1f5',NULL,NULL,NULL,'{\"id\": \"a2b618be-967b-41a6-8c82-23008363d1f5\", \"code\": \"RCA0723110926\", \"name\": \"UAT Responsibility A0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\"}',NULL,'459329f94d71010186f69d43dcdf34a4','127.0.0.1',NULL,'2026-07-23 11:09:26.874719'),('4b940e1f-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','responsibility_codes.create','responsibility_codes','a638ef25-1cad-40f3-b012-6ae1b855bbe8',NULL,NULL,NULL,'{\"id\": \"a638ef25-1cad-40f3-b012-6ae1b855bbe8\", \"code\": \"RCA0723110926\", \"name\": \"UAT Responsibility A0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"9eaabd4d-581a-4c1d-811a-4e3253300088\", \"description\": \"UAT\"}',NULL,'1bfbb0b2b33d839379d0c82604d9d6bb','127.0.0.1',NULL,'2026-07-23 11:09:26.882593'),('4bb15d7d-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','jobs.create','jobs','cda39d6b-da4f-4c29-b08b-3f8409ccfa99',NULL,NULL,NULL,'{\"id\": \"cda39d6b-da4f-4c29-b08b-3f8409ccfa99\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000001\"}',NULL,'fa57de282a626d588c2ff4eb0276161b','127.0.0.1',NULL,'2026-07-23 11:09:27.074618'),('4bb70a11-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_components.create','cedex_components','c8c723b2-243f-44fa-ac56-3d5b0bb3b8f5',NULL,NULL,NULL,'{\"id\": \"c8c723b2-243f-44fa-ac56-3d5b0bb3b8f5\", \"code\": \"TCA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:27Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"component_name\": \"Tamper Route\"}',NULL,'744f556de7fcff2b93e254628bfe3abe','127.0.0.1',NULL,'2026-07-23 11:09:27.111847'),('4bc41f00-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'df579f0d09d4b0daea9693c36a8fbb09','127.0.0.1',NULL,'2026-07-23 11:09:27.197598'),('4bcad946-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','inspection_test_parameters.create','inspection_test_parameters','52a2a24a-024f-437c-a59d-29f79013ae27',NULL,NULL,NULL,'{\"id\": \"52a2a24a-024f-437c-a59d-29f79013ae27\", \"code\": \"TPA0723110926\", \"unit\": null, \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:27Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"description\": \"UAT\", \"display_order\": 999, \"parameter_name\": \"UAT Parameter A0723110926\", \"standard_reference\": null, \"requires_attachment\": 0, \"requires_numeric_result\": 0, \"applies_to_new_container\": 1, \"applies_to_existing_container\": 1}',NULL,'1a5f40bd683543466fd3afe954599a76','127.0.0.1',NULL,'2026-07-23 11:09:27.241704'),('4bcc88c7-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','inspection_test_parameters.update','inspection_test_parameters','52a2a24a-024f-437c-a59d-29f79013ae27',NULL,NULL,'{\"id\": \"52a2a24a-024f-437c-a59d-29f79013ae27\", \"code\": \"TPA0723110926\", \"unit\": null, \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:27Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"description\": \"UAT\", \"display_order\": 999, \"parameter_name\": \"UAT Parameter A0723110926\", \"standard_reference\": null, \"requires_attachment\": 0, \"requires_numeric_result\": 0, \"applies_to_new_container\": 1, \"applies_to_existing_container\": 1}','{\"id\": \"52a2a24a-024f-437c-a59d-29f79013ae27\", \"code\": \"TPA0723110926\", \"unit\": null, \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:09:27Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"description\": \"UAT\", \"display_order\": 999, \"parameter_name\": \"UAT Parameter A0723110926\", \"standard_reference\": null, \"requires_attachment\": 0, \"requires_numeric_result\": 0, \"applies_to_new_container\": 1, \"applies_to_existing_container\": 1}',NULL,'8353443e57da187cc255682166506045','127.0.0.1',NULL,'2026-07-23 11:09:27.252722'),('4bcf8e8c-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','finding_severities.create','finding_severities','471c4676-df8c-4e59-9649-55e546cdb3cc',NULL,NULL,NULL,'{\"id\": \"471c4676-df8c-4e59-9649-55e546cdb3cc\", \"code\": \"FSA0723110926\", \"name\": \"UAT Severity A0723110926\", \"status\": \"active\", \"level_no\": 99, \"badge_tone\": \"neutral\", \"created_at\": \"2026-07-23T04:09:27Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"description\": \"UAT\", \"affects_fitness_default\": 0, \"requires_supervisor_review\": 0}',NULL,'85e6e0c02d9f33ff9fb2cad529f50785','127.0.0.1',NULL,'2026-07-23 11:09:27.272567'),('4bd0e03c-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','finding_severities.update','finding_severities','471c4676-df8c-4e59-9649-55e546cdb3cc',NULL,NULL,'{\"id\": \"471c4676-df8c-4e59-9649-55e546cdb3cc\", \"code\": \"FSA0723110926\", \"name\": \"UAT Severity A0723110926\", \"status\": \"active\", \"level_no\": 99, \"badge_tone\": \"neutral\", \"created_at\": \"2026-07-23T04:09:27Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"description\": \"UAT\", \"affects_fitness_default\": 0, \"requires_supervisor_review\": 0}','{\"id\": \"471c4676-df8c-4e59-9649-55e546cdb3cc\", \"code\": \"FSA0723110926\", \"name\": \"UAT Severity A0723110926\", \"status\": \"inactive\", \"level_no\": 99, \"badge_tone\": \"neutral\", \"created_at\": \"2026-07-23T04:09:27Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"description\": \"UAT\", \"affects_fitness_default\": 0, \"requires_supervisor_review\": 0}',NULL,'8a9746462a87fa667c27e697ee240a00','127.0.0.1',NULL,'2026-07-23 11:09:27.281198'),('4bd40d7a-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customer_personnel.update','customer_personnel','a11cea62-7e88-46d3-be07-fed3d7920b43',NULL,NULL,'{\"id\": \"a11cea62-7e88-46d3-be07-fed3d7920b43\", \"name\": \"UAT Personel A0723110926\", \"email\": \"uat.a0723110926@example.test\", \"notes\": null, \"phone\": null, \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"personnel_code\": \"PICA0723110926\", \"personnel_type\": \"pic\", \"position_title\": \"PIC UAT\"}','{\"id\": \"a11cea62-7e88-46d3-be07-fed3d7920b43\", \"name\": \"UAT Personel A0723110926\", \"email\": \"uat.a0723110926@example.test\", \"notes\": null, \"phone\": null, \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"personnel_code\": \"PICA0723110926\", \"personnel_type\": \"pic\", \"position_title\": \"PIC UAT\"}',NULL,'6377f2115c278c8a91e2393a4a7374d6','127.0.0.1',NULL,'2026-07-23 11:09:27.302007'),('4bd562c6-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_locations.update','cedex_locations','2c3418aa-0e5a-4a04-adb9-6fa60c75e402',NULL,NULL,'{\"id\": \"2c3418aa-0e5a-4a04-adb9-6fa60c75e402\", \"code\": \"CLA0723110926\", \"face\": \"left\", \"status\": \"active\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"display_order\": 999, \"container_size\": \"all\", \"cedex_mapping_code\": \"CLA0723110926\"}','{\"id\": \"2c3418aa-0e5a-4a04-adb9-6fa60c75e402\", \"code\": \"CLA0723110926\", \"face\": \"left\", \"status\": \"inactive\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"display_order\": 999, \"container_size\": \"all\", \"cedex_mapping_code\": \"CLA0723110926\"}',NULL,'37806dcc09aac268f88ef76bf9d42682','127.0.0.1',NULL,'2026-07-23 11:09:27.310755'),('4bd6b427-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_repairs.update','cedex_repairs','6fdb8cd5-3074-4cb1-a694-4e9225a67923',NULL,NULL,'{\"id\": \"6fdb8cd5-3074-4cb1-a694-4e9225a67923\", \"code\": \"CRA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"repair_name\": \"UAT Repair A0723110926\"}','{\"id\": \"6fdb8cd5-3074-4cb1-a694-4e9225a67923\", \"code\": \"CRA0723110926\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"repair_name\": \"UAT Repair A0723110926\"}',NULL,'2db02e67ebd93ea61cbcb488e4fd6462','127.0.0.1',NULL,'2026-07-23 11:09:27.319400'),('4bd812ad-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_components.update','cedex_components','2c6cec18-e5fd-49fa-a8f4-4696de377640',NULL,NULL,'{\"id\": \"2c6cec18-e5fd-49fa-a8f4-4696de377640\", \"code\": \"CCA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"component_name\": \"UAT Component A0723110926\"}','{\"id\": \"2c6cec18-e5fd-49fa-a8f4-4696de377640\", \"code\": \"CCA0723110926\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"component_name\": \"UAT Component A0723110926\"}',NULL,'02089b11ba2bc397a388a96e0315a13e','127.0.0.1',NULL,'2026-07-23 11:09:27.328368'),('4bd97bb7-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','container_types.update','container_types','53b504da-35d4-49f7-a1cc-3ea76aef2642',NULL,NULL,'{\"id\": \"53b504da-35d4-49f7-a1cc-3ea76aef2642\", \"code\": \"CTA0723110926\", \"size\": \"20\", \"type\": \"Dry General\", \"status\": \"active\", \"iso_code\": \"22G1\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\"}','{\"id\": \"53b504da-35d4-49f7-a1cc-3ea76aef2642\", \"code\": \"CTA0723110926\", \"size\": \"20\", \"type\": \"Dry General\", \"status\": \"inactive\", \"iso_code\": \"22G1\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\"}',NULL,'944b6dbd57959ef220c921ff2edd6774','127.0.0.1',NULL,'2026-07-23 11:09:27.337584'),('4bdb47b2-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','locations.update','locations','125db3af-9ece-4614-81a2-ae151bccadb4',NULL,NULL,'{\"id\": \"125db3af-9ece-4614-81a2-ae151bccadb4\", \"city\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"LCA0723110926\", \"location_name\": \"UAT Location A0723110926\", \"location_type\": \"depot\"}','{\"id\": \"125db3af-9ece-4614-81a2-ae151bccadb4\", \"city\": null, \"status\": \"inactive\", \"address\": \"UAT only\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"LCA0723110926\", \"location_name\": \"UAT Location A0723110926\", \"location_type\": \"depot\"}',NULL,'59cd57c6b5ddfe61923558bbf82cca41','127.0.0.1',NULL,'2026-07-23 11:09:27.349365'),('4bdd07d1-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','survey_types.update','survey_types','fe6f2dac-a29e-4350-85ad-7ee437030687',NULL,NULL,'{\"id\": \"fe6f2dac-a29e-4350-85ad-7ee437030687\", \"code\": \"STA0723110926\", \"name\": \"UAT Survey A0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"requires_eir\": 0, \"requires_light_test\": 0, \"requires_cargo_worthy_result\": 0}','{\"id\": \"fe6f2dac-a29e-4350-85ad-7ee437030687\", \"code\": \"STA0723110926\", \"name\": \"UAT Survey A0723110926\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"requires_eir\": 0, \"requires_light_test\": 0, \"requires_cargo_worthy_result\": 0}',NULL,'4b3038625785e1bfa1c0b283e5126f58','127.0.0.1',NULL,'2026-07-23 11:09:27.360856'),('4bde698a-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_materials.update','cedex_materials','8fb913ce-25f7-4085-8059-0629d2667c50',NULL,NULL,'{\"id\": \"8fb913ce-25f7-4085-8059-0629d2667c50\", \"code\": \"CMA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"material_name\": \"UAT Material A0723110926\"}','{\"id\": \"8fb913ce-25f7-4085-8059-0629d2667c50\", \"code\": \"CMA0723110926\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"material_name\": \"UAT Material A0723110926\"}',NULL,'ece7aefa5c5e831229e745c5598fc400','127.0.0.1',NULL,'2026-07-23 11:09:27.369920'),('4bdff4af-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_damages.update','cedex_damages','e2274dde-56f4-4551-9344-e7dfbd509399',NULL,NULL,'{\"id\": \"e2274dde-56f4-4551-9344-e7dfbd509399\", \"code\": \"CDA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"damage_name\": \"UAT Damage A0723110926\", \"description\": \"UAT\"}','{\"id\": \"e2274dde-56f4-4551-9344-e7dfbd509399\", \"code\": \"CDA0723110926\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"damage_name\": \"UAT Damage A0723110926\", \"description\": \"UAT\"}',NULL,'2142c33dd8616c0d875259c344047a51','127.0.0.1',NULL,'2026-07-23 11:09:27.380033'),('4be1d1d7-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','responsibility_codes.update','responsibility_codes','a2b618be-967b-41a6-8c82-23008363d1f5',NULL,NULL,'{\"id\": \"a2b618be-967b-41a6-8c82-23008363d1f5\", \"code\": \"RCA0723110926\", \"name\": \"UAT Responsibility A0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\"}','{\"id\": \"a2b618be-967b-41a6-8c82-23008363d1f5\", \"code\": \"RCA0723110926\", \"name\": \"UAT Responsibility A0723110926\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\"}',NULL,'30ab6e67b91513dd0c27eff3d5766302','127.0.0.1',NULL,'2026-07-23 11:09:27.392237'),('4be32cb7-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','cedex_components.update','cedex_components','c8c723b2-243f-44fa-ac56-3d5b0bb3b8f5',NULL,NULL,'{\"id\": \"c8c723b2-243f-44fa-ac56-3d5b0bb3b8f5\", \"code\": \"TCA0723110926\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:09:27Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"component_name\": \"Tamper Route\"}','{\"id\": \"c8c723b2-243f-44fa-ac56-3d5b0bb3b8f5\", \"code\": \"TCA0723110926\", \"status\": \"inactive\", \"created_at\": \"2026-07-23T04:09:27Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"description\": \"UAT\", \"component_name\": \"Tamper Route\"}',NULL,'0679cd40b0db9a73df7fbbe1b9e1d951','127.0.0.1',NULL,'2026-07-23 11:09:27.401120'),('4be48e13-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.update','customers','1b36b739-2080-451a-9092-64b5b771167a',NULL,NULL,'{\"id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"npwp\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_code\": \"A0723110926-A\", \"customer_name\": \"UAT ISO CEDEX A0723110926 Customer A\", \"billing_address\": null, \"payment_term_days\": null}','{\"id\": \"1b36b739-2080-451a-9092-64b5b771167a\", \"npwp\": null, \"status\": \"inactive\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_code\": \"A0723110926-A\", \"customer_name\": \"UAT ISO CEDEX A0723110926 Customer A\", \"billing_address\": null, \"payment_term_days\": null}',NULL,'9c7433232c86107594ec5a2016a54c57','127.0.0.1',NULL,'2026-07-23 11:09:27.410158'),('4be5c69b-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','customers.update','customers','9eaabd4d-581a-4c1d-811a-4e3253300088',NULL,NULL,'{\"id\": \"9eaabd4d-581a-4c1d-811a-4e3253300088\", \"npwp\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:26Z\", \"customer_code\": \"A0723110926-B\", \"customer_name\": \"UAT ISO CEDEX A0723110926 Customer B\", \"billing_address\": null, \"payment_term_days\": null}','{\"id\": \"9eaabd4d-581a-4c1d-811a-4e3253300088\", \"npwp\": null, \"status\": \"inactive\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-23T04:09:26Z\", \"updated_at\": \"2026-07-23T04:09:27Z\", \"customer_code\": \"A0723110926-B\", \"customer_name\": \"UAT ISO CEDEX A0723110926 Customer B\", \"billing_address\": null, \"payment_term_days\": null}',NULL,'9524e4284663c8b54fa062ed9276ba70','127.0.0.1',NULL,'2026-07-23 11:09:27.418170'),('4ecb7e61-8afa-11f1-85ad-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'6885f4218490c868c564d8f91dde12d0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-29 10:05:09.361133'),('4f40815a-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'7b7e338deff3dbb54b8629c7def48f9b','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:07:32.987655'),('4f57c4a2-81c7-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'eb4f044a4aef32edae87aa147fd9226b','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 17:07:25.481736'),('4f5e8b6e-81c7-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','survey_types.reference_options.update','survey_types','94e7124b-c5a8-4f27-8535-dd5618ee7caf',NULL,NULL,NULL,'{\"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"severity_ids\": [\"4821a7f4-79e5-11f1-a1f6-002b67818c25\"], \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"photo_category_ids\": [\"48278e9f-79e5-11f1-a1f6-002b67818c25\", \"4827a2e3-79e5-11f1-a1f6-002b67818c25\"], \"test_parameter_ids\": [\"4824f0f9-79e5-11f1-a1f6-002b67818c25\"]}',NULL,'efa14b01114ecb28858e7da7d5f2b9e1','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 17:07:25.525904'),('4f6dac99-8662-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'779fc44c21fd95073eb006d1a967f9a6','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 13:47:02.269915'),('4f96431d-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'c3fad34d9d5cfa04e085ed213910bb58','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-22 14:09:42.183534'),('50b1bd2b-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'c4dc18d3319c8622ed3d32abdf324e59','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-22 14:09:44.041309'),('51304c46-8b34-11f1-b11f-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'97eb90578a2c644a2cc9e5a3ac24bd6b','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-29 17:00:24.187560'),('5209c66a-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'4e065c220e2e584c0c7f9fa48a0b53d0','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:53:11.010834'),('52177fd0-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','customers.create','customers','fe540f39-80fa-4bf3-8795-08d5c022d9f2',NULL,NULL,NULL,'{\"id\": \"fe540f39-80fa-4bf3-8795-08d5c022d9f2\", \"npwp\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-17T09:53:11Z\", \"updated_at\": \"2026-07-17T09:53:11Z\", \"customer_code\": \"UAT-CUST-17\", \"customer_name\": \"UAT Customer Scope 17\", \"billing_address\": null, \"payment_term_days\": null}',NULL,'a25ea9807756776552acb7b389c0863b','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:53:11.099328'),('534c1d7b-8662-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'7dc9808a9366aca949e869de2fe1152f','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 13:47:08.760967'),('54d8ece5-768d-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.logout','auth',NULL,NULL,NULL,NULL,NULL,NULL,'c089169d09b2da5292ec04d5ae911354','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-03 10:14:41.116414'),('55404974-768b-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'b50954e0f3e0a9531bdc638ef52b00e4','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-03 10:00:22.800375'),('58610dd5-738c-11f1-ac50-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'785e358b96653181b77ad8b59d8073b0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.126.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-06-29 14:30:04.056611'),('591db6c7-768b-11f1-9885-002b67818c25',NULL,NULL,'auth.login_failed','auth',NULL,NULL,NULL,NULL,NULL,NULL,'df6b256e0a84a3ddbec2752c8e1abfbd','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-03 10:00:29.284647'),('5a07cae6-768b-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'28b2cf1e22c27715d7924e7075a2ff4e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-03 10:00:30.818737'),('5c086242-738c-11f1-ac50-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'52feb81954d1618bd2ad9a1995ef026e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-29 14:30:10.186369'),('5c704d71-8a5a-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'f10d643bb8e0cee3c2abd1a0a119bc30','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-28 15:00:12.774785'),('5fe3bd5a-7f2a-11f1-9e6a-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'325002dc7a46de477d7f53c36545cedd','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-14 09:18:59.931015'),('602d2e35-8647-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'c8ba04048970839381f8fc8d813d1046','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-23 10:34:13.956829'),('62f1a2a0-89a2-11f1-b52d-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'7b86d8654abcac5a8a0a15b0e785f104','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 17:03:16.290563'),('633214e3-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'e8c282f51ee5b2336d77a66f4ecc7429','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:53:39.796257'),('64abab0f-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'bd432b718afa743b31b3b95fb09742d7','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:10:08.980412'),('64bd6cec-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','evidence_photo_categories.create','evidence_photo_categories','e5f94595-e77d-4361-bf9f-aa2f71432f22',NULL,NULL,NULL,'{\"id\": \"e5f94595-e77d-4361-bf9f-aa2f71432f22\", \"code\": \"PCR0723111009\", \"name\": \"Retry Photo R0723111009\", \"status\": \"active\", \"applies_to\": \"inspection\", \"created_at\": \"2026-07-23T04:10:09Z\", \"updated_at\": \"2026-07-23T04:10:09Z\", \"description\": \"UAT\", \"display_order\": 999, \"is_required_default\": 0}',NULL,'bb5784b6cd9212a7410f8285ed651399','127.0.0.1',NULL,'2026-07-23 11:10:09.096755'),('6a8107ee-7e9c-11f1-b890-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'ab119b451bc236a7a6f975e8e406bb69','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-13 16:22:49.203306'),('6f36b314-864b-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'b0796c1d4a55d5365c6a0e3f4c75535a','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:03:17.172006'),('70584a28-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'13c1ee1cf4e80baf1b7445e87da4e776','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 13:55:06.991281'),('7155c7a8-864f-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'5155174d87e3d55d6468127171bb4ae4','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-23 11:31:58.718042'),('71afd9ba-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'47c9cc2cd3bb2dd72a8d0fa19ab8c831','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:08:30.759913'),('74475e75-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'cdb78c7b00f9dad21f03a004648c16ac','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 13:55:13.591358'),('772ad2a4-859b-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'79e945a14abccadaa07ffa7309938861','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-22 14:03:39.091526'),('7835a7e4-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'79edba73e9066b5d83e106f9633cd1a8','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 13:55:20.186212'),('7935e53b-864b-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'e7c86e7dd7eb157b2a40c99a6b4384be','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:03:33.944001'),('7a37e19c-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'1f2a3a750640f9402bf7ff818b416a0e','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-04 17:08:45.073186'),('7d79a876-8a6e-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'93e7189dbe3a6de2c0d42360a24f7bd5','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-28 17:24:18.135563'),('80e16b96-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'7baa551bb70aa381435e224b203599be','127.0.0.1','node','2026-07-28 10:43:32.031884'),('819707a7-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'05c9e9b0f002c25e7a00cbae14cab0d0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-22 14:11:06.074671'),('820abebb-768b-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.logout','auth',NULL,NULL,NULL,NULL,NULL,NULL,'b5992148f2ad24b072aa6d634923f029','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-03 10:01:37.946942'),('84a055f8-7e92-11f1-b890-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'28dd8548857aabb8a8d3fa538efe1cf8','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-13 15:11:58.061889'),('8541e6f9-768b-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'b56d65c33fd9b1786c2a258d06c4c0a0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-03 10:01:43.341584'),('8698cf07-864f-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'2e3f053d3e8a47e6c765abf5b855c4f6','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-23 11:32:34.389529'),('8906041e-8bc5-11f1-9154-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'ac33d014955b871cf4beb86d7185a88b','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-30 10:19:54.888606'),('8a03167f-859b-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'f79b152ccc3bfa445b1fc4d8eaadbac6','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-22 14:04:10.707878'),('8ba1bdbf-768b-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.logout','auth',NULL,NULL,NULL,NULL,NULL,NULL,'ed579e2ff7436e5543f5ce0cd9691c1e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-03 10:01:54.035994'),('8c32e8ad-8651-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'9d5d3f8dc71b354565eb74af05efab58','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-23 11:47:02.781466'),('8d078c18-768b-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'46a933b6c9cdb1c3ee33a387bd510625','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-03 10:01:56.380931'),('8fe92ade-859b-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'3a7ef8239662a49e392a7673caaa0314','::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-22 14:04:20.604296'),('94e69789-8a2d-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'16d584f3b5b4525aaa977684401e425b','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 09:39:40.149679'),('9bee65e8-8a2f-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'d2efb254febdbe697fb82e7d47e8b78c','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-28 09:54:10.938263'),('9cb2e1a7-8661-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'be1d0178f08f0b8ad2df4a89d4b8c3d0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 13:42:02.411386'),('9fbc1afb-8a62-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'3372e58a1b51e6be0ebe202054a95f27','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 15:59:21.652744'),('9fd27db0-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'262b9738dadc70550b01abbde3e3c01e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-22 14:11:56.795941'),('a0a3de39-7f41-11f1-9e6a-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'a1eabe85e9bb9a4aa0b6fc66a39025c8','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-14 12:05:26.989106'),('a12131ba-8660-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'0d33851e0f32a3888721baf2f960f2ba','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 13:35:00.348469'),('a13424fd-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'52e475d0417d3f57d6a7c79e03a2dde9','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-22 14:11:59.113695'),('a232acb9-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'eb6c65a2cc094aa07a69a928f67d17e7','127.0.0.1','node','2026-07-28 10:44:27.929269'),('a25a7d67-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'dd2207e59b5cfff34e83b0a0cedb5351','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-22 14:12:01.042680'),('a4aaf96d-8a40-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'b99720a14c8c2b56362d2db26467d92e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 11:56:07.040031'),('a548e314-8195-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'68912ae9dc117fe6fb29e1be41af8c6c','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-17 11:11:54.832272'),('a6c87f83-768b-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.logout','auth',NULL,NULL,NULL,NULL,NULL,NULL,'1c47a3557ba3a5f3b3be7866017412f0','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-03 10:02:39.588428'),('ab1be105-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'ea1f487250fe2324149f9f493edee71b','127.0.0.1','node','2026-07-28 10:44:42.879337'),('ad493875-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'2151334add20b566329aeb71302bef6a','127.0.0.1','node','2026-07-28 10:44:46.531958'),('ae7b20de-751d-11f1-8fe5-002b67818c25',NULL,NULL,'auth.login_failed','auth',NULL,NULL,NULL,NULL,NULL,NULL,'52c7260e32eea7b3c0cc68157d802dbb','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:22:56.700187'),('b06341d9-751f-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'9782ad8d3c163db5d2ad09a9c02bb7d3','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:37:18.892570'),('b158bfba-751d-11f1-8fe5-002b67818c25',NULL,NULL,'auth.login_failed','auth',NULL,NULL,NULL,NULL,NULL,NULL,'769d17285daf0e261058408288506dad','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:23:01.508037'),('b1ddaff5-751d-11f1-8fe5-002b67818c25',NULL,NULL,'auth.login_failed','auth',NULL,NULL,NULL,NULL,NULL,NULL,'83049c9a3c6bfa09a30a3c06d4bbd362','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:23:02.379236'),('b22b37af-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'0690a15b9c4dc56f11808fea9dace9f1','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:55:15.981226'),('b255ff0e-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','survey_damages.create','survey_damages','7d952d90-6b58-439d-b117-3df03f38f226',NULL,NULL,NULL,'{\"id\": \"7d952d90-6b58-439d-b117-3df03f38f226\", \"face\": \"left\", \"severity\": \"minor\", \"damage_no\": \"D-001\", \"internal_location\": \"L1\"}',NULL,'a0116b7547e1a4ec0e9eaaee68ec872a','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:55:16.261558'),('b25a6822-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','survey_damages.update','survey_damages','7d952d90-6b58-439d-b117-3df03f38f226',NULL,NULL,NULL,'{\"id\": \"7d952d90-6b58-439d-b117-3df03f38f226\", \"face\": \"left\", \"severity\": \"minor\", \"damage_no\": \"D-001\", \"internal_location\": \"L1\"}',NULL,'6ad1243bce34d79a34e2d697625e5498','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:55:16.290485'),('b28a8730-7f4c-11f1-9e6a-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'fd3af9a93c935b5f2bcd87e481eeb915','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-14 13:24:41.486020'),('b3faaf36-80d7-11f1-ae8c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'b0e85b262f523e85497c73d4cfdfd133','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-16 12:32:15.106716'),('b7784500-8a56-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'ec793844442a235a4961b2e0caf4cddd','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-28 14:34:07.512770'),('b7afb9e0-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'a2bb8f8e3902c54b87c6b9ae03c8b619','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:26:47.251296'),('b9899ac8-841d-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'9852065de736d5679088a4f60010cc0e','127.0.0.1','node','2026-07-20 16:31:02.691278'),('bb356e0b-80c1-11f1-ae8c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'3647b388004e25322eb78a483cb6df07','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-16 09:54:58.307934'),('bc7b7e0d-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'4bae32defa847e76394a2e140a258c5e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-22 14:12:44.879729'),('bd2aef80-768b-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'f38a9610bbb7851ceec2bc412f103997','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-03 10:03:17.143459'),('c188c49f-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'56f2003cc818b490fc3060a82b9edea6','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:08:57.254114'),('c1c20096-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'4c1652bbccc1c6ad02c3f4647a3815e6','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:55:42.135260'),('c1ccc1a4-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','survey_damages.delete','survey_damages','7d952d90-6b58-439d-b117-3df03f38f226',NULL,NULL,'{\"id\": \"7d952d90-6b58-439d-b117-3df03f38f226\", \"damage_no\": \"D-001\", \"survey_id\": \"829ea486-456b-44e3-883d-5cc97b7c6dc9\"}',NULL,NULL,'1ee7094e717625e47d6f0479d9555ec5','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:55:42.205651'),('c2614d49-751e-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'dccf7f824f812f8ed6e431bb8f6418d4','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:30:39.582087'),('c3f1dbfc-80d7-11f1-ae8c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'6f2799e116c0ce45bf1a0c497ced04b3','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-16 12:32:41.892631'),('c68b1eb6-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'2e9c96997dc26fe9760387f7615d5173','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:05.658069'),('c86fabcd-8189-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'b5114554cc340417260fad2cfac575e4','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-17 09:46:59.845947'),('c8f3e67a-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'caa4fcd582c2c25f7e7478e2cfbdfe1e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:09.700251'),('c946b2e2-76a2-11f1-974e-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'6397aca1c960beb5a6017077c2cb754d','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-03 12:48:15.882730'),('cae1b3a2-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'3bc98f0a26132e157da3308e61f1f5d9','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:56:33.752506'),('caecb10f-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','customers.create','customers','32aa190f-d0de-448d-b533-421da6e87ce9',NULL,NULL,NULL,'{\"id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"npwp\": null, \"status\": \"active\", \"address\": \"UAT only\", \"pic_name\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-17T09:56:33Z\", \"updated_at\": \"2026-07-17T09:56:33Z\", \"customer_code\": \"UAT-CUST-17B\", \"customer_name\": \"UAT Customer Scope 17B\", \"billing_address\": null, \"payment_term_days\": null}',NULL,'c9c665e41c46c4f37cca59eab4379d64','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:56:33.824263'),('caf3b902-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','customer_personnel.create','customer_personnel','11326687-6f63-49f8-a8f2-e53b6d3e47d0',NULL,NULL,NULL,'{\"id\": \"11326687-6f63-49f8-a8f2-e53b6d3e47d0\", \"name\": \"PIC UAT 17B\", \"email\": \"pic17b@example.test\", \"notes\": null, \"phone\": \"081700000018\", \"status\": \"active\", \"created_at\": \"2026-07-17T09:56:33Z\", \"updated_at\": \"2026-07-17T09:56:33Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"personnel_code\": \"PIC-17B\", \"personnel_type\": \"pic\", \"position_title\": \"Operations\"}',NULL,'696da3512dbbd834ca0565aabd53976d','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:56:33.870552'),('caf807dc-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','locations.create','locations','3fd7d149-4e43-4c0c-96ba-b846f4155d2b',NULL,NULL,NULL,'{\"id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"city\": \"Jakarta\", \"status\": \"active\", \"address\": \"UAT\", \"pic_name\": null, \"province\": null, \"pic_email\": null, \"pic_phone\": null, \"created_at\": \"2026-07-17T09:56:33Z\", \"updated_at\": \"2026-07-17T09:56:33Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"postal_code\": null, \"access_notes\": null, \"gps_latitude\": null, \"gps_longitude\": null, \"location_code\": \"LOC-17B\", \"location_name\": \"Depot UAT 17B\", \"location_type\": \"depot\"}',NULL,'2347e36a5d5d67fab01d3185a6b054d1','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:56:33.898730'),('cafaaaee-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','survey_types.create','survey_types','94e7124b-c5a8-4f27-8535-dd5618ee7caf',NULL,NULL,NULL,'{\"id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"code\": \"SV-17B\", \"name\": \"Survey UAT 17B\", \"status\": \"active\", \"created_at\": \"2026-07-17T09:56:33Z\", \"updated_at\": \"2026-07-17T09:56:33Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"description\": \"Customer scoped UAT\", \"requires_eir\": 1, \"requires_light_test\": 1, \"requires_cargo_worthy_result\": 1}',NULL,'e2a9d671706ffc6c9e24459abfce5169','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:56:33.916088'),('cafc6f05-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','container_types.create','container_types','06132cac-4ae5-4b80-9b07-417edcf756f1',NULL,NULL,NULL,'{\"id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"code\": \"CT-17B\", \"size\": \"20\", \"type\": \"Dry UAT\", \"status\": \"active\", \"iso_code\": \"22G1\", \"created_at\": \"2026-07-17T09:56:33Z\", \"updated_at\": \"2026-07-17T09:56:33Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"description\": \"Customer scoped UAT\"}',NULL,'384ff445478330bcee26644b31da9c01','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:56:33.927707'),('cafe6dd2-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','cedex_locations.create','cedex_locations','671b9126-54cd-4d03-8724-edc95506a0ad',NULL,NULL,NULL,'{\"id\": \"671b9126-54cd-4d03-8724-edc95506a0ad\", \"code\": \"L17B\", \"face\": \"left\", \"status\": \"active\", \"grid_code\": \"L1\", \"created_at\": \"2026-07-17T09:56:33Z\", \"updated_at\": \"2026-07-17T09:56:33Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"description\": \"Left grid\", \"display_order\": 1, \"container_size\": \"20\", \"cedex_mapping_code\": \"L1\"}',NULL,'71c3a90bb35ee66b135c7233e03a5e10','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:56:33.940776'),('cb0035b4-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','cedex_components.create','cedex_components','0c4b9c89-45b0-4bc0-9af7-2d2f720112df',NULL,NULL,NULL,'{\"id\": \"0c4b9c89-45b0-4bc0-9af7-2d2f720112df\", \"code\": \"CMP17B\", \"status\": \"active\", \"created_at\": \"2026-07-17T09:56:33Z\", \"updated_at\": \"2026-07-17T09:56:33Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"description\": \"UAT\", \"component_name\": \"Panel UAT\"}',NULL,'87c03d84b6a8943fc9254d37256846fb','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:56:33.952452'),('cb01ca58-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','cedex_damages.create','cedex_damages','99658a84-c385-4e6c-a264-4a5f357ec7eb',NULL,NULL,NULL,'{\"id\": \"99658a84-c385-4e6c-a264-4a5f357ec7eb\", \"code\": \"DMG17B\", \"status\": \"active\", \"created_at\": \"2026-07-17T09:56:33Z\", \"updated_at\": \"2026-07-17T09:56:33Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"damage_name\": \"Dent UAT\", \"description\": \"UAT\"}',NULL,'11e77db60d19b791d545512cd2754b6e','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:56:33.962802'),('cb035e11-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','cedex_repairs.create','cedex_repairs','c124aa17-7f13-48d5-a75c-4b423916ccae',NULL,NULL,NULL,'{\"id\": \"c124aa17-7f13-48d5-a75c-4b423916ccae\", \"code\": \"RPR17B\", \"status\": \"active\", \"created_at\": \"2026-07-17T09:56:33Z\", \"updated_at\": \"2026-07-17T09:56:33Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"description\": \"UAT\", \"repair_name\": \"Repair UAT\"}',NULL,'22ae038aeee771bcc6bb034985c6c529','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:56:33.973122'),('cb0509d2-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','cedex_materials.create','cedex_materials','bc716703-acf5-44c2-9a78-1f6deb3e1f73',NULL,NULL,NULL,'{\"id\": \"bc716703-acf5-44c2-9a78-1f6deb3e1f73\", \"code\": \"MAT17B\", \"status\": \"active\", \"created_at\": \"2026-07-17T09:56:33Z\", \"updated_at\": \"2026-07-17T09:56:33Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"description\": \"UAT\", \"material_name\": \"Steel UAT\"}',NULL,'16345e8fab1894e33917efe4d8971d37','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:56:33.984093'),('cb06aa2d-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','responsibility_codes.create','responsibility_codes','8b067287-87f5-4a60-85fd-07770b885a3d',NULL,NULL,NULL,'{\"id\": \"8b067287-87f5-4a60-85fd-07770b885a3d\", \"code\": \"RESP17B\", \"name\": \"Customer UAT\", \"status\": \"active\", \"created_at\": \"2026-07-17T09:56:33Z\", \"updated_at\": \"2026-07-17T09:56:33Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"description\": \"UAT\"}',NULL,'e4903b6a93775b5821e5346d64c1f04d','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:56:33.994750'),('cbd94daa-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'ff49884dbf6e9f1b92dc62fcb3d734fc','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:14.559109'),('cc18e923-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'7ed9d68e3468658d548d6c0e0ef44705','127.0.0.1',NULL,'2026-07-23 11:13:02.501668'),('cc2e4708-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','fitness_checklist_templates.create','fitness_checklist_templates','b320301c-1f96-4967-8d0c-c8a1c3c3dd0f',NULL,NULL,NULL,'{\"id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"status\": \"draft\", \"created_at\": \"2026-07-23T04:13:02Z\", \"updated_at\": \"2026-07-23T04:13:02Z\", \"version_no\": 1, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"description\": \"UAT\", \"template_code\": \"TPLF0723111302\", \"template_name\": \"UAT Checklist F0723111302\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"survey_type_label\": \"SV-17B - Survey UAT 17B\", \"approval_category_id\": null, \"container_type_label\": \"CT-17B - Dry UAT\", \"approval_category_label\": null}',NULL,'01f9cb730382cd5b0f3e0d8b8f8bc584','127.0.0.1',NULL,'2026-07-23 11:13:02.641671'),('cc368386-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','fitness_checklist_template_items.create','fitness_checklist_template_items','3798b4be-809c-4ddf-949d-426833064328',NULL,NULL,NULL,'{\"id\": \"3798b4be-809c-4ddf-949d-426833064328\", \"status\": \"active\", \"item_code\": \"ITMF0723111302\", \"created_at\": \"2026-07-23T04:13:02Z\", \"item_label\": \"UAT Checklist Item F0723111302\", \"updated_at\": \"2026-07-23T04:13:02Z\", \"description\": null, \"is_critical\": 0, \"is_required\": 1, \"template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"display_order\": 1, \"response_type\": \"ok_not_ok\", \"expected_value\": null, \"component_label\": null, \"fail_marks_unfit\": 0, \"test_parameter_id\": null, \"inspection_area_id\": null, \"fail_requires_repair\": 0, \"test_parameter_label\": null, \"inspection_area_label\": null, \"structural_component_id\": null}',NULL,'52f627068c87f7ef808e3f4407546b9c','127.0.0.1',NULL,'2026-07-23 11:13:02.695634'),('cc38dc37-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','jobs.create','jobs','ba973397-9eee-4cf9-b987-9a2e4e727195',NULL,NULL,NULL,'{\"id\": \"ba973397-9eee-4cf9-b987-9a2e4e727195\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000002\"}',NULL,'2430548d6cb8c6e11f98eb1e90d1d485','127.0.0.1',NULL,'2026-07-23 11:13:02.711059'),('cc3cbb41-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','job_containers.create','job_containers','ef3108a3-5d1e-4832-af0b-eb174edc0675',NULL,NULL,NULL,'{\"id\": \"ef3108a3-5d1e-4832-af0b-eb174edc0675\", \"status\": \"not_started\", \"container_no\": \"MSKU1234565\", \"check_digit_status\": \"valid\"}',NULL,'bded69457e2dd324130a99f25507b55b','127.0.0.1',NULL,'2026-07-23 11:13:02.736415'),('cc4493d3-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','assignments.assign','assignments','0af0234c-cf48-4860-9b19-f9943b638a4f',NULL,NULL,NULL,'{\"id\": \"0af0234c-cf48-4860-9b19-f9943b638a4f\", \"status\": \"assigned\", \"due_date\": null, \"start_date\": null, \"instruction\": \"UAT audit\", \"assignment_no\": \"GIFT-ASG-2026-000001\", \"assigned_containers\": 1}',NULL,'e788243c6e05987f3b5fe494bf201d4e','127.0.0.1',NULL,'2026-07-23 11:13:02.787815'),('cc45ef4f-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','evidence_photo_categories.update','evidence_photo_categories','e5f94595-e77d-4361-bf9f-aa2f71432f22',NULL,NULL,'{\"id\": \"e5f94595-e77d-4361-bf9f-aa2f71432f22\", \"code\": \"PCR0723111009\", \"name\": \"Retry Photo R0723111009\", \"status\": \"active\", \"applies_to\": \"inspection\", \"created_at\": \"2026-07-23T04:10:09Z\", \"updated_at\": \"2026-07-23T04:10:09Z\", \"description\": \"UAT\", \"display_order\": 999, \"is_required_default\": 0}','{\"id\": \"e5f94595-e77d-4361-bf9f-aa2f71432f22\", \"code\": \"PCR0723111009\", \"name\": \"Retry Photo R0723111009\", \"status\": \"inactive\", \"applies_to\": \"inspection\", \"created_at\": \"2026-07-23T04:10:09Z\", \"updated_at\": \"2026-07-23T04:13:02Z\", \"description\": \"UAT\", \"display_order\": 999, \"is_required_default\": 0}',NULL,'567210ae5e0536480d6d36bc046827b2','127.0.0.1',NULL,'2026-07-23 11:13:02.796688'),('ccc6b00c-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveyor_jobs.open','job_orders','e2e00001-0000-4000-8000-000000000001',NULL,NULL,NULL,'{\"job_order_no\": \"UAT-JOB-2026-0805-001\"}',NULL,'c2277d496f85ad162ccd8afc3d439ef5','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:16.113159'),('cd1fb4c0-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.start','surveys','749164da-9dcf-478c-be1c-973291e46176',NULL,NULL,NULL,'{\"id\": \"749164da-9dcf-478c-be1c-973291e46176\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000008\", \"container_no\": \"GFTU1234560\", \"job_order_no\": \"UAT-JOB-2026-0805-001\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\"}',NULL,'af046f212cc16029c50bde4fc8201699','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:16.698164'),('cd5da2f0-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.open','surveys','749164da-9dcf-478c-be1c-973291e46176',NULL,NULL,NULL,'{\"survey_no\": \"GIFT-SVY-2026-000008\"}',NULL,'90f3276ae29040143636b3ef1024a24f','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:17.104113'),('cdb2e433-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveyor_jobs.open','job_orders','e2e00001-0000-4000-8000-000000000001',NULL,NULL,NULL,'{\"job_order_no\": \"UAT-JOB-2026-0805-001\"}',NULL,'da6fed33321ab331695a92003e81548c','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:17.662779'),('ce535767-864a-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'d13b161bc892ca4d34838b3c64a72fba','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 10:58:47.246371'),('cebdbf20-751f-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.logout','auth',NULL,NULL,NULL,NULL,NULL,NULL,'8029a12c35e9bde0d324d5ef48e0a9e5','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:38:09.817309'),('cec288ff-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'d83efb4e477510e74db5544ca7bcae09','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:19.443044'),('cf4a4adf-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.open','surveys','e2e00003-0000-4000-8000-000000000301',NULL,NULL,NULL,'{\"survey_no\": \"UAT-SURVEY-2026-0805-003-A\"}',NULL,'d26f526a9fc027aba7e726aa68b6730f','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:20.332695'),('cfbadda5-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','survey_photos.upload_general','survey_photos','db4222ee-448a-466a-9eaa-b9e53ef7f7ee',NULL,NULL,NULL,'{\"id\": \"db4222ee-448a-466a-9eaa-b9e53ef7f7ee\", \"caption\": \"Evidence UAT revisi otomatis\", \"file_id\": \"a9171329-8565-4c96-849d-0a539392d65a\", \"damage_id\": null, \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"created_at\": \"2026-08-11T12:09:21Z\", \"object_key\": \"uat/UAT-REAL-CASE-2026-08/run-d/surveys/e2e00003-0000-4000-8000-000000000301/photos/original/66b27125-887c-4b8b-b480-f7c163d6d5d0.png\", \"photo_type\": \"general\", \"content_url\": \"/survey-photos/db4222ee-448a-466a-9eaa-b9e53ef7f7ee/content\", \"original_url\": \"/survey-photos/db4222ee-448a-466a-9eaa-b9e53ef7f7ee/content?variant=original\", \"photo_category\": \"general_container\", \"original_file_name\": \"gift-logo.png\", \"watermarked_file_id\": \"66a2682d-0639-47a2-903c-d0c735bb9eff\", \"watermarked_object_key\": \"uat/UAT-REAL-CASE-2026-08/run-d/surveys/e2e00003-0000-4000-8000-000000000301/photos/watermarked/66b27125-887c-4b8b-b480-f7c163d6d5d0.jpg\"}',NULL,'7c46a6b387f76123d34415d89a288831','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:21.070020'),('cfc39aba-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.open','surveys','e2e00003-0000-4000-8000-000000000301',NULL,NULL,NULL,'{\"survey_no\": \"UAT-SURVEY-2026-0805-003-A\"}',NULL,'b09289d95b22a60eee9e8e48fbc82ae1','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:21.127784'),('cfeb2124-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.open','surveys','e2e00003-0000-4000-8000-000000000301',NULL,NULL,NULL,'{\"survey_no\": \"UAT-SURVEY-2026-0805-003-A\"}',NULL,'0b1453e9feb47bdb8ed078a304bb7ba2','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:21.386817'),('cff034dd-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.submit','surveys','e2e00003-0000-4000-8000-000000000301',NULL,NULL,'{\"id\": \"e2e00003-0000-4000-8000-000000000301\", \"phase\": \"initial\", \"spk_no\": null, \"status\": \"draft\", \"spk_date\": null, \"is_active\": 1, \"survey_no\": \"UAT-SURVEY-2026-0805-003-A\", \"owner_code\": null, \"started_at\": \"2026-08-10T12:04:27Z\", \"approved_at\": null, \"check_digit\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"rejected_at\": null, \"surveyor_id\": \"9ac88126-eacc-4256-8f8b-efd594725b10\", \"container_no\": \"BCKU2468102\", \"final_remark\": null, \"job_deadline\": \"2026-08-25T12:04:27Z\", \"job_order_id\": \"e2e00003-0000-4000-8000-000000000001\", \"job_order_no\": \"UAT-JOB-2026-0805-003\", \"submitted_at\": null, \"survey_round\": 1, \"customer_code\": \"UAT-CUST-17B\", \"customer_name\": \"UAT Customer Scope 17B\", \"iso_type_code\": \"22G1\", \"location_code\": \"LOC-17B\", \"location_name\": \"Depot UAT 17B\", \"serial_number\": null, \"surveyor_name\": \"Raka Pratama UAT\", \"container_size\": \"20\", \"resubmitted_at\": null, \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_instruction\": \"Dataset UAT-REAL-CASE-2026-08 - bukan data operasional\", \"csc_plate_status\": null, \"job_container_id\": \"e2e00003-0000-4000-8000-000000000201\", \"manufacture_date\": null, \"survey_type_code\": \"SV-17B\", \"survey_type_name\": \"Survey UAT 17B\", \"assignment_due_at\": \"2026-08-25T12:04:27Z\", \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"pic_customer_name\": \"PIC UAT\", \"review_started_at\": null, \"check_digit_status\": \"not_checked\", \"pic_customer_email\": null, \"pic_customer_phone\": null, \"container_type_code\": \"CT-17B\", \"container_type_name\": \"Dry UAT\", \"current_reviewer_id\": null, \"current_revision_no\": 0, \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"current_reviewer_name\": null, \"assignment_instruction\": \"Assignment UAT-REAL-CASE-2026-08\"}','{\"id\": \"e2e00003-0000-4000-8000-000000000301\", \"status\": \"submitted\", \"survey_no\": \"UAT-SURVEY-2026-0805-003-A\", \"submitted_at\": \"2026-08-11T12:09:21Z\", \"resubmitted_at\": null}',NULL,'0b1453e9feb47bdb8ed078a304bb7ba2','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:21.419541'),('cffe8936-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.open','surveys','e2e00003-0000-4000-8000-000000000301',NULL,NULL,NULL,'{\"survey_no\": \"UAT-SURVEY-2026-0805-003-A\"}',NULL,'03dbc820597944aff236add93476e5bd','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:21.513968'),('d043dad0-9542-11f1-9595-002b67818c25','24c54a64-a645-4f8f-9b87-40a20b31d6ce','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'58618775fb0b1827d2c8d3a42723ad1b','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:21.968163'),('d0d8542d-751f-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'9ced6d8d6b684868f5f810db94d11b8e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:38:13.346980'),('d0db050d-9542-11f1-9595-002b67818c25','24c54a64-a645-4f8f-9b87-40a20b31d6ce','supervisor','reviews.start','surveys','e2e00003-0000-4000-8000-000000000301',NULL,NULL,'{\"id\": \"e2e00003-0000-4000-8000-000000000301\", \"status\": \"submitted\", \"survey_no\": \"UAT-SURVEY-2026-0805-003-A\", \"approved_at\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"rejected_at\": null, \"surveyor_id\": \"9ac88126-eacc-4256-8f8b-efd594725b10\", \"container_no\": \"BCKU2468102\", \"job_order_id\": \"e2e00003-0000-4000-8000-000000000001\", \"job_order_no\": \"UAT-JOB-2026-0805-003\", \"submitted_at\": \"2026-08-11T12:09:21Z\", \"customer_name\": \"UAT Customer Scope 17B\", \"location_name\": \"Depot UAT 17B\", \"survey_result\": \"damage\", \"surveyor_name\": \"Raka Pratama UAT\", \"resubmitted_at\": null, \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_container_id\": \"e2e00003-0000-4000-8000-000000000201\", \"survey_type_name\": \"Survey UAT 17B\", \"review_started_at\": null, \"current_reviewer_id\": null, \"current_revision_no\": 0, \"current_reviewer_name\": null}','{\"status\": \"under_review\", \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"previous_status\": \"submitted\", \"current_reviewer_id\": \"24c54a64-a645-4f8f-9b87-40a20b31d6ce\"}',NULL,'f9e581fe49bab649986bc0e1c2a772fd','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:22.958873'),('d1411aef-9542-11f1-9595-002b67818c25','24c54a64-a645-4f8f-9b87-40a20b31d6ce','supervisor','reviews.need_revision','surveys','e2e00003-0000-4000-8000-000000000301',NULL,NULL,'{\"id\": \"e2e00003-0000-4000-8000-000000000301\", \"status\": \"under_review\", \"survey_no\": \"UAT-SURVEY-2026-0805-003-A\", \"approved_at\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"rejected_at\": null, \"surveyor_id\": \"9ac88126-eacc-4256-8f8b-efd594725b10\", \"container_no\": \"BCKU2468102\", \"job_order_id\": \"e2e00003-0000-4000-8000-000000000001\", \"job_order_no\": \"UAT-JOB-2026-0805-003\", \"submitted_at\": \"2026-08-11T12:09:21Z\", \"customer_name\": \"UAT Customer Scope 17B\", \"location_name\": \"Depot UAT 17B\", \"survey_result\": \"damage\", \"surveyor_name\": \"Raka Pratama UAT\", \"resubmitted_at\": null, \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_container_id\": \"e2e00003-0000-4000-8000-000000000201\", \"survey_type_name\": \"Survey UAT 17B\", \"review_started_at\": \"2026-08-11T12:09:22Z\", \"current_reviewer_id\": \"24c54a64-a645-4f8f-9b87-40a20b31d6ce\", \"current_revision_no\": 0, \"current_reviewer_name\": \"Ardiansyah Wibowo UAT\"}','{\"status\": \"need_revision\", \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"revision_note\": \"UAT revisi bertarget survey.\", \"revision_items\": 2}',NULL,'40c9264450bc9fd1b8f3d73052beeae2','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:23.627967'),('d1b297ab-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'89f3fc43b54fbc2d6418381f19a74fc2','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:24.371739'),('d1fcc5d2-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.open','surveys','e2e00003-0000-4000-8000-000000000301',NULL,NULL,NULL,'{\"survey_no\": \"UAT-SURVEY-2026-0805-003-A\"}',NULL,'54c06d982a012da5485f981832ff3d2b','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:24.857746'),('d241a992-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.open','surveys','e2e00003-0000-4000-8000-000000000301',NULL,NULL,NULL,'{\"survey_no\": \"UAT-SURVEY-2026-0805-003-A\"}',NULL,'f1d00bb6aa359a2cbf7cd186a37619c4','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:25.309400'),('d246d063-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.resubmit','surveys','e2e00003-0000-4000-8000-000000000301',NULL,NULL,'{\"id\": \"e2e00003-0000-4000-8000-000000000301\", \"phase\": \"initial\", \"spk_no\": null, \"status\": \"need_revision\", \"spk_date\": null, \"is_active\": 1, \"survey_no\": \"UAT-SURVEY-2026-0805-003-A\", \"owner_code\": null, \"started_at\": \"2026-08-10T12:04:27Z\", \"approved_at\": null, \"check_digit\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"rejected_at\": null, \"surveyor_id\": \"9ac88126-eacc-4256-8f8b-efd594725b10\", \"container_no\": \"BCKU2468102\", \"final_remark\": \"UAT-REAL-CASE-2026-08\", \"job_deadline\": \"2026-08-25T12:04:27Z\", \"job_order_id\": \"e2e00003-0000-4000-8000-000000000001\", \"job_order_no\": \"UAT-JOB-2026-0805-003\", \"submitted_at\": \"2026-08-11T12:09:21Z\", \"survey_round\": 1, \"customer_code\": \"UAT-CUST-17B\", \"customer_name\": \"UAT Customer Scope 17B\", \"iso_type_code\": \"22G1\", \"location_code\": \"LOC-17B\", \"location_name\": \"Depot UAT 17B\", \"serial_number\": null, \"surveyor_name\": \"Raka Pratama UAT\", \"container_size\": \"20\", \"resubmitted_at\": null, \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_instruction\": \"Dataset UAT-REAL-CASE-2026-08 - bukan data operasional\", \"csc_plate_status\": null, \"job_container_id\": \"e2e00003-0000-4000-8000-000000000201\", \"manufacture_date\": null, \"survey_type_code\": \"SV-17B\", \"survey_type_name\": \"Survey UAT 17B\", \"assignment_due_at\": \"2026-08-25T12:04:27Z\", \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"pic_customer_name\": \"PIC UAT\", \"review_started_at\": null, \"check_digit_status\": \"not_checked\", \"pic_customer_email\": null, \"pic_customer_phone\": null, \"container_type_code\": \"CT-17B\", \"container_type_name\": \"Dry UAT\", \"current_reviewer_id\": null, \"current_revision_no\": 1, \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"current_reviewer_name\": null, \"assignment_instruction\": \"Assignment UAT-REAL-CASE-2026-08\"}','{\"id\": \"e2e00003-0000-4000-8000-000000000301\", \"status\": \"resubmitted\", \"survey_no\": \"UAT-SURVEY-2026-0805-003-A\", \"submitted_at\": \"2026-08-11T12:09:21Z\", \"resubmitted_at\": \"2026-08-11T12:09:25Z\"}',NULL,'f1d00bb6aa359a2cbf7cd186a37619c4','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:25.343086'),('d24fdfa7-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.open','surveys','e2e00003-0000-4000-8000-000000000301',NULL,NULL,NULL,'{\"survey_no\": \"UAT-SURVEY-2026-0805-003-A\"}',NULL,'0f78b1465f6cdb98e238abe40682e5dc','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:25.402513'),('d2aebb6f-9542-11f1-9595-002b67818c25','24c54a64-a645-4f8f-9b87-40a20b31d6ce','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'7b91eff72be6c801fda16b6384eaa2f7','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:26.024208'),('d2fec6ed-9542-11f1-9595-002b67818c25','24c54a64-a645-4f8f-9b87-40a20b31d6ce','supervisor','reviews.start','surveys','e2e00003-0000-4000-8000-000000000301',NULL,NULL,'{\"id\": \"e2e00003-0000-4000-8000-000000000301\", \"status\": \"resubmitted\", \"survey_no\": \"UAT-SURVEY-2026-0805-003-A\", \"approved_at\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"rejected_at\": null, \"surveyor_id\": \"9ac88126-eacc-4256-8f8b-efd594725b10\", \"container_no\": \"BCKU2468102\", \"job_order_id\": \"e2e00003-0000-4000-8000-000000000001\", \"job_order_no\": \"UAT-JOB-2026-0805-003\", \"submitted_at\": \"2026-08-11T12:09:21Z\", \"customer_name\": \"UAT Customer Scope 17B\", \"location_name\": \"Depot UAT 17B\", \"survey_result\": \"damage\", \"surveyor_name\": \"Raka Pratama UAT\", \"resubmitted_at\": \"2026-08-11T12:09:25Z\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_container_id\": \"e2e00003-0000-4000-8000-000000000201\", \"survey_type_name\": \"Survey UAT 17B\", \"review_started_at\": null, \"current_reviewer_id\": null, \"current_revision_no\": 1, \"current_reviewer_name\": null}','{\"status\": \"under_review\", \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"previous_status\": \"resubmitted\", \"current_reviewer_id\": \"24c54a64-a645-4f8f-9b87-40a20b31d6ce\"}',NULL,'e9c52612facd1a2785bd8c5c79e2f5b1','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:26.548636'),('d32d3342-9542-11f1-9595-002b67818c25','24c54a64-a645-4f8f-9b87-40a20b31d6ce','supervisor','reviews.approve','surveys','e2e00003-0000-4000-8000-000000000301',NULL,NULL,'{\"id\": \"e2e00003-0000-4000-8000-000000000301\", \"status\": \"under_review\", \"survey_no\": \"UAT-SURVEY-2026-0805-003-A\", \"approved_at\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"rejected_at\": null, \"surveyor_id\": \"9ac88126-eacc-4256-8f8b-efd594725b10\", \"container_no\": \"BCKU2468102\", \"job_order_id\": \"e2e00003-0000-4000-8000-000000000001\", \"job_order_no\": \"UAT-JOB-2026-0805-003\", \"submitted_at\": \"2026-08-11T12:09:21Z\", \"customer_name\": \"UAT Customer Scope 17B\", \"location_name\": \"Depot UAT 17B\", \"survey_result\": \"damage\", \"surveyor_name\": \"Raka Pratama UAT\", \"resubmitted_at\": \"2026-08-11T12:09:25Z\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_container_id\": \"e2e00003-0000-4000-8000-000000000201\", \"survey_type_name\": \"Survey UAT 17B\", \"review_started_at\": \"2026-08-11T12:09:26Z\", \"current_reviewer_id\": \"24c54a64-a645-4f8f-9b87-40a20b31d6ce\", \"current_revision_no\": 1, \"current_reviewer_name\": \"Ardiansyah Wibowo UAT\"}','{\"status\": \"approved\", \"report_id\": \"3eb68746-dc8a-4f6a-afea-340b033e5418\", \"report_no\": \"GIFT-RPT-2026-000003\", \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"report_generation_status\": \"metadata_ready\"}',NULL,'fd9658362820f1a59b3fc98daae5f07f','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:26.852882'),('d4268a65-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'c9d74added5d4759bd1800f1c93e905e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:28.487044'),('d484c86f-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.open','surveys','e2e00002-0000-4000-8000-000000000201',NULL,NULL,NULL,'{\"survey_no\": \"UAT-SURVEY-2026-0805-002-A\"}',NULL,'9ef63c6391e7d0717f58edad6729990b','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:29.104638'),('d4e5f741-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','survey_photos.upload_general','survey_photos','b53e0e58-5c3b-46ff-b54d-a9ab0805809a',NULL,NULL,NULL,'{\"id\": \"b53e0e58-5c3b-46ff-b54d-a9ab0805809a\", \"caption\": \"Evidence UAT reject otomatis\", \"file_id\": \"b8f945ef-41f6-4916-a0ce-d8a7b91224f9\", \"damage_id\": null, \"survey_id\": \"e2e00002-0000-4000-8000-000000000201\", \"created_at\": \"2026-08-11T12:09:29Z\", \"object_key\": \"uat/UAT-REAL-CASE-2026-08/run-d/surveys/e2e00002-0000-4000-8000-000000000201/photos/original/adda92b4-de63-42e8-85b1-ed10b0549446.png\", \"photo_type\": \"general\", \"content_url\": \"/survey-photos/b53e0e58-5c3b-46ff-b54d-a9ab0805809a/content\", \"original_url\": \"/survey-photos/b53e0e58-5c3b-46ff-b54d-a9ab0805809a/content?variant=original\", \"photo_category\": \"general_container\", \"original_file_name\": \"gift-logo.png\", \"watermarked_file_id\": \"bd0316d7-d620-48a9-a158-1655c0d6a814\", \"watermarked_object_key\": \"uat/UAT-REAL-CASE-2026-08/run-d/surveys/e2e00002-0000-4000-8000-000000000201/photos/watermarked/adda92b4-de63-42e8-85b1-ed10b0549446.jpg\"}',NULL,'4d67b1df7aa27e660c6c059a12619a69','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:29.741566'),('d4f00d5a-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.open','surveys','e2e00002-0000-4000-8000-000000000201',NULL,NULL,NULL,'{\"survey_no\": \"UAT-SURVEY-2026-0805-002-A\"}',NULL,'300ceaedda8fe2c3348ad9273a59be82','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:29.807669'),('d515db3d-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.open','surveys','e2e00002-0000-4000-8000-000000000201',NULL,NULL,NULL,'{\"survey_no\": \"UAT-SURVEY-2026-0805-002-A\"}',NULL,'71fecd5fc46418c6d10a6e8d491a7fbd','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:30.055424'),('d518cc12-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.submit','surveys','e2e00002-0000-4000-8000-000000000201',NULL,NULL,'{\"id\": \"e2e00002-0000-4000-8000-000000000201\", \"phase\": \"initial\", \"spk_no\": null, \"status\": \"draft\", \"spk_date\": null, \"is_active\": 1, \"survey_no\": \"UAT-SURVEY-2026-0805-002-A\", \"owner_code\": null, \"started_at\": \"2026-08-10T12:04:27Z\", \"approved_at\": null, \"check_digit\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"rejected_at\": null, \"surveyor_id\": \"9ac88126-eacc-4256-8f8b-efd594725b10\", \"container_no\": \"NPKU1357903\", \"final_remark\": null, \"job_deadline\": \"2026-08-25T12:04:27Z\", \"job_order_id\": \"e2e00002-0000-4000-8000-000000000001\", \"job_order_no\": \"UAT-JOB-2026-0805-002\", \"submitted_at\": null, \"survey_round\": 1, \"customer_code\": \"UAT-CUST-17B\", \"customer_name\": \"UAT Customer Scope 17B\", \"iso_type_code\": \"22G1\", \"location_code\": \"LOC-17B\", \"location_name\": \"Depot UAT 17B\", \"serial_number\": null, \"surveyor_name\": \"Raka Pratama UAT\", \"container_size\": \"20\", \"resubmitted_at\": null, \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_instruction\": \"Dataset UAT-REAL-CASE-2026-08 - bukan data operasional\", \"csc_plate_status\": null, \"job_container_id\": \"e2e00002-0000-4000-8000-000000000201\", \"manufacture_date\": null, \"survey_type_code\": \"SV-17B\", \"survey_type_name\": \"Survey UAT 17B\", \"assignment_due_at\": \"2026-08-25T12:04:27Z\", \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"pic_customer_name\": \"PIC UAT\", \"review_started_at\": null, \"check_digit_status\": \"not_checked\", \"pic_customer_email\": null, \"pic_customer_phone\": null, \"container_type_code\": \"CT-17B\", \"container_type_name\": \"Dry UAT\", \"current_reviewer_id\": null, \"current_revision_no\": 0, \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"current_reviewer_name\": null, \"assignment_instruction\": \"Assignment UAT-REAL-CASE-2026-08\"}','{\"id\": \"e2e00002-0000-4000-8000-000000000201\", \"status\": \"submitted\", \"survey_no\": \"UAT-SURVEY-2026-0805-002-A\", \"submitted_at\": \"2026-08-11T12:09:30Z\", \"resubmitted_at\": null}',NULL,'71fecd5fc46418c6d10a6e8d491a7fbd','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:30.074578'),('d52443a3-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','surveys.open','surveys','e2e00002-0000-4000-8000-000000000201',NULL,NULL,NULL,'{\"survey_no\": \"UAT-SURVEY-2026-0805-002-A\"}',NULL,'d56a7871c83052cdeed86a46ecc6fb25','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:30.149794'),('d5a7862c-9542-11f1-9595-002b67818c25','24c54a64-a645-4f8f-9b87-40a20b31d6ce','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'2c431faa19d382ef791636c4ba79f9ac','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:31.010105'),('d5fd79ff-9542-11f1-9595-002b67818c25','24c54a64-a645-4f8f-9b87-40a20b31d6ce','supervisor','reviews.start','surveys','e2e00002-0000-4000-8000-000000000201',NULL,NULL,'{\"id\": \"e2e00002-0000-4000-8000-000000000201\", \"status\": \"submitted\", \"survey_no\": \"UAT-SURVEY-2026-0805-002-A\", \"approved_at\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"rejected_at\": null, \"surveyor_id\": \"9ac88126-eacc-4256-8f8b-efd594725b10\", \"container_no\": \"NPKU1357903\", \"job_order_id\": \"e2e00002-0000-4000-8000-000000000001\", \"job_order_no\": \"UAT-JOB-2026-0805-002\", \"submitted_at\": \"2026-08-11T12:09:30Z\", \"customer_name\": \"UAT Customer Scope 17B\", \"location_name\": \"Depot UAT 17B\", \"survey_result\": \"sound\", \"surveyor_name\": \"Raka Pratama UAT\", \"resubmitted_at\": null, \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_container_id\": \"e2e00002-0000-4000-8000-000000000201\", \"survey_type_name\": \"Survey UAT 17B\", \"review_started_at\": null, \"current_reviewer_id\": null, \"current_revision_no\": 0, \"current_reviewer_name\": null}','{\"status\": \"under_review\", \"survey_id\": \"e2e00002-0000-4000-8000-000000000201\", \"previous_status\": \"submitted\", \"current_reviewer_id\": \"24c54a64-a645-4f8f-9b87-40a20b31d6ce\"}',NULL,'1b384ef4a0f669eddd4c48014cf2d259','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:31.573305'),('d6205d4d-9542-11f1-9595-002b67818c25','24c54a64-a645-4f8f-9b87-40a20b31d6ce','supervisor','reviews.reject','surveys','e2e00002-0000-4000-8000-000000000201',NULL,NULL,'{\"id\": \"e2e00002-0000-4000-8000-000000000201\", \"status\": \"under_review\", \"survey_no\": \"UAT-SURVEY-2026-0805-002-A\", \"approved_at\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"rejected_at\": null, \"surveyor_id\": \"9ac88126-eacc-4256-8f8b-efd594725b10\", \"container_no\": \"NPKU1357903\", \"job_order_id\": \"e2e00002-0000-4000-8000-000000000001\", \"job_order_no\": \"UAT-JOB-2026-0805-002\", \"submitted_at\": \"2026-08-11T12:09:30Z\", \"customer_name\": \"UAT Customer Scope 17B\", \"location_name\": \"Depot UAT 17B\", \"survey_result\": \"sound\", \"surveyor_name\": \"Raka Pratama UAT\", \"resubmitted_at\": null, \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_container_id\": \"e2e00002-0000-4000-8000-000000000201\", \"survey_type_name\": \"Survey UAT 17B\", \"review_started_at\": \"2026-08-11T12:09:31Z\", \"current_reviewer_id\": \"24c54a64-a645-4f8f-9b87-40a20b31d6ce\", \"current_revision_no\": 0, \"current_reviewer_name\": \"Ardiansyah Wibowo UAT\"}','{\"status\": \"rejected\", \"survey_id\": \"e2e00002-0000-4000-8000-000000000201\", \"rejection_reason\": \"Ditolak untuk pembuktian cabang UAT.\"}',NULL,'203c5600974b1dcca9670a4896b67a59','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:31.801847'),('d6317d3b-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'1acf5007bb74ed7d4018f3994f16b551','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-23 11:27:38.433397'),('d67750ee-9542-11f1-9595-002b67818c25','7f55f406-fa96-4bdb-8758-4178ba8e082c','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'dbed0ceb410e83f264742c9bb169bff1','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:32.371906'),('d7635525-9542-11f1-9595-002b67818c25','16d75d68-b6c2-43de-97c6-ec099ae08ce0','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'c388ff92f6ac16d9ca3b94082beedbc1','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:33.918684'),('d8e0e832-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'8c8aafeaffc722cce8c28db40507d531','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 11:56:20.925394'),('d9011326-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'8c530ac1caac4195d67237f064fb63c9','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-11 12:09:36.630150'),('d9cb2f72-864a-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'1745a4fb2891f53ab29fedaf7f4a2690','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 10:59:06.486923'),('d9d95bad-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'b8c548aee94b638ec660ae55e243e395','127.0.0.1',NULL,'2026-07-23 11:13:25.573282'),('d9e25f07-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','fitness_checklist_templates.update','fitness_checklist_templates','b320301c-1f96-4967-8d0c-c8a1c3c3dd0f',NULL,NULL,'{\"id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"status\": \"draft\", \"created_at\": \"2026-07-23T04:13:02Z\", \"updated_at\": \"2026-07-23T04:13:02Z\", \"version_no\": 1, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"description\": \"UAT\", \"template_code\": \"TPLF0723111302\", \"template_name\": \"UAT Checklist F0723111302\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"survey_type_label\": \"SV-17B - Survey UAT 17B\", \"approval_category_id\": null, \"container_type_label\": \"CT-17B - Dry UAT\", \"approval_category_label\": null}','{\"id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"status\": \"active\", \"created_at\": \"2026-07-23T04:13:02Z\", \"updated_at\": \"2026-07-23T04:13:25Z\", \"version_no\": 1, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"description\": \"UAT\", \"template_code\": \"TPLF0723111302\", \"template_name\": \"UAT Checklist F0723111302\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"survey_type_label\": \"SV-17B - Survey UAT 17B\", \"approval_category_id\": null, \"container_type_label\": \"CT-17B - Dry UAT\", \"approval_category_label\": null}',NULL,'553d24fcb40463fa84a4647e4da16d4e','127.0.0.1',NULL,'2026-07-23 11:13:25.632297'),('d9ee0ec9-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'6cf0f184029e470abac9d5c3fdce8bb7','127.0.0.1',NULL,'2026-07-23 11:13:25.708928'),('d9fc262f-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','surveys.start','surveys','293e4859-83eb-4e36-9ab5-48fbe2f33bbf',NULL,NULL,NULL,'{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"container_no\": \"MSKU1234565\", \"job_order_no\": \"GIFT-JO-2026-000002\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\"}',NULL,'051e323f6139952f1d48ef8c67c7e6dd','127.0.0.1',NULL,'2026-07-23 11:13:25.801259'),('daf4fac0-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'b7d8011ff4e36b937dcdf051a0c4e398','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-22 14:13:36.007550'),('dc6a2e91-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'9e8f8c673f7053158e28cc710fe8fd7e','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-22 14:13:38.453368'),('dde18b84-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'1ed255809576f1936c60a37d02ee1d36','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-22 14:13:40.913323'),('e07205ed-751b-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'8f1da8e0d98d896a73371e243a47b599','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:10:01.533135'),('e0cadcd5-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'6d0b1fc4993f6507f5d15df4de6bdf5c','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:57:10.512719'),('e4b109b6-841c-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'8a726ef96892a8184445bf2250b525ee','127.0.0.1','node','2026-07-20 16:25:05.595323'),('e62eff21-841d-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'1a72340f8a68d4efb35ad7adb8c45749','127.0.0.1','node','2026-07-20 16:32:17.595300'),('e63abc81-864a-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'8c8f6cfe35ec89108a0dfce7207e77c1','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 10:59:27.350651'),('e6b5764a-84ac-11f1-9629-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'a5088533c7875f17d4303742ada6d38b','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-21 09:35:56.508771'),('e6caa68c-8661-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','supervisor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'d1f1b2b8cf7ce7eb483ec45e5852c801','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 13:44:06.713007'),('e8811de7-745c-11f1-806f-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'53a52b5ffe9cebe5ee48bc1c6f6b5b51','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.126.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-06-30 15:23:01.178463'),('e9a1cde3-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'2b2c718cc57945500a532b175e477b4d','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 13:58:30.477484'),('eaa607bb-89a3-11f1-b52d-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'bfdadac857f683e43b10d0b8f24503e5','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-27 17:14:13.461890'),('eacc032e-8661-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','management','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'68a39997f2462fd53a30f99a1f8629f4','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 13:44:13.438385'),('eb66c35a-8416-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'b5cabd23ec98d1e1284fa99ca39345e7','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-20 15:42:19.872227'),('ec4163df-8666-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'ed05d46bf69585988433ba19ab8797ad','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-23 14:20:03.368994'),('ed0f1e84-864a-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'a1e9751ae13f9404ffbd029567e57ae7','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-23 10:59:38.808851'),('ef1c9ef0-8661-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','surveyor','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'3ec5bc0d9043806581380f56503a3c5f','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-07-23 13:44:20.677538'),('efef759a-8734-11f1-918a-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'7c29e08f8d7b3e4df7c39f25c22511ae','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-24 14:54:45.869247'),('f04b169c-8416-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'9596a221754f87a5d9e0f3ac923d251b','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-20 15:42:28.079417'),('f0e7d3af-8189-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'09c27ad453fa495400437abb4fcad9de','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-17 09:48:07.742275'),('f2fd7db4-78ef-11f1-bacd-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'5254d48619a7627cf9e0b1f9e3ed8f62','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-06 11:05:39.441127'),('f4775999-745c-11f1-806f-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'4586be383d5fd963bfc5a782b4a2449c','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-06-30 15:23:21.247083'),('f50b72fe-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'2dd443f4fa6c02af5ec99d2353c4922d','127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-17 16:57:44.490426'),('f80b14d4-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'a0b1dc213322a526971c2f5f090a65a9','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-04 17:12:16.172476'),('f954e812-859b-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'7cbc41b416fb103bbe5e38bbc89aa89d','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-07-22 14:07:17.471153'),('fab8b110-751e-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000002','admin','auth.logout','auth',NULL,NULL,NULL,NULL,NULL,NULL,'b4300406ae65263ec44606e5636cac17','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-01 14:32:14.107181'),('fccae406-841d-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'0a66b109760c507e3559be33eeb5d319','127.0.0.1','node','2026-07-20 16:32:55.526794'),('febf1322-859d-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000001','super_admin','auth.login_success','auth',NULL,NULL,NULL,NULL,NULL,NULL,'5a854b65103ff867817fbcc424d74996','::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-22 14:21:45.548993');
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
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_cedex_code_proposals_customer_status` (`customer_id`,`status`),
  KEY `idx_cedex_code_proposals_survey` (`survey_id`),
  KEY `idx_cedex_code_proposals_proposed_by` (`proposed_by`),
  KEY `idx_cedex_code_proposals_created_at` (`created_at`),
  KEY `fk_cedex_code_proposals_evidence` (`evidence_file_id`),
  KEY `fk_cedex_code_proposals_reviewed_by` (`reviewed_by`),
  CONSTRAINT `fk_cedex_code_proposals_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_cedex_code_proposals_evidence` FOREIGN KEY (`evidence_file_id`) REFERENCES `file_objects` (`id`),
  CONSTRAINT `fk_cedex_code_proposals_proposed_by` FOREIGN KEY (`proposed_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_cedex_code_proposals_reviewed_by` FOREIGN KEY (`reviewed_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_cedex_code_proposals_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`)
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
  `display_order` int NOT NULL DEFAULT '0',
  `source_type` varchar(30) NOT NULL DEFAULT 'legacy',
  `source_reason` text,
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
INSERT INTO `cedex_components` VALUES ('0c4b9c89-45b0-4bc0-9af7-2d2f720112df','32aa190f-d0de-448d-b533-421da6e87ce9','CMP17B','Panel UAT',NULL,NULL,0,'UAT',0,'legacy',NULL,'active','2026-07-17 16:56:33.950862','2026-07-17 16:56:33.950862'),('26b126b9-d1ef-490a-bfee-eb7174b2519c','cd0c0678-86f8-4f29-a44b-db12a4e481ec','CC89537506','Component UAT',NULL,NULL,0,'Data uji lokal',0,'legacy',NULL,'active','2026-07-23 13:52:18.088360','2026-07-23 13:52:18.088360'),('2c6cec18-e5fd-49fa-a8f4-4696de377640','1b36b739-2080-451a-9092-64b5b771167a','CCA0723110926','UAT Component A0723110926',NULL,NULL,0,'UAT',0,'legacy',NULL,'inactive','2026-07-23 11:09:26.723364','2026-07-23 11:09:27.000000'),('3f2c9272-737f-11f1-ac50-002b67818c25',NULL,'SP','Side Panel',NULL,NULL,0,'Side panel',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c98e3-737f-11f1-ac50-002b67818c25',NULL,'RP','Roof Panel',NULL,NULL,0,'Roof panel',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c9ab8-737f-11f1-ac50-002b67818c25',NULL,'FP','Front Panel',NULL,NULL,0,'Front panel',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c9bb5-737f-11f1-ac50-002b67818c25',NULL,'DP','Door Panel',NULL,NULL,0,'Door panel',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c9ca0-737f-11f1-ac50-002b67818c25',NULL,'DG','Door Gasket',NULL,NULL,0,'Door gasket',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c9dd7-737f-11f1-ac50-002b67818c25',NULL,'LB','Locking Bar',NULL,NULL,0,'Locking bar',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c9ecb-737f-11f1-ac50-002b67818c25',NULL,'CK','Cam Keeper',NULL,NULL,0,'Cam keeper',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2c9fbe-737f-11f1-ac50-002b67818c25',NULL,'FB','Floor Board',NULL,NULL,0,'Floor board',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca0b2-737f-11f1-ac50-002b67818c25',NULL,'CM','Cross Member',NULL,NULL,0,'Cross member',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca194-737f-11f1-ac50-002b67818c25',NULL,'CP','Corner Post',NULL,NULL,0,'Corner post',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca2ab-737f-11f1-ac50-002b67818c25',NULL,'CC','Corner Casting',NULL,NULL,0,'Corner casting',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca393-737f-11f1-ac50-002b67818c25',NULL,'BSR','Bottom Side Rail',NULL,NULL,0,'Bottom side rail',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca482-737f-11f1-ac50-002b67818c25',NULL,'TSR','Top Side Rail',NULL,NULL,0,'Top side rail',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca5b8-737f-11f1-ac50-002b67818c25',NULL,'FKP','Forklift Pocket',NULL,NULL,0,'Forklift pocket',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca695-737f-11f1-ac50-002b67818c25',NULL,'VN','Ventilator',NULL,NULL,0,'Ventilator',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('3f2ca78d-737f-11f1-ac50-002b67818c25',NULL,'CSC','CSC Plate',NULL,NULL,0,'CSC plate',0,'legacy',NULL,'active','2026-06-29 05:56:18.311693','2026-06-29 05:56:18.311693'),('65e70d98-eadb-4080-b2f8-80ab593d6434','42aee823-b9d1-4788-9fd6-cdce2cb732f8','TCUAT-ISO-CEDEX-20260723115019','Tamper Route',NULL,NULL,0,'UAT',0,'legacy',NULL,'inactive','2026-07-23 11:50:19.985645','2026-07-23 11:50:20.000000'),('68631952-439f-4c3f-8e9d-41834303e762','42aee823-b9d1-4788-9fd6-cdce2cb732f8','CCUAT-ISO-CEDEX-20260723115019','UAT Component UAT-ISO-CEDEX-20260723115019',NULL,NULL,0,'UAT',0,'legacy',NULL,'inactive','2026-07-23 11:50:19.685233','2026-07-23 11:50:20.000000'),('72120964-15d2-493b-9794-b7f85560c39d','1e95fb79-ee0d-41aa-b26a-99f07e50976c','CC89557566','Component UAT',NULL,NULL,0,'Data uji lokal',0,'legacy',NULL,'active','2026-07-23 13:52:38.183203','2026-07-23 13:52:38.183203'),('aeed8eb9-bcc3-4d4a-b6af-65be7210837e','9eaabd4d-581a-4c1d-811a-4e3253300088','CCA0723110926','UAT Component A0723110926',NULL,NULL,0,'UAT',0,'legacy',NULL,'active','2026-07-23 11:09:26.730705','2026-07-23 11:09:26.730705'),('c402bede-d7f0-43ed-81be-1ecad86d4b27','5581423d-c969-43b4-ba9b-b427ac1511ed','CC89518363','Component UAT',NULL,NULL,0,'Data uji lokal',0,'legacy',NULL,'active','2026-07-23 13:51:59.071666','2026-07-23 13:51:59.071666'),('c7401f89-12b7-4c74-a71e-f48dc1e879a3','5d275989-b5f8-4f56-abb7-1e6cf8630449','CCUAT-ISO-CEDEX-20260723115019','UAT Component UAT-ISO-CEDEX-20260723115019',NULL,NULL,0,'UAT',0,'legacy',NULL,'active','2026-07-23 11:50:19.699876','2026-07-23 11:50:19.699876'),('c8c723b2-243f-44fa-ac56-3d5b0bb3b8f5','1b36b739-2080-451a-9092-64b5b771167a','TCA0723110926','Tamper Route',NULL,NULL,0,'UAT',0,'legacy',NULL,'inactive','2026-07-23 11:09:27.110903','2026-07-23 11:09:27.000000');
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
  `approval_category_id` char(36) DEFAULT NULL,
  `inspection_reference_id` char(36) DEFAULT NULL,
  `measurement_field` varchar(30) NOT NULL DEFAULT 'none',
  `comparison_operator` varchar(20) NOT NULL DEFAULT 'manual',
  `minimum_value` decimal(14,4) DEFAULT NULL,
  `maximum_value` decimal(14,4) DEFAULT NULL,
  `min_value` decimal(12,3) DEFAULT NULL,
  `max_value` decimal(12,3) DEFAULT NULL,
  `unit` varchar(20) DEFAULT NULL,
  `decision_result` varchar(50) NOT NULL DEFAULT 'manual_review',
  `recommended_action_id` char(36) DEFAULT NULL,
  `decision_note` text,
  `priority` int NOT NULL DEFAULT '100',
  `valid_from` date DEFAULT NULL,
  `valid_until` date DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  KEY `idx_cedex_damage_rules_customer` (`customer_id`),
  KEY `idx_cedex_damage_rules_damage` (`damage_id`),
  KEY `idx_cedex_damage_rules_component` (`component_id`),
  KEY `idx_cedex_damage_rules_location` (`location_id`),
  KEY `idx_cedex_damage_rules_material` (`material_id`),
  KEY `idx_cedex_damage_rules_container_type` (`container_type_id`),
  KEY `idx_cedex_damage_rules_approval_category` (`approval_category_id`),
  KEY `idx_cedex_damage_rules_reference` (`inspection_reference_id`),
  KEY `idx_cedex_damage_rules_action` (`recommended_action_id`),
  KEY `idx_cedex_damage_rules_lookup` (`customer_id`,`damage_id`,`component_id`,`status`,`priority`),
  KEY `idx_cedex_damage_rules_validity` (`valid_from`,`valid_until`,`status`),
  CONSTRAINT `fk_cedex_damage_rules_action` FOREIGN KEY (`recommended_action_id`) REFERENCES `cedex_repairs` (`id`),
  CONSTRAINT `fk_cedex_damage_rules_approval_category` FOREIGN KEY (`approval_category_id`) REFERENCES `fitness_approval_categories` (`id`),
  CONSTRAINT `fk_cedex_damage_rules_component` FOREIGN KEY (`component_id`) REFERENCES `cedex_components` (`id`),
  CONSTRAINT `fk_cedex_damage_rules_container_type` FOREIGN KEY (`container_type_id`) REFERENCES `container_types` (`id`),
  CONSTRAINT `fk_cedex_damage_rules_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_cedex_damage_rules_damage` FOREIGN KEY (`damage_id`) REFERENCES `cedex_damages` (`id`),
  CONSTRAINT `fk_cedex_damage_rules_location` FOREIGN KEY (`location_id`) REFERENCES `cedex_locations` (`id`),
  CONSTRAINT `fk_cedex_damage_rules_material` FOREIGN KEY (`material_id`) REFERENCES `cedex_materials` (`id`),
  CONSTRAINT `fk_cedex_damage_rules_reference` FOREIGN KEY (`inspection_reference_id`) REFERENCES `inspection_test_parameters` (`id`)
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
  `category` varchar(80) DEFAULT NULL,
  `description` text,
  `display_order` int NOT NULL DEFAULT '0',
  `source_type` varchar(30) NOT NULL DEFAULT 'legacy',
  `source_reason` text,
  `default_severity` varchar(30) DEFAULT NULL,
  `requires_dimension` tinyint(1) NOT NULL DEFAULT '0',
  `default_action_id` char(36) DEFAULT NULL,
  `default_inspection_reference_id` char(36) DEFAULT NULL,
  `reference_parameter_id` char(36) DEFAULT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_cedex_damages_customer_code` (`customer_id`,`code`),
  KEY `idx_cedex_damages_status` (`status`),
  KEY `idx_cedex_damages_customer` (`customer_id`),
  KEY `idx_cedex_damages_customer_status` (`customer_id`,`status`),
  KEY `idx_cedex_damages_default_action` (`default_action_id`),
  KEY `idx_cedex_damages_reference_parameter` (`reference_parameter_id`),
  KEY `idx_cedex_damages_customer_order` (`customer_id`,`display_order`),
  KEY `idx_cedex_damages_default_reference` (`default_inspection_reference_id`),
  CONSTRAINT `fk_cedex_damages_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_cedex_damages_default_action` FOREIGN KEY (`default_action_id`) REFERENCES `cedex_repairs` (`id`),
  CONSTRAINT `fk_cedex_damages_default_reference` FOREIGN KEY (`default_inspection_reference_id`) REFERENCES `inspection_test_parameters` (`id`),
  CONSTRAINT `fk_cedex_damages_reference_parameter` FOREIGN KEY (`reference_parameter_id`) REFERENCES `inspection_test_parameters` (`id`),
  CONSTRAINT `chk_cedex_damages_status` CHECK ((`status` in (_utf8mb4'active',_utf8mb4'inactive')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cedex_damages`
--

LOCK TABLES `cedex_damages` WRITE;
/*!40000 ALTER TABLE `cedex_damages` DISABLE KEYS */;
INSERT INTO `cedex_damages` VALUES ('003fc685-001a-40c2-9455-d6f5c0df6c2d','1e95fb79-ee0d-41aa-b26a-99f07e50976c','CD89557566','Damage UAT',NULL,NULL,'Data uji lokal',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-07-23 13:52:38.193901','2026-07-23 13:52:38.193901'),('3f2d67ba-737f-11f1-ac50-002b67818c25',NULL,'DT','Dent',NULL,NULL,'Dent',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d6c10-737f-11f1-ac50-002b67818c25',NULL,'HL','Hole',NULL,NULL,'Hole',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d6d75-737f-11f1-ac50-002b67818c25',NULL,'CR','Crack',NULL,NULL,'Crack',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d6e64-737f-11f1-ac50-002b67818c25',NULL,'BN','Bent',NULL,NULL,'Bent',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d6f5c-737f-11f1-ac50-002b67818c25',NULL,'BR','Broken',NULL,NULL,'Broken',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7095-737f-11f1-ac50-002b67818c25',NULL,'MS','Missing',NULL,NULL,'Missing',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7190-737f-11f1-ac50-002b67818c25',NULL,'RS','Rust',NULL,NULL,'Rust',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d72aa-737f-11f1-ac50-002b67818c25',NULL,'CO','Corrosion',NULL,NULL,'Corrosion',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7394-737f-11f1-ac50-002b67818c25',NULL,'TO','Torn',NULL,NULL,'Torn',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7472-737f-11f1-ac50-002b67818c25',NULL,'LS','Loose',NULL,NULL,'Loose',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d75c7-737f-11f1-ac50-002b67818c25',NULL,'DY','Dirty',NULL,NULL,'Dirty',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7711-737f-11f1-ac50-002b67818c25',NULL,'WT','Wet',NULL,NULL,'Wet',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d786f-737f-11f1-ac50-002b67818c25',NULL,'OD','Odor',NULL,NULL,'Odor',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d79ac-737f-11f1-ac50-002b67818c25',NULL,'OS','Oil Stain',NULL,NULL,'Oil stain',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7af6-737f-11f1-ac50-002b67818c25',NULL,'BM','Burn Mark',NULL,NULL,'Burn mark',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7c5a-737f-11f1-ac50-002b67818c25',NULL,'DL','Delamination',NULL,NULL,'Delamination',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7dad-737f-11f1-ac50-002b67818c25',NULL,'LK','Leakage',NULL,NULL,'Leakage',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('3f2d7f06-737f-11f1-ac50-002b67818c25',NULL,'IR','Improper Repair',NULL,NULL,'Improper repair',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-06-29 05:56:18.317187','2026-06-29 05:56:18.317187'),('47c6fba5-7864-4b26-850a-6ca428902416','5581423d-c969-43b4-ba9b-b427ac1511ed','CD89518363','Damage UAT',NULL,NULL,'Data uji lokal',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-07-23 13:51:59.084585','2026-07-23 13:51:59.084585'),('4ee9a6f0-ac55-4921-b12c-1c997b7df2a1','cd0c0678-86f8-4f29-a44b-db12a4e481ec','CD89537506','Damage UAT',NULL,NULL,'Data uji lokal',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-07-23 13:52:18.098943','2026-07-23 13:52:18.098943'),('99658a84-c385-4e6c-a264-4a5f357ec7eb','32aa190f-d0de-448d-b533-421da6e87ce9','DMG17B','Dent UAT',NULL,NULL,'UAT',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-07-17 16:56:33.960795','2026-07-17 16:56:33.960795'),('ba52b394-9f86-4a31-a50d-baaf50b47f01','42aee823-b9d1-4788-9fd6-cdce2cb732f8','CDUAT-ISO-CEDEX-20260723115019','UAT Damage UAT-ISO-CEDEX-20260723115019',NULL,NULL,'UAT',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'inactive','2026-07-23 11:50:19.727761','2026-07-23 11:50:20.000000'),('d32ea6ef-4bae-4625-b9b9-3dbba1d67514','5d275989-b5f8-4f56-abb7-1e6cf8630449','CDUAT-ISO-CEDEX-20260723115019','UAT Damage UAT-ISO-CEDEX-20260723115019',NULL,NULL,'UAT',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-07-23 11:50:19.737816','2026-07-23 11:50:19.737816'),('e2274dde-56f4-4551-9344-e7dfbd509399','1b36b739-2080-451a-9092-64b5b771167a','CDA0723110926','UAT Damage A0723110926',NULL,NULL,'UAT',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'inactive','2026-07-23 11:09:26.753782','2026-07-23 11:09:27.000000'),('f7b86ee5-6b34-4fb3-8acf-255626e80629','9eaabd4d-581a-4c1d-811a-4e3253300088','CDA0723110926','UAT Damage A0723110926',NULL,NULL,'UAT',0,'legacy',NULL,'minor',0,NULL,NULL,NULL,'active','2026-07-23 11:09:26.761917','2026-07-23 11:09:26.761917');
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
INSERT INTO `cedex_locations` VALUES ('12eb4fe2-1254-47f2-90d2-7accbd156825','5581423d-c969-43b4-ba9b-b427ac1511ed','manual',NULL,NULL,NULL,NULL,NULL,'CL89518363','left','L1','M89518363','20','Lokasi UAT','legacy',NULL,1,'active','2026-07-23 13:51:59.060718','2026-07-23 13:51:59.060718'),('2c3418aa-0e5a-4a04-adb9-6fa60c75e402','1b36b739-2080-451a-9092-64b5b771167a','manual',NULL,NULL,NULL,NULL,NULL,'CLA0723110926','left','L1','CLA0723110926','all','UAT','legacy',NULL,999,'inactive','2026-07-23 11:09:26.693737','2026-07-23 11:09:27.000000'),('3f2bf1dd-737f-11f1-ac50-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'L1','left','L1',NULL,'all','Left side section 1','legacy',NULL,1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bf6b4-737f-11f1-ac50-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'L2','left','L2',NULL,'all','Left side section 2','legacy',NULL,2,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bf871-737f-11f1-ac50-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'L3','left','L3',NULL,'all','Left side section 3','legacy',NULL,3,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bfa0f-737f-11f1-ac50-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'R1','right','R1',NULL,'all','Right side section 1','legacy',NULL,1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bfb50-737f-11f1-ac50-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'R2','right','R2',NULL,'all','Right side section 2','legacy',NULL,2,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bfca8-737f-11f1-ac50-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'D1','door','D1',NULL,'all','Door end section 1','legacy',NULL,1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bfdde-737f-11f1-ac50-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'F1','front','F1',NULL,'all','Front end section 1','legacy',NULL,1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2bfef8-737f-11f1-ac50-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'T1','roof','T1',NULL,'all','Roof section 1','legacy',NULL,1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2c003a-737f-11f1-ac50-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'FL1','floor','FL1',NULL,'all','Floor section 1','legacy',NULL,1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('3f2c0168-737f-11f1-ac50-002b67818c25',NULL,'manual',NULL,NULL,NULL,NULL,NULL,'U1','understructure','U1',NULL,'all','Understructure section 1','legacy',NULL,1,'active','2026-06-29 05:56:18.307557','2026-06-29 05:56:18.307557'),('41d79ecb-ec82-461d-96f5-8d90e7f7441f','cd0c0678-86f8-4f29-a44b-db12a4e481ec','manual',NULL,NULL,NULL,NULL,NULL,'CL89537506','left','L1','M89537506','20','Lokasi UAT','legacy',NULL,1,'active','2026-07-23 13:52:18.079430','2026-07-23 13:52:18.079430'),('443fab73-cf3e-4125-a50e-8861d40a4d04','9eaabd4d-581a-4c1d-811a-4e3253300088','manual',NULL,NULL,NULL,NULL,NULL,'CLA0723110926','left','L1','CLA0723110926','all','UAT','legacy',NULL,999,'active','2026-07-23 11:09:26.702370','2026-07-23 11:09:26.702370'),('4a2a1e52-434d-4014-91a7-c5cb2851d826','42aee823-b9d1-4788-9fd6-cdce2cb732f8','manual',NULL,NULL,NULL,NULL,NULL,'CLUAT-ISO-CEDEX-20260723115019','left','L1','CLUAT-ISO-CEDEX-20260723115019','all','UAT','legacy',NULL,999,'inactive','2026-07-23 11:50:19.650412','2026-07-23 11:50:20.000000'),('6371a90e-1b0c-4e6a-854a-9a07a46f285f','4d388157-406a-47e6-9343-8ad39bbf6700','manual',NULL,NULL,NULL,NULL,NULL,'CL89557566','left','L1','M89557566','20','Lokasi UAT','legacy',NULL,1,'active','2026-07-23 13:52:38.289304','2026-07-23 13:52:38.289304'),('671b9126-54cd-4d03-8724-edc95506a0ad','32aa190f-d0de-448d-b533-421da6e87ce9','manual',NULL,NULL,NULL,NULL,NULL,'L17B','left','L1','L1','20','Left grid','legacy',NULL,1,'active','2026-07-17 16:56:33.939208','2026-07-17 16:56:33.939208'),('876c2246-4992-4fd2-a749-3d223f4c9e6f','1e95fb79-ee0d-41aa-b26a-99f07e50976c','manual',NULL,NULL,NULL,NULL,NULL,'CL89557566','left','L1','M89557566','20','Lokasi UAT','legacy',NULL,1,'active','2026-07-23 13:52:38.172792','2026-07-23 13:52:38.172792'),('f37cdf8b-142b-41f6-ba38-49495df609a9','5d275989-b5f8-4f56-abb7-1e6cf8630449','manual',NULL,NULL,NULL,NULL,NULL,'CLUAT-ISO-CEDEX-20260723115019','left','L1','CLUAT-ISO-CEDEX-20260723115019','all','UAT','legacy',NULL,999,'active','2026-07-23 11:50:19.658235','2026-07-23 11:50:19.658235'),('f80e9e2b-7203-4a5a-b03d-3f6c5c457081','af4d13f9-693e-4ded-8009-a43ef878741a','manual',NULL,NULL,NULL,NULL,NULL,'CL89537506','left','L1','M89537506','20','Lokasi UAT','legacy',NULL,1,'active','2026-07-23 13:52:18.179073','2026-07-23 13:52:18.179073');
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
INSERT INTO `cedex_materials` VALUES ('1dcd6e09-e845-413f-8011-f4f82a4861d5','9eaabd4d-581a-4c1d-811a-4e3253300088','CMA0723110926','UAT Material A0723110926','UAT','legacy',NULL,'active','2026-07-23 11:09:26.849841','2026-07-23 11:09:26.849841'),('2e96b899-49a5-49d6-927a-1c7fe096e0e0','1e95fb79-ee0d-41aa-b26a-99f07e50976c','CM89557566','Material UAT','Data uji lokal','legacy',NULL,'active','2026-07-23 13:52:38.263474','2026-07-23 13:52:38.263474'),('3f2f3f44-737f-11f1-ac50-002b67818c25',NULL,'STL','Steel','Steel','legacy',NULL,'active','2026-06-29 05:56:18.329122','2026-06-29 05:56:18.329122'),('3f2f4501-737f-11f1-ac50-002b67818c25',NULL,'AL','Aluminium','Aluminium','legacy',NULL,'active','2026-06-29 05:56:18.329122','2026-06-29 05:56:18.329122'),('3f2f4761-737f-11f1-ac50-002b67818c25',NULL,'PLY','Plywood','Plywood','legacy',NULL,'active','2026-06-29 05:56:18.329122','2026-06-29 05:56:18.329122'),('3f2f4928-737f-11f1-ac50-002b67818c25',NULL,'RUB','Rubber','Rubber','legacy',NULL,'active','2026-06-29 05:56:18.329122','2026-06-29 05:56:18.329122'),('3f2f4af7-737f-11f1-ac50-002b67818c25',NULL,'PLS','Plastic','Plastic','legacy',NULL,'active','2026-06-29 05:56:18.329122','2026-06-29 05:56:18.329122'),('660863cf-8d29-4981-9652-1dc219e95260','5d275989-b5f8-4f56-abb7-1e6cf8630449','CMUAT-ISO-CEDEX-20260723115019','UAT Material UAT-ISO-CEDEX-20260723115019','UAT','legacy',NULL,'active','2026-07-23 11:50:19.803845','2026-07-23 11:50:19.803845'),('6f4014c5-58f7-4654-9e5f-8b5c0c854c4a','cd0c0678-86f8-4f29-a44b-db12a4e481ec','CM89537506','Material UAT','Data uji lokal','legacy',NULL,'active','2026-07-23 13:52:18.139625','2026-07-23 13:52:18.139625'),('75e15d58-f90a-4e19-bf43-f85d9538d5b6','5581423d-c969-43b4-ba9b-b427ac1511ed','CM89518363','Material UAT','Data uji lokal','legacy',NULL,'active','2026-07-23 13:51:59.171037','2026-07-23 13:51:59.171037'),('8fb913ce-25f7-4085-8059-0629d2667c50','1b36b739-2080-451a-9092-64b5b771167a','CMA0723110926','UAT Material A0723110926','UAT','legacy',NULL,'inactive','2026-07-23 11:09:26.840903','2026-07-23 11:09:27.000000'),('bc716703-acf5-44c2-9a78-1f6deb3e1f73','32aa190f-d0de-448d-b533-421da6e87ce9','MAT17B','Steel UAT','UAT','legacy',NULL,'active','2026-07-17 16:56:33.983134','2026-07-17 16:56:33.983134'),('bdd643fb-ea2e-4db6-b523-df046fc80cf1','42aee823-b9d1-4788-9fd6-cdce2cb732f8','CMUAT-ISO-CEDEX-20260723115019','UAT Material UAT-ISO-CEDEX-20260723115019','UAT','legacy',NULL,'inactive','2026-07-23 11:50:19.794663','2026-07-23 11:50:20.000000');
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
  `display_order` int NOT NULL DEFAULT '0',
  `source_type` varchar(30) NOT NULL DEFAULT 'legacy',
  `source_reason` text,
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
INSERT INTO `cedex_repairs` VALUES ('082f144a-d94a-4f8b-8c7f-6503ec258f1f','5d275989-b5f8-4f56-abb7-1e6cf8630449','CRUAT-ISO-CEDEX-20260723115019','UAT Repair UAT-ISO-CEDEX-20260723115019',NULL,0,'UAT',0,'legacy',NULL,'active','2026-07-23 11:50:19.770156','2026-07-23 11:50:19.770156'),('3f2e0abd-737f-11f1-ac50-002b67818c25',NULL,'NR','No Repair',NULL,0,'No repair',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e10bc-737f-11f1-ac50-002b67818c25',NULL,'ST','Straighten',NULL,0,'Straighten',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1254-737f-11f1-ac50-002b67818c25',NULL,'WD','Weld',NULL,0,'Weld',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e135a-737f-11f1-ac50-002b67818c25',NULL,'PT','Patch',NULL,0,'Patch',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e144d-737f-11f1-ac50-002b67818c25',NULL,'RP','Replace',NULL,0,'Replace',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1542-737f-11f1-ac50-002b67818c25',NULL,'RF','Refit',NULL,0,'Refit',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1624-737f-11f1-ac50-002b67818c25',NULL,'CL','Clean',NULL,0,'Clean',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1705-737f-11f1-ac50-002b67818c25',NULL,'DR','Drying',NULL,0,'Drying',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e17ee-737f-11f1-ac50-002b67818c25',NULL,'GR','Grinding',NULL,0,'Grinding',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e18e2-737f-11f1-ac50-002b67818c25',NULL,'PN','Painting',NULL,0,'Painting',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e19c4-737f-11f1-ac50-002b67818c25',NULL,'SL','Sealant',NULL,0,'Sealant',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1aea-737f-11f1-ac50-002b67818c25',NULL,'TG','Tighten',NULL,0,'Tighten',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1bd7-737f-11f1-ac50-002b67818c25',NULL,'RM','Remove',NULL,0,'Remove',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('3f2e1cc2-737f-11f1-ac50-002b67818c25',NULL,'RI','Reinstall',NULL,0,'Reinstall',0,'legacy',NULL,'active','2026-06-29 05:56:18.321362','2026-06-29 05:56:18.321362'),('54ec9f74-3ea5-4d51-a161-01cc9706d8b7','9eaabd4d-581a-4c1d-811a-4e3253300088','CRA0723110926','UAT Repair A0723110926',NULL,0,'UAT',0,'legacy',NULL,'active','2026-07-23 11:09:26.793209','2026-07-23 11:09:26.793209'),('6fdb8cd5-3074-4cb1-a694-4e9225a67923','1b36b739-2080-451a-9092-64b5b771167a','CRA0723110926','UAT Repair A0723110926',NULL,0,'UAT',0,'legacy',NULL,'inactive','2026-07-23 11:09:26.784386','2026-07-23 11:09:27.000000'),('85c941ce-e3f0-4d4b-a451-dad95ad5e971','5581423d-c969-43b4-ba9b-b427ac1511ed','CR89518363','Action Repair UAT',NULL,0,'Referensi tindakan teknis',0,'legacy',NULL,'active','2026-07-23 13:51:59.096644','2026-07-23 13:51:59.000000'),('901027ac-8088-4682-bbc7-31d789561552','cd0c0678-86f8-4f29-a44b-db12a4e481ec','CR89537506','Action Repair UAT',NULL,0,'Referensi tindakan teknis',0,'legacy',NULL,'active','2026-07-23 13:52:18.107489','2026-07-23 13:52:18.000000'),('a246d224-9e03-4056-96fd-d33663dcaf11','42aee823-b9d1-4788-9fd6-cdce2cb732f8','CRUAT-ISO-CEDEX-20260723115019','UAT Repair UAT-ISO-CEDEX-20260723115019',NULL,0,'UAT',0,'legacy',NULL,'inactive','2026-07-23 11:50:19.761833','2026-07-23 11:50:20.000000'),('c124aa17-7f13-48d5-a75c-4b423916ccae','32aa190f-d0de-448d-b533-421da6e87ce9','RPR17B','Repair UAT',NULL,0,'UAT',0,'legacy',NULL,'active','2026-07-17 16:56:33.972148','2026-07-17 16:56:33.972148'),('dd311dc0-d26c-450f-bdac-22848504252f','1e95fb79-ee0d-41aa-b26a-99f07e50976c','CR89557566','Action Repair UAT',NULL,0,'Referensi tindakan teknis',0,'legacy',NULL,'active','2026-07-23 13:52:38.216970','2026-07-23 13:52:38.000000');
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
INSERT INTO `company_profiles` VALUES ('3f2932cb-737f-11f1-ac50-002b67818c25','PT Global Inspeksi Sertifikasi Group','GIFT',NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'2026-06-29 05:56:18.289455','2026-06-29 05:56:18.289455');
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
  CONSTRAINT `chk_container_import_batches_status` CHECK ((`status` in (_utf8mb4'processed',_utf8mb4'failed',_utf8mb4'partial')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `container_import_batches`
--

LOCK TABLES `container_import_batches` WRITE;
/*!40000 ALTER TABLE `container_import_batches` DISABLE KEYS */;
INSERT INTO `container_import_batches` VALUES ('0bdab046-8663-11f1-a160-002b67818c25','daf62320-72ab-42ed-b509-dd6b0a2ba413',NULL,1,1,0,'processed','[]','00000000-0000-0000-0000-000000000002','2026-07-23 13:52:18.396095'),('10c806a8-8651-11f1-a160-002b67818c25','e8438630-bfbf-4861-be6f-73611a3f479c',NULL,1,1,0,'processed','[]','00000000-0000-0000-0000-000000000002','2026-07-23 11:43:35.721249'),('17cdc023-8663-11f1-a160-002b67818c25','9cb28aad-c5f8-4a6e-93c6-7718905972fe',NULL,1,1,0,'processed','[]','00000000-0000-0000-0000-000000000002','2026-07-23 13:52:38.443997');
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
INSERT INTO `container_types` VALUES ('06132cac-4ae5-4b80-9b07-417edcf756f1','32aa190f-d0de-448d-b533-421da6e87ce9','CT-17B','22G1','20','Dry UAT','Customer scoped UAT','active','2026-07-17 16:56:33.926530','2026-07-17 16:56:33.926530'),('1ff41f1c-0e68-44f3-b029-e6a4041d0790','5d275989-b5f8-4f56-abb7-1e6cf8630449','CTUAT-ISO-CEDEX-20260723115019','22G1','20','Dry General','UAT','active','2026-07-23 11:50:19.583466','2026-07-23 11:50:19.583466'),('34d2298d-dbe3-465c-8117-ae7217269e31','9eaabd4d-581a-4c1d-811a-4e3253300088','CTA0723110926','22G1','20','Dry General','UAT','active','2026-07-23 11:09:26.639502','2026-07-23 11:09:26.639502'),('380639b0-d41b-48f6-ac6a-b43f2cfbb732','5581423d-c969-43b4-ba9b-b427ac1511ed','CT89518363','22G1','20','General Purpose UAT','Data uji lokal','active','2026-07-23 13:51:59.036619','2026-07-23 13:51:59.036619'),('3f2a7725-737f-11f1-ac50-002b67818c25',NULL,'20GP','22G1','20 Feet','General Purpose','Dry container 20 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a7dc9-737f-11f1-ac50-002b67818c25',NULL,'40GP','42G1','40 Feet','General Purpose','Dry container 40 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a8082-737f-11f1-ac50-002b67818c25',NULL,'40HC','45G1','40 Feet','High Cube','High cube dry container 40 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a822a-737f-11f1-ac50-002b67818c25',NULL,'20RF','22R1','20 Feet','Reefer','Refrigerated container 20 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a83b5-737f-11f1-ac50-002b67818c25',NULL,'40RF','45R1','40 Feet','Reefer','Refrigerated container 40 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a854b-737f-11f1-ac50-002b67818c25',NULL,'20OT',NULL,'20 Feet','Open Top','Open top container 20 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a86c7-737f-11f1-ac50-002b67818c25',NULL,'40OT',NULL,'40 Feet','Open Top','Open top container 40 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a8857-737f-11f1-ac50-002b67818c25',NULL,'20FR',NULL,'20 Feet','Flat Rack','Flat rack container 20 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a89dc-737f-11f1-ac50-002b67818c25',NULL,'40FR',NULL,'40 Feet','Flat Rack','Flat rack container 40 feet','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('3f2a8b64-737f-11f1-ac50-002b67818c25',NULL,'TANK',NULL,'Tank','Tank Container','Tank container','active','2026-06-29 05:56:18.297704','2026-06-29 05:56:18.297704'),('53b504da-35d4-49f7-a1cc-3ea76aef2642','1b36b739-2080-451a-9092-64b5b771167a','CTA0723110926','22G1','20','Dry General','UAT','inactive','2026-07-23 11:09:26.629192','2026-07-23 11:09:27.000000'),('a49affc2-b9d4-497d-a617-d25fd1d68300','cd0c0678-86f8-4f29-a44b-db12a4e481ec','CT89537506','22G1','20','General Purpose UAT','Data uji lokal','active','2026-07-23 13:52:18.055502','2026-07-23 13:52:18.055502'),('a9e4829b-c6d4-4fe0-b58b-ee05390713ac','42aee823-b9d1-4788-9fd6-cdce2cb732f8','CTUAT-ISO-CEDEX-20260723115019','22G1','20','Dry General','UAT','inactive','2026-07-23 11:50:19.574459','2026-07-23 11:50:20.000000'),('c3a0e586-8fda-40de-bd9c-4e5689ffe647','1e95fb79-ee0d-41aa-b26a-99f07e50976c','CT89557566','22G1','20','General Purpose UAT','Data uji lokal','active','2026-07-23 13:52:38.152850','2026-07-23 13:52:38.152850'),('e2e00004-0000-4000-8000-000000000040','e2e00004-0000-4000-8000-000000000010','UAT-ISO-CT','22G1','20','Dry UAT Isolation','UAT-REAL-CASE-2026-08','active','2026-08-11 12:04:27.837322','2026-08-11 12:04:27.837322');
/*!40000 ALTER TABLE `container_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `customer_fitness_configurations`
--

DROP TABLE IF EXISTS `customer_fitness_configurations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_fitness_configurations` (
  `customer_id` char(36) NOT NULL,
  `canonical_survey_type_id` char(36) DEFAULT NULL,
  `default_checklist_template_id` char(36) DEFAULT NULL,
  `default_inspection_reference_id` char(36) DEFAULT NULL,
  `workflow_mode` varchar(30) NOT NULL DEFAULT 'fitness_only',
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`customer_id`),
  KEY `idx_customer_fitness_config_survey_type` (`canonical_survey_type_id`),
  KEY `idx_customer_fitness_config_checklist` (`default_checklist_template_id`),
  KEY `idx_customer_fitness_config_reference` (`default_inspection_reference_id`),
  CONSTRAINT `fk_customer_fitness_config_checklist` FOREIGN KEY (`default_checklist_template_id`) REFERENCES `fitness_checklist_templates` (`id`),
  CONSTRAINT `fk_customer_fitness_config_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  CONSTRAINT `fk_customer_fitness_config_reference` FOREIGN KEY (`default_inspection_reference_id`) REFERENCES `inspection_test_parameters` (`id`),
  CONSTRAINT `fk_customer_fitness_config_survey_type` FOREIGN KEY (`canonical_survey_type_id`) REFERENCES `survey_types` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `customer_fitness_configurations`
--

LOCK TABLES `customer_fitness_configurations` WRITE;
/*!40000 ALTER TABLE `customer_fitness_configurations` DISABLE KEYS */;
/*!40000 ALTER TABLE `customer_fitness_configurations` ENABLE KEYS */;
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
INSERT INTO `customer_personnel` VALUES ('0b831a5e-3726-4bf9-b034-3a8d9cb92f0e','16473014-ae6c-4ee8-8f7f-a34cfc63ab3a','P289518363','Personel UAT','PIC Pemeriksaan','inspection','pic2-89518363@example.test','0811000000',NULL,'active','2026-07-23 13:51:58.995890','2026-07-23 13:51:58.995890',NULL),('11326687-6f63-49f8-a8f2-e53b6d3e47d0','32aa190f-d0de-448d-b533-421da6e87ce9','PIC-17B','PIC UAT 17B','Operations','pic','pic17b@example.test','081700000018',NULL,'active','2026-07-17 16:56:33.868683','2026-07-17 16:56:33.868683',NULL),('19316e14-bbe4-4ff5-b25d-d6f2ab1e22e9','af4d13f9-693e-4ded-8009-a43ef878741a','P289537506','Personel UAT','PIC Pemeriksaan','inspection','pic2-89537506@example.test','0811000000',NULL,'active','2026-07-23 13:52:18.023042','2026-07-23 13:52:18.023042',NULL),('273b4f3e-fe58-4c0e-b5a5-61130ff4077d','5d275989-b5f8-4f56-abb7-1e6cf8630449','PICUAT-ISO-CEDEX-20260723115019','UAT Personel UAT-ISO-CEDEX-20260723115019','PIC UAT','pic','uat.uat-iso-cedex-20260723115019@example.test',NULL,NULL,'active','2026-07-23 11:50:19.547393','2026-07-23 11:50:19.547393',NULL),('58c6bdc2-6922-4cbe-beac-93c26a94659b','cd0c0678-86f8-4f29-a44b-db12a4e481ec','PIC89537506','Personel UAT','PIC Pemeriksaan','inspection','pic-89537506@example.test','0811000000',NULL,'active','2026-07-23 13:52:17.983743','2026-07-23 13:52:18.000000',NULL),('649cbf15-be94-4625-a3a9-51e2ca35bd93','9eaabd4d-581a-4c1d-811a-4e3253300088','PICA0723110926','UAT Personel A0723110926','PIC UAT','pic','uat.a0723110926@example.test',NULL,NULL,'active','2026-07-23 11:09:26.607463','2026-07-23 11:09:26.607463',NULL),('78654527-4834-48d5-9339-48d3eb97d4f6','1e95fb79-ee0d-41aa-b26a-99f07e50976c','PIC89557566','Personel UAT','PIC Pemeriksaan','inspection','pic-89557566@example.test','0811000000',NULL,'active','2026-07-23 13:52:38.076256','2026-07-23 13:52:38.000000',NULL),('a11cea62-7e88-46d3-be07-fed3d7920b43','1b36b739-2080-451a-9092-64b5b771167a','PICA0723110926','UAT Personel A0723110926','PIC UAT','pic','uat.a0723110926@example.test',NULL,NULL,'inactive','2026-07-23 11:09:26.598006','2026-07-23 11:09:27.000000',NULL),('a3b99189-db38-4f31-a441-982d51f6199a','5581423d-c969-43b4-ba9b-b427ac1511ed','PIC89518363','Personel UAT','PIC Pemeriksaan','inspection','pic-89518363@example.test','0811000000',NULL,'active','2026-07-23 13:51:58.954399','2026-07-23 13:51:58.000000',NULL),('aac61537-a165-4cd0-97e0-1a3a27fdad87','42aee823-b9d1-4788-9fd6-cdce2cb732f8','PICUAT-ISO-CEDEX-20260723115019','UAT Personel UAT-ISO-CEDEX-20260723115019','PIC UAT','pic','uat.uat-iso-cedex-20260723115019@example.test',NULL,NULL,'inactive','2026-07-23 11:50:19.536269','2026-07-23 11:50:20.000000',NULL),('ca66d226-f8fd-4f8f-8e42-f87efbfa14b4','4d388157-406a-47e6-9343-8ad39bbf6700','P289557566','Personel UAT','PIC Pemeriksaan','inspection','pic2-89557566@example.test','0811000000',NULL,'active','2026-07-23 13:52:38.120592','2026-07-23 13:52:38.120592',NULL);
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
INSERT INTO `customer_survey_type_photo_categories` VALUES ('1e95fb79-ee0d-41aa-b26a-99f07e50976c','79589597-afe5-42ba-bd7d-e9d7df2f2c68','18bf2745-3dae-4b30-85a1-af359690d6af',1,'2026-07-23 13:52:38.340208'),('32aa190f-d0de-448d-b533-421da6e87ce9','94e7124b-c5a8-4f27-8535-dd5618ee7caf','48278e9f-79e5-11f1-a1f6-002b67818c25',1,'2026-07-17 17:07:25.524123'),('32aa190f-d0de-448d-b533-421da6e87ce9','94e7124b-c5a8-4f27-8535-dd5618ee7caf','4827a2e3-79e5-11f1-a1f6-002b67818c25',1,'2026-07-17 17:07:25.525015'),('cd0c0678-86f8-4f29-a44b-db12a4e481ec','14fcb920-2d27-4903-b6ae-c8c21cbd1c81','7e6dafb6-7f8f-481f-b197-b22c1746e539',1,'2026-07-23 13:52:18.254770');
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
INSERT INTO `customer_survey_type_severities` VALUES ('1e95fb79-ee0d-41aa-b26a-99f07e50976c','79589597-afe5-42ba-bd7d-e9d7df2f2c68','903e0508-30db-405c-8f36-e6dfc8f0fb10',1,'2026-07-23 13:52:38.337320'),('32aa190f-d0de-448d-b533-421da6e87ce9','94e7124b-c5a8-4f27-8535-dd5618ee7caf','4821a7f4-79e5-11f1-a1f6-002b67818c25',1,'2026-07-17 17:07:25.514990'),('cd0c0678-86f8-4f29-a44b-db12a4e481ec','14fcb920-2d27-4903-b6ae-c8c21cbd1c81','81b8cb6c-9b80-4336-bb2f-df19035bb7b7',1,'2026-07-23 13:52:18.248253');
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
INSERT INTO `customer_survey_type_test_parameters` VALUES ('1e95fb79-ee0d-41aa-b26a-99f07e50976c','79589597-afe5-42ba-bd7d-e9d7df2f2c68','61b24416-1880-4d7f-a97a-e0429cc21ecf',1,'2026-07-23 13:52:38.338914'),('32aa190f-d0de-448d-b533-421da6e87ce9','94e7124b-c5a8-4f27-8535-dd5618ee7caf','4824f0f9-79e5-11f1-a1f6-002b67818c25',1,'2026-07-17 17:07:25.521298'),('cd0c0678-86f8-4f29-a44b-db12a4e481ec','14fcb920-2d27-4903-b6ae-c8c21cbd1c81','6c8619be-d563-4dea-a527-c3c8e7148911',1,'2026-07-23 13:52:18.251333');
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
INSERT INTO `customers` VALUES ('16473014-ae6c-4ee8-8f7f-a34cfc63ab3a','U289518363','UAT Isolation 89518363','Data uji lokal finalisasi menu Admin',NULL,'PIC UAT','0800000000','uat-iso-89518363@example.test',NULL,14,'inactive',NULL,NULL,'2026-07-23 13:51:58.907287','2026-07-23 13:53:04.000000',NULL),('1b36b739-2080-451a-9092-64b5b771167a','A0723110926-A','UAT ISO CEDEX A0723110926 Customer A','UAT only',NULL,NULL,NULL,NULL,NULL,NULL,'inactive',NULL,NULL,'2026-07-23 11:09:26.477338','2026-07-23 11:09:27.000000',NULL),('1e95fb79-ee0d-41aa-b26a-99f07e50976c','UAT89557566','UAT Admin Finalisasi 89557566','Data uji lokal finalisasi menu Admin',NULL,'PIC UAT','0800000000','uat-89557566@example.test','Alamat penagihan UAT',14,'inactive',NULL,NULL,'2026-07-23 13:52:38.027986','2026-07-23 13:52:38.000000',NULL),('32aa190f-d0de-448d-b533-421da6e87ce9','UAT-CUST-17B','UAT Customer Scope 17B','UAT only',NULL,NULL,NULL,NULL,NULL,NULL,'active',NULL,NULL,'2026-07-17 16:56:33.821926','2026-07-17 16:56:33.821926',NULL),('42aee823-b9d1-4788-9fd6-cdce2cb732f8','UAT-ISO-CEDEX-20260723115019-A','UAT ISO CEDEX UAT-ISO-CEDEX-20260723115019 Customer A','UAT only',NULL,NULL,NULL,NULL,NULL,NULL,'inactive',NULL,NULL,'2026-07-23 11:50:19.409601','2026-07-23 11:50:20.000000',NULL),('4d388157-406a-47e6-9343-8ad39bbf6700','U289557566','UAT Isolation 89557566','Data uji lokal finalisasi menu Admin',NULL,'PIC UAT','0800000000','uat-iso-89557566@example.test',NULL,14,'inactive',NULL,NULL,'2026-07-23 13:52:38.041621','2026-07-23 13:52:38.000000',NULL),('5581423d-c969-43b4-ba9b-b427ac1511ed','UAT89518363','UAT Admin Finalisasi 89518363','Data uji lokal finalisasi menu Admin',NULL,'PIC UAT','0800000000','uat-89518363@example.test','Alamat penagihan UAT',14,'inactive',NULL,NULL,'2026-07-23 13:51:58.884150','2026-07-23 13:53:04.000000',NULL),('5d275989-b5f8-4f56-abb7-1e6cf8630449','UAT-ISO-CEDEX-20260723115019-B','UAT ISO CEDEX UAT-ISO-CEDEX-20260723115019 Customer B','UAT only',NULL,NULL,NULL,NULL,NULL,NULL,'inactive',NULL,NULL,'2026-07-23 11:50:19.424651','2026-07-23 11:50:20.000000',NULL),('9eaabd4d-581a-4c1d-811a-4e3253300088','A0723110926-B','UAT ISO CEDEX A0723110926 Customer B','UAT only',NULL,NULL,NULL,NULL,NULL,NULL,'inactive',NULL,NULL,'2026-07-23 11:09:26.490686','2026-07-23 11:09:27.000000',NULL),('af4d13f9-693e-4ded-8009-a43ef878741a','U289537506','UAT Isolation 89537506','Data uji lokal finalisasi menu Admin',NULL,'PIC UAT','0800000000','uat-iso-89537506@example.test',NULL,14,'inactive',NULL,NULL,'2026-07-23 13:52:17.948247','2026-07-23 13:53:04.000000',NULL),('cd0c0678-86f8-4f29-a44b-db12a4e481ec','UAT89537506','UAT Admin Finalisasi 89537506','Data uji lokal finalisasi menu Admin',NULL,'PIC UAT','0800000000','uat-89537506@example.test','Alamat penagihan UAT',14,'inactive',NULL,NULL,'2026-07-23 13:52:17.936883','2026-07-23 13:53:04.000000',NULL),('e2e00004-0000-4000-8000-000000000010','UAT-ISOLATION-CROSS-20260811','UAT Customer Isolation Cross Scope','UAT isolation only',NULL,NULL,NULL,NULL,NULL,NULL,'active','16d75d68-b6c2-43de-97c6-ec099ae08ce0','16d75d68-b6c2-43de-97c6-ec099ae08ce0','2026-08-11 12:04:27.833205','2026-08-11 12:04:27.833205',NULL),('fe540f39-80fa-4bf3-8795-08d5c022d9f2','UAT-CUST-17','UAT Customer Scope 17','UAT only',NULL,NULL,NULL,NULL,NULL,NULL,'active',NULL,NULL,'2026-07-17 16:53:11.092423','2026-07-17 16:53:11.092423',NULL);
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
INSERT INTO `evidence_photo_categories` VALUES ('18bf2745-3dae-4b30-85a1-af359690d6af','PC89557566','Photo Category UAT','Data uji lokal',0,'inspection',1,'active','2026-07-23 13:52:38.325798','2026-07-23 13:52:38.325798'),('48278e9f-79e5-11f1-a1f6-002b67818c25','general_container','General Container','Foto umum peti kemas.',1,'inspection',10,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('48279fb9-79e5-11f1-a1f6-002b67818c25','container_number','Container Number','Foto nomor peti kemas.',1,'inspection',20,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('4827a123-79e5-11f1-a1f6-002b67818c25','csc_plate','CSC Plate','Foto plate persetujuan keselamatan.',1,'inspection',30,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('4827a1f4-79e5-11f1-a1f6-002b67818c25','structural_component','Structural Component','Foto komponen struktur.',0,'inspection',40,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('4827a2e3-79e5-11f1-a1f6-002b67818c25','damage_finding','Damage Finding','Foto temuan kerusakan.',0,'finding',50,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('4827a3af-79e5-11f1-a1f6-002b67818c25','test_result','Test Result','Foto atau lampiran hasil pengujian.',0,'test',60,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('4827a476-79e5-11f1-a1f6-002b67818c25','repair_evidence','Repair Evidence','Evidence perbaikan.',0,'repair',70,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('4827a52d-79e5-11f1-a1f6-002b67818c25','reinspection_evidence','Reinspection Evidence','Evidence re-inspection.',0,'reinspection',80,'active','2026-07-07 16:21:49.020212','2026-07-07 16:21:49.020212'),('7e6dafb6-7f8f-481f-b197-b22c1746e539','PC89537506','Photo Category UAT','Data uji lokal',0,'inspection',1,'active','2026-07-23 13:52:18.233696','2026-07-23 13:52:18.233696'),('85d7a58e-5b30-41d8-bdc1-e141d2be7629','PX89557566','Photo Delete UAT','Data uji lokal',0,'inspection',1,'inactive','2026-07-23 13:52:38.808735','2026-07-23 13:52:38.000000'),('8b1b5b9a-dfb1-4758-8916-d27b45801ff0','PCUAT-ISO-CEDEX-20260723115019','UAT Photo UAT-ISO-CEDEX-20260723115019','UAT',0,'inspection',999,'inactive','2026-07-23 11:50:20.142468','2026-07-23 11:50:20.000000'),('e5f94595-e77d-4361-bf9f-aa2f71432f22','PCR0723111009','Retry Photo R0723111009','UAT',0,'inspection',999,'inactive','2026-07-23 11:10:09.094010','2026-07-23 11:13:02.000000');
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
INSERT INTO `file_objects` VALUES ('66a2682d-0639-47a2-903c-d0c735bb9eff','gift-survey-uat-real-case-d','uat/UAT-REAL-CASE-2026-08/run-d/surveys/e2e00003-0000-4000-8000-000000000301/photos/watermarked/66b27125-887c-4b8b-b480-f7c163d6d5d0.jpg','gift-logo-watermarked.jpg','image/jpeg',37578,'cfc82e2f8014b4e73fb3b0feba00f30e97411b04b6a0388adfc3895dbd436629','private',NULL,'8d94550e-df85-4ccf-9b87-f6717f61cccf','2026-08-11 12:09:21.063499',NULL),('a9171329-8565-4c96-849d-0a539392d65a','gift-survey-uat-real-case-d','uat/UAT-REAL-CASE-2026-08/run-d/surveys/e2e00003-0000-4000-8000-000000000301/photos/original/66b27125-887c-4b8b-b480-f7c163d6d5d0.png','gift-logo.png','image/png',99477,'985e3030426507a4727e6945b5d302d6d9532d0fc364ebecf1aa2839d7e0cfc3','private',NULL,'8d94550e-df85-4ccf-9b87-f6717f61cccf','2026-08-11 12:09:21.061192',NULL),('b8f945ef-41f6-4916-a0ce-d8a7b91224f9','gift-survey-uat-real-case-d','uat/UAT-REAL-CASE-2026-08/run-d/surveys/e2e00002-0000-4000-8000-000000000201/photos/original/adda92b4-de63-42e8-85b1-ed10b0549446.png','gift-logo.png','image/png',99477,'985e3030426507a4727e6945b5d302d6d9532d0fc364ebecf1aa2839d7e0cfc3','private',NULL,'8d94550e-df85-4ccf-9b87-f6717f61cccf','2026-08-11 12:09:29.735393',NULL),('bd0316d7-d620-48a9-a158-1655c0d6a814','gift-survey-uat-real-case-d','uat/UAT-REAL-CASE-2026-08/run-d/surveys/e2e00002-0000-4000-8000-000000000201/photos/watermarked/adda92b4-de63-42e8-85b1-ed10b0549446.jpg','gift-logo-watermarked.jpg','image/jpeg',37556,'0c18b8ec8fe6bf855f8ce460d6f635879bf75f6a44faf3c78789b080ae533600','private',NULL,'8d94550e-df85-4ccf-9b87-f6717f61cccf','2026-08-11 12:09:29.736938',NULL);
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
INSERT INTO `finding_severities` VALUES ('471c4676-df8c-4e59-9649-55e546cdb3cc','FSA0723110926','UAT Severity A0723110926','UAT',99,0,0,'neutral','inactive','2026-07-23 11:09:27.271539','2026-07-23 11:09:27.000000'),('4821a7f4-79e5-11f1-a1f6-002b67818c25','minor','Minor','Temuan ringan.',1,0,0,'neutral','active','2026-07-07 16:21:48.980742','2026-07-07 16:21:48.980742'),('4821ae79-79e5-11f1-a1f6-002b67818c25','major','Major','Temuan signifikan yang perlu review.',2,1,1,'warning','active','2026-07-07 16:21:48.980742','2026-07-07 16:21:48.980742'),('4821b088-79e5-11f1-a1f6-002b67818c25','critical','Critical','Temuan kritikal yang memengaruhi kelaikan.',3,1,1,'danger','active','2026-07-07 16:21:48.980742','2026-07-07 16:21:48.980742'),('81b8cb6c-9b80-4336-bb2f-df19035bb7b7','sv89537506','Severity UAT','Data uji lokal',1,0,0,'neutral','active','2026-07-23 13:52:18.208726','2026-07-23 13:52:18.208726'),('903e0508-30db-405c-8f36-e6dfc8f0fb10','sv89557566','Severity UAT','Data uji lokal',1,0,0,'neutral','active','2026-07-23 13:52:38.305663','2026-07-23 13:52:38.305663'),('d981b0ce-416c-498d-8b94-eebbb0bc34eb','FSUAT-ISO-CEDEX-20260723115019','UAT Severity UAT-ISO-CEDEX-20260723115019','UAT',99,0,0,'neutral','inactive','2026-07-23 11:50:20.169259','2026-07-23 11:50:20.000000');
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
INSERT INTO `fitness_approval_categories` VALUES ('4810596e-79e5-11f1-a1f6-002b67818c25','new_individual','Peti Kemas Baru Individual','Persetujuan kelaikan untuk peti kemas baru individual.','new',1,10,'active','2026-07-07 16:21:48.865067','2026-07-07 16:21:48.865067'),('48109af3-79e5-11f1-a1f6-002b67818c25','existing_used','Peti Kemas Lama yang Telah Digunakan','Persetujuan kelaikan untuk peti kemas lama yang telah digunakan.','existing',1,20,'active','2026-07-07 16:21:48.865067','2026-07-07 16:21:48.865067'),('4810a158-79e5-11f1-a1f6-002b67818c25','existing_produced_without_initial_approval','Peti Kemas yang Sudah Diproduksi dan Belum Mendapat Persetujuan Awal','Persetujuan kelaikan untuk peti kemas yang sudah diproduksi dan belum mendapat persetujuan awal.','existing',1,30,'active','2026-07-07 16:21:48.865067','2026-07-07 16:21:48.865067'),('4810a531-79e5-11f1-a1f6-002b67818c25','type_design','Peti Kemas Baru Type Design','Future scope; tidak aktif pada MVP.','new',0,90,'inactive','2026-07-07 16:21:48.865067','2026-07-07 16:21:48.865067');
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
INSERT INTO `fitness_checklist_template_items` VALUES ('3798b4be-809c-4ddf-949d-426833064328','b320301c-1f96-4967-8d0c-c8a1c3c3dd0f','ITMF0723111302','UAT Checklist Item F0723111302',NULL,NULL,NULL,NULL,'ok_not_ok',NULL,1,0,0,0,1,'active','2026-07-23 11:13:02.673317','2026-07-23 11:13:02.673317'),('5665a85b-983b-4764-b230-d698bd4f3ae5','0b56a5b1-d55d-47bd-a00e-26654be2a956','IT89557566','Kondisi umum sesuai','Item uji lokal',NULL,NULL,'61b24416-1880-4d7f-a97a-e0429cc21ecf','yes_no','yes',1,0,0,0,1,'active','2026-07-23 13:52:38.366281','2026-07-23 13:52:38.366281'),('79da1452-157f-4335-8780-a27115d270ae','545482cc-7dba-40b4-8558-d33de2382d8d','ITMUAT-ISO-CEDEX-20260723115019','UAT Checklist Item UAT-ISO-CEDEX-20260723115019',NULL,NULL,NULL,NULL,'ok_not_ok',NULL,1,0,0,0,1,'active','2026-07-23 11:50:19.889114','2026-07-23 11:50:19.889114'),('c94111b5-592a-4334-9d24-085933082e45','40c67324-02f0-4cbe-8d94-8f4b71008693','IT89537506','Kondisi umum sesuai','Item uji lokal',NULL,NULL,'6c8619be-d563-4dea-a527-c3c8e7148911','yes_no','yes',1,0,0,0,1,'active','2026-07-23 13:52:18.294276','2026-07-23 13:52:18.294276'),('e2e00004-0000-4000-8000-000000000060','e2e00004-0000-4000-8000-000000000050','UAT-ISO-ITEM','Item Isolation UAT',NULL,NULL,NULL,NULL,'ok_not_ok',NULL,1,0,0,0,1,'active','2026-08-11 12:04:27.839094','2026-08-11 12:04:27.839094');
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
INSERT INTO `fitness_checklist_templates` VALUES ('0b56a5b1-d55d-47bd-a00e-26654be2a956','1e95fb79-ee0d-41aa-b26a-99f07e50976c','CK89557566','Checklist UAT',NULL,'79589597-afe5-42ba-bd7d-e9d7df2f2c68','c3a0e586-8fda-40de-bd9c-4e5689ffe647','Checklist uji lokal',1,'active',NULL,NULL,NULL,'2026-07-23 13:52:38.353931','2026-07-23 13:52:38.000000',NULL),('40c67324-02f0-4cbe-8d94-8f4b71008693','cd0c0678-86f8-4f29-a44b-db12a4e481ec','CK89537506','Checklist UAT',NULL,'14fcb920-2d27-4903-b6ae-c8c21cbd1c81','a49affc2-b9d4-497d-a617-d25fd1d68300','Checklist uji lokal',1,'active',NULL,NULL,NULL,'2026-07-23 13:52:18.274766','2026-07-23 13:52:18.000000',NULL),('545482cc-7dba-40b4-8558-d33de2382d8d','42aee823-b9d1-4788-9fd6-cdce2cb732f8','TPLUAT-ISO-CEDEX-20260723115019','UAT Checklist UAT-ISO-CEDEX-20260723115019',NULL,'62581b70-cf5f-4d2b-b01e-e3367fb5493a','a9e4829b-c6d4-4fe0-b58b-ee05390713ac','UAT',1,'inactive',NULL,NULL,NULL,'2026-07-23 11:50:19.870008','2026-07-23 11:50:20.000000',NULL),('b320301c-1f96-4967-8d0c-c8a1c3c3dd0f','32aa190f-d0de-448d-b533-421da6e87ce9','TPLF0723111302','UAT Checklist F0723111302',NULL,'94e7124b-c5a8-4f27-8535-dd5618ee7caf','06132cac-4ae5-4b80-9b07-417edcf756f1','UAT',1,'active',NULL,NULL,NULL,'2026-07-23 11:13:02.636457','2026-07-23 11:13:25.000000',NULL),('e2e00004-0000-4000-8000-000000000050','e2e00004-0000-4000-8000-000000000010','UAT-ISO-TPL','Checklist Isolation UAT',NULL,'e2e00004-0000-4000-8000-000000000030','e2e00004-0000-4000-8000-000000000040','UAT-REAL-CASE-2026-08',1,'active','16d75d68-b6c2-43de-97c6-ec099ae08ce0','16d75d68-b6c2-43de-97c6-ec099ae08ce0','2026-08-11 12:04:27.000000','2026-08-11 12:04:27.838443','2026-08-11 12:04:27.838443',NULL);
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
INSERT INTO `inspection_areas` VALUES ('48167e70-79e5-11f1-a1f6-002b67818c25','left_side','Left Side','Sisi kiri peti kemas.',10,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('481683e7-79e5-11f1-a1f6-002b67818c25','right_side','Right Side','Sisi kanan peti kemas.',20,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('481685b8-79e5-11f1-a1f6-002b67818c25','front_end','Front End','Bagian depan peti kemas.',30,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('48168684-79e5-11f1-a1f6-002b67818c25','door_end','Door End','Bagian pintu peti kemas.',40,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('4816874d-79e5-11f1-a1f6-002b67818c25','roof','Roof','Atap peti kemas.',50,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('48168812-79e5-11f1-a1f6-002b67818c25','floor','Floor','Lantai peti kemas.',60,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('481688cc-79e5-11f1-a1f6-002b67818c25','understructure','Understructure','Struktur bawah peti kemas.',70,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('4816899b-79e5-11f1-a1f6-002b67818c25','corner_area','Corner Area','Area corner post dan corner fitting.',80,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592'),('48168a4f-79e5-11f1-a1f6-002b67818c25','csc_plate_area','CSC Plate Area','Area plate persetujuan keselamatan.',90,'active','2026-07-07 16:21:48.908592','2026-07-07 16:21:48.908592');
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
INSERT INTO `inspection_recommendations` VALUES ('482b299f-79e5-11f1-a1f6-002b67818c25','fit','Layak','Direkomendasikan layak.','fit','under_review','none',1,'active','2026-07-07 16:21:49.043135','2026-07-07 16:21:49.043135'),('482b3372-79e5-11f1-a1f6-002b67818c25','need_repair','Perlu Perbaikan','Perlu perbaikan sebelum keputusan akhir.','pending','need_repair','suspended',1,'active','2026-07-07 16:21:49.043135','2026-07-07 16:21:49.043135'),('482b36bd-79e5-11f1-a1f6-002b67818c25','unfit','Tidak Layak','Direkomendasikan tidak layak.','unfit','under_review','prohibited',1,'active','2026-07-07 16:21:49.043135','2026-07-07 16:21:49.043135'),('482b3846-79e5-11f1-a1f6-002b67818c25','need_reinspection','Perlu Re-Inspection','Perlu pemeriksaan ulang.','pending','ready_for_reinspection','suspended',1,'active','2026-07-07 16:21:49.043135','2026-07-07 16:21:49.043135'),('482b39cb-79e5-11f1-a1f6-002b67818c25','suspend_use','Dilarang Digunakan Sementara','Penggunaan ditangguhkan sementara.','pending','need_repair','suspended',1,'active','2026-07-07 16:21:49.043135','2026-07-07 16:21:49.043135');
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
  `description` text,
  `unit` varchar(50) DEFAULT NULL,
  `standard_reference` varchar(200) DEFAULT NULL,
  `clause_section` varchar(150) DEFAULT NULL,
  `reference_type` varchar(50) DEFAULT NULL,
  `reference_clause` varchar(120) DEFAULT NULL,
  `effective_date` date DEFAULT NULL,
  `expiry_date` date DEFAULT NULL,
  `reference_attachment_file_id` char(36) DEFAULT NULL,
  `expires_at` date DEFAULT NULL,
  `attachment_file_id` char(36) DEFAULT NULL,
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
  KEY `idx_inspection_test_parameters_effective_date` (`effective_date`),
  KEY `idx_inspection_test_parameters_attachment` (`attachment_file_id`),
  KEY `idx_inspection_test_parameters_validity` (`effective_date`,`expiry_date`),
  KEY `idx_inspection_test_parameters_reference_attachment` (`reference_attachment_file_id`),
  CONSTRAINT `fk_inspection_test_parameters_attachment` FOREIGN KEY (`attachment_file_id`) REFERENCES `file_objects` (`id`),
  CONSTRAINT `fk_inspection_test_parameters_reference_attachment` FOREIGN KEY (`reference_attachment_file_id`) REFERENCES `file_objects` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `inspection_test_parameters`
--

LOCK TABLES `inspection_test_parameters` WRITE;
/*!40000 ALTER TABLE `inspection_test_parameters` DISABLE KEYS */;
INSERT INTO `inspection_test_parameters` VALUES ('4824daef-79e5-11f1-a1f6-002b67818c25','lifting_test','Lifting Test','Pengujian lifting.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,10,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824e229-79e5-11f1-a1f6-002b67818c25','stacking_test','Stacking Test','Pengujian stacking.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,20,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824e594-79e5-11f1-a1f6-002b67818c25','concentrated_load_test','Concentrated Load Test','Pengujian concentrated load.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,30,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824e734-79e5-11f1-a1f6-002b67818c25','transverse_racking_test','Transverse Racking Test','Pengujian transverse racking.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,1,0,40,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824e9fd-79e5-11f1-a1f6-002b67818c25','longitudinal_restraint_test','Longitudinal Restraint Test','Pengujian longitudinal restraint.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,50,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824ec3e-79e5-11f1-a1f6-002b67818c25','side_wall_strength','Side Wall Strength','Pemeriksaan kekuatan side wall.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,60,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824ee28-79e5-11f1-a1f6-002b67818c25','end_wall_strength','End Wall Strength','Pemeriksaan kekuatan end wall.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,70,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824ef92-79e5-11f1-a1f6-002b67818c25','one_door_off_operation','One Door Off Operation','Pemeriksaan operasi one door off.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,0,0,0,80,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824f0f9-79e5-11f1-a1f6-002b67818c25','watertightness_test','Watertightness Test','Pengujian kedap air.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,1,90,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('4824f25b-79e5-11f1-a1f6-002b67818c25','ndt_if_required','NDT If Required','NDT jika diperlukan.',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,1,100,'active','2026-07-07 16:21:49.001635','2026-07-07 16:21:49.001635'),('52a2a24a-024f-437c-a59d-29f79013ae27','TPA0723110926','UAT Parameter A0723110926','UAT',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,999,'inactive','2026-07-23 11:09:27.240490','2026-07-23 11:09:27.000000'),('61b24416-1880-4d7f-a97a-e0429cc21ecf','TP89557566','Test Parameter UAT','Tanpa ambang atau standar rekaan',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,1,'active','2026-07-23 13:52:38.315375','2026-07-23 13:52:38.315375'),('6c8619be-d563-4dea-a527-c3c8e7148911','TP89537506','Test Parameter UAT','Tanpa ambang atau standar rekaan',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,1,'active','2026-07-23 13:52:18.221281','2026-07-23 13:52:18.221281'),('c02838f6-4057-4e88-b203-65323eea97f9','TPUAT-ISO-CEDEX-20260723115019','UAT Parameter UAT-ISO-CEDEX-20260723115019','UAT',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,1,0,0,999,'inactive','2026-07-23 11:50:20.112613','2026-07-23 11:50:20.000000');
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
  KEY `idx_job_containers_job_status_deleted` (`job_order_id`,`status`,`deleted_at`),
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
INSERT INTO `job_containers` VALUES ('30956aa8-4a29-4628-b5a2-2d297cd4208e','9cb28aad-c5f8-4a6e-93c6-7718905972fe','TSTU9557567','TSTU9557567','TSTU','955756','7',NULL,1,'valid','Nomor sintetis untuk UAT lokal',NULL,NULL,'c3a0e586-8fda-40de-bd9c-4e5689ffe647','22G1','IMP-89557566','empty',30000.00,2200.00,27800.00,'2020-01-01','valid',NULL,NULL,NULL,NULL,NULL,'B 1000 UAT','Driver UAT','Import UAT','rejected','2026-07-23 13:52:38.442300','2026-07-23 13:52:38.000000',NULL),('37e74fda-ed4b-499a-a6a0-849adfeb99b7','1b39e6d9-c766-41ae-bdfb-24b53e76eaa9','CSQU3054383','CSQU3054383','CSQU','305438','3',NULL,1,'valid',NULL,NULL,NULL,'06132cac-4ae5-4b80-9b07-417edcf756f1','22G1',NULL,'empty',NULL,NULL,NULL,NULL,'valid',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UAT-ISO-CEDEX-20260723112314 synthetic reject','rejected','2026-07-23 11:23:15.531580','2026-07-23 11:23:15.000000',NULL),('82b50221-7114-4dce-8544-c0508885094b','e8438630-bfbf-4861-be6f-73611a3f479c','MSKU1234567','MSKU1234567','MSKU','123456','7',NULL,0,'override','UAT check digit override',NULL,NULL,'06132cac-4ae5-4b80-9b07-417edcf756f1','22G1','UAT','empty',NULL,NULL,NULL,NULL,'valid',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UAT-ISO-CEDEX import','in_progress','2026-07-23 11:43:35.646690','2026-07-23 11:51:58.000000',NULL),('b517fda0-6324-4bbe-9d9e-4ac166232d53','daf62320-72ab-42ed-b509-dd6b0a2ba413','TSTU9537506','TSTU9537506','TSTU','953750','6',NULL,0,'override','Nomor sintetis untuk UAT lokal',NULL,NULL,'a49affc2-b9d4-497d-a617-d25fd1d68300','22G1','SEAL-89537506','empty',30000.00,2200.00,27800.00,'2020-01-01','valid',NULL,NULL,NULL,NULL,NULL,'B 1000 UAT','Driver UAT','Add Container regression UAT','in_progress','2026-07-23 13:52:18.365853','2026-07-23 13:52:18.000000',NULL),('c31da96a-53ce-4a1c-a194-c441fea1a43d','4f3589d9-1d31-4063-bf92-06e06a966fc0','MSKU1234565','MSKU1234565','MSKU','123456','5',NULL,1,'valid',NULL,NULL,NULL,'a9e4829b-c6d4-4fe0-b58b-ee05390713ac','22G1',NULL,'empty',NULL,NULL,NULL,NULL,'valid',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UAT audit','assigned','2026-07-23 11:50:19.939495','2026-07-23 11:50:19.000000',NULL),('d52f27a5-6060-41f6-aaad-a9d3deaa837b','9cb28aad-c5f8-4a6e-93c6-7718905972fe','TSTU9557566','TSTU9557566','TSTU','955756','6',NULL,0,'override','Nomor sintetis untuk UAT lokal',NULL,NULL,'c3a0e586-8fda-40de-bd9c-4e5689ffe647','22G1','SEAL-89557566','empty',30000.00,2200.00,27800.00,'2020-01-01','valid',NULL,NULL,NULL,NULL,NULL,'B 1000 UAT','Driver UAT','Add Container regression UAT','approved','2026-07-23 13:52:38.418607','2026-07-23 13:52:38.000000',NULL),('e2e00001-0000-4000-8000-000000000201','e2e00001-0000-4000-8000-000000000001','GFTU1234560','GFTU1234560',NULL,NULL,NULL,NULL,NULL,'not_checked',NULL,NULL,NULL,'06132cac-4ae5-4b80-9b07-417edcf756f1','22G1',NULL,'empty',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UAT-REAL-CASE-2026-08','draft','2026-08-11 12:04:27.778828','2026-08-11 12:09:16.000000',NULL),('e2e00001-0000-4000-8000-000000000202','e2e00001-0000-4000-8000-000000000001','NPKU7654323','NPKU7654323',NULL,NULL,NULL,NULL,NULL,'not_checked',NULL,NULL,NULL,'06132cac-4ae5-4b80-9b07-417edcf756f1','22G1',NULL,'empty',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UAT-REAL-CASE-2026-08','assigned','2026-08-11 12:04:27.782710','2026-08-11 12:04:27.782710',NULL),('e2e00002-0000-4000-8000-000000000201','e2e00002-0000-4000-8000-000000000001','NPKU1357903','NPKU1357903',NULL,NULL,NULL,NULL,NULL,'not_checked',NULL,NULL,NULL,'06132cac-4ae5-4b80-9b07-417edcf756f1','22G1',NULL,'empty',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UAT-REAL-CASE-2026-08','rejected','2026-08-11 12:04:27.785502','2026-08-11 12:09:31.000000',NULL),('e2e00002-0000-4000-8000-000000000202','e2e00002-0000-4000-8000-000000000001','BCKU1122331','BCKU1122331',NULL,NULL,NULL,NULL,NULL,'not_checked',NULL,NULL,NULL,'06132cac-4ae5-4b80-9b07-417edcf756f1','22G1',NULL,'empty',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UAT-REAL-CASE-2026-08','approved','2026-08-11 12:04:27.799667','2026-08-11 12:04:27.799667',NULL),('e2e00003-0000-4000-8000-000000000201','e2e00003-0000-4000-8000-000000000001','BCKU2468102','BCKU2468102',NULL,NULL,NULL,NULL,NULL,'not_checked',NULL,NULL,NULL,'06132cac-4ae5-4b80-9b07-417edcf756f1','22G1',NULL,'empty',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UAT-REAL-CASE-2026-08','approved','2026-08-11 12:04:27.812232','2026-08-11 12:09:26.000000',NULL),('e2e00003-0000-4000-8000-000000000202','e2e00003-0000-4000-8000-000000000001','GFTU6543216','GFTU6543216',NULL,NULL,NULL,NULL,NULL,'not_checked',NULL,NULL,NULL,'06132cac-4ae5-4b80-9b07-417edcf756f1','22G1',NULL,'empty',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UAT-REAL-CASE-2026-08','approved','2026-08-11 12:04:27.823350','2026-08-11 12:04:27.823350',NULL),('e2e00004-0000-4000-8000-000000000201','e2e00004-0000-4000-8000-000000000001','UATU0000015','UATU0000015',NULL,NULL,NULL,NULL,NULL,'not_checked',NULL,NULL,NULL,'e2e00004-0000-4000-8000-000000000040','22G1',NULL,'empty',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UAT-REAL-CASE-2026-08','draft','2026-08-11 12:04:27.840841','2026-08-11 12:04:27.840841',NULL),('ef3108a3-5d1e-4832-af0b-eb174edc0675','ba973397-9eee-4cf9-b987-9a2e4e727195','MSKU1234565','MSKU1234565','MSKU','123456','5',NULL,1,'valid',NULL,NULL,NULL,'06132cac-4ae5-4b80-9b07-417edcf756f1','22G1',NULL,'empty',NULL,NULL,NULL,NULL,'valid',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'UAT after fix','approved','2026-07-23 11:13:02.722313','2026-07-23 11:23:15.000000',NULL),('fd058dbe-7585-43f8-bc5a-a96fc0c102cf','daf62320-72ab-42ed-b509-dd6b0a2ba413','TSTU9537507','TSTU9537507','TSTU','953750','7',NULL,0,'override','Nomor sintetis untuk UAT lokal',NULL,NULL,'a49affc2-b9d4-497d-a617-d25fd1d68300','22G1','IMP-89537506','empty',30000.00,2200.00,27800.00,'2020-01-01','valid',NULL,NULL,NULL,NULL,NULL,'B 1000 UAT','Driver UAT','Import UAT','in_progress','2026-07-23 13:52:18.392604','2026-07-23 13:52:18.000000',NULL);
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
INSERT INTO `job_events` VALUES ('01b34107-8652-11f1-a160-002b67818c25','4f3589d9-1d31-4063-bf92-06e06a966fc0','job_created','Job order dibuat.','Job order GIFT-JO-2026-000005 dibuat.','00000000-0000-0000-0000-000000000002','{\"id\": \"4f3589d9-1d31-4063-bf92-06e06a966fc0\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000005\"}','2026-07-23 11:50:19.916065'),('01b6f547-8652-11f1-a160-002b67818c25','4f3589d9-1d31-4063-bf92-06e06a966fc0','container_added','Container ditambahkan.','MSKU1234565','00000000-0000-0000-0000-000000000002','{\"id\": \"c31da96a-53ce-4a1c-a194-c441fea1a43d\", \"status\": \"not_started\", \"container_no\": \"MSKU1234565\", \"check_digit_status\": \"valid\"}','2026-07-23 11:50:19.940346'),('01bbae6f-8652-11f1-a160-002b67818c25','4f3589d9-1d31-4063-bf92-06e06a966fc0','surveyor_assigned','Surveyor ditugaskan.','1 container ditugaskan','00000000-0000-0000-0000-000000000002','{\"id\": \"de85f1b5-14b7-4233-972e-16800b5461de\", \"status\": \"assigned\", \"due_date\": null, \"start_date\": null, \"instruction\": \"UAT audit\", \"assignment_no\": \"GIFT-ASG-2026-000003\", \"assigned_containers\": 1}','2026-07-23 11:50:19.971295'),('0407e571-864e-11f1-a160-002b67818c25','ba973397-9eee-4cf9-b987-9a2e4e727195','survey_submitted','Survey disubmit.','MSKU1234565','00000000-0000-0000-0000-000000000003','{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"submitted_at\": \"2026-07-23T04:21:45Z\"}','2026-07-23 11:21:45.839249'),('040fed03-864e-11f1-a160-002b67818c25','ba973397-9eee-4cf9-b987-9a2e4e727195','survey_need_revision','Survey perlu revisi.','UAT ISO CEDEX synthetic need revision','00000000-0000-0000-0000-000000000004','{\"status\": \"need_revision\", \"survey_id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"revision_note\": \"UAT ISO CEDEX synthetic need revision\"}','2026-07-23 11:21:45.891918'),('0bd41900-8663-11f1-a160-002b67818c25','daf62320-72ab-42ed-b509-dd6b0a2ba413','job_created','Job order dibuat.','Job order GIFT-JO-2026-000006 dibuat.','00000000-0000-0000-0000-000000000002','{\"id\": \"daf62320-72ab-42ed-b509-dd6b0a2ba413\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000006\"}','2026-07-23 13:52:18.352889'),('0bd66968-8663-11f1-a160-002b67818c25','daf62320-72ab-42ed-b509-dd6b0a2ba413','container_added','Container ditambahkan.','TSTU9537506','00000000-0000-0000-0000-000000000002','{\"id\": \"b517fda0-6324-4bbe-9d9e-4ac166232d53\", \"status\": \"not_started\", \"container_no\": \"TSTU9537506\", \"check_digit_status\": \"override\"}','2026-07-23 13:52:18.368065'),('0bdac60e-8663-11f1-a160-002b67818c25','daf62320-72ab-42ed-b509-dd6b0a2ba413','containers_imported','Container diimport.','1 berhasil, 0 gagal','00000000-0000-0000-0000-000000000002','{\"errors\": [], \"failed\": 0, \"imported\": 1, \"total_rows\": 1}','2026-07-23 13:52:18.396679'),('0bdf6523-8663-11f1-a160-002b67818c25','daf62320-72ab-42ed-b509-dd6b0a2ba413','surveyor_assigned','Surveyor ditugaskan.','2 container ditugaskan','00000000-0000-0000-0000-000000000002','{\"id\": \"4a946427-7d4d-41ab-8a84-e8576c80801f\", \"status\": \"assigned\", \"due_date\": \"2026-07-30T00:00:00Z\", \"start_date\": \"2026-07-23T00:00:00Z\", \"instruction\": \"Assignment UAT\", \"assignment_no\": \"GIFT-ASG-2026-000005\", \"assigned_containers\": 2}','2026-07-23 13:52:18.426937'),('0be3aac2-8663-11f1-a160-002b67818c25','daf62320-72ab-42ed-b509-dd6b0a2ba413','survey_started','Survey dimulai.','TSTU9537506','00000000-0000-0000-0000-000000000003','{\"id\": \"3bde18bd-5822-4531-8e90-ba16f508c162\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000004\", \"container_no\": \"TSTU9537506\", \"job_order_no\": \"GIFT-JO-2026-000006\", \"checklist_template_id\": \"40c67324-02f0-4cbe-8d94-8f4b71008693\"}','2026-07-23 13:52:18.454916'),('0be73588-8663-11f1-a160-002b67818c25','daf62320-72ab-42ed-b509-dd6b0a2ba413','survey_started','Survey dimulai.','TSTU9537507','00000000-0000-0000-0000-000000000003','{\"id\": \"c8cfacf2-cacf-43de-91a5-57c7bcb5c1d7\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000005\", \"container_no\": \"TSTU9537507\", \"job_order_no\": \"GIFT-JO-2026-000006\", \"checklist_template_id\": \"40c67324-02f0-4cbe-8d94-8f4b71008693\"}','2026-07-23 13:52:18.478117'),('10afef54-8651-11f1-a160-002b67818c25','e8438630-bfbf-4861-be6f-73611a3f479c','job_created','Job order dibuat.','Job order GIFT-JO-2026-000004 dibuat.','00000000-0000-0000-0000-000000000002','{\"id\": \"e8438630-bfbf-4861-be6f-73611a3f479c\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000004\"}','2026-07-23 11:43:35.563212'),('10cb29a5-8651-11f1-a160-002b67818c25','e8438630-bfbf-4861-be6f-73611a3f479c','containers_imported','Container diimport.','1 berhasil, 0 gagal','00000000-0000-0000-0000-000000000002','{\"errors\": [], \"failed\": 0, \"imported\": 1, \"total_rows\": 1}','2026-07-23 11:43:35.741794'),('17c82683-8663-11f1-a160-002b67818c25','9cb28aad-c5f8-4a6e-93c6-7718905972fe','job_created','Job order dibuat.','Job order GIFT-JO-2026-000007 dibuat.','00000000-0000-0000-0000-000000000002','{\"id\": \"9cb28aad-c5f8-4a6e-93c6-7718905972fe\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000007\"}','2026-07-23 13:52:38.407271'),('17ca1c3f-8663-11f1-a160-002b67818c25','9cb28aad-c5f8-4a6e-93c6-7718905972fe','container_added','Container ditambahkan.','TSTU9557566','00000000-0000-0000-0000-000000000002','{\"id\": \"d52f27a5-6060-41f6-aaad-a9d3deaa837b\", \"status\": \"not_started\", \"container_no\": \"TSTU9557566\", \"check_digit_status\": \"override\"}','2026-07-23 13:52:38.420125'),('17cdce10-8663-11f1-a160-002b67818c25','9cb28aad-c5f8-4a6e-93c6-7718905972fe','containers_imported','Container diimport.','1 berhasil, 0 gagal','00000000-0000-0000-0000-000000000002','{\"errors\": [], \"failed\": 0, \"imported\": 1, \"total_rows\": 1}','2026-07-23 13:52:38.444350'),('17d20561-8663-11f1-a160-002b67818c25','9cb28aad-c5f8-4a6e-93c6-7718905972fe','surveyor_assigned','Surveyor ditugaskan.','2 container ditugaskan','00000000-0000-0000-0000-000000000002','{\"id\": \"de3eeefb-9df3-465e-a137-0da41de4a3e9\", \"status\": \"assigned\", \"due_date\": \"2026-07-30T00:00:00Z\", \"start_date\": \"2026-07-23T00:00:00Z\", \"instruction\": \"Assignment UAT\", \"assignment_no\": \"GIFT-ASG-2026-000006\", \"assigned_containers\": 2}','2026-07-23 13:52:38.471960'),('17d4cb1a-8663-11f1-a160-002b67818c25','9cb28aad-c5f8-4a6e-93c6-7718905972fe','survey_started','Survey dimulai.','TSTU9557566','00000000-0000-0000-0000-000000000003','{\"id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000006\", \"container_no\": \"TSTU9557566\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"checklist_template_id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\"}','2026-07-23 13:52:38.490140'),('17d7ec25-8663-11f1-a160-002b67818c25','9cb28aad-c5f8-4a6e-93c6-7718905972fe','survey_started','Survey dimulai.','TSTU9557567','00000000-0000-0000-0000-000000000003','{\"id\": \"5905e03b-cc89-45cd-a99a-94f57871239c\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000007\", \"container_no\": \"TSTU9557567\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"checklist_template_id\": \"0b56a5b1-d55d-47bd-a00e-26654be2a956\"}','2026-07-23 13:52:38.510645'),('17ec09b7-8663-11f1-a160-002b67818c25','9cb28aad-c5f8-4a6e-93c6-7718905972fe','survey_submitted','Survey disubmit.','TSTU9557566','00000000-0000-0000-0000-000000000003','{\"id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000006\", \"submitted_at\": \"2026-07-23T06:52:38Z\"}','2026-07-23 13:52:38.642433'),('17eeaefc-8663-11f1-a160-002b67818c25','9cb28aad-c5f8-4a6e-93c6-7718905972fe','survey_need_revision','Survey perlu revisi.','Lengkapi verifikasi UAT','00000000-0000-0000-0000-000000000004','{\"status\": \"need_revision\", \"survey_id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"revision_note\": \"Lengkapi verifikasi UAT\"}','2026-07-23 13:52:38.659818'),('17f1beb3-8663-11f1-a160-002b67818c25','9cb28aad-c5f8-4a6e-93c6-7718905972fe','survey_submitted','Survey disubmit.','TSTU9557566','00000000-0000-0000-0000-000000000003','{\"id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000006\", \"submitted_at\": \"2026-07-23T06:52:38Z\"}','2026-07-23 13:52:38.679871'),('17f5759f-8663-11f1-a160-002b67818c25','9cb28aad-c5f8-4a6e-93c6-7718905972fe','survey_approved','Survey disetujui.','GIFT-RPT-2026-000002','00000000-0000-0000-0000-000000000004','{\"status\": \"approved\", \"report_no\": \"GIFT-RPT-2026-000002\", \"survey_id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"report_generation_status\": \"queued\"}','2026-07-23 13:52:38.704220'),('17feac94-8663-11f1-a160-002b67818c25','9cb28aad-c5f8-4a6e-93c6-7718905972fe','survey_submitted','Survey disubmit.','TSTU9557567','00000000-0000-0000-0000-000000000003','{\"id\": \"5905e03b-cc89-45cd-a99a-94f57871239c\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000007\", \"submitted_at\": \"2026-07-23T06:52:38Z\"}','2026-07-23 13:52:38.764602'),('180086cd-8663-11f1-a160-002b67818c25','9cb28aad-c5f8-4a6e-93c6-7718905972fe','survey_rejected','Survey ditolak.','Skenario reject UAT','00000000-0000-0000-0000-000000000004','{\"status\": \"rejected\", \"survey_id\": \"5905e03b-cc89-45cd-a99a-94f57871239c\", \"rejection_reason\": \"Skenario reject UAT\"}','2026-07-23 13:52:38.776744'),('396b83f2-864e-11f1-a160-002b67818c25','ba973397-9eee-4cf9-b987-9a2e4e727195','survey_submitted','Survey disubmit.','MSKU1234565','00000000-0000-0000-0000-000000000003','{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"submitted_at\": \"2026-07-23T04:23:15Z\"}','2026-07-23 11:23:15.411407'),('3972f82f-864e-11f1-a160-002b67818c25','ba973397-9eee-4cf9-b987-9a2e4e727195','survey_approved','Survey disetujui.','GIFT-RPT-2026-000001','00000000-0000-0000-0000-000000000004','{\"status\": \"approved\", \"report_no\": \"GIFT-RPT-2026-000001\", \"survey_id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"report_generation_status\": \"queued\"}','2026-07-23 11:23:15.460224'),('397c553c-864e-11f1-a160-002b67818c25','1b39e6d9-c766-41ae-bdfb-24b53e76eaa9','job_created','Job order dibuat.','Job order GIFT-JO-2026-000003 dibuat.','00000000-0000-0000-0000-000000000002','{\"id\": \"1b39e6d9-c766-41ae-bdfb-24b53e76eaa9\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000003\"}','2026-07-23 11:23:15.521623'),('397df37e-864e-11f1-a160-002b67818c25','1b39e6d9-c766-41ae-bdfb-24b53e76eaa9','container_added','Container ditambahkan.','CSQU3054383','00000000-0000-0000-0000-000000000002','{\"id\": \"37e74fda-ed4b-499a-a6a0-849adfeb99b7\", \"status\": \"not_started\", \"container_no\": \"CSQU3054383\", \"check_digit_status\": \"valid\"}','2026-07-23 11:23:15.532235'),('397fdf27-864e-11f1-a160-002b67818c25','1b39e6d9-c766-41ae-bdfb-24b53e76eaa9','surveyor_assigned','Surveyor ditugaskan.','1 container ditugaskan','00000000-0000-0000-0000-000000000002','{\"id\": \"14c3da84-9072-4fdd-a806-9f0dfe9d012f\", \"status\": \"assigned\", \"due_date\": null, \"start_date\": null, \"instruction\": \"UAT-ISO-CEDEX-20260723112314 synthetic reject\", \"assignment_no\": \"GIFT-ASG-2026-000002\", \"assigned_containers\": 1}','2026-07-23 11:23:15.544818'),('3981f798-864e-11f1-a160-002b67818c25','1b39e6d9-c766-41ae-bdfb-24b53e76eaa9','survey_started','Survey dimulai.','CSQU3054383','00000000-0000-0000-0000-000000000003','{\"id\": \"724d3aea-49fb-41de-82ce-05d35a394925\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000002\", \"container_no\": \"CSQU3054383\", \"job_order_no\": \"GIFT-JO-2026-000003\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\"}','2026-07-23 11:23:15.558551'),('398a6bfb-864e-11f1-a160-002b67818c25','1b39e6d9-c766-41ae-bdfb-24b53e76eaa9','survey_submitted','Survey disubmit.','CSQU3054383','00000000-0000-0000-0000-000000000003','{\"id\": \"724d3aea-49fb-41de-82ce-05d35a394925\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000002\", \"submitted_at\": \"2026-07-23T04:23:15Z\"}','2026-07-23 11:23:15.613958'),('398e5930-864e-11f1-a160-002b67818c25','1b39e6d9-c766-41ae-bdfb-24b53e76eaa9','survey_rejected','Survey ditolak.','UAT-ISO-CEDEX-20260723112314 synthetic reject','00000000-0000-0000-0000-000000000004','{\"status\": \"rejected\", \"survey_id\": \"724d3aea-49fb-41de-82ce-05d35a394925\", \"rejection_reason\": \"UAT-ISO-CEDEX-20260723112314 synthetic reject\"}','2026-07-23 11:23:15.639699'),('3c8e2f16-8652-11f1-a160-002b67818c25','e8438630-bfbf-4861-be6f-73611a3f479c','surveyor_assigned','Surveyor ditugaskan.','1 container ditugaskan','00000000-0000-0000-0000-000000000002','{\"id\": \"77196b64-3748-429f-ad4f-083fdb122e61\", \"status\": \"assigned\", \"due_date\": null, \"start_date\": null, \"instruction\": \"UAT-ISO-CEDEX-20260723115158-DAMAGE\", \"assignment_no\": \"GIFT-ASG-2026-000004\", \"assigned_containers\": 1}','2026-07-23 11:51:58.658683'),('3c922339-8652-11f1-a160-002b67818c25','e8438630-bfbf-4861-be6f-73611a3f479c','survey_started','Survey dimulai.','MSKU1234567','00000000-0000-0000-0000-000000000003','{\"id\": \"829ea486-456b-44e3-883d-5cc97b7c6dc9\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000003\", \"container_no\": \"MSKU1234567\", \"job_order_no\": \"GIFT-JO-2026-000004\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\"}','2026-07-23 11:51:58.684605'),('4baf688e-864c-11f1-a160-002b67818c25','cda39d6b-da4f-4c29-b08b-3f8409ccfa99','job_created','Job order dibuat.','Job order GIFT-JO-2026-000001 dibuat.','00000000-0000-0000-0000-000000000002','{\"id\": \"cda39d6b-da4f-4c29-b08b-3f8409ccfa99\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000001\"}','2026-07-23 11:09:27.061809'),('cc38ce23-864c-11f1-a160-002b67818c25','ba973397-9eee-4cf9-b987-9a2e4e727195','job_created','Job order dibuat.','Job order GIFT-JO-2026-000002 dibuat.','00000000-0000-0000-0000-000000000002','{\"id\": \"ba973397-9eee-4cf9-b987-9a2e4e727195\", \"status\": \"draft\", \"job_order_no\": \"GIFT-JO-2026-000002\"}','2026-07-23 11:13:02.710684'),('cc3ca8f8-864c-11f1-a160-002b67818c25','ba973397-9eee-4cf9-b987-9a2e4e727195','container_added','Container ditambahkan.','MSKU1234565','00000000-0000-0000-0000-000000000002','{\"id\": \"ef3108a3-5d1e-4832-af0b-eb174edc0675\", \"status\": \"not_started\", \"container_no\": \"MSKU1234565\", \"check_digit_status\": \"valid\"}','2026-07-23 11:13:02.735941'),('cc448059-864c-11f1-a160-002b67818c25','ba973397-9eee-4cf9-b987-9a2e4e727195','surveyor_assigned','Surveyor ditugaskan.','1 container ditugaskan','00000000-0000-0000-0000-000000000002','{\"id\": \"0af0234c-cf48-4860-9b19-f9943b638a4f\", \"status\": \"assigned\", \"due_date\": null, \"start_date\": null, \"instruction\": \"UAT audit\", \"assignment_no\": \"GIFT-ASG-2026-000001\", \"assigned_containers\": 1}','2026-07-23 11:13:02.787318'),('cd1f5c4f-9542-11f1-9595-002b67818c25','e2e00001-0000-4000-8000-000000000001','survey_started','Survey dimulai.','GFTU1234560','8d94550e-df85-4ccf-9b87-f6717f61cccf','{\"id\": \"749164da-9dcf-478c-be1c-973291e46176\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000008\", \"container_no\": \"GFTU1234560\", \"job_order_no\": \"UAT-JOB-2026-0805-001\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\"}','2026-08-11 12:09:16.695923'),('cfefef62-9542-11f1-9595-002b67818c25','e2e00003-0000-4000-8000-000000000001','survey_submitted','Survey disubmit.','BCKU2468102','8d94550e-df85-4ccf-9b87-f6717f61cccf','{\"id\": \"e2e00003-0000-4000-8000-000000000301\", \"status\": \"submitted\", \"survey_no\": \"UAT-SURVEY-2026-0805-003-A\", \"submitted_at\": \"2026-08-11T12:09:21Z\", \"resubmitted_at\": null}','2026-08-11 12:09:21.418325'),('d0dc5030-9542-11f1-9595-002b67818c25','e2e00003-0000-4000-8000-000000000001','survey_under_review','Review survey dimulai.','BCKU2468102','24c54a64-a645-4f8f-9b87-40a20b31d6ce','{\"status\": \"under_review\", \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"previous_status\": \"submitted\", \"current_reviewer_id\": \"24c54a64-a645-4f8f-9b87-40a20b31d6ce\"}','2026-08-11 12:09:22.967421'),('d141a5ff-9542-11f1-9595-002b67818c25','e2e00003-0000-4000-8000-000000000001','survey_need_revision','Survey perlu revisi.','UAT revisi bertarget survey.','24c54a64-a645-4f8f-9b87-40a20b31d6ce','{\"status\": \"need_revision\", \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"revision_note\": \"UAT revisi bertarget survey.\", \"revision_items\": 2}','2026-08-11 12:09:23.631551'),('d246a1f2-9542-11f1-9595-002b67818c25','e2e00003-0000-4000-8000-000000000001','survey_resubmitted','Survey disubmit ulang.','BCKU2468102','8d94550e-df85-4ccf-9b87-f6717f61cccf','{\"id\": \"e2e00003-0000-4000-8000-000000000301\", \"status\": \"resubmitted\", \"survey_no\": \"UAT-SURVEY-2026-0805-003-A\", \"submitted_at\": \"2026-08-11T12:09:21Z\", \"resubmitted_at\": \"2026-08-11T12:09:25Z\"}','2026-08-11 12:09:25.341986'),('d2ff739a-9542-11f1-9595-002b67818c25','e2e00003-0000-4000-8000-000000000001','survey_under_review','Review survey dimulai.','BCKU2468102','24c54a64-a645-4f8f-9b87-40a20b31d6ce','{\"status\": \"under_review\", \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"previous_status\": \"resubmitted\", \"current_reviewer_id\": \"24c54a64-a645-4f8f-9b87-40a20b31d6ce\"}','2026-08-11 12:09:26.553132'),('d32db474-9542-11f1-9595-002b67818c25','e2e00003-0000-4000-8000-000000000001','survey_approved','Survey disetujui.','Metadata laporan internal dibentuk.','24c54a64-a645-4f8f-9b87-40a20b31d6ce','{\"status\": \"approved\", \"report_id\": \"3eb68746-dc8a-4f6a-afea-340b033e5418\", \"report_no\": \"GIFT-RPT-2026-000003\", \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"report_generation_status\": \"metadata_ready\"}','2026-08-11 12:09:26.856309'),('d5188ea2-9542-11f1-9595-002b67818c25','e2e00002-0000-4000-8000-000000000001','survey_submitted','Survey disubmit.','NPKU1357903','8d94550e-df85-4ccf-9b87-f6717f61cccf','{\"id\": \"e2e00002-0000-4000-8000-000000000201\", \"status\": \"submitted\", \"survey_no\": \"UAT-SURVEY-2026-0805-002-A\", \"submitted_at\": \"2026-08-11T12:09:30Z\", \"resubmitted_at\": null}','2026-08-11 12:09:30.073180'),('d5fe5207-9542-11f1-9595-002b67818c25','e2e00002-0000-4000-8000-000000000001','survey_under_review','Review survey dimulai.','NPKU1357903','24c54a64-a645-4f8f-9b87-40a20b31d6ce','{\"status\": \"under_review\", \"survey_id\": \"e2e00002-0000-4000-8000-000000000201\", \"previous_status\": \"submitted\", \"current_reviewer_id\": \"24c54a64-a645-4f8f-9b87-40a20b31d6ce\"}','2026-08-11 12:09:31.578906'),('d620982d-9542-11f1-9595-002b67818c25','e2e00002-0000-4000-8000-000000000001','survey_rejected','Survey ditolak.','Ditolak untuk pembuktian cabang UAT.','24c54a64-a645-4f8f-9b87-40a20b31d6ce','{\"status\": \"rejected\", \"survey_id\": \"e2e00002-0000-4000-8000-000000000201\", \"rejection_reason\": \"Ditolak untuk pembuktian cabang UAT.\"}','2026-08-11 12:09:31.803561'),('d9fc0b0b-864c-11f1-a160-002b67818c25','ba973397-9eee-4cf9-b987-9a2e4e727195','survey_started','Survey dimulai.','MSKU1234565','00000000-0000-0000-0000-000000000003','{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"draft\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"container_no\": \"MSKU1234565\", \"job_order_no\": \"GIFT-JO-2026-000002\", \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\"}','2026-07-23 11:13:25.800578');
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
  `spk_no` varchar(100) DEFAULT NULL,
  `spk_date` date DEFAULT NULL,
  `spk_file_id` char(36) DEFAULT NULL,
  `spk_notes` text,
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
INSERT INTO `job_orders` VALUES ('1b39e6d9-c766-41ae-bdfb-24b53e76eaa9','GIFT-JO-2026-000003','2026-07-23','32aa190f-d0de-448d-b533-421da6e87ce9','94e7124b-c5a8-4f27-8535-dd5618ee7caf','3fd7d149-4e43-4c0c-96ba-b846f4155d2b','11326687-6f63-49f8-a8f2-e53b6d3e47d0','PIC UAT 17B','081700000018','pic17b@example.test','UAT-ISO-CEDEX-20260723112314-REJECT',NULL,NULL,NULL,NULL,NULL,NULL,'normal',NULL,'UAT-ISO-CEDEX-20260723112314 synthetic reject','all_survey_submitted',NULL,NULL,NULL,'00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003','2026-07-23 11:23:15.520305','2026-07-23 11:23:15.000000',NULL,NULL,NULL,NULL,NULL),('4f3589d9-1d31-4063-bf92-06e06a966fc0','GIFT-JO-2026-000005','2026-07-23','42aee823-b9d1-4788-9fd6-cdce2cb732f8','62581b70-cf5f-4d2b-b01e-e3367fb5493a','e256852a-9e06-448e-bc45-2f2f35712069','aac61537-a165-4cd0-97e0-1a3a27fdad87','UAT Personel UAT-ISO-CEDEX-20260723115019',NULL,'uat.uat-iso-cedex-20260723115019@example.test','REF-UAT-ISO-CEDEX-20260723115019',NULL,NULL,NULL,NULL,NULL,NULL,'normal',NULL,'UAT audit only','assigned',NULL,NULL,NULL,'00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000002','2026-07-23 11:50:19.914891','2026-07-23 11:50:19.000000',NULL,NULL,NULL,NULL,NULL),('9cb28aad-c5f8-4a6e-93c6-7718905972fe','GIFT-JO-2026-000007','2026-07-23','1e95fb79-ee0d-41aa-b26a-99f07e50976c','79589597-afe5-42ba-bd7d-e9d7df2f2c68','34275f3a-6e39-4224-998f-4c06aa4869cc','78654527-4834-48d5-9339-48d3eb97d4f6','Personel UAT','0811000000','pic-89557566@example.test','REF-89557566',NULL,NULL,NULL,NULL,NULL,NULL,'normal',NULL,'Data uji lokal finalisasi menu Admin','all_survey_submitted',NULL,NULL,NULL,'00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003','2026-07-23 13:52:38.406202','2026-07-23 13:52:38.000000',NULL,NULL,NULL,NULL,NULL),('ba973397-9eee-4cf9-b987-9a2e4e727195','GIFT-JO-2026-000002','2026-07-23','32aa190f-d0de-448d-b533-421da6e87ce9','94e7124b-c5a8-4f27-8535-dd5618ee7caf','3fd7d149-4e43-4c0c-96ba-b846f4155d2b','11326687-6f63-49f8-a8f2-e53b6d3e47d0','PIC UAT 17B','081700000018','pic17b@example.test','REF-F0723111302',NULL,NULL,NULL,NULL,NULL,NULL,'normal',NULL,'UAT fix verification','all_survey_approved',NULL,NULL,NULL,'00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000004','2026-07-23 11:13:02.708374','2026-07-23 11:23:15.000000',NULL,NULL,NULL,NULL,NULL),('cda39d6b-da4f-4c29-b08b-3f8409ccfa99','GIFT-JO-2026-000001','2026-07-23','1b36b739-2080-451a-9092-64b5b771167a','fe6f2dac-a29e-4350-85ad-7ee437030687','125db3af-9ece-4614-81a2-ae151bccadb4','a11cea62-7e88-46d3-be07-fed3d7920b43','UAT Personel A0723110926',NULL,'uat.a0723110926@example.test','REF-A0723110926',NULL,NULL,NULL,NULL,NULL,NULL,'normal',NULL,'UAT audit only','draft',NULL,NULL,NULL,'00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000002','2026-07-23 11:09:27.051384','2026-07-23 11:09:27.051384',NULL,NULL,NULL,NULL,NULL),('daf62320-72ab-42ed-b509-dd6b0a2ba413','GIFT-JO-2026-000006','2026-07-23','cd0c0678-86f8-4f29-a44b-db12a4e481ec','14fcb920-2d27-4903-b6ae-c8c21cbd1c81','a55a583c-7dbf-4e18-b255-f41c5d82e445','58c6bdc2-6922-4cbe-beac-93c26a94659b','Personel UAT','0811000000','pic-89537506@example.test','REF-89537506',NULL,NULL,NULL,NULL,NULL,NULL,'normal',NULL,'Data uji lokal finalisasi menu Admin','in_progress',NULL,NULL,NULL,'00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003','2026-07-23 13:52:18.348488','2026-07-23 13:52:18.000000',NULL,NULL,NULL,NULL,NULL),('e2e00001-0000-4000-8000-000000000001','UAT-JOB-2026-0805-001','2026-08-11','32aa190f-d0de-448d-b533-421da6e87ce9','94e7124b-c5a8-4f27-8535-dd5618ee7caf','3fd7d149-4e43-4c0c-96ba-b846f4155d2b',NULL,'PIC UAT',NULL,NULL,'REF-UAT-JOB-2026-0805-001',NULL,NULL,NULL,NULL,NULL,NULL,'normal','2026-08-25 12:04:27.000000','Dataset UAT-REAL-CASE-2026-08 - bukan data operasional','in_progress',NULL,NULL,NULL,'16d75d68-b6c2-43de-97c6-ec099ae08ce0','8d94550e-df85-4ccf-9b87-f6717f61cccf','2026-08-11 12:04:27.771474','2026-08-11 12:09:16.000000',NULL,NULL,NULL,NULL,NULL),('e2e00002-0000-4000-8000-000000000001','UAT-JOB-2026-0805-002','2026-08-11','32aa190f-d0de-448d-b533-421da6e87ce9','94e7124b-c5a8-4f27-8535-dd5618ee7caf','3fd7d149-4e43-4c0c-96ba-b846f4155d2b',NULL,'PIC UAT',NULL,NULL,'REF-UAT-JOB-2026-0805-002',NULL,NULL,NULL,NULL,NULL,NULL,'normal','2026-08-25 12:04:27.000000','Dataset UAT-REAL-CASE-2026-08 - bukan data operasional','completed_with_rejection',NULL,NULL,NULL,'16d75d68-b6c2-43de-97c6-ec099ae08ce0','24c54a64-a645-4f8f-9b87-40a20b31d6ce','2026-08-11 12:04:27.784132','2026-08-11 12:09:31.000000',NULL,NULL,NULL,NULL,NULL),('e2e00003-0000-4000-8000-000000000001','UAT-JOB-2026-0805-003','2026-08-11','32aa190f-d0de-448d-b533-421da6e87ce9','94e7124b-c5a8-4f27-8535-dd5618ee7caf','3fd7d149-4e43-4c0c-96ba-b846f4155d2b',NULL,'PIC UAT',NULL,NULL,'REF-UAT-JOB-2026-0805-003',NULL,NULL,NULL,NULL,NULL,NULL,'normal','2026-08-25 12:04:27.000000','Dataset UAT-REAL-CASE-2026-08 - bukan data operasional','all_survey_approved',NULL,NULL,NULL,'16d75d68-b6c2-43de-97c6-ec099ae08ce0','24c54a64-a645-4f8f-9b87-40a20b31d6ce','2026-08-11 12:04:27.809231','2026-08-11 12:09:26.000000',NULL,NULL,NULL,NULL,NULL),('e2e00004-0000-4000-8000-000000000001','UAT-ISOLATION-20260811-001','2026-08-11','e2e00004-0000-4000-8000-000000000010','e2e00004-0000-4000-8000-000000000030','e2e00004-0000-4000-8000-000000000020',NULL,NULL,NULL,NULL,'UAT-ISO-REF',NULL,NULL,NULL,NULL,NULL,NULL,'normal',NULL,'UAT-REAL-CASE-2026-08','in_progress',NULL,NULL,NULL,'16d75d68-b6c2-43de-97c6-ec099ae08ce0','16d75d68-b6c2-43de-97c6-ec099ae08ce0','2026-08-11 12:04:27.840047','2026-08-11 12:04:27.840047',NULL,NULL,NULL,NULL,NULL),('e8438630-bfbf-4861-be6f-73611a3f479c','GIFT-JO-2026-000004','2026-07-23','32aa190f-d0de-448d-b533-421da6e87ce9','94e7124b-c5a8-4f27-8535-dd5618ee7caf','3fd7d149-4e43-4c0c-96ba-b846f4155d2b','11326687-6f63-49f8-a8f2-e53b6d3e47d0','PIC UAT 17B','081700000018','pic17b@example.test','UAT-ISO-CEDEX-20260723114335-IMPORT',NULL,NULL,NULL,NULL,NULL,NULL,'normal',NULL,'UAT import audit only','in_progress',NULL,NULL,NULL,'00000000-0000-0000-0000-000000000002','00000000-0000-0000-0000-000000000003','2026-07-23 11:43:35.550931','2026-07-23 11:51:58.000000',NULL,NULL,NULL,NULL,NULL);
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
INSERT INTO `locations` VALUES ('0ae32257-a243-4690-a780-5c55a9a15735','af4d13f9-693e-4ded-8009-a43ef878741a','L289537506','Lokasi Isolation UAT','depot','Area uji lokal','Jakarta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active','2026-07-23 13:52:18.042999','2026-07-23 13:52:18.042999',NULL),('125db3af-9ece-4614-81a2-ae151bccadb4','1b36b739-2080-451a-9092-64b5b771167a','LCA0723110926','UAT Location A0723110926','depot','UAT only',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'inactive','2026-07-23 11:09:26.517075','2026-07-23 11:09:27.000000',NULL),('2f624b63-93c7-43c4-8da0-047d1660e91f','16473014-ae6c-4ee8-8f7f-a34cfc63ab3a','L289518363','Lokasi Isolation UAT','depot','Area uji lokal','Jakarta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active','2026-07-23 13:51:59.025894','2026-07-23 13:51:59.025894',NULL),('34275f3a-6e39-4224-998f-4c06aa4869cc','1e95fb79-ee0d-41aa-b26a-99f07e50976c','L89557566','Lokasi Pemeriksaan UAT','depot','Area uji lokal','Jakarta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active','2026-07-23 13:52:38.130282','2026-07-23 13:52:38.130282',NULL),('3fd7d149-4e43-4c0c-96ba-b846f4155d2b','32aa190f-d0de-448d-b533-421da6e87ce9','LOC-17B','Depot UAT 17B','depot','UAT','Jakarta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active','2026-07-17 16:56:33.895585','2026-07-17 16:56:33.895585',NULL),('406e10ef-c678-406f-9da6-c6013120c832','5d275989-b5f8-4f56-abb7-1e6cf8630449','LCUAT-ISO-CEDEX-20260723115019','UAT Location UAT-ISO-CEDEX-20260723115019','depot','UAT only',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active','2026-07-23 11:50:19.487627','2026-07-23 11:50:19.487627',NULL),('776399d2-3b5f-4235-bfa4-b884ae0d19e1','5581423d-c969-43b4-ba9b-b427ac1511ed','L89518363','Lokasi Pemeriksaan UAT','depot','Area uji lokal','Jakarta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active','2026-07-23 13:51:59.009126','2026-07-23 13:51:59.009126',NULL),('79a8279e-1d29-4f2b-9d59-92b471e4e52e','4d388157-406a-47e6-9343-8ad39bbf6700','L289557566','Lokasi Isolation UAT','depot','Area uji lokal','Jakarta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active','2026-07-23 13:52:38.141937','2026-07-23 13:52:38.141937',NULL),('a13b6587-4a4c-488b-ba09-91b7c6023b75','9eaabd4d-581a-4c1d-811a-4e3253300088','LCA0723110926','UAT Location A0723110926','depot','UAT only',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active','2026-07-23 11:09:26.533345','2026-07-23 11:09:26.533345',NULL),('a55a583c-7dbf-4e18-b255-f41c5d82e445','cd0c0678-86f8-4f29-a44b-db12a4e481ec','L89537506','Lokasi Pemeriksaan UAT','depot','Area uji lokal','Jakarta',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active','2026-07-23 13:52:18.033272','2026-07-23 13:52:18.033272',NULL),('e256852a-9e06-448e-bc45-2f2f35712069','42aee823-b9d1-4788-9fd6-cdce2cb732f8','LCUAT-ISO-CEDEX-20260723115019','UAT Location UAT-ISO-CEDEX-20260723115019','depot','UAT only',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'inactive','2026-07-23 11:50:19.475523','2026-07-23 11:50:20.000000',NULL),('e2e00004-0000-4000-8000-000000000020','e2e00004-0000-4000-8000-000000000010','UAT-ISO-LOC','Lokasi Isolation UAT','depot','UAT isolation only',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active','2026-08-11 12:04:27.834931','2026-08-11 12:04:27.834931',NULL);
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
INSERT INTO `maintenance_schemes` VALUES ('48134d5d-79e5-11f1-a1f6-002b67818c25','ACEP','ACEP','Approved continuous examination program.',1,NULL,'active','2026-07-07 16:21:48.886903','2026-07-07 16:21:48.886903'),('4813573d-79e5-11f1-a1f6-002b67818c25','PES','PES','Periodic examination scheme.',1,30,'active','2026-07-07 16:21:48.886903','2026-07-07 16:21:48.886903'),('48135940-79e5-11f1-a1f6-002b67818c25','IICL','IICL','IICL-based maintenance reference.',0,NULL,'active','2026-07-07 16:21:48.886903','2026-07-07 16:21:48.886903'),('481359fe-79e5-11f1-a1f6-002b67818c25','ISO','ISO','ISO-based maintenance reference.',0,NULL,'active','2026-07-07 16:21:48.886903','2026-07-07 16:21:48.886903'),('48135aa9-79e5-11f1-a1f6-002b67818c25','NED','NED','Next examination date reference.',1,NULL,'active','2026-07-07 16:21:48.886903','2026-07-07 16:21:48.886903'),('48135b68-79e5-11f1-a1f6-002b67818c25','OTHER','Other','Other maintenance scheme.',0,NULL,'active','2026-07-07 16:21:48.886903','2026-07-07 16:21:48.886903');
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
INSERT INTO `numbering_sequences` VALUES ('a76c6711-7ab2-11f1-bf35-002b67818c25','fitness_application','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76cd868-7ab2-11f1-bf35-002b67818c25','fitness_container_import','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76cdbff-7ab2-11f1-bf35-002b67818c25','fitness_assignment','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76cdcf8-7ab2-11f1-bf35-002b67818c25','fitness_inspection','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76cddc5-7ab2-11f1-bf35-002b67818c25','repair_followup','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76cdea2-7ab2-11f1-bf35-002b67818c25','fitness_review','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76cdf68-7ab2-11f1-bf35-002b67818c25','fitness_approval','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76ce032-7ab2-11f1-bf35-002b67818c25','approval_document','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('a76ce0ea-7ab2-11f1-bf35-002b67818c25','release_letter','2026',0,'2026-07-08 16:51:55.673276','2026-07-08 16:51:55.673276'),('dcb0ae4d-75c3-11f1-9f38-002b67818c25','job_order','2026',7,'2026-07-02 10:12:30.680519','2026-07-23 13:52:38.000000'),('dcb391f6-75c3-11f1-9f38-002b67818c25','assignment','2026',6,'2026-07-02 10:12:30.701510','2026-07-23 13:52:38.000000'),('dcb6ecf3-75c3-11f1-9f38-002b67818c25','survey','2026',8,'2026-07-02 10:12:30.723760','2026-08-11 12:09:16.000000'),('dcba1e60-75c3-11f1-9f38-002b67818c25','report','2026',3,'2026-07-02 10:12:30.744778','2026-08-11 12:09:26.000000'),('dcbd4e99-75c3-11f1-9f38-002b67818c25','invoice','2026',0,'2026-07-02 10:12:30.765568','2026-07-02 10:12:30.765568'),('dcc00562-75c3-11f1-9f38-002b67818c25','payment_receipt','2026',0,'2026-07-02 10:12:30.783332','2026-07-02 10:12:30.783332');
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
INSERT INTO `numbering_settings` VALUES ('3f29c8ab-737f-11f1-ac50-002b67818c25','job_order','GIFT','JO','YYYY',6,'yearly','GIFT-JO-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('3f29cdbd-737f-11f1-ac50-002b67818c25','assignment','GIFT','ASG','YYYY',6,'yearly','GIFT-ASG-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('3f29cf0f-737f-11f1-ac50-002b67818c25','survey','GIFT','SVY','YYYY',6,'yearly','GIFT-SVY-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('3f29cff7-737f-11f1-ac50-002b67818c25','report','GIFT','RPT','YYYY',6,'yearly','GIFT-RPT-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('3f29d133-737f-11f1-ac50-002b67818c25','eir','GIFT','EIR','YYYY',6,'yearly','GIFT-EIR-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('3f29d20d-737f-11f1-ac50-002b67818c25','invoice','GIFT','INV','YYYY',6,'yearly','GIFT-INV-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('3f29d304-737f-11f1-ac50-002b67818c25','payment_receipt','GIFT','RCP','YYYY',6,'yearly','GIFT-RCP-2026-000001',1,'2026-06-29 05:56:18.293517','2026-06-29 05:56:18.293517'),('482dffc8-79e5-11f1-a1f6-002b67818c25','fitness_application','GIFT','FAP','YYYY',6,'yearly','GIFT-FAP-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e08fc-79e5-11f1-a1f6-002b67818c25','fitness_container_import','GIFT','FCI','YYYY',6,'yearly','GIFT-FCI-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e0add-79e5-11f1-a1f6-002b67818c25','fitness_assignment','GIFT','FAS','YYYY',6,'yearly','GIFT-FAS-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e0bc9-79e5-11f1-a1f6-002b67818c25','fitness_inspection','GIFT','FIN','YYYY',6,'yearly','GIFT-FIN-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e0c99-79e5-11f1-a1f6-002b67818c25','repair_followup','GIFT','RFL','YYYY',6,'yearly','GIFT-RFL-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e0d67-79e5-11f1-a1f6-002b67818c25','fitness_review','GIFT','FRV','YYYY',6,'yearly','GIFT-FRV-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e0e3b-79e5-11f1-a1f6-002b67818c25','fitness_approval','GIFT','FAPV','YYYY',6,'yearly','GIFT-FAPV-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e0f19-79e5-11f1-a1f6-002b67818c25','approval_document','GIFT','ADOC','YYYY',6,'yearly','GIFT-ADOC-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483'),('482e1002-79e5-11f1-a1f6-002b67818c25','release_letter','GIFT','REL','YYYY',6,'yearly','GIFT-REL-2026-000001',1,'2026-07-07 16:21:49.062483','2026-07-07 16:21:49.062483');
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
INSERT INTO `permissions` VALUES ('39fd3973-8bf8-11f1-9154-002b67818c25','cedex_code_proposals.view.all','View ISO CEDEX Code Proposals','cedex_code_proposals','view','all','Melihat pengajuan kode ISO CEDEX'),('39fdcb91-8bf8-11f1-9154-002b67818c25','cedex_code_proposals.review.all','Review ISO CEDEX Code Proposals','cedex_code_proposals','review','all','Memeriksa dan memutuskan pengajuan kode ISO CEDEX'),('3f277c21-737f-11f1-ac50-002b67818c25','*.*.all',NULL,'*','*','all','Wildcard permission for super admin'),('3f2781d5-737f-11f1-ac50-002b67818c25','users.manage.all',NULL,'users','manage','all','Manage users'),('3f2783be-737f-11f1-ac50-002b67818c25','roles.manage.all',NULL,'roles','manage','all','Manage roles and permissions'),('3f2784b7-737f-11f1-ac50-002b67818c25','company_profiles.manage.all',NULL,'company_profiles','manage','all','Manage company profile'),('3f2785a1-737f-11f1-ac50-002b67818c25','numbering_settings.manage.all',NULL,'numbering_settings','manage','all','Manage numbering settings'),('3f278684-737f-11f1-ac50-002b67818c25','files.manage.all',NULL,'files','manage','all','Manage file metadata'),('3f278768-737f-11f1-ac50-002b67818c25','customers.manage.all',NULL,'customers','manage','all','Manage customers'),('3f278858-737f-11f1-ac50-002b67818c25','locations.manage.all',NULL,'locations','manage','all','Manage locations'),('3f27896c-737f-11f1-ac50-002b67818c25','surveyor_profiles.manage.all',NULL,'surveyor_profiles','manage','all','Manage surveyor profiles'),('3f278a4e-737f-11f1-ac50-002b67818c25','surveyor_profiles.view.own',NULL,'surveyor_profiles','view','own','View own surveyor profile'),('3f278b9f-737f-11f1-ac50-002b67818c25','container_types.manage.all',NULL,'container_types','manage','all','Manage container types'),('3f278c8d-737f-11f1-ac50-002b67818c25','survey_types.manage.all',NULL,'survey_types','manage','all','Manage survey types'),('3f278d74-737f-11f1-ac50-002b67818c25','cedex.manage.all',NULL,'cedex','manage','all','Manage CEDEX master data'),('3f278e50-737f-11f1-ac50-002b67818c25','master_data.view.all',NULL,'master_data','view','all','View master data'),('3f278f3f-737f-11f1-ac50-002b67818c25','dashboard.view.all',NULL,'dashboard','view','all','View dashboards'),('3f426ad5-737f-11f1-ac50-002b67818c25','customers.view.all',NULL,'customers','view','all','View customers'),('3f4270e3-737f-11f1-ac50-002b67818c25','customers.create.all',NULL,'customers','create','all','Create customers'),('3f4272f3-737f-11f1-ac50-002b67818c25','customers.update.all',NULL,'customers','update','all','Update customers'),('3f4274ea-737f-11f1-ac50-002b67818c25','customers.delete.all',NULL,'customers','delete','all','Deactivate customers'),('3f4276b0-737f-11f1-ac50-002b67818c25','locations.view.all',NULL,'locations','view','all','View locations'),('3f42781c-737f-11f1-ac50-002b67818c25','locations.create.all',NULL,'locations','create','all','Create locations'),('3f427971-737f-11f1-ac50-002b67818c25','locations.update.all',NULL,'locations','update','all','Update locations'),('3f427ad4-737f-11f1-ac50-002b67818c25','locations.delete.all',NULL,'locations','delete','all','Deactivate locations'),('3f427c3c-737f-11f1-ac50-002b67818c25','surveyors.view.all',NULL,'surveyors','view','all','View surveyor profiles'),('3f427e26-737f-11f1-ac50-002b67818c25','surveyors.create.all',NULL,'surveyors','create','all','Create surveyor profiles'),('3f428028-737f-11f1-ac50-002b67818c25','surveyors.update.all',NULL,'surveyors','update','all','Update surveyor profiles'),('3f4281cd-737f-11f1-ac50-002b67818c25','surveyors.delete.all',NULL,'surveyors','delete','all','Deactivate surveyor profiles'),('3f428365-737f-11f1-ac50-002b67818c25','container_types.view.all',NULL,'container_types','view','all','View container types'),('3f4284d5-737f-11f1-ac50-002b67818c25','container_types.create.all',NULL,'container_types','create','all','Create container types'),('3f42863f-737f-11f1-ac50-002b67818c25','container_types.update.all',NULL,'container_types','update','all','Update container types'),('3f4287a5-737f-11f1-ac50-002b67818c25','container_types.delete.all',NULL,'container_types','delete','all','Deactivate container types'),('3f42892f-737f-11f1-ac50-002b67818c25','survey_types.view.all',NULL,'survey_types','view','all','View survey types'),('3f428a67-737f-11f1-ac50-002b67818c25','survey_types.create.all',NULL,'survey_types','create','all','Create survey types'),('3f428b52-737f-11f1-ac50-002b67818c25','survey_types.update.all',NULL,'survey_types','update','all','Update survey types'),('3f428c36-737f-11f1-ac50-002b67818c25','survey_types.delete.all',NULL,'survey_types','delete','all','Deactivate survey types'),('3f428d2c-737f-11f1-ac50-002b67818c25','cedex_locations.view.all',NULL,'cedex_locations','view','all','View CEDEX locations'),('3f428fac-737f-11f1-ac50-002b67818c25','cedex_locations.create.all',NULL,'cedex_locations','create','all','Create CEDEX locations'),('3f4290f4-737f-11f1-ac50-002b67818c25','cedex_locations.update.all',NULL,'cedex_locations','update','all','Update CEDEX locations'),('3f429218-737f-11f1-ac50-002b67818c25','cedex_locations.delete.all',NULL,'cedex_locations','delete','all','Deactivate CEDEX locations'),('3f429301-737f-11f1-ac50-002b67818c25','cedex_components.view.all',NULL,'cedex_components','view','all','View CEDEX components'),('3f4293ea-737f-11f1-ac50-002b67818c25','cedex_components.create.all',NULL,'cedex_components','create','all','Create CEDEX components'),('3f4294d1-737f-11f1-ac50-002b67818c25','cedex_components.update.all',NULL,'cedex_components','update','all','Update CEDEX components'),('3f4295e8-737f-11f1-ac50-002b67818c25','cedex_components.delete.all',NULL,'cedex_components','delete','all','Deactivate CEDEX components'),('3f429730-737f-11f1-ac50-002b67818c25','cedex_damages.view.all',NULL,'cedex_damages','view','all','View CEDEX damages'),('3f429832-737f-11f1-ac50-002b67818c25','cedex_damages.create.all',NULL,'cedex_damages','create','all','Create CEDEX damages'),('3f429945-737f-11f1-ac50-002b67818c25','cedex_damages.update.all',NULL,'cedex_damages','update','all','Update CEDEX damages'),('3f429a6c-737f-11f1-ac50-002b67818c25','cedex_damages.delete.all',NULL,'cedex_damages','delete','all','Deactivate CEDEX damages'),('3f429b59-737f-11f1-ac50-002b67818c25','cedex_repairs.view.all',NULL,'cedex_repairs','view','all','View CEDEX repairs'),('3f429c43-737f-11f1-ac50-002b67818c25','cedex_repairs.create.all',NULL,'cedex_repairs','create','all','Create CEDEX repairs'),('3f429d21-737f-11f1-ac50-002b67818c25','cedex_repairs.update.all',NULL,'cedex_repairs','update','all','Update CEDEX repairs'),('3f429e2c-737f-11f1-ac50-002b67818c25','cedex_repairs.delete.all',NULL,'cedex_repairs','delete','all','Deactivate CEDEX repairs'),('3f429f1b-737f-11f1-ac50-002b67818c25','cedex_materials.view.all',NULL,'cedex_materials','view','all','View CEDEX materials'),('3f429ffd-737f-11f1-ac50-002b67818c25','cedex_materials.create.all',NULL,'cedex_materials','create','all','Create CEDEX materials'),('3f42a0f3-737f-11f1-ac50-002b67818c25','cedex_materials.update.all',NULL,'cedex_materials','update','all','Update CEDEX materials'),('3f42a1df-737f-11f1-ac50-002b67818c25','cedex_materials.delete.all',NULL,'cedex_materials','delete','all','Deactivate CEDEX materials'),('3f42a2cb-737f-11f1-ac50-002b67818c25','responsibility_codes.view.all',NULL,'responsibility_codes','view','all','View responsibility codes'),('3f42a435-737f-11f1-ac50-002b67818c25','responsibility_codes.create.all',NULL,'responsibility_codes','create','all','Create responsibility codes'),('3f42a533-737f-11f1-ac50-002b67818c25','responsibility_codes.update.all',NULL,'responsibility_codes','update','all','Update responsibility codes'),('3f42a628-737f-11f1-ac50-002b67818c25','responsibility_codes.delete.all',NULL,'responsibility_codes','delete','all','Deactivate responsibility codes'),('3f42a715-737f-11f1-ac50-002b67818c25','cedex_locations.manage.all',NULL,'cedex_locations','manage','all','Manage CEDEX locations'),('3f42a80d-737f-11f1-ac50-002b67818c25','cedex_components.manage.all',NULL,'cedex_components','manage','all','Manage CEDEX components'),('3f42a903-737f-11f1-ac50-002b67818c25','cedex_damages.manage.all',NULL,'cedex_damages','manage','all','Manage CEDEX damages'),('3f42a9ed-737f-11f1-ac50-002b67818c25','cedex_repairs.manage.all',NULL,'cedex_repairs','manage','all','Manage CEDEX repairs'),('3f42aaef-737f-11f1-ac50-002b67818c25','cedex_materials.manage.all',NULL,'cedex_materials','manage','all','Manage CEDEX materials'),('3f42abe3-737f-11f1-ac50-002b67818c25','responsibility_codes.manage.all',NULL,'responsibility_codes','manage','all','Manage responsibility codes'),('3f42acea-737f-11f1-ac50-002b67818c25','surveyors.manage.all',NULL,'surveyors','manage','all','Manage surveyor profiles'),('3fa60b5a-737f-11f1-ac50-002b67818c25','jobs.view.all',NULL,'jobs','view','all','View jobs'),('3fa60f39-737f-11f1-ac50-002b67818c25','jobs.create.all',NULL,'jobs','create','all','Create jobs'),('3fa610e1-737f-11f1-ac50-002b67818c25','jobs.update.all',NULL,'jobs','update','all','Update jobs'),('3fa611dc-737f-11f1-ac50-002b67818c25','jobs.cancel.all',NULL,'jobs','cancel','all','Cancel jobs'),('3fa612c5-737f-11f1-ac50-002b67818c25','jobs.manage.all',NULL,'jobs','manage','all','Manage jobs'),('3fa613ad-737f-11f1-ac50-002b67818c25','job_containers.view.all',NULL,'job_containers','view','all','View job containers'),('3fa6149e-737f-11f1-ac50-002b67818c25','job_containers.create.all',NULL,'job_containers','create','all','Create job containers'),('3fa61581-737f-11f1-ac50-002b67818c25','job_containers.import.all',NULL,'job_containers','import','all','Import job containers'),('3fa616b5-737f-11f1-ac50-002b67818c25','job_containers.update.all',NULL,'job_containers','update','all','Update job containers'),('3fa617a5-737f-11f1-ac50-002b67818c25','job_containers.delete.all',NULL,'job_containers','delete','all','Delete job containers'),('3fa6188d-737f-11f1-ac50-002b67818c25','job_containers.reassign.all',NULL,'job_containers','reassign','all','Reassign job containers'),('3fa61982-737f-11f1-ac50-002b67818c25','assignments.view.all',NULL,'assignments','view','all','View assignments'),('3fa61a5d-737f-11f1-ac50-002b67818c25','assignments.assign.all',NULL,'assignments','assign','all','Assign surveyors'),('3fa61b60-737f-11f1-ac50-002b67818c25','assignments.reassign.all',NULL,'assignments','reassign','all','Reassign surveyors'),('3fa61c4b-737f-11f1-ac50-002b67818c25','assignments.manage.all',NULL,'assignments','manage','all','Manage assignments'),('40377bc2-737f-11f1-ac50-002b67818c25','surveyor_jobs.view.assigned','View Assigned Surveyor Jobs','surveyor_jobs','view','assigned','Melihat job yang ditugaskan ke surveyor login'),('40378673-737f-11f1-ac50-002b67818c25','surveys.view.assigned','View Assigned Surveys','surveys','view','assigned','Melihat survey milik assignment sendiri'),('40378930-737f-11f1-ac50-002b67818c25','surveys.start.assigned','Start Assigned Survey','surveys','start','assigned','Memulai survey untuk container yang ditugaskan'),('40378b20-737f-11f1-ac50-002b67818c25','surveys.update.assigned','Update Assigned Survey','surveys','update','assigned','Mengubah draft/revisi survey sendiri'),('40378d25-737f-11f1-ac50-002b67818c25','surveys.submit.assigned','Submit Assigned Survey','surveys','submit','assigned','Submit survey sendiri untuk review'),('40378ed5-737f-11f1-ac50-002b67818c25','survey_damages.view.assigned','View Assigned Survey Damages','survey_damages','view','assigned','Melihat damage pada survey sendiri'),('40379102-737f-11f1-ac50-002b67818c25','survey_damages.create.assigned','Create Assigned Survey Damage','survey_damages','create','assigned','Membuat damage pada survey sendiri'),('403792f7-737f-11f1-ac50-002b67818c25','survey_damages.update.assigned','Update Assigned Survey Damage','survey_damages','update','assigned','Mengubah damage pada survey sendiri'),('403794be-737f-11f1-ac50-002b67818c25','survey_damages.delete.assigned','Delete Assigned Survey Damage','survey_damages','delete','assigned','Menghapus damage pada survey sendiri'),('4037966f-737f-11f1-ac50-002b67818c25','survey_photos.upload.assigned','Upload Assigned Survey Photo','survey_photos','upload','assigned','Upload foto evidence pada survey sendiri'),('40379833-737f-11f1-ac50-002b67818c25','survey_photos.view.assigned','View Assigned Survey Photos','survey_photos','view','assigned','Melihat foto evidence pada survey sendiri'),('40a3aee5-737f-11f1-ac50-002b67818c25','reviews.view.all','View Reviews','reviews','view','all','Melihat survey pending review'),('40a3b4bb-737f-11f1-ac50-002b67818c25','reviews.manage.all','Manage Reviews','reviews','manage','all','Approve, reject, dan need revision survey'),('40a3b75d-737f-11f1-ac50-002b67818c25','reports.view.all','View Reports','reports','view','all','Melihat arsip report'),('40a3b923-737f-11f1-ac50-002b67818c25','reports.generate.all','Generate Reports','reports','generate','all','Membuat report dari survey approved'),('40a3bb17-737f-11f1-ac50-002b67818c25','reports.version.all','Version Reports','reports','version','all','Membuat revisi report'),('40f9de5e-737f-11f1-ac50-002b67818c25','finance.view.all','View Finance','finance','view','all','Melihat dashboard finance, invoice, payment, outstanding'),('40f9e5e6-737f-11f1-ac50-002b67818c25','finance.manage.all','Manage Finance','finance','manage','all','Mengelola price list, invoice, dan payment'),('40f9e90f-737f-11f1-ac50-002b67818c25','finance.invoice.create.all','Create Invoice','finance.invoice','create','all','Membuat invoice draft'),('40f9eb1b-737f-11f1-ac50-002b67818c25','finance.payment.create.all','Create Payment','finance.payment','create','all','Mencatat payment'),('4831711a-79e5-11f1-a1f6-002b67818c25','container_manufacturers.view.all','View Container Manufacturers','container_manufacturers','view','all','Melihat master pabrik pembuat peti kemas'),('48318cc3-79e5-11f1-a1f6-002b67818c25','container_manufacturers.manage.all','Manage Container Manufacturers','container_manufacturers','manage','all','Mengelola master pabrik pembuat peti kemas'),('48318ebf-79e5-11f1-a1f6-002b67818c25','fitness_approval_categories.view.all','View Fitness Approval Categories','fitness_approval_categories','view','all','Melihat kategori persetujuan kelaikan'),('48318f9d-79e5-11f1-a1f6-002b67818c25','fitness_approval_categories.manage.all','Manage Fitness Approval Categories','fitness_approval_categories','manage','all','Mengelola kategori persetujuan kelaikan'),('4831f158-79e5-11f1-a1f6-002b67818c25','maintenance_schemes.view.all','View Maintenance Schemes','maintenance_schemes','view','all','Melihat skema pemeliharaan peti kemas'),('4831f29a-79e5-11f1-a1f6-002b67818c25','maintenance_schemes.manage.all','Manage Maintenance Schemes','maintenance_schemes','manage','all','Mengelola skema pemeliharaan peti kemas'),('4831f39b-79e5-11f1-a1f6-002b67818c25','inspection_areas.view.all','View Inspection Areas','inspection_areas','view','all','Melihat area pemeriksaan peti kemas'),('4831f454-79e5-11f1-a1f6-002b67818c25','inspection_areas.manage.all','Manage Inspection Areas','inspection_areas','manage','all','Mengelola area pemeriksaan peti kemas'),('4831f50d-79e5-11f1-a1f6-002b67818c25','structural_components.view.all','View Structural Components','structural_components','view','all','Melihat komponen struktur peti kemas'),('4831f5d2-79e5-11f1-a1f6-002b67818c25','structural_components.manage.all','Manage Structural Components','structural_components','manage','all','Mengelola komponen struktur peti kemas'),('4831f67e-79e5-11f1-a1f6-002b67818c25','structural_damage_criteria.view.all','View Structural Damage Criteria','structural_damage_criteria','view','all','Melihat kriteria kerusakan struktur'),('4831f72e-79e5-11f1-a1f6-002b67818c25','structural_damage_criteria.manage.all','Manage Structural Damage Criteria','structural_damage_criteria','manage','all','Mengelola kriteria kerusakan struktur'),('4831f81d-79e5-11f1-a1f6-002b67818c25','finding_severities.view.all','View Finding Severities','finding_severities','view','all','Melihat tingkat temuan'),('4831f927-79e5-11f1-a1f6-002b67818c25','finding_severities.manage.all','Manage Finding Severities','finding_severities','manage','all','Mengelola tingkat temuan'),('4831f9d7-79e5-11f1-a1f6-002b67818c25','inspection_test_parameters.view.all','View Inspection Test Parameters','inspection_test_parameters','view','all','Melihat parameter pengujian kelaikan'),('4831fa7e-79e5-11f1-a1f6-002b67818c25','inspection_test_parameters.manage.all','Manage Inspection Test Parameters','inspection_test_parameters','manage','all','Mengelola parameter pengujian kelaikan'),('4831fb21-79e5-11f1-a1f6-002b67818c25','fitness_checklist_templates.view.all','View Fitness Checklist Templates','fitness_checklist_templates','view','all','Melihat template checklist kelaikan'),('4831fbdf-79e5-11f1-a1f6-002b67818c25','fitness_checklist_templates.manage.all','Manage Fitness Checklist Templates','fitness_checklist_templates','manage','all','Mengelola template checklist kelaikan'),('4831fcae-79e5-11f1-a1f6-002b67818c25','evidence_photo_categories.view.all','View Evidence Photo Categories','evidence_photo_categories','view','all','Melihat kategori foto evidence'),('4831fd54-79e5-11f1-a1f6-002b67818c25','evidence_photo_categories.manage.all','Manage Evidence Photo Categories','evidence_photo_categories','manage','all','Mengelola kategori foto evidence'),('4831fdfc-79e5-11f1-a1f6-002b67818c25','inspection_recommendations.view.all','View Inspection Recommendations','inspection_recommendations','view','all','Melihat rekomendasi hasil pemeriksaan'),('4831feaf-79e5-11f1-a1f6-002b67818c25','inspection_recommendations.manage.all','Manage Inspection Recommendations','inspection_recommendations','manage','all','Mengelola rekomendasi hasil pemeriksaan'),('4831ff58-79e5-11f1-a1f6-002b67818c25','authorized_signers.view.all','View Authorized Signers','authorized_signers','view','all','Melihat pejabat penandatangan'),('48320000-79e5-11f1-a1f6-002b67818c25','authorized_signers.manage.all','Manage Authorized Signers','authorized_signers','manage','all','Mengelola pejabat penandatangan'),('483200b5-79e5-11f1-a1f6-002b67818c25','fitness_applications.view.all','View Fitness Applications','fitness_applications','view','all','Melihat permohonan kelaikan'),('48320163-79e5-11f1-a1f6-002b67818c25','fitness_applications.manage.all','Manage Fitness Applications','fitness_applications','manage','all','Mengelola permohonan kelaikan'),('48320221-79e5-11f1-a1f6-002b67818c25','application_containers.view.all','View Application Containers','application_containers','view','all','Melihat data peti kemas kelaikan'),('483202c5-79e5-11f1-a1f6-002b67818c25','application_containers.manage.all','Manage Application Containers','application_containers','manage','all','Mengelola data peti kemas kelaikan'),('4832037e-79e5-11f1-a1f6-002b67818c25','fitness_container_imports.view.all','View Fitness Container Imports','fitness_container_imports','view','all','Melihat import data peti kemas kelaikan'),('4832043a-79e5-11f1-a1f6-002b67818c25','fitness_container_imports.manage.all','Manage Fitness Container Imports','fitness_container_imports','manage','all','Mengelola import data peti kemas kelaikan'),('483204eb-79e5-11f1-a1f6-002b67818c25','fitness_assignments.view.all','View Fitness Assignments','fitness_assignments','view','all','Melihat assignment kelaikan'),('483205a3-79e5-11f1-a1f6-002b67818c25','fitness_assignments.manage.all','Manage Fitness Assignments','fitness_assignments','manage','all','Mengelola assignment kelaikan'),('4832064f-79e5-11f1-a1f6-002b67818c25','fitness_inspections.view.all','View Fitness Inspections','fitness_inspections','view','all','Melihat pemeriksaan kelaikan'),('483206fd-79e5-11f1-a1f6-002b67818c25','fitness_inspections.manage.assigned','Manage Assigned Fitness Inspections','fitness_inspections','manage','assigned','Mengelola pemeriksaan kelaikan yang ditugaskan'),('483207b3-79e5-11f1-a1f6-002b67818c25','structural_findings.view.all','View Structural Findings','structural_findings','view','all','Melihat temuan struktur'),('4832086c-79e5-11f1-a1f6-002b67818c25','structural_findings.manage.assigned','Manage Assigned Structural Findings','structural_findings','manage','assigned','Mengelola temuan struktur yang ditugaskan'),('4832093b-79e5-11f1-a1f6-002b67818c25','repair_followups.view.all','View Repair Followups','repair_followups','view','all','Melihat tindak lanjut perbaikan'),('483209ef-79e5-11f1-a1f6-002b67818c25','repair_followups.manage.all','Manage Repair Followups','repair_followups','manage','all','Mengelola tindak lanjut perbaikan'),('48320a97-79e5-11f1-a1f6-002b67818c25','fitness_reviews.view.all','View Fitness Reviews','fitness_reviews','view','all','Melihat review kelaikan'),('48320b44-79e5-11f1-a1f6-002b67818c25','fitness_reviews.manage.all','Manage Fitness Reviews','fitness_reviews','manage','all','Mengelola review kelaikan'),('48320bf9-79e5-11f1-a1f6-002b67818c25','fitness_approvals.view.all','View Fitness Approvals','fitness_approvals','view','all','Melihat persetujuan kelaikan'),('48320ca2-79e5-11f1-a1f6-002b67818c25','fitness_approvals.issue.all','Issue Fitness Approvals','fitness_approvals','issue','all','Menerbitkan persetujuan kelaikan'),('48324868-79e5-11f1-a1f6-002b67818c25','fitness_documents.view.all','View Fitness Documents','fitness_documents','view','all','Melihat dokumen kelaikan'),('48324a72-79e5-11f1-a1f6-002b67818c25','fitness_documents.manage.all','Manage Fitness Documents','fitness_documents','manage','all','Mengelola dokumen kelaikan'),('77ad877b-7a83-11f1-ab0b-002b67818c25','maintenance_schemes.create.all','Create Maintenance Schemes','maintenance_schemes','create','all','Membuat skema pemeliharaan peti kemas'),('77adc91d-7a83-11f1-ab0b-002b67818c25','maintenance_schemes.update.all','Update Maintenance Schemes','maintenance_schemes','update','all','Mengubah skema pemeliharaan peti kemas'),('77adcbbe-7a83-11f1-ab0b-002b67818c25','maintenance_schemes.delete.all','Delete Maintenance Schemes','maintenance_schemes','delete','all','Menonaktifkan skema pemeliharaan peti kemas'),('77ae7c50-7a83-11f1-ab0b-002b67818c25','inspection_areas.create.all','Create Inspection Areas','inspection_areas','create','all','Membuat area pemeriksaan peti kemas'),('77ae946c-7a83-11f1-ab0b-002b67818c25','inspection_areas.update.all','Update Inspection Areas','inspection_areas','update','all','Mengubah area pemeriksaan peti kemas'),('77ae9586-7a83-11f1-ab0b-002b67818c25','inspection_areas.delete.all','Delete Inspection Areas','inspection_areas','delete','all','Menonaktifkan area pemeriksaan peti kemas'),('77ae98e7-7a83-11f1-ab0b-002b67818c25','structural_components.create.all','Create Structural Components','structural_components','create','all','Membuat komponen struktur peti kemas'),('77ae9f69-7a83-11f1-ab0b-002b67818c25','structural_components.update.all','Update Structural Components','structural_components','update','all','Mengubah komponen struktur peti kemas'),('77aea080-7a83-11f1-ab0b-002b67818c25','structural_components.delete.all','Delete Structural Components','structural_components','delete','all','Menonaktifkan komponen struktur peti kemas'),('77aea46e-7a83-11f1-ab0b-002b67818c25','structural_damage_criteria.create.all','Create Structural Damage Criteria','structural_damage_criteria','create','all','Membuat kriteria kerusakan struktur'),('77aea8e3-7a83-11f1-ab0b-002b67818c25','structural_damage_criteria.update.all','Update Structural Damage Criteria','structural_damage_criteria','update','all','Mengubah kriteria kerusakan struktur'),('77aea9c5-7a83-11f1-ab0b-002b67818c25','structural_damage_criteria.delete.all','Delete Structural Damage Criteria','structural_damage_criteria','delete','all','Menonaktifkan kriteria kerusakan struktur'),('77aec591-7a83-11f1-ab0b-002b67818c25','finding_severities.create.all','Create Finding Severities','finding_severities','create','all','Membuat tingkat temuan'),('77aec696-7a83-11f1-ab0b-002b67818c25','finding_severities.update.all','Update Finding Severities','finding_severities','update','all','Mengubah tingkat temuan'),('77aec766-7a83-11f1-ab0b-002b67818c25','finding_severities.delete.all','Delete Finding Severities','finding_severities','delete','all','Menonaktifkan tingkat temuan'),('77aeca1f-7a83-11f1-ab0b-002b67818c25','inspection_test_parameters.create.all','Create Inspection Test Parameters','inspection_test_parameters','create','all','Membuat parameter pengujian kelaikan'),('77aecb21-7a83-11f1-ab0b-002b67818c25','inspection_test_parameters.update.all','Update Inspection Test Parameters','inspection_test_parameters','update','all','Mengubah parameter pengujian kelaikan'),('77aecbf0-7a83-11f1-ab0b-002b67818c25','inspection_test_parameters.delete.all','Delete Inspection Test Parameters','inspection_test_parameters','delete','all','Menonaktifkan parameter pengujian kelaikan'),('77aecea0-7a83-11f1-ab0b-002b67818c25','fitness_checklist_templates.create.all','Create Fitness Checklist Templates','fitness_checklist_templates','create','all','Membuat template checklist kelaikan'),('77aecfd0-7a83-11f1-ab0b-002b67818c25','fitness_checklist_templates.update.all','Update Fitness Checklist Templates','fitness_checklist_templates','update','all','Mengubah template checklist kelaikan'),('77aed0a4-7a83-11f1-ab0b-002b67818c25','fitness_checklist_templates.delete.all','Delete Fitness Checklist Templates','fitness_checklist_templates','delete','all','Menonaktifkan template checklist kelaikan'),('77aee013-7a83-11f1-ab0b-002b67818c25','evidence_photo_categories.create.all','Create Evidence Photo Categories','evidence_photo_categories','create','all','Membuat kategori foto evidence'),('77aee108-7a83-11f1-ab0b-002b67818c25','evidence_photo_categories.update.all','Update Evidence Photo Categories','evidence_photo_categories','update','all','Mengubah kategori foto evidence'),('77aee1de-7a83-11f1-ab0b-002b67818c25','evidence_photo_categories.delete.all','Delete Evidence Photo Categories','evidence_photo_categories','delete','all','Menonaktifkan kategori foto evidence'),('77aee477-7a83-11f1-ab0b-002b67818c25','inspection_recommendations.create.all','Create Inspection Recommendations','inspection_recommendations','create','all','Membuat rekomendasi hasil pemeriksaan'),('77aee54c-7a83-11f1-ab0b-002b67818c25','inspection_recommendations.update.all','Update Inspection Recommendations','inspection_recommendations','update','all','Mengubah rekomendasi hasil pemeriksaan'),('77aee622-7a83-11f1-ab0b-002b67818c25','inspection_recommendations.delete.all','Delete Inspection Recommendations','inspection_recommendations','delete','all','Menonaktifkan rekomendasi hasil pemeriksaan'),('77af1fd4-7a83-11f1-ab0b-002b67818c25','authorized_signers.create.all','Create Authorized Signers','authorized_signers','create','all','Membuat pejabat penandatangan'),('77af20dc-7a83-11f1-ab0b-002b67818c25','authorized_signers.update.all','Update Authorized Signers','authorized_signers','update','all','Mengubah pejabat penandatangan'),('77af2197-7a83-11f1-ab0b-002b67818c25','authorized_signers.delete.all','Delete Authorized Signers','authorized_signers','delete','all','Menonaktifkan pejabat penandatangan'),('77af23f5-7a83-11f1-ab0b-002b67818c25','company_profiles.create.all','Create Company Profiles','company_profiles','create','all','Membuat profil badan usaha'),('77af2f98-7a83-11f1-ab0b-002b67818c25','company_profiles.update.all','Update Company Profiles','company_profiles','update','all','Mengubah profil badan usaha'),('77af3122-7a83-11f1-ab0b-002b67818c25','company_profiles.delete.all','Delete Company Profiles','company_profiles','delete','all','Menonaktifkan profil badan usaha'),('84947ba5-7456-11f1-806f-002b67818c25','audit.view.all','View Audit Log','audit','view','all','Melihat audit log sistem'),('84955473-7456-11f1-806f-002b67818c25','checklist_templates.view.all','View Checklist Templates','checklist_templates','view','all','Melihat checklist template / data bootstrap'),('84955622-7456-11f1-806f-002b67818c25','settings.view.all','View Settings','settings','view','all','Melihat menu setting'),('849556d7-7456-11f1-806f-002b67818c25','users.view.all','View Users','users','view','all','Melihat user management'),('8495577e-7456-11f1-806f-002b67818c25','roles.view.all','View Roles','roles','view','all','Melihat role dan permission'),('8495581a-7456-11f1-806f-002b67818c25','company_profiles.view.all','View Company Profile','company_profiles','view','all','Melihat company profile'),('849558e0-7456-11f1-806f-002b67818c25','numbering_settings.view.all','View Numbering Settings','numbering_settings','view','all','Melihat numbering setting'),('86c6b216-8be7-11f1-9154-002b67818c25','survey_photos.delete.assigned','Delete Assigned Survey Photo','survey_photos','delete','assigned','Hapus lunak foto evidence pada survey sendiri'),('baf0ca5c-7a77-11f1-ab0b-002b67818c25','container_manufacturers.create.all','Create Container Manufacturers','container_manufacturers','create','all','Membuat master pabrik pembuat peti kemas'),('baf1a831-7a77-11f1-ab0b-002b67818c25','container_manufacturers.update.all','Update Container Manufacturers','container_manufacturers','update','all','Mengubah master pabrik pembuat peti kemas'),('baf1ab1d-7a77-11f1-ab0b-002b67818c25','container_manufacturers.delete.all','Delete Container Manufacturers','container_manufacturers','delete','all','Menonaktifkan master pabrik pembuat peti kemas'),('baf1accf-7a77-11f1-ab0b-002b67818c25','fitness_approval_categories.create.all','Create Fitness Approval Categories','fitness_approval_categories','create','all','Membuat kategori persetujuan kelaikan'),('baf1ae00-7a77-11f1-ab0b-002b67818c25','fitness_approval_categories.update.all','Update Fitness Approval Categories','fitness_approval_categories','update','all','Mengubah kategori persetujuan kelaikan'),('baf1aee0-7a77-11f1-ab0b-002b67818c25','fitness_approval_categories.delete.all','Delete Fitness Approval Categories','fitness_approval_categories','delete','all','Menonaktifkan kategori persetujuan kelaikan'),('bb3770dd-751e-11f1-8fe5-002b67818c25','surveys.view.all','View All Surveys','surveys','view','all','Melihat seluruh survey untuk monitoring Admin');
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
INSERT INTO `refresh_tokens` VALUES ('0006fdd7-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','9bb9b7c0241ab5382078100a1a550a60e10247b539a04c2580fd77d90c55c800',NULL,'127.0.0.1','node','2026-08-06 13:51:58.548485',NULL,'2026-07-23 13:51:58.553482'),('0018ace9-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','26dd7c8264b367421555a6a16a844953466a4a02ee8e02bc866167c434a2d70b',NULL,'127.0.0.1','node','2026-08-06 13:51:58.669083',NULL,'2026-07-23 13:51:58.669684'),('0026e3db-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','c87ee61fc0fd852279ee7434452236dc9cff5207518277f68bd592bdeed0f949',NULL,'127.0.0.1','node','2026-08-06 13:51:58.761730',NULL,'2026-07-23 13:51:58.762858'),('0034e539-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','45e26aaf9550c8a57338f9243db6314b546334f72c9cfe16dd64e9907d5ca2d0',NULL,'127.0.0.1','node','2026-08-06 13:51:58.854208',NULL,'2026-07-23 13:51:58.854630'),('00c31adb-8a6f-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','75caf8bf1c39deb82c21bbb2513961165e2e3a237dd62dc84e47d38e93894b78',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 17:27:58.368123',NULL,'2026-07-28 17:27:58.398469'),('013deb90-8a5a-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000002','bcf9f5cc2ddce998ad83e004b49bd3a7e3ede4e6d61bac30c88b4d8acf848103',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 14:57:39.749914',NULL,'2026-07-28 14:57:39.769161'),('0152cb8f-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','3012a91602f1f7b7f745de8253a6173e16bc0669a310abee7aaafd4418d222d7',NULL,'127.0.0.1',NULL,'2026-08-06 11:50:19.281305',NULL,'2026-07-23 11:50:19.283878'),('01c968c5-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','be37cf69d286f8275092da06fd1603ca3dae5a38eb0cd8a33dcb90fd48149666',NULL,'127.0.0.1',NULL,'2026-08-06 11:50:20.060748',NULL,'2026-07-23 11:50:20.061260'),('0399e637-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','424ba25edf16ef91b0f552745939ca8cc3f06c426c1d2fd0eb88a5f648314ac5',NULL,'127.0.0.1',NULL,'2026-08-06 11:21:45.117833',NULL,'2026-07-23 11:21:45.118400'),('03ac6558-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','21c1e62fe671fd1ee6af367b45c11569a38076032980cbfaa67b7b6f9161ed87',NULL,'127.0.0.1',NULL,'2026-08-06 11:21:45.238456',NULL,'2026-07-23 11:21:45.239637'),('03b8ca16-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','3c7bbff980c6a2f57eccf713e6cb4ef7dffc24b0b0e039e56aebf543a0389a52',NULL,'127.0.0.1',NULL,'2026-08-06 11:21:45.319750',NULL,'2026-07-23 11:21:45.320857'),('0b672a14-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','399ccaf6ee3c265ffe45f0d3d39db4e128791f0e16f60059ce97b397f0a82fad',NULL,'127.0.0.1','node','2026-08-06 13:52:17.638295',NULL,'2026-07-23 13:52:17.639011'),('0b7638c7-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','b362253bab1c15032eca433ee019b63832697f211519ec38fc4c26074fb59054',NULL,'127.0.0.1','node','2026-08-06 13:52:17.736670',NULL,'2026-07-23 13:52:17.737699'),('0b83d48e-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','de0bb87dc3a0a19e2a6d9a01695ba0e8da8cc99600f524710ab8aa5a5a81989a',NULL,'127.0.0.1','node','2026-08-06 13:52:17.826546',NULL,'2026-07-23 13:52:17.826877'),('0b91658e-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','0e7fd638a93628afc3a1ed037d67b4901b3fe7a61276bd7e6ec1b7d579f53c07',NULL,'127.0.0.1','node','2026-08-06 13:52:17.915106',NULL,'2026-07-23 13:52:17.915798'),('108a867d-8651-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','2c6c29b062a6e3334078a5ff016a2182afbf2847ad6d303af2441f3fe1548458',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 11:43:35.307033',NULL,'2026-07-23 11:43:35.315753'),('12dc03bb-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','f869a2dae831ac523125c1fb87964e7a2b64fabe77f73e4a857640a97e92bed9',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-18 17:05:51.661386',NULL,'2026-08-04 17:05:51.664735'),('1325ffa8-8662-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','319192da1ac3a9fc0a2b41cee46cf4e6db21dc62cd1687743ccee65dfd383c31',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 13:45:21.134781',NULL,'2026-07-23 13:45:21.136955'),('1367e6c8-751c-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000001','b5acc6854dc7302126ce8bf657237b36200e9ee57686815f672a02b574267bfe',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-15 14:11:27.030195','2026-07-01 14:11:29.368758','2026-07-01 14:11:27.030594'),('159c1d08-81c7-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','3a2690d951ff617d78c9c3f7803545289b35b614621ee51a4864c36b22ab6fc2',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-31 17:05:48.621157',NULL,'2026-07-17 17:05:48.622221'),('175daecf-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','2f8d6ddf86fc5933383f61d27badc2f8c461700910361fff6776bb4bdce63a97',NULL,'127.0.0.1','node','2026-08-06 13:52:37.708084',NULL,'2026-07-23 13:52:37.709533'),('176d5b47-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','069639c4744eea7fd0578029d0c6fda1577a16420f27dddff7444c31f6d35768',NULL,'127.0.0.1','node','2026-08-06 13:52:37.811770',NULL,'2026-07-23 13:52:37.812262'),('177c93ad-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','6cf386e4e4759f511f7cff5279436de811513b7b97a5201faab9b006edee007a',NULL,'127.0.0.1','node','2026-08-06 13:52:37.910751',NULL,'2026-07-23 13:52:37.911997'),('178ae8d8-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','b71da617ddab916c6d17d140e1ed63bae96a97585b419117add176f16d680877',NULL,'127.0.0.1','node','2026-08-06 13:52:38.004566',NULL,'2026-07-23 13:52:38.005919'),('17aeae1d-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000002','719999aea3c2a02d39d0f72aa5017e740e11280fbd19475c90d039ae9e4c0c51',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-05 14:08:08.388556',NULL,'2026-07-22 14:08:08.391140'),('18f102bd-8651-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','532b5d5297b8faec6e7319cad902003c87ac9d4d427707c31fb0cd4712e2171e',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 11:43:49.409217',NULL,'2026-07-23 11:43:49.411607'),('19553e0b-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','2de82c81ee78a556b6ccbdce6f1303c8ce318c6e20fd8f2272cc6ea686bd6e26',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-18 17:06:02.525963',NULL,'2026-08-04 17:06:02.526608'),('1c2e4de1-841c-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','ebf02c7f2c60f9809cbac84418b0bc1a26e09ff5f55fc9af1542655948681bff',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-03 16:19:29.155914',NULL,'2026-07-20 16:19:29.189007'),('1d9fffd7-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','17cd7badb501094a2e52605a32853ecb11ec72de0b04151df6303d0abe024d65',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 13:52:48.208779',NULL,'2026-07-23 13:52:48.210456'),('1ecfdc3a-864f-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','1ddcebb57c6027f4478a724c1e24d5aa613d11f617cffdfef1cfe6a87faf3127',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-06 11:29:40.265307',NULL,'2026-07-23 11:29:40.267225'),('1efceba7-8961-11f1-b28f-002b67818c25','00000000-0000-0000-0000-000000000001','7638735a3610ac152b46c3bb781447467dccbe42de96ca06507e0d91758e67cb',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-10 09:16:04.978419',NULL,'2026-07-27 09:16:04.983247'),('1fac055e-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','a564f661d7c267323b8f5e7ce42c226638e113a5cdb075426c03baa7454e2973',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-18 17:06:13.160861',NULL,'2026-08-04 17:06:13.161641'),('22e95406-864f-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','819707e63f7c23ae1810a535106cd67c78c3d1341527aead7d308e82c44f1ce4',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-06 11:29:47.144215',NULL,'2026-07-23 11:29:47.145035'),('2304df91-8664-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','2dce4c39491ec8d7ce4264fa501e0244f03837b2c859fe2dda20d19e9391f184',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 14:00:06.755387',NULL,'2026-07-23 14:00:06.756889'),('245a0bb7-864f-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','61ff819a61aaf39c0e4658cf2352809560f69a242abd6956e7d8edf0a54c3faf',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-06 11:29:49.560456',NULL,'2026-07-23 11:29:49.561474'),('25e434db-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','c45ee60ce89232e669dd5549882e083593af9413d8d4e72c41556868262ff47d',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-18 17:06:23.594932',NULL,'2026-08-04 17:06:23.596220'),('26de9fbe-8664-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','910fad46eb21a967b1ce90c0b4c5132be7ac3efb37e51e0d51fd0911ea596961',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 14:00:13.216552',NULL,'2026-07-23 14:00:13.217109'),('2749a452-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','a6e892343ed0cc18c42373ad3d1ea68ae49d970221ae07393e03d5886783838e',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 13:53:04.419345',NULL,'2026-07-23 13:53:04.421720'),('28d6f0dd-841c-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','5ad3136b21683aeb384e1fd6915996c8de3a142b6159d015b5dd8da1b9d88dcc',NULL,'127.0.0.1','node','2026-08-03 16:19:50.430967',NULL,'2026-07-20 16:19:50.432099'),('2aae3738-841e-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','c1f2a60c983eada3bc5989a41e8dd7a3825f07205085a8fe71286c5dfd479c42',NULL,'127.0.0.1','node','2026-08-03 16:34:12.513112',NULL,'2026-07-20 16:34:12.514076'),('2bd98595-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','f69ebcf79d25fc5f422e334222a609ca4aa68e7b4bb700d0b0c79bcaeaedb5f8',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-11 10:41:09.371692',NULL,'2026-07-28 10:41:09.373787'),('2c3c46a5-8664-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','6ab8a8281b1e66c8925c75d7e7509e78b4cfe147c593c2d8b3d56ed2b9ba5f7e',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 14:00:22.216238',NULL,'2026-07-23 14:00:22.219485'),('2d9ec09c-81c6-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','315b188a6d5858ccbe16b359fdc6021f2bb134df948bacdc7d14648b34e53a53',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-31 16:59:19.398644',NULL,'2026-07-17 16:59:19.408182'),('30f5b6ec-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','b5401a70a99468eaba0eed5bb512c2ff20011bac2a3dc6cebba248a05573b5fb',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 10:41:17.946700',NULL,'2026-07-28 10:41:17.947193'),('35b803ce-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','e9b33ff6e66db68f0ba9b28203d5465056ce8080e909a8ae4f1d568bfddcc6cd',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 13:53:28.631366',NULL,'2026-07-23 13:53:28.633170'),('38377f71-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000002','69febcc92202c169498edfe69f03609b3ba8db6eaf8b760a5280fadeca804f3b',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-11 10:41:30.116157',NULL,'2026-07-28 10:41:30.122350'),('3848e03a-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000004','4a9577fe9323a3681283de1e3b8647695a92b3d1b314c32be2f52470f36169a0',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-11 10:41:30.235757',NULL,'2026-07-28 10:41:30.236238'),('3854e431-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000006','ab91318d3c3c6f70f7f10fc32fae24b01841ad1623f57f3381294a179f5d073d',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-11 10:41:30.314083',NULL,'2026-07-28 10:41:30.314971'),('38612811-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000003','0e6577328110abcda04621b4165c87be60258babf774e1fa485947ecdf285de9',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-11 10:41:30.394190',NULL,'2026-07-28 10:41:30.395400'),('393071c1-81c6-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','5b6ed5d17cf95a90b57d6fc42593bab3d58ab56f7e522d9fcf2e056187e86cf1',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-31 16:59:38.812246',NULL,'2026-07-17 16:59:38.817940'),('3932cdf5-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','d33effecfddca94cf9a20816cfeeab19da81321106efca4d38f72e4abf818a80',NULL,'127.0.0.1',NULL,'2026-08-06 11:23:15.038729',NULL,'2026-07-23 11:23:15.039753'),('3945926c-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','2d7e318f347b637b2d8c7f36c4eaa603d57f9689e723d0676c34939ce4500278',NULL,'127.0.0.1',NULL,'2026-08-06 11:23:15.162019',NULL,'2026-07-23 11:23:15.162736'),('39503f8d-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','b9dfc815226e4c74a426b22e2c7ae58993fd843a15d7c29e02e8732063421b06',NULL,'127.0.0.1',NULL,'2026-08-06 11:23:15.231459',NULL,'2026-07-23 11:23:15.232686'),('39ea42b2-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','095f96638ac3baa14b504a2d19433a68b347158c6634afb95de05c68dc519082',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-18 17:06:57.188887',NULL,'2026-08-04 17:06:57.190325'),('39fc2777-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000002','e7a61ed95ace54b6634803222ee4a0a1519babb78850672b54cf72487169114c',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-18 17:06:57.306651',NULL,'2026-08-04 17:06:57.307555'),('3c251d8c-7385-11f1-ac50-002b67818c25','00000000-0000-0000-0000-000000000001','ef5023a6d610d7ca20521d89074c49e0f6151c3107db35e5b66aa72530c307c4',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-13 13:39:10.206639',NULL,'2026-06-29 13:39:10.210240'),('3c752411-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','897e8f84ac99450aabde4654a1ef734b3b3731d2e59680d9062bfa0339498225',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 11:51:58.493680',NULL,'2026-07-23 11:51:58.494521'),('3c872909-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','381e5527785523883b91210b7d8ed7111474ceb27bc4d3b5e5d59094c39ad2b1',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 11:51:58.611532',NULL,'2026-07-23 11:51:58.612662'),('3fb2544e-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','32c4808c2f35e724253dc14960144faee1a2f0d0d2145a4aeb3a7fc506c96eb2',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-31 16:52:40.224929',NULL,'2026-07-17 16:52:40.236604'),('4007a17e-8fd2-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000001','85e0bc7d565b42f8b786805989f425a0d26933e62160eab50ab2d9b6d0878936',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-18 14:01:00.512235',NULL,'2026-08-04 14:01:00.516126'),('401fb1e3-81c6-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','b25563d7de7fc85daecb46d6545e981e474ab4686e27ea3db70284400d956684',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-31 16:59:50.451098',NULL,'2026-07-17 16:59:50.452218'),('4728b73b-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','0ed84b8370f4da268f2b50115ed25ee725d7ebecb6e8c8bfa33d7a75da4a9668',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-18 17:07:19.409270',NULL,'2026-08-04 17:07:19.409974'),('477fa578-89a2-11f1-b52d-002b67818c25','00000000-0000-0000-0000-000000000001','ecfeee199162d38eaade4e9a594080d548b6ccb3d00fe71d5b8dad95e302e507',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-10 17:02:30.233461',NULL,'2026-07-27 17:02:30.237987'),('484bb56a-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','b1a69daa8999930e6e89d23e4f8310ebe76eb3a39eb7a5f0b34384cfcf936293',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 11:52:18.355000',NULL,'2026-07-23 11:52:18.355689'),('4b4149c3-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','71603f782df2eb736964ce2a3da6375c8a8df96a7acef2244820bd53bbeb3baf',NULL,'127.0.0.1',NULL,'2026-08-06 11:09:26.338647',NULL,'2026-07-23 11:09:26.340179'),('4b69dce2-8662-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','9af88c0dcffc875f10e171ed8be3f9dc0769b80fffcc0c348878e42e00131f75',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 13:46:55.528712',NULL,'2026-07-23 13:46:55.534143'),('4bc2c32b-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','f618f0a008a7753109884426a1fcc329899b215f403a18145d7afdc58f9d7a12',NULL,'127.0.0.1',NULL,'2026-08-06 11:09:27.188199',NULL,'2026-07-23 11:09:27.188730'),('4ec562f8-8afa-11f1-85ad-002b67818c25','00000000-0000-0000-0000-000000000001','c0531238c77d8b198ec5df20cd2c86da6bb1e618f6248a996f05cca1e4b1b290',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-12 10:05:09.298927',NULL,'2026-07-29 10:05:09.306769'),('4f3f0485-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','821c9d9982f555dd325378abdd76d2a821e48591577744a36a29ba1a626295f8',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-18 17:07:32.977274',NULL,'2026-08-04 17:07:32.977931'),('4f5590da-81c7-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','c653f8c4ff89212a8a2afa902baf3ea0b8f3ce4b0848ec126a9125993a344ee5',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-31 17:07:25.466140',NULL,'2026-07-17 17:07:25.467670'),('4f6c461d-8662-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','bbd4e0516d2ad34cf6dbc67eae58954a307f09d65efed5aca26cef9c8921fbd7',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 13:47:02.259858',NULL,'2026-07-23 13:47:02.260828'),('4f943b96-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000004','fa3504a99c7df763136c4e715c72b577a5a3a56dccb1c5621d5f72adb6e81d7d',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-05 14:09:42.168473',NULL,'2026-07-22 14:09:42.170242'),('50b00938-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000006','30298073eb9ef0af83050bde0fa51cf97361459f88455003709ee9d1c5fa109a',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-05 14:09:44.028981',NULL,'2026-07-22 14:09:44.030163'),('512e43d3-8b34-11f1-b11f-002b67818c25','00000000-0000-0000-0000-000000000003','ca0a17ee4f26369e17167432f19bf8d0d2a868046e435c73bce93e2c429e879e',NULL,'::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-12 17:00:24.168784',NULL,'2026-07-29 17:00:24.173981'),('5207b31f-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','2a1112981075f423b98852c00c1df83ea59f132d4d693f2577e3df5aa49997c4',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-31 16:53:10.986678',NULL,'2026-07-17 16:53:10.997222'),('5349465d-8662-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','74e44a920c4b835d0f84ddb9c0330a97f2b81ffe990577b8f8ffe517e0cd13e5',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 13:47:08.741120',NULL,'2026-07-23 13:47:08.742367'),('553c5035-768b-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000002','a35a63ad8da148b018671782a4cf0b6b06dbb6140d36a8009f732f4338a4d8ec',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-17 10:00:22.747302',NULL,'2026-07-03 10:00:22.756362'),('585dfc26-738c-11f1-ac50-002b67818c25','00000000-0000-0000-0000-000000000001','3ba163fa3092267a4a3c49a15171d3d5a3b1b2acd95e1f46347eb419f9eb2b2f',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.126.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-13 14:30:04.034242',NULL,'2026-06-29 14:30:04.036456'),('5a0662ce-768b-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000002','aec4c4b802398d4ab2b6f9cc503296f78b114828f494abfa55d7ae67aded65a0',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-17 10:00:30.807979','2026-07-03 10:01:37.937668','2026-07-03 10:00:30.809437'),('5c06ba1a-738c-11f1-ac50-002b67818c25','00000000-0000-0000-0000-000000000001','12afefe344831ae1038c2f00551dc79bc5b2d59e43242170d4ac179c66642ce9',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-13 14:30:10.174999',NULL,'2026-06-29 14:30:10.175585'),('5c67fa7a-8a5a-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','a93e84df568a58c796c99fcc58e9404a56a1440807a673a1054642ba619bcee3',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-11 15:00:12.686810',NULL,'2026-07-28 15:00:12.720097'),('5fe11b04-7f2a-11f1-9e6a-002b67818c25','00000000-0000-0000-0000-000000000001','fe122c006082033a8ab5bb7da525184f9d51634bce7be90dc90c401aa4d57509',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-28 09:18:59.900064',NULL,'2026-07-14 09:18:59.904950'),('601872d7-8647-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000001','2daecca4078c92c9d584a671491c432bd17c2fd55e13e0e3a567033b3801a966',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-06 10:34:13.377305',NULL,'2026-07-23 10:34:13.650746'),('62f071b8-89a2-11f1-b52d-002b67818c25','00000000-0000-0000-0000-000000000001','3c4052054fa5b69e559331cb89b58ae1b60abb68c60ce0a4985eadf278ab3d16',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-10 17:03:16.282207',NULL,'2026-07-27 17:03:16.282771'),('63303025-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','df9052e86cddcc8aa6a0fb580b71e88951b7bcea400a7b34b9241e8d611e7758',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-31 16:53:39.773674',NULL,'2026-07-17 16:53:39.783843'),('64aabf6c-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','1f8f70dbcf7a4c5375b202b4108af253b3e3572c47e8af526b755ef86d117ca9',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 11:10:08.973592',NULL,'2026-07-23 11:10:08.974359'),('6a789c64-7e9c-11f1-b890-002b67818c25','00000000-0000-0000-0000-000000000001','dddc649cc9a995ccfc59120beaf7d5603c16b9ec646536e591eef96bf25f7b67',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-27 16:22:49.138722',NULL,'2026-07-13 16:22:49.146891'),('6f35314e-864b-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','5b994b54b18207bca5dcf42deea2a252648c5f43d9b081fc7296fe1432e2bff6',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 11:03:17.157834',NULL,'2026-07-23 11:03:17.162083'),('705692c7-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','499593a53af1f040891270afbc4db4776d389ed6c42dbb98888f7b2b8a47615c',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 13:55:06.977549',NULL,'2026-07-23 13:55:06.980174'),('71516b30-864f-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','87cc2157484f06df3efb55a9a255a65507a05a1812cfde4f71bfb4b590a1c9f4',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-06 11:31:58.688570',NULL,'2026-07-23 11:31:58.689475'),('71ae58c7-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000003','fa7d3254008bbb6f44f274813468b712c6fdc9f7aecb61bb66b7416354bbdda3',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-18 17:08:30.748245',NULL,'2026-08-04 17:08:30.749996'),('7444793f-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','8695b39ddbac6c401fa02a71cd18abdcdff044df83ad5674be457c199237ff74',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 13:55:13.571120',NULL,'2026-07-23 13:55:13.572389'),('77245f73-859b-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000001','28be7fabbbe5b187adb69fe53d71c5a19c89b908e4eedce381cc4da7a41665c9',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-05 14:03:39.023294',NULL,'2026-07-22 14:03:39.032741'),('783433c4-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','c74243f738a894c6c49dd9e65cd545668d4c213236dfe570588bbc0695485b27',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 13:55:20.175992',NULL,'2026-07-23 13:55:20.176690'),('7934bf62-864b-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','7d56cc20fe9879ff7b898fc8e7ce7ac7d150ac09578d98fd5d1ce9366c683ecd',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 11:03:33.935338',NULL,'2026-07-23 11:03:33.936428'),('7a36107b-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000002','6b13b4a34c3fd4c27efc0b12a6e3506b1c09d5abb042d306499e2d5d7bfb2c73',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-18 17:08:45.060740',NULL,'2026-08-04 17:08:45.061283'),('7d6b5389-8a6e-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','7506d6e1a3d57fa29b92c46bc83c36dd30f0374ea916f0b1149315dff67721f7',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-11 17:24:18.010218',NULL,'2026-07-28 17:24:18.039176'),('80e00187-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000002','373903330550be22986914311903adfbba34fa9365cc617d529217b625a0289e',NULL,'127.0.0.1','node','2026-08-11 10:43:32.021436',NULL,'2026-07-28 10:43:32.022665'),('81957f2d-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000002','660e16e2758c815f92447affc7f5d02332aacfa3a13fdfcd15b64a0b00f3eb85',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-05 14:11:06.063787',NULL,'2026-07-22 14:11:06.064574'),('849a51d5-7e92-11f1-b890-002b67818c25','00000000-0000-0000-0000-000000000001','57db066e5f7deb0d67fdbdb66a883442932ec8096491c5580c99ea8e6725e9d0',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-27 15:11:58.014773',NULL,'2026-07-13 15:11:58.021880'),('8540816c-768b-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000001','ae09840a9a9ca8bedd2cfa2f6cb3ba76877585cb5348e3db7689269cd4c0602f',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-17 10:01:43.330839','2026-07-03 10:01:54.027984','2026-07-03 10:01:43.332343'),('8696e95e-864f-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','64dddf669142a2ed4a3687f493d2a350c5995412ccba43fd8d942053a13ea1f3',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-06 11:32:34.376343',NULL,'2026-07-23 11:32:34.377057'),('89019ffc-8bc5-11f1-9154-002b67818c25','00000000-0000-0000-0000-000000000001','ef4866e97493d3329a54820092f00422c9a89add78c6e029cd79096b432119ba',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-13 10:19:54.840524',NULL,'2026-07-30 10:19:54.846357'),('8a0127ee-859b-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000002','bfbffd86919eb6adddc796442d06a61dbb85a7499253bffbae1c09e1d9056cb1',NULL,'::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-05 14:04:10.694033',NULL,'2026-07-22 14:04:10.695188'),('8c310fde-8651-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','3192b9e896b4de65160f3a6ce42e4ebdd5bbd2f68bb562a3bdb4557f74a256e6',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-06 11:47:02.765939',NULL,'2026-07-23 11:47:02.769284'),('8d0626ab-768b-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000001','7c4177d8728e5521fa6292fc1d720452eda59b2ee7a5022146491429e03e44cb',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-17 10:01:56.365096','2026-07-03 10:02:39.579723','2026-07-03 10:01:56.371787'),('8fe71acd-859b-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000002','67a70d43a08af079ab6e0843f0a439d0a04baf5ddffa865c3ba0d1a90ae4ea1c',NULL,'::1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-05 14:04:20.589923',NULL,'2026-07-22 14:04:20.590812'),('94e28944-8a2d-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','37f35d181837413fd3ad0c007540ff76c1a07c2ffe6005e2e6b28fc0e54fc489',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 09:39:40.105273',NULL,'2026-07-28 09:39:40.109340'),('9bec842d-8a2f-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','cb502158018b89003900a8f12fb666f23636fc8c216f49787f33c2df2713eadc',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-11 09:54:10.924778',NULL,'2026-07-28 09:54:10.925940'),('9caece20-8661-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','40ee9cf35ae548d1829c1171a2e0a1c2c4bd46026e4a909d4ece26bc1a1441b7',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 13:42:02.373441',NULL,'2026-07-23 13:42:02.382539'),('9fb13d1c-8a62-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000002','869a8d9d037e945b8f905e4fdd397ff759a8d345647540a63e3684f80393f886',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 15:59:21.551726',NULL,'2026-07-28 15:59:21.579054'),('9fcdcc57-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000004','b86d114c6b871940e97e020bac212e130d4246131183d9131e1e40319f11472e',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-05 14:11:56.763191',NULL,'2026-07-22 14:11:56.765186'),('a0a01a8c-7f41-11f1-9e6a-002b67818c25','00000000-0000-0000-0000-000000000001','239ae907a9956fcf9745851949ae5012b6a57fb0b2a1693fa9c1136304faf04e',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-28 12:05:26.958313',NULL,'2026-07-14 12:05:26.963513'),('a11c6f6b-8660-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','8fd878892905278da6a4aa0399ffb45e2de3947b6b81e8dcbe3199a8cd930cb3',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 13:35:00.309010',NULL,'2026-07-23 13:35:00.315663'),('a132e230-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000006','d76fb986795c1111ba4e0cff434a5ca67efa0949845b175e99a8558c887caa27',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-05 14:11:59.104255',NULL,'2026-07-22 14:11:59.105408'),('a2303df5-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000002','510ecb010b4d095abe40444267372662e3383c1376485c6481afd3245280de98',NULL,'127.0.0.1','node','2026-08-11 10:44:27.911934',NULL,'2026-07-28 10:44:27.913313'),('a2586726-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000003','73758351a0c00ef869baf891e2805253739282c81d65ba401c14bbd97414fe1f',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-05 14:12:01.028413',NULL,'2026-07-22 14:12:01.029012'),('a4a686b0-8a40-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000001','d52a24eb79b451a1ff712244c3b4fca6292746e0fbc53326cc4bab48bc26d5f1',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 11:56:07.008431',NULL,'2026-07-28 11:56:07.010759'),('a5446a5e-8195-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000002','999bcf75bda55c0986bfbb18ecf4d1fffad577d8e8c0a62d1e60bb39cd230eb2',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-31 11:11:54.799059',NULL,'2026-07-17 11:11:54.802107'),('ab1a0047-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000004','aa774854bd9150e5572d63e4ee18a6127d118b8541c74f3bba7f131d191f0bbf',NULL,'127.0.0.1','node','2026-08-11 10:44:42.864583',NULL,'2026-07-28 10:44:42.867052'),('ad46ba9e-8a36-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000003','11463d98aac45b9c926ce711edd954fd04d10c37e6e8cbe85a38185b199acac4',NULL,'127.0.0.1','node','2026-08-11 10:44:46.515069',NULL,'2026-07-28 10:44:46.515606'),('b061d14c-751f-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000002','bc83c2c791d83fd4e77e1468adc2a37b65891fa72e5062e864d86e22f5558580',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-15 14:37:18.882539','2026-07-01 14:38:09.809823','2026-07-01 14:37:18.883198'),('b2241ea5-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','f4be56625dbede00b8ded6ca4cbe97df770c16678b1b46ee10055d6baf5f9122',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 11:55:15.903438',NULL,'2026-07-23 11:55:15.933100'),('b286c579-7f4c-11f1-9e6a-002b67818c25','00000000-0000-0000-0000-000000000001','2faa3204c895c720a2e27bb0840708da597aee3e3a43aeda766acc06d75a6457',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-28 13:24:41.455136',NULL,'2026-07-14 13:24:41.461137'),('b3ee8750-80d7-11f1-ae8c-002b67818c25','00000000-0000-0000-0000-000000000001','23b9c94afc10bfaf5c6d506d0cf4c97e63005f0284448a972c99501cc430b029',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-30 12:32:15.005057',NULL,'2026-07-16 12:32:15.025713'),('b770a0a6-8a56-11f1-a00a-002b67818c25','00000000-0000-0000-0000-000000000002','7cd1c2b4f619aa3fb7fac2178799bb5ef39018a852ee7a54a29f7fb187f686d7',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-11 14:34:07.457101',NULL,'2026-07-28 14:34:07.461282'),('b7ae7bd1-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','62cb083e1fa06a6d802cb853b1dd88278cfc3aaf2de6b30fa081de1479ef317d',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 11:26:47.242065',NULL,'2026-07-23 11:26:47.243162'),('b987360d-841d-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','40e9547969f8bb1886bf30eb6aa263307958fb0e9533bd84150b6f358c8f8ff4',NULL,'127.0.0.1','node','2026-08-03 16:31:02.673431',NULL,'2026-07-20 16:31:02.675593'),('bb2ce767-80c1-11f1-ae8c-002b67818c25','00000000-0000-0000-0000-000000000001','c6152182cae670a97d1a699ac1e8759d92684977a517b6868ae6df6cef831b44',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.127.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-30 09:54:58.220953',NULL,'2026-07-16 09:54:58.230690'),('bc79ad55-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000002','02eb55a0e1168b8a7d4afe48337285cb79b2a0b10e4488e0fe1686662b9c45bb',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-05 14:12:44.866982',NULL,'2026-07-22 14:12:44.867857'),('bd2948aa-768b-11f1-9885-002b67818c25','00000000-0000-0000-0000-000000000001','db0916eaaa4565a7fc94eda63a0f14ad7b309fdbbfc04a8e05f59f06af638260',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-17 10:03:17.132020','2026-07-03 10:14:41.088433','2026-07-03 10:03:17.132612'),('c183285b-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','92ee3b94d356930691295229b146f94f477bc1f706ed2b731fd29c47df69a347',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-25 05:08:57.132026',NULL,'2026-08-11 12:08:57.216833'),('c1c0d70a-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','2b70b9252e5548a2c19657676b5fa3ecefec280ab6bbb64f048b4a808d469001',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 11:55:42.125995',NULL,'2026-07-23 11:55:42.127650'),('c26015a4-751e-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000002','f36c6fd78c2226e4dcb8efd0f61191b8d48178718c3dd12015dd60e6a9d0a515',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-15 14:30:39.572949','2026-07-01 14:32:14.099910','2026-07-01 14:30:39.574077'),('c3eeb42e-80d7-11f1-ae8c-002b67818c25','00000000-0000-0000-0000-000000000001','9b5ea056df51c1ca7847a01dea46c0e17eddcd97cdc14cff092c14ce9d3c2b09',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-30 12:32:41.869045',NULL,'2026-07-16 12:32:41.871077'),('c65f1622-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','466b8bd200a2fa3e7e255e00dec8a3a2166cda8f721aff34799566901ae1891b',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-25 05:09:05.292853',NULL,'2026-08-11 12:09:05.302953'),('c86be15d-8189-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','e5cc27b347c6d8a00c89ea56d9e171fd23025df91b964f060836218585400906',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-07-31 09:46:59.801032',NULL,'2026-07-17 09:46:59.807830'),('c8ee5ed6-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','790bcb73e89e9622cecd2674695ba91b2f4d93711a3bd6a74aad31c210751bb2',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-25 05:09:09.652182',NULL,'2026-08-11 12:09:09.663949'),('c943249b-76a2-11f1-974e-002b67818c25','00000000-0000-0000-0000-000000000002','cc5135d51fa2f8c94c7153b501fababe1aaeb909b6c2e0e54d2ccab1e2b102d6',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-17 12:48:15.840268',NULL,'2026-07-03 12:48:15.849390'),('cadf7c2e-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','5a7b523d086e2e57b53a47c4093061fff8bd4047208a033a16552951cd0ff988',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-31 16:56:33.737198',NULL,'2026-07-17 16:56:33.737904'),('cbcc85ec-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','a87134af2aa8d3479d77097c0cb035ac44c1869cb440135b99eddf229002688b',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-25 05:09:14.463836',NULL,'2026-08-11 12:09:14.475320'),('cc171790-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','9bb9c9476e2c2f53af260e1b647399cb5321d975ce319d0355b7e1ba83924adb',NULL,'127.0.0.1',NULL,'2026-08-06 11:13:02.488537',NULL,'2026-07-23 11:13:02.489739'),('ce505080-864a-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','85fdb6eac65a1371fb904241b4258d2bdc40ccca3d695d6d96908c851d976ecf',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 10:58:47.222731',NULL,'2026-07-23 10:58:47.226581'),('cebf86b1-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','ff4b6d45273b8122de6d99b4ca7e5e38128c45c152a67512d47b607d9cae2a20',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-25 05:09:19.420754',NULL,'2026-08-11 12:09:19.423334'),('d0420dd3-9542-11f1-9595-002b67818c25','24c54a64-a645-4f8f-9b87-40a20b31d6ce','dc358dcc196f2bd7b0bf4c9f3879f7f6fb1f424f9768b73da1303436acb5784a',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-25 05:09:21.955335',NULL,'2026-08-11 12:09:21.956490'),('d0d72e94-751f-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000002','ab0e9cec2b8a0c7d46c4116d4cdc7dcacb8f7bd429a78097c21270258b3d363e',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-15 14:38:13.338844',NULL,'2026-07-01 14:38:13.339468'),('d1b094c6-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','97217423fe0873f789212054403ab8b3ee0270415b7c54ded27329b3969fcf15',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-25 05:09:24.357111',NULL,'2026-08-11 12:09:24.358598'),('d2ad09ef-9542-11f1-9595-002b67818c25','24c54a64-a645-4f8f-9b87-40a20b31d6ce','0ff2feec4599a27376d0623073273ea8f5b9895d3cc2792c56ee769b643af450',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-25 05:09:26.010103',NULL,'2026-08-11 12:09:26.013011'),('d423ea30-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','a675a7e044e7edd8e429e1a8b8e5532fc1e58cb8880eb171a6da4ffef7e7fbfa',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-25 05:09:28.468738',NULL,'2026-08-11 12:09:28.469870'),('d5a5a4d2-9542-11f1-9595-002b67818c25','24c54a64-a645-4f8f-9b87-40a20b31d6ce','b597006aa8f8efc754987452c7ea23583b2b2aa495730ae563a3345ca808d3fa',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-25 05:09:30.996310',NULL,'2026-08-11 12:09:30.997725'),('d62f5ee6-864e-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','4e7ae5c93ca1ddc41b4489c6ea6dbd298cbb413c134c3aa8cd4b6d72bb9cc24d',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-06 11:27:38.418196',NULL,'2026-07-23 11:27:38.419487'),('d675980e-9542-11f1-9595-002b67818c25','7f55f406-fa96-4bdb-8758-4178ba8e082c','688c3407fe5b5d8166accf6adf3dbc1f503f8a8958ffe5c1b9762750a0a491d7',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-25 05:09:32.356773',NULL,'2026-08-11 12:09:32.360512'),('d7614bc9-9542-11f1-9595-002b67818c25','16d75d68-b6c2-43de-97c6-ec099ae08ce0','fcbda428d5eef3b14ce6188e10d7dbe2ec5e65e3dfc021a5a48448e009501e5f',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-25 05:09:33.904232',NULL,'2026-08-11 12:09:33.905312'),('d8dfc431-8652-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','1b50c0c9056ce169621a2c9c32fabe295362d2589b53a30494164115ecd4f9ed',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 11:56:20.917207',NULL,'2026-07-23 11:56:20.917892'),('d8fef781-9542-11f1-9595-002b67818c25','8d94550e-df85-4ccf-9b87-f6717f61cccf','e612dcb8fb6f21d026dbf97187cf9dde94160c5074ea98d6c4722d45cc1cb96b',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/151.0.0.0 Safari/537.36 Edg/151.0.0.0','2026-08-25 05:09:36.614798',NULL,'2026-08-11 12:09:36.616362'),('d9c98b16-864a-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','7c4b47bda13fa6273402e40692e477f2a1a7a34eae66f09550ed66caed5dd9e4',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 10:59:06.475049',NULL,'2026-07-23 10:59:06.476163'),('d9d8242c-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','1951be037abbd8cfae2650ed9064d74e6387528263c3c8942a9b62bc2129fda8',NULL,'127.0.0.1',NULL,'2026-08-06 11:13:25.564450',NULL,'2026-07-23 11:13:25.565298'),('d9ece22e-864c-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','440a5c55171832b5f201f37bd4abb1b3b4e7c5bf4cebd60489c4a57f217a5713',NULL,'127.0.0.1',NULL,'2026-08-06 11:13:25.700323',NULL,'2026-07-23 11:13:25.701237'),('daf2c10b-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000004','c5e5a325ae880e362274ed05a2e388b7c98dfa8b630e676f793eb9a19d038ae7',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-05 14:13:35.984374',NULL,'2026-07-22 14:13:35.992913'),('dc677e5b-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000006','1550da4aff911d18228ed1f11a1a6dca571c11fd55b14787df316b378486a1ed',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-05 14:13:38.434415',NULL,'2026-07-22 14:13:38.435745'),('ddde3082-859c-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000003','88072f682e29c37309431f365e75329a2c0ef45f82abaf2326b8b608ff8a1121',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-05 14:13:40.890227',NULL,'2026-07-22 14:13:40.891353'),('e06f95b4-751b-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000001','37e40752f5254ba72d5db7866e56b31633cc91ed09cde11df41af6648fdd780d',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-15 14:10:01.501311','2026-07-01 14:11:02.829942','2026-07-01 14:10:01.507982'),('e0c96b80-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','e9447ea2ede48818c074abc4e6ffb80f27ea675b7e414f183393bffa47192d61',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-31 16:57:10.502753',NULL,'2026-07-17 16:57:10.503244'),('e4af1c1f-841c-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','93cf18ec5ed087f11aab64c656d1788991c7bef63993b389b69075811868ca6c',NULL,'127.0.0.1','node','2026-08-03 16:25:05.582184',NULL,'2026-07-20 16:25:05.582679'),('e62d98ec-841d-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','7351aa53066fe6ee2a30ec275f4c5115c84d26197db3e7a2006af1077cdeb282',NULL,'127.0.0.1','node','2026-08-03 16:32:17.585424',NULL,'2026-07-20 16:32:17.586103'),('e6395808-864a-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','8c259f6cc4f563894d5588db39aa88624a36060f0eeff333d82fb082da562be6',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 10:59:27.341089',NULL,'2026-07-23 10:59:27.341519'),('e6b0eb1c-84ac-11f1-9629-002b67818c25','00000000-0000-0000-0000-000000000001','afec7649660d327d7b3199162cd534330b2be3153344f20b997f1040d59fa09f',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-04 09:35:56.413737',NULL,'2026-07-21 09:35:56.424020'),('e6c7376b-8661-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000004','6d9f344fb25275e7bc90ea1217eaa8728fa7a1f001f4290c71d30e8386dad7b8',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 13:44:06.694887',NULL,'2026-07-23 13:44:06.696059'),('e87ee5d9-745c-11f1-806f-002b67818c25','00000000-0000-0000-0000-000000000001','00e56b6d61120482e4befc5596219b18a69b302fae71a20a0555eed3f024b384',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.126.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36','2026-07-14 15:23:01.162433',NULL,'2026-06-30 15:23:01.163894'),('e99f200a-8663-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','132e96ddfd4eafdeff0877e39db40aea3da2d6ec123d0ecdcad57e5398193a3a',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 13:58:30.454906',NULL,'2026-07-23 13:58:30.459358'),('ea9f364f-89a3-11f1-b52d-002b67818c25','00000000-0000-0000-0000-000000000001','17eea9d1c3de8af753250ed24208efa6f4b115b52efcef1b10d566d780dda339',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-10 17:14:13.398638',NULL,'2026-07-27 17:14:13.413337'),('eacaafcb-8661-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000006','86996e288771cd2b6947a4da1f077ad4c9345450fcf35a36b25e3d9478aeb1b7',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 13:44:13.428877',NULL,'2026-07-23 13:44:13.429649'),('eb618f7d-8416-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','83a6b376d98f8b13f1004cb303e72ef50de2af3fcc9d08de09c48e9c7bc388ed',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-03 15:42:19.816994',NULL,'2026-07-20 15:42:19.821231'),('ec3eedbf-8666-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000001','d566214bedd91ccb4560495ad3c44bb47c325b70e6e7bf33bed1110a5e7b49bc',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-06 14:20:03.344355',NULL,'2026-07-23 14:20:03.352567'),('ed0d2532-864a-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000002','0da68dbcf85adeb39f23ea6e7169562379256d946bfd4fb65535d4a240c4aebf',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-08-06 10:59:38.794521',NULL,'2026-07-23 10:59:38.795895'),('ef1b5432-8661-11f1-a160-002b67818c25','00000000-0000-0000-0000-000000000003','16e42b2c6332eaf51f2a2df446085f6db7773a9616118b72830af6e2bdaee984',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36','2026-08-06 13:44:20.668497',NULL,'2026-07-23 13:44:20.669070'),('efe6ae33-8734-11f1-918a-002b67818c25','00000000-0000-0000-0000-000000000001','146210ee4df08824fe4776bb144856f120a73040e1327f472bf27a2db0f6967e',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-07 14:54:45.791024',NULL,'2026-07-24 14:54:45.798014'),('f049bb93-8416-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','54e81c65fd5073aeef2bc5149117207fed55d245d3fec5bdeade8937990bca75',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-08-03 15:42:28.070133',NULL,'2026-07-20 15:42:28.070644'),('f0e64530-8189-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000002','55dae2963be2fe5d4a3f4c2924cfe71e2536ee099735fa373a28251129a1dced',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36','2026-07-31 09:48:07.730543',NULL,'2026-07-17 09:48:07.732089'),('f2f87ac7-78ef-11f1-bacd-002b67818c25','00000000-0000-0000-0000-000000000002','157a39d42772e0eaa86196e70982de1c727c113a7919e17adde1df8bdc6840b4',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-20 11:05:39.385988',NULL,'2026-07-06 11:05:39.393705'),('f47568a0-745c-11f1-806f-002b67818c25','00000000-0000-0000-0000-000000000001','a568caea46ac795f8f2b8481f578ae43eafadb0501192e8625bfdee81183b250',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36','2026-07-14 15:23:21.233918',NULL,'2026-06-30 15:23:21.234401'),('f50a30d6-81c5-11f1-b80c-002b67818c25','00000000-0000-0000-0000-000000000001','0bdb073a7f5a2d813939cb18ca1a4f034ecbbff6468c0dd146dbdf5519e26734',NULL,'127.0.0.1','Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.19041.6456','2026-07-31 16:57:44.481738',NULL,'2026-07-17 16:57:44.482168'),('f809a799-8fec-11f1-9dfc-002b67818c25','00000000-0000-0000-0000-000000000001','fc1add957ac8625ce60ef924ab30ad94a54c133e5fd41365f61e1a848b9dd512',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.130.0 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-18 17:12:16.162393',NULL,'2026-08-04 17:12:16.163170'),('f9537656-859b-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000002','f3afe61e9b847458dbb4f16fc328de4e4d9334f41c627396b578b32246dccb33',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) HeadlessChrome/150.0.0.0 Safari/537.36 Edg/150.0.0.0','2026-08-05 14:07:17.460965',NULL,'2026-07-22 14:07:17.461697'),('fcc968ba-841d-11f1-9ce3-002b67818c25','00000000-0000-0000-0000-000000000001','06163cf82405812340cacb54c12e15b58191e2ed61b1db945ee2a9796660dd44',NULL,'127.0.0.1','node','2026-08-03 16:32:55.516002',NULL,'2026-07-20 16:32:55.517101'),('feba7964-859d-11f1-881e-002b67818c25','00000000-0000-0000-0000-000000000001','de7504a3ef9e97f1716a349de1a2d5cad76e5c6c745bbaf31cafc117a829a3bc',NULL,'::1','Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.129.1 Chrome/148.0.7778.280 Electron/42.6.0 Safari/537.36','2026-08-05 14:21:45.517164',NULL,'2026-07-22 14:21:45.518367');
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
INSERT INTO `report_snapshots` VALUES ('17f513b0-8663-11f1-a160-002b67818c25','bc02e652-5bc1-4327-a6b2-86d323760f34','{\"id\": \"b3b96ed8-8308-4a83-af84-e5d488d1260e\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000006\", \"approved_at\": null, \"customer_id\": \"1e95fb79-ee0d-41aa-b26a-99f07e50976c\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"TSTU9557566\", \"job_order_id\": \"9cb28aad-c5f8-4a6e-93c6-7718905972fe\", \"job_order_no\": \"GIFT-JO-2026-000007\", \"submitted_at\": \"2026-07-23T06:52:38Z\", \"customer_name\": \"UAT Admin Finalisasi 89557566\", \"location_name\": \"Lokasi Pemeriksaan UAT\", \"survey_result\": \"sound\", \"surveyor_name\": \"Surveyor Demo\", \"survey_type_id\": \"79589597-afe5-42ba-bd7d-e9d7df2f2c68\", \"job_container_id\": \"d52f27a5-6060-41f6-aaad-a9d3deaa837b\", \"survey_type_name\": \"Survey UAT\", \"current_revision_no\": 1}','2026-07-23 13:52:38.701678'),('3970efda-864e-11f1-a160-002b67818c25','e731d60b-b738-4a87-a168-ce5bca29a54b','{\"id\": \"293e4859-83eb-4e36-9ab5-48fbe2f33bbf\", \"status\": \"submitted\", \"survey_no\": \"GIFT-SVY-2026-000001\", \"approved_at\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"surveyor_id\": \"00000000-0000-0000-0000-000000000103\", \"container_no\": \"MSKU1234565\", \"job_order_id\": \"ba973397-9eee-4cf9-b987-9a2e4e727195\", \"job_order_no\": \"GIFT-JO-2026-000002\", \"submitted_at\": \"2026-07-23T04:23:15Z\", \"customer_name\": \"UAT Customer Scope 17B\", \"location_name\": \"Depot UAT 17B\", \"survey_result\": \"sound\", \"surveyor_name\": \"Surveyor Demo\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_container_id\": \"ef3108a3-5d1e-4832-af0b-eb174edc0675\", \"survey_type_name\": \"Survey UAT 17B\", \"current_revision_no\": 1}','2026-07-23 11:23:15.446868'),('d32c0347-9542-11f1-9595-002b67818c25','fddd4632-bc82-4a5a-9b5f-6e322c9263db','{\"id\": \"e2e00003-0000-4000-8000-000000000301\", \"status\": \"under_review\", \"survey_no\": \"UAT-SURVEY-2026-0805-003-A\", \"approved_at\": null, \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"rejected_at\": null, \"surveyor_id\": \"9ac88126-eacc-4256-8f8b-efd594725b10\", \"container_no\": \"BCKU2468102\", \"job_order_id\": \"e2e00003-0000-4000-8000-000000000001\", \"job_order_no\": \"UAT-JOB-2026-0805-003\", \"submitted_at\": \"2026-08-11T12:09:21Z\", \"customer_name\": \"UAT Customer Scope 17B\", \"location_name\": \"Depot UAT 17B\", \"survey_result\": \"damage\", \"surveyor_name\": \"Raka Pratama UAT\", \"resubmitted_at\": \"2026-08-11T12:09:25Z\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"job_container_id\": \"e2e00003-0000-4000-8000-000000000201\", \"survey_type_name\": \"Survey UAT 17B\", \"review_started_at\": \"2026-08-11T12:09:26Z\", \"current_reviewer_id\": \"24c54a64-a645-4f8f-9b87-40a20b31d6ce\", \"current_revision_no\": 1, \"current_reviewer_name\": \"Ardiansyah Wibowo UAT\"}','2026-08-11 12:09:26.845129');
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
INSERT INTO `report_versions` VALUES ('bc02e652-5bc1-4327-a6b2-86d323760f34','4878295a-2f23-46a5-a31d-b1cc2eede3fe',0,NULL,NULL,'draft','00000000-0000-0000-0000-000000000004','2026-07-23 13:52:38.698661'),('e731d60b-b738-4a87-a168-ce5bca29a54b','89575651-da80-4925-9e32-c0eca6df6ddd',0,NULL,NULL,'draft','00000000-0000-0000-0000-000000000004','2026-07-23 11:23:15.432934'),('fddd4632-bc82-4a5a-9b5f-6e322c9263db','3eb68746-dc8a-4f6a-afea-340b033e5418',1,NULL,NULL,'draft','24c54a64-a645-4f8f-9b87-40a20b31d6ce','2026-08-11 12:09:26.837886');
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
INSERT INTO `reports` VALUES ('3eb68746-dc8a-4f6a-afea-340b033e5418','GIFT-RPT-2026-000003','container_inspection_report','e2e00003-0000-4000-8000-000000000001','e2e00003-0000-4000-8000-000000000201','e2e00003-0000-4000-8000-000000000301','32aa190f-d0de-448d-b533-421da6e87ce9','pending_generation',1,NULL,0,'24c54a64-a645-4f8f-9b87-40a20b31d6ce','24c54a64-a645-4f8f-9b87-40a20b31d6ce',NULL,NULL,'24c54a64-a645-4f8f-9b87-40a20b31d6ce','2026-08-11 12:09:26.000000',NULL,NULL,'2026-08-11 12:09:26.831478','2026-08-11 12:09:26.831478'),('4878295a-2f23-46a5-a31d-b1cc2eede3fe','GIFT-RPT-2026-000002','container_inspection_report','9cb28aad-c5f8-4a6e-93c6-7718905972fe',NULL,'b3b96ed8-8308-4a83-af84-e5d488d1260e','1e95fb79-ee0d-41aa-b26a-99f07e50976c','pending_generation',0,'d3302659-454d-4f39-b5a3-285b6c66816f',1,'00000000-0000-0000-0000-000000000004',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-23 13:52:38.696236','2026-07-23 13:52:38.696236'),('89575651-da80-4925-9e32-c0eca6df6ddd','GIFT-RPT-2026-000001','container_inspection_report','ba973397-9eee-4cf9-b987-9a2e4e727195',NULL,'293e4859-83eb-4e36-9ab5-48fbe2f33bbf','32aa190f-d0de-448d-b533-421da6e87ce9','pending_generation',0,'1848bfc3-c3d3-4ba6-90f1-fde018db9810',1,'00000000-0000-0000-0000-000000000004',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-23 11:23:15.425282','2026-07-23 11:23:15.425282');
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
INSERT INTO `responsibility_codes` VALUES ('3f2fe18e-737f-11f1-ac50-002b67818c25',NULL,'C','Customer','Customer responsibility','active','2026-06-29 05:56:18.333391','2026-06-29 05:56:18.333391'),('3f2fe5c4-737f-11f1-ac50-002b67818c25',NULL,'O','Owner','Owner responsibility','active','2026-06-29 05:56:18.333391','2026-06-29 05:56:18.333391'),('3f2fe71a-737f-11f1-ac50-002b67818c25',NULL,'D','Depot','Depot responsibility','active','2026-06-29 05:56:18.333391','2026-06-29 05:56:18.333391'),('3f2fe80d-737f-11f1-ac50-002b67818c25',NULL,'T','Trucker','Trucker responsibility','active','2026-06-29 05:56:18.333391','2026-06-29 05:56:18.333391'),('3f2fe8f7-737f-11f1-ac50-002b67818c25',NULL,'U','Unknown','Unknown responsibility','active','2026-06-29 05:56:18.333391','2026-06-29 05:56:18.333391'),('6e244cb0-3287-4f4d-9be4-74ae9a59b640','cd0c0678-86f8-4f29-a44b-db12a4e481ec','RC89537506','Responsibility UAT','Data uji lokal','active','2026-07-23 13:52:18.150553','2026-07-23 13:52:18.150553'),('7bf864f9-91a4-4825-a3de-3c534c69e7e3','1e95fb79-ee0d-41aa-b26a-99f07e50976c','RC89557566','Responsibility UAT','Data uji lokal','active','2026-07-23 13:52:38.273808','2026-07-23 13:52:38.273808'),('8b067287-87f5-4a60-85fd-07770b885a3d','32aa190f-d0de-448d-b533-421da6e87ce9','RESP17B','Customer UAT','UAT','active','2026-07-17 16:56:33.992815','2026-07-17 16:56:33.992815'),('97b0c491-26b5-45d9-a79f-08b9aa304696','42aee823-b9d1-4788-9fd6-cdce2cb732f8','RCUAT-ISO-CEDEX-20260723115019','UAT Responsibility UAT-ISO-CEDEX-20260723115019','UAT','inactive','2026-07-23 11:50:19.827823','2026-07-23 11:50:20.000000'),('a2b618be-967b-41a6-8c82-23008363d1f5','1b36b739-2080-451a-9092-64b5b771167a','RCA0723110926','UAT Responsibility A0723110926','UAT','inactive','2026-07-23 11:09:26.873316','2026-07-23 11:09:27.000000'),('a638ef25-1cad-40f3-b012-6ae1b855bbe8','9eaabd4d-581a-4c1d-811a-4e3253300088','RCA0723110926','UAT Responsibility A0723110926','UAT','active','2026-07-23 11:09:26.881624','2026-07-23 11:09:26.881624'),('e080d7fe-ebfd-4496-9d0d-4ca247d52440','5d275989-b5f8-4f56-abb7-1e6cf8630449','RCUAT-ISO-CEDEX-20260723115019','UAT Responsibility UAT-ISO-CEDEX-20260723115019','UAT','active','2026-07-23 11:50:19.837285','2026-07-23 11:50:19.837285');
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
INSERT INTO `role_permissions` VALUES ('1b5330c1-9542-11f1-9595-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','3f278a4e-737f-11f1-ac50-002b67818c25','2026-08-11 12:04:18.399952'),('1b761872-9542-11f1-9595-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','40a3aee5-737f-11f1-ac50-002b67818c25','2026-08-11 12:04:18.629114'),('1b761e8b-9542-11f1-9595-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','bb3770dd-751e-11f1-8fe5-002b67818c25','2026-08-11 12:04:18.629114'),('39fe7c38-8bf8-11f1-9154-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','39fdcb91-8bf8-11f1-9154-002b67818c25','2026-07-30 16:22:46.630799'),('39feb0f7-8bf8-11f1-9154-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','39fdcb91-8bf8-11f1-9154-002b67818c25','2026-07-30 16:22:46.630799'),('39feb342-8bf8-11f1-9154-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','39fd3973-8bf8-11f1-9154-002b67818c25','2026-07-30 16:22:46.630799'),('39feb47b-8bf8-11f1-9154-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','39fd3973-8bf8-11f1-9154-002b67818c25','2026-07-30 16:22:46.630799'),('39ff47e5-8bf8-11f1-9154-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','39fd3973-8bf8-11f1-9154-002b67818c25','2026-07-30 16:22:46.637337'),('39ff4c48-8bf8-11f1-9154-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','39fd3973-8bf8-11f1-9154-002b67818c25','2026-07-30 16:22:46.637337'),('3f282f02-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','3f277c21-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f2838e0-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278d74-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f283cf7-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278b9f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f284008-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278768-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f28472b-737f-11f1-ac50-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','3f278f3f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f284bbe-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278f3f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f285003-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278858-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f285c0a-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278e50-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f285f5a-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f278c8d-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f2862e9-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f27896c-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.282290'),('3f4365df-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42a80d-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3f436a4b-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42a903-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3f436c3a-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42a715-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3f436dd0-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42aaef-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3f436f85-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42a9ed-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3f437cda-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42abe3-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3f438189-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3f42acea-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.461229'),('3fa6b037-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa61c4b-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6b4d1-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa6149e-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6b6ba-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa617a5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6b889-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa61581-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6ba78-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa6188d-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6bc2d-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa616b5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6bd98-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa613ad-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('3fa6bef4-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','3fa612c5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:19.111593'),('403f8288-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40379102-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403f85d8-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40379102-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403f8ca9-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','403794be-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403f8f32-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','403794be-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403f95f7-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','403792f7-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403f9886-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','403792f7-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403f9f41-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40378ed5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fa1b3-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40378ed5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fa8d5-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4037966f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fabd9-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4037966f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fb49c-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40379833-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fb8ca-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40379833-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fc4da-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40377bc2-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fc8fe-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40377bc2-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fd3eb-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40378930-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fd709-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40378930-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fe088-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40378d25-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403fe729-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40378d25-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403ff050-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40378b20-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('403ff2f8-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40378b20-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('404041de-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40378673-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('404045ba-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40378673-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.113192'),('40a46ac5-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40a3b923-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a46df0-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40a3b923-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a4742e-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40a3bb17-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a4774e-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40a3bb17-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a47d3f-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40a3b75d-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a47fe9-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40a3b75d-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a485ad-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40a3b4bb-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a48e62-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40a3aee5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a490aa-737f-11f1-ac50-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','40a3aee5-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.774021'),('40a549f9-737f-11f1-ac50-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','40a3b75d-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:20.780876'),('40fa9a26-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40f9e90f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:21.339139'),('40faaa6a-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40f9e5e6-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:21.339139'),('40fab1bd-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40f9eb1b-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:21.339139'),('40fab7f1-737f-11f1-ac50-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','40f9de5e-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:21.339139'),('40fb6995-737f-11f1-ac50-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','40f9de5e-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:21.345000'),('4834b32a-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483202c5-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4834f1b6-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320221-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4834f375-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320000-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48350c7f-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831ff58-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48350dec-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48318cc3-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48350f2d-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831711a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351066-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831fd54-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351186-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831fcae-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4835128c-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f927-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483513cf-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f81d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483514e0-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320163-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483515f0-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483200b5-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351705-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48318f9d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351873-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48318ebf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483519a6-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320ca2-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351abb-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320bf9-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351bd2-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483205a3-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351cff-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483204eb-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351e28-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831fbdf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48351f3f-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831fb21-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48352065-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4832043a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48352188-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4832037e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4835229a-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48324a72-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483523bd-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48324868-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483524e6-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483206fd-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4835260a-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4832064f-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4835272a-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320b44-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('4835283a-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','48320a97-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48352991-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f454-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48352aab-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f39b-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48352bc8-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831feaf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48352db1-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831fdfc-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483534cc-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831fa7e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48353696-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f9d7-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48353864-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f29a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48353a42-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f158-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48353c02-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483209ef-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48353dde-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4832093b-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48353fab-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f5d2-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48354197-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f50d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48354317-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f72e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48354499-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4831f67e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48354603-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','4832086c-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('48354729-79e5-11f1-a1f6-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','483207b3-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.105372'),('483758e7-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','483202c5-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48375e01-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48320221-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48375f4e-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48320000-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('4837606e-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831ff58-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483761a9-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48318cc3-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483762c4-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831711a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483763ca-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831fd54-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483764d1-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831fcae-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483765d2-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f927-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483766ef-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f81d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483767fa-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48320163-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48376919-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','483200b5-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48376a29-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48318f9d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48376b30-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48318ebf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48376e29-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','483205a3-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48376f48-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','483204eb-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('4837705d-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831fbdf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('4837716d-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831fb21-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377286-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4832043a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377396-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4832037e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('4837749d-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48324a72-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483775cb-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','48324868-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377704-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f454-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377800-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f39b-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377901-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831feaf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377a02-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831fdfc-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377b1e-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831fa7e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377c30-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f9d7-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377d2c-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f29a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377e5b-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f158-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48377f57-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','483209ef-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48378051-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4832093b-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('4837814d-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f5d2-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48378244-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f50d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48378343-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f72e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('48378456-79e5-11f1-a1f6-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','4831f67e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.125128'),('483deba3-79e5-11f1-a1f6-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','483206fd-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.168251'),('483df426-79e5-11f1-a1f6-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','4832086c-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.168251'),('48409ddb-79e5-11f1-a1f6-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','48320bf9-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.185987'),('4840a37e-79e5-11f1-a1f6-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','48324868-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.185987'),('4840a4fc-79e5-11f1-a1f6-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','4832064f-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.185987'),('4840a629-79e5-11f1-a1f6-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','48320b44-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.185987'),('4840a784-79e5-11f1-a1f6-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','48320a97-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.185987'),('48435caf-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','48320221-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48436392-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831ff58-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484365b9-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831711a-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484369a7-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831fcae-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48436beb-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831f81d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48436d75-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','483200b5-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48436f19-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','48318ebf-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('4843708c-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','48320bf9-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484371db-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','483204eb-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48437337-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831fb21-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('4843d6a1-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4832037e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('4843d8ac-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','48324868-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('4843d9f6-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4832064f-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('4843db2d-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','48320a97-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('4843dc64-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831f39b-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48440236-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831fdfc-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('48440393-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831f9d7-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484404a0-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831f158-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484405c4-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4832093b-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484406ec-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831f50d-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484407f8-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','4831f67e-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('484408ff-79e5-11f1-a1f6-002b67818c25','3f26bccb-737f-11f1-ac50-002b67818c25','483207b3-79e5-11f1-a1f6-002b67818c25','2026-07-07 16:21:49.203882'),('77af693e-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77af1fd4-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77af7e1f-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77af1fd4-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77af809a-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77af2197-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77af8410-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77af2197-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77af8b33-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77af20dc-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77af8c51-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77af20dc-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b01ab0-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77af23f5-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b01cf9-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77af23f5-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b01fef-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77af3122-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02281-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77af3122-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0241d-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77af2f98-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02535-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77af2f98-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02b17-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aee013-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02c27-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aee013-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02d8e-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aee1de-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02e78-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aee1de-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b02fd7-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aee108-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b03154-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aee108-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b03655-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aec591-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b03763-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aec591-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b039ba-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aec766-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b03add-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aec766-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b03c40-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aec696-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b03db0-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aec696-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b042aa-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aecea0-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b04395-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aecea0-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b045a8-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aed0a4-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0469b-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aed0a4-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b047f8-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aecfd0-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b04a14-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aecfd0-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b04fc8-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77ae7c50-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b050d7-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77ae7c50-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05220-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77ae9586-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b052f5-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77ae9586-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05433-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77ae946c-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0551d-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77ae946c-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05a09-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aee477-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05af6-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aee477-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05c3a-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aee622-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05d15-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aee622-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05e68-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aee54c-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b05f41-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aee54c-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b06455-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aeca1f-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b06540-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aeca1f-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b06697-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aecbf0-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0676e-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aecbf0-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b06a8a-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aecb21-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b06b6f-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aecb21-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b08d9e-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77ad877b-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b08ebc-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77ad877b-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09158-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77adcbbe-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0923a-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77adcbbe-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09404-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77adc91d-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b094f3-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77adc91d-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09a09-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77ae98e7-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09afe-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77ae98e7-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09c4a-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aea080-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09d34-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aea080-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09e83-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77ae9f69-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b09f68-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77ae9f69-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0a44a-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aea46e-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0a561-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aea46e-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0a6b4-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aea9c5-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0a79b-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aea9c5-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0a8e7-7a83-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','77aea8e3-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('77b0a9d4-7a83-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','77aea8e3-7a83-11f1-ab0b-002b67818c25','2026-07-08 11:14:09.247341'),('84980f0f-7456-11f1-806f-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','84947ba5-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.575296'),('84981fef-7456-11f1-806f-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','84955473-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.575296'),('8498219e-7456-11f1-806f-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','8495581a-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.575296'),('84982331-7456-11f1-806f-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','849558e0-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.575296'),('8498248f-7456-11f1-806f-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','84955622-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.575296'),('849a6e56-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','84947ba5-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('849a72a9-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','84955473-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('849a73ee-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','8495581a-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('849a7614-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','849558e0-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('849a77c8-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','8495577e-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('849a78ef-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','84955622-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('849a7a05-7456-11f1-806f-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','849556d7-7456-11f1-806f-002b67818c25','2026-06-30 14:37:16.591657'),('86c82651-8be7-11f1-9154-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','86c6b216-8be7-11f1-9154-002b67818c25','2026-07-30 14:23:14.016038'),('86c87f75-8be7-11f1-9154-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','86c6b216-8be7-11f1-9154-002b67818c25','2026-07-30 14:23:14.016038'),('86c8840d-8be7-11f1-9154-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','86c6b216-8be7-11f1-9154-002b67818c25','2026-07-30 14:23:14.016038'),('86c893f4-8be7-11f1-9154-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','86c6b216-8be7-11f1-9154-002b67818c25','2026-07-30 14:23:14.016038'),('b42347c3-751e-11f1-8fe5-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','40a3b923-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.687365'),('b4235107-751e-11f1-8fe5-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','40a3bb17-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.687365'),('b42355eb-751e-11f1-8fe5-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','40a3b75d-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.687365'),('b42359ee-751e-11f1-8fe5-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','40a3b4bb-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.687365'),('b4235d2f-751e-11f1-8fe5-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','40a3aee5-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.687365'),('b4283720-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','3f429301-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4283b46-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','3f429730-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4283d67-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','3f428d2c-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4283f46-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','3f429f1b-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4284851-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','3f429b59-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4284a6a-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','3f42a2cb-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4284c33-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40379102-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4284e09-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','403794be-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4284fe3-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','403792f7-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b42851c7-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40378ed5-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b428574e-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','4037966f-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4285966-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40379833-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4285b99-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40377bc2-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4285fe1-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40378930-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b42864c5-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40378d25-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b42867ae-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40378b20-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b4286ae2-751e-11f1-8fe5-002b67818c25','3f26b8df-737f-11f1-ac50-002b67818c25','40378673-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.719664'),('b42d39d2-751e-11f1-8fe5-002b67818c25','3f26bb58-737f-11f1-ac50-002b67818c25','40f9e90f-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.752531'),('b42d3e08-751e-11f1-8fe5-002b67818c25','3f26bb58-737f-11f1-ac50-002b67818c25','40f9e5e6-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.752531'),('b42d401e-751e-11f1-8fe5-002b67818c25','3f26bb58-737f-11f1-ac50-002b67818c25','40f9eb1b-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.752531'),('b42d41f9-751e-11f1-8fe5-002b67818c25','3f26bb58-737f-11f1-ac50-002b67818c25','40f9de5e-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.752531'),('b42d43fe-751e-11f1-8fe5-002b67818c25','3f26bb58-737f-11f1-ac50-002b67818c25','40a3b75d-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:15.752531'),('baf3dc1b-7a77-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','baf0ca5c-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf3f875-7a77-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','baf0ca5c-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf3fafe-7a77-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','baf1ab1d-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf3fc16-7a77-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','baf1ab1d-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf3fdab-7a77-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','baf1a831-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf3fed6-7a77-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','baf1a831-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf4002e-7a77-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','baf1accf-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf40136-7a77-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','baf1accf-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf402a4-7a77-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','baf1aee0-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf403e7-7a77-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','baf1aee0-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf47cbc-7a77-11f1-ab0b-002b67818c25','3f26a41f-737f-11f1-ac50-002b67818c25','baf1ae00-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('baf47e54-7a77-11f1-ab0b-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','baf1ae00-7a77-11f1-ab0b-002b67818c25','2026-07-08 09:50:08.129698'),('bb3d4e77-751e-11f1-8fe5-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','bb3770dd-751e-11f1-8fe5-002b67818c25','2026-07-01 14:30:27.600531'),('bb3d510e-751e-11f1-8fe5-002b67818c25','3f26b6a0-737f-11f1-ac50-002b67818c25','849556d7-7456-11f1-806f-002b67818c25','2026-07-01 14:30:27.600531'),('bf5804b1-75f6-11f1-9f38-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','3f278f3f-737f-11f1-ac50-002b67818c25','2026-07-02 16:16:45.781230'),('bf5857be-75f6-11f1-9f38-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','bb3770dd-751e-11f1-8fe5-002b67818c25','2026-07-02 16:16:45.781230'),('bf5ebefb-75f6-11f1-9f38-002b67818c25','3f26bb58-737f-11f1-ac50-002b67818c25','3f278f3f-737f-11f1-ac50-002b67818c25','2026-07-02 16:16:45.825328'),('e311b0f6-75c3-11f1-9f38-002b67818c25','3f26ba11-737f-11f1-ac50-002b67818c25','40379833-737f-11f1-ac50-002b67818c25','2026-07-02 10:12:41.384461');
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
INSERT INTO `roles` VALUES ('3f26a41f-737f-11f1-ac50-002b67818c25','super_admin','Super Admin','Highest system administrator',1,'2026-06-29 05:56:18.271615','2026-06-29 05:56:18.271615'),('3f26b6a0-737f-11f1-ac50-002b67818c25','admin','Admin / Operasional','Operational admin for master data and jobs',1,'2026-06-29 05:56:18.271615','2026-06-29 05:56:18.271615'),('3f26b8df-737f-11f1-ac50-002b67818c25','surveyor','Surveyor','Survey field user',1,'2026-06-29 05:56:18.271615','2026-06-29 05:56:18.271615'),('3f26ba11-737f-11f1-ac50-002b67818c25','supervisor','Supervisor / Approver','Survey reviewer and approver',1,'2026-06-29 05:56:18.271615','2026-06-29 05:56:18.271615'),('3f26bb58-737f-11f1-ac50-002b67818c25','finance','Finance','Finance and billing user',1,'2026-06-29 05:56:18.271615','2026-06-29 05:56:18.271615'),('3f26bccb-737f-11f1-ac50-002b67818c25','management','Management','Read-only dashboard and recap user',1,'2026-06-29 05:56:18.271615','2026-06-29 05:56:18.271615');
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
INSERT INTO `structural_components` VALUES ('481afb0b-79e5-11f1-a1f6-002b67818c25','top_side_rail','Top Side Rail','4816874d-79e5-11f1-a1f6-002b67818c25',1,NULL,10,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b0ca1-79e5-11f1-a1f6-002b67818c25','bottom_side_rail','Bottom Side Rail','481688cc-79e5-11f1-a1f6-002b67818c25',1,NULL,20,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b100a-79e5-11f1-a1f6-002b67818c25','header','Header','481685b8-79e5-11f1-a1f6-002b67818c25',1,NULL,30,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b11f3-79e5-11f1-a1f6-002b67818c25','sill','Sill','48168684-79e5-11f1-a1f6-002b67818c25',1,NULL,40,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b13f3-79e5-11f1-a1f6-002b67818c25','corner_post','Corner Post','4816899b-79e5-11f1-a1f6-002b67818c25',1,NULL,50,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b15d2-79e5-11f1-a1f6-002b67818c25','corner_fitting','Corner Fitting','4816899b-79e5-11f1-a1f6-002b67818c25',1,NULL,60,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b17ea-79e5-11f1-a1f6-002b67818c25','intermediate_fitting','Intermediate Fitting','4816899b-79e5-11f1-a1f6-002b67818c25',1,NULL,70,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b1a55-79e5-11f1-a1f6-002b67818c25','cross_member','Cross Member','481688cc-79e5-11f1-a1f6-002b67818c25',1,NULL,80,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b1c58-79e5-11f1-a1f6-002b67818c25','understructure','Understructure','481688cc-79e5-11f1-a1f6-002b67818c25',1,NULL,90,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b1e4d-79e5-11f1-a1f6-002b67818c25','floor','Floor','48168812-79e5-11f1-a1f6-002b67818c25',0,NULL,100,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b200c-79e5-11f1-a1f6-002b67818c25','roof','Roof','4816874d-79e5-11f1-a1f6-002b67818c25',0,NULL,110,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b2222-79e5-11f1-a1f6-002b67818c25','side_wall','Side Wall','48167e70-79e5-11f1-a1f6-002b67818c25',0,NULL,120,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b23ff-79e5-11f1-a1f6-002b67818c25','end_wall','End Wall','481685b8-79e5-11f1-a1f6-002b67818c25',0,NULL,130,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b25d4-79e5-11f1-a1f6-002b67818c25','door_panel','Door Panel','48168684-79e5-11f1-a1f6-002b67818c25',0,NULL,140,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b27b5-79e5-11f1-a1f6-002b67818c25','door_locking_rod','Door Locking Rod','48168684-79e5-11f1-a1f6-002b67818c25',1,NULL,150,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298'),('481b2994-79e5-11f1-a1f6-002b67818c25','csc_safety_approval_plate','CSC Safety Approval Plate','48168a4f-79e5-11f1-a1f6-002b67818c25',1,NULL,160,'active','2026-07-07 16:21:48.934298','2026-07-07 16:21:48.934298');
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
INSERT INTO `structural_damage_criteria` VALUES ('481e65eb-79e5-11f1-a1f6-002b67818c25','dent','Dent','Penyok pada komponen peti kemas.',NULL,'minor',0,0,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e6f50-79e5-11f1-a1f6-002b67818c25','crack','Crack','Retak pada komponen peti kemas.',NULL,'major',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e7201-79e5-11f1-a1f6-002b67818c25','hole','Hole','Lubang pada komponen peti kemas.',NULL,'major',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e7372-79e5-11f1-a1f6-002b67818c25','broken','Broken','Komponen patah atau rusak berat.',NULL,'critical',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e74dd-79e5-11f1-a1f6-002b67818c25','bent','Bent','Komponen bengkok atau berubah bentuk.',NULL,'major',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e7677-79e5-11f1-a1f6-002b67818c25','missing','Missing','Komponen hilang.',NULL,'critical',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e785b-79e5-11f1-a1f6-002b67818c25','corrosion','Corrosion','Korosi pada komponen.',NULL,'minor',0,0,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e79c0-79e5-11f1-a1f6-002b67818c25','severe_corrosion','Severe Corrosion','Korosi berat pada komponen.',NULL,'critical',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e7e2e-79e5-11f1-a1f6-002b67818c25','loose_locking_rod','Loose Locking Rod','Locking rod longgar.','481b27b5-79e5-11f1-a1f6-002b67818c25','major',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e81d9-79e5-11f1-a1f6-002b67818c25','csc_plate_missing','CSC Plate Missing','Plate persetujuan keselamatan tidak ada.','481b2994-79e5-11f1-a1f6-002b67818c25','critical',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e851e-79e5-11f1-a1f6-002b67818c25','csc_plate_unreadable','CSC Plate Unreadable','Plate persetujuan keselamatan tidak terbaca.','481b2994-79e5-11f1-a1f6-002b67818c25','major',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e86f8-79e5-11f1-a1f6-002b67818c25','deformation_affecting_structure','Deformation Affecting Structure','Deformasi yang memengaruhi struktur.',NULL,'critical',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475'),('481e8879-79e5-11f1-a1f6-002b67818c25','watertightness_failure','Watertightness Failure','Kegagalan kedap air.',NULL,'major',1,1,NULL,'active','2026-07-07 16:21:48.957475','2026-07-07 16:21:48.957475');
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
INSERT INTO `survey_approvals` VALUES ('085a35cb-d210-4936-96ec-6ed35fafd67f','b3b96ed8-8308-4a83-af84-e5d488d1260e','00000000-0000-0000-0000-000000000004','need_revision','Lengkapi verifikasi UAT',NULL,1,'2026-07-23 13:52:38.654102','2026-07-23 13:52:38.654102'),('17f33daf-8663-11f1-a160-002b67818c25','b3b96ed8-8308-4a83-af84-e5d488d1260e','00000000-0000-0000-0000-000000000004','approved','Approved UAT','sound',1,'2026-07-23 13:52:38.689692','2026-07-23 13:52:38.689692'),('18002f2a-8663-11f1-a160-002b67818c25','5905e03b-cc89-45cd-a99a-94f57871239c','00000000-0000-0000-0000-000000000004','rejected','Skenario reject UAT',NULL,0,'2026-07-23 13:52:38.774516','2026-07-23 13:52:38.774516'),('20ee5cf5-9542-11f1-9595-002b67818c25','e2e00002-0000-4000-8000-000000000202','24c54a64-a645-4f8f-9b87-40a20b31d6ce','approved','Fixture terminal UAT','cargo_worthy',0,'2026-08-05 10:00:00.000000','2026-08-11 12:04:27.806793'),('20f23502-9542-11f1-9595-002b67818c25','e2e00003-0000-4000-8000-000000000302','24c54a64-a645-4f8f-9b87-40a20b31d6ce','approved','Fixture terminal UAT','cargo_worthy',0,'2026-08-05 10:00:00.000000','2026-08-11 12:04:27.831966'),('396cd8a0-864e-11f1-a160-002b67818c25','293e4859-83eb-4e36-9ab5-48fbe2f33bbf','00000000-0000-0000-0000-000000000004','approved','UAT-ISO-CEDEX-20260723112314 synthetic approve','fit',1,'2026-07-23 11:23:15.420147','2026-07-23 11:23:15.420147'),('398dd893-864e-11f1-a160-002b67818c25','724d3aea-49fb-41de-82ce-05d35a394925','00000000-0000-0000-0000-000000000004','rejected','UAT-ISO-CEDEX-20260723112314 synthetic reject',NULL,0,'2026-07-23 11:23:15.636394','2026-07-23 11:23:15.636394'),('879bcc0e-48d1-45ae-84a7-17d566c795f1','293e4859-83eb-4e36-9ab5-48fbe2f33bbf','00000000-0000-0000-0000-000000000004','need_revision','UAT ISO CEDEX synthetic need revision',NULL,1,'2026-07-23 11:21:45.857565','2026-07-23 11:21:45.857565'),('9ba37c6e-0287-4104-a1cb-6d3ef01c8fae','e2e00003-0000-4000-8000-000000000301','24c54a64-a645-4f8f-9b87-40a20b31d6ce','need_revision','UAT revisi bertarget survey.',NULL,1,'2026-08-11 12:09:23.602795','2026-08-11 12:09:23.602795'),('d32748dd-9542-11f1-9595-002b67818c25','e2e00003-0000-4000-8000-000000000301','24c54a64-a645-4f8f-9b87-40a20b31d6ce','approved','Disetujui pada UAT real-case.','cargo_worthy',1,'2026-08-11 12:09:26.814217','2026-08-11 12:09:26.814217'),('d61f09ab-9542-11f1-9595-002b67818c25','e2e00002-0000-4000-8000-000000000201','24c54a64-a645-4f8f-9b87-40a20b31d6ce','rejected','Ditolak untuk pembuktian cabang UAT.',NULL,0,'2026-08-11 12:09:31.793318','2026-08-11 12:09:31.793318');
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
INSERT INTO `survey_checklist_responses` VALUES ('0be2d70a-8663-11f1-a160-002b67818c25','3bde18bd-5822-4531-8e90-ba16f508c162','c94111b5-592a-4334-9d24-085933082e45','IT89537506','Kondisi umum sesuai',NULL,NULL,NULL,'yes_no',NULL,NULL,1,0,0,NULL,1,'2026-07-23 13:52:18.449353','2026-07-23 13:52:18.449353'),('0be6c4e9-8663-11f1-a160-002b67818c25','c8cfacf2-cacf-43de-91a5-57c7bcb5c1d7','c94111b5-592a-4334-9d24-085933082e45','IT89537506','Kondisi umum sesuai',NULL,NULL,NULL,'yes_no',NULL,NULL,1,0,0,NULL,1,'2026-07-23 13:52:18.475048','2026-07-23 13:52:18.475048'),('17d4700d-8663-11f1-a160-002b67818c25','b3b96ed8-8308-4a83-af84-e5d488d1260e','5665a85b-983b-4764-b230-d698bd4f3ae5','IT89557566','Kondisi umum sesuai','yes',NULL,'UAT','yes_no',NULL,NULL,1,0,0,NULL,1,'2026-07-23 13:52:38.487628','2026-07-23 13:52:38.000000'),('17d7a2aa-8663-11f1-a160-002b67818c25','5905e03b-cc89-45cd-a99a-94f57871239c','5665a85b-983b-4764-b230-d698bd4f3ae5','IT89557566','Kondisi umum sesuai','yes',NULL,'UAT','yes_no',NULL,NULL,1,0,0,NULL,1,'2026-07-23 13:52:38.508611','2026-07-23 13:52:38.000000'),('3981b1bd-864e-11f1-a160-002b67818c25','724d3aea-49fb-41de-82ce-05d35a394925','3798b4be-809c-4ddf-949d-426833064328','ITMF0723111302','UAT Checklist Item F0723111302','ok',NULL,'UAT-ISO-CEDEX-20260723112314-REJECT checklist','ok_not_ok',NULL,NULL,1,0,0,NULL,1,'2026-07-23 11:23:15.556672','2026-07-23 11:23:15.000000'),('3c91a551-8652-11f1-a160-002b67818c25','829ea486-456b-44e3-883d-5cc97b7c6dc9','3798b4be-809c-4ddf-949d-426833064328','ITMF0723111302','UAT Checklist Item F0723111302',NULL,NULL,NULL,'ok_not_ok',NULL,NULL,1,0,0,NULL,1,'2026-07-23 11:51:58.680127','2026-07-23 11:51:58.680127'),('4679e434-85c2-487f-a9b3-0501d452bcec','e2e00002-0000-4000-8000-000000000202','3798b4be-809c-4ddf-949d-426833064328','ITMF0723111302','UAT Checklist Item F0723111302','yes',NULL,NULL,'ok_not_ok',NULL,NULL,1,0,0,NULL,1,'2026-08-11 12:04:27.803986','2026-08-11 12:04:27.803986'),('a80014a4-1a41-4279-8206-be9f1ada419d','e2e00003-0000-4000-8000-000000000302','3798b4be-809c-4ddf-949d-426833064328','ITMF0723111302','UAT Checklist Item F0723111302','yes',NULL,NULL,'ok_not_ok',NULL,NULL,1,0,0,NULL,1,'2026-08-11 12:04:27.830176','2026-08-11 12:04:27.830176'),('b176fa7d-cd1a-4b35-b52a-e97878435475','e2e00002-0000-4000-8000-000000000201','3798b4be-809c-4ddf-949d-426833064328','ITMF0723111302','UAT Checklist Item F0723111302','yes',NULL,NULL,'ok_not_ok',NULL,NULL,1,0,0,NULL,1,'2026-08-11 12:04:27.798612','2026-08-11 12:04:27.798612'),('cd19fb8b-9542-11f1-9595-002b67818c25','749164da-9dcf-478c-be1c-973291e46176','3798b4be-809c-4ddf-949d-426833064328','ITMF0723111302','UAT Checklist Item F0723111302',NULL,NULL,NULL,'ok_not_ok',NULL,NULL,1,0,0,NULL,1,'2026-08-11 12:09:16.660028','2026-08-11 12:09:16.660028'),('d9f9e35a-864c-11f1-a160-002b67818c25','293e4859-83eb-4e36-9ab5-48fbe2f33bbf','3798b4be-809c-4ddf-949d-426833064328','ITMF0723111302','UAT Checklist Item F0723111302','ok',NULL,'UAT-ISO-CEDEX-20260723112314-APPROVE checklist','ok_not_ok',NULL,NULL,1,0,0,NULL,1,'2026-07-23 11:13:25.786327','2026-07-23 11:23:15.000000'),('e2e00004-0000-4000-8000-000000000501','e2e00004-0000-4000-8000-000000000401','e2e00004-0000-4000-8000-000000000060','UAT-ISO-ITEM','Item Isolation UAT','yes',NULL,NULL,'ok_not_ok',NULL,NULL,1,0,0,NULL,1,'2026-08-11 12:04:27.845482','2026-08-11 12:04:27.845482'),('fbbcd20f-5aef-4b92-8c25-e857bd135d14','e2e00003-0000-4000-8000-000000000301','3798b4be-809c-4ddf-949d-426833064328','ITMF0723111302','UAT Checklist Item F0723111302','no',NULL,NULL,'ok_not_ok',NULL,NULL,1,0,0,NULL,1,'2026-08-11 12:04:27.814856','2026-08-11 12:04:27.814856');
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
  PRIMARY KEY (`survey_id`),
  CONSTRAINT `fk_survey_damage_counters_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_damage_counters`
--

LOCK TABLES `survey_damage_counters` WRITE;
/*!40000 ALTER TABLE `survey_damage_counters` DISABLE KEYS */;
INSERT INTO `survey_damage_counters` VALUES ('829ea486-456b-44e3-883d-5cc97b7c6dc9',1,'2026-07-23 11:55:16.000000'),('b3b96ed8-8308-4a83-af84-e5d488d1260e',1,'2026-07-23 13:52:38.000000'),('e2e00003-0000-4000-8000-000000000301',1,'2026-08-11 12:04:27.822345');
/*!40000 ALTER TABLE `survey_damage_counters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `survey_damage_followups`
--

DROP TABLE IF EXISTS `survey_damage_followups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `survey_damage_followups` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `original_damage_id` char(36) NOT NULL,
  `followup_no` int NOT NULL DEFAULT '1',
  `status` varchar(50) NOT NULL DEFAULT 'waiting_external_repair',
  `external_party_name` varchar(180) DEFAULT NULL,
  `external_repair_note` text,
  `external_repair_reported_at` datetime(6) DEFAULT NULL,
  `reinspection_survey_id` char(36) DEFAULT NULL,
  `result` varchar(50) NOT NULL DEFAULT 'pending',
  `decision_note` text,
  `created_by` char(36) DEFAULT NULL,
  `updated_by` char(36) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_survey_damage_followups_round` (`original_damage_id`,`followup_no`),
  KEY `idx_survey_damage_followups_status` (`status`),
  KEY `idx_survey_damage_followups_reinspection` (`reinspection_survey_id`),
  KEY `idx_survey_damage_followups_created_by` (`created_by`),
  KEY `idx_survey_damage_followups_updated_by` (`updated_by`),
  CONSTRAINT `fk_survey_damage_followups_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_survey_damage_followups_damage` FOREIGN KEY (`original_damage_id`) REFERENCES `survey_damages` (`id`),
  CONSTRAINT `fk_survey_damage_followups_reinspection` FOREIGN KEY (`reinspection_survey_id`) REFERENCES `surveys` (`id`),
  CONSTRAINT `fk_survey_damage_followups_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_damage_followups`
--

LOCK TABLES `survey_damage_followups` WRITE;
/*!40000 ALTER TABLE `survey_damage_followups` DISABLE KEYS */;
/*!40000 ALTER TABLE `survey_damage_followups` ENABLE KEYS */;
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
  `decision_result` varchar(50) DEFAULT NULL,
  `decision_reason` text,
  `tolerance_snapshot` json DEFAULT NULL,
  `finding_description` text,
  `finding_status` varchar(30) NOT NULL DEFAULT 'open',
  `decision_evaluated_at` datetime(6) DEFAULT NULL,
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
  `dimension_profile` varchar(30) DEFAULT NULL,
  `location_selection_snapshot` json DEFAULT NULL,
  `checklist_response_id` char(36) DEFAULT NULL,
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
  KEY `idx_survey_damages_decision_result` (`decision_result`),
  KEY `idx_survey_damages_finding_status` (`finding_status`),
  KEY `idx_survey_damages_checklist_response` (`checklist_response_id`),
  KEY `idx_survey_damages_recommended_action` (`recommended_action_id`),
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
INSERT INTO `survey_damages` VALUES ('43a36e7d-5d9c-464f-833d-1f5b6b925faa','b3b96ed8-8308-4a83-af84-e5d488d1260e','D-001','left','L1','876c2246-4992-4fd2-a749-3d223f4c9e6f',NULL,'72120964-15d2-493b-9794-b7f85560c39d','003fc685-001a-40c2-9455-d6f5c0df6c2d','dd311dc0-d26c-450f-bdac-22848504252f','2e96b899-49a5-49d6-927a-1c7fe096e0e0','7bf864f9-91a4-4825-a3de-3c534c69e7e3',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'open',NULL,'sv89557566',1,NULL,NULL,NULL,NULL,'cm',1,0,0,'Damage updated UAT','00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000003','2026-07-23 13:52:38.549528','2026-07-23 13:52:38.000000','2026-07-23 13:52:38.000000',NULL,NULL,NULL),('7d952d90-6b58-439d-b117-3df03f38f226','829ea486-456b-44e3-883d-5cc97b7c6dc9','D-001','left','L1','671b9126-54cd-4d03-8724-edc95506a0ad',NULL,'0c4b9c89-45b0-4bc0-9af7-2d2f720112df','99658a84-c385-4e6c-a264-4a5f357ec7eb','c124aa17-7f13-48d5-a75c-4b423916ccae','bc716703-acf5-44c2-9a78-1f6deb3e1f73','8b067287-87f5-4a60-85fd-07770b885a3d',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'open',NULL,'minor',1,NULL,1.00,1.00,0.10,'cm',0,0,0,'UAT-ISO-CEDEX-20260723115158-DAMAGE-UPDATED','00000000-0000-0000-0000-000000000003','00000000-0000-0000-0000-000000000003','2026-07-23 11:55:16.254969','2026-07-23 11:55:42.000000','2026-07-23 11:55:42.000000',NULL,NULL,NULL),('e2e00003-0000-4000-8000-000000000601','e2e00003-0000-4000-8000-000000000301','D-001','left','L1','671b9126-54cd-4d03-8724-edc95506a0ad',NULL,'0c4b9c89-45b0-4bc0-9af7-2d2f720112df','99658a84-c385-4e6c-a264-4a5f357ec7eb','c124aa17-7f13-48d5-a75c-4b423916ccae','bc716703-acf5-44c2-9a78-1f6deb3e1f73','8b067287-87f5-4a60-85fd-07770b885a3d',NULL,NULL,NULL,NULL,NULL,NULL,'Temuan UAT pada panel kiri','open',NULL,'minor',NULL,NULL,NULL,NULL,NULL,'cm',1,0,0,'UAT-REAL-CASE-2026-08','8d94550e-df85-4ccf-9b87-f6717f61cccf','8d94550e-df85-4ccf-9b87-f6717f61cccf','2026-08-11 12:04:27.819941','2026-08-11 12:04:27.819941',NULL,NULL,'{\"code\": \"L17B\", \"face\": \"left\", \"grid_code\": \"L1\", \"input_mode\": \"manual\", \"container_size\": \"20\"}','fbbcd20f-5aef-4b92-8c25-e857bd135d14');
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
  CONSTRAINT `fk_survey_general_infos_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_survey_general_infos_lifecycle` CHECK (((`container_lifecycle` is null) or (`container_lifecycle` in (_utf8mb4'new',_utf8mb4'existing'))))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_general_infos`
--

LOCK TABLES `survey_general_infos` WRITE;
/*!40000 ALTER TABLE `survey_general_infos` DISABLE KEYS */;
INSERT INTO `survey_general_infos` VALUES ('0be2437c-8663-11f1-a160-002b67818c25','3bde18bd-5822-4531-8e90-ba16f508c162','TSTU9537506','a49affc2-b9d4-497d-a617-d25fd1d68300','22G1','cd0c0678-86f8-4f29-a44b-db12a4e481ec','a55a583c-7dbf-4e18-b255-f41c5d82e445','2026-07-23 13:52:18.445618','empty','SEAL-89537506','B 1000 UAT','Driver UAT',NULL,'valid',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-23 13:52:18.445618','2026-07-23 13:52:18.445618'),('0be68f6a-8663-11f1-a160-002b67818c25','c8cfacf2-cacf-43de-91a5-57c7bcb5c1d7','TSTU9537507','a49affc2-b9d4-497d-a617-d25fd1d68300','22G1','cd0c0678-86f8-4f29-a44b-db12a4e481ec','a55a583c-7dbf-4e18-b255-f41c5d82e445','2026-07-23 13:52:18.473909','empty','IMP-89537506','B 1000 UAT','Driver UAT',NULL,'valid',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-23 13:52:18.473909','2026-07-23 13:52:18.473909'),('17d43f7a-8663-11f1-a160-002b67818c25','b3b96ed8-8308-4a83-af84-e5d488d1260e','TSTU9557566','c3a0e586-8fda-40de-bd9c-4e5689ffe647','22G1','1e95fb79-ee0d-41aa-b26a-99f07e50976c','34275f3a-6e39-4224-998f-4c06aa4869cc','2026-07-23 13:00:00.000000','empty',NULL,'B 1000 UAT','Driver UAT',NULL,'valid','closed','sound',NULL,'clear',NULL,NULL,'UAT lokal','2026-07-23 13:52:38.486570','2026-07-23 13:52:38.000000'),('17d775b7-8663-11f1-a160-002b67818c25','5905e03b-cc89-45cd-a99a-94f57871239c','TSTU9557567','c3a0e586-8fda-40de-bd9c-4e5689ffe647','22G1','1e95fb79-ee0d-41aa-b26a-99f07e50976c','34275f3a-6e39-4224-998f-4c06aa4869cc','2026-07-23 13:00:00.000000','empty',NULL,'B 1000 UAT','Driver UAT',NULL,'valid','closed','sound',NULL,'clear',NULL,NULL,'UAT lokal','2026-07-23 13:52:38.507605','2026-07-23 13:52:38.000000'),('20ec8ff0-9542-11f1-9595-002b67818c25','e2e00002-0000-4000-8000-000000000201','NPKU1357903','06132cac-4ae5-4b80-9b07-417edcf756f1','22G1','32aa190f-d0de-448d-b533-421da6e87ce9','3fd7d149-4e43-4c0c-96ba-b846f4155d2b','2026-08-11 12:04:27.000000','empty',NULL,NULL,NULL,NULL,NULL,NULL,'serviceable','existing','Cerah',NULL,NULL,'UAT-REAL-CASE-2026-08','2026-08-11 12:04:27.794983','2026-08-11 12:04:27.794983'),('20edd8e1-9542-11f1-9595-002b67818c25','e2e00002-0000-4000-8000-000000000202','BCKU1122331','06132cac-4ae5-4b80-9b07-417edcf756f1','22G1','32aa190f-d0de-448d-b533-421da6e87ce9','3fd7d149-4e43-4c0c-96ba-b846f4155d2b','2026-08-11 12:04:27.000000','empty',NULL,NULL,NULL,NULL,NULL,NULL,'serviceable','existing','Cerah',NULL,NULL,'UAT-REAL-CASE-2026-08','2026-08-11 12:04:27.803381','2026-08-11 12:04:27.803381'),('20ef818b-9542-11f1-9595-002b67818c25','e2e00003-0000-4000-8000-000000000301','BCKU2468102','06132cac-4ae5-4b80-9b07-417edcf756f1','22G1','32aa190f-d0de-448d-b533-421da6e87ce9','3fd7d149-4e43-4c0c-96ba-b846f4155d2b','2026-08-11 12:04:27.000000','empty',NULL,NULL,NULL,NULL,NULL,NULL,'serviceable','existing','Cerah',NULL,NULL,'UAT-REAL-CASE-2026-08','2026-08-11 12:04:27.814287','2026-08-11 12:04:27.814287'),('20f1b07d-9542-11f1-9595-002b67818c25','e2e00003-0000-4000-8000-000000000302','GFTU6543216','06132cac-4ae5-4b80-9b07-417edcf756f1','22G1','32aa190f-d0de-448d-b533-421da6e87ce9','3fd7d149-4e43-4c0c-96ba-b846f4155d2b','2026-08-11 12:04:27.000000','empty',NULL,NULL,NULL,NULL,NULL,NULL,'serviceable','existing','Cerah',NULL,NULL,'UAT-REAL-CASE-2026-08','2026-08-11 12:04:27.828545','2026-08-11 12:04:27.828545'),('20f42ebb-9542-11f1-9595-002b67818c25','e2e00004-0000-4000-8000-000000000401','UATU0000015','e2e00004-0000-4000-8000-000000000040','22G1','e2e00004-0000-4000-8000-000000000010','e2e00004-0000-4000-8000-000000000020','2026-08-11 12:04:27.844925','empty',NULL,NULL,NULL,NULL,NULL,NULL,'serviceable','existing',NULL,NULL,NULL,'UAT-REAL-CASE-2026-08','2026-08-11 12:04:27.844925','2026-08-11 12:04:27.844925'),('398193a5-864e-11f1-a160-002b67818c25','724d3aea-49fb-41de-82ce-05d35a394925','CSQU3054383','06132cac-4ae5-4b80-9b07-417edcf756f1','22G1','32aa190f-d0de-448d-b533-421da6e87ce9','3fd7d149-4e43-4c0c-96ba-b846f4155d2b','2026-07-23 11:23:15.000000','empty','UAT-ISO-CEDEX-20260723112314-REJECT-SEAL','UAT-ISO-CEDEX-20260723112314-REJECT-TRUCK','UAT-ISO-CEDEX-20260723112314-REJECT Driver','UAT-ISO-CEDEX-20260723112314-REJECT-CHASSIS','valid','closed','good',NULL,'clear',-6.2000000,106.8166660,'UAT-ISO-CEDEX-20260723112314-REJECT audit only','2026-07-23 11:23:15.555999','2026-07-23 11:23:15.000000'),('3c90ed69-8652-11f1-a160-002b67818c25','829ea486-456b-44e3-883d-5cc97b7c6dc9','MSKU1234567','06132cac-4ae5-4b80-9b07-417edcf756f1','22G1','32aa190f-d0de-448d-b533-421da6e87ce9','3fd7d149-4e43-4c0c-96ba-b846f4155d2b','2026-07-23 11:51:58.676579','empty','UAT',NULL,NULL,NULL,'valid',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-07-23 11:51:58.676579','2026-07-23 11:51:58.676579'),('cd1883b6-9542-11f1-9595-002b67818c25','749164da-9dcf-478c-be1c-973291e46176','GFTU1234560','06132cac-4ae5-4b80-9b07-417edcf756f1','22G1','32aa190f-d0de-448d-b533-421da6e87ce9','3fd7d149-4e43-4c0c-96ba-b846f4155d2b','2026-08-11 12:09:16.650971','empty',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2026-08-11 12:09:16.650971','2026-08-11 12:09:16.650971'),('d9f784d4-864c-11f1-a160-002b67818c25','293e4859-83eb-4e36-9ab5-48fbe2f33bbf','MSKU1234565','06132cac-4ae5-4b80-9b07-417edcf756f1','22G1','32aa190f-d0de-448d-b533-421da6e87ce9','3fd7d149-4e43-4c0c-96ba-b846f4155d2b','2026-07-23 11:23:15.000000','empty','UAT-ISO-CEDEX-20260723112314-APPROVE-SEAL','UAT-ISO-CEDEX-20260723112314-APPROVE-TRUCK','UAT-ISO-CEDEX-20260723112314-APPROVE Driver','UAT-ISO-CEDEX-20260723112314-APPROVE-CHASSIS','valid','closed','good',NULL,'clear',-6.2000000,106.8166660,'UAT-ISO-CEDEX-20260723112314-APPROVE audit only','2026-07-23 11:13:25.770941','2026-07-23 11:23:15.000000');
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
INSERT INTO `survey_photos` VALUES ('b53e0e58-5c3b-46ff-b54d-a9ab0805809a','e2e00002-0000-4000-8000-000000000201',NULL,'b8f945ef-41f6-4916-a0ce-d8a7b91224f9','bd0316d7-d620-48a9-a158-1655c0d6a814','general','general_container','Evidence UAT reject otomatis','2026-08-11 05:09:29.651621',NULL,NULL,'Container: NPKU1357903\nSurvey: UAT-SURVEY-2026-0805-002-A\nDamage: General Evidence\nCategory: general_container\nLocation: Depot UAT 17B\nTaken: 2026-08-11 05:09:29 UTC\nSurveyor: Raka Pratama UAT',0,'8d94550e-df85-4ccf-9b87-f6717f61cccf','2026-08-11 12:09:29.738946','2026-08-11 12:09:29.738946',NULL),('db4222ee-448a-466a-9eaa-b9e53ef7f7ee','e2e00003-0000-4000-8000-000000000301',NULL,'a9171329-8565-4c96-849d-0a539392d65a','66a2682d-0639-47a2-903c-d0c735bb9eff','general','general_container','Evidence UAT revisi otomatis','2026-08-11 05:09:20.954969',NULL,NULL,'Container: BCKU2468102\nSurvey: UAT-SURVEY-2026-0805-003-A\nDamage: General Evidence\nCategory: general_container\nLocation: Depot UAT 17B\nTaken: 2026-08-11 05:09:20 UTC\nSurveyor: Raka Pratama UAT',0,'8d94550e-df85-4ccf-9b87-f6717f61cccf','2026-08-11 12:09:21.068175','2026-08-11 12:09:21.068175',NULL);
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
  KEY `idx_revision_items_approval` (`approval_id`),
  KEY `idx_revision_items_resolved_by` (`resolved_by`),
  KEY `idx_survey_revision_items_target` (`survey_id`,`target_type`,`target_id`),
  CONSTRAINT `fk_revision_items_approval` FOREIGN KEY (`approval_id`) REFERENCES `survey_approvals` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_revision_items_resolved_by` FOREIGN KEY (`resolved_by`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_revision_items_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_survey_revision_items_target` CHECK ((`target_type` in (_cp850'survey',_cp850'finding',_cp850'checklist',_cp850'photo')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `survey_revision_items`
--

LOCK TABLES `survey_revision_items` WRITE;
/*!40000 ALTER TABLE `survey_revision_items` DISABLE KEYS */;
INSERT INTO `survey_revision_items` VALUES ('040d0f4d-864e-11f1-a160-002b67818c25','879bcc0e-48d1-45ae-84a7-17d566c795f1','293e4859-83eb-4e36-9ab5-48fbe2f33bbf','survey','general',NULL,NULL,NULL,'UAT ISO CEDEX synthetic need revision',0,NULL,NULL,'2026-07-23 11:21:45.873129'),('17ee3ab6-8663-11f1-a160-002b67818c25','085a35cb-d210-4936-96ec-6ed35fafd67f','b3b96ed8-8308-4a83-af84-e5d488d1260e','survey','general',NULL,NULL,NULL,'Lengkapi verifikasi UAT',0,NULL,NULL,'2026-07-23 13:52:38.656842'),('d13e7075-9542-11f1-9595-002b67818c25','9ba37c6e-0287-4104-a1cb-6d3ef01c8fae','e2e00003-0000-4000-8000-000000000301','finding','general','e2e00003-0000-4000-8000-000000000601',NULL,NULL,'Periksa kembali Temuan terpilih.',1,'8d94550e-df85-4ccf-9b87-f6717f61cccf','2026-08-11 12:09:25.000000','2026-08-11 12:09:23.610524'),('d13f10e7-9542-11f1-9595-002b67818c25','9ba37c6e-0287-4104-a1cb-6d3ef01c8fae','e2e00003-0000-4000-8000-000000000301','photo','general','db4222ee-448a-466a-9eaa-b9e53ef7f7ee',NULL,NULL,'Periksa kembali Foto Evidence terpilih.',1,'8d94550e-df85-4ccf-9b87-f6717f61cccf','2026-08-11 12:09:25.000000','2026-08-11 12:09:23.614636');
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
INSERT INTO `survey_revisions` VALUES ('d13f935b-9542-11f1-9595-002b67818c25','e2e00003-0000-4000-8000-000000000301',1,'UAT revisi bertarget survey.','24c54a64-a645-4f8f-9b87-40a20b31d6ce','2026-08-11 12:09:23.617282','8d94550e-df85-4ccf-9b87-f6717f61cccf','2026-08-11 12:09:25.000000','Disetujui pada UAT real-case.','approved','{\"photos\": [{\"id\": \"db4222ee-448a-466a-9eaa-b9e53ef7f7ee\", \"caption\": \"Evidence UAT revisi otomatis\", \"file_id\": \"a9171329-8565-4c96-849d-0a539392d65a\", \"taken_at\": \"2026-08-11T05:09:20Z\", \"damage_id\": null, \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"created_at\": \"2026-08-11T12:09:21Z\", \"deleted_at\": null, \"photo_type\": \"general\", \"updated_at\": \"2026-08-11T12:09:21Z\", \"uploaded_by\": \"8d94550e-df85-4ccf-9b87-f6717f61cccf\", \"gps_latitude\": null, \"display_order\": 0, \"gps_longitude\": null, \"photo_category\": \"general_container\", \"watermark_text\": \"Container: BCKU2468102\\nSurvey: UAT-SURVEY-2026-0805-003-A\\nDamage: General Evidence\\nCategory: general_container\\nLocation: Depot UAT 17B\\nTaken: 2026-08-11 05:09:20 UTC\\nSurveyor: Raka Pratama UAT\", \"watermarked_file_id\": \"66a2682d-0639-47a2-903c-d0c735bb9eff\"}], \"survey\": {\"id\": \"e2e00003-0000-4000-8000-000000000301\", \"phase\": \"initial\", \"status\": \"under_review\", \"is_active\": 1, \"survey_no\": \"UAT-SURVEY-2026-0805-003-A\", \"created_at\": \"2026-08-11T12:04:27Z\", \"deleted_at\": null, \"started_at\": \"2026-08-10T12:04:27Z\", \"updated_at\": \"2026-08-11T12:09:22Z\", \"approved_at\": null, \"rejected_at\": null, \"surveyor_id\": \"9ac88126-eacc-4256-8f8b-efd594725b10\", \"final_remark\": \"UAT-REAL-CASE-2026-08\", \"job_order_id\": \"e2e00003-0000-4000-8000-000000000001\", \"submitted_at\": \"2026-08-11T12:09:21Z\", \"survey_round\": 1, \"assignment_id\": \"e2e00003-0000-4000-8000-000000000101\", \"survey_result\": \"damage\", \"resubmitted_at\": null, \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"inspection_phase\": \"initial\", \"job_container_id\": \"e2e00003-0000-4000-8000-000000000201\", \"parent_survey_id\": null, \"review_started_at\": \"2026-08-11T12:09:22Z\", \"review_started_by\": \"24c54a64-a645-4f8f-9b87-40a20b31d6ce\", \"current_reviewer_id\": \"24c54a64-a645-4f8f-9b87-40a20b31d6ce\", \"current_revision_no\": 0, \"inspection_round_no\": 1, \"reinspection_reason\": null, \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"system_recommendation_result\": null}, \"damages\": [{\"id\": \"e2e00003-0000-4000-8000-000000000601\", \"face\": \"left\", \"unit\": \"cm\", \"remark\": \"UAT-REAL-CASE-2026-08\", \"quantity\": null, \"severity\": \"minor\", \"damage_id\": \"99658a84-c385-4e6c-a264-4a5f357ec7eb\", \"damage_no\": \"D-001\", \"repair_id\": \"c124aa17-7f13-48d5-a75c-4b423916ccae\", \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"created_at\": \"2026-08-11T12:04:27Z\", \"created_by\": \"8d94550e-df85-4ccf-9b87-f6717f61cccf\", \"deleted_at\": null, \"updated_at\": \"2026-08-11T12:04:27Z\", \"updated_by\": \"8d94550e-df85-4ccf-9b87-f6717f61cccf\", \"depth_value\": null, \"material_id\": \"bc716703-acf5-44c2-9a78-1f6deb3e1f73\", \"width_value\": null, \"component_id\": \"0c4b9c89-45b0-4bc0-9af7-2d2f720112df\", \"length_value\": null, \"is_photo_only\": 0, \"quantity_unit\": null, \"finding_status\": \"open\", \"decision_reason\": null, \"decision_result\": null, \"decision_rule_id\": null, \"cedex_location_id\": \"671b9126-54cd-4d03-8724-edc95506a0ad\", \"dimension_profile\": null, \"internal_location\": \"L1\", \"responsibility_id\": \"8b067287-87f5-4a60-85fd-07770b885a3d\", \"is_repair_required\": 1, \"tolerance_snapshot\": null, \"finding_description\": \"Temuan UAT pada panel kiri\", \"checklist_response_id\": \"fbbcd20f-5aef-4b92-8c25-e857bd135d14\", \"decision_evaluated_at\": null, \"recommended_action_id\": null, \"is_cargo_worthy_impact\": 0, \"manual_location_reason\": null, \"inspection_reference_id\": null, \"location_selection_snapshot\": \"{\\\"code\\\": \\\"L17B\\\", \\\"face\\\": \\\"left\\\", \\\"grid_code\\\": \\\"L1\\\", \\\"input_mode\\\": \\\"manual\\\", \\\"container_size\\\": \\\"20\\\"}\"}], \"checklist\": [{\"id\": \"fbbcd20f-5aef-4b92-8c25-e857bd135d14\", \"unit\": null, \"item_code\": \"ITMF0723111302\", \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"created_at\": \"2026-08-11T12:04:27Z\", \"item_label\": \"UAT Checklist Item F0723111302\", \"updated_at\": \"2026-08-11T12:04:27Z\", \"is_critical\": 0, \"is_required\": 1, \"display_order\": 1, \"response_text\": null, \"response_type\": \"ok_not_ok\", \"response_value\": \"no\", \"response_numeric\": null, \"template_item_id\": \"3798b4be-809c-4ddf-949d-426833064328\", \"attachment_file_id\": null, \"standard_reference\": null, \"requires_attachment\": 0}], \"general_info\": {\"id\": \"20ef818b-9542-11f1-9595-002b67818c25\", \"seal_no\": null, \"weather\": \"Cerah\", \"truck_no\": null, \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"chassis_no\": null, \"created_at\": \"2026-08-11T12:04:27Z\", \"updated_at\": \"2026-08-11T12:04:27Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"door_status\": null, \"driver_name\": null, \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"cargo_status\": \"empty\", \"container_no\": \"BCKU2468102\", \"gps_latitude\": null, \"gps_longitude\": null, \"iso_type_code\": \"22G1\", \"general_remark\": \"UAT-REAL-CASE-2026-08\", \"csc_plate_status\": null, \"survey_date_time\": \"2026-08-11T12:04:27Z\", \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"general_condition\": \"serviceable\", \"container_lifecycle\": \"existing\"}}','{\"photos\": [{\"id\": \"db4222ee-448a-466a-9eaa-b9e53ef7f7ee\", \"caption\": \"Evidence UAT revisi otomatis\", \"file_id\": \"a9171329-8565-4c96-849d-0a539392d65a\", \"taken_at\": \"2026-08-11T05:09:20Z\", \"damage_id\": null, \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"created_at\": \"2026-08-11T12:09:21Z\", \"deleted_at\": null, \"photo_type\": \"general\", \"updated_at\": \"2026-08-11T12:09:21Z\", \"uploaded_by\": \"8d94550e-df85-4ccf-9b87-f6717f61cccf\", \"gps_latitude\": null, \"display_order\": 0, \"gps_longitude\": null, \"photo_category\": \"general_container\", \"watermark_text\": \"Container: BCKU2468102\\nSurvey: UAT-SURVEY-2026-0805-003-A\\nDamage: General Evidence\\nCategory: general_container\\nLocation: Depot UAT 17B\\nTaken: 2026-08-11 05:09:20 UTC\\nSurveyor: Raka Pratama UAT\", \"watermarked_file_id\": \"66a2682d-0639-47a2-903c-d0c735bb9eff\"}], \"survey\": {\"id\": \"e2e00003-0000-4000-8000-000000000301\", \"phase\": \"initial\", \"status\": \"resubmitted\", \"is_active\": 1, \"survey_no\": \"UAT-SURVEY-2026-0805-003-A\", \"created_at\": \"2026-08-11T12:04:27Z\", \"deleted_at\": null, \"started_at\": \"2026-08-10T12:04:27Z\", \"updated_at\": \"2026-08-11T12:09:25Z\", \"approved_at\": null, \"rejected_at\": null, \"surveyor_id\": \"9ac88126-eacc-4256-8f8b-efd594725b10\", \"final_remark\": \"UAT-REAL-CASE-2026-08\", \"job_order_id\": \"e2e00003-0000-4000-8000-000000000001\", \"submitted_at\": \"2026-08-11T12:09:21Z\", \"survey_round\": 1, \"assignment_id\": \"e2e00003-0000-4000-8000-000000000101\", \"survey_result\": \"damage\", \"resubmitted_at\": \"2026-08-11T12:09:25Z\", \"survey_type_id\": \"94e7124b-c5a8-4f27-8535-dd5618ee7caf\", \"inspection_phase\": \"initial\", \"job_container_id\": \"e2e00003-0000-4000-8000-000000000201\", \"parent_survey_id\": null, \"review_started_at\": null, \"review_started_by\": null, \"current_reviewer_id\": null, \"current_revision_no\": 1, \"inspection_round_no\": 1, \"reinspection_reason\": null, \"checklist_template_id\": \"b320301c-1f96-4967-8d0c-c8a1c3c3dd0f\", \"system_recommendation_result\": null}, \"damages\": [{\"id\": \"e2e00003-0000-4000-8000-000000000601\", \"face\": \"left\", \"unit\": \"cm\", \"remark\": \"UAT-REAL-CASE-2026-08\", \"quantity\": null, \"severity\": \"minor\", \"damage_id\": \"99658a84-c385-4e6c-a264-4a5f357ec7eb\", \"damage_no\": \"D-001\", \"repair_id\": \"c124aa17-7f13-48d5-a75c-4b423916ccae\", \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"created_at\": \"2026-08-11T12:04:27Z\", \"created_by\": \"8d94550e-df85-4ccf-9b87-f6717f61cccf\", \"deleted_at\": null, \"updated_at\": \"2026-08-11T12:04:27Z\", \"updated_by\": \"8d94550e-df85-4ccf-9b87-f6717f61cccf\", \"depth_value\": null, \"material_id\": \"bc716703-acf5-44c2-9a78-1f6deb3e1f73\", \"width_value\": null, \"component_id\": \"0c4b9c89-45b0-4bc0-9af7-2d2f720112df\", \"length_value\": null, \"is_photo_only\": 0, \"quantity_unit\": null, \"finding_status\": \"open\", \"decision_reason\": null, \"decision_result\": null, \"decision_rule_id\": null, \"cedex_location_id\": \"671b9126-54cd-4d03-8724-edc95506a0ad\", \"dimension_profile\": null, \"internal_location\": \"L1\", \"responsibility_id\": \"8b067287-87f5-4a60-85fd-07770b885a3d\", \"is_repair_required\": 1, \"tolerance_snapshot\": null, \"finding_description\": \"Temuan UAT pada panel kiri\", \"checklist_response_id\": \"fbbcd20f-5aef-4b92-8c25-e857bd135d14\", \"decision_evaluated_at\": null, \"recommended_action_id\": null, \"is_cargo_worthy_impact\": 0, \"manual_location_reason\": null, \"inspection_reference_id\": null, \"location_selection_snapshot\": \"{\\\"code\\\": \\\"L17B\\\", \\\"face\\\": \\\"left\\\", \\\"grid_code\\\": \\\"L1\\\", \\\"input_mode\\\": \\\"manual\\\", \\\"container_size\\\": \\\"20\\\"}\"}], \"checklist\": [{\"id\": \"fbbcd20f-5aef-4b92-8c25-e857bd135d14\", \"unit\": null, \"item_code\": \"ITMF0723111302\", \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"created_at\": \"2026-08-11T12:04:27Z\", \"item_label\": \"UAT Checklist Item F0723111302\", \"updated_at\": \"2026-08-11T12:04:27Z\", \"is_critical\": 0, \"is_required\": 1, \"display_order\": 1, \"response_text\": null, \"response_type\": \"ok_not_ok\", \"response_value\": \"no\", \"response_numeric\": null, \"template_item_id\": \"3798b4be-809c-4ddf-949d-426833064328\", \"attachment_file_id\": null, \"standard_reference\": null, \"requires_attachment\": 0}], \"general_info\": {\"id\": \"20ef818b-9542-11f1-9595-002b67818c25\", \"seal_no\": null, \"weather\": \"Cerah\", \"truck_no\": null, \"survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"chassis_no\": null, \"created_at\": \"2026-08-11T12:04:27Z\", \"updated_at\": \"2026-08-11T12:04:27Z\", \"customer_id\": \"32aa190f-d0de-448d-b533-421da6e87ce9\", \"door_status\": null, \"driver_name\": null, \"location_id\": \"3fd7d149-4e43-4c0c-96ba-b846f4155d2b\", \"cargo_status\": \"empty\", \"container_no\": \"BCKU2468102\", \"gps_latitude\": null, \"gps_longitude\": null, \"iso_type_code\": \"22G1\", \"general_remark\": \"UAT-REAL-CASE-2026-08\", \"csc_plate_status\": null, \"survey_date_time\": \"2026-08-11T12:04:27Z\", \"container_type_id\": \"06132cac-4ae5-4b80-9b07-417edcf756f1\", \"general_condition\": \"serviceable\", \"container_lifecycle\": \"existing\"}}','2026-08-11 12:09:23.617282','2026-08-11 12:09:26.000000');
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
INSERT INTO `survey_types` VALUES ('14fcb920-2d27-4903-b6ae-c8c21cbd1c81','cd0c0678-86f8-4f29-a44b-db12a4e481ec','ST89537506','Survey UAT','Data uji lokal',0,0,1,'active','2026-07-23 13:52:18.065895','2026-07-23 13:52:18.065895'),('3f2b441f-737f-11f1-ac50-002b67818c25',NULL,'GI','Gate In Survey','Survey when container enters yard or depot',1,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b4c28-737f-11f1-ac50-002b67818c25',NULL,'GO','Gate Out Survey','Survey when container leaves yard or depot',1,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b4eea-737f-11f1-ac50-002b67818c25',NULL,'DS','Damage Survey','Specific survey for container damage',0,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b50fc-737f-11f1-ac50-002b67818c25',NULL,'CW','Cargo Worthy Survey','Cargo worthy condition assessment',0,1,1,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b52e1-737f-11f1-ac50-002b67818c25',NULL,'CL','Cleanliness Survey','Container cleanliness survey',0,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b5e33-737f-11f1-ac50-002b67818c25',NULL,'ONH','On Hire Survey','Start of hire survey',0,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b6033-737f-11f1-ac50-002b67818c25',NULL,'OFH','Off Hire Survey','End of hire survey',0,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b626d-737f-11f1-ac50-002b67818c25',NULL,'STUF','Stuffing Survey','Survey during stuffing activity',0,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b63fa-737f-11f1-ac50-002b67818c25',NULL,'STRP','Stripping Survey','Survey during stripping activity',0,0,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('3f2b65bf-737f-11f1-ac50-002b67818c25',NULL,'PTI','Pre-Trip Inspection','Reefer pre-trip inspection',0,1,0,'active','2026-06-29 05:56:18.302441','2026-06-29 05:56:18.302441'),('62581b70-cf5f-4d2b-b01e-e3367fb5493a','42aee823-b9d1-4788-9fd6-cdce2cb732f8','STUAT-ISO-CEDEX-20260723115019','UAT Survey UAT-ISO-CEDEX-20260723115019','UAT',0,0,0,'inactive','2026-07-23 11:50:19.607071','2026-07-23 11:50:20.000000'),('79589597-afe5-42ba-bd7d-e9d7df2f2c68','1e95fb79-ee0d-41aa-b26a-99f07e50976c','ST89557566','Survey UAT','Data uji lokal',0,0,1,'active','2026-07-23 13:52:38.163141','2026-07-23 13:52:38.163141'),('7a3da078-9a7e-4cfa-bed4-a3283eab1023','9eaabd4d-581a-4c1d-811a-4e3253300088','STA0723110926','UAT Survey A0723110926','UAT',0,0,0,'active','2026-07-23 11:09:26.672705','2026-07-23 11:09:26.672705'),('94e7124b-c5a8-4f27-8535-dd5618ee7caf','32aa190f-d0de-448d-b533-421da6e87ce9','SV-17B','Survey UAT 17B','Customer scoped UAT',1,1,1,'active','2026-07-17 16:56:33.913953','2026-07-17 16:56:33.913953'),('d0daeabd-1e41-4bd8-8666-09a8cb66a782','5d275989-b5f8-4f56-abb7-1e6cf8630449','STUAT-ISO-CEDEX-20260723115019','UAT Survey UAT-ISO-CEDEX-20260723115019','UAT',0,0,0,'active','2026-07-23 11:50:19.621080','2026-07-23 11:50:19.621080'),('e2e00004-0000-4000-8000-000000000030','e2e00004-0000-4000-8000-000000000010','UAT-ISO-SURVEY','Survey Isolation UAT','UAT-REAL-CASE-2026-08',0,0,0,'active','2026-08-11 12:04:27.836339','2026-08-11 12:04:27.836339'),('f811c4a3-df8c-4ab7-af5a-fa4b736ca7df','5581423d-c969-43b4-ba9b-b427ac1511ed','ST89518363','Survey UAT','Data uji lokal',0,0,1,'active','2026-07-23 13:51:59.048170','2026-07-23 13:51:59.048170'),('fe6f2dac-a29e-4350-85ad-7ee437030687','1b36b739-2080-451a-9092-64b5b771167a','STA0723110926','UAT Survey A0723110926','UAT',0,0,0,'inactive','2026-07-23 11:09:26.663708','2026-07-23 11:09:27.000000');
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
INSERT INTO `surveyor_profiles` VALUES ('00000000-0000-0000-0000-000000000103','00000000-0000-0000-0000-000000000003','SVY-DEMO','Surveyor Demo',NULL,'Demo Area',NULL,NULL,NULL,NULL,NULL,'active','2026-07-01 14:30:22.051372','2026-07-01 14:30:22.051372',NULL),('47527587-fe0f-4b52-b87c-d3866beffbdf','2cd29025-9cf6-41ec-b70d-73e83ba6b83a','UAT-SURV-02','Nabila Putri UAT',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active','2026-08-11 12:04:27.735917','2026-08-11 12:04:27.735917',NULL),('9ac88126-eacc-4256-8f8b-efd594725b10','8d94550e-df85-4ccf-9b87-f6717f61cccf','UAT-SURV-01','Raka Pratama UAT',NULL,NULL,NULL,NULL,NULL,NULL,NULL,'active','2026-08-11 12:04:27.733917','2026-08-11 12:04:27.733917',NULL);
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
  `parent_survey_id` char(36) DEFAULT NULL,
  `inspection_phase` varchar(30) NOT NULL DEFAULT 'initial',
  `inspection_round_no` int NOT NULL DEFAULT '1',
  `reinspection_reason` text,
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
  `review_started_by` char(36) DEFAULT NULL,
  `current_reviewer_id` char(36) DEFAULT NULL,
  `review_started_at` datetime(6) DEFAULT NULL,
  `resubmitted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `survey_no` (`survey_no`),
  UNIQUE KEY `idx_surveys_no` (`survey_no`),
  UNIQUE KEY `uq_surveys_container_type_phase_round` (`job_container_id`,`survey_type_id`,`inspection_phase`,`inspection_round_no`),
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
  KEY `idx_surveys_parent` (`parent_survey_id`),
  KEY `idx_surveys_phase_round` (`job_container_id`,`inspection_phase`,`inspection_round_no`),
  KEY `fk_surveys_review_started_by` (`review_started_by`),
  KEY `idx_surveys_review_started_at` (`review_started_at`),
  KEY `idx_surveys_resubmitted_at` (`resubmitted_at`),
  KEY `idx_surveys_surveyor_status_updated` (`surveyor_id`,`status`,`updated_at`),
  KEY `idx_surveys_review_queue` (`status`,`submitted_at`,`resubmitted_at`),
  KEY `idx_surveys_container_type_status` (`job_container_id`,`survey_type_id`,`status`),
  KEY `idx_surveys_active_status` (`is_active`,`status`),
  KEY `idx_surveys_current_reviewer` (`current_reviewer_id`),
  CONSTRAINT `fk_surveys_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`),
  CONSTRAINT `fk_surveys_checklist_template` FOREIGN KEY (`checklist_template_id`) REFERENCES `fitness_checklist_templates` (`id`),
  CONSTRAINT `fk_surveys_current_reviewer` FOREIGN KEY (`current_reviewer_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_surveys_job_container` FOREIGN KEY (`job_container_id`) REFERENCES `job_containers` (`id`),
  CONSTRAINT `fk_surveys_job_order` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`id`),
  CONSTRAINT `fk_surveys_parent` FOREIGN KEY (`parent_survey_id`) REFERENCES `surveys` (`id`),
  CONSTRAINT `fk_surveys_review_started_by` FOREIGN KEY (`review_started_by`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_surveys_survey_type` FOREIGN KEY (`survey_type_id`) REFERENCES `survey_types` (`id`),
  CONSTRAINT `fk_surveys_surveyor` FOREIGN KEY (`surveyor_id`) REFERENCES `surveyor_profiles` (`id`),
  CONSTRAINT `chk_surveys_inspection_phase` CHECK ((`inspection_phase` in (_utf8mb4'initial',_utf8mb4'reinspection'))),
  CONSTRAINT `chk_surveys_inspection_round` CHECK ((`inspection_round_no` >= 1)),
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
INSERT INTO `surveys` VALUES ('293e4859-83eb-4e36-9ab5-48fbe2f33bbf','GIFT-SVY-2026-000001','ba973397-9eee-4cf9-b987-9a2e4e727195','ef3108a3-5d1e-4832-af0b-eb174edc0675','0af0234c-cf48-4860-9b19-f9943b638a4f','00000000-0000-0000-0000-000000000103','94e7124b-c5a8-4f27-8535-dd5618ee7caf','initial',1,1,'b320301c-1f96-4967-8d0c-c8a1c3c3dd0f',NULL,'initial',1,NULL,'approved','fit',NULL,'2026-07-23 11:13:25.000000','2026-07-23 11:23:15.000000','2026-07-23 11:23:15.000000',NULL,1,'UAT-ISO-CEDEX-20260723112314-APPROVE submit','2026-07-23 11:13:25.765929','2026-07-23 11:23:15.000000',NULL,NULL,NULL,NULL,NULL),('3bde18bd-5822-4531-8e90-ba16f508c162','GIFT-SVY-2026-000004','daf62320-72ab-42ed-b509-dd6b0a2ba413','b517fda0-6324-4bbe-9d9e-4ac166232d53','4a946427-7d4d-41ab-8a84-e8576c80801f','00000000-0000-0000-0000-000000000103','14fcb920-2d27-4903-b6ae-c8c21cbd1c81','initial',1,1,'40c67324-02f0-4cbe-8d94-8f4b71008693',NULL,'initial',1,NULL,'draft',NULL,NULL,'2026-07-23 13:52:18.000000',NULL,NULL,NULL,0,NULL,'2026-07-23 13:52:18.442880','2026-07-23 13:52:18.442880',NULL,NULL,NULL,NULL,NULL),('5905e03b-cc89-45cd-a99a-94f57871239c','GIFT-SVY-2026-000007','9cb28aad-c5f8-4a6e-93c6-7718905972fe','30956aa8-4a29-4628-b5a2-2d297cd4208e','de3eeefb-9df3-465e-a137-0da41de4a3e9','00000000-0000-0000-0000-000000000103','79589597-afe5-42ba-bd7d-e9d7df2f2c68','initial',1,1,'0b56a5b1-d55d-47bd-a00e-26654be2a956',NULL,'initial',1,NULL,'rejected','sound',NULL,'2026-07-23 13:52:38.000000','2026-07-23 13:52:38.000000',NULL,'2026-07-23 13:52:38.000000',0,'Submit untuk Reject UAT','2026-07-23 13:52:38.506385','2026-07-23 13:52:38.000000',NULL,NULL,NULL,NULL,NULL),('724d3aea-49fb-41de-82ce-05d35a394925','GIFT-SVY-2026-000002','1b39e6d9-c766-41ae-bdfb-24b53e76eaa9','37e74fda-ed4b-499a-a6a0-849adfeb99b7','14c3da84-9072-4fdd-a806-9f0dfe9d012f','00000000-0000-0000-0000-000000000103','94e7124b-c5a8-4f27-8535-dd5618ee7caf','initial',1,1,'b320301c-1f96-4967-8d0c-c8a1c3c3dd0f',NULL,'initial',1,NULL,'rejected','sound',NULL,'2026-07-23 11:23:15.000000','2026-07-23 11:23:15.000000',NULL,'2026-07-23 11:23:15.000000',0,'UAT-ISO-CEDEX-20260723112314-REJECT submit','2026-07-23 11:23:15.555135','2026-07-23 11:23:15.000000',NULL,NULL,NULL,NULL,NULL),('749164da-9dcf-478c-be1c-973291e46176','GIFT-SVY-2026-000008','e2e00001-0000-4000-8000-000000000001','e2e00001-0000-4000-8000-000000000201','e2e00001-0000-4000-8000-000000000101','9ac88126-eacc-4256-8f8b-efd594725b10','94e7124b-c5a8-4f27-8535-dd5618ee7caf','initial',1,1,'b320301c-1f96-4967-8d0c-c8a1c3c3dd0f',NULL,'initial',1,NULL,'draft',NULL,NULL,'2026-08-11 12:09:16.000000',NULL,NULL,NULL,0,NULL,'2026-08-11 12:09:16.641300','2026-08-11 12:09:16.641300',NULL,NULL,NULL,NULL,NULL),('829ea486-456b-44e3-883d-5cc97b7c6dc9','GIFT-SVY-2026-000003','e8438630-bfbf-4861-be6f-73611a3f479c','82b50221-7114-4dce-8544-c0508885094b','77196b64-3748-429f-ad4f-083fdb122e61','00000000-0000-0000-0000-000000000103','94e7124b-c5a8-4f27-8535-dd5618ee7caf','initial',1,1,'b320301c-1f96-4967-8d0c-c8a1c3c3dd0f',NULL,'initial',1,NULL,'draft',NULL,NULL,'2026-07-23 11:51:58.000000',NULL,NULL,NULL,0,NULL,'2026-07-23 11:51:58.674226','2026-07-23 11:51:58.674226',NULL,NULL,NULL,NULL,NULL),('b3b96ed8-8308-4a83-af84-e5d488d1260e','GIFT-SVY-2026-000006','9cb28aad-c5f8-4a6e-93c6-7718905972fe','d52f27a5-6060-41f6-aaad-a9d3deaa837b','de3eeefb-9df3-465e-a137-0da41de4a3e9','00000000-0000-0000-0000-000000000103','79589597-afe5-42ba-bd7d-e9d7df2f2c68','initial',1,1,'0b56a5b1-d55d-47bd-a00e-26654be2a956',NULL,'initial',1,NULL,'approved','sound',NULL,'2026-07-23 13:52:38.000000','2026-07-23 13:52:38.000000','2026-07-23 13:52:38.000000',NULL,1,'Resubmit UAT','2026-07-23 13:52:38.485271','2026-07-23 13:52:38.000000',NULL,NULL,NULL,NULL,NULL),('c8cfacf2-cacf-43de-91a5-57c7bcb5c1d7','GIFT-SVY-2026-000005','daf62320-72ab-42ed-b509-dd6b0a2ba413','fd058dbe-7585-43f8-bc5a-a96fc0c102cf','4a946427-7d4d-41ab-8a84-e8576c80801f','00000000-0000-0000-0000-000000000103','14fcb920-2d27-4903-b6ae-c8c21cbd1c81','initial',1,1,'40c67324-02f0-4cbe-8d94-8f4b71008693',NULL,'initial',1,NULL,'draft',NULL,NULL,'2026-07-23 13:52:18.000000',NULL,NULL,NULL,0,NULL,'2026-07-23 13:52:18.472562','2026-07-23 13:52:18.472562',NULL,NULL,NULL,NULL,NULL),('e2e00002-0000-4000-8000-000000000201','UAT-SURVEY-2026-0805-002-A','e2e00002-0000-4000-8000-000000000001','e2e00002-0000-4000-8000-000000000201','e2e00002-0000-4000-8000-000000000101','9ac88126-eacc-4256-8f8b-efd594725b10','94e7124b-c5a8-4f27-8535-dd5618ee7caf','initial',1,1,'b320301c-1f96-4967-8d0c-c8a1c3c3dd0f',NULL,'initial',1,NULL,'rejected','sound',NULL,'2026-08-10 12:04:27.000000','2026-08-11 12:09:30.000000',NULL,'2026-08-11 12:09:31.000000',0,'UAT-REAL-CASE-2026-08','2026-08-11 12:04:27.788795','2026-08-11 12:09:31.000000',NULL,'24c54a64-a645-4f8f-9b87-40a20b31d6ce','24c54a64-a645-4f8f-9b87-40a20b31d6ce','2026-08-11 12:09:31.000000',NULL),('e2e00002-0000-4000-8000-000000000202','UAT-SURVEY-2026-0805-002-B','e2e00002-0000-4000-8000-000000000001','e2e00002-0000-4000-8000-000000000202','e2e00002-0000-4000-8000-000000000101','9ac88126-eacc-4256-8f8b-efd594725b10','94e7124b-c5a8-4f27-8535-dd5618ee7caf','initial',1,1,'b320301c-1f96-4967-8d0c-c8a1c3c3dd0f',NULL,'initial',1,NULL,'approved','cargo_worthy',NULL,'2026-08-10 12:04:27.000000','2026-08-05 09:00:00.000000','2026-08-05 10:00:00.000000',NULL,0,NULL,'2026-08-11 12:04:27.801844','2026-08-11 12:04:27.801844',NULL,NULL,NULL,NULL,NULL),('e2e00003-0000-4000-8000-000000000301','UAT-SURVEY-2026-0805-003-A','e2e00003-0000-4000-8000-000000000001','e2e00003-0000-4000-8000-000000000201','e2e00003-0000-4000-8000-000000000101','9ac88126-eacc-4256-8f8b-efd594725b10','94e7124b-c5a8-4f27-8535-dd5618ee7caf','initial',1,1,'b320301c-1f96-4967-8d0c-c8a1c3c3dd0f',NULL,'initial',1,NULL,'approved','cargo_worthy',NULL,'2026-08-10 12:04:27.000000','2026-08-11 12:09:21.000000','2026-08-11 12:09:26.000000',NULL,1,'UAT-REAL-CASE-2026-08','2026-08-11 12:04:27.813606','2026-08-11 12:09:26.000000',NULL,'24c54a64-a645-4f8f-9b87-40a20b31d6ce','24c54a64-a645-4f8f-9b87-40a20b31d6ce','2026-08-11 12:09:26.000000','2026-08-11 12:09:25.000000'),('e2e00003-0000-4000-8000-000000000302','UAT-SURVEY-2026-0805-003-B','e2e00003-0000-4000-8000-000000000001','e2e00003-0000-4000-8000-000000000202','e2e00003-0000-4000-8000-000000000101','9ac88126-eacc-4256-8f8b-efd594725b10','94e7124b-c5a8-4f27-8535-dd5618ee7caf','initial',1,1,'b320301c-1f96-4967-8d0c-c8a1c3c3dd0f',NULL,'initial',1,NULL,'approved','cargo_worthy',NULL,'2026-08-10 12:04:27.000000','2026-08-05 09:00:00.000000','2026-08-05 10:00:00.000000',NULL,0,NULL,'2026-08-11 12:04:27.827064','2026-08-11 12:04:27.827064',NULL,NULL,NULL,NULL,NULL),('e2e00004-0000-4000-8000-000000000401','UAT-SURVEY-ISOLATION-001','e2e00004-0000-4000-8000-000000000001','e2e00004-0000-4000-8000-000000000201','e2e00004-0000-4000-8000-000000000101','47527587-fe0f-4b52-b87c-d3866beffbdf','e2e00004-0000-4000-8000-000000000030','initial',1,1,'e2e00004-0000-4000-8000-000000000050',NULL,'initial',1,NULL,'draft',NULL,NULL,'2026-08-11 12:04:27.000000',NULL,NULL,NULL,0,NULL,'2026-08-11 12:04:27.844210','2026-08-11 12:04:27.844210',NULL,NULL,NULL,NULL,NULL);
/*!40000 ALTER TABLE `surveys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `uat_seed_manifests`
--

DROP TABLE IF EXISTS `uat_seed_manifests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `uat_seed_manifests` (
  `dataset_id` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `source_fingerprint` char(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` json NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  PRIMARY KEY (`dataset_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `uat_seed_manifests`
--

LOCK TABLES `uat_seed_manifests` WRITE;
/*!40000 ALTER TABLE `uat_seed_manifests` DISABLE KEYS */;
INSERT INTO `uat_seed_manifests` VALUES ('UAT-REAL-CASE-2026-08','BOOTSTRAPPED','25d8f7a7fc120a805c34352ed49cd0b26e263187fff97dfdb0b9355fe45d5c18','{\"e2e\": {\"container_a_no\": \"GFTU1234560\", \"container_b_no\": \"NPKU7654323\", \"revision_survey_id\": \"e2e00003-0000-4000-8000-000000000301\", \"isolation_survey_id\": \"e2e00004-0000-4000-8000-000000000401\", \"rejection_survey_id\": \"e2e00002-0000-4000-8000-000000000201\", \"multi_container_job_id\": \"e2e00001-0000-4000-8000-000000000001\"}, \"mode\": \"BrowserReady\", \"dataset_id\": \"UAT-REAL-CASE-2026-08\", \"object_prefix\": \"uat/UAT-REAL-CASE-2026-08\", \"source_database\": \"kontainer_db\", \"bootstrapped_users\": 6, \"master_fingerprint\": \"25d8f7a7fc120a805c34352ed49cd0b26e263187fff97dfdb0b9355fe45d5c18\", \"master_source_customer_code\": \"UAT-CUST-17B\"}','2026-08-11 12:04:27.849226','2026-08-11 12:04:27.849226');
/*!40000 ALTER TABLE `uat_seed_manifests` ENABLE KEYS */;
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
INSERT INTO `user_roles` VALUES ('08c0b4c5-96c2-46ed-9f5c-7d9ac53df9c5','7f55f406-fa96-4bdb-8758-4178ba8e082c','3f26bccb-737f-11f1-ac50-002b67818c25','2026-08-11 12:04:27.739168'),('3f418ea9-737f-11f1-ac50-002b67818c25','00000000-0000-0000-0000-000000000001','3f26a41f-737f-11f1-ac50-002b67818c25','2026-06-29 05:56:18.448821'),('5cc69a84-56c1-4cb9-af19-9c0b48f6f655','24c54a64-a645-4f8f-9b87-40a20b31d6ce','3f26ba11-737f-11f1-ac50-002b67818c25','2026-08-11 12:04:27.737537'),('5f1ccec3-06bf-4012-b269-4ac3da0612b1','2cd29025-9cf6-41ec-b70d-73e83ba6b83a','3f26b8df-737f-11f1-ac50-002b67818c25','2026-08-11 12:04:27.735537'),('b7ebacc3-751e-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000002','3f26b6a0-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:22.033497'),('b7ebbb17-751e-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000005','3f26bb58-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:22.033497'),('b7ebc0c6-751e-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000006','3f26bccb-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:22.033497'),('b7ebc781-751e-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000004','3f26ba11-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:22.033497'),('b7ebd074-751e-11f1-8fe5-002b67818c25','00000000-0000-0000-0000-000000000003','3f26b8df-737f-11f1-ac50-002b67818c25','2026-07-01 14:30:22.033497'),('c3dd285a-b5c6-4b07-bacd-885153f98873','8d94550e-df85-4ccf-9b87-f6717f61cccf','3f26b8df-737f-11f1-ac50-002b67818c25','2026-08-11 12:04:27.731562'),('d3bfaf28-3b12-4c36-baed-7ceab10a3139','16d75d68-b6c2-43de-97c6-ec099ae08ce0','3f26b6a0-737f-11f1-ac50-002b67818c25','2026-08-11 12:04:27.729726');
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
INSERT INTO `users` VALUES ('00000000-0000-0000-0000-000000000001','Super Admin Dev','superadmin@gift.local','superadmin','$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',NULL,NULL,'active','2026-08-04 17:12:16.162393','2026-06-29 05:56:18.000000','2026-06-29 05:56:18.440310','2026-08-04 17:12:16.162393',NULL),('00000000-0000-0000-0000-000000000002','Admin Demo','admin@gift.local','admin','$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',NULL,NULL,'active','2026-08-04 17:08:45.060740','2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622','2026-08-04 17:08:45.060740',NULL),('00000000-0000-0000-0000-000000000003','Surveyor Demo','surveyor@gift.local','surveyor','$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',NULL,NULL,'active','2026-08-04 17:08:30.748245','2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622','2026-08-04 17:08:30.748245',NULL),('00000000-0000-0000-0000-000000000004','Supervisor Demo','supervisor@gift.local','supervisor','$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',NULL,NULL,'active','2026-07-28 10:44:42.864583','2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622','2026-07-28 10:44:42.864583',NULL),('00000000-0000-0000-0000-000000000005','Finance Demo','finance@gift.local','finance','$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',NULL,NULL,'active',NULL,'2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622',NULL),('00000000-0000-0000-0000-000000000006','Management Demo','management@gift.local','management','$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG',NULL,NULL,'active','2026-07-28 10:41:30.314083','2026-07-01 14:30:22.014622','2026-07-01 14:30:22.014622','2026-07-28 10:41:30.314083',NULL),('16d75d68-b6c2-43de-97c6-ec099ae08ce0','Siti Maharani UAT','siti.maharani@uat-gift.test','uat.admin','$2a$10$lb3c1h0sp7ad3tjkOtkCRO1TySD0BUs68VeiD7LaFKomfud4Yp0um',NULL,NULL,'active','2026-08-11 05:09:33.904232','2026-08-11 12:04:27.727535','2026-08-11 12:04:27.727535','2026-08-11 05:09:33.904232',NULL),('24c54a64-a645-4f8f-9b87-40a20b31d6ce','Ardiansyah Wibowo UAT','ardiansyah.wibowo@uat-gift.test','uat.reviewer','$2a$10$lb3c1h0sp7ad3tjkOtkCRO1TySD0BUs68VeiD7LaFKomfud4Yp0um',NULL,NULL,'active','2026-08-11 05:09:30.996310','2026-08-11 12:04:27.736683','2026-08-11 12:04:27.736683','2026-08-11 05:09:30.996310',NULL),('2cd29025-9cf6-41ec-b70d-73e83ba6b83a','Nabila Putri UAT','nabila.putri@uat-gift.test','uat.surveyor.nabila','$2a$10$lb3c1h0sp7ad3tjkOtkCRO1TySD0BUs68VeiD7LaFKomfud4Yp0um',NULL,NULL,'active',NULL,'2026-08-11 12:04:27.734856','2026-08-11 12:04:27.734856','2026-08-11 12:04:27.734856',NULL),('7f55f406-fa96-4bdb-8758-4178ba8e082c','Dewi Lestari UAT','dewi.lestari@uat-gift.test','uat.management','$2a$10$lb3c1h0sp7ad3tjkOtkCRO1TySD0BUs68VeiD7LaFKomfud4Yp0um',NULL,NULL,'active','2026-08-11 05:09:32.356773','2026-08-11 12:04:27.738385','2026-08-11 12:04:27.738385','2026-08-11 05:09:32.356773',NULL),('8d94550e-df85-4ccf-9b87-f6717f61cccf','Raka Pratama UAT','raka.pratama@uat-gift.test','uat.surveyor.raka','$2a$10$lb3c1h0sp7ad3tjkOtkCRO1TySD0BUs68VeiD7LaFKomfud4Yp0um',NULL,NULL,'active','2026-08-11 05:09:36.614798','2026-08-11 12:04:27.730568','2026-08-11 12:04:27.730568','2026-08-11 05:09:36.614798',NULL),('b3d02401-5f9c-439c-9b80-199d8ff3feed','Bima Saputra UAT','bima.saputra@uat-npk.test','uat.customer.pic','$2a$10$lb3c1h0sp7ad3tjkOtkCRO1TySD0BUs68VeiD7LaFKomfud4Yp0um',NULL,NULL,'active',NULL,'2026-08-11 12:04:27.739945','2026-08-11 12:04:27.739945','2026-08-11 12:04:27.739945',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping events for database 'kontainer_final_operational_20260811d_uat'
--

--
-- Dumping routines for database 'kontainer_final_operational_20260811d_uat'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_db19_add_constraint` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_db19_add_constraint`(
    IN p_table_name VARCHAR(128),
    IN p_constraint_name VARCHAR(128),
    IN p_ddl TEXT
)
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    SELECT COUNT(*)
      INTO v_exists
    FROM information_schema.TABLE_CONSTRAINTS
    WHERE CONSTRAINT_SCHEMA = DATABASE()
      AND TABLE_NAME = p_table_name
      AND CONSTRAINT_NAME = p_constraint_name;

    IF v_exists = 0 THEN
        SET @db19_dynamic_ddl = p_ddl;
        PREPARE db19_stmt FROM @db19_dynamic_ddl;
        EXECUTE db19_stmt;
        DEALLOCATE PREPARE db19_stmt;

        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (p_constraint_name, 'APPLIED', CONCAT('Constraint ditambahkan pada ', p_table_name, '.'));
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (p_constraint_name, 'SKIPPED', 'Constraint sudah tersedia.');
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_db19_add_index` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_db19_add_index`(
    IN p_table_name VARCHAR(128),
    IN p_index_name VARCHAR(128),
    IN p_ddl TEXT
)
BEGIN
    DECLARE v_exists INT DEFAULT 0;

    SELECT COUNT(*)
      INTO v_exists
    FROM information_schema.STATISTICS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = p_table_name
      AND INDEX_NAME = p_index_name;

    IF v_exists = 0 THEN
        SET @db19_dynamic_ddl = p_ddl;
        PREPARE db19_stmt FROM @db19_dynamic_ddl;
        EXECUTE db19_stmt;
        DEALLOCATE PREPARE db19_stmt;

        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (p_index_name, 'APPLIED', CONCAT('Index ditambahkan pada ', p_table_name, '.'));
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (p_index_name, 'SKIPPED', 'Index sudah tersedia.');
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_db19_patch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'NO_AUTO_VALUE_ON_ZERO' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_db19_patch`()
main_block: BEGIN
    DECLARE v_count BIGINT DEFAULT 0;
    DECLARE v_invalid BIGINT DEFAULT 0;
    DECLARE v_table_count INT DEFAULT 0;

    -- ------------------------------------------------------------------------
    -- B1. Preflight tabel runtime.
    -- ------------------------------------------------------------------------
    SELECT COUNT(*)
      INTO v_table_count
    FROM information_schema.TABLES
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME IN (
          'job_orders',
          'job_containers',
          'assignments',
          'assignment_containers',
          'surveys',
          'survey_general_infos',
          'survey_checklist_responses',
          'survey_damages',
          'survey_damage_counters',
          'survey_photos',
          'survey_approvals',
          'survey_revision_items',
          'survey_revisions',
          'cedex_damage_decision_rules',
          'cedex_code_proposals',
          'inspection_test_parameters',
          'file_objects'
      );

    IF v_table_count < 17 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Patch dihentikan: tabel runtime DB19 belum lengkap.';
    END IF;

    INSERT INTO `_db19_patch_results`
        (object_name, result_status, detail)
    VALUES
        ('preflight.runtime_tables', 'PASS', 'Seluruh tabel runtime utama tersedia.');

    -- ------------------------------------------------------------------------
    -- B2. Sinkronisasi alias legacy -> canonical.
    -- Tidak menimpa nilai canonical yang sudah terisi.
    -- ------------------------------------------------------------------------
    UPDATE cedex_damages
    SET damage_category = category
    WHERE damage_category IS NULL
      AND category IS NOT NULL;

    UPDATE cedex_damages
    SET default_inspection_reference_id = reference_parameter_id
    WHERE default_inspection_reference_id IS NULL
      AND reference_parameter_id IS NOT NULL;

    UPDATE inspection_test_parameters
    SET clause_section = reference_clause
    WHERE clause_section IS NULL
      AND reference_clause IS NOT NULL;

    UPDATE inspection_test_parameters
    SET expiry_date = expires_at
    WHERE expiry_date IS NULL
      AND expires_at IS NOT NULL;

    UPDATE inspection_test_parameters
    SET reference_attachment_file_id = attachment_file_id
    WHERE reference_attachment_file_id IS NULL
      AND attachment_file_id IS NOT NULL;

    UPDATE cedex_damage_decision_rules
    SET minimum_value = min_value
    WHERE minimum_value IS NULL
      AND min_value IS NOT NULL;

    UPDATE cedex_damage_decision_rules
    SET maximum_value = max_value
    WHERE maximum_value IS NULL
      AND max_value IS NOT NULL;

    UPDATE cedex_damage_decision_rules rule_item
    JOIN fitness_approval_categories approval_category
      ON approval_category.id = rule_item.approval_category_id
    SET rule_item.container_lifecycle = approval_category.container_lifecycle
    WHERE rule_item.container_lifecycle IS NULL
      AND rule_item.approval_category_id IS NOT NULL;

    INSERT INTO `_db19_patch_results`
        (object_name, result_status, detail)
    VALUES
        (
            'compatibility_alias_backfill',
            'APPLIED',
            'Nilai alias legacy disalin hanya ke field canonical yang masih NULL.'
        );

    -- ------------------------------------------------------------------------
    -- B3. Relasi attachment canonical pada Inspection Reference.
    -- DB19 sebelumnya memiliki index/FK pada attachment_file_id versi legacy.
    -- ------------------------------------------------------------------------
    CALL sp_db19_add_index(
        'inspection_test_parameters',
        'idx_inspection_test_parameters_reference_attachment',
        'CREATE INDEX idx_inspection_test_parameters_reference_attachment ON inspection_test_parameters(reference_attachment_file_id)'
    );

    SELECT COUNT(*)
      INTO v_invalid
    FROM inspection_test_parameters reference_item
    LEFT JOIN file_objects file_item
      ON file_item.id = reference_item.reference_attachment_file_id
    WHERE reference_item.reference_attachment_file_id IS NOT NULL
      AND file_item.id IS NULL;

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'inspection_test_parameters',
            'fk_inspection_test_parameters_reference_attachment',
            'ALTER TABLE inspection_test_parameters ADD CONSTRAINT fk_inspection_test_parameters_reference_attachment FOREIGN KEY (reference_attachment_file_id) REFERENCES file_objects(id)'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'fk_inspection_test_parameters_reference_attachment',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' reference_attachment_file_id tanpa file_objects.')
            );
    END IF;

    -- ------------------------------------------------------------------------
    -- B4. Validasi lifecycle Informasi Umum.
    -- ------------------------------------------------------------------------
    SELECT COUNT(*)
      INTO v_invalid
    FROM survey_general_infos
    WHERE container_lifecycle IS NOT NULL
      AND container_lifecycle NOT IN ('new', 'existing');

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'survey_general_infos',
            'chk_survey_general_infos_lifecycle',
            'ALTER TABLE survey_general_infos ADD CONSTRAINT chk_survey_general_infos_lifecycle CHECK (container_lifecycle IS NULL OR container_lifecycle IN (''new'',''existing''))'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_survey_general_infos_lifecycle',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' container_lifecycle tidak dikenal.')
            );
    END IF;

    -- ------------------------------------------------------------------------
    -- B5. Validasi status dan putaran Survey.
    -- ------------------------------------------------------------------------
    SELECT COUNT(*)
      INTO v_invalid
    FROM surveys
    WHERE status NOT IN (
        'draft',
        'submitted',
        'under_review',
        'need_revision',
        'resubmitted',
        'approved',
        'rejected',
        'cancelled'
    );

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'surveys',
            'chk_surveys_status',
            'ALTER TABLE surveys ADD CONSTRAINT chk_surveys_status CHECK (status IN (''draft'',''submitted'',''under_review'',''need_revision'',''resubmitted'',''approved'',''rejected'',''cancelled''))'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_surveys_status',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' status Survey di luar workflow source.')
            );
    END IF;

    SELECT COUNT(*)
      INTO v_invalid
    FROM surveys
    WHERE inspection_phase NOT IN ('initial', 'reinspection');

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'surveys',
            'chk_surveys_inspection_phase',
            'ALTER TABLE surveys ADD CONSTRAINT chk_surveys_inspection_phase CHECK (inspection_phase IN (''initial'',''reinspection''))'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_surveys_inspection_phase',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' inspection_phase tidak dikenal.')
            );
    END IF;

    SELECT COUNT(*)
      INTO v_invalid
    FROM surveys
    WHERE inspection_round_no < 1;

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'surveys',
            'chk_surveys_inspection_round',
            'ALTER TABLE surveys ADD CONSTRAINT chk_surveys_inspection_round CHECK (inspection_round_no >= 1)'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_surveys_inspection_round',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' inspection_round_no kurang dari 1.')
            );
    END IF;

    SELECT COUNT(*)
      INTO v_invalid
    FROM (
        SELECT
            job_container_id,
            survey_type_id,
            inspection_phase,
            inspection_round_no
        FROM surveys
        GROUP BY
            job_container_id,
            survey_type_id,
            inspection_phase,
            inspection_round_no
        HAVING COUNT(*) > 1
    ) duplicate_rounds;

    IF v_invalid = 0 THEN
        CALL sp_db19_add_index(
            'surveys',
            'uq_surveys_container_type_phase_round',
            'CREATE UNIQUE INDEX uq_surveys_container_type_phase_round ON surveys(job_container_id, survey_type_id, inspection_phase, inspection_round_no)'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'uq_surveys_container_type_phase_round',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' kombinasi Survey fase/putaran ganda.')
            );
    END IF;

    -- ------------------------------------------------------------------------
    -- B6. Decision Rule sesuai kontrak query repo.
    -- ------------------------------------------------------------------------
    SELECT COUNT(*)
      INTO v_invalid
    FROM cedex_damage_decision_rules
    WHERE inspection_reference_id IS NULL;

    IF v_invalid = 0 THEN
        SET @db19_column_nullable := (
            SELECT IS_NULLABLE
            FROM information_schema.COLUMNS
            WHERE TABLE_SCHEMA = DATABASE()
              AND TABLE_NAME = 'cedex_damage_decision_rules'
              AND COLUMN_NAME = 'inspection_reference_id'
            LIMIT 1
        );

        IF @db19_column_nullable = 'YES' THEN
            ALTER TABLE cedex_damage_decision_rules
                MODIFY COLUMN inspection_reference_id CHAR(36) NOT NULL;

            INSERT INTO `_db19_patch_results`
                (object_name, result_status, detail)
            VALUES
                (
                    'cedex_damage_decision_rules.inspection_reference_id',
                    'APPLIED',
                    'Kolom diselaraskan menjadi NOT NULL sesuai migration repo.'
                );
        ELSE
            INSERT INTO `_db19_patch_results`
                (object_name, result_status, detail)
            VALUES
                (
                    'cedex_damage_decision_rules.inspection_reference_id',
                    'SKIPPED',
                    'Kolom sudah NOT NULL.'
                );
        END IF;
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'cedex_damage_decision_rules.inspection_reference_id',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' Decision Rule tanpa Inspection Reference.')
            );
    END IF;

    SELECT COUNT(*)
      INTO v_invalid
    FROM cedex_damage_decision_rules
    WHERE measurement_field NOT IN (
        'length',
        'width',
        'depth',
        'thickness',
        'quantity',
        'area',
        'manual_assessment'
    );

    IF v_invalid = 0 THEN
        ALTER TABLE cedex_damage_decision_rules
            MODIFY COLUMN measurement_field
            VARCHAR(30) NOT NULL DEFAULT 'manual_assessment';

        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'cedex_damage_decision_rules.measurement_field',
                'APPLIED',
                'Default diselaraskan menjadi manual_assessment.'
            );

        CALL sp_db19_add_constraint(
            'cedex_damage_decision_rules',
            'chk_cedex_decision_rules_measurement',
            'ALTER TABLE cedex_damage_decision_rules ADD CONSTRAINT chk_cedex_decision_rules_measurement CHECK (measurement_field IN (''length'',''width'',''depth'',''thickness'',''quantity'',''area'',''manual_assessment''))'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_cedex_decision_rules_measurement',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' measurement_field tidak dikenal; data tidak diubah otomatis.')
            );
    END IF;

    SELECT COUNT(*)
      INTO v_invalid
    FROM cedex_damage_decision_rules
    WHERE container_lifecycle IS NOT NULL
      AND container_lifecycle NOT IN ('new', 'existing');

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'cedex_damage_decision_rules',
            'chk_cedex_decision_rules_lifecycle',
            'ALTER TABLE cedex_damage_decision_rules ADD CONSTRAINT chk_cedex_decision_rules_lifecycle CHECK (container_lifecycle IS NULL OR container_lifecycle IN (''new'',''existing''))'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_cedex_decision_rules_lifecycle',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' lifecycle Decision Rule tidak dikenal.')
            );
    END IF;

    SELECT COUNT(*)
      INTO v_invalid
    FROM cedex_damage_decision_rules
    WHERE comparison_operator NOT IN (
        'lt',
        'lte',
        'eq',
        'gt',
        'gte',
        'between',
        'manual'
    );

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'cedex_damage_decision_rules',
            'chk_cedex_decision_rules_operator',
            'ALTER TABLE cedex_damage_decision_rules ADD CONSTRAINT chk_cedex_decision_rules_operator CHECK (comparison_operator IN (''lt'',''lte'',''eq'',''gt'',''gte'',''between'',''manual''))'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_cedex_decision_rules_operator',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' comparison_operator tidak dikenal.')
            );
    END IF;

    SELECT COUNT(*)
      INTO v_invalid
    FROM cedex_damage_decision_rules
    WHERE decision_result NOT IN (
        'passed',
        'need_repair',
        'need_reinspection',
        'not_passed',
        'manual_review'
    );

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'cedex_damage_decision_rules',
            'chk_cedex_decision_rules_result',
            'ALTER TABLE cedex_damage_decision_rules ADD CONSTRAINT chk_cedex_decision_rules_result CHECK (decision_result IN (''passed'',''need_repair'',''need_reinspection'',''not_passed'',''manual_review''))'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_cedex_decision_rules_result',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' decision_result tidak dikenal.')
            );
    END IF;

    SELECT COUNT(*)
      INTO v_invalid
    FROM cedex_damage_decision_rules
    WHERE priority < 0;

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'cedex_damage_decision_rules',
            'chk_cedex_decision_rules_priority',
            'ALTER TABLE cedex_damage_decision_rules ADD CONSTRAINT chk_cedex_decision_rules_priority CHECK (priority >= 0)'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_cedex_decision_rules_priority',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' priority negatif.')
            );
    END IF;

    SELECT COUNT(*)
      INTO v_invalid
    FROM cedex_damage_decision_rules
    WHERE status NOT IN ('active', 'inactive');

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'cedex_damage_decision_rules',
            'chk_cedex_decision_rules_status',
            'ALTER TABLE cedex_damage_decision_rules ADD CONSTRAINT chk_cedex_decision_rules_status CHECK (status IN (''active'',''inactive''))'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_cedex_decision_rules_status',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' status Decision Rule tidak dikenal.')
            );
    END IF;

    -- ------------------------------------------------------------------------
    -- B7. Governance pengajuan kode CEDEX.
    -- ------------------------------------------------------------------------
    SELECT COUNT(*)
      INTO v_invalid
    FROM cedex_code_proposals
    WHERE code_type NOT IN (
        'location',
        'component',
        'damage',
        'action_repair',
        'material'
    );

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'cedex_code_proposals',
            'chk_cedex_code_proposals_type',
            'ALTER TABLE cedex_code_proposals ADD CONSTRAINT chk_cedex_code_proposals_type CHECK (code_type IN (''location'',''component'',''damage'',''action_repair'',''material''))'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_cedex_code_proposals_type',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' code_type proposal tidak dikenal.')
            );
    END IF;

    SELECT COUNT(*)
      INTO v_invalid
    FROM cedex_code_proposals
    WHERE status NOT IN ('pending', 'approved', 'rejected');

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'cedex_code_proposals',
            'chk_cedex_code_proposals_status',
            'ALTER TABLE cedex_code_proposals ADD CONSTRAINT chk_cedex_code_proposals_status CHECK (status IN (''pending'',''approved'',''rejected''))'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_cedex_code_proposals_status',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' status proposal tidak dikenal.')
            );
    END IF;

    -- ------------------------------------------------------------------------
    -- B8. Integritas histori revisi baru.
    -- Tidak melakukan backfill histori UAT lama karena snapshot asli tidak ada.
    -- ------------------------------------------------------------------------
    SELECT COUNT(*)
      INTO v_invalid
    FROM survey_revisions
    WHERE revision_no < 1;

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'survey_revisions',
            'chk_survey_revisions_revision_no',
            'ALTER TABLE survey_revisions ADD CONSTRAINT chk_survey_revisions_revision_no CHECK (revision_no >= 1)'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_survey_revisions_revision_no',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' revision_no kurang dari 1.')
            );
    END IF;

    SELECT COUNT(*)
      INTO v_invalid
    FROM survey_revisions
    WHERE status NOT IN (
        'requested',
        'resubmitted',
        'under_review',
        'superseded',
        'approved',
        'rejected'
    );

    IF v_invalid = 0 THEN
        CALL sp_db19_add_constraint(
            'survey_revisions',
            'chk_survey_revisions_status',
            'ALTER TABLE survey_revisions ADD CONSTRAINT chk_survey_revisions_status CHECK (status IN (''requested'',''resubmitted'',''under_review'',''superseded'',''approved'',''rejected''))'
        );
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'chk_survey_revisions_status',
                'BLOCKED',
                CONCAT('Ditemukan ', v_invalid, ' status histori revisi tidak dikenal.')
            );
    END IF;

    -- ------------------------------------------------------------------------
    -- B9. Permission utama.
    -- ------------------------------------------------------------------------
    SELECT COUNT(*)
      INTO v_invalid
    FROM (
        SELECT 'survey_photos.delete.assigned' AS code
        UNION ALL SELECT 'cedex_code_proposals.view.all'
        UNION ALL SELECT 'cedex_code_proposals.review.all'
        UNION ALL SELECT 'surveys.view.assigned'
        UNION ALL SELECT 'surveys.update.assigned'
        UNION ALL SELECT 'reviews.manage.all'
    ) required_permission
    LEFT JOIN permissions permission_item
      ON permission_item.code = required_permission.code
    WHERE permission_item.id IS NULL;

    IF v_invalid = 0 THEN
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            ('permissions.runtime_required', 'PASS', 'Permission runtime utama tersedia.');
    ELSE
        INSERT INTO `_db19_patch_results`
            (object_name, result_status, detail)
        VALUES
            (
                'permissions.runtime_required',
                'BLOCKED',
                CONCAT('Terdapat ', v_invalid, ' permission runtime yang belum tersedia.')
            );
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed
