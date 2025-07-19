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
########                                                                                                        ########.
########                                        R Script 05                                                     ########.
########                                                                                                        ########.
########                         PROGRAM TO ATTACH FINAL WEIGHTS AND CORRECTION FACTORS                         ########.
########                          TO THE FULL SAMPLE "DER" TO CREATE THE DATASET "CAL"                          ########.
########                                                                                                        ########.
########        1 DOMAINS  (33 Regions)                                                                          ########.
########        156 CONSTRAINTS (X1 TO X156)                                                                      ########.
########              - Population by region, sex and 2 age groups    (X1 TO X156)                              ########.
########                                                                                                        ########.
########################################################################################################################.
########################################################################################################################.


######################################################################################################
###  
###   STEP 5.1 
###  
###   SET THE WORKING DIRECTORY WHERE THE OUPUTS WILL BE STORED 
### 
######################################################################################################

root = "D:/DOCUMENTS/CAE/"

setwd(paste0(root,"Calibration/Applications ENEM/DATA/QUARTERLY_WEIGHTING/2024/T4/156X_1D_ALLWR_np_milieu/"))
getwd()


######################################################################################################
###  
###   STEP 5.2 
###  
###   Load the R objects from the specific folder (not necessary if we have produced them in the same R session)  
###
##############################################################################################################

### Load the full sample dataframe "DER"

load(file='D:/DOCUMENTS/CAE/Calibration/Applications ENEM/DATA/DERIVED_VARIABLES/2024/T4/LFS_ILO_2024_T4_DER.RData')

head(LFS_ILO_DER)


### Load the dataframe with the final weights

load("LFS_CALIBRATION_2024_T4_156X_1D_ALLWR_np_FINAL_WEIGHTS.RData")

head(LFS_CALIBRATION_FINAL_WEIGHTS )


######################################################################################################
###  
###   STEP 5.3 
###  
###   Merge the final weights to the full sample "DER" and create the new dataframe "CAL"  
###
##############################################################################################################


### select the variables to be merged with the full sample

tmp_FINAL_WEIGHTS <- LFS_CALIBRATION_FINAL_WEIGHTS[, c("INDKEY", "FINAL_CORR_FACTOR", "FINAL_WEIGHT")]

head(tmp_FINAL_WEIGHTS) 


### verify the dimension of the two dataframes (must have the same number of rows) 

dim(LFS_ILO_DER)

dim(tmp_FINAL_WEIGHTS)


### merge the two datasets by "INDKEY" (the unique identifiers of the individual respondents) 

LFS_ILO_DER$INDKEY    <- as.factor(paste0(sample_data$HH2, "-",sample_data$HH3, "-", sample_data$HH4, "-", sample_data$HH8, "-", sample_data$interview__key, "-", sample_data$membres__id))


LFS_ILO_CAL <- merge( LFS_ILO_DER, tmp_FINAL_WEIGHTS, by = "INDKEY") 


### verify the content and the dimension of the resulting "CAL" dataframe 

dim(LFS_ILO_CAL)

str(LFS_ILO_CAL)


######################################################################################################
###  
###   STEP 5.4 
###  
###   SAVE THE R DATAFRAME WITH THE FINAL WEIGHTS ON DISK   
###
##############################################################################################################

write_xlsx(LFS_ILO_CAL,
           "LFS_CALIBRATION_2024_T4_156X_1D_ALLWR_np.xlsx" )

save(LFS_ILO_CAL, file="LFS_ILO_2024_T4_CAL.RData")


######################################################################################################
###  
###   STEP 5.5 
###  
###    SAVE AN IMAGE OF ALL THE R OBJECTS CREATED IN THIS PHASE (CAN BE REUSED LATER FOR OTHER TASKS)
###
##############################################################################################################

ls()

save.image("LFS_CALIBRATION_2024_T4_156X_1D_ALLWR_np_IMAGE.RData")

# load("LFS_CALIBRATION_2024_T4_8X_1D_ALLWR_np_IMAGE.RData")


######################################################################################################
###  
###   STEP 5.6 
###  
###   CHECK FINAL ESTIMATES   
###
##############################################################################################################



### We can compare the estimates obtained using the design weights and final weights
### Create a table using the "expss" package and the magritte %>% pipe 
### (see https://magrittr.tidyverse.org/reference/pipe.html)

library("expss")

load("LFS_ILO_2024_T4_CAL.RData")
str(LFS_ILO_CAL)

### calculate ilo status using design weights

LFS_ILO_CAL %>%
  #tab_cols(ilo_lfs , total()) %>%
  tab_rows(HH2, total()) %>%
  tab_weight(poids_menage) %>%
  tab_stat_sum %>%
  tab_pivot()

### calculate ilo status using final weights

LFS_ILO_CAL %>%
  #tab_cols(ilo_lfs , total()) %>%
  tab_rows(HH2, total()) %>%
  tab_weight(FINAL_WEIGHT) %>%
  tab_stat_sum %>%
  tab_pivot()





### Vérifications

LFS_ILO_CAL[,c("interview__key", "HH2", "HH8", "poids_menage", "FINAL_WEIGHT")]


LFS_CALIBRATION_FINAL_WEIGHTS  %>%
  tab_cols(mdset(X1 %to% X156),total()) %>%
  tab_rows(HH2, total()) %>%
  tab_weight(FINAL_WEIGHT) %>%
  tab_stat_sum %>%
  tab_pivot() %>%
  as.data.frame()
