########################################################################################################################.
########################################################################################################################.
########################################################################################################################.
########                                                                                                        ########.
########          TRAINING ON STRATEGIES TO CALCULATE LFS SAMPLE WEIGHTS USING CALIBRATION                      ########.
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
########                                        R Script 04c                                                    ########.
########                                                                                                        ########.
########                     PROGRAM TO CALCULATE FINAL WEIGHTS OF LFS USING CALIBRATION ESTIMATORS             ########.
########                                SUMMARY TABLES FOR THE X ARE ALSO PRODUCED                              ########.
########                                                                                                        ########.
########                                    BASED ON THE R PACKAGE "REGENESSES"                                 ########.
########                               see https://diegozardetto.github.io/ReGenesees/                          ########.
########                                                                                                        ########.
########                                                                                                        ########.
########        1 DOMAINS  (33 Regions)                                                                        ########.
########        156 CONSTRAINTS (X1 TO X156)                                                                        ########.
########              - Population by region, sex and 2 age groups    (X1 TO X156)                                ########.
########                                                                                                        ########.
########################################################################################################################.
########################################################################################################################.


########################################################################################################################
###  
###   STEP 4.0 -  THE PACKAGES BELOW HAVE TO BE INSTALLED ONLY ONCE. THEN THE CODE CAN BE COMMENTED USING THE HASHTAG 
### 
########################################################################################################################

# install.packages("remotes")
# remotes::install_github("DiegoZardetto/ReGenesees")
# remotes::install_github("DiegoZardetto/ReGenesees.GUI")

######################################################################################################
###  
###   STEP 4.1 - SET THE WORKING DIRECTORY WHERE THE OUPUTS ARE STORED 
### 
######################################################################################################
root = "D:/DOCUMENTS/CAE/"


setwd(paste0(root,"Calibration/Applications ENEM/DATA/QUARTERLY_WEIGHTING/2024/T4/156X_1D_ALLWR_np/"))
getwd()

ls()

######################################################################################################
###  
###   STEP 4.2 - LOAD THE R OBJECTS CONTAINING SAMPLE DATA AND KNOWN TOTAL FROM THE WORKING DIRECTORY 
###              (not necessary if we have produced them in the same R session)
### 
######################################################################################################

load("LFS_SAMPLE_DATA_2024_T4_156X_1D_ALLWR_np.RData")

ls()

View(LFS_SAMPLE_DATA)



load("LFS_KNOWN_TOTALS_2024_T4_156X_1D_ALLWR_np.RData")

View(LFS_KNOWN_TOTALS)


######################################################################################################
###  
###   STEP 4.3 -  Activate the libraries that are needed by the procedure every time we need to calibrate
### 
######################################################################################################

library("ReGenesees")
library("summarytools")
library("writexl")

###   lists the objects in memory in the currect session

ls()

###   show the manuals of the package (when needed)
# help(ReGenesees)



######################################################################################################
###  
###   STEP 4.4 -  Step 4 is only needed when we use parameterised R script
### 
######################################################################################################

######################################################################################################
###  
###   STEP 4.5 -  Step 5 is only needed when we use parameterised R scripts
### 
######################################################################################################


######################################################################################################
###  
###   STEP 4.6 -  Read the input SAMPLE_DATA that has been created with the R scripts "02_......R"  
###  
######################################################################################################

sample_data <-  	LFS_SAMPLE_DATA
			  
###   transform some variables as factor as required by the routines used later


sample_data$DOMAIN    <- as.factor(sample_data$DOMAIN)
sample_data$STRATAKEY <- as.factor(sample_data$HH2)
sample_data$PSUKEY    <- as.factor(paste0(sample_data$HH2, "-",sample_data$HH3, "-", sample_data$HH4, "-", sample_data$HH8))
sample_data$HHKEY     <- as.factor(paste0(sample_data$HH2,  "-",sample_data$HH3, "-", sample_data$HH4, "-", sample_data$HH8, "-", sample_data$interview__key))
sample_data$INDKEY    <- as.factor(paste0(sample_data$HH2, "-",sample_data$HH3, "-", sample_data$HH4, "-", sample_data$HH8, "-", sample_data$interview__key, "-", sample_data$membres__id))

###   add a variable with "ones" that will be used later to calculate summary statistics on the weighting

sample_data$ONES      <- 1


###  show the entire dataset
View(sample_data)

### in case we need to rename some variables whose name was not correctly read from the csv
#names(sample_data)[names(sample_data) == "@UR_RU"] <- "UR_RU"
#head(sample_data)

###  Check the total of the estimates using the design weights (before final calibration) 
sum(sample_data$poids_menage)


######################################################################################################
###  
###   STEP 4.7 -  Read the known totals that has been created with the R scripts "03_......R"   
###  
######################################################################################################

known_totals <-  	LFS_KNOWN_TOTALS

###  transform some vairables as factor as required by the routines used later

known_totals$DOMAIN <- as.factor(known_totals$DOMAIN)
known_totals


###  Check the total of the known total population 
###  Calculates the sum of the X by rows (the total for each domain) and then adds over the domains to get the total for the country 
#sum(rowSums( known_totals[, seq(2,288) ] ))
sum(rowSums( known_totals[, seq(2,157) ] ))



######################################################################################################
###  
###   STEP 4.8 
###
###   CREATE THE DESIGN OBJECT THAT SPECIFIES THE SAMPLE DESIGN FOR THE LFS
###   TO KNOW MORE ABOUT THE FUNCTION USE help("e.svydesign")
###  
######################################################################################################

design_lfs  <- ReGenesees::e.svydesign(data = sample_data, 
                                       ids = ~ PSUKEY + HHKEY, 
                                      strata = ~ STRATAKEY, 
                                    weights = ~ poids_menage, 
                                        fpc = NULL, 
                               self.rep.str = NULL, 
                                 check.data = TRUE)


###  check if there is any lonely PSU in a STRATA (if that is the case need to ne collapsed)
###  if everything is we will get the message "#No lonely PSUs found!"

ReGenesees::find.lon.strata(design_lfs)


######################################################################################################
###  
###   STEP 4.9 
###
###   CREATE THE MODEL FOR THE SET OF CONSTRAINTS (NUMBER OF X USED)
###
###  Use the function "constraints_model" to create the list of Xs identifying the calibration cells
###  The function "constraints_model" has been developed by Alessandro Martini, 
###  Statistician at the Italian National Institute of Statistics (email alessandro.martini@istat.it)  
###
###  The function is not part of the package and must be uploaded from file below
###
#################################################################################################################

### We shoudl wirte the calibration constraints in the following way. However we can used the function 
### illustrated below

# constrains_x <- ~X1 + X2 + X3 + X4 + X5 + X6 + X7 + X8 + X9 + X10 + X11 + X12 + 
#  X13 + X14 + X15 + X16 + X17 + X18 + X19 + X20 + X21 + X22 + 
#  X23 + X24 - 1


### install new functions for ReGenesees from the following file
source(paste0(root,"Calibration/Applications ENEM/PROG/QUARTERLY_WEIGHTING/Other_R_functions_for_Regenesees/Functions_to_Create _X_vector_and_X_Summary_Table.R"))

###  use the function "constraints_model" to create the list of Xs identifying the calibration cells (Calibration model)

constrains_x <- constraints_model(156)

###  Shows the calibration cells Xs 

constrains_x



######################################################################################################
###  
###   STEP 4.10 
###
###   FILL IN THE POPULATION DATA IN A SPECIFIC DATAFRAME REQUIRED BY THE PROCEDURE.
###   ALSO CHECK THAT THE SAMPLE DATA AND POPULATION CONSTRAINTS ARE CONSISTENT 
###
###################################################################################################################


### If everything is ok we will get the message "# Coherence check between 'universe' and 'template': OK"

poptemplate  <-  ReGenesees::pop.template(data= known_totals, calmodel= constrains_x, partition = ~ DOMAIN )
popdataframe <-  ReGenesees::fill.template(universe= known_totals, template= poptemplate, mem.frac= 5)

popdataframe

###  Check the total of the known total population 
sum(rowSums( popdataframe[, seq(2,157) ] ))


######################################################################################################
###  
###   STEP 4.12 
###
###   SUGGEST THE BOUNDS TO BE USED FOR A RANGE RESTRICTED CALIBRATION:
###
#####################################################################################################################


bounds.h <-ReGenesees::bounds.hint( design = design_lfs, 
                             df.population = popdataframe, 
                                  calmodel = constrains_x, 
                                 partition = ~ DOMAIN )

bounds.h

### For the bounds we use the suggested ones called "bounds.h" or define a new one, for example c(0.75, 1.35)  
### Make sure the suggested bounds are not negative, otherwise define new positive bound as above  


######################################################################################################
###  
###   STEP 4.13 
###
###   START CALIBRATION 
###   
###   TO KNOW MORE ABOUT THE CALIBRATION FUNCTION 
###   help("e.calibrate")
###   
###   CHECK ALWAYS CONVERGENCE OF CALIBRATION USING ecal.status 
###       A) IF RETURN CODE IS ZERO FOR ALL DOMAINS THE CALIBRATION CONVERGED
###       B) IF RETURN CODE IS ONE FOR AT LEAST ONE DOMAIN THE CALIBRATION DID NOT CONVERGE HENCE 
###          BOUNDS NEED TO BE ENLARGED (for example from c(0.5, 1.8) to c(0.3, 2.0))
###
#####################################################################################################################

### Create the calibrated object (ignore the message in red "Warning in ReGenesees::e.calibrate.....")
### It appears because we are not using the standard way used by the author of the package to build the known totals
 
calib_lfs   <-  ReGenesees::e.calibrate(design = design_lfs, 
                                 df.population = popdataframe, 
                                      calmodel = constrains_x,
                                     partition = ~ DOMAIN , 
                                        calfun = "logit", 
                                        #bounds = bounds.h , # La borne suggerée est négative
                                       bounds = c(0.354, 3),
                               aggregate.stage =  NULL, 
                                         maxit = 50,
                                       epsilon = 1e-06, 
                                         force = TRUE)


###   Check convergence of calibration: all the "$return.codes" for all DOMAINS from "ecal.status" must always be zero 

###   If one or more codes are different from 0 the procedure did not converge and the final weights are not correctly calculated
###   and the constraints/benchmarks (the set of X) or the DOMAINS need to be revised

ecal.status


###   Check that the sum of the final weights is equal to the population benchmarks  

sum(weights(calib_lfs))


###   Read the message about convergence  

ReGenesees::check.cal(calib_lfs)


###   Read the message about strata and clusters    

calib_lfs

######################################################################################################
###  
###    STEP 4.15 
###
###   ATTACH THE FINAL WEIGHTS TO THE INPUT DATA IN THE R DATASET 
###
###############################################################################################################

###   Attach the final weights to the sample_data dataset

sample_data$FINAL_WEIGHT <- weights(calib_lfs)

###   Calculate the final correction factors

sample_data$FINAL_CORR_FACTOR <- sample_data$FINAL_WEIGHT / sample_data$poids_menage


###   View the "sample_data" dataframe. Notice that it does not contain all the variables collected but only those needed for calibration

View(sample_data)


######################################################################################################
###  
###    STEP 4.17 
###
###    CHECK VISUALLY THE DIFFERENCES BETWEEN INTERMEDIATE WEIGHTS AND FINAL WEIGHTS 
###
###############################################################################################################


plot(sample_data$poids_menage,sample_data$FINAL_WEIGHT,abline(0,1,col="green"))
abline(0,1.2,col="blue")
abline(0,.8,col="blue")
abline(0,1.5,col="red")
abline(0,.5,col="red")



#######   STEP 16   ###########################################################################################
###
###    SAVE THE WEIGHTS IN A NEW R OBJECT THAT WILL BE USED FOR NEXT STEPS 
###
###############################################################################################################

LFS_CALIBRATION_FINAL_WEIGHTS <- sample_data

View(LFS_CALIBRATION_FINAL_WEIGHTS)



###    Saver the R object on disk

save(LFS_CALIBRATION_FINAL_WEIGHTS, file="LFS_CALIBRATION_2024_T4_156X_1D_ALLWR_np_FINAL_WEIGHTS.RData")





######################################################################################################
###  
###    STEP 4.16 
###
###   PRODUCE SUMMARY STATISTICS FOR FINAL WEIGHTS AND CORRECTION FACTORS BY STRATA 
###   AND EXPORT TO A CSV OR XLS FILE 
###
###############################################################################################################



### SUMMARY OF DESIGN WEIGHTS

LFS_CALIBRATION_SUMMARY_OF_DESIGN_WEIGHTS <-
  aggregate(  x = list( DESIGN_WEIGHT = LFS_CALIBRATION_FINAL_WEIGHTS$poids_menage) , 
              by = list( STRATA = LFS_CALIBRATION_FINAL_WEIGHTS$HH2),
              FUN = summary )

View(LFS_CALIBRATION_SUMMARY_OF_DESIGN_WEIGHTS)

save(LFS_CALIBRATION_SUMMARY_OF_DESIGN_WEIGHTS, file="LFS_CALIBRATION_2024_T4_156X_1D_ALLWR_np_SUMMARY_OF_DESIGN_WEIGHTS.RData")

write.csv(LFS_CALIBRATION_SUMMARY_OF_DESIGN_WEIGHTS, file="LFS_CALIBRATION_2024_T4_156X_1D_ALLWR_np_SUMMARY_OF_DESIGN_WEIGHTS.csv")


### SUMMARY OF CORRECTION FACTORS

LFS_CALIBRATION_SUMMARY_OF_FINAL_CORR_FACTOR <-
  aggregate(  x = list( FINAL_CORR_FACTOR = LFS_CALIBRATION_FINAL_WEIGHTS$FINAL_CORR_FACTOR ) , 
              by = list( STRATA = LFS_CALIBRATION_FINAL_WEIGHTS$HH2),
              FUN = summary )

View(LFS_CALIBRATION_SUMMARY_OF_FINAL_CORR_FACTOR)

save(LFS_CALIBRATION_SUMMARY_OF_FINAL_CORR_FACTOR, file="LFS_CALIBRATION_2024_T4_156X_1D_ALLWR_np_SUMMARY_OF_CORR_FACTORS.RData")

write.csv(LFS_CALIBRATION_SUMMARY_OF_FINAL_CORR_FACTOR, file="LFS_CALIBRATION_2024_T4_156X_1D_ALLWR_np_SUMMARY_OF_CORR_FACTORS.csv")


### SUMMARY OF FINAL WEIGHTS

LFS_CALIBRATION_SUMMARY_OF_FINAL_WEIGHTS <-
  aggregate(  x = list( FINAL_WEIGHT = LFS_CALIBRATION_FINAL_WEIGHTS$FINAL_WEIGHT ) , 
              by = list( STRATA = LFS_CALIBRATION_FINAL_WEIGHTS$HH2),
              FUN = summary )

View(LFS_CALIBRATION_SUMMARY_OF_FINAL_WEIGHTS)

save(LFS_CALIBRATION_SUMMARY_OF_FINAL_WEIGHTS, file="LFS_CALIBRATION_2024_T4_156X_1D_ALLWR_np_SUMMARY_OF_FINAL_WEIGHTS.RData")

write.csv(LFS_CALIBRATION_SUMMARY_OF_FINAL_WEIGHTS, file="LFS_CALIBRATION_2024_T4_156X_1D_ALLWR_np_SUMMARY_OF_FINAL_WEIGHTS.csv")



