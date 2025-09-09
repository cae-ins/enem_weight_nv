########################################################################################################################.
########################################################################################################################.
########################################################################################################################.
########                                                                                                        ########.
########      TRAINING ON WEIGHTING METHODS AND STRATEGIES  - ILO STATISTICS & ITC-ILO -  Oct/Dec 2023          ########.
########                                                                                                        ########.
########      PREPARED BY: ANTONIO R. DISCENZA - ITALIAN NATIONAL INSTITUTE OF STATISTICS - ISTAT               ########.
########                               E.mail: antonio.r.discenza@gmail.com                                     ########.
########                                                                                                        ########.
########                                 CASE STUDY N. 17 - (154X_4D_ALLWR)                                     ########.
########                                  EXERCISE 3 - FILLING TEMPLATE VER 3                                   ########.
########                                                                                                        ########.
########                       CALIBRATION OF FINAL WEIGHTS USING R FOR ALL STEPS                               ########.
########                                                                                                        ########.
########               Filenames, paths, reference periods and set of constraints are parameterized             ########.
########                                                                                                        ########.
########                                                                                                        ########.
########                                          R SCRIPT 07f                                                  ########.
########                     PROGRAM TO CALCULATE PRECISION OF KEY LABOUR MARKET INDICATORS (LEVELS)            ########.
########                                     OBTAINED USING CALIBRATED WEIGHTS                                  ########.
########                                                                                                        ########.
########                     AND TO PUT RESULTS INTO TEMPLATE "Template_CVS_EMP_Levels_ver3.xlsx"               ########.
########                                                                                                        ########.
########                                                                                                        ########.
########                                 BASED ON THE R PACKAGE "REGENESSES"                                    ########.
########                             see https://diegozardetto.github.io/ReGenesees/                            ########.
########                                                                                                        ########.
########                                                                                                        ########.
########        4 DOMAINS  (4 Regions)                                                                          ########.
########        24 CONSTRAINTS (X1 TO X154)                                                                     ########.
########              - Population by region, sex and 12 age groups    (X1 TO X24)                              ########.
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

# 
library(ReGenesees)


#######   STEP 2   ###########################################################################################
###
###    LOAD THE IMAGE CONTAINING THE R OBJECTS CREATED DURING THE CALIBRATION PHASE TO BE REUSED HERE
###
##############################################################################################################


######################################################################################################
###  
###   STEP 7.2 
###  
###   SET THE WORKING DIRECTORY WHERE THE OUPUTS WILL BE STORED 
### 
######################################################################################################

getwd()
setwd(dir_data_QW)
getwd()


######################################################################################################
###  
###   STEP 7.3 
###
###    LOAD THE IMAGE CONTAINING THE R OBJECTS CREATED DURING THE CALIBRATION PHASE TO BE REUSED HERE
###
##############################################################################################################


ls()

load(FILE_LFS_CALIBRATION_IMAGE_RDATA)

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

tmp_cvs_TOT <-   svystatTM( design = calib_lfs,
                                 y = ~ EMP_16Plus ,
                                  by = ~ ONES,
                           vartype = c("se","cvpct"), 
                          conf.int = TRUE, 
                          conf.lev = 0.95, 
                              deff = TRUE, 
                             na.rm = FALSE)
tmp_cvs_TOT


### Calculate the standard errors for the total by SEX   

tmp_cvs_SEX             <-   svystatTM( design = calib_lfs,
                                             y = ~ EMP_16Plus ,
                                            by = ~ M5,
                                       vartype = c("se","cvpct"),
                                      conf.int = TRUE, 
                                      conf.lev = 0.95, 
                                          deff = TRUE, 
                                        na.rm = FALSE)
tmp_cvs_SEX
     

### Calculate the standard errors for the total by AGE GROUPS

tmp_cvs_AGE             <-   svystatTM( design = calib_lfs,
                                             y = ~ EMP_16Plus,
                                            by = ~ GroupAge12,
                                       vartype = c("se","cvpct"), 
                                      conf.int = TRUE, 
                                      conf.lev = 0.95, 
                                          deff = TRUE, 
                                        na.rm = FALSE)
tmp_cvs_AGE


### Calculate the standard errors for the total by Urban and Rural   

tmp_cvs_URRU             <-  svystatTM( design = calib_lfs,
                                             y = ~ EMP_16Plus ,
                                            by = ~ HH6,
                                       vartype = c("se","cvpct"),
                                      conf.int = TRUE, 
                                      conf.lev = 0.95, 
                                          deff = TRUE, 
                                        na.rm = FALSE)
tmp_cvs_URRU





### Calculate the standard errors for the total by Urban and Rural and sex

tmp_cvs_URRU_SEX        <-   svystatTM( design = calib_lfs,
                                        y = ~ EMP_16Plus,
                                        by = ~ HH6 * M5,
                                        vartype = c("se","cvpct"), 
                                        conf.int = TRUE, 
                                        conf.lev = 0.95, 
                                        deff = TRUE, 
                                        na.rm = FALSE)
tmp_cvs_URRU_SEX 


###  and reorder to match the order in the template

tmp_cvs_URRU_SEX <-  tmp_cvs_URRU_SEX[order(tmp_cvs_URRU_SEX$HH6,
                                            tmp_cvs_URRU_SEX$M5),]

tmp_cvs_URRU_SEX 



### Calculate the standard errors for the total by REGION  

tmp_cvs_REG             <-   svystatTM( design = calib_lfs,
                                             y = ~ EMP_16Plus ,
                                            by = ~ Region,
                                       vartype = c("se","cvpct"),
                                      conf.int = TRUE, 
                                      conf.lev = 0.95, 
                                          deff = TRUE, 
                                        na.rm = FALSE)
tmp_cvs_REG
     

### Calculate the standard errors for by REGION and SEX  

tmp_cvs_REG_SEX        <-    svystatTM( design = calib_lfs,
                                             y = ~ EMP_16Plus,
                                            by = ~ Region * M5,
                                       vartype = c("se","cvpct"), 
                                      conf.int = TRUE, 
                                      conf.lev = 0.95, 
                                          deff = TRUE, 
                                        na.rm = FALSE)
tmp_cvs_REG_SEX  


###  and reorder to match the order in the template

tmp_cvs_REG_SEX <-  tmp_cvs_REG_SEX[order(tmp_cvs_REG_SEX$Region,
                                          tmp_cvs_REG_SEX$M5),]

tmp_cvs_REG_SEX 




### Calculate the standard errors for by REGION and TYPE OF LOCALITY (UR_RU)  

tmp_cvs_REG_URRU        <-    svystatTM( design = calib_lfs,
                                        y = ~ EMP_16Plus,
                                        by = ~ Region * HH6,
                                        vartype = c("se","cvpct"), 
                                        conf.int = TRUE, 
                                        conf.lev = 0.95, 
                                        deff = TRUE, 
                                        na.rm = FALSE)
tmp_cvs_REG_URRU  


###  and reorder to match the order in the template

tmp_cvs_REG_URRU <-  tmp_cvs_REG_URRU[order(tmp_cvs_REG_URRU$Region,
                                            tmp_cvs_REG_URRU$HH6),]

tmp_cvs_REG_URRU 




### Calculate the standard errors for by REGION, TYPE OF LOCALITY (UR_RU) and SEX 

tmp_cvs_REG_URRU_SEX        <-    svystatTM( design = calib_lfs,
                                         y = ~ EMP_16Plus,
                                         by = ~ Region * HH6 * M5,
                                         vartype = c("se","cvpct"), 
                                         conf.int = TRUE, 
                                         conf.lev = 0.95, 
                                         deff = TRUE, 
                                         na.rm = FALSE)
tmp_cvs_REG_URRU_SEX  


###  and reorder to match the order in the template

tmp_cvs_REG_URRU_SEX <-  tmp_cvs_REG_URRU_SEX[order(tmp_cvs_REG_URRU_SEX$Region,
                                                    tmp_cvs_REG_URRU_SEX$HH6,
                                                    tmp_cvs_REG_URRU_SEX$M5),]
tmp_cvs_REG_URRU_SEX 



# # 
# # ### Calculate the standard errors for by REGION and DISTRICT  
# # 
# # tmp_cvs_REG_DISTR        <-    svystatTM( design = calib_lfs,
# #                                          y = ~ EMP_15plus,
# #                                          by = ~ REGION * DISTRICT,
# #                                          vartype = c("se","cvpct"), 
# #                                          conf.int = TRUE, 
# #                                          conf.lev = 0.95, 
# #                                          deff = TRUE, 
# #                                          na.rm = FALSE)
# # tmp_cvs_REG_DISTR   
# # 
# 
# ###  and reorder to match the order in the template
# 
# tmp_cvs_REG_DISTR <-  tmp_cvs_REG_DISTR[order(tmp_cvs_REG_DISTR$REGION,
#                                               tmp_cvs_REG_DISTR$DISTRICT),]
# 
# tmp_cvs_REG_DISTR 



# 
# ### Calculate the standard errors for by REGION, TYPE OF LOCALITY (UR_RU) and SEX 
# 
# tmp_cvs_REG_DISTR_SEX        <-    svystatTM( design = calib_lfs,
#                                              y = ~ EMP_15plus,
#                                              by = ~ REGION * DISTRICT * SEX,
#                                              vartype = c("se","cvpct"), 
#                                              conf.int = TRUE, 
#                                              conf.lev = 0.95, 
#                                              deff = TRUE, 
#                                              na.rm = FALSE)
# tmp_cvs_REG_DISTR_SEX  
# 
# 
# ###  and reorder to match the order in the template
# 
# tmp_cvs_REG_DISTR_SEX <-  tmp_cvs_REG_DISTR_SEX[order(tmp_cvs_REG_DISTR_SEX$REGION,
#                                                       tmp_cvs_REG_DISTR_SEX$DISTRICT,
#                                                       tmp_cvs_REG_DISTR_SEX$SEX),]
# tmp_cvs_REG_DISTR_SEX 



#######   STEP 15   ###########################################################################################
###
###     PUT TOGHETHER ALL THE R TABLES CREATED ABOVE AND EXPORT TO EXCEL  
###
###############################################################################################################


# load the new library to use to function rbindlist (allows to put together tables that have different columns)


# install.packages("data.table")

library(data.table)

### PUT TOGETHER  put together all the tables containing standard errors, cvs etc
# help(rbindlist)

tmp_cvs_ALL    	 <-  rbindlist(list(	 tmp_cvs_TOT,
                                       tmp_cvs_SEX,
                                       tmp_cvs_AGE[tmp_cvs_AGE$GroupAge12>1,],
                                       tmp_cvs_URRU,
                                       tmp_cvs_URRU_SEX,
                                       tmp_cvs_REG,
                                       tmp_cvs_REG_SEX,
                                       tmp_cvs_REG_URRU,
                                       tmp_cvs_REG_URRU_SEX
                                       #tmp_cvs_REG_DISTR,
                                       #tmp_cvs_REG_DISTR_SEX
                                       ), fill = TRUE)
View(tmp_cvs_ALL) 



		
#######   STEP 16   ###########################################################################################
###
###    EXPORT THE STANDARD ERRORS AND CONFIDENCE INTERVALS IN CSV  
###
###############################################################################################################

write.csv(tmp_cvs_ALL, file = LFS_STD_ERR_EMP_LEVELS_CSV )



### The results is not satisfying. We can use a different option


#######   STEP 17   ###########################################################################################
###
###    EXPORT DATA FROM THE R TABLES TO EMPTY TEMPLATES IN EXCEL AND SAVE THE EXCEL FILE WITH A SPECIFIC 
###    NAME IN A SPECIFIC FOLDER.
###    THIS PROGRAM CAN BE PARAMETERIZED TO AUTOMATICALLY GENERATE TABLES IN EXCEL.
###
###    Step1: Prepare the table in R using the command above
###    Step2: Prepare the empty template in excel already formatted.
###    Step2: Use the code below to copy data within the empty template and save it.
###
###    Use the package "excel.link"

# install.packages("excel.link")

library(excel.link)


### COPY NUMBERS IN THE EXCEL TEMPLATE #####################


#############################################      OPEN EXCEL      #####################

xls = xl.get.excel()


#############################################      CLOSE THE DEFAULT SHEET #####################

xl.workbook.close(xl.workbook.name = NULL)


############################    OPEN THE EMPTY TEMPLATE ALREADY FORMATTED  #####################

xl.workbook.open(LFS_STD_ERR_EMP_LEVEL_TEMPLATE3_XLSX)


####################     SAVE WITH ANOTHER NAME IN A SPECIFIC FOLDER (CAN BE PARAMETERISED)     #####################

xl.workbook.save(LFS_TABLE_CVS_EMP_LEVEL_TEMPLATE3_XLSX)


######################      SET THE FIRST CELLS OF THE EMPTY TEMPLATE WHERE THE DATA WILL BE SAVED       #####################

firstcelldata = xls[["Activesheet"]]$Cells(7,4)


######################  WRITE DATA (NOT LABEL) TO THE RENAMED EMPTY TEMPLATE READING FROM THE DATAFRAME CONTAINTING THE R TABLE #####################

xl.write(as.data.frame(tmp_cvs_ALL)[,seq(2,7)], firstcelldata, row.names = FALSE,col.names = FALSE)


######################    WRITE THE NAME OF THE INDICATORS IN THE TABLE OF THE TABLE     #####################


### Define the cell where to write the name of the indicator
 
celltitle = xls[["Activesheet"]]$Cells(5,4)


### Write the name of the indicator

xl.write("Indicateurs", celltitle)


######################    WRITE THE REFERENCE PERIOD IN THE TABLE OF THE TABLE     #####################

### Define the cell where to write the reference period
 
cellrefper = xls[["Activesheet"]]$Cells(2,2)


### Write the reference period

xl.write(paste0(year,"_Q",quarter), cellrefper )

######################    WRITE THE TYPE OF CONSTRAINTS IN THE TABLE OF THE TABLE     #####################

### Define the cell where to write the reference period
 
cellconstr = xls[["Activesheet"]]$Cells(3,2)


### Write the reference period

xl.write(paste0("Constraints ",pathx), cellconstr )


######################      SAVE AGAIN THE EXCEL TABLE  #####################


xl.workbook.save(LFS_TABLE_CVS_EMP_LEVEL_TEMPLATE3_XLSX)


######################     CLOSE THE EXCEL TABLE  #####################

xl.workbook.close(xl.workbook.name = NULL)

