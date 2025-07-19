########################################################################################################################.
########################################################################################################################.
########################################################################################################################.
########                                                                                                        ########.
########           TRAINING ON STRATEGIES TO CALCULATE LFS SAMPLE WEIGHTS USING CALIBRATION                     ########.
########                                                                                                        ########.
########          PREPARED BY: ANDERSON KOUASSI - STATISTICIEN - CAE - ANSTAT                                   ########.
########                                    E.mail: j.kouassi@stat.plan.gouv.ci                                 ########.
########                                                                                                        ########.
########                                 CASE STUDY  - (156X_1D_ALLWR_np)                                        ########.
########                       CALIBRATION OF FINAL WEIGHTS USING R FOR ALL STEPS ( suffix _ALLWR)              ########.
########                                                                                                        ########.
########                                    BASED ON THE R PACKAGE "REGENESSES"                                 ########.
########                               see https://diegozardetto.github.io/ReGenesees/                          ########.
########                                                                                                        ########.
########                      Version A:  Filenames and paths are not parameterized ( suffix _np)               ########.
########                                                                                                        ########.
########                                                                                                        ########.
########                                        MASTER SCRIPT                                                   ########.
########                                                                                                        ########.
########                                                                                                        ########.
########    Population figures available from an external trusted official source to be used as benchmarks      ########.  
########    for the final weights are stored in the following folder                                            ########.  
########    "D:/DOCUMENTS/CAE/Calibration/Applications ENEM/PROG/POPULATION_ESTIMATE/2024/T4/                   ########.
########                                                                                                        ########.
########    Microdata containing the interviews successfully completed are stored in the following folder       ########.  
########    "D:/DOCUMENTS/CAE/Calibration/Applications ENEM/PROG/DERIVED_VARIABLES/2024/T4/                                          ########.
########    These microdata have been edited and imputed and contain the theorethical design weights.           ########.  
########    Final weights will be calculated starting from design weights using Regenesees and will be attached ########.
########    back to the microdata file                                                                          ########.
########                                                                                                        ########.
########    The folder containing the sequence of R scripts needed for the procedure is                         ########.
########    "D:/DOCUMENTS/CAE/Calibration/Applications ENEM/PROG/QUARTERLY_WEIGHTING/2024/T4/156X_1D_ALLWR_np/                       ########.
########                                                                                                        ########.
########    The outputs of the procedure (both R objects and Excel files) will be stored in the folder          ########.
########    "D:/DOCUMENTS/CAE/Calibration/Applications ENEM/PROG/QUARTERLY_WEIGHTING/2024/T4/                   ########.                                                                                           ###
########    Please create such folder in your file structure before starting                                    ########.
########                                                                                                        ########.
########    The set of R scripts connected to this master script relates to Trimestre 4 2024.                   ########.
########                                                                                                        ########.
########    To reuse these scripts in another quarter do the following:                                         ########.
########         a) make a copy of all scripts in the folder of a new quarter;                                  ########.
########         b) substitute the two strings "/2024/T4/ " and "2024_T4" accordingly                           ########.
########                                                                                                        ########.
########    To reuse these scripts with another set of constraints:                                             ########.
########         a) make a copy of all scripts in another folder and rename accordingly;                        ########.
########         b) substitute the string "156X_1D" accordingly (e.g. 66X_4D") within paths and filenames;       ########.
########         c) modify the scripts to include the new constraints                                           ########.
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

### To install Regenesees 
# install.packages("devtools")
# devtools::install_github("DiegoZardetto/ReGenesees")

### or also  
# install.packages("remotes")
# remotes::install_github("DiegoZardetto/ReGenesees")
# remotes::install_github("DiegoZardetto/ReGenesees.GUI")


### To install all the other packages
# remotes::install_github("dcomtois/summarytools")
# install.packages("summarytools")

# install.packages("dplyr")
# install.packages("excel.link")
# install.packages("writexl")

### install the library to create multidimensional tables with weighted data
 install.packages("expss")

### install the library to read and write SPSS and STATA datasets
# install.packages("haven")



#######   ACTIVATE PACKAGES   #################################################################################
###
###    Activate the libraries that are needed by the procedure every time need to design a sample
###
##############################################################################################################

library("ReGenesees")     # to calculate weights, CVs and DEFFs
library("dplyr")          # to summarize data
library("summarytools")   # to summarize data
library("excel.link")     # contains the functions xl.get.excel(), xl.write(), xl.workbook.save()
library("readxl")         # to export R dataframes in excel
library("writexl")        # to export R dataframes in excel
library("expss")          # contains functions to create weighted tables
library("haven")          # to read and write SPSS and STATA datasets 



##############################################################################################################
###
###    RUN THE SEQUENCE OF SCRIPTS BELOW TO COMPLETE CALIBRATION OF FINAL WEIGHTS           
###
##############################################################################################################

### The sequence of scripts is stored in the following folder 

### "D:/DOCUMENTS/CAE/Calibration/Applications ENEM/PROG/QUARTERLY_WEIGHTING/2024/T4/156X_1D_ALLWR_np_milieu/ 




#######   RUN SCRIPT 01   ###########################################################################################
###
###    Read in R the full sample data and population figures available in the CSV format stored in a specific directory
###
##############################################################################################################

### run the script below step by step (in the prog folder) and check the outputs (in the data folder)

# "01_Upload_Sample_Data_and_Known_Totals_in_R_2024_T4_np.R"



#######   UPDATE EXCEL SCHEME ON SET OF CONSTRAINTS  #########################################################
###
###    Update excel scheme an programs to format summary tables on calibration produced by Regenesees
###
##############################################################################################################

# "01_Set_of_constraints_156X_1D.xlsx"


#######   RUN SCRIPT 02   ###########################################################################################
###
###       PREPARE INPUT SAMPLE DATA FOR REGENESEES 
###
##############################################################################################################

### run the script below step by step (in the prog folder) and check the outputs (in the data folder)

# "02_Prepare_input_sample_data_for_regenesees_2024_T4_156X_1D_ALLWR_np.R"



#######   RUN SCRIPT 3   ###########################################################################################
###
###       PREPARE KNOWN TOTALS DATA FOR REGENESEES 
###
##############################################################################################################

### run the script below step by step (in the prog folder) and check the outputs (in the data folder)

# "03_Prepare_input_pop_figures_for_regenesees_2024_T4_156X_1D_ALLWR_np.R"




#######   RUN SCRIPT 04c   ###########################################################################################
###
###       RUN CALIBRATION WITH REGENESEES 
###
##############################################################################################################

### run the script below step by step (in the prog folder) and check the outputs (in the data folder)

# "04c_Run_Quarterly_Calibration_with_Regenesees_156X_1D_ALLWR_np_2_Commented.R"



#######   RUN SCRIPT 5   ###########################################################################################
###
###       ATTACH FINAL WEIGHTS TO THE DATASET CONTAINING THE FULL SAMPLE DATA  
###
##############################################################################################################

### run the script below step by step (in the prog folder) and check the outputs (in the data folder)

# "05_Attach_final_weights_to_full_sample_data_2024_T4_156X_1D_ALLWR_np.R"



#######   RUN SCRIPT 6   ###########################################################################################
###
###       CHECK ESTIMATES OBTAINED WITH FINAL WEIGHTS 
###
##############################################################################################################

### run the script below step by step (in the prog folder) and check the outputs (in the data folder)

# "06_Create_Table1_2024_T4_156X_1D_ALLWR_np.R"

