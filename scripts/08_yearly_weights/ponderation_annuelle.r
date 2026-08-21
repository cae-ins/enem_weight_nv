# ============================================================
# Production des poids annuels ENE
# Purpose: empiler les poids trimestriels officiels et les diviser par K
# Inputs: data/04_weights/T{1..4}_{year}/calibrated_weights/*.dta
# Outputs: DTA de compatibilite, Parquet principal, manifeste JSON et QC CSV
# ============================================================

suppressPackageStartupMessages({
  library(arrow)
  library(dplyr)
  library(haven)
  library(jsonlite)
  library(ReGenesees)
})

parse_args <- function(args = commandArgs(trailingOnly = TRUE)) {
  values <- list(year = "2025", base_dir = ".", strategy = "180X_1D")
  for (arg in args) {
    if (grepl("^--year=", arg)) {
      values$year <- sub("^--year=", "", arg)
    } else if (grepl("^--base-dir=", arg)) {
      values$base_dir <- sub("^--base-dir=", "", arg)
    } else if (grepl("^--strategy=", arg)) {
      values$strategy <- sub("^--strategy=", "", arg)
    } else {
      stop("Option inconnue : ", arg, call. = FALSE)
    }
  }
  if (!grepl("^[0-9]{4}$", values$year)) {
    stop("--year doit etre au format YYYY.", call. = FALSE)
  }
  if (!grepl("^[A-Za-z0-9_-]+$", values$strategy)) {
    stop("--strategy contient des caracteres invalides.", call. = FALSE)
  }
  values
}

stata_key <- function(value) {
  if (!inherits(value, "haven_labelled")) {
    return(as.character(value))
  }
  labels <- attr(value, "labels", exact = TRUE)
  raw <- as.character(haven::zap_labels(value))
  if (is.null(labels) || length(labels) == 0L) {
    return(raw)
  }
  label_lookup <- stats::setNames(names(labels), as.character(unname(labels)))
  labelled <- unname(label_lookup[raw])
  labelled[is.na(labelled)] <- raw[is.na(labelled)]
  labelled
}

assert_required_columns <- function(data, required, source_path) {
  missing_columns <- setdiff(required, names(data))
  if (length(missing_columns) > 0L) {
    stop(
      "Variables absentes de ", source_path, " : ",
      paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }
}

assert_nonblank_columns <- function(data, columns, label) {
  invalid <- vapply(
    data[, columns, drop = FALSE],
    function(value) is.na(value) | !nzchar(trimws(as.character(value))),
    logical(nrow(data))
  )
  if (any(invalid)) {
    stop("Cle manquante ou blanche dans ", label, ".", call. = FALSE)
  }
}

assert_unique_annual_key <- function(data) {
  key_columns <- c("trimestre", "interview_key", "membres_id")
  key_data <- data[, key_columns, drop = FALSE]
  blank_key <- vapply(
    key_data,
    function(value) is.na(value) | !nzchar(trimws(as.character(value))),
    logical(nrow(key_data))
  )
  if (any(blank_key)) {
    stop("La cle annuelle contient des valeurs manquantes.", call. = FALSE)
  }
  annual_key <- paste(
    data$trimestre,
    data$interview_key,
    data$membres_id,
    sep = "::"
  )
  if (anyDuplicated(annual_key)) {
    stop(
      "La cle trimestre + interview_key + membres_id n'est pas unique.",
      call. = FALSE
    )
  }
}

write_atomic <- function(data, output_path, writer, fileext) {
  dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
  staging_path <- tempfile(
    pattern = paste0(basename(output_path), "_"),
    tmpdir = dirname(output_path),
    fileext = fileext
  )
  on.exit(unlink(staging_path), add = TRUE)
  writer(data, staging_path)
  copied <- suppressWarnings(file.copy(
    staging_path,
    output_path,
    overwrite = TRUE
  ))
  if (!isTRUE(copied)) {
    stop("Impossible de remplacer ", output_path, call. = FALSE)
  }
  invisible(output_path)
}

verify_calibrated_weights <- function(data, calibration_path, tolerance = 1e-10) {
  calibration_environment <- new.env(parent = emptyenv())
  loaded <- load(calibration_path, envir = calibration_environment)
  candidates <- loaded[vapply(loaded, function(name) {
    inherits(calibration_environment[[name]], "cal.analytic")
  }, logical(1))]
  if (length(candidates) != 1L) {
    stop(
      "L'image de calibration doit contenir exactement un objet cal.analytic : ",
      calibration_path,
      call. = FALSE
    )
  }
  design <- calibration_environment[[candidates[[1L]]]]
  if (!"INDKEY" %in% names(design$variables)) {
    stop("INDKEY absent de l'objet cal.analytic : ", calibration_path, call. = FALSE)
  }
  reference <- data.frame(
    INDKEY = stata_key(design$variables$INDKEY),
    calibrated_weight = as.numeric(ReGenesees::weights(design)),
    stringsAsFactors = FALSE
  )
  observed <- data.frame(
    INDKEY = stata_key(data$INDKEY),
    published_weight = suppressWarnings(as.numeric(data$FINAL_WEIGHT)),
    stringsAsFactors = FALSE
  )
  invalid_reference_key <- is.na(reference$INDKEY) |
    !nzchar(trimws(reference$INDKEY))
  invalid_observed_key <- is.na(observed$INDKEY) |
    !nzchar(trimws(observed$INDKEY))
  if (any(invalid_reference_key) || anyDuplicated(reference$INDKEY) ||
      any(invalid_observed_key) || anyDuplicated(observed$INDKEY)) {
    stop("INDKEY manquant ou duplique pendant la verification de calibration.", call. = FALSE)
  }
  matched <- match(observed$INDKEY, reference$INDKEY)
  if (anyNA(matched) || nrow(observed) != nrow(reference)) {
    stop(
      "Les individus du poids publie ne correspondent pas a l'objet de calibration : ",
      calibration_path,
      call. = FALSE
    )
  }
  relative_delta <- abs(
    observed$published_weight - reference$calibrated_weight[matched]
  ) / pmax(abs(reference$calibrated_weight[matched]), .Machine$double.eps)
  maximum <- max(relative_delta)
  if (!is.finite(maximum) || maximum > tolerance) {
    stop(
      "Le poids publie ne correspond pas a l'objet de calibration ",
      calibration_path, " : ecart relatif maximal = ", maximum,
      call. = FALSE
    )
  }
  maximum
}

args <- parse_args()
project_root <- normalizePath(args$base_dir, winslash = "/", mustWork = TRUE)
weights_root <- file.path(project_root, "data", "04_weights")
quarters <- paste0("T", 1L:4L)

source_paths <- file.path(
  weights_root,
  paste0(quarters, "_", args$year),
  "calibrated_weights",
  paste0("individu_", quarters, "_", args$year, "_CAL.dta")
)
calibration_paths <- file.path(
  project_root,
  "data", "07_QUARTERLY_WEIGHTING", args$year, quarters, args$strategy,
  paste0(
    "LFS_CALIBRATION_", args$year, "_", quarters, "_",
    args$strategy, "_IMAGE.RData"
  )
)
available <- file.exists(source_paths)
if (!all(available)) {
  stop(
    "Les quatre poids trimestriels sont obligatoires pour une estimation ",
    "annuelle. Fichiers absents : ",
    paste(source_paths[!available], collapse = ", "),
    call. = FALSE
  )
}
available_calibration <- file.exists(calibration_paths)
if (!all(available_calibration)) {
  stop(
    "Les quatre objets de calibration ", args$strategy,
    " sont obligatoires. Fichiers absents : ",
    paste(calibration_paths[!available_calibration], collapse = ", "),
    call. = FALSE
  )
}
n_quarters <- length(quarters)

required_columns <- c(
  "INDKEY", "interview_key", "membres_id", "HHKEY",
  "PSUKEY", "STRATAKEY", "FINAL_WEIGHT"
)

quarterly_data <- vector("list", n_quarters)
quarterly_qc <- vector("list", n_quarters)
for (index in seq_len(n_quarters)) {
  source_path <- source_paths[[index]]
  quarter <- quarters[[index]]
  data <- haven::read_dta(
    source_path,
    col_select = dplyr::all_of(required_columns)
  )
  assert_required_columns(data, required_columns, source_path)
  quarterly_weight <- suppressWarnings(as.numeric(data$FINAL_WEIGHT))
  if (any(!is.finite(quarterly_weight) | quarterly_weight <= 0)) {
    stop(
      "FINAL_WEIGHT doit etre fini et strictement positif dans ",
      source_path,
      call. = FALSE
    )
  }
  calibration_delta <- verify_calibrated_weights(
    data,
    calibration_paths[[index]]
  )

  data <- data %>%
    mutate(
      across(
        c(INDKEY, interview_key, membres_id, HHKEY, PSUKEY, STRATAKEY),
        stata_key
      ),
      trimestre = paste0(substr(args$year, 3L, 4L), quarter),
      QUARTERLY_FINAL_WEIGHT = quarterly_weight,
      FINAL_WEIGHT = quarterly_weight / n_quarters
    ) %>%
    select(
      INDKEY, interview_key, membres_id, HHKEY, PSUKEY, STRATAKEY,
      trimestre, QUARTERLY_FINAL_WEIGHT, FINAL_WEIGHT
    )
  assert_nonblank_columns(
    data,
    c(
      "INDKEY", "interview_key", "membres_id", "HHKEY",
      "PSUKEY", "STRATAKEY", "trimestre"
    ),
    source_path
  )

  quarterly_data[[index]] <- data
  quarterly_qc[[index]] <- data.frame(
    quarter = quarter,
    rows = nrow(data),
    min_quarterly_weight = min(quarterly_weight),
    max_quarterly_weight = max(quarterly_weight),
    sum_annual_weight = sum(data$FINAL_WEIGHT),
    max_relative_calibration_difference = calibration_delta,
    stringsAsFactors = FALSE
  )
}

annual_weights <- dplyr::bind_rows(quarterly_data)
quality <- dplyr::bind_rows(quarterly_qc)
assert_unique_annual_key(annual_weights)

expected_annual <- annual_weights$QUARTERLY_FINAL_WEIGHT / n_quarters
relative_delta <- abs(annual_weights$FINAL_WEIGHT - expected_annual) /
  pmax(abs(expected_annual), .Machine$double.eps)
if (max(relative_delta) > 1e-12) {
  stop("Incoherence interne du calcul du poids annuel.", call. = FALSE)
}

output_dir <- file.path(weights_root, args$year)
output_stem <- paste0("LFS_WEIGHTS_", args$year)
dta_path <- file.path(output_dir, paste0(output_stem, ".dta"))
parquet_path <- file.path(output_dir, paste0(output_stem, ".parquet"))
quality_path <- file.path(output_dir, paste0(output_stem, "_quality.csv"))
manifest_path <- file.path(output_dir, paste0(output_stem, "_manifest.json"))

write_atomic(
  annual_weights,
  dta_path,
  function(data, path) haven::write_dta(data, path),
  ".dta"
)
write_atomic(
  annual_weights,
  parquet_path,
  function(data, path) {
    arrow::write_parquet(data, path, compression = "zstd")
  },
  ".parquet"
)
utils::write.csv(
  quality,
  quality_path,
  row.names = FALSE,
  fileEncoding = "UTF-8"
)

manifest <- list(
  year = args$year,
  created_at_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
  method = "direct pooled-quarter weighting: quarterly FINAL_WEIGHT / K",
  calibration_strategy = args$strategy,
  contributing_quarters = quarters,
  quarter_count = n_quarters,
  row_count = nrow(annual_weights),
  key = c("trimestre", "interview_key", "membres_id"),
  primary_format = "Apache Parquet (Zstandard)",
  parquet_file = basename(parquet_path),
  compatibility_file = basename(dta_path),
  source_files = basename(source_paths),
  source_md5 = unname(tools::md5sum(source_paths)),
  calibration_files = basename(calibration_paths),
  calibration_md5 = unname(tools::md5sum(calibration_paths)),
  max_relative_weight_difference = max(relative_delta)
)
jsonlite::write_json(
  manifest,
  manifest_path,
  auto_unbox = TRUE,
  pretty = TRUE
)

message(
  "Poids annuels ", args$year, " produits : ", nrow(annual_weights),
  " lignes, K = ", n_quarters, "."
)
message("Parquet principal : ", parquet_path)
message("DTA de compatibilite : ", dta_path)
