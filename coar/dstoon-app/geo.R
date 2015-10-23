
source("../global/all.R")

##===================================================================================
## RD x, y to WGS84 latitude longitude. See: http://www.regiolab-delft.nl/?q=node/36
##===================================================================================
## (The sixth decimal place is worth up to 0.11 m.)
## args:
##      x       a numeric vector, the x-value of an RD-point
##      y       a numeric vector, the y-value of an RD-point
##
## returns:     a list of WGS84 latitude/longitude points
RDtoWGS84 <- function(x, y) {
        # converts points x, y to WGS84 lat, lon
        if (is.null(x) || is.na(x) || length(x) < 1) {
                return(NA)
        }
        p <- (x - 155000.00)/100000.00
        q <- (y - 463000.00)/100000.00
        df <- ((q*3235.65389)+(p^2*-32.58297)+(q^2*-0.24750)+(p^2*q*-0.84978)+(q^3*-0.06550)+(p^2*q^2*-0.01709)
               +(p*-0.00738)+(p^4*0.00530)+(p^2*q^3*-0.00039)+(p^4*q*0.00033)+(p*q*-0.00012))/3600.00
        dl <- ((p*5260.52916)+(p*q*105.94684)+(p*q^2*2.45656)+(p^3*-0.81885)+(p*q^3*0.05594)+(p^3*q*-0.05607)
               +(q*0.01199)+(p^3*q^2*-0.00256)+(p*q^4*0.00128)+(q^2*0.00022)+(p^2*-0.00022)+(p^5*0.00026))/3600.00
        lat <- round(52.15517440+df, 6)
        lon <- round(5.387206210+dl, 6)
        
        list("lat"=lat, "lon"=lon)
}

## 
googleMapsURL <- function(wgs84, fmt="%.6f") {
        lat <- sprintf(fmt, wgs84[[1]])
        lon <- sprintf(fmt, wgs84[[2]])
        ifelse(is.na(lat) || is.na(lon), NA,
                paste0("http://maps.google.com/maps?q=", lat, "+", lon))
}

##
openstreetMapURL <- function(wgs84, fmt="%.6f") {
        lat <- sprintf(fmt, wgs84[[1]])
        lon <- sprintf(fmt, wgs84[[2]])
        ifelse(is.na(lat) || is.na(lon), NA,
                paste0("http://www.openstreetmap.org/?mlat=", lat, "&mlon=", lon))
}

##
openstreetMapSearchURL <- function(wgs84, fmt="%.6f") {
        lat <- sprintf(fmt, wgs84[[1]])
        lon <- sprintf(fmt, wgs84[[2]])
        ifelse(is.na(lat) || is.na(lon), NA,
                paste0("http://www.openstreetmap.org/search?query=", lat, "%2C", lon, 
                       "&mlat=", lat, "&mlon=", lon, "#map=12/", lat, "/", lon))
}

##
geonamesPostalCodeURL <- function(wgs84, fmt="%.6f", username=uname_geo) {
        # http://api.geonames.org/findNearbyPostalCodes?lat=52.71377&lng=4.931245&username=demo
        lat <- sprintf(fmt, wgs84[[1]])
        lon <- sprintf(fmt, wgs84[[2]])
        ifelse(is.na(lat) || is.na(lon), NA,
                paste0("http://api.geonames.org/findNearbyPostalCodes?lat=", lat, "&lng=", lon, "&username=", username))
}

##
linkBlank <- function(url, text) {
        ifelse(is.na(url), NA,
                paste0("<a href='", url, "' target='_blank'>", text, "</a>"))
}

##
RDtoTable <- function(x, y) {
        coor_x <- x
        coor_y <- y
        latlon <- RDtoWGS84(x,y)
        if (is.null(latlon) || is.na(latlon)) {
                coor_x <- NA
                coor_y <- NA
                google <- NA
                osm <- NA
                geo <- NA
                return(data.frame(coor_x, coor_y, latlon, google, osm, geo))
        }
        google <- linkBlank(googleMapsURL(latlon), "g-map")
        osm <- linkBlank(openstreetMapSearchURL(latlon), "os-map")
        geo <- linkBlank(geonamesPostalCodeURL(latlon), "geo")
        data <- data.frame(coor_x, coor_y, latlon, google, osm, geo)
        
        data$coor_x <- sprintf("%3.3f", data$coor_x/1000)
        data$coor_y <- sprintf("%3.3f", data$coor_y/1000)
        data$lat <- sprintf("%.6f", data$lat)
        data$lon <- sprintf("%.6f", data$lon)
        data
}

distance <-function(x1, y1, x2, y2) {
        as.integer(sqrt((x1 - x2)^2 + (y1 - y2)^2))
}

##
remove_outliers <- function(x, y, out.disc = -1) {
        
}

