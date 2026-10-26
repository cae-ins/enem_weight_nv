#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(arrow)
  library(data.table)
  library(haven)
  library(yaml)
})

script_file <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
script_path <- if (length(script_file)) {
  normalizePath(sub("^--file=", "", script_file[[1L]]), winslash = "/", mustWork = TRUE)
} else {
  normalizePath("scripts/12_longitudinal_weights/01_estimate_return_probabilities.R", winslash = "/", mustWork = TRUE)
}
repo_root <- normalizePath(file.path(dirname(script_path), "../.."), winslash = "/", mustWork = TRUE)
source(file.path(repo_root, "scripts/12_longitudinal_weights/longitudinal_propensity_utils.R"))

argument_value <- function(name, default = NULL) {
  args <- commandArgs(trailingOnly = TRUE)
  exact <- which(args == name)
  if (length(exact) && exact[[1L]] < length(args)) return(args[[exact[[1L]] + 1L]])
  prefixed <- grep(paste0("^", name, "="), args, value = TRUE)
  if (length(prefixed)) return(sub(paste0("^", name, "="), "", prefixed[[1L]]))
  default
}

config_path <- argument_value(
  "--config",
  file.path(repo_root, "config/longitudinal_propensity.yml")
)
config <- yaml::read_yaml(config_path)

input_path <- argument_value("--input", Sys.getenv("ENE_LONGITUDINAL_INPUT", unset = NA_character_))
if (is.na(input_path) || !nzchar(input_path)) {
  stop(
    "Fournir --input chemin/base.dta (ou definir ENE_LONGITUDINAL_INPUT).",
    call. = FALSE
  )
}
if (!file.exists(input_path)) stop("Fichier d'entree introuvable : ", input_path, call. = FALSE)

output_dir <- argument_value(
  "--output-dir",
  file.path(repo_root, config$outputs$directory)
)
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

columns <- config$columns
required <- unlist(columns[c("individual_id", "quarter", "interview_rank", "age", "origin_weight")])
optional <- unique(c(
  columns$household_id,
  unlist(config$model$categorical_covariates),
  unlist(config$model$numeric_covariates)
))
input_columns <- unique(c(required, optional))

extension <- tolower(tools::file_ext(input_path))
raw_data <- switch(
  extension,
  dta = haven::read_dta(input_path, col_select = tidyselect::any_of(input_columns)),
  parquet = arrow::read_parquet(input_path, col_select = input_columns),
  stop("Format d'entree non pris en charge : ", extension, call. = FALSE)
)
raw_data <- data.table::as.data.table(raw_data)
assert_columns(raw_data, required, "la base d'entree")

age <- suppressWarnings(as.numeric(raw_data[[columns$age]]))
raw_data <- raw_data[is.finite(age) & age >= as.numeric(config$population$minimum_age)]
raw_data <- add_age_group(raw_data, columns$age)

origins <- build_longitudinal_origins(
  raw_data,
  id_col = columns$individual_id,
  quarter_col = columns$quarter,
  rank_col = columns$interview_rank
)

available_categorical <- intersect(
  unlist(config$model$categorical_covariates),
  names(origins)
)
available_numeric <- intersect(
  unlist(config$model$numeric_covariates),
  names(origins)
)
missing_covariates <- setdiff(
  c(unlist(config$model$categorical_covariates), unlist(config$model$numeric_covariates)),
  names(origins)
)
if (length(missing_covariates)) {
  warning(
    "Covariables absentes, donc exclues : ",
    paste(missing_covariates, collapse = ", "),
    call. = FALSE
  )
}

estimated <- estimate_propensities_by_window(
  origins,
  categorical = available_categorical,
  numeric = available_numeric,
  min_level_count = as.integer(config$model$minimum_level_count),
  probability_epsilon = as.numeric(config$model$probability_epsilon),
  max_iterations = as.integer(config$model$maximum_iterations)
)
weighted <- attach_longitudinal_weights(
  estimated$data,
  base_weight_col = columns$origin_weight,
  trim_quantile = as.numeric(config$weights$winsorization_quantile)
)
diagnostics <- longitudinal_diagnostics(weighted)

probability_output <- weighted[, .(
  id_individu = .panel_id,
  model_id,
  transition_id,
  horizon,
  origin_quarter,
  destination_quarter,
  origin_rank,
  destination_rank,
  response,
  origin_cross_sectional_weight,
  probability_raw,
  probability_used,
  probability_clipped,
  ipw_factor,
  longitudinal_weight_raw,
  longitudinal_weight_trimmed,
  weight_trimmed,
  trim_threshold
)]

probability_path <- file.path(output_dir, config$outputs$probabilities_file)
diagnostics_path <- file.path(output_dir, config$outputs$diagnostics_file)
models_path <- file.path(output_dir, config$outputs$models_file)
arrow::write_parquet(probability_output, probability_path)
arrow::write_parquet(diagnostics, diagnostics_path)
saveRDS(
  list(
    created_at = format(Sys.time(), tz = "UTC", usetz = TRUE),
    input = normalizePath(input_path, winslash = "/", mustWork = TRUE),
    config = config,
    models = estimated$models
  ),
  models_path
)

print(diagnostics)
cat("\nSorties creees :\n")
cat("- ", probability_path, "\n", sep = "")
cat("- ", diagnostics_path, "\n", sep = "")
cat("- ", models_path, "\n", sep = "")
