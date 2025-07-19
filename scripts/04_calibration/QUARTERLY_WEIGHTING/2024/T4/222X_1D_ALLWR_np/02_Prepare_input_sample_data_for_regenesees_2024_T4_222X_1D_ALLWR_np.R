########################################################################################################################.
########################################################################################################################.
########################################################################################################################.
########                                                                                                        ########.
########           TRAINING ON STRATEGIES TO CALCULATE LFS SAMPLE WEIGHTS USING CALIBRATION                     ########.
########                                                                                                        ########.
########          PREPARED BY: ANDERSON KOUASSI - STATISTICIEN - CAE - ANSTAT                                   ########.
########                                    E.mail: j.kouassi@stat.plan.gouv.ci                                 ########.
########                                                                                                        ########.
########                                 CASE STUDY  - (222X_1D_ALLWR_np)                                        ########.
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
########        1 DOMAINS  (33 Regions)                                                                        ########.
########        222 CONSTRAINTS (X1 TO X222)                                                                        ########.
########              - Population by region, sex and 14 age groups    (X1 TO X222)                                ########.
########                                                                                                        ########.
########################################################################################################################.
########################################################################################################################.
library(writexl)
######################################################################################################
###  
###   STEP 2.1 - SET THE WORKING DIRECTORY WHERE THE OUPUTS OF THE CALIBRATION PROCESS WILL BE STORED 
### 
######################################################################################################
root = "D:/DOCUMENTS/CAE/"


setwd(paste0(root,"Calibration/Applications ENEM/DATA/QUARTERLY_WEIGHTING/2024/T4/222X_1D_ALLWR_np/"))
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
### The shorter name will help when we have to write the code. The prefix tmp will help to r&gnize that is a temporary
### dataframe that does not need to be saved permanently on disk  

tmpSD <- LFS_ILO_DER

head(tmpSD)



######################################################################################################
###  
###   STEP 2.3 - CALCULATE THE SET OF 8 X VARIABLES (DUMMY 0,1)  
### 
######################################################################################################


###   Create the X variables and initialize them to 0

tmpSD <- cbind( tmpSD , data.frame(matrix(0 , nrow = nrow(tmpSD), ncol =  222, byrow = FALSE)))
#tmpSD <- cbind( tmpSD , data.frame(matrix(0 , nrow = nrow(tmpSD), ncol =  xnum, byrow = FALSE)))

###   CREATE AN OBJECT CONTAING THE LIST OF Xs TO RETAIN TO BE USED IN THE NEXT STEPS  

list_of_X  <- paste(rep("X",222),seq(1,222),sep="")
#list_of_X  <- paste(rep("X",xnum),seq(1,xnum),sep="")
list_of_X





###    For each r&rd of the dataset, the following code will assign 1 to the X variables based on the specific conditions  

###  MALES by 12 AGE GROUPS

tmpSD$X1[ tmpSD$AgeAnnee>=  0 & tmpSD$AgeAnnee <=14 & tmpSD$M5==1] <- 1
tmpSD$X2[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <=19 & tmpSD$M5==1] <- 1
tmpSD$X3[ tmpSD$AgeAnnee>= 20 & tmpSD$AgeAnnee <=24 & tmpSD$M5==1] <- 1
tmpSD$X4[ tmpSD$AgeAnnee>= 25 & tmpSD$AgeAnnee <=29 & tmpSD$M5==1] <- 1
tmpSD$X5[ tmpSD$AgeAnnee>= 30 & tmpSD$AgeAnnee <=34 & tmpSD$M5==1] <- 1
tmpSD$X6[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <=39 & tmpSD$M5==1] <- 1
tmpSD$X7[ tmpSD$AgeAnnee>= 40 & tmpSD$AgeAnnee <=44 & tmpSD$M5==1] <- 1
tmpSD$X8[ tmpSD$AgeAnnee>= 45 & tmpSD$AgeAnnee <=49 & tmpSD$M5==1] <- 1
tmpSD$X9[ tmpSD$AgeAnnee>= 50 & tmpSD$AgeAnnee <=54 & tmpSD$M5==1] <- 1
tmpSD$X10[tmpSD$AgeAnnee>= 55 & tmpSD$AgeAnnee <=59 & tmpSD$M5==1] <- 1
tmpSD$X11[tmpSD$AgeAnnee>= 60 & tmpSD$AgeAnnee <=64 & tmpSD$M5==1] <- 1
tmpSD$X12[tmpSD$AgeAnnee>= 65                  & tmpSD$M5==1] <- 1

###  FEMALES by 12 AgeAnnee GROUPS

tmpSD$X13[tmpSD$AgeAnnee>=  0 & tmpSD$AgeAnnee <=14 & tmpSD$M5==2] <- 1
tmpSD$X14[tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <=19 & tmpSD$M5==2] <- 1
tmpSD$X15[tmpSD$AgeAnnee>= 20 & tmpSD$AgeAnnee <=24 & tmpSD$M5==2] <- 1
tmpSD$X16[tmpSD$AgeAnnee>= 25 & tmpSD$AgeAnnee <=29 & tmpSD$M5==2] <- 1
tmpSD$X17[tmpSD$AgeAnnee>= 30 & tmpSD$AgeAnnee <=34 & tmpSD$M5==2] <- 1
tmpSD$X18[tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <=39 & tmpSD$M5==2] <- 1
tmpSD$X19[tmpSD$AgeAnnee>= 40 & tmpSD$AgeAnnee <=44 & tmpSD$M5==2] <- 1
tmpSD$X20[tmpSD$AgeAnnee>= 45 & tmpSD$AgeAnnee <=49 & tmpSD$M5==2] <- 1
tmpSD$X21[tmpSD$AgeAnnee>= 50 & tmpSD$AgeAnnee <=54 & tmpSD$M5==2] <- 1
tmpSD$X22[tmpSD$AgeAnnee>= 55 & tmpSD$AgeAnnee <=59 & tmpSD$M5==2] <- 1
tmpSD$X23[tmpSD$AgeAnnee>= 60 & tmpSD$AgeAnnee <=64 & tmpSD$M5==2] <- 1
tmpSD$X24[tmpSD$AgeAnnee>= 65                  & tmpSD$M5==2] <- 1


table(tmpSD$X25)
table(tmpSD$OFFICIEL_CodReg)
# 
# tmpSD$X25[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==1] <- 1
# tmpSD$X26[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==1] <- 1
# tmpSD$X27[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==1] <- 1
# tmpSD$X28[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==1] <- 1
# tmpSD$X29[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==1] <- 1
# tmpSD$X30[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==1] <- 1
# tmpSD$X31[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==1] <- 1
# tmpSD$X32[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==1] <- 1
# tmpSD$X33[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==2] <- 1
# tmpSD$X34[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==2] <- 1
# tmpSD$X35[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==2] <- 1
# tmpSD$X36[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==2] <- 1
# tmpSD$X37[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==2] <- 1
# tmpSD$X38[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==2] <- 1
# tmpSD$X39[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==2] <- 1
# tmpSD$X40[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==2] <- 1
# tmpSD$X41[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==3] <- 1
# tmpSD$X42[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==3] <- 1
# tmpSD$X43[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==3] <- 1
# tmpSD$X44[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==3] <- 1
# tmpSD$X45[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==3] <- 1
# tmpSD$X46[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==3] <- 1
# tmpSD$X47[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==3] <- 1
# tmpSD$X48[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==3] <- 1
# tmpSD$X49[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==4] <- 1
# tmpSD$X50[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==4] <- 1
# tmpSD$X51[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==4] <- 1
# tmpSD$X52[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==4] <- 1
# tmpSD$X53[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==4] <- 1
# tmpSD$X54[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==4] <- 1
# tmpSD$X55[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==4] <- 1
# tmpSD$X56[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==4] <- 1
# tmpSD$X57[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==5] <- 1
# tmpSD$X58[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==5] <- 1
# tmpSD$X59[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==5] <- 1
# tmpSD$X60[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==5] <- 1
# tmpSD$X61[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==5] <- 1
# tmpSD$X62[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==5] <- 1
# tmpSD$X63[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==5] <- 1
# tmpSD$X64[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==5] <- 1
# tmpSD$X65[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==6] <- 1
# tmpSD$X66[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==6] <- 1
# tmpSD$X67[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==6] <- 1
# tmpSD$X68[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==6] <- 1
# tmpSD$X69[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==6] <- 1
# tmpSD$X70[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==6] <- 1
# tmpSD$X71[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==6] <- 1
# tmpSD$X72[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==6] <- 1
# tmpSD$X73[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==7] <- 1
# tmpSD$X74[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==7] <- 1
# tmpSD$X75[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==7] <- 1
# tmpSD$X76[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==7] <- 1
# tmpSD$X77[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==7] <- 1
# tmpSD$X78[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==7] <- 1
# tmpSD$X79[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==7] <- 1
# tmpSD$X80[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==7] <- 1
# tmpSD$X81[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==8] <- 1
# tmpSD$X82[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==8] <- 1
# tmpSD$X83[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==8] <- 1
# tmpSD$X84[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==8] <- 1
# tmpSD$X85[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==8] <- 1
# tmpSD$X86[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==8] <- 1
# tmpSD$X87[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==8] <- 1
# tmpSD$X88[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==8] <- 1
# tmpSD$X89[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==9] <- 1
# tmpSD$X90[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==9] <- 1
# tmpSD$X91[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==9] <- 1
# tmpSD$X92[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==9] <- 1
# tmpSD$X93[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==9] <- 1
# tmpSD$X94[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==9] <- 1
# tmpSD$X95[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==9] <- 1
# tmpSD$X96[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==9] <- 1
# tmpSD$X97[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==10] <- 1
# tmpSD$X98[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==10] <- 1
# tmpSD$X99[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==10] <- 1
# tmpSD$X100[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==10] <- 1
# tmpSD$X101[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==10] <- 1
# tmpSD$X102[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==10] <- 1
# tmpSD$X103[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==10] <- 1
# tmpSD$X104[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==10] <- 1
# tmpSD$X105[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==11] <- 1
# tmpSD$X106[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==11] <- 1
# tmpSD$X107[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==11] <- 1
# tmpSD$X108[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==11] <- 1
# tmpSD$X109[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==11] <- 1
# tmpSD$X110[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==11] <- 1
# tmpSD$X111[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==11] <- 1
# tmpSD$X112[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==11] <- 1
# tmpSD$X113[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==12] <- 1
# tmpSD$X114[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==12] <- 1
# tmpSD$X115[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==12] <- 1
# tmpSD$X116[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==12] <- 1
# tmpSD$X117[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==12] <- 1
# tmpSD$X118[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==12] <- 1
# tmpSD$X119[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==12] <- 1
# tmpSD$X120[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==12] <- 1
# tmpSD$X121[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==13] <- 1
# tmpSD$X122[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==13] <- 1
# tmpSD$X123[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==13] <- 1
# tmpSD$X124[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==13] <- 1
# tmpSD$X125[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==13] <- 1
# tmpSD$X126[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==13] <- 1
# tmpSD$X127[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==13] <- 1
# tmpSD$X128[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==13] <- 1
# tmpSD$X129[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==14] <- 1
# tmpSD$X130[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==14] <- 1
# tmpSD$X131[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==14] <- 1
# tmpSD$X132[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==14] <- 1
# tmpSD$X133[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==14] <- 1
# tmpSD$X134[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==14] <- 1
# tmpSD$X135[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==14] <- 1
# tmpSD$X136[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==14] <- 1
# tmpSD$X137[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==15] <- 1
# tmpSD$X138[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==15] <- 1
# tmpSD$X139[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==15] <- 1
# tmpSD$X140[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==15] <- 1
# tmpSD$X141[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==15] <- 1
# tmpSD$X142[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==15] <- 1
# tmpSD$X143[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==15] <- 1
# tmpSD$X144[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==15] <- 1
# tmpSD$X145[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==16] <- 1
# tmpSD$X146[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==16] <- 1
# tmpSD$X147[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==16] <- 1
# tmpSD$X148[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==16] <- 1
# tmpSD$X149[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==16] <- 1
# tmpSD$X150[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==16] <- 1
# tmpSD$X151[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==16] <- 1
# tmpSD$X152[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==16] <- 1
# tmpSD$X153[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==17] <- 1
# tmpSD$X154[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==17] <- 1
# tmpSD$X155[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==17] <- 1
# tmpSD$X156[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==17] <- 1
# tmpSD$X157[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==17] <- 1
# tmpSD$X158[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==17] <- 1
# tmpSD$X159[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==17] <- 1
# tmpSD$X160[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==17] <- 1
# tmpSD$X161[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==18] <- 1
# tmpSD$X162[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==18] <- 1
# tmpSD$X163[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==18] <- 1
# tmpSD$X164[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==18] <- 1
# tmpSD$X165[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==18] <- 1
# tmpSD$X166[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==18] <- 1
# tmpSD$X167[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==18] <- 1
# tmpSD$X168[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==18] <- 1
# tmpSD$X169[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==19] <- 1
# tmpSD$X170[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==19] <- 1
# tmpSD$X171[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==19] <- 1
# tmpSD$X172[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==19] <- 1
# tmpSD$X173[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==19] <- 1
# tmpSD$X174[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==19] <- 1
# tmpSD$X175[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==19] <- 1
# tmpSD$X176[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==19] <- 1
# tmpSD$X177[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==20] <- 1
# tmpSD$X178[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==20] <- 1
# tmpSD$X179[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==20] <- 1
# tmpSD$X180[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==20] <- 1
# tmpSD$X181[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==20] <- 1
# tmpSD$X182[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==20] <- 1
# tmpSD$X183[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==20] <- 1
# tmpSD$X184[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==20] <- 1
# tmpSD$X185[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==21] <- 1
# tmpSD$X186[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==21] <- 1
# tmpSD$X187[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==21] <- 1
# tmpSD$X188[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==21] <- 1
# tmpSD$X189[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==21] <- 1
# tmpSD$X190[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==21] <- 1
# tmpSD$X191[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==21] <- 1
# tmpSD$X192[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==21] <- 1
# tmpSD$X193[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==22] <- 1
# tmpSD$X194[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==22] <- 1
# tmpSD$X195[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==22] <- 1
# tmpSD$X196[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==22] <- 1
# tmpSD$X197[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==22] <- 1
# tmpSD$X198[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==22] <- 1
# tmpSD$X199[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==22] <- 1
# tmpSD$X200[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==22] <- 1
# tmpSD$X201[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==23] <- 1
# tmpSD$X202[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==23] <- 1
# tmpSD$X203[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==23] <- 1
# tmpSD$X204[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==23] <- 1
# tmpSD$X205[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==23] <- 1
# tmpSD$X206[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==23] <- 1
# tmpSD$X207[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==23] <- 1
# tmpSD$X208[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==23] <- 1
# tmpSD$X209[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==24] <- 1
# tmpSD$X210[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==24] <- 1
# tmpSD$X211[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==24] <- 1
# tmpSD$X212[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==24] <- 1
# tmpSD$X213[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==24] <- 1
# tmpSD$X214[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==24] <- 1
# tmpSD$X215[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==24] <- 1
# tmpSD$X216[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==24] <- 1
# tmpSD$X217[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==25] <- 1
# tmpSD$X218[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==25] <- 1
# tmpSD$X219[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==25] <- 1
# tmpSD$X220[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==25] <- 1
# tmpSD$X221[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==25] <- 1
# tmpSD$X222[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==25] <- 1
# tmpSD$X223[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==25] <- 1
# tmpSD$X224[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==25] <- 1
# tmpSD$X225[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==26] <- 1
# tmpSD$X226[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==26] <- 1
# tmpSD$X227[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==26] <- 1
# tmpSD$X228[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==26] <- 1
# tmpSD$X229[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==26] <- 1
# tmpSD$X230[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==26] <- 1
# tmpSD$X231[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==26] <- 1
# tmpSD$X232[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==26] <- 1
# tmpSD$X233[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==27] <- 1
# tmpSD$X234[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==27] <- 1
# tmpSD$X235[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==27] <- 1
# tmpSD$X236[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==27] <- 1
# tmpSD$X237[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==27] <- 1
# tmpSD$X238[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==27] <- 1
# tmpSD$X239[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==27] <- 1
# tmpSD$X240[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==27] <- 1
# tmpSD$X241[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==28] <- 1
# tmpSD$X242[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==28] <- 1
# tmpSD$X243[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==28] <- 1
# tmpSD$X244[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==28] <- 1
# tmpSD$X245[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==28] <- 1
# tmpSD$X246[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==28] <- 1
# tmpSD$X247[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==28] <- 1
# tmpSD$X248[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==28] <- 1
# tmpSD$X249[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==29] <- 1
# tmpSD$X250[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==29] <- 1
# tmpSD$X251[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==29] <- 1
# tmpSD$X252[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==29] <- 1
# tmpSD$X253[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==29] <- 1
# tmpSD$X254[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==29] <- 1
# tmpSD$X255[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==29] <- 1
# tmpSD$X256[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==29] <- 1
# tmpSD$X257[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==30] <- 1
# tmpSD$X258[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==30] <- 1
# tmpSD$X259[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==30] <- 1
# tmpSD$X260[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==30] <- 1
# tmpSD$X261[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==30] <- 1
# tmpSD$X262[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==30] <- 1
# tmpSD$X263[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==30] <- 1
# tmpSD$X264[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==30] <- 1
# tmpSD$X265[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==31] <- 1
# tmpSD$X266[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==31] <- 1
# tmpSD$X267[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==31] <- 1
# tmpSD$X268[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==31] <- 1
# tmpSD$X269[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==31] <- 1
# tmpSD$X270[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==31] <- 1
# tmpSD$X271[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==31] <- 1
# tmpSD$X272[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==31] <- 1
# tmpSD$X273[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==32] <- 1
# tmpSD$X274[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==32] <- 1
# tmpSD$X275[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==32] <- 1
# tmpSD$X276[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==32] <- 1
# tmpSD$X277[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==32] <- 1
# tmpSD$X278[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==32] <- 1
# tmpSD$X279[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==32] <- 1
# tmpSD$X280[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==32] <- 1
# tmpSD$X281[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==33] <- 1
# tmpSD$X282[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==33] <- 1
# tmpSD$X283[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==33] <- 1
# tmpSD$X284[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==33] <- 1
# tmpSD$X285[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==33] <- 1
# tmpSD$X286[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==33] <- 1
# tmpSD$X287[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <= 64 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==33] <- 1
# tmpSD$X222[ tmpSD$AgeAnnee>= 65 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==33] <- 1



tmpSD$X25[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X26[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X27[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X28[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X29[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X30[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X31[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X32[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X33[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X34[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X35[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X36[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X37[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X38[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X39[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X40[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X41[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X42[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X43[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X44[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X45[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X46[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X47[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X48[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X49[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X50[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X51[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X52[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X53[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X54[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X55[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X56[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X57[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X58[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X59[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X60[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X61[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X62[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X63[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X64[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X65[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X66[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X67[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X68[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X69[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X70[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X71[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X72[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X73[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X74[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X75[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X76[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X77[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X78[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X79[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X80[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X81[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X82[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X83[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X84[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X85[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X86[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X87[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X88[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X89[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X90[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X91[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X92[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X93[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X94[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X95[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X96[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X97[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X98[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X99[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X100[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X101[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X102[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X103[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X104[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X105[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X106[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X107[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X108[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X109[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X110[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X111[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X112[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X113[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X114[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X115[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X116[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X117[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X118[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X119[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X120[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X121[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X122[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X123[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X124[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X125[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X126[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X127[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X128[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X129[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X130[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X131[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X132[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X133[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X134[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X135[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X136[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X137[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X138[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X139[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X140[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X141[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X142[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X143[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X144[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X145[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X146[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X147[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X148[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X149[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X150[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X151[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X152[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X153[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X154[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X155[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X156[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X157[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X158[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X159[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X160[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X161[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X162[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X163[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X164[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X165[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X166[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X167[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X168[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X169[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X170[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X171[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X172[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X173[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X174[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X175[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X176[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X177[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X178[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X179[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X180[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X181[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X182[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X183[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X184[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X185[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X186[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X187[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X188[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X189[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X190[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X191[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X192[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X193[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X194[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X195[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X196[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X197[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X198[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X199[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X200[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X201[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X202[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X203[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X204[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X205[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X206[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X207[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X208[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X209[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X210[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X211[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X212[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X213[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X214[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X215[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X216[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X217[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X218[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X219[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X220[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X221[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X222[ tmpSD$AgeAnnee>= 35                                         & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==33] <- 1


######################################################################################################
###  
###   STEP 2.4 - CREATE THE VARIABLE "DOMAIN" THAT IDENTIFIES THE DOMAIN OF ESTIMATION   
### 
######################################################################################################

tmpSD$DOMAIN <- as.character(1)


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




######################################################################################################
###  
###   STEP 2.7 - CREATE THE R DATAFRAME WITH THE SAMPLE DATA THAT ARE USED AS FIRST INPUT BY REGENESEES  
### 
######################################################################################################


### We can create the R dataframe with the sample data 
### keeping only the variables needed for weighting and to calculate Precision


list_of_X  <- paste(rep("X",222),seq(1,222),sep="")
#list_of_X  <- paste(rep("X",xnum),seq(1,xnum),sep="")
list_of_X



LFS_SAMPLE_DATA <- tmpSD[,c("DOMAIN", names(tmpSD))]

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

save(LFS_SAMPLE_DATA, file="LFS_SAMPLE_DATA_2024_T4_222X_1D_ALLWR_np.RData")


### If we have not set the working directory for the outputs (or we need to save the object in a different folder) we can use 

# save(LFS_SAMPLE_DATA ,file='D:/DOCUMENTS/CAE/Calibration/Applications ENEM/DATA/QUARTERLY_WEIGHTING/2024/T4/222X_1D_ALLWR_np//LFS_SAMPLE_DATA_2024_T4_222X_1D_ALLWR_np.RData')



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

View(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE)


###   Save permanently the object in the destination folder  
###   If we have set the working directory for the outputs we can use 

save(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE, file="LFS_SAMPLE_DATA_2024_T4_222X_1D_ALLWR_np_SUMMARY_OF_Xs_SAMPLE_SIZE.RData")


###   Save the results in an excel file using the package "writexl"

write_xlsx(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE,
          "LFS_SAMPLE_DATA_2024_T4_222X_1D_ALLWR_np_SUMMARY_OF_Xs_SAMPLE_SIZE.xlsx" )



######################################################################################################
###  
###   STEP 2.11 - SUMMARIZE BY DOMAIN TO SAVE IN A DATAFRAME THE ESTIMATES OBTAINED USING THE DESIGN WEIGHT
###  
######################################################################################################


### Create a table (stored in the object "LFS_SAMPLE_DATA_2024_T4_222X_1D_ALLWR_np_SUMMARY_OF_Xs_EST_DES_WEIGHT" ). 
### Now, we need to weight the X

LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT <-
  LFS_SAMPLE_DATA  %>%
  tab_cols(mdset(X1 %to% X222),total()) %>%
  tab_rows(DOMAIN, total()) %>%
  tab_weight(poids_menage) %>%
  tab_stat_sum %>%
  tab_pivot() %>%
  as.data.frame()

View(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT)


###   Save permanently the object in the destination folder  
###   If we have set the working directory for the outputs we can use 

save(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT, file="LFS_SAMPLE_DATA_2024_T4_222X_1D_ALLWR_np_SUMMARY_OF_Xs_EST_DES_WEIGHT.RData")


###   Save the results in an excel file



write_xlsx(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT,
          "LFS_SAMPLE_DATA_2024_T4_222X_1D_ALLWR_np_SUMMARY_OF_Xs_EST_DES_WEIGHT.xlsx" )


