#' Welcome page UI
#'
#' @import shiny
#' @import shinydashboard
#' @noRd
ui_search <- function() {
  tabItem(
    tabName = "search",
    
    h3("Step 1: Search"),
    wellPanel(
      mod_search_ui("search_ui_1"),
    ),
    
    h3("Step 2: Filter"),
    wellPanel(
      mod_filter_ui("filter_ui_1")
    ),
    
    h3("Step 3: Preview"),
    wellPanel(
      p(
        "To preview unfiltered search results, leave filter fields blank
                and hit 'Filter'"
      ),
      tabsetPanel(
        tabPanel("Included articles", mod_preview_ui("preview_ui_1")),
        tabPanel("Excluded articles", mod_preview_ui("preview_ui_2"))
      )
    ),
    
    h3("Step 4: Download"),
    wellPanel(
      mod_download_ui("download_ui_1")
    )
  )
}