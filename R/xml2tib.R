#' Pick out nodes from xml and turn it into a tibble
#'
#' @param xmlnodeset an xml node containing nodes
#' @param nodenames the names of the nodes you wish to extract (string with nodes separated by commas)
#' @param root_node_label name of the top node that (first element returned by rvest::xml_nodes)
#' @importFrom dplyr select mutate rename bind_cols group_by ungroup
#' @importFrom tidyr spread
#' @importFrom tibble as_tibble
#' @importFrom rvest xml_nodes
#' @importFrom xml2 xml_text xml_name
#' @importFrom purrr pmap_int
#' @return A tibble with node names as col names and node text as values
xml2tib <- function(xmlnodeset, nodenames, root_node_label) {
  xml_nodes <- xmlnodeset %>%
    xml_nodes(nodenames)

  values <- xml_nodes %>%
    xml_text() %>%
    as_tibble()

  fields <- xml_nodes %>%
    xml_name() %>%
    as_tibble() %>%
    rename(field = value)

  index <- 0L

  # give group number (node number) to elements in same node
  bind_cols(values, fields) %>%
    mutate(idx = pmap_int(., function(field, ...) {
      if (field == root_node_label) {
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
}