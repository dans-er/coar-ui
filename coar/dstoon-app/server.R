
source("coar.R")
source("geo.R")
source("helper.R")


require(maps)
require(mapdata)

shinyServer(function(input, output, session) {
        
        getDatasetId <- reactive({
                query <- parseQueryString(session$clientData$url_search)
                id <- query$id
                if (is.null(id)) {
                        id <- "easy-dataset:28563"
                }
                id
        })
        
        getEmdValues <- reactive({
                data <- emd_values(getDatasetId())
                data
        })
        
        getEmdSpatials <- reactive({
                emd_spatials(getDatasetId())
        })
        
        getEmdSpatialsDisplay <- reactive({
                data <- getEmdSpatials()
                data <- distance_emd(data, data)
                data <- outliers_emd(data)
                
                data$coor_x <- sprintf("%3.3f", as.numeric(data$coor_x)/1000)
                data$coor_y <- sprintf("%3.3f", as.numeric(data$coor_y)/1000)
                
                data$bijz <- data$xy_exchanged
                data$xy_exchanged <- NULL
                data$source <- NULL
                data
        })
        
        getPdfSpatials <- reactive({
                pdfdata <- pdf_spatials(getDatasetId())
                pdfdata <- distance_emd(getEmdSpatials(), pdfdata)
                pdfdata <- distance_pdf(pdfdata)
                pdfdata <- outliers_pdf(getEmdSpatialsDisplay(), pdfdata)
                pdfdata
        })
        
        getFileDisplay <- reactive({
                file_data(getPdfSpatials())
        })
        
        getEmdDiscriminator <- reactive({
                as.integer(discriminator_emd(getEmdSpatialsDisplay(), FALSE))
        })
        
        getPdfDiscriminator <- reactive({
                as.integer(discriminator_pdf(getFileDisplay()))
        })
        
        getTableCenterpointEmd <- reactive({
                emds <- getEmdSpatials()
                medx <- median(emds$coor_x)
                medy <- median(emds$coor_y)
                data <- RDtoTable(medx, medy)
                
                data$out_disc <- getEmdDiscriminator()
                data 
        })
        
        getTableCenterpointPdf <- reactive({
                
                pdfs <- getPdfSpatials()
                medx <- median(pdfs$coor_x)
                medy <- median(pdfs$coor_y)                
                data <- RDtoTable(medx, medy)
                
                data$out_disc <- getPdfDiscriminator()
                
                emds <- getEmdSpatials()
                medxe <- median(emds$coor_x)
                medye <- median(emds$coor_y)
                data$dist.center.emd <- distance(medx, medy, medxe, medye)
                
                data 
        })
        
        
        ####### outputs #######
        
        output$navbar <- renderText({ getDatasetId() })
        
        # dataset tab
        
        # https://easy.dans.knaw.nl/oai/?verb=GetRecord&metadataPrefix=oai_dc&identifier=oai:easy.dans.knaw.nl:easy-dataset:29446
        output$oai_pmh <- renderUI({ HTML((paste0("<a href='https://easy.dans.knaw.nl/oai/?verb=GetRecord&metadataPrefix=oai_dc&identifier=oai:easy.dans.knaw.nl:", 
                        getDatasetId(), "' target='_blank'>OAI</a>"))) })
        # https://easy.dans.knaw.nl/ui/datasets/id/easy-dataset:29446
        output$easy <- renderUI({ HTML((paste0("<a href='https://easy.dans.knaw.nl/ui/datasets/id/", 
                        getDatasetId(), "' target='_blank'>EASY</a>"))) })
        
        output$dstitel <- renderText({
                getEmdValues()[1, 1]
        })
        
        output$emd_values <- renderTable({ getEmdValues() })
        output$emd_spatials <- renderTable({ getEmdSpatialsDisplay() }, sanitize.text.function = function(x) x)
        
        output$centerpointemd <- renderTable({
                getTableCenterpointEmd()
        }, sanitize.text.function = function(x) x)
        
        output$centerpointpdf <- renderTable({
                getTableCenterpointPdf()
        }, sanitize.text.function = function(x) x)
        
        
        output$map_emd <- renderPlot({
                data <- getEmdSpatials()
                lon <- as.numeric(data$lon)
                lat <- as.numeric(data$lat)
                cols <- rainbow(nrow(data), alpha=0.7)
                xl <- 2.3; xr <- 8.0; yb <- 50.7; yt <- 53.8
                op <- par(mar = c(0, 0, 4, 0), mai=c(0,0,0,0))
                map("worldHires", xlim=c(xl, xr), ylim=c(yb, yt), bg="gray98")
                points(x=lon, y=lat, col=cols, pch=19, cex=1.5)
                
                if(nrow(data) >= 1) {
                        emdcenter <- getTableCenterpointEmd()
                        lon <- as.numeric(emdcenter$lon)
                        lat <- as.numeric(emdcenter$lat)
                        points(x=lon, y=lat, col="black", pch=3, cex=3.5)
                }
                
                title(main=paste0("Coordinaten uit EASY metadata (", nrow(data), ")"), adj=0)
                par(op)
        })
        
        output$map_pdf <- renderPlot({
                data <- getPdfSpatials()
                lon <- as.numeric(data$lon)
                lat <- as.numeric(data$lat)
                cols <- rainbow(nrow(data), alpha=0.7)
                xl <- 2.3; xr <- 8.0; yb <- 50.7; yt <- 53.8
                op <- par(mar = c(0, 0, 4, 0), mai=c(0,0,0,0))
                map("worldHires", xlim=c(xl, xr), ylim=c(yb, yt), bg="gray98")
                points(x=lon, y=lat, col=cols, pch=19, cex=1.5)
                
                if(nrow(data) >= 1) {
                        pdfcenter <- getTableCenterpointPdf()
                        lon <- as.numeric(pdfcenter$lon)
                        lat <- as.numeric(pdfcenter$lat)
                        points(x=lon, y=lat, col="black", pch=3, cex=3.5)
                }
                
                title(main=paste0("Coordinaten uit pdf-bestanden (", nrow(data), ")"), adj=0)
                par(op)
        })
        
        # coordina tab
        output$dstitel2 <- renderText({
                getEmdValues()[1, 1]
        })
        output$pdf_spatials <- renderTable({ getFileDisplay() }, sanitize.text.function = function(x) x)
        
        # nummers tab
        output$nummers <- renderText({ "nummers" })
})
