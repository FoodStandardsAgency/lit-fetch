#' Pick out nodes from xml and turn it into a tibble
#' 
#' Extract xml nodes and turn xml to tibble
#'
#' @param xmlnodeset an xml node containing nodes
#' @param nodenames the names of the nodes you wish to extract (string with nodes separated by commas)
#' @param api name of api and determines the indexing and the top node to index on (first element returned by rvest::xml_nodes)
#' @importFrom dplyr select mutate rename bind_cols group_by ungroup
#' @importFrom tidyr spread
#' @importFrom tibble as_tibble
#' @importFrom rvest xml_nodes
#' @importFrom xml2 xml_text xml_name
#' @importFrom purrr pmap_int
#' @return A tibble with node names as col names and node text as values
xml2tib <- function(xmlnodeset, nodenames, api) {
  xml_nodes <- xmlnodeset %>%
    xml_nodes(nodenames)

  values <- xml_nodes %>%
    xml_text() %>%
    as_tibble()

  fields <- xml_nodes %>%
    xml_name() %>%
    as_tibble() %>%
    rename(field = value)

  if (api == "ebsco") {
    index <- 0L
    
    # give group number (node number) to elements in same node
    bind_cols(values, fields) %>%
      mutate(idx = pmap_int(., function(field, ...) {
        if (field == "jtl") {
          index <<- index + 1L
        }
        index
      })) %>%
      group_by(idx, field) %>%
      mutate(value = paste0(value, collapse = " ; ")) %>%
      unique() %>%
      ungroup() %>%
      spread(field, value) %>%
      select(-idx)
    
  } else if (api == "pubmed") {
    index <- 0L
    
    res <- bind_cols(values, fields) %>%
      mutate(
        idx = pmap_int(., function(field, ...) {
          if (field == "Year") {
            index <<- index + 1L
          }
          index
        }))
    
    is.title <- res$field == "Title"
    lagged <- c(FALSE, res$field[2:length(res$field)-1])
    lagged.is.year.month.day <- lagged%in% c("Year", "Month", "Day")
    
    res$is.preceded.by.date <- is.title & lagged.is.year.month.day
    
    res <- res %>%
      mutate(idx2 = pmap_int(., function(field, is.preceded.by.date, ...) {
        if (field == "Title" & is.preceded.by.date == FALSE) {
          index <<- index + 1L
        }
        index
      })) %>%
      mutate(idx3 = idx + idx2) %>%
      select(value, field, idx3) %>%
      group_by(idx3, field) %>%
      mutate(value = paste0(value, collapse = " ; ")) %>%
      unique() %>%
      ungroup() %>%
      spread(field, value) %>%
      select(-idx3)
  }
}
