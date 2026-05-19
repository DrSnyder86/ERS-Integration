SET FOREIGN_KEY_CHECKS = 0;

DROP PROCEDURE IF EXISTS ers_add_column_if_missing;
DELIMITER $$
CREATE PROCEDURE ers_add_column_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_column_name VARCHAR(64),
    IN p_column_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND COLUMN_NAME = p_column_name
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', p_table_name, '` ADD COLUMN `', p_column_name, '` ', p_column_definition);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

DROP PROCEDURE IF EXISTS ers_add_index_if_missing;
DELIMITER $$
CREATE PROCEDURE ers_add_index_if_missing(
    IN p_table_name VARCHAR(64),
    IN p_index_name VARCHAR(64),
    IN p_index_definition TEXT
)
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = DATABASE()
          AND TABLE_NAME = p_table_name
          AND INDEX_NAME = p_index_name
    ) THEN
        SET @sql = CONCAT('ALTER TABLE `', p_table_name, '` ADD ', p_index_definition);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END$$
DELIMITER ;

CREATE TABLE IF NOT EXISTS `ers_players` (
    `citizenid` VARCHAR(50) PRIMARY KEY,
    `firstname` VARCHAR(50),
    `lastname` VARCHAR(50),
    `callsign` VARCHAR(50),
    `last_service` VARCHAR(50),
    `is_on_duty` TINYINT(1) DEFAULT 0,
    `unit_status` VARCHAR(50) DEFAULT '10-8',
    `tablet_background` TEXT NULL,
    `tablet_background_position_x` INT DEFAULT 50,
    `tablet_background_position_y` INT DEFAULT 50,
    `tablet_background_zoom` INT DEFAULT 100,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CALL ers_add_column_if_missing('ers_players', 'unit_status', "VARCHAR(50) DEFAULT '10-8'");
CALL ers_add_column_if_missing('ers_players', 'tablet_background', 'TEXT NULL');
CALL ers_add_column_if_missing('ers_players', 'tablet_background_position_x', 'INT DEFAULT 50');
CALL ers_add_column_if_missing('ers_players', 'tablet_background_position_y', 'INT DEFAULT 50');
CALL ers_add_column_if_missing('ers_players', 'tablet_background_zoom', 'INT DEFAULT 100');

CREATE TABLE IF NOT EXISTS `ers_player_service_stats` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `service` VARCHAR(50) NOT NULL,
    `total_seconds` INT DEFAULT 0,
    `accepted_callouts` INT DEFAULT 0,
    `arrived_callouts` INT DEFAULT 0,
    UNIQUE KEY `unique_service` (`citizenid`, `service`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ers_duty_sessions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `citizenid` VARCHAR(50) NOT NULL,
    `service` VARCHAR(50) NOT NULL,
    `started_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `ended_at` TIMESTAMP NULL,
    `duration_seconds` INT DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ers_ped_database` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `ped_identifier` VARCHAR(100) NOT NULL UNIQUE,
    `firstname` VARCHAR(50),
    `lastname` VARCHAR(50),
    `dob` VARCHAR(50),
    `gender` VARCHAR(50),
    `address` VARCHAR(150),
    `phone` VARCHAR(50),
    `email` VARCHAR(100),
    `profile_picture` TEXT,
    `profile_position_x` INT DEFAULT 50,
    `profile_position_y` INT DEFAULT 5,
    `profile_zoom` INT DEFAULT 100,
    `ped_data` LONGTEXT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CALL ers_add_column_if_missing('ers_ped_database', 'profile_position_x', 'INT DEFAULT 50');
CALL ers_add_column_if_missing('ers_ped_database', 'profile_position_y', 'INT DEFAULT 5');
CALL ers_add_column_if_missing('ers_ped_database', 'profile_zoom', 'INT DEFAULT 100');

CREATE TABLE IF NOT EXISTS `ers_vehicle_database` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `plate` VARCHAR(20) NOT NULL,
    `owner_identifier` VARCHAR(100) NULL,
    `owner_name` VARCHAR(150) NULL,
    `vehicle_model` VARCHAR(100) NULL,
    `vehicle_label` VARCHAR(150) NULL,
    `color` VARCHAR(100) NULL,
    `type` VARCHAR(50) DEFAULT 'NPC',
    `vehicle_data` LONGTEXT NULL,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY `unique_ers_vehicle_plate` (`plate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ers_reports` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `report_type` VARCHAR(50) NOT NULL,
    `title` VARCHAR(100) NOT NULL,
    `narrative` LONGTEXT,
    `created_by` VARCHAR(100),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_by` VARCHAR(100) NULL,
    `updated_at` TIMESTAMP NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CALL ers_add_column_if_missing('ers_reports', 'updated_by', 'VARCHAR(100) NULL');
CALL ers_add_column_if_missing('ers_reports', 'updated_at', 'TIMESTAMP NULL DEFAULT NULL');

CREATE TABLE IF NOT EXISTS `ers_report_officers` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `report_id` INT NOT NULL,
    `officer_name` VARCHAR(100),
    `callsign` VARCHAR(50),
    `job` VARCHAR(50),
    CONSTRAINT `fk_ers_report_officers_report` FOREIGN KEY (`report_id`) REFERENCES `ers_reports`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ers_report_peds` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `report_id` INT NOT NULL,
    `ped_identifier` VARCHAR(100),
    `firstname` VARCHAR(50),
    `lastname` VARCHAR(50),
    `dob` VARCHAR(50),
    `ped_data` LONGTEXT,
    CONSTRAINT `fk_ers_report_peds_report` FOREIGN KEY (`report_id`) REFERENCES `ers_reports`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ers_report_charges` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `report_id` INT NOT NULL,
    `ped_identifier` VARCHAR(100) NULL,
    `ped_name` VARCHAR(100) NULL,
    `charge_name` VARCHAR(100),
    `fine` INT DEFAULT 0,
    `jail_time` INT DEFAULT 0,
    `count` INT DEFAULT 1,
    CONSTRAINT `fk_ers_report_charges_report` FOREIGN KEY (`report_id`) REFERENCES `ers_reports`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CALL ers_add_column_if_missing('ers_report_charges', 'ped_identifier', 'VARCHAR(100) NULL');
CALL ers_add_column_if_missing('ers_report_charges', 'ped_name', 'VARCHAR(100) NULL');

CREATE TABLE IF NOT EXISTS `ers_report_photos` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `report_id` INT NOT NULL,
    `url` TEXT NOT NULL,
    `caption` VARCHAR(255) NULL,
    `uploaded_by` VARCHAR(100) NULL,
    `position_x` INT DEFAULT 50,
    `position_y` INT DEFAULT 50,
    `zoom` INT DEFAULT 100,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT `fk_ers_report_photos_report` FOREIGN KEY (`report_id`) REFERENCES `ers_reports`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CALL ers_add_column_if_missing('ers_report_photos', 'position_x', 'INT DEFAULT 50');
CALL ers_add_column_if_missing('ers_report_photos', 'position_y', 'INT DEFAULT 50');
CALL ers_add_column_if_missing('ers_report_photos', 'zoom', 'INT DEFAULT 100');

CREATE TABLE IF NOT EXISTS `ers_charges` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `code` VARCHAR(50) NULL,
    `name` VARCHAR(150) NOT NULL,
    `category` VARCHAR(50) NULL,
    `jail_time` INT DEFAULT 0,
    `fine` INT DEFAULT 0,
    `color` VARCHAR(50) NULL,
    `description` TEXT NULL,
    UNIQUE KEY `unique_charge_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CALL ers_add_column_if_missing('ers_charges', 'code', 'VARCHAR(50) NULL');
CALL ers_add_column_if_missing('ers_charges', 'color', 'VARCHAR(50) NULL');
CALL ers_add_column_if_missing('ers_charges', 'description', 'TEXT NULL');
CALL ers_add_index_if_missing('ers_charges', 'unique_charge_code', 'UNIQUE KEY `unique_charge_code` (`code`)');

INSERT INTO `ers_charges` (`code`, `name`, `category`, `jail_time`, `fine`, `color`, `description`) VALUES
('P.C. 1001','Simple Assault','misdemeanor',7,500,'green','When a person intentionally or knowingly causes physical contact with another (without a weapon)'),
('P.C. 1002','Assault','misdemeanor',15,850,'orange','If a person intentionally or knowingly causes injury to another (without a weapon)'),
('P.C. 1003','Aggravated Assault','felony',20,1250,'orange','When a person unintentionally, and recklessly causes bodily injury to another as a result of a confrontation AND causes bodily injury'),
('P.C. 1004','Assault with a Deadly Weapon','felony',30,3750,'red','When a person intentionally, knowingly, or recklessly causes bodily injury to another person AND either causes serious bodily injury or uses or exhibits a deadly weapon'),
('P.C. 1005','Involuntary Manslaughter','felony',60,7500,'red','When a person unintentionally and recklessly causes the death of another'),
('P.C. 1006','Vehicular Manslaughter','felony',75,7500,'red','When a person unintentionally and recklessly causes the death of anther with a vehicle'),
('P.C. 1007','Attempted Murder of a Civilian','felony',50,7500,'red','When a non-government person intentionally attacks another with the intent to kill'),
('P.C. 1008','Second Degree Murder','felony',100,15000,'red','Any intentional killing that is not premeditated or planned. A situation in which the killer intends only to inflict serious bodily harm.'),
('P.C. 1009','Accessory to Second Degree Murder','felony',50,5000,'red','Being present and or participating in the act of parent charge'),
('P.C. 1010','First Degree Murder','felony',90,15000,'red','Any intentional killing that is willful and premeditated with malice.'),
('P.C. 1011','Accessory to First Degree Murder','felony',60,10000,'red','Being present and or participating in the act of parent charge'),
('P.C. 1012','Murder of a Public Servant or Peace Officer','felony',120,20000,'red','Any intentional killing that is done to a government employee'),
('P.C. 1013','Attempted Murder of a Public Servant or Peace Officer','felony',65,10000,'red','Any attacks that are done to a government employee with the intent to cause death'),
('P.C. 1014','Accessory to the Murder of a Public Servant or Peace Officer','felony',80,15000,'red','Being present and or participating in the act of parent charge'),
('P.C. 1015','Unlawful Imprisonment','misdemeanor',10,600,'green','The act of taking another against their will and holding them for an extended period of time'),
('P.C. 1016','Kidnapping','felony',15,900,'orange','The act of taking another against their will for a short period of time'),
('P.C. 1017','Accessory to Kidnapping','felony',7,450,'orange','Being present and or participating in the act of parent charge'),
('P.C. 1018','Attempted Kidnapping','felony',10,450,'orange','The act of trying to take someone against their will'),
('P.C. 1019','Hostage Taking','felony',20,1200,'orange','The act of taking another against their will for personal gain'),
('P.C. 1020','Accessory to Hostage Taking','felony',10,600,'orange','Being present and or participating in the act of parent charge'),
('P.C. 1021','Unlawful Imprisonment of a Public Servant or Peace Officer.','felony',25,4000,'orange','The act of taking a government employee against their will for an extended period of time'),
('P.C. 1022','Criminal Threats','misdemeanor',5,500,'orange','The act of stating the intent to commit a crime against another'),
('P.C. 1023','Reckless Endangerment','misdemeanor',10,1000,'orange','The act of disregarding safety of another which may place another in danger of death or bodily injury'),
('P.C. 1024','Gang Related Shooting','felony',30,2500,'red','The act in which a firearm is discharged in relation to gang activity'),
('P.C. 1025','Cannibalism','felony',100,20000,'red','The act in which a persons consumes the flesh of another willingly'),
('P.C. 1026','Torture','felony',40,4500,'red','The act of causing harm to another to extract informaion and or for self enjoyment'),
('P.C. 2001','Petty Theft','infraction',0,250,'green','The theft of property below $50 amount'),
('P.C. 2002','Grand Theft','misdemeanor',10,600,'green','Theft of property above $700'),
('P.C. 2003','Grand Theft Auto A','felony',15,900,'green','The act of stealing a vehicle that belongs to someone else without permission'),
('P.C. 2004','Grand Theft Auto B','felony',35,3500,'green','The act of stealing a vehicle that belongs to someone else without permission while armed'),
('P.C. 2005','Carjacking','felony',30,2000,'orange','The act of someone forcefully taking a vehicle from its occupants'),
('P.C. 2006','Burglary','misdemeanor',10,500,'green','The act of entering into a building illegally with intent to commit a crime, especially theft.'),
('P.C. 2007','Robbery','felony',25,2000,'green','The action of taking property unlawfully from a person or place by force or threat of force.'),
('P.C. 2008','Accessory to Robbery','felony',12,1000,'green','Being present and or participating in the act of parent charge'),
('P.C. 2009','Attempted Robbery','felony',20,1000,'green','The action of attempting property unlawfully from a person or place by force or threat of force.'),
('P.C. 2010','Armed Robbery','felony',30,3000,'orange','The action of taking property unlawfully from a person or place by force or threat of force while armed.'),
('P.C. 2011','Accessory to Armed Robbery','felony',15,1500,'orange','Being present and or participating in the act of parent charge'),
('P.C. 2012','Attempted Armed Robbery','felony',25,1500,'orange','The action of attempting property unlawfully from a person or place by force or threat of force while armed.'),
('P.C. 2013','Grand Larceny','felony',45,7500,'orange','Theft of personal property having a value above a legally specified amount.'),
('P.C. 2014','Leaving Without Paying','infraction',0,500,'green','The act of leaving an establishment without paying for provided service'),
('P.C. 2015','Possession of Nonlegal Currency','misdemeanor',10,750,'green','Being in possession of stolen currency'),
('P.C. 2016','Possession of Government-Issued Items','misdemeanor',15,1000,'green','Being in possession of Items only acquireable by government employees'),
('P.C. 2017','Possession of Items Used in the Commission of a Crime','misdemeanor',10,500,'green','Being in possession of Items that were previously used to commit crimes'),
('P.C. 2018','Sale of Items Used in the Commission of a Crime','felony',15,1000,'orange','The act of selling items that were previously used to commit crimes'),
('P.C. 2019','Theft of an Aircraft','felony',20,1000,'green','The act of stealing an aircraft'),
('P.C. 3001','Impersonating','misdemeanor',15,1250,'green','The action of falsely identifying as another person to deceive'),
('P.C. 3002','Impersonating a Peace Officer or Public Servant','felony',25,2750,'green','The action of falsely identifying as a government employee to deceive'),
('P.C. 3003','Impersonating a Judge','felony',30,3500,'green','The action of falsely identifying as a Judge to deceive'),
('P.C. 3004','Possession of Stolen Identification','misdemeanor',10,750,'green','To have another persons Identification without consent'),
('P.C. 3005','Possession of Stolen Government Identification','misdemeanor',20,2000,'green','To have the identification of a government employee without consent'),
('P.C. 3006','Extortion','felony',20,900,'orange','To threaten or cause harm to a person or property for financial gain'),
('P.C. 3007','Fraud','misdemeanor',10,450,'green','To deceive another for financial gain'),
('P.C. 3008','Forgery','misdemeanor',15,750,'green','To falsify legal documentation for personal gain'),
('P.C. 3009','Money Laundering','felony',40,7500,'red','The processing stolen money for legal currency'),
('P.C. 4001','Trespassing','misdemeanor',10,450,'green','For a person to be within the bounds of a location of which they are not legally allowed'),
('P.C. 4002','Felony Trespassing','felony',15,1500,'green','For a person to have repeatedly entered the bounds of a location of which they are knowingly not legally allowed'),
('P.C. 4003','Arson','felony',15,1500,'orange','The use if fire and accelerants to will and maliciously destroy, harm or cause death to a person or property'),
('P.C. 4004','Vandalism','infraction',0,300,'green','The willful destruction of property'),
('P.C. 4005','Vandalism of Government Property','felony',20,1500,'green','The willful destruction of government property'),
('P.C. 4006','Littering','infraction',0,200,'green','The willful discard of refuse into to open and not in designated bin'),
('P.C. 5001','Bribery of a Government Official','felony',20,3500,'green','the use of money, favors and or property to gain favor with a government official'),
('P.C. 5002','Anti-Mask Law','infraction',0,750,'green','Wearing a mask in a prohibited zone'),
('P.C. 5003','Possession of Contraband in a Government Facility','felony',25,1000,'green','Being in possession of items that are illegal while within a government building'),
('P.C. 5004','Criminal Possession of Stolen Property','misdemeanor',10,500,'green','Being in possession of items stolen knowingly or not'),
('P.C. 5005','Escaping','felony',10,450,'green','The action of willful and knowingly leaving custody while legally being arrest, detained or in jail'),
('P.C. 5006','Jailbreak','felony',30,2500,'orange','The action of leaving state custody from a state or county detention facility'),
('P.C. 5007','Accessory to Jailbreak','felony',25,2000,'orange','Being present and or participating in the act of parent charge'),
('P.C. 5008','Attempted Jailbreak','felony',20,1500,'orange','The willful and intentional attempted escape from a state or county detention facility'),
('P.C. 5009','Perjury','felony',20,2000,'green','The action of stating falsities while legally bound to speak the truth'),
('P.C. 5010','Violation of a Restraining Order','felony',20,2250,'green','The willful and knowing infringement upon court ordered protective documentation'),
('P.C. 5011','Embezzlement','felony',45,10000,'green','The willful and knowingly movement of funds from non personal bank accounts to personal bank accounts for personal gain'),
('P.C. 5012','Unlawful Practice','felony',15,1500,'orange','The action of performing a service without proper legal licensing and approval'),
('P.C. 5013','Misuse of Emergency Systems','infraction',0,600,'orange','Use of government emergency equipment for its non-intended purpose'),
('P.C. 5014','Conspiracy','misdemeanor',10,450,'green','The act of planning a crime but not yet commiting the crime'),
('P.C. 5015','Violating a Court Order','misdemeanor',10,1000,'orange','The infringement of court ordered documentation'),
('P.C. 5016','Failure to Appear','misdemeanor',15,1500,'orange','When someone who is legally bound to appear in court does not do so'),
('P.C. 5017','Contempt of Court','felony',20,2500,'orange','The disruption of court proceedings in a courtroom while it is in session (judicial decision)'),
('P.C. 5018','Resisting Arrest','misdemeanor',5,300,'orange','The act of not allowing peace officers to take you into custody willingly'),
('P.C. 6001','Disobeying a Peace Officer','infraction',0,750,'green','The willful disregard of a lawful order'),
('P.C. 6002','Disorderly Conduct','infraction',0,250,'green','Acting in a manner that creates a hazardous or physically offensive condition by any act which serves no legitimate purpose of the actor. '),
('P.C. 6003','Disturbing the Peace','infraction',0,350,'green','Action in a manner that causes unrest and disrupts public order'),
('P.C. 6004','False Reporting','misdemeanor',10,750,'green','The act of reporting a crime that did not happen'),
('P.C. 6005','Harassment','misdemeanor',10,500,'orange','The repeated disruption or verbal attacks of another person'),
('P.C. 6006','Misdemeanor Obstruction of Justice','misdemeanor',10,500,'green','Acting in a way that hinders the process of Justice or lawful investigations'),
('P.C. 6007','Felony Obstruction of Justice','felony',15,900,'green','Acting in a way that hinders the process of Justice or lawful investigations while using violence'),
('P.C. 6008','Inciting a Riot','felony',25,1000,'orange','Causing civil unrest in a manner to incite a group to cause harm to people or property'),
('P.C. 6009','Loitering on Government Properties','infraction',0,500,'green','When someone is present in a government proper for an extended period of time'),
('P.C. 6010','Tampering','misdemeanor',10,500,'green','When someone willfully, knowingly and indirectly interfering with key points of a lawful investigation'),
('P.C. 6011','Vehicle Tampering','misdemeanor',15,750,'green','The willful and knowing interference the normal function of a vehicle'),
('P.C. 6012','Evidence Tampering','felony',20,1000,'green','The willful and knowing interference with evidence from a lawful investigation'),
('P.C. 6013','Witness Tampering','felony',25,3000,'green','The willful and knowing coaching or coercing of a witness in a lawful investigation'),
('P.C. 6014','Failure to Provide Identification','misdemeanor',15,1500,'green','The act of not presenting identification when lawfully required to do so'),
('P.C. 6015','Vigilantism','felony',30,1500,'orange','The act of engaging in enforcing the law with legal authority to do so'),
('P.C. 6016','Unlawful Assembly','misdemeanor',10,750,'orange','when a large group gathers in a location that requires prior approval to do so'),
('P.C. 6017','Government Corruption','felony',50,10000,'red','The act of using political position and power for self gain'),
('P.C. 6018','Stalking','felony',40,1500,'orange','When one person monitors another without their consent'),
('P.C. 6019','Aiding and Abetting','misdemeanor',15,450,'orange','To assist someone in committing or to encourage someone to commit a crime'),
('P.C. 6020','Harboring a Fugitive','misdemeanor',10,1000,'green','When someone willingly hides another who is wanted by the authorities'),
('P.C. 7001','Misdemeanor Possession of Marijuana','misdemeanor',5,250,'green','The possession of a quantity of marijuana in the amount of less the 4 blunts'),
('P.C. 7002','Felony manufacturing of Marijuana','felony',15,1000,'red','The possession of a quantity of marijuana that is from manufacturing'),
('P.C. 7003','Cultivation of Marijuana A','misdemeanor',10,750,'green','The possession of 4 or less marijuana plants'),
('P.C. 7004','Cultivation of Marijuana B','felony',30,1500,'orange','The possession of 5 or more marijuana plants'),
('P.C. 7005','Possession of Marijuana with Intent to Distribute','felony',30,3000,'orange','The possession of a quantity of Marijuana for distribution'),
('P.C. 7006','Misdemeanor Possession of Cocaine','misdemeanor',7,500,'green','The possession of cocaine in a small quantity usually for personal use'),
('P.C. 7007','Felony manufacturing Possession of Cocaine','felony',25,1500,'red','The possession of a quantity of cocaine that is from manufacturing'),
('P.C. 7008','Possession of Cocaine with Intent to Distribute','felony',35,4500,'orange','The possession of a quantity of Cocaine for distribution'),
('P.C. 7009','Misdemeanor Possession of Methamphetamine','misdemeanor',7,500,'green','The possession of methamphetamine in a small quantity usually for personal use'),
('P.C. 7010','Felony manufacturing Possession of Methamphetamine','felony',25,1500,'red','The possession of a quantity of methamphetamine that is from manufacturing'),
('P.C. 7011','Possession of Methamphetamine with Intent to Distribute','felony',35,4500,'orange','The possession of a quantity of Methamphetamine for distribution'),
('P.C. 7012','Misdemeanor Possession of Oxy / Vicodin','misdemeanor',7,500,'green','The possession of oxy / vicodin in a small quantity usually for personal use without prescription'),
('P.C. 7013','Felony manufacturing Possession of Oxy / Vicodin','felony',25,1500,'red','The possession of a quantity of oxy / vicodin that is from manufacturing'),
('P.C. 7014','Felony Possession of Oxy / Vicodin with Intent to Distribute','felony',35,4500,'orange','The possession of a quantity of oxy / vicodin for distribution'),
('P.C. 7015','Misdemeanor Possession of Ecstasy','misdemeanor',7,500,'green','The possession of ecstasy in a small quantity usually for personal use'),
('P.C. 7016','Felony manufacturing Possession of Ecstasy','felony',25,1500,'red','The possession of a quantity of ecstasy that is from manufacturing'),
('P.C. 7017','Possession of Ecstasy with Intent to Distribute','felony',35,4500,'orange','The possession of a quantity of ecstasy for distribution'),
('P.C. 7018','Misdemeanor Possession of Opium','misdemeanor',7,500,'green','The possession of opium in a small quantity usually for personal use'),
('P.C. 7019','Felony manufacturing Possession of Opium','felony',25,1500,'red','The possession of a quantity of opium that is from manufacturing'),
('P.C. 7020','Possession of Opium with Intent to Distribute','felony',35,4500,'orange','The possession of a quantity of Opium for distribution'),
('P.C. 7021','Misdemeanor Possession of Adderall','misdemeanor',7,500,'green','The possession of adderall in a small quantity usually for personal use without prescription'),
('P.C. 7022','Felony manufacturing Possession of Adderall','felony',25,1500,'red','The possession of a quantity of adderall that is from manufacturing'),
('P.C. 7023','Possession of Adderall with Intent to Distribute','felony',35,4500,'orange','The possession of a quantity of Adderall for distribution'),
('P.C. 7024','Misdemeanor Possession of Xanax','misdemeanor',7,500,'green','The possession of xanax in a small quantity usually for personal use without prescription'),
('P.C. 7025','Felony manufacturing Possession of Xanax','felony',25,1500,'red','The possession of a quantity of xanax that is from manufacturing'),
('P.C. 7026','Possession of Xanax with Intent to Distribute','felony',35,4500,'orange','The possession of a quantity of Xanax for distribution'),
('P.C. 7027','Misdemeanor Possession of Shrooms','misdemeanor',7,500,'green','The possession of shrooms in a small quantity usually for personal use'),
('P.C. 7028','Felony manufacturing Possession of Shrooms','felony',25,1500,'red','The possession of a quantity of shrooms that is from manufacturing'),
('P.C. 7029','Possession of Shrooms with Intent to Distribute','felony',35,4500,'orange','The possession of a quantity of Shrooms for distribution'),
('P.C. 7030','Misdemeanor Possession of Lean','misdemeanor',7,500,'green','The possession of lean in a small quantity usually for personal use'),
('P.C. 7031','Felony manufacturing Possession of Lean','felony',25,1500,'red','The possession of a quantity of lean that is from manufacturing'),
('P.C. 7032','Possession of Lean with Intent to Distribute','felony',35,4500,'orange','The possession of a quantity of lean for distribution'),
('P.C. 7033','Sale of a controlled substance','misdemeanor',10,1000,'green','The sale of a substance that is controlled by law'),
('P.C. 7034','Drug Trafficking','felony',45,8000,'red','The large scale movement of illegal drugs'),
('P.C. 7035','Desecration of a Human Corpse','felony',20,1500,'orange','When someone harms, disturbs or destroys the remains of another person'),
('P.C. 7036','Public Intoxication','infraction',0,500,'green','When someone is intoxicated above legal limit in public'),
('P.C. 7037','Public Indecency','misdemeanor',10,750,'green','The act of someone exposing themself in a way that infringes in public morals'),
('P.C. 8001','Criminal Possession of Weapon Class A','felony',10,500,'green','Possession of a Class A firearm without licensing'),
('P.C. 8002','Criminal Possession of Weapon Class B','felony',15,1000,'green','Possession of a Class B firearm without licensing'),
('P.C. 8003','Criminal Possession of Weapon Class C','felony',30,3500,'green','Possession of a Class C firearm without licensing'),
('P.C. 8004','Criminal Possession of Weapon Class D','felony',25,1500,'green','Possession of a Class D firearm without licensing'),
('P.C. 8005','Criminal Sale of Weapon Class A','felony',15,1000,'orange','The act of selling a Class A firearm without licensing'),
('P.C. 8006','Criminal Sale of Weapon Class B','felony',20,2000,'orange','The act of selling a Class B firearm without licensing'),
('P.C. 8007','Criminal Sale of Weapon Class C','felony',35,7000,'orange','The act of selling a Class C firearm without licensing'),
('P.C. 8008','Criminal Sale of Weapon Class D','felony',30,3000,'orange','The act of selling a Class D firearm without licensing'),
('P.C. 8009','Criminal Use of Weapon','misdemeanor',10,450,'orange','Use of a weapon while in commission of a crime'),
('P.C. 8010','Possession of Illegal Firearm Modifications','misdemeanor',10,300,'green','Being in possession of firearm modifications unlawfully'),
('P.C. 8011','Weapon Trafficking','felony',50,10000,'red','The transportation of a large amount of weapons for one point to another'),
('P.C. 8012','Brandishing a Weapon','misdemeanor',15,500,'orange','The act of making a firearm purposely visible'),
('P.C. 8013','Insurrection','felony',120,25000,'red','Attempting to overthrow the government with violence'),
('P.C. 8014','Flying into Restricted Airspace','felony',20,1500,'green','Piloting and aircraft into airspace that is governmentally controlled'),
('P.C. 8015','Jaywalking','infraction',0,150,'green','crossing a roadway in a manner that is hazardous to motor vehicles'),
('P.C. 8016','Criminal Use of Explosives','felony',30,2500,'orange','Use of explosives to committing a crime'),
('P.C. 9001','Driving While Intoxicated','misdemeanor',5,300,'green','Operating a motor vehicle while impaired by alcohol'),
('P.C. 9002','Evading','misdemeanor',5,400,'green','Hiding or running from lawful detainment'),
('P.C. 9003','Reckless Evading','felony',10,800,'orange','Recklessly disregarding safety and Hiding or running from lawful detainment while '),
('P.C. 9004','Failure to Yield to Emergency Vehicle','infraction',0,600,'green','Not giving way to emergency vehicles'),
('P.C. 9005','Failure to Obey Traffic Control Device','infraction',0,150,'green','Not following the safety devices of the roadway'),
('P.C. 9006','Nonfunctional Vehicle','infraction',0,75,'green','Having a vehicle that is no longer functional in the roadway'),
('P.C. 9007','Negligent Driving','infraction',0,300,'green','Driving in a manner as to unknowingly disregard safety'),
('P.C. 9008','Reckless Driving','misdemeanor',10,750,'orange','Driving in a manner as to knowingly disregard safety'),
('P.C. 9009','Third Degree Speeding','infraction',0,225,'green','Speeding 15 over the limit'),
('P.C. 9010','Second Degree Speeding','infraction',0,450,'green','Speeding 35 over the limit'),
('P.C. 9011','First Degree Speeding','infraction',0,750,'green','Speeding 50 over the limit'),
('P.C. 9012','Unlicensed Operation of Vehicle','infraction',0,500,'green','The operation of a motor vehicle without proper licensing'),
('P.C. 9013','Illegal U-Turn','infraction',0,75,'green','Performing a u-turn where it is prohibited'),
('P.C. 9014','Illegal Passing','infraction',0,300,'green','Passing other motor vehicles in a prohibited manner'),
('P.C. 9015','Failure to Maintain Lane','infraction',0,300,'green','Not staying in the correct lane with a motor vehicle'),
('P.C. 9016','Illegal Turn','infraction',0,150,'green','Performing a turn where it is prohibited'),
('P.C. 9017','Failure to Stop','infraction',0,600,'green','Not stopping for a lawful stop or traffic device'),
('P.C. 9018','Unauthorized Parking','infraction',0,300,'green','Parking a vehicle in a location that requires approval with any'),
('P.C. 9019','Hit and Run','misdemeanor',10,500,'green','Striking another person or vehicle and fleeing the location'),
('P.C. 9020','Driving without Headlights or Signals','infraction',0,300,'green','Operating a vehicle with no functional lights'),
('P.C. 9021','Street Racing','felony',15,1500,'green','Operating motorvehicles in a contest'),
('P.C. 9022','Piloting without Proper Licensing','felony',20,1500,'orange','Failure to be in possession of valid licensing when operating an aircraft'),
('P.C. 9023','Unlawful Use of a Motor Vehicle','misdemeanor',10,750,'green','The use of a motor vehicle without a lawful reason'),
('P.C. 10001','Hunting in Restricted Areas','infraction',0,450,'green','Harvesting game in areas where it is prohibited to do so'),
('P.C. 10002','Unlicensed Hunting','infraction',0,450,'green','Harvesting game without proper licensing'),
('P.C. 10003','Animal Cruelty','misdemeanor',10,450,'green','The act of abusing an animal knowingly or not'),
('P.C. 10004','Hunting with a Non-Hunting Weapon','misdemeanor',10,750,'green','To use a weapon not lawfully stated or manufactured to be used for the harvesting of wild game'),
('P.C. 10005','Hunting outside of hunting hours','infraction',0,750,'green','Harvesting animals outside of specified time to do so'),
('P.C. 10006','Overhunting','misdemeanor',10,1000,'green','Taking more than legally specified amount of game'),
('P.C. 10007','Poaching','felony',20,1250,'red','Harvesting an animal that is listed as legally non-harvestable')
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `category` = VALUES(`category`),
  `jail_time` = VALUES(`jail_time`),
  `fine` = VALUES(`fine`),
  `color` = VALUES(`color`),
  `description` = VALUES(`description`);

DROP PROCEDURE IF EXISTS ers_add_column_if_missing;
DROP PROCEDURE IF EXISTS ers_add_index_if_missing;

SET FOREIGN_KEY_CHECKS = 1;
