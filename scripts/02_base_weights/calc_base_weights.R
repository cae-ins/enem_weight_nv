################################################################################
# Script Name: calc_base_weights.R
# Project: Employment Survey Weights – National Rotating Panel (10-Year Study)
# Author: [Your Name or Team]
# Created: [YYYY-MM-DD]
# Last Updated: [YYYY-MM-DD]
#
# Description:
# ------------------------------------------------------------------------------
# This script calculates the **base weights** for sampled units in the employment
# survey. Base weights represent the inverse of the inclusion probability for each
# sampled unit and are the foundation for subsequent adjustments such as
# nonresponse correction and calibration.
#
# Base Weight Formula:
#   w_base = 1 / π_i
#   where π_i = probability of selection for unit i
#
# Key Functions:
# - Load sampling frame and sample selection metadata
# - Compute inclusion probabilities based on design strata, clusters, and rotation group
# - Assign base weights to all respondents (and optionally nonrespondents)
# - Export the base weight dataset for downstream use
#
# Inputs:
# - Sampling frame or design metadata (e.g., inclusion probabilities, stratification info)
# - Raw survey sample data for the current wave
#
# Outputs:
# - A data frame with base weights appended
#   (usually saved to `data/processed/base_weights_[wave].rds`)
#
# Dependencies:
# - R packages: data.table, dplyr, readr, etc.
# - Source utilities from scripts/00_utils/ if needed
#
# Notes:
# - Base weights should reflect any planned oversampling, stratified design, or multi-stage selection
# - They are the first stage in the full survey weighting pipeline
# - Nonresponse and calibration adjustments will follow in subsequent scripts
#
# Example downstream usage:
#   - `adjust_for_nonresponse.R` will read in these base weights to compute adjusted weights
#   - Used in QC reports to assess sample representation before adjustments
#
################################################################################

# ------------------------------------------------------------------------------
# FUNCTIONS TO COMPUTE INCLUSION PROBABILITIES AND BASE WEIGHTS
# ------------------------------------------------------------------------------

# 1. Inclusion probability for ZD (Zone de Dénombrement)
compute_pi_zd <- function(n_zd, N_zd) {
  if (n_zd <= 0 || N_zd <= 0 || n_zd > N_zd) stop("Invalid ZD selection parameters.")
  pi_zd <- n_zd / N_zd
  return(pi_zd)
}

# 2. Inclusion probability for segment (fixed: 1 selected out of 6)
compute_pi_segment <- function() {
  return(1 / 6)
}

# 3. Inclusion probability for a ménage (household) within a segment
compute_pi_menage <- function(n_menages, N_menages) {
  if (n_menages <= 0 || N_menages <= 0 || n_menages > N_menages) stop("Invalid household selection parameters.")
  pi_menage <- n_menages / N_menages
  return(pi_menage)
}

# 4. Combined probability of inclusion for a household
compute_pi_household <- function(n_zd, N_zd, n_menages, N_menages) {
  pi_zd <- compute_pi_zd(n_zd, N_zd)
  pi_seg <- compute_pi_segment()
  pi_men <- compute_pi_menage(n_menages, N_menages)
  pi_total <- pi_zd * pi_seg * pi_men
  return(pi_total)
}

# ------------------------------------------------------------------------------
# FUNCTION TO APPEND BASE WEIGHTS TO A DATASET
# ------------------------------------------------------------------------------

#' Compute base weights and append to dataset
#'
#' @param data A data.frame or data.table containing the input sample
#' @param n_zd_col, N_zd_col Column names for number selected and total ZDs in region
#' @param n_men_col, N_men_col Column names for number and total households per segment
#' @param weight_col Name of the column to store base weights
#'
#' @return A dataset with base weights column
#' 
compute_base_weights <- function(data,
                                 n_zd_col, N_zd_col,
                                 n_men_col, N_men_col,
                                 weight_col = "base_weight") {
  data[[weight_col]] <- mapply(
    function(n_zd, N_zd, n_men, N_men) {
      pi <- compute_pi_household(n_zd, N_zd, n_men, N_men)
      return(1 / pi)
    },
    data[[n_zd_col]],
    data[[N_zd_col]],
    data[[n_men_col]],
    data[[N_men_col]]
  )
  return(data)
}