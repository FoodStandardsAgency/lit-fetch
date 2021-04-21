#' search UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @import shiny
mod_search_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # --- SEARCH BAR ---
    fluidRow(
      column(
        12,
        textInput(
          ns("searchterm"),
          label = "Enter search term")
      )
    ),

    # --- DATABASES SELECTION ---
    checkboxGroupInput(
      ns("whichdb"),
      label = "Select databases to search",
      choiceNames = c(
        "Pubmed (citation's title, collection title, abstract, other abstract, keywords)",
        "Scopus (title, abstract, keywords)",
        "Springer (title)",
        "Ebsco (title, abstract)"
      ),
      choiceValues = c("Pubmed", "Scopus", "Springer", "Ebsco"),
      selected = c("Pubmed", "Scopus", "Springer", "Ebsco")
    ),
    br(),
    # h1(glue::glue("{ns('searchdate')}-label")),

    # --- DATE TO SEARCH FROM ---
    fluidRow(
      # tags$head(
      #   tags$style(
      #     "#search_ui_1-searchdate-label { font-size:80%; font-family:Times New Roman; margin-bottom: 20px; }"
      #     )
      #   ),
      # tags$head(
      #   tags$style(
      #     "#search_ui_1-searchdate-label { class = 'col-sm-8' }"
      #     )
      #   ),
      # tags$label(
      #   HTML(
      #     "<label for='search_ui_1-searchdate-label'>Find articles online since (To note: Scopus will only filter as far as year)</label>"
      #   )
      # ),
      column(
      12,
      dateInput(
        ns("searchdate"),
        label = "Find articles online since (To note: Scopus will only filter as far as year)",
        value = Sys.Date() - 365,
        min = as.Date("1900-01-01"),
        max = Sys.Date()
        )
      )
    ),
    br(),

    # --- SLIDER NUMBER OF RESULTS ALLOWED ---
    fluidRow(
      column(
        12,
        sliderInput(
          ns("maxhits"),
          "Only return results if there are less than (default = 1000)",
          min = 100,
          max = 5000,
          value = 1000,
          step = 50,
          round = TRUE
        )
      )
    ),
    br(),

    # --- SEARCH ACTION BUTTON ---
    actionButton(
      inputId = ns("searchnow"),
      label = "Search"
    ),
    
    # --- INFO - ERROR ---
    textOutput(ns("nrecords")),
    br(),
    p(
      "If the above search returned an error please check that you have closed all your brackets.
      Some special characters (e.g. &) may also cause errors."
    )
  ) # end tagList
}

#' search Server Function
#' 
#' @param r a `reactiveValues()` list containing the search results
#'
#' @noRd
#' 
#' @importFrom shiny moduleServer reactive observeEvent validate need renderText
#' @importFrom stringr str_count
#' @importFrom tibble tibble
#' @importFrom dplyr anti_join bind_rows
mod_search_server <- function(id, r) {
  moduleServer(
    id,
    function(input, output, session) {

      # execute on click search button
      observeEvent(input$searchnow, {

        validate(
          need(
            input$searchterm != "",
            message = FALSE
          )
        )

        # check that number of opening parenthesis match number of closing ones
        bracket_match_check <-
          str_count(input$searchterm, "\\(") == str_count(input$searchterm, "\\)")
        
        
        # if brackets do not match, return empty result
        if (bracket_match_check == FALSE) {
          r$search_result <- list(
            search_query = input$searchterm,
            date_from = input$searchdate,
            # date_to = Sys.Date() - 1,
            result = tibble(doi = character(0)),
            totalhits = -1
          )

        } else {
          # do an initial 'number of hits' search
          totalhits <- gettotal(
            searchterm = input$searchterm,
            datefrom = input$searchdate,
            across = input$whichdb
          )
          
          # case : more hits than allowed by user
          if (totalhits > input$maxhits) {
            r$search_result <- list(
              search_query = input$searchterm,
              date_from = input$searchdate,
              # date_to = Sys.Date() - 1,
              result = tibble(doi = character(0)),
              totalhits = totalhits
            )

          # case : less hits than allowed by user
          } else {
            # --- PUBMED ---
            if ("Pubmed" %in% input$whichdb) {
              pm <- get_pm(
                searchterm = input$searchterm,
                datefrom = input$searchdate
              )
            } else {
              pm <- tibble(doi = character(0))
            }
            
            # --- SCOPUS ---
            if ("Scopus" %in% input$whichdb) {
              scopus <- get_scopus(
                input$searchterm,
                datefrom = input$searchdate
              )
            } else {
              scopus <- tibble(doi = character(0))
            }
            
            # --- SPRINGER ---
            if ("Springer" %in% input$whichdb) {
              spring <- get_springer(
                input$searchterm,
                datefrom = input$searchdate
              )
            } else {
              spring <- tibble(doi = character(0))
            }
            
            # --- EBSCO ---
            if ("Ebsco" %in% input$whichdb) {
              ebsco <- get_ebsco(
                input$searchterm,
                datefrom = input$searchdate
              )
            } else {
              ebsco <- tibble(doi = character(0))
            }

            # anti-join by DOI to remove duplicates between databases
            result <- spring %>%
              anti_join(scopus, by = "doi") %>%
              bind_rows(scopus) %>%
              anti_join(pm, by = "doi") %>%
              bind_rows(pm)

            # FIX doi is NA for EBSCO
            ebsco_na <- ebsco %>% filter(is.na(doi))
            ebsco <- ebsco %>% filter(!is.na(doi))
            
            # Add EBSCO doi is NA back to final result
            result <- result %>%
              anti_join(ebsco, by = "doi") %>%
              bind_rows(ebsco) %>%
              bind_rows(ebsco_na)
            
            r$search_result <- list(
              search_query = input$searchterm,
              date_from = input$searchdate,
              # date_to = Sys.Date() - 1,
              result = result,
              totalhits = nrow(result)
            )

          } # end less hits than allowed by user
        } # end if bracket check
      }) # observeEvent
      
      
      # --- MESSAGE - ERROR ---
      output$nrecords <- renderText({
        if (r$search_result$totalhits > input$maxhits) {
          paste(
            "Your search returned",
            r$search_result$totalhits,
            "articles. You can adjust the above slider to allow in more results or 
            try a more specific search term or a smaller time window."
          )

        } else if (r$search_result$totalhits == 0) {
          paste("Your search did not return any results.")

        } else if (r$search_result$totalhits == -1) {
          paste("Check your brackets, it looks like you haven't an equal number of '(' and ')'.")
        
        # case: initial state of r
        } else if (r$search_result$totalhits == -2) {
          paste("")

        } else {
          paste(
            "Your search returned",
            r$search_result$totalhits,
            "articles. Refine your search or continue to additional filters below."
          )
        }
      }) # end renderText output$nrecords

    } # end function
  ) # end moduleServer
} # end mod_search_server
