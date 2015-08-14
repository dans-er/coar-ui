
source("coar.R")

require(maps)
require(mapdata)

shinyServer(function(input, output, session) {
        
        getDatasetId <- reactive({
                query <- parseQueryString(session$clientData$url_search)
                id <- query$id
                if (is.null(id)) {
                        id <- "easy-dataset:28564"
                }
                id
        })
        
        getEmdValues <- reactive({
                emd_values(getDatasetId())
        })
        
        getEmdSpatials <- reactive({
                emd_spatials(getDatasetId())
        })
        
        getEmdSpatialsDisplay <- reactive({
                data <- getEmdSpatials()
                data <- distance_emd(data, data)
                data$coor_x <- sprintf("%3.3f", as.numeric(data$coor_x)/1000)
                data$coor_y <- sprintf("%3.3f", as.numeric(data$coor_y)/1000)
                data
        })
        
        getPdfSpatials <- reactive({
                pdfdata <- pdf_spatials(getDatasetId())
                pdfdata <- distance_emd(getEmdSpatials(), pdfdata)
                pdfdata <- distance_pdf(pdfdata)
        })
        
        getFileDisplay <- reactive({
                file_data(getPdfSpatials())
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
        
        output$map_emd <- renderPlot({
                data <- getEmdSpatials()
                lon <- as.numeric(data$lon)
                lat <- as.numeric(data$lat)
                cols <- rainbow(nrow(data), alpha=0.7)
                xl <- 2.3; xr <- 8.0; yb <- 50.7; yt <- 53.7
                op <- par(mar = c(0, 0, 0, 0))
                map("world", xlim=c(xl, xr), ylim=c(yb, yt), bg="snow")
                points(x=lon, y=lat, col=cols, pch=19, cex=1.5)
                title(main=paste0("Coordinaten uit EASY metadata (", nrow(data), ")"))
                par(op)
        })
        
        output$map_pdf <- renderPlot({
                data <- getPdfSpatials()
                lon <- as.numeric(data$lon)
                lat <- as.numeric(data$lat)
                cols <- rainbow(nrow(data), alpha=0.7)
                xl <- 2.3; xr <- 8.0; yb <- 50.7; yt <- 53.7
                op <- par(mar = c(0, 0, 0, 0))
                map("world", xlim=c(xl, xr), ylim=c(yb, yt), bg="snow")
                points(x=lon, y=lat, col=cols, pch=19, cex=1.5)
                title(main=paste0("Coordinaten uit pdf-bestanden (", nrow(data), ")"))
                par(op)
        })
        
        # coordina tab
        output$pdf_spatials <- renderTable({ getFileDisplay() }, sanitize.text.function = function(x) x)
        
        # nummers tab
        output$nummers <- renderText({ "nummers" })
})
