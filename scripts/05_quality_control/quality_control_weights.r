source("check_duplicates.R")

# Wrapper function for your specific use case
check_ene_data_quality <- function(data_path = WEIGHTS_COLUMNS_PATH) {
  
  # Standard ENE survey key combinations
  ene_keys <- list(
    "Household_Complete" = c("region", "depart", "souspref", "ZD", "segment", "nummen"),
    "Geographic_Unit" = c("region", "depart", "souspref", "ZD", "segment"),
    "Survey_ID" = c("ZD", "segment", "nummen", "rgmen")
  )
  
  # Run checks
  results <- run_duplicate_check_pipeline(
    data_path = data_path,
    key_combinations = ene_keys,
    output_dir = file.path(dirname(data_path), "quality_reports")
  )
  
  # Create summary report
  cat("\n📊 ENE DATA QUALITY SUMMARY\n")
  cat(paste(rep("=", 60), collapse = ""), "\n")
  
  for (check_name in names(results$duplicate_results)) {
    dup_count <- results$duplicate_results[[check_name]]$summary$duplicate_rows
    total_rows <- results$duplicate_results[[check_name]]$summary$total_rows
    
    status <- if (dup_count == 0) "✅ PASS" else "❌ FAIL"
    cat(sprintf("%-20s: %s (%d duplicates out of %d rows)\n", 
                check_name, status, dup_count, total_rows))
  }
  
  return(results)
}