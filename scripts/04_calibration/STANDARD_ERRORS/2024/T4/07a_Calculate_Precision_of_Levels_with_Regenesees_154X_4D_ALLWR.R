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
########                                          R SCRIPT 07a                                                  ########.
########                     PROGRAM TO CALCULATE PRECISION OF KEY LABOUR MARKET INDICATORS (LEVELS)            ########.
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
###    ESTIMATE THE STANDARD ERRORS, CVs AND CONFIDENCE INTERVALS FOR LEVEL ESTIMATES
###
###############################################################################################################


### We can use the same function for Unemployment   

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                                 y = ~ UNE_15plus ,
                                by = ~ REGION:DISTRICT,
                           vartype = c("se","cvpct"), 
                          conf.int = TRUE, 
                          conf.lev = 0.95, 
                              deff = TRUE, 
                             na.rm = TRUE)
tmp_cvs_TOT


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

### It is zero if we have added constraints on the population by UR_RU 
### It is not zero if we have not dded constraints on the population by UR_RU 

### Notice now the standard error of the Population Estimates for age groups that are benchmarked
### they are zero because the age group 15-64 is benchmarked in weighting

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                                 y = ~ I(POP_15plus * (AGE>=15 & AGE<=64) ) ,
                                by = ~ YEAR,
                           vartype = c("cvpct"), 
                          conf.int = FALSE, 
                          conf.lev = 0.95, 
                              deff = FALSE, 
                             na.rm = TRUE)
tmp_cvs_TOT


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

