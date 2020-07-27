context("searches")

# testing a search that should return results

searchtest <- "allergy AND (soy OR \"peanut butter\")"

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

pmurl <- gen_url_pm(searchtest, datefrom = as.Date("2019-07-01"), dateto = as.Date("2020-06-30"))
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

# scopus

scopusurl <- gen_url_scopus(searchtest, datefrom = as.Date("2019-07-01"), dateto = as.Date("2020-06-30"))

test_that("scopus URL", {
  
  expect_equal(scopusurl, 
               "https://api.elsevier.com/content/search/scopus?query=title-abs-key(allergy+AND+(soy+OR+%22peanut+butter%22))&date=2019-2020&view=COMPLETE&count=25&cursor=*")
  
})

scopussearch <- get_scopus(searchtest)

test_that("scopus search",{
  
  expect_is(scopussearch, "data.frame")
  expect_gte(nrow(scopussearch), 50)
  expect_equal(ncol(scopussearch), 10)
  
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
