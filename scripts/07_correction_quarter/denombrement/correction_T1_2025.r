.touba_t1_2025_correction_cache <- NULL

.touba_t1_2025_excel_path <- function() {
  base_dir <- if (exists("BASE_DIR", inherits = TRUE)) {
    get("BASE_DIR", inherits = TRUE)
  } else {
    "."
  }

  file.path(
    base_dir,
    "data", "01_raw", "Denombrement_update", "T1_2025",
    "SEG_BaseT12025_menage_Touba_6014_.xlsx"
  )
}

.normalize_column_key <- function(x) {
  x <- iconv(x, from = "", to = "ASCII//TRANSLIT")
  tolower(gsub("[^[:alnum:]]", "", x))
}

.find_column_index <- function(columns, aliases) {
  columns_key <- .normalize_column_key(columns)
  aliases_key <- .normalize_column_key(aliases)
  idx <- match(aliases_key, columns_key)
  idx <- idx[!is.na(idx)]

  if (length(idx) == 0) {
    return(NA_integer_)
  }

  idx[[1]]
}

.as_segment_number <- function(x) {
  suppressWarnings(as.numeric(gsub(",", ".", gsub("[^0-9,.-]", "", as.character(x)))))
}

.touba_t1_2025_segment1_correction <- function(path = .touba_t1_2025_excel_path()) {
  if (!is.null(.touba_t1_2025_correction_cache)) {
    return(.touba_t1_2025_correction_cache)
  }

  if (!file.exists(path)) {
    stop("Fichier Excel introuvable pour la correction TOUBA T1_2025: ", path)
  }

  segment_summary <- readxl::read_excel(path, sheet = "TCD")
  segment_col <- .find_column_index(
    names(segment_summary),
    c("Numero Segment", "NumeroSegment", "IDSeg", "ID Segment", "segment")
  )
  count_col <- .find_column_index(
    names(segment_summary),
    c("Nombre Menage", "Nombre Menage", "Nombre Ménage", "nb_mens_seg", "nb mens seg")
  )

  if (is.na(segment_col) || is.na(count_col)) {
    stop("Impossible d'identifier les colonnes segment/menages dans la feuille TCD: ", path)
  }

  segment_numbers <- .as_segment_number(segment_summary[[segment_col]])
  nb_mens_values <- suppressWarnings(as.numeric(segment_summary[[count_col]]))
  nb_mens_seg <- nb_mens_values[segment_numbers == 1][[1]]

  if (is.na(nb_mens_seg)) {
    stop("Impossible de lire le nombre de menages du segment 1 dans la feuille TCD: ", path)
  }

  detail <- readxl::read_excel(path, sheet = "Feuil1")
  idseg_col <- .find_column_index(names(detail), c("IDSeg", "ID Segment", "Numero Segment"))
  key_col <- .find_column_index(names(detail), c("interview__key", "interview_key"))
  zd_col <- .find_column_index(names(detail), c("HH8", "ZD"))

  if (any(is.na(c(idseg_col, key_col, zd_col)))) {
    stop("Impossible d'identifier IDSeg/interview_key/HH8 dans la feuille Feuil1: ", path)
  }

  detail_segment <- .as_segment_number(detail[[idseg_col]])
  detail_segment1 <- detail[detail_segment == 1, , drop = FALSE]
  detail_n <- nrow(detail_segment1)
  interview_key <- unique(stats::na.omit(as.character(detail_segment1[[key_col]])))
  zd <- unique(stats::na.omit(as.character(detail_segment1[[zd_col]])))

  if (length(interview_key) != 1 || length(zd) != 1) {
    stop("La feuille Feuil1 ne permet pas d'identifier une unique ZD TOUBA segment 1: ", path)
  }

  if (detail_n != nb_mens_seg) {
    warning(
      "Correction TOUBA T1_2025: la feuille TCD indique ", nb_mens_seg,
      " menages pour le segment 1, mais Feuil1 contient ", detail_n,
      " lignes. La valeur TCD est utilisee."
    )
  }

  correction <- list(
    interview_key = interview_key,
    region = 11319,
    depart = 11319046,
    souspref = 1131904604,
    ZD = zd,
    segment = 1,
    nb_mens_seg = as.numeric(nb_mens_seg)
  )

  .touba_t1_2025_correction_cache <<- correction
  correction
}

correction_taille_segment_par_interview_key <- function(data) {
  correction <- .touba_t1_2025_segment1_correction()
  matched <- as.character(data$interview_key) == correction$interview_key

  if (!any(matched, na.rm = TRUE)) {
    warning(
      "Correction TOUBA T1_2025 non appliquee: interview_key introuvable dans seg_counts: ",
      correction$interview_key
    )
    return(data)
  }

  data$nb_mens_seg[matched] <- correction$nb_mens_seg
  message(
    "Correction TOUBA T1_2025: nb_mens_seg = ", correction$nb_mens_seg,
    " pour interview_key ", correction$interview_key,
    " / ZD ", correction$ZD,
    " / segment ", correction$segment
  )

  data
}
