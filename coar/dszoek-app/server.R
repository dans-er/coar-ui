
require(stringr)

source("coar.R")

shinyServer(function(input, output) {
        
        paras <- function() {
                str_trim(c(input$emd_title, input$emd_publisher, input$emd_rightsholder, 
                           input$datasetId, input$emd_archis_onderzoeksmeldingsnr))
        }
        
        # output the section.display
        output$section.display <- renderText({ paste("Sectie", input$section) })
        
        # output the query text
        output$query <- renderText({ build.select.1(paras(), input$section) })
        
        # output the number of datasets found
        output$found <- renderText({ 
                paste("Resultaat: ", execute.count.1(paras()), "datasets, sectienr.", input$section) 
                })        
        
        # output the result table
        output$table <- renderDataTable({ execute.select.1(paras(), input$section) }, 
                                        options = list(
                                                lengthMenu = list(c(5, 10, 20, -1), c('5', '10', '20', 'All')),
                                                pageLength = 10),
                                        escape = FALSE)
        
        
})