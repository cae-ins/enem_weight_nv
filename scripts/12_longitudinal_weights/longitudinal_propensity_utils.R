# ==============================================================================
# Probabilites de retour et poids longitudinaux ENE-M
# ==============================================================================
# Les cibles sont reconstruites a partir de la rotation observee :
#   - rang 1 -> rang 2, a un trimestre ;
#   - rang 3 -> rang 4, a un trimestre ;
#   - rang 1 -> rang 3, a quatre trimestres.
# Une ligne d'origine n'est eligible que si son trimestre de destination est
# present dans la base. Cela evite de coder les fins de fichier comme attrition.

`%||%` <- function(x, y) if (is.null(x)) y else x

assert_columns <- function(data, columns, context = "la base") {
  missing_columns <- setdiff(columns, names(data))
  if (length(missing_columns)) {
    stop(
      sprintf(
        "Colonnes absentes de %s : %s",
        context,
        paste(missing_columns, collapse = ", ")
      ),
      call. = FALSE
    )
  }
  invisible(TRUE)
}

parse_ene_quarter <- function(x) {
  raw <- toupper(trimws(as.character(x)))
  compact <- gsub("[-_ ]", "", raw)
  year <- quarter <- rep(NA_integer_, length(compact))

  for (i in seq_along(compact)) {
    value <- compact[[i]]
    if (is.na(value) || !nzchar(value)) next

    match_year_first <- regexec("^([0-9]{2}|[0-9]{4})T([1-4])$", value)
    parts <- regmatches(value, match_year_first)[[1L]]
    if (length(parts)) {
      year[[i]] <- as.integer(parts[[2L]])
      quarter[[i]] <- as.integer(parts[[3L]])
    } else {
      match_quarter_first <- regexec("^T([1-4])([0-9]{2}|[0-9]{4})$", value)
      parts <- regmatches(value, match_quarter_first)[[1L]]
      if (length(parts)) {
        quarter[[i]] <- as.integer(parts[[2L]])
        year[[i]] <- as.integer(parts[[3L]])
      }
    }

    if (!is.na(year[[i]]) && year[[i]] < 100L) year[[i]] <- 2000L + year[[i]]
  }

  invalid <- !is.na(raw) & nzchar(raw) & (is.na(year) | is.na(quarter))
  if (any(invalid)) {
    stop(
      sprintf(
        "Format de trimestre non reconnu : %s",
        paste(unique(raw[invalid]), collapse = ", ")
      ),
      call. = FALSE
    )
  }

  index <- ifelse(is.na(year), NA_integer_, year * 4L + quarter - 1L)
  data.frame(
    quarter_raw = raw,
    year = year,
    quarter_number = quarter,
    quarter_index = index,
    quarter_std = ifelse(is.na(year), NA_character_, sprintf("T%d_%04d", quarter, year)),
    stringsAsFactors = FALSE
  )
}

quarter_from_index <- function(index) {
  index <- as.integer(index)
  year <- index %/% 4L
  quarter <- index %% 4L + 1L
  sprintf("T%d_%04d", quarter, year)
}

default_transition_specs <- function() {
  data.frame(
    transition_id = c("quarterly_rank1_rank2", "quarterly_rank3_rank4", "annual_rank1_rank3"),
    horizon = c("quarterly", "quarterly", "annual"),
    origin_rank = c(1L, 3L, 1L),
    destination_rank = c(2L, 4L, 3L),
    quarter_gap = c(1L, 1L, 4L),
    stringsAsFactors = FALSE
  )
}

build_longitudinal_origins <- function(
    data,
    id_col = "id_individu",
    quarter_col = "current_quarter",
    rank_col = "rang_int",
    specs = default_transition_specs()) {
  assert_columns(data, c(id_col, quarter_col, rank_col))
  assert_columns(
    specs,
    c("transition_id", "horizon", "origin_rank", "destination_rank", "quarter_gap"),
    "la specification des transitions"
  )

  dt <- data.table::as.data.table(data.table::copy(data))
  dt[, `.panel_id` := as.character(get(id_col))]
  dt[, `.rank` := as.integer(get(rank_col))]
  parsed <- parse_ene_quarter(dt[[quarter_col]])
  dt[, `.quarter_index` := parsed$quarter_index]
  dt[, `.quarter_std` := parsed$quarter_std]

  if (anyNA(dt$.panel_id) || any(!nzchar(dt$.panel_id))) {
    stop("L'identifiant individuel est manquant ou vide.", call. = FALSE)
  }
  if (anyNA(dt$.quarter_index) || anyNA(dt$.rank)) {
    stop("Le trimestre ou le rang d'interrogation est manquant.", call. = FALSE)
  }
  duplicate_key <- dt[, .N, by = .(`.panel_id`, `.quarter_index`)][N > 1L]
  if (nrow(duplicate_key)) {
    stop(
      sprintf(
        "La cle individu-trimestre n'est pas unique (%d doublons).",
        nrow(duplicate_key)
      ),
      call. = FALSE
    )
  }

  observed_quarters <- unique(dt$.quarter_index)
  samples <- vector("list", nrow(specs))

  for (j in seq_len(nrow(specs))) {
    spec <- specs[j, , drop = FALSE]
    origins <- dt[
      .rank == as.integer(spec$origin_rank) &
        (.quarter_index + as.integer(spec$quarter_gap)) %in% observed_quarters
    ]
    if (!nrow(origins)) next

    origins[, destination_index := .quarter_index + as.integer(spec$quarter_gap)]
    destination <- unique(
      dt[
        .rank == as.integer(spec$destination_rank),
        .(.panel_id, destination_index = .quarter_index, destination_observed = 1L)
      ]
    )
    origins <- merge(
      origins,
      destination,
      by = c(".panel_id", "destination_index"),
      all.x = TRUE,
      sort = FALSE
    )
    origins[, response := data.table::fcoalesce(destination_observed, 0L)]
    origins[, destination_observed := NULL]
    origins[, `:=`(
      transition_id = as.character(spec$transition_id),
      horizon = as.character(spec$horizon),
      origin_rank = as.integer(spec$origin_rank),
      destination_rank = as.integer(spec$destination_rank),
      quarter_gap = as.integer(spec$quarter_gap),
      origin_quarter = .quarter_std,
      destination_quarter = quarter_from_index(destination_index)
    )]
    origins[, window_id := paste(origin_quarter, destination_quarter, sep = "__")]
    origins[, model_id := paste(transition_id, window_id, sep = "__")]
    samples[[j]] <- origins
  }

  result <- data.table::rbindlist(samples, use.names = TRUE, fill = TRUE)
  if (!nrow(result)) {
    stop("Aucune fenetre longitudinale complete n'a ete trouvee.", call. = FALSE)
  }
  data.table::setorder(result, transition_id, .quarter_index, .panel_id)
  result[]
}

add_age_group <- function(data, age_col = "ageannee") {
  result <- data.table::as.data.table(data.table::copy(data))
  if (!age_col %in% names(result)) return(result)
  age <- suppressWarnings(as.numeric(result[[age_col]]))
  result[, age_group_model := cut(
    age,
    breaks = c(15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, Inf),
    right = FALSE,
    include.lowest = TRUE
  )]
  result
}

learn_propensity_recipe <- function(data, categorical, numeric, min_level_count = 30L) {
  categorical <- intersect(categorical, names(data))
  numeric <- intersect(numeric, names(data))
  recipe <- list(categorical = list(), numeric = list())

  for (variable in categorical) {
    value <- as.character(data[[variable]])
    value[is.na(value) | !nzchar(trimws(value))] <- "__MISSING__"
    counts <- table(value)
    kept <- names(counts[counts >= min_level_count])
    mapped <- ifelse(value %in% kept, value, "__OTHER__")
    observed <- unique(mapped)
    if (length(observed) < 2L) next
    levels <- sort(unique(c(kept, "__MISSING__", "__OTHER__")))
    recipe$categorical[[variable]] <- list(kept = kept, levels = levels)
  }

  for (variable in numeric) {
    value <- suppressWarnings(as.numeric(data[[variable]]))
    value[!is.finite(value)] <- NA_real_
    if (all(is.na(value))) next
    median_value <- stats::median(value, na.rm = TRUE)
    imputed <- ifelse(is.na(value), median_value, value)
    if (!is.finite(stats::sd(imputed)) || stats::sd(imputed) == 0) next
    recipe$numeric[[variable]] <- list(
      median = median_value,
      add_missing_indicator = anyNA(value)
    )
  }
  recipe
}

apply_propensity_recipe <- function(data, recipe) {
  output <- data.frame(row.names = seq_len(nrow(data)))

  for (variable in names(recipe$categorical)) {
    rule <- recipe$categorical[[variable]]
    value <- as.character(data[[variable]])
    value[is.na(value) | !nzchar(trimws(value))] <- "__MISSING__"
    value[!value %in% rule$kept] <- "__OTHER__"
    output[[variable]] <- factor(value, levels = rule$levels)
  }

  for (variable in names(recipe$numeric)) {
    rule <- recipe$numeric[[variable]]
    value <- suppressWarnings(as.numeric(data[[variable]]))
    value[!is.finite(value)] <- NA_real_
    missing_value <- is.na(value)
    value[missing_value] <- rule$median
    output[[variable]] <- value
    if (isTRUE(rule$add_missing_indicator)) {
      output[[paste0(variable, "__missing")]] <- as.integer(missing_value)
    }
  }
  output
}

fit_propensity_model <- function(
    sample,
    categorical,
    numeric,
    min_level_count = 30L,
    probability_epsilon = 1e-6,
    max_iterations = 100L) {
  assert_columns(sample, "response", "l'echantillon du modele")
  response <- as.integer(sample$response)
  if (anyNA(response) || !all(response %in% 0:1)) {
    stop("La cible de retour doit etre binaire et sans valeur manquante.", call. = FALSE)
  }
  class_counts <- table(factor(response, levels = 0:1))
  if (any(class_counts < 20L)) {
    stop(
      sprintf("Modele non estimable : seulement %d non-retours et %d retours.", class_counts[[1L]], class_counts[[2L]]),
      call. = FALSE
    )
  }

  recipe <- learn_propensity_recipe(sample, categorical, numeric, min_level_count)
  prepared <- apply_propensity_recipe(sample, recipe)
  if (!ncol(prepared)) stop("Aucune covariable exploitable pour le modele.", call. = FALSE)

  matrix_full <- stats::model.matrix(~ ., data = prepared)
  variable_columns <- setdiff(colnames(matrix_full), "(Intercept)")
  nonconstant <- variable_columns[
    vapply(
      variable_columns,
      function(column) {
        value <- matrix_full[, column]
        is.finite(stats::sd(value)) && stats::sd(value) > sqrt(.Machine$double.eps)
      },
      logical(1L)
    )
  ]
  matrix_full <- matrix_full[, c("(Intercept)", nonconstant), drop = FALSE]
  qr_matrix <- qr(matrix_full, tol = 1e-10)
  independent <- sort(qr_matrix$pivot[seq_len(qr_matrix$rank)])
  model_matrix <- matrix_full[, independent, drop = FALSE]

  fit <- stats::glm.fit(
    x = model_matrix,
    y = response,
    family = stats::binomial(),
    control = stats::glm.control(maxit = max_iterations, epsilon = 1e-8)
  )
  if (!isTRUE(fit$converged)) stop("Le logit de retour n'a pas converge.", call. = FALSE)
  if (any(!is.finite(fit$coefficients))) {
    stop("Le logit contient des coefficients non finis.", call. = FALSE)
  }

  linear_predictor <- drop(model_matrix %*% fit$coefficients)
  probability_raw <- stats::plogis(linear_predictor)
  probability_used <- pmin(pmax(probability_raw, probability_epsilon), 1 - probability_epsilon)

  model <- list(
    fit = fit,
    recipe = recipe,
    matrix_columns = colnames(model_matrix),
    probability_epsilon = probability_epsilon,
    n = length(response),
    n_return = sum(response),
    response_rate = mean(response)
  )
  class(model) <- "ene_longitudinal_propensity"

  list(
    model = model,
    probability_raw = probability_raw,
    probability_used = probability_used,
    probability_clipped = probability_raw != probability_used
  )
}

estimate_propensities_by_window <- function(
    origins,
    categorical,
    numeric,
    min_level_count = 30L,
    probability_epsilon = 1e-6,
    max_iterations = 100L) {
  assert_columns(origins, c("model_id", "response"))
  dt <- data.table::as.data.table(data.table::copy(origins))
  dt[, `.model_row` := .I]
  models <- list()

  for (id in unique(dt$model_id)) {
    rows <- which(dt$model_id == id)
    fitted <- fit_propensity_model(
      dt[rows],
      categorical = categorical,
      numeric = numeric,
      min_level_count = min_level_count,
      probability_epsilon = probability_epsilon,
      max_iterations = max_iterations
    )
    dt[rows, `:=`(
      probability_raw = fitted$probability_raw,
      probability_used = fitted$probability_used,
      probability_clipped = fitted$probability_clipped
    )]
    models[[id]] <- fitted$model
  }
  dt[, `.model_row` := NULL]
  list(data = dt[], models = models)
}

attach_longitudinal_weights <- function(
    probabilities,
    base_weight_col = "pmencor_ind",
    trim_quantile = 0.99) {
  assert_columns(
    probabilities,
    c(base_weight_col, "response", "probability_used", "model_id")
  )
  if (!is.numeric(trim_quantile) || length(trim_quantile) != 1L ||
      !is.finite(trim_quantile) || trim_quantile <= 0 || trim_quantile >= 1) {
    stop("trim_quantile doit etre strictement compris entre 0 et 1.", call. = FALSE)
  }

  dt <- data.table::as.data.table(data.table::copy(probabilities))
  base_weight <- suppressWarnings(as.numeric(dt[[base_weight_col]]))
  invalid_weight <- !is.finite(base_weight) | base_weight <= 0
  dt[, origin_cross_sectional_weight := base_weight]
  dt[invalid_weight, origin_cross_sectional_weight := NA_real_]
  dt[, ipw_factor := 1 / probability_used]
  dt[, longitudinal_weight_raw := data.table::fifelse(
    response == 1L & !is.na(origin_cross_sectional_weight),
    origin_cross_sectional_weight * ipw_factor,
    NA_real_
  )]
  dt[, trim_threshold := {
    valid <- longitudinal_weight_raw[is.finite(longitudinal_weight_raw)]
    if (length(valid)) {
      as.numeric(stats::quantile(valid, probs = trim_quantile, names = FALSE, type = 7))
    } else {
      NA_real_
    }
  }, by = model_id]
  dt[, longitudinal_weight_trimmed := pmin(longitudinal_weight_raw, trim_threshold)]
  dt[, weight_trimmed := !is.na(longitudinal_weight_raw) &
       longitudinal_weight_raw > trim_threshold]
  dt[]
}

longitudinal_diagnostics <- function(weighted_data) {
  assert_columns(
    weighted_data,
    c(
      "model_id", "transition_id", "horizon", "origin_quarter",
      "destination_quarter", "response", "probability_raw",
      "probability_used", "probability_clipped", "longitudinal_weight_trimmed"
    )
  )
  dt <- data.table::as.data.table(weighted_data)
  dt[, {
    w <- longitudinal_weight_trimmed[response == 1L & is.finite(longitudinal_weight_trimmed)]
    list(
      n_origin = .N,
      n_return = sum(response),
      response_rate = mean(response),
      probability_min = min(probability_raw),
      probability_p01 = as.numeric(stats::quantile(probability_raw, 0.01, names = FALSE)),
      probability_median = stats::median(probability_raw),
      probability_p99 = as.numeric(stats::quantile(probability_raw, 0.99, names = FALSE)),
      probability_max = max(probability_raw),
      n_probability_clipped = sum(probability_clipped),
      n_weight_trimmed = sum(weight_trimmed, na.rm = TRUE),
      weight_trim_threshold = unique(trim_threshold)[1L],
      respondent_weight_ess = if (length(w)) sum(w)^2 / sum(w^2) else NA_real_
    )
  }, by = .(
    model_id,
    transition_id,
    horizon,
    origin_quarter,
    destination_quarter
  )]
}
