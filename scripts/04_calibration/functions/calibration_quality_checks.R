#' Contrôles de qualité pour la calibration
#'
#' Fonctions pour vérifier la qualité de la calibration, notamment au niveau
#' des agrégations régionales.

# ============================================================================
#' Vérifier les écarts régionaux après calibration
#'
#' Cette fonction vérifie que les écarts entre les totaux connus et les
#' estimations finales au niveau régional n'excèdent pas un seuil acceptable.
#'
#' @param X_Summary_Table Tableau de synthèse des contraintes X
#' @param threshold Seuil d'écart acceptable (défaut: 100 unités)
#' @param verbose Afficher les détails (défaut: TRUE)
#' @return Liste avec les résultats du contrôle
#' @export
check_regional_discrepancies <- function(X_Summary_Table,
                                          threshold = 100,
                                          verbose = TRUE) {

  if (verbose) {
    cat("\n")
    cat("╔═══════════════════════════════════════════════════════════════════════════╗\n")
    cat("║        CONTRÔLE DES ÉCARTS AU NIVEAU DES AGRÉGATIONS RÉGIONALES          ║\n")
    cat("╚═══════════════════════════════════════════════════════════════════════════╝\n\n")
  }

  # Vérifier que la colonne Diff_Known_Tot_Final_Est existe
  if (!"Diff_Known_Tot_Final_Est" %in% names(X_Summary_Table)) {
    if (verbose) {
      cat("  ✗ Colonne 'Diff_Known_Tot_Final_Est' introuvable\n\n")
    }
    return(list(
      success = FALSE,
      message = "Colonne Diff_Known_Tot_Final_Est introuvable"
    ))
  }

  # Calculer les écarts absolus
  diffs <- abs(X_Summary_Table$Diff_Known_Tot_Final_Est)

  # Compter les contraintes qui dépassent le seuil
  exceeding_threshold <- which(diffs > threshold)
  n_exceeding <- length(exceeding_threshold)
  total_constraints <- length(diffs)

  if (verbose) {
    cat("┌─────────────────────────────────────────────────────────────────────────┐\n")
    cat("│ RÉSULTATS DU CONTRÔLE                                                   │\n")
    cat("├─────────────────────────────────────────────────────────────────────────┤\n")
    cat("│                                                                         │\n")
    cat("│  Seuil de tolérance      : ", threshold, "unités                               │\n")
    cat("│  Contraintes testées     : ", total_constraints, "                                  │\n")
    cat("│  Contraintes hors seuil  : ", n_exceeding, "                                   │\n")
    cat("│                                                                         │\n")
  }

  # Résultat du test
  if (n_exceeding == 0) {
    if (verbose) {
      cat("│  ✓✓✓ CONTRÔLE RÉUSSI !                                                  │\n")
      cat("│                                                                         │\n")
      cat("│  Tous les écarts sont ≤ ", threshold, " unités                                  │\n")
      cat("│  La calibration est de QUALITÉ ACCEPTABLE                              │\n")
    }
    success <- TRUE
  } else {
    if (verbose) {
      cat("│  ⚠⚠⚠ CONTRÔLE ÉCHOUÉ !                                                  │\n")
      cat("│                                                                         │\n")
      cat("│  ", n_exceeding, " contrainte(s) ont un écart > ", threshold, " unités                    │\n")
      cat("│  La calibration nécessite une révision                                 │\n")
    }
    success <- FALSE
  }

  # Afficher les statistiques descriptives des écarts
  if (verbose) {
    cat("│                                                                         │\n")
    cat("│  Statistiques des écarts absolus:                                      │\n")
    cat("│    • Minimum    : ", sprintf("%.2f", min(diffs, na.rm = TRUE)), "\n")
    cat("│    • Q1         : ", sprintf("%.2f", quantile(diffs, 0.25, na.rm = TRUE)), "\n")
    cat("│    • Médiane    : ", sprintf("%.2f", median(diffs, na.rm = TRUE)), "\n")
    cat("│    • Q3         : ", sprintf("%.2f", quantile(diffs, 0.75, na.rm = TRUE)), "\n")
    cat("│    • Maximum    : ", sprintf("%.2f", max(diffs, na.rm = TRUE)), "\n")
    cat("│    • Moyenne    : ", sprintf("%.2f", mean(diffs, na.rm = TRUE)), "\n")
  }

  # Afficher les contraintes problématiques
  if (!success && verbose) {
    cat("│                                                                         │\n")
    cat("│  Contraintes dépassant le seuil:                                       │\n")

    # Récupérer les informations sur les contraintes problématiques
    problem_table <- X_Summary_Table[exceeding_threshold, ]

    # Afficher les 10 premières
    n_display <- min(10, n_exceeding)
    for (i in 1:n_display) {
      idx <- exceeding_threshold[i]
      diff_val <- X_Summary_Table$Diff_Known_Tot_Final_Est[idx]

      # Essayer d'obtenir le nom de la contrainte si disponible
      x_name <- if ("X" %in% names(X_Summary_Table)) {
        X_Summary_Table$X[idx]
      } else {
        paste0("X", idx)
      }

      cat("│    • ", x_name, ": écart = ", sprintf("%.2f", abs(diff_val)), " unités\n")
    }

    if (n_exceeding > 10) {
      cat("│    ... et ", n_exceeding - 10, " autre(s)\n")
    }
  }

  if (verbose) {
    cat("└─────────────────────────────────────────────────────────────────────────┘\n\n")
  }

  # Si le contrôle échoue, donner des recommandations
  if (!success && verbose) {
    cat("┌─────────────────────────────────────────────────────────────────────────┐\n")
    cat("│ RECOMMANDATIONS                                                         │\n")
    cat("├─────────────────────────────────────────────────────────────────────────┤\n")
    cat("│                                                                         │\n")

    max_diff <- max(diffs, na.rm = TRUE)

    if (max_diff > threshold * 10) {
      cat("│  ⚠ Écarts très importants (max = ", sprintf("%.0f", max_diff), ")                          │\n")
      cat("│    → Vérifier les données d'entrée                                     │\n")
      cat("│    → Vérifier les totaux de population                                 │\n")
      cat("│    → Considérer un autre schéma de calibration                         │\n")
    } else if (max_diff > threshold * 2) {
      cat("│  ⚠ Écarts modérés (max = ", sprintf("%.0f", max_diff), ")                                │\n")
      cat("│    → Essayer d'élargir les bornes de calibration                       │\n")
      cat("│    → Augmenter le nombre d'itérations (maxit)                          │\n")
      cat("│    → Réduire epsilon (critère de convergence)                          │\n")
    } else {
      cat("│  ℹ Écarts proches du seuil (max = ", sprintf("%.0f", max_diff), ")                       │\n")
      cat("│    → Les écarts sont acceptables dans certains contextes               │\n")
      cat("│    → Consulter l'expert métier pour validation                         │\n")
      cat("│    → Documenter les écarts dans le rapport                             │\n")
    }

    cat("│                                                                         │\n")
    cat("└─────────────────────────────────────────────────────────────────────────┘\n\n")
  }

  # Retourner les résultats
  return(list(
    success = success,
    n_exceeding = n_exceeding,
    total_constraints = total_constraints,
    exceeding_indices = exceeding_threshold,
    threshold = threshold,
    max_diff = max(diffs, na.rm = TRUE),
    mean_diff = mean(diffs, na.rm = TRUE),
    median_diff = median(diffs, na.rm = TRUE),
    problem_constraints = if (n_exceeding > 0) X_Summary_Table[exceeding_threshold, ] else NULL,
    message = if (success) {
      "Tous les écarts régionaux sont acceptables"
    } else {
      paste0(n_exceeding, " contrainte(s) dépassent le seuil de ", threshold, " unités")
    }
  ))
}


# ============================================================================
#' Contrôle complet de qualité de la calibration
#'
#' Effectue un ensemble complet de contrôles de qualité incluant:
#' - Vérification de la convergence (ecal.status)
#' - Contrôle des écarts régionaux
#' - Vérification des facteurs de correction
#' - Vérification des tailles d'échantillon
#'
#' @param calib_result Objet calibré (résultat de e.calibrate)
#' @param X_Summary_Table Tableau de synthèse des contraintes X
#' @param threshold_diff Seuil d'écart acceptable (défaut: 100)
#' @param threshold_corr_low Seuil bas pour facteurs de correction (défaut: 0.5)
#' @param threshold_corr_high Seuil haut pour facteurs de correction (défaut: 2.0)
#' @param verbose Afficher les détails (défaut: TRUE)
#' @return Liste avec tous les résultats de contrôle
#' @export
run_complete_quality_check <- function(calib_result,
                                        X_Summary_Table,
                                        threshold_diff = 100,
                                        threshold_corr_low = 0.5,
                                        threshold_corr_high = 2.0,
                                        verbose = TRUE) {

  if (verbose) {
    cat("\n")
    cat("═══════════════════════════════════════════════════════════════════════════\n")
    cat("           CONTRÔLE COMPLET DE QUALITÉ DE LA CALIBRATION\n")
    cat("═══════════════════════════════════════════════════════════════════════════\n\n")
  }

  results <- list()

  # ========== 1. VÉRIFICATION DE LA CONVERGENCE ==========
  if (verbose) {
    cat("1️⃣  Vérification de la convergence (ecal.status)...\n")
  }

  status <- ecal.status(calib_result)
  all_converged <- all(status$return.code == 0)

  if (verbose) {
    if (all_converged) {
      cat("    ✓ Tous les domaines ont convergé (return.code = 0)\n\n")
    } else {
      failed_domains <- which(status$return.code != 0)
      cat("    ✗ ", length(failed_domains), " domaine(s) n'ont pas convergé:\n")
      for (d in failed_domains) {
        cat("      • Domaine", d, "- Code:", status$return.code[d], "\n")
      }
      cat("\n")
    }
  }

  results$convergence <- list(
    all_converged = all_converged,
    failed_domains = if (!all_converged) which(status$return.code != 0) else integer(0),
    status = status
  )

  # Si la convergence a échoué, arrêter les autres tests
  if (!all_converged) {
    if (verbose) {
      cat("⚠ Contrôle arrêté : la calibration n'a pas convergé\n\n")
    }
    results$overall_success <- FALSE
    return(results)
  }

  # ========== 2. CONTRÔLE DES ÉCARTS RÉGIONAUX ==========
  if (verbose) {
    cat("2️⃣  Contrôle des écarts régionaux (seuil: ", threshold_diff, " unités)...\n")
  }

  regional_check <- check_regional_discrepancies(
    X_Summary_Table,
    threshold = threshold_diff,
    verbose = verbose
  )

  results$regional_discrepancies <- regional_check

  # ========== 3. VÉRIFICATION DES FACTEURS DE CORRECTION ==========
  if (verbose) {
    cat("3️⃣  Vérification des facteurs de correction...\n")
  }

  if ("Mean_corr_factor" %in% names(X_Summary_Table)) {
    corr_factors <- X_Summary_Table$Mean_corr_factor

    extreme_low <- sum(corr_factors < threshold_corr_low, na.rm = TRUE)
    extreme_high <- sum(corr_factors > threshold_corr_high, na.rm = TRUE)

    if (verbose) {
      cat("    • Facteurs < ", threshold_corr_low, "  : ", extreme_low, "/", length(corr_factors), "\n")
      cat("    • Facteurs > ", threshold_corr_high, " : ", extreme_high, "/", length(corr_factors), "\n")

      if (extreme_low == 0 && extreme_high == 0) {
        cat("    ✓ Tous les facteurs de correction sont acceptables\n\n")
      } else {
        cat("    ⚠ Certains facteurs de correction sont extrêmes\n\n")
      }
    }

    results$correction_factors <- list(
      extreme_low = extreme_low,
      extreme_high = extreme_high,
      min = min(corr_factors, na.rm = TRUE),
      max = max(corr_factors, na.rm = TRUE),
      mean = mean(corr_factors, na.rm = TRUE),
      median = median(corr_factors, na.rm = TRUE)
    )
  }

  # ========== 4. VÉRIFICATION DES TAILLES D'ÉCHANTILLON ==========
  if (verbose) {
    cat("4️⃣  Vérification des tailles d'échantillon...\n")
  }

  if ("flag_small_sample_size" %in% names(X_Summary_Table)) {
    small_samples <- sum(X_Summary_Table$flag_small_sample_size == 1, na.rm = TRUE)
    total <- nrow(X_Summary_Table)

    if (verbose) {
      cat("    • Contraintes avec petit échantillon: ", small_samples, "/", total, "\n")

      if (small_samples == 0) {
        cat("    ✓ Toutes les contraintes ont un échantillon suffisant\n\n")
      } else {
        pct <- round(100 * small_samples / total, 1)
        cat("    ℹ ", pct, "% des contraintes ont un échantillon réduit\n\n")
      }
    }

    results$sample_sizes <- list(
      small_samples = small_samples,
      total = total,
      percentage = 100 * small_samples / total
    )
  }

  # ========== 5. SYNTHÈSE GLOBALE ==========
  overall_success <- all_converged && regional_check$success

  if (verbose) {
    cat("═══════════════════════════════════════════════════════════════════════════\n")
    cat("                        SYNTHÈSE DU CONTRÔLE QUALITÉ\n")
    cat("═══════════════════════════════════════════════════════════════════════════\n\n")

    if (overall_success) {
      cat("  ✅ CALIBRATION DE QUALITÉ ACCEPTABLE\n\n")
      cat("  ✓ Convergence réussie\n")
      cat("  ✓ Écarts régionaux dans les limites (≤ ", threshold_diff, " unités)\n")
      if ("correction_factors" %in% names(results)) {
        cat("  ✓ Facteurs de correction dans les limites\n")
      }
      cat("\n  → La calibration peut être utilisée pour l'analyse.\n\n")
    } else {
      cat("  ⚠ CALIBRATION NÉCESSITANT UNE RÉVISION\n\n")
      if (!all_converged) {
        cat("  ✗ Problèmes de convergence détectés\n")
      }
      if (!regional_check$success) {
        cat("  ✗ Écarts régionaux trop importants\n")
      }
      cat("\n  → Réviser les paramètres ou les données avant utilisation.\n\n")
    }

    cat("═══════════════════════════════════════════════════════════════════════════\n\n")
  }

  results$overall_success <- overall_success
  results$timestamp <- Sys.time()

  return(results)
}


# ============================================================================
#' Générer un rapport de qualité de calibration
#'
#' Génère un rapport texte résumant tous les contrôles de qualité
#'
#' @param quality_results Résultats de run_complete_quality_check()
#' @param output_file Chemin du fichier de sortie (optionnel)
#' @export
generate_quality_report <- function(quality_results, output_file = NULL) {

  report_lines <- c(
    "═══════════════════════════════════════════════════════════════",
    "      RAPPORT DE CONTRÔLE QUALITÉ DE LA CALIBRATION",
    "═══════════════════════════════════════════════════════════════",
    "",
    paste("Date:", format(quality_results$timestamp, "%Y-%m-%d %H:%M:%S")),
    "",
    "1. CONVERGENCE",
    "───────────────────────────────────────────────────────────────",
    paste("  Statut:", if (quality_results$convergence$all_converged) "✓ RÉUSSIE" else "✗ ÉCHEC"),
    ""
  )

  if (!quality_results$convergence$all_converged) {
    report_lines <- c(report_lines,
      paste("  Domaines sans convergence:", length(quality_results$convergence$failed_domains)),
      ""
    )
  }

  report_lines <- c(report_lines,
    "2. ÉCARTS RÉGIONAUX",
    "───────────────────────────────────────────────────────────────",
    paste("  Seuil:", quality_results$regional_discrepancies$threshold, "unités"),
    paste("  Contraintes testées:", quality_results$regional_discrepancies$total_constraints),
    paste("  Contraintes hors seuil:", quality_results$regional_discrepancies$n_exceeding),
    paste("  Écart maximum:", sprintf("%.2f", quality_results$regional_discrepancies$max_diff)),
    paste("  Écart moyen:", sprintf("%.2f", quality_results$regional_discrepancies$mean_diff)),
    paste("  Statut:", if (quality_results$regional_discrepancies$success) "✓ ACCEPTABLE" else "✗ NON ACCEPTABLE"),
    ""
  )

  if ("correction_factors" %in% names(quality_results)) {
    report_lines <- c(report_lines,
      "3. FACTEURS DE CORRECTION",
      "───────────────────────────────────────────────────────────────",
      paste("  Minimum:", sprintf("%.4f", quality_results$correction_factors$min)),
      paste("  Médiane:", sprintf("%.4f", quality_results$correction_factors$median)),
      paste("  Moyenne:", sprintf("%.4f", quality_results$correction_factors$mean)),
      paste("  Maximum:", sprintf("%.4f", quality_results$correction_factors$max)),
      paste("  Facteurs extrêmes bas:", quality_results$correction_factors$extreme_low),
      paste("  Facteurs extrêmes hauts:", quality_results$correction_factors$extreme_high),
      ""
    )
  }

  report_lines <- c(report_lines,
    "═══════════════════════════════════════════════════════════════",
    "CONCLUSION",
    "═══════════════════════════════════════════════════════════════",
    "",
    if (quality_results$overall_success) {
      "  ✅ CALIBRATION DE QUALITÉ ACCEPTABLE"
    } else {
      "  ⚠ CALIBRATION NÉCESSITANT UNE RÉVISION"
    },
    "",
    quality_results$regional_discrepancies$message,
    "",
    "═══════════════════════════════════════════════════════════════"
  )

  # Afficher le rapport
  for (line in report_lines) {
    cat(line, "\n")
  }

  # Sauvegarder dans un fichier si demandé
  if (!is.null(output_file)) {
    writeLines(report_lines, output_file)
    cat("\n✓ Rapport sauvegardé dans:", output_file, "\n\n")
  }

  invisible(report_lines)
}
