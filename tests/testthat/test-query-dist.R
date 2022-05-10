con <- magnitude(system.file("magnitude/w2v_en_sample.magnitude", package = "apportita"))

test_that("calc_dist works", {
  dist <- calc_dist(con, c("movie", "book") , c("dog", "movie"))
  expect_equal(dim(dist), c(2, 2))
  expect_equal(dist[2, 2], 0)
})

test_that("doesnt_match works", {
  expect_warning(doesnt_match(con, c("movie", "book") , c("dog", "movie")),
                 "length of `key` is not 1L. the first element will be used.")
  expect_equal(nrow(doesnt_match(con, "movie", c("dog", "movie"))), 1)
  dist <- doesnt_match(con, "movie", c("dog", "movie", "cat"), n = 2)
  expect_equal(nrow(dist), 2)
  expect_equal(dist$keys, c("dog", "cat"))
})

close(con)
