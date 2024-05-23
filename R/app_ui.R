#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    
    dashboardPage(
      skin = "green",
      dashboardHeader(title = "Lit Fetch",
                      tags$li(class="dropdown",
                              tags$a("Accessibility Statement",
                                     href="www/accessibility-statement.html",
                                     target="_blank"),
                              style = "cursor: pointer;")),
      
      # --- LEFT RAIL MENU ---
      dashboardSidebar(
        
        sidebarMenu(
          tags$li(class='img-logo',
                  tags$img(src = 'www/fsa-logo-english.png',
                           alt="Food Standards Agency logo",
                           height=110),
                  style='text-align:center'),
          # available icons at https://fontawesome.com/icons?d=gallery
          menuItem("Welcome", tabName = "welcome", icon = icon("home")),
          menuItem("Search and download", tabName = "search", icon = icon("search")),
          menuItem("Documentation", tabName = "doc", icon = icon("book-open"))
        )
      ),
      
      # --- DASHBOARD BODY ---
      dashboardBody(
        # to include google analytics, save the tracking script in
        # the working directory as google-analytics.html, and
        # uncomment the code below
        # tags$head(includeHTML(("google-analytics.html"))),

        tabItems(
          ui_welcome(),
          ui_search(),
          ui_documentation()

        ) # end of tab items
      ) # end of dashboard body
    ) # end of dashboard page
  ) # end of tag list
}


#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www", app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "Lit Fetch"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}