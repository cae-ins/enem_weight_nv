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
########                                                                                                        ########.
########                                        R Script 01                                                     ########.
########                                                                                                        ########.
########      CREATE THE R DATAFRAMES CONTAINING                                                                ########.
########      - THE FULL SAMPLE DATA   (steps 1.1 and 1.2)                                                      ########.
########      - POPULATION FIGURES     (steps 1.3 and 1.4)                                                      ########.
########                                                                                                        ########.
########################################################################################################################.
########################################################################################################################.
########################################################################################################################.


######################################################################################################
###  
###   STEP 1.1 
### 
###   Read the full sample data available in the dta format stored in a specific directory
### 
######################################################################################################

root = "D:/DOCUMENTS/CAE/"



library(haven)

LFS_ILO_DER <- read_dta(paste0(root,"Calibration/Applications ENEM/DATA/DERIVED_VARIABLES/2024/T4/base_finale_ind_menage_wcal.dta"))

###  show the first 6 lines of the dataset 

head(LFS_ILO_DER)

### See the structure of the object

str(LFS_ILO_DER)

View(LFS_ILO_DER)


### We have 20 620 observations (individual interviews successfully completed) and 1 132 variables

### Note that the number of individuals interviewed can be obtained in different ways, and the result must be consistent


### and must also correspond to the number of records/rows of the dataframe

dim(LFS_ILO_DER)



### We can also check how many households we have interviewed by counting the unique households ids (interview__key)

length(unique(LFS_ILO_DER$interview__key))




### The number of regions (REGION)

length(unique(LFS_ILO_DER$HH2))



### We can also tabulate the actual sample size in several ways, for example using the function "table"

### to open the manual of the function table 

# help(table) 

table(LFS_ILO_DER$HH2)




### We can also check the estimates obtained using the design weights
### Create a table using the "expss" package and the magritte %>% pipe 
### (see https://magrittr.tidyverse.org/reference/pipe.html)


library(expss)

LFS_ILO_DER %>%
  tab_cols(HH6, total()) %>%
  tab_rows(HH2, total()) %>%
  tab_weight(poids_menage) %>% 
  tab_stat_sum %>%
  tab_pivot()


######################################################################################################
###  
###    STEP 1.2 
###
###    Save the R objects in the specific "DER" folder for future use
### 
######################################################################################################

save(LFS_ILO_DER ,file=paste0(root,"Calibration/Applications ENEM/DATA/DERIVED_VARIABLES/2024/T4/LFS_ILO_2024_T4_DER.RData"))

###  Check now within destination folder. We now have a new file named "LFS_SW_2024_T4_DER.RData"


#######   NOTE   ###########################################################################################
###
###  When we want to reuse the R objects (.RData) in a future session we can use the following code. 

ls()

###  Lets first remove all the objects from the memory of the current session

rm(LFS_ILO_DER)
ls()


###  Load the object "LFS_ILO_2024_T4_DER.RData" from the related folder

load(file=paste0(root,"Calibration/Applications ENEM/DATA/DERIVED_VARIABLES/2024/T4/LFS_ILO_2024_T4_DER.RData"))

###  Now check that the object "LFS_ILO_2021_Q1_DER" does exist. In R the object name is without ".Rdata"

ls()


###  Now let's verify again the content of the object

str(LFS_ILO_DER)






######################################################################################################
###  
###   STEP 1.3 
### 
###   Read the population figures available in the CSV format stored in a specific directory
### 
######################################################################################################


###  Read the CSV file stored in a specific directory 
library(readxl)
POP_LFS_BY_REGION_MILIEU_2AGEGR <- read_excel(paste0(root,"Calibration/Applications ENEM/DATA/POPULATION_ESTIMATES/2024/T4/POP_LFS_BY_REGION_MILIEU_2AGEGR_corrige.xlsx"))
POP_LFS_BY_REGION_MILIEU_2AGEGR

View(POP_LFS_BY_REGION_MILIEU_2AGEGR)


######################################################################################################
###  
###    STEP 1.4 
###
###    Save the R objects in the specific folder for future use
### 
######################################################################################################

save(POP_LFS_BY_REGION_MILIEU_2AGEGR,file=paste0(root,"/Calibration/Applications ENEM/DATA/POPULATION_ESTIMATES/2024/T4/POP_LFS_BY_REGION_MILIEU_2AGEGR_corrige.RData"))

###  Check now within destination folder. We now have a new file named "POP_LFS_BY_REGION_SEX_14AGEGR_2024_T4.RData"


###  Check the R objects created

ls()




