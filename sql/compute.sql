

/* 
Script to create tables that will be filled by R.
*/
USE coar_n;

DROP TABLE if exists `rdatasets`;

/* 
=============================================
The table to hold computed dataset properties 
=============================================
*/

CREATE TABLE `rdatasets` (
    `rds_id` BIGINT(20) NOT NULL AUTO_INCREMENT,
    `datasetId` VARCHAR(255) NOT NULL,
    `median_emd_x` INT DEFAULT NULL,
    `median_emd_y` INT DEFAULT NULL,
    `n_emd` INT DEFAULT 0,
    `median_emd_lat` VARCHAR(255) DEFAULT NULL,
    `median_emd_lon` VARCHAR(255) DEFAULT NULL,
    `median_dist_emd_q2` INT DEFAULT NULL,
    `median_dist_emd_q3` INT DEFAULT NULL,
    `median_pdf_x` INT DEFAULT NULL,
    `median_pdf_y` INT DEFAULT NULL,
    `n_pdf` INT DEFAULT 0,
    `median_pdf_lat` VARCHAR(255) DEFAULT NULL,
    `median_pdf_lon` VARCHAR(255) DEFAULT NULL,
    `median_dist_pdf_q2` INT DEFAULT NULL,
    `median_dist_pdf_q3` INT DEFAULT NULL,
    `median_distance` INT DEFAULT NULL,
    PRIMARY KEY (`rds_id`),
    UNIQUE KEY `key_tdatasets_datasetId` (`datasetId`)
)  ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=UTF8;