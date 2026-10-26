library(testthat)
library(data.table)

repo_root <- normalizePath(file.path(test_path(), "../.."), winslash = "/", mustWork = TRUE)
source(file.path(repo_root, "scripts/12_longitudinal_weights/longitudinal_propensity_utils.R"))

test_that("les formats usuels de trimestre sont normalises", {
  parsed <- parse_ene_quarter(c("24T2", "2024T3", "T4_2024", "2025_T1"))
  expect_equal(parsed$quarter_std, c("T2_2024", "T3_2024", "T4_2024", "T1_2025"))
  expect_equal(diff(parsed$quarter_index), rep(1L, 3L))
})

test_that("la rotation trimestrielle et annuelle est reconstruite sans censure a droite", {
  panel <- data.table(
    id_individu = c(
      "A", "A", "A", "A",
      "B", "B",
      "C", "C",
      "D"
    ),
    current_quarter = c(
      "24T2", "24T3", "25T2", "25T3",
      "24T2", "24T3",
      "24T2", "25T2",
      "25T3"
    ),
    rang_int = c(1, 2, 3, 4, 1, 2, 1, 3, 1),
    ageannee = 30,
    pmencor_ind = 100
  )

  origins <- build_longitudinal_origins(panel)

  expect_equal(origins[transition_id == "quarterly_rank1_rank2", .N], 3L)
  expect_equal(origins[transition_id == "quarterly_rank1_rank2", sum(response)], 2L)
  expect_equal(origins[transition_id == "quarterly_rank3_rank4", .N], 2L)
  expect_equal(origins[transition_id == "quarterly_rank3_rank4", sum(response)], 1L)
  expect_equal(origins[transition_id == "annual_rank1_rank3", .N], 3L)
  expect_equal(origins[transition_id == "annual_rank1_rank3", sum(response)], 2L)

  # L'origine D en 25T3 n'est eligible a aucune transition : les destinations
  # 25T4 et 26T3 ne sont pas observees dans la base.
  expect_false("D" %in% origins$.panel_id)
})

test_that("les rangs structurels ne contaminent pas les modeles", {
  panel <- data.table(
    id_individu = paste0("I", seq_len(80)),
    current_quarter = rep(c("24T2", "24T3"), each = 40),
    rang_int = rep(c(1L, 2L), each = 40),
    ageannee = 25,
    pmencor_ind = 100
  )
  # Vingt repondants parmi les 40 origines.
  panel[id_individu %in% paste0("I", 1:20) & current_quarter == "24T3", rang_int := 2L]
  panel[id_individu %in% paste0("I", 21:40) & current_quarter == "24T3", id_individu := paste0("J", 21:40)]

  origins <- build_longitudinal_origins(panel)
  quarterly <- origins[transition_id == "quarterly_rank1_rank2"]
  expect_true(all(quarterly$origin_rank == 1L))
  expect_true(all(quarterly$.rank == 1L))
})

test_that("le logit et les poids restent auditables", {
  set.seed(42)
  n <- 240L
  sample <- data.table(
    response = rep(c(0L, 1L), each = n / 2L),
    sexe = rep(c("1", "2"), n / 2L),
    ageannee = runif(n, 15, 65),
    model_id = "test_window",
    transition_id = "quarterly_rank1_rank2",
    horizon = "quarterly",
    origin_quarter = "T2_2024",
    destination_quarter = "T3_2024",
    pmencor_ind = runif(n, 50, 150)
  )
  fitted <- estimate_propensities_by_window(
    sample,
    categorical = "sexe",
    numeric = "ageannee",
    min_level_count = 10L
  )
  expect_true(all(fitted$data$probability_used > 0 & fitted$data$probability_used < 1))
  expect_length(fitted$models, 1L)

  weighted <- attach_longitudinal_weights(fitted$data, "pmencor_ind", 0.99)
  expect_true(all(is.na(weighted[response == 0L]$longitudinal_weight_raw)))
  expect_true(all(is.finite(weighted[response == 1L]$longitudinal_weight_trimmed)))
  expect_true(all(weighted$longitudinal_weight_trimmed <= weighted$trim_threshold, na.rm = TRUE))
})
