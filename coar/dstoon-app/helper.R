

# de factor 
outlier.factor <- 3

# bereken outliers op grond van gegevens in de distance kolom voor emd
discriminator_emd <- function(emddata, strict=FALSE) {
        if (strict && nrow(emddata) < 3) {
                return(NA)
        }
        if (nrow(emddata) < 2) {
                return(NA)
        }
        disc.emd <- quantile(emddata$dist.emd)[[4]]
        accept <- floor(outlier.factor * disc.emd)
        accept
}

# bereken outliers op grond van gegevens in de distance kolom voor pdf
discriminator_pdf <- function(pdfdata) {
        if (nrow(pdfdata) < 3) {
                return(NA)
        }
        disc.pdf <- quantile(pdfdata$dist.pdf)[[4]]
        accept <- floor(outlier.factor * disc.pdf)
        accept
}

outliers_emd <- function(emddata) {
        accept_emd <- discriminator_emd(emddata, TRUE)
        emddata$o.e <- ifelse(emddata$dist.emd >= accept_emd, 
                              "<img src='alarm.png' width='20'/>", "<img src='check.png' width='20'/>")
        emddata
}

outliers_pdf <- function(emddata, pdfdata) {
        accept_emd <- discriminator_emd(emddata)
        pdfdata$out.emd <- ifelse(pdfdata$dist.emd >= accept_emd, 
                                  "<img src='alarm.png' width='20'/>", "<img src='check.png' width='20'/>")
        
        accept_pdf <- discriminator_pdf(pdfdata)
        pdfdata$out.pdf <- ifelse(pdfdata$dist.pdf >= accept_pdf, 
                                  "<img src='alarm.png' width='20'/>", "<img src='check.png' width='20'/>")
        
        pdfdata
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

setfile_url <- function(datasetId, fileId) {
        #https://easy.dans.knaw.nl/ui/rest/datasets/easy-dataset:28378/files/easy-file:2634442/content
        paste0("<a href='https://easy.dans.knaw.nl/ui/rest/datasets/", 
               datasetId, "/files/", fileId, "/content", "' target='_blank'>", fileId, "</a>")
}

file_data <- function(pdfdata) {
        newdata <- pdfdata
        newdata$parent_fedora_file_id <- mapply(setfile_url, 
                                                datasetId=newdata$parent_datasetId, fileId=newdata$parent_fedora_file_id, USE.NAMES=FALSE)
        newdata$parent_datasetId <- NULL
        # compute outliers and distance
        
        newdata$coor_x <- sprintf("%3.3f", as.numeric(newdata$coor_x)/1000)
        newdata$coor_y <- sprintf("%3.3f", as.numeric(newdata$coor_y)/1000)
        
        newdata$bijz <- newdata$xy_exchanged
        newdata$point_index <- NULL
        newdata$xy_exchanged <- NULL
        
        if (nrow(newdata) > 0) {
                lo <- duplicated(newdata[,1:4])
                newdata[lo,1:4] <- ""
        }
        
        #         print(colnames(newdata))
        #         [1] "parent_fedora_file_id" "ds_label"              "ds_size"               "page_count"            "source"               
        #         [6] "method"                "coor_x"                "coor_y"                "lat"                   "lon"                  
        #         [11] "google"                "osm"                   "geo"                   "dist.emd"              "dist.pdf"             
        #         [16] "out.emd"               "out.pdf"               "bijz"                  
        
        colnames(newdata) <- c("fileId", "filename", "size", "pages", "page", 
                               "method", "coor_x", "coor_y", "lat", "lon", 
                               "google", "osm", "geo", "dist.emd", "dist.pdf", 
                               "o.e", "o.p", "bijz.")
        newdata <- newdata[,c(1,2,3,4,5,7,8,9,10,11,12,13,14,16,15,17,18,6)]
        newdata
}