library(shiny)

source("coar.R")
        
shinyUI(fluidPage(
        
        sidebarLayout(
                sidebarPanel( a("< Index", href="../"),
                              h4("Dataset zoeken"),
                              
                              textInput("emd_title", label = h5("Title")),
                              textInput("emd_publisher", label = h5("Publisher")),
                              textInput("emd_rightsholder", label = h5("RightsHolder")),
                              textInput("datasetId", label = h5("dataset ID")),
                              textInput("emd_archis_onderzoeksmeldingsnr", label = h5("ARCHIS onderzoeksmeldingsnr.")),
                              
                              # maxresults is a property of coar.R
                              helpText(paste("Een query met meer dan", maxresults, 
                                    "resultaten wordt verdeeld in secties.",
                                    "Verhoog eventueel het sectienr. om de volgende", maxresults, 
                                    "resultaten te bekijken.")),
                              numericInput("section", label = h5("sectienr."), value = 1, min = 1),
                              
                              submitButton("zoek"),
                              width = 2
                              ),
                mainPanel(
                          h2(textOutput("found", inline = TRUE)),
                          hr(),
                          dataTableOutput('table'),
                          hr(),
                          fluidRow(column(7, includeHTML("veldnamen.html"))),
                          fluidRow(column(7, includeHTML("zoeken.html"))),
                          h2("Query"),
                          fluidRow(column(9, verbatimTextOutput("query"))),
                          fluidRow(column(7, includeHTML("filteren.html"))),
                          
                          width = 10
                )       
        )
        
))