
source("../rdb/mysql.R")
source("../global/all.R")


## get the emd values for a single dataset
emd_values <- function(datasetId) {
#         SELECT emd_title, emd_publisher, emd_rightsholder, emd_accessrights, 
#         emd_archis_omnr, emd_archis_vondst, emd_archis_waarneming
#         FROM tdatasets
#         WHERE datasetId = 'easy-dataset:27407';
        query <- paste("SELECT emd_title, emd_publisher, emd_rightsholder, emd_accessrights,",
                       "emd_archis_omnr, emd_archis_vondst, emd_archis_waarneming, pdf_files",
                       "FROM tdatasets",
                       paste0("WHERE datasetId = '", datasetId, "'"),
                       sep = "\n")
        data <- execute.select(query)
        ds <- t(data)
        colnames(ds) <- c("EASY metadata (selectie)")
        ds
}

## set the google maps url for given latitude, longitude
set_gom_url <- function(lat, lon) {
        #http://maps.google.com/maps?q=51.013766+5.785849
        url <- paste0("http://maps.google.com/maps?q=",
               lat, "+", lon)
        paste0("<a href='", url, "'' target='_blank'>g-map</a>")
}

set_osm_url <- function(lat, lon) {
        #http://www.openstreetmap.org/search?query=51.013766%2C5.785849&mlat=51.013766&mlon=5.785849#map=12/51.0138/5.7855
        url <- paste0("http://www.openstreetmap.org/search?query=",
                      lat, "%2C", lon,
                      "&mlat=", lat, "&mlon=", lon, "#map=15")
        paste0("<a href='", url, "'' target='_blank'>os-map</a>")
}

set_geonames_url <- function(lat, lon) {
        # http://api.geonames.org/findNearbyPostalCodes?lat=52.713778&lng=4.931245&username=demo
        url <- paste0("http://api.geonames.org/findNearbyPostalCodes?lat=",
                      lat, "&lng=", lon, "&username=", uname_geo)
        paste0("<a href='", url, "'' target='_blank'>geo</a>")
}

# get a table with coordinates from emd per dataset
emd_spatials <- function(datasetId) {
#         SELECT source, coor_x, coor_y, lat, lon, xy_exchanged
#         FROM tspatials
#         WHERE datasetId = 'easy-dataset:28564' AND source = 'emd'
        query <- paste("SELECT source, coor_x, coor_y, lat, lon, xy_exchanged",
                       "FROM tspatials",
                       paste0("WHERE parent_datasetId = '", datasetId, "' AND source = 'emd'"),
                       sep="\n")
        data <- execute.select(query)
        
        data$google <- mapply(set_gom_url, lat = data$lat, lon = data$lon, USE.NAMES = FALSE)
        data$osm <- mapply(set_osm_url, lat = data$lat, lon = data$lon, USE.NAMES = FALSE)
        data$geo <- mapply(set_geonames_url, lat = data$lat, lon = data$lon, USE.NAMES = FALSE)
        data
}

pdf_spatials <- function(datasetId) {
#         SELECT tspatials.parent_datasetId, parent_fedora_file_id, ds_label, ds_size, page_count, source, 
#         method, xy_exchanged, point_index, coor_x, coor_y, lat, lon
#         FROM tspatials
#         JOIN tfiles ON fedora_file_id = parent_fedora_file_id
#         WHERE tspatials.parent_datasetId = 'easy-dataset:57646' AND point_index > 0'
#         ORDER BY parent_fedora_file_id, point_index;
        query <- paste("SELECT tspatials.parent_datasetId, parent_fedora_file_id, ds_label, ds_size, page_count, source,",
                       "method, xy_exchanged, point_index, coor_x, coor_y, lat, lon",
                       "FROM tspatials",
                       "JOIN tfiles ON fedora_file_id = parent_fedora_file_id",
                       paste0("WHERE tspatials.parent_datasetId = '", datasetId, "' AND point_index > 0"),
                       "ORDER BY parent_fedora_file_id, point_index;",
                       sep="\n")
        data <- execute.select(query)
        data$google <- mapply(set_gom_url, lat = data$lat, lon = data$lon, USE.NAMES = FALSE)
        data$osm <- mapply(set_osm_url, lat = data$lat, lon = data$lon, USE.NAMES = FALSE)
        data$geo <- mapply(set_geonames_url, lat = data$lat, lon = data$lon, USE.NAMES = FALSE)
        data
}






