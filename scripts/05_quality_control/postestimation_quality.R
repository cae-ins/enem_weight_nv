# ==============================================================================
# Quarterly Survey Indicators – Mean, CI, CV, Quality Flags
# Statistics Canada style – ENHANCED with Regional & District Breakdowns
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. Packages
# ------------------------------------------------------------------------------
library(survey)
library(dplyr)
library(openxlsx)
library(ggplot2)
library(scales)
library(haven)
library(tidyr)

# ------------------------------------------------------------------------------
# 1. Data validation and summary
# ------------------------------------------------------------------------------
# Check for required variables
df = read_dta("data/04_weights/Base_Travail_BT_vf.dta")  
required_vars <- c("pmencor_ind", "trimestre", "pop_emp_dich", "SU1","SU2","SU3","SU4", "region", "District")
missing_vars <- setdiff(required_vars, names(df))

if (length(missing_vars) > 0) {
  stop("Missing required variables in dataframe 'df': ", 
       paste(missing_vars, collapse = ", "))
}

# Basic data summary
cat("\n=== DATA SUMMARY ===\n")
cat("Total observations:", nrow(df), "\n")
cat("Quarters present:", paste(unique(df$trimestre), collapse = ", "), "\n")
cat("Regions present:", paste(sort(unique(df$region)), collapse = ", "), "\n")
cat("Districts present:", length(unique(df$District)), "unique districts\n")
cat("Weight range:", round(min(df$pmencor_ind, na.rm = TRUE), 2), "to", 
    round(max(df$pmencor_ind, na.rm = TRUE), 2), "\n\n")

# Missing data summary
missing_summary <- data.frame(
  variable = c("pmencor_ind", "trimestre", "pop_emp_dich", "region", "District", "SU1","SU2","SU3","SU4"),
  n_missing = c(
    sum(is.na(df$pmencor_ind)),
    sum(is.na(df$trimestre)),
    sum(is.na(df$pop_emp_dich)),
    sum(is.na(df$region)),
    sum(is.na(df$District)),
    sum(is.na(df$SU1)),
    sum(is.na(df$SU2)),
    sum(is.na(df$SU3)),
    sum(is.na(df$SU4))
  ),
  pct_missing = round(c(
    sum(is.na(df$pmencor_ind)) / nrow(df) * 100,
    sum(is.na(df$trimestre)) / nrow(df) * 100,
    sum(is.na(df$pop_emp_dich)) / nrow(df) * 100,
    sum(is.na(df$region)) / nrow(df) * 100,
    sum(is.na(df$District)) / nrow(df) * 100,
    sum(is.na(df$SU1)) / nrow(df) * 100,
    sum(is.na(df$SU2)) / nrow(df) * 100,
    sum(is.na(df$SU3)) / nrow(df) * 100,
    sum(is.na(df$SU4)) / nrow(df) * 100
  ), 2)
)

print(missing_summary)
cat("\n")

# Regional and District distribution
cat("=== DISTRIBUTION BY REGION ===\n")
region_dist <- df %>%
  group_by(region) %>%
  summarise(
    n = n(),
    pct = round(n() / nrow(df) * 100, 2),
    .groups = "drop"
  ) %>%
  arrange(desc(n))
print(region_dist)
cat("\n")

cat("=== DISTRIBUTION BY DISTRICT (Top 15) ===\n")
district_dist <- df %>%
  group_by(District) %>%
  summarise(
    n = n(),
    pct = round(n() / nrow(df) * 100, 2),
    .groups = "drop"
  ) %>%
  arrange(desc(n)) %>%
  head(15)
print(district_dist)
cat("\n")

# ------------------------------------------------------------------------------
# 2. Survey design (Stata pweight equivalent)
# ------------------------------------------------------------------------------
options(survey.lonely.psu = "adjust")

des <- svydesign(
  ids = ~1,
  weights = ~pmencor_ind,
  data = df
)

# ------------------------------------------------------------------------------
# 3. Indicators to estimate
# ------------------------------------------------------------------------------
indicators <- c("SU1", "SU2", "SU3", "SU4")

# ------------------------------------------------------------------------------
# 4. Statistics Canada CV quality flag function
# ------------------------------------------------------------------------------
cv_flag <- function(estimate, cv) {
  case_when(
    is.na(estimate) | estimate == 0 ~ "F",
    cv < 0.15                       ~ "A",
    cv < 0.30                       ~ "B",
    TRUE                            ~ "C"
  )
}

# ------------------------------------------------------------------------------
# 5. Quality footnotes
# ------------------------------------------------------------------------------
quality_footnotes <- data.frame(
  Flag = c("A", "B", "C", "F"),
  Meaning = c(
    "Reliable estimate (CV < 15%)",
    "Use with caution (15% ≤ CV < 30%)",
    "Unreliable estimate (CV ≥ 30%)",
    "Estimate suppressed or not reliable"
  )
)

# ------------------------------------------------------------------------------
# 6. Enhanced estimation function with sample sizes
# ------------------------------------------------------------------------------
estimate_by_quarter <- function(var, design, quarter_var = "trimestre") {
  
  f <- as.formula(paste0("~", var))
  
  # Get sample sizes (unweighted)
  n_data <- design$variables %>%
    group_by(!!sym(quarter_var)) %>%
    summarise(
      n_total = n(),
      n_valid = sum(!is.na(!!sym(var))),
      n_missing = sum(is.na(!!sym(var))),
      pct_missing = round(n_missing / n_total * 100, 2),
      .groups = "drop"
    )
  
  # Weighted estimates
  res <- svyby(
    formula = f,
    by = as.formula(paste0("~", quarter_var)),
    design = design,
    FUN = svymean,
    vartype = c("se", "ci"),
    na.rm = TRUE
  )
  
  # Convert to data.frame and inspect column names
  res <- as.data.frame(res)
  
  # Dynamically find column names
  col_names <- names(res)
  quarter_col <- col_names[1]
  estimate_col <- col_names[grepl(paste0("^", var, "$"), col_names)]
  se_col <- col_names[grepl("^se", col_names)]
  ci_l_col <- col_names[grepl("^ci_l", col_names)]
  ci_u_col <- col_names[grepl("^ci_u", col_names)]
  
  # Rename columns to standardized names
  res_renamed <- res
  names(res_renamed)[names(res_renamed) == quarter_col] <- quarter_var
  names(res_renamed)[names(res_renamed) == estimate_col] <- "estimate"
  names(res_renamed)[names(res_renamed) == se_col] <- "se"
  names(res_renamed)[names(res_renamed) == ci_l_col] <- "ci_l"
  names(res_renamed)[names(res_renamed) == ci_u_col] <- "ci_u"
  
  # Combine with sample sizes
  res_renamed %>%
    left_join(n_data, by = quarter_var) %>%
    mutate(
      indicator = var,
      cv = se / estimate,
      flag = cv_flag(estimate, cv)
    ) %>%
    select(
      indicator,
      !!sym(quarter_var),
      n_total,
      n_valid,
      n_missing,
      pct_missing,
      estimate,
      se,
      ci_l,
      ci_u,
      cv,
      flag
    )
}

# ------------------------------------------------------------------------------
# 6b. NEW: Estimation function with stratification
# ------------------------------------------------------------------------------
estimate_by_quarter_and_strata <- function(var, design, quarter_var = "trimestre", strata_var) {
  
  f <- as.formula(paste0("~", var))
  
  # Get sample sizes (unweighted)
  n_data <- design$variables %>%
    group_by(!!sym(quarter_var), !!sym(strata_var)) %>%
    summarise(
      n_total = n(),
      n_valid = sum(!is.na(!!sym(var))),
      n_missing = sum(is.na(!!sym(var))),
      pct_missing = round(n_missing / n_total * 100, 2),
      .groups = "drop"
    )
  
  # Weighted estimates
  res <- svyby(
    formula = f,
    by = as.formula(paste0("~", quarter_var, "+", strata_var)),
    design = design,
    FUN = svymean,
    vartype = c("se", "ci"),
    na.rm = TRUE
  )
  
  # Convert to data.frame
  res <- as.data.frame(res)
  
  # Dynamically find column names
  col_names <- names(res)
  quarter_col <- col_names[1]
  strata_col <- col_names[2]
  estimate_col <- col_names[grepl(paste0("^", var, "$"), col_names)]
  se_col <- col_names[grepl("^se", col_names)]
  ci_l_col <- col_names[grepl("^ci_l", col_names)]
  ci_u_col <- col_names[grepl("^ci_u", col_names)]
  
  # Rename columns
  res_renamed <- res
  names(res_renamed)[names(res_renamed) == quarter_col] <- quarter_var
  names(res_renamed)[names(res_renamed) == strata_col] <- strata_var
  names(res_renamed)[names(res_renamed) == estimate_col] <- "estimate"
  names(res_renamed)[names(res_renamed) == se_col] <- "se"
  names(res_renamed)[names(res_renamed) == ci_l_col] <- "ci_l"
  names(res_renamed)[names(res_renamed) == ci_u_col] <- "ci_u"
  
  # Combine with sample sizes
  res_renamed %>%
    left_join(n_data, by = c(quarter_var, strata_var)) %>%
    mutate(
      indicator = var,
      cv = se / estimate,
      flag = cv_flag(estimate, cv)
    ) %>%
    select(
      indicator,
      !!sym(quarter_var),
      !!sym(strata_var),
      n_total,
      n_valid,
      n_missing,
      pct_missing,
      estimate,
      se,
      ci_l,
      ci_u,
      cv,
      flag
    )
}

# ------------------------------------------------------------------------------
# 7. Run estimation - OVERALL
# ------------------------------------------------------------------------------
cat("Running overall estimations...\n")

results_all <- bind_rows(
  lapply(indicators, estimate_by_quarter, design = des)
) %>%
  mutate(
    estimate = round(estimate, 4),
    se       = round(se, 4),
    ci_l     = round(ci_l, 4),
    ci_u     = round(ci_u, 4),
    cv       = round(cv, 4)
  ) %>%
  arrange(indicator, .data$trimestre)

cat("Overall estimations complete.\n\n")

# ------------------------------------------------------------------------------
# 7b. NEW: Run estimation - BY REGION
# ------------------------------------------------------------------------------
cat("Running estimations by REGION...\n")

results_region <- bind_rows(
  lapply(indicators, estimate_by_quarter_and_strata, design = des, strata_var = "region")
) %>%
  mutate(
    estimate = round(estimate, 4),
    se       = round(se, 4),
    ci_l     = round(ci_l, 4),
    ci_u     = round(ci_u, 4),
    cv       = round(cv, 4)
  ) %>%
  arrange(indicator, trimestre, region)

cat("Regional estimations complete.\n\n")

# ------------------------------------------------------------------------------
# 7c. NEW: Run estimation - BY DISTRICT
# ------------------------------------------------------------------------------
cat("Running estimations by DISTRICT...\n")

results_district <- bind_rows(
  lapply(indicators, estimate_by_quarter_and_strata, design = des, strata_var = "District")
) %>%
  mutate(
    estimate = round(estimate, 4),
    se       = round(se, 4),
    ci_l     = round(ci_l, 4),
    ci_u     = round(ci_u, 4),
    cv       = round(cv, 4)
  ) %>%
  arrange(indicator, trimestre, District)

cat("District estimations complete.\n\n")

# ------------------------------------------------------------------------------
# 8. Quality flag summaries
# ------------------------------------------------------------------------------
cat("=== QUALITY FLAG SUMMARY - OVERALL ===\n")
flag_summary_overall <- results_all %>%
  group_by(flag) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(flag)
print(flag_summary_overall)
cat("\n")

cat("=== QUALITY FLAG SUMMARY - BY REGION ===\n")
flag_summary_region <- results_region %>%
  group_by(flag) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(flag)
print(flag_summary_region)
cat("\n")

cat("=== QUALITY FLAG SUMMARY - BY DISTRICT ===\n")
flag_summary_district <- results_district %>%
  group_by(flag) %>%
  summarise(count = n(), .groups = "drop") %>%
  arrange(flag)
print(flag_summary_district)
cat("\n")

# ------------------------------------------------------------------------------
# 9. CONSOLIDATED EXCEL TABLE FUNCTION
# ------------------------------------------------------------------------------
create_consolidated_table <- function(results_df) {
  
  # Pour chaque combinaison indicateur-trimestre, créer le texte formaté
  formatted_data <- results_df %>%
    mutate(
      # Ligne 1: Estimation
      line1 = sprintf("%.4f", estimate),
      # Ligne 2: SE entre parenthèses
      line2 = sprintf("(%.4f)", se),
      # Ligne 3: IC entre crochets
      line3 = sprintf("[%.4f, %.4f]", ci_l, ci_u),
      # Combiner les trois lignes avec retour à la ligne
      cell_value = paste(line1, line2, line3, sep = "\n"),
      # Ajouter le flag de qualité
      cell_value_with_flag = paste0(cell_value, " ", flag)
    )
  
  # Créer le tableau large (indicateurs en lignes, trimestres en colonnes)
  wide_table <- formatted_data %>%
    select(indicator, trimestre, cell_value_with_flag) %>%
    pivot_wider(
      names_from = trimestre,
      values_from = cell_value_with_flag,
      names_prefix = "Q"
    )
  
  return(wide_table)
}

# ------------------------------------------------------------------------------
# 10. MAIN EXCEL WORKBOOK - ENHANCED WITH REGIONAL/DISTRICT SHEETS
# ------------------------------------------------------------------------------
cat("Creating comprehensive Excel workbook...\n")

# Create output directory if it doesn't exist
output_dir <- "data/08_STANDARD_ERRORS"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

wb_main <- createWorkbook()

# Define styles
headerStyle <- createStyle(
  fontSize = 12,
  fontColour = "white",
  fgFill = "#4F81BD",
  halign = "center",
  valign = "center",
  textDecoration = "bold",
  border = "TopBottomLeftRight"
)

dataStyle <- createStyle(
  halign = "center",
  valign = "center",
  border = "TopBottomLeftRight",
  wrapText = TRUE
)

# ------------------------------------------------------------------------------
# Sheet 1: Overall Consolidated
# ------------------------------------------------------------------------------
cat("  Creating sheet: Overall_Consolidated\n")
addWorksheet(wb_main, "Overall_Consolidated")

consolidated_overall <- create_consolidated_table(results_all)

writeData(wb_main, "Overall_Consolidated", consolidated_overall, startRow = 1, startCol = 1)

addStyle(wb_main, "Overall_Consolidated", headerStyle, 
         rows = 1, cols = 1:ncol(consolidated_overall), gridExpand = TRUE)
addStyle(wb_main, "Overall_Consolidated", dataStyle, 
         rows = 2:(nrow(consolidated_overall) + 1), cols = 1:ncol(consolidated_overall), gridExpand = TRUE)

setRowHeights(wb_main, "Overall_Consolidated", rows = 2:(nrow(consolidated_overall) + 1), heights = 60)
setColWidths(wb_main, "Overall_Consolidated", cols = 1:ncol(consolidated_overall), 
             widths = c(15, rep(20, ncol(consolidated_overall) - 1)))

# Add footnotes
start_row <- nrow(consolidated_overall) + 4
writeData(wb_main, "Overall_Consolidated", "Quality flags:", startRow = start_row, startCol = 1)
writeDataTable(wb_main, "Overall_Consolidated", quality_footnotes, startRow = start_row + 1, startCol = 1)

# ------------------------------------------------------------------------------
# Sheet 2: Overall Details
# ------------------------------------------------------------------------------
cat("  Creating sheet: Overall_Details\n")
addWorksheet(wb_main, "Overall_Details")
writeDataTable(wb_main, "Overall_Details", results_all, withFilter = TRUE)

start_row <- nrow(results_all) + 4
writeData(wb_main, "Overall_Details", "Quality flags:", startRow = start_row, startCol = 1)
writeDataTable(wb_main, "Overall_Details", quality_footnotes, startRow = start_row + 1, startCol = 1)

# ------------------------------------------------------------------------------
# Sheets 3-N: By Region (one sheet per quarter)
# ------------------------------------------------------------------------------
cat("  Creating sheets: By Region\n")

quarters <- unique(results_region$trimestre)

for (q in quarters) {
  sheet_name <- paste0("Region_Q", q)
  cat("    - ", sheet_name, "\n")
  
  addWorksheet(wb_main, sheet_name)
  
  sheet_data <- results_region %>% 
    filter(trimestre == q) %>%
    arrange(region, indicator)
  
  writeDataTable(wb_main, sheet_name, sheet_data, withFilter = TRUE)
  
  # Add footnotes
  start_row <- nrow(sheet_data) + 4
  writeData(wb_main, sheet_name, "Quality flags:", startRow = start_row, startCol = 1)
  writeDataTable(wb_main, sheet_name, quality_footnotes, startRow = start_row + 1, startCol = 1)
}

# ------------------------------------------------------------------------------
# Sheets N+1: Regional Summary (all quarters, wide format by region)
# ------------------------------------------------------------------------------
cat("  Creating sheet: Regional_Summary\n")
addWorksheet(wb_main, "Regional_Summary")

# Create a summary table with regions in rows, quarters in columns
for (ind in indicators) {
  
  ind_data <- results_region %>%
    filter(indicator == ind) %>%
    mutate(
      cell_value = sprintf("%.4f (%.4f) %s", estimate, se, flag)
    ) %>%
    select(region, trimestre, cell_value) %>%
    pivot_wider(
      names_from = trimestre,
      values_from = cell_value,
      names_prefix = "Q"
    ) %>%
    mutate(Indicator = ind) %>%
    select(Indicator, region, everything())
  
  if (ind == indicators[1]) {
    current_row <- 1
    writeData(wb_main, "Regional_Summary", ind_data, startRow = current_row, startCol = 1)
    addStyle(wb_main, "Regional_Summary", headerStyle, 
             rows = current_row, cols = 1:ncol(ind_data), gridExpand = TRUE)
    current_row <- current_row + nrow(ind_data) + 1
  } else {
    writeData(wb_main, "Regional_Summary", ind_data, startRow = current_row, startCol = 1, colNames = FALSE)
    current_row <- current_row + nrow(ind_data) + 1
  }
}

# ------------------------------------------------------------------------------
# Sheets: By District (one sheet per quarter)
# ------------------------------------------------------------------------------
cat("  Creating sheets: By District\n")

for (q in quarters) {
  sheet_name <- paste0("District_Q", q)
  cat("    - ", sheet_name, "\n")
  
  addWorksheet(wb_main, sheet_name)
  
  sheet_data <- results_district %>% 
    filter(trimestre == q) %>%
    arrange(District, indicator)
  
  writeDataTable(wb_main, sheet_name, sheet_data, withFilter = TRUE)
  
  # Add footnotes
  start_row <- nrow(sheet_data) + 4
  writeData(wb_main, sheet_name, "Quality flags:", startRow = start_row, startCol = 1)
  writeDataTable(wb_main, sheet_name, quality_footnotes, startRow = start_row + 1, startCol = 1)
}

# ------------------------------------------------------------------------------
# Sheet: District Summary (Top districts by sample size)
# ------------------------------------------------------------------------------
cat("  Creating sheet: District_Summary_Top\n")
addWorksheet(wb_main, "District_Summary_Top")

# Get top 20 districts by total sample size
top_districts <- results_district %>%
  group_by(District) %>%
  summarise(total_n = sum(n_total, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(total_n)) %>%
  head(20) %>%
  pull(District)

district_summary <- results_district %>%
  filter(District %in% top_districts) %>%
  arrange(District, indicator, trimestre)

writeDataTable(wb_main, "District_Summary_Top", district_summary, withFilter = TRUE)

start_row <- nrow(district_summary) + 4
writeData(wb_main, "District_Summary_Top", "Quality flags:", startRow = start_row, startCol = 1)
writeDataTable(wb_main, "District_Summary_Top", quality_footnotes, startRow = start_row + 1, startCol = 1)

# ------------------------------------------------------------------------------
# Save the main workbook
# ------------------------------------------------------------------------------
saveWorkbook(wb_main, file.path(output_dir, "survey_indicators_comprehensive.xlsx"), overwrite = TRUE)
cat("✓ survey_indicators_comprehensive.xlsx created\n\n")

# ------------------------------------------------------------------------------
# 11. SEPARATE WORKBOOKS (Optional - keeping original structure)
# ------------------------------------------------------------------------------
cat("Creating separate Excel files...\n")

# File 1: By Quarter (Overall)
wb_quarter <- createWorkbook()

for (q in unique(results_all$trimestre)) {
  addWorksheet(wb_quarter, as.character(q))
  sheet_data <- results_all %>% filter(trimestre == q)
  writeDataTable(wb_quarter, as.character(q), sheet_data, withFilter = TRUE)
  
  start_row <- nrow(sheet_data) + 4
  writeData(wb_quarter, as.character(q), "Quality flags:", startRow = start_row, startCol = 1)
  writeDataTable(wb_quarter, as.character(q), quality_footnotes, startRow = start_row + 1, startCol = 1)
}

saveWorkbook(wb_quarter, file.path(output_dir, "survey_indicators_by_quarter.xlsx"), overwrite = TRUE)
cat("✓ survey_indicators_by_quarter.xlsx created\n")

# File 2: By Indicator (Overall)
wb_indicator <- createWorkbook()

for (ind in indicators) {
  addWorksheet(wb_indicator, ind)
  sheet_data <- results_all %>% filter(indicator == ind)
  writeDataTable(wb_indicator, ind, sheet_data, withFilter = TRUE)
  
  start_row <- nrow(sheet_data) + 4
  writeData(wb_indicator, ind, "Quality flags:", startRow = start_row, startCol = 1)
  writeDataTable(wb_indicator, ind, quality_footnotes, startRow = start_row + 1, startCol = 1)
}

saveWorkbook(wb_indicator, file.path(output_dir, "survey_indicators_by_indicator.xlsx"), overwrite = TRUE)
cat("✓ survey_indicators_by_indicator.xlsx created\n")

# File 3: Regional Analysis
wb_region <- createWorkbook()

for (q in quarters) {
  addWorksheet(wb_region, paste0("Q", q))
  sheet_data <- results_region %>% filter(trimestre == q)
  writeDataTable(wb_region, paste0("Q", q), sheet_data, withFilter = TRUE)
  
  start_row <- nrow(sheet_data) + 4
  writeData(wb_region, paste0("Q", q), "Quality flags:", startRow = start_row, startCol = 1)
  writeDataTable(wb_region, paste0("Q", q), quality_footnotes, startRow = start_row + 1, startCol = 1)
}

saveWorkbook(wb_region, file.path(output_dir, "survey_indicators_by_region.xlsx"), overwrite = TRUE)
cat("✓ survey_indicators_by_region.xlsx created\n")

# File 4: District Analysis
wb_district <- createWorkbook()

for (q in quarters) {
  addWorksheet(wb_district, paste0("Q", q))
  sheet_data <- results_district %>% filter(trimestre == q)
  writeDataTable(wb_district, paste0("Q", q), sheet_data, withFilter = TRUE)
  
  start_row <- nrow(sheet_data) + 4
  writeData(wb_district, paste0("Q", q), "Quality flags:", startRow = start_row, startCol = 1)
  writeDataTable(wb_district, paste0("Q", q), quality_footnotes, startRow = start_row + 1, startCol = 1)
}

saveWorkbook(wb_district, file.path(output_dir, "survey_indicators_by_district.xlsx"), overwrite = TRUE)
cat("✓ survey_indicators_by_district.xlsx created\n\n")

# ==============================================================================
# 12. FOREST PLOTS - OVERALL
# ==============================================================================
cat("Creating forest plots - Overall...\n")

plot_dir <- file.path(output_dir, "forest_plots")
dir.create(plot_dir, showWarnings = FALSE, recursive = TRUE)

for (q in quarters) {
  
  indicator_order <- c("SU4", "SU3", "SU2", "SU1")
  
  df_plot <- results_all %>%
    filter(
      trimestre == q,
      flag %in% c("A", "B")
    ) %>%
    mutate(
      indicator = factor(indicator, levels = indicator_order),
      estimate_text = sprintf("%.1f%%", estimate * 100),
      ci_text = sprintf("[%.1f%%, %.1f%%]", ci_l * 100, ci_u * 100),
      cv_text = sprintf("%.2f%%", cv * 100)
    ) %>%
    arrange(indicator)
  
  if (nrow(df_plot) == 0) {
    cat("  ⚠ No reliable estimates for", q, "- plot skipped\n")
    next
  }
  
  x_min <- 0
  x_max <- max(df_plot$ci_u) * 1.1
  
  col1_x <- x_max * 1.15
  col2_x <- x_max * 1.40
  col3_x <- x_max * 1.70
  
  p <- ggplot(df_plot, aes(x = estimate, y = indicator)) +
    theme_minimal(base_size = 13) +
    geom_vline(xintercept = 0, color = "gray40", linetype = "solid", linewidth = 0.4) +
    geom_errorbarh(aes(xmin = ci_l, xmax = ci_u, color = flag, linewidth = flag), height = 0.3) +
    geom_point(aes(color = flag, size = flag), shape = 16) +
    geom_text(aes(x = col1_x, label = estimate_text), hjust = 0.5, size = 4, fontface = "bold", family = "sans") +
    geom_text(aes(x = col2_x, label = ci_text), hjust = 0.5, size = 3.8, family = "sans") +
    geom_text(aes(x = col3_x, label = cv_text), hjust = 0.5, size = 3.8, family = "sans") +
    scale_color_manual(
      values = c("A" = "#27AE60", "B" = "#E67E22"),
      labels = c("A" = "Reliable (CV < 15%)", "B" = "Use with caution (15% ≤ CV < 30%)"),
      name = "Quality"
    ) +
    scale_linewidth_manual(values = c("A" = 1.0, "B" = 0.8), guide = "none") +
    scale_size_manual(values = c("A" = 4, "B" = 3.5), guide = "none") +
    scale_x_continuous(
      limits = c(x_min, col3_x * 1.15),
      breaks = pretty(c(x_min, x_max), n = 6),
      labels = label_percent(accuracy = 0.1, scale = 100),
      expand = c(0, 0)
    ) +
    labs(
      x = "Estimate (95% Confidence Interval)",
      y = NULL,
      title = paste("Survey Estimates –", q, "– Overall"),
      subtitle = "Points = point estimate | Horizontal bars = 95% confidence interval"
    ) +
    theme(
      panel.grid.major.y = element_blank(),
      panel.grid.major.x = element_line(color = "gray90", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      panel.background = element_rect(fill = "white", color = NA),
      plot.background = element_rect(fill = "white", color = NA),
      axis.text.y = element_text(size = 12, face = "bold", hjust = 1, color = "gray20"),
      axis.text.x = element_text(size = 11, color = "gray30"),
      axis.title.x = element_text(size = 12, face = "bold", margin = margin(t = 10)),
      axis.line.x = element_line(color = "gray40", linewidth = 0.5),
      plot.title = element_text(face = "bold", size = 16, hjust = 0, margin = margin(b = 5)),
      plot.subtitle = element_text(size = 11, color = "gray50", hjust = 0, margin = margin(b = 15)),
      legend.position = "bottom",
      legend.title = element_text(face = "bold", size = 11),
      legend.text = element_text(size = 10),
      legend.background = element_rect(fill = "gray95", color = "gray70", linewidth = 0.3),
      legend.key = element_rect(fill = "gray95"),
      legend.margin = margin(5, 5, 5, 5),
      plot.margin = margin(15, 150, 15, 15)
    ) +
    annotate(
      "rect",
      xmin = col1_x - (col2_x - col1_x) * 0.45,
      xmax = col3_x + (col3_x - col2_x) * 0.45,
      ymin = nrow(df_plot) + 0.5,
      ymax = nrow(df_plot) + 1.0,
      fill = "gray90",
      alpha = 0.5
    ) +
    annotate("text", x = col1_x, y = nrow(df_plot) + 0.75, label = "Estimate", fontface = "bold", size = 4.2) +
    annotate("text", x = col2_x, y = nrow(df_plot) + 0.75, label = "95% CI", fontface = "bold", size = 4.2) +
    annotate("text", x = col3_x, y = nrow(df_plot) + 0.75, label = "CV", fontface = "bold", size = 4.2)
  
  ggsave(
    filename = file.path(plot_dir, paste0("overall_Q", q, ".png")),
    plot = p,
    width = 13,
    height = max(6, nrow(df_plot) * 0.65 + 2.5),
    dpi = 400,
    bg = "white"
  )
  
  cat("  ✓ Forest plot created for", q, "\n")
}

# ==============================================================================
# 13. NEW: FOREST PLOTS - BY REGION
# ==============================================================================
cat("\nCreating forest plots - By Region...\n")

plot_dir_region <- file.path(output_dir, "forest_plots_region")
dir.create(plot_dir_region, showWarnings = FALSE, recursive = TRUE)

regions <- sort(unique(results_region$region))

for (q in quarters) {
  for (reg in regions) {
    
    df_plot <- results_region %>%
      filter(
        trimestre == q,
        region == reg,
        flag %in% c("A", "B")
      ) %>%
      mutate(
        indicator = factor(indicator, levels = c("SU4", "SU3", "SU2", "SU1")),
        estimate_text = sprintf("%.1f%%", estimate * 100),
        ci_text = sprintf("[%.1f%%, %.1f%%]", ci_l * 100, ci_u * 100),
        cv_text = sprintf("%.2f%%", cv * 100)
      ) %>%
      arrange(indicator)
    
    if (nrow(df_plot) == 0) {
      next
    }
    
    x_min <- 0
    x_max <- max(df_plot$ci_u) * 1.1
    
    col1_x <- x_max * 1.15
    col2_x <- x_max * 1.40
    col3_x <- x_max * 1.70
    
    p <- ggplot(df_plot, aes(x = estimate, y = indicator)) +
      theme_minimal(base_size = 13) +
      geom_vline(xintercept = 0, color = "gray40", linetype = "solid", linewidth = 0.4) +
      geom_errorbarh(aes(xmin = ci_l, xmax = ci_u, color = flag, linewidth = flag), height = 0.3) +
      geom_point(aes(color = flag, size = flag), shape = 16) +
      geom_text(aes(x = col1_x, label = estimate_text), hjust = 0.5, size = 4, fontface = "bold") +
      geom_text(aes(x = col2_x, label = ci_text), hjust = 0.5, size = 3.8) +
      geom_text(aes(x = col3_x, label = cv_text), hjust = 0.5, size = 3.8) +
      scale_color_manual(
        values = c("A" = "#27AE60", "B" = "#E67E22"),
        labels = c("A" = "Reliable (CV < 15%)", "B" = "Use with caution (15% ≤ CV < 30%)"),
        name = "Quality"
      ) +
      scale_linewidth_manual(values = c("A" = 1.0, "B" = 0.8), guide = "none") +
      scale_size_manual(values = c("A" = 4, "B" = 3.5), guide = "none") +
      scale_x_continuous(
        limits = c(x_min, col3_x * 1.15),
        breaks = pretty(c(x_min, x_max), n = 6),
        labels = label_percent(accuracy = 0.1, scale = 100),
        expand = c(0, 0)
      ) +
      labs(
        x = "Estimate (95% Confidence Interval)",
        y = NULL,
        title = paste("Survey Estimates –", q, "– Region:", reg),
        subtitle = "Points = point estimate | Horizontal bars = 95% confidence interval"
      ) +
      theme(
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(color = "gray90", linewidth = 0.3),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA),
        axis.text.y = element_text(size = 12, face = "bold", hjust = 1, color = "gray20"),
        axis.text.x = element_text(size = 11, color = "gray30"),
        axis.title.x = element_text(size = 12, face = "bold", margin = margin(t = 10)),
        axis.line.x = element_line(color = "gray40", linewidth = 0.5),
        plot.title = element_text(face = "bold", size = 16, hjust = 0, margin = margin(b = 5)),
        plot.subtitle = element_text(size = 11, color = "gray50", hjust = 0, margin = margin(b = 15)),
        legend.position = "bottom",
        legend.title = element_text(face = "bold", size = 11),
        legend.text = element_text(size = 10),
        legend.background = element_rect(fill = "gray95", color = "gray70", linewidth = 0.3),
        legend.key = element_rect(fill = "gray95"),
        legend.margin = margin(5, 5, 5, 5),
        plot.margin = margin(15, 150, 15, 15)
      ) +
      annotate(
        "rect",
        xmin = col1_x - (col2_x - col1_x) * 0.45,
        xmax = col3_x + (col3_x - col2_x) * 0.45,
        ymin = nrow(df_plot) + 0.5,
        ymax = nrow(df_plot) + 1.0,
        fill = "gray90",
        alpha = 0.5
      ) +
      annotate("text", x = col1_x, y = nrow(df_plot) + 0.75, label = "Estimate", fontface = "bold", size = 4.2) +
      annotate("text", x = col2_x, y = nrow(df_plot) + 0.75, label = "95% CI", fontface = "bold", size = 4.2) +
      annotate("text", x = col3_x, y = nrow(df_plot) + 0.75, label = "CV", fontface = "bold", size = 4.2)
    
    ggsave(
      filename = file.path(plot_dir_region, paste0("region_", reg, "_Q", q, ".png")),
      plot = p,
      width = 13,
      height = max(6, nrow(df_plot) * 0.65 + 2.5),
      dpi = 400,
      bg = "white"
    )
  }
  
  cat("  ✓ Regional forest plots created for", q, "\n")
}

# ==============================================================================
# 14. COMPARISON PLOTS - Regions within same quarter
# ==============================================================================
cat("\nCreating comparison plots - Regions...\n")

plot_dir_comparison <- file.path(output_dir, "comparison_plots")
dir.create(plot_dir_comparison, showWarnings = FALSE, recursive = TRUE)

for (q in quarters) {
  for (ind in indicators) {
    
    df_plot <- results_region %>%
      filter(
        trimestre == q,
        indicator == ind,
        flag %in% c("A", "B")
      ) %>%
      mutate(
        region = factor(region),
        estimate_text = sprintf("%.1f%%", estimate * 100)
      ) %>%
      arrange(desc(estimate))
    
    if (nrow(df_plot) < 2) {
      next
    }
    
    p <- ggplot(df_plot, aes(x = estimate, y = reorder(region, estimate))) +
      theme_minimal(base_size = 12) +
      geom_vline(xintercept = 0, color = "gray40", linetype = "solid", linewidth = 0.4) +
      geom_errorbarh(aes(xmin = ci_l, xmax = ci_u, color = flag), height = 0.4, linewidth = 1) +
      geom_point(aes(color = flag), size = 4, shape = 16) +
      geom_text(aes(label = estimate_text), hjust = -0.5, size = 3.5, fontface = "bold") +
      scale_color_manual(
        values = c("A" = "#27AE60", "B" = "#E67E22"),
        labels = c("A" = "Reliable (CV < 15%)", "B" = "Use with caution (15% ≤ CV < 30%)"),
        name = "Quality"
      ) +
      scale_x_continuous(
        labels = label_percent(accuracy = 0.1, scale = 100),
        expand = expansion(mult = c(0.05, 0.15))
      ) +
      labs(
        x = "Estimate (95% Confidence Interval)",
        y = NULL,
        title = paste("Regional Comparison:", ind, "–", q),
        subtitle = "Regions ranked by estimate value"
      ) +
      theme(
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(color = "gray90", linewidth = 0.3),
        panel.grid.minor = element_blank(),
        panel.background = element_rect(fill = "white", color = NA),
        plot.background = element_rect(fill = "white", color = NA),
        axis.text.y = element_text(size = 11, face = "bold", color = "gray20"),
        axis.text.x = element_text(size = 10, color = "gray30"),
        axis.title.x = element_text(size = 11, face = "bold", margin = margin(t = 10)),
        axis.line.x = element_line(color = "gray40", linewidth = 0.5),
        plot.title = element_text(face = "bold", size = 14, hjust = 0, margin = margin(b = 5)),
        plot.subtitle = element_text(size = 10, color = "gray50", hjust = 0, margin = margin(b = 15)),
        legend.position = "bottom",
        legend.title = element_text(face = "bold", size = 10),
        legend.text = element_text(size = 9)
      )
    
    ggsave(
      filename = file.path(plot_dir_comparison, paste0("comparison_", ind, "_Q", q, ".png")),
      plot = p,
      width = 11,
      height = max(5, nrow(df_plot) * 0.45 + 2),
      dpi = 400,
      bg = "white"
    )
  }
  
  cat("  ✓ Regional comparison plots created for", q, "\n")
}

# ==============================================================================
# 15. FINAL SUMMARY
# ==============================================================================
cat("\n")
cat("═══════════════════════════════════════════════════════════════════════════\n")
cat("                          ANALYSIS COMPLETE                                  \n")
cat("═══════════════════════════════════════════════════════════════════════════\n\n")

cat("📊 EXCEL FILES CREATED:\n")
cat("  ✓ survey_indicators_comprehensive.xlsx (MAIN FILE - all analyses)\n")
cat("  ✓ survey_indicators_by_quarter.xlsx\n")
cat("  ✓ survey_indicators_by_indicator.xlsx\n")
cat("  ✓ survey_indicators_by_region.xlsx\n")
cat("  ✓ survey_indicators_by_district.xlsx\n\n")

cat("📈 VISUALIZATION FOLDERS:\n")
cat("  ✓", plot_dir, "/ (overall forest plots)\n")
cat("  ✓", plot_dir_region, "/ (regional forest plots)\n")
cat("  ✓", plot_dir_comparison, "/ (regional comparison plots)\n\n")

cat("📋 SUMMARY STATISTICS:\n")
cat("  • Total indicators analyzed:", length(indicators), "\n")
cat("  • Quarters analyzed:", length(quarters), "\n")
cat("  • Regions analyzed:", length(regions), "\n")
cat("  • Districts analyzed:", length(unique(results_district$District)), "\n\n")

cat("✅ All files saved to:", output_dir, "\n\n")

message("Survey analysis complete with regional and district breakdowns!")

