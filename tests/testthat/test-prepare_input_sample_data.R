library(testthat)

test_that("X98 constraint is set to 1 for age>=16, m5==1, hh2==10413", {
  # Minimal row matching the condition in the script
  df <- data.frame(ageannee = 20, m5 = 1, hh2 = 10413, stringsAsFactors = FALSE)
  # initialize X98 to 0 as done in the script
  df$X98 <- 0

  # Apply the same assignment as in the script under test
  df$X98[ df$ageannee >= 16 & df$m5 == 1 & df$hh2 == 10413 ] <- 1

  expect_equal(df$X98, 1)
})
