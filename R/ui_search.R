#' Welcome page UI
#'
#' @import shiny
#' @import shinydashboard
#' @importFrom shinyBS bsCollapsePanel
#' @importFrom shinybusy add_busy_spinner
#' @noRd
ui_search <- function() {
  tabItem(
    tabName = "search",
    
    add_busy_spinner(spin = "fading-circle"),
    
    wellPanel(
      h1("Search"),
      mod_search_ui("search_ui_1"),
      
      # --- FILTER ---
      bsCollapsePanel(
        h2("Filter"),
        wellPanel(
          mod_filter_ui("filter_ui_1")
        )
      ),
      
      # --- PREVIEW ---
      wellPanel(
        h2("Preview"),
        # p(
        #   "To preview unfiltered search results, leave filter fields blank 
        # and hit 'Filter'"
        # ),
        tabsetPanel(
          tabPanel("Included articles", mod_preview_ui("preview_ui_1")),
          tabPanel("Excluded articles", mod_preview_ui("preview_ui_2"))
        )
      )
    ),
    
    # bsCollapsePanel(
    #   h3("Filter"),
    #   wellPanel(
    #     mod_filter_ui("filter_ui_1")
    #   )
    # ),
    
    # bsCollapsePanel(
    #   h3("Preview"),
    #   wellPanel(
    #     p(
    #       "To preview unfiltered search results, leave filter fields blank 
    #     and hit 'Filter'"
    #     ),
    #     tabsetPanel(
    #       tabPanel("Included articles", mod_preview_ui("preview_ui_1")),
    #       tabPanel("Excluded articles", mod_preview_ui("preview_ui_2"))
    #     )
    #   )  
    # ),
    
    bsCollapsePanel(
      h2("Download"),
      wellPanel(
        mod_download_ui("download_ui_1")
      )  
    )
  )
}