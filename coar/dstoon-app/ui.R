library(shiny)

shinyUI(
        navbarPage(textOutput("navbar"),
                tabPanel("dataset", h3(textOutput("dstitel")),
                                  fluidRow(
                                           column(1, htmlOutput("oai_pmh")),
                                           column(1, htmlOutput("easy"))
                                           ),
                                  fluidRow(column(6, tableOutput("emd_values"))),
                                  fluidRow(column(6, plotOutput("map_emd")), column(6, plotOutput("map_pdf"))),
                                  fluidRow(column(6, tableOutput("emd_spatials")))
                        ),
                tabPanel("coordinaten",
                         h3("Gevonden coordinaten in pdf-bestanden"),
                         tableOutput("pdf_spatials"),
                         helpText("De link naar pdf-bestanden onder 'fedora_identifier' werkt alleen als je bent ingelogd bij EASY als archivaris.")
                         ),
                tabPanel("nummers",
                         h3(textOutput("nummers"))
                         ),
                windowTitle="Dataset viewer"
        )
        
)
