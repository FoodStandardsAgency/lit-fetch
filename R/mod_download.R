#' download UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList
#' @import openxlsx
#' @import dplyr
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
mod_download_server <- function(input, output, session, data, searchstring, filters){
  ns <- session$ns
  
  articles <- reactive({data()})

  searchdetail <- reactive({ data.frame(searchstring = searchstring(),
                        timeint = paste(Sys.Date()-365, "to", Sys.Date()),
                        include = as.character(filters()[1]),
                        exclude = as.character(filters()[2]),
                        searchdate = Sys.Date()) })
  
  output$filedownload <- downloadHandler(
    filename = "searchresults.xlsx",
    
    content = function(file) {
      
      wb <- createWorkbook()
      addWorksheet(wb, "Search details")
      addWorksheet(wb, "Included articles")
      addWorksheet(wb, "Excluded articles")

      writeData(wb, "Search details", searchdetail())
      writeData(wb, "Included articles", articles()[[1]])
      writeData(wb, "Excluded articles", articles()[[2]])
      
      saveWorkbook(wb, file)
      
    }
  )
 
}
    
## To be copied in the UI
# mod_download_ui("download_ui_1")
    
## To be copied in the server
# callModule(mod_download_server, "download_ui_1")
 