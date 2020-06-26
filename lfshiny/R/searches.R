# SEARCH FUNCTIONS

# Query databases for search terms

#' Generates URL for pubmed API
#'
#' @param searchterm text of the query
#' @param startdate from date appeared online (default = 1 year ago today)
#' @param enddate to date appeared online (default = today)
#' @import dplyr
#' @import stringr
#' 
get_url_pm <- function(searchterm, 
                         startdate=as.character(Sys.Date()-365, "%Y/%m/%d"), 
                         enddate=as.character(Sys.Date(), "%Y/%m/%d")) {
  
  baseurl <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?"
  
  term <- searchterm %>% 
    str_replace_all(., "(\")([^\" ]+)( )([^\" ]+)(\")", "%22\\2+\\4%22") %>% 
    str_replace_all(., "(\\))", " \\1") %>%
    paste0(., " ") %>% 
    str_replace_all(., " ", "[tiab] ") %>% 
    str_replace_all(., fixed("AND[tiab]"), "AND") %>% 
    str_replace_all(., fixed("OR[tiab]"), "OR") %>% 
    str_replace_all(., fixed("NOT[tiab]"), "NOT") %>% 
    str_replace_all(., fixed(")[tiab]"), ")") %>% 
    str_squish() %>% 
    str_replace_all(., " ", "+")
  
  searchurl <- paste0(baseurl,
                      "db=pubmed&term=",term,
                      "&datetype=pdat&mindate=",startdate,"&maxdate=",enddate,
                      "&usehistory=y")
  return(searchurl)
}


#' Gets results from pubmed API
#'
#' @param searchurl URL with search query
#' @import dplyr
#' @import purrr
#' @import tidyr
#' @import httr
#' @import rvest
#' @import xml2
#' 
get_results_pm <- function(searchurl) {
  
  # get number of hits and where the results are stored
  
  keyenv <- GET(searchurl) %>% 
    content() %>% 
    xml_nodes("Count, QueryKey, WebEnv") %>% 
    xml_text()
  
   # make vector of pages (at 500 per page)
    
  pages <- seq(1, keyenv[1], 500)
   
   # define function to fetch info from a page
    
  fetchinfo <- function(pagenumber, historyinfo) {
    
    url <- paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&query_key=",
                    historyinfo[2],"&WebEnv=",historyinfo[3],"&retmax=500&retstart=",pagenumber,"&retmode=xml")
      
    articlexml <- GET(url) %>% content() %>% xml_nodes("PubmedArticle")
      
    values <- articlexml  %>% 
      map(function(x) xml_nodes(x,"ArticleTitle, Abstract, ArticleId[IdType=\"doi\"]") %>% xml_text() %>% as_tibble())
      
    fields <- articlexml %>%  
      map(function(x) xml_nodes(x,"ArticleTitle, Abstract, ArticleId[IdType=\"doi\"]") %>% xml_name() %>% as_tibble() %>% rename(field = value))
      
    map2_df(fields, values, function(x,y) bind_cols(x,y) %>% spread(field, value)) %>% 
      select(doi = ArticleId, title = ArticleTitle, abstract = Abstract)
    
    }
  
   # map across all pages
    
  map_df(pages, fetchinfo, historyinfo=keyenv)
  
}


# searchexample <- getsearchurl("aflatoxin AND (aspergillus parasiticus OR peanut)")
# 
# # get number of hits and where the results are stored
# 
# keyenv <- GET(searchexample) %>% 
#   content() %>% 
#   xml_nodes("Count, QueryKey, WebEnv") %>% 
#   xml_text()
# 
# # vector of pages (at 500 per page)
# 
# pages <- seq(1, keyenv[1], 500)
# 
# # map fetch across all pages
# 
# fetchinfo <- function(pagenumber, historyinfo) {
#   url <- paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&query_key=",
#                 historyinfo[2],"&WebEnv=",historyinfo[3],"&retmax=500&retstart=",pagenumber,"&retmode=xml")
#   
#   articlexml <- GET(url) %>% content() %>% xml_nodes("PubmedArticle")
#   
#   values <- articlexml  %>% 
#     map(function(x) xml_nodes(x,"ArticleTitle, Abstract, ArticleId[IdType=\"doi\"]") %>% xml_text() %>% as_tibble())
#   
#   fields <- articlexml %>%  
#     map(function(x) xml_nodes(x,"ArticleTitle, Abstract, ArticleId[IdType=\"doi\"]") %>% xml_name() %>% as_tibble() %>% rename(field = value))
#   
#   map2_df(fields, values, function(x,y) bind_cols(x,y) %>% spread(field, value)) %>% 
#     select(doi = ArticleId, title = ArticleTitle, abstract = Abstract)
# }
# 
# map_df(pages, fetchinfo, historyinfo=keyenv)