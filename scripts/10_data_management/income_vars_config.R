# income_vars_config.R
# ------------------------------------------------------------
# Define the mapping between income components (a‑l) and the
# corresponding amount and frequency variables in the survey data.
# The variables are split for the main job (prefix EP) and the
# secondary job (prefix ES).  Replace the placeholder names with the
# actual variable names from your dictionary.

# ---- Main job (EP) ------------------------------------------------
# Amount variables (numeric) – replace with real variable names
EP_AMOUNT_VARS <- list(
    a = "ep_salary_amount", # Salaire
    b = "ep_piece_rate_amount", # Paiement à la tâche
    c = "ep_commission_amount", # Commissions
    d = "ep_tip_amount", # Pourboires
    e = "ep_service_fee_amount", # Frais pour services fournis
    f = "ep_other_cash_amount", # Autre paiement en espèces
    g = "ep_meal_housing_amount", # Paiement avec repas ou hébergement
    h = "ep_profit_amount", # Bénéfice
    i = "ep_in_kind_amount", # Paiement en nature
    j = "ep_unpaid_amount", # Non payé (travailleurs familiaux)
    k = "ep_perdiem_amount", # Perdiems
    l = "ep_bonus_amount" # Primes
)

# Frequency variables (character) – values: "weekly", "monthly", "yearly"
EP_FREQUENCY_VARS <- list(
    a = "ep_salary_freq",
    b = "ep_piece_rate_freq",
    c = "ep_commission_freq",
    d = "ep_tip_freq",
    e = "ep_service_fee_freq",
    f = "ep_other_cash_freq",
    g = "ep_meal_housing_freq",
    h = "ep_profit_freq",
    i = "ep_in_kind_freq",
    j = "ep_unpaid_freq",
    k = "ep_perdiem_freq",
    l = "ep_bonus_freq"
)

# ---- Secondary job (ES) ------------------------------------------------
ES_AMOUNT_VARS <- list(
    a = "es_salary_amount",
    b = "es_piece_rate_amount",
    c = "es_commission_amount",
    d = "es_tip_amount",
    e = "es_service_fee_amount",
    f = "es_other_cash_amount",
    g = "es_meal_housing_amount",
    h = "es_profit_amount",
    i = "es_in_kind_amount",
    j = "es_unpaid_amount",
    k = "es_perdiem_amount",
    l = "es_bonus_amount"
)

ES_FREQUENCY_VARS <- list(
    a = "es_salary_freq",
    b = "es_piece_rate_freq",
    c = "es_commission_freq",
    d = "es_tip_freq",
    e = "es_service_fee_freq",
    f = "es_other_cash_freq",
    g = "es_meal_housing_freq",
    h = "es_profit_freq",
    i = "es_in_kind_freq",
    j = "es_unpaid_freq",
    k = "es_perdiem_freq",
    l = "es_bonus_freq"
)

# Helper to convert a frequency string to a monthly multiplier
freq_to_monthly <- function(freq) {
    switch(tolower(freq),
        "weekly" = 4.345,
        "monthly" = 1,
        "yearly" = 1 / 12,
        NA_real_
    )
}

# Export objects for sourcing
utils::globalVariables(c(
    "EP_AMOUNT_VARS", "EP_FREQUENCY_VARS",
    "ES_AMOUNT_VARS", "ES_FREQUENCY_VARS",
    "freq_to_monthly"
))
