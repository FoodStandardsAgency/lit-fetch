
# lfshiny

<!-- badges: start -->
[![Codecov test coverage](https://codecov.io/gh/FoodStandardsAgency/lit-fetch/branch/master/graph/badge.svg)](https://codecov.io/gh/FoodStandardsAgency/lit-fetch?branch=master)
[![R-CMD-check](https://github.com/FoodStandardsAgency/lit-fetch/workflows/R-CMD-check/badge.svg)](https://github.com/FoodStandardsAgency/lit-fetch/actions)
<!-- badges: end -->

# General

Search engine app for users to search, filter and download (into an xlsx spreadsheet) bibliographic references (abstracts, titles, authors, etc.) from Ebsco, Pubmed, Scopus and Springer databases.  

For the tool to work, you will need a `.Renviron` file, in the root folder of the app, containing the API keys. Note that a key is not required for Pubmed and that the key for Scopus is named "Elsevier".  

```r
# .Renviron

SPRINGER_API = "springer API key"
ELSEVIER_API_KEY = "Scopus API key"
ELSEVIER_INST_TOKEN = "Scopus token"
EBSCO_PROF = "Ebsco profile"
EBSCO_PASSWORD = "Ebsco password"
```

Dependencies necessary to run the app are captured using {renv} - create/restore using `renv::restore()`.  

> If a containerised version were required, a `Dockerfile` is provided.  


# Functions

The application, built with `{ golem }`, is organized in modules (prefixed with `mod_`). Since searches are API specific, helper functions have been created and grouped into sub-files (prefixed with `search_`).  

## App modules

* `mod_search.R` contains the logic for searching the API. It takes user inputs (search term, date, which databases), conducts any requested searches and deduplicates the results. If the total number of results across the APIs is over a certain threshold (set by the user), it does not proceed with the article retrieval.  

* `mod_filter.R` takes the search results and applies and inclusion or exclusion filters the user has requested. It does not remove any articles from the results - it flags them as excluded.  

* `mod_preview.R` handles the display of the results of a search (e.g. column selection). If filters have been applied, articles that have been filtered out will appear in the "excluded" tab. The rest of the articles appear in the "included" tab.

* `mod_download.R` parses the search terms, filters and results in an excel file and downloads it.


## Searches

The APIs all work slightly differently but the general workflow is the same:

1. Generate the search URL: a) parse the search string into the appropriate format, b) parse the complete query URL with additional parameters such as dates and API keys.  
2. Make a request to the API.  
3. Clean and standardise the data.

For example, `search_pubmed.R` contains helper functions to query the Pubmed API, query that is performed in the search module (`mod_search.R`). `search_pubmed.R` contains the following logic:

* `gen_url_pm()`: in the search URL, each word or phrase needs to be followed by `"[tiab]"`.  
  * Note: For springer search URLs need to be prefixed with `"title:"`, while scopus does not require this).  
  * Quote marks also need to be URL encoded and replaced with `"%22"` and spaces with "+".  
  * AND, OR, NOT, brackets etc can be left as is - these will be interpreted by the API just as they would be interactively (in the Pubmed onine search tool).  
  * For Pubmed dates also need to be in the format `YYYY/MM/DD`.  
* The initial search is performed by `search_pm()`. It returns the web environment from which the metadata will be retrieved.
* The web environment info is passed on and used in `fetch_pm()` to return up to 500 records at once - the API returns an XML formatted file, which is converted into a tibble (with the function `xml2tib()`).  
* `get_pm()` is the main function. It will be using the aforementioned helpers. It takes in the search query and dates, and steps through all the necessary pages to retrieve the data, then does some final tidying up.  
