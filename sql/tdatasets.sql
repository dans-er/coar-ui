/* 
Script to normalize part of the coar database into the coar_n database.
*/
USE coar_n;

/* 
========================================
The table to hold the dataset properties 
========================================
*/
DROP TABLE if exists `tdatasets`;

CREATE TABLE `tdatasets` (
    `tds_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
    `datasetId` VARCHAR(255) NOT NULL,
    `emd_title` VARCHAR(255) DEFAULT NULL,
    `emd_publisher` VARCHAR(255) DEFAULT NULL,
    `emd_rightsholder` VARCHAR(255) DEFAULT NULL,
    `emd_accessrights` VARCHAR(255) DEFAULT NULL,
    `emd_archis_omnr` VARCHAR(255) DEFAULT NULL,
    `emd_archis_vondst` VARCHAR(255) DEFAULT NULL,
    `emd_archis_waarneming` VARCHAR(255) DEFAULT NULL,
    `pdf_files` INT DEFAULT 0,
    `co_emd` INT DEFAULT 0,
    `co_pdf` INT DEFAULT 0,
    `rcd` datetime DEFAULT NULL,
    `rlm` datetime DEFAULT NULL,
    PRIMARY KEY (`tds_id`),
    UNIQUE KEY `key_tdatasets_datasetId` (`datasetId`)
)  ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=UTF8;

/* dataset properties from coar.profile */
INSERT INTO `tdatasets`
	(`datasetId`, `emd_title`, `emd_publisher`, `emd_rightsholder`,
     `emd_accessrights`, `emd_archis_omnr`, `emd_archis_vondst`, `emd_archis_waarneming`, `rcd`, `rlm`)
     SELECT `datasetId`, `emd_title`, `emd_publisher`, `emd_rightsholder`,
     `emd_accessrights`, `emd_archis_onderzoeksmeldingsnr`, `emd_archis_vondst`, `emd_archis_waarneming`, 
     min(`recordcreationdate`) as `rcd`, max(`recordlastmodified`) as `rlm`
	 FROM coar.profile
	 GROUP BY `datasetId`
	 ORDER BY `datasetId`;

/* create a tmp table to hold the pdf-counts */
DROP TABLE IF exists `tbl_pdf_count`;

CREATE temporary table IF NOT EXISTS `tbl_pdf_count` AS 
( SELECT coar.profile.datasetId as `ds_id`, count(distinct(coar.tbl_spatial.fedora_identifier)) as `c_files`
	FROM coar.profile
	JOIN coar.tbl_spatial ON `parent_tikaprofile_id` = `tikaprofile_id`
	GROUP BY `ds_id`
	ORDER BY `ds_id`
);

/* update the count of pdf-files per dataset */
UPDATE `tdatasets`, `tbl_pdf_count` SET `pdf_files` = `c_files`
WHERE `datasetId` = `ds_id`;

TRUNCATE TABLE `tbl_pdf_count`;

/* create a tmp table to hold the count of spatial points from emd */
DROP TABLE IF exists `tbl_co_emd_count`;

CREATE temporary table IF NOT EXISTS `tbl_co_emd_count` AS
( SELECT coar.profile.datasetId as `ds_id`,
	floor(count(distinct(coar.tbl_spatial.spatial_id)) / count(distinct(coar.tbl_spatial.fedora_identifier))) as `c_emd`
	FROM coar.profile
	JOIN coar.tbl_spatial ON `parent_tikaprofile_id` = `tikaprofile_id`
	WHERE coar.tbl_spatial.source = 'emd'
	GROUP BY `ds_id`
	ORDER BY `ds_id`
);

/* update the count of coordinates from emd per dataset */
UPDATE `tdatasets`, `tbl_co_emd_count` SET `co_emd` = `c_emd`
WHERE `datasetId` = `ds_id`;

TRUNCATE TABLE `tbl_co_emd_count`;

/* create a tmp table to hold the count of spatial points from pdf */
DROP TABLE IF exists `tbl_coo_count`;

CREATE temporary table IF NOT EXISTS `tbl_coo_count` AS
( SELECT coar.profile.datasetId as `ds_id`,
	count(coar.tbl_spatial.spatial_id) as `c_coo`
	FROM coar.profile
	JOIN coar.tbl_spatial ON `parent_tikaprofile_id` = `tikaprofile_id`
	WHERE coar.tbl_spatial.source != 'emd'
	GROUP BY `ds_id`
	ORDER BY `ds_id`
);

/* update the count of coordinates from emd per dataset */
UPDATE `tdatasets`, `tbl_coo_count` SET `co_pdf` = `c_coo`
WHERE `datasetId` = `ds_id`;

TRUNCATE TABLE `tbl_coo_count`;

/*
=========================================
The table to hold the pdf-file properties
=========================================
*/

DROP TABLE if exists `tfiles`;

CREATE TABLE `tfiles` (
    `tfiles_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
    `datasetId` VARCHAR(255) NOT NULL,
    `fedora_id` VARCHAR(255) NOT NULL,
    
    `ds_label` VARCHAR(255) NOT NULL,
    `ds_creationdate` datetime DEFAULT NULL,
    `rcd` datetime DEFAULT NULL,
    `rlm` datetime DEFAULT NULL,
    PRIMARY KEY (`tfiles_id`),
    UNIQUE KEY `key_tfiles_fedora_id` (`fedora_id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=UTF8;





