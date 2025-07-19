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
########                                        R Script 03                                                     ########.
########                                                                                                        ########.
########        PROGRAM TO PREPARE THE INPUT "KNOWN TOTALS" FOR FINAL CALIBRATION USING REGENESEES              ########.
########                                                                                                        ########.
########        33 DOMAINS  (33 Regions)                                                                        ########.
########        8 CONSTRAINTS (X1 TO X8)                                                                        ########.
########              - Population by region, sex and 4 age groups    (X1 TO X8)                                ########.
########                                                                                                        ########.
########################################################################################################################.
########################################################################################################################.

#### TO REUSE THIS PROGRAM IN ANOTHER QUARTER MAKE A COPY AND SUBSTITUTE THE TWO STRINGS "\2024\T4\" AND "2024_T4" ACCORDINGLY   ****/.
#### TO REUSE THIS PROGRAM WITH ANOTHER SET OF CONSTRAINTS: a) MAKE A COPY AND RENAME ACCORDINGLY; b) SUBSTITUTE THE STRINGS "8X_33D" ACCORDINGLY (e.g. 66X_4D") WITHIN PATHS AND FILENAMES  ****/.



######################################################################################################
###  
###   STEP 3.1 - SET THE WORKING DIRECTORY WHERE THE OUPUTS WILL BE STORED 
### 
######################################################################################################

setwd("D:/DOCUMENTS/CAE/Calibration/Applications ENEM/DATA/QUARTERLY_WEIGHTING/2024/T4/8X_33D_ALLWR_np/")
getwd()


######################################################################################################
###  
###   STEP 3.2 - LOAD THE INPUT DATAFRAME CONTAINING THE POPULATION FIGURES FROM FOLDER 560  
### 
######################################################################################################

load(file="D:/DOCUMENTS/CAE/Calibration/Applications ENEM/DATA/POPULATION_ESTIMATES/2024/T4/POP_LFS_BY_REGION_SEX_4AGEGR.RData")

### Check that the dataframe "POP_LFS_BY_REGION_SEX_12AGEGR" has been loaded


str(POP_LFS_BY_REGION_SEX_4AGEGR)


View(POP_LFS_BY_REGION_SEX_4AGEGR)




### Create a new dataframe that will be renamed at the end of the steps as LFS_KNOWN_TOTALS_2024_T4_8X_33D
### Working on the new dataframe will help to avoid possible unwanted modifications/errors on the original dataset.
### The shorter name will help when we have to write the code. The prefix tmp will help to recognize that is a temporary
### dataframe that does not need to be saved permanently on disk  

tmpKT <- POP_LFS_BY_REGION_SEX_4AGEGR

head(tmpKT )


######################################################################################################
###  
###   STEP 3.3 - CALCULATE THE SET OF 24 X VARIABLES (containing the population figures)  
### 
######################################################################################################


###    Create the X variables and initialize them to 0    

tmpKT$X1 <- 0 
tmpKT$X2 <- 0 
tmpKT$X3 <- 0 
tmpKT$X4 <- 0 
tmpKT$X5 <- 0 
tmpKT$X6 <- 0 
tmpKT$X7 <- 0 
tmpKT$X8 <- 0 

View(tmpKT)


###   We are creating the X starting from the variable already in the dataframe

tmpKT$X1[  tmpKT$Sexe==1] <- tmpKT$groupe_age_0_14[   tmpKT$Sexe==1] 
tmpKT$X2[  tmpKT$Sexe==1] <- tmpKT$groupe_age_15_34[  tmpKT$Sexe==1]
tmpKT$X3[  tmpKT$Sexe==1] <- tmpKT$groupe_age_35_64[  tmpKT$Sexe==1]
tmpKT$X4[  tmpKT$Sexe==1] <- tmpKT$groupe_age_65_plus[  tmpKT$Sexe==1]


tmpKT$X5[ tmpKT$Sexe==2] <- tmpKT$groupe_age_0_14[   tmpKT$Sexe==2] 
tmpKT$X6[ tmpKT$Sexe==2] <- tmpKT$groupe_age_15_34[  tmpKT$Sexe==2] 
tmpKT$X7[ tmpKT$Sexe==2] <- tmpKT$groupe_age_35_64[  tmpKT$Sexe==2]
tmpKT$X8[ tmpKT$Sexe==2] <- tmpKT$groupe_age_65_plus[  tmpKT$Sexe==2]


######################################################################################################
###  
###   STEP 3.4 - CREATE THE VARIABLE "DOMAIN" THAT IDENTIFIES THE DOMAIN OF ESTIMATION   
### 
######################################################################################################



View(tmpKT)

#names(tmpKT)


######################################################################################################
###  
###   STEP 3.5 - CREATE AN OBJECT CONTAING THE LIST OF Xs TO RETAIN TO BE USED IN THE NEXT STEPS  
### 
######################################################################################################

### Create a list of the Xs to retain to be used in the next steps (useful when we have a huge number of X)

list_of_X  <- paste(rep("X",8),seq(1,8),sep="")
list_of_X 


######################################################################################################
###  
###   STEP 3.6 - SUMMARIZE BY DOMAIN TO SAVE IN A DATAFRAME THE KNOWN TOTALS FOR EACH X  
### 
######################################################################################################

LFS_KNOWN_TOTALS <- aggregate(tmpKT[, list_of_X], by = list(DOMAIN = tmpKT$Domain), FUN = sum)
View(LFS_KNOWN_TOTALS)

######################################################################################################
###  
###   STEP 3.7 - CREATE THE R DATAFRAME WITH THE KNOWN TOTALS THAT ARE USED AS SECOND INPUT BY REGENESEES  
### 
######################################################################################################

### If we have set the working directory for the outputs we can use 

save(LFS_KNOWN_TOTALS, file="LFS_KNOWN_TOTALS_2024_T4_8X_33D_ALLWR_np.RData")


######################################################################################################
###  
###   STEP 3.8 - CHECK TOTAL POPULATION FIGURES
###
######################################################################################################

###   We can calculate the total population summing all the X values

sum(LFS_KNOWN_TOTALS[,list_of_X])

### or else summing the columns from 2 to 25 of the dataframe

sum(LFS_KNOWN_TOTALS[,seq(2,9)])




######################################################################################################
###  
###   STEP 3.8 - CREATE A TABLE FOR REPORTING WITH ROWS AND COLUMNS TOTALS TO EXPORT IN AN EXCEL FILE   
### 
######################################################################################################

### create a new dataframe for reporting

LFS_KNOWN_TOTALS_TOT_POP_FIGURES <- LFS_KNOWN_TOTALS


### add a column with the total of the 8 Xs using the function rowSums

LFS_KNOWN_TOTALS_TOT_POP_FIGURES$X_TOT <- rowSums(LFS_KNOWN_TOTALS_TOT_POP_FIGURES[,seq(2,9)])

View(LFS_KNOWN_TOTALS_TOT_POP_FIGURES) 

### create and insert also a new row with the totals for each X 

### lets calculate the sum of the Xs

colSums( LFS_KNOWN_TOTALS_TOT_POP_FIGURES[,seq(2,10)])

### lets add an additional element at the beginning

c("Total",colSums( LFS_KNOWN_TOTALS_TOT_POP_FIGURES[,seq(2,10)] ))

### lets do that in a single step using also the function rbind


LFS_KNOWN_TOTALS_TOT_POP_FIGURES <- rbind( LFS_KNOWN_TOTALS_TOT_POP_FIGURES,
                                           c("Total",colSums( LFS_KNOWN_TOTALS_TOT_POP_FIGURES[,seq(2,10)] ))
                                         )
View(LFS_KNOWN_TOTALS_TOT_POP_FIGURES) 

###   Save permanently the object in the destination folder  

save(LFS_KNOWN_TOTALS_TOT_POP_FIGURES, file="LFS_KNOWN_TOTALS_2024_T4_8X_33D_ALLWR_np_TOT_POP_FIGURES.RData")


###   Save the results in an excel file


write_xlsx(LFS_KNOWN_TOTALS_TOT_POP_FIGURES,
          "LFS_KNOWN_TOTALS_2024_T4_8X_33D_ALLWR_np_TOT_POP_FIGURES.xlsx" )










