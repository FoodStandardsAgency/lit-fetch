#' filter UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_filter_ui <- function(id){
  ns <- NS(id)
  tagList(
    strong("INCLUDE"),
    fluidRow(column(3,textInput(ns("mustinclude"), "Must include")),
             column(1, selectInput(ns("bool"), label = NULL, choices = c("AND", "OR"))),
             column(3, textInput(ns("mustinclude2"), "Must include")),
             column(1, selectInput(ns("bool2"), label = NULL, choices = c("AND", "OR"))),
             column(3, textInput(ns("mustinclude3"), "Must include"))
    ),
    strong("EXCLUDE"),
    fluidRow(column(3,textInput(ns("mustexclude"), "Must exclude")),
             column(1, strong("AND")),
             column(3,textInput(ns("mustexclude2"), "Must exclude")),
             column(1, strong("AND")),
             column(3,textInput(ns("mustexclude3"), "Must exclude"))
    ),
    actionButton(ns("filternow"),
                 "Filter")
  )
}
    
#' filter Server Function
#'
#' @noRd 
mod_filter_server <- function(input, output, session){
  ns <- session$ns
 
}
    
## To be copied in the UI
# mod_filter_ui("filter_ui_1")
    
## To be copied in the server
# callModule(mod_filter_server, "filter_ui_1")
 
