# ==============================================================================
# Script_name : check_duplicates.R
# Title       : Check for Duplicates in ENE Survey Data
# Description : This script checks for duplicate records based on specified
#               key variables and provides detailed reporting
# Author      : Data Quality Check
# Date        : 24-06-2025
# ==============================================================================

# ------------------------------------------------------------------------------
# Load Required Libraries
# ------------------------------------------------------------------------------
library(dplyr)
library(haven)
library(janitor)

# ------------------------------------------------------------------------------
# Load Configuration (assuming same structure as your main script)
# ------------------------------------------------------------------------------
source("config/1_config.r")

DATA_DIR <- file.path(BASE_DIR, "data")
WEIGHTS_DIR <- file.path(DATA_DIR, "04_weights")
WEIGHTS_COLUMNS_PATH <- file.path(WEIGHTS_DIR, TARGET_QUARTER, "base_weights",
                                  paste0("base_weights_", TARGET_QUARTER, ".dta"))

# ------------------------------------------------------------------------------
# Function to Check for Duplicates
# ------------------------------------------------------------------------------
check_duplicates <- function(data, key_vars, dataset_name = "Dataset") {
  
  # Validate that key variables exist in the dataset
  missing_vars <- setdiff(key_vars, names(data))
  if (length(missing_vars) > 0) {
    stop(paste("Missing key variables:", paste(missing_vars, collapse = ", ")))
  }
  
  # Create a summary of the duplicate check
  cat(paste(rep("=", 80), collapse = ""), "\n")
  cat("DUPLICATE CHECK REPORT FOR:", dataset_name, "\n")
  cat(paste(rep("=", 80), collapse = ""), "\n")
  cat("Key variables:", paste(key_vars, collapse = ", "), "\n")
  cat("Total observations:", nrow(data), "\n")
  
  # Check for duplicates
  duplicates <- data %>%
    group_by(across(all_of(key_vars))) %>%
    filter(n() > 1) %>%
    mutate(duplicate_count = n()) %>%
    arrange(across(all_of(key_vars))) %>%
    ungroup()
  
  # Summary statistics
  n_duplicate_rows <- nrow(duplicates)
  n_unique_duplicate_groups <- duplicates %>%
    group_by(across(all_of(key_vars))) %>%
    summarise(.groups = "drop") %>%
    nrow()
  
  cat("Duplicate rows found:", n_duplicate_rows, "\n")
  cat("Unique duplicate groups:", n_unique_duplicate_groups, "\n")
  
  if (n_duplicate_rows > 0) {
    cat("\nDUPLICATE GROUPS SUMMARY:\n")
    cat(paste(rep("-", 50), collapse = ""), "\n")
    
    # Show duplicate group sizes
    duplicate_summary <- duplicates %>%
      group_by(across(all_of(key_vars))) %>%
      summarise(count = n(), .groups = "drop") %>%
      count(count, name = "groups")
    
    print(duplicate_summary)
    
    cat("\nFIRST FEW DUPLICATE RECORDS:\n")
    cat(paste(rep("-", 50), collapse = ""), "\n")
    
    # Show first few duplicate records
    duplicates_display <- duplicates %>%
      select(all_of(key_vars), duplicate_count, everything()) %>%
      head(20)
    
    print(duplicates_display)
    
  } else {
    cat("\n✓ No duplicates found!\n")
  }
  
  cat(paste(rep("=", 80), collapse = ""), "\n\n")
  
  return(list(
    duplicates = duplicates,
    summary = list(
      total_rows = nrow(data),
      duplicate_rows = n_duplicate_rows,
      duplicate_groups = n_unique_duplicate_groups,
      duplicate_rate = round(n_duplicate_rows / nrow(data) * 100, 2)
    )
  ))
}

# ------------------------------------------------------------------------------
# Function to Check Multiple Key Combinations
# ------------------------------------------------------------------------------
check_multiple_key_combinations <- function(data, key_combinations, dataset_name = "Dataset") {
  
  results <- list()
  
  for (i in seq_along(key_combinations)) {
    combo_name <- names(key_combinations)[i]
    if (is.null(combo_name) || combo_name == "") {
      combo_name <- paste("Combination", i)
    }
    
    cat("Checking key combination:", combo_name, "\n")
    results[[combo_name]] <- check_duplicates(data, key_combinations[[i]], 
                                              paste(dataset_name, "-", combo_name))
  }
  
  return(results)
}

# ------------------------------------------------------------------------------
# Function to Export Duplicates
# ------------------------------------------------------------------------------
export_duplicates <- function(duplicate_result, output_path, key_vars) {
  if (nrow(duplicate_result$duplicates) > 0) {
    # Add row numbers for reference
    duplicates_export <- duplicate_result$duplicates %>%
      mutate(original_row_number = row_number()) %>%
      select(original_row_number, all_of(key_vars), duplicate_count, everything())
    
    write_dta(duplicates_export, output_path)
    cat("Duplicates exported to:", output_path, "\n")
  } else {
    cat("No duplicates to export.\n")
  }
}

# ------------------------------------------------------------------------------
# Function to run full duplicate check pipeline
# ------------------------------------------------------------------------------
run_duplicate_check_pipeline <- function(data_path = NULL, key_combinations = NULL, output_dir = NULL) {
  
  # Default data path if not provided
  if (is.null(data_path)) {
    if (exists("WEIGHTS_COLUMNS_PATH")) {
      data_path <- WEIGHTS_COLUMNS_PATH
    } else {
      stop("Please provide data_path or ensure WEIGHTS_COLUMNS_PATH is defined")
    }
  }
  
  # Default key combinations
  if (is.null(key_combinations)) {
    key_combinations <- list(
      "Household_ID" = c("region", "depart", "souspref", "ZD", "segment", "nummen"),
      "Geographic_Segment" = c("region", "depart", "souspref", "ZD", "segment"),
      "Full_Geographic" = c("region", "depart", "souspref", "ZD", "segment", "nummen", "rgmen"),
      "Minimal_ID" = c("ZD", "segment", "nummen")
    )
  }
  
  # Load the data
  cat("Loading data from:", data_path, "\n")
  weight_data <- read_dta(data_path)
  cat("Dataset loaded. Dimensions:", nrow(weight_data), "rows x", ncol(weight_data), "columns\n\n")
  
  # Check for duplicates with different key combinations
  duplicate_results <- check_multiple_key_combinations(weight_data, key_combinations, "ENE Survey Weights")
  
  # Export duplicates if output directory provided
  if (!is.null(output_dir)) {
    if (!dir.exists(output_dir)) {
      dir.create(output_dir, recursive = TRUE)
    }
    
    # Export first key combination results
    first_key_name <- names(key_combinations)[1]
    duplicate_output_path <- file.path(output_dir, paste0("duplicates_", tolower(first_key_name), "_", 
                                                         format(Sys.Date(), "%Y%m%d"), ".dta"))
    export_duplicates(duplicate_results[[first_key_name]], duplicate_output_path, key_combinations[[first_key_name]])
  }
  
  # Additional Quality Checks
  quality_checks <- run_additional_quality_checks(weight_data, key_combinations)
  
  return(list(
    duplicate_results = duplicate_results,
    quality_checks = quality_checks,
    data = weight_data
  ))
}

# ------------------------------------------------------------------------------
# Function for additional quality checks
# ------------------------------------------------------------------------------
run_additional_quality_checks <- function(data, key_combinations) {
  
  cat("ADDITIONAL QUALITY CHECKS:\n")
  cat(paste(rep("=", 50), collapse = ""), "\n")
  
  # Check for missing values in key variables
  cat("Missing values in key variables:\n")
  key_vars_all <- unique(unlist(key_combinations))
  existing_key_vars <- intersect(key_vars_all, names(data))
  
  missing_summary <- data %>%
    select(all_of(existing_key_vars)) %>%
    summarise(across(everything(), ~ sum(is.na(.x)))) %>%
    pivot_longer(everything(), names_to = "variable", values_to = "missing_count") %>%
    filter(missing_count > 0)
  
  if (nrow(missing_summary) > 0) {
    print(missing_summary)
  } else {
    cat("✓ No missing values in key variables\n")
  }
  
  # Check for unexpected values (e.g., negative weights)
  cat("\nWeight variable checks:\n")
  weight_vars <- c("base_weight_HH", "base_weight_HH_WR")
  existing_weight_vars <- intersect(weight_vars, names(data))
  
  quality_summary <- NULL
  if (length(existing_weight_vars) > 0) {
    quality_summary <- data %>%
      select(all_of(existing_weight_vars)) %>%
      summarise(across(everything(), list(
        min = ~ min(.x, na.rm = TRUE),
        max = ~ max(.x, na.rm = TRUE),
        mean = ~ mean(.x, na.rm = TRUE),
        negative = ~ sum(.x < 0, na.rm = TRUE),
        zero = ~ sum(.x == 0, na.rm = TRUE),
        missing = ~ sum(is.na(.x))
      )))
    
    print(quality_summary)
  } else {
    cat("No weight variables found in dataset\n")
  }
  
  cat("\nQuality check completed!\n")
  
  return(list(
    missing_summary = missing_summary,
    weight_summary = quality_summary
  ))
}

# ------------------------------------------------------------------------------
# Example usage (commented out - uncomment to run directly)
# ------------------------------------------------------------------------------
# if (FALSE) {
#   # Run the full pipeline
#   results <- run_duplicate_check_pipeline()
#   
#   # Or run with custom parameters
#   custom_keys <- list("Custom_ID" = c("region", "ZD", "nummen"))
#   results <- run_duplicate_check_pipeline(
#     data_path = "path/to/your/data.dta",
#     key_combinations = custom_keys,
#     output_dir = "path/to/output"
#   )
# }

# ==============================================================================
# Fonction utilitaire pour enrichir le jeu de données avec des infos de doublons
# ==============================================================================
enrich_with_duplicates_info <- function(data, key_vars = c("region", "depart", "souspref", "ZD", "segment")) {
  dup_result <- check_duplicates(
    data,
    key_vars = key_vars,
    dataset_name = "Dataset pour enrichissement"
  )

  if (nrow(dup_result$duplicates) > 0) {
    # Ajoute les colonnes duplicate_count + is_duplicate
    data <- data %>%
      left_join(
        dup_result$duplicates %>%
          select(all_of(key_vars), duplicate_count) %>%
          mutate(is_duplicate = TRUE),
        by = key_vars
      ) %>%
      mutate(
        duplicate_count = ifelse(is.na(duplicate_count), 0, duplicate_count),
        is_duplicate = ifelse(is.na(is_duplicate), FALSE, is_duplicate)
      )
  } else {
    # Aucun doublon : ajouter colonnes avec valeurs par défaut
    data <- data %>%
      mutate(
        duplicate_count = 0,
        is_duplicate = FALSE
      )
  }

  return(data)
}
