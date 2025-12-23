########################################################################################################################.
########################################################################################################################.
########################################################################################################################.
########                                                                                                        ########.
########      TRAINING ON WEIGHTING METHODS AND STRATEGIES  - ILO STATISTICS & ITC-ILO -  Oct/Dec 2023          ########.
########                                                                                                        ########.
########      PREPARED BY: ANTONIO R. DISCENZA - ITALIAN NATIONAL INSTITUTE OF STATISTICS - ISTAT               ########.
########                               E.mail: antonio.r.discenza@gmail.com                                     ########.
########                                                                                                        ########.
########                                 CASE STUDY N. 16 - (154X_4D_ALLWR)                                     ########.
########                                                                                                        ########.
########                       CALIBRATION OF FINAL WEIGHTS USING R FOR ALL STEPS                               ########.
########                                                                                                        ########.
########               Filenames, paths, reference periods and set of constraints are parameterized             ########.
########                                                                                                        ########.
########                                                                                                        ########.
########                                          R SCRIPT 07b                                                  ########.
########           PROGRAM TO CALCULATE PRECISION OF RATIOS / RATES FOR KEY LABOUR MARKET INDICATORS            ########.
########                                     OBTAINED USING CALIBRATED WEIGHTS                                  ########.
########                                                                                                        ########.
########                                 BASED ON THE R PACKAGE "REGENESSES"                                    ########.
########                             see https://diegozardetto.github.io/ReGenesees/                            ########.
########                                                                                                        ########.
########                                                                                                        ########.
########        4 DOMAINS  (4 Regions)                                                                          ########.
########        154 CONSTRAINTS (X1 TO X154)                                                                    ########.
########              - Population by region, sex and 12 age groups    (X1 TO X24)                              ########.
########              - Population by region, urban and rural, sex and 7 age groups  (X25 TO X52)               ########.   
########              - Population by region, district, sex and 7 age groups  (X53 TO X94)                      ########.                     
########              - Population by region, month, sex and 7 age groups  (X95 TO X136)                        ########.                     
########              - Population by region, month, district and sex (X137 TO X154)                            ########.        
########                                                                                                        ########.
########################################################################################################################.
########################################################################################################################.
########################################################################################################################.



#######   STEP 0   ###########################################################################################
###
###    THE PACKAGES BELOW HAVE TO BE INSTALLED ONLY ONCE. THEN THE CODE CAN BE COMMENTED USING THE HASHTAG  
###
##############################################################################################################

# install.packages("remotes")
# remotes::install_github("DiegoZardetto/ReGenesees")
# remotes::install_github("DiegoZardetto/ReGenesees.GUI")


#######   STEP 1   ###########################################################################################
###
###    Activate the libraries that are needed by the procedure every time need to calculate precision
###
##############################################################################################################

# library(ReGenesees)


#######   STEP 2   ###########################################################################################
###
###    LOAD THE IMAGE CONTAINING THE R OBJECTS CREATED DURING THE CALIBRATION PHASE TO BE REUSED HERE
###
##############################################################################################################

load(FILE_LFS_CALIBRATION_IMAGE_RDATA )


### See all the R objects loaded from the image file
ls()

### See the variables with the dataset calib_lfs
head(calib_lfs$variables)




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
################## We create a temporaray copy of the calibrated objects to avoid to damage it 

# tmp_calib_lfs <- des.addvars( calib_lfs, EMP_15plus_100 = EMP_15plus * 100 )

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

tmp_calib_lfs <- des.addvars( calib_lfs2, pop_chomage_dich_100 = pop_chomage_dich * 100 )



################################## For the COUNTRY TOTAL

tmp_cvs_RAT               <-  svystatR( design = tmp_calib_lfs,
                                           num = ~ pop_chomage_dich_100,
                                           den = ~ MO,
                                            by = ~ ONES,
                                         cross = TRUE,
                                       vartype = c("cvpct"), 
                                      conf.int = FALSE, 
                                      conf.lev = 0.95, 
                                          deff = FALSE, 
                                        na.rm = TRUE)
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
