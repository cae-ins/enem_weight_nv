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

###   choose the year

year=2024

year 

###   choose the quarter

quarter=4

quarter 



###   For regenesees: number of constraints X used in the calibration with Regenesees

xnum <- 312
xnum

###   For regenesees: suffix for filenames referring to the set of parameters X and the number of domains of estimation D

setx <- '312X_1D'
setx

###   For regenesees: suffix for filenames referring to the set of parameters X and the number of domains of estimation D
pathx <- '312X_1D'
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

root_lfs <- "D:/DOCUMENTS/CAE/Calibration/Applications ENEM"
root_lfs


##############################################################################################################
###
###  Let's parameterize the path of the directory/folder from which we want to read the csv file with the full sample data 

                     

dir_data_DV <- paste0( root_lfs , "/DATA/DERIVED_VARIABLES/", year, "/T", quarter , "/" )
dir_data_DV



##############################################################################################################
###
###  Let's parameterize the name and path of the csv file with the full sample data "_DER"

FILE_LFS_ILO_DER_DTA  <- paste0(dir_data_DV,"base_finale_ind_menage_wcal.dta")
FILE_LFS_ILO_DER_DTA

###  Let's parameterize the name and path of the RData file with the full sample data 

FILE_LFS_ILO_DER_RDATA  <- paste0(dir_data_DV,"LFS_ILO_",year,"_T",quarter,"_DER.RData")
FILE_LFS_ILO_DER_RDATA


##############################################################################################################
###
###  Let's parameterize the path of the directory/folder from which we want to read the population figures 

dir_data_PE <- paste0( root_lfs , "/DATA/POPULATION_ESTIMATES/", year, "/T", quarter , "/" )
dir_data_PE


##############################################################################################################
###
###  Let's parameterize the name and path of the csv file with the population figures by regions
### "W:/2023_ILO_ITC_WEIGHTING/LFS_GSBPM_SW/DATA/560_POPULATION_ESTIMATES/2021/Quarter1/POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_2021_Q1.csv"


FILE_POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_CSV  <- paste0(dir_data_PE,"POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_",year,"_T",quarter,".csv")
FILE_POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_CSV

FILE_POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_XLSX  <- paste0(dir_data_PE,"POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_",year,"_T",quarter,".xlsx")
FILE_POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_XLSX

FILE_POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_DTA  <- paste0(dir_data_PE,"POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_",year,"_T",quarter,".dta")
FILE_POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_DTA

###  Let's parameterize the name and path of the RData file with the population figures 

FILE_POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_RDATA  <- paste0(dir_data_PE,"POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_",year,"_T",quarter,".RData")
FILE_POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_RDATA


##############################################################################################################
###
###  Let's parameterize the name and path of the csv file with the population figures by districts
###  "W:/2023_ILO_ITC_WEIGHTING/LFS_GSBPM_SW/DATA/560_POPULATION_ESTIMATES/2021/Quarter1/POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR_2021_Q1vert.csv"

# FILE_POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert_CSV  <- paste0(dir_data_PE,"POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR_",year,"_T",quarter,"vert.csv")
# FILE_POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert_CSV
# 
# 
# FILE_POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert_XLSX  <- paste0(dir_data_PE,"POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR_",year,"_T",quarter,"vert.xlsx")
# FILE_POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert_XLSX
# 
# FILE_POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR_DTA  <- paste0(dir_data_PE,"POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR_",year,"_T",quarter,".dta")
# FILE_POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR_DTA
# 
# ###  Let's parameterize the name and path of the RData file with the population figures 
# 
# FILE_POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert_RDATA  <- paste0(dir_data_PE,"POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR_",year,"_T",quarter,"vert.RData")
# FILE_POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert_RDATA



##############################################################################################################
###
###  Let's parameterize the path of the working directory where the outputs of the calibration will be stored

dir_data_QW <- paste0( root_lfs , "/DATA/QUARTERLY_WEIGHTING/", year, "/T", quarter , "/" , pathx,"/")
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
### "W\ILO_LFS_GSBPM\PROG\565_QUARTERLY_WEIGHTING\2021\Quarter1\312X_1D_ALLWR"

dir_prog_QW <- paste0( root_lfs , "/PROG/QUARTERLY_WEIGHTING/", pathx,"/")
dir_prog_QW


###  Let's parameterize the name and path of the script file that constains the additional functions for ReGenesees

R_SCRIPT_NEW_FUNCTIONS_FOR_X_CONSTRAINS <- paste0( root_lfs , "/PROG/QUARTERLY_WEIGHTING/Other_R_functions_for_Regenesees/Functions_to_Create _X_vector_and_X_Summary_Table.R")
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

LFS_STD_ERR_EMP_LEVEL_TEMPLATE3_XLSX  <- paste0( root_lfs , "/PROG/STANDARD_ERRORS/Templates/Template_CVS_EMP_Levels_ver3.xlsx")
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

#  source( paste0( dir_prog_565QW , "01_Upload_Sample_Data_and_Known_Totals_in_R_", pathx,".R"  ) )



#######   UPDATE EXCEL SCHEME ON SET OF CONSTRAINTS  #########################################################
###
###    Update excel scheme an programs to format summary tables on calibration produced by Regenesees
###
##############################################################################################################

#  xls = xl.get.excel()
#  xl.workbook.close(xl.workbook.name = NULL)
#  xl.workbook.open( paste0( dir_prog_565QW , "01_Set_of_constraints_", setx,".xlsx")   )



#######   RUN SCRIPT 02   ###########################################################################################
###
###       PREPARE INPUT SAMPLE DATA FOR REGENESEES 
###
##############################################################################################################

### open and run the script below step by step (in the prog folder) and check the outputs (in the data folder)

#  rstudioapi::navigateToFile(paste0( dir_prog_565QW , "02_Prepare_input_sample_data_for_regenesees_", pathx,".R"))

### or run the script below altogether without opening it 

#  source( paste0( dir_prog_565QW , "02_Prepare_input_sample_data_for_regenesees_", pathx,".R") )



#######   RUN SCRIPT 3   ###########################################################################################
###
###       PREPARE KNOWN TOTALS DATA FOR REGENESEES 
###
##############################################################################################################


### open and run the script below step by step (in the prog folder) and check the outputs (in the data folder)

#  rstudioapi::navigateToFile( paste0( dir_prog_565QW , "03_Prepare_input_pop_figures_for_regenesees_", pathx,".R") )

### or run the script below altogether without opening it 
#  source( paste0( dir_prog_565QW , "03_Prepare_input_pop_figures_for_regenesees_", pathx,".R") )



#######   RUN SCRIPT 04c   ###########################################################################################
###
###       RUN CALIBRATION WITH REGENESEES 
###
##############################################################################################################


### open and run the script below step by step (in the prog folder) and check the outputs (in the data folder)

#  rstudioapi::navigateToFile( paste0( dir_prog_565QW , "04c_Run_Quarterly_Calibration_with_Regenesees_", pathx,".R") )

### or run the script below altogether without opening it 
#  source( paste0( dir_prog_565QW , "04c_Run_Quarterly_Calibration_with_Regenesees_", pathx,".R") )



#######   RUN SCRIPT 5   ###########################################################################################
###
###       ATTACH FINAL WEIGHTS TO THE DATASET CONTAINING THE FULL SAMPLE DATA  
###
##############################################################################################################


### open and run the script below step by step (in the prog folder) and check the outputs (in the data folder)

#  rstudioapi::navigateToFile( paste0( dir_prog_565QW , "05_Attach_final_weights_to_full_sample_data_", pathx,".R") )

### or run the script below altogether without opening it  
#  source( paste0( dir_prog_565QW , "05_Attach_final_weights_to_full_sample_data_", pathx,".R") )



#######   RUN SCRIPT 6   ###########################################################################################
###
###       CHECK ESTIMATES OBTAINED WITH FINAL WEIGHTS 
###
##############################################################################################################

### open and run the script below step by step (in the prog folder) and check the outputs (in the data folder)

#  rstudioapi::navigateToFile( paste0( dir_prog_565QW , "06_Create_Table1_", pathx,".R") )

### or run the script below altogether without opening it  
#  source( paste0( dir_prog_565QW , "06_Create_Table1_", pathx,".R"  ) )



#######   RUN SCRIPT 7   ###########################################################################################
###
###       CALCULATE PRECISION 
###
##############################################################################################################


#  rstudioapi::navigateToFile( paste0( dir_prog_565QW , "07f_Calculate_Precision_of_levels_with_Regenesees_ver3_", pathx,".R") )

### or run the script below altogether without opening it  
#  source( paste0( dir_prog_565QW , "07f_Calculate_Precision_of_levels_with_Regenesees_ver3_", pathx,".R"  ) )

