#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function( input, output, session ) {
  # List the first level callModules here
  
  returndata <- callModule(mod_search_server, "search_ui_1")
  
  filterdata <- callModule(mod_filter_server, "filter_ui_1", data = returndata[[2]])
  
  callModule(mod_preview_server, "preview_ui_1", data = filterdata[[2]], incorex = 1)
  callModule(mod_preview_server, "preview_ui_2", data = filterdata[[2]], incorex = 2)
  
  callModule(mod_download_server, "download_ui_1", data = filterdata[[2]], searchstring = returndata[[1]], filters = filterdata[[1]])

}
