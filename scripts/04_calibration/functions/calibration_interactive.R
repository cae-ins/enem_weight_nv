#' Fonctions interactives pour le test de calibration
#'
#' Ces fonctions facilitent le processus exploratoire de sélection des bornes
#' de calibration en permettant des tests rapides et itératifs.

# Charger les fonctions de contrôle qualité
source_quality_checks <- function() {
  quality_checks_file <- file.path(BASE_DIR, "scripts/04_calibration/functions/calibration_quality_checks.R")
  if (file.exists(quality_checks_file)) {
    source(quality_checks_file)
  }
}

# Charger automatiquement au chargement du fichier
tryCatch({
  source_quality_checks()
}, error = function(e) {
  # Silencieux si le fichier n'existe pas encore
})

# ============================================================================
#' Afficher les bornes suggérées et tester la calibration
#'
#' Cette fonction exécute les étapes préliminaires et affiche les informations
#' nécessaires pour décider des bornes de calibration.
#'
#' @param design_lfs Objet design créé avec e.svydesign
#' @param popdataframe DataFrame de population créé avec fill.template
#' @param constrains_x Modèle de contraintes créé avec constraints_model
#' @return Liste avec les informations de diagnostic
#' @export
show_calibration_info <- function(design_lfs, popdataframe, constrains_x) {

  cat("\n")
  cat("╔═══════════════════════════════════════════════════════════════════════════╗\n")
  cat("║                   DIAGNOSTIC DE CALIBRATION                               ║\n")
  cat("╚═══════════════════════════════════════════════════════════════════════════╝\n\n")

  # Calculer les bornes suggérées
  cat("📊 Calcul des bornes suggérées...\n\n")

  bounds_suggested <- tryCatch({
    bounds.hint(
      design = design_lfs,
      df.population = popdataframe,
      calmodel = constrains_x,
      partition = ~ DOMAIN
    )
  }, error = function(e) {
    cat("⚠ Erreur lors du calcul des bornes suggérées:", e$message, "\n")
    return(NULL)
  })

  # Afficher les bornes suggérées
  if (!is.null(bounds_suggested)) {
    cat("┌─────────────────────────────────────────────────────────────────────────┐\n")
    cat("│ BORNES SUGGÉRÉES PAR bounds.hint()                                     │\n")
    cat("├─────────────────────────────────────────────────────────────────────────┤\n")

    if (is.numeric(bounds_suggested) && length(bounds_suggested) == 2) {
      cat("│  Borne inférieure : ", sprintf("%.4f", bounds_suggested[1]), "\n")
      cat("│  Borne supérieure : ", sprintf("%.4f", bounds_suggested[2]), "\n")
      cat("│                                                                         │\n")

      # Vérifier si les bornes sont valides
      if (bounds_suggested[1] < 0) {
        cat("│  ⚠ ATTENTION: La borne inférieure est NÉGATIVE !                       │\n")
        cat("│               Vous devez spécifier des bornes manuelles.              │\n")
      } else if (bounds_suggested[1] == 0) {
        cat("│  ⚠ ATTENTION: La borne inférieure est ZÉRO !                           │\n")
        cat("│               Recommandation: utiliser une valeur positive (ex: 0.01) │\n")
      } else {
        cat("│  ✓ Les bornes suggérées sont positives et peuvent être testées.       │\n")
      }

      if (bounds_suggested[2] > 10) {
        cat("│  ⚠ La borne supérieure est très élevée (>10)                           │\n")
        cat("│     Cela peut indiquer des problèmes de données.                      │\n")
      }

    } else {
      cat("│  Format de bornes non standard:", paste(bounds_suggested, collapse=", "), "\n")
    }

    cat("└─────────────────────────────────────────────────────────────────────────┘\n\n")
  }

  # Afficher les recommandations
  cat("┌─────────────────────────────────────────────────────────────────────────┐\n")
  cat("│ RECOMMANDATIONS POUR LES BORNES                                        │\n")
  cat("├─────────────────────────────────────────────────────────────────────────┤\n")
  cat("│                                                                         │\n")
  cat("│  Bornes standards à tester:                                            │\n")
  cat("│    • Conservateur : c(0.5, 1.5)                                        │\n")
  cat("│    • Standard      : c(0.3, 2.0)                                       │\n")
  cat("│    • Large         : c(0.1, 3.0)                                       │\n")
  cat("│    • Très large    : c(0.01, 6.0)  ← Souvent utilisé                  │\n")
  cat("│                                                                         │\n")
  cat("│  Fonction de calibration:                                              │\n")
  cat("│    • 'logit' (recommandé, nécessite des bornes)                        │\n")
  cat("│    • 'linear' (pas de bornes nécessaires, mais moins contrôle)        │\n")
  cat("│    • 'raking' (pas de bornes nécessaires)                              │\n")
  cat("│                                                                         │\n")
  cat("└─────────────────────────────────────────────────────────────────────────┘\n\n")

  # Retourner les informations
  return(list(
    bounds_suggested = bounds_suggested,
    design = design_lfs,
    popdataframe = popdataframe,
    constrains_x = constrains_x
  ))
}


# ============================================================================
#' Tester la calibration avec des bornes spécifiques
#'
#' Fonction pour tester rapidement différentes bornes et voir si la calibration
#' converge.
#'
#' @param cal_info Liste retournée par show_calibration_info()
#' @param bounds Vecteur de 2 valeurs c(min, max)
#' @param calfun Fonction de calibration ("logit", "linear", "raking")
#' @param maxit Nombre maximum d'itérations (défaut: 30)
#' @param epsilon Critère de convergence (défaut: 1e-4)
#' @param verbose Afficher les détails (défaut: TRUE)
#' @return Objet calibré ou NULL si échec
#' @export
test_calibration_bounds <- function(cal_info,
                                     bounds = c(0.01, 6),
                                     calfun = "logit",
                                     maxit = 30,
                                     epsilon = 1e-4,
                                     verbose = TRUE) {

  if (verbose) {
    cat("\n")
    cat("═══════════════════════════════════════════════════════════════════════════\n")
    cat("  TEST DE CALIBRATION\n")
    cat("═══════════════════════════════════════════════════════════════════════════\n\n")
    cat("  Paramètres testés:\n")
    cat("    • Bornes       : [", bounds[1], ", ", bounds[2], "]\n")
    cat("    • Fonction     : ", calfun, "\n")
    cat("    • Max itérations: ", maxit, "\n")
    cat("    • Epsilon      : ", epsilon, "\n\n")
    cat("  → Exécution de la calibration...\n")
  }

  # Tenter la calibration
  calib_result <- tryCatch({

    e.calibrate(
      design = cal_info$design,
      df.population = cal_info$popdataframe,
      calmodel = cal_info$constrains_x,
      partition = ~ DOMAIN,
      calfun = calfun,
      bounds = if (calfun == "logit") bounds else NULL,
      aggregate.stage = NULL,
      maxit = maxit,
      epsilon = epsilon,
      force = FALSE
    )

  }, warning = function(w) {
    if (verbose) cat("  ⚠ Warning:", w$message, "\n")
    NULL
  }, error = function(e) {
    if (verbose) {
      cat("\n")
      cat("  ✗ ÉCHEC DE LA CALIBRATION\n")
      cat("  Erreur:", e$message, "\n\n")
    }
    return(NULL)
  })

  # Vérifier la convergence
  if (!is.null(calib_result)) {

    # Vérifier les codes de retour
    status <- ecal.status(calib_result)

    if (verbose) {
      cat("\n")
      cat("┌─────────────────────────────────────────────────────────────────────────┐\n")
      cat("│ RÉSULTATS DE LA CALIBRATION                                            │\n")
      cat("├─────────────────────────────────────────────────────────────────────────┤\n")
    }

    # Analyser les codes de retour
    all_converged <- all(status$return.code == 0)

    if (all_converged) {
      if (verbose) {
        cat("│                                                                         │\n")
        cat("│  ✓ SUCCÈS : La calibration a CONVERGÉ pour tous les domaines !         │\n")
        cat("│                                                                         │\n")
      }
    } else {
      if (verbose) {
        cat("│                                                                         │\n")
        cat("│  ✗ ÉCHEC : La calibration N'A PAS CONVERGÉ pour certains domaines      │\n")
        cat("│                                                                         │\n")

        # Afficher les domaines problématiques
        failed_domains <- which(status$return.code != 0)
        cat("│  Domaines sans convergence:                                            │\n")
        for (d in failed_domains) {
          cat("│    • Domaine", d, "- Code de retour:", status$return.code[d], "\n")
        }
        cat("│                                                                         │\n")
        cat("│  💡 Recommandation: Élargir les bornes et réessayer                    │\n")
      }
    }

    # Afficher les statistiques des poids
    if (all_converged && verbose) {
      weights_cal <- weights(calib_result)

      cat("│                                                                         │\n")
      cat("│  Statistiques des poids finaux:                                        │\n")
      cat("│    • Minimum   : ", sprintf("%.4f", min(weights_cal)), "\n")
      cat("│    • Q1        : ", sprintf("%.4f", quantile(weights_cal, 0.25)), "\n")
      cat("│    • Médiane   : ", sprintf("%.4f", median(weights_cal)), "\n")
      cat("│    • Moyenne   : ", sprintf("%.4f", mean(weights_cal)), "\n")
      cat("│    • Q3        : ", sprintf("%.4f", quantile(weights_cal, 0.75)), "\n")
      cat("│    • Maximum   : ", sprintf("%.4f", max(weights_cal)), "\n")
      cat("│    • Total     : ", sprintf("%.0f", sum(weights_cal)), "\n")

      # ===== VÉRIFICATION CRITIQUE DE LA CALIBRATION =====
      # Vérifier que les poids calibrés reproduisent exactement les totaux connus
      cat("│                                                                         │\n")
      cat("│  ⚙ Vérification de la calibration (check.cal):                         │\n")

      check_result <- check.cal(calib_result)

      # Analyser le résultat de check.cal
      # Cette fonction retourne un message indiquant si les contraintes sont satisfaites
      cat("│    → ", gsub("\n", "\n│    → ", capture.output(check_result)), "\n")
    }

    if (verbose) {
      cat("└─────────────────────────────────────────────────────────────────────────┘\n\n")
    }

    # Retourner le résultat avec le statut
    attr(calib_result, "converged") <- all_converged
    attr(calib_result, "bounds_used") <- bounds
    attr(calib_result, "calfun_used") <- calfun

    return(calib_result)

  } else {
    return(NULL)
  }
}


# ============================================================================
#' Tester plusieurs ensembles de bornes automatiquement
#'
#' Teste plusieurs combinaisons de bornes pour trouver celle qui fonctionne.
#'
#' @param cal_info Liste retournée par show_calibration_info()
#' @param bounds_list Liste de vecteurs de bornes à tester
#' @param calfun Fonction de calibration
#' @return Liste avec les résultats de tous les tests
#' @export
test_multiple_bounds <- function(cal_info,
                                  bounds_list = list(
                                    c(0.5, 1.5),
                                    c(0.3, 2.0),
                                    c(0.1, 3.0),
                                    c(0.01, 6.0),
                                    c(0.01, 10.0)
                                  ),
                                  calfun = "logit") {

  cat("\n")
  cat("╔═══════════════════════════════════════════════════════════════════════════╗\n")
  cat("║              TEST AUTOMATIQUE DE PLUSIEURS BORNES                         ║\n")
  cat("╚═══════════════════════════════════════════════════════════════════════════╝\n\n")

  cat("Nombre de combinaisons à tester:", length(bounds_list), "\n\n")

  results <- list()

  for (i in seq_along(bounds_list)) {
    bounds <- bounds_list[[i]]

    cat("─────────────────────────────────────────────────────────────────────────\n")
    cat("Test", i, "/", length(bounds_list), "\n")

    result <- test_calibration_bounds(
      cal_info = cal_info,
      bounds = bounds,
      calfun = calfun,
      verbose = TRUE
    )

    results[[i]] <- list(
      bounds = bounds,
      success = !is.null(result) && attr(result, "converged", exact = TRUE),
      calib_obj = result
    )

    # Si on a trouvé une solution, on peut arrêter
    if (results[[i]]$success) {
      cat("\n")
      cat("✓ SUCCÈS trouvé avec les bornes [", bounds[1], ", ", bounds[2], "]\n")
      cat("  Vous pouvez arrêter ici ou continuer pour tester d'autres bornes.\n\n")
      break
    }
  }

  # Résumé
  cat("\n")
  cat("═══════════════════════════════════════════════════════════════════════════\n")
  cat("  RÉSUMÉ DES TESTS\n")
  cat("═══════════════════════════════════════════════════════════════════════════\n\n")

  for (i in seq_along(results)) {
    status_icon <- if (results[[i]]$success) "✓" else "✗"
    bounds <- results[[i]]$bounds
    cat(status_icon, " Bornes [", bounds[1], ", ", bounds[2], "] : ",
        if (results[[i]]$success) "SUCCÈS" else "ÉCHEC", "\n")
  }

  cat("\n")

  return(results)
}


# ============================================================================
#' Mode interactif de sélection des bornes
#'
#' Interface interactive pour tester les bornes de calibration.
#'
#' @param cal_info Liste retournée par show_calibration_info()
#' @export
interactive_bounds_selection <- function(cal_info) {

  cat("\n")
  cat("╔═══════════════════════════════════════════════════════════════════════════╗\n")
  cat("║              MODE INTERACTIF DE SÉLECTION DES BORNES                     ║\n")
  cat("╚═══════════════════════════════════════════════════════════════════════════╝\n\n")

  cat("Vous pouvez maintenant tester différentes bornes interactivement.\n\n")

  cat("Exemples d'utilisation:\n\n")

  cat("1. Tester les bornes suggérées (si positives):\n")
  cat("   calib_result <- test_calibration_bounds(cal_info, bounds = bounds_suggested)\n\n")

  cat("2. Tester des bornes manuelles:\n")
  cat("   calib_result <- test_calibration_bounds(cal_info, bounds = c(0.01, 6))\n\n")

  cat("3. Tester plusieurs bornes automatiquement:\n")
  cat("   results <- test_multiple_bounds(cal_info)\n\n")

  cat("4. Tester une calibration linéaire (sans bornes):\n")
  cat("   calib_result <- test_calibration_bounds(cal_info, calfun = 'linear')\n\n")

  cat("5. Lancer le contrôle de qualité complet (vérifier écarts régionaux ≤ 100):\n")
  cat("   # D'abord, calculer X_Summary_Table\n")
  cat("   X_Summary_Table <- X_Summaries(numX=xnum, des_size=design_size, des_initial=design_lfs, des_total=popdataframe, des_final=calib_result, L_trsld_corr_fact=0.95, H_trsld_corr_fact=1.65, L_trsld_sample_size=30, calc_tot=TRUE)\n")
  cat("   # Puis lancer le contrôle\n")
  cat("   quality <- run_complete_quality_check(calib_result, X_Summary_Table, threshold_diff=100)\n\n")

  cat("Après avoir trouvé les bonnes bornes et vérifié la qualité,\n")
  cat("continuez avec votre workflow habituel.\n\n")
}
