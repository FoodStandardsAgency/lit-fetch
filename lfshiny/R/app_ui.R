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
    # List the first level UI elements here 
    dashboardPage(skin = "green",
                  dashboardHeader(title = "Lit fetch"),
                  dashboardSidebar(
                    sidebarMenu(menuItem("Welcome", tabName = "welcome", icon = icon("home")), # available icons at https://fontawesome.com/icons?d=gallery
                                menuItem("Search and download", tabName = "search", icon = icon("search")),
                                menuItem("Documentation", tabName = "doc", icon = icon("book-open"))
                    )
                  ),
                  dashboardBody(
                    
                    # to include google analytics, save the tracking script in 
                    # the working directory as google-analytics.html, and 
                    # uncomment the code below
                    
                    # tags$head(includeHTML(("google-analytics.html"))),
                    
                    tabItems(
                      
                      # UI for page 1
                      
                      tabItem(tabName = "welcome",     
                              h3("Welcome"),
                              wellPanel(
                                p("Welcome to the lit fetch app (insert text explaining 
                                  what it is and how it works)")
                                
                                # add module UI calls below
                                
                                # ...
                                
                              )
                      ),
                      
                      # UI for page 2
                      
                      tabItem(tabName = "search",
                              h3("Step 1: Search"),
                              wellPanel(
                                
                                # add module UI calls below

                                mod_search_ui("search_ui_1"),
                              ),
                              h3("Step 2: Filter (term in title or abstract)"),
                              wellPanel(

                                mod_filter_ui("filter_ui_1")
                              ),
                              h3("Step 3: Preview"),
                              wellPanel(
                                
                                mod_preview_ui("preview_ui_1")
                              ),
                              h3("Step 4: Download"),
                              wellPanel(
                                
                                mod_download_ui("download_ui_1")
                                
                              )
                                
                              ),
                      
                      # UI for page 3
                      
                      tabItem(tabName = "doc",
                              h3("Documentation"), 
                              wellPanel(
                                p("Information about the sources")
                                
                                # add module UI calls below
                                
                                # ...
                              )
                      )
                      
                    ) #end of tab items
                  ) #end of dashboard body
    ) #end of dashboard page
  ) #end of tag list
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
  
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'dashboardtemplate'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}