#' search UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom shinycssloaders withSpinner
mod_search_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fluidRow(column(
      12,
      textInput(ns("searchterm"), label = "Enter search term")
      )
    ),
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
    fluidRow(column(
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
    )),
    br(),
    actionButton(
      ns("searchnow"),
      "Search"
    ),
    withSpinner(
      textOutput(ns("nrow")),
      type = 4,
      color = "#006F51",
      size = 0.3
    ),
    textOutput(ns("springerkey")),
    br(),
    p(
      "If the above search returned an error please check that you have closed all your brackets.
      Some special characters (i.e. &) may also cause errors."
    )
  )
}

#' search Server Function
#'
#' @noRd
#' 
#' @importFrom shiny eventReactive
#' @importFrom stringr str_count
#' @importFrom tibble tibble
#' @importFrom dplyr anti_join bind_rows
mod_search_server <- function(input, output, session) {
  # ns <- session$ns

  returned <- eventReactive(input$searchnow, {
    
    # check that number of opening parenthesis match number of closing ones
    bracket_match_check <-
      str_count(input$searchterm, "\\(") == str_count(input$searchterm, "\\)")

    if (bracket_match_check == FALSE) {
      totalhits <- -1
      result <- tibble(doi = character(0))
      searchresult <- list(input$searchterm, result, totalhits)

    } else {
      # do an initial 'number of hits' search
      totalhits <- gettotal(
        searchterm = input$searchterm,
        datefrom = input$searchdate,
        across = input$whichdb
      )

      if (totalhits > input$maxhits) {
        result <- tibble(doi = character(0))
        searchresult <- list(input$searchterm, result, totalhits)
        
      } else {
        # get pubmed articles for the given search term
        if ("Pubmed" %in% input$whichdb) {
          pm <-
            get_pm(
              searchterm = input$searchterm,
              datefrom = input$searchdate
            )
        } else {
          pm <- tibble(doi = character(0))
        }

        # get scopus articles for the given search term
        if ("Scopus" %in% input$whichdb) {
          scopus <- get_scopus(input$searchterm, datefrom = input$searchdate)
        } else {
          scopus <- tibble(doi = character(0))
        }

        # get springer articles for the given search term
        if ("Springer" %in% input$whichdb) {
          spring <-
            get_springer(input$searchterm, datefrom = input$searchdate)
        } else {
          spring <- tibble(doi = character(0))
        }
        
        if ("Ebsco" %in% input$whichdb) {
          ebsco <-
            get_ebsco(input$searchterm, datefrom = input$searchdate)
        } else {
          ebsco <- tibble(doi = character(0))
        }


        # anti-join by DOI to remove duplicates
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
          
        # get abstracts that will be hidden (not currently implemented)

        # if(nrow(scopus) > 0) {
        #
        #   dois <- result %>% filter(source == "Scopus") %>% pull(doi)
        #
        #   extraab <- map_df(dois, slowly(getab, rate = rate_delay(pause = .15)))
        #
        # } else {
        #
        #   extraab <- tibble(doi = character(0), altab = character(0))
        #
        # }
        #
        # result <- result %>%
        #   left_join(extraab, by = "doi")

        totalhits <- nrow(result)

        searchresult <-
          list(input$searchterm, result, totalhits, input$searchdate)
      }
    }
    
    return(searchresult)
  })

  output$nrow <- renderText({
    if (returned()[[3]] > input$maxhits) {
      paste(
        "Woah your search returned",
        returned()[[3]],
        "articles. You can adjust the above slider
            to allow in more results or try a more specific
            search term or a smaller time window."
      )
    } else if (returned()[[3]] == 0) {
      paste("Your search did not return any results.")
    } else if (returned()[[3]] == -1) {
      paste("Check your brackets, it looks like you haven't an equal number of '(' and ')'.")
    } else {
      paste(
        "Your search returned",
        returned()[[3]],
        "articles. Refine your
            search or continue to additional filters below."
      )
    }
  })

  return(returned)
}

## To be copied in the UI
# mod_search_ui("search_ui_1")

## To be copied in the server
# callModule(mod_search_server, "search_ui_1")
