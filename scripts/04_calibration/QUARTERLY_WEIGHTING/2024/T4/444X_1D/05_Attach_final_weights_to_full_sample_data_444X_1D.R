########################################################################################################################.
########################################################################################################################.
########################################################################################################################.
########                                                                                                        ########.
########           TRAINING ON STRATEGIES TO CALCULATE LFS SAMPLE WEIGHTS USING CALIBRATIONS                    ########.
########                                                                                                        ########.
########          PREPARED BY: ANTONIO R. DISCENZA - ILO DEPARTMENT OF STATISTICS - SSMU UNIT                   ########.
########                                    E.mail: discenza@ilo.org                                            ########.
########                                                                                                        ########.
########                                 CASE STUDY N. 6 - (444X_1D_ALLWR)                                      ########.
########                       CALIBRATION OF FINAL WEIGHTS USING R FOR ALL STEPS                               ########.
########                                                                                                        ########.
########        Version B:  Filenames, paths, reference periods and set of constraints are parameterized        ########.
########                                                                                                        ########.
########                                                                                                        ########.
########                                        R Script 05                                                     ########.
########                                                                                                        ########.
########                         PROGRAM TO ATTACH FINAL WEIGHTS AND CORRECTION FACTORS                         ########.
########                          TO THE FULL SAMPLE "DER" TO CREATE THE DATASET "CAL"                          ########.
########                                                                                                        ########.
########        1 DOMAINS  (33 Regions)                                                                         ########.
########        444 CONSTRAINTS (X1 TO X444)                                                                    ########.
########              - Population by sex and urban and rural and 12 age groups    (X1 TO X48)                  ########.
########              - Population by region, urban and rural, sex and 3 age groups  (X49 TO X444)              ########.    
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

getwd()
setwd(dir_data_QW)
getwd()


######################################################################################################
###  
###   STEP 5.2 
###  
###   Load the R objects from the specific folder (not necessary if we have produced them in the same R session)  
###
##############################################################################################################

### Load the full sample dataframe "DER"

load( FILE_LFS_ILO_DER_RDATA )

head(LFS_ILO_DER)


### Load the dataframe with the final weights

load( FILE_LFS_CALIBRATION_FINAL_WEIGHTS_RDATA )

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

save(LFS_ILO_CAL, file = FILE_LFS_ILO_CAL_RDATA )


######################################################################################################
###  
###   STEP 5.5 
###  
###    SAVE AN IMAGE OF ALL THE R OBJECTS CREATED IN THIS PHASE (CAN BE REUSED LATER FOR OTHER TASKS)
###
##############################################################################################################

save.image( FILE_LFS_CALIBRATION_IMAGE_RDATA )

# load(FILE_LFS_CALIBRATION_IMAGE_RDATA)


######################################################################################################
###  
###   STEP 5.5 
###  
###   CHECK FINAL ESTIMATES   
###
##############################################################################################################



### We can compare the estimates obtained using the design weights and final weights
### Create a table using the "expss" package and the magritte %>% pipe 
### (see https://magrittr.tidyverse.org/reference/pipe.html)

library("expss")

load( FILE_LFS_ILO_CAL_RDATA)
str(LFS_ILO_CAL)

### calculate ilo status using design weights

LFS_ILO_CAL %>%
  # tab_cols(ilo_lfs , total()) %>%
  tab_rows(HH2, total()) %>%
  tab_weight(poids_menage) %>%
  tab_stat_sum %>%
  tab_pivot()


### calculate ilo status using final weights

LFS_ILO_CAL %>%
  # tab_cols(ilo_lfs , total()) %>%
  tab_rows(HH2, total()) %>%
  tab_weight(FINAL_WEIGHT) %>%
  tab_stat_sum %>%
  tab_pivot()


######################################################################################################
###  
###   STEP 5.6 
###  
###   LET'S TRY TO COMPARE QUaRTERLY AND MONTHLY ESTIMATES OF ILO labour status   
###
##############################################################################################################



# LFS_ILO_CAL$FINAL_MONTHLY_WEIGHT <- LFS_ILO_CAL$FINAL_WEIGHT * 3

###   QUARTERLY ESTIMATE

# LFS_ILO_CAL %>%
#   tab_cols(ilo_lfs , total()) %>%
#   tab_rows(QUARTER) %>%
#   tab_weight(FINAL_WEIGHT) %>%
#   tab_stat_sum %>%
#   tab_pivot()


###   MONTHLY ESTIMATES

# LFS_ILO_CAL %>%
#   tab_cols(ilo_lfs , total()) %>%
#   tab_rows(MONTH) %>%
#   tab_weight(FINAL_MONTHLY_WEIGHT) %>%
#   tab_stat_sum %>%
#   tab_pivot()
