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

table(LFS_ILO_DER$hh2, LFS_ILO_DER$milieu)

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

### from the first population dataframe
tmp_sum_pop_fig1 <-
  sum(POP_LFS_BY_REGION_SEX_2AGEGR$Nombre) / 2
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






