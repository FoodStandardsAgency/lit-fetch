#' download UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_download_ui <- function(id){
  ns <- NS(id)
  tagList(
    checkboxGroupInput(ns("dlopts"),
                       "Fields to include in download",
                       choices = c("DOI", "Title", "Abstract", "URL", "Journal", "Author"),
                       selected = c("DOI", "Title", "Abstract", "URL"),
                       inline = T),
    downloadButton(ns("filedownload"), label = "Download articles")
 
  )
}
    
#' download Server Function
#'
#' @noRd 
mod_download_server <- function(input, output, session){
  ns <- session$ns
 
}
    
## To be copied in the UI
# mod_download_ui("download_ui_1")
    
## To be copied in the server
# callModule(mod_download_server, "download_ui_1")
 
