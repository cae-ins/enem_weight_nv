# ==============================================================================
# Script_name : 2_attrition_propensity.R
# Title       : Modelled non-response adjustment (production from T1 2026)
# Description : Alternative branch to the regional cell adjustment of
#               1_adjust_weights_non_response.R. For households at their 2nd to
#               4th interview, the non-response factor is a response-propensity
#               class adjustment estimated on the cohort's first-interview
#               respondents; first-interview households keep a cell adjustment
#               (region x rank).
#               Production method from NR_MODEL_FIRST_QUARTER (T1 2026) on.
#               Runs after 02_base_weights/3_indivs_weights.R and updates the
#               calibration input in place:
#                 data/04_weights/<quarter>/base_weights/individu_<quarter>.dta
#               d_weights = modelled weight, d_weights_cellules = historical
#               weight (corrected_weight_HH), both calibrated by the standard
#               master (FINAL_WEIGHT and FINAL_WEIGHT_cellules). Model
#               diagnostics: base_weights/nr_modele_*_<quarter>.csv.
# Usage       : Rscript scripts/03_nonresponse/2_attrition_propensity.R [--quarter=T1_2026]
# ==============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(haven)
  library(labelled)
})

# ------------------------------------------------------------------------------
# Parameters
# ------------------------------------------------------------------------------
source("config/1_config.r")
q_index <- function(q) 4L * as.integer(substr(q, 4, 7)) + as.integer(substr(q, 2, 2)) - 1L

args <- commandArgs(trailingOnly = TRUE)
quarter <- TARGET_QUARTER
for (arg in args) {
  if (grepl("^--quarter=", arg)) {
    quarter <- sub("^--quarter=", "", arg)
  } else {
    stop("Option inconnue : ", arg, call. = FALSE)
  }
}
if (!grepl("^T[1-4]_[0-9]{4}$", quarter)) stop("--quarter attendu au format T1_2026.", call. = FALSE)
if (q_index(quarter) < q_index(NR_MODEL_FIRST_QUARTER)) {
  stop("La non-réponse modélisée s'applique à partir de ", NR_MODEL_FIRST_QUARTER,
       " (trimestres antérieurs déjà publiés).", call. = FALSE)
}

# Indicator bases (Traite_) of the cohorts' first quarters, downloaded from
# MinIO gold/enem/<quarter>/base_indicateurs/ by scripts/medallion/03_download_weights_inputs.ps1.
TRAITE_DIR <- "data/03_processed/base_indicateurs"
W_DIR <- "data/04_weights"
BW_DIR <- file.path(W_DIR, quarter, "base_weights")
diag_path <- function(name) file.path(BW_DIR, paste0("nr_modele_", name, "_", quarter, ".csv"))

N_CLASSES <- 5L          # propensity classes per interview rank
EXPECTED_HH_PER_SEG <- 12

q_label <- function(i) paste0("T", i %% 4L + 1L, "_", i %/% 4L)
short <- function(q) paste0(substr(q, 6, 7), substr(q, 1, 2))   # T4_2025 -> 25T4

# Rotation 2-2-2: offsets 0, 1, 4, 5 from the first quarter give ranks 1 to 4.
current <- q_index(quarter)
cohorts <- data.frame(rank = 2:4, offset = c(1L, 4L, 5L))
cohorts$first <- vapply(current - cohorts$offset, q_label, character(1))
# Intermediate visits (between the first interview and the current quarter).
intermediate <- list(
  `2` = character(0),
  `3` = q_label(current - 3L),
  `4` = c(q_label(current - 4L), q_label(current - 1L))
)

clean_key <- function(x) {
  x <- trimws(as.character(x))
  x[x %in% c("", "nan", "##N/A##")] <- NA
  x
}
zd_key <- function(hh2, hh3, hh4, hh8) {
  paste(sprintf("%.0f", as.numeric(hh2)), sprintf("%.0f", as.numeric(hh3)),
        sprintf("%.0f", as.numeric(hh4)), trimws(as.character(hh8)), sep = "_")
}
read_menage <- function(q) {
  haven::read_dta(
    file.path(W_DIR, q, "base_weights", paste0("menage_", q, ".dta")),
    col_select = any_of(c("interview_key", "first_trim", "hh14", "v1interviewkey",
                          "hh2", "hh3", "hh4", "hh6", "hh8", "modintr", "hh10_1",
                          "ord_sem", "date_ref_x", "hha", "visite",
                          "q1_0", "hh10_2", "hh11_0"))
  ) %>%
    mutate(across(everything(), haven::zap_labels)) %>%
    distinct(interview_key, .keep_all = TRUE)
}
traite_path <- function(q) {
  path <- file.path(TRAITE_DIR, q, paste0("Traite_", short(q), ".dta"))
  if (!file.exists(path)) {
    stop("Base Traite absente pour ", q, " : ", path,
         "\nLa télécharger depuis MinIO (gold/enem/", q, "/base_indicateurs/) avec ",
         "scripts/medallion/03_download_weights_inputs.ps1 -Quarter ", quarter, call. = FALSE)
  }
  path
}

# ------------------------------------------------------------------------------
# 1. Frame: first-interview respondents of each re-interviewed cohort
# ------------------------------------------------------------------------------
# A household responds when it enters the calibration input of the quarter
# (individual records with a corrected weight, whatever HH14): same set as the
# calibrated sample, but known before the calibration.
IND_PATH <- file.path(W_DIR, quarter, "base_weights", paste0("individu_", quarter, ".dta"))
cal_keys <- unique(haven::read_dta(IND_PATH, col_select = "interview_key")$interview_key)
cur <- read_menage(quarter) %>%
  mutate(v1 = clean_key(v1interviewkey), repondant = interview_key %in% cal_keys)
message("Ménages du trimestre : ", nrow(cur), " ; dans l'échantillon calibré : ", sum(cur$repondant),
        " ; dont HH14 = 1 : ", sum(cur$repondant & cur$hh14 %in% 1))

frame <- bind_rows(lapply(seq_len(nrow(cohorts)), function(i) {
  coh <- cohorts$first[i]
  m <- read_menage(coh) %>% filter(first_trim == coh, hh14 == 1)
  # Household composition and labour status at the first interview.
  p <- haven::read_dta(traite_path(coh), col_select = c(
    "interview_key", "membres_id", "age", "sexe", "m4", "niveau_instruction",
    "pop_emp_dich", "SU1"
  )) %>%
    mutate(across(everything(), haven::zap_labels)) %>%
    filter(interview_key %in% m$interview_key)
  h <- p %>%
    group_by(interview_key) %>%
    summarise(
      taille = n(),
      n_enf6 = sum(age < 6, na.rm = TRUE),
      n_16plus = sum(age >= 16, na.rm = TRUE),
      n_emploi = sum(pop_emp_dich == 1, na.rm = TRUE),
      n_chom = sum(SU1 == 1, na.rm = TRUE),
      cm_age = age[which(m4 == 1)[1]],
      cm_femme = as.integer(sexe[which(m4 == 1)[1]] == 2),
      cm_instr = niveau_instruction[which(m4 == 1)[1]],
      .groups = "drop"
    )
  # Response at intermediate visits (known before the current quarter).
  inter <- intermediate[[as.character(cohorts$rank[i])]]
  n_inter <- rep(0L, nrow(m))
  for (iq in inter) {
    v <- read_menage(iq) %>%
      filter(first_trim == coh, hh14 == 1) %>%
      mutate(v1 = clean_key(v1interviewkey))
    n_inter <- n_inter + as.integer(m$interview_key %in% v$v1)
  }
  out <- cur %>% filter(first_trim == coh)
  m %>%
    mutate(
      rang = cohorts$rank[i],
      cohorte = coh,
      zdkey = zd_key(hh2, hh3, hh4, hh8),
      n_inter_ok = n_inter,
      n_inter_max = length(inter),
      repond = as.integer(interview_key %in% out$v1[out$repondant])
    ) %>%
    left_join(h, by = "interview_key")
}))

frame <- frame %>%
  mutate(
    abidjan = as.integer(hh2 == 10101),
    district = factor(floor(hh2 / 100)),
    urbain = as.integer(hh6 == 1),
    telephone = as.integer(!is.na(clean_key(hh10_1))),
    appel = as.integer(modintr %in% 2),
    taille_c = cut(taille, c(0, 1, 3, 5, 8, Inf), labels = c("1", "2-3", "4-5", "6-8", "9+")),
    cm_age_c = cut(cm_age, c(-Inf, 29, 44, 59, Inf), labels = c("<30", "30-44", "45-59", "60+")),
    cm_instr_c = case_when(
      is.na(cm_instr) ~ "nd",
      cm_instr %in% c(-99, 0, 1) ~ "aucun",
      cm_instr == 2 ~ "primaire",
      cm_instr %in% 3:6 ~ "secondaire",
      TRUE ~ "superieur"
    ),
    part_emploi = ifelse(n_16plus > 0, n_emploi / n_16plus, 0),
    chom = as.integer(n_chom > 0),
    enf6 = as.integer(n_enf6 > 0),
    rang_f = factor(rang),
    # Collection paradata of the first interview. The household is re-interviewed
    # in the same week of the quarter (semaine_ref of the preloading script).
    # ord_sem looks like "Sem_11_T1A2025" or "Tele_Sem_8_4T2025_01001947".
    semaine = suppressWarnings(as.integer(sub("_.*$", "", sub("^(Tele_)?Sem_", "", ord_sem)))),
    semaine_c = factor(cut(semaine, c(0, 3, 7, 10, 13), labels = c("1-3", "4-7", "8-10", "11-13"))),
    delai = as.numeric(difftime(as.POSIXct(substr(hha, 1, 10), tz = "UTC"),
                                as.POSIXct(substr(date_ref_x, 1, 10), tz = "UTC"), units = "days")),
    delai_c = factor(cut(delai, c(-Inf, 3, 7, 14, Inf), labels = c("0-3j", "4-7j", "8-14j", "15j+"))),
    visites_mult = as.integer(visite > 1 & !is.na(visite)),
    # Respondent profile at the first interview (equivalent of profil_rep):
    # household questionnaire answered by someone other than the head, and
    # number of ways to re-contact the household (phones, e-mail).
    rep_non_cm = as.integer(q1_0 %in% 2),
    n_contacts = telephone + as.integer(!is.na(clean_key(hh10_2))) + as.integer(hh11_0 %in% 1),
    contacts_c = factor(pmin(n_contacts, 2), levels = 0:2, labels = c("aucun", "un", "deux+")),
    inter_c = factor(ifelse(n_inter_max == 0, "sans_objet",
                     paste0(n_inter_ok, "/", n_inter_max)))
  ) %>%
  mutate(
    # Households absent from the indicator base of their first quarter, or
    # without an identified head, are kept with an explicit flag.
    compo_nd = as.integer(is.na(taille)),
    across(c(enf6, cm_femme, part_emploi, chom), ~ ifelse(is.na(.x), 0, .x)),
    across(c(taille_c, cm_age_c, semaine_c, delai_c), ~ addNA(.x)),
    cm_instr_c = factor(cm_instr_c)
  )

message("Panel attendu : ", nrow(frame), " ménages ; répondants au ", quarter, " : ", sum(frame$repond))

# ------------------------------------------------------------------------------
# 2. Response propensity model (logit, covariates measured before the quarter)
# ------------------------------------------------------------------------------
base_formula <- repond ~ rang_f + inter_c + abidjan + urbain + district + taille_c + enf6 +
  cm_age_c + cm_femme + cm_instr_c + part_emploi + chom + telephone + appel + compo_nd
model_base <- glm(base_formula, family = binomial(), data = frame)
# Extended model: collection paradata of the first interview.
model_para <- glm(update(base_formula, . ~ . + semaine_c + delai_c + visites_mult),
                  family = binomial(), data = frame)
# Final model: paradata + respondent profile (contacts replace the single phone flag).
model <- glm(update(base_formula, . ~ . - telephone + semaine_c + delai_c + visites_mult +
                      rep_non_cm + contacts_c),
             family = binomial(), data = frame)
frame$p_hat <- predict(model, type = "response")
frame$p_base <- predict(model_base, type = "response")
frame$p_para <- predict(model_para, type = "response")
lr <- anova(model_base, model_para, test = "LRT")
lr_profil <- anova(model_para, model, test = "LRT")

auc <- function(y, p) {
  r <- rank(p); n1 <- sum(y == 1); n0 <- sum(y == 0)
  (sum(r[y == 1]) - n1 * (n1 + 1) / 2) / (n1 * n0)
}
coefs <- as.data.frame(summary(model)$coefficients)
coefs$terme <- rownames(coefs)
write.csv(coefs, diag_path("coefficients"), row.names = FALSE, fileEncoding = "UTF-8")

# Propensity classes: quintiles of p_hat within each rank.
frame <- frame %>%
  group_by(rang) %>%
  mutate(classe = dplyr::ntile(p_hat, N_CLASSES)) %>%
  ungroup()

# ------------------------------------------------------------------------------
# 3. Modelled non-response adjustment (household-level input weight)
# ------------------------------------------------------------------------------
bw <- haven::read_dta(file.path(W_DIR, quarter, "base_weights", paste0("base_weights_", quarter, ".dta"))) %>%
  mutate(across(everything(), haven::zap_labels),
         zdkey = paste(sprintf("%.0f", region), sprintf("%.0f", depart),
                       sprintf("%.0f", souspref), trimws(ZD), sep = "_"))
stopifnot(!anyDuplicated(bw$zdkey))

# Rank of each sampled ZD in the current quarter.
bw$rang <- ifelse(bw$first_trim %in% cohorts$first,
                  cohorts$rank[match(bw$first_trim, cohorts$first)], 1L)

# Respondents of the current quarter (households) with their ZD.
resp <- cur %>%
  filter(repondant) %>%
  mutate(zdkey = zd_key(hh2, hh3, hh4, hh8)) %>%
  left_join(bw %>% select(zdkey, region, rang, base_weight_HH, nb_men_theo), by = "zdkey")
message("Ménages répondants sans ZD dans base_weights : ", sum(is.na(resp$base_weight_HH)))

# Rank 1: region x rank cells, without model: 12 x segments / respondents.
cells <- bw %>% group_by(region, rang) %>% summarise(theo = sum(nb_men_theo), .groups = "drop") %>%
  left_join(resp %>% filter(!is.na(rang)) %>% count(region, rang, name = "enq"), by = c("region", "rang")) %>%
  mutate(f_cell = theo / enq)
resp <- resp %>% left_join(cells %>% select(region, rang, f_cell), by = c("region", "rang"))

# Ranks 2-4: phase 1 = 12 x segments / first-interview
# respondents (region x rank), phase 2 = propensity class factor
# (weighted frame / weighted respondents, weights = base weight of the ZD).
frame <- frame %>% left_join(bw %>% select(zdkey, region, base_weight_HH, nb_men_theo), by = "zdkey")
message("Ménages du panel sans ZD dans base_weights : ", sum(is.na(frame$base_weight_HH)))
phase1 <- bw %>% filter(rang >= 2) %>% group_by(region, rang) %>%
  summarise(theo = sum(nb_men_theo), .groups = "drop") %>%
  left_join(frame %>% count(region, rang, name = "n1"), by = c("region", "rang")) %>%
  mutate(f_phase1 = theo / n1)
classes <- frame %>% filter(!is.na(base_weight_HH)) %>% group_by(rang, classe) %>%
  summarise(
    n_panel = n(), n_rep = sum(repond),
    p_moy = mean(p_hat),
    taux_brut = n_rep / n_panel,
    f_classe = sum(base_weight_HH) / sum(base_weight_HH * repond),
    .groups = "drop"
  )
write.csv(classes, diag_path("classes"), row.names = FALSE, fileEncoding = "UTF-8")

link <- frame %>% filter(repond == 1) %>% select(v1 = interview_key, classe)
resp <- resp %>%
  left_join(link, by = "v1") %>%
  left_join(phase1 %>% select(region, rang, f_phase1), by = c("region", "rang")) %>%
  left_join(classes %>% select(rang, classe, f_classe), by = c("rang", "classe")) %>%
  mutate(
    d_cell = base_weight_HH * f_cell,
    d_modele = ifelse(rang == 1, d_cell, base_weight_HH * f_phase1 * f_classe)
  )
message("Répondants réinterrogés sans classe (non retrouvés dans le panel) : ",
        sum(resp$rang >= 2 & is.na(resp$classe), na.rm = TRUE))
# Re-interviewed respondents outside the panel frame keep the cell weight.
resp$d_modele <- ifelse(is.na(resp$d_modele), resp$d_cell, resp$d_modele)
stopifnot(!anyDuplicated(resp$interview_key), !anyNA(resp$d_modele))


# ------------------------------------------------------------------------------
# 4. Calibration input: individu_<quarter>.dta with the modelled d_weights
# ------------------------------------------------------------------------------
# Same file as the official input (3_indivs_weights.R), only d_weights changes.
# The calibration itself is run by the standard master.
individu <- haven::read_dta(IND_PATH)
nr_cols <- c("rang", "classe_propension", "f_cell", "f_phase1", "f_classe", "d_weights_cellules")
individu <- individu %>%
  select(-any_of(nr_cols)) %>%
  # Historical weight from the cell adjustment (idempotent if the script is rerun).
  mutate(d_weights_cellules = corrected_weight_HH) %>%
  left_join(resp %>% select(interview_key, rang, classe_propension = classe,
                            f_cell, f_phase1, f_classe, d_modele),
            by = "interview_key") %>%
  mutate(d_weights = d_modele) %>%
  select(-d_modele) %>%
  set_variable_labels(
    d_weights = "Poids avant calage - non-réponse modélisée",
    d_weights_cellules = "Poids avant calage - correction régionale (méthode historique)",
    rang = "Rang d'interrogation du ménage (1 à 4)",
    classe_propension = "Quintile de propension de réponse (rangs 2 à 4)",
    f_cell = "Facteur de non-réponse région x rang",
    f_phase1 = "Facteur phase 1 : 12 x segments / répondants à la 1re interrogation",
    f_classe = "Facteur phase 2 : classe de propension"
  )
stopifnot(!anyNA(individu$d_weights))

haven::write_dta(individu, IND_PATH)

by_rank <- individu %>%
  group_by(rang) %>%
  summarise(n = n(), cellules = sum(d_weights_cellules), modele = sum(d_weights), .groups = "drop") %>%
  mutate(part_cellules = 100 * cellules / sum(cellules), part_modele = 100 * modele / sum(modele))
write.csv(by_rank, diag_path("poids_par_rang"), row.names = FALSE, fileEncoding = "UTF-8")

diagnostics <- data.frame(
  quarter = quarter,
  panel_menages = nrow(frame),
  panel_repondants = sum(frame$repond),
  auc_sans_paradonnees = auc(frame$repond, frame$p_base),
  auc_avec_paradonnees = auc(frame$repond, frame$p_para),
  auc_modele_final = auc(frame$repond, frame$p_hat),
  lrt_paradonnees_p = lr$`Pr(>Chi)`[2],
  lrt_profil_p = lr_profil$`Pr(>Chi)`[2]
)
write.csv(diagnostics, diag_path("diagnostics"), row.names = FALSE, fileEncoding = "UTF-8")

cat("\n== Modèle ==\n"); print(summary(model)$coefficients[, c(1, 2, 4)], digits = 3)
cat("AUC modèle sans paradonnées :", round(diagnostics$auc_sans_paradonnees, 3),
    " ; avec paradonnées :", round(diagnostics$auc_avec_paradonnees, 3),
    " ; avec paradonnées et profil du répondant :", round(diagnostics$auc_modele_final, 3), "\n")
cat("Test du rapport de vraisemblance (profil du répondant) :\n"); print(lr_profil)
cat("Test du rapport de vraisemblance (paradonnées) :\n"); print(lr)
cat("\n== Taux de réponse bruts selon les paradonnées ==\n")
for (v in c("semaine_c", "delai_c", "visites_mult", "rep_non_cm", "contacts_c")) {
  print(frame %>% group_by(rang, .data[[v]]) %>%
          summarise(n = n(), taux = round(100 * mean(repond), 1), .groups = "drop") %>%
          tidyr::pivot_wider(names_from = rang, values_from = c(n, taux)) %>% as.data.frame())
}
cat("\n== Classes de propension ==\n"); print(as.data.frame(classes), digits = 3)
cat("\n== Poids avant calage par rang (%) ==\n"); print(as.data.frame(by_rank), digits = 3)
cat("\nEntrée du calage mise à jour : ", IND_PATH, "\n", sep = "")
cat("Étape suivante : 00_Master_Calibration_180X_1D.R (FINAL_WEIGHT et FINAL_WEIGHT_cellules)\n")
