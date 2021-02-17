#' Generates URL with query string for Ebsco API
#'
#' @param searchterm text of the query
#' @param datefrom from date appeared online (default = 1 year ago from today), format YYYY/MM/DD
#' @param dateto to date appeared online (default = today), format YYYY/MM/DD
#' @importFrom stringr str_replace_all
#' @return string, a URL to search pubmed for a particular term between two given dates
gen_url_ebsco <-
  function(searchterm,
           datefrom = Sys.Date() - 365,
           dateto = Sys.Date() - 1) {
    term <- searchterm %>%
      str_replace_all(., "“", '"') %>%
      str_replace_all(., "”", '"') %>%
      
      # FIXME user ASCII (fix R CMD check warning)
      # stringi::stri_escape_unicode("“Hello World”") %>% 
      # gsub("[(\\u201c)|(\\u201d)]", "", .)
    
      # str_replace_all(., "( ){2,}", " ") %>%
      # str_replace_all(., "NOT", "AND NOT") %>%
      # str_replace_all(., "\"", "%22") %>%
      str_replace_all(., " ", "+")

    # dates need to be replaced with years as this is as granular as it goes!
    datefrom <- format(datefrom, "%Y%m%d")
    dateto <- format(dateto, "%Y%m%d")

    query <- paste0(
      "(",
      term,
      ")+AND+(DT+",
      datefrom,
      "-",
      dateto,
      ")"
    )
    # "&(TI+AB+SU+yes)"

    base_url <- "http://eit.ebscohost.com/Services/SearchService.asmx/Search?"
    
    url <-
      paste0(
        base_url,
        "prof=", Sys.getenv("EBSCO_PROF"),
        "&pwd=", Sys.getenv("EBSCO_PASSWORD"),
        "&authType=profile",
        "&ipprof=",
        "&query=", query,
        "&db=fsr"
      )

    return(url)
  }


#' Pubmed fetch one page (up to 500 refs) from search
#'
#' @param pagenumber number of page to retrieve
#' @param historyinfo web environment info returned from search_pm()
#' @importFrom tidyr spread
#' @importFrom purrr map_df
#' @importFrom httr GET content
#' @importFrom rvest xml_nodes
#' @return tibble with info fields on up to 500 articles
fetch_ebsco <- function(pagenumber, historyinfo) {
  url <- paste0(historyinfo, "&numrec=200&startrec=", pagenumber + 1)

  articlexml <- GET(url) %>%
    content() %>%
    xml_nodes("controlInfo")

  articleinfo <- map_df(articlexml, function(x) {
    xml2tib(
      x,
      "atl,
      ab,
      ui[type=\"doi\"],
      jtl,
      pubtype,
      doctype,
      dt,
      au,
      language"
    ) %>% spread(field, value)
  })

  return(articleinfo)
}


#' ebsco get page of results
#'
#' @param url URL to hit
#' @importFrom httr GET content
#' @importFrom dplyr mutate case_when if_else
#' @importFrom purrr map_df
#' @importFrom xml2 xml_text xml_find_first xml_ns
#' @return a list with a tibble of results, a URL for the next page, and the total number of pages
get_ebsco <- function(searchterm,
                      datefrom = Sys.Date() - 365,
                      dateto = Sys.Date() - 1) {
  url <-
    gen_url_ebsco(searchterm, datefrom = datefrom, dateto = dateto)

  rcount <- GET(url) %>%
    content() %>%
    xml_find_first("//d1:Hits", xml_ns(.)) %>%
    xml_text()

  # search <- search_ebsco(url)

  if (as.numeric(rcount) > 0) {
    pages <- seq(0, rcount, 200)

    results <- map_df(pages, fetch_ebsco, url) %>%

      # block to create any missing variables, there is probably a more elegant way
      mutate(ArticleTitle = {
        if ("atl" %in% names(.)) {
          paste0(atl)
        } else {
          ""
        }
      }) %>%
      mutate(Abstract = {
        if ("ab" %in% names(.)) {
          paste0(ab)
        } else {
          ""
        }
      }) %>%
      mutate(ArticleId = {
        if ("ui" %in% names(.)) {
          paste0(ui)
        } else {
          ""
        }
      }) %>%
      # mutate(Title = {
      #   if ("Title" %in% names(.)) {
      #     paste0(Title)
      #   } else {
      #     ""
      #   }
      # }) %>%
      # mutate(PublicationStatus = {
      #   if ("PublicationStatus" %in% names(.)) {
      #     paste0(PublicationStatus)
      #   } else {
      #     ""
      #   }
      # }) %>%
      mutate(PublicationType = {
        if ("pubtype" %in% names(.)) {
          paste0(pubtype)
        } else {
          ""
        }
      }) %>%
      mutate(Year = {
        if ("dt" %in% names(.)) {
          paste0(dt)
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
      mutate(
        dt = substr(dt, 1, nchar(dt) - 3),
        date_format_1 = as.Date(dt, "%m/%d/%Y"),
        # date_format_2 not working
        date_format_2 = ifelse(
          grepl(".*[a-zA-Z]{3}[0-9]{4}", dt),
          paste0(substr(dt, 1, 3), "-", substr(dt, nchar(dt) - 3, nchar(dt))),
          ""
        ),
        # date_format_2 not working
        date_format_2 = as.Date(date_format_2, "%b-%Y"),
        date_format_3 = ifelse(grepl("^[0-9]{4}$", dt), dt, ""),
        date_format_3 = format(as.Date(date_format_3, "%Y"), "%Y-01-01"),
        date_format_3 = as.Date(date_format_3),
        pdate = case_when(
          !is.na(date_format_1) ~ date_format_1,
          !is.na(date_format_2) ~ date_format_2,
          !is.na(date_format_3) ~ date_format_3
        )
      ) %>%

      # mutate(Year = ifelse(Year == "","1990",Year)) %>%
      # mutate_at(vars(Day, Month), ~if_else(. == "", "01", .)) %>%
      # mutate(Month = case_when(
      #   Month == "Jan" ~ "01",
      #   Month == "Feb" ~ "02",
      #   Month == "Mar" ~ "03",
      #   Month == "Apr" ~ "04",
      #   Month == "May" ~ "05",
      #   Month == "Jun" ~ "06",
      #   Month == "Jul" ~ "07",
      #   Month == "Aug" ~ "08",
      #   Month == "Sep" ~ "09",
      #   Month == "Oct" ~ "10",
      #   Month == "Nov" ~ "11",
      #   Month == "Dec" ~ "12",
      #   TRUE ~ Month
      # )) %>%
      # mutate(pdate = paste0(Year,"-",Month,"-",Day)) %>%
      mutate(type = "") %>%
      mutate(type = if_else(
        grepl("Academic Journal", PublicationType),
        "journal article",
        type
      )) %>%
      # check for review flags!
      # mutate(type = if_else(grepl("^Review ;|; Review ;| ; Review$|^Review$", PublicationType), "review", type)) %>%
      mutate(type = if_else(type == "", "other", type)) %>%
      # need ebsco link
      mutate(url = paste0("https://dx.doi.org/", ArticleId)) %>%
      select(
        doi = ui,
        title = ArticleTitle,
        abstract = ab,
        author = au,
        `publication date (yyyy-mm-dd)` = pdate,
        `publication type` = PublicationType,
        journal = jtl,
        lang = language,
        url
      ) %>%
      mutate(source = "Ebsco") %>%
      group_by(doi) %>%
      mutate(id = row_number()) %>%
      group_by(title, abstract) %>%
      mutate(title_id = row_number()) %>%
      ungroup() %>%
      filter((!is.na(doi) &
        doi != "" &
        id == 1) |
        (title_id == 1 &
          doi == "") | (title_id == 1 & is.na(doi))) %>%
      select(-id, -title_id)

  } else {
    results <- tibble(doi = character(0))
  }

  return(results)
}