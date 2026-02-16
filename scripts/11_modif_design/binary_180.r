
tmpSD$X1[ tmpSD$ageannee>=  0 & tmpSD$ageannee <=14 & tmpSD$milieu_code==1 & tmpSD$m5_code==1]<- 1
tmpSD$X2[ tmpSD$ageannee>= 15 & tmpSD$ageannee <=19 & tmpSD$milieu_code==1 & tmpSD$m5_code==1]<- 1
tmpSD$X3[ tmpSD$ageannee>= 20 & tmpSD$ageannee <=24 & tmpSD$milieu_code==1 & tmpSD$m5_code==1]<- 1
tmpSD$X4[ tmpSD$ageannee>= 25 & tmpSD$ageannee <=29 & tmpSD$milieu_code==1 & tmpSD$m5_code==1]<- 1
tmpSD$X5[ tmpSD$ageannee>= 30 & tmpSD$ageannee <=34 & tmpSD$milieu_code==1 & tmpSD$m5_code==1]<- 1
tmpSD$X6[ tmpSD$ageannee>= 35 & tmpSD$ageannee <=39 & tmpSD$milieu_code==1 & tmpSD$m5_code==1]<- 1
tmpSD$X7[ tmpSD$ageannee>= 40 & tmpSD$ageannee <=44 & tmpSD$milieu_code==1 & tmpSD$m5_code==1]<- 1
tmpSD$X8[ tmpSD$ageannee>= 45 & tmpSD$ageannee <=49 & tmpSD$milieu_code==1 & tmpSD$m5_code==1]<- 1
tmpSD$X9[ tmpSD$ageannee>= 50 & tmpSD$ageannee <=54 & tmpSD$milieu_code==1 & tmpSD$m5_code==1]<- 1
tmpSD$X10[tmpSD$ageannee>= 55 & tmpSD$ageannee <=59 & tmpSD$milieu_code==1 & tmpSD$m5_code==1]<- 1
tmpSD$X11[tmpSD$ageannee>= 60 & tmpSD$ageannee <=64 & tmpSD$milieu_code==1 & tmpSD$m5_code==1]<- 1
tmpSD$X12[tmpSD$ageannee>= 65                  & tmpSD$milieu_code==1 & tmpSD$m5_code==1]<- 1


# NATIONAL LEVEL - MALE BY RURAL LOCATION AND 12 AGE GROUP

tmpSD$X13[ tmpSD$ageannee>=  0 & tmpSD$ageannee <=14 & tmpSD$milieu_code==2 & tmpSD$m5_code==1]<- 1
tmpSD$X14[ tmpSD$ageannee>= 15 & tmpSD$ageannee <=19 & tmpSD$milieu_code==2 & tmpSD$m5_code==1]<- 1
tmpSD$X15[ tmpSD$ageannee>= 20 & tmpSD$ageannee <=24 & tmpSD$milieu_code==2 & tmpSD$m5_code==1]<- 1
tmpSD$X16[ tmpSD$ageannee>= 25 & tmpSD$ageannee <=29 & tmpSD$milieu_code==2 & tmpSD$m5_code==1]<- 1
tmpSD$X17[ tmpSD$ageannee>= 30 & tmpSD$ageannee <=34 & tmpSD$milieu_code==2 & tmpSD$m5_code==1]<- 1
tmpSD$X18[ tmpSD$ageannee>= 35 & tmpSD$ageannee <=39 & tmpSD$milieu_code==2 & tmpSD$m5_code==1]<- 1
tmpSD$X19[ tmpSD$ageannee>= 40 & tmpSD$ageannee <=44 & tmpSD$milieu_code==2 & tmpSD$m5_code==1]<- 1
tmpSD$X20[ tmpSD$ageannee>= 45 & tmpSD$ageannee <=49 & tmpSD$milieu_code==2 & tmpSD$m5_code==1]<- 1
tmpSD$X21[ tmpSD$ageannee>= 50 & tmpSD$ageannee <=54 & tmpSD$milieu_code==2 & tmpSD$m5_code==1]<- 1
tmpSD$X22[tmpSD$ageannee>= 55 & tmpSD$ageannee <=59 & tmpSD$milieu_code==2 & tmpSD$m5_code==1]<- 1
tmpSD$X23[tmpSD$ageannee>= 60 & tmpSD$ageannee <=64 & tmpSD$milieu_code==2 & tmpSD$m5_code==1]<- 1
tmpSD$X24[tmpSD$ageannee>= 65                  & tmpSD$milieu_code==2 & tmpSD$m5_code==1]<- 1



# NATIONAL LEVEL - FEMALE BY URBAN LOCATION AND 12 AGE GROUP

tmpSD$X25[ tmpSD$ageannee>=  0 & tmpSD$ageannee <=14 & tmpSD$milieu_code==1 & tmpSD$m5_code==2]<- 1
tmpSD$X26[ tmpSD$ageannee>= 15 & tmpSD$ageannee <=19 & tmpSD$milieu_code==1 & tmpSD$m5_code==2]<- 1
tmpSD$X27[ tmpSD$ageannee>= 20 & tmpSD$ageannee <=24 & tmpSD$milieu_code==1 & tmpSD$m5_code==2]<- 1
tmpSD$X28[ tmpSD$ageannee>= 25 & tmpSD$ageannee <=29 & tmpSD$milieu_code==1 & tmpSD$m5_code==2]<- 1
tmpSD$X29[ tmpSD$ageannee>= 30 & tmpSD$ageannee <=34 & tmpSD$milieu_code==1 & tmpSD$m5_code==2]<- 1
tmpSD$X30[ tmpSD$ageannee>= 35 & tmpSD$ageannee <=39 & tmpSD$milieu_code==1 & tmpSD$m5_code==2]<- 1
tmpSD$X31[ tmpSD$ageannee>= 40 & tmpSD$ageannee <=44 & tmpSD$milieu_code==1 & tmpSD$m5_code==2]<- 1
tmpSD$X32[ tmpSD$ageannee>= 45 & tmpSD$ageannee <=49 & tmpSD$milieu_code==1 & tmpSD$m5_code==2]<- 1
tmpSD$X33[ tmpSD$ageannee>= 50 & tmpSD$ageannee <=54 & tmpSD$milieu_code==1 & tmpSD$m5_code==2]<- 1
tmpSD$X34[tmpSD$ageannee>= 55 & tmpSD$ageannee <=59 & tmpSD$milieu_code==1 & tmpSD$m5_code==2]<- 1
tmpSD$X35[tmpSD$ageannee>= 60 & tmpSD$ageannee <=64 & tmpSD$milieu_code==1 & tmpSD$m5_code==2]<- 1
tmpSD$X36[tmpSD$ageannee>= 65                  & tmpSD$milieu_code==1 & tmpSD$m5_code==2]<- 1


# NATIONAL LEVEL - FEMALE BY RURAL LOCATION AND 12 AGE GROUP


tmpSD$X37[ tmpSD$ageannee>=  0 & tmpSD$ageannee <=14 & tmpSD$milieu_code==2 & tmpSD$m5_code==2]<- 1
tmpSD$X38[ tmpSD$ageannee>= 15 & tmpSD$ageannee <=19 & tmpSD$milieu_code==2 & tmpSD$m5_code==2]<- 1
tmpSD$X39[ tmpSD$ageannee>= 20 & tmpSD$ageannee <=24 & tmpSD$milieu_code==2 & tmpSD$m5_code==2]<- 1
tmpSD$X40[ tmpSD$ageannee>= 25 & tmpSD$ageannee <=29 & tmpSD$milieu_code==2 & tmpSD$m5_code==2]<- 1
tmpSD$X41[ tmpSD$ageannee>= 30 & tmpSD$ageannee <=34 & tmpSD$milieu_code==2 & tmpSD$m5_code==2]<- 1
tmpSD$X42[ tmpSD$ageannee>= 35 & tmpSD$ageannee <=39 & tmpSD$milieu_code==2 & tmpSD$m5_code==2]<- 1
tmpSD$X43[ tmpSD$ageannee>= 40 & tmpSD$ageannee <=44 & tmpSD$milieu_code==2 & tmpSD$m5_code==2]<- 1
tmpSD$X44[ tmpSD$ageannee>= 45 & tmpSD$ageannee <=49 & tmpSD$milieu_code==2 & tmpSD$m5_code==2]<- 1
tmpSD$X45[ tmpSD$ageannee>= 50 & tmpSD$ageannee <=54 & tmpSD$milieu_code==2 & tmpSD$m5_code==2]<- 1
tmpSD$X46[tmpSD$ageannee>= 55 & tmpSD$ageannee <=59 & tmpSD$milieu_code==2 & tmpSD$m5_code==2]<- 1
tmpSD$X47[tmpSD$ageannee>= 60 & tmpSD$ageannee <=64 & tmpSD$milieu_code==2 & tmpSD$m5_code==2]<- 1
tmpSD$X48[tmpSD$ageannee>= 65                  & tmpSD$milieu_code==2 & tmpSD$m5_code==2]<- 1


# REGION BY SEX BY URBAN_RURAL LOCATION AND 2 AGE GROUP

tmpSD$X49[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10101] <- 1
tmpSD$X50[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10101] <- 1
tmpSD$X51[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10101] <- 1
tmpSD$X52[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10101] <- 1
tmpSD$X53[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10702] <- 1
tmpSD$X54[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10702] <- 1
tmpSD$X55[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10702] <- 1
tmpSD$X56[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10702] <- 1
tmpSD$X57[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==11103] <- 1
tmpSD$X58[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==11103] <- 1
tmpSD$X59[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==11103] <- 1
tmpSD$X60[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==11103] <- 1
tmpSD$X61[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==11204] <- 1
tmpSD$X62[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==11204] <- 1
tmpSD$X63[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==11204] <- 1
tmpSD$X64[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==11204] <- 1
tmpSD$X65[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10405] <- 1
tmpSD$X66[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10405] <- 1
tmpSD$X67[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10405] <- 1
tmpSD$X68[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10405] <- 1
tmpSD$X69[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==11006] <- 1
tmpSD$X70[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==11006] <- 1
tmpSD$X71[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==11006] <- 1
tmpSD$X72[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==11006] <- 1
tmpSD$X73[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10207] <- 1
tmpSD$X74[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10207] <- 1
tmpSD$X75[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10207] <- 1
tmpSD$X76[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10207] <- 1
tmpSD$X77[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==11408] <- 1
tmpSD$X78[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==11408] <- 1
tmpSD$X79[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==11408] <- 1
tmpSD$X80[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==11408] <- 1
tmpSD$X81[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10309] <- 1
tmpSD$X82[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10309] <- 1
tmpSD$X83[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10309] <- 1
tmpSD$X84[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10309] <- 1
tmpSD$X85[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10510] <- 1
tmpSD$X86[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10510] <- 1
tmpSD$X87[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10510] <- 1
tmpSD$X88[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10510] <- 1
tmpSD$X89[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10811] <- 1
tmpSD$X90[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10811] <- 1
tmpSD$X91[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10811] <- 1
tmpSD$X92[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10811] <- 1
tmpSD$X93[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10712] <- 1
tmpSD$X94[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10712] <- 1
tmpSD$X95[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10712] <- 1
tmpSD$X96[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10712] <- 1
tmpSD$X97[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10413] <- 1
tmpSD$X98[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10413] <- 1
tmpSD$X99[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10413] <- 1
tmpSD$X100[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10413] <- 1
tmpSD$X101[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==11314] <- 1
tmpSD$X102[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==11314] <- 1
tmpSD$X103[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==11314] <- 1
tmpSD$X104[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==11314] <- 1
tmpSD$X105[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10615] <- 1
tmpSD$X106[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10615] <- 1
tmpSD$X107[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10615] <- 1
tmpSD$X108[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10615] <- 1
tmpSD$X109[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10916] <- 1
tmpSD$X110[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10916] <- 1
tmpSD$X111[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10916] <- 1
tmpSD$X112[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10916] <- 1
tmpSD$X113[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10617] <- 1
tmpSD$X114[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10617] <- 1
tmpSD$X115[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10617] <- 1
tmpSD$X116[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10617] <- 1
tmpSD$X117[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==11018] <- 1
tmpSD$X118[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==11018] <- 1
tmpSD$X119[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==11018] <- 1
tmpSD$X120[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==11018] <- 1
tmpSD$X121[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==11319] <- 1
tmpSD$X122[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==11319] <- 1
tmpSD$X123[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==11319] <- 1
tmpSD$X124[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==11319] <- 1
tmpSD$X125[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==11120] <- 1
tmpSD$X126[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==11120] <- 1
tmpSD$X127[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==11120] <- 1
tmpSD$X128[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==11120] <- 1
tmpSD$X129[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10821] <- 1
tmpSD$X130[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10821] <- 1
tmpSD$X131[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10821] <- 1
tmpSD$X132[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10821] <- 1
tmpSD$X133[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==11322] <- 1
tmpSD$X134[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==11322] <- 1
tmpSD$X135[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==11322] <- 1
tmpSD$X136[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==11322] <- 1
tmpSD$X137[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==11423] <- 1
tmpSD$X138[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==11423] <- 1
tmpSD$X139[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==11423] <- 1
tmpSD$X140[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==11423] <- 1
tmpSD$X141[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10524] <- 1
tmpSD$X142[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10524] <- 1
tmpSD$X143[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10524] <- 1
tmpSD$X144[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10524] <- 1
tmpSD$X145[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10325] <- 1
tmpSD$X146[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10325] <- 1
tmpSD$X147[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10325] <- 1
tmpSD$X148[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10325] <- 1
tmpSD$X149[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10926] <- 1
tmpSD$X150[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10926] <- 1
tmpSD$X151[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10926] <- 1
tmpSD$X152[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10926] <- 1
tmpSD$X153[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==11027] <- 1
tmpSD$X154[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==11027] <- 1
tmpSD$X155[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==11027] <- 1
tmpSD$X156[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==11027] <- 1
tmpSD$X157[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==11228] <- 1
tmpSD$X158[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==11228] <- 1
tmpSD$X159[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==11228] <- 1
tmpSD$X160[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==11228] <- 1
tmpSD$X161[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10829] <- 1
tmpSD$X162[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10829] <- 1
tmpSD$X163[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10829] <- 1
tmpSD$X164[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10829] <- 1
tmpSD$X165[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10930] <- 1
tmpSD$X166[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10930] <- 1
tmpSD$X167[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10930] <- 1
tmpSD$X168[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10930] <- 1
tmpSD$X169[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10331] <- 1
tmpSD$X170[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10331] <- 1
tmpSD$X171[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10331] <- 1
tmpSD$X172[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10331] <- 1
tmpSD$X173[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==11132] <- 1
tmpSD$X174[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==11132] <- 1
tmpSD$X175[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==11132] <- 1
tmpSD$X176[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==11132] <- 1
tmpSD$X177[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 1& tmpSD$hh2_code==10833] <- 1
tmpSD$X178[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 1& tmpSD$hh2_code==10833] <- 1
tmpSD$X179[ tmpSD$ageannee>= 0 & tmpSD$ageannee <= 14 & tmpSD$m5_code== 2& tmpSD$hh2_code==10833] <- 1
tmpSD$X180[ tmpSD$ageannee>= 15 & tmpSD$m5_code== 2& tmpSD$hh2_code==10833] <- 1
