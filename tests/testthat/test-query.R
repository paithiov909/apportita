con <- magnitude(system.file("magnitude/w2v_en_sample.magnitude", package = "apportita"))

test_that("has_exact works", {
  expect_equal(
    has_exact(con, c("movie", "doggy")),
    tibble::tibble(keys = c("movie", "doggy"), exists = c(TRUE, FALSE))
  )
})

test_that("query works", {
  expect_equal(
    dim(query(con, c("movie", "cat"))),
    c(2, 21)
  )
})

test_that("calc_wrd works", {
  expect_type(
    calc_wrd(con, c("dog", "and", "cat"), c("dog", "and", "cat")),
    "double"
  )
})

close(con)
