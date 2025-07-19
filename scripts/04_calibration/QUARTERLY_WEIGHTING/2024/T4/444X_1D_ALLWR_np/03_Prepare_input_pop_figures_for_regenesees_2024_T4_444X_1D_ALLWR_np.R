########################################################################################################################.
########################################################################################################################.
########################################################################################################################.
########                                                                                                        ########.
########           TRAINING ON STRATEGIES TO CALCULATE LFS SAMPLE WEIGHTS USING CALIBRATION                     ########.
########                                                                                                        ########.
########          PREPARED BY: ANDERSON KOUASSI - STATISTICIEN - CAE - ANSTAT                                   ########.
########                                    E.mail: j.kouassi@stat.plan.gouv.ci                                 ########.
########                                                                                                        ########.
########                                 CASE STUDY  - (444X_1D_ALLWR_np)                                        ########.
########                       CALIBRATION OF FINAL WEIGHTS USING R FOR ALL STEPS ( suffix _ALLWR)              ########.
########                                                                                                        ########.
########                                    BASED ON THE R PACKAGE "REGENESSES"                                 ########.
########                               see https://diegozardetto.github.io/ReGenesees/                          ########.
########                                                                                                        ########.
########                      Version A:  Filenames and paths are not parameterized ( suffix _np)               ########.
########                                                                                                        ########.
########                                                                                                        ########.
########                                                                                                        ########.
########                                        R Script 03                                                     ########.
########                                                                                                        ########.
########        PROGRAM TO PREPARE THE INPUT "KNOWN TOTALS" FOR FINAL CALIBRATION USING REGENESEES              ########.
########                                                                                                        ########.
########        1 DOMAINS  (33 Regions)                                                                        ########.
########        444 CONSTRAINTS (X1 TO X444)                                                                        ########.
########              - Population by region, sex, milieu and 3 age groups    (X1 TO X444)                                ########.
########                                                                                                        ########.
########################################################################################################################.
########################################################################################################################.

#### TO REUSE THIS PROGRAM IN ANOTHER QUARTER MAKE A COPY AND SUBSTITUTE THE TWO STRINGS "\2024\T4\" AND "2024_T4" ACCORDINGLY   ****/.
#### TO REUSE THIS PROGRAM WITH ANOTHER SET OF CONSTRAINTS: a) MAKE A COPY AND RENAME ACCORDINGLY; b) SUBSTITUTE THE STRINGS "8X_33D" ACCORDINGLY (e.g. 66X_4D") WITHIN PATHS AND FILENAMES  ****/.



######################################################################################################
###  
###   STEP 3.1 - SET THE WORKING DIRECTORY WHERE THE OUPUTS WILL BE STORED 
### 
######################################################################################################
root = "D:/DOCUMENTS/CAE/"


setwd(paste0(root,"Calibration/Applications ENEM/DATA/QUARTERLY_WEIGHTING/2024/T4/444X_1D_ALLWR_np/"))
getwd()


######################################################################################################
###  
###   STEP 3.2 - LOAD THE INPUT DATAFRAME CONTAINING THE POPULATION FIGURES FROM FOLDER 560  
### 
######################################################################################################

load(file=paste0(root,"Calibration/Applications ENEM/DATA/POPULATION_ESTIMATES/2024/T4/POP_LFS_BY_REGION_SEX_MILIEU_3AGEGR_corrige.RData"))

### Check that the dataframe "POP_LFS_BY_REGION_SEX_14AGEGR" has been loaded


str(POP_LFS_BY_REGION_SEX_MILIEU_3AGEGR)


View(POP_LFS_BY_REGION_SEX_MILIEU_3AGEGR)




### Create a new dataframe that will be renamed at the end of the steps as LFS_KNOWN_TOTALS_2024_T4_8X_33D
### Working on the new dataframe will help to avoid possible unwanted modifications/errors on the original dataset.
### The shorter name will help when we have to write the code. The prefix tmp will help to r & gnize that is a temporary
### dataframe that does not need to be saved permanently on disk  

tmpKT <- POP_LFS_BY_REGION_SEX_MILIEU_3AGEGR

head(tmpKT )


######################################################################################################
###  
###   STEP 3.3 - CALCULATE THE SET OF 24 X VARIABLES (containing the population figures)  
### 
######################################################################################################


###    Create the X variables and initialize them to 0    
tmpKT <- cbind( tmpKT , data.frame(matrix(0 , nrow = nrow(tmpKT), ncol =  444, byrow = FALSE)))

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
tmpKT$X50[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X51[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X52[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X53[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X54[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X55[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X56[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X57[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X58[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X59[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X60[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X61[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X62[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X63[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X64[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X65[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X66[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X67[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X68[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X69[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X70[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X71[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X72[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X73[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X74[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X75[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X76[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X77[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X78[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X79[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X80[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X81[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X82[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X83[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X84[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X85[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X86[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X87[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X88[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X89[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X90[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X91[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X92[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X93[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X94[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X95[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X96[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X97[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X98[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X99[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X100[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X101[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X102[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X103[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X104[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X105[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X106[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X107[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X108[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X109[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X110[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X111[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X112[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X113[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X114[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X115[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X116[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X117[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X118[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X119[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X120[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X121[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X122[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X123[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X124[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X125[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X126[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X127[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X128[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X129[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X130[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X131[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X132[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X133[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X134[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X135[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X136[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X137[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X138[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X139[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X140[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X141[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X142[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X143[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X144[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X145[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X146[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X147[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X148[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X149[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X150[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X151[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X152[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X153[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X154[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X155[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X156[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X157[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X158[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X159[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X160[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X161[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X162[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X163[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X164[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X165[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X166[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X167[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X168[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X169[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X170[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X171[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X172[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X173[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X174[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X175[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X176[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X177[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X178[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X179[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X180[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X181[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X182[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X183[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X184[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X185[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X186[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X187[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X188[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X189[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X190[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X191[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X192[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X193[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X194[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X195[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X196[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X197[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X198[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X199[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X200[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X201[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X202[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X203[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X204[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X205[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X206[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X207[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X208[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X209[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X210[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X211[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X212[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X213[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X214[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X215[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X216[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X217[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X218[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X219[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X220[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X221[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X222[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X223[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X224[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X225[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X226[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X227[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X228[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X229[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X230[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X231[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X232[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X233[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X234[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X235[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X236[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X237[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X238[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X239[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X240[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X241[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X242[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X243[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==1]
tmpKT$X244[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X245[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X246[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==1 & tmpKT$Sexe ==2]
tmpKT$X247[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X248[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X249[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X250[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X251[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X252[tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "ABIDJAN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X253[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X254[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X255[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X256[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X257[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X258[tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAUT-SASSANDRA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X259[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X260[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X261[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X262[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X263[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X264[tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "PORO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X265[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X266[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X267[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X268[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X269[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X270[tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBEKE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X271[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X272[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X273[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X274[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X275[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X276[tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "INDENIE-DJUABLIN" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X277[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X278[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X279[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X280[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X281[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X282[tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TONKPI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X283[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X284[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X285[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X286[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X287[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X288[tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "YAMOUSSOUKRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X289[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X290[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X291[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X292[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X293[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X294[tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GONTOUGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X295[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X296[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X297[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X298[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X299[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X300[tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SAN-PEDRO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X301[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X302[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X303[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X304[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X305[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X306[tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "KABADOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X307[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X308[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X309[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X310[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X311[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X312[tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "N'ZI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X313[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X314[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X315[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X316[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X317[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X318[tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MARAHOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X319[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X320[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X321[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X322[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X323[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X324[tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "SUD-COMOE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X325[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X326[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X327[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X328[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X329[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X330[tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "WORODOUGOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X331[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X332[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X333[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X334[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X335[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X336[tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LÔH-DJIBOUA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X337[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X338[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X339[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X340[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X341[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X342[tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "AGNEBY-TIASSA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X343[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X344[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X345[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X346[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X347[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X348[tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GÔH" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X349[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X350[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X351[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X352[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X353[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X354[tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "CAVALLY" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X355[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X356[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X357[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X358[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X359[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X360[tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAFING" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X361[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X362[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X363[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X364[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X365[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X366[tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BAGOUE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X367[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X368[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X369[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X370[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X371[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X372[tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BELIER" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X373[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X374[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X375[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X376[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X377[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X378[tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BERE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X379[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X380[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X381[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X382[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X383[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X384[tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "BOUNKANI" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X385[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X386[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X387[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X388[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X389[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X390[tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "FOLON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X391[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X392[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X393[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X394[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X395[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X396[tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GBOKLE" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X397[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X398[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X399[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X400[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X401[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X402[tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GRAND-PONTS" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X403[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X404[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X405[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X406[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X407[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X408[tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "GUEMON" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X409[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X410[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X411[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X412[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X413[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X414[tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "HAMBOL" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X415[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X416[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X417[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X418[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X419[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X420[tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "IFFOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X421[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X422[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X423[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X424[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X425[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X426[tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "LA ME" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X427[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X428[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X429[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X430[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X431[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X432[tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "NAWA" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X433[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X434[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X435[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X436[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X437[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X438[tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "TCHOLOGO" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X439[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X440[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X441[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==1]
tmpKT$X442[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "0_14" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X443[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "15_34" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]
tmpKT$X444[tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2] = tmpKT$Nombre[ tmpKT$`Région (33)` == "MORONOU" & tmpKT$groupe_age == "35_plus" & tmpKT$Milieu ==2 & tmpKT$Sexe ==2]


######################################################################################################
###  
###   STEP 3.4 - CREATE THE VARIABLE "DOMAIN" THAT IDENTIFIES THE DOMAIN OF ESTIMATION   
### 
######################################################################################################



View(tmpKT)

#names(tmpKT)


######################################################################################################
###  
###   STEP 3.5 - CREATE AN OBJECT CONTAING THE LIST OF Xs TO RETAIN TO BE USED IN THE NEXT STEPS  
### 
######################################################################################################

### Create a list of the Xs to retain to be used in the next steps (useful when we have a huge number of X)

list_of_X  <- paste(rep("X",444),seq(1,444),sep="")
list_of_X 

######################################################################################################
###  
###   STEP 3.6 - SUMMARIZE BY DOMAIN TO SAVE IN A DATAFRAME THE KNOWN TOTALS FOR EACH X  
### 
######################################################################################################
tmpKT$DOMAIN <- as.character(1)

LFS_KNOWN_TOTALS <- aggregate(tmpKT[, list_of_X], by = list(DOMAIN = tmpKT$DOMAIN), FUN = sum)
View(LFS_KNOWN_TOTALS)

######################################################################################################
###  
###   STEP 3.7 - CREATE THE R DATAFRAME WITH THE KNOWN TOTALS THAT ARE USED AS S & ND INPUT BY REGENESEES  
### 
######################################################################################################

### If we have set the working directory for the outputs we can use 



save(LFS_KNOWN_TOTALS, file="LFS_KNOWN_TOTALS_2024_T4_444X_1D_ALLWR_np.RData")


######################################################################################################
###  
###   STEP 3.8 - CHECK TOTAL POPULATION FIGURES
###
######################################################################################################

###   We can calculate the total population summing all the X values

sum(LFS_KNOWN_TOTALS[,list_of_X])

### or else summing the columns from 2 to 25 of the dataframe

sum(LFS_KNOWN_TOTALS[,seq(2,445)])



######################################################################################################
###  
###   STEP 3.8 - CREATE A TABLE FOR REPORTING WITH ROWS AND COLUMNS TOTALS TO EXPORT IN AN EXCEL FILE   
### 
######################################################################################################

### create a new dataframe for reporting

LFS_KNOWN_TOTALS_TOT_POP_FIGURES <- LFS_KNOWN_TOTALS


### add a column with the total of the 8 Xs using the function rowSums

LFS_KNOWN_TOTALS_TOT_POP_FIGURES$X_TOT <- rowSums(LFS_KNOWN_TOTALS_TOT_POP_FIGURES[,seq(2,445)])

View(LFS_KNOWN_TOTALS_TOT_POP_FIGURES) 

### create and insert also a new row with the totals for each X 

### lets calculate the sum of the Xs

colSums( LFS_KNOWN_TOTALS_TOT_POP_FIGURES[,seq(2,446)])

### lets add an additional element at the beginning

c("Total",colSums( LFS_KNOWN_TOTALS_TOT_POP_FIGURES[,seq(2,446)] ))

### lets do that in a single step using also the function rbind


LFS_KNOWN_TOTALS_TOT_POP_FIGURES <- rbind( LFS_KNOWN_TOTALS_TOT_POP_FIGURES,
                                           c("Total",colSums( LFS_KNOWN_TOTALS_TOT_POP_FIGURES[,seq(2,446)] ))
                                         )
View(LFS_KNOWN_TOTALS_TOT_POP_FIGURES) 

###   Save permanently the object in the destination folder  

save(LFS_KNOWN_TOTALS_TOT_POP_FIGURES, file="LFS_KNOWN_TOTALS_2024_T4_444X_1D_ALLWR_np_TOT_POP_FIGURES.RData")


###   Save the results in an excel file


write_xlsx(LFS_KNOWN_TOTALS_TOT_POP_FIGURES,
          "LFS_KNOWN_TOTALS_2024_T4_444X_1D_ALLWR_np_TOT_POP_FIGURES.xlsx" )










