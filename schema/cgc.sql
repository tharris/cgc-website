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
  `frozen_by` int(11) NOT NULL COMMENT 'Should probably be foreign key to app_user',
  PRIMARY KEY (`id`),
  KEY `freezer_sample_freezer_fk` (`freezer_id`),
  KEY `freezer_sample_strain_fk` (`strain_id`),
  CONSTRAINT `freezer_sample_freezer_fk` FOREIGN KEY (`freezer_id`) REFERENCES `freezer` (`id`),
  CONSTRAINT `freezer_sample_strain_fk` FOREIGN KEY (`strain_id`) REFERENCES `strain` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




# Dump of table order
# ------------------------------------------------------------

DROP TABLE IF EXISTS `app_order`;

CREATE TABLE `app_order` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `laboratory_id` int(11) unsigned DEFAULT NULL,  
  `remark`    mediumtext COMMENT 'Special order requests supplied by user',
  `date_received` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `date_shipped`  mediumtext COMMENT 'this needs to be some sort of timestamp',
  PRIMARY KEY (`id`),
  CONSTRAINT `app_order_user_fk` FOREIGN KEY (`user_id`) REFERENCES `app_user` (`user_id`),
  CONSTRAINT `app_order_laboratory_fk` FOREIGN KEY (`laboratory_id`) REFERENCES `laboratory` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

DROP TABLE IF EXISTS `app_order_contents`;

CREATE TABLE `app_order_contents` (
  `order_id` int(11) unsigned NOT NULL,
  `strain_id`      int(11) unsigned NOT NULL,
  `date_thawed` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `thaw_status` enum('success','failed'),
  `curator_remarks` varchar(5) DEFAULT NULL COMMENT 'to be added by whoever freezes/thaws strain',
  PRIMARY KEY (`order_id`,`strain_id`),
  KEY `app_order_contents_strain_id_fk` (`strain_id`),
  KEY `app_order_contents_order_id_fk` (`order_id`),
  CONSTRAINT `app_order_contents_strain_id_fk` FOREIGN KEY (`strain_id`) REFERENCES `strain` (`id`),
  CONSTRAINT `app_order_contents_order_id_fk` FOREIGN KEY (`order_id`) REFERENCES `strain_order` (`id`)
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






# Dump of table cart
# ------------------------------------------------------------

DROP TABLE IF EXISTS app_cart;

CREATE TABLE app_cart (
    `cart_id` int(11) NOT NULL,
    `user_id` int(11) NOT NULL,
     PRIMARY KEY (`cart_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS app_cart_contents;

CREATE TABLE app_cart_contents (
    `cart_id` int(11) NOT NULL,
    `strain_id` int(11) NOT NULL,
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


# Dump of table app_user
# ------------------------------------------------------------

DROP TABLE IF EXISTS `app_user`;

CREATE TABLE `app_user` (
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

INSERT INTO `app_user` VALUES ('1','tharris','{SSHA}ZZ2/yHLi1OZ0G4fUMaN/T+NA7rm7Jy57','1','EG','Todd','William','Harris','todd@wormbase.org','1');
INSERT INTO `app_user` VALUES ('2','shiran','{SSHA}ZZ2/yHLi1OZ0G4fUMaN/T+NA7rm7Jy57','1','EG','Shiran','','Pasternak','shiranpasternak@gmail.com','1');

# Dump of table app_users_to_roles
# ------------------------------------------------------------

DROP TABLE IF EXISTS `app_users_to_roles`;

CREATE TABLE `app_users_to_roles` (
  `user_id` int(11) NOT NULL DEFAULT '0',
  `role_id` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`user_id`,`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `app_users_to_roles` VALUES ('1','1');
INSERT INTO `app_users_to_roles` VALUES ('2','1');






# Dump of table genotype
# ------------------------------------------------------------

#DROP TABLE IF EXISTS `genotype`;

#CREATE TABLE `genotype` (
#  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
#  `name` varchar(30) DEFAULT NULL,
#  PRIMARY KEY (`id`),
#  KEY `genotype_name_unique` (`name`)
#) ENGINE=InnoDB DEFAULT CHARSET=utf8;


# Dump of table gene
# ------------------------------------------------------------

DROP TABLE IF EXISTS `gene`;

CREATE TABLE `gene` (
  `id`          int(11) unsigned NOT NULL AUTO_INCREMENT,
  `wormbase_id` varchar(20) DEFAULT NULL,
  `name`        varchar(30) DEFAULT NULL,
  `locus_name` varchar(30) DEFAULT NULL,
  `sequence_name` varchar(30) DEFAULT NULL,
  `chromosome`  varchar(20) DEFAULT NULL,  
  `gmap` float(7,5) DEFAULT NULL,
  `pmap_start` int(8) unsigned DEFAULT NULL,
  `pmap_stop` int(8) unsigned DEFAULT NULL,
  `strand`  char(1) DEFAULT NULL,
  `species_id` int(8) unsigned DEFAULT NULL,
  `gene_class_id` int(8) unsigned DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `gene_wormbase_id_unique` (`wormbase_id`),
  UNIQUE KEY `gene_name_unique` (`name`),
  KEY `gene_species_fk` (`species_id`),
  KEY `gene_class_fk` (`gene_class_id`),
  CONSTRAINT `gene_species_fk` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`),
  CONSTRAINT `gene_gene_class_fk` FOREIGN KEY (`gene_class_id`) REFERENCES `gene_class` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `gene_class`;

CREATE TABLE `gene_class` (
  `id`   int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(20) NOT NULL DEFAULT '',
  `description` mediumtext,
  `laboratory_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `gene_class_name_unique` (`name`),
  KEY `gene_class_laboratory_fk` (`laboratory_id`),
  CONSTRAINT `gene_class_laboratory_fk` FOREIGN KEY (`laboratory_id`) REFERENCES `laboratory` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `variation`;

CREATE TABLE `variation` (
  `id`          int(11) unsigned NOT NULL AUTO_INCREMENT,
  `wormbase_id` varchar(20) DEFAULT NULL,
  `name` varchar(30) DEFAULT NULL,
  `chromosome`  varchar(20) DEFAULT NULL,
  `gmap` float(7,5) DEFAULT NULL,
  `pmap_start` int(8) unsigned DEFAULT NULL,
  `pmap_stop`  int(8) unsigned DEFAULT NULL,
  `strand`  char(1) DEFAULT NULL,
  `genic_location` varchar(30) DEFAULT NULL COMMENT 'eg intron, exon, promoter',
  `variation_type` varchar(30) DEFAULT NULL COMMENT 'synthesis of the is_* cols, eg Naturally occurring insertion',
  `type_of_dna_change` varchar(30) DEFAULT NULL COMMENT 'eg substitution, insertion, deletion',
  `type_of_protein_change` varchar(30) DEFAULT NULL COMMENT 'eg missense, nonsense, frameshift',
  `protein_change_position` varchar(30) DEFAULT NULL COMMENT 'A212D',
  `is_ko_consortium_allele` int(1) DEFAULT NULL,
  `is_reference_allele` int(1) DEFAULT NULL,
  `is_snp` int(1) DEFAULT NULL,
  `is_rflp` int(1) DEFAULT NULL,
  `is_natural_variant` int(1) DEFAULT NULL,
  `is_transposon_insertion` int(1) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `species_id` int(11) unsigned DEFAULT NULL,
  `gene_class_id` int(11) unsigned DEFAULT NULL,
  `laboratory_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `variation_name_unique` (`name`),
  KEY `variation_species_fk` (`species_id`),
  KEY `variation_gene_class_fk` (`gene_class_id`),
  KEY `variation_laboratory_fk` (`laboratory_id`),
  CONSTRAINT `variation_species_fk` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`),
  CONSTRAINT `variation_gene_class_fk` FOREIGN KEY (`gene_class_id`) REFERENCES `gene_class` (`id`),
  CONSTRAINT `variation_laboratory_fk` FOREIGN KEY (`laboratory_id`) REFERENCES `laboratory` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DROP TABLE IF EXISTS `variation2gene`;

CREATE TABLE `variation2gene` (
  `variation_id` int(11) unsigned NOT NULL,
  `gene_id`      int(11) unsigned NOT NULL,
  PRIMARY KEY (`variation_id`,`gene_id`),
  KEY `variation2gene_gene_id_fk` (`gene_id`),
  KEY `variation2gene_variation_id_fk` (`variation_id`),
  CONSTRAINT `variation2gene_gene_id_fk` FOREIGN KEY (`gene_id`) REFERENCES `gene` (`id`),
  CONSTRAINT `variation2gene_variation_id_fk` FOREIGN KEY (`variation_id`) REFERENCES `variation` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




DROP TABLE IF EXISTS `transgene`;

CREATE TABLE `transgene` (
  `id`          int(11) unsigned NOT NULL AUTO_INCREMENT,
  `wormbase_id` varchar(20) DEFAULT NULL,
  `name` varchar(30) DEFAULT NULL,
  `description`  varchar(255) DEFAULT NULL,
  `reporter_type` varchar(40) DEFAULT NULL,
  `reporter_product` varchar(40) DEFAULT NULL,
  `extrachromosomal` int(1) unsigned DEFAULT NULL,
  `integrated` int(1) unsigned DEFAULT NULL,
  `reporter_product_gene_id` int(11) unsigned DEFAULT NULL,
  `chromosome`  varchar(20) DEFAULT NULL,  
  `gmap` float(7,5) DEFAULT NULL,
  `pmap_start` int(8) unsigned DEFAULT NULL,
  `pmap_stop` int(8) unsigned DEFAULT NULL,
  `strand`  char(1) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `species_id` int(11) unsigned DEFAULT NULL,
  `laboratory_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `transgene_name_unique` (`name`),
  KEY `transgene_species_fk` (`species_id`),
  KEY `transgene_laboratory_fk` (`laboratory_id`),
  CONSTRAINT `transgene_species_fk` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`),
  CONSTRAINT `transgene_laboratory_fk` FOREIGN KEY (`laboratory_id`) REFERENCES `laboratory` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;




DROP TABLE IF EXISTS `rearrangement`;

CREATE TABLE `rearrangement` (
  `id`          int(11) unsigned NOT NULL AUTO_INCREMENT,
  `wormbase_id` varchar(20) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description`  varchar(255) DEFAULT NULL,
  `type` varchar(100) DEFAULT NULL,
  `mutagen_id` int(11) unsigned DEFAULT NULL,
  `chromosome`  varchar(20) DEFAULT NULL,  
  `gmap` float(7,5) DEFAULT NULL,
  `pmap_start` int(8) unsigned DEFAULT NULL,
  `pmap_stop` int(8) unsigned DEFAULT NULL,
  `strand`  char(1) DEFAULT NULL,
  `status` varchar(20) DEFAULT NULL,
  `species_id` int(11) unsigned DEFAULT NULL,
  `laboratory_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `rearrangement_name_unique` (`name`),
  KEY `rearrangement_species_fk` (`species_id`),
  KEY `rearrangement_laboratory_fk` (`laboratory_id`),
  CONSTRAINT `rearrangement_species_fk` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`),
  CONSTRAINT `rearrangement_laboratory_fk` FOREIGN KEY (`laboratory_id`) REFERENCES `laboratory` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



DROP TABLE IF EXISTS `atomized_genotype`;

CREATE TABLE `atomized_genotype` (
  `id`               int(11) unsigned NOT NULL AUTO_INCREMENT,
  `strain_id`        int(11) unsigned NOT NULL,
  `variation_id`     int(11) unsigned DEFAULT NULL,
  `transgene_id`     int(11) unsigned DEFAULT NULL,
  `gene_id`          int(11) unsigned DEFAULT NULL,
  `rearrangement_id` int(11) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `atomized_genotype_gene_id_fk` (`gene_id`),
  KEY `atomized_genotype_variation_id_fk` (`variation_id`),
  KEY `atomized_genotype_transgene_id_fk` (`transgene_id`),
  KEY `atomized_genotype_rearrangement_id_fk` (`rearrangement_id`),
  CONSTRAINT `atomized_genotype_gene_id_fk` FOREIGN KEY (`gene_id`) REFERENCES `gene` (`id`),
  CONSTRAINT `atomized_genotype_variation_id_fk` FOREIGN KEY (`variation_id`) REFERENCES `variation` (`id`),
  CONSTRAINT `atomized_genotype_transgene_id_fk` FOREIGN KEY (`transgene_id`) REFERENCES `transgene` (`id`),
  CONSTRAINT `atomized_genotype_rearrangement_id_fk` FOREIGN KEY (`rearrangement_id`) REFERENCES `rearrangement` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


# Dump of table laboratory
# ------------------------------------------------------------

DROP TABLE IF EXISTS `laboratory`;

CREATE TABLE `laboratory` (
  `id`   int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(25) DEFAULT NULL,
  `head` varchar(255) DEFAULT NULL,
  `lab_head_first_name` varchar(255) DEFAULT NULL,
  `lab_head_middle_name` varchar(255) DEFAULT NULL,  
  `lab_head_last_name` varchar(255) DEFAULT NULL,
  `allele_designation` varchar(5) DEFAULT NULL,
  `street_address` varchar(255) DEFAULT NULL,
  `address1` varchar(255) DEFAULT NULL,
  `address2` varchar(255) DEFAULT NULL,
  `state` char(2) DEFAULT NULL,
  `zip` decimal(5,0) unsigned DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `commercial` tinyint(1) DEFAULT NULL,
  `institution` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `date_assigned` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_unique` (`name`)	
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


#DROP TABLE IF EXISTS `laboratory2gene_class`;

#CREATE TABLE `laboratory2gene_class` (
#  `laboratory_id` int(11) unsigned NOT NULL,
#  `gene_class_id`      int(11) unsigned NOT NULL,
#  PRIMARY KEY (`laboratory_id`,`gene_class_id`),
#  KEY `laboratory2gene_class_gene_class_id_fk` (`gene_class_id`),
#  KEY `laboratory2gene_class_laboratory_id_fk` (`laboratory_id`),
#  CONSTRAINT `laboratory2gene_class_gene_class_id_fk` FOREIGN KEY (`gene_class_id#`) REFERENCES `gene_class` (`id`),
#  CONSTRAINT `laboratory2gene_class_laboratory_id_fk` FOREIGN KEY (`laboratory_id#`) REFERENCES `laboratory` (`id`)
#) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table mutagen
# ------------------------------------------------------------

DROP TABLE IF EXISTS `mutagen`;

CREATE TABLE `mutagen` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(40) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `mutagen_name_unique` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;



# Dump of table species
# ------------------------------------------------------------

DROP TABLE IF EXISTS `species`;

CREATE TABLE `species` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL DEFAULT '',
  `ncbi_taxonomy_id` int(50) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `species_name_unique` (`name`)
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
#  `genotype_id` int(11) unsigned DEFAULT NULL,
  `genotype` varchar(100) DEFAULT NULL,
  `received` varchar(50) DEFAULT NULL,
  `made_by` varchar(50) DEFAULT NULL,
  `laboratory_id` int(11) unsigned DEFAULT NULL,
  `males` varchar(50) DEFAULT NULL,
  `inbreeding_state_selfed` varchar(50) DEFAULT NULL,
  `inbreeding_state_isofemale` varchar(50) DEFAULT NULL,
  `inbreeding_state_multifemale` varchar(50) DEFAULT NULL,
  `inbreeding_state_inbred` varchar(50) DEFAULT NULL,
  `reference_strain` varchar(50) DEFAULT NULL,
  `sample_history`  varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `strain_name_unique` (`name`),
#  KEY `strain_genotype_fk` (`genotype_id`),
  KEY `strain_mutagen_fk` (`mutagen_id`),
  KEY `strain_species_fk` (`species_id`),
  KEY `made_in_laboratory_fk` (`laboratory_id`),
#  CONSTRAINT `strain_genotype_fk`  FOREIGN KEY (`genotype_id`) REFERENCES `genotype` (`id`),
  CONSTRAINT `strain_mutagen_fk`    FOREIGN KEY (`mutagen_id`) REFERENCES `mutagen` (`id`),
  CONSTRAINT `strain_species_fk`    FOREIGN KEY (`species_id`) REFERENCES `species` (`id`),
  CONSTRAINT `strain_laboratory_fk` FOREIGN KEY (`laboratory_id`) REFERENCES `laboratory` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;






/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
