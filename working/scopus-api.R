
# scopus API will give up to 25 at a time, can page along with start parameter (which is page) (cursor does not work)

GET("https://api.elsevier.com/content/search/scopus?query=title-abs-key(mars)&apiKey=") %>% 
  content(., "text") %>% 
  jsonlite::fromJSON() %>% 
  as_tibble() %>% slice(6) %>% tidyr::unnest(cols = c(`search-results`))  


SD_API = "4b477e75e890387702fa86038096014f"


GET("https://api.elsevier.com/content/search/scopus?query=title-abs-key(mars)&apiKey=4b477e75e890387702fa86038096014f&view=STANDARD") %>% 
  content() %>% 
  .$`search-results` %>% 
  .$entry %>% 
  .[[1]]


# possibly useful websites
# https://dev.elsevier.com/partner_support.html
# https://dev.elsevier.com/tecdoc_api_authentication.html
# https://www.elsevier.com/solutions/scopus/support/authentication-and-access
# https://dev.elsevier.com/api_key_settings.html
# 
# 