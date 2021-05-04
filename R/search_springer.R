# SPRINGER SEARCH FUNCTIONS

#' Make URL for Springer API
#' 
#' @param searchterm text of query
#' @param datefrom earliest date added
#' @param dateto latest date added
#' @param apikey Springer API key
#' @importFrom stringr str_replace_all str_remove_all str_split str_c str_squish
#' @importFrom purrr map_chr
gen_url_springer <- function(searchterm,
                             datefrom = as.character(Sys.Date() - 365),
                             dateto = as.character(Sys.Date() - 1),
                             apikey = Sys.getenv("SPRINGER_API")) {
  
  baseurl <- "http://api.springernature.com/meta/v2/json?"
  
  terms <- searchterm %>% 
    str_replace_all(.,'“','"') %>%
    str_replace_all(.,'”','"') %>%
    str_split(., " AND | OR | NOT ") %>% 
    .[[1]] %>% 
    str_remove_all(., "[\\(\\)]") %>% 
    str_replace_all(., "\"", "%22") %>%
    map_chr(., str_squish) %>% 
    str_c(., collapse = "|") %>% 
    paste0("(",.,")")
  
  term <- searchterm %>%
    str_replace_all(.,'“','"') %>%
    str_replace_all(.,'”','"') %>%
    str_replace_all(., "( ){2,}", " ") %>%
    str_replace_all(., "\"", "%22") %>%
    str_replace_all(., terms, "title:\\1") %>% 
    str_replace_all(., " ", "+") 
  
  searchurl <- paste0(baseurl,
                      "q=",term,"+onlinedatefrom:",datefrom,"+onlinedateto:",dateto,
                      "&api_key=",apikey)
  return(searchurl)
}


#' Springer fetch 1 page (up to 100 per page)
#' 
#' @param searchurl URL with the search query
#' @param page page to fetch
#' @importFrom dplyr select mutate_at
#' @importFrom jsonlite fromJSON
#' @importFrom httr GET content
#' @importFrom tibble as_tibble
get_results_springer <- function(page, searchurl) {
  
  pagurl <- paste0(searchurl,"&p=100&s=",page)
  
  fullspring <- GET(pagurl) %>% 
    content(., "text") %>% 
    fromJSON() %>% 
    .$records %>% 
    as_tibble() %>% 
    select(url, title, creators, publicationName, doi, publicationDate, publicationType,
           genre, abstract) %>% 
    mutate_at(vars(url, creators, genre), ~as.list(.))
  
  return(fullspring)
}


#' Springer all steps
#'  
#' @param searchterm text of query
#' @param datefrom earliest date added
#' @param dateto latest date added
#' @param apikey Springer API key
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @importFrom purrr map_df
#' @importFrom dplyr group_by ungroup filter select mutate left_join if_else row_number
#' @importFrom tidyr unnest
#' @importFrom tibble tibble
#' @return a tibble with 11 columns
get_springer <- function(searchterm,
                         datefrom = as.character(Sys.Date() - 365),
                         dateto = as.character(Sys.Date() - 1),
                         apikey = Sys.getenv("SPRINGER_API"))  {
  
  searchurl <- gen_url_springer(searchterm, datefrom = datefrom, dateto = dateto)
  
  total <- GET(searchurl) %>% 
    content(., "text") %>% 
    fromJSON() %>% 
    .$result %>% .$total 
  
  if(as.numeric(total) > 0) {
    pages <- seq(1, total, 100)
    
    result <- map_df(pages, get_results_springer, searchurl = searchurl)
    
    # clean
    urls <- result %>% 
      group_by(doi) %>% 
      unnest(cols = "url") %>% 
      filter(format == "html") %>% 
      ungroup() %>% 
      select(doi, url = value) 
    
    authors <- result %>% 
      group_by(doi) %>%
      unnest(cols = "creators") %>%
      mutate(createlist = paste0(creator, collapse = " ; ")) %>%
      select(-creator) %>%
      ungroup() %>%
      unique() %>%
      select(doi, author = createlist)
    
    types <- result %>%
      group_by(doi) %>%
      select(doi, publicationType, genre) %>%
      unnest(cols = "genre") %>%
      mutate(genre = paste0(genre, collapse = " ; ")) %>%
      unique() %>%
      mutate(type = "") %>%
      mutate(
        type = if_else(
          publicationType == "Journal" & grepl(
            "original( )?paper|^article$|original( )?article|research( )?article|^research$|research( )?paper|original( )?contribution", 
            genre, ignore.case = T
            ),
          "journal article",
          type
          )
      ) %>%
      mutate(type = if_else(publicationType == "Journal" &
        grepl("review( )?paper|review( )?article|invited( )review|^review$",
          genre,
          ignore.case = T
        ),
      "review", type
      )) %>%
      mutate(type = if_else(type == "", "other", type)) %>%
      select(-genre) %>%
      unique() %>%
      ungroup()
    
    result <- result %>%
      left_join(urls, by = "doi") %>%
      left_join(authors, by = "doi") %>%
      left_join(types, by = "doi") %>%
      select(
        doi,
        title,
        abstract,
        author,
        `publication date (yyyy-mm-dd)` = publicationDate,
        `publication type` = type,
        journal = publicationName,
        url = url.y
      ) %>%
      mutate(
        source = "Springer",
        lang = NA
      ) %>%
      group_by(doi) %>%
      mutate(id = row_number()) %>%
      ungroup() %>%
      filter(id == 1 | is.na(doi)) %>%
      select(-id)
    
    
  } else {
    result <- tibble(doi = character(0))
  }
  
  return(result)
}
