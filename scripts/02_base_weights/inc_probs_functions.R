################################################################################
# Script Name: inc_probs_functions.R
# Project: Employment Survey Weights – National Rotating Panel (10-Year Study)
# Author: Ezechiel KOFFIE
# Created:2025-05-02
# Last Updated: 2025-05-02
#
# Description:
# -------------------------------------------------------------------------------
# This utility script provides functions for calculating inclusion probabilities
# for:
#   - Quarters since Q2 2024
#   - Zone de Dénombrement (ZD)
#   - Segments and households (ménages)
#
# These functions support the survey weighting pipeline by computing base
# inclusion probabilities at multiple stages of the sampling design.
#
# Usage:
# - Source this file into other R scripts as needed:
#     source("path/to/utils_inclusion_probabilities.R")
################################################################################

# ------------------------------------------------------------------------------
# Function 1: Quarters Since Q2 2024
# ------------------------------------------------------------------------------
#' Calculate the number of full quarters since Q2 2024
#'
#' @param reference_date A Date object. The reference date from which the number
#'                       of quarters will be calculated. Defaults to today's date
#'                       if not provided (via `Sys.Date()`).
#' 
#' @return An integer. The number of full quarters that have passed since Q2 2024.
#'         For example, 1 represents Q2 2024, 2 represents Q3 2024, etc.
#'
#' @examples
#' quarters_since_q2_2024()  # Uses today's date
#' quarters_since_q2_2024(as.Date("2026-01-01"))  # Uses a custom reference date
quarters_since_q2_2024 <- function(reference_date = Sys.Date()) {
  start_quarter <- as.Date("2024-04-01")  # Start of Q2 2024
  
  # Calculate difference in months and convert to quarters
  months_diff <- as.numeric(difftime(reference_date, start_quarter, units = "days")) %/% 30.44
  quarters_passed <- floor(months_diff / 3)
  
  return(quarters_passed + 1)
}

# ------------------------------------------------------------------------------
# Function: Number of ZD being collected in the current quater.
# ------------------------------------------------------------------------------
#' Calculate the number of zones de dénombrement (ZD) being collected for the stratum
#'
#' @param region A character string representing the region name (e.g., "ABIDJAN")
#' @param reference_date A Date object for the reference date of the quarter
#'
#' @return An integer: the number of ZD being collected in the region's stratum this quarter
#'
#' @examples
#' calc_nb_zdc("ABIDJAN", as.Date("2024-07-01"))  # Returns 26
#' calc_nb_zdc("BOUAKE", as.Date("2024-07-01"))   # Returns 14
calc_nb_zdc <- function(region, reference_date = Sys.Date()) {
  quarter_number <- quarters_since_q2_2024(reference_date)
  if (toupper(region) == "ABIDJAN") {
    return(13 * quarter_number)
  } else {
    return(7 * quarter_number)
  }
}

# ------------------------------------------------------------------------------
# Function 2: Probability of Inclusion – Zone de Dénombrement (ZD)
# ------------------------------------------------------------------------------
#' Calculate the probability of inclusion of a Zone de Dénombrement (ZD)
#'
#' @param region A character string. The name of the region (e.g., "ABIDJAN").
#'               The region affects the calculation (ABIDJAN uses a different factor).
#'
#' @param nb_indiv_zd An integer. The number of individuals in the selected ZD.
#'
#' @param nb_indiv_strat An integer. The total number of individuals in the entire
#'                       stratum from which the ZD is sampled.
#'
#' @param nb_zd_strat An integer. The total number of ZDs in the stratum.
#'
#' @return A numeric value representing the inclusion probability of the ZD.
#'         The formula used depends on the region.
#'         - For ABIDJAN: `104 * (nb_indiv_zd / nb_indiv_strat) * (nb_zd_strat / 104)`
#'         - For other regions: `56 * (nb_indiv_zd / nb_indiv_strat) * (nb_zd_strat / 56)`
#'
#' @examples
#' calc_proba_inclusion_zd("ABIDJAN", 1000, 50000, 80)
#' calc_proba_inclusion_zd("OTHER_REGION", 1200, 50000, 100)
calc_proba_inclusion_zd <- function(region, nb_indiv_zd, nb_indiv_strat, nb_zd_strat) {
  if (region == "ABIDJAN") {
    proba <- 104 * (nb_indiv_zd / nb_indiv_strat) * (nb_zd_strat / 104)
  } else {
    proba <- 56 * (nb_indiv_zd / nb_indiv_strat) * (nb_zd_strat / 56)
  }
  return(proba)
}

# ------------------------------------------------------------------------------
# Function 3: Probability of Inclusion – Household (Ménage)
# ------------------------------------------------------------------------------
#' Calculate the probability of inclusion of a household (ménage)
#'
#' @param nb_enq_ti An integer. The number of households surveyed in the selected
#'                  segment at the quarter (T_i).
#'
#' @param nb_total_segment An integer. The total number of households in the segment
#'                          as per the enumeration.
#'
#' @return A numeric value representing the probability of inclusion for a household
#'         in the segment. The formula used is: `(nb_enq_ti / nb_total_segment) * (1 / 6)`
#'
#' @examples
#' calc_proba_inclusion_menage(25, 150)  # Example where 25 households surveyed in a segment of 150
calc_proba_inclusion_menage <- function(nb_enq_ti, nb_total_segment) {
  proba <- (nb_enq_ti / nb_total_segment) * (1 / 6)
  return(proba)
}
