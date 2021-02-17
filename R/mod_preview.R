#' preview UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @importFrom dplyr if_else
mod_preview_ui <- function(id){
  ns <- NS(id)
  tagList(
    checkboxGroupInput(ns("dlopts"),
                       "Fields to include",
                       choiceNames = c("doi", "title", "abstract", "journal", "author", "publication date", "publication type", "url", "source"),
                       choiceValues = c("doi", "title", "abstract", "journal", "author", "publication date (yyyy-mm-dd)", "publication type", "url", "source"),
                       selected = c("doi", "title", "abstract", "url"),
                       inline = T),
    DT::dataTableOutput(ns("previewarticles"))
  )
}
    
#' preview Server Function
#'
#' @noRd
#' @importFrom dplyr if_else
mod_preview_server <- function(input, output, session, data, incorex){
  ns <- session$ns
  
  fields <- reactive({ input$dlopts })
  
  output$previewarticles <- DT::renderDataTable({
    
    tabledata <- data()[[incorex]]
    
    if(nrow(tabledata) > 0) {

      tabledata %>%
        mutate(abstract = if_else(source == "Scopus", "[redacted]", abstract)) %>% 
        #mutate(abstract = if_else(source == "Scopus", altab, abstract)) %>% 
        #rename("publication date" = "publication date")
        arrange(source) %>% 
        select( fields() )
      
    } else {
      
      data()[[incorex]]
      
    }

  })

}
    
## To be copied in the UI
# mod_preview_ui("preview_ui_1")
    
## To be copied in the server
# callModule(mod_preview_server, "preview_ui_1")
 
