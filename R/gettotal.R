#' Search counter
#'
#' gets a total search count across all sources
#'
#' @param searchterm string of search term
#' @param dateto search articles published until (default today)
#' @param datefrom search articles published from (default one year ago)
#' @param across list of APIs sources to be used
#' @importFrom httr GET content
#' @importFrom stringr str_replace_all
#' @importFrom jsonlite fromJSON
gettotal <- function(searchterm,
                     dateto = Sys.Date() - 1,
                     datefrom = Sys.Date() - 365,
                     across) {
  searchterm <- searchterm %>%
    str_replace_all(., "“", '"') %>%
    str_replace_all(., "”", '"')
  
  if ("Pubmed" %in% across) {
    pm <-
      gen_url_pm(searchterm, dateto = dateto, datefrom = datefrom) %>%
      search_pm() %>%
      .$count %>%
      as.numeric()
  } else {
    pm <- 0
  }
  
  if ("Scopus" %in% across) {
    scop <-
      gen_url_scopus(searchterm, dateto = dateto, datefrom = datefrom) %>%
      get_scopus_result() %>%
      .[[3]]
  } else {
    scop <- 0
  }
  
  if ("Springer" %in% across) {
    spring <-
      gen_url_springer(searchterm, datefrom = datefrom, dateto = dateto) %>%
      GET() %>%
      content(., "text") %>%
      fromJSON() %>%
      .$result %>%
      .$total %>%
      as.numeric()
  } else {
    spring <- 0
  }
  
  totalhits <- pm + scop + spring
  
  return(totalhits)
}