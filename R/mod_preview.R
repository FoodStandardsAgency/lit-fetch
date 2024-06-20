#' preview UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList checkboxGroupInput
#' @importFrom DT DTOutput
#' @importFrom dplyr if_else
mod_preview_ui <- function(id) {
  ns <- NS(id)

  tagList(
    checkboxGroupInput(
      ns("dlopts"),
      label = "Fields to include",
      choiceNames = c(
        "doi",
        "title",
        "abstract",
        "journal",
        "author",
        "publication date",
        "publication type",
        "url",
        "source"
      ),
      choiceValues = c(
        "doi",
        "title",
        "abstract",
        "journal",
        "author",
        "publication date (yyyy-mm-dd)",
        "publication type",
        "url",
        "source"
      ),
      selected = c("doi", "title"),
      inline = T
    ), # end checkboxGroupInput
    
    DTOutput(ns("previewarticles"))
  ) # end tagList
}


#' preview Server Function
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' @param incorex (include or exclude) props index for articles tables (included: 1, excluded: 2)
#' @param r a `reactiveValues()` list containing the search results
#'
#' @noRd
#' 
#' @importFrom shiny moduleServer reactive
#' @importFrom dplyr mutate if_else arrange select
#' @importFrom DT renderDT
mod_preview_server <- function(id, incorex, r) {
  moduleServer(
    id,
    function(input, output, session) {
      fields <- reactive({ input$dlopts })
      
      output$previewarticles <- renderDT({
        
        if (incorex == "include") {
          # if results filtered (action button) -> display filtered ...
          if (r$filtered_result$is_filtered) {
            tabledata <- r$filtered_result$result$include
          # ... else display search results
          } else {
            tabledata <- r$search_result$result
          }

        } else if (incorex == "exclude") {
          tabledata <- r$filtered_result$result$exclude
        }
        
        # redact scopus, sort, filter columns for fields
        if(nrow(tabledata) > 0) {
          tabledata %>%
            mutate(
              abstract = if_else(source == "Scopus", "[redacted]", abstract)
            ) %>%
            arrange(source) %>%
            select( fields() )

        } else {
          tabledata
        }

      }, options=list(scrollX=TRUE))
    }
  )
}
