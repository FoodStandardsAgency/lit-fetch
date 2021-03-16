#' Welcome page UI
#'
#' @import shiny
#' @import shinydashboard
#' @noRd
ui_welcome <- function() {
  tabItem(
    tabName = "welcome",
    h3("Welcome"),
    wellPanel(
      p(
        "Welcome to the lit fetch app! This tool performs key word 
                searches on Pubmed and Scopus and provides information about the
                returned publications (including a list of dois, titles and
                abstracts).
                It is designed to be used at the start of a literature review to
                create an initial list of useful publications.
                These can then be manually checked for suitability.
                Publications from Springer can also be searched by title."
      ),
      p(strong("Search")),
      p(
        "Search as you would normally, building your search term with
                AND, OR, NOT, brackets, quote marks and wildcards (*). Searches
                are implemented as they would be in the online search interfaces
                for the databases, for details see: ",
        a(href = "https://link.springer.com/searchhelp", "[Springer]"),
        a(href = "https://www.ncbi.nlm.nih.gov/books/NBK3827/#pubmedhelp.Advanced_Search", "[Pubmed]"),
        a(href = "https://service.elsevier.com/app/answers/detail/a_id/11213/supporthub/scopus/#tips", "[Scopus]"),
        ".
                Publications will be filtered up to but not including the date
                that the search is being run. You can select the date from which
                you want to see articles. Dates are filtered in the following way:"
      ),
      tags$ul(
        tags$li(
          "Scopus searches automatically convert dates to the year
                  of publication (this is the most fine-grained search that is
                  possible)"
        ),
        tags$li("Springer searches by when an item first appeared online"),
        tags$li("
                  Pubmed searches by publication date, however the date it
                  displays in the in the tool is the electronic publication date")
      ),
      p("Search tips:"),
      tags$ul(
        tags$li("to search for multiple terms: botulism AND sheep will 
                                return everything containing the word botulism if it 
                                also contains the word sheep"),
        tags$li("combining multiple conditions with brackets: botulism 
                                AND (sheep OR cow) will return anything containing 
                                botulism but only if it also contains the word sheep or the word cow"),
        tags$li("using quote marks: \"Clostridium botulinum\" will return 
                                articles containing that exact term"),
        tags$li(
          "using wildcards: botul* will return anything containing botulism, botulinium, etc. ",
          strong("TO NOTE:"), " For Pubmed, the wildcard character will expand to match any set of characters up to 
                                        a limit of 600 unique expansions. This means that poorly determined terms, for example cat*, 
                                        will give incomplete results."
        ),
        tags$li("Note that any search term with NOT is automatically converted to AND NOT for Scopus searches")
      ),
      p("The volume of publications returned may differ to the volume returned by the equivalent 
                                  website search for one of the following reasons:"),
      tags$ul(
        tags$li("we have removed any instances where the same publication was returned more than once"),
        tags$li("some website searches may return publications with a future publication date"),
        tags$li("For Pubmed, the wildcard character will expand to match any set of characters up to a limit of 600 unique expansions.
                                          This means that poorly determined terms, for example cat*, will give incomplete results."),
        tags$li("For a small number of search terms the Pubmed website will return publications 
                                          containing a slight variation of the search term 
                                          (i.e. 'h2o2' captures titles and abstracts with 'h(2)o(2)'). This tool will not.")
      ),
      br(),
      p(strong("Filter")),
      p("This section lets you filter for terms that you want 
                                  to include or exclude in your collection of articles."),
      p("The initial search may return articles that do not 
                                  contain the search term in the title or abstract 
                                  (for example Pubmed may have returned an article that had the search term listed as a keyword)
                                  - so you can filter these out at this 
                                  stage, or perform additional filtering."),
      p("All filter terms are treated as wildcards unless 
                                  they are enclosed in quotes"),
      p("You can also filter by publication type (currently 
                                  journal article, journal review, or other)."),
      p("The English language filter only applies to articles 
                                  returned from Pubmed, so foreign language items may 
                                  still appear in the Scopus and Springer results."),
      br(),
      p(strong("Preview")),
      p("You can preview the results of your search. The 'included' 
                                tab shows anything returned by the search that has not been 
                                excluded by any further filtering. Anything that has been excluded 
                                at the filter stage will be in the ‘excluded’ tab."),
      br(),
      p(strong("Download")),
      p("This will download an excel spreadsheet with your search 
                                  term, filters, included and excluded articles (with all fields).
                                  You can use refer to this spreadsheet in the future as a document of 
                                  what filters were used."),
      p("TO NOTE: where month and day of publication are not provided 01 is used as a default.
                                  Where year of publication is not provided 1990 is used as a default.
                                  This means that all publications that only provide the year of publication are given 
                                  the publication date 01/01/year in our output and those that have no details are
                                  given the date 01/01/1990"),
      br(),
      p("If there are any issues with the tool or you have feedback please contact a member of the data science team")
    )
  )
}
