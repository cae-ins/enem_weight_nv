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
########                                        R Script 01                                                     ########.
########                                                                                                        ########.
########      CREATE THE R DATAFRAMES CONTAINING                                                                ########.
########      - THE FULL SAMPLE DATA   (steps 1.1 and 1.2)                                                      ########.
########      - POPULATION FIGURES AT THE NATIONAL LEVEL, BY URBAN/RURAL, SEX AND 12 AGE GROUPS   (X1 TO X48)   ########.
########      - POPULATION FIGURES AT THE REGIONAL LEVEL, BY URBAN/RURAL, SEX AND 2 AGE GROUPS   ( X49 TO X312) ########.   ########.
########                                                                                                        ########.
########################################################################################################################.
########################################################################################################################.
########################################################################################################################.



######################################################################################################
###  
###   STEP 1.1 
### 
###   Read the full sample data available in the CSV format stored in a specific directory
### 
######################################################################################################

LFS_ILO_DER <- read_dta(file = FILE_LFS_ILO_DER_DTA)

###  show the first 6 lines of the dataset 

head(LFS_ILO_DER)

### See the structure of the object

str(LFS_ILO_DER)

# View(LFS_ILO_DER)

### We have 53619 observations (individual interviews successfully completed) and 40 variables

### Note that the number of individuals interviewed can be obtained in different ways, and the result must be consistent

### For example, the number of individuals can be obtained summing the column of ones "POP_0plus", i.e.
### the dummy variable that identifies the population of age 0 plus (is 1 for all individuals interviewed) 

# sum(LFS_ILO_DER$POP_0plus)

### and must also correspond to the number of records/rows of the dataframe

dim(LFS_ILO_DER)

### Individuals in the frame must have a unique identification code (INDKEY) hence let's verify it using the following instruction


LFS_ILO_DER$INDKEY <- as.factor(paste0(LFS_ILO_DER$hh2, "-",LFS_ILO_DER$hh3, "-", LFS_ILO_DER$hh4, "-", LFS_ILO_DER$hh8, "-", LFS_ILO_DER$interview_key, "-", LFS_ILO_DER$membres_id))

length(unique(LFS_ILO_DER$INDKEY))

### We can also check how many households we have interviewed by counting the unique households ids (HHKEY)

LFS_ILO_DER$HHKEY <- as.factor(paste0(LFS_ILO_DER$hh2, "-",LFS_ILO_DER$hh3, "-", LFS_ILO_DER$hh4, "-", LFS_ILO_DER$hh8, "-", LFS_ILO_DER$interview_key))

length(unique(LFS_ILO_DER$HHKEY))

### and the number of enumeration areas (PSUKEY)

LFS_ILO_DER$PSUKEY <- as.factor(paste0(LFS_ILO_DER$hh2, "-",LFS_ILO_DER$hh3, "-", LFS_ILO_DER$hh4, "-", LFS_ILO_DER$hh8))


length(unique(LFS_ILO_DER$PSUKEY))

### We can also check how many households we have succesfully interviewed on average in each PSU
### dividing the numebr of households by the number of PSU

length(unique(LFS_ILO_DER$HHKEY)) / length(unique(LFS_ILO_DER$PSUKEY))

### The number of strata (STRATAKEY)

LFS_ILO_DER$STRATAKEY <- as.factor(LFS_ILO_DER$hh2)

length(unique(LFS_ILO_DER$STRATAKEY))

### The number of districts (DISTRICT )

# length(unique(LFS_ILO_DER$DISTRICT ))

### The number of regions (REGION)

length(unique(LFS_ILO_DER$hh2))



### We can also tabulate the actual sample size in several ways, for example using the function "table"

### to open the manual of the function table 
help(table) 

table(LFS_ILO_DER$hh2)

# table(LFS_ILO_DER$YEAR , LFS_ILO_DER$QUARTER )
# 
# table(LFS_ILO_DER$QUARTER, LFS_ILO_DER$MONTH )
# 
# table(LFS_ILO_DER$AGE_GROUP14, LFS_ILO_DER$SEX )
# 
# table(LFS_ILO_DER$SEX, LFS_ILO_DER$ilo_lfs)


### We can also check the estimates obtained using the design weights
### Create a table using the "expss" package and the magritte %>% pipe 
### (see https://magrittr.tidyverse.org/reference/pipe.html)


LFS_ILO_DER %>%
  tab_cols(m5, milieu, total()) %>%
  tab_rows(hh2, total()) %>%
  tab_weight(d_weights) %>%
  tab_stat_sum %>%
  tab_pivot()



######################################################################################################
###  
###    STEP 1.2 
###
###    Save the R objects in the specific "DER" folder for future use
### 
######################################################################################################

save(LFS_ILO_DER ,file= FILE_LFS_ILO_DER_RDATA)

###  Check now within destination folder. We now have a new file named "LFS_SW_2021_Q1_DER.RData"


#######   NOTE   ###########################################################################################
###
###  When we want to reuse the R objects (.RData) in a future session we can use the following code. 


###  Lets first remove all the objects from the memory of the current session

# rm(LFS_ILO_DER)
# ls()


###  Load the object "LFS_SW_2021_Q1_DER.RData" from the related folder

# load(file= FILE_LFS_ILO_DER_RDATA)
# ls()

###  Now check that the object "LFS_SW_2021_Q1_DER" does exist. In R the object name is without ".Rdata"

# ls()


###  Now let's verify again the content of the object

# str(LFS_ILO_DER)








######################################################################################################
###  
###   STEP 1.3 
### 
###   Read the population figures available in the Stata dta format stored in a specific directory
### 
###   POPULATION BY REGION (33) AND URBAN_RURAL AND SEX AND 3 AGE GROUPS
###
######################################################################################################


###  Read the xlsx file stored in a specific directory 

POP_LFS_BY_REGION_SEX_2AGEGR <- read_xlsx(FILE_POP_LFS_BY_REGION_SEX_2AGEGR_XLSX)
# POP_LFS_BY_REGION_SEX_2AGEGR <- read_dta(FILE_POP_LFS_BY_REGION_SEX_2AGEGR_DTA)

#  View(POP_LFS_BY_REGION_SEX_2AGEGR)



######################################################################################################
###  
###    STEP 1.4 
###
###    Save the R objects in the specific folder for future use
### 
######################################################################################################

save(POP_LFS_BY_REGION_SEX_2AGEGR,file = FILE_POP_LFS_BY_REGION_SEX_2AGEGR_RDATA)

###  Check now within destination folder. We now have a new file named "POP_LFS_BY_REGION_URBAIN_RURAL_SEX_12AGEGR_2021_Q1.RData"


######################################################################################################
###  
###   STEP 1.5 
### 
###   Read the population figures available in the CSV format stored in a specific directory
### 
###   POPULATION BY REGION, URBAN AND RURAL LOCATIONS (2), SEX AND 7 AGE GROUPS
###   POPULATION BY REGION, DISTRICTS, SEX AND 7 AGE GROUPS
###
######################################################################################################



### if we have the excel file "vert" we can read it directly

#POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert <- read_xlsx(FILE_POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert_XLSX)

# View(POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert)


### if we do not have the excel file "vert" but the original one, we can create the "vert" version 
### by transforming the original one using the following code


###  Read the STATA file stored in a specific directory using package "haven" 

# POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR <- read_dta(FILE_POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR_DTA)
# 
# POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR


### REARRANGE AS VERTICAL TABLE 

# tmp_AGEGROUP1 <- POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","group_age_0_14")]
# 
# tmp_AGEGROUP1$POPULATION_FIGURES <-  tmp_AGEGROUP1$group_age_0_14
# 
# tmp_AGEGROUP1$AGE_GROUP7label <- "group_age_0_14"
# 
# tmp_AGEGROUP1$AGE_GROUP7 <-  1
# 
# tmp_AGEGROUP1 <- tmp_AGEGROUP1[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","AGE_GROUP7","AGE_GROUP7label", "POPULATION_FIGURES")]
# 
# 
# 
# 
# tmp_AGEGROUP2 <- POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","group_age_15_24")]
# 
# tmp_AGEGROUP2$POPULATION_FIGURES <-  tmp_AGEGROUP2$group_age_15_24
# 
# tmp_AGEGROUP2$AGE_GROUP7label <- "group_age_15_24"
# 
# tmp_AGEGROUP2$AGE_GROUP7 <-  2
# 
# tmp_AGEGROUP2 <- tmp_AGEGROUP2[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","AGE_GROUP7","AGE_GROUP7label", "POPULATION_FIGURES")]
# 
# 
# 
# tmp_AGEGROUP3 <- POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","group_age_25_34")]
# 
# tmp_AGEGROUP3$POPULATION_FIGURES <-  tmp_AGEGROUP3$group_age_25_34
# 
# tmp_AGEGROUP3$AGE_GROUP7label <- "group_age_25_34"
# 
# tmp_AGEGROUP3$AGE_GROUP7 <-  3
# 
# tmp_AGEGROUP3 <- tmp_AGEGROUP3[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","AGE_GROUP7","AGE_GROUP7label", "POPULATION_FIGURES")]
# 
# 
# 
# tmp_AGEGROUP4 <- POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","group_age_35_44")]
# 
# tmp_AGEGROUP4$POPULATION_FIGURES <-  tmp_AGEGROUP4$group_age_35_44
# 
# tmp_AGEGROUP4$AGE_GROUP7label <- "group_age_35_44"
# 
# tmp_AGEGROUP4$AGE_GROUP7 <-  4
# 
# tmp_AGEGROUP4 <- tmp_AGEGROUP4[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","AGE_GROUP7","AGE_GROUP7label", "POPULATION_FIGURES")]
# 
# 
# 
# tmp_AGEGROUP5 <- POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","group_age_45_54")]
# 
# tmp_AGEGROUP5$POPULATION_FIGURES <-  tmp_AGEGROUP5$group_age_45_54
# 
# tmp_AGEGROUP5$AGE_GROUP7label <- "group_age_45_54"
# 
# tmp_AGEGROUP5$AGE_GROUP7 <-  5
# 
# tmp_AGEGROUP5 <- tmp_AGEGROUP5[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","AGE_GROUP7","AGE_GROUP7label", "POPULATION_FIGURES")]
# 
# 
# 
# tmp_AGEGROUP6 <- POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","group_age_55_64")]
# 
# tmp_AGEGROUP6$POPULATION_FIGURES <-  tmp_AGEGROUP6$group_age_55_64
# 
# tmp_AGEGROUP6$AGE_GROUP7label <- "group_age_55_64"
# 
# tmp_AGEGROUP6$AGE_GROUP7 <-  6
# 
# tmp_AGEGROUP6 <- tmp_AGEGROUP6[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","AGE_GROUP7","AGE_GROUP7label", "POPULATION_FIGURES")]
# 
# 
# tmp_AGEGROUP7 <- POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","group_age_65_plus")]
# 
# tmp_AGEGROUP7$POPULATION_FIGURES <-  tmp_AGEGROUP7$group_age_65_plus
# 
# tmp_AGEGROUP7$AGE_GROUP7label <- "group_age_65_plus"
# 
# tmp_AGEGROUP7$AGE_GROUP7 <-  7
# 
# tmp_AGEGROUP7 <- tmp_AGEGROUP7[c("YEAR","QUARTER","REGION","DISTRICT","UR_RU","SEX","AGE_GROUP7","AGE_GROUP7label", "POPULATION_FIGURES")]


###  PUT THEM TOGETHER

# POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert <- rbind(tmp_AGEGROUP1,tmp_AGEGROUP2,tmp_AGEGROUP3,tmp_AGEGROUP4,tmp_AGEGROUP5,tmp_AGEGROUP6,tmp_AGEGROUP7)
#  View(POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert)





######################################################################################################
###  
###    STEP 1.6 
###
###    Save the R objects in the specific folder for future use
### 
######################################################################################################

# save(POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert,file =  FILE_POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert_RDATA )

###  Check now within destination folder.



######################################################################################################
###  
###    STEP 1.7
###
###    CHECK THE POPULATION FIGURES AND INITIAL DESIGN ESTIMATES 
### 
######################################################################################################


#######  CHECK THE POPULATION FIGURES WE WILL BE USING AS BENCHMARK   ###########################################################################################

### from the first population dataframe
tmp_sum_pop_fig1 <-
  sum(POP_LFS_BY_REGION_SEX_2AGEGR$Nombre)
tmp_sum_pop_fig1

### from the second population dataframe
# tmp_sum_pop_fig2 <- 
#   sum(POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert$POPULATION_FIGURES)
# 
# tmp_sum_pop_fig2

#######   CHECK THE POPULATION ESTIMATES OBTAINED WITH THE DESIGN WEIGHTS   ###########################################################################################

tmp_sum_est_pop_dw <- 
  sum(LFS_ILO_DER$d_weights)
tmp_sum_est_pop_dw

#######   CHECK THE AVERAGE CORRECTION FACTOR FOR THE FINAL WIEGHTS   ###########################################################################################

tmp_sum_pop_fig1 / tmp_sum_est_pop_dw 


#######   VISUALIZE THE OUTPUTS OF THIS STEP   ###########################################################################################

View(POP_LFS_BY_REGION_SEX_2AGEGR) 

# View(POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert)




