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
    wellPanel(
      p("To preview unfiltered search results, leave filter fields blank 
        and hit 'Filter'")
    ),
    checkboxGroupInput(ns("dlopts"),
                       "Fields to include",
                       choices = c("doi", "title", "abstract", "journal", "author", "publication date", "publication type", "publication status", "url"),
                       selected = c("doi", "title", "abstract", "url"),
                       inline = T),
    #textOutput(ns("options")),
    DT::dataTableOutput(ns("articletable"))
 
  )
}
    
#' preview Server Function
#'
#' @noRd 
mod_preview_server <- function(input, output, session, data){
  ns <- session$ns
  
  fields <- reactive({ input$dlopts })
  
  #output$options <- renderText({ paste0(input$dlopts) })
  
  output$articletable <- DT::renderDataTable({
    
    if(nrow(data()) > 0) {

    data() %>%
      mutate(url = paste0("https://dx.doi.org/",doi)) %>%
      select( fields() )
      
    } else {
      
      data()
      
    }

  })
 
}
    
## To be copied in the UI
# mod_preview_ui("preview_ui_1")
    
## To be copied in the server
# callModule(mod_preview_server, "preview_ui_1")
 
