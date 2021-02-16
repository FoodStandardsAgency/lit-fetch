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
      ns("otherchoices"),
      "Additional Pubmed search restrictions",
      choiceNames = c("English language only"),
      choiceValues = c("english"),
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
      "Use OR within text field if required. You cannot use AND in this filter. If a document has an exclude term
      and an include term it will be excluded."
    ),
    br(),
    fluidRow(column(3, textInput(
      ns("mustexclude"), "Must exclude"
    ))),
    actionButton(
      ns("filternow"),
      "Filter"
    ),
    textOutput(ns("nrow2"))
  )
}

#' filter Server Function
#'
#' @noRd
mod_filter_server <- function(input, output, session, data) {
  ns <- session$ns

  filters <- reactive({
    incterm <- paste0(
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

    
    exterm <- input$mustexclude

    types <- input$pubchoice %>% paste0(., collapse = " , ")

    if (is.null(input$otherchoices)) {
      other <- ""
    } else {
      other <- input$otherchoices
    }

    list(incterm, exterm, types, other, data()[[4]])
  })


  filterdata <- eventReactive(input$filternow, {
    iterm1 <-
      str_replace_all(input$mustinclude, " OR ", "|") %>% str_replace_all(., "\"", "\\\\b")
    iterm2 <-
      str_replace_all(input$mustinclude2, " OR ", "|") %>% str_replace_all(., "\"", "\\\\b")
    iterm3 <-
      str_replace_all(input$mustinclude3, " OR ", "|") %>% str_replace_all(., "\"", "\\\\b")

    excl <-
      str_replace_all(input$mustexclude, " OR ", "|") %>% str_replace_all(., "\"", "\\\\b")

    types <- paste0(input$pubchoice, collapse = "|")

    searchreturn <- data()[[2]]

    if (nrow(searchreturn) > 0) {
      include <- searchreturn %>%
        filter_at(vars(title, abstract), any_vars(grepl(iterm1, ., ignore.case = T))) %>%
        filter_at(vars(title, abstract), any_vars(grepl(iterm2, ., ignore.case = T))) %>%
        filter_at(vars(title, abstract), any_vars(grepl(iterm3, ., ignore.case = T))) %>%
        filter(grepl(types, `publication type`))

      if ("english" %in% input$otherchoices) {
        include <- include %>% filter(lang == "eng" | is.na(lang))
      } else {
        include <- include
      }

      if (excl == "") {
        include <- include
      } else {
        include <- include %>%
          filter_at(vars(title, abstract), all_vars(!grepl(excl, ., ignore.case = T)))
      }
    } else {
      include <- searchreturn
    }

    exclude <-
      searchreturn %>%
      anti_join(include) %>%
      mutate(exclude = 1)

    fdata <- list(include, exclude)

    return(fdata)
  })

  
  output$nrow2 <- renderText({
    validate(need(
      nrow(filterdata()[[1]]) != 0,
      "Your filters have excluded all of the articles"
    ))
    paste(
      "There are",
      nrow(filterdata()[[1]]),
      "articles in your filtered data."
    )
  })

  return(list(filters, filterdata))
}

## To be copied in the UI
# mod_filter_ui("filter_ui_1")

## To be copied in the server
# callModule(mod_filter_server, "filter_ui_1")
