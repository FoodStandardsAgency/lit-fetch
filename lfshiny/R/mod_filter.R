#' filter UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList
#' @import stringr 
mod_filter_ui <- function(id){
  ns <- NS(id)
  tagList(
    p(strong("INCLUDE")),
    wellPanel(
      p("Use OR within text fields if required - each field acts as parentheses")
      ),
    br(),
    fluidRow(column(3,textInput(ns("mustinclude"), "Must include")),
             column(1, strong("AND")),
             column(3, textInput(ns("mustinclude2"), "Must include")),
             column(1, strong("AND")),
             column(3, textInput(ns("mustinclude3"), "Must include"))
    ),
    br(),
    p(strong("EXCLUDE")),
    fluidRow(column(3,textInput(ns("mustexclude"), "Must exclude")),
             column(1, strong("AND")),
             column(3,textInput(ns("mustexclude2"), "Must exclude")),
             column(1, strong("AND")),
             column(3,textInput(ns("mustexclude3"), "Must exclude"))
    ),
    actionButton(ns("filternow"),
                 "Filter"),
    textOutput(ns("nrow2"))
  )
}
    
#' filter Server Function
#'
#' @noRd 
mod_filter_server <- function(input, output, session, data){
  ns <- session$ns
  
  filterdata <- eventReactive(input$filternow,{
    
    iterm1 <- str_replace_all(input$mustinclude, " OR ", "|")
    iterm2 <- str_replace_all(input$mustinclude2, " OR ", "|")
    iterm3 <- str_replace_all(input$mustinclude3, " OR ", "|")
    
    excl <- paste0(input$mustexclude,"|",input$mustexclude2,"|",input$mustexclude3) %>% 
      str_replace(., "[|]+$", "")
      
    
    f1 <- data() %>% 
      filter_at(vars(title, abstract), any_vars(grepl(iterm1, ., ignore.case = T))) %>% 
      filter_at(vars(title, abstract), any_vars(grepl(iterm2, ., ignore.case = T))) %>% 
      filter_at(vars(title, abstract), any_vars(grepl(iterm3, ., ignore.case = T))) 
    
    if(excl == "") {
      f1
    } else {
      f1 %>% 
        filter_at(vars(title, abstract), all_vars(!grepl(excl, ., ignore.case = T))) 
    }
    
  })
  
  output$nrow2 <- renderText({
    validate(
      need(nrow(filterdata()) != 0, "Your filters have excluded all of the articles"))
    paste("There are", nrow(filterdata()), "articles in your filtered data.")
  })
  
  return(filterdata)
  
 
}
    
## To be copied in the UI
# mod_filter_ui("filter_ui_1")
    
## To be copied in the server
# callModule(mod_filter_server, "filter_ui_1")
 
