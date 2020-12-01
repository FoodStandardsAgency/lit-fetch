#' The application User-Interface
#' 
#' @param request Internal parameter for `{shiny}`. 
#'     DO NOT REMOVE.
#' @import shiny
#' @import shinydashboard
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # List the first level UI elements here 
    dashboardPage(skin = "green",
                  dashboardHeader(title = "Lit fetch"),
                  dashboardSidebar(
                    sidebarMenu(menuItem("Welcome", tabName = "welcome", icon = icon("home")), # available icons at https://fontawesome.com/icons?d=gallery
                                menuItem("Search and download", tabName = "search", icon = icon("search")),
                                menuItem("Documentation", tabName = "doc", icon = icon("book-open"))
                    )
                  ),
                  dashboardBody(
                    
                    # to include google analytics, save the tracking script in 
                    # the working directory as google-analytics.html, and 
                    # uncomment the code below
                    
                    # tags$head(includeHTML(("google-analytics.html"))),
                    
                    tabItems(
                      
                      # UI for page 1
                      
                      tabItem(tabName = "welcome",     
                              h3("Welcome"),
                              wellPanel(
                                p("Welcome to the lit fetch app! This tool performs key word searches on Pubmed and Scopus and 
                                provides information about the returned publications (including a list of dois, titles and abstracts).
                                  It is designed to be used at the start of a literature review to create an initial list of useful publications. 
                                  These can then be manually checked for suitability.
                                  Publications from Springer can also be searched by title." ),
                                p(strong("Search")),
                                p("Search as you would normally, building your 
                                  search term with AND, OR, NOT, brackets, quote marks 
                                  and wildcards (*). Searches are implemented as they would be in the online 
                                  search interfaces for the databases, 
                                  for details see: ", 
                                  a(href="https://link.springer.com/searchhelp", "[Springer]"),
                                  a(href = "https://www.ncbi.nlm.nih.gov/books/NBK3827/#pubmedhelp.Advanced_Search", "[Pubmed]"),
                                  a(href = "https://service.elsevier.com/app/answers/detail/a_id/11213/supporthub/scopus/#tips", "[Scopus]"),
                                  ". Publications will be filtered up to but not including the date that the search is being run. 
                                  You can select the date from which you want 
                                  to see articles. Dates are filtered in the following way:"),
                                tags$ul(
                                  tags$li("Scopus searches automatically 
                                  convert dates to the year of publication (this is 
                                  the most fine-grained search that is possible)"),
                                  tags$li("Springer searches by when an item first appeared online"),
                                  tags$li("Pubmed searches by publication date, however the date it displays in the in the tool
                                          is the electronic publication date")),
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
                                tags$li("using wildcards: botul* will return anything containing botulism, botulinium, etc. ", 
                                        strong("TO NOTE:"), " For Pubmed, the wildcard character will expand to match any set of characters up to 
                                        a limit of 600 unique expansions. This means that poorly determined terms, for example cat*, 
                                        will give incomplete results."),
                                tags$li("Note that any search term with NOT is automatically converted to AND NOT for Scopus searches")),
                                p("The volume of publications returned may differ to the volume returned by the equivalent 
                                  website search for one of the following reasons:"),
                                tags$ul(
                                  tags$li("we have removed any instances where the same publication was returned more than once"),
                                  tags$li("some website searches may return publications with a future publication date"),
                                  tags$li("For Pubmed, the wildcard character will expand to match any set of characters up to a limit of 600 unique expansions.
                                          This means that poorly determined terms, for example cat*, will give incomplete results."),
                                  tags$li("For a small number of search terms the Pubmed website will return publications 
                                          containing a slight variation of the search term 
                                          (i.e. 'h2o2' captures titles and abstracts with 'h(2)o(2)'). This tool will not.")),
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
                      ),
                      
                      # UI for page 2
                      
                      tabItem(tabName = "search",
                              h3("Step 1: Search"),
                              wellPanel(
                                
                                # add module UI calls below

                                mod_search_ui("search_ui_1"),
                              ),
                              h3("Step 2: Filter"),
                              wellPanel(

                                mod_filter_ui("filter_ui_1")
                              ),
                              h3("Step 3: Preview"),
                              wellPanel(
                                p("To preview unfiltered search results, leave filter fields blank 
                                  and hit 'Filter'"),
                                tabsetPanel(
                                  tabPanel("Included articles", mod_preview_ui("preview_ui_1")),
                                  tabPanel("Excluded articles", mod_preview_ui("preview_ui_2"))
                                )
                              ),
                              h3("Step 4: Download"),
                              wellPanel(
                                
                                mod_download_ui("download_ui_1")
                                
                              )
                                
                              ),
                      
                      # UI for page 3
                      
                      tabItem(tabName = "doc",
                              h3("Documentation"), 
                              wellPanel(
                                p(strong("Sources")),
                                p("The Pubmed search is implemented using the ",
                                  a(href = "https://www.ncbi.nlm.nih.gov/books/NBK25501/", "Entrez Programming Utilities")),
                                p("The Scopus search is implemented using the Elsevier ",
                                  a(href = "https://dev.elsevier.com/documentation/ScopusSearchAPI.wadl", "Scopus Search API")),
                                p("The Springer search is implemented using the ",
                                  a(href = "https://dev.springernature.com/", "Springer Nature Meta API")),
                                p(strong("Fields in the returned data")),
                                p("DOI: Article identifier. No article without a DOI is included 
                                  and it is used as the basis for removing duplicates"),
                                p("Title: The title of the article (or chapter or paper)"),
                                p("Abstract: The article abstract where this has been supplied by the API"),
                                p("Publication Date: Publication date of the article (online or paper, 
                                whichever was first).For journals that publish as 
                                e.g. “April 2019”, the day has been set to the first of the month"),
                                p("Publication type: Journal articles are any article or research paper 
                                  published in a journal. Reviews are review articles published 
                                  in a journal. Anything else (including books and book chapters) 
                                  is classified as 'other'"),
                                p("Journal: journal in which an article is published 
                                  (not applicable to books or chapters)"),
                                p("Lang: Language of the item (only available for items from Pubmed)"),
                                p("URL: Link that will take you to the article page on the publisher's website"),
                                p("Source: Which database the item has come from "),
                                p("Scopus link: Where item is from Scopus, link to Scopus record"),
                                p("Elsevier have specified in the Scopus API ",
                                  a(href = "https://dev.elsevier.com/federated_search.html", "documentation"), 
                                  " that when the API is used for federated search tools: 
                                  'the application can only show the core bibliographic data for each search result; 
                                  abstracts and references are off-limits'. We are therefore not displaying any Scopus abstracts 
                                  within the tool. However Elsevier have confirmed that abstracts can be displayed in the tools
                                  downloads")
                              
                              )
                      )
                      
                    ) #end of tab items
                  ) #end of dashboard body
    ) #end of dashboard page
  ) #end of tag list
}

#' Add external Resources to the Application
#' 
#' This function is internally used to add external 
#' resources inside the Shiny application. 
#' 
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function(){
  
  add_resource_path(
    'www', app_sys('app/www')
  )
  
  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys('app/www'),
      app_title = 'Lit Fetch'
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert() 
  )
}