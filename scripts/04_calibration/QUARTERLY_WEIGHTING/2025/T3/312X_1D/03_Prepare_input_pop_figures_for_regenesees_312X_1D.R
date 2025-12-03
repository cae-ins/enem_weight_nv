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
########                                        R Script 03                                                     ########.
########                                                                                                        ########.
########        PROGRAM TO PREPARE THE INPUT "KNOWN TOTALS" FOR FINAL CALIBRATION USING REGENESEES              ########.
########                                                                                                        ########.
########        1 DOMAINS  (33 Regions)                                                                         ########.
########        312 CONSTRAINTS (X1 TO X312)                                                                    ########.
########              - Population by sex and urban and rural and 12 age groups    (X1 TO X48)                  ########.
########              - Population by region, urban and rural, sex and 2 age groups  (X49 TO X312)              ########.    
########                                                                                                        ########.
########        NOTE THAT POPULATION DATA TO FILL THE THRE SUBSETS OF CONSTRAINTS                               ########.
########        ARE STORED IN DIFFERENT EXCEL FILES (OR RDATA FILES)                                            ########.
########        THEREFORE, THEY ARE RECODED HERE SEPARATELY AND THE MERGED TOGETHER TO CREATE A UNIQUE          ########.
########        FILE WITH THE 136 "KNOWN TOTALS" FOR FINAL CALIBRATION USING REGENESEES                         ########.
########                                                                                                        ########.
########################################################################################################################.
########################################################################################################################.


######################################################################################################
###  
###   STEP 3.1 - SET THE WORKING DIRECTORY WHERE THE OUPUTS WILL BE STORED 
### 
######################################################################################################

getwd()
setwd(dir_data_QW)
getwd()


######################################################################################################
###  
###   STEP 3.2 - LOAD THE INPUT DATAFRAME CONTAINING THE POPULATION FIGURES FROM FOLDER 560  
### 
###              BY REGION, SEX AND 12 AGE GROUPS   
###
######################################################################################################

### Load the R dataframe called "POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR" stored on disk in the RData file identified by the macro variable "FILE_POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_RDATA"

load(FILE_POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR_RDATA)


### Check that the dataframe "POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR" has been loaded


str(POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR)


View(POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR)




### Create a new dataframe that will be renamed at the end of the steps as LFS_KNOWN_TOTALS_2021_Q1_24X_4D
### Working on the new dataframe will help to avoid possible unwanted modifications/errors on the original dataset.
### The shorter name will help when we have to write the code. The prefix tmp will help to recognize that is a temporary
### dataframe that does not need to be saved permanently on disk  

tmpKT <- POP_LFS_BY_REGION_URBAIN_RURAL_SEX_2AGEGR

head(tmpKT )



######################################################################################################
###  
###   STEP 3.3 - CREATE THE VARIABLE "DOMAIN" THAT IDENTIFIES THE DOMAIN OF ESTIMATION   
### 
######################################################################################################

tmpKT$DOMAIN <- as.character(tmpKT$Domain)

#  View(tmpKT)

#  names(tmpKT)

######################################################################################################
###  
###   STEP 3.4 - CALCULATE THE SET OF 24 X VARIABLES (containing the population figures)  
### 
######################################################################################################

#tmpKT <- cbind( tmpKT , data.frame(matrix(0 , nrow = nrow(tmpKT), ncol =  24, byrow = FALSE)))
tmpKT <- cbind( tmpKT , data.frame(matrix(0 , nrow = nrow(tmpKT), ncol =  xnum, byrow = FALSE)))

View(tmpKT)



###   We are creating the X starting from the variable already in the dataframe 

tmpKT$X1[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "0_14" & tmpKT$Sexe == 1  & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "0_14"& tmpKT$Sexe == 1  & tmpKT$Milieu == 1 ]
tmpKT$X2[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "15_19" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "15_19"& tmpKT$Sexe == 1  & tmpKT$Milieu == 1 ]
tmpKT$X3[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "20_24" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "20_24"& tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ]
tmpKT$X4[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "25_29" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "25_29"& tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ]
tmpKT$X5[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "30_34" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "30_34"& tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ]
tmpKT$X6[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "35_39" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "35_39"& tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ]
tmpKT$X7[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "40_44" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "40_44"& tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ]
tmpKT$X8[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "45_49" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "45_49"& tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ]
tmpKT$X9[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "50_54" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "50_54"& tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ]
tmpKT$X10[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "55_59" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "55_59"& tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ]
tmpKT$X11[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "60_64" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "60_64"& tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ]
tmpKT$X12[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "65_plus" & tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "65_plus"& tmpKT$Sexe == 1 & tmpKT$Milieu == 1 ]
tmpKT$X13[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "0_14" & tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "0_14"& tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ]
tmpKT$X14[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "15_19" & tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "15_19"& tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ]
tmpKT$X15[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "20_24" & tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "20_24"& tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ]
tmpKT$X16[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "25_29" & tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "25_29"& tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ]
tmpKT$X17[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "30_34" & tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "30_34"& tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ]
tmpKT$X18[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "35_39" & tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "35_39"& tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ]
tmpKT$X19[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "40_44" & tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "40_44"& tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ]
tmpKT$X20[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "45_49" & tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "45_49"& tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ]
tmpKT$X21[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "50_54" & tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "50_54"& tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ]
tmpKT$X22[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "55_59" & tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "55_59"& tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ]
tmpKT$X23[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "60_64" & tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "60_64"& tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ]
tmpKT$X24[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "65_plus" & tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "65_plus"& tmpKT$Sexe == 1 & tmpKT$Milieu == 2 ]
tmpKT$X25[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "0_14" & tmpKT$Sexe == 2  & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "0_14"& tmpKT$Sexe == 2  & tmpKT$Milieu == 1 ]
tmpKT$X26[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "15_19" & tmpKT$Sexe == 2  & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "15_19"& tmpKT$Sexe == 2  & tmpKT$Milieu == 1 ]
tmpKT$X27[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "20_24" & tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "20_24"& tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ]
tmpKT$X28[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "25_29" & tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "25_29"& tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ]
tmpKT$X29[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "30_34" & tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "30_34"& tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ]
tmpKT$X30[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "35_39" & tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "35_39"& tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ]
tmpKT$X31[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "40_44" & tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "40_44"& tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ]
tmpKT$X32[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "45_49" & tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "45_49"& tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ]
tmpKT$X33[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "50_54" & tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "50_54"& tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ]
tmpKT$X34[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "55_59" & tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "55_59"& tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ]
tmpKT$X35[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "60_64" & tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "60_64"& tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ]
tmpKT$X36[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "65_plus" & tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "65_plus"& tmpKT$Sexe == 2 & tmpKT$Milieu == 1 ]
tmpKT$X37[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "0_14" & tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "0_14"& tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ]
tmpKT$X38[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "15_19" & tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "15_19"& tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ]
tmpKT$X39[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "20_24" & tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "20_24"& tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ]
tmpKT$X40[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "25_29" & tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "25_29"& tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ]
tmpKT$X41[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "30_34" & tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "30_34"& tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ]
tmpKT$X42[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "35_39" & tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "35_39"& tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ]
tmpKT$X43[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "40_44" & tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "40_44"& tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ]
tmpKT$X44[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "45_49" & tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "45_49"& tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ]
tmpKT$X45[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "50_54" & tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "50_54"& tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ]
tmpKT$X46[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "55_59" & tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "55_59"& tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ]
tmpKT$X47[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "60_64" & tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "60_64"& tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ]
tmpKT$X48[ tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "65_plus" & tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ] = tmpKT$Nombre[tmpKT$`Région (33)` == "NATIONAL" & tmpKT$groupe_age == "65_plus"& tmpKT$Sexe == 2 & tmpKT$Milieu == 2 ]



tmpKT$X49[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X50[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X51[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X52[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X53[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X54[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X55[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X56[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X57[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X58[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X59[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X60[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X61[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X62[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X63[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X64[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X65[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X66[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X67[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X68[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X69[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X70[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X71[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X72[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X73[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X74[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X75[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X76[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X77[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X78[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X79[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X80[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X81[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X82[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X83[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X84[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X85[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X86[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X87[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X88[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X89[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X90[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X91[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X92[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X93[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X94[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X95[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X96[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X97[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X98[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X99[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X100[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X101[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X102[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X103[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X104[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X105[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X106[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X107[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X108[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X109[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X110[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X111[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X112[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X113[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X114[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X115[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X116[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X117[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X118[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X119[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X120[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X121[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X122[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X123[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X124[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X125[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X126[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X127[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X128[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X129[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X130[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X131[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X132[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X133[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X134[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X135[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X136[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X137[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X138[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X139[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X140[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X141[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X142[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X143[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X144[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X145[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X146[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X147[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X148[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X149[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X150[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X151[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X152[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X153[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X154[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X155[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X156[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X157[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X158[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X159[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X160[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X161[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X162[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X163[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X164[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X165[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X166[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X167[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X168[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X169[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X170[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X171[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X172[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X173[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X174[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X175[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X176[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X177[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X178[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X179[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X180[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X181[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X182[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X183[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X184[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X185[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X186[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X187[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X188[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X189[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X190[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X191[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X192[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X193[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X194[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X195[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X196[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X197[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X198[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X199[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X200[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X201[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X202[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X203[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X204[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X205[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X206[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X207[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X208[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X209[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X210[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X211[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X212[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X213[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X214[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X215[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X216[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X217[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X218[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X219[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X220[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X221[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X222[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X223[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X224[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X225[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X226[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X227[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X228[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X229[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X230[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X231[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X232[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X233[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X234[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X235[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X236[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X237[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X238[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X239[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X240[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X241[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X242[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X243[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X244[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X245[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X246[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X247[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X248[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X249[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X250[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X251[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X252[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X253[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X254[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X255[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X256[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X257[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X258[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X259[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X260[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X261[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X262[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X263[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X264[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X265[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X266[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X267[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X268[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X269[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X270[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X271[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X272[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X273[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X274[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X275[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X276[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X277[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X278[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X279[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X280[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X281[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X282[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X283[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X284[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X285[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X286[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X287[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X288[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X289[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X290[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X291[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X292[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X293[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X294[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X295[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X296[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X297[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X298[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X299[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X300[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X301[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X302[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X303[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X304[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X305[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X306[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X307[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X308[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X309[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X310[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X311[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X312[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]


### Create a list of the first 24 Xs to retain to be used in the next steps (useful when we have a huge number of X)

list_of_X  <- paste(rep("X",xnum),seq(1,xnum),sep="")
list_of_X 

######################################################################################################
###  
###   STEP 3.5 - CREATE AN OBJECT CONTAING THE LIST OF Xs TO RETAIN TO BE USED IN THE NEXT STEPS  
### 
######################################################################################################

### Create a list of the first 24 Xs to retain to be used in the next steps (useful when we have a huge number of X)

# list_of_X  <- paste(rep("X",24),seq(1,24),sep="")
# list_of_X 


######################################################################################################
###  
###   STEP 3.6 - SUMMARIZE BY DOMAIN TO SAVE IN A DATAFRAME THE KNOWN TOTALS FOR EACH X  
### 
######################################################################################################

# tmpKT1 <- aggregate(   x = tmpKT1[, list_of_X], 
#                       by = list(DOMAIN = tmpKT1$DOMAIN), 
#                      FUN = sum)
#  View(tmpKT1)

### check also the total

# sum(tmpKT1[,list_of_X ])




######################################################################################################
######################################################################################################
######################################################################################################
###  
###   STEP 3.7 - LOAD THE INPUT DATAFRAME CONTAINING THE POPULATION FIGURES FROM FOLDER 560  
### 
###              BY REGION, URBAN AND RURAL, SEX AND 7 AGE GROUPS   
###
######################################################################################################


### Load the R dataframe called "POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert" stored on disk in the RData file identified by the macro variable "FILE_POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert_RDATA"

#load(file="W:/2023_ILO_ITC_WEIGHTING/LFS_GSBPM_SW/DATA/560_POPULATION_ESTIMATES/2021/Quarter1/POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGR_2021_Q1vert.RData")
# load(file=FILE_POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert_RDATA)

### Check that the dataframe that has been loaded

# str(POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert)

#  View(POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert)

### Create a new dataframe that will be renamed at the end of the steps as LFS_KNOWN_TOTALS_2021_Q1_24X_4D
### Working on the new dataframe will help to avoid possible unwanted modifications/errors on the original dataset.
### The shorter name will help when we have to write the code. The prefix tmp will help to recognize that is a temporary
### dataframe that does not need to be saved permanently on disk  

# tmpKT2 <- POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert
# 
# head(tmpKT2 )


######################################################################################################
###  
###   STEP 3.8 - CREATE THE VARIABLE "DOMAIN" THAT IDENTIFIES THE DOMAIN OF ESTIMATION   
### 
######################################################################################################

# tmpKT2$DOMAIN <- as.character(tmpKT2$REGION)


######################################################################################################
###  
###   STEP 3.9 - CALCULATE THE SET OF VARIABLES X25 TO X52 (containing the population figures)  
### 
######################################################################################################


###    Create the X variables and initialize them to 0    


# tmpKT2 <- cbind( tmpKT2 , data.frame(matrix(0 , nrow = nrow(tmpKT2), ncol =  52, byrow = FALSE)))

##  MALES IN URBAN LOCATION by 7 AGE GROUPS 

# tmpKT2$X25 <- ifelse( tmpKT2$AGE_GROUP7 == 1 & tmpKT2$SEX==1 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0) 
# tmpKT2$X26 <- ifelse( tmpKT2$AGE_GROUP7 == 2 & tmpKT2$SEX==1 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X27 <- ifelse( tmpKT2$AGE_GROUP7 == 3 & tmpKT2$SEX==1 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X28 <- ifelse( tmpKT2$AGE_GROUP7 == 4 & tmpKT2$SEX==1 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X29 <- ifelse( tmpKT2$AGE_GROUP7 == 5 & tmpKT2$SEX==1 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X30 <- ifelse( tmpKT2$AGE_GROUP7 == 6 & tmpKT2$SEX==1 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X31 <- ifelse( tmpKT2$AGE_GROUP7 == 7 & tmpKT2$SEX==1 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0)

###  FEMALES IN URBAN  LOCATION by 7 AGE GROUPS                                                            

# tmpKT2$X32 <- ifelse( tmpKT2$AGE_GROUP7 == 1 & tmpKT2$SEX==2 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X33 <- ifelse( tmpKT2$AGE_GROUP7 == 2 & tmpKT2$SEX==2 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X34 <- ifelse( tmpKT2$AGE_GROUP7 == 3 & tmpKT2$SEX==2 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X35 <- ifelse( tmpKT2$AGE_GROUP7 == 4 & tmpKT2$SEX==2 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X36 <- ifelse( tmpKT2$AGE_GROUP7 == 5 & tmpKT2$SEX==2 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0) 
# tmpKT2$X37 <- ifelse( tmpKT2$AGE_GROUP7 == 6 & tmpKT2$SEX==2 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X38 <- ifelse( tmpKT2$AGE_GROUP7 == 7 & tmpKT2$SEX==2 & tmpKT2$UR_RU==1 , tmpKT2$POPULATION_FIGURES , 0)


###  MALES IN RURAL L OCATION by 7 AGE GROUPS                                                              

# tmpKT2$X39 <- ifelse( tmpKT2$AGE_GROUP7 == 1 & tmpKT2$SEX==1 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X40 <- ifelse( tmpKT2$AGE_GROUP7 == 2 & tmpKT2$SEX==1 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X41 <- ifelse( tmpKT2$AGE_GROUP7 == 3 & tmpKT2$SEX==1 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X42 <- ifelse( tmpKT2$AGE_GROUP7 == 4 & tmpKT2$SEX==1 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X43 <- ifelse( tmpKT2$AGE_GROUP7 == 5 & tmpKT2$SEX==1 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0) 
# tmpKT2$X44 <- ifelse( tmpKT2$AGE_GROUP7 == 6 & tmpKT2$SEX==1 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0) 
# tmpKT2$X45 <- ifelse( tmpKT2$AGE_GROUP7 == 7 & tmpKT2$SEX==1 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0) 

###  FEMALES IN RURAL  LOCATION by 7 AGE GROUPS                                                            

# tmpKT2$X46 <- ifelse( tmpKT2$AGE_GROUP7 == 1 & tmpKT2$SEX==2 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X47 <- ifelse( tmpKT2$AGE_GROUP7 == 2 & tmpKT2$SEX==2 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X48 <- ifelse( tmpKT2$AGE_GROUP7 == 3 & tmpKT2$SEX==2 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X49 <- ifelse( tmpKT2$AGE_GROUP7 == 4 & tmpKT2$SEX==2 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X50 <- ifelse( tmpKT2$AGE_GROUP7 == 5 & tmpKT2$SEX==2 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X51 <- ifelse( tmpKT2$AGE_GROUP7 == 6 & tmpKT2$SEX==2 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0)
# tmpKT2$X52 <- ifelse( tmpKT2$AGE_GROUP7 == 7 & tmpKT2$SEX==2 & tmpKT2$UR_RU==2 , tmpKT2$POPULATION_FIGURES , 0) 

#  View(tmpKT2)



######################################################################################################
###  
###   STEP 3.10 - CREATE AN OBJECT CONTAING THE LIST OF Xs TO RETAIN TO BE USED IN THE NEXT STEPS  
### 
######################################################################################################

### Create a list of the Xs (from X25 TO X52 ) to retain to be used in the next steps (useful when we have a huge number of X)

# list_of_X  <- paste(rep("X",28),seq(25,52),sep="")
# list_of_X 


######################################################################################################
###  
###   STEP 3.11 - SUMMARIZE BY DOMAIN TO SAVE IN A DATAFRAME THE KNOWN TOTALS FOR EACH X FROM X25 TO X52  
### 
######################################################################################################

# tmpKT2 <- aggregate(   x = tmpKT2[, list_of_X], 
#                       by = list(DOMAIN = tmpKT2$DOMAIN), 
#                      FUN = sum)
#  View(tmpKT2)

### check also the total

# sum(tmpKT2[,list_of_X ])




######################################################################################################
######################################################################################################
######################################################################################################
###  
###   STEP 3.12 - LOAD THE INPUT DATAFRAME CONTAINING THE POPULATION FIGURES FROM FOLDER 560  
### 
###              BY REGION, URBAN AND RURAL, SEX AND 7 AGE GROUPS   
###
######################################################################################################


### Create a new dataframe that will be renamed at the end 
### Working on the new dataframe will help to avoid possible unwanted modifications/errors on the original dataset.
### The shorter name will help when we have to write the code. The prefix tmp will help to recognize that is a temporary
### dataframe that does not need to be saved permanently on disk  

# tmpKT3 <- POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert
# 
# head(tmpKT3 )


######################################################################################################
###  
###   STEP 3.13 - CREATE THE VARIABLE "DOMAIN" THAT IDENTIFIES THE DOMAIN OF ESTIMATION   
### 
######################################################################################################

# tmpKT3$DOMAIN <- as.character(tmpKT3$REGION)


######################################################################################################
###  
###   STEP 3.14 - CALCULATE THE SET OF VARIABLES X53 TO X94 (containing the population figures)  
### 
######################################################################################################

###    Create the X variables and initialize them to 0    

# tmpKT3 <- cbind( tmpKT3 , data.frame(matrix(0 , nrow = nrow(tmpKT3), ncol =  94, byrow = FALSE)))


### Create a list of the 42 Xs from X25 TO X52 to retain and to be used in the next steps (useful when we have a huge number of X)

# list_of_X  <- paste(rep("X",42),seq(53,94),sep="")
# list_of_X 


###  CREATE THE SEQUENCE FOR THE DISTRICTS WITHIN REGIONS FOR CALIBRATION

# tmpKT3$DISTRICT_SEQ_CALIB <- 0
# 
# tmpKT3$DISTRICT_SEQ_CALIB[tmpKT3$REGION=="1" & tmpKT3$DISTRICT=="1"] <- 1
# tmpKT3$DISTRICT_SEQ_CALIB[tmpKT3$REGION=="1" & tmpKT3$DISTRICT=="2"] <- 2
# 
# tmpKT3$DISTRICT_SEQ_CALIB[tmpKT3$REGION=="2" & tmpKT3$DISTRICT=="3"] <- 1
# tmpKT3$DISTRICT_SEQ_CALIB[tmpKT3$REGION=="2" & tmpKT3$DISTRICT=="4"] <- 2
# tmpKT3$DISTRICT_SEQ_CALIB[tmpKT3$REGION=="2" & tmpKT3$DISTRICT=="5"] <- 3
# 
# tmpKT3$DISTRICT_SEQ_CALIB[tmpKT3$REGION=="3" & tmpKT3$DISTRICT=="6"] <- 1
# tmpKT3$DISTRICT_SEQ_CALIB[tmpKT3$REGION=="3" & tmpKT3$DISTRICT=="7"] <- 2
# 
# tmpKT3$DISTRICT_SEQ_CALIB[tmpKT3$REGION=="4" & tmpKT3$DISTRICT=="8"] <- 1


### LET's CHECK IF THE ASSIGNMENT WORKED

# tmp_check <- aggregate(  x = tmpKT3[,"POPULATION_FIGURES"], 
#                          by = list(DOMAIN = tmpKT3$DOMAIN, REGION = tmpKT3$REGION, DISTRICT = tmpKT3$DISTRICT, DISTRICT_SEQ_CALIB = tmpKT3$DISTRICT_SEQ_CALIB ), 
#                          FUN = sum)
#  View(tmp_check)


###  MALES IN THE FIRST DISTRICT OF ALL REGIONS by 7 AGE GROUPS 

# tmpKT3$X53 <- ifelse( tmpKT3$AGE_GROUP7 == 1 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0) 
# tmpKT3$X54 <- ifelse( tmpKT3$AGE_GROUP7 == 2 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X55 <- ifelse( tmpKT3$AGE_GROUP7 == 3 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X56 <- ifelse( tmpKT3$AGE_GROUP7 == 4 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X57 <- ifelse( tmpKT3$AGE_GROUP7 == 5 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X58 <- ifelse( tmpKT3$AGE_GROUP7 == 6 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X59 <- ifelse( tmpKT3$AGE_GROUP7 == 7 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0)

###  FEMALES IN THE FIRST DISTRICT OF ALL REGIONS by 7 AGE GROUPS 

# tmpKT3$X60 <- ifelse( tmpKT3$AGE_GROUP7 == 1 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X61 <- ifelse( tmpKT3$AGE_GROUP7 == 2 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X62 <- ifelse( tmpKT3$AGE_GROUP7 == 3 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X63 <- ifelse( tmpKT3$AGE_GROUP7 == 4 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X64 <- ifelse( tmpKT3$AGE_GROUP7 == 5 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0) 
# tmpKT3$X65 <- ifelse( tmpKT3$AGE_GROUP7 == 6 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X66 <- ifelse( tmpKT3$AGE_GROUP7 == 7 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==1 , tmpKT3$POPULATION_FIGURES , 0)

### LET'S CHECK IF THAT WORKED

# tmp_check <- aggregate(  x = tmpKT3[, list_of_X], 
#                          by = list(DOMAIN = tmpKT3$DOMAIN), 
#                          FUN = sum)

#  View(tmp_check)

###  MALES IN THE SECOND DISTRICT OF ALL REGIONS by 7 AGE GROUPS 

# tmpKT3$X67 <- ifelse( tmpKT3$AGE_GROUP7 == 1 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X68 <- ifelse( tmpKT3$AGE_GROUP7 == 2 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X69 <- ifelse( tmpKT3$AGE_GROUP7 == 3 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X70 <- ifelse( tmpKT3$AGE_GROUP7 == 4 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X71 <- ifelse( tmpKT3$AGE_GROUP7 == 5 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0) 
# tmpKT3$X72 <- ifelse( tmpKT3$AGE_GROUP7 == 6 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0) 
# tmpKT3$X73 <- ifelse( tmpKT3$AGE_GROUP7 == 7 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0) 


###  FEMALES IN THE SECOND DISTRICT OF ALL REGIONS by 7 AGE GROUPS 

# tmpKT3$X74 <- ifelse( tmpKT3$AGE_GROUP7 == 1 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X75 <- ifelse( tmpKT3$AGE_GROUP7 == 2 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X76 <- ifelse( tmpKT3$AGE_GROUP7 == 3 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X77 <- ifelse( tmpKT3$AGE_GROUP7 == 4 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X78 <- ifelse( tmpKT3$AGE_GROUP7 == 5 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X79 <- ifelse( tmpKT3$AGE_GROUP7 == 6 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X80 <- ifelse( tmpKT3$AGE_GROUP7 == 7 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==2 , tmpKT3$POPULATION_FIGURES , 0) 

### LET'S CHECK IF THAT WORKED

# tmp_check <- aggregate(  x = tmpKT3[, list_of_X], 
#                          by = list(DOMAIN = tmpKT3$DOMAIN), 
#                          FUN = sum)

#  View(tmp_check)


###  MALES IN THE FIRST DISTRICT OF ALL REGIONS by 7 AGE GROUPS 

# tmpKT3$X81 <- ifelse( tmpKT3$AGE_GROUP7 == 1 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0) 
# tmpKT3$X82 <- ifelse( tmpKT3$AGE_GROUP7 == 2 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X83 <- ifelse( tmpKT3$AGE_GROUP7 == 3 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X84 <- ifelse( tmpKT3$AGE_GROUP7 == 4 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X85 <- ifelse( tmpKT3$AGE_GROUP7 == 5 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X86 <- ifelse( tmpKT3$AGE_GROUP7 == 6 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X87 <- ifelse( tmpKT3$AGE_GROUP7 == 7 & tmpKT3$SEX==1 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0)

###  FEMALES IN THE FIRST DISTRICT OF ALL REGIONS by 7 AGE GROUPS 

# tmpKT3$X88 <- ifelse( tmpKT3$AGE_GROUP7 == 1 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X89 <- ifelse( tmpKT3$AGE_GROUP7 == 2 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X90 <- ifelse( tmpKT3$AGE_GROUP7 == 3 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X91 <- ifelse( tmpKT3$AGE_GROUP7 == 4 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X92 <- ifelse( tmpKT3$AGE_GROUP7 == 5 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0) 
# tmpKT3$X93 <- ifelse( tmpKT3$AGE_GROUP7 == 6 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0)
# tmpKT3$X94 <- ifelse( tmpKT3$AGE_GROUP7 == 7 & tmpKT3$SEX==2 & tmpKT3$DISTRICT_SEQ_CALIB==3 , tmpKT3$POPULATION_FIGURES , 0)



### LET'S CHECK IF THAT WORKED

# tmp_check <- aggregate(  x = tmpKT3[, list_of_X], 
#                          by = list(DOMAIN = tmpKT3$DOMAIN), 
#                          FUN = sum)

#  View(tmp_check)


######################################################################################################
###  
###   STEP 3.15 - SUMMARIZE BY DOMAIN TO SAVE IN A DATAFRAME THE KNOWN TOTALS FOR EACH X FROM X25 TO X52  
### 
######################################################################################################

# tmpKT3 <- aggregate(   x = tmpKT3[, list_of_X], 
#                        by = list(DOMAIN = tmpKT3$DOMAIN), 
#                        FUN = sum)
#  View(tmpKT3)

### check also the total and consistency withth eother sets of constraints

# sum(tmpKT3[,list_of_X ])





######################################################################################################
######################################################################################################
######################################################################################################
###  
###   STEP 3.16 - LOAD THE INPUT DATAFRAME CONTAINING THE POPULATION FIGURES FROM FOLDER 560  
### 
###              BY REGION, URBAN AND RURAL, SEX AND 7 AGE GROUPS   
###
######################################################################################################


### Create the dataframe with the population by region, month sex and age_group7

# tmpKT4 <- POP_LFS_BY_DISTRICT_URRU_SEX_7AGEGRvert
# 
# head(tmpKT4 )


######################################################################################################
###  
###   STEP 3.17 - CREATE THE VARIABLE "DOMAIN" THAT IDENTIFIES THE DOMAIN OF ESTIMATION   
### 
######################################################################################################

# tmpKT4$DOMAIN <- as.character(tmpKT4$REGION)


######################################################################################################
###  
###   STEP 3.18 - CALCULATE THE SET OF VARIABLES X95 TO X136 (containing the population figures by month)  
### 
######################################################################################################

###    Create the X variables and initialize them to 0    

# tmpKT4 <- cbind( tmpKT4 , data.frame(matrix(0 , nrow = nrow(tmpKT4), ncol =  136, byrow = FALSE)))


### Create a list of the 42 Xs from X25 TO X52 to retain and to be used in the next steps (useful when we have a huge number of X)

# list_of_X  <- paste(rep("X",42),seq(95,136),sep="")
# list_of_X 





###  MALES IN THE FIRST MONTH OF ALL REGIONS by 7 AGE GROUPS 

# tmpKT4$X95  <- ifelse( tmpKT4$AGE_GROUP7 == 1 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0) 
# tmpKT4$X96  <- ifelse( tmpKT4$AGE_GROUP7 == 2 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X97  <- ifelse( tmpKT4$AGE_GROUP7 == 3 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X98  <- ifelse( tmpKT4$AGE_GROUP7 == 4 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X99  <- ifelse( tmpKT4$AGE_GROUP7 == 5 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X100 <- ifelse( tmpKT4$AGE_GROUP7 == 6 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X101 <- ifelse( tmpKT4$AGE_GROUP7 == 7 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)

###  FEMALES IN THE FIRST MONTH OF ALL REGIONS by 7 AGE GROUPS 

# tmpKT4$X102 <- ifelse( tmpKT4$AGE_GROUP7 == 1 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X103 <- ifelse( tmpKT4$AGE_GROUP7 == 2 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X104 <- ifelse( tmpKT4$AGE_GROUP7 == 3 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X105 <- ifelse( tmpKT4$AGE_GROUP7 == 4 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X106 <- ifelse( tmpKT4$AGE_GROUP7 == 5 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0) 
# tmpKT4$X107 <- ifelse( tmpKT4$AGE_GROUP7 == 6 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X108 <- ifelse( tmpKT4$AGE_GROUP7 == 7 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)

### LET'S CHECK IF THAT WORKED

# tmp_check <- aggregate(  x = tmpKT4[, list_of_X], 
#                          by = list(DOMAIN = tmpKT4$DOMAIN), 
#                          FUN = sum)

#  View(tmp_check)

###  MALES IN THE SECOND MONTH OF ALL REGIONS by 7 AGE GROUPS 

# tmpKT4$X109 <- ifelse( tmpKT4$AGE_GROUP7 == 1 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X110 <- ifelse( tmpKT4$AGE_GROUP7 == 2 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X111 <- ifelse( tmpKT4$AGE_GROUP7 == 3 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X112 <- ifelse( tmpKT4$AGE_GROUP7 == 4 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X113 <- ifelse( tmpKT4$AGE_GROUP7 == 5 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0) 
# tmpKT4$X114 <- ifelse( tmpKT4$AGE_GROUP7 == 6 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0) 
# tmpKT4$X115 <- ifelse( tmpKT4$AGE_GROUP7 == 7 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0) 


###  FEMALES IN THE SECOND MONTH OF ALL REGIONS by 7 AGE GROUPS 

# tmpKT4$X116 <- ifelse( tmpKT4$AGE_GROUP7 == 1 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X117 <- ifelse( tmpKT4$AGE_GROUP7 == 2 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X118 <- ifelse( tmpKT4$AGE_GROUP7 == 3 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X119 <- ifelse( tmpKT4$AGE_GROUP7 == 4 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X120 <- ifelse( tmpKT4$AGE_GROUP7 == 5 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X121 <- ifelse( tmpKT4$AGE_GROUP7 == 6 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X122 <- ifelse( tmpKT4$AGE_GROUP7 == 7 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0) 

### LET'S CHECK IF THAT WORKED

# tmp_check <- aggregate(  x = tmpKT4[, list_of_X], 
#                          by = list(DOMAIN = tmpKT4$DOMAIN), 
#                          FUN = sum)

#  View(tmp_check)


###  MALES IN THE FIRST MONTH OF ALL REGIONS by 7 AGE GROUPS 

# tmpKT4$X123 <- ifelse( tmpKT4$AGE_GROUP7 == 1 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0) 
# tmpKT4$X124 <- ifelse( tmpKT4$AGE_GROUP7 == 2 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X125 <- ifelse( tmpKT4$AGE_GROUP7 == 3 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X126 <- ifelse( tmpKT4$AGE_GROUP7 == 4 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X127 <- ifelse( tmpKT4$AGE_GROUP7 == 5 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X128 <- ifelse( tmpKT4$AGE_GROUP7 == 6 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X129 <- ifelse( tmpKT4$AGE_GROUP7 == 7 & tmpKT4$SEX==1   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)

###  FEMALES IN THE FIRST MONTH OF ALL REGIONS by 7 AGE GROUPS 

# tmpKT4$X130 <- ifelse( tmpKT4$AGE_GROUP7 == 1 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X131 <- ifelse( tmpKT4$AGE_GROUP7 == 2 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X132 <- ifelse( tmpKT4$AGE_GROUP7 == 3 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X133 <- ifelse( tmpKT4$AGE_GROUP7 == 4 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X134 <- ifelse( tmpKT4$AGE_GROUP7 == 5 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0) 
# tmpKT4$X135 <- ifelse( tmpKT4$AGE_GROUP7 == 6 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# tmpKT4$X136 <- ifelse( tmpKT4$AGE_GROUP7 == 7 & tmpKT4$SEX==2   ,  tmpKT4$POPULATION_FIGURES / 3 , 0)
# 
# 
# tmpKT4 <- aggregate(   x = tmpKT4[, list_of_X], 
#                        by = list(DOMAIN = tmpKT4$DOMAIN), 
#                        FUN = sum)
#  View(tmpKT4)

### check also the total and consistency withth eother sets of constraints

# sum(tmpKT4[,list_of_X ])


######################################################################################################
###  
###   STEP 3.6 - SUMMARIZE BY DOMAIN TO SAVE IN A DATAFRAME THE KNOWN TOTALS FOR EACH X  
### 
######################################################################################################
tmpKT$DOMAIN <- as.character(1)

LFS_KNOWN_TOTALS <- aggregate(tmpKT[, list_of_X], by = list(DOMAIN = tmpKT$DOMAIN), FUN = sum)



######################################################################################################
###  
###   STEP 3.13 - CREATE THE R DATAFRAME WITH THE KNOWN TOTALS THAT ARE USED AS SECOND INPUT BY REGENESEES  
### 
######################################################################################################

### If we have set the working directory for the outputs we can use 

save( LFS_KNOWN_TOTALS , file = FILE_LFS_KNOWN_TOTALS_RDATA )


######################################################################################################
###  
###   STEP 3.14 - CHECK TOTAL POPULATION FIGURES
###
######################################################################################################

###   We can calculate the total population summing the X values of the first subset of X
###   notice that X1 is the second column in the dataframe, hence X48 is the 49th column

sum(LFS_KNOWN_TOTALS[,seq(2,49)])

###   We can calculate the total population summing the X values of the second subset of X

sum(LFS_KNOWN_TOTALS[,seq(50,61)]) # ABIDJAN


###   We can calculate the total population summing the X values of the third subset of X

# sum(LFS_KNOWN_TOTALS[,seq(54,95)])

###   We can calculate the total population summing the X values of the fourth subset of X

# sum(LFS_KNOWN_TOTALS[,seq(96,137)])


######################################################################################################
###  
###   STEP 3.15 - CREATE A TABLE FOR REPORTING WITH ROWS AND COLUMNS TOTALS TO EXPORT IN AN EXCEL FILE   
### 
######################################################################################################

###   Save the results in an excel file


# write_xlsx(LFS_KNOWN_TOTALS, "LFS_KNOWN_TOTALS_2021_Q1_94X_4D_ALLWR_np.xlsx" )
write_xlsx(LFS_KNOWN_TOTALS, FILE_LFS_KNOWN_TOTALS_XLSX )



View(LFS_KNOWN_TOTALS)





