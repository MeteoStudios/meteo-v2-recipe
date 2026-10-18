--  Meteo Studios V2 Package
--
--  Documentation : https://docs.meteostudios.net/packages/meteo-v2-package
--  Discord       : https://discord.gg/P5cPsVTNZf
--  Website       : https://meteostudios.net

SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS `bans` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `license` varchar(50) DEFAULT NULL,
  `discord` varchar(50) DEFAULT NULL,
  `ip` varchar(50) DEFAULT NULL,
  `reason` text DEFAULT NULL,
  `expire` int DEFAULT NULL,
  `bannedby` varchar(255) NOT NULL DEFAULT 'MTEO',
  PRIMARY KEY (`id`),
  KEY `license` (`license`),
  KEY `discord` (`discord`),
  KEY `ip` (`ip`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `ox_inventory` (
  `owner` varchar(60) DEFAULT NULL,
  `name` varchar(100) NOT NULL,
  `data` longtext DEFAULT NULL,
  `lastupdated` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  UNIQUE KEY `owner` (`owner`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_appearance_job_outfits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `job` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `gender` enum('male','female') NOT NULL,
  `model` varchar(50) NOT NULL,
  `components` longtext DEFAULT NULL,
  `props` longtext DEFAULT NULL,
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_job` (`job`),
  KEY `idx_job_gender` (`job`,`gender`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_appearance_outfit_codes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(20) NOT NULL,
  `model` varchar(50) NOT NULL,
  `components` longtext DEFAULT NULL,
  `props` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `expires_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `code` (`code`),
  KEY `idx_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_appearance_outfits` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `model` varchar(50) NOT NULL,
  `components` longtext DEFAULT NULL,
  `props` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_boosting_contracts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `serial` varchar(20) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `class` char(1) NOT NULL,
  `vehicle` varchar(50) NOT NULL,
  `vehicle_label` varchar(100) NOT NULL,
  `reward` int NOT NULL,
  `xp_reward` int NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'inventory',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `started_at` timestamp NULL DEFAULT NULL,
  `completed_at` timestamp NULL DEFAULT NULL,
  `listed_price` double DEFAULT NULL,
  `contract_type` varchar(20) DEFAULT 'standard',
  PRIMARY KEY (`id`),
  UNIQUE KEY `serial` (`serial`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_boosting_players` (
  `citizenid` varchar(50) NOT NULL,
  `xp` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_bossmenu` (
  `id` int NOT NULL AUTO_INCREMENT,
  `job_name` varchar(50) NOT NULL,
  `action` varchar(50) NOT NULL,
  `action_label` varchar(50) DEFAULT NULL,
  `icon` varchar(50) DEFAULT NULL,
  `amount` int DEFAULT NULL,
  `details` text DEFAULT NULL,
  `performed_by` varchar(100) DEFAULT NULL,
  `performed_by_id` varchar(50) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_bossmenu_applications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `job_name` varchar(50) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `answers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`answers`)),
  `status` varchar(20) DEFAULT 'pending',
  `reviewed_by` varchar(100) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_job_status` (`job_name`,`status`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_bossmenu_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `job_name` varchar(50) NOT NULL,
  `question_text` text NOT NULL,
  `sort_order` int DEFAULT 0,
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_job` (`job_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_bossmenu_settings` (
  `job_name` varchar(50) NOT NULL,
  `applications_enabled` tinyint DEFAULT 1,
  PRIMARY KEY (`job_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_character_slots` (
  `identifier` varchar(60) NOT NULL,
  `slots` int DEFAULT 0,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_cityhall_doc_cooldowns` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `document_type` varchar(50) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_cooldown` (`citizenid`,`document_type`),
  KEY `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_cleaningjob` (
  `citizenid` varchar(50) NOT NULL,
  `xp` int NOT NULL DEFAULT 0,
  `total_spots` int NOT NULL DEFAULT 0,
  `total_tasks` int NOT NULL DEFAULT 0,
  `total_earned` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_coca_plants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `owner` varchar(50) NOT NULL,
  `coords` text NOT NULL,
  `heading` float NOT NULL DEFAULT 0,
  `water` float NOT NULL DEFAULT 100,
  `fertilizer` float NOT NULL DEFAULT 0,
  `health` float NOT NULL DEFAULT 100,
  `growth` float NOT NULL DEFAULT 0,
  `stage` int NOT NULL DEFAULT 1,
  `planted_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_crimetablet_achievements` (
  `citizenid` varchar(50) NOT NULL,
  `achievement_id` varchar(50) NOT NULL,
  `progress` int NOT NULL DEFAULT 0,
  `completed` tinyint NOT NULL DEFAULT 0,
  `completed_at` timestamp NULL DEFAULT NULL,
  `collected` tinyint NOT NULL DEFAULT 0,
  `collected_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`citizenid`,`achievement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_crimetablet_activity` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `text` varchar(255) NOT NULL,
  `icon` varchar(50) NOT NULL DEFAULT 'info',
  `color` varchar(20) NOT NULL DEFAULT '#57EFAF',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_crimetablet_blackmarket` (
  `id` int NOT NULL AUTO_INCREMENT,
  `seller_citizenid` varchar(50) NOT NULL,
  `seller_name` varchar(20) NOT NULL,
  `item_id` varchar(50) NOT NULL,
  `item_metadata` longtext DEFAULT NULL,
  `price` double NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'active',
  `buyer_citizenid` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_seller` (`seller_citizenid`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_crimetablet_files` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tablet_serial` varchar(50) NOT NULL,
  `name` varchar(50) NOT NULL,
  `content` text,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_file` (`tablet_serial`,`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_crimetablet_players` (
  `citizenid` varchar(50) NOT NULL,
  `name` varchar(20) DEFAULT NULL,
  `wallet_address` varchar(20) NOT NULL,
  `balance` double NOT NULL DEFAULT 0,
  `level` int NOT NULL DEFAULT 1,
  `xp` int NOT NULL DEFAULT 0,
  `reputation` int NOT NULL DEFAULT 0,
  `settings` longtext DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `profile_image` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`citizenid`),
  UNIQUE KEY `wallet_address` (`wallet_address`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_crimetablet_transactions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `type` varchar(20) NOT NULL,
  `amount` double NOT NULL,
  `fee` double NOT NULL DEFAULT 0,
  `description` varchar(255) DEFAULT NULL,
  `from_wallet` varchar(20) DEFAULT NULL,
  `to_wallet` varchar(20) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_crimetablet_usb` (
  `id` int NOT NULL AUTO_INCREMENT,
  `serial` varchar(50) NOT NULL,
  `label` varchar(100) NOT NULL DEFAULT 'USB Drive',
  `type` varchar(20) NOT NULL DEFAULT 'encrypted',
  `difficulty` varchar(20) NOT NULL DEFAULT 'medium',
  `custom_difficulty` text DEFAULT NULL,
  `password` varchar(100) DEFAULT NULL,
  `content` text,
  `reward_type` varchar(20) NOT NULL DEFAULT 'file',
  `reward_data` text DEFAULT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'active',
  `source_resource` varchar(50) DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_serial` (`serial`),
  KEY `idx_status` (`status`),
  KEY `idx_expires` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dailyrewards` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `date` date NOT NULL,
  `daily_tasks` longtext DEFAULT NULL,
  `completed_tasks` longtext,
  `claimed_milestones` longtext,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizen_date` (`citizenid`,`date`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_date` (`date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dailyrewards_boost` (
  `citizenid` varchar(50) NOT NULL,
  `active` tinyint DEFAULT 0,
  `multiplier` int DEFAULT 2,
  `target` int DEFAULT 5000,
  `earned` int DEFAULT 0,
  `last_boost_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_app_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealership` varchar(50) NOT NULL,
  `question_text` text NOT NULL,
  `sort_order` int DEFAULT 0,
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_dealer` (`dealership`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_app_settings` (
  `dealership` varchar(50) NOT NULL,
  `applications_enabled` tinyint DEFAULT 1,
  PRIMARY KEY (`dealership`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_applications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealership` varchar(50) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `answers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`answers`)),
  `status` varchar(20) DEFAULT 'pending',
  `reviewed_by` varchar(100) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_dealer_status` (`dealership`,`status`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_banking` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealership` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `amount` int NOT NULL,
  `balance_after` int NOT NULL DEFAULT 0,
  `performed_by` varchar(50) DEFAULT NULL,
  `performed_by_name` varchar(100) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_banking_dealership` (`dealership`),
  KEY `idx_banking_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_blacklist` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `total_repos` int DEFAULT 0,
  `blacklisted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `cleared_by` varchar(50) DEFAULT NULL,
  `cleared_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenid` (`citizenid`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_display` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealership` varchar(50) NOT NULL,
  `slot` int NOT NULL,
  `vehicle` varchar(50) NOT NULL,
  `color_primary` int DEFAULT 0,
  `color_secondary` int DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `dealership_slot` (`dealership`,`slot`),
  KEY `fk_display_dealership` (`dealership`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealership` varchar(50) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `grade` int NOT NULL DEFAULT 0,
  `commission_earned` int NOT NULL DEFAULT 0,
  `pending_commission` int NOT NULL DEFAULT 0,
  `hired_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `dealership_citizen` (`dealership`,`citizenid`),
  KEY `fk_employees_dealership` (`dealership`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_favorites` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `vehicle` varchar(50) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizen_vehicle` (`citizenid`,`vehicle`),
  KEY `fk_favorites_citizen` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_finance_payments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `plate` varchar(10) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `dealership` varchar(50) NOT NULL,
  `amount` int NOT NULL,
  `payment_source` varchar(10) NOT NULL DEFAULT 'bank',
  `balance_before` int NOT NULL,
  `balance_after` int NOT NULL,
  `payment_number` int NOT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_finance_plate` (`plate`),
  KEY `fk_finance_citizen` (`citizenid`),
  KEY `fk_finance_dealership` (`dealership`),
  KEY `idx_finance_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_inventory` (
  `dealership` varchar(50) NOT NULL,
  `vehicle` varchar(50) NOT NULL,
  `quantity` int NOT NULL DEFAULT 0,
  `sale_price` int DEFAULT NULL,
  `featured` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`dealership`,`vehicle`),
  KEY `fk_inventory_vehicle` (`vehicle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealership` varchar(50) NOT NULL,
  `action` varchar(100) NOT NULL,
  `action_type` varchar(50) DEFAULT NULL,
  `details` longtext DEFAULT NULL,
  `performed_by` varchar(50) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_logs_dealership` (`dealership`),
  KEY `idx_logs_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_lto` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealership` varchar(50) DEFAULT NULL,
  `vehicle` varchar(50) NOT NULL,
  `discount_percent` int NOT NULL DEFAULT 0,
  `start_time` datetime NOT NULL,
  `end_time` datetime NOT NULL,
  `created_by` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_lto_dealership` (`dealership`),
  KEY `fk_lto_vehicle` (`vehicle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealership` varchar(50) NOT NULL,
  `vehicle` varchar(50) NOT NULL,
  `quantity` int NOT NULL DEFAULT 1,
  `total_cost` int NOT NULL DEFAULT 0,
  `status` varchar(20) NOT NULL DEFAULT 'delivered',
  `ordered_by` varchar(50) DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `fk_orders_dealership` (`dealership`),
  KEY `fk_orders_vehicle` (`vehicle`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_repo_vehicles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealership` varchar(50) NOT NULL,
  `plate` varchar(20) NOT NULL,
  `vehicle` varchar(100) NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `balance_remaining` int NOT NULL,
  `original_price` int NOT NULL,
  `repoed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `sold` tinyint DEFAULT 0,
  `sold_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `plate` (`plate`),
  KEY `idx_dealership` (`dealership`),
  KEY `idx_plate` (`plate`),
  KEY `idx_sold` (`sold`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_sales` (
  `id` int NOT NULL AUTO_INCREMENT,
  `dealership` varchar(50) NOT NULL,
  `vehicle` varchar(50) NOT NULL,
  `plate` varchar(10) NOT NULL,
  `buyer_citizenid` varchar(50) NOT NULL,
  `buyer_name` varchar(100) DEFAULT NULL,
  `seller_citizenid` varchar(50) DEFAULT NULL,
  `seller_name` varchar(100) DEFAULT NULL,
  `purchase_type` varchar(20) NOT NULL,
  `amount_paid` int NOT NULL DEFAULT 0,
  `total_price` int NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `tax` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `fk_sales_dealership` (`dealership`),
  KEY `fk_sales_vehicle` (`vehicle`),
  KEY `fk_sales_buyer` (`buyer_citizenid`),
  KEY `fk_sales_plate` (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_skipped_vehicles` (
  `model` varchar(50) NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `brand` varchar(50) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  `data` longtext DEFAULT NULL,
  `skipped_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`model`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_vehicles` (
  `model` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `brand` varchar(50) DEFAULT NULL,
  `category` varchar(50) DEFAULT NULL,
  `customclass` varchar(10) DEFAULT NULL,
  `price` int NOT NULL,
  `dealerships` longtext DEFAULT NULL,
  `price_overrides` longtext DEFAULT NULL,
  `is_featured` longtext DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`model`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealerships` (
  `id` varchar(50) NOT NULL,
  `owner_citizenid` varchar(50) DEFAULT NULL,
  `owner_name` varchar(100) DEFAULT NULL,
  `balance` int NOT NULL DEFAULT 0,
  `commission_rate` int NOT NULL DEFAULT 15,
  `settings` longtext DEFAULT NULL,
  `created_at` datetime NOT NULL DEFAULT current_timestamp(),
  `balance_synced` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_electricianjob` (
  `citizenid` varchar(50) NOT NULL,
  `xp` int NOT NULL DEFAULT 0,
  `total_tasks` int NOT NULL DEFAULT 0,
  `total_repairs` int NOT NULL DEFAULT 0,
  `total_earned` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_evidence_lockers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `created_by` varchar(50) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_fishingjob` (
  `citizenid` varchar(50) NOT NULL,
  `xp` int NOT NULL DEFAULT 0,
  `total_catches` int NOT NULL DEFAULT 0,
  `total_earned` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_furnishing` (
  `id` int NOT NULL AUTO_INCREMENT,
  `property_id` varchar(100) NOT NULL,
  `property_type` varchar(20) NOT NULL,
  `item_id` varchar(100) NOT NULL,
  `model` varchar(255) NOT NULL,
  `coords` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`coords`)),
  `rotation` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`rotation`)),
  `placed_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_property` (`property_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_gopostaljob` (
  `citizenid` varchar(50) NOT NULL,
  `xp` int NOT NULL DEFAULT 0,
  `total_deliveries` int NOT NULL DEFAULT 0,
  `total_tasks` int NOT NULL DEFAULT 0,
  `total_earned` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_hsd_times` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `time` double NOT NULL,
  `completed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_time` (`time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_jail` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `items` longtext DEFAULT NULL,
  `cash` BIGINT DEFAULT 0,
  `bank` BIGINT DEFAULT 0,
  `clothing` longtext DEFAULT NULL,
  `jailed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_jail_reputation` (
  `citizenid` varchar(50) NOT NULL,
  `reputation` int DEFAULT 0,
  `total_jobs_completed` int DEFAULT 0,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_jail_sentence` (
  `citizenid` varchar(50) DEFAULT NULL,
  `sentenced` int NOT NULL DEFAULT 0,
  `served` int NOT NULL DEFAULT 0,
  `commuted` int NOT NULL DEFAULT 0,
  `remaining` int NOT NULL DEFAULT 0,
  `started_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_manage_announcements` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `message` text NOT NULL,
  `important` tinyint(1) NOT NULL DEFAULT 0,
  `duration` int NOT NULL DEFAULT 20,
  `by_name` varchar(120) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_manage_featured` (
  `license` varchar(64) NOT NULL,
  `models` longtext NOT NULL,
  PRIMARY KEY (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_manage_logs` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `action` varchar(50) NOT NULL,
  `title` varchar(160) NOT NULL,
  `description` text NOT NULL,
  `actor_name` varchar(120) NOT NULL,
  `actor_cid` varchar(60) DEFAULT NULL,
  `target_cid` varchar(60) DEFAULT NULL,
  `meta` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `created_at` (`created_at`),
  KEY `action` (`action`),
  KEY `actor_cid` (`actor_cid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_manage_notif_reads` (
  `license` varchar(60) NOT NULL,
  `read_at` int unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_activity_logs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(64) NOT NULL,
  `actor_name` varchar(100) NOT NULL DEFAULT '',
  `category` varchar(32) NOT NULL,
  `action` varchar(48) NOT NULL,
  `description` varchar(255) NOT NULL,
  `source_resource` varchar(64) NOT NULL DEFAULT '',
  `meta` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `citizenid_id` (`citizenid`,`id`),
  KEY `category_id` (`category`,`id`),
  KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_announcements` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `body` text DEFAULT NULL,
  `priority` varchar(16) NOT NULL DEFAULT 'normal',
  `pinned` tinyint NOT NULL DEFAULT 0,
  `job` varchar(64) NOT NULL DEFAULT '',
  `author` varchar(64) DEFAULT NULL,
  `author_name` varchar(64) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `pinned` (`pinned`),
  KEY `created_at` (`created_at`),
  KEY `job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_audit_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `action` varchar(32) DEFAULT NULL,
  `actor_name` varchar(64) DEFAULT NULL,
  `actor_cid` varchar(64) DEFAULT NULL,
  `title` varchar(128) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `meta` longtext DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `created_at` (`created_at`),
  KEY `action` (`action`),
  KEY `actor_cid_id` (`actor_cid`,`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_bolos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `subject_type` varchar(16) NOT NULL DEFAULT 'other',
  `subject_id` varchar(64) DEFAULT NULL,
  `title` varchar(128) NOT NULL,
  `details` text DEFAULT NULL,
  `priority` varchar(16) NOT NULL DEFAULT 'medium',
  `status` varchar(16) NOT NULL DEFAULT 'active',
  `created_by` varchar(64) DEFAULT NULL,
  `created_by_name` varchar(96) DEFAULT NULL,
  `updated_by` varchar(64) DEFAULT NULL,
  `updated_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `subject_type_subject_id` (`subject_type`,`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_court_filings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(160) NOT NULL DEFAULT '',
  `category` varchar(16) NOT NULL DEFAULT 'criminal',
  `status` varchar(16) NOT NULL DEFAULT 'FILED',
  `judge` varchar(96) NOT NULL DEFAULT '',
  `description` longtext DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_by` varchar(64) DEFAULT NULL,
  `created_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_court_hearings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `filing_id` int NOT NULL,
  `title` varchar(128) NOT NULL,
  `day` date NOT NULL,
  `created_by` varchar(64) DEFAULT NULL,
  `created_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `filing_id` (`filing_id`),
  KEY `day` (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_court_parties` (
  `id` int NOT NULL AUTO_INCREMENT,
  `filing_id` int NOT NULL,
  `role` varchar(16) NOT NULL,
  `citizenid` varchar(64) DEFAULT NULL,
  `name` varchar(96) NOT NULL,
  `lawyer` varchar(96) NOT NULL DEFAULT '',
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `filing_id` (`filing_id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_court_photos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `filing_id` int NOT NULL,
  `url` varchar(512) NOT NULL,
  `name` varchar(128) NOT NULL DEFAULT '',
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `filing_id` (`filing_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_court_posts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `filing_id` int NOT NULL,
  `citizenid` varchar(64) DEFAULT NULL,
  `author` varchar(96) NOT NULL,
  `text` text NOT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `filing_id` (`filing_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_court_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `filing_id` int NOT NULL,
  `report_id` int NOT NULL,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_filing_report` (`filing_id`,`report_id`),
  KEY `report_id` (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_duty_days` (
  `citizenid` varchar(64) NOT NULL,
  `job` varchar(64) NOT NULL,
  `day` date NOT NULL,
  `seconds` int unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`citizenid`,`job`,`day`),
  KEY `day` (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_duty_time` (
  `citizenid` varchar(64) NOT NULL,
  `job` varchar(64) NOT NULL,
  `seconds` int unsigned NOT NULL DEFAULT 0,
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`citizenid`,`job`),
  KEY `job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_fingerprints` (
  `citizenid` varchar(64) NOT NULL,
  `fingerprint` varchar(64) NOT NULL,
  `collected_by` varchar(64) DEFAULT NULL,
  `collected_by_name` varchar(96) DEFAULT NULL,
  `lab` varchar(64) DEFAULT NULL,
  `collected_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`citizenid`),
  KEY `fingerprint` (`fingerprint`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_lab_evidence` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `kind` varchar(24) NOT NULL,
  `raw_type` varchar(64) DEFAULT NULL,
  `raw_description` text DEFAULT NULL,
  `token` varchar(96) DEFAULT NULL,
  `plate` varchar(16) DEFAULT NULL,
  `subject_type` varchar(16) DEFAULT NULL,
  `subject_id` varchar(64) DEFAULT NULL,
  `subject_label` varchar(128) DEFAULT NULL,
  `extra_type` varchar(16) DEFAULT NULL,
  `extra_id` varchar(64) DEFAULT NULL,
  `extra_label` varchar(128) DEFAULT NULL,
  `matched` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  KEY `subject_type_subject_id` (`subject_type`,`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_lab_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(24) NOT NULL,
  `label` varchar(64) NOT NULL,
  `status` varchar(16) NOT NULL DEFAULT 'open',
  `owner_cid` varchar(64) DEFAULT NULL,
  `owner_name` varchar(96) DEFAULT NULL,
  `bench` varchar(64) DEFAULT NULL,
  `processed_by_name` varchar(96) DEFAULT NULL,
  `process_ends_at` bigint DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `code` (`code`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_lab_report_notes` (
  `report_id` varchar(64) NOT NULL,
  `notes` longtext DEFAULT NULL,
  `updated_by` varchar(64) DEFAULT NULL,
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_lab_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(24) NOT NULL,
  `label` varchar(64) NOT NULL,
  `order_id` int DEFAULT NULL,
  `submitted_by` varchar(64) DEFAULT NULL,
  `submitted_by_name` varchar(96) DEFAULT NULL,
  `intake` varchar(64) DEFAULT NULL,
  `evidence_count` int NOT NULL DEFAULT 0,
  `matched_count` int NOT NULL DEFAULT 0,
  `runs` int NOT NULL DEFAULT 1,
  `last_run_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `code` (`code`),
  KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_lab_runs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `run_no` int NOT NULL,
  `ran_by` varchar(64) DEFAULT NULL,
  `ran_by_name` varchar(96) DEFAULT NULL,
  `matched` int NOT NULL DEFAULT 0,
  `new_matches` int NOT NULL DEFAULT 0,
  `ran_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_license_types` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `identifier` varchar(64) NOT NULL,
  `description` text DEFAULT NULL,
  `image` varchar(512) DEFAULT NULL,
  `obtainable` tinyint NOT NULL DEFAULT 0,
  `price` int NOT NULL DEFAULT 0,
  `sort_order` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_license_type_name` (`name`),
  UNIQUE KEY `uniq_license_type_identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_notifications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(64) NOT NULL,
  `kind` varchar(32) NOT NULL,
  `data` text DEFAULT NULL,
  `is_read` tinyint NOT NULL DEFAULT 0,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_penal_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `color` varchar(16) NOT NULL DEFAULT '#8B97A6',
  `sort_order` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_penal_cat_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_penal_codes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `code` varchar(32) NOT NULL,
  `title` varchar(128) NOT NULL,
  `category` varchar(64) DEFAULT NULL,
  `class` varchar(16) NOT NULL DEFAULT 'Misdemeanor',
  `description` text DEFAULT NULL,
  `burdens` longtext DEFAULT NULL,
  `modifiers` longtext DEFAULT NULL,
  `hidden` tinyint NOT NULL DEFAULT 0,
  `internal` tinyint NOT NULL DEFAULT 0,
  `updated_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `category` (`category`),
  KEY `class` (`class`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_person_contacts` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(64) NOT NULL,
  `contact_cid` varchar(64) NOT NULL,
  `relationship` varchar(48) NOT NULL DEFAULT '',
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_person_contact` (`citizenid`,`contact_cid`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_person_licenses` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(64) NOT NULL,
  `type_id` int DEFAULT NULL,
  `type_identifier` varchar(64) NOT NULL DEFAULT '',
  `type_name` varchar(64) NOT NULL,
  `status` varchar(16) NOT NULL DEFAULT 'VALID',
  `reason` varchar(255) DEFAULT NULL,
  `issued_by_cid` varchar(64) DEFAULT NULL,
  `issued_by_name` varchar(64) DEFAULT NULL,
  `updated_by_cid` varchar(64) DEFAULT NULL,
  `updated_by_name` varchar(64) DEFAULT NULL,
  `issued_at` timestamp DEFAULT current_timestamp(),
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `citizenid_status` (`citizenid`,`status`),
  KEY `type_id` (`type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_person_notes` (
  `citizenid` varchar(64) NOT NULL,
  `notes` longtext DEFAULT NULL,
  `updated_by` varchar(64) DEFAULT NULL,
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_person_photos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(64) NOT NULL,
  `url` varchar(512) NOT NULL,
  `name` varchar(128) DEFAULT NULL,
  `is_primary` tinyint NOT NULL DEFAULT 0,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(64) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `citizenid_is_primary` (`citizenid`,`is_primary`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_person_tickets` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(64) NOT NULL,
  `type_id` int DEFAULT NULL,
  `type_name` varchar(64) NOT NULL,
  `amount` int NOT NULL DEFAULT 0,
  `reason` varchar(255) DEFAULT NULL,
  `status` varchar(16) NOT NULL DEFAULT 'UNPAID',
  `issued_by_cid` varchar(64) DEFAULT NULL,
  `issued_by_name` varchar(64) DEFAULT NULL,
  `updated_by_cid` varchar(64) DEFAULT NULL,
  `updated_by_name` varchar(64) DEFAULT NULL,
  `issued_at` timestamp DEFAULT current_timestamp(),
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `issued_job` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `citizenid_status` (`citizenid`,`status`),
  KEY `type_id` (`type_id`),
  KEY `issued_by_cid_issued_at` (`issued_by_cid`,`issued_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_persons` (
  `citizenid` varchar(64) NOT NULL,
  `name` varchar(96) NOT NULL,
  `birthdate` varchar(32) DEFAULT NULL,
  `gender` varchar(16) DEFAULT NULL,
  `nationality` varchar(64) DEFAULT NULL,
  `phone` varchar(32) DEFAULT NULL,
  `job` varchar(96) DEFAULT NULL,
  `deleted` tinyint NOT NULL DEFAULT 0,
  `deleted_at` timestamp NULL DEFAULT NULL,
  `last_seen` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`citizenid`),
  KEY `name` (`name`),
  KEY `deleted` (`deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_photo_categories` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `color` varchar(16) NOT NULL DEFAULT '#4A90E2',
  `sort_order` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_photo_cat_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_photos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `url` varchar(512) NOT NULL,
  `name` varchar(128) DEFAULT NULL,
  `category` varchar(64) DEFAULT NULL,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(64) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  `loc_x` float DEFAULT NULL,
  `loc_y` float DEFAULT NULL,
  `loc_z` float DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `category` (`category`),
  KEY `created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_prescriptions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(64) NOT NULL,
  `patient_name` varchar(96) NOT NULL DEFAULT '',
  `medication` varchar(96) NOT NULL,
  `dosage` varchar(48) NOT NULL DEFAULT '',
  `frequency` varchar(48) NOT NULL DEFAULT '',
  `notes` varchar(500) NOT NULL DEFAULT '',
  `status` varchar(16) NOT NULL DEFAULT 'ACTIVE',
  `cancel_reason` varchar(255) NOT NULL DEFAULT '',
  `expires_on` date DEFAULT NULL,
  `issued_by_cid` varchar(64) DEFAULT NULL,
  `issued_by_name` varchar(64) DEFAULT NULL,
  `updated_by_cid` varchar(64) DEFAULT NULL,
  `updated_by_name` varchar(64) DEFAULT NULL,
  `issued_at` timestamp DEFAULT current_timestamp(),
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `citizenid_status` (`citizenid`,`status`),
  KEY `issued_by_cid_issued_at` (`issued_by_cid`,`issued_at`),
  KEY `status_expires_on` (`status`,`expires_on`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_radio_channels` (
  `id` int NOT NULL AUTO_INCREMENT,
  `label` varchar(32) NOT NULL,
  `created_by` varchar(64) DEFAULT NULL,
  `created_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_record_shares` (
  `id` int NOT NULL AUTO_INCREMENT,
  `record_type` varchar(16) NOT NULL,
  `record_id` int NOT NULL,
  `citizenid` varchar(64) NOT NULL,
  `name` varchar(96) NOT NULL,
  `perms` varchar(64) NOT NULL DEFAULT 'view',
  `granted_by` varchar(64) DEFAULT NULL,
  `granted_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_share` (`record_type`,`record_id`,`citizenid`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_record_tags` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tag_id` int NOT NULL,
  `record_type` varchar(8) NOT NULL,
  `record_id` varchar(64) NOT NULL,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(64) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_record_tag` (`tag_id`,`record_type`,`record_id`),
  KEY `record_type_record_id` (`record_type`,`record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_charges` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `suspect_id` int NOT NULL,
  `penal_id` int DEFAULT NULL,
  `code` varchar(48) DEFAULT NULL,
  `label` varchar(160) NOT NULL,
  `felony` tinyint NOT NULL DEFAULT 0,
  `role` varchar(32) NOT NULL DEFAULT 'Principal',
  `time_months` int NOT NULL DEFAULT 0,
  `fine` int NOT NULL DEFAULT 0,
  `dropped` tinyint NOT NULL DEFAULT 0,
  `dropped_reason` varchar(160) DEFAULT NULL,
  `dropped_by` varchar(64) DEFAULT NULL,
  `dropped_by_name` varchar(96) DEFAULT NULL,
  `dropped_at` timestamp NULL DEFAULT NULL,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  KEY `suspect_id` (`suspect_id`),
  KEY `suspect_id_dropped` (`suspect_id`,`dropped`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_chat` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `citizenid` varchar(64) DEFAULT NULL,
  `author` varchar(96) NOT NULL,
  `text` varchar(300) NOT NULL,
  `is_system` tinyint NOT NULL DEFAULT 0,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_doj` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `citizenid` varchar(64) DEFAULT NULL,
  `name` varchar(96) NOT NULL,
  `role` varchar(48) NOT NULL DEFAULT 'Prosecutor',
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_lab_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `lab_report_id` int NOT NULL,
  `code` varchar(24) DEFAULT NULL,
  `label` varchar(64) DEFAULT NULL,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  KEY `lab_report_id` (`lab_report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_links` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `linked_report_id` int NOT NULL,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  KEY `linked_report_id` (`linked_report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_lockers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `locker_id` int NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  KEY `locker_id` (`locker_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_officers` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `citizenid` varchar(64) DEFAULT NULL,
  `name` varchar(96) NOT NULL,
  `status` varchar(16) NOT NULL DEFAULT 'Assisting',
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_parties` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `kind` varchar(16) NOT NULL,
  `citizenid` varchar(64) NOT NULL,
  `name` varchar(96) NOT NULL,
  `status` varchar(24) NOT NULL DEFAULT 'Pending',
  `statement` text DEFAULT NULL,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  KEY `report_id_kind` (`report_id`,`kind`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_photos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `url` varchar(512) NOT NULL,
  `name` varchar(128) NOT NULL DEFAULT '',
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_properties` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `property_id` varchar(64) DEFAULT NULL,
  `address` varchar(160) NOT NULL,
  `type` varchar(48) NOT NULL DEFAULT 'property',
  `owner_cid` varchar(64) DEFAULT NULL,
  `owner_name` varchar(96) DEFAULT NULL,
  `coords` varchar(96) DEFAULT NULL,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_suspects` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `citizenid` varchar(64) NOT NULL,
  `name` varchar(96) NOT NULL,
  `plea` varchar(16) NOT NULL DEFAULT 'Pending',
  `lawyer` varchar(96) NOT NULL DEFAULT '',
  `note` text DEFAULT NULL,
  `time_pct` int NOT NULL DEFAULT 100,
  `fine_pct` int NOT NULL DEFAULT 100,
  `booked_at` timestamp NULL DEFAULT NULL,
  `booked_by` varchar(64) DEFAULT NULL,
  `booked_by_name` varchar(96) DEFAULT NULL,
  `fine_status` varchar(16) NOT NULL DEFAULT 'UNPAID',
  `fine_paid_by_name` varchar(96) DEFAULT NULL,
  `fine_paid_at` timestamp NULL DEFAULT NULL,
  `sentence_months` int NOT NULL DEFAULT 0,
  `served_months` int DEFAULT NULL,
  `commuted_months` int DEFAULT NULL,
  `release_reason` varchar(16) DEFAULT NULL,
  `released_at` timestamp NULL DEFAULT NULL,
  `sentence_active` tinyint NOT NULL DEFAULT 0,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  `booked_job` varchar(64) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  KEY `citizenid` (`citizenid`),
  KEY `citizenid_sentence_active` (`citizenid`,`sentence_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_tasks` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `label` varchar(200) NOT NULL,
  `done` tinyint NOT NULL DEFAULT 0,
  `created_by` varchar(64) DEFAULT NULL,
  `created_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_vehicles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `plate` varchar(16) NOT NULL,
  `model` varchar(96) DEFAULT NULL,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  KEY `plate` (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_report_weapons` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` int NOT NULL,
  `serial` varchar(64) NOT NULL,
  `label` varchar(96) DEFAULT NULL,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `report_id` (`report_id`),
  KEY `serial` (`serial`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_reports` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(160) NOT NULL DEFAULT '',
  `type` varchar(48) NOT NULL DEFAULT 'Incident',
  `status` varchar(12) NOT NULL DEFAULT 'OPEN',
  `description` longtext DEFAULT NULL,
  `incident_date` date DEFAULT NULL,
  `location` varchar(160) NOT NULL DEFAULT '',
  `created_by` varchar(64) DEFAULT NULL,
  `created_by_name` varchar(96) DEFAULT NULL,
  `updated_by` varchar(64) DEFAULT NULL,
  `updated_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `created_at` (`created_at`),
  KEY `created_by` (`created_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_roles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `label` varchar(64) DEFAULT NULL,
  `color` varchar(16) DEFAULT NULL,
  `job` varchar(64) DEFAULT NULL,
  `grade` int NOT NULL DEFAULT 0,
  `require_duty` tinyint DEFAULT 0,
  `permissions` longtext DEFAULT NULL,
  `updated_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_roster_records` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(64) NOT NULL,
  `job` varchar(64) NOT NULL,
  `type` varchar(16) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `issued_by` varchar(64) DEFAULT NULL,
  `issued_by_name` varchar(64) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_stolen_vehicles` (
  `plate` varchar(16) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `flagged_by` varchar(64) DEFAULT NULL,
  `flagged_by_name` varchar(96) DEFAULT NULL,
  `flagged_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_tags` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(48) NOT NULL,
  `color` varchar(16) NOT NULL DEFAULT '#8B97A6',
  `scope` varchar(8) NOT NULL DEFAULT 'both',
  `sort_order` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_tag_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_ticket_types` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `color` varchar(16) NOT NULL DEFAULT '#8B97A6',
  `default_fine` int NOT NULL DEFAULT 0,
  `max_fine` int NOT NULL DEFAULT 0,
  `sort_order` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_ticket_type_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_user_prefs` (
  `citizenid` varchar(64) DEFAULT NULL,
  `settings` longtext DEFAULT NULL,
  `avatar` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_vehicle_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `plate` varchar(16) NOT NULL,
  `event` varchar(32) NOT NULL,
  `detail` varchar(255) DEFAULT NULL,
  `at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `plate_id` (`plate`,`id`),
  KEY `at` (`at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_vehicle_notes` (
  `plate` varchar(16) NOT NULL,
  `notes` longtext DEFAULT NULL,
  `updated_by` varchar(64) DEFAULT NULL,
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_vehicle_photos` (
  `id` int NOT NULL AUTO_INCREMENT,
  `plate` varchar(16) NOT NULL,
  `url` varchar(512) NOT NULL,
  `name` varchar(128) DEFAULT NULL,
  `is_primary` tinyint NOT NULL DEFAULT 0,
  `added_by` varchar(64) DEFAULT NULL,
  `added_by_name` varchar(64) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `plate` (`plate`),
  KEY `plate_is_primary` (`plate`,`is_primary`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_vehicles` (
  `plate` varchar(16) DEFAULT NULL,
  `reg_no` int DEFAULT NULL,
  `model` varchar(64) DEFAULT NULL,
  `owner_cid` varchar(64) DEFAULT NULL,
  `owner_name` varchar(128) DEFAULT NULL,
  `first_seen` timestamp DEFAULT current_timestamp(),
  `last_seen` timestamp DEFAULT current_timestamp(),
  `gone` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`plate`),
  KEY `gone` (`gone`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_wanted` (
  `subject_type` varchar(16) NOT NULL,
  `subject_id` varchar(64) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `flagged_by` varchar(64) DEFAULT NULL,
  `flagged_by_name` varchar(96) DEFAULT NULL,
  `flagged_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`subject_type`,`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_warrants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `subject_type` varchar(16) NOT NULL DEFAULT 'person',
  `subject_id` varchar(64) DEFAULT NULL,
  `subject_label` varchar(128) DEFAULT NULL,
  `warrant_type` varchar(16) NOT NULL DEFAULT 'arrest',
  `title` varchar(128) NOT NULL,
  `reason` text DEFAULT NULL,
  `priority` varchar(16) NOT NULL DEFAULT 'medium',
  `status` varchar(16) NOT NULL DEFAULT 'active',
  `judge` varchar(96) DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_by` varchar(64) DEFAULT NULL,
  `created_by_name` varchar(96) DEFAULT NULL,
  `updated_by` varchar(64) DEFAULT NULL,
  `updated_by_name` varchar(96) DEFAULT NULL,
  `created_at` timestamp DEFAULT current_timestamp(),
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `subject_type_subject_id` (`subject_type`,`subject_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_weapon_flags` (
  `serial` varchar(64) NOT NULL,
  `flag` varchar(16) NOT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `flagged_by` varchar(64) DEFAULT NULL,
  `flagged_by_name` varchar(96) DEFAULT NULL,
  `flagged_at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`serial`,`flag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_weapon_history` (
  `id` int NOT NULL AUTO_INCREMENT,
  `serial` varchar(64) NOT NULL,
  `event` varchar(32) NOT NULL,
  `detail` varchar(255) DEFAULT NULL,
  `at` timestamp DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `serial_id` (`serial`,`id`),
  KEY `at` (`at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_weapon_notes` (
  `serial` varchar(64) NOT NULL,
  `notes` longtext DEFAULT NULL,
  `updated_by` varchar(64) DEFAULT NULL,
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`serial`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_weapons` (
  `serial` varchar(64) NOT NULL,
  `weapon` varchar(64) NOT NULL,
  `label` varchar(64) DEFAULT NULL,
  `owner_cid` varchar(64) DEFAULT NULL,
  `owner_name` varchar(128) DEFAULT NULL,
  `source` varchar(32) NOT NULL DEFAULT 'manual',
  `origin` varchar(96) DEFAULT NULL,
  `origin_coords` varchar(64) DEFAULT NULL,
  `components` longtext DEFAULT NULL,
  `registered_by` varchar(64) DEFAULT NULL,
  `registered_by_name` varchar(96) DEFAULT NULL,
  `registered_at` timestamp DEFAULT current_timestamp(),
  `updated_at` timestamp DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `gone` tinyint NOT NULL DEFAULT 0,
  PRIMARY KEY (`serial`),
  KEY `owner_cid_gone` (`owner_cid`,`gone`),
  KEY `origin` (`origin`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mechanic_invoices` (
  `id` int NOT NULL AUTO_INCREMENT,
  `invoice_id` varchar(20) NOT NULL,
  `shop_job` varchar(50) NOT NULL,
  `customer_citizenid` varchar(50) DEFAULT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `mechanic_citizenid` varchar(50) DEFAULT NULL,
  `mechanic_name` varchar(100) DEFAULT NULL,
  `plate` varchar(20) DEFAULT NULL,
  `order_id` varchar(20) DEFAULT NULL,
  `rows` longtext DEFAULT NULL,
  `total_amount` int DEFAULT 0,
  `status` varchar(20) DEFAULT 'draft',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_id` (`invoice_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mechanic_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(20) NOT NULL,
  `shop_job` varchar(50) NOT NULL,
  `customer_citizenid` varchar(50) DEFAULT NULL,
  `customer_name` varchar(100) DEFAULT NULL,
  `plate` varchar(20) DEFAULT NULL,
  `vehicle_props` longtext DEFAULT NULL,
  `cart` longtext DEFAULT NULL,
  `parts` longtext DEFAULT NULL,
  `total_cost` int DEFAULT 0,
  `status` varchar(20) DEFAULT 'pending',
  `mechanic_citizenid` varchar(50) DEFAULT NULL,
  `mechanic_name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `completed_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_organization_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `org_id` int NOT NULL,
  `text` varchar(255) NOT NULL,
  `icon` varchar(50) NOT NULL DEFAULT 'info',
  `color` varchar(20) NOT NULL DEFAULT '#9B6DFF',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_org_id` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_organization_members` (
  `id` int NOT NULL AUTO_INCREMENT,
  `org_id` int NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `rank_id` varchar(32) NOT NULL DEFAULT 'member',
  `joined_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_citizenid` (`citizenid`),
  KEY `idx_org` (`org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_organization_upgrades` (
  `id` int NOT NULL AUTO_INCREMENT,
  `org_id` int NOT NULL,
  `upgrade_type` varchar(32) NOT NULL,
  `tier` int NOT NULL DEFAULT 1,
  `purchased_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_org_type` (`org_id`,`upgrade_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_organizations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(24) NOT NULL,
  `tag` varchar(3) NOT NULL,
  `color` varchar(7) NOT NULL DEFAULT '#57EFAF',
  `owner_citizenid` varchar(50) NOT NULL,
  `level` int NOT NULL DEFAULT 1,
  `xp` int NOT NULL DEFAULT 0,
  `member_capacity` int NOT NULL DEFAULT 8,
  `treasury` double NOT NULL DEFAULT 0,
  `upkeep_paid` tinyint NOT NULL DEFAULT 1,
  `upkeep_due_at` datetime DEFAULT NULL,
  `image` varchar(500) DEFAULT NULL,
  `status` varchar(16) NOT NULL DEFAULT 'active',
  `reviewed_by` varchar(50) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `hq_property_id` int DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `idx_name` (`name`),
  UNIQUE KEY `idx_tag` (`tag`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_albums` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `device_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(48) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_device_id` (`device_id`, `id`),
  CONSTRAINT `fk_albums_device` FOREIGN KEY (`device_id`) REFERENCES `meteo_phone_devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_bleeter_accounts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `handle` VARCHAR(20) NOT NULL,
  `name` VARCHAR(32) NOT NULL,
  `bio` VARCHAR(160) NOT NULL DEFAULT '',
  `avatar` VARCHAR(512) NOT NULL DEFAULT '#2FDC8C',  -- a color or an image link
  `password` VARCHAR(100) NOT NULL,                  -- bcrypt hash
  `owner` VARCHAR(50) DEFAULT NULL,                  -- the character that made it
  `verified` TINYINT(1) NOT NULL DEFAULT 0,
  `moderator` TINYINT(1) NOT NULL DEFAULT 0,
  `suspended` TINYINT(1) NOT NULL DEFAULT 0,
  `banned` TINYINT(1) NOT NULL DEFAULT 0,
  `followers` INT UNSIGNED NOT NULL DEFAULT 0,       -- counters, never a COUNT
  `following` INT UNSIGNED NOT NULL DEFAULT 0,
  `posts` INT UNSIGNED NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_handle` (`handle`),
  KEY `idx_owner` (`owner`),
  KEY `idx_popular` (`banned`, `suspended`, `followers`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_bleeter_likes` (
  `post_id` BIGINT UNSIGNED NOT NULL,
  `account_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`post_id`, `account_id`),
  KEY `idx_account` (`account_id`, `post_id`),
  CONSTRAINT `fk_bl_likes_post` FOREIGN KEY (`post_id`) REFERENCES `meteo_phone_bleeter_posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bl_likes_account` FOREIGN KEY (`account_id`) REFERENCES `meteo_phone_bleeter_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_bleeter_rebleets` (
  `post_id` BIGINT UNSIGNED NOT NULL,
  `account_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`post_id`, `account_id`),
  KEY `idx_account` (`account_id`, `post_id`),
  CONSTRAINT `fk_bl_rebleets_post` FOREIGN KEY (`post_id`) REFERENCES `meteo_phone_bleeter_posts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bl_rebleets_account` FOREIGN KEY (`account_id`) REFERENCES `meteo_phone_bleeter_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_bleeter_sessions` (
  `device_id` INT UNSIGNED NOT NULL,
  `account_id` INT UNSIGNED NOT NULL,
  `active` TINYINT(1) NOT NULL DEFAULT 0,
  `signed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`device_id`, `account_id`),
  KEY `idx_account` (`account_id`, `active`),
  CONSTRAINT `fk_bl_sessions_device` FOREIGN KEY (`device_id`) REFERENCES `meteo_phone_devices` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bl_sessions_account` FOREIGN KEY (`account_id`) REFERENCES `meteo_phone_bleeter_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_calendar_events` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `device_id` INT UNSIGNED NOT NULL,     -- the host
  `host_name` VARCHAR(48) NOT NULL,
  `title` VARCHAR(80) NOT NULL,
  `details` VARCHAR(1000) NOT NULL DEFAULT '',
  `images` TEXT DEFAULT NULL,
  `start_at` BIGINT NOT NULL,
  `end_at` BIGINT NOT NULL,
  `all_day` TINYINT(1) NOT NULL DEFAULT 0,
  `color` VARCHAR(9) NOT NULL DEFAULT '#0A84FF',
  `location` TEXT DEFAULT NULL,
  `cancelled` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_host_start` (`device_id`, `start_at`),
  KEY `idx_start` (`start_at`),
  CONSTRAINT `fk_calendar_events_device` FOREIGN KEY (`device_id`) REFERENCES `meteo_phone_devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_calls` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `sim_id` INT UNSIGNED NOT NULL,
  `number` VARCHAR(16) NOT NULL,
  `direction` ENUM('incoming', 'outgoing', 'missed') NOT NULL,
  `video` TINYINT(1) NOT NULL DEFAULT 0,
  `duration` INT UNSIGNED NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sim_id` (`sim_id`, `id`),
  KEY `idx_sim_number` (`sim_id`, `number`, `id`), -- one caller's history
  KEY `idx_created` (`created_at`),
  CONSTRAINT `fk_calls_sim` FOREIGN KEY (`sim_id`) REFERENCES `meteo_phone_sims` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_contacts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `sim_id` INT UNSIGNED NOT NULL,
  `number` VARCHAR(16) NOT NULL,
  `name` VARCHAR(48) NOT NULL,
  `avatar` VARCHAR(512) DEFAULT NULL,
  `note` VARCHAR(255) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_sim_number` (`sim_id`, `number`),
  KEY `idx_sim_name` (`sim_id`, `name`),
  CONSTRAINT `fk_contacts_sim` FOREIGN KEY (`sim_id`) REFERENCES `meteo_phone_sims` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_emails` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `device_id` INT UNSIGNED NOT NULL,
  `sender` VARCHAR(64) NOT NULL,
  `address` VARCHAR(96) NOT NULL,
  `subject` VARCHAR(160) NOT NULL,
  `preview` VARCHAR(255) NOT NULL DEFAULT '',
  `body` TEXT DEFAULT NULL,
  `seen` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_device_id` (`device_id`, `id`),
  KEY `idx_device_unseen` (`device_id`, `seen`),
  CONSTRAINT `fk_emails_device` FOREIGN KEY (`device_id`) REFERENCES `meteo_phone_devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_gallery` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `device_id` INT UNSIGNED NOT NULL,
  `kind` ENUM('image', 'video') NOT NULL DEFAULT 'image',
  `url` VARCHAR(512) NOT NULL,
  `thumb` VARCHAR(512) NOT NULL,
  `duration` SMALLINT UNSIGNED NOT NULL DEFAULT 0,
  `favorite` TINYINT(1) NOT NULL DEFAULT 0,
  `location` VARCHAR(96) DEFAULT NULL, -- where it was taken, when the phone tags photos
  `pos_x` FLOAT DEFAULT NULL, -- the world spot it was taken at
  `pos_y` FLOAT DEFAULT NULL,
  `deleted_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_device_live` (`device_id`, `deleted_at`, `id`),
  KEY `idx_device_favorite` (`device_id`, `favorite`, `deleted_at`),
  KEY `idx_device_kind` (`device_id`, `kind`, `deleted_at`),
  CONSTRAINT `fk_gallery_device` FOREIGN KEY (`device_id`) REFERENCES `meteo_phone_devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_messages` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `conversation_id` INT UNSIGNED NOT NULL,
  `sender` VARCHAR(16) NOT NULL,
  `type` VARCHAR(16) NOT NULL DEFAULT 'text',
  `content` VARCHAR(1024) NOT NULL DEFAULT '',
  `payload` MEDIUMTEXT DEFAULT NULL,
  `hidden_for` VARCHAR(16) DEFAULT NULL, -- a number that blocked the sender
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_conversation` (`conversation_id`, `id`),
  KEY `idx_kind` (`conversation_id`, `type`, `id`),
  CONSTRAINT `fk_messages_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `meteo_phone_conversations` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_music_accounts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(20) NOT NULL,
  `name` VARCHAR(32) NOT NULL,
  `avatar` VARCHAR(512) NOT NULL DEFAULT '#FF6E96',  -- a color or an image link
  `password` VARCHAR(100) NOT NULL,                  -- bcrypt hash
  `owner` VARCHAR(50) DEFAULT NULL,                  -- the character that made it
  `artist_status` ENUM('none', 'pending', 'approved', 'rejected', 'suspended') NOT NULL DEFAULT 'none',
  `artist_name` VARCHAR(48) DEFAULT NULL,
  `artist_bio` VARCHAR(200) NOT NULL DEFAULT '',
  `status_reason` VARCHAR(255) DEFAULT NULL,
  `verified` TINYINT(1) NOT NULL DEFAULT 0,
  `followers` INT UNSIGNED NOT NULL DEFAULT 0,       -- counters, never a COUNT
  `total_plays` INT UNSIGNED NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_username` (`username`),
  KEY `idx_owner` (`owner`),
  KEY `idx_artists` (`artist_status`, `followers`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_music_likes` (
  `track_id` INT UNSIGNED NOT NULL,
  `account_id` INT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`track_id`, `account_id`),
  KEY `idx_account` (`account_id`, `created_at`),
  CONSTRAINT `fk_mu_likes_track` FOREIGN KEY (`track_id`) REFERENCES `meteo_phone_music_tracks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mu_likes_account` FOREIGN KEY (`account_id`) REFERENCES `meteo_phone_music_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_music_playlists` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `account_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(48) NOT NULL,
  `collaborative` TINYINT(1) NOT NULL DEFAULT 0,
  `featured` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_account` (`account_id`, `updated_at`),
  KEY `idx_featured` (`featured`),
  CONSTRAINT `fk_mu_playlists_account` FOREIGN KEY (`account_id`) REFERENCES `meteo_phone_music_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_music_sessions` (
  `device_id` INT UNSIGNED NOT NULL,
  `account_id` INT UNSIGNED NOT NULL,
  `active` TINYINT(1) NOT NULL DEFAULT 0,
  `signed_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`device_id`, `account_id`),
  KEY `idx_account` (`account_id`),
  CONSTRAINT `fk_mu_sessions_device` FOREIGN KEY (`device_id`) REFERENCES `meteo_phone_devices` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mu_sessions_account` FOREIGN KEY (`account_id`) REFERENCES `meteo_phone_music_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_notes` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `device_id` INT UNSIGNED NOT NULL,
  `title` VARCHAR(120) NOT NULL DEFAULT '',
  `preview` VARCHAR(255) NOT NULL DEFAULT '',
  `content` MEDIUMTEXT DEFAULT NULL,
  `pinned` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_device_board` (`device_id`, `pinned`, `updated_at`),
  KEY `idx_device_updated` (`device_id`, `updated_at`),
  CONSTRAINT `fk_notes_device` FOREIGN KEY (`device_id`) REFERENCES `meteo_phone_devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_racing_players` (
  `citizenid` varchar(64) NOT NULL,
  `name` varchar(64) DEFAULT NULL,
  `elo` int NOT NULL DEFAULT 1000,
  `peak_elo` int NOT NULL DEFAULT 1000,
  `races` int unsigned NOT NULL DEFAULT 0,
  `ranked_races` int unsigned NOT NULL DEFAULT 0,
  `wins` int unsigned NOT NULL DEFAULT 0,
  `p2` int unsigned NOT NULL DEFAULT 0,
  `p3` int unsigned NOT NULL DEFAULT 0,
  `podiums` int unsigned NOT NULL DEFAULT 0,
  `dnf` int unsigned NOT NULL DEFAULT 0,
  `place_sum` int unsigned NOT NULL DEFAULT 0,
  `crypto_won` double NOT NULL DEFAULT 0,
  `time_raced_ms` bigint unsigned NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`citizenid`),
  KEY `idx_elo` (`elo`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_racing_results` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(64) NOT NULL,
  `track_id` int unsigned DEFAULT NULL,
  `track_name` varchar(64) DEFAULT NULL,
  `place` int NOT NULL DEFAULT 0,
  `field_size` int NOT NULL DEFAULT 1,
  `ranked` tinyint NOT NULL DEFAULT 0,
  `finished` tinyint NOT NULL DEFAULT 0,
  `time_ms` int unsigned DEFAULT NULL,
  `laps` int unsigned NOT NULL DEFAULT 1,
  `payout` double NOT NULL DEFAULT 0,
  `elo_before` int DEFAULT NULL,
  `elo_after` int DEFAULT NULL,
  `vehicle` varchar(48) DEFAULT NULL,
  `vehicle_class` varchar(8) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_cid` (`citizenid`),
  KEY `idx_track` (`track_id`),
  KEY `idx_when` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_racing_tracks` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `creator` varchar(64) DEFAULT NULL,
  `creator_name` varchar(64) DEFAULT NULL,
  `data` longtext NOT NULL,
  `object_count` int unsigned NOT NULL DEFAULT 0,
  `checkpoint_count` int unsigned NOT NULL DEFAULT 0,
  `track_type` varchar(24) NOT NULL DEFAULT 'Circuit',
  `difficulty` varchar(16) NOT NULL DEFAULT 'Medium',
  `ranked` tinyint NOT NULL DEFAULT 1,
  `prizes_enabled` tinyint NOT NULL DEFAULT 1,
  `entry_min` double NOT NULL DEFAULT 0,
  `entry_max` double NOT NULL DEFAULT 0,
  `host_fee` double NOT NULL DEFAULT 0,
  `times_raced` int unsigned NOT NULL DEFAULT 0,
  `record_ms` int unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_creator` (`creator`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_repojob` (
  `citizenid` varchar(50) NOT NULL,
  `xp` int NOT NULL DEFAULT 0,
  `total_repos` int NOT NULL DEFAULT 0,
  `total_earned` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_report_chats` (
  `id` int NOT NULL AUTO_INCREMENT,
  `report_id` varchar(50) NOT NULL,
  `sender_citizenid` varchar(50) NOT NULL,
  `sender_name` varchar(100) NOT NULL,
  `sender_type` enum('user','admin') NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_report` (`report_id`),
  KEY `idx_report_unread` (`report_id`, `sender_type`, `is_read`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_reports` (
  `id` varchar(50) NOT NULL,
  `type` enum('player','general','question') NOT NULL,
  `reporter_citizenid` varchar(50) NOT NULL,
  `reporter_name` varchar(100) NOT NULL,
  `reported_player` varchar(255) DEFAULT NULL,
  `reported_player_citizenid` varchar(50) DEFAULT NULL,
  `category` varchar(100) NOT NULL,
  `priority` enum('low','medium','high','urgent') NOT NULL DEFAULT 'medium',
  `title` varchar(255) DEFAULT NULL,
  `description` text NOT NULL,
  `evidence` text DEFAULT NULL,
  `status` enum('pending','investigating','resolved','closed','archived') NOT NULL DEFAULT 'pending',
  `assigned_admin` varchar(50) DEFAULT NULL,
  `assigned_admin_name` varchar(100) DEFAULT NULL,
  `resolution_notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `resolved_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_reporter` (`reporter_citizenid`),
  KEY `idx_reported` (`reported_player_citizenid`),
  KEY `idx_status_created` (`status`, `created_at`),
  KEY `idx_type` (`type`),
  KEY `idx_priority` (`priority`),
  KEY `idx_updated` (`updated_at`),
  KEY `idx_resolved_at` (`resolved_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurant_app_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurantId` int NOT NULL,
  `question_text` text NOT NULL,
  `sort_order` int DEFAULT 0,
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_restaurant` (`restaurantId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurant_app_settings` (
  `restaurantId` int NOT NULL,
  `applications_enabled` tinyint DEFAULT 1,
  PRIMARY KEY (`restaurantId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurant_applications` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurantId` int NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `name` varchar(100) NOT NULL,
  `phone` varchar(20) DEFAULT NULL,
  `answers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`answers`)),
  `status` varchar(20) DEFAULT 'pending',
  `reviewed_by` varchar(100) DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_restaurant_status` (`restaurantId`,`status`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurant_banking_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurantId` int NOT NULL,
  `type` enum('deposit','withdraw','order_payment','commission','bonus','paycheck','ingredients','phone_transfer','shop_sale') NOT NULL,
  `amount` int NOT NULL,
  `balanceAfter` int NOT NULL,
  `performedBy` varchar(50) DEFAULT NULL,
  `performedByName` varchar(100) DEFAULT NULL,
  `targetCitizenid` varchar(50) DEFAULT NULL,
  `targetName` varchar(100) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_restaurant` (`restaurantId`),
  KEY `idx_type` (`type`),
  KEY `idx_created` (`createdAt`),
  KEY `idx_restaurant_created` (`restaurantId`,`createdAt`),
  CONSTRAINT `meteo_restaurant_banking_logs_ibfk_1` FOREIGN KEY (`restaurantId`) REFERENCES `meteo_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurant_doors` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurantId` int NOT NULL,
  `name` varchar(100) DEFAULT NULL,
  `data` longtext NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_restaurant` (`restaurantId`),
  CONSTRAINT `meteo_restaurant_doors_ibfk_1` FOREIGN KEY (`restaurantId`) REFERENCES `meteo_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurant_earnings` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurantId` int NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `type` enum('commission','bonus','paycheck') NOT NULL,
  `amount` int NOT NULL,
  `paidBy` varchar(50) DEFAULT NULL,
  `paidByName` varchar(100) DEFAULT NULL,
  `note` varchar(255) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_restaurant` (`restaurantId`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_type` (`type`),
  KEY `idx_created` (`createdAt`),
  CONSTRAINT `meteo_restaurant_earnings_ibfk_1` FOREIGN KEY (`restaurantId`) REFERENCES `meteo_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurant_employees` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurantId` int NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `grade` int DEFAULT 0,
  `clockedIn` tinyint DEFAULT 0,
  `clockInTime` timestamp NULL DEFAULT NULL,
  `suspendedUntil` timestamp NULL DEFAULT NULL,
  `hiredAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_employee` (`restaurantId`,`citizenid`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_restaurant` (`restaurantId`),
  CONSTRAINT `meteo_restaurant_employees_ibfk_1` FOREIGN KEY (`restaurantId`) REFERENCES `meteo_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurant_locations` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurantId` int NOT NULL,
  `type` varchar(50) NOT NULL,
  `label` varchar(100) DEFAULT NULL,
  `coords` longtext NOT NULL,
  `size` longtext DEFAULT NULL,
  `rotation` float DEFAULT 0,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_restaurant` (`restaurantId`),
  KEY `idx_type` (`type`),
  CONSTRAINT `meteo_restaurant_locations_ibfk_1` FOREIGN KEY (`restaurantId`) REFERENCES `meteo_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurant_orders` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurantId` int NOT NULL,
  `items` longtext NOT NULL,
  `totalPrice` int NOT NULL,
  `status` enum('pending','preparing','ready','completed','cancelled') DEFAULT 'pending',
  `createdBy` varchar(50) DEFAULT NULL,
  `preparingBy` varchar(50) DEFAULT NULL,
  `preparingAt` timestamp NULL DEFAULT NULL,
  `completedBy` varchar(50) DEFAULT NULL,
  `commissionEarned` int DEFAULT 0,
  `paidBy` varchar(50) DEFAULT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `completedAt` timestamp NULL DEFAULT NULL,
  `isPaid` tinyint DEFAULT 0,
  `paidAt` timestamp NULL DEFAULT NULL,
  `isCollected` tinyint DEFAULT 0,
  `collectedAt` timestamp NULL DEFAULT NULL,
  `collectedBy` varchar(50) DEFAULT NULL,
  `orderNumber` int DEFAULT 0,
  `cancelledBy` varchar(50) DEFAULT NULL,
  `cancelledAt` timestamp NULL DEFAULT NULL,
  `tax` int(11) NOT NULL DEFAULT 0,
  `taxRate` decimal(6,2) NOT NULL DEFAULT 0.00,
  PRIMARY KEY (`id`),
  KEY `idx_restaurant_status` (`restaurantId`,`status`),
  KEY `idx_completedBy` (`completedBy`),
  CONSTRAINT `meteo_restaurant_orders_ibfk_1` FOREIGN KEY (`restaurantId`) REFERENCES `meteo_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurant_performance` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurantId` int NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `date` date NOT NULL,
  `itemsCooked` int DEFAULT 0,
  `ordersCompleted` int DEFAULT 0,
  `salesValue` int DEFAULT 0,
  `commissionEarned` int DEFAULT 0,
  `commissionPaid` tinyint DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_daily` (`restaurantId`,`citizenid`,`date`),
  KEY `idx_restaurant` (`restaurantId`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_date` (`date`),
  KEY `idx_unpaid` (`restaurantId`,`commissionPaid`),
  CONSTRAINT `meteo_restaurant_performance_ibfk_1` FOREIGN KEY (`restaurantId`) REFERENCES `meteo_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurant_shop_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurantId` int NOT NULL,
  `itemName` varchar(100) NOT NULL,
  `itemLabel` varchar(255) NOT NULL,
  `quantity` int NOT NULL,
  `totalPrice` int NOT NULL,
  `paymentMethod` enum('cash','bank') NOT NULL,
  `customerName` varchar(255) NOT NULL,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_restaurant` (`restaurantId`),
  KEY `idx_created` (`createdAt`),
  KEY `idx_restaurant_created` (`restaurantId`,`createdAt`),
  CONSTRAINT `meteo_restaurant_shop_logs_ibfk_1` FOREIGN KEY (`restaurantId`) REFERENCES `meteo_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurant_work_logs` (
  `id` int NOT NULL AUTO_INCREMENT,
  `restaurantId` int NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `action` enum('clock_in','clock_out','hired','fired','promoted','demoted','suspended','unsuspended','commission_paid','bonus_paid','item_cooked','order_completed','paycheck') NOT NULL,
  `details` text DEFAULT NULL,
  `performedBy` varchar(50) DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_restaurant` (`restaurantId`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_action` (`action`),
  KEY `idx_timestamp` (`timestamp`),
  CONSTRAINT `meteo_restaurant_work_logs_ibfk_1` FOREIGN KEY (`restaurantId`) REFERENCES `meteo_restaurants` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `coords` longtext DEFAULT NULL,
  `blipSprite` int DEFAULT 106,
  `blipColor` int DEFAULT 0,
  `owner` varchar(50) DEFAULT NULL,
  `enabledCategories` longtext DEFAULT NULL,
  `bank` int DEFAULT 0,
  `totalSales` int DEFAULT 0,
  `ordersCount` int DEFAULT 0,
  `totalRevenue` int DEFAULT 0,
  `commissionRate` int DEFAULT 15,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `customPrices` longtext DEFAULT NULL,
  `workRadius` float DEFAULT 50,
  `shopEnabled` tinyint DEFAULT 1,
  `shopRevenue` int DEFAULT 0,
  `blipEnabled` tinyint DEFAULT 1,
  `bank_synced` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_scene_images` (
  `id` int NOT NULL AUTO_INCREMENT,
  `label` varchar(60) NOT NULL,
  `url` varchar(256) NOT NULL,
  `added_by` varchar(60) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_scenes` (
  `id` int NOT NULL AUTO_INCREMENT,
  `display` longtext NOT NULL,
  `coords` varchar(120) NOT NULL,
  `rotation` varchar(120) DEFAULT NULL,
  `citizenid` varchar(60) NOT NULL,
  `is_staff` tinyint NOT NULL DEFAULT 0,
  `org_id` int DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`),
  KEY `expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_settings` (
  `resource` varchar(64) NOT NULL,
  `setting_key` varchar(128) NOT NULL,
  `value` longtext DEFAULT NULL,
  `is_custom` tinyint NOT NULL DEFAULT 0,
  `changed_by` varchar(64) DEFAULT NULL,
  `changed_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`resource`,`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_taxijob` (
  `citizenid` varchar(50) NOT NULL,
  `xp` int NOT NULL DEFAULT 0,
  `total_fares` int NOT NULL DEFAULT 0,
  `total_earned` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_transitjob` (
  `citizenid` varchar(50) NOT NULL,
  `xp` int NOT NULL DEFAULT 0,
  `total_routes` int NOT NULL DEFAULT 0,
  `total_earned` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_weed_plants` (
  `id` int NOT NULL AUTO_INCREMENT,
  `owner` varchar(50) NOT NULL,
  `coords` text NOT NULL,
  `heading` float NOT NULL DEFAULT 0,
  `water` float NOT NULL DEFAULT 100,
  `fertilizer` float NOT NULL DEFAULT 0,
  `health` float NOT NULL DEFAULT 100,
  `growth` float NOT NULL DEFAULT 0,
  `stage` int NOT NULL DEFAULT 1,
  `planted_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `ox_doorlock` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `data` longtext NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `player_vehicles` (
  `id` int NOT NULL AUTO_INCREMENT,
  `license` varchar(50) DEFAULT NULL,
  `citizenid` varchar(50) DEFAULT NULL,
  `vehicle` varchar(50) DEFAULT NULL,
  `hash` varchar(50) DEFAULT NULL,
  `mods` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `plate` varchar(8) NOT NULL,
  `fakeplate` varchar(8) DEFAULT NULL,
  `garage` varchar(50) DEFAULT NULL,
  `fuel` int DEFAULT 100,
  `engine` float DEFAULT 1000,
  `body` float DEFAULT 1000,
  `state` int DEFAULT 1,
  `depotprice` int NOT NULL DEFAULT 0,
  `impound_reason` varchar(255) DEFAULT NULL,
  `impound_until` int unsigned DEFAULT NULL,
  `isfav` tinyint DEFAULT 0,
  `drivingdistance` int DEFAULT NULL,
  `status` text DEFAULT NULL,
  `balance` int NOT NULL DEFAULT 0,
  `paymentamount` int NOT NULL DEFAULT 0,
  `paymentsleft` int NOT NULL DEFAULT 0,
  `financetime` int NOT NULL DEFAULT 0,
  `mileage` float NOT NULL DEFAULT 0,
  `financed` tinyint NOT NULL DEFAULT 0,
  `finance_data` longtext DEFAULT NULL,
  `nitrous` tinyint NOT NULL DEFAULT 0,
  `trunk` longtext DEFAULT NULL,
  `glovebox` longtext DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `plate` (`plate`),
  KEY `citizenid` (`citizenid`),
  KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `players` (
  `id` int NOT NULL AUTO_INCREMENT,
  `userId` int unsigned DEFAULT NULL,
  `citizenid` varchar(50) NOT NULL,
  `cid` int DEFAULT NULL,
  `license` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `money` text NOT NULL,
  `charinfo` text DEFAULT NULL,
  `job` text NOT NULL,
  `gang` text DEFAULT NULL,
  `position` text NOT NULL,
  `metadata` text NOT NULL,
  `inventory` longtext DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `last_logged_out` timestamp NULL DEFAULT NULL,
  `playtime` int DEFAULT 0,
  `dispatch_status` varchar(20) DEFAULT 'available',
  `crafting_level` varchar(255) DEFAULT '{"level":1,"xp":0}',
  PRIMARY KEY (`citizenid`),
  KEY `id` (`id`),
  KEY `last_updated` (`last_updated`),
  KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `users` (
  `userId` int unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(255) DEFAULT NULL,
  `license` varchar(50) DEFAULT NULL,
  `license2` varchar(50) DEFAULT NULL,
  `fivem` varchar(20) DEFAULT NULL,
  `discord` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`userId`),
  UNIQUE KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `player_groups` (
  `citizenid` varchar(50) NOT NULL,
  `group` varchar(50) NOT NULL,
  `type` varchar(50) NOT NULL,
  `grade` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`citizenid`, `type`, `group`),
  CONSTRAINT `fk_citizenid` FOREIGN KEY (`citizenid`)
    REFERENCES `players` (`citizenid`) ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `playerskins` (
  `id` int NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `model` varchar(255) NOT NULL,
  `skin` longtext NOT NULL,
  `active` tinyint NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenid_model` (`citizenid`,`model`),
  KEY `citizenid` (`citizenid`),
  KEY `active` (`active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_appearance_custom_peds` (
  `citizenid` VARCHAR(50) NOT NULL PRIMARY KEY,
  `model` VARCHAR(64) NOT NULL,
  `backup` LONGTEXT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_bank_accounts` (
  id         INT UNSIGNED NOT NULL AUTO_INCREMENT,
  type       ENUM('player', 'personal', 'job', 'gang', 'business') NOT NULL,
  owner      VARCHAR(64)  NOT NULL,
  org_key    VARCHAR(80)  DEFAULT NULL,
  name       VARCHAR(64)  NOT NULL,
  number     VARCHAR(16)  NOT NULL,
  balance    BIGINT       NOT NULL DEFAULT 0,
  frozen     TINYINT(1)   NOT NULL DEFAULT 0,
  closed     TINYINT(1)   NOT NULL DEFAULT 0,
  created_at INT UNSIGNED NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY org_key (org_key),
  UNIQUE KEY number (number),
  KEY owner_type (owner, type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_bank_activity` (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  account_id INT UNSIGNED    NOT NULL,
  kind       VARCHAR(12)     NOT NULL,
  action     VARCHAR(32)     NOT NULL,
  actor      VARCHAR(64)     DEFAULT NULL,
  actor_name VARCHAR(64)     DEFAULT NULL,
  target     VARCHAR(96)     DEFAULT NULL,
  meta       VARCHAR(255)    DEFAULT NULL,
  created_at INT UNSIGNED    NOT NULL,
  PRIMARY KEY (id),
  KEY account_page (account_id, id),
  KEY created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_bank_bills` (
  id          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  account_id  INT UNSIGNED NOT NULL,
  sender      VARCHAR(64)  DEFAULT NULL,
  sender_name VARCHAR(64)  NOT NULL,
  target      VARCHAR(64)  NOT NULL,
  target_name VARCHAR(64)  NOT NULL,
  amount      BIGINT       NOT NULL,
  reason      VARCHAR(120) DEFAULT NULL,
  status      ENUM('pending', 'paid', 'cancelled', 'declined') NOT NULL DEFAULT 'pending',
  resource    VARCHAR(64)  DEFAULT NULL,
  created_at  INT UNSIGNED NOT NULL,
  closed_at   INT UNSIGNED DEFAULT NULL,
  PRIMARY KEY (id),
  KEY target_status (target, status),
  KEY sender (sender, id),
  KEY account_status (account_id, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_bank_daily` (
  account_id INT UNSIGNED NOT NULL,
  day        INT UNSIGNED NOT NULL,
  money_in   BIGINT       NOT NULL DEFAULT 0,
  money_out  BIGINT       NOT NULL DEFAULT 0,
  closing    BIGINT       DEFAULT NULL,
  tx_count   INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (account_id, day)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_bank_invites` (
  account_id  INT UNSIGNED     NOT NULL,
  citizenid   VARCHAR(64)      NOT NULL,
  name        VARCHAR(64)      NOT NULL,
  perms       TINYINT UNSIGNED NOT NULL DEFAULT 1,
  daily_limit BIGINT           DEFAULT NULL,
  invited_by  VARCHAR(64)      NOT NULL,
  inviter     VARCHAR(64)      NOT NULL,
  expires_at  INT UNSIGNED     NOT NULL,
  PRIMARY KEY (account_id, citizenid),
  KEY citizenid (citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_bank_members` (
  account_id  INT UNSIGNED     NOT NULL,
  citizenid   VARCHAR(64)      NOT NULL,
  name        VARCHAR(64)      NOT NULL,
  perms       TINYINT UNSIGNED NOT NULL DEFAULT 1,
  daily_limit BIGINT           DEFAULT NULL,
  added_by    VARCHAR(64)      DEFAULT NULL,
  added_at    INT UNSIGNED     NOT NULL,
  PRIMARY KEY (account_id, citizenid),
  KEY citizenid (citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_bank_transactions` (
  id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  account_id      INT UNSIGNED    NOT NULL,
  category        VARCHAR(16)     NOT NULL,
  amount          BIGINT          NOT NULL,
  balance_after   BIGINT          DEFAULT NULL,
  title           VARCHAR(96)     NOT NULL,
  description     VARCHAR(255)    DEFAULT NULL,
  counterparty    VARCHAR(96)     DEFAULT NULL,
  counter_account INT UNSIGNED    DEFAULT NULL,
  actor           VARCHAR(64)     DEFAULT NULL,
  actor_name      VARCHAR(64)     DEFAULT NULL,
  resource        VARCHAR(64)     DEFAULT NULL,
  location        VARCHAR(64)     DEFAULT NULL,
  metadata        TEXT            DEFAULT NULL,
  created_at      INT UNSIGNED    NOT NULL,
  PRIMARY KEY (id),
  KEY account_page (account_id, id),
  KEY account_actor (account_id, actor, created_at),
  KEY created_at (created_at),
  KEY idx_amount (amount)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_casino_daily` (
  `day` DATE NOT NULL,
  `game` VARCHAR(16) NOT NULL,
  `rounds` INT UNSIGNED NOT NULL DEFAULT 0,
  `wagered` BIGINT NOT NULL DEFAULT 0,
  `paid_out` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`day`, `game`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_casino_events` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type` VARCHAR(24) NOT NULL,
  `citizenid` VARCHAR(50) NOT NULL,
  `game` VARCHAR(16) NOT NULL,
  `amount` BIGINT NOT NULL DEFAULT 0,
  `meta` LONGTEXT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `created_at` (`created_at`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_casino_ledger` (
  `ref` VARCHAR(40) NOT NULL,
  `citizenid` VARCHAR(50) NOT NULL,
  `game` VARCHAR(16) NOT NULL,
  `amount` BIGINT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ref`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_casino_pending` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `amount` BIGINT NOT NULL,
  `reason` VARCHAR(32) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_casino_player_daily` (
  `citizenid` VARCHAR(50) NOT NULL,
  `day` DATE NOT NULL,
  `game` VARCHAR(16) NOT NULL,
  `rounds` INT UNSIGNED NOT NULL DEFAULT 0,
  `wagered` BIGINT NOT NULL DEFAULT 0,
  `paid_out` BIGINT NOT NULL DEFAULT 0,
  `biggest_win` BIGINT NOT NULL DEFAULT 0,
  PRIMARY KEY (`citizenid`, `day`, `game`),
  KEY `day` (`day`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_casino_players` (
  `citizenid` VARCHAR(50) NOT NULL,
  `name` VARCHAR(100) NOT NULL,
  `last_seen` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`citizenid`),
  KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_creator_records` (
  `resource`   VARCHAR(64)  NOT NULL,
  `record_id`  VARCHAR(64)  NOT NULL,
  `data`       LONGTEXT     NOT NULL,
  `enabled`    TINYINT(1)   NOT NULL DEFAULT 1,
  `sort`       INT          NOT NULL DEFAULT 0,
  `changed_by` VARCHAR(64)  DEFAULT NULL,
  `changed_at` TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`resource`, `record_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_creator_state` (
  resource   VARCHAR(64) NOT NULL,
  seeded     TINYINT(1)  NOT NULL DEFAULT 0,
  seeded_at  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (resource)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_configs` (
  `id` varchar(50) NOT NULL,
  `data` longtext NOT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_presets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `data` longtext NOT NULL,
  `created_by` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `preset_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_dealership_roles` (
  `dealership` varchar(50) NOT NULL,
  `grade` int(11) NOT NULL,
  `label` varchar(32) NOT NULL,
  `paycheck` int(11) NOT NULL DEFAULT 0,
  `commission` int(11) NOT NULL DEFAULT 0,
  `permissions` longtext DEFAULT NULL,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`dealership`, `grade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_gym` (
  `citizenid` varchar(50) NOT NULL,
  `strength` float NOT NULL DEFAULT 0,
  `dexterity` float NOT NULL DEFAULT 0,
  `endurance` float NOT NULL DEFAULT 0,
  `strength_at` int(10) unsigned NOT NULL DEFAULT 0,
  `dexterity_at` int(10) unsigned NOT NULL DEFAULT 0,
  `endurance_at` int(10) unsigned NOT NULL DEFAULT 0,
  `energy` float NOT NULL DEFAULT 100,
  `energy_at` int(10) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_hud_settings` (
  `citizenid` VARCHAR(50) NOT NULL,
  `layout` LONGTEXT DEFAULT NULL COMMENT 'JSON: element id -> {x, y, scale, visible}',
  `prefs` LONGTEXT DEFAULT NULL COMMENT 'JSON: pref id -> value',
  `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_hussling` (
  `citizenid` VARCHAR(64) NOT NULL,
  `unlocked` TINYINT(1) NOT NULL DEFAULT 0,
  `deals` INT UNSIGNED NOT NULL DEFAULT 0,
  `washed` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `earned` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `missed` INT UNSIGNED NOT NULL DEFAULT 0,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_hussling_log` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(64) NOT NULL,
  `outcome` VARCHAR(16) NOT NULL,
  `dirty` INT UNSIGNED NOT NULL DEFAULT 0,
  `clean` INT UNSIGNED NOT NULL DEFAULT 0,
  `xp` INT UNSIGNED NOT NULL DEFAULT 0,
  `buyer` VARCHAR(48) NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_hussling_log_cid` (`citizenid`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_manage_members` (
  license    VARCHAR(64)  NOT NULL,
  citizenid  VARCHAR(64)  NULL,
  name       VARCHAR(96)  NULL,
  role       VARCHAR(32)  NULL,
  extras     LONGTEXT     NULL,
  added_by   VARCHAR(64)  NULL,
  updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (license)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_manage_perm_seen` (
  perm_key VARCHAR(160) NOT NULL,
  PRIMARY KEY (perm_key)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_manage_presets` (
  id         INT          NOT NULL AUTO_INCREMENT,
  name       VARCHAR(64)  NOT NULL,
  note       VARCHAR(255) NULL,
  kind       VARCHAR(16)  NOT NULL DEFAULT 'snapshot',
  summary    TEXT         NULL,
  data       LONGTEXT     NOT NULL,
  size       INT          NOT NULL DEFAULT 0,
  created_by VARCHAR(64)  NULL,
  created_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY kind (kind)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_manage_roles` (
  id         VARCHAR(32)  NOT NULL,
  label      VARCHAR(48)  NOT NULL,
  color      VARCHAR(16)  NULL,
  perms      LONGTEXT     NOT NULL,
  sort       INT          NOT NULL DEFAULT 0,
  updated_by VARCHAR(64)  NULL,
  updated_at TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_dispatch_calls` (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(16),
  title VARCHAR(64) NOT NULL,
  description VARCHAR(500),
  priority VARCHAR(8) NOT NULL DEFAULT 'medium',
  jobs VARCHAR(255) NOT NULL,
  street VARCHAR(128),
  x FLOAT NOT NULL,
  y FLOAT NOT NULL,
  z FLOAT NOT NULL DEFAULT 0,
  caller_name VARCHAR(64),
  caller_phone VARCHAR(24),
  caller_cid VARCHAR(64),
  details TEXT,
  units VARCHAR(512),
  report_count INT NOT NULL DEFAULT 1,
  status VARCHAR(8) NOT NULL DEFAULT 'active',
  closed_by VARCHAR(64),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  closed_at TIMESTAMP NULL DEFAULT NULL,
  INDEX (status),
  INDEX (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_mdt_taxes` (
  tax_key VARCHAR(32) NOT NULL PRIMARY KEY,
  rate DECIMAL(5,2) NOT NULL DEFAULT 0,
  min_rate DECIMAL(5,2) NOT NULL DEFAULT 0,
  max_rate DECIMAL(5,2) NOT NULL DEFAULT 0,
  updated_by VARCHAR(64) NULL,
  updated_by_name VARCHAR(96) NULL,
  updated_at INT UNSIGNED NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_pawnshop_players` (
  `citizenid`    VARCHAR(64) NOT NULL,
  `orders_done`  INT NOT NULL DEFAULT 0,
  `order_cash`   INT NOT NULL DEFAULT 0,
  `pawn_cash`    INT NOT NULL DEFAULT 0,
  `items_sold`   INT NOT NULL DEFAULT 0,
  `best_order`   INT NOT NULL DEFAULT 0,
  `data`         LONGTEXT NULL,
  `updated_at`   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_perk_xp` (
  `citizenid` VARCHAR(50) NOT NULL,
  `line`      VARCHAR(48) NOT NULL,
  `xp`        INT NOT NULL DEFAULT 0,
  `daily`     INT NOT NULL DEFAULT 0,
  `day`       DATE DEFAULT NULL,
  PRIMARY KEY (`citizenid`, `line`),
  KEY `idx_citizenid` (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_album_items` (
  `album_id` INT UNSIGNED NOT NULL,
  `item_id` BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (`album_id`, `item_id`),
  KEY `idx_item` (`item_id`),
  CONSTRAINT `fk_album_items_album` FOREIGN KEY (`album_id`) REFERENCES `meteo_phone_albums` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_album_items_item` FOREIGN KEY (`item_id`) REFERENCES `meteo_phone_gallery` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_bleeter_activity` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `account_id` INT UNSIGNED NOT NULL,
  `kind` ENUM('like', 'follow', 'reply', 'mention') NOT NULL,
  `actor_id` INT UNSIGNED NOT NULL,
  `post_id` BIGINT UNSIGNED DEFAULT NULL,
  `is_read` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_account` (`account_id`, `id`),
  KEY `idx_unread` (`account_id`, `is_read`),
  KEY `idx_created` (`created_at`),
  CONSTRAINT `fk_bl_activity_account` FOREIGN KEY (`account_id`) REFERENCES `meteo_phone_bleeter_accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bl_activity_actor` FOREIGN KEY (`actor_id`) REFERENCES `meteo_phone_bleeter_accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bl_activity_post` FOREIGN KEY (`post_id`) REFERENCES `meteo_phone_bleeter_posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_bleeter_follows` (
  `follower_id` INT UNSIGNED NOT NULL,
  `followed_id` INT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`follower_id`, `followed_id`),
  KEY `idx_followed` (`followed_id`),
  CONSTRAINT `fk_bl_follows_follower` FOREIGN KEY (`follower_id`) REFERENCES `meteo_phone_bleeter_accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_bl_follows_followed` FOREIGN KEY (`followed_id`) REFERENCES `meteo_phone_bleeter_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_bleeter_posts` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `account_id` INT UNSIGNED NOT NULL,
  `content` TEXT NOT NULL,
  `payload` TEXT DEFAULT NULL,                        -- JSON: images, event
  `quote_of` BIGINT UNSIGNED DEFAULT NULL,
  `reply_to` BIGINT UNSIGNED DEFAULT NULL,
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,
  `likes` INT UNSIGNED NOT NULL DEFAULT 0,
  `rebleets` INT UNSIGNED NOT NULL DEFAULT 0,
  `replies` INT UNSIGNED NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_reply` (`reply_to`, `id`),                 -- timelines (NULL) and threads
  KEY `idx_account` (`account_id`, `id`),
  KEY `idx_created` (`created_at`),
  CONSTRAINT `fk_bl_posts_account` FOREIGN KEY (`account_id`) REFERENCES `meteo_phone_bleeter_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_bleeter_tags` (
  `tag` VARCHAR(30) NOT NULL,                         -- lowercase key
  `label` VARCHAR(30) NOT NULL,                       -- as it was written
  `post_id` BIGINT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`tag`, `post_id`),
  KEY `idx_created` (`created_at`),
  KEY `idx_post` (`post_id`),
  CONSTRAINT `fk_bl_tags_post` FOREIGN KEY (`post_id`) REFERENCES `meteo_phone_bleeter_posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_blocks` (
  `sim_id` INT UNSIGNED NOT NULL,
  `number` VARCHAR(16) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sim_id`, `number`),
  CONSTRAINT `fk_blocks_sim` FOREIGN KEY (`sim_id`) REFERENCES `meteo_phone_sims` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_calendar_saves` (
  `event_id` INT UNSIGNED NOT NULL,
  `device_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(48) NOT NULL,            -- how they show on the host's guest list
  `rsvp` ENUM('going', 'maybe', 'no') DEFAULT NULL,
  `reminder` SMALLINT UNSIGNED DEFAULT NULL, -- minutes before the start
  `reminded_for` BIGINT DEFAULT NULL,     -- the start it already fired for
  PRIMARY KEY (`event_id`, `device_id`),
  KEY `idx_device` (`device_id`),
  CONSTRAINT `fk_calendar_saves_event` FOREIGN KEY (`event_id`) REFERENCES `meteo_phone_calendar_events` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_calendar_saves_device` FOREIGN KEY (`device_id`) REFERENCES `meteo_phone_devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_conversation_members` (
  `conversation_id` INT UNSIGNED NOT NULL,
  `sim_id` INT UNSIGNED NOT NULL,
  `number` VARCHAR(16) NOT NULL,
  `role` ENUM('owner', 'admin', 'member') NOT NULL DEFAULT 'member',
  `muted` TINYINT(1) NOT NULL DEFAULT 0,
  `unread` INT UNSIGNED NOT NULL DEFAULT 0,
  `last_message` VARCHAR(160) DEFAULT NULL, -- this member's own newest, when hidden from the rest
  `last_at` TIMESTAMP NULL DEFAULT NULL,
  `joined_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`conversation_id`, `sim_id`),
  KEY `idx_sim` (`sim_id`, `conversation_id`),
  KEY `idx_number` (`number`),
  CONSTRAINT `fk_members_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `meteo_phone_conversations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_members_sim` FOREIGN KEY (`sim_id`) REFERENCES `meteo_phone_sims` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_conversations` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `kind` ENUM('dm', 'group') NOT NULL DEFAULT 'dm',
  `service` ENUM('gov', 'system', 'mission', 'number') DEFAULT NULL, -- a one-way sender, read only
  `dm_key` VARCHAR(64) DEFAULT NULL,  -- the two numbers, sorted; one dm per pair
  `name` VARCHAR(48) DEFAULT NULL,    -- groups and services carry their own
  `color` VARCHAR(9) DEFAULT NULL,
  `avatar` VARCHAR(512) DEFAULT NULL,
  `owner` VARCHAR(16) DEFAULT NULL,   -- the group's creator, by number
  `hide_members` TINYINT(1) NOT NULL DEFAULT 0,
  `last_message` VARCHAR(160) NOT NULL DEFAULT '',
  `last_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_dm_key` (`dm_key`),
  KEY `idx_last_at` (`last_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_devices` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `serial` VARCHAR(24) NOT NULL,
  `owner` VARCHAR(50) DEFAULT NULL,
  `settings` TEXT DEFAULT NULL,
  `layout` TEXT DEFAULT NULL,
  `locked` TINYINT(1) NOT NULL DEFAULT 0, -- owner reported it at a shop
  `lock_message` VARCHAR(160) DEFAULT NULL,
  `lock_name` VARCHAR(48) DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_serial` (`serial`),
  KEY `idx_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_document_signers` (
  `document_id` INT UNSIGNED NOT NULL,
  `number` VARCHAR(16) NOT NULL,
  `requested_at` TIMESTAMP NULL DEFAULT NULL, -- sent for signing; until then they see nothing
  `requested_by` VARCHAR(48) DEFAULT NULL,    -- who asked, as they were named when they did
  `signed_at` TIMESTAMP NULL DEFAULT NULL,
  `added_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`document_id`, `number`),
  KEY `idx_number` (`number`, `requested_at`),
  CONSTRAINT `fk_document_signers_document` FOREIGN KEY (`document_id`) REFERENCES `meteo_phone_documents` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_documents` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `device_id` INT UNSIGNED NOT NULL,
  `title` VARCHAR(120) NOT NULL DEFAULT '',
  `preview` VARCHAR(200) NOT NULL DEFAULT '',
  `content` MEDIUMTEXT NOT NULL,
  `template` VARCHAR(24) DEFAULT NULL,
  `locked` TINYINT(1) NOT NULL DEFAULT 0,
  `signatures` MEDIUMTEXT DEFAULT NULL,
  `signed` TINYINT UNSIGNED NOT NULL DEFAULT 0, -- how many, so the list never opens the JSON
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_device_updated` (`device_id`, `updated_at`),
  CONSTRAINT `fk_documents_device` FOREIGN KEY (`device_id`) REFERENCES `meteo_phone_devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_favorites` (
  `sim_id` INT UNSIGNED NOT NULL,
  `number` VARCHAR(16) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`sim_id`, `number`),
  CONSTRAINT `fk_favorites_sim` FOREIGN KEY (`sim_id`) REFERENCES `meteo_phone_sims` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_group_aliases` (
  `citizenid` VARCHAR(50) NOT NULL,
  `alias` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_labor_achievements` (
  `citizenid` VARCHAR(50) NOT NULL,
  `achievement_id` VARCHAR(64) NOT NULL,
  `progress` INT NOT NULL DEFAULT 0,
  `completed` TINYINT(1) NOT NULL DEFAULT 0,
  `completed_at` TIMESTAMP NULL DEFAULT NULL,
  `collected` TINYINT(1) NOT NULL DEFAULT 0,
  `collected_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`citizenid`, `achievement_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_labor_activity` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `text` VARCHAR(255) NOT NULL,
  `icon` VARCHAR(48) NOT NULL DEFAULT 'work',
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_citizen_time` (`citizenid`, `id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_labor_history` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `citizenid` VARCHAR(50) NOT NULL,
  `job_id` VARCHAR(64) NOT NULL,
  `job_name` VARCHAR(64) NOT NULL,
  `job_icon` VARCHAR(48) NOT NULL DEFAULT 'work',
  `title` VARCHAR(255) NOT NULL,
  `amount` INT NOT NULL DEFAULT 0,
  `xp` INT NOT NULL DEFAULT 0,
  `breakdown` TEXT DEFAULT NULL,
  `bonuses` TEXT DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_citizen_time` (`citizenid`, `id`),
  KEY `idx_citizen_job` (`citizenid`, `job_id`),
  KEY `idx_citizen_created` (`citizenid`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_labor_players` (
  `citizenid` VARCHAR(50) NOT NULL,
  `name` VARCHAR(64) DEFAULT NULL,
  `reputation` INT NOT NULL DEFAULT 0,
  `total_earned` BIGINT NOT NULL DEFAULT 0,
  `tasks_completed` INT NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`citizenid`),
  KEY `idx_reputation` (`reputation`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_map_pins` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `device_id` INT UNSIGNED NOT NULL,
  `label` VARCHAR(64) NOT NULL,
  `x` FLOAT NOT NULL,
  `y` FLOAT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_device` (`device_id`, `id`),
  CONSTRAINT `fk_map_pins_device` FOREIGN KEY (`device_id`) REFERENCES `meteo_phone_devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_message_reactions` (
  `message_id` BIGINT UNSIGNED NOT NULL,
  `number` VARCHAR(16) NOT NULL,
  `emoji` VARCHAR(16) COLLATE utf8mb4_bin NOT NULL, -- emojis compare equal under _ci
  PRIMARY KEY (`message_id`, `number`, `emoji`),
  CONSTRAINT `fk_reactions_message` FOREIGN KEY (`message_id`) REFERENCES `meteo_phone_messages` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_music_follows` (
  `follower_id` INT UNSIGNED NOT NULL,
  `artist_id` INT UNSIGNED NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`follower_id`, `artist_id`),
  KEY `idx_artist` (`artist_id`, `created_at`),
  CONSTRAINT `fk_mu_follows_follower` FOREIGN KEY (`follower_id`) REFERENCES `meteo_phone_music_accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mu_follows_artist` FOREIGN KEY (`artist_id`) REFERENCES `meteo_phone_music_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_music_playlist_members` (
  `playlist_id` INT UNSIGNED NOT NULL,
  `account_id` INT UNSIGNED NOT NULL,
  PRIMARY KEY (`playlist_id`, `account_id`),
  KEY `idx_account` (`account_id`),
  CONSTRAINT `fk_mu_members_playlist` FOREIGN KEY (`playlist_id`) REFERENCES `meteo_phone_music_playlists` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mu_members_account` FOREIGN KEY (`account_id`) REFERENCES `meteo_phone_music_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_music_playlist_tracks` (
  `playlist_id` INT UNSIGNED NOT NULL,
  `track_id` INT UNSIGNED NOT NULL,
  `position` INT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`playlist_id`, `track_id`),
  KEY `idx_order` (`playlist_id`, `position`),
  KEY `idx_track` (`track_id`),
  CONSTRAINT `fk_mu_pl_tracks_playlist` FOREIGN KEY (`playlist_id`) REFERENCES `meteo_phone_music_playlists` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mu_pl_tracks_track` FOREIGN KEY (`track_id`) REFERENCES `meteo_phone_music_tracks` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_music_plays` (
  `track_id` INT UNSIGNED NOT NULL,
  `account_id` INT UNSIGNED NOT NULL,
  `day` DATE NOT NULL,
  PRIMARY KEY (`track_id`, `account_id`, `day`),
  KEY `idx_day` (`day`),
  CONSTRAINT `fk_mu_plays_track` FOREIGN KEY (`track_id`) REFERENCES `meteo_phone_music_tracks` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_music_track_artists` (
  `track_id` INT UNSIGNED NOT NULL,
  `account_id` INT UNSIGNED NOT NULL,
  `position` TINYINT UNSIGNED NOT NULL DEFAULT 0,   -- 0 is the lead
  `status` ENUM('accepted', 'pending') NOT NULL DEFAULT 'pending',
  PRIMARY KEY (`track_id`, `account_id`),
  KEY `idx_account` (`account_id`, `status`),
  CONSTRAINT `fk_mu_credits_track` FOREIGN KEY (`track_id`) REFERENCES `meteo_phone_music_tracks` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_mu_credits_account` FOREIGN KEY (`account_id`) REFERENCES `meteo_phone_music_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_music_tracks` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `account_id` INT UNSIGNED NOT NULL,                -- the lead artist, who uploaded it
  `title` VARCHAR(80) NOT NULL,
  `audio_url` VARCHAR(512) NOT NULL,
  `cover` VARCHAR(512) NOT NULL,
  `genre` VARCHAR(24) NOT NULL,
  `duration` SMALLINT UNSIGNED NOT NULL DEFAULT 0,  -- seconds
  `plays` INT UNSIGNED NOT NULL DEFAULT 0,
  `week_plays` INT UNSIGNED NOT NULL DEFAULT 0,     -- refreshed by the sweep
  `likes` INT UNSIGNED NOT NULL DEFAULT 0,
  `unreleased` TINYINT(1) NOT NULL DEFAULT 0,
  `deleted` TINYINT(1) NOT NULL DEFAULT 0,
  `released_at` TIMESTAMP NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_account` (`account_id`, `id`),
  KEY `idx_released` (`deleted`, `unreleased`, `released_at`),
  KEY `idx_trending` (`deleted`, `unreleased`, `week_plays`),
  CONSTRAINT `fk_mu_tracks_account` FOREIGN KEY (`account_id`) REFERENCES `meteo_phone_music_accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_news` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `author_cid` VARCHAR(50) NOT NULL,                  -- only they correct or pull it
  `author` VARCHAR(64) NOT NULL,
  `outlet` VARCHAR(48) NOT NULL,
  `headline` VARCHAR(160) NOT NULL,
  `body` MEDIUMTEXT NOT NULL,
  `image` VARCHAR(512) DEFAULT NULL,
  `views` INT UNSIGNED NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `edited_at` TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_author` (`author_cid`, `id`),
  KEY `idx_popular` (`created_at`, `views`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_pages` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `sim_id` INT UNSIGNED NOT NULL,          -- the poster; answers go to its number
  `number` VARCHAR(16) NOT NULL,
  `name` VARCHAR(48) NOT NULL DEFAULT '',
  `title` VARCHAR(80) NOT NULL,
  `body` VARCHAR(600) NOT NULL,
  `price` VARCHAR(40) NOT NULL DEFAULT '',
  `images` TEXT DEFAULT NULL,              -- JSON array, up to 4
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_sim` (`sim_id`, `id`),
  KEY `idx_number` (`number`),
  KEY `idx_created` (`created_at`),
  CONSTRAINT `fk_pages_sim` FOREIGN KEY (`sim_id`) REFERENCES `meteo_phone_sims` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_service_notices` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `job` VARCHAR(50) NOT NULL,
  `internal` TINYINT(1) NOT NULL DEFAULT 0,
  `title` VARCHAR(64) NOT NULL,
  `body` VARCHAR(400) NOT NULL,
  `author` VARCHAR(64) NOT NULL,
  `author_cid` VARCHAR(50) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_board` (`job`, `internal`, `id`),
  KEY `idx_created` (`created_at`),
  CONSTRAINT `fk_sv_notices_service` FOREIGN KEY (`job`) REFERENCES `meteo_phone_services` (`job`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_service_prefs` (
  `citizenid` VARCHAR(50) NOT NULL,
  `job` VARCHAR(50) NOT NULL,
  `calls` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`citizenid`, `job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_services` (
  `job` VARCHAR(50) NOT NULL,
  `number` VARCHAR(16) NOT NULL,
  `taking` TINYINT(1) NOT NULL DEFAULT 1,
  `pos_x` FLOAT DEFAULT NULL,
  `pos_y` FLOAT DEFAULT NULL,
  `place` VARCHAR(64) DEFAULT NULL,
  PRIMARY KEY (`job`),
  UNIQUE KEY `uk_number` (`number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_signatures` (
  `device_id` INT UNSIGNED NOT NULL,
  `name` VARCHAR(48) NOT NULL,
  `image` MEDIUMTEXT DEFAULT NULL,
  PRIMARY KEY (`device_id`),
  CONSTRAINT `fk_signatures_device` FOREIGN KEY (`device_id`) REFERENCES `meteo_phone_devices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_phone_sims` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `number` VARCHAR(16) NOT NULL,
  `owner` VARCHAR(50) DEFAULT NULL,
  `name` VARCHAR(48) DEFAULT NULL,
  `avatar` VARCHAR(512) DEFAULT NULL,
  `enabled` TINYINT(1) NOT NULL DEFAULT 1,
  `pin_hash` VARCHAR(100) DEFAULT NULL,
  `unlocked_device` INT UNSIGNED DEFAULT NULL, -- phone the PIN was entered in
  `calls_seen_id` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `barred` TINYINT(1) NOT NULL DEFAULT 0, -- owner barred it at a shop
  `retired` TINYINT(1) NOT NULL DEFAULT 0, -- number given up for a new one
  `card` SMALLINT UNSIGNED NOT NULL DEFAULT 0, -- older cards are void
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_number` (`number`),
  KEY `idx_owner` (`owner`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_alert_reads` (
  citizenid VARCHAR(64) NOT NULL,
  property_id INT UNSIGNED NOT NULL,
  last_read_id BIGINT UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (citizenid, property_id),
  KEY idx_alert_read_prop (property_id),
  CONSTRAINT fk_meteo_props_alert_read_prop FOREIGN KEY (property_id)
  REFERENCES meteo_props_properties (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_alerts` (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id INT UNSIGNED NOT NULL,
  kind VARCHAR(12) NOT NULL,
  title VARCHAR(128) NOT NULL DEFAULT '',
  body VARCHAR(255) NOT NULL DEFAULT '',
  actor_cid VARCHAR(64) NULL DEFAULT NULL,
  owner_only TINYINT(1) NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_alert_prop (property_id, id),
  KEY idx_alert_created (created_at),
  CONSTRAINT fk_meteo_props_alert_prop FOREIGN KEY (property_id)
  REFERENCES meteo_props_properties (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_complexes` (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  label VARCHAR(64) NOT NULL DEFAULT '',
  type_id INT UNSIGNED NOT NULL,
  entrance LONGTEXT NOT NULL,
  street VARCHAR(64) NOT NULL DEFAULT '',
  zone_name VARCHAR(64) NOT NULL DEFAULT '',
  ped LONGTEXT NULL,
  garage LONGTEXT NULL,
  elevators LONGTEXT NULL,
  images LONGTEXT NULL,
  starter TINYINT(1) NOT NULL DEFAULT 1,
  price INT UNSIGNED NOT NULL DEFAULT 0,
  rent INT UNSIGNED NOT NULL DEFAULT 0,
  room_prefix VARCHAR(16) NOT NULL DEFAULT 'Room',
  room_security TINYINT UNSIGNED NOT NULL DEFAULT 1,
  hidden TINYINT(1) NOT NULL DEFAULT 0,
  room_images LONGTEXT NULL,
  data LONGTEXT NULL,
  created_by VARCHAR(64) NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_cx_type (type_id),
  CONSTRAINT fk_meteo_props_cx_type FOREIGN KEY (type_id)
  REFERENCES meteo_props_types (id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_doors` (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id INT UNSIGNED NOT NULL,
  label VARCHAR(48) NOT NULL DEFAULT '',
  door_type VARCHAR(12) NOT NULL DEFAULT 'single',
  leaves LONGTEXT NOT NULL,
  center LONGTEXT NOT NULL,
  z_min FLOAT NOT NULL DEFAULT 0,
  z_max FLOAT NOT NULL DEFAULT 0,
  security TINYINT UNSIGNED NULL DEFAULT NULL,
  locked TINYINT(1) NOT NULL DEFAULT 1,
  autolock_override SMALLINT UNSIGNED NULL DEFAULT NULL,
  max_distance DECIMAL(3,1) NOT NULL DEFAULT 1.5,
  door_rate DECIMAL(4,1) NULL DEFAULT NULL,
  hold_open TINYINT(1) NOT NULL DEFAULT 0,
  sort_order TINYINT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_door_prop (property_id),
  CONSTRAINT fk_meteo_props_door_prop FOREIGN KEY (property_id)
  REFERENCES meteo_props_properties (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_logs` (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  action VARCHAR(40) NOT NULL,
  property_id INT UNSIGNED NULL DEFAULT NULL,
  actor_cid VARCHAR(64) NULL DEFAULT NULL,
  actor_name VARCHAR(96) NOT NULL DEFAULT '',
  target_cid VARCHAR(64) NULL DEFAULT NULL,
  title VARCHAR(128) NOT NULL DEFAULT '',
  description VARCHAR(500) NOT NULL DEFAULT '',
  meta TEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_log_prop (property_id, id),
  KEY idx_log_action (action, id),
  KEY idx_log_actor (actor_cid, id),
  KEY idx_log_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_members` (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id INT UNSIGNED NOT NULL,
  citizenid VARCHAR(64) NOT NULL,
  role_id INT UNSIGNED NULL DEFAULT NULL,
  added_by VARCHAR(64) NULL DEFAULT NULL,
  added_by_name VARCHAR(96) NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uniq_member (property_id, citizenid),
  KEY idx_member_cid (citizenid),
  KEY idx_member_role (role_id),
  CONSTRAINT fk_meteo_props_member_prop FOREIGN KEY (property_id)
  REFERENCES meteo_props_properties (id) ON DELETE CASCADE,
  CONSTRAINT fk_meteo_props_member_role FOREIGN KEY (role_id)
  REFERENCES meteo_props_roles (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_meta` (
  k VARCHAR(48) NOT NULL,
  v VARCHAR(255) NULL DEFAULT NULL,
  PRIMARY KEY (k)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_owner_perks` (
  citizenid VARCHAR(64) NOT NULL,
  perks LONGTEXT NULL,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (citizenid)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_perk_marks` (
  kind VARCHAR(12) NOT NULL,
  ref VARCHAR(128) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (kind, ref),
  KEY idx_mark_created (kind, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_presets` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(64) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `kind` varchar(16) NOT NULL DEFAULT 'mixed',
  `data` longtext NOT NULL,
  `summary` varchar(255) NOT NULL DEFAULT '{}',
  `size` int unsigned NOT NULL DEFAULT 0,
  `created_by` varchar(64) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_preset_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_properties` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `label` varchar(64) NOT NULL DEFAULT '',
  `type_id` int(10) unsigned NOT NULL,
  `kind` varchar(8) NOT NULL DEFAULT 'shell',
  `price` int(10) unsigned NOT NULL DEFAULT 0,
  `for_sale` tinyint(1) NOT NULL DEFAULT 1,
  `owner_cid` varchar(64) DEFAULT NULL,
  `purchased_at` timestamp NULL DEFAULT NULL,
  `entrance` longtext NOT NULL,
  `street` varchar(64) NOT NULL DEFAULT '',
  `zone_name` varchar(64) NOT NULL DEFAULT '',
  `shell_key` varchar(32) DEFAULT NULL,
  `zone` longtext DEFAULT NULL,
  `inside_spawn` longtext DEFAULT NULL,
  `garage` longtext DEFAULT NULL,
  `images` longtext DEFAULT NULL,
  `security` tinyint(3) unsigned NOT NULL DEFAULT 1,
  `member_tier` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `storage_tier` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `locked` tinyint(1) NOT NULL DEFAULT 1,
  `data` longtext DEFAULT NULL,
  `created_by` varchar(64) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `sale_mode` varchar(8) NOT NULL DEFAULT 'direct',
  `listed_at` timestamp NULL DEFAULT NULL,
  `hidden` tinyint(1) NOT NULL DEFAULT 0,
  `complex_id` int(10) unsigned DEFAULT NULL,
  `room_number` smallint(5) unsigned DEFAULT NULL,
  `room_floor` smallint(6) DEFAULT NULL,
  `room_state` varchar(8) DEFAULT NULL,
  `former_cid` varchar(64) DEFAULT NULL,
  `vacated_at` timestamp NULL DEFAULT NULL,
  `last_seen_at` timestamp NULL DEFAULT NULL,
  `rent_due_at` timestamp NULL DEFAULT NULL,
  `rent_missed` tinyint(3) unsigned NOT NULL DEFAULT 0,
  `vacate_reason` varchar(12) DEFAULT NULL,
  `room_price` int(10) unsigned DEFAULT NULL,
  `doorbell` tinyint(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_room` (`complex_id`,`room_number`),
  KEY `idx_prop_type` (`type_id`),
  KEY `idx_prop_owner` (`owner_cid`),
  KEY `idx_prop_former` (`former_cid`),
  CONSTRAINT `fk_meteo_props_prop_complex` FOREIGN KEY (`complex_id`) REFERENCES `meteo_props_complexes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_meteo_props_type` FOREIGN KEY (`type_id`) REFERENCES `meteo_props_types` (`id`) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_roles` (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id INT UNSIGNED NOT NULL,
  label VARCHAR(32) NOT NULL,
  color VARCHAR(16) NOT NULL DEFAULT '#57EFAF',
  perms LONGTEXT NOT NULL,
  sort_order TINYINT UNSIGNED NOT NULL DEFAULT 0,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uniq_role_label (property_id, label),
  KEY idx_role_prop (property_id),
  CONSTRAINT fk_meteo_props_role_prop FOREIGN KEY (property_id)
  REFERENCES meteo_props_properties (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_sales` (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  property_id INT UNSIGNED NOT NULL,
  property_label VARCHAR(64) NOT NULL DEFAULT '',
  buyer_cid VARCHAR(64) NULL DEFAULT NULL,
  seller_cid VARCHAR(64) NULL DEFAULT NULL,
  agent_cid VARCHAR(64) NULL DEFAULT NULL,
  price INT UNSIGNED NOT NULL,
  commission INT UNSIGNED NOT NULL DEFAULT 0,
  tax INT UNSIGNED NOT NULL DEFAULT 0,
  payment VARCHAR(8) NOT NULL,
  mode VARCHAR(8) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_sale_agent (agent_cid, created_at),
  KEY idx_sale_buyer (buyer_cid, created_at),
  KEY idx_sale_seller (seller_cid, created_at),
  KEY idx_sale_prop (property_id, id),
  KEY idx_sale_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_props_types` (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `key` VARCHAR(32) NOT NULL,
  label VARCHAR(64) NOT NULL DEFAULT '',
  icon VARCHAR(48) NOT NULL DEFAULT 'house',
  color VARCHAR(16) NOT NULL DEFAULT '#57EFAF',
  blip_enabled TINYINT(1) NOT NULL DEFAULT 1,
  blip_sprite SMALLINT UNSIGNED NOT NULL DEFAULT 40,
  blip_color TINYINT UNSIGNED NOT NULL DEFAULT 0,
  blip_owned_color TINYINT UNSIGNED NOT NULL DEFAULT 2,
  blip_scale DECIMAL(3,2) NOT NULL DEFAULT 0.70,
  member_limit SMALLINT UNSIGNED NOT NULL DEFAULT 5,
  storage_tier TINYINT UNSIGNED NOT NULL DEFAULT 0,
  garage_allowed TINYINT(1) NOT NULL DEFAULT 1,
  default_security TINYINT UNSIGNED NOT NULL DEFAULT 1,
  interior_kinds VARCHAR(16) NOT NULL DEFAULT 'shell,mlo',
  sort_order SMALLINT NOT NULL DEFAULT 0,
  data LONGTEXT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uniq_type_key (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_restaurant_presets` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(64) NOT NULL,
  `description` VARCHAR(255) DEFAULT NULL,
  `data` LONGTEXT NOT NULL,
  `createdBy` VARCHAR(100) DEFAULT NULL,
  `createdAt` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY `preset_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `meteo_tow_requests` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `plate` VARCHAR(16) NOT NULL,
  `net_id` INT NOT NULL DEFAULT 0,
  `seizure` LONGTEXT NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

SET FOREIGN_KEY_CHECKS = 1;
