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
########                                          R SCRIPT 07                                                   ########.
########                     PROGRAM TO CALCULATE PRECISION OF KEY LABOUR MARKET INDICATORS (LEVELS)            ########.
########                                     OBTAINED USING CALIBRATED WEIGHTS                                  ########.
########                                                                                                        ########
########                                 BASED ON THE R PACKAGE "REGENESSES"                                    ########.
########                             see https://diegozardetto.github.io/ReGenesees/                            ########.
########                                                                                                        ########.
########                                                                                                        ########.
########        4 DOMAINS  (4 Regions)                                                                          ########.
########        24 CONSTRAINTS (X1 TO X24)                                                                      ########.
########              - Population by region, sex and 12 age groups    (X1 TO X24)                              ########.
########                                                                                                        ########.
########################################################################################################################.
########################################################################################################################.


#######   STEP 7.0   ###########################################################################################
###
###    THE PACKAGES BELOW HAVE TO BE INSTALLED ONLY ONCE. THEN THE CODE CAN BE COMMENTED USING THE HASHTAG  
###
##############################################################################################################

# install.packages("remotes")
# remotes::install_github("DiegoZardetto/ReGenesees")
# remotes::install_github("DiegoZardetto/ReGenesees.GUI")


#######   STEP 7.1   ###########################################################################################
###
###    Activate the libraries that are needed by the procedure every time need to calculate precision
###
##############################################################################################################

 library(ReGenesees)


######################################################################################################
###  
###   STEP 7.2 
###  
###   SET THE WORKING DIRECTORY WHERE THE OUPUTS WILL BE STORED 
### 
######################################################################################################

getwd()
setwd("D:/DOCUMENTS/CAE/Calibration/06032025/ILO_STAT_CALIBRATION_Delivery_2_2025_03_06/ILO_LFS_GSBPM/DATA/565_QUARTERLY_WEIGHTING/2021/Quarter1/24X_4D_ALLWR_np/")
getwd()


######################################################################################################
###  
###   STEP 7.3 
###
###    LOAD THE IMAGE CONTAINING THE R OBJECTS CREATED DURING THE CALIBRATION PHASE TO BE REUSED HERE
###
##############################################################################################################


ls()

load("LFS_CALIBRATION_2021_Q1_24X_4D_ALLWR_np_IMAGE.RData")

### See all the R objects loaded from the image file
ls()

### See the variables with the dataset calib_lfs

head(calib_lfs$variables)


#######   STEP 5   ###########################################################################################
###
###    ESTIMATE THE STANDARD ERRORS, CVs AND CONFIDENCE INTERVALS FOR LEVEL ESTIMATES
###
###############################################################################################################


### Calculate the standard errors for the total   
### Generally it is convenient to store the results in a dataframe so we can export them in excel or other type of file   

### When we want the precision of the total of a variable, without disaggregation, the parameter "by" is not used
### However, I suggest to use a variable that is constant across all record (like for example the YEAR, QUARTER or ONES
### So the output is consistent with the output produced when we do use disaggregation (later we will see why this is important)


tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ EMP_15plus ,
                            by = ~ ONES,
                            vartype = c("se","cvpct"), 
                            conf.int = TRUE, 
                            conf.lev = 0.95, 
                            deff = TRUE, 
                            na.rm = FALSE)
tmp_cvs_TOT

View(tmp_cvs_TOT)

### if we want the precision of the total of the variable disaggregated by any variable we use the parameter "by"


### Precision of the total of the variable disaggregated by SEX

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ EMP_15plus ,
                            by = ~ SEX,
                            vartype = c("se","cvpct"), 
                            conf.int = TRUE, 
                            conf.lev = 0.95, 
                            deff = TRUE, 
                            na.rm = FALSE)
tmp_cvs_TOT


### Precision of the total of the variable disaggregated by REGION 

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ EMP_15plus ,
                            by = ~ REGION,
                            vartype = c("se","cvpct"), 
                            conf.int = TRUE, 
                            conf.lev = 0.95, 
                            deff = TRUE, 
                            na.rm = FALSE)
tmp_cvs_TOT

### Precision of the total of the variable disaggregated by REGION and SEX 

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ EMP_15plus ,
                            by = ~ REGION:SEX,
                            vartype = c("se","cvpct"), 
                            conf.int = TRUE, 
                            conf.lev = 0.95, 
                            deff = TRUE, 
                            na.rm = FALSE)
tmp_cvs_TOT

### Precision of the total of the variable disaggregated by REGION and DISTRICTS

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ EMP_15plus ,
                            by = ~ REGION:DISTRICT,
                            vartype = c("se","cvpct"), 
                            conf.int = TRUE, 
                            conf.lev = 0.95, 
                            deff = TRUE, 
                            na.rm = FALSE)
tmp_cvs_TOT



#######   STEP 6   ###########################################################################################
###
###    ESTIMATE THE STANDARD ERRORS, CVs AND CONFIDENCE INTERVALS FOR LEVEL ESTIMATES OF UNEMPLOYED
###
###############################################################################################################


### We can use the same function for Unemployment   

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ UNE_15plus ,
                            by = ~ REGION:SEX,
                            vartype = c("se","cvpct"), 
                            conf.int = TRUE, 
                            conf.lev = 0.95, 
                            deff = TRUE, 
                            na.rm = TRUE)
tmp_cvs_TOT


tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ UNE_15plus ,
                            by = ~ REGION:SEX:AGE_GROUP7 ,
                            vartype = c("se","cvpct"), 
                            conf.int = TRUE, 
                            conf.lev = 0.95, 
                            deff = TRUE, 
                            na.rm = TRUE)
tmp_cvs_TOT

View(tmp_cvs_TOT)

### We can use the same function for Labour Force   

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ LF_15plus ,
                            by = ~ REGION:SEX,
                            vartype = c("se","cvpct"), 
                            conf.int = TRUE, 
                            conf.lev = 0.95, 
                            deff = TRUE, 
                            na.rm = TRUE)
tmp_cvs_TOT


### Notice the standard error of the Population Estimates at the regional level

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ POP_15plus ,
                            by = ~ REGION,
                            vartype = c("se","cvpct"), 
                            conf.int = TRUE, 
                            conf.lev = 0.95, 
                            deff = TRUE, 
                            na.rm = TRUE)
tmp_cvs_TOT

### It is zero because that is a known total that we have benchmarked to external figures

### NOtice now the standard error of the Population Estimates at the urban and rural level level

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ POP_15plus ,
                            by = ~ UR_RU,
                            vartype = c("se","cvpct"), 
                            conf.int = TRUE, 
                            conf.lev = 0.95, 
                            deff = TRUE, 
                            na.rm = TRUE)
tmp_cvs_TOT

### It is not zero because we have not added constraints on the population by UR_RU 
### It would become zero if we have add constraints on the population by UR_RU 

### Notice now the standard error of the Population Estimates for age groups that are benchmarked
### they are zero because the age group 15-64 is benchmarked in weighting

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ I(POP_15plus * (AGE>=15 & AGE<=64) ) ,
                            by = ~ ONES,
                            vartype = c("cvpct"), 
                            conf.int = FALSE, 
                            conf.lev = 0.95, 
                            deff = FALSE, 
                            na.rm = TRUE)
tmp_cvs_TOT
View()

### And now the standard error of the Population Estimates for age groups that are not benchmarked
### the CV is different from zero

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ I(POP_15plus * (AGE>=17 & AGE<=67) ) ,
                            by = ~ YEAR,
                            vartype = c("cvpct"), 
                            conf.int = FALSE, 
                            conf.lev = 0.95, 
                            deff = FALSE, 
                            na.rm = TRUE)
tmp_cvs_TOT


#######   STEP 5   ###########################################################################################
###
###    ESTIMATE THE STANDARD ERRORS, CVs AND CONFIDENCE INTERVALS FOR THE EMPLOYMENT TO POPULATION RATIO
###
###############################################################################################################

### Let's use the function svystatR
# help(svystatR) 

################################## EMPLOYMENT For the COUNTRY TOTAL

tmp_cvs_RAT               <-  svystatR( design = calib_lfs,
                                        num = ~ EMP_15plus,
                                        den = ~ POP_15plus,
                                        by = ~ YEAR,
                                        cross = TRUE,
                                        vartype = c("cvpct"), 
                                        conf.int = FALSE, 
                                        conf.lev = 0.95, 
                                        deff = FALSE, 
                                        na.rm = FALSE)
tmp_cvs_RAT 


### NOTICE what happens if we calculate the CV for the variable EMP_15plus we get   

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ EMP_15plus ,
                            by = ~ YEAR,
                            vartype = c("cvpct"), 
                            conf.int = FALSE, 
                            conf.lev = 0.95, 
                            deff = FALSE, 
                            na.rm = TRUE)
tmp_cvs_TOT

### The CVs are exactly the same because the denominator of that ratio has been benchmarked in calibration (so it is considered as a constant in the formula of the variance)   


################################## EMPLOYMENT For DOMAIN AND SEX

tmp_cvs_RAT               <-  svystatR( design = calib_lfs,
                                        num = ~ EMP_15plus,
                                        den = ~ POP_15plus,
                                        by = ~ DOMAIN:SEX,
                                        cross = TRUE,
                                        vartype = c("cvpct"), 
                                        conf.int = FALSE, 
                                        conf.lev = 0.95, 
                                        deff = FALSE, 
                                        na.rm = FALSE)

tmp_cvs_RAT 

### NOTICE again what happens if we calculate the CV for the variable EMP_15plus we get   

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ EMP_15plus ,
                            by = ~ DOMAIN:SEX,
                            vartype = c("cvpct"), 
                            conf.int = FALSE, 
                            conf.lev = 0.95, 
                            deff = FALSE, 
                            na.rm = TRUE)
tmp_cvs_TOT

### As above, the CVs are exactly the same because also for this disaggregation the denominator of that ratio has been benchmarked in calibration 


################################## EMPLOYMENT For URBAN AND RURAL

tmp_cvs_RAT               <-  svystatR( design = calib_lfs,
                                        num = ~ EMP_15plus,
                                        den = ~ POP_15plus,
                                        by = ~ UR_RU ,
                                        cross = TRUE,
                                        vartype = c("cvpct"), 
                                        conf.int = FALSE, 
                                        conf.lev = 0.95, 
                                        deff = FALSE, 
                                        na.rm = FALSE)

tmp_cvs_RAT 

### NOTICE again what happens if we calculate the CV for the variable EMP_15plus we get   

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ EMP_15plus ,
                            by = ~ UR_RU ,
                            vartype = c("cvpct"), 
                            conf.int = FALSE, 
                            conf.lev = 0.95, 
                            deff = FALSE, 
                            na.rm = TRUE)
tmp_cvs_TOT


### It is the same if we have added constraints on the population by UR_RU 
### It is different if we have not dded constraints on the population by UR_RU 



################################## POPULATION For URBAN AND RURAL


### It is zero if we have added constraints on the population by UR_RU 
### It is not zero if we have not dded constraints on the population by UR_RU 

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ POP_15plus ,
                            by = ~ UR_RU ,
                            vartype = c("cvpct"), 
                            conf.int = FALSE, 
                            conf.lev = 0.95, 
                            deff = FALSE, 
                            na.rm = TRUE)

tmp_cvs_TOT






#######   STEP 5   ###########################################################################################
###
###    ESTIMATE THE STANDARD ERRORS, CVs AND CONFIDENCE INTERVALS FOR THE EMPLOYMENT TO POPULATION RATIO (IN PERCENTAGES)
###
###############################################################################################################

################## We use a trick. We create a new varible that is 100 (i.e 1 * 100) for the employed and zero otherwise 

################################## For DOMAIN AND SEX

tmp_cvs_RAT               <-  svystatR( design = calib_lfs,
                                        num = ~ EMP_15plus_100,
                                        den = ~ POP_15plus,
                                        by = ~ DOMAIN:SEX,
                                        cross = TRUE,
                                        vartype = c("cvpct"), 
                                        conf.int = FALSE, 
                                        conf.lev = 0.95, 
                                        deff = FALSE, 
                                        na.rm = FALSE)

tmp_cvs_RAT 
View(tmp_cvs_RAT)

tmp_cvs_RAT               <-  svystatR( design = calib_lfs,
                                        num = ~ EMP_15plus,
                                        den = ~ POP_15plus,
                                        by = ~ DOMAIN:SEX,
                                        cross = TRUE,
                                        vartype = c("cvpct"), 
                                        conf.int = FALSE, 
                                        conf.lev = 0.95, 
                                        deff = FALSE, 
                                        na.rm = FALSE)

tmp_cvs_RAT 

### The CVs are exactly the same because the constant multiplier (100) does not affect the standard error   













#######   STEP 6   ###########################################################################################
###
###    ESTIMATE THE STANDARD ERRORS, CVs AND CONFIDENCE INTERVALS FOR THE UNEMPLOYMENT RATES
###
###############################################################################################################

### Let's use the function svystatR
# help(svystatR) 

################## As before we use the trick. We create a new varible that is 100 (i.e 1 * 100) for the unemployed and zero otherwise 
################## We continue to work on the temporaray copy of the calibrated objects to avoid to damage it 


################################## For the COUNTRY TOTAL

tmp_cvs_RAT               <-  svystatR( design = calib_lfs,
                                        num = ~ UNE_15plus_100,
                                        den = ~ LF_15plus,
                                        by = ~ YEAR,
                                        cross = TRUE,
                                        vartype = c("cvpct"), 
                                        conf.int = FALSE, 
                                        conf.lev = 0.95, 
                                        deff = FALSE, 
                                        na.rm = FALSE)
tmp_cvs_RAT 

################################## Is the same as above

tmp_cvs_RAT               <-  svystatR( design = calib_lfs,
                                        num = ~ UNE_15plus,
                                        den = ~ LF_15plus,
                                        by = ~ YEAR,
                                        cross = TRUE,
                                        vartype = c("cvpct"), 
                                        conf.int = FALSE, 
                                        conf.lev = 0.95, 
                                        deff = FALSE, 
                                        na.rm = FALSE)
tmp_cvs_RAT 


### HOWEVER, NOTICE what happens if we calculate the CV for the variable UNE_15plus we get   

tmp_cvs_TOT <-   svystatTM(  design = calib_lfs,
                             y = ~ UNE_15plus ,
                             by = ~ YEAR,
                             vartype = c("cvpct"), 
                             conf.int = FALSE, 
                             conf.lev = 0.95, 
                             deff = FALSE, 
                             na.rm = TRUE)
tmp_cvs_TOT



################################## For DOMAIN AND SEX


tmp_cvs_RAT               <-  svystatR( design = calib_lfs,
                                        num = ~ UNE_15plus_100,
                                        den = ~ LF_15plus,
                                        by = ~ DOMAIN:SEX,
                                        cross = TRUE,
                                        vartype = c("cvpct"), 
                                        conf.int = FALSE, 
                                        conf.lev = 0.95, 
                                        deff = FALSE, 
                                        na.rm = FALSE)
tmp_cvs_RAT 

### NOTICE what happens if we calculate the CV for the variable UNE_15plus we get   
### that the CV are different because the denominator of the unemployment rate is also an estimate
### hence ReGenesees calculates the CV of a ratio between two estimates

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                            y = ~ UNE_15plus ,
                            by = ~ DOMAIN:SEX,
                            vartype = c("cvpct"), 
                            conf.int = FALSE, 
                            conf.lev = 0.95, 
                            deff = FALSE, 
                            na.rm = TRUE)
tmp_cvs_TOT



################################## For DOMAIN AND SEX AND AGEGROUPS


tmp_cvs_RAT               <-  svystatR( design = calib_lfs,
                                        num = ~ UNE_15plus_100,
                                        den = ~ LF_15plus,
                                        by = ~ DOMAIN:SEX:AGE_GROUP7,
                                        cross = TRUE,
                                        vartype = c("cvpct"), 
                                        conf.int = FALSE, 
                                        conf.lev = 0.95, 
                                        deff = FALSE, 
                                        na.rm = FALSE)
tmp_cvs_RAT 