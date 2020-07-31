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
    column(8,
    textInput(ns("searchterm"), label = "Enter search term")
    )
    ),
    fluidRow(
    column(4,
    dateInput(ns("searchdate"), 
              "Find articles online since",
              value = Sys.Date() - 365,
              min = as.Date("1900-01-01"),
              max = Sys.Date())
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

  returned <- eventReactive(input$searchnow,{
    
    # do an initial 'number of hits' search
    
    totalhits <- gettotal(searchterm = input$searchterm,
             datefrom = input$searchdate,
             across = input$whichdb)
    
    if(totalhits > 1000) {
      
      result <- tibble(doi = character(0))
      
      searchresult <- list(input$searchterm, result, totalhits)
      
    } else {
    
    
      # get pubmed articles for the given search term
      
      if("Pubmed" %in% input$whichdb) {
      
        pm <- get_pm(searchterm = input$searchterm, datefrom = input$searchdate)
        
      } else {
        
        pm <- tibble(doi = character(0))
        
      }
      
      # get scopus articles for the given search term
      
      if("Scopus" %in% input$whichdb) {
      
        scopus <- get_scopus(input$searchterm, datefrom = input$searchdate)
        
      } else {
        
        scopus <- tibble(doi = character(0))
        
      }
      
      # get springer articles for the given search term
      
      if("Springer" %in% input$whichdb) {
      
        spring <- get_springer(input$searchterm, datefrom = input$searchdate)
        
      } else {
        
        spring <- tibble(doi = character(0))
        
      }
        
      
      # anti-join by DOI to remove duplicates
      
      result <- spring %>% 
        anti_join(scopus, by = "doi") %>% 
        bind_rows(scopus) %>% 
        anti_join(pm, by = "doi") %>% 
        bind_rows(pm)
      
      # get abstracts that will be hidden (not currently implemented)
      
      # if(nrow(scopus) > 0) {
      # 
      #   dois <- result %>% filter(source == "Scopus") %>% pull(doi)
      # 
      #   extraab <- map_df(dois, slowly(getab, rate = rate_delay(pause = .15)))
      # 
      # } else {
      # 
      #   extraab <- tibble(doi = character(0), altab = character(0))
      # 
      # }
      # 
      # result <- result %>%
      #   left_join(extraab, by = "doi")
      
      totalhits <- nrow(result)
      
      searchresult <- list(input$searchterm, result, totalhits)
      
    }
    return(searchresult)
    
  })
  
  output$nrow <- renderText({
    
    if(returned()[[3]] > 1000) {
      
      paste("Woah your search returned", returned()[[3]], "articles. Try a more specific 
            search term or a smaller time window. The filtering and download 
            functions below will not work.")
      
    } else if(returned()[[3]] == 0) {
      
      paste("Your search did not return any results.")
      
    } else {
      
      paste("Your search returned",returned()[[3]], "articles. Refine your 
            search or continue to additional filters below.")
      
    }

  })
  
  return(returned)
 
}
    
## To be copied in the UI
# mod_search_ui("search_ui_1")
    
## To be copied in the server
# callModule(mod_search_server, "search_ui_1")
 
