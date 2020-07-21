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
                       choices = c("Pubmed", "Scopus", "Springer"),
                       selected = c("Pubmed", "Scopus", "Springer"),
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
  
  searchterm <- reactive({ input$searchterm })
  
  searchdate <- reactive({ input$searchdate })
  
  returned <- eventReactive(input$searchnow,{
    
    # get pubmed articles for the given search term
    
    pm <- get_pm(searchterm = searchterm(), startdate = searchdate())
    
    # get scopus articles for the given search term
    
    scopus <- get_scopus(searchterm(), datefrom = searchdate())
    
    # get springer articles for the given search term
    
    spring <- get_springer(searchterm(), datefrom = searchdate())
    
    # anti-join by DOI to remove duplicates
    
    spring %>% 
      anti_join(scopus, by = "doi") %>% 
      bind_rows(scopus) %>% 
      anti_join(pm, by = "doi") %>% 
      bind_rows(pm)
    
  })
  
  output$nrow <- renderText({
    validate(
      need(nrow(returned()) != 0, "There are no articles matching that search term."))
    paste("Your search has returned", nrow(returned()), "articles. Refine your search 
    or continue to additional filters below.")
  })
  
  return(list(searchterm, returned))
 
}
    
## To be copied in the UI
# mod_search_ui("search_ui_1")
    
## To be copied in the server
# callModule(mod_search_server, "search_ui_1")
 
