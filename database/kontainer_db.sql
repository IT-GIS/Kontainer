-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jun 30, 2026 at 08:46 AM
-- Server version: 8.4.3
-- PHP Version: 8.3.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `kontainer_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `assignments`
--

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
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `assignment_containers`
--

CREATE TABLE `assignment_containers` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `assignment_id` char(36) NOT NULL,
  `job_container_id` char(36) NOT NULL,
  `assigned_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `unassigned_at` datetime(6) DEFAULT NULL,
  `unassigned_reason` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

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
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `user_id`, `active_role`, `action`, `entity_type`, `entity_id`, `old_state`, `new_state`, `old_value`, `new_value`, `reason`, `request_id`, `ip_address`, `user_agent`, `created_at`) VALUES
('3c2c23e3-7385-11f1-ac50-002b67818c25', '00000000-0000-0000-0000-000000000001', 'super_admin', 'auth.login_success', 'auth', NULL, NULL, NULL, NULL, NULL, NULL, '971018841986695fe355b950296994c1', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-29 13:39:10.256537'),
('58610dd5-738c-11f1-ac50-002b67818c25', '00000000-0000-0000-0000-000000000001', 'super_admin', 'auth.login_success', 'auth', NULL, NULL, NULL, NULL, NULL, NULL, '785e358b96653181b77ad8b59d8073b0', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.126.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36', '2026-06-29 14:30:04.056611'),
('5c086242-738c-11f1-ac50-002b67818c25', '00000000-0000-0000-0000-000000000001', 'super_admin', 'auth.login_success', 'auth', NULL, NULL, NULL, NULL, NULL, NULL, '52feb81954d1618bd2ad9a1995ef026e', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-29 14:30:10.186369'),
('e8811de7-745c-11f1-806f-002b67818c25', '00000000-0000-0000-0000-000000000001', 'super_admin', 'auth.login_success', 'auth', NULL, NULL, NULL, NULL, NULL, NULL, '53a52b5ffe9cebe5ee48bc1c6f6b5b51', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.126.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36', '2026-06-30 15:23:01.178463'),
('f4775999-745c-11f1-806f-002b67818c25', '00000000-0000-0000-0000-000000000001', 'super_admin', 'auth.login_success', 'auth', NULL, NULL, NULL, NULL, NULL, NULL, '4586be383d5fd963bfc5a782b4a2449c', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-06-30 15:23:21.247083');

-- --------------------------------------------------------

--
-- Table structure for table `cedex_components`
--

CREATE TABLE `cedex_components` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(30) NOT NULL,
  `component_name` varchar(150) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ;

--
-- Dumping data for table `cedex_components`
--

INSERT INTO `cedex_components` (`id`, `code`, `component_name`, `description`, `status`, `created_at`, `updated_at`) VALUES
('3f2c9272-737f-11f1-ac50-002b67818c25', 'SP', 'Side Panel', 'Side panel', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2c98e3-737f-11f1-ac50-002b67818c25', 'RP', 'Roof Panel', 'Roof panel', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2c9ab8-737f-11f1-ac50-002b67818c25', 'FP', 'Front Panel', 'Front panel', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2c9bb5-737f-11f1-ac50-002b67818c25', 'DP', 'Door Panel', 'Door panel', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2c9ca0-737f-11f1-ac50-002b67818c25', 'DG', 'Door Gasket', 'Door gasket', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2c9dd7-737f-11f1-ac50-002b67818c25', 'LB', 'Locking Bar', 'Locking bar', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2c9ecb-737f-11f1-ac50-002b67818c25', 'CK', 'Cam Keeper', 'Cam keeper', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2c9fbe-737f-11f1-ac50-002b67818c25', 'FB', 'Floor Board', 'Floor board', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2ca0b2-737f-11f1-ac50-002b67818c25', 'CM', 'Cross Member', 'Cross member', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2ca194-737f-11f1-ac50-002b67818c25', 'CP', 'Corner Post', 'Corner post', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2ca2ab-737f-11f1-ac50-002b67818c25', 'CC', 'Corner Casting', 'Corner casting', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2ca393-737f-11f1-ac50-002b67818c25', 'BSR', 'Bottom Side Rail', 'Bottom side rail', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2ca482-737f-11f1-ac50-002b67818c25', 'TSR', 'Top Side Rail', 'Top side rail', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2ca5b8-737f-11f1-ac50-002b67818c25', 'FKP', 'Forklift Pocket', 'Forklift pocket', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2ca695-737f-11f1-ac50-002b67818c25', 'VN', 'Ventilator', 'Ventilator', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693'),
('3f2ca78d-737f-11f1-ac50-002b67818c25', 'CSC', 'CSC Plate', 'CSC plate', 'active', '2026-06-29 05:56:18.311693', '2026-06-29 05:56:18.311693');

-- --------------------------------------------------------

--
-- Table structure for table `cedex_damages`
--

CREATE TABLE `cedex_damages` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(30) NOT NULL,
  `damage_name` varchar(150) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ;

--
-- Dumping data for table `cedex_damages`
--

INSERT INTO `cedex_damages` (`id`, `code`, `damage_name`, `description`, `status`, `created_at`, `updated_at`) VALUES
('3f2d67ba-737f-11f1-ac50-002b67818c25', 'DT', 'Dent', 'Dent', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d6c10-737f-11f1-ac50-002b67818c25', 'HL', 'Hole', 'Hole', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d6d75-737f-11f1-ac50-002b67818c25', 'CR', 'Crack', 'Crack', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d6e64-737f-11f1-ac50-002b67818c25', 'BN', 'Bent', 'Bent', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d6f5c-737f-11f1-ac50-002b67818c25', 'BR', 'Broken', 'Broken', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d7095-737f-11f1-ac50-002b67818c25', 'MS', 'Missing', 'Missing', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d7190-737f-11f1-ac50-002b67818c25', 'RS', 'Rust', 'Rust', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d72aa-737f-11f1-ac50-002b67818c25', 'CO', 'Corrosion', 'Corrosion', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d7394-737f-11f1-ac50-002b67818c25', 'TO', 'Torn', 'Torn', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d7472-737f-11f1-ac50-002b67818c25', 'LS', 'Loose', 'Loose', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d75c7-737f-11f1-ac50-002b67818c25', 'DY', 'Dirty', 'Dirty', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d7711-737f-11f1-ac50-002b67818c25', 'WT', 'Wet', 'Wet', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d786f-737f-11f1-ac50-002b67818c25', 'OD', 'Odor', 'Odor', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d79ac-737f-11f1-ac50-002b67818c25', 'OS', 'Oil Stain', 'Oil stain', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d7af6-737f-11f1-ac50-002b67818c25', 'BM', 'Burn Mark', 'Burn mark', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d7c5a-737f-11f1-ac50-002b67818c25', 'DL', 'Delamination', 'Delamination', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d7dad-737f-11f1-ac50-002b67818c25', 'LK', 'Leakage', 'Leakage', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187'),
('3f2d7f06-737f-11f1-ac50-002b67818c25', 'IR', 'Improper Repair', 'Improper repair', 'active', '2026-06-29 05:56:18.317187', '2026-06-29 05:56:18.317187');

-- --------------------------------------------------------

--
-- Table structure for table `cedex_locations`
--

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
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ;

--
-- Dumping data for table `cedex_locations`
--

INSERT INTO `cedex_locations` (`id`, `code`, `face`, `grid_code`, `cedex_mapping_code`, `container_size`, `description`, `display_order`, `status`, `created_at`, `updated_at`) VALUES
('3f2bf1dd-737f-11f1-ac50-002b67818c25', 'L1', 'left', 'L1', NULL, 'all', 'Left side section 1', 1, 'active', '2026-06-29 05:56:18.307557', '2026-06-29 05:56:18.307557'),
('3f2bf6b4-737f-11f1-ac50-002b67818c25', 'L2', 'left', 'L2', NULL, 'all', 'Left side section 2', 2, 'active', '2026-06-29 05:56:18.307557', '2026-06-29 05:56:18.307557'),
('3f2bf871-737f-11f1-ac50-002b67818c25', 'L3', 'left', 'L3', NULL, 'all', 'Left side section 3', 3, 'active', '2026-06-29 05:56:18.307557', '2026-06-29 05:56:18.307557'),
('3f2bfa0f-737f-11f1-ac50-002b67818c25', 'R1', 'right', 'R1', NULL, 'all', 'Right side section 1', 1, 'active', '2026-06-29 05:56:18.307557', '2026-06-29 05:56:18.307557'),
('3f2bfb50-737f-11f1-ac50-002b67818c25', 'R2', 'right', 'R2', NULL, 'all', 'Right side section 2', 2, 'active', '2026-06-29 05:56:18.307557', '2026-06-29 05:56:18.307557'),
('3f2bfca8-737f-11f1-ac50-002b67818c25', 'D1', 'door', 'D1', NULL, 'all', 'Door end section 1', 1, 'active', '2026-06-29 05:56:18.307557', '2026-06-29 05:56:18.307557'),
('3f2bfdde-737f-11f1-ac50-002b67818c25', 'F1', 'front', 'F1', NULL, 'all', 'Front end section 1', 1, 'active', '2026-06-29 05:56:18.307557', '2026-06-29 05:56:18.307557'),
('3f2bfef8-737f-11f1-ac50-002b67818c25', 'T1', 'roof', 'T1', NULL, 'all', 'Roof section 1', 1, 'active', '2026-06-29 05:56:18.307557', '2026-06-29 05:56:18.307557'),
('3f2c003a-737f-11f1-ac50-002b67818c25', 'FL1', 'floor', 'FL1', NULL, 'all', 'Floor section 1', 1, 'active', '2026-06-29 05:56:18.307557', '2026-06-29 05:56:18.307557'),
('3f2c0168-737f-11f1-ac50-002b67818c25', 'U1', 'understructure', 'U1', NULL, 'all', 'Understructure section 1', 1, 'active', '2026-06-29 05:56:18.307557', '2026-06-29 05:56:18.307557');

-- --------------------------------------------------------

--
-- Table structure for table `cedex_materials`
--

CREATE TABLE `cedex_materials` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(30) NOT NULL,
  `material_name` varchar(150) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ;

--
-- Dumping data for table `cedex_materials`
--

INSERT INTO `cedex_materials` (`id`, `code`, `material_name`, `description`, `status`, `created_at`, `updated_at`) VALUES
('3f2f3f44-737f-11f1-ac50-002b67818c25', 'STL', 'Steel', 'Steel', 'active', '2026-06-29 05:56:18.329122', '2026-06-29 05:56:18.329122'),
('3f2f4501-737f-11f1-ac50-002b67818c25', 'AL', 'Aluminium', 'Aluminium', 'active', '2026-06-29 05:56:18.329122', '2026-06-29 05:56:18.329122'),
('3f2f4761-737f-11f1-ac50-002b67818c25', 'PLY', 'Plywood', 'Plywood', 'active', '2026-06-29 05:56:18.329122', '2026-06-29 05:56:18.329122'),
('3f2f4928-737f-11f1-ac50-002b67818c25', 'RUB', 'Rubber', 'Rubber', 'active', '2026-06-29 05:56:18.329122', '2026-06-29 05:56:18.329122'),
('3f2f4af7-737f-11f1-ac50-002b67818c25', 'PLS', 'Plastic', 'Plastic', 'active', '2026-06-29 05:56:18.329122', '2026-06-29 05:56:18.329122');

-- --------------------------------------------------------

--
-- Table structure for table `cedex_repairs`
--

CREATE TABLE `cedex_repairs` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(30) NOT NULL,
  `repair_name` varchar(150) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ;

--
-- Dumping data for table `cedex_repairs`
--

INSERT INTO `cedex_repairs` (`id`, `code`, `repair_name`, `description`, `status`, `created_at`, `updated_at`) VALUES
('3f2e0abd-737f-11f1-ac50-002b67818c25', 'NR', 'No Repair', 'No repair', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362'),
('3f2e10bc-737f-11f1-ac50-002b67818c25', 'ST', 'Straighten', 'Straighten', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362'),
('3f2e1254-737f-11f1-ac50-002b67818c25', 'WD', 'Weld', 'Weld', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362'),
('3f2e135a-737f-11f1-ac50-002b67818c25', 'PT', 'Patch', 'Patch', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362'),
('3f2e144d-737f-11f1-ac50-002b67818c25', 'RP', 'Replace', 'Replace', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362'),
('3f2e1542-737f-11f1-ac50-002b67818c25', 'RF', 'Refit', 'Refit', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362'),
('3f2e1624-737f-11f1-ac50-002b67818c25', 'CL', 'Clean', 'Clean', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362'),
('3f2e1705-737f-11f1-ac50-002b67818c25', 'DR', 'Drying', 'Drying', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362'),
('3f2e17ee-737f-11f1-ac50-002b67818c25', 'GR', 'Grinding', 'Grinding', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362'),
('3f2e18e2-737f-11f1-ac50-002b67818c25', 'PN', 'Painting', 'Painting', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362'),
('3f2e19c4-737f-11f1-ac50-002b67818c25', 'SL', 'Sealant', 'Sealant', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362'),
('3f2e1aea-737f-11f1-ac50-002b67818c25', 'TG', 'Tighten', 'Tighten', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362'),
('3f2e1bd7-737f-11f1-ac50-002b67818c25', 'RM', 'Remove', 'Remove', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362'),
('3f2e1cc2-737f-11f1-ac50-002b67818c25', 'RI', 'Reinstall', 'Reinstall', 'active', '2026-06-29 05:56:18.321362', '2026-06-29 05:56:18.321362');

-- --------------------------------------------------------

--
-- Table structure for table `company_profiles`
--

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
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `company_profiles`
--

INSERT INTO `company_profiles` (`id`, `company_name`, `brand_name`, `address`, `phone`, `email`, `website`, `tax_no`, `logo_file_id`, `default_signature_file_id`, `is_active`, `created_at`, `updated_at`) VALUES
('3f2932cb-737f-11f1-ac50-002b67818c25', 'PT Global Inspeksi Sertifikasi Group', 'GIFT', NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, '2026-06-29 05:56:18.289455', '2026-06-29 05:56:18.289455');

-- --------------------------------------------------------

--
-- Table structure for table `container_import_batches`
--

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
  `imported_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `container_types`
--

CREATE TABLE `container_types` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(30) NOT NULL,
  `iso_code` varchar(20) DEFAULT NULL,
  `size` varchar(50) NOT NULL,
  `type_name` varchar(100) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ;

--
-- Dumping data for table `container_types`
--

INSERT INTO `container_types` (`id`, `code`, `iso_code`, `size`, `type_name`, `description`, `status`, `created_at`, `updated_at`) VALUES
('3f2a7725-737f-11f1-ac50-002b67818c25', '20GP', '22G1', '20 Feet', 'General Purpose', 'Dry container 20 feet', 'active', '2026-06-29 05:56:18.297704', '2026-06-29 05:56:18.297704'),
('3f2a7dc9-737f-11f1-ac50-002b67818c25', '40GP', '42G1', '40 Feet', 'General Purpose', 'Dry container 40 feet', 'active', '2026-06-29 05:56:18.297704', '2026-06-29 05:56:18.297704'),
('3f2a8082-737f-11f1-ac50-002b67818c25', '40HC', '45G1', '40 Feet', 'High Cube', 'High cube dry container 40 feet', 'active', '2026-06-29 05:56:18.297704', '2026-06-29 05:56:18.297704'),
('3f2a822a-737f-11f1-ac50-002b67818c25', '20RF', '22R1', '20 Feet', 'Reefer', 'Refrigerated container 20 feet', 'active', '2026-06-29 05:56:18.297704', '2026-06-29 05:56:18.297704'),
('3f2a83b5-737f-11f1-ac50-002b67818c25', '40RF', '45R1', '40 Feet', 'Reefer', 'Refrigerated container 40 feet', 'active', '2026-06-29 05:56:18.297704', '2026-06-29 05:56:18.297704'),
('3f2a854b-737f-11f1-ac50-002b67818c25', '20OT', NULL, '20 Feet', 'Open Top', 'Open top container 20 feet', 'active', '2026-06-29 05:56:18.297704', '2026-06-29 05:56:18.297704'),
('3f2a86c7-737f-11f1-ac50-002b67818c25', '40OT', NULL, '40 Feet', 'Open Top', 'Open top container 40 feet', 'active', '2026-06-29 05:56:18.297704', '2026-06-29 05:56:18.297704'),
('3f2a8857-737f-11f1-ac50-002b67818c25', '20FR', NULL, '20 Feet', 'Flat Rack', 'Flat rack container 20 feet', 'active', '2026-06-29 05:56:18.297704', '2026-06-29 05:56:18.297704'),
('3f2a89dc-737f-11f1-ac50-002b67818c25', '40FR', NULL, '40 Feet', 'Flat Rack', 'Flat rack container 40 feet', 'active', '2026-06-29 05:56:18.297704', '2026-06-29 05:56:18.297704'),
('3f2a8b64-737f-11f1-ac50-002b67818c25', 'TANK', NULL, 'Tank', 'Tank Container', 'Tank container', 'active', '2026-06-29 05:56:18.297704', '2026-06-29 05:56:18.297704');

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

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
  `deleted_at` datetime(6) DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `file_objects`
--

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
  `deleted_at` datetime(6) DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `invoices`
--

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
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `invoice_items`
--

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
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_containers`
--

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
  CONSTRAINT `chk_job_containers_status` CHECK ((`status` in (_utf8mb4'not_started',_utf8mb4'assigned',_utf8mb4'in_progress',_utf8mb4'draft',_utf8mb4'submitted',_utf8mb4'need_revision',_utf8mb4'approved',_utf8mb4'rejected',_utf8mb4'reported',_utf8mb4'invoiced',_utf8mb4'closed',_utf8mb4'cancelled')))
) ;

-- --------------------------------------------------------

--
-- Table structure for table `job_events`
--

CREATE TABLE `job_events` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `job_order_id` char(36) NOT NULL,
  `event_type` varchar(100) NOT NULL,
  `event_title` varchar(200) NOT NULL,
  `event_description` text,
  `actor_id` char(36) DEFAULT NULL,
  `metadata` json DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_orders`
--

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
  `deleted_at` datetime(6) DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `locations`
--

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
  `deleted_at` datetime(6) DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `numbering_sequences`
--

CREATE TABLE `numbering_sequences` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `document_type` varchar(50) NOT NULL,
  `period_key` varchar(20) NOT NULL,
  `last_number` bigint NOT NULL DEFAULT '0',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ;

-- --------------------------------------------------------

--
-- Table structure for table `numbering_settings`
--

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
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ;

--
-- Dumping data for table `numbering_settings`
--

INSERT INTO `numbering_settings` (`id`, `document_type`, `prefix`, `doc_code`, `year_format`, `running_digits`, `reset_period`, `format_preview`, `is_active`, `created_at`, `updated_at`) VALUES
('3f29c8ab-737f-11f1-ac50-002b67818c25', 'job_order', 'GIFT', 'JO', 'YYYY', 6, 'yearly', 'GIFT-JO-2026-000001', 1, '2026-06-29 05:56:18.293517', '2026-06-29 05:56:18.293517'),
('3f29cdbd-737f-11f1-ac50-002b67818c25', 'assignment', 'GIFT', 'ASG', 'YYYY', 6, 'yearly', 'GIFT-ASG-2026-000001', 1, '2026-06-29 05:56:18.293517', '2026-06-29 05:56:18.293517'),
('3f29cf0f-737f-11f1-ac50-002b67818c25', 'survey', 'GIFT', 'SVY', 'YYYY', 6, 'yearly', 'GIFT-SVY-2026-000001', 1, '2026-06-29 05:56:18.293517', '2026-06-29 05:56:18.293517'),
('3f29cff7-737f-11f1-ac50-002b67818c25', 'report', 'GIFT', 'RPT', 'YYYY', 6, 'yearly', 'GIFT-RPT-2026-000001', 1, '2026-06-29 05:56:18.293517', '2026-06-29 05:56:18.293517'),
('3f29d133-737f-11f1-ac50-002b67818c25', 'eir', 'GIFT', 'EIR', 'YYYY', 6, 'yearly', 'GIFT-EIR-2026-000001', 1, '2026-06-29 05:56:18.293517', '2026-06-29 05:56:18.293517'),
('3f29d20d-737f-11f1-ac50-002b67818c25', 'invoice', 'GIFT', 'INV', 'YYYY', 6, 'yearly', 'GIFT-INV-2026-000001', 1, '2026-06-29 05:56:18.293517', '2026-06-29 05:56:18.293517'),
('3f29d304-737f-11f1-ac50-002b67818c25', 'payment_receipt', 'GIFT', 'RCP', 'YYYY', 6, 'yearly', 'GIFT-RCP-2026-000001', 1, '2026-06-29 05:56:18.293517', '2026-06-29 05:56:18.293517');

-- --------------------------------------------------------

--
-- Table structure for table `payments`
--

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
  `cancel_reason` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `permissions`
--

CREATE TABLE `permissions` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(120) NOT NULL,
  `name` varchar(150) DEFAULT NULL,
  `module` varchar(80) NOT NULL,
  `action` varchar(50) NOT NULL,
  `scope` varchar(50) NOT NULL DEFAULT 'all',
  `description` text
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `permissions`
--

INSERT INTO `permissions` (`id`, `code`, `name`, `module`, `action`, `scope`, `description`) VALUES
('3f277c21-737f-11f1-ac50-002b67818c25', '*.*.all', NULL, '*', '*', 'all', 'Wildcard permission for super admin'),
('3f2781d5-737f-11f1-ac50-002b67818c25', 'users.manage.all', NULL, 'users', 'manage', 'all', 'Manage users'),
('3f2783be-737f-11f1-ac50-002b67818c25', 'roles.manage.all', NULL, 'roles', 'manage', 'all', 'Manage roles and permissions'),
('3f2784b7-737f-11f1-ac50-002b67818c25', 'company_profiles.manage.all', NULL, 'company_profiles', 'manage', 'all', 'Manage company profile'),
('3f2785a1-737f-11f1-ac50-002b67818c25', 'numbering_settings.manage.all', NULL, 'numbering_settings', 'manage', 'all', 'Manage numbering settings'),
('3f278684-737f-11f1-ac50-002b67818c25', 'files.manage.all', NULL, 'files', 'manage', 'all', 'Manage file metadata'),
('3f278768-737f-11f1-ac50-002b67818c25', 'customers.manage.all', NULL, 'customers', 'manage', 'all', 'Manage customers'),
('3f278858-737f-11f1-ac50-002b67818c25', 'locations.manage.all', NULL, 'locations', 'manage', 'all', 'Manage locations'),
('3f27896c-737f-11f1-ac50-002b67818c25', 'surveyor_profiles.manage.all', NULL, 'surveyor_profiles', 'manage', 'all', 'Manage surveyor profiles'),
('3f278a4e-737f-11f1-ac50-002b67818c25', 'surveyor_profiles.view.own', NULL, 'surveyor_profiles', 'view', 'own', 'View own surveyor profile'),
('3f278b9f-737f-11f1-ac50-002b67818c25', 'container_types.manage.all', NULL, 'container_types', 'manage', 'all', 'Manage container types'),
('3f278c8d-737f-11f1-ac50-002b67818c25', 'survey_types.manage.all', NULL, 'survey_types', 'manage', 'all', 'Manage survey types'),
('3f278d74-737f-11f1-ac50-002b67818c25', 'cedex.manage.all', NULL, 'cedex', 'manage', 'all', 'Manage CEDEX master data'),
('3f278e50-737f-11f1-ac50-002b67818c25', 'master_data.view.all', NULL, 'master_data', 'view', 'all', 'View master data'),
('3f278f3f-737f-11f1-ac50-002b67818c25', 'dashboard.view.all', NULL, 'dashboard', 'view', 'all', 'View dashboards'),
('3f426ad5-737f-11f1-ac50-002b67818c25', 'customers.view.all', NULL, 'customers', 'view', 'all', 'View customers'),
('3f4270e3-737f-11f1-ac50-002b67818c25', 'customers.create.all', NULL, 'customers', 'create', 'all', 'Create customers'),
('3f4272f3-737f-11f1-ac50-002b67818c25', 'customers.update.all', NULL, 'customers', 'update', 'all', 'Update customers'),
('3f4274ea-737f-11f1-ac50-002b67818c25', 'customers.delete.all', NULL, 'customers', 'delete', 'all', 'Deactivate customers'),
('3f4276b0-737f-11f1-ac50-002b67818c25', 'locations.view.all', NULL, 'locations', 'view', 'all', 'View locations'),
('3f42781c-737f-11f1-ac50-002b67818c25', 'locations.create.all', NULL, 'locations', 'create', 'all', 'Create locations'),
('3f427971-737f-11f1-ac50-002b67818c25', 'locations.update.all', NULL, 'locations', 'update', 'all', 'Update locations'),
('3f427ad4-737f-11f1-ac50-002b67818c25', 'locations.delete.all', NULL, 'locations', 'delete', 'all', 'Deactivate locations'),
('3f427c3c-737f-11f1-ac50-002b67818c25', 'surveyors.view.all', NULL, 'surveyors', 'view', 'all', 'View surveyor profiles'),
('3f427e26-737f-11f1-ac50-002b67818c25', 'surveyors.create.all', NULL, 'surveyors', 'create', 'all', 'Create surveyor profiles'),
('3f428028-737f-11f1-ac50-002b67818c25', 'surveyors.update.all', NULL, 'surveyors', 'update', 'all', 'Update surveyor profiles'),
('3f4281cd-737f-11f1-ac50-002b67818c25', 'surveyors.delete.all', NULL, 'surveyors', 'delete', 'all', 'Deactivate surveyor profiles'),
('3f428365-737f-11f1-ac50-002b67818c25', 'container_types.view.all', NULL, 'container_types', 'view', 'all', 'View container types'),
('3f4284d5-737f-11f1-ac50-002b67818c25', 'container_types.create.all', NULL, 'container_types', 'create', 'all', 'Create container types'),
('3f42863f-737f-11f1-ac50-002b67818c25', 'container_types.update.all', NULL, 'container_types', 'update', 'all', 'Update container types'),
('3f4287a5-737f-11f1-ac50-002b67818c25', 'container_types.delete.all', NULL, 'container_types', 'delete', 'all', 'Deactivate container types'),
('3f42892f-737f-11f1-ac50-002b67818c25', 'survey_types.view.all', NULL, 'survey_types', 'view', 'all', 'View survey types'),
('3f428a67-737f-11f1-ac50-002b67818c25', 'survey_types.create.all', NULL, 'survey_types', 'create', 'all', 'Create survey types'),
('3f428b52-737f-11f1-ac50-002b67818c25', 'survey_types.update.all', NULL, 'survey_types', 'update', 'all', 'Update survey types'),
('3f428c36-737f-11f1-ac50-002b67818c25', 'survey_types.delete.all', NULL, 'survey_types', 'delete', 'all', 'Deactivate survey types'),
('3f428d2c-737f-11f1-ac50-002b67818c25', 'cedex_locations.view.all', NULL, 'cedex_locations', 'view', 'all', 'View CEDEX locations'),
('3f428fac-737f-11f1-ac50-002b67818c25', 'cedex_locations.create.all', NULL, 'cedex_locations', 'create', 'all', 'Create CEDEX locations'),
('3f4290f4-737f-11f1-ac50-002b67818c25', 'cedex_locations.update.all', NULL, 'cedex_locations', 'update', 'all', 'Update CEDEX locations'),
('3f429218-737f-11f1-ac50-002b67818c25', 'cedex_locations.delete.all', NULL, 'cedex_locations', 'delete', 'all', 'Deactivate CEDEX locations'),
('3f429301-737f-11f1-ac50-002b67818c25', 'cedex_components.view.all', NULL, 'cedex_components', 'view', 'all', 'View CEDEX components'),
('3f4293ea-737f-11f1-ac50-002b67818c25', 'cedex_components.create.all', NULL, 'cedex_components', 'create', 'all', 'Create CEDEX components'),
('3f4294d1-737f-11f1-ac50-002b67818c25', 'cedex_components.update.all', NULL, 'cedex_components', 'update', 'all', 'Update CEDEX components'),
('3f4295e8-737f-11f1-ac50-002b67818c25', 'cedex_components.delete.all', NULL, 'cedex_components', 'delete', 'all', 'Deactivate CEDEX components'),
('3f429730-737f-11f1-ac50-002b67818c25', 'cedex_damages.view.all', NULL, 'cedex_damages', 'view', 'all', 'View CEDEX damages'),
('3f429832-737f-11f1-ac50-002b67818c25', 'cedex_damages.create.all', NULL, 'cedex_damages', 'create', 'all', 'Create CEDEX damages'),
('3f429945-737f-11f1-ac50-002b67818c25', 'cedex_damages.update.all', NULL, 'cedex_damages', 'update', 'all', 'Update CEDEX damages'),
('3f429a6c-737f-11f1-ac50-002b67818c25', 'cedex_damages.delete.all', NULL, 'cedex_damages', 'delete', 'all', 'Deactivate CEDEX damages'),
('3f429b59-737f-11f1-ac50-002b67818c25', 'cedex_repairs.view.all', NULL, 'cedex_repairs', 'view', 'all', 'View CEDEX repairs'),
('3f429c43-737f-11f1-ac50-002b67818c25', 'cedex_repairs.create.all', NULL, 'cedex_repairs', 'create', 'all', 'Create CEDEX repairs'),
('3f429d21-737f-11f1-ac50-002b67818c25', 'cedex_repairs.update.all', NULL, 'cedex_repairs', 'update', 'all', 'Update CEDEX repairs'),
('3f429e2c-737f-11f1-ac50-002b67818c25', 'cedex_repairs.delete.all', NULL, 'cedex_repairs', 'delete', 'all', 'Deactivate CEDEX repairs'),
('3f429f1b-737f-11f1-ac50-002b67818c25', 'cedex_materials.view.all', NULL, 'cedex_materials', 'view', 'all', 'View CEDEX materials'),
('3f429ffd-737f-11f1-ac50-002b67818c25', 'cedex_materials.create.all', NULL, 'cedex_materials', 'create', 'all', 'Create CEDEX materials'),
('3f42a0f3-737f-11f1-ac50-002b67818c25', 'cedex_materials.update.all', NULL, 'cedex_materials', 'update', 'all', 'Update CEDEX materials'),
('3f42a1df-737f-11f1-ac50-002b67818c25', 'cedex_materials.delete.all', NULL, 'cedex_materials', 'delete', 'all', 'Deactivate CEDEX materials'),
('3f42a2cb-737f-11f1-ac50-002b67818c25', 'responsibility_codes.view.all', NULL, 'responsibility_codes', 'view', 'all', 'View responsibility codes'),
('3f42a435-737f-11f1-ac50-002b67818c25', 'responsibility_codes.create.all', NULL, 'responsibility_codes', 'create', 'all', 'Create responsibility codes'),
('3f42a533-737f-11f1-ac50-002b67818c25', 'responsibility_codes.update.all', NULL, 'responsibility_codes', 'update', 'all', 'Update responsibility codes'),
('3f42a628-737f-11f1-ac50-002b67818c25', 'responsibility_codes.delete.all', NULL, 'responsibility_codes', 'delete', 'all', 'Deactivate responsibility codes'),
('3f42a715-737f-11f1-ac50-002b67818c25', 'cedex_locations.manage.all', NULL, 'cedex_locations', 'manage', 'all', 'Manage CEDEX locations'),
('3f42a80d-737f-11f1-ac50-002b67818c25', 'cedex_components.manage.all', NULL, 'cedex_components', 'manage', 'all', 'Manage CEDEX components'),
('3f42a903-737f-11f1-ac50-002b67818c25', 'cedex_damages.manage.all', NULL, 'cedex_damages', 'manage', 'all', 'Manage CEDEX damages'),
('3f42a9ed-737f-11f1-ac50-002b67818c25', 'cedex_repairs.manage.all', NULL, 'cedex_repairs', 'manage', 'all', 'Manage CEDEX repairs'),
('3f42aaef-737f-11f1-ac50-002b67818c25', 'cedex_materials.manage.all', NULL, 'cedex_materials', 'manage', 'all', 'Manage CEDEX materials'),
('3f42abe3-737f-11f1-ac50-002b67818c25', 'responsibility_codes.manage.all', NULL, 'responsibility_codes', 'manage', 'all', 'Manage responsibility codes'),
('3f42acea-737f-11f1-ac50-002b67818c25', 'surveyors.manage.all', NULL, 'surveyors', 'manage', 'all', 'Manage surveyor profiles'),
('3fa60b5a-737f-11f1-ac50-002b67818c25', 'jobs.view.all', NULL, 'jobs', 'view', 'all', 'View jobs'),
('3fa60f39-737f-11f1-ac50-002b67818c25', 'jobs.create.all', NULL, 'jobs', 'create', 'all', 'Create jobs'),
('3fa610e1-737f-11f1-ac50-002b67818c25', 'jobs.update.all', NULL, 'jobs', 'update', 'all', 'Update jobs'),
('3fa611dc-737f-11f1-ac50-002b67818c25', 'jobs.cancel.all', NULL, 'jobs', 'cancel', 'all', 'Cancel jobs'),
('3fa612c5-737f-11f1-ac50-002b67818c25', 'jobs.manage.all', NULL, 'jobs', 'manage', 'all', 'Manage jobs'),
('3fa613ad-737f-11f1-ac50-002b67818c25', 'job_containers.view.all', NULL, 'job_containers', 'view', 'all', 'View job containers'),
('3fa6149e-737f-11f1-ac50-002b67818c25', 'job_containers.create.all', NULL, 'job_containers', 'create', 'all', 'Create job containers'),
('3fa61581-737f-11f1-ac50-002b67818c25', 'job_containers.import.all', NULL, 'job_containers', 'import', 'all', 'Import job containers'),
('3fa616b5-737f-11f1-ac50-002b67818c25', 'job_containers.update.all', NULL, 'job_containers', 'update', 'all', 'Update job containers'),
('3fa617a5-737f-11f1-ac50-002b67818c25', 'job_containers.delete.all', NULL, 'job_containers', 'delete', 'all', 'Delete job containers'),
('3fa6188d-737f-11f1-ac50-002b67818c25', 'job_containers.reassign.all', NULL, 'job_containers', 'reassign', 'all', 'Reassign job containers'),
('3fa61982-737f-11f1-ac50-002b67818c25', 'assignments.view.all', NULL, 'assignments', 'view', 'all', 'View assignments'),
('3fa61a5d-737f-11f1-ac50-002b67818c25', 'assignments.assign.all', NULL, 'assignments', 'assign', 'all', 'Assign surveyors'),
('3fa61b60-737f-11f1-ac50-002b67818c25', 'assignments.reassign.all', NULL, 'assignments', 'reassign', 'all', 'Reassign surveyors'),
('3fa61c4b-737f-11f1-ac50-002b67818c25', 'assignments.manage.all', NULL, 'assignments', 'manage', 'all', 'Manage assignments'),
('40377bc2-737f-11f1-ac50-002b67818c25', 'surveyor_jobs.view.assigned', 'View Assigned Surveyor Jobs', 'surveyor_jobs', 'view', 'assigned', 'Melihat job yang ditugaskan ke surveyor login'),
('40378673-737f-11f1-ac50-002b67818c25', 'surveys.view.assigned', 'View Assigned Surveys', 'surveys', 'view', 'assigned', 'Melihat survey milik assignment sendiri'),
('40378930-737f-11f1-ac50-002b67818c25', 'surveys.start.assigned', 'Start Assigned Survey', 'surveys', 'start', 'assigned', 'Memulai survey untuk container yang ditugaskan'),
('40378b20-737f-11f1-ac50-002b67818c25', 'surveys.update.assigned', 'Update Assigned Survey', 'surveys', 'update', 'assigned', 'Mengubah draft/revisi survey sendiri'),
('40378d25-737f-11f1-ac50-002b67818c25', 'surveys.submit.assigned', 'Submit Assigned Survey', 'surveys', 'submit', 'assigned', 'Submit survey sendiri untuk review'),
('40378ed5-737f-11f1-ac50-002b67818c25', 'survey_damages.view.assigned', 'View Assigned Survey Damages', 'survey_damages', 'view', 'assigned', 'Melihat damage pada survey sendiri'),
('40379102-737f-11f1-ac50-002b67818c25', 'survey_damages.create.assigned', 'Create Assigned Survey Damage', 'survey_damages', 'create', 'assigned', 'Membuat damage pada survey sendiri'),
('403792f7-737f-11f1-ac50-002b67818c25', 'survey_damages.update.assigned', 'Update Assigned Survey Damage', 'survey_damages', 'update', 'assigned', 'Mengubah damage pada survey sendiri'),
('403794be-737f-11f1-ac50-002b67818c25', 'survey_damages.delete.assigned', 'Delete Assigned Survey Damage', 'survey_damages', 'delete', 'assigned', 'Menghapus damage pada survey sendiri'),
('4037966f-737f-11f1-ac50-002b67818c25', 'survey_photos.upload.assigned', 'Upload Assigned Survey Photo', 'survey_photos', 'upload', 'assigned', 'Upload foto evidence pada survey sendiri'),
('40379833-737f-11f1-ac50-002b67818c25', 'survey_photos.view.assigned', 'View Assigned Survey Photos', 'survey_photos', 'view', 'assigned', 'Melihat foto evidence pada survey sendiri'),
('40a3aee5-737f-11f1-ac50-002b67818c25', 'reviews.view.all', 'View Reviews', 'reviews', 'view', 'all', 'Melihat survey pending review'),
('40a3b4bb-737f-11f1-ac50-002b67818c25', 'reviews.manage.all', 'Manage Reviews', 'reviews', 'manage', 'all', 'Approve, reject, dan need revision survey'),
('40a3b75d-737f-11f1-ac50-002b67818c25', 'reports.view.all', 'View Reports', 'reports', 'view', 'all', 'Melihat arsip report'),
('40a3b923-737f-11f1-ac50-002b67818c25', 'reports.generate.all', 'Generate Reports', 'reports', 'generate', 'all', 'Membuat report dari survey approved'),
('40a3bb17-737f-11f1-ac50-002b67818c25', 'reports.version.all', 'Version Reports', 'reports', 'version', 'all', 'Membuat revisi report'),
('40f9de5e-737f-11f1-ac50-002b67818c25', 'finance.view.all', 'View Finance', 'finance', 'view', 'all', 'Melihat dashboard finance, invoice, payment, outstanding'),
('40f9e5e6-737f-11f1-ac50-002b67818c25', 'finance.manage.all', 'Manage Finance', 'finance', 'manage', 'all', 'Mengelola price list, invoice, dan payment'),
('40f9e90f-737f-11f1-ac50-002b67818c25', 'finance.invoice.create.all', 'Create Invoice', 'finance.invoice', 'create', 'all', 'Membuat invoice draft'),
('40f9eb1b-737f-11f1-ac50-002b67818c25', 'finance.payment.create.all', 'Create Payment', 'finance.payment', 'create', 'all', 'Mencatat payment'),
('84947ba5-7456-11f1-806f-002b67818c25', 'audit.view.all', 'View Audit Log', 'audit', 'view', 'all', 'Melihat audit log sistem'),
('84955473-7456-11f1-806f-002b67818c25', 'checklist_templates.view.all', 'View Checklist Templates', 'checklist_templates', 'view', 'all', 'Melihat checklist template / data bootstrap'),
('84955622-7456-11f1-806f-002b67818c25', 'settings.view.all', 'View Settings', 'settings', 'view', 'all', 'Melihat menu setting'),
('849556d7-7456-11f1-806f-002b67818c25', 'users.view.all', 'View Users', 'users', 'view', 'all', 'Melihat user management'),
('8495577e-7456-11f1-806f-002b67818c25', 'roles.view.all', 'View Roles', 'roles', 'view', 'all', 'Melihat role dan permission'),
('8495581a-7456-11f1-806f-002b67818c25', 'company_profiles.view.all', 'View Company Profile', 'company_profiles', 'view', 'all', 'Melihat company profile'),
('849558e0-7456-11f1-806f-002b67818c25', 'numbering_settings.view.all', 'View Numbering Settings', 'numbering_settings', 'view', 'all', 'Melihat numbering setting');

-- --------------------------------------------------------

--
-- Table structure for table `price_lists`
--

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
  `deleted_at` datetime(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `refresh_tokens`
--

CREATE TABLE `refresh_tokens` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `user_id` char(36) NOT NULL,
  `token_hash` text NOT NULL,
  `device_name` varchar(150) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text,
  `expires_at` datetime(6) NOT NULL,
  `revoked_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `refresh_tokens`
--

INSERT INTO `refresh_tokens` (`id`, `user_id`, `token_hash`, `device_name`, `ip_address`, `user_agent`, `expires_at`, `revoked_at`, `created_at`) VALUES
('3c251d8c-7385-11f1-ac50-002b67818c25', '00000000-0000-0000-0000-000000000001', 'ef5023a6d610d7ca20521d89074c49e0f6151c3107db35e5b66aa72530c307c4', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-13 13:39:10.206639', NULL, '2026-06-29 13:39:10.210240'),
('585dfc26-738c-11f1-ac50-002b67818c25', '00000000-0000-0000-0000-000000000001', '3ba163fa3092267a4a3c49a15171d3d5a3b1b2acd95e1f46347eb419f9eb2b2f', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.126.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36', '2026-07-13 14:30:04.034242', NULL, '2026-06-29 14:30:04.036456'),
('5c06ba1a-738c-11f1-ac50-002b67818c25', '00000000-0000-0000-0000-000000000001', '12afefe344831ae1038c2f00551dc79bc5b2d59e43242170d4ac179c66642ce9', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-13 14:30:10.174999', NULL, '2026-06-29 14:30:10.175585'),
('e87ee5d9-745c-11f1-806f-002b67818c25', '00000000-0000-0000-0000-000000000001', '00e56b6d61120482e4befc5596219b18a69b302fae71a20a0555eed3f024b384', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.126.0 Chrome/148.0.7778.97 Electron/42.2.0 Safari/537.36', '2026-07-14 15:23:01.162433', NULL, '2026-06-30 15:23:01.163894'),
('f47568a0-745c-11f1-806f-002b67818c25', '00000000-0000-0000-0000-000000000001', 'a568caea46ac795f8f2b8481f578ae43eafadb0501192e8625bfdee81183b250', NULL, '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', '2026-07-14 15:23:21.233918', NULL, '2026-06-30 15:23:21.234401');

-- --------------------------------------------------------

--
-- Table structure for table `reports`
--

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
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `report_snapshots`
--

CREATE TABLE `report_snapshots` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `report_version_id` char(36) NOT NULL,
  `snapshot_data` json NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `report_versions`
--

CREATE TABLE `report_versions` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `report_id` char(36) NOT NULL,
  `version_no` int NOT NULL,
  `file_id` char(36) DEFAULT NULL,
  `change_reason` text,
  `status` varchar(30) NOT NULL DEFAULT 'draft',
  `created_by` char(36) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `responsibility_codes`
--

CREATE TABLE `responsibility_codes` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(30) NOT NULL,
  `name` varchar(150) NOT NULL,
  `description` text,
  `status` varchar(30) NOT NULL DEFAULT 'active',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ;

--
-- Dumping data for table `responsibility_codes`
--

INSERT INTO `responsibility_codes` (`id`, `code`, `name`, `description`, `status`, `created_at`, `updated_at`) VALUES
('3f2fe18e-737f-11f1-ac50-002b67818c25', 'C', 'Customer', 'Customer responsibility', 'active', '2026-06-29 05:56:18.333391', '2026-06-29 05:56:18.333391'),
('3f2fe5c4-737f-11f1-ac50-002b67818c25', 'O', 'Owner', 'Owner responsibility', 'active', '2026-06-29 05:56:18.333391', '2026-06-29 05:56:18.333391'),
('3f2fe71a-737f-11f1-ac50-002b67818c25', 'D', 'Depot', 'Depot responsibility', 'active', '2026-06-29 05:56:18.333391', '2026-06-29 05:56:18.333391'),
('3f2fe80d-737f-11f1-ac50-002b67818c25', 'T', 'Trucker', 'Trucker responsibility', 'active', '2026-06-29 05:56:18.333391', '2026-06-29 05:56:18.333391'),
('3f2fe8f7-737f-11f1-ac50-002b67818c25', 'U', 'Unknown', 'Unknown responsibility', 'active', '2026-06-29 05:56:18.333391', '2026-06-29 05:56:18.333391');

-- --------------------------------------------------------

--
-- Table structure for table `roles`
--

CREATE TABLE `roles` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `code` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `description` text,
  `is_system_role` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `roles`
--

INSERT INTO `roles` (`id`, `code`, `name`, `description`, `is_system_role`, `created_at`, `updated_at`) VALUES
('3f26a41f-737f-11f1-ac50-002b67818c25', 'super_admin', 'Super Admin', 'Highest system administrator', 1, '2026-06-29 05:56:18.271615', '2026-06-29 05:56:18.271615'),
('3f26b6a0-737f-11f1-ac50-002b67818c25', 'admin', 'Admin / Operasional', 'Operational admin for master data and jobs', 1, '2026-06-29 05:56:18.271615', '2026-06-29 05:56:18.271615'),
('3f26b8df-737f-11f1-ac50-002b67818c25', 'surveyor', 'Surveyor', 'Survey field user', 1, '2026-06-29 05:56:18.271615', '2026-06-29 05:56:18.271615'),
('3f26ba11-737f-11f1-ac50-002b67818c25', 'supervisor', 'Supervisor / Approver', 'Survey reviewer and approver', 1, '2026-06-29 05:56:18.271615', '2026-06-29 05:56:18.271615'),
('3f26bb58-737f-11f1-ac50-002b67818c25', 'finance', 'Finance', 'Finance and billing user', 1, '2026-06-29 05:56:18.271615', '2026-06-29 05:56:18.271615'),
('3f26bccb-737f-11f1-ac50-002b67818c25', 'management', 'Management', 'Read-only dashboard and recap user', 1, '2026-06-29 05:56:18.271615', '2026-06-29 05:56:18.271615');

-- --------------------------------------------------------

--
-- Table structure for table `role_permissions`
--

CREATE TABLE `role_permissions` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `role_id` char(36) NOT NULL,
  `permission_id` char(36) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `role_permissions`
--

INSERT INTO `role_permissions` (`id`, `role_id`, `permission_id`, `created_at`) VALUES
('1ec471a1-7460-11f1-806f-002b67818c25', '3f26ba11-737f-11f1-ac50-002b67818c25', '40a3b923-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.706462'),
('1ec488e2-7460-11f1-806f-002b67818c25', '3f26ba11-737f-11f1-ac50-002b67818c25', '40a3bb17-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.706462'),
('1ec49048-7460-11f1-806f-002b67818c25', '3f26ba11-737f-11f1-ac50-002b67818c25', '40a3b75d-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.706462'),
('1ec4963f-7460-11f1-806f-002b67818c25', '3f26ba11-737f-11f1-ac50-002b67818c25', '40a3b4bb-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.706462'),
('1ec49bee-7460-11f1-806f-002b67818c25', '3f26ba11-737f-11f1-ac50-002b67818c25', '40a3aee5-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.706462'),
('1ed21f47-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '3f429301-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed22a10-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '3f429730-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed230f9-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '3f428d2c-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed236b6-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '3f429f1b-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed27383-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '3f429b59-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed27a7c-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '3f42a2cb-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed2806e-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '40379102-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed28675-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '403794be-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed28c1c-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '403792f7-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed291c8-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '40378ed5-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed29762-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '4037966f-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed29d29-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '40379833-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed2a347-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '40377bc2-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed2a8c3-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '40378930-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed2add7-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '40378d25-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed2c1d5-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '40378b20-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ed2c8cb-7460-11f1-806f-002b67818c25', '3f26b8df-737f-11f1-ac50-002b67818c25', '40378673-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.795912'),
('1ee0dff2-7460-11f1-806f-002b67818c25', '3f26bb58-737f-11f1-ac50-002b67818c25', '40f9e90f-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.892707'),
('1ee0f754-7460-11f1-806f-002b67818c25', '3f26bb58-737f-11f1-ac50-002b67818c25', '40f9e5e6-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.892707'),
('1ee0fdc6-7460-11f1-806f-002b67818c25', '3f26bb58-737f-11f1-ac50-002b67818c25', '40f9eb1b-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.892707'),
('1ee103b2-7460-11f1-806f-002b67818c25', '3f26bb58-737f-11f1-ac50-002b67818c25', '40f9de5e-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.892707'),
('1ee10909-7460-11f1-806f-002b67818c25', '3f26bb58-737f-11f1-ac50-002b67818c25', '40a3b75d-737f-11f1-ac50-002b67818c25', '2026-06-30 15:46:00.892707'),
('3f282f02-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '3f277c21-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.282290'),
('3f2838e0-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f278d74-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.282290'),
('3f283cf7-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f278b9f-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.282290'),
('3f284008-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f278768-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.282290'),
('3f28472b-737f-11f1-ac50-002b67818c25', '3f26bccb-737f-11f1-ac50-002b67818c25', '3f278f3f-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.282290'),
('3f284bbe-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f278f3f-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.282290'),
('3f285003-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f278858-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.282290'),
('3f285c0a-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f278e50-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.282290'),
('3f285f5a-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f278c8d-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.282290'),
('3f2862e9-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f27896c-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.282290'),
('3f4365df-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f42a80d-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.461229'),
('3f436a4b-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f42a903-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.461229'),
('3f436c3a-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f42a715-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.461229'),
('3f436dd0-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f42aaef-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.461229'),
('3f436f85-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f42a9ed-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.461229'),
('3f437cda-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f42abe3-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.461229'),
('3f438189-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3f42acea-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.461229'),
('3fa6b037-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3fa61c4b-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:19.111593'),
('3fa6b4d1-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3fa6149e-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:19.111593'),
('3fa6b6ba-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3fa617a5-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:19.111593'),
('3fa6b889-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3fa61581-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:19.111593'),
('3fa6ba78-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3fa6188d-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:19.111593'),
('3fa6bc2d-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3fa616b5-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:19.111593'),
('3fa6bd98-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3fa613ad-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:19.111593'),
('3fa6bef4-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '3fa612c5-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:19.111593'),
('403f8288-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40379102-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403f85d8-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '40379102-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403f8ca9-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '403794be-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403f8f32-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '403794be-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403f95f7-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '403792f7-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403f9886-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '403792f7-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403f9f41-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40378ed5-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403fa1b3-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '40378ed5-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403fa8d5-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '4037966f-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403fabd9-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '4037966f-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403fb49c-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40379833-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403fb8ca-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '40379833-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403fc4da-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40377bc2-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403fc8fe-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '40377bc2-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403fd3eb-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40378930-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403fd709-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '40378930-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403fe088-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40378d25-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403fe729-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '40378d25-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403ff050-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40378b20-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('403ff2f8-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '40378b20-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('404041de-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40378673-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('404045ba-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '40378673-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.113192'),
('40a46ac5-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40a3b923-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.774021'),
('40a46df0-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '40a3b923-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.774021'),
('40a4742e-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40a3bb17-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.774021'),
('40a4774e-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '40a3bb17-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.774021'),
('40a47d3f-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40a3b75d-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.774021'),
('40a47fe9-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '40a3b75d-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.774021'),
('40a485ad-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40a3b4bb-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.774021'),
('40a48833-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '40a3b4bb-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.774021'),
('40a48e62-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40a3aee5-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.774021'),
('40a490aa-737f-11f1-ac50-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '40a3aee5-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.774021'),
('40a549f9-737f-11f1-ac50-002b67818c25', '3f26bccb-737f-11f1-ac50-002b67818c25', '40a3b75d-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:20.780876'),
('40fa9a26-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40f9e90f-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:21.339139'),
('40faaa6a-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40f9e5e6-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:21.339139'),
('40fab1bd-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40f9eb1b-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:21.339139'),
('40fab7f1-737f-11f1-ac50-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '40f9de5e-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:21.339139'),
('40fb6995-737f-11f1-ac50-002b67818c25', '3f26bccb-737f-11f1-ac50-002b67818c25', '40f9de5e-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:21.345000'),
('84980f0f-7456-11f1-806f-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '84947ba5-7456-11f1-806f-002b67818c25', '2026-06-30 14:37:16.575296'),
('84981fef-7456-11f1-806f-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '84955473-7456-11f1-806f-002b67818c25', '2026-06-30 14:37:16.575296'),
('8498219e-7456-11f1-806f-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '8495581a-7456-11f1-806f-002b67818c25', '2026-06-30 14:37:16.575296'),
('84982331-7456-11f1-806f-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '849558e0-7456-11f1-806f-002b67818c25', '2026-06-30 14:37:16.575296'),
('8498248f-7456-11f1-806f-002b67818c25', '3f26b6a0-737f-11f1-ac50-002b67818c25', '84955622-7456-11f1-806f-002b67818c25', '2026-06-30 14:37:16.575296'),
('849a6e56-7456-11f1-806f-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '84947ba5-7456-11f1-806f-002b67818c25', '2026-06-30 14:37:16.591657'),
('849a72a9-7456-11f1-806f-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '84955473-7456-11f1-806f-002b67818c25', '2026-06-30 14:37:16.591657'),
('849a73ee-7456-11f1-806f-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '8495581a-7456-11f1-806f-002b67818c25', '2026-06-30 14:37:16.591657'),
('849a7614-7456-11f1-806f-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '849558e0-7456-11f1-806f-002b67818c25', '2026-06-30 14:37:16.591657'),
('849a77c8-7456-11f1-806f-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '8495577e-7456-11f1-806f-002b67818c25', '2026-06-30 14:37:16.591657'),
('849a78ef-7456-11f1-806f-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '84955622-7456-11f1-806f-002b67818c25', '2026-06-30 14:37:16.591657'),
('849a7a05-7456-11f1-806f-002b67818c25', '3f26a41f-737f-11f1-ac50-002b67818c25', '849556d7-7456-11f1-806f-002b67818c25', '2026-06-30 14:37:16.591657');

-- --------------------------------------------------------

--
-- Table structure for table `surveyor_profiles`
--

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
  `deleted_at` datetime(6) DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `surveys`
--

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
  `deleted_at` datetime(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `survey_approvals`
--

CREATE TABLE `survey_approvals` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `survey_id` char(36) NOT NULL,
  `reviewer_id` char(36) NOT NULL,
  `decision` varchar(30) NOT NULL,
  `review_note` text,
  `final_result` varchar(50) DEFAULT NULL,
  `revision_no` int NOT NULL DEFAULT '0',
  `reviewed_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6),
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `survey_checklist_responses`
--

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
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `survey_damages`
--

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
  `deleted_at` datetime(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `survey_damage_counters`
--

CREATE TABLE `survey_damage_counters` (
  `survey_id` char(36) NOT NULL,
  `last_number` int NOT NULL DEFAULT '0',
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `survey_general_infos`
--

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
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `survey_photos`
--

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
  `deleted_at` datetime(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `survey_revision_items`
--

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
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `survey_types`
--

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
  `updated_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ;

--
-- Dumping data for table `survey_types`
--

INSERT INTO `survey_types` (`id`, `code`, `name`, `description`, `requires_eir`, `requires_light_test`, `requires_cargo_worthy_result`, `status`, `created_at`, `updated_at`) VALUES
('3f2b441f-737f-11f1-ac50-002b67818c25', 'GI', 'Gate In Survey', 'Survey when container enters yard or depot', 1, 0, 0, 'active', '2026-06-29 05:56:18.302441', '2026-06-29 05:56:18.302441'),
('3f2b4c28-737f-11f1-ac50-002b67818c25', 'GO', 'Gate Out Survey', 'Survey when container leaves yard or depot', 1, 0, 0, 'active', '2026-06-29 05:56:18.302441', '2026-06-29 05:56:18.302441'),
('3f2b4eea-737f-11f1-ac50-002b67818c25', 'DS', 'Damage Survey', 'Specific survey for container damage', 0, 0, 0, 'active', '2026-06-29 05:56:18.302441', '2026-06-29 05:56:18.302441'),
('3f2b50fc-737f-11f1-ac50-002b67818c25', 'CW', 'Cargo Worthy Survey', 'Cargo worthy condition assessment', 0, 1, 1, 'active', '2026-06-29 05:56:18.302441', '2026-06-29 05:56:18.302441'),
('3f2b52e1-737f-11f1-ac50-002b67818c25', 'CL', 'Cleanliness Survey', 'Container cleanliness survey', 0, 0, 0, 'active', '2026-06-29 05:56:18.302441', '2026-06-29 05:56:18.302441'),
('3f2b5e33-737f-11f1-ac50-002b67818c25', 'ONH', 'On Hire Survey', 'Start of hire survey', 0, 0, 0, 'active', '2026-06-29 05:56:18.302441', '2026-06-29 05:56:18.302441'),
('3f2b6033-737f-11f1-ac50-002b67818c25', 'OFH', 'Off Hire Survey', 'End of hire survey', 0, 0, 0, 'active', '2026-06-29 05:56:18.302441', '2026-06-29 05:56:18.302441'),
('3f2b626d-737f-11f1-ac50-002b67818c25', 'STUF', 'Stuffing Survey', 'Survey during stuffing activity', 0, 0, 0, 'active', '2026-06-29 05:56:18.302441', '2026-06-29 05:56:18.302441'),
('3f2b63fa-737f-11f1-ac50-002b67818c25', 'STRP', 'Stripping Survey', 'Survey during stripping activity', 0, 0, 0, 'active', '2026-06-29 05:56:18.302441', '2026-06-29 05:56:18.302441'),
('3f2b65bf-737f-11f1-ac50-002b67818c25', 'PTI', 'Pre-Trip Inspection', 'Reefer pre-trip inspection', 0, 1, 0, 'active', '2026-06-29 05:56:18.302441', '2026-06-29 05:56:18.302441');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

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
  `deleted_at` datetime(6) DEFAULT NULL
) ;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `username`, `password_hash`, `phone`, `avatar_file_id`, `status`, `last_login_at`, `password_changed_at`, `created_at`, `updated_at`, `deleted_at`) VALUES
('00000000-0000-0000-0000-000000000001', 'Super Admin Dev', 'superadmin@gift.local', 'superadmin', '$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG', NULL, NULL, 'active', '2026-06-30 15:23:21.233918', '2026-06-29 05:56:18.000000', '2026-06-29 05:56:18.440310', '2026-06-30 15:23:21.233918', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `user_roles`
--

CREATE TABLE `user_roles` (
  `id` char(36) NOT NULL DEFAULT (uuid()),
  `user_id` char(36) NOT NULL,
  `role_id` char(36) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `user_roles`
--

INSERT INTO `user_roles` (`id`, `user_id`, `role_id`, `created_at`) VALUES
('3f418ea9-737f-11f1-ac50-002b67818c25', '00000000-0000-0000-0000-000000000001', '3f26a41f-737f-11f1-ac50-002b67818c25', '2026-06-29 05:56:18.448821');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `assignments`
--
ALTER TABLE `assignments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `assignment_no` (`assignment_no`),
  ADD KEY `idx_assignments_job` (`job_order_id`),
  ADD KEY `idx_assignments_surveyor` (`surveyor_id`),
  ADD KEY `idx_assignments_status` (`status`);

--
-- Indexes for table `assignment_containers`
--
ALTER TABLE `assignment_containers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `assignment_id` (`assignment_id`,`job_container_id`),
  ADD KEY `idx_assignment_containers_active_container` (`job_container_id`),
  ADD KEY `idx_assignment_containers_assignment` (`assignment_id`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_logs_user` (`user_id`),
  ADD KEY `idx_audit_logs_entity` (`entity_type`,`entity_id`),
  ADD KEY `idx_audit_logs_action` (`action`),
  ADD KEY `idx_audit_logs_created_at` (`created_at`);

--
-- Indexes for table `cedex_components`
--
ALTER TABLE `cedex_components`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_cedex_components_status` (`status`);

--
-- Indexes for table `cedex_damages`
--
ALTER TABLE `cedex_damages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_cedex_damages_status` (`status`);

--
-- Indexes for table `cedex_locations`
--
ALTER TABLE `cedex_locations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_cedex_locations_unique_scope` (`code`,`face`,`container_size`),
  ADD KEY `idx_cedex_locations_face` (`face`),
  ADD KEY `idx_cedex_locations_status` (`status`);

--
-- Indexes for table `cedex_materials`
--
ALTER TABLE `cedex_materials`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_cedex_materials_status` (`status`);

--
-- Indexes for table `cedex_repairs`
--
ALTER TABLE `cedex_repairs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_cedex_repairs_status` (`status`);

--
-- Indexes for table `company_profiles`
--
ALTER TABLE `company_profiles`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_company_profiles_single_active` (`is_active`);

--
-- Indexes for table `container_import_batches`
--
ALTER TABLE `container_import_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `container_types`
--
ALTER TABLE `container_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_container_types_status` (`status`);

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_customers_code` (`customer_code`),
  ADD KEY `idx_customers_name` (`customer_name`),
  ADD KEY `idx_customers_status` (`status`);

--
-- Indexes for table `file_objects`
--
ALTER TABLE `file_objects`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `public_token` (`public_token`),
  ADD KEY `idx_file_objects_object_key` (`object_key`),
  ADD KEY `idx_file_objects_uploaded_by` (`uploaded_by`);

--
-- Indexes for table `invoices`
--
ALTER TABLE `invoices`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `invoice_no` (`invoice_no`),
  ADD UNIQUE KEY `idx_invoices_no` (`invoice_no`),
  ADD KEY `idx_invoices_customer` (`customer_id`),
  ADD KEY `idx_invoices_status` (`status`),
  ADD KEY `idx_invoices_date` (`invoice_date`),
  ADD KEY `idx_invoices_due_date` (`due_date`);

--
-- Indexes for table `invoice_items`
--
ALTER TABLE `invoice_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_invoice_items_invoice` (`invoice_id`),
  ADD KEY `idx_invoice_items_report` (`report_id`);

--
-- Indexes for table `job_containers`
--
ALTER TABLE `job_containers`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_job_containers_job_container_no` (`job_order_id`,`container_no`),
  ADD KEY `idx_job_containers_job` (`job_order_id`),
  ADD KEY `idx_job_containers_container_no` (`container_no`),
  ADD KEY `idx_job_containers_status` (`status`);

--
-- Indexes for table `job_events`
--
ALTER TABLE `job_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_job_events_job` (`job_order_id`),
  ADD KEY `idx_job_events_created_at` (`created_at`);

--
-- Indexes for table `job_orders`
--
ALTER TABLE `job_orders`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `job_order_no` (`job_order_no`),
  ADD UNIQUE KEY `idx_job_orders_no` (`job_order_no`),
  ADD KEY `idx_job_orders_customer` (`customer_id`),
  ADD KEY `idx_job_orders_status` (`status`),
  ADD KEY `idx_job_orders_date` (`job_date`),
  ADD KEY `idx_job_orders_survey_type` (`survey_type_id`),
  ADD KEY `idx_job_orders_deleted` (`deleted_at`);

--
-- Indexes for table `locations`
--
ALTER TABLE `locations`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_locations_code` (`location_code`),
  ADD KEY `idx_locations_name` (`location_name`),
  ADD KEY `idx_locations_type` (`location_type`),
  ADD KEY `idx_locations_status` (`status`);

--
-- Indexes for table `numbering_sequences`
--
ALTER TABLE `numbering_sequences`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `document_type` (`document_type`,`period_key`);

--
-- Indexes for table `numbering_settings`
--
ALTER TABLE `numbering_settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_numbering_settings_active` (`document_type`);

--
-- Indexes for table `payments`
--
ALTER TABLE `payments`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `payment_no` (`payment_no`),
  ADD KEY `idx_payments_invoice` (`invoice_id`),
  ADD KEY `idx_payments_date` (`payment_date`);

--
-- Indexes for table `permissions`
--
ALTER TABLE `permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_permissions_module_action` (`module`,`action`);

--
-- Indexes for table `price_lists`
--
ALTER TABLE `price_lists`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_price_lists_customer` (`customer_id`),
  ADD KEY `idx_price_lists_survey_type` (`survey_type_id`),
  ADD KEY `idx_price_lists_effective` (`effective_date`);

--
-- Indexes for table `refresh_tokens`
--
ALTER TABLE `refresh_tokens`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_refresh_tokens_user` (`user_id`),
  ADD KEY `idx_refresh_tokens_expires` (`expires_at`),
  ADD KEY `idx_refresh_tokens_revoked` (`revoked_at`);

--
-- Indexes for table `reports`
--
ALTER TABLE `reports`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `report_no` (`report_no`),
  ADD UNIQUE KEY `idx_reports_no` (`report_no`),
  ADD UNIQUE KEY `qr_token` (`qr_token`),
  ADD KEY `idx_reports_survey_active` (`survey_id`),
  ADD KEY `idx_reports_job` (`job_order_id`),
  ADD KEY `idx_reports_survey` (`survey_id`),
  ADD KEY `idx_reports_status` (`status`),
  ADD KEY `idx_reports_qr_token` (`qr_token`);

--
-- Indexes for table `report_snapshots`
--
ALTER TABLE `report_snapshots`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `report_version_id` (`report_version_id`);

--
-- Indexes for table `report_versions`
--
ALTER TABLE `report_versions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `report_id` (`report_id`,`version_no`),
  ADD KEY `idx_report_versions_report` (`report_id`),
  ADD KEY `idx_report_versions_status` (`status`);

--
-- Indexes for table `responsibility_codes`
--
ALTER TABLE `responsibility_codes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_responsibility_codes_status` (`status`);

--
-- Indexes for table `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`);

--
-- Indexes for table `role_permissions`
--
ALTER TABLE `role_permissions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `role_id` (`role_id`,`permission_id`),
  ADD KEY `idx_role_permissions_role` (`role_id`),
  ADD KEY `idx_role_permissions_permission` (`permission_id`);

--
-- Indexes for table `surveyor_profiles`
--
ALTER TABLE `surveyor_profiles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD UNIQUE KEY `idx_surveyor_profiles_code` (`surveyor_code`),
  ADD KEY `idx_surveyor_profiles_status` (`status`);

--
-- Indexes for table `surveys`
--
ALTER TABLE `surveys`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `survey_no` (`survey_no`),
  ADD UNIQUE KEY `idx_surveys_no` (`survey_no`),
  ADD KEY `idx_surveys_container_type_active` (`job_container_id`,`survey_type_id`),
  ADD KEY `idx_surveys_job` (`job_order_id`),
  ADD KEY `idx_surveys_container` (`job_container_id`),
  ADD KEY `idx_surveys_surveyor` (`surveyor_id`),
  ADD KEY `idx_surveys_status` (`status`),
  ADD KEY `idx_surveys_submitted_at` (`submitted_at`);

--
-- Indexes for table `survey_approvals`
--
ALTER TABLE `survey_approvals`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_survey_approvals_survey` (`survey_id`),
  ADD KEY `idx_survey_approvals_decision` (`decision`);

--
-- Indexes for table `survey_checklist_responses`
--
ALTER TABLE `survey_checklist_responses`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `survey_id` (`survey_id`,`item_code`),
  ADD KEY `idx_survey_checklist_survey` (`survey_id`);

--
-- Indexes for table `survey_damages`
--
ALTER TABLE `survey_damages`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_survey_damages_no_active` (`survey_id`,`damage_no`),
  ADD KEY `idx_survey_damages_survey` (`survey_id`),
  ADD KEY `idx_survey_damages_location` (`face`,`internal_location`),
  ADD KEY `idx_survey_damages_severity` (`severity`),
  ADD KEY `idx_survey_damages_component` (`component_id`),
  ADD KEY `idx_survey_damages_damage` (`damage_id`);

--
-- Indexes for table `survey_damage_counters`
--
ALTER TABLE `survey_damage_counters`
  ADD PRIMARY KEY (`survey_id`);

--
-- Indexes for table `survey_general_infos`
--
ALTER TABLE `survey_general_infos`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `survey_id` (`survey_id`);

--
-- Indexes for table `survey_photos`
--
ALTER TABLE `survey_photos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_survey_photos_survey` (`survey_id`),
  ADD KEY `idx_survey_photos_damage` (`damage_id`),
  ADD KEY `idx_survey_photos_watermarked_file` (`watermarked_file_id`),
  ADD KEY `idx_survey_photos_type` (`photo_type`);

--
-- Indexes for table `survey_revision_items`
--
ALTER TABLE `survey_revision_items`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_survey_revision_items_survey` (`survey_id`),
  ADD KEY `idx_survey_revision_items_resolved` (`is_resolved`);

--
-- Indexes for table `survey_types`
--
ALTER TABLE `survey_types`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `code` (`code`),
  ADD KEY `idx_survey_types_status` (`status`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_users_email` (`email`),
  ADD UNIQUE KEY `idx_users_username` (`username`),
  ADD KEY `idx_users_status` (`status`);

--
-- Indexes for table `user_roles`
--
ALTER TABLE `user_roles`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`role_id`),
  ADD KEY `idx_user_roles_user` (`user_id`),
  ADD KEY `idx_user_roles_role` (`role_id`);

--
-- Constraints for dumped tables
--

--
-- Constraints for table `file_objects`
--
ALTER TABLE `file_objects`
  ADD CONSTRAINT `fk_file_objects_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`);

ALTER TABLE `job_orders`
  ADD CONSTRAINT `fk_job_orders_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  ADD CONSTRAINT `fk_job_orders_survey_type` FOREIGN KEY (`survey_type_id`) REFERENCES `survey_types` (`id`),
  ADD CONSTRAINT `fk_job_orders_location` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`);

ALTER TABLE `job_containers`
  ADD CONSTRAINT `fk_job_containers_job_order` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`id`),
  ADD CONSTRAINT `fk_job_containers_container_type` FOREIGN KEY (`container_type_id`) REFERENCES `container_types` (`id`);

ALTER TABLE `assignments`
  ADD CONSTRAINT `fk_assignments_job_order` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`id`),
  ADD CONSTRAINT `fk_assignments_surveyor` FOREIGN KEY (`surveyor_id`) REFERENCES `surveyor_profiles` (`id`),
  ADD CONSTRAINT `fk_assignments_assigned_by` FOREIGN KEY (`assigned_by`) REFERENCES `users` (`id`);

ALTER TABLE `assignment_containers`
  ADD CONSTRAINT `fk_assignment_containers_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`),
  ADD CONSTRAINT `fk_assignment_containers_job_container` FOREIGN KEY (`job_container_id`) REFERENCES `job_containers` (`id`);

ALTER TABLE `surveys`
  ADD CONSTRAINT `fk_surveys_job_order` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`id`),
  ADD CONSTRAINT `fk_surveys_job_container` FOREIGN KEY (`job_container_id`) REFERENCES `job_containers` (`id`),
  ADD CONSTRAINT `fk_surveys_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `assignments` (`id`),
  ADD CONSTRAINT `fk_surveys_surveyor` FOREIGN KEY (`surveyor_id`) REFERENCES `surveyor_profiles` (`id`),
  ADD CONSTRAINT `fk_surveys_survey_type` FOREIGN KEY (`survey_type_id`) REFERENCES `survey_types` (`id`);

ALTER TABLE `survey_general_infos`
  ADD CONSTRAINT `fk_survey_general_infos_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_survey_general_infos_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`),
  ADD CONSTRAINT `fk_survey_general_infos_location` FOREIGN KEY (`location_id`) REFERENCES `locations` (`id`),
  ADD CONSTRAINT `fk_survey_general_infos_container_type` FOREIGN KEY (`container_type_id`) REFERENCES `container_types` (`id`);

ALTER TABLE `survey_damages`
  ADD CONSTRAINT `fk_survey_damages_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_survey_damages_cedex_location` FOREIGN KEY (`cedex_location_id`) REFERENCES `cedex_locations` (`id`),
  ADD CONSTRAINT `fk_survey_damages_component` FOREIGN KEY (`component_id`) REFERENCES `cedex_components` (`id`),
  ADD CONSTRAINT `fk_survey_damages_damage` FOREIGN KEY (`damage_id`) REFERENCES `cedex_damages` (`id`),
  ADD CONSTRAINT `fk_survey_damages_repair` FOREIGN KEY (`repair_id`) REFERENCES `cedex_repairs` (`id`),
  ADD CONSTRAINT `fk_survey_damages_material` FOREIGN KEY (`material_id`) REFERENCES `cedex_materials` (`id`),
  ADD CONSTRAINT `fk_survey_damages_responsibility` FOREIGN KEY (`responsibility_id`) REFERENCES `responsibility_codes` (`id`);

ALTER TABLE `survey_photos`
  ADD CONSTRAINT `fk_survey_photos_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_survey_photos_damage` FOREIGN KEY (`damage_id`) REFERENCES `survey_damages` (`id`),
  ADD CONSTRAINT `fk_survey_photos_file` FOREIGN KEY (`file_id`) REFERENCES `file_objects` (`id`),
  ADD CONSTRAINT `fk_survey_photos_watermarked_file` FOREIGN KEY (`watermarked_file_id`) REFERENCES `file_objects` (`id`),
  ADD CONSTRAINT `fk_survey_photos_uploaded_by` FOREIGN KEY (`uploaded_by`) REFERENCES `users` (`id`);

ALTER TABLE `reports`
  ADD CONSTRAINT `fk_reports_job_order` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`id`),
  ADD CONSTRAINT `fk_reports_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`),
  ADD CONSTRAINT `fk_reports_customer` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`);

ALTER TABLE `invoice_items`
  ADD CONSTRAINT `fk_invoice_items_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_invoice_items_report` FOREIGN KEY (`report_id`) REFERENCES `reports` (`id`),
  ADD CONSTRAINT `fk_invoice_items_survey` FOREIGN KEY (`survey_id`) REFERENCES `surveys` (`id`);

ALTER TABLE `payments`
  ADD CONSTRAINT `fk_payments_invoice` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`id`);

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code='survey_photos.view.assigned'
WHERE r.code IN ('admin','supervisor');

INSERT IGNORE INTO permissions (code, name, module, action, scope, description)
VALUES ('surveys.view.all', 'View All Surveys', 'surveys', 'view', 'all', 'Melihat seluruh survey untuk monitoring Admin');

DELETE rp
FROM role_permissions rp
JOIN roles r ON r.id = rp.role_id
JOIN permissions p ON p.id = rp.permission_id
WHERE r.code = 'admin'
  AND p.code IN ('users.manage.all', 'roles.view.all', 'roles.manage.all');

INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT r.id, p.id
FROM roles r
JOIN permissions p ON p.code IN (
  'surveys.view.all', 'reviews.view.all', 'reviews.manage.all', 'reports.view.all',
  'users.view.all', 'company_profiles.view.all', 'numbering_settings.view.all', 'audit.view.all'
)
WHERE r.code = 'admin';

-- Development demo accounts. Password for every account: password.
INSERT IGNORE INTO users (id, name, email, username, password_hash, status, password_changed_at)
VALUES
  ('00000000-0000-0000-0000-000000000002', 'Admin Demo', 'admin@gift.local', 'admin', '$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG', 'active', CURRENT_TIMESTAMP(6)),
  ('00000000-0000-0000-0000-000000000003', 'Surveyor Demo', 'surveyor@gift.local', 'surveyor', '$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG', 'active', CURRENT_TIMESTAMP(6)),
  ('00000000-0000-0000-0000-000000000004', 'Supervisor Demo', 'supervisor@gift.local', 'supervisor', '$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG', 'active', CURRENT_TIMESTAMP(6)),
  ('00000000-0000-0000-0000-000000000005', 'Finance Demo', 'finance@gift.local', 'finance', '$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG', 'active', CURRENT_TIMESTAMP(6)),
  ('00000000-0000-0000-0000-000000000006', 'Management Demo', 'management@gift.local', 'management', '$2a$10$lhfVbkWYGTiUaDCI2e77xe6g1GYZUMNZl0G.8iL7Z7VvUi/J6rTlG', 'active', CURRENT_TIMESTAMP(6));

INSERT IGNORE INTO user_roles (user_id, role_id)
SELECT u.id, r.id
FROM users u
JOIN roles r ON r.code = CASE u.email
  WHEN 'admin@gift.local' THEN 'admin'
  WHEN 'surveyor@gift.local' THEN 'surveyor'
  WHEN 'supervisor@gift.local' THEN 'supervisor'
  WHEN 'finance@gift.local' THEN 'finance'
  WHEN 'management@gift.local' THEN 'management'
END
WHERE u.email IN (
  'admin@gift.local',
  'surveyor@gift.local',
  'supervisor@gift.local',
  'finance@gift.local',
  'management@gift.local'
);

INSERT IGNORE INTO surveyor_profiles (id, user_id, surveyor_code, full_name, area, status)
SELECT
  '00000000-0000-0000-0000-000000000103',
  u.id,
  'SVY-DEMO',
  'Surveyor Demo',
  'Demo Area',
  'active'
FROM users u
WHERE u.email = 'surveyor@gift.local';

-- Initialize transactional numbering from any operational rows included in the dump.
INSERT INTO numbering_sequences (document_type, period_key, last_number)
SELECT ns.document_type, CASE ns.reset_period WHEN 'monthly' THEN DATE_FORMAT(CURRENT_DATE, '%Y%m') WHEN 'never' THEN 'global' ELSE DATE_FORMAT(CURRENT_DATE, '%Y') END,
       COALESCE(MAX(CAST(SUBSTRING_INDEX(jo.job_order_no, '-', -1) AS UNSIGNED)), 0)
FROM numbering_settings ns LEFT JOIN job_orders jo ON ns.reset_period = 'never' OR (ns.reset_period = 'yearly' AND YEAR(jo.created_at) = YEAR(CURRENT_DATE)) OR (ns.reset_period = 'monthly' AND DATE_FORMAT(jo.created_at, '%Y%m') = DATE_FORMAT(CURRENT_DATE, '%Y%m'))
WHERE ns.document_type = 'job_order' GROUP BY ns.document_type, ns.reset_period
ON DUPLICATE KEY UPDATE last_number = GREATEST(numbering_sequences.last_number, VALUES(last_number));

INSERT INTO numbering_sequences (document_type, period_key, last_number)
SELECT ns.document_type, CASE ns.reset_period WHEN 'monthly' THEN DATE_FORMAT(CURRENT_DATE, '%Y%m') WHEN 'never' THEN 'global' ELSE DATE_FORMAT(CURRENT_DATE, '%Y') END,
       COALESCE(MAX(CAST(SUBSTRING_INDEX(a.assignment_no, '-', -1) AS UNSIGNED)), 0)
FROM numbering_settings ns LEFT JOIN assignments a ON ns.reset_period = 'never' OR (ns.reset_period = 'yearly' AND YEAR(a.created_at) = YEAR(CURRENT_DATE)) OR (ns.reset_period = 'monthly' AND DATE_FORMAT(a.created_at, '%Y%m') = DATE_FORMAT(CURRENT_DATE, '%Y%m'))
WHERE ns.document_type = 'assignment' GROUP BY ns.document_type, ns.reset_period
ON DUPLICATE KEY UPDATE last_number = GREATEST(numbering_sequences.last_number, VALUES(last_number));

INSERT INTO numbering_sequences (document_type, period_key, last_number)
SELECT ns.document_type, CASE ns.reset_period WHEN 'monthly' THEN DATE_FORMAT(CURRENT_DATE, '%Y%m') WHEN 'never' THEN 'global' ELSE DATE_FORMAT(CURRENT_DATE, '%Y') END,
       COALESCE(MAX(CAST(SUBSTRING_INDEX(s.survey_no, '-', -1) AS UNSIGNED)), 0)
FROM numbering_settings ns LEFT JOIN surveys s ON ns.reset_period = 'never' OR (ns.reset_period = 'yearly' AND YEAR(s.created_at) = YEAR(CURRENT_DATE)) OR (ns.reset_period = 'monthly' AND DATE_FORMAT(s.created_at, '%Y%m') = DATE_FORMAT(CURRENT_DATE, '%Y%m'))
WHERE ns.document_type = 'survey' GROUP BY ns.document_type, ns.reset_period
ON DUPLICATE KEY UPDATE last_number = GREATEST(numbering_sequences.last_number, VALUES(last_number));

INSERT INTO numbering_sequences (document_type, period_key, last_number)
SELECT ns.document_type, CASE ns.reset_period WHEN 'monthly' THEN DATE_FORMAT(CURRENT_DATE, '%Y%m') WHEN 'never' THEN 'global' ELSE DATE_FORMAT(CURRENT_DATE, '%Y') END,
       COALESCE(MAX(CAST(SUBSTRING_INDEX(r.report_no, '-', -1) AS UNSIGNED)), 0)
FROM numbering_settings ns LEFT JOIN reports r ON ns.reset_period = 'never' OR (ns.reset_period = 'yearly' AND YEAR(r.created_at) = YEAR(CURRENT_DATE)) OR (ns.reset_period = 'monthly' AND DATE_FORMAT(r.created_at, '%Y%m') = DATE_FORMAT(CURRENT_DATE, '%Y%m'))
WHERE ns.document_type = 'report' GROUP BY ns.document_type, ns.reset_period
ON DUPLICATE KEY UPDATE last_number = GREATEST(numbering_sequences.last_number, VALUES(last_number));

INSERT INTO numbering_sequences (document_type, period_key, last_number)
SELECT ns.document_type, CASE ns.reset_period WHEN 'monthly' THEN DATE_FORMAT(CURRENT_DATE, '%Y%m') WHEN 'never' THEN 'global' ELSE DATE_FORMAT(CURRENT_DATE, '%Y') END,
       COALESCE(MAX(CAST(SUBSTRING_INDEX(i.invoice_no, '-', -1) AS UNSIGNED)), 0)
FROM numbering_settings ns LEFT JOIN invoices i ON ns.reset_period = 'never' OR (ns.reset_period = 'yearly' AND YEAR(i.created_at) = YEAR(CURRENT_DATE)) OR (ns.reset_period = 'monthly' AND DATE_FORMAT(i.created_at, '%Y%m') = DATE_FORMAT(CURRENT_DATE, '%Y%m'))
WHERE ns.document_type = 'invoice' GROUP BY ns.document_type, ns.reset_period
ON DUPLICATE KEY UPDATE last_number = GREATEST(numbering_sequences.last_number, VALUES(last_number));

INSERT INTO numbering_sequences (document_type, period_key, last_number)
SELECT ns.document_type, CASE ns.reset_period WHEN 'monthly' THEN DATE_FORMAT(CURRENT_DATE, '%Y%m') WHEN 'never' THEN 'global' ELSE DATE_FORMAT(CURRENT_DATE, '%Y') END,
       COALESCE(MAX(CAST(SUBSTRING_INDEX(p.payment_no, '-', -1) AS UNSIGNED)), 0)
FROM numbering_settings ns LEFT JOIN payments p ON ns.reset_period = 'never' OR (ns.reset_period = 'yearly' AND YEAR(p.created_at) = YEAR(CURRENT_DATE)) OR (ns.reset_period = 'monthly' AND DATE_FORMAT(p.created_at, '%Y%m') = DATE_FORMAT(CURRENT_DATE, '%Y%m'))
WHERE ns.document_type = 'payment_receipt' GROUP BY ns.document_type, ns.reset_period
ON DUPLICATE KEY UPDATE last_number = GREATEST(numbering_sequences.last_number, VALUES(last_number));

COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
