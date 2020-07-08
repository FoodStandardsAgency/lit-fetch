context("searches")

# testing a search that should return results

searchtest <- "allergy AND (soy OR \"peanut butter\")"

test_that("search to filter", {
  filterterm <- search2filter(searchtest)
  expect_equal(filterterm,
               "grepl(\"allergy\", ., ignore.case = T) & (grepl(\"soy\", ., ignore.case = T) | grepl(\"peanut butter\", ., ignore.case = T))")
})

test_that("xml to tibble", {
  xtib <- xml2tib(xml2::read_xml("testxml.xml"), "ArticleTitle, Author LastName")
  expect_is(xtib, "tbl")
  expect_equal(nrow(xtib), 2)
  expect_equal(ncol(xtib), 2)
  expect_equal(names(xtib), c("value", "field"))
  expect_equal(xtib$field, c("ArticleTitle", "LastName"))
  authorvec <- as.character(xtib[1,2])
  expect_is(authorvec, "character")
})

# pubmed

pmurl <- gen_url_pm(searchtest, startdate = "2019/07/01", enddate = "2020/06/30")
pmsearch <- search_pm(pmurl)
pmfetch <- fetch_pm(1, pmsearch)

test_that("pubmed URL generator", {

  expect_equal(pmurl, 
               "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&term=allergy[tiab]+AND+(soy[tiab]+OR+%22peanut+butter%22[tiab]+)&datetype=pdat&mindate=2019/07/01&maxdate=2020/06/30&usehistory=y")
  
})

test_that("pubmed esearch", {
  
  expect_is(pmsearch, "list")
  expect_length(pmsearch, 3)
  
})

test_that("pubmed fetch", {
  
  expect_lte(nrow(pmfetch), as.numeric(pmsearch$count))
  expect_is(pmfetch, "data.frame")
  
})

# testing a search that should (safely) return zero results

zerosearch <- "ahgodifgbhsjhebvhujfhdg"

zeropm <- get_pm(zerosearch)

test_that("pubmed safely returns zero searches", {
  
  expect_is(zeropm, "tbl")
  expect_equal(nrow(zeropm), 0)
  expect_equal(ncol(zeropm), 0)
  
})
