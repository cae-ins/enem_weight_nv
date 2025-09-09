


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
###     FUNCTION TO CALCULATE SUMMMRY STATISTICS FOR THE X CONSTRAINTS FOR THE R PACKAGE "REGENESSES"      ###
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

### des_size  is an desing object created using the function e.svydesign and the variable "ONES" (containgìing 1s) as weights
### des_initial is the first desing object created in the calbtration using the function e.svydesign and the variable "DESIGN_WEIGTH" as weight 
### des_total is the population dataframe "popdataframe"
### des_final is the calibrated object

### Within the function there are the following parameters that can be changed as needed
### L_trsld_corr_fact=0.5  will highlight the Xs that will have a mean correction factor lower than 0.5
### H_trsld_corr_fact=1.5  will highlight the Xs that will have a mean correction factor higher than 1.5
### L_trsld_sample_size=30 will highlight the Xs that have a sample size of 30 or less 
### calc_tot = TRUE        will produce a row total at the end of the table 






X_Summaries <- function(numX, des_size, des_initial, des_total, des_final = NULL, L_trsld_corr_fact, H_trsld_corr_fact, L_trsld_sample_size, calc_tot = FALSE ) {

### Calculate the sample size for each calibration cell X for the different domains (ignore the warning message)

X_sample_size <- aux.estimates(des_size, template=poptemplate)


### Calculate the initial estimates (obtained with initial weights) for each calibration cell X for the different domains (ignore the warning message)

X_initial_estimate <- data.frame(aux.estimates( des_initial ,template=poptemplate))

### Calculate the known totals (benchmarks) for each calibration cell X for the different domains (ignore the warning message)

X_known_total <- des_total

if (!is.null(des_final)) {
        X_final_estimate <- data.frame(aux.estimates( des_final ,template=poptemplate))
    }


if (!is.null(des_final)) {
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

XST <- XST[,c('Domain', 'X_Constraints','Sample_Size', 'Initial_Estimate', 'Known_Total', 'Diff_Known_Tot_Init_Est','Final_Estimate','Diff_Known_Tot_Final_Est' )]
}



if (is.null(des_final)) {
 j <- 1
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

}


### Change row names to avoid confusion between the row names and variable X_constraints

rownames(XST) <- 1:nrow(XST)
XST

Ord <- 1:nrow(XST)

XST <- cbind(Ord,XST)






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




if (is.null(des_final)) {
XST <- XST[,c('Ord','Domain', 'X_Constraints','Sample_Size', 'Initial_Estimate', 'Known_Total', 'Diff_Known_Tot_Init_Est', 'Mean_corr_factor',
              'Error_in_X','High_corr_factor', 'Small_sample_size' )]
}



if (!is.null(des_final)) {
XST <- XST[,c('Ord','Domain', 'X_Constraints','Sample_Size', 'Initial_Estimate', 'Known_Total', 'Diff_Known_Tot_Init_Est', 'Mean_corr_factor',
              'Error_in_X','High_corr_factor', 'Small_sample_size', 'Final_Estimate', 'Diff_Known_Tot_Final_Est' )]
}


#create last row of summaries

if (!is.null(des_final) & calc_tot == TRUE) {


XST <- rbind(XST, 
              c(nrow(XST)+1,
                'TOT',
                'TOT',
                sum(XST$Sample_Size),
                sum(XST$Initial_Estimate),
                sum(XST$Known_Total),
                sum(abs(as.numeric(XST$Diff_Known_Tot_Init_Est))),
                0,
                '',
                '',
                '',
                sum(XST$Final_Estimate),
                sum(abs(XST$Diff_Known_Tot_Final_Est))
                )
           )

max_ord <- nrow(XST)

XST$Mean_corr_factor[XST$Ord==max_ord]  <- round(as.numeric(XST$Known_Total[XST$Ord==max_ord]) / as.numeric(XST$Initial_Estimate[XST$Ord==max_ord]),2)

### Identify large correction factors. If any then write a note in the last row. 

XST$High_corr_factor[XST$Ord==max_ord] <- "."
 
#if ( any(XST$Mean_corr_factor > H_trsld_corr_fact )==TRUE ) {
#XST$High_corr_factor[XST$Ord==max_ord] <-  paste("Higher than", H_trsld_corr_fact)
#} 

#if ( any(XST$Mean_corr_factor < L_trsld_corr_fact )==TRUE ) {
#XST$High_corr_factor[XST$Ord==max_ord] <- paste("Lower than", L_trsld_corr_fact)
#} 

### Identify X constraints that cannot be satysfied by the calibration problem and impede converge/solution.  If any then write a note in the last row. 

XST$Error_in_X[XST$Ord==max_ord] <- "."
#if ( any(XST$Known_Total==0 & XST$Initial_Estimate!=0)==TRUE) {
#XST$Error_in_X[XST$Ord==max_ord] <-  "Error"
#} 
#if ( any(XST$Known_Total!=0 & XST$Initial_Estimate==0)==TRUE) {
#XST$Error_in_X[XST$Ord==max_ord] <-  "Error"
#} 

### Identify X constraints that have a sample size smaller that a user defined threshold and may hinder converge/solution.  If any then write a note in the last row. 

XST$Small_sample_size[XST$Ord==max_ord] <- "."
# if ( any(XST$Sample_Size > 0 & XST$Sample_Size <= L_trsld_sample_size )==TRUE ) {
#XST$Small_sample_size[XST$Ord==max_ord] <-  paste("Sample size <= ", L_trsld_sample_size)
#} 

}



if (is.null(des_final) & calc_tot == TRUE) {

XST <- rbind(XST, 
              c(nrow(XST)+1,
                'TOT',
                'TOT',
                sum(XST$Sample_Size),
                sum(XST$Initial_Estimate),
                sum(XST$Known_Total),
                sum(abs(XST$Diff_Known_Tot_Init_Est)),
                0,
                '',
                '',
                ''
                )
           )

max_ord <- nrow(XST)

XST$Mean_corr_factor[XST$Ord==max_ord]  <- round(as.numeric(XST$Known_Total[XST$Ord==max_ord]) / as.numeric(XST$Initial_Estimate[XST$Ord==max_ord]),2)

### Identify large correction factors. 

XST$High_corr_factor[XST$Ord==max_ord] <- "."
 
#if ( any(XST$Mean_corr_factor > H_trsld_corr_fact )==TRUE ) {
#XST$High_corr_factor[XST$Ord==max_ord] <-  paste("Higher than", H_trsld_corr_fact)
#} 

#if ( any(XST$Mean_corr_factor < L_trsld_corr_fact )==TRUE ) {
#XST$High_corr_factor[XST$Ord==max_ord] <- paste("Lower than", L_trsld_corr_fact)
#} 

### Identify X constraints that cannot be satysfied by the calibration problem and impede converge/solution. 

XST$Error_in_X[XST$Ord==max_ord] <- "."

#if ( any(XST$Known_Total==0 & XST$Initial_Estimate!=0)==TRUE) {
#XST$Error_in_X[XST$Ord==max_ord] <-  "Error"
#} 
#if ( any(XST$Known_Total!=0 & XST$Initial_Estimate==0)==TRUE) {
#XST$Error_in_X[XST$Ord==max_ord] <-  "Error"
#} 

### Identify X constraints that have a sample size smaller that a user defined threshold and may hinder converge/solution. 

XST$Small_sample_size[XST$Ord==max_ord] <- "."

# if ( any(XST$Sample_Size > 0 & XST$Sample_Size <= L_trsld_sample_size )==TRUE ) {
# XST$Small_sample_size[XST$Ord==max_ord] <-  paste("Sample size <= ", L_trsld_sample_size)
# } 

}


 return(XST)
}










#X_Summary_Tables <- X_Summaries(numX=xnum, des_size=design_size, des_initial=design_lfs, des_total=popdataframe,  des_final=calib_lfs,
#                                L_trsld_corr_fact=0.5, H_trsld_corr_fact=1.5, L_trsld_sample_size=10) 
# head(X_Summary_Tables)


#X_Summary_Tables <- X_Summaries(numX=xnum, des_size=design_size, des_initial=design_lfs, des_total=popdataframe, 
#                                L_trsld_corr_fact=0.5, H_trsld_corr_fact=1.5, L_trsld_sample_size=13) 
#head(X_Summary_Tables)
#X_Summary_Tables

