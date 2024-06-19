#' filter UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#' 
#' @import shiny
mod_filter_ui <- function(id) {
  ns <- NS(id)

  tagList(
    checkboxGroupInput(
      ns("pubchoice"),
      "Publication type",
      choiceNames = c("Review", "Journal article", "All other types"),
      choiceValues = c("review", "journal article", "other"),
      selected = c("review", "journal article", "other"),
    ),
    br(),

    checkboxGroupInput(
      ns("language"),
      "Language options",
      choiceNames = c("English language only (Ebsco and Pubmed)"),
      choiceValues = c("english"),
      inline = T
    ),
    br(),
    
    checkboxGroupInput(
      ns("openaccess"),
      "Open access filter",
      choiceNames = c("Open access articles only (Springer and Scopus)"),
      choiceValues = c("true"),
      inline = T
    ),
    br(),

    p(strong("Words to INCLUDE in title or abstract")),
    wellPanel(
      p(
        "Use OR within text fields if required - each field acts as parentheses"
      )
    ),

    fluidRow(
      column(3, textInput(ns("mustinclude"), "Must include")),
      column(1, strong("AND")),
      column(3, textInput(ns("mustinclude2"), "Must include")),
      column(1, strong("AND")),
      column(3, textInput(ns("mustinclude3"), "Must include"))
    ),
    br(),

    p(strong("Words to EXCLUDE from title and abstract")),
    p(
      "Use OR within text field if required. You cannot use AND in this filter. 
      If a document has an exclude term and an include term it will be excluded."
    ),
    br(),

    fluidRow(column(3, textInput(
      ns("mustexclude"), "Must exclude"
    ))),

    actionButton(
      ns("filternow"),
      "Filter"
    ),

    textOutput(ns("nrecords_filtered"))

  ) # end tagList
}


#' filter Server Function
#' 
#' @param r a `reactiveValues()` list containing the search results
#' @param id Internal parameters for {shiny}.
#'
#' @noRd
#' 
#' @importFrom stringr str_remove_all str_replace_all
#' @importFrom dplyr filter filter_at vars any_vars all_vars anti_join mutate
mod_filter_server <- function(id, r) {
  moduleServer(
    id,
    function(input, output, session) {

      observeEvent(input$filternow, {
        
        r$filtered_result$is_filtered <- TRUE
        
        r$filtered_result$include_terms <- 
          paste0(
            "(",
            input$mustinclude,
            ") AND (",
            input$mustinclude2,
            ") AND (",
            input$mustinclude3,
            ")"
          ) %>%
          str_remove_all(., " AND \\(\\)$") %>%
          str_remove_all(., " AND \\(\\)$") %>%
          str_remove_all(., "^\\(\\)$")
        
        r$filtered_result$exclude_terms <- input$mustexclude
        
        # publication type
        r$filtered_result$include_type <- 
          input$pubchoice %>%
            paste0(., collapse = " , ")
        
        # language
        r$filtered_result$language <-
          if_else(
            is.null(input$language), "", input$language
          )
        
        # open access
        #r$filtered_result$openaccess <-
         # if_else(
          #  is.null(input$openaccess), "", input$openaccess
          #)

        iterm1 <-
          str_replace_all(input$mustinclude, " OR ", "|") %>%
          str_replace_all(., "\"", "\\\\b")
        
        iterm2 <-
          str_replace_all(input$mustinclude2, " OR ", "|") %>%
          str_replace_all(., "\"", "\\\\b")
        
        iterm3 <-
          str_replace_all(input$mustinclude3, " OR ", "|") %>%
          str_replace_all(., "\"", "\\\\b")

        excl <-
          str_replace_all(input$mustexclude, " OR ", "|") %>%
          str_replace_all(., "\"", "\\\\b")
        
        
        if (
          "review" %in% input$pubchoice
          | "journal article" %in% input$pubchoice
        ) {
          types <- c(input$pubchoice, "journal article or review")
        } else {
          types <- input$pubchoice
        }
        
        types <- paste0(types, collapse = "|")
        
        searchreturn <- r$search_result$result

        if (nrow(searchreturn) > 0) {
          # filter on title and abstract for include terms
          include <- searchreturn %>%
            
            # first term
            filter_at(
              vars(title, abstract),
              any_vars(grepl(iterm1, ., ignore.case = T))
            ) %>%
            
            # second term
            filter_at(
              vars(title, abstract),
              any_vars(grepl(iterm2, ., ignore.case = T))
            ) %>%
            
            # third term
            filter_at(
              vars(title, abstract),
              any_vars(grepl(iterm3, ., ignore.case = T))
            ) %>%
            
            # filter publication type
            filter(grepl(types, `publication type`))

          # language filters (only works for Pubmed, others are currently NA)
          if ("english" %in% input$language) {
            include <- include %>%
              filter(lang == "eng" | lang == "English" | is.na(lang))
          }
          
        
          
          if (input$openaccess == "true"){
            include <- include %>% 
              filter(openaccess==TRUE| openaccess=="true")
          }

          # filter out exclusions
          if (excl != "") {
            include <- include %>%
              filter_at(
                vars(title, abstract),
                all_vars(!grepl(excl, ., ignore.case = T))
              )
          }

        } else {
          include <- searchreturn
        }
        
        r$filtered_result$result$include <- include
        
        r$filtered_result$result$exclude <-
          searchreturn %>%
          anti_join(include) %>%
          mutate(exclude = 1)
        
      }) # end filters
      
      
      output$nrecords_filtered <- renderText({

        # case : initial state -> no message
        validate(need(
          r$search_result$search_query != "search query initial state",
          message = FALSE
        ))
        
        # case : no result from search
        validate(need(
          nrow(r$search_result$result) != 0,
          "Your query did not return any result to filter on."
        ))
        
        # case : all results filtered out
        validate(need(
          !(nrow(r$filtered_result$result$include) == 0
            & nrow(r$filtered_result$result$exclude) >= 1),
          "Your filters have excluded all results."
        ))
        
        paste(
          "There are",
          nrow(r$filtered_result$result$include),
          "articles in your filtered data."
        )
      })
    }
  )
}
