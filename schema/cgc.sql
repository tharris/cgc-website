# ************************************************************
# Sequel Pro SQL dump
# Version 3452
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: localhost (MySQL 5.5.15)
# Database: cgc
# Generation Time: 2011-12-23 16:08:22 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table freezer
# ------------------------------------------------------------

DROP TABLE IF EXISTS `freezer`;

CREATE TABLE `freezer` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT '',
  `location` char(10) DEFAULT NULL COMMENT 'Not sure yet how to represent location',
  PRIMARY KEY (`id`),
  KEY `freezer_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table freezer_sample
# ------------------------------------------------------------

DROP TABLE IF EXISTS `freezer_sample`;

CREATE TABLE `freezer_sample` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `freezer_id` int(11) unsigned DEFAULT NULL,
  `strain_id` int(11) unsigned DEFAULT NULL,
  `vials` tinyint(11) unsigned DEFAULT NULL,
  `freeze_date` datetime DEFAULT NULL,
  `frozen_by` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `freezer_sample_freezer_fk` (`freezer_id`),
  KEY `freezer_sample_strain_fk` (`strain_id`),
  CONSTRAINT `freezer_sample_freezer_fk` FOREIGN KEY (`freezer_id`) REFERENCES `freezer` (`id`),
  CONSTRAINT `freezer_sample_strain_fk` FOREIGN KEY (`strain_id`) REFERENCES `strain` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table genotype
# ------------------------------------------------------------

DROP TABLE IF EXISTS `genotype`;

CREATE TABLE `genotype` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `genotype_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


# Dump of table gene
# ------------------------------------------------------------

DROP TABLE IF EXISTS `gene`;

CREATE TABLE `gene` (
  `id`          int(11) unsigned NOT NULL AUTO_INCREMENT,
  `wormbase_id` int(15) unsigned,
  `name` varchar(30) DEFAULT NULL,
  `locus_name` varchar(30) DEFAULT NULL,
  `sequence_name` varchar(30) DEFAULT NULL,
  `chromosome`  varchar(20) DEFAULT NULL,  
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




DROP TABLE IF EXISTS `variation`;

CREATE TABLE `variation` (
  `id`          int(11) unsigned NOT NULL AUTO_INCREMENT,
  `wormbase_id` int(15) unsigned,
  `name` varchar(30) DEFAULT NULL,
  `chromosome`  varchar(20) DEFAULT NULL,  
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table lab_order
# ------------------------------------------------------------

DROP TABLE IF EXISTS `lab_order`;

CREATE TABLE `lab_order` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `laboratory_id` int(11) unsigned DEFAULT NULL,
  `user_id` int(11) unsigned DEFAULT NULL,
  `strain_id` int(11) unsigned DEFAULT NULL,
  `order_date` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `lab_order_laboratory_fk` FOREIGN KEY (`id`) REFERENCES `laboratory` (`id`),
  CONSTRAINT `lab_order_strain_fk` FOREIGN KEY (`id`) REFERENCES `strain` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table laboratory
# ------------------------------------------------------------

DROP TABLE IF EXISTS `laboratory`;

CREATE TABLE `laboratory` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `head` varchar(255) DEFAULT NULL,
  `lab_head_first_name` varchar(255) DEFAULT NULL,
  `lab_head_middle_name` varchar(255) DEFAULT NULL,  
  `lab_head_last_name` varchar(255) DEFAULT NULL,
  `laboratory_designation` varchar(5) DEFAULT NULL,
  `strain_designation` varchar(5) DEFAULT NULL,
  `address1` varchar(255) DEFAULT NULL,
  `address2` varchar(255) DEFAULT NULL,
  `state` char(2) DEFAULT NULL,
  `zip` decimal(5,0) unsigned DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `commercial` tinyint(1) DEFAULT NULL,
  `institution` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `date_assigned` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table legacy_cgcmail
# ------------------------------------------------------------

DROP TABLE IF EXISTS `legacy_cgcmail`;

CREATE TABLE `legacy_cgcmail` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `entry` mediumtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table legacy_frzloc
# ------------------------------------------------------------

DROP TABLE IF EXISTS `legacy_frzloc`;

CREATE TABLE `legacy_frzloc` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `freezer_id` int(11) unsigned DEFAULT NULL,
  `entry` mediumtext,
  PRIMARY KEY (`id`),
  KEY `legacy_frzloc_freezer_fk` (`freezer_id`),
  CONSTRAINT `legacy_frzloc_freezer_fk` FOREIGN KEY (`freezer_id`) REFERENCES `freezer` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table legacy_lablist
# ------------------------------------------------------------

DROP TABLE IF EXISTS `legacy_lablist`;

CREATE TABLE `legacy_lablist` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `laboratory_id` int(11) unsigned DEFAULT NULL,
  `entry` mediumtext,
  PRIMARY KEY (`id`),
  KEY `legacy_lablist_laboratory_fk` (`laboratory_id`),
  CONSTRAINT `legacy_lablist_laboratory_fk` FOREIGN KEY (`laboratory_id`) REFERENCES `laboratory` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table legacy_transrec
# ------------------------------------------------------------

DROP TABLE IF EXISTS `legacy_transrec`;

CREATE TABLE `legacy_transrec` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `entry` mediumtext,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table mutagen
# ------------------------------------------------------------

DROP TABLE IF EXISTS `mutagen`;

CREATE TABLE `mutagen` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mutagen_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table species
# ------------------------------------------------------------

DROP TABLE IF EXISTS `species`;

CREATE TABLE `species` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `species_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table strain
# ------------------------------------------------------------

DROP TABLE IF EXISTS `strain`;

CREATE TABLE `strain` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL DEFAULT '',
  `species_id` int(11) unsigned DEFAULT NULL,
  `description` mediumtext,
  `outcrossed` char(2) DEFAULT NULL COMMENT 'Number of times outcrossed? Another table?',
  `mutagen_id` int(11) unsigned DEFAULT NULL,
  `genotype_id` int(11) unsigned DEFAULT NULL,
  `received` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `made_by` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `strain_name_unique` (`name`),
  KEY `strain_genotype_fk` (`genotype_id`),
  KEY `strain_mutagen_fk` (`mutagen_id`),
  KEY `strain_species_fk` (`species_id`),
  CONSTRAINT `strain_genotype_fk` FOREIGN KEY (`genotype_id`) REFERENCES `genotype` (`id`),
  CONSTRAINT `strain_mutagen_fk` FOREIGN KEY (`mutagen_id`) REFERENCES `mutagen` (`id`),
  CONSTRAINT `strain_species_fk` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table cart
# ------------------------------------------------------------

DROP TABLE IF EXISTS app_cart;

CREATE TABLE app_cart (
    `cart_id` int(11) NOT NULL AUTO_INCREMENT,
    `user_id` int(11) NOT NULL AUTO_INCREMENT,
     PRIMARY KEY (`cart_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS app_cart_contents;

CREATE TABLE app_cart_contents (
    `cart_id` int(11) NOT NULL AUTO_INCREMENT,
    `strain_id` int(11) NOT NULL AUTO_INCREMENT,
     PRIMARY KEY (`cart_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table comments
# ------------------------------------------------------------

DROP TABLE IF EXISTS `comments`;

CREATE TABLE `comments` (
  `comment_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `page_id` int(11) DEFAULT NULL,
  `timestamp` int(11) DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `content` text,
  PRIMARY KEY (`comment_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table history
# ------------------------------------------------------------

DROP TABLE IF EXISTS `app_history`;

CREATE TABLE `app_history` (
  `session_id` char(72) NOT NULL DEFAULT '',
  `page_id` int(11) NOT NULL DEFAULT '0',
  `timestamp` int(11) DEFAULT NULL,
  `visit_count` int(11) DEFAULT NULL,
  PRIMARY KEY (`session_id`,`page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table app_oauth
# ------------------------------------------------------------

DROP TABLE IF EXISTS `app_oauth`;

CREATE TABLE `app_oauth` (
  `oauth_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `provider` char(255) DEFAULT NULL,
  `access_token` char(255) DEFAULT NULL,
  `access_token_secret` char(255) DEFAULT NULL,
  `username` char(255) DEFAULT NULL,
  PRIMARY KEY (`oauth_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table app_openid
# ------------------------------------------------------------

DROP TABLE IF EXISTS `app_openid`;

CREATE TABLE `app_openid` (
  `auth_id` int(11) NOT NULL AUTO_INCREMENT,
  `openid_url` char(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `provider` char(255) DEFAULT NULL,
  `oauth_access_token` char(255) DEFAULT NULL,
  `oauth_access_token_secret` char(255) DEFAULT NULL,
  `screen_name` char(255) DEFAULT NULL,
  `auth_type` char(20) DEFAULT NULL,
  PRIMARY KEY (`auth_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


# Dump of table app_password_reset
# ------------------------------------------------------------
DROP TABLE IF EXISTS `app_password_reset`;

CREATE TABLE `app_password_reset` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `token` char(50) DEFAULT NULL,
  `expires` int(11) DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


# Dump of table app_roles
# ------------------------------------------------------------
DROP TABLE IF EXISTS `app_roles`;

CREATE TABLE `app_roles` (
  `role_id` int(11) NOT NULL,
  `role` char(255) DEFAULT NULL,
  PRIMARY KEY (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `app_roles` VALUES ('1','admin'),('2','manager'),('3','employee'),('4','user');

# Dump of table app_sessions
# ------------------------------------------------------------

DROP TABLE IF EXISTS `app_sessions`;

CREATE TABLE `app_sessions` (
  `session_id` char(72) NOT NULL,
  `session_data` text,
  `expires` int(10) DEFAULT NULL,
  PRIMARY KEY (`session_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table app_starred
# ------------------------------------------------------------

DROP TABLE IF EXISTS `app_starred`;

CREATE TABLE `app_starred` (
  `session_id` char(72) NOT NULL DEFAULT '',
  `page_id` int(11) NOT NULL DEFAULT '0',
  `save_to` char(50) DEFAULT NULL,
  `timestamp` int(11) DEFAULT NULL,
  PRIMARY KEY (`session_id`,`page_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


# Dump of table app_users
# ------------------------------------------------------------

DROP TABLE IF EXISTS `app_users`;

CREATE TABLE `app_users` (
  `user_id`  int(11) NOT NULL AUTO_INCREMENT,
  `username` char(255) DEFAULT NULL,
  `password` char(255) DEFAULT NULL,
  `active`   int(11) DEFAULT NULL,
  `laboratory_id` int(11) DEFAULT NULL,
  `first_name` char(255) DEFAULT NULL,
  `middle_name` char(255) DEFAULT NULL,
  `last_name` char(255) DEFAULT NULL,
  `email` char(255) NOT NULL DEFAULT '',
  `validated` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `app_users` VALUES ('1','tharris','{SSHA}ZZ2/yHLi1OZ0G4fUMaN/T+NA7rm7Jy57','1','EG','Todd','William','Harris','todd@wormbase.org','1');

# Dump of table app_users_to_roles
# ------------------------------------------------------------

DROP TABLE IF EXISTS `app_users_to_roles`;

CREATE TABLE `app_users_to_roles` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `role_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `app_users_to_roles` VALUES ('1','1');

/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
