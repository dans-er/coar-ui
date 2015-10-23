library(shiny)


shinyUI(
        navbarPage(textOutput("navbar"),
                tabPanel("dataset", h3("^"),
                          h3(textOutput("dstitel")),
                          fluidRow(
                                   column(1, htmlOutput("oai_pmh")),
                                   column(1, htmlOutput("easy"))
                                   ),
                          fluidRow(column(6, tableOutput("emd_values")), 
                                   column(6, h4("center.emd: center point en outlier discriminator (out_disc in m.)")), 
                                   column(6, tableOutput("centerpointemd")),
                                   column(6, h4("center.pdf: center point en outlier discriminator (out_disc in m.)")),
                                   column(6, tableOutput("centerpointpdf"))
                                   ),
                          fluidRow(column(6, plotOutput("map_emd")), column(6, plotOutput("map_pdf"))),
                          fluidRow(column(6, tableOutput("emd_spatials"))),
                          fluidRow(column(5, includeHTML("veldnamen.html"))),
                         
                          hr()
                        ),
                tabPanel("coordinaten", h3("^"),
                         h3(textOutput("dstitel2")),
                         h4("Gevonden coordinaten in pdf-bestanden"),
                         tableOutput("pdf_spatials"),
                         helpText("De link naar pdf-bestanden onder 'fileId' werkt alleen als je bent ingelogd bij EASY als archivaris.")
                         ),
                tabPanel("nummers", h3("^"),
                         h3(textOutput("nummers"))
                         ),
                position="fixed-top",
                
                windowTitle="Dataset viewer"
        )
        
)
