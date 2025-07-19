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
########                                        R Script 06                                                     ########.
########                                                                                                        ########.
########                                                PROGRAM TO                                              ########.     
########    1) PRODUCE A MULTIDIMENSIONAL "WEIGHTED" TABLE USING R (package "expss")                            ########.
########    2) SAVE THE TABLE IN AN R DATAFRAME                                                                 ########.
########    3) EXPORT DATA FROM R TABLE TO EMPTY TEMPLATE PREPARED IN ADVANCE IN EXCEL (package "excel.link")   ########.
########    4) SAVE THE RESULTING EXCEL FILE WITH A SPECIFIC NAME IN A SPECIFIC FOLDER                          ########.
########                                                                                                        ########.
########                 THIS PROGRAM CAN BE PARAMETERIZED TO AUTOMATICALLY GENERATE TABLES IN EXCEL            ########.
########                                                                                                        ########.
########        4 DOMAINS  (4 Regions)                                                                          ########.
########        24 CONSTRAINTS (X1 TO X24)                                                                      ########.
########              - Population by region, sex and 12 age groups    (X1 TO X24)                              ########.
########                                                                                                        ########.
########################################################################################################################.
########################################################################################################################.


#######   STEP 0   ###########################################################################################
###
###    Install and load the packages "expss" and "excel.link"    
###
##############################################################################################################

# install.packages("expss")
# install.packages("excel.link")

### load the packages

library(expss)
library(excel.link)


#######   STEP 1   ###########################################################################################
###
###    load the dataframe "CAL" containing "Derived variables" and "Final Weights"  
###
##############################################################################################################

load(file='D:/DOCUMENTS/CAE/Calibration/06032025/ILO_STAT_CALIBRATION_Delivery_2_2025_03_06/ILO_LFS_GSBPM/DATA/565_QUARTERLY_WEIGHTING/2021/Quarter1/24X_4D_ALLWR_np/LFS_ILO_2021_Q1_CAL.RData')

head(LFS_ILO_CAL)


#######   STEP 2   ###########################################################################################
###
###    Create labels for the variables SEX, AGE_GROUP7 and ilo_lfs  
###
##############################################################################################################

list_labels 	<- list( 
                      SEX = "Sex",
				 	            SEX = num_lab("1 1-Males 
                                     2 2-Females"),

                      AGE_GROUP7 = "Age in 7 groups",
				 	            AGE_GROUP7 = num_lab("1 1 - 0-14 
                                            2 2 - 15-24
                                            3 3 - 25-34
                                            4 4 - 35-44
                                            5 5 - 45-54
                                            6 6 - 55-64
                                            7 7 - 65+"),

				 	ilo_lfs = "Labour Status",
				 	ilo_lfs = num_lab("1 1-Employed 
                                         2 2-Unemployed 
                                         3 3-Outside Labour Force")
                     )
	




###    Apply label to the dataframe with the sample data and create a new temporary dataframe 
###    that will be used to prepare the tables

tmp_data_CAL_withlab = apply_labels(LFS_ILO_CAL, list_labels)

str(tmp_data_CAL_withlab)
 

#######   STEP 3   ###########################################################################################
###
###    CREATE THE WEIGHTED TABLE USING forward-pipe operator, %>%. (See "magrittr" package)
###
##############################################################################################################

### CREATE THE TABLE AND SAVE AS AN R OBJECT CALLED "tmp_TABLE_1"

tmp_TABLE_1 <-
tmp_data_CAL_withlab %>%
	tab_cols(  list(SEX,total(label="Males and Females"))    %nest%  list(ilo_lfs ,total(label="Total Population"))  )  %>%
        tab_rows(      list(REGION,total(label="Total Country"))    %nest%    list(AGE_GROUP7,total(label="Total Age Groups"))  ) %>%
	    			tab_weight(FINAL_WEIGHT) %>%
    		         	tab_stat_sum () %>%
         	    			tab_pivot() %>%
							as.data.frame()

head(tmp_TABLE_1)

View(tmp_TABLE_1)

tmp_TABLE_1





#######   STEP 4   ###########################################################################################
###
###    WE COULD EXPORT THE TABLE IN EXCEL BUT USUALLY THE FORMAT OF THE TABLE IS NOT USEFUL FOR PUBBLICATION  
###    SEE EXAMPLE BELOW
###
##############################################################################################################


#############################################      OPEN EXCEL      #####################

xls = xl.get.excel()


######################      SET THE FIRST CELLS OF THE EXCEL FILE WHERE THE TABLE WILL BE SAVED       #####################

firstcelldata = xls[["Activesheet"]]$Cells(1,1)


######################  WRITE THE TABLE IN THE EXCEL FILE #####################

xl.write(as.data.frame(tmp_TABLE_1),xls[["Activesheet"]]$Cells(1,1))


###  NOTE: THIS METHOD IS NOT SATISFYING. THE NEXT METHOD IS MUCH MORE EFFICIENT




#######   STEP 4   ###########################################################################################
###
###    CREATE AN EMPTY TEMPLATE FOR THE TABLE IN EXCEL ALREADY FORMATTES AS NEEDED FOR DISSEMINATION
###
##############################################################################################################

### SEE THE EXCEL TEMPLATE "Template_table_1.xlsx" IN FOLDER 
### "W:/ILO_LFS_GSBPM/PROG/565_QUARTERLY_WEIGHTING/2021/Quarter1/24X_4D_ALLWR_np"


#######   STEP 5   ###########################################################################################
###
###    EXPORT DATA (ONLY THE NUMBERS) FROM THE R TABLES TO THE RELATED 
###    SAVE THE EXCEL FILE WITH A SPECIFIC NAME IN A SPECIFIC FOLDER.
###
##############################################################################################################


#############################################      OPEN EXCEL      #####################

xls = xl.get.excel()


#############################################      CLOSE THE DEFAULT SHEET #####################

xl.workbook.close(xl.workbook.name = NULL)



############################    OPEN THE EMPTY TEMPLATE ALREADY FORMATTED  #####################

xl.workbook.open("D:/DOCUMENTS/CAE/Calibration/06032025/ILO_STAT_CALIBRATION_Delivery_2_2025_03_06/ILO_LFS_GSBPM/PROG/565_QUARTERLY_WEIGHTING/2021/Quarter1/24X_4D_ALLWR_np/Template_table_1.xlsx")



######################      SET THE FIRST CELLS OF THE EMPTY TEMPLATE WHERE THE DATA WILL BE SAVED       #####################

firstcelldata = xls[["Activesheet"]]$Cells(5,4)



######################  WRITE DATA (NOT LABEL) TO THE RENAMED EMPTY TEMPLATE READING FROM THE DATAFRAME CONTAINTING THE R TABLE #####################

xl.write(as.data.frame(tmp_TABLE_1)[,seq(2,13)], firstcelldata, row.names = FALSE,col.names = FALSE)



######################    WRITE THE REFERENCE PERIOD IN THE TABLE OF THE TABLE     #####################

### Define the cell where to write the reference period
 
celltitle = xls[["Activesheet"]]$Cells(1,9)

### Write the reference period

xl.write("2021 Quarter 1", celltitle)



####################     SAVE WITH ANOTHER NAME IN A SPECIFIC FOLDER (CAN BE PARAMETERISED)     #####################

xl.workbook.save("D:/DOCUMENTS/CAE/Calibration/06032025/ILO_STAT_CALIBRATION_Delivery_2_2025_03_06/ILO_LFS_GSBPM/DATA/565_QUARTERLY_WEIGHTING/2021/Quarter1/24X_4D_ALLWR_np/Table_1_2021_Q1_24X_4D_ALLWR_np.xlsx")


######################     CLOSE THE EXCEL TABLE  #####################

xl.workbook.close(xl.workbook.name = NULL)







