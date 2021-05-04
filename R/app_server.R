#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#'
#' @import shiny
#' @importFrom tibble tibble
#' 
#' @noRd
app_server <- function(input, output, session) {
  
  # --- INSTANTIATE AND DEFINE APP STATE ---
  r <- reactiveValues(
    search_result = list(
      search_query = "search query initial state",
      date_from = NULL,
      date_to = NULL,
      result = tibble(doi = character(0)),
      totalhits = -2
    ),
    filtered_result = list(
      is_filtered = FALSE,
      include_terms = "",
      exclude_terms = "",
      include_type = "",
      language = "",
      result = list(
        include = tibble(doi = character(0)),
        exclude = tibble(doi = character(0))
      )
    )
  )

  # --- MAIN ---
  mod_search_server("search_ui_1", r = r)
  
  mod_filter_server("filter_ui_1", r = r)
  
  mod_preview_server("preview_ui_1", incorex = "include", r = r)
  
  mod_preview_server("preview_ui_2", incorex = "exclude", r = r)
  
  mod_download_server("download_ui_1", r = r)
}
