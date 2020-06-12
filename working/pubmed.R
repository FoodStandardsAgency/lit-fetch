
# pubmed API

library(httr)
library(rvest)
library(dplyr)
library(tidyr)
library(purrr)
library(stringr)

# generate query string
# term in title/abstract (actually searches keywords as well so may not appear in title/abstract - could insist that it does) + date range
# could add additional options - publication type? (full list here https://www.ncbi.nlm.nih.gov/books/NBK3827/table/pubmedhelp.T.publication_types/)
# sort is automatically by date, only other option is alphabetical I think (relevancy not available through API)

# (this code gives all searchable fields in pubmed)

GET("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/einfo.fcgi?db=pubmed") %>%  
  content() %>% 
  xml_nodes("Field") %>% 
  map_df(function(x) xml_nodes(x, "Name, FullName, Description") %>% 
        xml_text() %>% 
        as_tibble() %>% 
        mutate(key = c("Abbr", "Name", "Description")) %>% 
        spread(key, value))
  

# generate search URL from a query string (boolean, with brackets if required), start date and end date (default today and minus 1 year)


getsearchurl <- function(tiab, 
                         startdate=as.character(Sys.Date()-365, "%Y/%m/%d"), 
                         enddate=as.character(Sys.Date(), "%Y/%m/%d")) {
  
  baseurl <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?"
  
  term <- str_replace_all(tiab, "(\\))", " \\1") %>%
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

searchexample <- getsearchurl("aflatoxin AND (aspergillus OR peanut)")

# get number of hits and where the results are stored

keyenv <- GET(searchexample) %>% 
  content() %>% 
  xml_nodes("Count, QueryKey, WebEnv") %>% 
  xml_text()

# vector of pages (at 500 per page)

pages <- seq(1, keyenv[1], 500)

# map fetch across all pages

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

map_df(pages, fetchinfo, historyinfo=keyenv)









