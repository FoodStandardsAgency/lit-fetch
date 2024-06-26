# PUBMED SEARCH FUNCTIONS

#' Generates URL with query string for pubmed API
#'
#' @param searchterm text of the query
#' @param datefrom from date appeared online (default = 1 year ago from today), format YYYY/MM/DD
#' @param dateto to date appeared online (default = today), format YYYY/MM/DD
#' @importFrom stringr str_replace_all str_squish fixed
#' @return string, a URL to search pubmed for a particular term between two given dates
gen_url_pm <- function(searchterm,
                       datefrom = Sys.Date() - 365,
                       dateto = Sys.Date() - 1) {
  term <- searchterm %>%
    str_replace_all(., "“", '"') %>%
    str_replace_all(., "”", '"') %>%
    str_replace_all(., "( ){2,}", " ") %>%
    str_replace_all(., "\"", "%22") %>%
    str_replace_all(., " ", "+") %>%
    str_replace_all(., fixed("+AND+"), " AND ") %>%
    str_replace_all(., fixed("+OR+"), " OR ") %>%
    str_replace_all(., fixed("+NOT+"), " NOT ") %>%
    paste0(., " ") %>%
    str_replace_all(., " ", "[tiab] ") %>%
    str_replace_all(., fixed("AND[tiab]"), "AND") %>%
    str_replace_all(., fixed("OR[tiab]"), "OR") %>%
    str_replace_all(., fixed("NOT[tiab]"), "NOT") %>%
    str_replace_all(., fixed(")[tiab]"), "[tiab])") %>%
    str_replace_all(., fixed(")[tiab]"), "[tiab])") %>%
    str_replace_all(., fixed(")[tiab]"), "[tiab])") %>%
    str_squish() %>%
    str_replace_all(., " ", "+")

  datefrom <- as.character(datefrom, "%Y/%m/%d")
  dateto <- as.character(dateto, "%Y/%m/%d")

  base_url <-
    "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?"

  paste0(
    base_url,
    "db=pubmed&term=", term,
    "&datetype=pdat&mindate=", datefrom,
    "&maxdate=", dateto,
    "&usehistory=y"
  )
}


#' Pubmed search
#' 
#' @param searchurl search URL generated by gen_url_pm()
#' @importFrom rvest xml_nodes
#' @importFrom xml2 xml_text read_xml
#' @return A list with the total hits and history parameters for returning article info
search_pm <- function(searchurl) {
  keyenv <- read_xml(searchurl) %>%
    xml_nodes("Count, QueryKey, WebEnv") %>%
    xml_text()
  
  list(
    count = keyenv[1],
    querykey = keyenv[2],
    webenv = keyenv[3]
  )
}


#' Pubmed fetch one page (up to 500 refs) from search
#' 
#' @param pagenumber number of page to retrieve
#' @param historyinfo web environment info returned from search_pm()
#' @importFrom xml2 read_xml xml_find_all
#' @return tibble with info fields on up to 500 articles
fetch_pm <- function(pagenumber, historyinfo) {
  url <-
    paste0(
      "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&query_key=",
      historyinfo$querykey,
      "&WebEnv=", historyinfo$webenv,
      "&retmax=500&retstart=", pagenumber, # max of 500 res from page number start
      "&retmode=xml"
    )

  # NOTE : for doi, avoid catching dois at css path
  # ReferenceList>Reference>ArticleIdList>ArticleId
  nodenames <-
    "ArticleTitle,
    Abstract,
    PubmedData>ArticleIdList>ArticleId[IdType=\"doi\"],
    Journal Title,
    PublicationStatus,
    PublicationType,
    PubDate Year,
    PubDate Month,
    PubDate Day,
    Author LastName,
    Language"
  
  read_xml(url) %>%
    xml_find_all(".//PubmedArticle") %>%
    xml2tib(nodenames, "pubmed")
}


#' Pubmed all steps
#' 
#' @param searchterm text of the query
#' @param datefrom from date appeared online (default = 1 year ago today), format YYYY/MM/DD
#' @param dateto to date appeared online (default = today), format YYYY/MM/DD
#' @importFrom dplyr mutate mutate_at select group_by ungroup filter case_when if_else row_number
#' @importFrom tibble tibble
#' @importFrom purrr map_df
#' @return a tibble of results
get_pm <- function(searchterm,
                   datefrom = Sys.Date() - 365,
                   dateto = Sys.Date() - 1) {
  url <- gen_url_pm(searchterm, datefrom, dateto)

  search <- search_pm(url)

  if (as.numeric(search$count) > 0) {
    pages <- seq(0, search$count, 500)

    results <- map_df(pages, fetch_pm, search)
    
    results %>%
      # block to create any missing variables, there is probably a more elegant way
      mutate(ArticleTitle = {
        if ("ArticleTitle" %in% names(.)) {
          paste0(ArticleTitle)
        } else {
          ""
        }
      }) %>%
      mutate(Abstract = {
        if ("Abstract" %in% names(.)) {
          paste0(Abstract)
        } else {
          ""
        }
      }) %>%
      mutate(ArticleId = {
        if ("ArticleId" %in% names(.)) {
          paste0(ArticleId)
        } else {
          ""
        }
      }) %>%
      mutate(Title = {
        if ("Title" %in% names(.)) {
          paste0(Title)
        } else {
          ""
        }
      }) %>%
      mutate(PublicationStatus = {
        if ("PublicationStatus" %in% names(.)) {
          paste0(PublicationStatus)
        } else {
          ""
        }
      }) %>%
      mutate(PublicationType = {
        if ("PublicationType" %in% names(.)) {
          paste0(PublicationType)
        } else {
          ""
        }
      }) %>%
      mutate(Year = {
        if ("Year" %in% names(.)) {
          paste0(Year)
        } else {
          ""
        }
      }) %>%
      mutate(Month = {
        if ("Month" %in% names(.)) {
          paste0(Month)
        } else {
          ""
        }
      }) %>%
      mutate(Day = {
        if ("Day" %in% names(.)) {
          paste0(Day)
        } else {
          ""
        }
      }) %>%
      mutate(LastName = {
        if ("LastName" %in% names(.)) {
          paste0(LastName)
        } else {
          ""
        }
      }) %>%
      mutate(Language = {
        if ("Language" %in% names(.)) {
          paste0(Language)
        } else {
          ""
        }
      }) %>%
      replace(., . == "NA", "") %>%
      mutate(Year = ifelse(Year == "", "1990", Year)) %>%
      mutate_at(vars(Day, Month), ~ if_else(. == "", "01", .)) %>%
      mutate(
        Month = case_when(
          Month == "Jan" ~ "01",
          Month == "Feb" ~ "02",
          Month == "Mar" ~ "03",
          Month == "Apr" ~ "04",
          Month == "May" ~ "05",
          Month == "Jun" ~ "06",
          Month == "Jul" ~ "07",
          Month == "Aug" ~ "08",
          Month == "Sep" ~ "09",
          Month == "Oct" ~ "10",
          Month == "Nov" ~ "11",
          Month == "Dec" ~ "12",
          TRUE ~ Month
        )
      ) %>%
      mutate(pdate = paste0(Year, "-", Month, "-", Day)) %>%
      mutate(type = "") %>%
      mutate(type = if_else(
        grepl(
          "^Journal Article ;|; Journal Article ;|; Journal Article$|^Journal Article$",
          PublicationType
        ),
        "journal article",
        type
      )) %>%
      mutate(type = if_else(
        grepl("^Review ;|; Review ;| ; Review$|^Review$", PublicationType),
        "review",
        type
      )) %>%
      mutate(type = if_else(type == "", "other", type)) %>%
      mutate(url = paste0("https://dx.doi.org/", ArticleId)) %>%
      select(
        doi = ArticleId,
        title = ArticleTitle,
        abstract = Abstract,
        author = LastName,
        `publication date (yyyy-mm-dd)` = pdate,
        `publication type` = type,
        journal = Title,
        lang = Language,
        url
      ) %>%
      mutate(source = "Pubmed") %>%
      # filter(!is.na(doi) & doi != "") %>%
      mutate(openaccess = "NA") %>% 
      group_by(doi) %>%
      mutate(id = row_number()) %>%
      ungroup() %>%
      filter(id == 1 | is.na(doi) | doi == "") %>%
      select(-id)

  } else {
    tibble(doi = character(0))
  }
}
