
require(stringr)
source("../rdb/mysql.R")

maxresults <- 10000

################################################################################
## Build a WHERE clause from args
build.where.claus.1 <- function(args) {
        expr <- c("emd_title", "emd_publisher", "emd_rightsholder", "datasetId", "emd_archis_omnr")
        lo <- args != ""                                # a boolean vector reflecting non-empty args
        cl <- paste0(expr[lo], " like '", args[lo], "' and ", collapse = "")
        cl <- substring(cl, 1, str_length(cl) - 5)      # take away last " and "
        if (cl == " like ''") {
                clause <- ""                            # no paras: no WHERE clause
        } else {
                clause <- paste("WHERE", cl)
        }
        return(clause)        
}

################################################################################
## Get datasets given selection in args and section. Limit to maxresults
build.select.1 <- function(args.where, section) {
#         SELECT `datasetId`, `emd_title`, `pdf_files`, `emd_publisher`, `emd_rightsholder`, `emd_archis_omnr`, `co_emd`, `co_pdf` 
#         FROM tdatasets
#         WHERE `emd_title` like '%wijchen%' AND `emd_publisher` like '%ADC%'
#         ORDER BY `datasetId`;
        
        select1 <- "SELECT datasetId, emd_title, pdf_files, emd_publisher, "
        select2 <- "       emd_rightsholder, emd_archis_omnr, co_emd, co_pdf"
        from <- "FROM tdatasets"
        where <- build.where.claus.1(args.where)
        orderby <- "ORDER BY datasetId"
        start <- (section - 1) * maxresults
        limit <- paste0("LIMIT ", start, ",", maxresults, ";")
        paste(select1, select2, from, where, orderby, limit, sep = "\n")
}

setHref <- function(id) {
        paste0("<a href='../dstoon-app/?id=", id, "' target='_blank'>", id, "</a>")
}

execute.select.1 <- function(args.where, section) {
        data <- execute.select(build.select.1(args.where, section))
        colnames(data) <- c("datasetId", "title", "pdfs", "publisher", "rightsholder", "archis_omnr", "co_emd", "co_pdf")
        data$datasetId <- sapply(data$datasetId, setHref, USE.NAMES = FALSE)
        data
}

################################################################################
## Count datasets given selection in args.
build.count.1 <- function(args) {
        select <- "SELECT count(*)"
        from <- "FROM tdatasets"
        where <- build.where.claus.1(args)
        paste(select, from, where, ";", sep = " ")
}

execute.count.1 <- function(args) {
        unlist(execute.select(build.count.1(args)))
}
################################################################################


