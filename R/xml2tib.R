#' Pick out nodes from xml and turn it into a tibble
#' 
#' @param xmlnode an xml node containing nodes
#' @param nodenames the names of the nodes you wish to extract (string with nodes separated by commas)
#' @importFrom dplyr mutate rename bind_cols group_by ungroup
#' @importFrom magrittr %>%
#' @importFrom tibble as_tibble
#' @importFrom rvest xml_nodes
#' @importFrom xml2 xml_text xml_name
#' @return A tibble with node names as col names and node text as values
xml2tib <- function(xmlnode, nodenames) {
  values <- xmlnode %>%
    xml_nodes(nodenames) %>% 
    xml_text() %>% 
    as_tibble()
  
  fields <- xmlnode %>% 
    xml_nodes(nodenames) %>% 
    xml_name() %>% 
    as_tibble() %>% 
    rename(field = value)
  
  bind_cols(values, fields) %>% 
    group_by(field) %>% 
    mutate(value = paste0(value, collapse = " ; ")) %>% 
    unique() %>% 
    ungroup() 
}
