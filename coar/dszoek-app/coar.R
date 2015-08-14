
require(stringr)
source("../rdb/mysql.R")

maxresults <- 10000

build.where.claus.1 <- function(args) {
        expr <- c("emd_title", "emd_publisher", "emd_rightsholder", "datasetId", "emd_archis_onderzoeksmeldingsnr")
        lo <- args != ""
        cl <- paste0(expr[lo], " like '", args[lo], "' and ", collapse = "")
        cl <- substring(cl, 1, str_length(cl) - 5)
        if (cl == " like ''") {
                clause <- ""
        } else {
                clause <- paste("WHERE", cl)
        }
        return(clause)        
}

build.select.1 <- function(args.where, section) {
        #         SELECT datasetId, emd_title, emd_publisher, emd_rightsholder, emd_archis_onderzoeksmeldingsnr 
        #         FROM profile
        #         WHERE emd_publisher like 'RAAP%' and emd_title like '%plangebied%'
        #         GROUP BY datasetId
        #         ORDER BY emd_title
        
        select <- "SELECT datasetId, emd_title, emd_publisher, emd_rightsholder, emd_archis_onderzoeksmeldingsnr,"
        subselect1 <- paste("(SELECT count(*) FROM tbl_spatial", 
                           "   where parent_tikaprofile_id = tikaprofile_id AND source = 'emd') as co_emd,", 
                           sep="\n")
        subselect2 <- paste("(SELECT count(*) FROM tbl_spatial", 
                           "   where parent_tikaprofile_id = tikaprofile_id AND source != 'emd') as co_pdf", 
                           sep="\n")
        from <- "FROM profile"
        where <- build.where.claus.1(args.where)
        groupby <- "GROUP BY datasetId"
        orderby <- "ORDER BY emd_title"
        start <- (section - 1) * maxresults
        limit <- paste0("LIMIT ", start, ",", maxresults, ";")
        paste(select, subselect1, subselect2, from, where, groupby, orderby, limit, sep = "\n")
}

setHref <- function(id) {
        paste0("<a href='../dstoon-app/?id=", id, "' target='_blank'>", id, "</a>")
}

execute.select.1 <- function(args.where, section) {
        data <- execute.select(build.select.1(args.where, section))
        colnames(data) <- c("datasetId", "title", "publisher", "rightsholder", "archis_omnr", "co_emd", "co_pdf")
        data$datasetId <- sapply(data$datasetId, setHref, USE.NAMES = FALSE)
        data
}

build.count.1 <- function(args.where) {
        select <- "SELECT count(distinct(datasetId))"
        from <- "FROM profile"
        where <- build.where.claus.1(args.where)
        paste(select, from, where, ";", sep = " ")
}

execute.count.1 <- function(args.where) {
        unlist(execute.select(build.count.1(args.where)))
}



