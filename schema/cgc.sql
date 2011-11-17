# ************************************************************
# Sequel Pro SQL dump
# Version 3452
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: localhost (MySQL 5.5.15)
# Database: cgc
# Generation Time: 2011-11-14 16:03:57 +0000
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
  PRIMARY KEY (`id`)
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
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table lab_order
# ------------------------------------------------------------

DROP TABLE IF EXISTS `lab_order`;

CREATE TABLE `lab_order` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `laboratory_id` int(11) unsigned DEFAULT NULL,
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
  `name` varchar(255) NOT NULL DEFAULT '',
  `address1` varchar(255) DEFAULT NULL,
  `address2` varchar(255) DEFAULT NULL,
  `state` char(2) DEFAULT NULL,
  `zip` decimal(5,0) unsigned DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `commercial` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table mutagen
# ------------------------------------------------------------

DROP TABLE IF EXISTS `mutagen`;

CREATE TABLE `mutagen` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(15) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table species
# ------------------------------------------------------------

DROP TABLE IF EXISTS `species`;

CREATE TABLE `species` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
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
  KEY `strain_genotype_fk` (`genotype_id`),
  KEY `strain_mutagen_fk` (`mutagen_id`),
  KEY `strain_species_fk` (`species_id`),
  CONSTRAINT `strain_genotype_fk` FOREIGN KEY (`genotype_id`) REFERENCES `genotype` (`id`),
  CONSTRAINT `strain_mutagen_fk` FOREIGN KEY (`mutagen_id`) REFERENCES `mutagen` (`id`),
  CONSTRAINT `strain_species_fk` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
