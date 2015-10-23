/* 
Script to normalize part of the coar database into the coar_n database.
*/
USE coar_n;

/*
=========================================
Some trick
=========================================
*/
SET foreign_key_checks = 0;

DROP TABLE if exists `tspatials`;
DROP TABLE if exists `tfiles`;
DROP TABLE if exists `tdatasets`;

/* 
========================================
The table to hold the dataset properties 
========================================
*/

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

CREATE TABLE `tfiles` (
    `tfiles_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
    `parent_datasetId` VARCHAR(255) NOT NULL,
    `fedora_file_id` VARCHAR(255) NOT NULL,
    
    `ds_label` VARCHAR(255) DEFAULT NULL,
    `ds_creationdate` datetime DEFAULT NULL,
	`ds_size` bigint(20) DEFAULT NULL,
	`ds_state` varchar(5) DEFAULT NULL,
    `page_count` int(11) DEFAULT NULL,
    `co_pdf` INT DEFAULT 0,
    
    `rcd` datetime DEFAULT NULL,
    `rlm` datetime DEFAULT NULL,
    PRIMARY KEY (`tfiles_id`),
    FOREIGN KEY (`parent_datasetId`) REFERENCES tdatasets(`datasetId`),
    UNIQUE KEY `key_tfiles_fedora_file_id` (`fedora_file_id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=UTF8;

/* tfiles properties from coar.profile */
INSERT INTO `tfiles`
	(`parent_datasetId`, `fedora_file_id`, `ds_label`, `ds_creationdate`, `ds_size`, `ds_state`,
    `page_count`, `rcd`, `rlm`)
    SELECT `datasetId`, `fedora_identifier`, `ds_label`, `ds_creation_date`, `ds_size`, `ds_state`,
    `page_count`, min(`recordcreationdate`) as `rcd`, max(`recordlastmodified`) as `rlm`
    FROM coar.profile
    GROUP BY `fedora_identifier`
    ORDER BY `fedora_identifier`;

/* the count of coordinates per file */

DROP TABLE IF exists `tbl_coo_file_count`;

CREATE temporary table IF NOT EXISTS `tbl_coo_file_count` AS
( SELECT coar.profile.fedora_identifier,
	count(coar.tbl_spatial.spatial_id) as `c_coo`
	FROM coar.profile
	JOIN coar.tbl_spatial ON `parent_tikaprofile_id` = `tikaprofile_id`
	WHERE coar.tbl_spatial.source != 'emd'
	GROUP BY `fedora_identifier`
	ORDER BY `fedora_identifier`
);

/* update the count of coordinates from emd per dataset */
UPDATE `tfiles`, `tbl_coo_file_count` SET `co_pdf` = `c_coo`
WHERE `fedora_file_id` = `fedora_identifier`;

TRUNCATE TABLE `tbl_coo_file_count`;

/*
=========================================
The table to hold the spatials
=========================================
*/

CREATE TABLE `tspatials` (
    `tspatials_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
    `parent_datasetId` VARCHAR(255) NOT NULL,
    `parent_fedora_file_id` VARCHAR(255) DEFAULT NULL,
    `source` varchar(255) DEFAULT NULL,
    
    `coor_x` int(11) DEFAULT NULL,
    `coor_y` int(11) DEFAULT NULL,
	`lat` varchar(255) DEFAULT NULL,
	`lon` varchar(255) DEFAULT NULL,
    `point_index` int(11) DEFAULT NULL,
    `method` int(11) DEFAULT NULL,
    `xy_exchanged` bit(1) DEFAULT NULL,
    
    `limit_north` int(11) DEFAULT NULL,
	`limit_east` int(11) DEFAULT NULL,
    `limit_south` int(11) DEFAULT NULL,
    `limit_west` int(11) DEFAULT NULL,

    PRIMARY KEY (`tspatials_id`),
    FOREIGN KEY (`parent_datasetId`) REFERENCES tdatasets(`datasetId`),
    FOREIGN KEY (`parent_fedora_file_id`) REFERENCES tfiles(`fedora_file_id`)
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=UTF8;

INSERT INTO `tspatials`
	(`parent_datasetId`, `source`, `coor_x`, `coor_y`, `lat`, `lon`, `point_index`, `method`, `xy_exchanged`,
    `limit_north`, `limit_east`, `limit_south`, `limit_west`)
    SELECT `datasetId`, `source`, `coor_x`, `coor_y`, `lat`, `lon`, `point_index`, `method`, `xy_exchanged`,
		`limit_north`, `limit_east`, `limit_south`, `limit_west`
		FROM coar.profile
		JOIN coar.tbl_spatial ON `parent_tikaprofile_id` = `tikaprofile_id`
		WHERE coar.tbl_spatial.source = 'emd'
		GROUP BY `datasetId`, `coor_x`, `coor_y`
		ORDER BY `datasetId`, `coor_x`, `coor_y`;
        
INSERT INTO `tspatials`
	(`parent_datasetId`, `parent_fedora_file_id`, `source`, `coor_x`, `coor_y`, `lat`, `lon`, `point_index`, `method`, `xy_exchanged`,
    `limit_north`, `limit_east`, `limit_south`, `limit_west`)
    SELECT `datasetId`, tbl_spatial.fedora_identifier, `source`, `coor_x`, `coor_y`, `lat`, `lon`, `point_index`, `method`, `xy_exchanged`,
		`limit_north`, `limit_east`, `limit_south`, `limit_west`
		FROM coar.profile
		JOIN coar.tbl_spatial ON `parent_tikaprofile_id` = `tikaprofile_id`
		WHERE coar.tbl_spatial.source != 'emd'
        ORDER BY `datasetId`, tbl_spatial.fedora_identifier, `point_index`;
        
UPDATE `tspatials` SET `limit_north` = NULL, `limit_east` = NULL, `limit_south` = NULL, `limit_west` = NULL
WHERE `limit_north` = 0 AND `limit_east` = 0 AND `limit_south` = 0 AND `limit_west` = 0;


/*
=========================================
Some trick
=========================================
*/
SET foreign_key_checks = 1;