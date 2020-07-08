#' search UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @importFrom shinycssloaders withSpinner
#' @import dplyr
#' 
mod_search_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
    column(4,
    textInput(ns("searchterm"), label = "Enter search term")
    ),
    column(6,
           wellPanel(
           p("Boolean searches accepted, using brackets if required, and surrounding exact terms 
        with quote marks, e.g. aflatoxin AND (maize OR \"aspergillus parasiticus\"). All 
             search terms are wildcards unless surrounded by quotes.")
           )
    )
    ),
    fluidRow(
    column(4,
    dateInput(ns("searchdate"), 
              "Find articles online since",
              value = Sys.Date() - 365,
              min = as.Date("1900-01-01"),
              max = Sys.Date())
    ),
    column(6,
           wellPanel(
           p("For Springer articles, this is the date articles were added to the 
           database (may precede publication date)")
           )
           )
    ),
    checkboxGroupInput(ns("whichdb"),
                       "Select databases to search",
                       choices = c("Pubmed", "Springer"),
                       selected = c("Pubmed", "Springer"),
                       inline = T),
    checkboxGroupInput(ns("pubchoice"),
                       "Publication type",
                       choices = c("Review", "Journal article", "All other types"),
                       selected = c("Review", "Journal article", "All other types"),
                       inline = T),
    checkboxGroupInput(ns("otherchoices"),
                       "Additional search restrictions",
                       choices = c("English language only"),
                       inline = T),
    actionButton(ns("searchnow"),
                 "Search"),
    withSpinner(textOutput(ns("nrow")), type = 4, color = "#006F51", size = 0.3),
    textOutput(ns("springerkey"))
    
  )
}
    
#' search Server Function
#'
#' @noRd 
mod_search_server <- function(input, output, session){
  ns <- session$ns
  
  spapi <- Sys.getenv("SPRINGER_API")
  
  searchterm <- reactive({ input$searchterm })
  
  returned <- eventReactive(input$searchnow,{
    pm <- get_pm(searchterm())
    pmdoi <- pm %>% pull(doi)
    spring <- get_springer(searchterm()) %>% filter(!doi %in% pmdoi)
    bind_rows(pm, spring)
  })
  
  output$nrow <- renderText({
    validate(
      need(nrow(returned()) != 0, "There are no articles matching that search term."))
    paste("Your search has returned", nrow(returned()), "articles. Refine your search 
    or continue to additional filters below.")
  })
  
  
  
  #output$springerkey <- renderText(paste0("the springer URL is ",gen_url_springer("aflatoxin AND (maize OR \"aspergillus parasiticus\")",
  #                                                                                apikey = spapi)))
  
  return(list(searchterm, returned))
 
}
    
## To be copied in the UI
# mod_search_ui("search_ui_1")
    
## To be copied in the server
# callModule(mod_search_server, "search_ui_1")
 
