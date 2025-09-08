########################################################################################################################.
########################################################################################################################.
########################################################################################################################.
########                                                                                                        ########.
########           TRAINING ON STRATEGIES TO CALCULATE LFS SAMPLE WEIGHTS USING CALIBRATIONS                    ########.
########                                                                                                        ########.
########          PREPARED BY: ANTONIO R. DISCENZA - ILO DEPARTMENT OF STATISTICS - SSMU UNIT                   ########.
########                                    E.mail: discenza@ilo.org                                            ########.
########                                                                                                        ########.
########                                 CASE STUDY N. 6 - (136X_4D_ALLWR)                                      ########.
########                       CALIBRATION OF FINAL WEIGHTS USING R FOR ALL STEPS                               ########.
########                                                                                                        ########.
########        Version B:  Filenames, paths, reference periods and set of constraints are parameterized        ########.
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

load ( FILE_LFS_ILO_CAL_RDATA )

head(LFS_ILO_CAL)


#######   STEP 2   ###########################################################################################
###
###    Create labels for the variables SEX, AGE_GROUP7 and ilo_lfs  
###
##############################################################################################################


##### Groupes d'age au niveau région
LFS_ILO_CAL$AgeAnnee_interval[ LFS_ILO_CAL$AgeAnnee>=  0 & LFS_ILO_CAL$AgeAnnee <=14] = 1
LFS_ILO_CAL$AgeAnnee_interval[ LFS_ILO_CAL$AgeAnnee>=  15 ] = 2

##### Groupes d'age au niveau national
LFS_ILO_CAL$AgeAnnee_interval_nat[ LFS_ILO_CAL$AgeAnnee>=  0 & LFS_ILO_CAL$AgeAnnee <=14] = 1
LFS_ILO_CAL$AgeAnnee_interval_nat[  LFS_ILO_CAL$AgeAnnee>=  15 & LFS_ILO_CAL$AgeAnnee <=19] = 2
LFS_ILO_CAL$AgeAnnee_interval_nat[  LFS_ILO_CAL$AgeAnnee>=  20 & LFS_ILO_CAL$AgeAnnee <=24] = 3
LFS_ILO_CAL$AgeAnnee_interval_nat[  LFS_ILO_CAL$AgeAnnee>=  25 & LFS_ILO_CAL$AgeAnnee <=29] = 4
LFS_ILO_CAL$AgeAnnee_interval_nat[  LFS_ILO_CAL$AgeAnnee>=  30 & LFS_ILO_CAL$AgeAnnee <=34] = 5
LFS_ILO_CAL$AgeAnnee_interval_nat[  LFS_ILO_CAL$AgeAnnee>=  35 & LFS_ILO_CAL$AgeAnnee <=39] = 6
LFS_ILO_CAL$AgeAnnee_interval_nat[  LFS_ILO_CAL$AgeAnnee>=  40 & LFS_ILO_CAL$AgeAnnee <=44] = 7
LFS_ILO_CAL$AgeAnnee_interval_nat[  LFS_ILO_CAL$AgeAnnee>=  45 & LFS_ILO_CAL$AgeAnnee <=49] = 8
LFS_ILO_CAL$AgeAnnee_interval_nat[  LFS_ILO_CAL$AgeAnnee>=  50 & LFS_ILO_CAL$AgeAnnee <=54] = 9
LFS_ILO_CAL$AgeAnnee_interval_nat[  LFS_ILO_CAL$AgeAnnee>=  55 & LFS_ILO_CAL$AgeAnnee <=59] = 10
LFS_ILO_CAL$AgeAnnee_interval_nat[  LFS_ILO_CAL$AgeAnnee>=  60 & LFS_ILO_CAL$AgeAnnee <=64] = 11
LFS_ILO_CAL$AgeAnnee_interval_nat[  LFS_ILO_CAL$AgeAnnee>=  65] = 12


list_labels 	<- list( 
                      M5 = "Sexe",
				 	M5 = num_lab("1 1-Hommes 
                                     2 2-Femmes"),

                      AgeAnnee_interval = "Groupe d'age",
				 	AgeAnnee_interval = num_lab("1 1 - 0-14 
                                            2 2 - 15+"),
				 	
				 	AgeAnnee_interval_nat = "Groupe d'age",
				 	AgeAnnee_interval_nat = num_lab("1 1 - 0-14 
                                            2 2 - 15-19
                                            3 3 - 20-24
				 	                                  4 4 - 25-29
				 	                                  5 5 - 30-34
				 	                                  6 6 - 35-39
				 	                                  7 7 - 40-44
				 	                                  8 8 - 45-49
				 	                                  9 9 - 50-54
				 	                                  10 10 - 55-59
				 	                                  11 11 - 60-64
				 	                                  12 12 - 65+"),
				 	

				 	HH6 = "Milieu",
				 	HH6 = num_lab("1 1-Urbain 
                                         2 2-Rural" 
                                         )
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


# Au niveau region
tmp_TABLE_1 <-
  tmp_data_CAL_withlab %>%
  tab_cols(  list(M5,total(label="Hommes et Femmes"))    %nest%  list(HH6 ,total(label="Total Population"))  )  %>%
  tab_rows(      list(Region,total(label="Total National"))    %nest%    list(AgeAnnee_interval,total(label="Total Groupe d'age"))  ) %>%
  tab_weight(FINAL_WEIGHT) %>%
  tab_stat_sum () %>%
  tab_pivot() %>%
  as.data.frame()

head(tmp_TABLE_1)

View(tmp_TABLE_1)

tmp_TABLE_1

# Au niveau national

tmp_TABLE_2 <-
  tmp_data_CAL_withlab %>%
  tab_cols(  list(M5,total(label="Hommes et Femmes"))    %nest%  list(HH6 ,total(label="Total Population"))  )  %>%
  tab_rows(      list("NATIONAL")    %nest%    list(AgeAnnee_interval_nat,total(label="Total Groupe d'age"))  ) %>%
  tab_weight(FINAL_WEIGHT) %>%
  tab_stat_sum () %>%
  tab_pivot() %>%
  as.data.frame()

View(tmp_TABLE_2)







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

### SEE THE EXCEL TEMPLATE "Template_table_1.xlsx" 


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

xl.workbook.open( FILE_TEMPLATE_TABLE_1_XLSX )



######################      SET THE FIRST CELLS OF THE EMPTY TEMPLATE WHERE THE DATA WILL BE SAVED       #####################

firstcelldata = xls[["Activesheet"]]$Cells(5,6)
secondcelldata = xls[["Activesheet"]]$Cells(5,21)



######################  WRITE DATA (NOT LABEL) TO THE RENAMED EMPTY TEMPLATE READING FROM THE DATAFRAME CONTAINTING THE R TABLE #####################

xl.write(as.data.frame(tmp_TABLE_1)[, 2:ncol(tmp_TABLE_1)], firstcelldata, row.names = FALSE,col.names = FALSE)
xl.write(as.data.frame(tmp_TABLE_2)[, 2:ncol(tmp_TABLE_2)], secondcelldata, row.names = FALSE,col.names = FALSE)


######################    WRITE THE REFERENCE PERIOD IN THE TABLE OF THE TABLE     #####################

### Define the cell where to write the reference period
 
celltitle = xls[["Activesheet"]]$Cells(1,9)

### Write the reference period

xl.write(paste(year,"_T",quarter,sep=''), celltitle)


####################     SAVE WITH ANOTHER NAME IN A SPECIFIC FOLDER (CAN BE PARAMETERISED)     #####################

xl.workbook.save( FILE_TABLE_1_XLSX )



######################     CLOSE THE EXCEL TABLE  #####################

xl.workbook.close(xl.workbook.name = NULL)







