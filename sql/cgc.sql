# ************************************************************
# Sequel Pro SQL dump
# Version 3448
#
# http://www.sequelpro.com/
# http://code.google.com/p/sequel-pro/
#
# Host: localhost (MySQL 5.5.15)
# Database: cgc
# Generation Time: 2011-10-20 02:45:37 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table lab_order
# ------------------------------------------------------------

DROP TABLE IF EXISTS `lab_order`;

CREATE TABLE `lab_order` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `laboratory_id` int(11) unsigned DEFAULT NULL,
  `strain_id` int(11) unsigned DEFAULT NULL,
  `order_date` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  CONSTRAINT `lab_order_strain_fk` FOREIGN KEY (`id`) REFERENCES `strain` (`id`),
  CONSTRAINT `lab_order_laboratory_fk` FOREIGN KEY (`id`) REFERENCES `laboratory` (`id`)
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
  `zip` decimal(5,0) DEFAULT NULL,
  `commercial` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table strain
# ------------------------------------------------------------

DROP TABLE IF EXISTS `strain`;

CREATE TABLE `strain` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
