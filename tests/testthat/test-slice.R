con <- magnitude(system.file("magnitude/w2v_en_sample.magnitude", package = "apportita"))

test_that("slice works", {
  expect_equal(slice_n(con, n = 2, offset = 5),
               slice_index(con, index = c(6, 7)))
  expect_equal(dim(slice_frac(con, frac = .01)), c(127, 21))
})

close(con)
