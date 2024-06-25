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
    
    tags$head(
      tags$style(HTML("
      .shiny-output-error-validation {
        color: red;
        font-weight: bold;
      }
      "))
    ),
    verbatimTextOutput(ns("error")),
    
    # --- DATABASES SELECTION ---
    checkboxGroupInput(
      ns("whichdb"),
      label = "Select databases to search",
      choiceNames = c(
        "Pubmed (citation's title, collection title, abstract, other abstract, keywords)",
        "Scopus (title, abstract, keywords)",
        "Springer (title)",
        "Ebsco - Food Science Resource (title, abstract)"
      ),
      choiceValues = c("Pubmed", "Scopus", "Springer", "Ebsco"),
      selected = c("Pubmed", "Scopus", "Springer", "Ebsco")
    ),
    br(),

    # --- DATE TO SEARCH FROM ---
    fluidRow(
      column(
      12,
      dateInput(
        ns("searchdate_from"),
        label = "Find articles online since:",
        value = Sys.Date() - 365,
        min = as.Date("1900-01-01"),
        max = Sys.Date()
        )
      )
    ),
    
    # --- DATE TO SEARCH TO ---
    fluidRow(
      column(
        12,
        dateInput(
          ns("searchdate_to"),
          label = "... up to",
          value = Sys.Date() - 1,
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
    
    # --- INFO ---
    htmlOutput(ns("nrecords")),
    br()
  ) # end tagList
}


#' search Server Function
#' 
#' @param r a `reactiveValues()` list containing the search results
#'
#' @noRd
#' 
#' @importFrom shiny moduleServer reactive observeEvent validate need renderText
#' @importFrom stringr str_count str_detect
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

        # Reset value on each new search so preview updates on new search
        # that follows a filter
        r$filtered_result = list(
          is_filtered = FALSE,
          include_terms = "",
          exclude_terms = "",
          include_type = "",
          language = "",
          result = list(
            include = tibble(doi = character(0)),
            exclude = tibble(doi = character(0))
          )
        )

        # check that number of opening parenthesis match number of closing ones
        bracket_match_check <-
          str_count(input$searchterm, "\\(") == str_count(input$searchterm, "\\)")
        
        double_quotation_match_check <-
          str_count(input$searchterm, "\"") %% 2 == 0
        
        # check special characters
        contains_special_char <- str_detect(input$searchterm, "[&$%\\!\\^]")
        
        # render error messages
        output$error <- renderText({
          validate(
            need(
              bracket_match_check,
              message = "Check your brackets, it looks like you haven't an equal number of '(' and ')'."
            )
          )
          
          validate(
            need(
              double_quotation_match_check,
              message = "Check your quotations marks, it looks like you do not have an even number of double quotation marks."
            )
          )
          
          validate(
            need(
              !contains_special_char,
              message = "Your search contains special characters (&, $, !, ^) which may cause errors."
            )
          )
        })
        
        
        # if brackets do not match, return empty result
        if (
          bracket_match_check == FALSE
          | double_quotation_match_check == FALSE
          | contains_special_char
        ) {
          r$search_result <- list(
            search_query = input$searchterm,
            date_from = input$searchdate_from,
            date_to = input$searchdate_to,
            result = tibble(doi = character(0)),
            totalhits = -1
          )

        } else {
          # do an initial 'number of hits' search
          totalhits <- get_total_hits(
            searchterm = input$searchterm,
            datefrom = input$searchdate_from,
            dateto = input$searchdate_to,
            across = input$whichdb
          )
          
          # case : more hits than allowed by user
          if (totalhits > input$maxhits) {
            r$search_result <- list(
              search_query = input$searchterm,
              date_from = input$searchdate_from,
              date_to = input$searchdate_to,
              result = tibble(doi = character(0)),
              totalhits = totalhits
            )

          # case : less hits than allowed by user
          } else {
            # --- PUBMED ---
            if ("Pubmed" %in% input$whichdb) {
              pm <- get_pm(
                searchterm = input$searchterm,
                datefrom = input$searchdate_from,
                dateto = input$searchdate_to
              )
            } else {
              pm <- tibble(doi = character(0))
            }
            
            # --- SCOPUS ---
            if ("Scopus" %in% input$whichdb) {
              scopus <- get_scopus(
                input$searchterm,
                datefrom = input$searchdate_from,
                dateto = input$searchdate_to
              )
            } else {
              scopus <- tibble(doi = character(0))
            }
            
            # --- SPRINGER ---
            if ("Springer" %in% input$whichdb) {
              spring <- get_springer(
                input$searchterm,
                datefrom = input$searchdate_from,
                dateto = input$searchdate_to
              )
            } else {
              spring <- tibble(doi = character(0))
            }
            
            # --- EBSCO ---
            if ("Ebsco" %in% input$whichdb) {
              ebsco <- get_ebsco(
                input$searchterm,
                datefrom = input$searchdate_from,
                dateto = input$searchdate_to
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
              date_from = input$searchdate_from,
              date_to = input$searchdate_to,
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
            "<font color=\"#FF0000\"><b>",
            "Your search returned",
            r$search_result$totalhits,
            "articles (including duplicates) which is over the above slider 
            threshold. You can adjust the above slider to allow in more results 
            or try a more specific search term or a smaller time window.",
            "</b></font>"
          )

        } else if (r$search_result$totalhits == 0) {
          paste("Your search did not return any results.")

        # case: initial state of r
        } else if (r$search_result$totalhits == -2) {
          paste("")

        } else if (
            r$search_result$totalhits > 0
            & r$search_result$totalhits <= input$maxhits
          ) {
          paste(
            "Your search returned",
            r$search_result$totalhits,
            "unique articles. Refine your search or continue to additional 
            filters below."
          )
        }
      }) # end renderText output$nrecords
      
    } # end function
  ) # end moduleServer
} # end mod_search_server
