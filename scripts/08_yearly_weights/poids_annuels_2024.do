use "C:\Users\f.migone\Desktop\ENE_SURVEY_WEIGHTS\data\04_weights\T2_2024\calibrated_weights\individu_T2_2024_CAL.dta" 
append using "C:\Users\f.migone\Desktop\ENE_SURVEY_WEIGHTS\data\04_weights\T3_2024\calibrated_weights\individu_T3_2024_CAL.dta" "C:\Users\f.migone\Desktop\ENE_SURVEY_WEIGHTS\data\04_weights\T4_2024\calibrated_weights\individu_T4_2024_CAL.dta", force
count if missing(FINAL_WEIGHT)
replace FINAL_WEIGHT  = FINAL_WEIGHT / 3
keep INDKEY interview_key membres_id HHKEY PSUKEY STRATAKEY FINAL_WEIGHT
save "C:\Users\f.migone\Desktop\ENE_SURVEY_WEIGHTS\data\04_weights\2024\LFS_WEIGHTS_2024.dta"