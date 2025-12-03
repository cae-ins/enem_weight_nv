########################################################################################################################.
########################################################################################################################.
########################################################################################################################.
########                                                                                                        ########.
########           TRAINING ON STRATEGIES TO CALCULATE LFS SAMPLE WEIGHTS USING CALIBRATION                     ########.
########                                                                                                        ########.
########          PREPARED BY: ANTONIO R. DISCENZA - ILO DEPARTMENT OF STATISTICS - SSMU UNIT                   ########.
########                                    E.mail: discenza@ilo.org                                            ########.
########                                                                                                        ########.
########                                 CASE STUDY N. 6 - (312X_1D_ALLWR)                                      ########.
########                       CALIBRATION OF FINAL WEIGHTS USING R FOR ALL STEPS                               ########.
########                                                                                                        ########.
########        Version B:  Filenames, paths, reference periods and set of constraints are parameterized        ########.
########                                                                                                        ########.
########                                                                                                        ########.
########                                        Master Script                                                   ########.
########                                                                                                        ########.
########                                                                                                        ########.
########    The population figures available from an external trusted official source to be used as benchmarks  ########.  
########    for the final weights are stored in the following folder                                            ########.  
########    "W:/ILO_LFS_GSBPM/DATA/560_POPULATION_ESTIMATE/2021/Quarter1/                                       ########.
########                                                                                                        ########.
########    The microdata containing the interviews successfully completed are stored in the following folder   ########.  
########    "W:/ILO_LFS_GSBPM/DATA/550_DERIVED_VARIABLES/2021/Quarter1/                                         ########.
########    These microdata have been edited and imputed and contain the theorethical design weights            ########.  
########    Final weights will be calculated starting from design weights using Regenesees and will be attached ########.
########    back to the microdata file                                                                          ########.
########                                                                                                        ########.
########    The folder containing the sequence of R scripts needed for the procedure is                         ########.
########    "W:/ILO_LFS_GSBPM/PROG/565_QUARTERLY_WEIGHTING/2021/Quarter1/312X_1D_ALLWR/                         ########.
########                                                                                                        ########.
########    The outputs of the procedure (both R objects and Excel files) will be stored in the folder          ########.
########    "W:/ILO_LFS_GSBPM/DATA/565_QUARTERLY_WEIGHTING/2021/Quarter1/312X_1D_ALLWR/                         ########.                                              
########    Please create such folder in your file structure before starting                                    ########.
########                                                                                                        ########.
########        1 DOMAINS  (33 Regions)                                                                         ########.
########        312 CONSTRAINTS (X1 TO X312)                                                                    ########.
########              - Population by urban and rural, sex and 12 age groups    (X1 TO X48)                     ########.
########              - Population by region, urban and rural, sex and 2 age groups  (X49 TO X312)              ########.    
########                                                                                                        ########.
########################################################################################################################.
########################################################################################################################.
########################################################################################################################.


###  Lets first remove all the objects from the memory of the current session

rm(list = ls())
ls()


#######   INSTALL PACKAGES  ##################################################################################
###
###    THE PACKAGES BELOW HAVE TO BE INSTALLED ONLY ONCE. THEN THE CODE CAN BE COMMENTED USING THE HASHTAG  
###
##############################################################################################################

# install.packages("rstudioapi")

### To install Regenesees 
# install.packages("devtools")
# devtools::install_github("DiegoZardetto/ReGenesees")

### or also  
# install.packages("remotes")
# remotes::install_github("DiegoZardetto/ReGenesees")
# remotes::install_github("DiegoZardetto/ReGenesees.GUI")

# remotes::install_github("dcomtois/summarytools")
# install.packages("summarytools")

# install.packages("dplyr")
# install.packages("excel.link")
# install.packages("writexl")

### install the library to create multidimensional tables with weighted data 
# install.packages("expss")

### to read and write SPSS and STATA datasets 
# install.packages("haven")






#######   ACTIVATE PACKAGES   #################################################################################
###
###    Activate the libraries that are needed by the procedure every time need to design a sample
###
##############################################################################################################

library("rstudioapi")     # to open and closse tabs in Rstudio from syntax
library("ReGenesees")     # to calculate weights, CVs and DEFFs
library("dplyr")          # to summarize data
library("summarytools")   # to summarize data
library("excel.link")     # contains the functions xl.get.excel(), xl.write(), xl.workbook.save()
library("readxl")         # to export R dataframes in excel
library("writexl")        # to export R dataframes in excel
library("expss")          # contains unctions to create weighted tables
library("haven")          # to read and write SPSS and STATA datasets 



#######   STEP 1   ###########################################################################################
#######            ###########################################################################################
###
###
###    Define the parameters for YEAR, QUARTERS, MONTHS and NUMBER OF CONSTRAINTS 
###
###
##############################################################################################################
##############################################################################################################

parse_target_quarter <- function(target_quarter) {
  
  # Check if input is valid
  if (is.null(target_quarter) || !is.character(target_quarter)) {
    stop("target_quarter must be a character string")
  }
  
  # Check format (should be like "T1_2025", "T2_2024", etc.)
  if (!grepl("^T[1-4]_[0-9]{4}$", target_quarter)) {
    stop("target_quarter format should be 'TX_YYYY' where X is 1-4 and YYYY is a 4-digit year")
  }
  
  # Extract quarter number and year
  parts <- strsplit(target_quarter, "_")[[1]]
  quarter_part <- parts[1]  # "T1", "T2", etc.
  year_part <- parts[2]     # "2025", "2024", etc.
  
  # Extract just the number from quarter part
  quarter <- as.numeric(gsub("T", "", quarter_part))
  year <- as.numeric(year_part)
  
  # Return as a named list
  result <- list(
    quarter = quarter,
    year = year,
    original = target_quarter
  )
  
  # Print results
  cat("Parsed target quarter:\n")
  cat("Quarter:", quarter, "\n")
  cat("Year:", year, "\n")
  
  return(result)
}
source("config/1_config.r")
source("scripts/02_base_weights/3_indivs_weights.R")
# Parse the target quarter
parsed <- parse_target_quarter(TARGET_QUARTER)

# Extract individual components
quarter <- parsed$quarter  
year <- parsed$year        

###   For regenesees: number of constraints X used in the calibration with Regenesees

xnum <- 180
xnum

###   For regenesees: suffix for filenames referring to the set of parameters X and the number of domains of estimation D

setx <- '180X_1D'
setx

###   For regenesees: suffix for filenames referring to the set of parameters X and the number of domains of estimation D
pathx <- '180X_1D'
pathx 

#######   STEP 2   ###########################################################################################
#######            ###########################################################################################
###
###
###    Define the parameterized folders (on disk) and filenames (paths and names of the files saved on disk)
###
###
##############################################################################################################
##############################################################################################################

###  Note that the "\" is not recognized by R, we need a "\\" instead 
###  or a more general "/" (recognized on all operating systems) 


##############################################################################################################
###
###  Lets set the main root/directory on our computer o server (where we have the LFS data and programs )


##############################################################################################################
###
###  Let's parameterize the path of the directory/folder from which we want to read the csv file with the full sample data 

dir_data_DV <- paste0(BASE_DIR , "/data/05_DERIVED_VARIABLES/", year, "/T", quarter , "/" )
dir_data_DV

##############################################################################################################
###
###  Let's parameterize the name and path of the csv file with the full sample data "_DER"
get_weights_path <- function(target_quarter, use_sr = FALSE) {
  # Choisir le préfixe selon SR ou pas
  prefix <- if (use_sr) "SR_individu_" else "individu_"
  
  file.path(BASE_DIR,
    "data", "04_weights", target_quarter, "base_weights",
    paste0(prefix, target_quarter, ".dta")
  )
}

FILE_LFS_ILO_DER_DTA  <- get_weights_path(TARGET_QUARTER, use_sr = FALSE) 
FILE_LFS_ILO_DER_DTA

###  Let's parameterize the name and path of the RData file with the full sample data 

FILE_LFS_ILO_DER_RDATA  <- paste0(dir_data_DV,"LFS_ILO_",year,"_T",quarter,"_DER.RData")
FILE_LFS_ILO_DER_RDATA


##############################################################################################################
###
###  Let's parameterize the path of the directory/folder from which we want to read the population figures 

dir_data_PE <- paste0( BASE_DIR , "/data/06_POPULATION_ESTIMATES/", year, "/T", quarter , "/" )
dir_data_PE


##############################################################################################################
###

FILE_POP_LFS_BY_REGION_SEX_2AGEGR_CSV  <- paste0(dir_data_PE,"POP_LFS_BY_REGION_SEX_2AGEGR_",year,"_T",quarter,".csv")
FILE_POP_LFS_BY_REGION_SEX_2AGEGR_CSV

FILE_POP_LFS_BY_REGION_SEX_2AGEGR_XLSX  <- paste0(dir_data_PE,"POP_LFS_BY_REGION_SEX_2AGEGR_",year,"_T",quarter,".xlsx")
FILE_POP_LFS_BY_REGION_SEX_2AGEGR_XLSX

FILE_POP_LFS_BY_REGION_SEX_2AGEGR_DTA  <- paste0(dir_data_PE,"POP_LFS_BY_REGION_SEX_2AGEGR_",year,"_T",quarter,".dta")
FILE_POP_LFS_BY_REGION_SEX_2AGEGR_DTA

###  Let's parameterize the name and path of the RData file with the population figures 

FILE_POP_LFS_BY_REGION_SEX_2AGEGR_RDATA  <- paste0(dir_data_PE,"POP_LFS_BY_REGION_SEX_2AGEGR_",year,"_T",quarter,".RData")
FILE_POP_LFS_BY_REGION_SEX_2AGEGR_RDATA


##############################################################################################################
###
###  Let's parameterize the path of the working directory where the outputs of the calibration will be stored

dir_data_QW <- paste0( BASE_DIR , "/data/07_QUARTERLY_WEIGHTING/", year, "/T", quarter , "/" , pathx,"/")
dir_data_QW


##############################################################################################################
###
###  Let's parameterize the name and path of the RData file with the SAMPLE DATA prepared for Regenesees
 
FILE_LFS_SAMPLE_DATA_RDATA  <- paste0(dir_data_QW,"LFS_SAMPLE_DATA_",year,"_T",quarter,"_", pathx ,".RData")
FILE_LFS_SAMPLE_DATA_RDATA

##############################################################################################################
###
###  Let's parameterize the name and path of the RData file with the SUMMARY_OF_Xs_SAMPLE_SIZE
 
FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE_RDATA  <- paste0(dir_data_QW,"LFS_SAMPLE_DATA_",year,"_T",quarter,"_", pathx ,"_SUMMARY_OF_Xs_SAMPLE_SIZE.RData")
FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE_RDATA

###  Let's parameterize the name and path of the XLSX file with the SUMMARY_OF_Xs_SAMPLE_SIZE
 
FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE_XLSX  <- paste0(dir_data_QW,"LFS_SAMPLE_DATA_",year,"_T",quarter,"_", pathx ,"_SUMMARY_OF_Xs_SAMPLE_SIZE.xlsx")
FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE_XLSX



##############################################################################################################
###
###  Let's parameterize the name and path of the RData file with the SUMMARY_OF_Xs_EST_DES_WEIGHT
 
FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT_RDATA  <- paste0(dir_data_QW,"LFS_SAMPLE_DATA_",year,"_T",quarter,"_", pathx ,"_SUMMARY_OF_Xs_EST_DES_WEIGHT.RData")
FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT_RDATA


###  Let's parameterize the name and path of the XLSX file with the SUMMARY_OF_Xs_EST_DES_WEIGHT
 
FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT_XLSX  <- paste0(dir_data_QW,"LFS_SAMPLE_DATA_",year,"_T",quarter,"_", pathx ,"_SUMMARY_OF_Xs_EST_DES_WEIGHT.xlsx")
FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT_XLSX


##############################################################################################################
###
###  Let's parameterize the name and path of the RData file with the KNOWN TOTALS prepared for Regenesees
 
FILE_LFS_KNOWN_TOTALS_RDATA  <- paste0(dir_data_QW,"LFS_KNOWN_TOTALS_",year,"_T",quarter,"_", pathx ,".RData")
FILE_LFS_KNOWN_TOTALS_RDATA


###  Let's parameterize the name and path of the XLSX file with the KNOWN TOTALS prepared for Regenesees
 
FILE_LFS_KNOWN_TOTALS_XLSX  <- paste0(dir_data_QW,"LFS_KNOWN_TOTALS_",year,"_T",quarter,"_", pathx ,".xlsx")
FILE_LFS_KNOWN_TOTALS_XLSX




##############################################################################################################
###
###  Let's parameterize the path of the program folder

dir_prog_QW <- paste0( BASE_DIR , "/scripts/04_calibration/QUARTERLY_WEIGHTING/", pathx,"/")
dir_prog_QW


###  Let's parameterize the name and path of the script file that constains the additional functions for ReGenesees

R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS <- paste0( BASE_DIR , "/scripts/04_calibration/QUARTERLY_WEIGHTING/Other_R_functions_for_Regenesees/Functions_to_Create _X_vector_and_X_Summary_Table.R")
R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS 


##############################################################################################################
###
###  Let's parameterize the name and path of the RDATA file with the final weights

FILE_LFS_CALIBRATION_FINAL_WEIGHTS_RDATA <- paste0(dir_data_QW,"LFS_CALIBRATION_",year,"_T",quarter,"_", pathx ,"_FINAL_WEIGHTS.RData")
FILE_LFS_CALIBRATION_FINAL_WEIGHTS_RDATA


##############################################################################################################
###
###  Let's parameterize the name and path of the CSV file with the summary statistics on the final weights

FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_WEIGHTS_CSV  <- paste0(dir_data_QW,"LFS_CALIBRATION_",year,"_T",quarter,"_", pathx ,"_SUMMARY_OF_FINAL_WEIGHTS.csv")
FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_WEIGHTS_CSV

###  Let's parameterize the name and path of the RDATA file with the summary statistics on the final weights

FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_WEIGHTS_RDATA  <- paste0(dir_data_QW,"LFS_CALIBRATION_",year,"_T",quarter,"_", pathx ,"_SUMMARY_OF_FINAL_WEIGHTS.RData")
FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_WEIGHTS_RDATA



##############################################################################################################
###
###  Let's parameterize the name and path of the CSV file with the summary statistics on the DESIGN weights

FILE_LFS_CALIBRATION_SUMMARY_OF_DESIGN_WEIGHTS_CSV  <- paste0(dir_data_QW,"LFS_CALIBRATION_",year,"_T",quarter,"_", pathx ,"_SUMMARY_OF_DESIGN_WEIGHTS.csv")
FILE_LFS_CALIBRATION_SUMMARY_OF_DESIGN_WEIGHTS_CSV

###  Let's parameterize the name and path of the RDATA file with the summary statistics on the DESIGN weights

FILE_LFS_CALIBRATION_SUMMARY_OF_DESIGN_WEIGHTS_RDATA  <- paste0(dir_data_QW,"LFS_CALIBRATION_",year,"_T",quarter,"_", pathx ,"_SUMMARY_OF_DESIGN_WEIGHTS.RData")
FILE_LFS_CALIBRATION_SUMMARY_OF_DESIGN_WEIGHTS_RDATA




##############################################################################################################
###
###  Let's parameterize the name and path of the CSV file with the summary statistics on the CORRECTION FACTORS

FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_CORR_FACTORS_CSV  <- paste0(dir_data_QW,"LFS_CALIBRATION_",year,"_T",quarter,"_", pathx ,"_SUMMARY_OF_FINAL_CORR_FACTORS.csv")
FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_CORR_FACTORS_CSV

###  Let's parameterize the name and path of the RDATA file with the summary statistics on the CORRECTION FACTORS

FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_CORR_FACTORS_RDATA  <- paste0(dir_data_QW,"LFS_CALIBRATION_",year,"_T",quarter,"_", pathx ,"_SUMMARY_OF_FINAL_CORR_FACTORS.RData")
FILE_LFS_CALIBRATION_SUMMARY_OF_FINAL_CORR_FACTORS_RDATA


##############################################################################################################
###
###  Let's parameterize the name and path of the RDATA IMAGE file containing all the R objects created in this session

FILE_LFS_CALIBRATION_IMAGE_RDATA <- paste0(dir_data_QW,"LFS_CALIBRATION_",year,"_T",quarter,"_", pathx ,"_IMAGE.RData")
FILE_LFS_CALIBRATION_IMAGE_RDATA


##############################################################################################################
###
###  Let's parameterize the name and path of the final RData file with the full sample data (CAL) 

FILE_LFS_ILO_CAL_RDATA  <- paste0(dir_data_QW,"LFS_ILO_",year,"_T",quarter,"_CAL.RData")
FILE_LFS_ILO_CAL_RDATA

FILE_LFS_ILO_CAL_DTA  <- paste0(dir_data_QW,"LFS_ILO_",year,"_T",quarter,"_CAL.dta")
FILE_LFS_ILO_CAL_DTA

# Version plus flexible avec option SR
get_export_path <- function(target_quarter, quarter, year, use_sr = FALSE) {
  prefix <- if (use_sr) "SR_individu" else "individu"
  
  file.path(BASE_DIR, 
    "data", "04_weights", target_quarter, "calibrated_weights",
    paste0(prefix, "_T", quarter, "_", year, "_CAL.dta")
  )
}

# Utilisation
FILE_LFS_ILO_CAL_DTA_EXPORT <- get_export_path(TARGET_QUARTER, quarter, year, use_sr = FALSE)
FILE_LFS_ILO_CAL_DTA_EXPORT
###  Let's parameterize the name and path of the EXCEL file containing the empty template for table 1 already formatted 

FILE_TEMPLATE_TABLE_1_XLSX <- paste0(dir_prog_QW,"Template_table_1.xlsx")
FILE_TEMPLATE_TABLE_1_XLSX

###  Let's parameterize the name and path of the EXCEL file containing table 1 filled with data 

FILE_TABLE_1_XLSX <- paste0(dir_data_QW,"Table1_",year,"_T",quarter,"_", pathx,".xlsx")
FILE_TABLE_1_XLSX


###  Let's parameterize the name and path of the CSV file containing the result of STandard errors, CVs, and CIs 

LFS_STD_ERR_EMP_LEVELS_CSV  <- paste0(dir_data_QW,"LFS_STD_ERR_EMP_LEVELS_",year,"_T",quarter,"_", pathx ,".csv")
LFS_STD_ERR_EMP_LEVELS_CSV

###  Let's parameterize the name and path of the EXCEL file containing the empty template for the table of CVs 

LFS_STD_ERR_EMP_LEVEL_TEMPLATE3_XLSX  <- paste0( BASE_DIR , "/scripts/04_calibration/STANDARD_ERRORS/Templates/Template_CVS_EMP_Levels_ver3.xlsx")
LFS_STD_ERR_EMP_LEVEL_TEMPLATE3_XLSX


###  Let's parameterize the name and path of the EXCEL file containing the empty template for the table of CVs 

LFS_TABLE_CVS_EMP_LEVEL_TEMPLATE3_XLSX  <- paste0( dir_data_QW ,"Table_CVS_EMPL_Levels_ver3_",year,"_T",quarter,"_", pathx ,".xlsx") 
LFS_TABLE_CVS_EMP_LEVEL_TEMPLATE3_XLSX






######  STEP  3  ##############################################################################################
######           ##############################################################################################
###
###
###    RUN THE SEQUENCE OF SCRIPTS BELOW TO COMPLETE CALIBRATION OF FINAL WEIGHTS           
###
###
##############################################################################################################
##############################################################################################################


### folder with the sequence of scripts to run

dir_prog_QW



#######   RUN SCRIPT 01   ###########################################################################################
###
###    Read in R the full sample data and population figures available in the CSV format stored in a specific directory
###
##############################################################################################################

### open and run the script below step by step (in the prog folder) and check the outputs (in the data folder)

#  rstudioapi::navigateToFile(paste0( dir_prog_565QW , "01_Upload_Sample_Data_and_Known_Totals_in_R_", pathx,".R"  ))

### or run the script below altogether without opening it
PROG_DIR = paste0( BASE_DIR,"/scripts/04_calibration/QUARTERLY_WEIGHTING" ,"/",year,"/T",quarter,"/",pathx,"/")
source( paste0( PROG_DIR, "01_Upload_Sample_Data_and_Known_Totals_in_R_", pathx,".R"  ) )

#######   UPDATE EXCEL SCHEME ON SET OF CONSTRAINTS  #########################################################
###
###    Update excel scheme an programs to format summary tables on calibration produced by Regenesees
###
##############################################################################################################

xls = xl.get.excel()
xl.workbook.close(xl.workbook.name = NULL)
xl.workbook.open( paste0( PROG_DIR , "01_Set_of_constraints_", setx,".xlsx")   )



#######   RUN SCRIPT 02   ###########################################################################################
###
###       PREPARE INPUT SAMPLE DATA FOR REGENESEES 
###
##############################################################################################################

### open and run the script below step by step (in the prog folder) and check the outputs (in the data folder)

#  rstudioapi::navigateToFile(paste0( dir_prog_565QW , "02_Prepare_input_sample_data_for_regenesees_", pathx,".R"))

### or run the script below altogether without opening it 

source( paste0( PROG_DIR , "02_Prepare_input_sample_data_for_regenesees_", pathx,".R") )



#######   RUN SCRIPT 3   ###########################################################################################
###
###       PREPARE KNOWN TOTALS DATA FOR REGENESEES 
###
##############################################################################################################


### open and run the script below step by step (in the prog folder) and check the outputs (in the data folder)

#  rstudioapi::navigateToFile( paste0( dir_prog_565QW , "03_Prepare_input_pop_figures_for_regenesees_", pathx,".R") )

### or run the script below altogether without opening it 
source( paste0( PROG_DIR , "03_Prepare_input_pop_figures_for_regenesees_", pathx,".R") )



#######   RUN SCRIPT 04c   ###########################################################################################
###
###       RUN CALIBRATION WITH REGENESEES 
###
##############################################################################################################


### open and run the script below step by step (in the prog folder) and check the outputs (in the data folder)

#  rstudioapi::navigateToFile( paste0( dir_prog_565QW , "04c_Run_Quarterly_Calibration_with_Regenesees_", pathx,".R") )

### or run the script below altogether without opening it 
source( paste0( PROG_DIR , "04c_Run_Quarterly_Calibration_with_Regenesees_", pathx,".R") )



#######   RUN SCRIPT 5   ###########################################################################################
###
###       ATTACH FINAL WEIGHTS TO THE DATASET CONTAINING THE FULL SAMPLE DATA  
###
##############################################################################################################


### open and run the script below step by step (in the prog folder) and check the outputs (in the data folder)

#  rstudioapi::navigateToFile( paste0( dir_prog_565QW , "05_Attach_final_weights_to_full_sample_data_", pathx,".R") )

### or run the script below altogether without opening it  
source( paste0( PROG_DIR , "05_Attach_final_weights_to_full_sample_data_", pathx,".R") )



#######   RUN SCRIPT 6   ###########################################################################################
###
###       CHECK ESTIMATES OBTAINED WITH FINAL WEIGHTS 
###
##############################################################################################################

### open and run the script below step by step (in the prog folder) and check the outputs (in the data folder)

#  rstudioapi::navigateToFile( paste0( dir_prog_565QW , "06_Create_Table1_", pathx,".R") )

### or run the script below altogether without opening it  
source( paste0( PROG_DIR , "06_Create_Table1_", pathx,".R"  ) )



#######   RUN SCRIPT 7   ###########################################################################################
###
###       CALCULATE PRECISION 
###
##############################################################################################################


#  rstudioapi::navigateToFile( paste0( dir_prog_565QW , "07f_Calculate_Precision_of_levels_with_Regenesees_ver3_", pathx,".R") )

### or run the script below altogether without opening it  
source( paste0( PROG_DIR , "07f_Calculate_Precision_of_levels_with_Regenesees_ver3_", pathx,".R"  ) )

