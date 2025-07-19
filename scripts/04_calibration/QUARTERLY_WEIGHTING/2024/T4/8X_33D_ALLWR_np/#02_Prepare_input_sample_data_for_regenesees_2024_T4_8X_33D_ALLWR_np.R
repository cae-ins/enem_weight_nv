########################################################################################################################.
########################################################################################################################.
########################################################################################################################.
########                                                                                                        ########.
########           TRAINING ON STRATEGIES TO CALCULATE LFS SAMPLE WEIGHTS USING CALIBRATION                     ########.
########                                                                                                        ########.
########          PREPARED BY: ANDERSON KOUASSI - STATISTICIEN - CAE - ANSTAT                                   ########.
########                                    E.mail: j.kouassi@stat.plan.gouv.ci                                 ########.
########                                                                                                        ########.
########                                 CASE STUDY  - (8X_33D_ALLWR_np)                                        ########.
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
########                                        R Script 02                                                     ########.
########                                                                                                        ########.
########        PROGRAM TO PREPARE INPUT SAMPLE DATA FOR FINAL CALIBRATION USING REGENESEES                     ########.
########                                                                                                        ########.
########        33 DOMAINS  (33 Regions)                                                                        ########.
########        8 CONSTRAINTS (X1 TO X8)                                                                        ########.
########              - Population by region, sex and 4 age groups    (X1 TO X8)                                ########.
########                                                                                                        ########.
########################################################################################################################.
########################################################################################################################.
library(writexl)
######################################################################################################
###  
###   STEP 2.1 - SET THE WORKING DIRECTORY WHERE THE OUPUTS OF THE CALIBRATION PROCESS WILL BE STORED 
### 
######################################################################################################

setwd("D:/DOCUMENTS/CAE/Calibration/Applications ENEM/DATA/QUARTERLY_WEIGHTING/2024/T4/8X_33D_ALLWR_np/")
getwd()


######################################################################################################
###  
###   STEP 2.2 - LOAD THE INPUT DATAFRAME CONTAINING THE SAMPLE DATA FROM FOLDER   DERIVED_VARIABLES
### 
######################################################################################################

ls()

# rm(LFS_ILO_DER)

load(file="D:/DOCUMENTS/CAE/Calibration/Applications ENEM/DATA/DERIVED_VARIABLES/2024/T4/LFS_ILO_2024_T4_DER.RData")

ls()


### check its the structure

str(LFS_ILO_DER)


### Create a new dataframe that will be renamed at the end of the steps as LFS_SAMPLE_DATA_2024_T4_8X_33D_ALLWR_np
### Working on the new dataframe will help to avoid possible unwanted modifications/errors on the original dataset.
### The shorter name will help when we have to write the code. The prefix tmp will help to recognize that is a temporary
### dataframe that does not need to be saved permanently on disk  

tmpSD <- LFS_ILO_DER

head(tmpSD)



######################################################################################################
###  
###   STEP 2.3 - CALCULATE THE SET OF 28 X VARIABLES (DUMMY 0,1)  
### 
######################################################################################################


###   Create the X variables and initialize them to 0

tmpSD$X1 <- 0 
tmpSD$X2 <- 0 
tmpSD$X3 <- 0 
tmpSD$X4 <- 0 
tmpSD$X5 <- 0 
tmpSD$X6 <- 0 
tmpSD$X7 <- 0 
tmpSD$X8 <- 0
tmpSD$X9 <- 0 
tmpSD$X10 <- 0 
tmpSD$X11 <- 0 
tmpSD$X12 <- 0 
tmpSD$X13 <- 0 
tmpSD$X14 <- 0 
tmpSD$X15 <- 0 
tmpSD$X16 <- 0 
tmpSD$X17 <- 0 
tmpSD$X18 <- 0 
tmpSD$X19<- 0 
tmpSD$X20 <- 0 
tmpSD$X21 <- 0 
tmpSD$X22 <- 0
tmpSD$X23 <- 0 
tmpSD$X24 <- 0 
tmpSD$X25 <- 0 
tmpSD$X26 <- 0 
tmpSD$X27 <- 0 
tmpSD$X28 <- 0 



###    For each record of the dataset, the following code will assign 1 to the X variables based on the specific conditions  

tmpSD$X1[ tmpSD$AgeAnnee>=  0 & tmpSD$AgeAnnee <=14 & tmpSD$M5==1] <- 1
tmpSD$X2[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <=19 & tmpSD$M5==1] <- 1
tmpSD$X3[ tmpSD$AgeAnnee>= 20 & tmpSD$AgeAnnee <=24 & tmpSD$M5==1] <- 1
tmpSD$X4[ tmpSD$AgeAnnee>= 25 & tmpSD$AgeAnnee <=29 & tmpSD$M5==1] <- 1
tmpSD$X5[ tmpSD$AgeAnnee>= 30 & tmpSD$AgeAnnee <=34 & tmpSD$M5==1] <- 1
tmpSD$X6[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <=34 & tmpSD$M5==1] <- 1
tmpSD$X7[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <=39 & tmpSD$M5==1] <- 1
tmpSD$X8[ tmpSD$AgeAnnee>= 40 & tmpSD$AgeAnnee <=44 & tmpSD$M5==1] <- 1
tmpSD$X9[ tmpSD$AgeAnnee>= 45 & tmpSD$AgeAnnee <=49 & tmpSD$M5==1] <- 1
tmpSD$X10[ tmpSD$AgeAnnee>= 50 & tmpSD$AgeAnnee <=54 & tmpSD$M5==1] <- 1
tmpSD$X11[ tmpSD$AgeAnnee>= 55 & tmpSD$AgeAnnee <=59 & tmpSD$M5==1] <- 1
tmpSD$X12[ tmpSD$AgeAnnee>= 60 & tmpSD$AgeAnnee <=64 & tmpSD$M5==1] <- 1
tmpSD$X13[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <=64 & tmpSD$M5==1] <- 1
tmpSD$X14[ tmpSD$AgeAnnee>= 65                       & tmpSD$M5==1] <- 1


tmpSD$X15[ tmpSD$AgeAnnee>=  0 & tmpSD$AgeAnnee <=14 & tmpSD$M5==2] <- 1
tmpSD$X16[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <=19 & tmpSD$M5==2] <- 1
tmpSD$X17[ tmpSD$AgeAnnee>= 20 & tmpSD$AgeAnnee <=24 & tmpSD$M5==2] <- 1
tmpSD$X18[ tmpSD$AgeAnnee>= 25 & tmpSD$AgeAnnee <=29 & tmpSD$M5==2] <- 1
tmpSD$X19[ tmpSD$AgeAnnee>= 30 & tmpSD$AgeAnnee <=34 & tmpSD$M5==2] <- 1
tmpSD$X20[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <=34 & tmpSD$M5==2] <- 1
tmpSD$X21[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <=39 & tmpSD$M5==2] <- 1
tmpSD$X22[ tmpSD$AgeAnnee>= 40 & tmpSD$AgeAnnee <=44 & tmpSD$M5==2] <- 1
tmpSD$X23[ tmpSD$AgeAnnee>= 45 & tmpSD$AgeAnnee <=49 & tmpSD$M5==2] <- 1
tmpSD$X24[ tmpSD$AgeAnnee>= 50 & tmpSD$AgeAnnee <=54 & tmpSD$M5==2] <- 1
tmpSD$X25[ tmpSD$AgeAnnee>= 55 & tmpSD$AgeAnnee <=59 & tmpSD$M5==2] <- 1
tmpSD$X26[ tmpSD$AgeAnnee>= 60 & tmpSD$AgeAnnee <=64 & tmpSD$M5==2] <- 1
tmpSD$X27[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <=64 & tmpSD$M5==2] <- 1
tmpSD$X28[ tmpSD$AgeAnnee>= 65                       & tmpSD$M5==2] <- 1


######################################################################################################
###  
###   STEP 2.4 - CREATE THE VARIABLE "DOMAIN" THAT IDENTIFIES THE DOMAIN OF ESTIMATION   
### 
######################################################################################################

tmpSD$DOMAIN <- as.character(tmpSD$HH2)


######################################################################################################
###  
###   STEP 2.5 - CREATE THE DUMMY VARIABLES NEEDED TO CALCULATE THE MAIN LFS INDICATORS AND THEIR PRECISION  
### 
######################################################################################################


###   Respondents in working age 15 plus   

tmpSD$POP_15plus <- 0
tmpSD$POP_15plus[tmpSD$AgeAnnee>=15] <- 1




names(tmpSD)


######################################################################################################
###  
###   STEP 2.6 - CREATE AN OBJECT CONTAING THE LIST OF Xs TO RETAIN TO BE USED IN THE NEXT STEPS  
### 
######################################################################################################


###   We can use the following code 

list_of_X <- c("X1","X2","X3","X4","X5","X6","X7","X8", "X9","X10","X11","X12","X13","X14","X15","X16", "X17","X18","X19","X20","X21", "X22","X23","X24","X25","X26","X27","X28")  
list_of_X 


###   or alternatively the next one (much more useful when we have a huge number of X)

list_of_X  <- paste(rep("X",28),seq(1,28),sep="")
list_of_X 


######################################################################################################
###  
###   STEP 2.7 - CREATE THE R DATAFRAME WITH THE SAMPLE DATA THAT ARE USED AS FIRST INPUT BY REGENESEES  
### 
######################################################################################################


### We can create the R dataframe with the sample data 
### keeping only the variables needed for weighting and to calculate Precision

LFS_SAMPLE_DATA <- tmpSD[,c("DOMAIN", names(tmpSD), list_of_X,"POP_15plus")]

head( LFS_SAMPLE_DATA)


### We can remove the temporary dataframe 
ls()
rm(tmpSD)
ls()


######################################################################################################
###  
###   STEP 2.8 - SAVE ON DISK THE R DATAFRAME WITH THE SAMPLE DATA IN THE OUTPUT FOLDER   
### 
######################################################################################################


### If we have set the working directory for the outputs we can use 

save(LFS_SAMPLE_DATA, file="LFS_SAMPLE_DATA_2024_T4_28X_33D_ALLWR_np.RData")


### If we have not set the working directory for the outputs (or we need to save the object in a different folder) we can use 

# save(LFS_SAMPLE_DATA ,file='D:/DOCUMENTS/CAE/Calibration/Applications ENEM/DATA/QUARTERLY_WEIGHTING/2024/T4/8X_33D_ALLWR_np//LFS_SAMPLE_DATA_2024_T4_28X_33D_ALLWR_np.RData')



######################################################################################################
###  
###   STEP 2.9 - CHECK THE POPULATION ESTIMATES OBTAINED USING THE DESIGN WEIGHT   
### 
######################################################################################################


### Create a table using the package "expss" 
### and the magritte %>% pipe operators (see https://magrittr.tidyverse.org/reference/pipe.html)

LFS_SAMPLE_DATA  %>%
  tab_cols(M5, total()) %>%
  tab_rows(DOMAIN, total()) %>%
  tab_weight(poids_menage) %>%
  tab_stat_sum %>%
  tab_pivot()


######################################################################################################
###  
###   STEP 2.10 - SUMMARIZE BY DOMAIN TO SAVE IN A DATAFRAME THE SAMPLE SIZE FOR EACH X
###  
######################################################################################################


### Create a table (stored in the R object "LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE" ).

LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE <- aggregate( x = LFS_SAMPLE_DATA[, list_of_X], 
                                                       by = list(DOMAIN = LFS_SAMPLE_DATA$DOMAIN), 
													  FUN = sum)


LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE <- rbind( LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE,
                                           c("National",colSums(LFS_SAMPLE_DATA[, list_of_X]))
)

LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE[ LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE$DOMAIN != "Total", c("X2","X3","X4","X5","X7","X8", "X9","X10","X11","X12","X16", "X17","X18","X19","X21", "X22","X23","X24","X25","X26")] = 0
View(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE)


###   Save permanently the object in the destination folder  
###   If we have set the working directory for the outputs we can use 

save(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE, file="LFS_SAMPLE_DATA_2024_T4_28X_33D_ALLWR_np_SUMMARY_OF_Xs_SAMPLE_SIZE.RData")


###   Save the results in an excel file using the package "writexl"

write_xlsx(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE,
          "LFS_SAMPLE_DATA_2024_T4_28X_33D_ALLWR_np_SUMMARY_OF_Xs_SAMPLE_SIZE.xlsx" )



######################################################################################################
###  
###   STEP 2.11 - SUMMARIZE BY DOMAIN TO SAVE IN A DATAFRAME THE ESTIMATES OBTAINED USING THE DESIGN WEIGHT
###  
######################################################################################################


### Create a table (stored in the object "LFS_SAMPLE_DATA_2024_T4_8X_33D_ALLWR_np_SUMMARY_OF_Xs_EST_DES_WEIGHT" ). 
### Now, we need to weight the X

LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT <-
  LFS_SAMPLE_DATA  %>%
  tab_cols(mdset(X1 %to% X28),total()) %>%
  tab_rows(DOMAIN, total()) %>%
  tab_weight(poids_menage) %>%
  tab_stat_sum %>%
  tab_pivot() %>%
  as.data.frame()

View(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT)


###   Save permanently the object in the destination folder  
###   If we have set the working directory for the outputs we can use 

save(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT, file="LFS_SAMPLE_DATA_2024_T4_8X_33D_ALLWR_np_SUMMARY_OF_Xs_EST_DES_WEIGHT.RData")


###   Save the results in an excel file



write_xlsx(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT,
          "LFS_SAMPLE_DATA_2024_T4_8X_33D_ALLWR_np_SUMMARY_OF_Xs_EST_DES_WEIGHT.xlsx" )


