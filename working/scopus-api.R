
# scopus API will give up to 25 at a time, can page along with start parameter (which is page) (cursor does not work)

GET("https://api.elsevier.com/content/search/scopus?query=title-abs-key(mars)&apiKey=") %>% 
  content(., "text") %>% 
  jsonlite::fromJSON() %>% 
  as_tibble() %>% slice(6) %>% tidyr::unnest(cols = c(`search-results`))     

