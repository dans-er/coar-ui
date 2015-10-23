

require(data.table)
require(XML)
require(stringr)

source("../coar/rdb/mysql.R")

username <- "gendan"

getSourceData <- function() {
        query <- paste("SELECT rdatasets.datasetId, median_emd_lat, median_emd_lon, emd_title", 
                        "FROM coar_n.rdatasets",
                        "JOIN tdatasets ON rdatasets.datasetId = tdatasets.datasetId",
                        "WHERE median_emd_lat is not null;",
                        sep = "\n")
        dt <- as.data.table(execute.select(query))
        dt
}

# paste0("http://api.geonames.org/findNearbyPostalCodes?lat=", lat, "&lng=", lon, "&username=", username))

findPlaces <- function(lat, lon) {
        xml.url <- paste0("http://api.geonames.org/findNearbyPostalCodes?lat=", lat, 
                          "&lng=", lon, "&username=", username)
        #print(xml.url)
        xmlfile <- xmlTreeParse(xml.url)
        xmltop = xmlRoot(xmlfile) 
        
        geopc <- xmlSApply(xmltop, function(x) xmlSApply(x, xmlValue))
        data.frame(t(geopc), row.names=NULL)
}

testFindPlaces <- function() {
        lat <- "52.100007"
        lon <- "6.646686"
        findPlaces(lat, lon)
}

comparePlaces <- function(lat, lon, title) {
        df <- findPlaces(lat, lon)
        
        lv <- mapply(grepl, df$name, title, USE.NAMES=FALSE)
        common <- unlist(unique(df$name[lv]))
        paste(common, collapse=",")  
}

testComparePlaces <- function() {
        lat <- "52.046564"
        lon <- "4.257287"
        title <- "Plangebied Meppelweg, Bouwlustlaan, Marterrade en De Rade, gemeente Den Haag; archeologisch vooronderzoek"
        #title <- "Bureauonderzoek en karterend veldonderzoek d.m.v. boringen, Huenderstraat te"
        
        comparePlaces(lat, lon, title)
}

