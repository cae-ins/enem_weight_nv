


##############################################################################################################
##############################################################################################################
###                                                                                                        ###
###                                                                                                        ###
###     FUNCTION TO CALCULATE THE X VECTOR OF CONSTRAINTS FOR THE R PACKAGE "REGENESSES"                   ###
###                                                                                                        ###
###  PREPARED BY: ALESSANDRO MARTINI - Italian National Institute of Statistics (ISTAT)                    ###
###                                    e-mail: alessandro.martini@istat.it                                 ###
###                                                                                                        ###
##############################################################################################################
##############################################################################################################


###  function to create the list of Xs identifying the calibration cells 
###  this function is not in the paskage must be uploaded from file)


constraints_model <- function(vincolin ){
mod<-"~ "
for(i in 1:(vincolin-1)){
assign("m",paste(paste("X",i,"+",sep=""))) 
mod<-paste(mod,m,sep="")
}
mod<-as.formula(paste(mod,"X",vincolin,"-1",sep=""))
return(mod)
} 




##############################################################################################################
##############################################################################################################
###                                                                                                        ###
###                                                                                                        ###
###     FUNCTIONS TO CALCULATE SUMMARY STATISTICS FOR THE X CONSTRAINTS FOR THE R PACKAGE "REGENESSES"     ###
###        1) FUNCTION "X_Summaries" TO CREATE THE TABLE WITH SUMMARY STATISTICS ABOUT THE Xs              ###
###        2) FUNCTION "X_Summaries_Filter_View" TO VIEW A SUBSET OF THE Xs of the SUMMARY TABLE           ###
###                                                                                                        ###
###  PREPARED BY: ANTONIO R. DISCENZA - Italian National Institute of Statistics (ISTAT)                   ###
###                                    e-mail: discenza@istat.it                                           ###
###                                                                                                        ###
##############################################################################################################
##############################################################################################################

### Calculate the sample size for each calibration cell X for the different domains (ignore the messages "Warning in aux.estimates ....")

### NOTE: TO CALCULATE THE SUMMARY STATISTICS FOR THE WEIGHTS WE NEED TO ADD THE FOLLOWING
###       1) create a variable ONES=1 in sample_data
###       2) create a an object "design_size" using the function e.svydesign and the variable "ONES" as weights
###       3) use a new function called "X_Summaries" specifically created for the purpose, not included in Regenesees
###       4) use the package "writexl" to export results in excel
###       5) define the parameterized name of the output excel table



### X_Summary_Table <- X_Summaries( numX = xnum, 
###                             des_size = design_size, 
###                          des_initial = design_lfs, 
###                            des_total = popdataframe,
###                            des_final = calib_lfs (default=NULL),
###                    L_trsld_corr_fact = 0.5,
###                    H_trsld_corr_fact = 1.5, 
###                  L_trsld_sample_size = 30,
###                             calc_tot = TRUE (default=NULL)
###                               ) 

### des_size  is an design object created using the function e.svydesign and the variable "ONES" (containing 1s) as weights
### des_initial is the first design object created in the calibration using the function e.svydesign and the variable "DESIGN_WEIGHT" as weight 
### des_total is the population dataframe "popdataframe"
### des_final is the calibrated object

### Within the function there are the following parameters that can be changed as needed
### L_trsld_corr_fact=0.5  will highlight the Xs that will have a mean correction factor lower than 0.5
### H_trsld_corr_fact=1.5  will highlight the Xs that will have a mean correction factor higher than 1.5
### L_trsld_sample_size=30 will highlight the Xs that have a sample size of 30 or less 
### calc_tot = TRUE        will produce a row total at the end of the table 

# 
#                numX <- xnum
#            des_size <- design_size
#         des_initial <- design_lfs
#           des_total <- popdataframe
#           des_final <- calib_lfs
#   L_trsld_corr_fact <- 0.95
#   H_trsld_corr_fact <- 1.15
# L_trsld_sample_size <- 200
#            calc_tot <- TRUE



#################################################################################
#################################################################################
### 
### FUNCTION "X_Summaries" TO CREATE THE SUMMARY TABLES WITH THE Xs

X_Summaries <- function(numX, des_size, des_initial, des_total, des_final = NULL, L_trsld_corr_fact, H_trsld_corr_fact, L_trsld_sample_size, calc_tot = FALSE ) {

### Calculate the sample size for each calibration cell X for the different domains (ignore the warning message)

X_sample_size <- aux.estimates(des_size, template=poptemplate)


### Calculate the initial estimates (obtained with initial weights) for each calibration cell X for the different domains (ignore the warning message)

X_initial_estimate <- data.frame(aux.estimates( des_initial ,template=poptemplate))

### Calculate the known totals (benchmarks) for each calibration cell X for the different domains (ignore the warning message)

X_known_total <- des_total


################################################################################################################################## 
### Before calibration, calculate the difference between direct estimates and known totals for each calibration cell X 
### for the different domains (ignore the warning message)

if (is.null(des_final)) {

j <- 1

### Calculate the outputs for the different DOMAINs and append them in a single table  

  for (i in X_sample_size$DOMAIN) {
    tmp_XST <- cbind.data.frame(rep(i,1,numX),
                                round(as.numeric(as.character(t(X_sample_size[X_sample_size$DOMAIN==i,-c(1)]),0))),
                                round(as.numeric(as.character(t(X_initial_estimate[X_initial_estimate$DOMAIN==i,-c(1)]),1))),
                                round(as.numeric(as.character(t(X_known_total[X_known_total$DOMAIN==i,-c(1)]),1)))
    )
    colnames(tmp_XST) <- c( 'Domain', 'Sample_Size', 'Initial_Estimate', 'Known_Total')
    rownames(tmp_XST) <- colnames(X_sample_size[-1])
    tmp_XST$X_Constraints <-rownames(tmp_XST)
    tmp_XST <- tmp_XST[,c('Domain', 'X_Constraints','Sample_Size', 'Initial_Estimate', 'Known_Total' )]
    if (j == 1) XST <- tmp_XST[0,]
    XST <- rbind(XST,tmp_XST)
    j <- j + 1
  } 
  
### Calculate the difference between Known totals and initial estimates
  
XST$Diff_Known_Tot_Init_Est <- XST$Known_Total - XST$Initial_Estimate

### Rearrange columns in the resulting table

XST <- XST[,c('Domain', 'X_Constraints','Sample_Size', 'Initial_Estimate', 'Known_Total', 'Diff_Known_Tot_Init_Est')]

}



################################################################################################################################## 
### After calibration, calculate the the final estimates for each calibration cell X 
### for the different domains (ignore the warning message)

if (!is.null(des_final)) {

X_final_estimate <- data.frame(aux.estimates( des_final ,template=poptemplate))
   
 j <- 1
 
 for (i in X_sample_size$DOMAIN) {
  tmp_XST <- cbind.data.frame(rep(i,1,numX),
                              round(as.numeric(as.character(t(X_sample_size[X_sample_size$DOMAIN==i,-c(1)]),0))),
                              round(as.numeric(as.character(t(X_initial_estimate[X_initial_estimate$DOMAIN==i,-c(1)]),1))),
                              round(as.numeric(as.character(t(X_known_total[X_known_total$DOMAIN==i,-c(1)]),1))),
                              round(as.numeric(as.character(t(X_final_estimate[X_final_estimate$DOMAIN==i,-c(1)]),1)))
                              )
  colnames(tmp_XST) <- c( 'Domain', 'Sample_Size', 'Initial_Estimate', 'Known_Total','Final_Estimate')
  rownames(tmp_XST) <- colnames(X_sample_size[-1])
  tmp_XST$X_Constraints <-rownames(tmp_XST)
  tmp_XST <- tmp_XST[,c('Domain', 'X_Constraints','Sample_Size', 'Initial_Estimate', 'Known_Total','Final_Estimate' )]
  if (j == 1) XST <- tmp_XST[0,]
  XST <- rbind(XST,tmp_XST)
  j <- j + 1
 } 

### Calculate the difference between Known totals and initial estimates

XST$Diff_Known_Tot_Init_Est <- XST$Known_Total -XST$Initial_Estimate

### Calculate the difference between Known totals and final estimates

XST$Diff_Known_Tot_Final_Est <- XST$Known_Total -XST$Final_Estimate

### Rearrange columns in the resulting table

XST <- XST[,c('Domain', 'X_Constraints','Sample_Size', 'Initial_Estimate', 'Known_Total', 'Diff_Known_Tot_Init_Est','Final_Estimate','Diff_Known_Tot_Final_Est' )]
}



################################################################################################################################## 
### Change row names to avoid confusion between the row names and variable X_constraints

Ord <- 1:nrow(XST)

XST <- cbind(Ord,XST)


################################################################################################################################## 
### Calculate the correction factor for each calibration cell X for the different domains

XST$Mean_corr_factor <- round(XST$Known_Total / XST$Initial_Estimate,2)


### Identify correction factor that are higher or lower users defined thresholds (need to be checked) 

XST$High_corr_factor <- "."
XST$High_corr_factor[XST$Mean_corr_factor > H_trsld_corr_fact] <- paste("Higher than", H_trsld_corr_fact)
XST$High_corr_factor[XST$Mean_corr_factor < L_trsld_corr_fact] <- paste("Lower than", L_trsld_corr_fact)


### Identify X constraints that cannot be satysfied by the calibration problem and impede converge/solution. 

XST$Error_in_X <- "."
XST$Error_in_X[XST$Known_Total==0 & XST$Initial_Estimate!=0] <- "Error"
XST$Error_in_X[XST$Known_Total!=0 & XST$Initial_Estimate==0] <- "Error"

### Identify X constraints that have a sample size smaller than a user defined threshold and may hinder converge/solution. 

XST$Small_sample_size <- "."
XST$Small_sample_size[(XST$Known_Total>0 | XST$Initial_Estimate>0) & (XST$Sample_Size <= L_trsld_sample_size)] <- paste("Sample size <= ", L_trsld_sample_size)





### Rearrange columns in the resulting table before calibration

if (is.null(des_final)) {
XST <- XST[,c('Ord','Domain', 'X_Constraints','Sample_Size', 'Initial_Estimate', 'Known_Total', 'Diff_Known_Tot_Init_Est', 'Mean_corr_factor',
              'Error_in_X','High_corr_factor', 'Small_sample_size' )]
}


### Rearrange columns in the resulting table after calibration

if (!is.null(des_final)) {
XST <- XST[,c('Ord','Domain', 'X_Constraints','Sample_Size', 'Initial_Estimate', 'Known_Total', 'Diff_Known_Tot_Init_Est', 'Mean_corr_factor',
              'Error_in_X','High_corr_factor', 'Small_sample_size', 'Final_Estimate', 'Diff_Known_Tot_Final_Est' )]
}



######################################################################################################
### Create last row of summaries the resulting table before calibration

if (is.null(des_final) & calc_tot == TRUE) {

  max_ord <- nrow(XST) 
  
  XST_tot                               <- XST[1,] 
  XST_tot$Ord[1]                        <- max_ord + 1
  XST_tot$Domain[1]                     <- 'TOT'
  XST_tot$X_Constraints[1]              <- 'TOT'
  XST_tot$Sample_Size[1]                <- sum(XST$Sample_Size)
  XST_tot$Initial_Estimate[1]           <- sum(XST$Initial_Estimate)
  XST_tot$Known_Total[1]                <- sum(XST$Known_Total)
  XST_tot$Diff_Known_Tot_Init_Est[1]    <- sum(abs(as.numeric(XST$Diff_Known_Tot_Init_Est)))
  
  XST_tot$Mean_corr_factor[1]           <- round( as.numeric(XST_tot$Known_Total) / as.numeric(XST_tot$Initial_Estimate),2)
  
  ### Identify X constraints that cannot be satysfied by the calibration problem and impede converge/solution.  If any then write a note in the last row. 
  XST_tot$Error_in_X[1]                 <- "."
  
  if ( any(XST$Error_in_X == "Error") == TRUE ) {
    XST_tot$Error_in_X[1] <-  "Error"
  } 
  
  
  ### Identify large correction factors. If any then write a note in the last row. 
  XST_tot$High_corr_factor[1]           <- "."
  
  if ( any(XST$Mean_corr_factor > H_trsld_corr_fact )==TRUE ) {
    XST_tot$High_corr_factor[1] <-  paste("Higher than", H_trsld_corr_fact)
  } 
  
  if ( any(XST$Mean_corr_factor < L_trsld_corr_fact )==TRUE ) {
    XST_tot$High_corr_factor[1] <- paste("Lower than", L_trsld_corr_fact)
  } 
  
  if ( any(XST$Mean_corr_factor > H_trsld_corr_fact) ==TRUE & any(XST$Mean_corr_factor < L_trsld_corr_fact ) ==TRUE ) {
    XST_tot$High_corr_factor[1] <-  paste("Higher than", H_trsld_corr_fact, "and Lower than",L_trsld_corr_fact)
  } 
  
  
  ### Identify X constraints that have a sample size smaller that a user defined threshold and may hinder converge/solution.  If any then write a note in the last row. 
  XST_tot$Small_sample_size[1]          <-   "."    
  
  if ( any(XST$Small_sample_size == paste("Sample size <= ", L_trsld_sample_size) ) == TRUE ) {
    XST_tot$Small_sample_size[1] <-  paste("Sample size <= ", L_trsld_sample_size)
  } 
  
  
  XST <- rbind(XST,XST_tot)
  
}


######################################################################################################
### Create last row of summaries the resulting table after calibration

if (!is.null(des_final) & calc_tot == TRUE) {

  max_ord <- nrow(XST) 
  
  XST_tot                               <- XST[1,] 
  XST_tot$Ord[1]                        <- max_ord + 1
  XST_tot$Domain[1]                     <- 'TOT'
  XST_tot$X_Constraints[1]              <- 'TOT'
  XST_tot$Sample_Size[1]                <- sum(XST$Sample_Size)
  XST_tot$Initial_Estimate[1]           <- sum(XST$Initial_Estimate)
  XST_tot$Known_Total[1]                <- sum(XST$Known_Total)
  XST_tot$Diff_Known_Tot_Init_Est[1]    <- sum(abs(as.numeric(XST$Diff_Known_Tot_Init_Est)))
  
  XST_tot$Mean_corr_factor[1]           <- round( as.numeric(XST_tot$Known_Total) / as.numeric(XST_tot$Initial_Estimate),2)
  
  ### Identify X constraints that cannot be satysfied by the calibration problem and impede converge/solution.  If any then write a note in the last row. 
  XST_tot$Error_in_X[1]                 <- "."
  
  if ( any(XST$Error_in_X == "Error", na.rm = TRUE) == TRUE ) {
    XST_tot$Error_in_X[1] <-  "Error"
  } 
  
  
  ### Identify large correction factors. If any then write a note in the last row. 
  XST_tot$High_corr_factor[1]           <- "."
  
  if ( any(XST$Mean_corr_factor > H_trsld_corr_fact, na.rm = TRUE)==TRUE ) {
    XST_tot$High_corr_factor[1] <-  paste("Higher than", H_trsld_corr_fact)
  } 
  
  if ( any(XST$Mean_corr_factor < L_trsld_corr_fact, na.rm = TRUE)==TRUE ) {
    XST_tot$High_corr_factor[1] <- paste("Lower than", L_trsld_corr_fact)
  } 
  
  if ( any(XST$Mean_corr_factor > H_trsld_corr_fact, na.rm = TRUE) ==TRUE & any(XST$Mean_corr_factor < L_trsld_corr_fact, na.rm = TRUE ) ==TRUE ) {
    XST_tot$High_corr_factor[1] <-  paste("Higher than", H_trsld_corr_fact, "and Lower than",L_trsld_corr_fact)
  } 
  
  
  ### Identify X constraints that have a sample size smaller that a user defined threshold and may hinder converge/solution.  If any then write a note in the last row. 
  XST_tot$Small_sample_size[1]          <-   "."    
  
  if ( any(XST$Small_sample_size == paste("Sample size <= ", L_trsld_sample_size), na.rm = TRUE ) == TRUE ) {
       XST_tot$Small_sample_size[1] <-  paste("Sample size <= ", L_trsld_sample_size)
  } 
  
  
  XST_tot$Final_Estimate[1]             <- sum(XST$Final_Estimate)
  
  XST_tot$Diff_Known_Tot_Final_Est[1]   <- sum(abs(XST$Diff_Known_Tot_Final_Est))
  
    
  XST <- rbind(XST,XST_tot)

}

return(XST)

}



#################################################################################
### Example of how to execute the function X_Summaries 

### X_Summary_Table <- X_Summaries( numX = xnum, 
###                                 des_size = design_size, 
###                                 des_initial = design_lfs, 
###                                 des_total = popdataframe,
###                                 des_final = calib_lfs,
###                                 L_trsld_corr_fact = 0.95,
###                                 H_trsld_corr_fact = 1.15, 
###                                 L_trsld_sample_size = 10,
###                                 calc_tot = TRUE) 
### 
### View(X_Summary_Table)



#################################################################################
#################################################################################
### 
### FUNCTION "X_Summaries_Filter_View" TO VIEW A SUBSET OF THE Xs of the X_SUMMARIES
### To visualize only the Xs that have some error in the construction (Error_in_X=TRUE)
### To visualize only the Xs that have a low sample size (Small_sample_size=TRUE)
### To visualize only the Xs that have a too high or too low correction factors (High_corr_factor=TRUE)

  
X_Summaries_Filter_View <- function(X_Table, High_corr_factor=FALSE, Small_sample_size=FALSE, Error_in_X=FALSE, L_trsld_sample_size = FALSE, L_trsld_corr_fact = FALSE, H_trsld_corr_fact = FALSE, X_diff_not_zero = FALSE) {

  if (Error_in_X == TRUE) {
  X_Summaries_Errors_in_X <-  X_Table[X_Table$Error_in_X!=".",] 
  View( X_Summaries_Errors_in_X )
  }

  if (Small_sample_size == TRUE & is.numeric(L_trsld_sample_size)==FALSE) {
  X_Summaries_Small_sample_size <- X_Table[X_Table$Small_sample_size!=".",] 
  View( X_Summaries_Small_sample_size )
  }
  
  ### In case we want to select records unde a specific threshold. 
  if (Small_sample_size == TRUE & is.numeric(L_trsld_sample_size)==TRUE) {
  ### Identify X constraints that have a sample size smaller than a user defined threshold and may hinder converge/solution. 
  X_Table$Small_sample_size <- "."
  X_Table$Small_sample_size[(X_Table$Known_Total>0 | X_Table$Initial_Estimate>0) & (X_Table$Sample_Size <= L_trsld_sample_size)] <- paste("Sample size <= ", L_trsld_sample_size)
  X_Summaries_Small_sample_size <- X_Table[X_Table$Small_sample_size!=".",] 
  View( X_Summaries_Small_sample_size )
  }
  
  if ( High_corr_factor == TRUE & is.numeric(L_trsld_corr_fact)==FALSE & is.numeric(H_trsld_corr_fact)==FALSE ) {
  X_Summaries_High_corr_factor <- X_Table[X_Table$High_corr_factor!=".",]
  View( X_Summaries_High_corr_factor )
  }

  if ( High_corr_factor == TRUE & is.numeric(L_trsld_corr_fact)==TRUE & is.numeric(H_trsld_corr_fact)==FALSE ) {
  ### Identify correction factor that are higher or lower users defined thresholds (need to be checked) 
  X_Table$High_corr_factor <- "."
  X_Table$High_corr_factor[X_Table$Mean_corr_factor < L_trsld_corr_fact] <- paste("Lower than", L_trsld_corr_fact)
  X_Summaries_High_corr_factor <- X_Table[X_Table$High_corr_factor!=".",]
  View( X_Summaries_High_corr_factor )
  }

  if ( High_corr_factor == TRUE & is.numeric(L_trsld_corr_fact)==FALSE & is.numeric(H_trsld_corr_fact)==TRUE ) {
  ### Identify correction factor that are higher or lower users defined thresholds (need to be checked) 
  X_Table$High_corr_factor <- "."
  X_Table$High_corr_factor[X_Table$Mean_corr_factor > H_trsld_corr_fact] <- paste("Higher than", H_trsld_corr_fact)
  X_Summaries_High_corr_factor <- X_Table[X_Table$High_corr_factor!=".",]
  View( X_Summaries_High_corr_factor )
  }

  if ( High_corr_factor == TRUE & is.numeric(L_trsld_corr_fact)==TRUE & is.numeric(H_trsld_corr_fact)==TRUE ) {
  ### Identify correction factor that are higher or lower users defined thresholds (need to be checked) 
  X_Table$High_corr_factor <- "."
  X_Table$High_corr_factor[X_Table$Mean_corr_factor > H_trsld_corr_fact] <- paste("Higher than", H_trsld_corr_fact)
  X_Table$High_corr_factor[X_Table$Mean_corr_factor < L_trsld_corr_fact] <- paste("Lower than", L_trsld_corr_fact)
  X_Summaries_High_corr_factor <- X_Table[X_Table$High_corr_factor!=".",]
  View( X_Summaries_High_corr_factor )
  }

  # only works after calibration, when the parameter "des_final" has beed used in the function "X_Summaries" 
  if (X_diff_not_zero == TRUE) {
    X_Summaries_X_diff_not_zero <-  X_Table[X_Table$Diff_Known_Tot_Final_Est!=0,] 
    View( X_Summaries_X_diff_not_zero )
  }
    
} 

#################################################################################
### Example of how to execute the function X_Summaries_Filter_View 
### (using the same parameters of the function X_Summaries)
 
### To visualize only the Xs that have some error in the construction (e.g. the known total is >0 and sample_size=0)
# X_Summaries_Filter_View(X_Summary_Table, Error_in_X=TRUE)
 
### To visualize only the Xs that have a low sample size
# X_Summaries_Filter_View(X_Summary_Table, Small_sample_size=TRUE)

### To visualize only the Xs that have a too high or too low correction factors
# X_Summaries_Filter_View(X_Summary_Table, High_corr_factor=TRUE)

### To visualize only the Xs that have not converged (Diff_Known_Tot_Final_Est different from zero)
# X_Summaries_Filter_View(X_Summary_Table, X_diff_not_zero=TRUE)

#################################################################################
### Example of how to execute the function X_Summaries_Filter_View 
### (passing new parameters )

### Visualize only the Xs that have a low sample size based on a different threshold (defined below)  

# X_Summaries_Filter_View(X_Summary_Table, Small_sample_size=TRUE, L_trsld_sample_size=200)
 
### To visualize only the Xs that have a too high or too low correction factors based on different thresholds (defined below) 

# X_Summaries_Filter_View(X_Summary_Table, High_corr_factor=TRUE, H_trsld_corr_fact=1.25)
 
# X_Summaries_Filter_View(X_Summary_Table, High_corr_factor=TRUE, L_trsld_corr_fact=0.95)
 
# X_Summaries_Filter_View(X_Summary_Table, High_corr_factor=TRUE, H_trsld_corr_fact=1.15, L_trsld_corr_fact=0.95)






