########################################################################################################################.
########################################################################################################################.
########################################################################################################################.
########                                                                                                        ########.
########           TRAINING ON STRATEGIES TO CALCULATE LFS SAMPLE WEIGHTS USING CALIBRATIONS                    ########.
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
########                                        R Script 02                                                     ########.
########                                                                                                        ########.
########        PROGRAM TO PREPARE INPUT SAMPLE DATA FOR FINAL CALIBRATION USING REGENESEES                     ########.
########                                                                                                        ########.
########        1 DOMAINS  (33 Regions)                                                                         ########.
########        312 CONSTRAINTS (X1 TO X312)                                                                    ########.
########              - Population by sex and urban and rural and 12 age groups    (X1 TO X48)                  ########.
########              - Population by region, urban and rural, sex and 2 age groups  (X49 TO X312)              ########.    
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

tmpSD$DOMAIN <- as.character(tmpSD$hh2)


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

tmpSD$X1[ tmpSD$ageannee>=  0 & tmpSD$ageannee <=14 & tmpSD$milieu==1 & tmpSD$m5==1]<- 1
tmpSD$X2[ tmpSD$ageannee>= 15 & tmpSD$ageannee <=19 & tmpSD$milieu==1 & tmpSD$m5==1]<- 1
tmpSD$X3[ tmpSD$ageannee>= 20 & tmpSD$ageannee <=24 & tmpSD$milieu==1 & tmpSD$m5==1]<- 1
tmpSD$X4[ tmpSD$ageannee>= 25 & tmpSD$ageannee <=29 & tmpSD$milieu==1 & tmpSD$m5==1]<- 1
tmpSD$X5[ tmpSD$ageannee>= 30 & tmpSD$ageannee <=34 & tmpSD$milieu==1 & tmpSD$m5==1]<- 1
tmpSD$X6[ tmpSD$ageannee>= 35 & tmpSD$ageannee <=39 & tmpSD$milieu==1 & tmpSD$m5==1]<- 1
tmpSD$X7[ tmpSD$ageannee>= 40 & tmpSD$ageannee <=44 & tmpSD$milieu==1 & tmpSD$m5==1]<- 1
tmpSD$X8[ tmpSD$ageannee>= 45 & tmpSD$ageannee <=49 & tmpSD$milieu==1 & tmpSD$m5==1]<- 1
tmpSD$X9[ tmpSD$ageannee>= 50 & tmpSD$ageannee <=54 & tmpSD$milieu==1 & tmpSD$m5==1]<- 1
tmpSD$X10[tmpSD$ageannee>= 55 & tmpSD$ageannee <=59 & tmpSD$milieu==1 & tmpSD$m5==1]<- 1
tmpSD$X11[tmpSD$ageannee>= 60 & tmpSD$ageannee <=64 & tmpSD$milieu==1 & tmpSD$m5==1]<- 1
tmpSD$X12[tmpSD$ageannee>= 65                  & tmpSD$milieu==1 & tmpSD$m5==1]<- 1


# NATIONAL LEVEL - MALE BY RURAL LOCATION AND 12 AGE GROUP

tmpSD$X13[ tmpSD$ageannee>=  0 & tmpSD$ageannee <=14 & tmpSD$milieu==2 & tmpSD$m5==1]<- 1
tmpSD$X14[ tmpSD$ageannee>= 15 & tmpSD$ageannee <=19 & tmpSD$milieu==2 & tmpSD$m5==1]<- 1
tmpSD$X15[ tmpSD$ageannee>= 20 & tmpSD$ageannee <=24 & tmpSD$milieu==2 & tmpSD$m5==1]<- 1
tmpSD$X16[ tmpSD$ageannee>= 25 & tmpSD$ageannee <=29 & tmpSD$milieu==2 & tmpSD$m5==1]<- 1
tmpSD$X17[ tmpSD$ageannee>= 30 & tmpSD$ageannee <=34 & tmpSD$milieu==2 & tmpSD$m5==1]<- 1
tmpSD$X18[ tmpSD$ageannee>= 35 & tmpSD$ageannee <=39 & tmpSD$milieu==2 & tmpSD$m5==1]<- 1
tmpSD$X19[ tmpSD$ageannee>= 40 & tmpSD$ageannee <=44 & tmpSD$milieu==2 & tmpSD$m5==1]<- 1
tmpSD$X20[ tmpSD$ageannee>= 45 & tmpSD$ageannee <=49 & tmpSD$milieu==2 & tmpSD$m5==1]<- 1
tmpSD$X21[ tmpSD$ageannee>= 50 & tmpSD$ageannee <=54 & tmpSD$milieu==2 & tmpSD$m5==1]<- 1
tmpSD$X22[tmpSD$ageannee>= 55 & tmpSD$ageannee <=59 & tmpSD$milieu==2 & tmpSD$m5==1]<- 1
tmpSD$X23[tmpSD$ageannee>= 60 & tmpSD$ageannee <=64 & tmpSD$milieu==2 & tmpSD$m5==1]<- 1
tmpSD$X24[tmpSD$ageannee>= 65                  & tmpSD$milieu==2 & tmpSD$m5==1]<- 1



# NATIONAL LEVEL - FEMALE BY URBAN LOCATION AND 12 AGE GROUP

tmpSD$X25[ tmpSD$ageannee>=  0 & tmpSD$ageannee <=14 & tmpSD$milieu==1 & tmpSD$m5==2]<- 1
tmpSD$X26[ tmpSD$ageannee>= 15 & tmpSD$ageannee <=19 & tmpSD$milieu==1 & tmpSD$m5==2]<- 1
tmpSD$X27[ tmpSD$ageannee>= 20 & tmpSD$ageannee <=24 & tmpSD$milieu==1 & tmpSD$m5==2]<- 1
tmpSD$X28[ tmpSD$ageannee>= 25 & tmpSD$ageannee <=29 & tmpSD$milieu==1 & tmpSD$m5==2]<- 1
tmpSD$X29[ tmpSD$ageannee>= 30 & tmpSD$ageannee <=34 & tmpSD$milieu==1 & tmpSD$m5==2]<- 1
tmpSD$X30[ tmpSD$ageannee>= 35 & tmpSD$ageannee <=39 & tmpSD$milieu==1 & tmpSD$m5==2]<- 1
tmpSD$X31[ tmpSD$ageannee>= 40 & tmpSD$ageannee <=44 & tmpSD$milieu==1 & tmpSD$m5==2]<- 1
tmpSD$X32[ tmpSD$ageannee>= 45 & tmpSD$ageannee <=49 & tmpSD$milieu==1 & tmpSD$m5==2]<- 1
tmpSD$X33[ tmpSD$ageannee>= 50 & tmpSD$ageannee <=54 & tmpSD$milieu==1 & tmpSD$m5==2]<- 1
tmpSD$X34[tmpSD$ageannee>= 55 & tmpSD$ageannee <=59 & tmpSD$milieu==1 & tmpSD$m5==2]<- 1
tmpSD$X35[tmpSD$ageannee>= 60 & tmpSD$ageannee <=64 & tmpSD$milieu==1 & tmpSD$m5==2]<- 1
tmpSD$X36[tmpSD$ageannee>= 65                  & tmpSD$milieu==1 & tmpSD$m5==2]<- 1


# NATIONAL LEVEL - FEMALE BY RURAL LOCATION AND 12 AGE GROUP


tmpSD$X37[ tmpSD$ageannee>=  0 & tmpSD$ageannee <=14 & tmpSD$milieu==2 & tmpSD$m5==2]<- 1
tmpSD$X38[ tmpSD$ageannee>= 15 & tmpSD$ageannee <=19 & tmpSD$milieu==2 & tmpSD$m5==2]<- 1
tmpSD$X39[ tmpSD$ageannee>= 20 & tmpSD$ageannee <=24 & tmpSD$milieu==2 & tmpSD$m5==2]<- 1
tmpSD$X40[ tmpSD$ageannee>= 25 & tmpSD$ageannee <=29 & tmpSD$milieu==2 & tmpSD$m5==2]<- 1
tmpSD$X41[ tmpSD$ageannee>= 30 & tmpSD$ageannee <=34 & tmpSD$milieu==2 & tmpSD$m5==2]<- 1
tmpSD$X42[ tmpSD$ageannee>= 35 & tmpSD$ageannee <=39 & tmpSD$milieu==2 & tmpSD$m5==2]<- 1
tmpSD$X43[ tmpSD$ageannee>= 40 & tmpSD$ageannee <=44 & tmpSD$milieu==2 & tmpSD$m5==2]<- 1
tmpSD$X44[ tmpSD$ageannee>= 45 & tmpSD$ageannee <=49 & tmpSD$milieu==2 & tmpSD$m5==2]<- 1
tmpSD$X45[ tmpSD$ageannee>= 50 & tmpSD$ageannee <=54 & tmpSD$milieu==2 & tmpSD$m5==2]<- 1
tmpSD$X46[tmpSD$ageannee>= 55 & tmpSD$ageannee <=59 & tmpSD$milieu==2 & tmpSD$m5==2]<- 1
tmpSD$X47[tmpSD$ageannee>= 60 & tmpSD$ageannee <=64 & tmpSD$milieu==2 & tmpSD$m5==2]<- 1
tmpSD$X48[tmpSD$ageannee>= 65                  & tmpSD$milieu==2 & tmpSD$m5==2]<- 1


# REGION BY SEX BY URBAN_RURAL LOCATION AND 2 AGE GROUP

tmpSD$X49[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==1] <- 1
tmpSD$X50[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==1] <- 1
tmpSD$X51[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==1] <- 1
tmpSD$X52[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==1] <- 1
tmpSD$X53[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==2] <- 1
tmpSD$X54[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==2] <- 1
tmpSD$X55[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==2] <- 1
tmpSD$X56[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==2] <- 1
tmpSD$X57[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==3] <- 1
tmpSD$X58[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==3] <- 1
tmpSD$X59[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==3] <- 1
tmpSD$X60[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==3] <- 1
tmpSD$X61[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==4] <- 1
tmpSD$X62[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==4] <- 1
tmpSD$X63[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==4] <- 1
tmpSD$X64[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==4] <- 1
tmpSD$X65[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==5] <- 1
tmpSD$X66[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==5] <- 1
tmpSD$X67[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==5] <- 1
tmpSD$X68[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==5] <- 1
tmpSD$X69[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==6] <- 1
tmpSD$X70[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==6] <- 1
tmpSD$X71[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==6] <- 1
tmpSD$X72[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==6] <- 1
tmpSD$X73[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==7] <- 1
tmpSD$X74[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==7] <- 1
tmpSD$X75[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==7] <- 1
tmpSD$X76[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==7] <- 1
tmpSD$X77[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==8] <- 1
tmpSD$X78[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==8] <- 1
tmpSD$X79[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==8] <- 1
tmpSD$X80[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==8] <- 1
tmpSD$X81[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==9] <- 1
tmpSD$X82[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==9] <- 1
tmpSD$X83[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==9] <- 1
tmpSD$X84[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==9] <- 1
tmpSD$X85[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==10] <- 1
tmpSD$X86[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==10] <- 1
tmpSD$X87[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==10] <- 1
tmpSD$X88[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==10] <- 1
tmpSD$X89[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==11] <- 1
tmpSD$X90[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==11] <- 1
tmpSD$X91[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==11] <- 1
tmpSD$X92[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==11] <- 1
tmpSD$X93[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==12] <- 1
tmpSD$X94[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==12] <- 1
tmpSD$X95[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==12] <- 1
tmpSD$X96[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==12] <- 1
tmpSD$X97[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==13] <- 1
tmpSD$X98[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==13] <- 1
tmpSD$X99[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==13] <- 1
tmpSD$X100[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==13] <- 1
tmpSD$X101[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==14] <- 1
tmpSD$X102[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==14] <- 1
tmpSD$X103[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==14] <- 1
tmpSD$X104[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==14] <- 1
tmpSD$X105[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==15] <- 1
tmpSD$X106[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==15] <- 1
tmpSD$X107[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==15] <- 1
tmpSD$X108[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==15] <- 1
tmpSD$X109[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==16] <- 1
tmpSD$X110[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==16] <- 1
tmpSD$X111[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==16] <- 1
tmpSD$X112[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==16] <- 1
tmpSD$X113[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==17] <- 1
tmpSD$X114[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==17] <- 1
tmpSD$X115[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==17] <- 1
tmpSD$X116[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==17] <- 1
tmpSD$X117[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==18] <- 1
tmpSD$X118[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==18] <- 1
tmpSD$X119[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==18] <- 1
tmpSD$X120[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==18] <- 1
tmpSD$X121[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==19] <- 1
tmpSD$X122[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==19] <- 1
tmpSD$X123[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==19] <- 1
tmpSD$X124[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==19] <- 1
tmpSD$X125[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==20] <- 1
tmpSD$X126[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==20] <- 1
tmpSD$X127[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==20] <- 1
tmpSD$X128[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==20] <- 1
tmpSD$X129[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==21] <- 1
tmpSD$X130[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==21] <- 1
tmpSD$X131[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==21] <- 1
tmpSD$X132[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==21] <- 1
tmpSD$X133[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==22] <- 1
tmpSD$X134[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==22] <- 1
tmpSD$X135[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==22] <- 1
tmpSD$X136[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==22] <- 1
tmpSD$X137[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==23] <- 1
tmpSD$X138[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==23] <- 1
tmpSD$X139[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==23] <- 1
tmpSD$X140[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==23] <- 1
tmpSD$X141[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==24] <- 1
tmpSD$X142[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==24] <- 1
tmpSD$X143[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==24] <- 1
tmpSD$X144[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==24] <- 1
tmpSD$X145[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==25] <- 1
tmpSD$X146[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==25] <- 1
tmpSD$X147[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==25] <- 1
tmpSD$X148[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==25] <- 1
tmpSD$X149[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==26] <- 1
tmpSD$X150[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==26] <- 1
tmpSD$X151[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==26] <- 1
tmpSD$X152[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==26] <- 1
tmpSD$X153[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==27] <- 1
tmpSD$X154[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==27] <- 1
tmpSD$X155[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==27] <- 1
tmpSD$X156[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==27] <- 1
tmpSD$X157[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==28] <- 1
tmpSD$X158[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==28] <- 1
tmpSD$X159[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==28] <- 1
tmpSD$X160[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==28] <- 1
tmpSD$X161[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==29] <- 1
tmpSD$X162[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==29] <- 1
tmpSD$X163[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==29] <- 1
tmpSD$X164[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==29] <- 1
tmpSD$X165[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==30] <- 1
tmpSD$X166[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==30] <- 1
tmpSD$X167[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==30] <- 1
tmpSD$X168[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==30] <- 1
tmpSD$X169[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==31] <- 1
tmpSD$X170[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==31] <- 1
tmpSD$X171[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==31] <- 1
tmpSD$X172[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==31] <- 1
tmpSD$X173[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==32] <- 1
tmpSD$X174[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==32] <- 1
tmpSD$X175[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==32] <- 1
tmpSD$X176[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==32] <- 1
tmpSD$X177[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==33] <- 1
tmpSD$X178[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 1 & tmpSD$reg==33] <- 1
tmpSD$X179[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==33] <- 1
tmpSD$X180[ tmpSD$ageannee>= 15 & tmpSD$milieu== 1 & tmpSD$m5== 2 & tmpSD$reg==33] <- 1
tmpSD$X181[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==1] <- 1
tmpSD$X182[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==1] <- 1
tmpSD$X183[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==1] <- 1
tmpSD$X184[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==1] <- 1
tmpSD$X185[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==2] <- 1
tmpSD$X186[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==2] <- 1
tmpSD$X187[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==2] <- 1
tmpSD$X188[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==2] <- 1
tmpSD$X189[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==3] <- 1
tmpSD$X190[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==3] <- 1
tmpSD$X191[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==3] <- 1
tmpSD$X192[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==3] <- 1
tmpSD$X193[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==4] <- 1
tmpSD$X194[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==4] <- 1
tmpSD$X195[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==4] <- 1
tmpSD$X196[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==4] <- 1
tmpSD$X197[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==5] <- 1
tmpSD$X198[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==5] <- 1
tmpSD$X199[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==5] <- 1
tmpSD$X200[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==5] <- 1
tmpSD$X201[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==6] <- 1
tmpSD$X202[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==6] <- 1
tmpSD$X203[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==6] <- 1
tmpSD$X204[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==6] <- 1
tmpSD$X205[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==7] <- 1
tmpSD$X206[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==7] <- 1
tmpSD$X207[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==7] <- 1
tmpSD$X208[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==7] <- 1
tmpSD$X209[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==8] <- 1
tmpSD$X210[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==8] <- 1
tmpSD$X211[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==8] <- 1
tmpSD$X212[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==8] <- 1
tmpSD$X213[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==9] <- 1
tmpSD$X214[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==9] <- 1
tmpSD$X215[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==9] <- 1
tmpSD$X216[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==9] <- 1
tmpSD$X217[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==10] <- 1
tmpSD$X218[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==10] <- 1
tmpSD$X219[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==10] <- 1
tmpSD$X220[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==10] <- 1
tmpSD$X221[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==11] <- 1
tmpSD$X222[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==11] <- 1
tmpSD$X223[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==11] <- 1
tmpSD$X224[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==11] <- 1
tmpSD$X225[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==12] <- 1
tmpSD$X226[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==12] <- 1
tmpSD$X227[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==12] <- 1
tmpSD$X228[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==12] <- 1
tmpSD$X229[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==13] <- 1
tmpSD$X230[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==13] <- 1
tmpSD$X231[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==13] <- 1
tmpSD$X232[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==13] <- 1
tmpSD$X233[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==14] <- 1
tmpSD$X234[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==14] <- 1
tmpSD$X235[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==14] <- 1
tmpSD$X236[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==14] <- 1
tmpSD$X237[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==15] <- 1
tmpSD$X238[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==15] <- 1
tmpSD$X239[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==15] <- 1
tmpSD$X240[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==15] <- 1
tmpSD$X241[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==16] <- 1
tmpSD$X242[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==16] <- 1
tmpSD$X243[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==16] <- 1
tmpSD$X244[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==16] <- 1
tmpSD$X245[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==17] <- 1
tmpSD$X246[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==17] <- 1
tmpSD$X247[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==17] <- 1
tmpSD$X248[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==17] <- 1
tmpSD$X249[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==18] <- 1
tmpSD$X250[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==18] <- 1
tmpSD$X251[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==18] <- 1
tmpSD$X252[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==18] <- 1
tmpSD$X253[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==19] <- 1
tmpSD$X254[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==19] <- 1
tmpSD$X255[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==19] <- 1
tmpSD$X256[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==19] <- 1
tmpSD$X257[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==20] <- 1
tmpSD$X258[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==20] <- 1
tmpSD$X259[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==20] <- 1
tmpSD$X260[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==20] <- 1
tmpSD$X261[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==21] <- 1
tmpSD$X262[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==21] <- 1
tmpSD$X263[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==21] <- 1
tmpSD$X264[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==21] <- 1
tmpSD$X265[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==22] <- 1
tmpSD$X266[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==22] <- 1
tmpSD$X267[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==22] <- 1
tmpSD$X268[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==22] <- 1
tmpSD$X269[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==23] <- 1
tmpSD$X270[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==23] <- 1
tmpSD$X271[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==23] <- 1
tmpSD$X272[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==23] <- 1
tmpSD$X273[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==24] <- 1
tmpSD$X274[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==24] <- 1
tmpSD$X275[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==24] <- 1
tmpSD$X276[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==24] <- 1
tmpSD$X277[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==25] <- 1
tmpSD$X278[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==25] <- 1
tmpSD$X279[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==25] <- 1
tmpSD$X280[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==25] <- 1
tmpSD$X281[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==26] <- 1
tmpSD$X282[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==26] <- 1
tmpSD$X283[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==26] <- 1
tmpSD$X284[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==26] <- 1
tmpSD$X285[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==27] <- 1
tmpSD$X286[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==27] <- 1
tmpSD$X287[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==27] <- 1
tmpSD$X288[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==27] <- 1
tmpSD$X289[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==28] <- 1
tmpSD$X290[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==28] <- 1
tmpSD$X291[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==28] <- 1
tmpSD$X292[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==28] <- 1
tmpSD$X293[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==29] <- 1
tmpSD$X294[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==29] <- 1
tmpSD$X295[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==29] <- 1
tmpSD$X296[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==29] <- 1
tmpSD$X297[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==30] <- 1
tmpSD$X298[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==30] <- 1
tmpSD$X299[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==30] <- 1
tmpSD$X300[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==30] <- 1
tmpSD$X301[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==31] <- 1
tmpSD$X302[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==31] <- 1
tmpSD$X303[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==31] <- 1
tmpSD$X304[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==31] <- 1
tmpSD$X305[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==32] <- 1
tmpSD$X306[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==32] <- 1
tmpSD$X307[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==32] <- 1
tmpSD$X308[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==32] <- 1
tmpSD$X309[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==33] <- 1
tmpSD$X310[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 1 & tmpSD$reg==33] <- 1
tmpSD$X311[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==33] <- 1
tmpSD$X312[ tmpSD$ageannee>= 15 & tmpSD$milieu== 2 & tmpSD$m5== 2 & tmpSD$reg==33] <- 1




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

LFS_SAMPLE_DATA <- tmpSD[,c("hh2", "milieu", "DOMAIN", "STRATAKEY", "PSUKEY", "HHKEY", "INDKEY", 
                            "m5", list_of_X, "d_weights")]

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
  tab_cols(m5, milieu, total()) %>%
  tab_rows(DOMAIN, total()) %>%
  tab_weight(d_weights) %>%
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
  tab_weight(d_weights) %>%
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

sum(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT[1,seq(50,57)],na.rm = TRUE)


###   We can calculate the total population summing the X values of the third subset of X

# sum(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT[seq(1,4),seq(54,95)],na.rm = TRUE)

###   We can calculate the total population summing the X values of the fourth subset of X

# sum(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT[seq(1,4),seq(96,137)],na.rm = TRUE)


### VISUALIZE THE OUTPUTS PRODUCED BY THIS STEP

View(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_EST_DES_WEIGHT)

View(LFS_SAMPLE_DATA_SUMMARY_OF_Xs_SAMPLE_SIZE)
