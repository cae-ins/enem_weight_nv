################################################################################
# Script Name: calc_base_weights.R
# Project: ENE Survey Weights – National Rotating Panel
# Author: Ezechiel KOFFIE
# Created: 2025-05-14
# Last Updated: 2025-05-14
#
# Description:
# Calculates base weights for the ENE survey, using:
# - ZD (zone de dénombrement) inclusion probabilities
# - Household selection probabilities (first and second households)
#
################################################################################

# ------------------------------------------------------------------------------
# Load Required Libraries
# ------------------------------------------------------------------------------
library(dplyr)

# ------------------------------------------------------------------------------
# FUNCTIONS TO COMPUTE INCLUSION PROBABILITIES
# ------------------------------------------------------------------------------

# ZD-level inclusion probability
compute_pi_zd <- function(region, nb_indivs_zd, nb_indivs_reg, nb_zd_strat) {
  if (is.na(region) || is.na(nb_indivs_zd) || is.na(nb_indivs_reg) || is.na(nb_zd_strat)) return(NA_real_)
  if (nb_indivs_reg == 0) return(NA_real_)
  multiplier <- ifelse(region == 10101, 104, 56)
  pi_zd <- multiplier * (nb_indivs_zd / nb_indivs_reg) * (nb_zd_strat / multiplier)
  return(pi_zd)
}

# ZD-level inclusion probability without resurvey
compute_pi_zd_without_resurvey <- function(region, nb_indivs_zd, nb_indivs_reg) {
  if (is.na(region) || is.na(nb_indivs_zd) || is.na(nb_indivs_reg)) return(NA_real_)
  if (nb_indivs_reg == 0) return(NA_real_)
  multiplier <- ifelse(region == 10101, 104, 56)
  pi_zd <- multiplier * (nb_indivs_zd / nb_indivs_reg) / multiplier
  return(pi_zd)
}


# Inclusion prob for 1st household
compute_pi_men1 <- function(nb_mens_enq, nb_mens_seg) {
  if (is.na(nb_mens_enq) || is.na(nb_mens_seg) || nb_mens_seg == 0) return(NA_real_)
  return((nb_mens_enq / nb_mens_seg) * (1 / 6))
}

# Inclusion prob for 2nd household (resurvey)
compute_pi_men2 <- function(proportion, nb_mens_enq, nb_mens_seg) {
  if (is.na(proportion) || is.na(nb_mens_enq) || is.na(nb_mens_seg) || nb_mens_seg == 0) return(NA_real_)
  return(proportion * (nb_mens_enq / nb_mens_seg) * (1 / 6))
}

# Combined inclusion prob
compute_pi_final <- function(pi_zd, pi_hh) {
  ifelse(is.na(pi_zd) | is.na(pi_hh), NA, pi_zd * pi_hh)
}

# ------------------------------------------------------------------------------
# MAIN FUNCTION: APPLY TO FULL DATASET
# ------------------------------------------------------------------------------

#' Compute and append base weights
#'
#' @param data A dataframe with required columns:
#'        region, depart, souspref, ZD, segment,
#'        nb_indivs_seg, nb_mens_seg, nb_indivs_reg,
#'        nb_mens_reg, nb_indivs_zd, nb_mens_zd, nb_zd_strat,
#'        proportion (for second interview prob)
#' @param nb_mens_enq Number of households interviewed per segment (default = 2)
#'
#' @return Dataframe with added columns:
#'         pi_zd, pi_hh1, pi_hh2, pi_final_hh1, pi_final_hh2,
#'         base_weight_hh1, base_weight_hh2
append_base_weights <- function(data) {
  required_cols <- c("region", "depart", "souspref", "ZD", "segment",
                     "nb_indivs_zd", "nb_indivs_reg", "nb_zd_strat",
                     "nb_mens_seg" 
                     #"proportion"
                     )
  missing_cols <- setdiff(required_cols, colnames(data))
  if (length(missing_cols) > 0) {
    stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
  }
  
  data <- data %>%
    mutate(
      pi_zd = mapply(compute_pi_zd, region, nb_indivs_zd, nb_indivs_reg, nb_zd_strat),
      pi_zd_wr = mapply(compute_pi_zd_without_resurvey, region, nb_indivs_zd, nb_indivs_reg),
      pi_men1 = mapply(compute_pi_men1, nb_mens_enq, nb_mens_seg),
      #pi_men2 = mapply(compute_pi_hh2, proportion, nb_mens_enq, nb_mens_seg),
      pi_final_men1 = compute_pi_final(pi_zd, pi_men1),
      pi_final_men1_wr = compute_pi_final(pi_zd_wr, pi_men1),
      #pi_final_men2 = compute_pi_final(pi_zd, pi_men2),
      base_weight_men1 = ifelse(!is.na(pi_final_men1) & pi_final_men1 != 0, 1 / pi_final_men1, NA_real_),
      base_weight_men1_wr = ifelse(!is.na(pi_final_men1_wr) & pi_final_men1_wr != 0, 1 / pi_final_men1_wr, NA_real_),
      #base_weight_men2 = ifelse(!is.na(pi_final_hh2) & pi_final_hh2 != 0, 1 / pi_final_hh2, NA_real_)
    )
  
  return(data)
}

# ------------------------------------------------------------------------------
# END OF SCRIPT
# ------------------------------------------------------------------------------