context("keys")

test_that("get springer key", {
  skey <- Sys.getenv("SPRINGER_API")
  lenkey <- nchar(skey)
  expect_gt(lenkey, 0)
})