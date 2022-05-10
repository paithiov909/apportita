con <- magnitude(system.file("magnitude/w2v_en_sample.magnitude", package = "apportita"))

test_that("calc_simil works", {
  simil <- calc_simil(con, c("movie", "book"), c("dog", "movie"))
  expect_equal(dim(simil), c(2, 2))
  expect_equal(simil[2, 2], 1)
})

test_that("most_similar works", {
  expect_warning(
    most_similar(con, c("movie", "book"), c("dog", "movie")),
    "length of `key` is not 1L. the first element will be used."
  )
  expect_equal(nrow(most_similar(con, "movie", c("dog", "movie"))), 1)
  simil <- most_similar(con, "movie", c("dog", "movie", "cat"), n = 2)
  expect_equal(nrow(simil), 2)
  expect_equal(simil$keys, c("cat", "dog"))
})

close(con)
