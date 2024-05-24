#' Documentation page UI
#'
#' @import shiny
#' @import shinydashboard
#' @noRd
ui_documentation <- function() {
  tabItem(
    tabName = "doc",
    
    h1("Documentation"),
    wellPanel(
      h2("Sources"),
      p(
        "The Ebsco search is implemented using the ",
        a(href = "https://connect.ebsco.com/s/article/EBSCOhost-API?language=en_US", "Ebsco API"),
        "."
      ),
      p(
        "The Pubmed search is implemented using the ",
        a(href = "https://www.ncbi.nlm.nih.gov/books/NBK25501/", "Entrez Programming Utilities"),
        "."
      ),
      p(
        "The Scopus search is implemented using the Elsevier ",
        a(href = "https://dev.elsevier.com/documentation/ScopusSearchAPI.wadl", "Scopus Search API"),
        "."
      ),
      p(
        "The Springer search is implemented using the ",
        a(href = "https://dev.springernature.com/", "Springer Nature Meta API"),
        "."
      ),
      
      h2("Fields in the returned data"),
      p(
        strong("DOI"), ": Article identifier. No article without a DOI is 
        included and it is used as the basis for removing duplicates."
      ),
      p(
        strong("Title"), ": The title of the article (or chapter or paper)."
      ),
      p(
        strong("Abstract"), ": The article abstract where this has been supplied 
        by the API."
        ),
      p(
        strong("Publication Date"), ": Publication date of the article (online or 
        paper, whichever was first).For journals that publish as e.g. 
        “April 2019”, the day has been set to the first of the month."
      ),
      p(
        strong("Publication type"), ": Journal articles are any article or 
        research paper published in a journal. Reviews are review articles 
        published in a journal. Anything else (including books and book chapters)
        is classified as 'other'."
      ),
      p(
        strong("Journal"), ": journal in which an article is published (not 
        applicable to books or chapters)."
      ),
      p(
        strong("Lang"), ": Language of the item (only available for items from 
        Pubmed)."
      ),
      p(
        strong("URL"), ": Link that will take you to the article page on the 
        publisher's website."
      ),
      p(
        strong("Source"), ": Which database the item has come from."
      ),
      p(
        strong("Scopus link"), ": Where item is from Scopus, link to 
        Scopus record."
      ),
      p(
        "Elsevier have specified in the Scopus API ",
        a(href = "https://dev.elsevier.com/federated_search.html", "documentation"),
        " that when the API is used for federated search tools: 'the 
        application can only show the core bibliographic data for each search 
        result; abstracts and references are off-limits'. We are therefore not 
        displaying any Scopus abstracts within the tool. However Elsevier have 
        confirmed that abstracts can be displayed in the tools downloads."
      )
    )
  )
}

