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
########                                        R Script 02                                                     ########.
########                                                                                                        ########.
########        PROGRAM TO PREPARE INPUT SAMPLE DATA FOR FINAL CALIBRATION USING REGENESEES                     ########.
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
###   STEP 2.1 - SET THE WORKING DIRECTORY WHERE THE OUPUTS OF THE CALIBRATION PROCESS WILL BE STORED 
### 
######################################################################################################

getwd()
setwd(dir_data_QW)
getwd()


######################################################################################################
###  
###   STEP 2.2 - LOAD THE INPUT DATAFRAME CONTAINING THE SAMPLE DATA FROM FOLDER 550  
### 
######################################################################################################

load( file = FILE_LFS_ILO_DER_RDATA )

ls()


### check its the structure

str(LFS_ILO_DER)


### Create a new dataframe that will be renamed at the end of the steps as LFS_SAMPLE_DATA_2021_Q1_52X_4D_ALLWR_np
### Working on the new dataframe will help to avoid possible unwanted modifications/errors on the original dataset.
### The shorter name will help when we have to write the code. The prefix tmp will help to recognize that is a temporary
### dataframe that does not need to be saved permanently on disk  

tmpSD <- LFS_ILO_DER

head(tmpSD)


######################################################################################################
###  
###   STEP 2.3 - CREATE THE VARIABLE "DOMAIN" THAT IDENTIFIES THE DOMAINS OF ESTIMATION   
### 
######################################################################################################

tmpSD$DOMAIN <- as.character(tmpSD$HH2)


######################################################################################################
###  
###   STEP 2.4 - CALCULATE THE SET OF 52 X VARIABLES (DUMMY 0,1)  
### 
######################################################################################################


###   Create the 94 X variables and initialize them to 0
###   We can use the function "cbind" to attach them to the current dataframe

# tmpSD <- cbind( tmpSD , data.frame(matrix(0 , nrow = nrow(tmpSD), ncol =  136, byrow = FALSE)))
tmpSD <- cbind( tmpSD , data.frame(matrix(0 , nrow = nrow(tmpSD), ncol =  xnum, byrow = FALSE)))

###   CREATE AN OBJECT CONTAING THE LIST OF Xs TO RETAIN TO BE USED IN THE NEXT STEPS  

# list_of_X  <- paste(rep("X",136),seq(1,136),sep="")
list_of_X  <- paste(rep("X",xnum),seq(1,xnum),sep="")
list_of_X 


###    For each record of the dataset, the following code will assign 1 to the X variables based on the specific conditions  

# NATIONAL LEVEL - MALE BY URBAN LOCATION AND 12 AGE GROUP

tmpSD$X1[ tmpSD$AgeAnnee>=  0 & tmpSD$AgeAnnee <=14 & tmpSD$HH6==1 & tmpSD$M5==1]<- 1
tmpSD$X2[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <=19 & tmpSD$HH6==1 & tmpSD$M5==1]<- 1
tmpSD$X3[ tmpSD$AgeAnnee>= 20 & tmpSD$AgeAnnee <=24 & tmpSD$HH6==1 & tmpSD$M5==1]<- 1
tmpSD$X4[ tmpSD$AgeAnnee>= 25 & tmpSD$AgeAnnee <=29 & tmpSD$HH6==1 & tmpSD$M5==1]<- 1
tmpSD$X5[ tmpSD$AgeAnnee>= 30 & tmpSD$AgeAnnee <=34 & tmpSD$HH6==1 & tmpSD$M5==1]<- 1
tmpSD$X6[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <=39 & tmpSD$HH6==1 & tmpSD$M5==1]<- 1
tmpSD$X7[ tmpSD$AgeAnnee>= 40 & tmpSD$AgeAnnee <=44 & tmpSD$HH6==1 & tmpSD$M5==1]<- 1
tmpSD$X8[ tmpSD$AgeAnnee>= 45 & tmpSD$AgeAnnee <=49 & tmpSD$HH6==1 & tmpSD$M5==1]<- 1
tmpSD$X9[ tmpSD$AgeAnnee>= 50 & tmpSD$AgeAnnee <=54 & tmpSD$HH6==1 & tmpSD$M5==1]<- 1
tmpSD$X10[tmpSD$AgeAnnee>= 55 & tmpSD$AgeAnnee <=59 & tmpSD$HH6==1 & tmpSD$M5==1]<- 1
tmpSD$X11[tmpSD$AgeAnnee>= 60 & tmpSD$AgeAnnee <=64 & tmpSD$HH6==1 & tmpSD$M5==1]<- 1
tmpSD$X12[tmpSD$AgeAnnee>= 65                  & tmpSD$HH6==1 & tmpSD$M5==1]<- 1


# NATIONAL LEVEL - MALE BY RURAL LOCATION AND 12 AGE GROUP

tmpSD$X13[ tmpSD$AgeAnnee>=  0 & tmpSD$AgeAnnee <=14 & tmpSD$HH6==2 & tmpSD$M5==1]<- 1
tmpSD$X14[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <=19 & tmpSD$HH6==2 & tmpSD$M5==1]<- 1
tmpSD$X15[ tmpSD$AgeAnnee>= 20 & tmpSD$AgeAnnee <=24 & tmpSD$HH6==2 & tmpSD$M5==1]<- 1
tmpSD$X16[ tmpSD$AgeAnnee>= 25 & tmpSD$AgeAnnee <=29 & tmpSD$HH6==2 & tmpSD$M5==1]<- 1
tmpSD$X17[ tmpSD$AgeAnnee>= 30 & tmpSD$AgeAnnee <=34 & tmpSD$HH6==2 & tmpSD$M5==1]<- 1
tmpSD$X18[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <=39 & tmpSD$HH6==2 & tmpSD$M5==1]<- 1
tmpSD$X19[ tmpSD$AgeAnnee>= 40 & tmpSD$AgeAnnee <=44 & tmpSD$HH6==2 & tmpSD$M5==1]<- 1
tmpSD$X20[ tmpSD$AgeAnnee>= 45 & tmpSD$AgeAnnee <=49 & tmpSD$HH6==2 & tmpSD$M5==1]<- 1
tmpSD$X21[ tmpSD$AgeAnnee>= 50 & tmpSD$AgeAnnee <=54 & tmpSD$HH6==2 & tmpSD$M5==1]<- 1
tmpSD$X22[tmpSD$AgeAnnee>= 55 & tmpSD$AgeAnnee <=59 & tmpSD$HH6==2 & tmpSD$M5==1]<- 1
tmpSD$X23[tmpSD$AgeAnnee>= 60 & tmpSD$AgeAnnee <=64 & tmpSD$HH6==2 & tmpSD$M5==1]<- 1
tmpSD$X24[tmpSD$AgeAnnee>= 65                  & tmpSD$HH6==2 & tmpSD$M5==1]<- 1



# NATIONAL LEVEL - FEMALE BY URBAN LOCATION AND 12 AGE GROUP

tmpSD$X25[ tmpSD$AgeAnnee>=  0 & tmpSD$AgeAnnee <=14 & tmpSD$HH6==1 & tmpSD$M5==2]<- 1
tmpSD$X26[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <=19 & tmpSD$HH6==1 & tmpSD$M5==2]<- 1
tmpSD$X27[ tmpSD$AgeAnnee>= 20 & tmpSD$AgeAnnee <=24 & tmpSD$HH6==1 & tmpSD$M5==2]<- 1
tmpSD$X28[ tmpSD$AgeAnnee>= 25 & tmpSD$AgeAnnee <=29 & tmpSD$HH6==1 & tmpSD$M5==2]<- 1
tmpSD$X29[ tmpSD$AgeAnnee>= 30 & tmpSD$AgeAnnee <=34 & tmpSD$HH6==1 & tmpSD$M5==2]<- 1
tmpSD$X30[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <=39 & tmpSD$HH6==1 & tmpSD$M5==2]<- 1
tmpSD$X31[ tmpSD$AgeAnnee>= 40 & tmpSD$AgeAnnee <=44 & tmpSD$HH6==1 & tmpSD$M5==2]<- 1
tmpSD$X32[ tmpSD$AgeAnnee>= 45 & tmpSD$AgeAnnee <=49 & tmpSD$HH6==1 & tmpSD$M5==2]<- 1
tmpSD$X33[ tmpSD$AgeAnnee>= 50 & tmpSD$AgeAnnee <=54 & tmpSD$HH6==1 & tmpSD$M5==2]<- 1
tmpSD$X34[tmpSD$AgeAnnee>= 55 & tmpSD$AgeAnnee <=59 & tmpSD$HH6==1 & tmpSD$M5==2]<- 1
tmpSD$X35[tmpSD$AgeAnnee>= 60 & tmpSD$AgeAnnee <=64 & tmpSD$HH6==1 & tmpSD$M5==2]<- 1
tmpSD$X36[tmpSD$AgeAnnee>= 65                  & tmpSD$HH6==1 & tmpSD$M5==2]<- 1


# NATIONAL LEVEL - FEMALE BY RURAL LOCATION AND 12 AGE GROUP


tmpSD$X37[ tmpSD$AgeAnnee>=  0 & tmpSD$AgeAnnee <=14 & tmpSD$HH6==2 & tmpSD$M5==2]<- 1
tmpSD$X38[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <=19 & tmpSD$HH6==2 & tmpSD$M5==2]<- 1
tmpSD$X39[ tmpSD$AgeAnnee>= 20 & tmpSD$AgeAnnee <=24 & tmpSD$HH6==2 & tmpSD$M5==2]<- 1
tmpSD$X40[ tmpSD$AgeAnnee>= 25 & tmpSD$AgeAnnee <=29 & tmpSD$HH6==2 & tmpSD$M5==2]<- 1
tmpSD$X41[ tmpSD$AgeAnnee>= 30 & tmpSD$AgeAnnee <=34 & tmpSD$HH6==2 & tmpSD$M5==2]<- 1
tmpSD$X42[ tmpSD$AgeAnnee>= 35 & tmpSD$AgeAnnee <=39 & tmpSD$HH6==2 & tmpSD$M5==2]<- 1
tmpSD$X43[ tmpSD$AgeAnnee>= 40 & tmpSD$AgeAnnee <=44 & tmpSD$HH6==2 & tmpSD$M5==2]<- 1
tmpSD$X44[ tmpSD$AgeAnnee>= 45 & tmpSD$AgeAnnee <=49 & tmpSD$HH6==2 & tmpSD$M5==2]<- 1
tmpSD$X45[ tmpSD$AgeAnnee>= 50 & tmpSD$AgeAnnee <=54 & tmpSD$HH6==2 & tmpSD$M5==2]<- 1
tmpSD$X46[tmpSD$AgeAnnee>= 55 & tmpSD$AgeAnnee <=59 & tmpSD$HH6==2 & tmpSD$M5==2]<- 1
tmpSD$X47[tmpSD$AgeAnnee>= 60 & tmpSD$AgeAnnee <=64 & tmpSD$HH6==2 & tmpSD$M5==2]<- 1
tmpSD$X48[tmpSD$AgeAnnee>= 65                  & tmpSD$HH6==2 & tmpSD$M5==2]<- 1


# REGION BY SEX BY URBAN_RURAL LOCATION AND 3 AGE GROUP

tmpSD$X49[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X50[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X51[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X52[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X53[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X54[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X55[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X56[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X57[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X58[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X59[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X60[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X61[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X62[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X63[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X64[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X65[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X66[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X67[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X68[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X69[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X70[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X71[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X72[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X73[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X74[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X75[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X76[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X77[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X78[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X79[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X80[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X81[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X82[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X83[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X84[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X85[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X86[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X87[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X88[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X89[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X90[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X91[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X92[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X93[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X94[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X95[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X96[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X97[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X98[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X99[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X100[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X101[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X102[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X103[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X104[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X105[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X106[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X107[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X108[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X109[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X110[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X111[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X112[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X113[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X114[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X115[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X116[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X117[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X118[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X119[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X120[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X121[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X122[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X123[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X124[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X125[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X126[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X127[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X128[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X129[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X130[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X131[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X132[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X133[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X134[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X135[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X136[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X137[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X138[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X139[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X140[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X141[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X142[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X143[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X144[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X145[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X146[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X147[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X148[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X149[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X150[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X151[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X152[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X153[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X154[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X155[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X156[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X157[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X158[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X159[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X160[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X161[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X162[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X163[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X164[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X165[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X166[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X167[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X168[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X169[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X170[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X171[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X172[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X173[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X174[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X175[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X176[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X177[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X178[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X179[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X180[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X181[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X182[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X183[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X184[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X185[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X186[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X187[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X188[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X189[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X190[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X191[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X192[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X193[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X194[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X195[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X196[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X197[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X198[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X199[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X200[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X201[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X202[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X203[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X204[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X205[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X206[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X207[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X208[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X209[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X210[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X211[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X212[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X213[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X214[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X215[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X216[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X217[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X218[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X219[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X220[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X221[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X222[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X223[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X224[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X225[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X226[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X227[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X228[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X229[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X230[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X231[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X232[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X233[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X234[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X235[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X236[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X237[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X238[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X239[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X240[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X241[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X242[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X243[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X244[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X245[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X246[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 1 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X247[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X248[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X249[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X250[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X251[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X252[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==1] <- 1
tmpSD$X253[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X254[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X255[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X256[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X257[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X258[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==2] <- 1
tmpSD$X259[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X260[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X261[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X262[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X263[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X264[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==3] <- 1
tmpSD$X265[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X266[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X267[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X268[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X269[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X270[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==4] <- 1
tmpSD$X271[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X272[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X273[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X274[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X275[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X276[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==5] <- 1
tmpSD$X277[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X278[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X279[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X280[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X281[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X282[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==6] <- 1
tmpSD$X283[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X284[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X285[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X286[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X287[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X288[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==7] <- 1
tmpSD$X289[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X290[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X291[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X292[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X293[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X294[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==8] <- 1
tmpSD$X295[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X296[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X297[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X298[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X299[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X300[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==9] <- 1
tmpSD$X301[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X302[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X303[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X304[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X305[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X306[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==10] <- 1
tmpSD$X307[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X308[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X309[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X310[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X311[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X312[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==11] <- 1
tmpSD$X313[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X314[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X315[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X316[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X317[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X318[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==12] <- 1
tmpSD$X319[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X320[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X321[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X322[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X323[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X324[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==13] <- 1
tmpSD$X325[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X326[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X327[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X328[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X329[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X330[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==14] <- 1
tmpSD$X331[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X332[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X333[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X334[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X335[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X336[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==15] <- 1
tmpSD$X337[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X338[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X339[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X340[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X341[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X342[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==16] <- 1
tmpSD$X343[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X344[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X345[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X346[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X347[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X348[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==17] <- 1
tmpSD$X349[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X350[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X351[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X352[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X353[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X354[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==18] <- 1
tmpSD$X355[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X356[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X357[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X358[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X359[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X360[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==19] <- 1
tmpSD$X361[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X362[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X363[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X364[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X365[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X366[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==20] <- 1
tmpSD$X367[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X368[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X369[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X370[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X371[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X372[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==21] <- 1
tmpSD$X373[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X374[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X375[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X376[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X377[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X378[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==22] <- 1
tmpSD$X379[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X380[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X381[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X382[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X383[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X384[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==23] <- 1
tmpSD$X385[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X386[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X387[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X388[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X389[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X390[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==24] <- 1
tmpSD$X391[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X392[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X393[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X394[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X395[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X396[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==25] <- 1
tmpSD$X397[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X398[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X399[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X400[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X401[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X402[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==26] <- 1
tmpSD$X403[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X404[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X405[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X406[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X407[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X408[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==27] <- 1
tmpSD$X409[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X410[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X411[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X412[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X413[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X414[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==28] <- 1
tmpSD$X415[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X416[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X417[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X418[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X419[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X420[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==29] <- 1
tmpSD$X421[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X422[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X423[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X424[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X425[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X426[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==30] <- 1
tmpSD$X427[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X428[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X429[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X430[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X431[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X432[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==31] <- 1
tmpSD$X433[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X434[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X435[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X436[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X437[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X438[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==32] <- 1
tmpSD$X439[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X440[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X441[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 1 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X442[ tmpSD$AgeAnnee>= 0 & tmpSD$AgeAnnee <= 14 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X443[ tmpSD$AgeAnnee>= 15 & tmpSD$AgeAnnee <= 34 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==33] <- 1
tmpSD$X444[ tmpSD$AgeAnnee>= 35 & tmpSD$HH6== 2 & tmpSD$M5== 2 & tmpSD$OFFICIEL_CodReg==33] <- 1




######################################################################################################
###  
###   STEP 2.5 - CREATE THE DUMMY VARIABLES NEEDED TO CALCULATE THE MAIN LFS INDICATORS AND THEIR PRECISION  
### 
######################################################################################################


###   Respondents in working age 15 plus   

# tmpSD$POP_15plus <- 0
# tmpSD$POP_15plus[tmpSD$AGE>=15] <- 1


###   Respondents in Labour Force

# tmpSD$LF_15plus <- 0
# tmpSD$LF_15plus[tmpSD$AGE>=15 & (tmpSD$ilo_lfs==1 | tmpSD$ilo_lfs==2 ) ] <- 1
# 
# tmpSD$LF_15plus_100 <- tmpSD$LF_15plus * 100 

###   Respondents in Employment

# tmpSD$EMP_15plus <- 0
# tmpSD$EMP_15plus[tmpSD$AGE>=15 & tmpSD$ilo_lfs==1 ] <- 1
# 
# tmpSD$EMP_15plus_100 <- tmpSD$EMP_15plus * 100

###   Respondents in Unemployment

# tmpSD$UNE_15plus <- 0
# tmpSD$UNE_15plus[tmpSD$AGE>=15 & tmpSD$ilo_lfs==2 ] <- 1
# 
# tmpSD$UNE_15plus_100  <- tmpSD$UNE_15plus * 100
# 
# names(tmpSD)


######################################################################################################
###  
###   STEP 2.7 - CREATE THE R DATAFRAME WITH THE SAMPLE DATA THAT ARE USED AS FIRST INPUT BY REGENESEES  
### 
######################################################################################################


tmpSD$DOMAIN <- as.character(1)

### We can create the R dataframe with the sample data 
### keeping only the variables needed for weighting and to calculate Precision

LFS_SAMPLE_DATA <- tmpSD[,c("HH2", "HH6", "DOMAIN", "STRATAKEY", "PSUKEY", "HHKEY", "INDKEY", 
                            "M5", list_of_X, "poids_menage")]

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

save( LFS_SAMPLE_DATA, file = FILE_LFS_SAMPLE_DATA_RDATA )



######################################################################################################
###  
###   STEP 2.9 - CHECK THE POPULATION ESTIMATES OBTAINED USING THE DESIGN WEIGHT   
### 
######################################################################################################


### Create a table using the package "expss" 
### and the magritte %>% pipe operators (see https://magrittr.tidyverse.org/reference/pipe.html)

LFS_SAMPLE_DATA  %>%
  tab_cols(M5, HH6, total()) %>%
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


LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE <- aggregate(   x = LFS_SAMPLE_DATA[, list_of_X], 
                                                         by = list(DOMAIN = LFS_SAMPLE_DATA$DOMAIN), 
                                                        FUN = sum)

#  View(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE)



###   Save permanently the object in the destination folder  
###   If we have set the working directory for the outputs we can use 

#save( LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE , file = "LFS_SAMPLE_DATA_2021_Q1_94X_4D_ALLWR_np_SUMMARY_OF_Xs_SAMPLE_SIZE.RData")
save( LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE , file = FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE_RDATA)
                                                  
###   Save the results in an excel file using the package "writexl"

# write_xlsx(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE, "LFS_SAMPLE_DATA_2021_Q1_94X_4D_ALLWR_np_SUMMARY_OF_Xs_SAMPLE_SIZE.xlsx" )
write_xlsx(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE, FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE_XLSX )
                                                             


######################################################################################################
###  
###   STEP 2.11 - SUMMARIZE BY DOMAIN TO SAVE IN A DATAFRAME THE ESTIMATES OBTAINED USING THE DESIGN WEIGHT
###  
######################################################################################################


### Create a table (stored in the object "LFS_SAMPLE_DATA_2021_Q1_94X_4D_ALLWR_np_SUMMARY_OF_Xs_EST_DES_WEIGHT" ). 
### Now, we need to weight the X


### the following is a version that is not parameterised (last X is X136 ). 

# LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT <-
#   LFS_SAMPLE_DATA  %>%
#   tab_cols(mdset(X1 %to% X136),total()) %>%
#   tab_rows(DOMAIN, total()) %>%
#   tab_weight(DESIGN_WEIGHT) %>%
#   tab_stat_sum %>%
#   tab_pivot() %>%
#   as.data.frame()



### here below is a version that is parameterised (last X is taken from the parameter 'xnum' ). 

last_X <- paste0('X',xnum)
last_X

LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT <-
  LFS_SAMPLE_DATA  %>%
  tab_cols(mdset(X1 %to% get("last_X")),total()) %>%
  tab_rows(DOMAIN, total()) %>%
  tab_weight(poids_menage) %>%
  tab_stat_sum %>%
  tab_pivot() %>%
  as.data.frame()


View(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT)


###   Save permanently the object in the destination folder  
###   If we have set the working directory for the outputs we can use 

# save(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT, file="LFS_SAMPLE_DATA_2021_Q1_94X_4D_ALLWR_np_SUMMARY_OF_Xs_EST_DES_WEIGHT.RData")
save(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT, file=FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT_RDATA)


###   Save the results in an excel file

#write_xlsx(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT, "LFS_SAMPLE_DATA_2021_Q1_94X_4D_ALLWR_np_SUMMARY_OF_Xs_EST_DES_WEIGHT.xlsx" )
write_xlsx(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT, FILE_LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT_XLSX )


######################################################################################################
###  
###   STEP 2.13 - CHECK TOTAL POPULATION ESTIMATES USING DESIGN WEIGHTS
###
######################################################################################################

###   We can calculate the total population summing the X values of the first subset of X
###   notice that X1 is the second column in the dataframe, hence X24 is the 25th column

sum(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT[1,seq(2,49)],na.rm = TRUE)

###   We can calculate the total population summing the X values of the second subset of X

sum(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT[1,seq(50,61)],na.rm = TRUE)


###   We can calculate the total population summing the X values of the third subset of X

# sum(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT[seq(1,4),seq(54,95)],na.rm = TRUE)

###   We can calculate the total population summing the X values of the fourth subset of X

# sum(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT[seq(1,4),seq(96,137)],na.rm = TRUE)


### VISUALIZE THE OUTPUTS PRODUCED BY THIS STEP

View(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT)

View(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE)
