library(stringr)
library(dplyr)
library(shiny)
library(plotly)
library(dplyr)
library(shinydashboard)

library(purrr)
library(fs)
library(DT)




BASE_DIR <- "C:/Users/aj.kouassi/Downloads/DOCUMENTS/CAE/ENE_SURVEY_WEIGHTS"  
setwd(BASE_DIR)


######################### Chargement de la  base #########################
base_ENE_path = file.path(BASE_DIR, "data/04_weights/T3_2025/base_weights/individu_T3_2025.dta")
base_temp <- read_dta(file = base_ENE_path)


base_temp <- base_temp %>% select(ageannee, milieu, m5, hh2)

################ Construction des variables et contraintes ###############

base_temp <- cbind( base_temp , data.frame(matrix(0 , nrow = nrow(base_temp), ncol =  444, byrow = FALSE)))


# NATIONAL LEVEL - MALE BY URBAN LOCATION AND 12 AGE GROUP

base_temp$X1[ base_temp$ageannee>=  0 & base_temp$ageannee <=14 & base_temp$milieu==1 & base_temp$m5==1]<- 1
base_temp$X2[ base_temp$ageannee>= 15 & base_temp$ageannee <=19 & base_temp$milieu==1 & base_temp$m5==1]<- 1
base_temp$X3[ base_temp$ageannee>= 20 & base_temp$ageannee <=24 & base_temp$milieu==1 & base_temp$m5==1]<- 1
base_temp$X4[ base_temp$ageannee>= 25 & base_temp$ageannee <=29 & base_temp$milieu==1 & base_temp$m5==1]<- 1
base_temp$X5[ base_temp$ageannee>= 30 & base_temp$ageannee <=34 & base_temp$milieu==1 & base_temp$m5==1]<- 1
base_temp$X6[ base_temp$ageannee>= 35 & base_temp$ageannee <=39 & base_temp$milieu==1 & base_temp$m5==1]<- 1
base_temp$X7[ base_temp$ageannee>= 40 & base_temp$ageannee <=44 & base_temp$milieu==1 & base_temp$m5==1]<- 1
base_temp$X8[ base_temp$ageannee>= 45 & base_temp$ageannee <=49 & base_temp$milieu==1 & base_temp$m5==1]<- 1
base_temp$X9[ base_temp$ageannee>= 50 & base_temp$ageannee <=54 & base_temp$milieu==1 & base_temp$m5==1]<- 1
base_temp$X10[base_temp$ageannee>= 55 & base_temp$ageannee <=59 & base_temp$milieu==1 & base_temp$m5==1]<- 1
base_temp$X11[base_temp$ageannee>= 60 & base_temp$ageannee <=64 & base_temp$milieu==1 & base_temp$m5==1]<- 1
base_temp$X12[base_temp$ageannee>= 65                  & base_temp$milieu==1 & base_temp$m5==1]<- 1


# NATIONAL LEVEL - MALE BY RURAL LOCATION AND 12 AGE GROUP

base_temp$X13[ base_temp$ageannee>=  0 & base_temp$ageannee <=14 & base_temp$milieu==2 & base_temp$m5==1]<- 1
base_temp$X14[ base_temp$ageannee>= 15 & base_temp$ageannee <=19 & base_temp$milieu==2 & base_temp$m5==1]<- 1
base_temp$X15[ base_temp$ageannee>= 20 & base_temp$ageannee <=24 & base_temp$milieu==2 & base_temp$m5==1]<- 1
base_temp$X16[ base_temp$ageannee>= 25 & base_temp$ageannee <=29 & base_temp$milieu==2 & base_temp$m5==1]<- 1
base_temp$X17[ base_temp$ageannee>= 30 & base_temp$ageannee <=34 & base_temp$milieu==2 & base_temp$m5==1]<- 1
base_temp$X18[ base_temp$ageannee>= 35 & base_temp$ageannee <=39 & base_temp$milieu==2 & base_temp$m5==1]<- 1
base_temp$X19[ base_temp$ageannee>= 40 & base_temp$ageannee <=44 & base_temp$milieu==2 & base_temp$m5==1]<- 1
base_temp$X20[ base_temp$ageannee>= 45 & base_temp$ageannee <=49 & base_temp$milieu==2 & base_temp$m5==1]<- 1
base_temp$X21[ base_temp$ageannee>= 50 & base_temp$ageannee <=54 & base_temp$milieu==2 & base_temp$m5==1]<- 1
base_temp$X22[base_temp$ageannee>= 55 & base_temp$ageannee <=59 & base_temp$milieu==2 & base_temp$m5==1]<- 1
base_temp$X23[base_temp$ageannee>= 60 & base_temp$ageannee <=64 & base_temp$milieu==2 & base_temp$m5==1]<- 1
base_temp$X24[base_temp$ageannee>= 65                  & base_temp$milieu==2 & base_temp$m5==1]<- 1



# NATIONAL LEVEL - FEMALE BY URBAN LOCATION AND 12 AGE GROUP

base_temp$X25[ base_temp$ageannee>=  0 & base_temp$ageannee <=14 & base_temp$milieu==1 & base_temp$m5==2]<- 1
base_temp$X26[ base_temp$ageannee>= 15 & base_temp$ageannee <=19 & base_temp$milieu==1 & base_temp$m5==2]<- 1
base_temp$X27[ base_temp$ageannee>= 20 & base_temp$ageannee <=24 & base_temp$milieu==1 & base_temp$m5==2]<- 1
base_temp$X28[ base_temp$ageannee>= 25 & base_temp$ageannee <=29 & base_temp$milieu==1 & base_temp$m5==2]<- 1
base_temp$X29[ base_temp$ageannee>= 30 & base_temp$ageannee <=34 & base_temp$milieu==1 & base_temp$m5==2]<- 1
base_temp$X30[ base_temp$ageannee>= 35 & base_temp$ageannee <=39 & base_temp$milieu==1 & base_temp$m5==2]<- 1
base_temp$X31[ base_temp$ageannee>= 40 & base_temp$ageannee <=44 & base_temp$milieu==1 & base_temp$m5==2]<- 1
base_temp$X32[ base_temp$ageannee>= 45 & base_temp$ageannee <=49 & base_temp$milieu==1 & base_temp$m5==2]<- 1
base_temp$X33[ base_temp$ageannee>= 50 & base_temp$ageannee <=54 & base_temp$milieu==1 & base_temp$m5==2]<- 1
base_temp$X34[base_temp$ageannee>= 55 & base_temp$ageannee <=59 & base_temp$milieu==1 & base_temp$m5==2]<- 1
base_temp$X35[base_temp$ageannee>= 60 & base_temp$ageannee <=64 & base_temp$milieu==1 & base_temp$m5==2]<- 1
base_temp$X36[base_temp$ageannee>= 65                  & base_temp$milieu==1 & base_temp$m5==2]<- 1


# NATIONAL LEVEL - FEMALE BY RURAL LOCATION AND 12 AGE GROUP


base_temp$X37[ base_temp$ageannee>=  0 & base_temp$ageannee <=14 & base_temp$milieu==2 & base_temp$m5==2]<- 1
base_temp$X38[ base_temp$ageannee>= 15 & base_temp$ageannee <=19 & base_temp$milieu==2 & base_temp$m5==2]<- 1
base_temp$X39[ base_temp$ageannee>= 20 & base_temp$ageannee <=24 & base_temp$milieu==2 & base_temp$m5==2]<- 1
base_temp$X40[ base_temp$ageannee>= 25 & base_temp$ageannee <=29 & base_temp$milieu==2 & base_temp$m5==2]<- 1
base_temp$X41[ base_temp$ageannee>= 30 & base_temp$ageannee <=34 & base_temp$milieu==2 & base_temp$m5==2]<- 1
base_temp$X42[ base_temp$ageannee>= 35 & base_temp$ageannee <=39 & base_temp$milieu==2 & base_temp$m5==2]<- 1
base_temp$X43[ base_temp$ageannee>= 40 & base_temp$ageannee <=44 & base_temp$milieu==2 & base_temp$m5==2]<- 1
base_temp$X44[ base_temp$ageannee>= 45 & base_temp$ageannee <=49 & base_temp$milieu==2 & base_temp$m5==2]<- 1
base_temp$X45[ base_temp$ageannee>= 50 & base_temp$ageannee <=54 & base_temp$milieu==2 & base_temp$m5==2]<- 1
base_temp$X46[base_temp$ageannee>= 55 & base_temp$ageannee <=59 & base_temp$milieu==2 & base_temp$m5==2]<- 1
base_temp$X47[base_temp$ageannee>= 60 & base_temp$ageannee <=64 & base_temp$milieu==2 & base_temp$m5==2]<- 1
base_temp$X48[base_temp$ageannee>= 65                  & base_temp$milieu==2 & base_temp$m5==2]<- 1


# REGION BY SEX BY URBAN_RURAL LOCATION AND 2 AGE GROUP

base_temp$X49[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10101] <- 1
base_temp$X50[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10101] <- 1
base_temp$X51[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10101] <- 1
base_temp$X52[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10101] <- 1
base_temp$X53[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10101] <- 1
base_temp$X54[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10101] <- 1
base_temp$X55[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10101] <- 1
base_temp$X56[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10101] <- 1
base_temp$X57[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10101] <- 1
base_temp$X58[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10101] <- 1
base_temp$X59[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10101] <- 1
base_temp$X60[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10101] <- 1
base_temp$X61[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10702] <- 1
base_temp$X62[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10702] <- 1
base_temp$X63[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10702] <- 1
base_temp$X64[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10702] <- 1
base_temp$X65[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10702] <- 1
base_temp$X66[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10702] <- 1
base_temp$X67[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10702] <- 1
base_temp$X68[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10702] <- 1
base_temp$X69[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10702] <- 1
base_temp$X70[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10702] <- 1
base_temp$X71[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10702] <- 1
base_temp$X72[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10702] <- 1
base_temp$X73[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11103] <- 1
base_temp$X74[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11103] <- 1
base_temp$X75[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11103] <- 1
base_temp$X76[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11103] <- 1
base_temp$X77[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11103] <- 1
base_temp$X78[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11103] <- 1
base_temp$X79[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11103] <- 1
base_temp$X80[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11103] <- 1
base_temp$X81[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11103] <- 1
base_temp$X82[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11103] <- 1
base_temp$X83[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11103] <- 1
base_temp$X84[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11103] <- 1
base_temp$X85[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11204] <- 1
base_temp$X86[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11204] <- 1
base_temp$X87[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11204] <- 1
base_temp$X88[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11204] <- 1
base_temp$X89[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11204] <- 1
base_temp$X90[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11204] <- 1
base_temp$X91[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11204] <- 1
base_temp$X92[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11204] <- 1
base_temp$X93[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11204] <- 1
base_temp$X94[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11204] <- 1
base_temp$X95[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11204] <- 1
base_temp$X96[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11204] <- 1
base_temp$X97[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10405] <- 1
base_temp$X98[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10405] <- 1
base_temp$X99[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10405] <- 1
base_temp$X100[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10405] <- 1
base_temp$X101[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10405] <- 1
base_temp$X102[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10405] <- 1
base_temp$X103[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10405] <- 1
base_temp$X104[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10405] <- 1
base_temp$X105[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10405] <- 1
base_temp$X106[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10405] <- 1
base_temp$X107[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10405] <- 1
base_temp$X108[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10405] <- 1
base_temp$X109[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11006] <- 1
base_temp$X110[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11006] <- 1
base_temp$X111[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11006] <- 1
base_temp$X112[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11006] <- 1
base_temp$X113[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11006] <- 1
base_temp$X114[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11006] <- 1
base_temp$X115[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11006] <- 1
base_temp$X116[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11006] <- 1
base_temp$X117[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11006] <- 1
base_temp$X118[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11006] <- 1
base_temp$X119[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11006] <- 1
base_temp$X120[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11006] <- 1
base_temp$X121[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10207] <- 1
base_temp$X122[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10207] <- 1
base_temp$X123[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10207] <- 1
base_temp$X124[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10207] <- 1
base_temp$X125[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10207] <- 1
base_temp$X126[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10207] <- 1
base_temp$X127[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10207] <- 1
base_temp$X128[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10207] <- 1
base_temp$X129[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10207] <- 1
base_temp$X130[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10207] <- 1
base_temp$X131[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10207] <- 1
base_temp$X132[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10207] <- 1
base_temp$X133[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11408] <- 1
base_temp$X134[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11408] <- 1
base_temp$X135[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11408] <- 1
base_temp$X136[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11408] <- 1
base_temp$X137[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11408] <- 1
base_temp$X138[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11408] <- 1
base_temp$X139[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11408] <- 1
base_temp$X140[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11408] <- 1
base_temp$X141[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11408] <- 1
base_temp$X142[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11408] <- 1
base_temp$X143[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11408] <- 1
base_temp$X144[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11408] <- 1
base_temp$X145[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10309] <- 1
base_temp$X146[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10309] <- 1
base_temp$X147[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10309] <- 1
base_temp$X148[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10309] <- 1
base_temp$X149[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10309] <- 1
base_temp$X150[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10309] <- 1
base_temp$X151[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10309] <- 1
base_temp$X152[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10309] <- 1
base_temp$X153[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10309] <- 1
base_temp$X154[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10309] <- 1
base_temp$X155[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10309] <- 1
base_temp$X156[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10309] <- 1
base_temp$X157[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10510] <- 1
base_temp$X158[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10510] <- 1
base_temp$X159[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10510] <- 1
base_temp$X160[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10510] <- 1
base_temp$X161[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10510] <- 1
base_temp$X162[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10510] <- 1
base_temp$X163[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10510] <- 1
base_temp$X164[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10510] <- 1
base_temp$X165[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10510] <- 1
base_temp$X166[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10510] <- 1
base_temp$X167[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10510] <- 1
base_temp$X168[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10510] <- 1
base_temp$X169[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10811] <- 1
base_temp$X170[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10811] <- 1
base_temp$X171[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10811] <- 1
base_temp$X172[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10811] <- 1
base_temp$X173[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10811] <- 1
base_temp$X174[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10811] <- 1
base_temp$X175[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10811] <- 1
base_temp$X176[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10811] <- 1
base_temp$X177[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10811] <- 1
base_temp$X178[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10811] <- 1
base_temp$X179[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10811] <- 1
base_temp$X180[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10811] <- 1
base_temp$X181[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10712] <- 1
base_temp$X182[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10712] <- 1
base_temp$X183[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10712] <- 1
base_temp$X184[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10712] <- 1
base_temp$X185[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10712] <- 1
base_temp$X186[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10712] <- 1
base_temp$X187[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10712] <- 1
base_temp$X188[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10712] <- 1
base_temp$X189[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10712] <- 1
base_temp$X190[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10712] <- 1
base_temp$X191[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10712] <- 1
base_temp$X192[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10712] <- 1
base_temp$X193[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10413] <- 1
base_temp$X194[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10413] <- 1
base_temp$X195[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10413] <- 1
base_temp$X196[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10413] <- 1
base_temp$X197[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10413] <- 1
base_temp$X198[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10413] <- 1
base_temp$X199[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10413] <- 1
base_temp$X200[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10413] <- 1
base_temp$X201[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10413] <- 1
base_temp$X202[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10413] <- 1
base_temp$X203[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10413] <- 1
base_temp$X204[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10413] <- 1
base_temp$X205[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11314] <- 1
base_temp$X206[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11314] <- 1
base_temp$X207[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11314] <- 1
base_temp$X208[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11314] <- 1
base_temp$X209[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11314] <- 1
base_temp$X210[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11314] <- 1
base_temp$X211[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11314] <- 1
base_temp$X212[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11314] <- 1
base_temp$X213[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11314] <- 1
base_temp$X214[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11314] <- 1
base_temp$X215[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11314] <- 1
base_temp$X216[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11314] <- 1
base_temp$X217[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10615] <- 1
base_temp$X218[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10615] <- 1
base_temp$X219[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10615] <- 1
base_temp$X220[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10615] <- 1
base_temp$X221[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10615] <- 1
base_temp$X222[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10615] <- 1
base_temp$X223[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10615] <- 1
base_temp$X224[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10615] <- 1
base_temp$X225[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10615] <- 1
base_temp$X226[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10615] <- 1
base_temp$X227[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10615] <- 1
base_temp$X228[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10615] <- 1
base_temp$X229[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10916] <- 1
base_temp$X230[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10916] <- 1
base_temp$X231[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10916] <- 1
base_temp$X232[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10916] <- 1
base_temp$X233[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10916] <- 1
base_temp$X234[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10916] <- 1
base_temp$X235[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10916] <- 1
base_temp$X236[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10916] <- 1
base_temp$X237[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10916] <- 1
base_temp$X238[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10916] <- 1
base_temp$X239[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10916] <- 1
base_temp$X240[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10916] <- 1
base_temp$X241[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10617] <- 1
base_temp$X242[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10617] <- 1
base_temp$X243[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10617] <- 1
base_temp$X244[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10617] <- 1
base_temp$X245[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10617] <- 1
base_temp$X246[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10617] <- 1
base_temp$X247[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10617] <- 1
base_temp$X248[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10617] <- 1
base_temp$X249[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10617] <- 1
base_temp$X250[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10617] <- 1
base_temp$X251[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10617] <- 1
base_temp$X252[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10617] <- 1
base_temp$X253[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11018] <- 1
base_temp$X254[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11018] <- 1
base_temp$X255[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11018] <- 1
base_temp$X256[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11018] <- 1
base_temp$X257[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11018] <- 1
base_temp$X258[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11018] <- 1
base_temp$X259[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11018] <- 1
base_temp$X260[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11018] <- 1
base_temp$X261[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11018] <- 1
base_temp$X262[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11018] <- 1
base_temp$X263[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11018] <- 1
base_temp$X264[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11018] <- 1
base_temp$X265[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11319] <- 1
base_temp$X266[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11319] <- 1
base_temp$X267[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11319] <- 1
base_temp$X268[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11319] <- 1
base_temp$X269[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11319] <- 1
base_temp$X270[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11319] <- 1
base_temp$X271[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11319] <- 1
base_temp$X272[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11319] <- 1
base_temp$X273[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11319] <- 1
base_temp$X274[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11319] <- 1
base_temp$X275[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11319] <- 1
base_temp$X276[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11319] <- 1
base_temp$X277[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11120] <- 1
base_temp$X278[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11120] <- 1
base_temp$X279[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11120] <- 1
base_temp$X280[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11120] <- 1
base_temp$X281[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11120] <- 1
base_temp$X282[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11120] <- 1
base_temp$X283[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11120] <- 1
base_temp$X284[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11120] <- 1
base_temp$X285[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11120] <- 1
base_temp$X286[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11120] <- 1
base_temp$X287[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11120] <- 1
base_temp$X288[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11120] <- 1
base_temp$X289[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10821] <- 1
base_temp$X290[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10821] <- 1
base_temp$X291[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10821] <- 1
base_temp$X292[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10821] <- 1
base_temp$X293[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10821] <- 1
base_temp$X294[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10821] <- 1
base_temp$X295[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10821] <- 1
base_temp$X296[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10821] <- 1
base_temp$X297[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10821] <- 1
base_temp$X298[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10821] <- 1
base_temp$X299[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10821] <- 1
base_temp$X300[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10821] <- 1
base_temp$X301[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11322] <- 1
base_temp$X302[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11322] <- 1
base_temp$X303[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11322] <- 1
base_temp$X304[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11322] <- 1
base_temp$X305[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11322] <- 1
base_temp$X306[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11322] <- 1
base_temp$X307[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11322] <- 1
base_temp$X308[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11322] <- 1
base_temp$X309[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11322] <- 1
base_temp$X310[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11322] <- 1
base_temp$X311[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11322] <- 1
base_temp$X312[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11322] <- 1
base_temp$X313[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11423] <- 1
base_temp$X314[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11423] <- 1
base_temp$X315[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11423] <- 1
base_temp$X316[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11423] <- 1
base_temp$X317[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11423] <- 1
base_temp$X318[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11423] <- 1
base_temp$X319[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11423] <- 1
base_temp$X320[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11423] <- 1
base_temp$X321[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11423] <- 1
base_temp$X322[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11423] <- 1
base_temp$X323[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11423] <- 1
base_temp$X324[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11423] <- 1
base_temp$X325[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10524] <- 1
base_temp$X326[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10524] <- 1
base_temp$X327[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10524] <- 1
base_temp$X328[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10524] <- 1
base_temp$X329[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10524] <- 1
base_temp$X330[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10524] <- 1
base_temp$X331[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10524] <- 1
base_temp$X332[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10524] <- 1
base_temp$X333[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10524] <- 1
base_temp$X334[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10524] <- 1
base_temp$X335[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10524] <- 1
base_temp$X336[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10524] <- 1
base_temp$X337[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10325] <- 1
base_temp$X338[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10325] <- 1
base_temp$X339[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10325] <- 1
base_temp$X340[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10325] <- 1
base_temp$X341[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10325] <- 1
base_temp$X342[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10325] <- 1
base_temp$X343[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10325] <- 1
base_temp$X344[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10325] <- 1
base_temp$X345[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10325] <- 1
base_temp$X346[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10325] <- 1
base_temp$X347[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10325] <- 1
base_temp$X348[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10325] <- 1
base_temp$X349[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10926] <- 1
base_temp$X350[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10926] <- 1
base_temp$X351[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10926] <- 1
base_temp$X352[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10926] <- 1
base_temp$X353[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10926] <- 1
base_temp$X354[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10926] <- 1
base_temp$X355[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10926] <- 1
base_temp$X356[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10926] <- 1
base_temp$X357[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10926] <- 1
base_temp$X358[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10926] <- 1
base_temp$X359[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10926] <- 1
base_temp$X360[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10926] <- 1
base_temp$X361[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11027] <- 1
base_temp$X362[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11027] <- 1
base_temp$X363[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11027] <- 1
base_temp$X364[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11027] <- 1
base_temp$X365[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11027] <- 1
base_temp$X366[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11027] <- 1
base_temp$X367[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11027] <- 1
base_temp$X368[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11027] <- 1
base_temp$X369[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11027] <- 1
base_temp$X370[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11027] <- 1
base_temp$X371[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11027] <- 1
base_temp$X372[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11027] <- 1
base_temp$X373[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11228] <- 1
base_temp$X374[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11228] <- 1
base_temp$X375[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11228] <- 1
base_temp$X376[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11228] <- 1
base_temp$X377[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11228] <- 1
base_temp$X378[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11228] <- 1
base_temp$X379[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11228] <- 1
base_temp$X380[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11228] <- 1
base_temp$X381[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11228] <- 1
base_temp$X382[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11228] <- 1
base_temp$X383[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11228] <- 1
base_temp$X384[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11228] <- 1
base_temp$X385[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10829] <- 1
base_temp$X386[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10829] <- 1
base_temp$X387[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10829] <- 1
base_temp$X388[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10829] <- 1
base_temp$X389[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10829] <- 1
base_temp$X390[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10829] <- 1
base_temp$X391[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10829] <- 1
base_temp$X392[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10829] <- 1
base_temp$X393[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10829] <- 1
base_temp$X394[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10829] <- 1
base_temp$X395[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10829] <- 1
base_temp$X396[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10829] <- 1
base_temp$X397[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10930] <- 1
base_temp$X398[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10930] <- 1
base_temp$X399[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10930] <- 1
base_temp$X400[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10930] <- 1
base_temp$X401[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10930] <- 1
base_temp$X402[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10930] <- 1
base_temp$X403[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10930] <- 1
base_temp$X404[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10930] <- 1
base_temp$X405[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10930] <- 1
base_temp$X406[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10930] <- 1
base_temp$X407[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10930] <- 1
base_temp$X408[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10930] <- 1
base_temp$X409[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10331] <- 1
base_temp$X410[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10331] <- 1
base_temp$X411[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10331] <- 1
base_temp$X412[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10331] <- 1
base_temp$X413[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10331] <- 1
base_temp$X414[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10331] <- 1
base_temp$X415[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10331] <- 1
base_temp$X416[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10331] <- 1
base_temp$X417[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10331] <- 1
base_temp$X418[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10331] <- 1
base_temp$X419[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10331] <- 1
base_temp$X420[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10331] <- 1
base_temp$X421[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11132] <- 1
base_temp$X422[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11132] <- 1
base_temp$X423[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==11132] <- 1
base_temp$X424[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11132] <- 1
base_temp$X425[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11132] <- 1
base_temp$X426[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==11132] <- 1
base_temp$X427[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11132] <- 1
base_temp$X428[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11132] <- 1
base_temp$X429[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==11132] <- 1
base_temp$X430[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11132] <- 1
base_temp$X431[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11132] <- 1
base_temp$X432[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==11132] <- 1
base_temp$X433[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10833] <- 1
base_temp$X434[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10833] <- 1
base_temp$X435[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 1 & base_temp$hh2==10833] <- 1
base_temp$X436[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10833] <- 1
base_temp$X437[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10833] <- 1
base_temp$X438[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 1 & base_temp$hh2==10833] <- 1
base_temp$X439[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10833] <- 1
base_temp$X440[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10833] <- 1
base_temp$X441[ base_temp$ageannee>= 35 & base_temp$milieu== 1 & base_temp$m5== 2 & base_temp$hh2==10833] <- 1
base_temp$X442[ base_temp$ageannee>= 0 & base_temp$ageannee <= 14 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10833] <- 1
base_temp$X443[ base_temp$ageannee>= 15 & base_temp$ageannee <= 34 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10833] <- 1
base_temp$X444[ base_temp$ageannee>= 35 & base_temp$milieu== 2 & base_temp$m5== 2 & base_temp$hh2==10833] <- 1





table_agg <- data.frame(X_Constraints = paste0("X", 1:444),
                        Sample_size = colSums(base_temp[paste0("X", 1:444)], na.rm = TRUE)
                        )




##################### Association des labels #########################


table_agg$X_Labels[table_agg$X_Constraints=="X1"] <- "X1: NATIONAL MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X2"] <- "X2: NATIONAL MILIEU URBAIN SEX MASCULIN AGE 15_19"
table_agg$X_Labels[table_agg$X_Constraints=="X3"] <- "X3: NATIONAL MILIEU URBAIN SEX MASCULIN AGE 20_24"
table_agg$X_Labels[table_agg$X_Constraints=="X4"] <- "X4: NATIONAL MILIEU URBAIN SEX MASCULIN AGE 25_29"
table_agg$X_Labels[table_agg$X_Constraints=="X5"] <- "X5: NATIONAL MILIEU URBAIN SEX MASCULIN AGE 30_34"
table_agg$X_Labels[table_agg$X_Constraints=="X6"] <- "X6: NATIONAL MILIEU URBAIN SEX MASCULIN AGE 35_39"
table_agg$X_Labels[table_agg$X_Constraints=="X7"] <- "X7: NATIONAL MILIEU URBAIN SEX MASCULIN AGE 40_44"
table_agg$X_Labels[table_agg$X_Constraints=="X8"] <- "X8: NATIONAL MILIEU URBAIN SEX MASCULIN AGE 45_49"
table_agg$X_Labels[table_agg$X_Constraints=="X9"] <- "X9: NATIONAL MILIEU URBAIN SEX MASCULIN AGE 50_54"
table_agg$X_Labels[table_agg$X_Constraints=="X10"] <- "X10: NATIONAL MILIEU URBAIN SEX MASCULIN AGE 55_59"
table_agg$X_Labels[table_agg$X_Constraints=="X11"] <- "X11: NATIONAL MILIEU URBAIN SEX MASCULIN AGE 60_64"
table_agg$X_Labels[table_agg$X_Constraints=="X12"] <- "X12: NATIONAL MILIEU URBAIN SEX MASCULIN AGE 65_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X13"] <- "X13: NATIONAL MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X14"] <- "X14: NATIONAL MILIEU RURAL SEX MASCULIN AGE 15_19"
table_agg$X_Labels[table_agg$X_Constraints=="X15"] <- "X15: NATIONAL MILIEU RURAL SEX MASCULIN AGE 20_24"
table_agg$X_Labels[table_agg$X_Constraints=="X16"] <- "X16: NATIONAL MILIEU RURAL SEX MASCULIN AGE 25_29"
table_agg$X_Labels[table_agg$X_Constraints=="X17"] <- "X17: NATIONAL MILIEU RURAL SEX MASCULIN AGE 30_34"
table_agg$X_Labels[table_agg$X_Constraints=="X18"] <- "X18: NATIONAL MILIEU RURAL SEX MASCULIN AGE 35_39"
table_agg$X_Labels[table_agg$X_Constraints=="X19"] <- "X19: NATIONAL MILIEU RURAL SEX MASCULIN AGE 40_44"
table_agg$X_Labels[table_agg$X_Constraints=="X20"] <- "X20: NATIONAL MILIEU RURAL SEX MASCULIN AGE 45_49"
table_agg$X_Labels[table_agg$X_Constraints=="X21"] <- "X21: NATIONAL MILIEU RURAL SEX MASCULIN AGE 50_54"
table_agg$X_Labels[table_agg$X_Constraints=="X22"] <- "X22: NATIONAL MILIEU RURAL SEX MASCULIN AGE 55_59"
table_agg$X_Labels[table_agg$X_Constraints=="X23"] <- "X23: NATIONAL MILIEU RURAL SEX MASCULIN AGE 60_64"
table_agg$X_Labels[table_agg$X_Constraints=="X24"] <- "X24: NATIONAL MILIEU RURAL SEX MASCULIN AGE 65_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X25"] <- "X25: NATIONAL MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X26"] <- "X26: NATIONAL MILIEU URBAIN SEX FEMININ AGE 15_19"
table_agg$X_Labels[table_agg$X_Constraints=="X27"] <- "X27: NATIONAL MILIEU URBAIN SEX FEMININ AGE 20_24"
table_agg$X_Labels[table_agg$X_Constraints=="X28"] <- "X28: NATIONAL MILIEU URBAIN SEX FEMININ AGE 25_29"
table_agg$X_Labels[table_agg$X_Constraints=="X29"] <- "X29: NATIONAL MILIEU URBAIN SEX FEMININ AGE 30_34"
table_agg$X_Labels[table_agg$X_Constraints=="X30"] <- "X30: NATIONAL MILIEU URBAIN SEX FEMININ AGE 35_39"
table_agg$X_Labels[table_agg$X_Constraints=="X31"] <- "X31: NATIONAL MILIEU URBAIN SEX FEMININ AGE 40_44"
table_agg$X_Labels[table_agg$X_Constraints=="X32"] <- "X32: NATIONAL MILIEU URBAIN SEX FEMININ AGE 45_49"
table_agg$X_Labels[table_agg$X_Constraints=="X33"] <- "X33: NATIONAL MILIEU URBAIN SEX FEMININ AGE 50_54"
table_agg$X_Labels[table_agg$X_Constraints=="X34"] <- "X34: NATIONAL MILIEU URBAIN SEX FEMININ AGE 55_59"
table_agg$X_Labels[table_agg$X_Constraints=="X35"] <- "X35: NATIONAL MILIEU URBAIN SEX FEMININ AGE 60_64"
table_agg$X_Labels[table_agg$X_Constraints=="X36"] <- "X36: NATIONAL MILIEU URBAIN SEX FEMININ AGE 65_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X37"] <- "X37: NATIONAL MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X38"] <- "X38: NATIONAL MILIEU RURAL SEX FEMININ AGE 15_19"
table_agg$X_Labels[table_agg$X_Constraints=="X39"] <- "X39: NATIONAL MILIEU RURAL SEX FEMININ AGE 20_24"
table_agg$X_Labels[table_agg$X_Constraints=="X40"] <- "X40: NATIONAL MILIEU RURAL SEX FEMININ AGE 25_29"
table_agg$X_Labels[table_agg$X_Constraints=="X41"] <- "X41: NATIONAL MILIEU RURAL SEX FEMININ AGE 30_34"
table_agg$X_Labels[table_agg$X_Constraints=="X42"] <- "X42: NATIONAL MILIEU RURAL SEX FEMININ AGE 35_39"
table_agg$X_Labels[table_agg$X_Constraints=="X43"] <- "X43: NATIONAL MILIEU RURAL SEX FEMININ AGE 40_44"
table_agg$X_Labels[table_agg$X_Constraints=="X44"] <- "X44: NATIONAL MILIEU RURAL SEX FEMININ AGE 45_49"
table_agg$X_Labels[table_agg$X_Constraints=="X45"] <- "X45: NATIONAL MILIEU RURAL SEX FEMININ AGE 50_54"
table_agg$X_Labels[table_agg$X_Constraints=="X46"] <- "X46: NATIONAL MILIEU RURAL SEX FEMININ AGE 55_59"
table_agg$X_Labels[table_agg$X_Constraints=="X47"] <- "X47: NATIONAL MILIEU RURAL SEX FEMININ AGE 60_64"
table_agg$X_Labels[table_agg$X_Constraints=="X48"] <- "X48: NATIONAL MILIEU RURAL SEX FEMININ AGE 65_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X49"] <- "X49: ABIDJAN MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X50"] <- "X50: ABIDJAN MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X51"] <- "X51: ABIDJAN MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X52"] <- "X52: ABIDJAN MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X53"] <- "X53: ABIDJAN MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X54"] <- "X54: ABIDJAN MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X55"] <- "X55: ABIDJAN MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X56"] <- "X56: ABIDJAN MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X57"] <- "X57: ABIDJAN MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X58"] <- "X58: ABIDJAN MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X59"] <- "X59: ABIDJAN MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X60"] <- "X60: ABIDJAN MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X61"] <- "X61: HAUT-SASSANDRA MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X62"] <- "X62: HAUT-SASSANDRA MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X63"] <- "X63: HAUT-SASSANDRA MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X64"] <- "X64: HAUT-SASSANDRA MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X65"] <- "X65: HAUT-SASSANDRA MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X66"] <- "X66: HAUT-SASSANDRA MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X67"] <- "X67: HAUT-SASSANDRA MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X68"] <- "X68: HAUT-SASSANDRA MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X69"] <- "X69: HAUT-SASSANDRA MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X70"] <- "X70: HAUT-SASSANDRA MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X71"] <- "X71: HAUT-SASSANDRA MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X72"] <- "X72: HAUT-SASSANDRA MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X73"] <- "X73: PORO MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X74"] <- "X74: PORO MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X75"] <- "X75: PORO MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X76"] <- "X76: PORO MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X77"] <- "X77: PORO MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X78"] <- "X78: PORO MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X79"] <- "X79: PORO MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X80"] <- "X80: PORO MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X81"] <- "X81: PORO MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X82"] <- "X82: PORO MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X83"] <- "X83: PORO MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X84"] <- "X84: PORO MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X85"] <- "X85: GBEKE MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X86"] <- "X86: GBEKE MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X87"] <- "X87: GBEKE MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X88"] <- "X88: GBEKE MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X89"] <- "X89: GBEKE MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X90"] <- "X90: GBEKE MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X91"] <- "X91: GBEKE MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X92"] <- "X92: GBEKE MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X93"] <- "X93: GBEKE MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X94"] <- "X94: GBEKE MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X95"] <- "X95: GBEKE MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X96"] <- "X96: GBEKE MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X97"] <- "X97: INDENIE-DJUABLIN MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X98"] <- "X98: INDENIE-DJUABLIN MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X99"] <- "X99: INDENIE-DJUABLIN MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X100"] <- "X100: INDENIE-DJUABLIN MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X101"] <- "X101: INDENIE-DJUABLIN MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X102"] <- "X102: INDENIE-DJUABLIN MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X103"] <- "X103: INDENIE-DJUABLIN MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X104"] <- "X104: INDENIE-DJUABLIN MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X105"] <- "X105: INDENIE-DJUABLIN MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X106"] <- "X106: INDENIE-DJUABLIN MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X107"] <- "X107: INDENIE-DJUABLIN MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X108"] <- "X108: INDENIE-DJUABLIN MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X109"] <- "X109: TONKPI MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X110"] <- "X110: TONKPI MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X111"] <- "X111: TONKPI MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X112"] <- "X112: TONKPI MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X113"] <- "X113: TONKPI MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X114"] <- "X114: TONKPI MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X115"] <- "X115: TONKPI MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X116"] <- "X116: TONKPI MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X117"] <- "X117: TONKPI MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X118"] <- "X118: TONKPI MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X119"] <- "X119: TONKPI MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X120"] <- "X120: TONKPI MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X121"] <- "X121: YAMOUSSOUKRO MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X122"] <- "X122: YAMOUSSOUKRO MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X123"] <- "X123: YAMOUSSOUKRO MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X124"] <- "X124: YAMOUSSOUKRO MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X125"] <- "X125: YAMOUSSOUKRO MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X126"] <- "X126: YAMOUSSOUKRO MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X127"] <- "X127: YAMOUSSOUKRO MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X128"] <- "X128: YAMOUSSOUKRO MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X129"] <- "X129: YAMOUSSOUKRO MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X130"] <- "X130: YAMOUSSOUKRO MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X131"] <- "X131: YAMOUSSOUKRO MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X132"] <- "X132: YAMOUSSOUKRO MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X133"] <- "X133: GONTOUGO MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X134"] <- "X134: GONTOUGO MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X135"] <- "X135: GONTOUGO MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X136"] <- "X136: GONTOUGO MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X137"] <- "X137: GONTOUGO MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X138"] <- "X138: GONTOUGO MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X139"] <- "X139: GONTOUGO MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X140"] <- "X140: GONTOUGO MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X141"] <- "X141: GONTOUGO MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X142"] <- "X142: GONTOUGO MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X143"] <- "X143: GONTOUGO MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X144"] <- "X144: GONTOUGO MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X145"] <- "X145: SAN-PEDRO MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X146"] <- "X146: SAN-PEDRO MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X147"] <- "X147: SAN-PEDRO MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X148"] <- "X148: SAN-PEDRO MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X149"] <- "X149: SAN-PEDRO MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X150"] <- "X150: SAN-PEDRO MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X151"] <- "X151: SAN-PEDRO MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X152"] <- "X152: SAN-PEDRO MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X153"] <- "X153: SAN-PEDRO MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X154"] <- "X154: SAN-PEDRO MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X155"] <- "X155: SAN-PEDRO MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X156"] <- "X156: SAN-PEDRO MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X157"] <- "X157: KABADOUGOU MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X158"] <- "X158: KABADOUGOU MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X159"] <- "X159: KABADOUGOU MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X160"] <- "X160: KABADOUGOU MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X161"] <- "X161: KABADOUGOU MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X162"] <- "X162: KABADOUGOU MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X163"] <- "X163: KABADOUGOU MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X164"] <- "X164: KABADOUGOU MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X165"] <- "X165: KABADOUGOU MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X166"] <- "X166: KABADOUGOU MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X167"] <- "X167: KABADOUGOU MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X168"] <- "X168: KABADOUGOU MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X169"] <- "X169: N'ZI MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X170"] <- "X170: N'ZI MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X171"] <- "X171: N'ZI MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X172"] <- "X172: N'ZI MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X173"] <- "X173: N'ZI MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X174"] <- "X174: N'ZI MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X175"] <- "X175: N'ZI MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X176"] <- "X176: N'ZI MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X177"] <- "X177: N'ZI MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X178"] <- "X178: N'ZI MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X179"] <- "X179: N'ZI MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X180"] <- "X180: N'ZI MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X181"] <- "X181: MARAHOUE MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X182"] <- "X182: MARAHOUE MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X183"] <- "X183: MARAHOUE MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X184"] <- "X184: MARAHOUE MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X185"] <- "X185: MARAHOUE MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X186"] <- "X186: MARAHOUE MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X187"] <- "X187: MARAHOUE MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X188"] <- "X188: MARAHOUE MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X189"] <- "X189: MARAHOUE MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X190"] <- "X190: MARAHOUE MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X191"] <- "X191: MARAHOUE MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X192"] <- "X192: MARAHOUE MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X193"] <- "X193: SUD-COMOE MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X194"] <- "X194: SUD-COMOE MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X195"] <- "X195: SUD-COMOE MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X196"] <- "X196: SUD-COMOE MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X197"] <- "X197: SUD-COMOE MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X198"] <- "X198: SUD-COMOE MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X199"] <- "X199: SUD-COMOE MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X200"] <- "X200: SUD-COMOE MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X201"] <- "X201: SUD-COMOE MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X202"] <- "X202: SUD-COMOE MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X203"] <- "X203: SUD-COMOE MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X204"] <- "X204: SUD-COMOE MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X205"] <- "X205: WORODOUGOU MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X206"] <- "X206: WORODOUGOU MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X207"] <- "X207: WORODOUGOU MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X208"] <- "X208: WORODOUGOU MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X209"] <- "X209: WORODOUGOU MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X210"] <- "X210: WORODOUGOU MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X211"] <- "X211: WORODOUGOU MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X212"] <- "X212: WORODOUGOU MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X213"] <- "X213: WORODOUGOU MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X214"] <- "X214: WORODOUGOU MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X215"] <- "X215: WORODOUGOU MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X216"] <- "X216: WORODOUGOU MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X217"] <- "X217: LÔH-DJIBOUA MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X218"] <- "X218: LÔH-DJIBOUA MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X219"] <- "X219: LÔH-DJIBOUA MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X220"] <- "X220: LÔH-DJIBOUA MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X221"] <- "X221: LÔH-DJIBOUA MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X222"] <- "X222: LÔH-DJIBOUA MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X223"] <- "X223: LÔH-DJIBOUA MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X224"] <- "X224: LÔH-DJIBOUA MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X225"] <- "X225: LÔH-DJIBOUA MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X226"] <- "X226: LÔH-DJIBOUA MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X227"] <- "X227: LÔH-DJIBOUA MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X228"] <- "X228: LÔH-DJIBOUA MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X229"] <- "X229: AGNEBY-TIASSA MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X230"] <- "X230: AGNEBY-TIASSA MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X231"] <- "X231: AGNEBY-TIASSA MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X232"] <- "X232: AGNEBY-TIASSA MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X233"] <- "X233: AGNEBY-TIASSA MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X234"] <- "X234: AGNEBY-TIASSA MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X235"] <- "X235: AGNEBY-TIASSA MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X236"] <- "X236: AGNEBY-TIASSA MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X237"] <- "X237: AGNEBY-TIASSA MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X238"] <- "X238: AGNEBY-TIASSA MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X239"] <- "X239: AGNEBY-TIASSA MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X240"] <- "X240: AGNEBY-TIASSA MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X241"] <- "X241: GÔH MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X242"] <- "X242: GÔH MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X243"] <- "X243: GÔH MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X244"] <- "X244: GÔH MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X245"] <- "X245: GÔH MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X246"] <- "X246: GÔH MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X247"] <- "X247: GÔH MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X248"] <- "X248: GÔH MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X249"] <- "X249: GÔH MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X250"] <- "X250: GÔH MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X251"] <- "X251: GÔH MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X252"] <- "X252: GÔH MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X253"] <- "X253: CAVALLY MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X254"] <- "X254: CAVALLY MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X255"] <- "X255: CAVALLY MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X256"] <- "X256: CAVALLY MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X257"] <- "X257: CAVALLY MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X258"] <- "X258: CAVALLY MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X259"] <- "X259: CAVALLY MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X260"] <- "X260: CAVALLY MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X261"] <- "X261: CAVALLY MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X262"] <- "X262: CAVALLY MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X263"] <- "X263: CAVALLY MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X264"] <- "X264: CAVALLY MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X265"] <- "X265: BAFING MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X266"] <- "X266: BAFING MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X267"] <- "X267: BAFING MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X268"] <- "X268: BAFING MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X269"] <- "X269: BAFING MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X270"] <- "X270: BAFING MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X271"] <- "X271: BAFING MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X272"] <- "X272: BAFING MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X273"] <- "X273: BAFING MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X274"] <- "X274: BAFING MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X275"] <- "X275: BAFING MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X276"] <- "X276: BAFING MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X277"] <- "X277: BAGOUE MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X278"] <- "X278: BAGOUE MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X279"] <- "X279: BAGOUE MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X280"] <- "X280: BAGOUE MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X281"] <- "X281: BAGOUE MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X282"] <- "X282: BAGOUE MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X283"] <- "X283: BAGOUE MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X284"] <- "X284: BAGOUE MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X285"] <- "X285: BAGOUE MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X286"] <- "X286: BAGOUE MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X287"] <- "X287: BAGOUE MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X288"] <- "X288: BAGOUE MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X289"] <- "X289: BELIER MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X290"] <- "X290: BELIER MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X291"] <- "X291: BELIER MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X292"] <- "X292: BELIER MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X293"] <- "X293: BELIER MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X294"] <- "X294: BELIER MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X295"] <- "X295: BELIER MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X296"] <- "X296: BELIER MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X297"] <- "X297: BELIER MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X298"] <- "X298: BELIER MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X299"] <- "X299: BELIER MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X300"] <- "X300: BELIER MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X301"] <- "X301: BERE MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X302"] <- "X302: BERE MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X303"] <- "X303: BERE MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X304"] <- "X304: BERE MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X305"] <- "X305: BERE MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X306"] <- "X306: BERE MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X307"] <- "X307: BERE MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X308"] <- "X308: BERE MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X309"] <- "X309: BERE MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X310"] <- "X310: BERE MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X311"] <- "X311: BERE MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X312"] <- "X312: BERE MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X313"] <- "X313: BOUNKANI MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X314"] <- "X314: BOUNKANI MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X315"] <- "X315: BOUNKANI MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X316"] <- "X316: BOUNKANI MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X317"] <- "X317: BOUNKANI MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X318"] <- "X318: BOUNKANI MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X319"] <- "X319: BOUNKANI MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X320"] <- "X320: BOUNKANI MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X321"] <- "X321: BOUNKANI MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X322"] <- "X322: BOUNKANI MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X323"] <- "X323: BOUNKANI MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X324"] <- "X324: BOUNKANI MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X325"] <- "X325: FOLON MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X326"] <- "X326: FOLON MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X327"] <- "X327: FOLON MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X328"] <- "X328: FOLON MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X329"] <- "X329: FOLON MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X330"] <- "X330: FOLON MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X331"] <- "X331: FOLON MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X332"] <- "X332: FOLON MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X333"] <- "X333: FOLON MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X334"] <- "X334: FOLON MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X335"] <- "X335: FOLON MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X336"] <- "X336: FOLON MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X337"] <- "X337: GBOKLE MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X338"] <- "X338: GBOKLE MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X339"] <- "X339: GBOKLE MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X340"] <- "X340: GBOKLE MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X341"] <- "X341: GBOKLE MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X342"] <- "X342: GBOKLE MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X343"] <- "X343: GBOKLE MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X344"] <- "X344: GBOKLE MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X345"] <- "X345: GBOKLE MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X346"] <- "X346: GBOKLE MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X347"] <- "X347: GBOKLE MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X348"] <- "X348: GBOKLE MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X349"] <- "X349: GRAND-PONTS MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X350"] <- "X350: GRAND-PONTS MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X351"] <- "X351: GRAND-PONTS MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X352"] <- "X352: GRAND-PONTS MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X353"] <- "X353: GRAND-PONTS MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X354"] <- "X354: GRAND-PONTS MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X355"] <- "X355: GRAND-PONTS MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X356"] <- "X356: GRAND-PONTS MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X357"] <- "X357: GRAND-PONTS MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X358"] <- "X358: GRAND-PONTS MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X359"] <- "X359: GRAND-PONTS MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X360"] <- "X360: GRAND-PONTS MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X361"] <- "X361: GUEMON MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X362"] <- "X362: GUEMON MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X363"] <- "X363: GUEMON MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X364"] <- "X364: GUEMON MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X365"] <- "X365: GUEMON MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X366"] <- "X366: GUEMON MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X367"] <- "X367: GUEMON MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X368"] <- "X368: GUEMON MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X369"] <- "X369: GUEMON MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X370"] <- "X370: GUEMON MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X371"] <- "X371: GUEMON MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X372"] <- "X372: GUEMON MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X373"] <- "X373: HAMBOL MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X374"] <- "X374: HAMBOL MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X375"] <- "X375: HAMBOL MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X376"] <- "X376: HAMBOL MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X377"] <- "X377: HAMBOL MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X378"] <- "X378: HAMBOL MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X379"] <- "X379: HAMBOL MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X380"] <- "X380: HAMBOL MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X381"] <- "X381: HAMBOL MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X382"] <- "X382: HAMBOL MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X383"] <- "X383: HAMBOL MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X384"] <- "X384: HAMBOL MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X385"] <- "X385: IFFOU MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X386"] <- "X386: IFFOU MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X387"] <- "X387: IFFOU MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X388"] <- "X388: IFFOU MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X389"] <- "X389: IFFOU MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X390"] <- "X390: IFFOU MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X391"] <- "X391: IFFOU MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X392"] <- "X392: IFFOU MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X393"] <- "X393: IFFOU MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X394"] <- "X394: IFFOU MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X395"] <- "X395: IFFOU MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X396"] <- "X396: IFFOU MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X397"] <- "X397: LA ME MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X398"] <- "X398: LA ME MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X399"] <- "X399: LA ME MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X400"] <- "X400: LA ME MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X401"] <- "X401: LA ME MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X402"] <- "X402: LA ME MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X403"] <- "X403: LA ME MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X404"] <- "X404: LA ME MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X405"] <- "X405: LA ME MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X406"] <- "X406: LA ME MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X407"] <- "X407: LA ME MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X408"] <- "X408: LA ME MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X409"] <- "X409: NAWA MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X410"] <- "X410: NAWA MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X411"] <- "X411: NAWA MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X412"] <- "X412: NAWA MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X413"] <- "X413: NAWA MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X414"] <- "X414: NAWA MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X415"] <- "X415: NAWA MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X416"] <- "X416: NAWA MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X417"] <- "X417: NAWA MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X418"] <- "X418: NAWA MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X419"] <- "X419: NAWA MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X420"] <- "X420: NAWA MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X421"] <- "X421: TCHOLOGO MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X422"] <- "X422: TCHOLOGO MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X423"] <- "X423: TCHOLOGO MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X424"] <- "X424: TCHOLOGO MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X425"] <- "X425: TCHOLOGO MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X426"] <- "X426: TCHOLOGO MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X427"] <- "X427: TCHOLOGO MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X428"] <- "X428: TCHOLOGO MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X429"] <- "X429: TCHOLOGO MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X430"] <- "X430: TCHOLOGO MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X431"] <- "X431: TCHOLOGO MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X432"] <- "X432: TCHOLOGO MILIEU RURAL SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X433"] <- "X433: MORONOU MILIEU URBAIN SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X434"] <- "X434: MORONOU MILIEU URBAIN SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X435"] <- "X435: MORONOU MILIEU URBAIN SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X436"] <- "X436: MORONOU MILIEU RURAL SEX MASCULIN AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X437"] <- "X437: MORONOU MILIEU RURAL SEX MASCULIN AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X438"] <- "X438: MORONOU MILIEU RURAL SEX MASCULIN AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X439"] <- "X439: MORONOU MILIEU URBAIN SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X440"] <- "X440: MORONOU MILIEU URBAIN SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X441"] <- "X441: MORONOU MILIEU URBAIN SEX FEMININ AGE 35_plus"
table_agg$X_Labels[table_agg$X_Constraints=="X442"] <- "X442: MORONOU MILIEU RURAL SEX FEMININ AGE 0_14"
table_agg$X_Labels[table_agg$X_Constraints=="X443"] <- "X443: MORONOU MILIEU RURAL SEX FEMININ AGE 15_34"
table_agg$X_Labels[table_agg$X_Constraints=="X444"] <- "X444: MORONOU MILIEU RURAL SEX FEMININ AGE 35_plus"




################# Dashboard #########################



table_agg <- table_agg %>%
  mutate(
    Small_sample_size = ifelse( Sample_size < 30, "⚠️ Size < 30", "✅" ) 
  ) %>%
  select(X_Labels, Sample_size, Small_sample_size)




# Appli Shiny
ui <- fluidPage(
  
  fluidRow(
    column(width = 2, tags$img(src = "Logo_ANStat.png", height = "50px")),
    column(width = 10, tags$h2(paste0("Point de tabulation sur les effectifs Région x Sexe x Milieu de résidence x groupe âge - ", str_extract(base_ENE_path, "T[1-4]_\\d{4}")), style = "text-align: center;font-family: 'Montserrat';"))
  ),
  
  
  fluidRow(
    column(width = 3, ""),         # colonne vide pour centrer
    column(width = 6, 
           style = "margin-right:-500px;font-family: 'Montserrat';",              # colonne centrale
           div(style = "text-align: center;",
               plotlyOutput("diagramme", height = "400px")
           )
    ),
    column(width = 3, "")          # colonne vide pour centrer
    
    
  ),
  
  fluidRow(
    column(
      style = "margin-right:-350px;font-family: 'Montserrat';",
      width = 12,
      DTOutput("Tableau_recap")
    )
    
  )
  
  
  
  
  
)

server <- function(input, output, session) {
  ##### Premier affichage avec le bouton radio
  
  
  ########## Tables statics 
  
  table_size <- table_agg %>%
      mutate(statut = ifelse(Sample_size < 30, "Small size", "Good size")) %>%
      group_by(statut) %>%
      summarise(Count = n())
  
  
  ############## Table de sortie
  
  output$Tableau_recap <- renderDT({
    datatable(
      table_agg,             
      rownames = TRUE,
      options = list(
        pageLength = dim(table_agg)[1],       # nombre de lignes visibles
        scrollY = "300px",    # hauteur du scroll vertical
        scrollX = TRUE,       # scroll horizontal automatique si besoin
        scrollCollapse = TRUE, # le scroll s’ajuste si peu de lignes
        lengthChange = FALSE,
        dom = 't',        # uniquement le tableau, pas la barre de recherche
        class = 'cell-border stripe'
      )
    )
  })
  
  
  ############## Les diagrammes de sortie
  
  output$diagramme <- renderPlotly({
    
    plot_ly(
      table_size,
      labels = ~statut, 
      values = ~Count,
      type = "pie",
      textinfo = "value",
      insidetextfont = list(size = 14, color = "white"),
      marker = list(colors = c( "#49655A", "#F28E2B")),    
      hoverinfo = "label+value+percent"
    ) %>%
      layout(
        title = list(
          text = "<b>Répartition des effectifs des contraintes</b>",
          font = list(size = 18),
          x = 0.5,
          xanchor = "center"
        ),
        showlegend = TRUE,
        margin = list(t = 80, b = 20, l = 20, r = 20),
        paper_bgcolor = "white",
        plot_bgcolor = "white"
      )
  })
  
  
  
  
}

shinyApp(ui, server)
