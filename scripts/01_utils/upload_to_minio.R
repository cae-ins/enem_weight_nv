#!/usr/bin/env Rscript
# Upload data/Excel files to a MinIO (S3-compatible) bucket using aws-cli or mc (MinIO client)
# Usage (example):
# Rscript scripts/01_utils/upload_to_minio.R --sourcedir data --bucket my-bucket --prefix repo_backup --endpoint https://minio.example.org:9000 --dryrun

args <- commandArgs(trailingOnly = TRUE)

print_help <- function() {
  cat("upload_to_minio.R - upload data/Excel files to MinIO (S3-compatible)\n\n")
  cat("Options:\n")
  cat("  --sourcedir    Path to source folder (default: data)\n")
  cat("  --bucket       Target bucket name (or set MINIO_BUCKET env var)\n")
  cat("  --prefix       Optional key prefix inside the bucket\n")
  cat("  --endpoint     MinIO endpoint URL (or set MINIO_ENDPOINT env var)\n")
  cat("  --accesskey    MinIO access key (or set MINIO_ACCESS_KEY env var)\n")
  cat("  --secretkey    MinIO secret key (or set MINIO_SECRET_KEY env var)\n")
  cat("  --dryrun       If set, only print planned uploads\n")
  cat("  --parquet      Convert matched .dta files to parquet and upload parquet instead of the original\n")
  cat("  --help         Show this help\n")
}

parse_args <- function(args) {
  opts <- list(
    sourcedir = "data",
    bucket = Sys.getenv('MINIO_BUCKET', ''),
    prefix = "",
    endpoint = Sys.getenv('MINIO_ENDPOINT', 'https://192.168.1.230:32639'),
    accesskey = Sys.getenv('MINIO_ACCESS_KEY', ''),
    secretkey = Sys.getenv('MINIO_SECRET_KEY', ''),
    dryrun = FALSE,
    parquet = FALSE
  )
  i <- 1
  while (i <= length(args)) {
    a <- args[i]
    if (a %in% c('--help','-h')) { print_help(); quit(status = 0) }
    if (a == '--sourcedir') { i <- i + 1; opts$sourcedir <- args[i] }
    else if (a == '--bucket') { i <- i + 1; opts$bucket <- args[i] }
    else if (a == '--prefix') { i <- i + 1; opts$prefix <- args[i] }
    else if (a == '--endpoint') { i <- i + 1; opts$endpoint <- args[i] }
    else if (a == '--accesskey') { i <- i + 1; opts$accesskey <- args[i] }
    else if (a == '--secretkey') { i <- i + 1; opts$secretkey <- args[i] }
    else if (a == '--dryrun') { opts$dryrun <- TRUE }
    else if (a == '--parquet') { opts$parquet <- TRUE }
    else { cat('Unknown argument:', a, '\n'); print_help(); quit(status=1) }
    i <- i + 1
  }
  opts
}

opts <- parse_args(args)

if (!dir.exists(opts$sourcedir)) stop(sprintf("SourceDir '%s' n'existe pas.", opts$sourcedir))
if (opts$bucket == "") stop("Nom du bucket non fourni. Passez --bucket ou définissez MINIO_BUCKET env var.")
if (opts$endpoint == "") stop("Endpoint MinIO non fourni. Passez --endpoint ou définissez MINIO_ENDPOINT env var.")

message(sprintf("Source: %s", opts$sourcedir))
message(sprintf("Bucket: %s", opts$bucket))
if (nzchar(opts$prefix)) message(sprintf("Prefix: %s", opts$prefix))
message(sprintf("Endpoint: %s", opts$endpoint))
if (opts$dryrun) message("DRY RUN: aucun fichier ne sera uploadé")
if (opts$parquet) message("PARQUET: conversion activée pour fichiers .dta identifiés")

exts <- c('dta','csv','xlsx','xls','sav','rds')
all_files <- list.files(opts$sourcedir, recursive = TRUE, full.names = TRUE)
files <- all_files[tolower(tools::file_ext(all_files)) %in% exts]

if (length(files) == 0) {
  message(sprintf("Aucun fichier trouvé pour les extensions: %s", paste(exts, collapse=", ")))
  quit(save = 'no', status = 0)
}

# --- Option: convert certain .dta files to parquet (quarterly calibrated and annual) ---
convert_candidates <- character(0)
if (opts$parquet) {
  # Choose .dta files only
  dta_files <- files[tolower(tools::file_ext(files)) == 'dta']
  if (length(dta_files) > 0) {
    for (f in dta_files) {
      fn <- basename(f)
      path_lower <- tolower(f)
      # heuristics: calibrated quarterly files often contain "_cal" or live in a folder named "calibrated_weights"
      is_calibrated <- grepl('_cal(\\.|_)', tolower(fn), perl = TRUE) || grepl('/calibrated_weights/', path_lower, fixed = TRUE)
      # heuristics for annual files: folder or filename contains 'annual' or 'annuel' or 'annuels' or 'yearly'
      is_annual <- grepl('annual|annuel|annuels|yearly', path_lower)
      if (is_calibrated || is_annual) {
        convert_candidates <- c(convert_candidates, f)
      }
    }
  }
}

if (length(convert_candidates) > 0) {
  # check arrow availability
  if (!requireNamespace('arrow', quietly = TRUE)) {
    warning('Package arrow non installé — impossible de convertir en parquet. Installez arrow pour activer la conversion.')
  } else {
    for (f in unique(convert_candidates)) {
      parquet_path <- sub('\\.[dD][tT][aA]$', '.parquet', f)
      if (opts$dryrun) {
        message(sprintf('DRY -> Convert %s -> %s (will upload parquet instead of original)', f, parquet_path))
        next
      }
      message(sprintf('Converting %s -> %s', f, parquet_path))
      # read with haven and write with arrow
      tryCatch({
        df <- haven::read_dta(f)
        # ensure arrow writes parent dir exists
        dir.create(dirname(parquet_path), recursive = TRUE, showWarnings = FALSE)
        arrow::write_parquet(df, parquet_path)
      }, error = function(e) {
        warning(sprintf('Échec conversion %s : %s', f, e$message))
      })
        # replace original with parquet in upload list (upload parquet instead of original)
        if (f %in% files) {
          files[files == f] <- parquet_path
        } else {
          files <- c(files, parquet_path)
        }
    }
  }
}

which_aws <- Sys.which('aws')
which_mc  <- Sys.which('mc')

norm_source <- normalizePath(opts$sourcedir, winslash = '/', mustWork = TRUE)

relpath <- function(fullpath) {
  p <- normalizePath(fullpath, winslash = '/', mustWork = TRUE)
  ns <- norm_source
  # remove trailing slash from source if any
  ns <- sub('/+$', '', ns)
  if (startsWith(p, paste0(ns, '/'))) {
    rel <- substring(p, nchar(ns) + 2)
  } else if (startsWith(p, ns)) {
    rel <- substring(p, nchar(ns) + 2)
  } else {
    rel <- p
  }
  # normalize separators and remove leading slashes
  rel <- gsub('\\\\', '/', rel)
  rel <- sub('^/+', '', rel)
  rel
}

if (nzchar(which_aws)) {
  message('aws CLI trouvé. Utilisation de aws s3 --endpoint-url ...')
  for (f in files) {
    rel <- relpath(f)
    key <- if (nzchar(opts$prefix)) paste0(opts$prefix, '/', rel) else rel
    key <- gsub('\\\\','/', key)
    dest <- paste0('s3://', opts$bucket, '/', key)
    if (opts$dryrun) {
      cat(sprintf('DRY -> aws --endpoint-url %s s3 cp "%s" "%s"\n', opts$endpoint, f, dest))
    } else {
      message(sprintf('Uploading %s -> %s', rel, dest))
      env <- character()
      if (nzchar(opts$accesskey)) env <- c(env, sprintf('AWS_ACCESS_KEY_ID=%s', opts$accesskey))
      if (nzchar(opts$secretkey)) env <- c(env, sprintf('AWS_SECRET_ACCESS_KEY=%s', opts$secretkey))
      args <- c('--endpoint-url', opts$endpoint, 's3', 'cp', f, dest)
      status <- system2('aws', args = args, env = env)
      if (status != 0) warning(sprintf('Upload échoué pour %s (exit %s)', rel, status))
    }
  }
  message('Terminé (aws).')
  quit(save='no', status = 0)
}

if (nzchar(which_mc)) {
  message("MinIO client 'mc' trouvé. Création d'un alias temporaire 'tmpminio'.")
  alias <- 'tmpminio'
  # mc alias set tmpminio <endpoint> <access> <secret> --api S3v4
  if (opts$dryrun) {
    for (f in files) {
      rel <- relpath(f)
      dest <- sprintf('%s/%s/%s', alias, opts$bucket, ifelse(nzchar(opts$prefix), paste0(opts$prefix, '/', rel), rel))
      dest <- gsub('//', '/', dest)
      cat(sprintf('DRY -> mc cp "%s" "%s"\n', f, dest))
    }
    quit(save='no', status=0)
  }
  # set alias
  setcmd <- c('alias', 'set', alias, opts$endpoint, opts$accesskey, opts$secretkey, '--api', 'S3v4')
  sc <- system2('mc', args = setcmd)
  if (sc != 0) stop('Impossible de créer alias mc (mc alias set a échoué).')
  for (f in files) {
    rel <- relpath(f)
    dest <- sprintf('%s/%s/%s', alias, opts$bucket, ifelse(nzchar(opts$prefix), paste0(opts$prefix, '/', rel), rel))
    dest <- gsub('//', '/', dest)
    message(sprintf('Uploading %s -> %s', rel, dest))
    # mc cp --preserve <file> <dest>
    status <- system2('mc', args = c('cp', '--preserve', f, dest))
    if (status != 0) warning(sprintf('Upload échoué pour %s (exit %s)', rel, status))
  }
  message('Terminé (mc).')
  quit(save='no', status = 0)
}

stop("Ni 'aws' ni 'mc' n'ont été trouvés sur le système. Installez aws-cli ou mc (minio client).")
