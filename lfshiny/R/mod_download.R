#' download UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList
#' @importFrom dplyr tibble 
#' @import openxlsx
#' 
mod_download_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    downloadButton(ns("filedownload"), label = "Download articles")
 
  )
}
    
#' download Server Function
#'
#' @noRd 
mod_download_server <- function(input, output, session, data){
  ns <- session$ns
  
  articles <- reactive({data()})
  
  searchdetail <- tibble(searchstring = "peanut allergy",
                         timeint = paste(Sys.Date()-365, "to", Sys.Date()),
                         include = "egg AND infant", 
                         exclude = "Australia", 
                         searchdate = Sys.Date())
  
  #articles <- tibble(doi = "10.101011", title = "this is a title", abstract = "blah blah blah")
  
  output$filedownload <- downloadHandler(
    filename = "searchresults.xlsx",
    
    content = function(file) {
      
      wb <- createWorkbook()
      addWorksheet(wb, "Search details")
      addWorksheet(wb, "Articles")

      writeData(wb, "Search details", searchdetail)
      writeData(wb, "Articles", articles())
      
      saveWorkbook(wb, file)
      
    }
  )
 
}
    
## To be copied in the UI
# mod_download_ui("download_ui_1")
    
## To be copied in the server
# callModule(mod_download_server, "download_ui_1")
 
