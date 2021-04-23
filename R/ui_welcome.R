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
        "The lit fetch app is a tool that performs key word searches on the 
        following services:"
      ),
      tags$ul(
        tags$li("Ebsco (Food Science Source)"),
        tags$li("Pubmed"),
        tags$li("Scopus"),
        tags$li("Springer")
      ),
      p(
        "Lit fetch provides information about the returned publications (including a 
        list of dois, titles and abstracts). It is designed to be used at the 
        start of a literature review to create an initial list of useful 
        publications. These can then be manually checked for suitability."
      ),
      
      h3("Search"),
      p(
        "Search as you would normally do on classic search tools, by building your
        search queries with AND, OR, NOT, brackets, quote marks and wildcards (*)."
      ),
      p(
        "Searches are implemented according to the online search interfaces of ",
        a(href = "https://connect.ebsco.com/s/article/EBSCOhost-API?language=en_US", "[Ebsco]"),
        a(href = "https://www.ncbi.nlm.nih.gov/books/NBK3827/#pubmedhelp.Advanced_Search", "[Pubmed]"),
        a(href = "https://service.elsevier.com/app/answers/detail/a_id/11213/supporthub/scopus/#tips", "[Scopus]"),
        a(href = "https://link.springer.com/searchhelp", "[Springer]"),
        ".
        Publications will be filtered up to but not including the date
        that the search is being run
        ."
      ),
      p(
        "You can select the date from which you want to see articles. Dates are 
        filtered in the following way:"
      ),
      tags$ul(
        tags$li(
          "Ebsco searches by publication date."
        ),
        tags$li(
          "Pubmed searches by publication date, however the date it displays in 
          the tool is the electronic publication date."
        ),
        tags$li(
          "Scopus searches automatically convert dates to the year of publication
          (this is the most fine-grained search available on this service)."
        ),
        tags$li(
          "Springer searches by when an item first appeared online."
        )
      ),
      
      h4("Search tips:"),
      tags$ul(
        tags$li(
          "To search for multiple terms: ",
          tags$code("botulism AND sheep"),
          "will return everything containing the word ", em("botulism"),
          "if it also contains the word ", em("sheep.")
        ),
        tags$li(
          "Combining multiple conditions with brackets: ",
          tags$code("botulism AND (sheep OR cow)"), "will return anything
          containing ", em("botulism"), "but only if it also contains the word ",
          em("sheep"), "or the word ", em("cow.")
        ),
                                
        tags$li(
          "Using quotation marks: ", tags$code("\"Clostridium botulinum\""),
          "will return articles containing that exact term."),
        tags$li(
          "Using wildcards: ", tags$code("botul*"), "will return anything 
          containing ", em("botulism"), ",", em("botulinium"), "etc.",
          helpText(
            strong("NOTE:"), "For Pubmed, the wildcard character will expand to 
            match any set of characters up to a limit of 600 unique expansions.
            This means that poorly determined terms, for example",
            tags$code("cat*"), "will yield incomplete results."
          )
        ),
        tags$li(
          "Note that for Scopus searches, any search term with", 
          tags$code("NOT"), "is automatically converted to", tags$code("AND NOT"),
          "."
        )
      ),
      
      h4("Volume of publications"),
      p(
        "The volume of publications returned may differ to the volume returned
        by the equivalent website search for one of the following reasons:"
      ),
      tags$ul(
        tags$li(
          "We have removed any instances where the same publication was returned
          more than once (by the different services most notably)."
        ),
        tags$li(
          "Some website searches may return publications with a future
          publication date."
        ),
        tags$li(
          "For Pubmed, as aforementioned, the wildcard character will expand to
          match any set of characters up to a limit of 600 unique expansions."
        ),
        tags$li(
          "For a small number of search terms, the Pubmed website will return
          publications containing a slight variation of the search term. As an
          example, 'h2o2' captures titles and abstracts with 'h(2)o(2)'. This
          tool will not capture these variations."
        )
      ),
      
      h4("Preview"),
      p(
        "You can preview the results of your search. The 'included' tab shows
        anything returned by the search that has not been excluded by any
        further filtering. Anything that has been excluded at the filter stage
        will be in the ‘excluded’ tab."
      ),
      p(
        helpText(
          strong("NOTE:"), "where month and day of publication are not provided
          by the service, 01 is used as a default. Similarly, where year of 
          publication is not provided 1990 is used as a default. This means that
          all publications that only provide the year of publication are given
          the publication date", tags$code("01/01/year"), "in our output, and
          those that have no details are given the date",
          tags$code("01/01/1990"), "."
        )
      ),
      
      h3("Filter"),
      p("
        The filter section lets you choose terms that you want to include or 
        exclude from your returned collection of articles."
      ),
      p(
        helpText(
          strong("NOTE:"), "To use the filter section, please click on the 
          header to expand it."  
        )
      ),
      p(
        "The initial search may return articles that do not contain the search
        term(s) in the title or abstract (e.g. Pubmed may have returned an 
        article that had the search term listed as a keyword). You can then
        filter these out at this stage."
      ),
      p(
        helpText(
          strong("NOTE:"), "All filter terms are treated as wildcards unless
          they are enclosed in quotes."  
        )
      ),
      p(
        "You can also filter by publication type (currently: journal article,
        journal review, or other)."
      ),
      p(
        "The English language filter only applies to articles returned from 
        Ebsco and Pubmed, so foreign language items may still appear in the 
        Scopus and Springer results."
      ),
      
      h3("Download"),
      p(
        "You can download an excel spreadsheet with your search term, filters,
        included and excluded articles (with all fields). You can refer back to
        this spreadsheet in the future as a document of what filters were used."
      ),

      h3("Help and feedback"),
      p(
        "If there are any issues with the tool or you have feedback please
        contact a member of the data science team."
      )
    )
  )
}
