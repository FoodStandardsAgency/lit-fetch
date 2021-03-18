#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom data.table copy
#' @noRd
app_server <- function(input, output, session) {
  
  search_result <- callModule(mod_search_server, "search_ui_1")

  # if (exists("search_result")) {
  #   search_result_filtered <- copy(search_result)  
  # }
  
  search_result_filtered <-
    callModule(mod_filter_server, "filter_ui_1", data = search_result)

  callModule(mod_preview_server,
    "preview_ui_1",
    data = search_result_filtered[[2]],
    # data = search_result[[2]],
    incorex = 1
  )

  callModule(mod_preview_server,
    "preview_ui_2",
    data = search_result_filtered[[2]],
    incorex = 2
  )

  callModule(
    mod_download_server,
    "download_ui_1",
    data = search_result_filtered[[2]],
    searchstring = search_result[[1]],
    filters = search_result_filtered[[1]]
  )
}
