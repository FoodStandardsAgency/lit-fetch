# SCOPUS SEARCH FUNCTIONS

#' Scopus generate URL
#' 
#' @param searchterm string with search term
#' @param dateto search articles published until (default today)
#' @param datefrom search articles published from (default one year ago)
#' @param cursor code for cursor (defaults to asterisk for first page)
#' @import dplyr
#' @import stringr
#' @return a string with the URL to hit
#' 
gen_url_scopus <- function(searchterm, dateto = Sys.Date(), datefrom = Sys.Date()-365, cursor = "*") {
  
  query <- searchterm %>% 
    str_replace_all(., "( ){2,}", " ") %>%
    str_replace_all(., "NOT", "AND NOT") %>% 
    str_replace_all(., "\"", "%22") %>% 
    str_replace_all(., " ", "+")
  
  # dates need to be replaced with years as this is as granular as it goes!
  
  yearfrom = substr(as.character(datefrom), 1, 4)
  yearto = substr(as.character(dateto), 1, 4)
  if(yearfrom == yearto) {
    dates <- paste0("date=",yearfrom)
  } else {
    dates <- paste0("date=",yearfrom,"-",yearto)
  }

  url <- paste0("https://api.elsevier.com/content/search/scopus?query=title-abs-key(",query,")&",dates,"&view=COMPLETE&count=25&cursor=",cursor)
  
  return(url)
  
}

#' Scopus get page of results
#' 
#' @param url URL to hit
#' @import httr
#' @import dplyr
#' @importFrom magrittr extract
#' @import purrr
#' @return a list with a tibble of results, a URL for the next page, and the total number of pages
#' 
get_scopus_result <- function(url) {
  
  hit <- GET(url,
             add_headers(.headers = c(`X-ELS-APIKey` = Sys.getenv("ELSEVIER_API_KEY"),
                                      `X-ELS-Insttoken` = Sys.getenv("ELSEVIER_INST_TOKEN")))) %>% 
    content() %>% 
    .$`search-results`
  
  rcount <- hit %>% .$`opensearch:totalResults` %>% as.numeric()
  
  if(rcount == 0) {
    
    result <- tibble(doi = character(0))
    nextpage <- NA
    
  } else if(rcount > 0) {
    
    nextpage <- hit %>% .$link %>% map(., data.frame) %>% bind_rows() %>% filter(X.ref == "next") %>% pull(X.href) %>% as.character()
    
    if(rcount <= 25) {
      nextpage <- NA
    } else {
      nextpage <- nextpage
    }
    
    meta <- hit %>% .$entry %>% map_df(., function(x) extract(x, c("dc:title", 
                                                                   "prism:publicationName",
                                                                   "prism:coverDate",
                                                                   "prism:doi",
                                                                   "dc:description",
                                                                   "subtypeDescription",
                                                                   "prism:aggregationType")) %>% 
                                         flatten_df())
    
    authors <- hit %>% 
      .$entry %>% 
      map(., function(x) map(x$author, "authname") %>% paste(., collapse = " ; ")) %>% 
      map(., function(x) ifelse(is.null(x), NA, x)) %>% 
      flatten_chr()
    
    link <- hit %>% 
      .$entry %>% 
      map("link") %>% 
      map(., function(x) unlist(x) %>% 
            as_tibble() %>% 
            mutate(lead = lead(value)) %>% 
            filter(value == "scopus") %>% 
            pull(lead)) %>% 
      flatten_chr()
    
    result <- meta %>% 
      mutate(author = authors, 
             scopuslink = link) %>% 
      mutate(pubtype = paste(`prism:aggregationType`, `subtypeDescription`)) %>% 
      mutate(pubtype = case_when(pubtype == "Journal Article" ~ "journal article",
                                 pubtype == "Journal Review" ~ "review", 
                                 TRUE ~ "other")) %>% 
      select(doi = `prism:doi`, 
             title = `dc:title`,
             abstract = `dc:description`,
             author,
             `publication date` = `prism:coverDate`,
             `publication type` = pubtype,
             journal = `prism:publicationName`,
             scopuslink) %>% 
      mutate(source = "Scopus",
             lang = NA,
             url = paste0("https://dx.doi.org/",doi)) %>% 
      filter(!is.na(doi)) %>% 
      group_by(doi) %>% 
      mutate(id = row_number()) %>% 
      ungroup() %>% 
      filter(id == 1) %>% 
      select(-id)
    
  }
  
  return(list(result, nextpage, rcount))
  
}

#' Scopus all steps
#' 
#' @param searchterm string with search term
#' @param dateto search articles published until (default today)
#' @param datefrom search articles published from (default one year ago)
#' @param cursor code for cursor (defaults to asterisk for first page)
#' @import dplyr
#' @import purrr
#' @return a tibble with all results
#' 
get_scopus <- function(searchterm, dateto = Sys.Date(), datefrom = Sys.Date()-365, cursor = "*") {
  
  df <- get_scopus_result(gen_url_scopus(searchterm, datefrom = datefrom, dateto = dateto))
  first <- df
  
  if(df[[3]] == 0) {
    
    result <- tibble(doi = character(0))
    
  } else if(df[[3]] > 0 & df[[3]] <= 25) {
    
    result <- df[[1]]
    
  } else {
    
    pages <- ceiling(df[[3]] / 25) - 1
    
    restof <- vector("list", pages)
    
    for(i in 1:pages) {
      df <- get_scopus_result(df[[2]])
      restof[[i]] <- df[[1]]
    }
    
    result <- bind_rows(first[[1]], restof)
    
  }
  
  return(result)
  
}

#' Scopus missing abstracts
#' 
#' Fetches forbidden scopus abstracts from sciencedirect
#' 
#' @param doi string of DOI of article abstract to retrieve
#' @import dplyr
#' @import stringr
#' @return a tibble with all results
#'
getab <- function(doi) {
  
  abstract <- GET(paste0("https://api.elsevier.com/content/article/doi/",doi),
      add_headers(.headers = c(`X-ELS-APIKey` = Sys.getenv("ELSEVIER_API_KEY"),
                               `X-ELS-Insttoken` = Sys.getenv("ELSEVIER_INST_TOKEN")))) %>% 
    content() %>% 
    .$`full-text-retrieval-response` %>% 
    .$coredata %>% 
    .$`dc:description` %>% 
    str_squish()
  
  tibble(doi = doi, altab = abstract)
}


#' Search counter
#' 
#' gets a total search count across all sources
#' 
#' @param searchterm string of search term
#' @param dateto search articles published until (default today)
#' @param datefrom search articles published from (default one year ago)
#' @import httr
#' @import dplyr
gettotal <- function(searchterm,
                     dateto = Sys.Date(), 
                     datefrom = Sys.Date()-365,
                     across) {
  if("Pubmed" %in% across) {
    pm <- search_pm(gen_url_pm(searchterm, dateto = dateto, datefrom = datefrom)) %>% .$count %>% as.numeric()
  } else {
    pm <- 0
  }
  if("Scopus" %in% across) {
    scop <- get_scopus_result(gen_url_scopus(searchterm, dateto = dateto, datefrom = datefrom)) %>% .[[3]]
  } else {
    scop <- 0
  }
  if("Springer" %in% across) {
    spring <- GET(gen_url_springer(searchterm, datefrom = datefrom, dateto = dateto)) %>% 
      content(., "text") %>% 
      fromJSON() %>% 
      .$result %>% .$total %>% as.numeric()
  } else {
    spring <- 0
  }
  
  totalhits <- pm + scop + spring
  return(totalhits)
}
