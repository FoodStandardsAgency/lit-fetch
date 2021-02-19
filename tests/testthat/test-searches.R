context("searches")

# --- xml2tib ---
searchtest <- "allergy AND (soy OR \"peanut butter\")"

test_that("xml to tibble", {
  xtib <-
    xml2tib(
      xml2::read_xml("testxml.xml"),
      "ArticleTitle, Author LastName",
      "ArticleTitle"
    )
  expect_is(xtib, "tbl")
  expect_equal(nrow(xtib), 1)
  expect_equal(ncol(xtib), 2)
  expect_equal(names(xtib), c("ArticleTitle", "LastName"))
  # expect_equal(xtib$field, c("ArticleTitle", "LastName"))
  
  coltypes <- dplyr::summarise_all(xtib, class)
  expect_is(as.character(coltypes[1,1]), "character")
  expect_is(as.character(coltypes[1,2]), "character")
})


# --- PUBMED ---
pmurl <-
  gen_url_pm(searchtest,
    datefrom = as.Date("2019-07-01"),
    dateto = as.Date("2020-06-30")
  )
pmsearch <- search_pm(pmurl)
pmfetch <- fetch_pm(1, pmsearch)
pmget <-
  get_pm(searchtest,
    datefrom = as.Date("2019-07-01"),
    dateto = as.Date("2020-06-30")
  )

test_that("expected pubmed URL is generated", {
  expect_equal(
    pmurl,
    "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=allergy[tiab]+AND+(soy[tiab]+OR+%22peanut+butter%22[tiab])&datetype=pdat&mindate=2019/07/01&maxdate=2020/06/30&usehistory=y"
  )
})

test_that("pubmed search returns a list of three items", {
  expect_is(pmsearch, "list")
  expect_length(pmsearch, 3)
})

test_that("pubmed fetch returns data frame with expected number of articles", {
  expect_lte(nrow(pmfetch), as.numeric(pmsearch$count))
  expect_is(pmfetch, "data.frame")
})

test_that("get_pubmed returns dataframe with expected rows/cols", {
  expect_is(pmget, "data.frame")
  expect_gte(nrow(pmget), 25)
  expect_equal(ncol(pmget), 10)
})


#  --- SCOPUS ---
scopusurl <-
  gen_url_scopus(searchtest,
    datefrom = as.Date("2019-07-01"),
    dateto = as.Date("2020-06-30")
  )
scopuspage <- get_scopus_result(gen_url_scopus(searchtest))
scopussearch <- get_scopus(searchtest)

test_that("expected scopus URL is generated", {
  expect_equal(
    scopusurl,
    "https://api.elsevier.com/content/search/scopus?query=title-abs-key(allergy+AND+(soy+OR+%22peanut+butter%22))&date=2019-2020&view=COMPLETE&count=25&cursor=*"
  )
})

test_that("scopus fetches expected number of rows (25)", {
  expect_equal(nrow(scopuspage[[1]]), 25)
})

test_that("scopus search returns a dataframe with expected rows/cols", {
  expect_is(scopussearch, "data.frame")
  expect_gte(nrow(scopussearch), 50)
  expect_equal(ncol(scopussearch), 11)
})


# --- SPRINGER ---
springurl <-
  gen_url_springer("botulism",
    datefrom = as.Date("2019-07-01"),
    dateto = as.Date("2020-06-30")
  )

hitcount <- httr::GET(springurl) %>%
  content(., "text") %>%
  jsonlite::fromJSON() %>%
  .$result %>%
  .$total %>%
  as.numeric()

returns <- get_results_springer(1, springurl) %>% nrow()

test_that("springer fetches total", {
  expect_equal(hitcount, returns)
})



# testing a search that should (safely) return zero results

zerosearch <- "ahgodifgbhsjhebvhujfhdg"

zeropm <- get_pm(zerosearch)

test_that("pubmed safely returns zero searches", {
  expect_is(zeropm, "tbl")
  expect_equal(nrow(zeropm), 0)
  expect_equal(ncol(zeropm), 1)
})

zerospringer <- get_springer(zerosearch)

test_that("springer safely returns zero searches", {
  expect_is(zerospringer, "tbl")
  expect_equal(nrow(zerospringer), 0)
  expect_equal(ncol(zerospringer), 1)
})

zeroscopus <- get_scopus(zerosearch)

test_that("scopus safely returns zero searches", {
  expect_is(zeroscopus, "tbl")
  expect_equal(nrow(zeroscopus), 0)
  expect_equal(ncol(zeroscopus), 1)
})
