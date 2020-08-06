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
                                p("Welcome to the lit fetch app!"),
                                p(strong("Search")),
                                p("Search as you would normally, building your 
                                  search term with AND, OR, NOT, brackets, quote marks 
                                  and wildcards (*)"),
                                p("Searches are implemented as they would be in the online 
                                  search interfaces for the databases, 
                                  for details see: ", 
                                  a(href="https://link.springer.com/searchhelp", "[Springer]"),
                                  a(href = "https://www.ncbi.nlm.nih.gov/books/NBK3827/#pubmedhelp.Advanced_Search", "[Pubmed]"),
                                  a(href = "https://service.elsevier.com/app/answers/detail/a_id/11213/supporthub/scopus/#tips", "[Scopus]")),
                                p("Note that any search term with NOT is automatically converted to AND NOT for Scopus searches"),
                                p("Search tips:"),
                                tags$ul("to search for multiple terms: botulism AND sheep will 
                                return everything containing the word botulism if it 
                                also contains the word sheep"),
                                tags$ul("combining multiple conditions with brackets: botulism 
                                AND (sheep OR cow) will return anything containing 
                                botulism but only if it also contains the word sheep or the word cow"),
                                tags$ul("using quote marks: \"Clostridium botulinum\" will return 
                                articles containing that exact term"),
                                tags$ul("using wildcards: botul* will return anything containing botulism, botulinium, etc."),
                                p("You can also select the date from which you want 
                                  to see articles. Note that Scopus searches automatically 
                                  convert dates to the year of publication (this is 
                                  the most fine-grained search that is possible), and
                                  Springer searches by when an item first appeared online."),
                                p(strong("Filter")),
                                p("This section lets you filter for terms that you want 
                                  to include or exclude in your collection of articles."),
                                p("The initial search may return articles that do not 
                                  contain the search term in the title or abstract 
                                  (this is due to how each database provider chooses to 
                                  implement searches) - so you can filter these out at this 
                                  stage, or perform additional filtering."),
                                p("All filter terms are treated as wildcards unless 
                                  they are enclosed in quotes"),
                                p("You can also filter by publication type (currently 
                                  journal article, journal review, or other)."),
                                p("The English language filter only applies to articles 
                                  returned from Pubmed, so foreign language items may 
                                  still appear in the Scopus and Springer results."),
                                p(strong("Preview")),
                                p("You can preview the results of your search. The 'included' 
                                tab shows anything returned by the search that has not been 
                                excluded by any further filtering. Anything that has been excluded 
                                at the filter stage will be in the ‘excluded’ tab."),
                                p(strong("Download")),
                                p("This will download an excel spreadsheet with your search 
                                  term, filters, included and excluded articles (with all fields)")
                                
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
                                p("Scopus link: Where item is from Scopus, link to Scopus record")
                              
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