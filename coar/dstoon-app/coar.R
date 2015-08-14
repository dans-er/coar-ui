
source("../rdb/mysql.R")

uname_geo <- "demo"

emd_values <- function(datasetId) {
#         SELECT emd_title, emd_publisher, emd_rightsholder, emd_accessrights, 
#         emd_archis_onderzoeksmeldingsnr, emd_archis_vondst, emd_archis_waarneming
#         FROM profile
#         WHERE datasetId = 'easy-dataset:27407'
#         GROUP BY datasetId;
        query <- paste("SELECT emd_title, emd_publisher, emd_rightsholder, emd_accessrights,",
                       "emd_archis_onderzoeksmeldingsnr, emd_archis_vondst, emd_archis_waarneming",
                       "FROM profile",
                       paste0("WHERE datasetId = '", datasetId, "'"),
                       "GROUP BY datasetId;",
                       sep = "\n")
        data <- execute.select(query)
        ds <- t(data)
        colnames(ds) <- c("EASY metadata (selectie)")
        ds
}

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

emd_spatials <- function(datasetId) {
#         SELECT source, coor_x, coor_y, lat, lon 
#         FROM profile
#         JOIN tbl_spatial ON profile.tikaprofile_id = tbl_spatial.parent_tikaprofile_id
#         WHERE datasetId = 'easy-dataset:28564' AND source = 'emd'
#         GROUP BY datasetId, coor_x, coor_y;
        query <- paste("SELECT source, coor_x, coor_y, lat, lon",
                       "FROM profile",
                       "JOIN tbl_spatial ON profile.tikaprofile_id = tbl_spatial.parent_tikaprofile_id",
                       paste0("WHERE datasetId = '", datasetId, "' AND source = 'emd'"),
                       "GROUP BY datasetId, coor_x, coor_y;",
                       sep="\n")
        data <- execute.select(query)
        
        data$google <- mapply(set_gom_url, lat = data$lat, lon = data$lon, USE.NAMES = FALSE)
        data$osm <- mapply(set_osm_url, lat = data$lat, lon = data$lon, USE.NAMES = FALSE)
        data$geo <- mapply(set_geonames_url, lat = data$lat, lon = data$lon, USE.NAMES = FALSE)
        data
}

pdf_spatials <- function(datasetId) {
#         SELECT datasetId, profile.fedora_identifier, ds_label, ds_size, page_count, 
#         source, method, xy_exchanged, within_bounds_x, within_bounds_y, point_index, coor_x, coor_y, lat, lon 
#         FROM profile
#         JOIN tbl_spatial ON tikaprofile_id = parent_tikaprofile_id
#         WHERE datasetId = 'easy-dataset:27886' AND point_index > 0
#         ORDER BY ds_label, point_index;
        query <- paste("SELECT datasetId, profile.fedora_identifier, ds_label, ds_size, page_count,",
                       "source, method, xy_exchanged, within_bounds_x, within_bounds_y, point_index, coor_x, coor_y, lat, lon",
                       "FROM profile",
                       "JOIN tbl_spatial ON tikaprofile_id = parent_tikaprofile_id",
                       paste0("WHERE datasetId = '", datasetId, "' AND point_index > 0"),
                       "ORDER BY ds_label, point_index;",
                       sep="\n")
        data <- execute.select(query)
        data$google <- mapply(set_gom_url, lat = data$lat, lon = data$lon, USE.NAMES = FALSE)
        data$osm <- mapply(set_osm_url, lat = data$lat, lon = data$lon, USE.NAMES = FALSE)
        data$geo <- mapply(set_geonames_url, lat = data$lat, lon = data$lon, USE.NAMES = FALSE)
        data
}

# bereken de afstand tot de median van emd_spatials.
distance_emd <- function(emddata, pdfdata) {
        # int diagonal = (int) Math.sqrt(xdis * xdis + ydis * ydis);
        medx <- median(emddata$coor_x)
        medy <- median(emddata$coor_y)
        
        pdfdata$dist.emd <- as.integer(sqrt((medx - pdfdata$coor_x)^2 + (medy - pdfdata$coor_y)^2))
        pdfdata
}

# bereken de afstand tot de median van pdf_spatials.
distance_pdf <- function(pdfdata) {
        medx <- median(pdfdata$coor_x)
        medy <- median(pdfdata$coor_y)
        
        pdfdata$dist.pdf <- as.integer(sqrt((medx - pdfdata$coor_x)^2 + (medy - pdfdata$coor_y)^2))
        pdfdata 
}

# bereken outliers in de distance kolommen
outliers_distance <- function(pdfdata) {
        
}

setfile_url <- function(datasetId, fileId) {
        #https://easy.dans.knaw.nl/ui/rest/datasets/easy-dataset:28378/files/easy-file:2634442/content
        paste0("<a href='https://easy.dans.knaw.nl/ui/rest/datasets/", 
               datasetId, "/files/", fileId, "/content", "' target='_blank'>", fileId, "</a>")
}

file_data <- function(pdfdata) {
        newdata <- pdfdata
        newdata$fedora_identifier <- mapply(setfile_url, datasetId=newdata$datasetId, fileId=newdata$fedora_identifier,
                                            USE.NAMES=FALSE)
        newdata$datasetId <- NULL
        # compute outliers and distance
        newdata$coor_x <- sprintf("%3.3f", as.numeric(newdata$coor_x)/1000)
        newdata$coor_y <- sprintf("%3.3f", as.numeric(newdata$coor_y)/1000)
        
        newdata$bijz <- as.integer(1*newdata$xy_exchanged + 2*newdata$within_bounds_x + 4*newdata$within_bounds_y)
        newdata$xy_exchanged <- NULL
        newdata$within_bounds_x <- NULL
        newdata$within_bounds_y <- NULL
        newdata$point_index <- NULL
        
        if (nrow(newdata) > 0) {
                lo <- duplicated(newdata[,1:4])
                newdata[lo,1:4] <- ""
        }
        newdata
}





