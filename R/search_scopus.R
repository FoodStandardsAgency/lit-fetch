# SCOPUS SEARCH FUNCTIONS

#' Scopus generate URL
#'
#' @param searchterm string with search term
#' @param dateto search articles published until (default today)
#' @param datefrom search articles published from (default one year ago)
#' @param cursor code for cursor (defaults to asterisk for first page)
#' @importFrom stringr str_replace_all
#' @return a string with the URL to hit
gen_url_scopus <-
  function(searchterm,
           datefrom = Sys.Date() - 365,
           dateto = Sys.Date() - 1,
           cursor = "*") {
    query <- searchterm %>%
      str_replace_all(., "“", '"') %>%
      str_replace_all(., "”", '"') %>%
      str_replace_all(., "( ){2,}", " ") %>%
      str_replace_all(., "NOT", "AND NOT") %>%
      str_replace_all(., "AND AND", "AND") %>% 
      str_replace_all(., "\"", "%22") %>%
      str_replace_all(., " ", "+")
    
    # dates need to be replaced with years as this is as granular as it goes!
    yearfrom <- substr(as.character(datefrom), 1, 4)
    yearto <- substr(as.character(dateto), 1, 4)
    
    if (yearfrom == yearto) {
      dates <- paste0("date=", yearfrom)
    } else {
      dates <- paste0("date=", yearfrom, "-", yearto)
    }

    paste0(
      "https://api.elsevier.com/content/search/scopus?query=title-abs-key(",
      query,
      ")&",
      dates,
      "&view=COMPLETE&count=25&cursor=",
      cursor
    )
  }


#' Scopus get page of results
#'
#' @param url URL to hit
#' @importFrom httr GET add_headers content
#' @importFrom dplyr bind_rows filter pull mutate filter lead
#' @importFrom magrittr extract
#' @importFrom purrr map map_df flatten_df flatten_chr
#' @importFrom tibble tibble as_tibble
#' @return a list with a tibble of results, a URL for the next page, and the total number of pages
get_scopus_result <- function(url) {
  hit <- GET(
    url,
    add_headers(
      .headers = c(
        `X-ELS-APIKey` = Sys.getenv("ELSEVIER_API_KEY"),
        `X-ELS-Insttoken` = Sys.getenv("ELSEVIER_INST_TOKEN")
      )
    )
  ) %>%
    content() %>%
    .$`search-results`

  rcount <- hit %>%
    .$`opensearch:totalResults` %>%
    as.numeric()

  if (rcount == 0) {
    result <- tibble(doi = character(0))
    nextpage <- NA
    
  } else if (rcount > 0) {
    # only query first page (25 results)
    nextpage <- hit %>%
      .$link %>%
      map(., data.frame) %>%
      bind_rows() %>%
      filter(X.ref == "next") %>%
      pull(X.href) %>%
      as.character()

    if (rcount <= 25) {
      nextpage <- NA
      
    } else {
      nextpage <- nextpage
    }

    meta <-
      hit %>%
      .$entry %>%
      map_df(., function(x) {
        magrittr::extract(   # (make sure it is not taken from tidyr when testing)
          x,
          c(
            "dc:title",
            "prism:publicationName",
            "prism:coverDate",
            "prism:doi",
            "dc:description",
            "subtypeDescription",
            "prism:aggregationType"
          )
        ) %>%
          flatten_df()
      })

    authors <- hit %>%
      .$entry %>%
      map(., function(x) {
        map(x$author, "authname") %>% paste(., collapse = " ; ")
      }) %>%
      map(., function(x) {
        ifelse(is.null(x), NA, x)
      }) %>%
      flatten_chr()

    link <- hit %>%
      .$entry %>%
      map("link") %>%
      map(., function(x) {
        unlist(x) %>%
          as_tibble() %>%
          mutate(lead = lead(value)) %>%
          filter(value == "scopus") %>%
          pull(lead)
      }) %>%
      flatten_chr()
    
    openaccess <- hit %>%
      .$entry %>%
      map("openaccessFlag") %>%
      map(., function(x) {
        unlist(x) %>%
          as_tibble() %>%
          pull(value)
      }) %>%
      flatten_chr()

    result <- meta %>%
      mutate(
        author = authors,
        scopuslink = link,
        openaccess = openaccess
      )
  }

  return(list(result, nextpage, rcount))
}


#' Scopus all steps
#'
#' @param searchterm string with search term
#' @param dateto search articles published until (default today)
#' @param datefrom search articles published from (default one year ago)
#' @param cursor code for cursor (defaults to asterisk for first page)
#' @importFrom dplyr bind_rows mutate select filter case_when group_by ungroup row_number
#' @importFrom tibble tibble
#' @return a tibble with all results
get_scopus <-
  function(searchterm,
           datefrom = Sys.Date() - 365,
           dateto = Sys.Date() - 1,
           cursor = "*") {
    df <- gen_url_scopus(searchterm, datefrom, dateto) %>%
      get_scopus_result()

    if (df[[3]] == 0) {
      return(
        tibble(doi = character(0))
      )
      
    } else if (df[[3]] > 0 & df[[3]] <= 25) {
      result <- df[[1]]
      
    } else {
      n_pages <- ceiling(df[[3]] / 25) - 1
      restof <- vector("list", n_pages)
      first <- df

      # df[[2]] points to next page (cursor)
      for (i in 1:n_pages) {
        df <- get_scopus_result(df[[2]])
        restof[[i]] <- df[[1]]
      }

      result <- bind_rows(first[[1]], restof)
    }

    result %>%
      mutate(
        pubtype = paste(`prism:aggregationType`, `subtypeDescription`)
      ) %>%
      mutate(
        pubtype = case_when(
          pubtype == "Journal Article" ~ "journal article",
          pubtype == "Journal Review" ~ "review",
          TRUE ~ "other"
        )
      ) %>%
      select(
        doi = `prism:doi`,
        title = `dc:title`,
        abstract = `dc:description`,
        author,
        `publication date (yyyy-mm-dd)` = `prism:coverDate`,
        `publication type` = pubtype,
        journal = `prism:publicationName`,
        scopuslink,
        openaccess
      ) %>%
      mutate(
        source = "Scopus",
        lang = NA,
        url = paste0("https://dx.doi.org/", doi)
      ) %>%
      mutate(
        url = case_when(
          is.na(doi) ~ scopuslink,
          TRUE ~ url
        )
      ) %>%
      group_by(url) %>%
      mutate(id = row_number()) %>%
      ungroup() %>%
      filter(id == 1) %>%
      mutate(openaccess=tolower(openaccess)=='TRUE'
             ) %>% 
      select(-id)
  }


#' Scopus missing abstracts
#'
#' Fetches forbidden scopus abstracts from sciencedirect
#'
#' @param doi string of DOI of article abstract to retrieve
#' @importFrom httr GET add_headers content
#' @importFrom stringr str_squish
#' @importFrom tibble tibble
#' @return a tibble with all results
getab <- function(doi) {
  abstract <-
    GET(
      paste0("https://api.elsevier.com/content/article/doi/", doi),
      add_headers(
        .headers = c(
          `X-ELS-APIKey` = Sys.getenv("ELSEVIER_API_KEY"),
          `X-ELS-Insttoken` = Sys.getenv("ELSEVIER_INST_TOKEN")
        )
      )
    ) %>%
    content() %>%
    .$`full-text-retrieval-response` %>%
    .$coredata %>%
    .$`dc:description` %>%
    str_squish()

  tibble(doi = doi, altab = abstract)
}
