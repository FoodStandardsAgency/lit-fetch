
# lfshiny

<!-- badges: start -->
[![Codecov test coverage](https://codecov.io/gh/FoodStandardsAgency/lit-fetch/branch/master/graph/badge.svg)](https://codecov.io/gh/FoodStandardsAgency/lit-fetch?branch=master)
[![R-CMD-check](https://github.com/FoodStandardsAgency/lit-fetch/workflows/R-CMD-check/badge.svg)](https://github.com/FoodStandardsAgency/lit-fetch/actions)
<!-- badges: end -->

# General

Shiny app for users to access the search, filter and cleaning functionality, and download the resulting references as a spreadsheet.  

To call the Springer API you will need a `.Renviron` file with a variable called `"SPRINGER_API"` taking the value of your API key, and variables `"ELSEVIER_API_KEY"` and `"ELSEVIER_INST_TOKEN"` to use the Scopus API.  

The app is built as an R package, using the { golem } framework.  

Dependencies necessary to run the app are captured using {renv} - create/restore using `renv::restore()`.  

> In case a docker version were required, a docker file is provided.  


# Functions

## Searches

The APIs all work slightly differently but the general workflow is the same:

1. Generate the search URL, translating the search string into the appropriate format, and pasting it to the base URL along 
with any other parameters such as dates and API keys.  
2. Call the API with GET or PUT as appropriate.  
3. Depending on the API you may need to do subsequent calls to return all the metadata.
4. Clean and standardise the data.
5. If there are a lot of results you may need to repeat this process across several pages of results.

For example, the functions in `pubmed_search.R` work as follows:

* `gen_url_pm()`: in the search URL, each word or phrase needs to be followed by "[tiab]" (for springer they need to be prefixed with "title:", while scopus does not require this). Quote marks also need to be replaced with "%22" and spaces with "+". AND, OR, NOT, brackets etc can be left as is - these will be interpreted in the API call as they would be interactively. For Pubmed dates also need to be in the format `YYYY/MM/DD`.  
* The initial search (`search_pm()`) returns the web environment from which the metadata will be retrieved. This info is used in `fetch_pm()` to return up to 500 records at once - the API returns an XML, which is converted into a tibble (with the function `xml2tib()`).  
* All these functions are combined in `get_pm()`, which takes in the search query and dates, and steps through all the necessary pages to retrieve everything, then does some final tidying on the combined data.  


## App modules

* `mod_search.R` takes user inputs (search term, date, which databases), conducts any requested searches and deduplicates the results. If the total number of results across the APIs is over a certain threshold (currently 1000), it does not proceed with the article retrieval.  

* `mod_filter.R` takes the search results and applies and inclusion or exclusion filters the user has requested. It does not remove any articles from the results - it flags them as excluded.  

* `mod_preview.R` shows the user the results of their (filtered) search in the "included" tab, plus any articles excluded by the filter in the "excluded" tab users can select which columns they want to view (but all will be in the download).  

* `mod_download.R` parses the search terms, filters and results in an excel file that users can download.  
