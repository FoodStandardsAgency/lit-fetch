#' preview UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_preview_ui <- function(id){
  ns <- NS(id)
  tagList(
    checkboxGroupInput(ns("dlopts"),
                       "Fields to include",
                       choices = c("doi", "title", "abstract", "journal", "author", "publication date", "publication type", "url", "source"),
                       selected = c("doi", "title", "abstract", "url"),
                       inline = T),
    DT::dataTableOutput(ns("previewarticles"))
  )
}
    
#' preview Server Function
#'
#' @noRd 
mod_preview_server <- function(input, output, session, data, incorex){
  ns <- session$ns
  
  fields <- reactive({ input$dlopts })
  
  output$previewarticles <- DT::renderDataTable({
    
    tabledata <- data()[[incorex]]
    
    if(nrow(tabledata) > 0) {

      tabledata %>%
        mutate(abstract = if_else(source == "Scopus", altab, abstract)) %>% 
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
 
