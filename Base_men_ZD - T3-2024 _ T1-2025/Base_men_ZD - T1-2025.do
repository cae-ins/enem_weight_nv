
*TRIMESTRE 4
**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE KABADOUGOU  ODIENNE ZD=0004

*Nombre de batiment dans la ZD=0004 / interview__key=90-79-13-91



use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0001" & HH1==105 & HH2==10510 & HH4==1051003404

list HH1 HH2 HH4 HH8 if HH8=="0004" & HH1==105 & HH2==10510 & HH4==1051003404

preserve


keep if HH8=="0001" & HH1==105 & HH2==10510 & HH4==1051003404


save "$base_brute_denom_inter\Base_fusion_menage_KABADOUGOU_ODIENNE_0001.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_KABADOUGOU_ODIENNE_0001.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_KABADOUGOU_ODIENNE_0001_15012025_20h01.xlsx", sheetreplace firstrow(variables) 



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE WORODOUGOU  ODIENNE ZD=0057




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0057" & HH1==113 & HH2==11314 & HH4==1131403906

list HH1 HH2 HH4 HH8 if HH8=="0057" & HH1==113 & HH2==11314 & HH4==1131403906

preserve


keep if HH8=="0057" & HH1==113 & HH2==11314 & HH4==1131403906



save "$base_brute_denom_inter\Base_fusion_menage_WORODOUGOU_0057.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_WORODOUGOU_0057.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_WORODOUGOU_0057_18012025_08h16.xlsx", sheetreplace firstrow(variables) 



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE BEYO ZD=6040




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6040" & HH1==103 & HH2==10325 & HH4==1032503801

list HH1 HH2 HH4 HH8 if HH8=="6040" & HH1==103 & HH2==10325 & HH4==1032503801

preserve


keep if HH8=="6040" & HH1==103 & HH2==10325 & HH4==1032503801



save "$base_brute_denom_inter\Base_fusion_menage_BEYO_6040.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BEYO_6040.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE FRONAN ZD=0033




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0033" & HH1==112 & HH2==11228 & HH4==1122802801

list HH1 HH2 HH4 HH8 if HH8=="0033" & HH1==112 & HH2==11228 & HH4==1122802801

preserve


keep if HH8=="0033" & HH1==112 & HH2==11228 & HH4==1122802801



save "$base_brute_denom_inter\Base_fusion_menage_FRONAN_0033.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_FRONAN_0033.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_FRONAN_0033_26012025_17h12.csv", delimiter(";") datafmt replace




**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE KAHIN-ZARABAON ZD=4001




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="4001" & HH1==110 & HH2==11027 & HH4==1102700707

list HH1 HH2 HH4 HH8 if HH8=="4001" & HH1==110 & HH2==11027 & HH4==1102700707

preserve


keep if HH8=="4001" & HH1==110 & HH2==11027 & HH4==1102700707



save "$base_brute_denom_inter\Base_fusion_menage_KAHIN_ZARABAON_4001.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_KAHIN_ZARABAON_4001.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_KAHIN_ZARABAON_4001_27012025_19h42.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE MARCOUCIS ZD=0016




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0016" & HH1==111 & HH2==11120 & HH4==1112008304

list HH1 HH2 HH4 HH8 if HH8=="0016" & HH1==111 & HH2==11120 & HH4==1112008304

preserve


keep if HH8=="0016" & HH1==111 & HH2==11120 & HH4==1112008304



save "$base_brute_denom_inter\Base_fusion_menage_MARCOUCIS_0016.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_MARCOUCIS_0016.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_MARCOUCIS_0016_27012025_21h02.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE San-pedro ZD=0075




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0075" & HH1==103 & HH2==10309 & HH4==1030903705

list HH1 HH2 HH4 HH8 if HH8=="0075" & HH1==103 & HH2==10309 & HH4==1030903705

preserve


keep if HH8=="0075" & HH1==103 & HH2==10309 & HH4==1030903705



save "$base_brute_denom_inter\Base_fusion_menage_SAN_PEDRO_0075.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_SAN_PEDRO_0075.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_SAN_PEDRO_0075_30012025_08h22.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Broukro-Banouan ZD=6006




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6006" & HH1==114 & HH2==11408 & HH4==1140807005

list HH1 HH2 HH4 HH8 if HH8=="6006" & HH1==114 & HH2==11408 & HH4==1140807005

preserve


keep if HH8=="6006" & HH1==114 & HH2==11408 & HH4==1140807005



save "$base_brute_denom_inter\Base_fusion_menage_Broukro_Banouan_6006.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Broukro_Banouan_6006.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_Broukro_Banouan_6006_31012025_10h23.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Mahandiana_Sokourani ZD=6015




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6015" & HH1==105 & HH2==10524 & HH4==1052408103

list HH1 HH2 HH4 HH8 if HH8=="6015" & HH1==105 & HH2==10524 & HH4==1052408103

preserve


keep if HH8=="6015" & HH1==105 & HH2==10524 & HH4==1052408103



save "$base_brute_denom_inter\Base_fusion_menage_Mahandiana_Sokourani_6015.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Mahandiana_Sokourani_6015.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_Mahandiana_Sokourani_6015_01022025_10h23.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE KOLOUKRO ZD=4054




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="4054" & HH1==107 & HH2==10712 & HH4==1071210901

list HH1 HH2 HH4 HH8 if HH8=="4054" & HH1==107 & HH2==10712 & HH4==1071210901

preserve


keep if HH8=="4054" & HH1==107 & HH2==10712 & HH4==1071210901



save "$base_brute_denom_inter\Base_fusion_menage_KOLOUKRO_4054.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_KOLOUKRO_4054.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_KOLOUKRO_4054_03022025_05h42.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE FERKESSEDOUGOU ZD=0018




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0018" & HH1==111 & HH2==11132 & HH4==1113202301 & interview__key=="94-10-30-83"

list HH1 HH2 HH4 HH8 if HH8=="0018" & HH1==111 & HH2==11132 & HH4==1113202301 & interview__key=="94-10-30-83"
preserve


keep if HH8=="0018" & HH1==111 & HH2==11132 & HH4==1113202301 & interview__key=="94-10-30-83"



save "$base_brute_denom_inter\Base_fusion_menage_FERKESSEDOUGOU_0018.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_FERKESSEDOUGOU_0018.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_FERKESSEDOUGOU_0018_04022025_07h58.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE GOBROKO ZD=6058




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6058" & HH1==103 & HH2==10325 & HH4==1032503805 & inlist(interview__key,"72-31-86-21","81-18-33-09")

list HH1 HH2 HH4 HH8 if HH8=="6058" & HH1==103 & HH2==10325 & HH4==1032503805 & inlist(interview__key,"72-31-86-21","81-18-33-09")



preserve


keep if HH8=="6058" & HH1==103 & HH2==10325 & HH4==1032503805 & inlist(interview__key,"72-31-86-21","81-18-33-09")




save "$base_brute_denom_inter\Base_fusion_menage_GOBROKO_6058.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_GOBROKO_6058.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_GOBROKO_6058_08022025_11h15.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE BONIKRO ZD=6012




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6012" & HH1==109 & HH2==10916 & HH4==1091600506 & inlist(interview__key,"17-78-75-64")

list HH1 HH2 HH4 HH8 if HH8=="6012" & HH1==109 & HH2==10916 & HH4==1091600506 & inlist(interview__key,"17-78-75-64")



preserve


keep if HH8=="6012" & HH1==109 & HH2==10916 & HH4==1091600506 & inlist(interview__key,"17-78-75-64")




save "$base_brute_denom_inter\Base_fusion_menage_BONIKRO_6012.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BONIKRO_6012.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_BONIKRO_6012_08022025_15h56.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Tomikoro  ZD=6007




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6007" & HH1==113 & HH2==11322 & HH4==1132209702 

list HH1 HH2 HH4 HH8 if HH8=="6007" & HH1==113 & HH2==11322 & HH4==1132209702 



preserve


keep if HH8=="6007" & HH1==113 & HH2==11322 & HH4==1132209702 




save "$base_brute_denom_inter\Base_fusion_menage_Tomikoro_6007.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Tomikoro_6007.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_Tomikoro_6007_09022025_15h08.csv", delimiter(";") datafmt replace

**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE KOLOUKRO ZD=4054




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="4054" & HH1==107 & HH2==10712 & HH4==1071210901 & inlist(interview__key,"05-54-28-19", "61-24-49-01")

list HH1 HH2 HH4 HH8 if HH8=="4054" & HH1==107 & HH2==10712 & HH4==1071210901 & inlist(interview__key,"05-54-28-19", "61-24-49-01")



preserve


keep if HH8=="4054" & HH1==107 & HH2==10712 & HH4==1071210901 & inlist(interview__key,"05-54-28-19", "61-24-49-01")



save "$base_brute_denom_inter\Base_fusion_menage_KOLOUKRO_4054.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_KOLOUKRO_4054.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_KOLOUKRO_4054_09022025_16h02.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE CECHI_BONIKRO ZD=6012




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6012" & HH1==109 & HH2==10916 & HH4==1091600506 & inlist(interview__key,"17-78-75-64")

list HH1 HH2 HH4 HH8 if HH8=="6012" & HH1==109 & HH2==10916 & HH4==1091600506 & inlist(interview__key,"17-78-75-64")



preserve


keep if HH8=="6012" & HH1==109 & HH2==10916 & HH4==1091600506 & inlist(interview__key,"17-78-75-64")



save "$base_brute_denom_inter\Base_fusion_menage_CECHI_BONIKRO_6012.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_CECHI_BONIKRO_6012.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_CECHI_BONIKRO_6012_10022025_09h07.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Dadiasse ZD=6024




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6024" & HH1==114 & HH2==11408 & HH4==1140809301 & inlist(interview__key,"28-54-43-67")

list HH1 HH2 HH4 HH8 if HH8=="6024" & HH1==114 & HH2==11408 & HH4==1140809301 & inlist(interview__key,"28-54-43-67")




preserve


keep if HH8=="6024" & HH1==114 & HH2==11408 & HH4==1140809301 & inlist(interview__key,"28-54-43-67")




save "$base_brute_denom_inter\Base_fusion_menage_Dadiasse_6024.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Dadiasse_6024.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_Dadiasse_6024_10022025_15h01.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE GUIGLO ZD=6055




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6055" & HH1==110 & HH2==11018 & HH4==1101802602

list HH1 HH2 HH4 HH8 if HH8=="6055" & HH1==110 & HH2==11018 & HH4==1101802602




preserve


keep if HH8=="6055" & HH1==110 & HH2==11018 & HH4==1101802602




save "$base_brute_denom_inter\Base_fusion_menage_GUIGLO_6055.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_GUIGLO_6055.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_GUIGLO_6055_15022025_14h26.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Kabadougou ZD=0059




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0059" & HH1==105 & HH2==10510 & HH4==1051003404 & inlist(interview__key,"64-23-51-62")

list HH1 HH2 HH4 HH8 if HH8=="0059" & HH1==105 & HH2==10510 & HH4==1051003404 & inlist(interview__key,"64-23-51-62")




preserve


keep if HH8=="0059" & HH1==105 & HH2==10510 & HH4==1051003404 & inlist(interview__key,"64-23-51-62")




save "$base_brute_denom_inter\Base_fusion_menage_Kabadougou_0059.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Kabadougou_0059.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_Kabadougou_0059_17022025_14h30.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE DIOULABOUGOU ZD=0058




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0058" & HH1==111 & HH2==11132 & HH4==1113202301 & inlist(interview__key,"12-65-21-58")

list HH1 HH2 HH4 HH8 if HH8=="0058" & HH1==111 & HH2==11132 & HH4==1113202301 & inlist(interview__key,"12-65-21-58")




preserve


keep if HH8=="0058" & HH1==111 & HH2==11132 & HH4==1113202301 & inlist(interview__key,"12-65-21-58")




save "$base_brute_denom_inter\Base_fusion_menage_DIOULABOUGOU_0058.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_DIOULABOUGOU_0058.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_DIOULABOUGOU_0058_18022025_08h02.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Assoumanbango ZD=6012




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6012" & HH1==114 & HH2==11408 & HH4==1140804302 & inlist(interview__key,"57-12-46-95")

list HH1 HH2 HH4 HH8 if HH8=="6012" & HH1==114 & HH2==11408 & HH4==1140804302 & inlist(interview__key,"57-12-46-95")




preserve


keep if HH8=="6012" & HH1==114 & HH2==11408 & HH4==1140804302 & inlist(interview__key,"57-12-46-95")




save "$base_brute_denom_inter\Base_fusion_menage_Assoumanbango_6012.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Assoumanbango_6012.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_Assoumanbango_6012_18022025_12h37.csv", delimiter(";") datafmt replace




**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE MARAHOUÉ  ZD=0012




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0012" & HH1==107 & HH2==10712 & HH4==1071204004 & inlist(interview__key,"85-28-55-44")

list HH1 HH2 HH4 HH8 if HH8=="0012" & HH1==107 & HH2==10712 & HH4==1071204004 & inlist(interview__key,"85-28-55-44")




preserve


keep if HH8=="0012" & HH1==107 & HH2==10712 & HH4==1071204004 & inlist(interview__key,"85-28-55-44")



save "$base_brute_denom_inter\Base_fusion_menage_MARAHOUE_0012.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_MARAHOUE_0012.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_MARAHOUE_0012_19022025_10h00.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Missidougou  ZD=6018




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6018" & HH1==113 & HH2==11322 & HH4==1132203204 & inlist(interview__key,"09-25-33-53")

list HH1 HH2 HH4 HH8 if HH8=="6018" & HH1==113 & HH2==11322 & HH4==1132203204 & inlist(interview__key,"09-25-33-53")




preserve


keep if HH8=="6018" & HH1==113 & HH2==11322 & HH4==1132203204 & inlist(interview__key,"09-25-33-53")



save "$base_brute_denom_inter\Base_fusion_menage_Missidougou_6018.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Missidougou_6018.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_Missidougou_6018_21022025_06h40.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE KOUASSI_KANKRO  ZD=6039




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6039" & HH1==107 & HH2==10702 & HH4==1070201702 & inlist(interview__key,"13-01-97-01")

list HH1 HH2 HH4 HH8 if HH8=="6039" & HH1==107 & HH2==10702 & HH4==1070201702 & inlist(interview__key,"13-01-97-01")




preserve


keep if HH8=="6039" & HH1==107 & HH2==10702 & HH4==1070201702 & inlist(interview__key,"13-01-97-01")



save "$base_brute_denom_inter\Base_fusion_menage_KOUASSI_KANKRO_6039.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_KOUASSI_KANKRO_6039.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_KOUASSI_KANKRO_6039_21022025_06h44.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE KASSIRIME  ZD=0240




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0240" & HH1==111 & HH2==11103 & HH4==1110302906 & inlist(interview__key,"54-36-51-18","36-08-60-33")

list HH1 HH2 HH4 HH8 if HH8=="0240" & HH1==111 & HH2==11103 & HH4==1110302906 & inlist(interview__key,"54-36-51-18","36-08-60-33")



preserve


keep if HH8=="0240" & HH1==111 & HH2==11103 & HH4==1110302906 & inlist(interview__key,"54-36-51-18","36-08-60-33")



save "$base_brute_denom_inter\Base_fusion_menage_KASSIRIME_0240.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_KASSIRIME_0240.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_KASSIRIME_0240_21022025_15h21.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE LAOUO  ZD=6018




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6018" & HH1==110 & HH2==11027 & HH4==1102702202 & inlist(interview__key,"94-79-60-72")

list HH1 HH2 HH4 HH8 if HH8=="6018" & HH1==110 & HH2==11027 & HH4==1102702202 & inlist(interview__key,"94-79-60-72")



preserve


keep if HH8=="6018" & HH1==110 & HH2==11027 & HH4==1102702202 & inlist(interview__key,"94-79-60-72")



save "$base_brute_denom_inter\Base_fusion_menage_LAOUO_6018.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_LAOUO_6018.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_LAOUO_6018_21022025_18h43.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Soko  ZD=6018




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6018" & HH1==113 & HH2==11314 & HH4==1131403908 & inlist(interview__key,"88-64-76-24")

list HH1 HH2 HH4 HH8 if HH8=="6018" & HH1==113 & HH2==11314 & HH4==1131403908 & inlist(interview__key,"88-64-76-24")



preserve


keep if HH8=="6018" & HH1==113 & HH2==11314 & HH4==1131403908 & inlist(interview__key,"88-64-76-24")



save "$base_brute_denom_inter\Base_fusion_menage_Soko_6018.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Soko_6018.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_Soko_6018_23022025_10h27.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE DUEKOUE  ZD=6018




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6018" & HH1==110 & HH2==11027 & HH4==1102702202 & inlist(interview__key,"94-79-60-72")

list HH1 HH2 HH4 HH8 if HH8=="6018" & HH1==110 & HH2==11027 & HH4==1102702202 & inlist(interview__key,"94-79-60-72")



preserve


keep if HH8=="6018" & HH1==110 & HH2==11027 & HH4==1102702202 & inlist(interview__key,"94-79-60-72")



save "$base_brute_denom_inter\Base_fusion_menage_DUEKOUE_6018.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_DUEKOUE_6018.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_DUEKOUE_6018_25022025_16h36.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE SEPENEDJOKAHA  ZD=6084




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6084" & HH1==111 & HH2==11132 & HH4==1113202301 & inlist(interview__key,"85-05-28-65")

list HH1 HH2 HH4 HH8 if HH8=="6084" & HH1==111 & HH2==11132 & HH4==1113202301 & inlist(interview__key,"85-05-28-65")



preserve


keep if HH8=="6084" & HH1==111 & HH2==11132 & HH4==1113202301 & inlist(interview__key,"85-05-28-65")



save "$base_brute_denom_inter\Base_fusion_menage_SEPENEDJOKAHA_6084.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_SEPENEDJOKAHA_6084.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_SEPENEDJOKAHA_6084_26022025_20h52.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE SEPENEDJOKAHA  ZD=6084




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6084" & HH1==111 & HH2==11132 & HH4==1113202301 & inlist(interview__key,"85-05-28-65")

list HH1 HH2 HH4 HH8 if HH8=="6084" & HH1==111 & HH2==11132 & HH4==1113202301 & inlist(interview__key,"85-05-28-65")



preserve


keep if HH8=="6084" & HH1==111 & HH2==11132 & HH4==1113202301 & inlist(interview__key,"85-05-28-65")



save "$base_brute_denom_inter\Base_fusion_menage_SEPENEDJOKAHA_6084.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_SEPENEDJOKAHA_6084.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_SEPENEDJOKAHA_6084_26022025_20h52.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Agboville  ZD=0008




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0008" & HH1==109 & HH2==10916 & HH4==1091600503 & inlist(interview__key,"98-12-67-72")

list HH1 HH2 HH4 HH8 if HH8=="0008" & HH1==109 & HH2==10916 & HH4==1091600503 & inlist(interview__key,"98-12-67-72")



preserve


keep if HH8=="0008" & HH1==109 & HH2==10916 & HH4==1091600503 & inlist(interview__key,"98-12-67-72")



save "$base_brute_denom_inter\Base_fusion_menage_AGBOVILLE_0008.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_AGBOVILLE_0008.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_AGBOVILLE_0008_04032025_13h35.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE KASSIAPLEU   ZD=6027




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6027" & HH1==110 & HH2==11006 & HH4==1100603105 & inlist(interview__key,"04-50-19-71","71-70-09-97")

list HH1 HH2 HH4 HH8 if HH8=="6027" & HH1==110 & HH2==11006 & HH4==1100603105 & inlist(interview__key,"04-50-19-71","71-70-09-97")



preserve


keep if HH8=="6027" & HH1==110 & HH2==11006 & HH4==1100603105 & inlist(interview__key,"04-50-19-71","71-70-09-97")



save "$base_brute_denom_inter\Base_fusion_menage_KASSIAPLEU_6027.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_KASSIAPLEU_6027.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_KASSIAPLEU_6027_05032025_08h58.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE ASSIÉ_AKPESSE   ZD=6028




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6028" & HH1==108 & HH2==10833 & HH4==1083308403 & inlist(interview__key,"16-90-25-71")

list HH1 HH2 HH4 HH8 if HH8=="6028" & HH1==108 & HH2==10833 & HH4==1083308403 & inlist(interview__key,"16-90-25-71")


preserve


keep if HH8=="6028" & HH1==108 & HH2==10833 & HH4==1083308403 & inlist(interview__key,"16-90-25-71")


save "$base_brute_denom_inter\Base_fusion_menage_ASSIE_AKPESSE_6028.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_ASSIE_AKPESSE_6028.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_ASSIE_AKPESSE_6028_05032025_13h07.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Korokopla   ZD=6035




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6035" & HH1==113 & HH2==11322 & HH4==1132206901 & inlist(interview__key,"63-67-71-69")

list HH1 HH2 HH4 HH8 if HH8=="6035" & HH1==113 & HH2==11322 & HH4==1132206901 & inlist(interview__key,"63-67-71-69")


preserve


keep if HH8=="6035" & HH1==113 & HH2==11322 & HH4==1132206901 & inlist(interview__key,"63-67-71-69")


save "$base_brute_denom_inter\Base_fusion_menage_Korokopla_6035.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Korokopla_6035.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_Korokopla_6035_06032025_08h39.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE ODIENNE   ZD=0023




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0023" & HH1==105 & HH2==10510 & HH4==1051003404 & inlist(interview__key,"69-70-26-46")

list HH1 HH2 HH4 HH8 if HH8=="0023" & HH1==105 & HH2==10510 & HH4==1051003404 & inlist(interview__key,"69-70-26-46")

preserve


keep if HH8=="0023" & HH1==105 & HH2==10510 & HH4==1051003404 & inlist(interview__key,"69-70-26-46")


save "$base_brute_denom_inter\Base_fusion_menage_ODIENNE_0023.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_ODIENNE_0023.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_ODIENNE_0023_06032025_13h24.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE SUEFLA   ZD=6081




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6081" & HH1==107 & HH2==10712 & HH4==1071201203 & inlist(interview__key,"00-89-86-77")

list HH1 HH2 HH4 HH8 if HH8=="6081" & HH1==107 & HH2==10712 & HH4==1071201203 & inlist(interview__key,"00-89-86-77")


preserve


keep if HH8=="6081" & HH1==107 & HH2==10712 & HH4==1071201203 & inlist(interview__key,"00-89-86-77")

save "$base_brute_denom_inter\Base_fusion_menage_SUEFLA_6081.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_SUEFLA_6081.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_SUEFLA_6081_08032025_21h09.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE DJUEKRO   ZD=6025




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6025" & HH1==103 & HH2==10325 & HH4==1032503801 & inlist(interview__key,"10-14-94-41")

list HH1 HH2 HH4 HH8 if HH8=="6025" & HH1==103 & HH2==10325 & HH4==1032503801 & inlist(interview__key,"10-14-94-41")


preserve


keep if HH8=="6025" & HH1==103 & HH2==10325 & HH4==1032503801 & inlist(interview__key,"10-14-94-41")
save "$base_brute_denom_inter\Base_fusion_menage_DJUEKRO_6025.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_DJUEKRO_6025.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_DJUEKRO_6025_09032025_15h15.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE DALYONON   ZD=0003




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0003" & HH1==111 & HH2==11132 & HH4==1113208603 & inlist(interview__key,"73-82-48-81")

list HH1 HH2 HH4 HH8 if HH8=="0003" & HH1==111 & HH2==11132 & HH4==1113208603 & inlist(interview__key,"73-82-48-81")

preserve


keep if HH8=="0003" & HH1==111 & HH2==11132 & HH4==1113208603 & inlist(interview__key,"73-82-48-81")


save "$base_brute_denom_inter\Base_fusion_menage_DALYONON_0003.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_DALYONON_0003.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_DALYONON_0003_14032025_14h43.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE DEKIKAHA   ZD=6091




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6091" & HH1==111 & HH2==11132 & HH4==1113202301 & inlist(interview__key,"06-91-07-66")

list HH1 HH2 HH4 HH8 if HH8=="6091" & HH1==111 & HH2==11132 & HH4==1113202301 & inlist(interview__key,"06-91-07-66")

preserve


keep if HH8=="6091" & HH1==111 & HH2==11132 & HH4==1113202301 & inlist(interview__key,"06-91-07-66")


save "$base_brute_denom_inter\Base_fusion_menage_DEKIKAHA_6091.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_DEKIKAHA_6091.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_DEKIKAHA_6091_17032025_08h37.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE DYNAMOKRO    ZD=6091




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6071" & HH1==107 & HH2==10702 & HH4==1070201701 & inlist(interview__key,"27-49-65-10")

list HH1 HH2 HH4 HH8 if HH8=="6071" & HH1==107 & HH2==10702 & HH4==1070201701 & inlist(interview__key,"27-49-65-10")

preserve


keep if HH8=="6071" & HH1==107 & HH2==10702 & HH4==1070201701 & inlist(interview__key,"27-49-65-10")


save "$base_brute_denom_inter\Base_fusion_menage_DYNAMOKRO_6071.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_DYNAMOKRO_6071.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_DYNAMOKRO_6071_17032025_08h37.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Odienné    ZD=6009




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6009" & HH1==105 & HH2==10510 & HH4==1051003404 & inlist(interview__key,"06-49-16-29")

list HH1 HH2 HH4 HH8 if HH8=="6009" & HH1==105 & HH2==10510 & HH4==1051003404 & inlist(interview__key,"06-49-16-29")

preserve


keep if HH8=="6009" & HH1==105 & HH2==10510 & HH4==1051003404 & inlist(interview__key,"06-49-16-29")



save "$base_brute_denom_inter\Base_fusion_menage_ODIENNE_6009.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_ODIENNE_6009.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_ODIENNE_6009_17032025_11h47.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE INDENIE_DJUABLIN    ZD=0113




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0113" & HH1==104 & HH2==10405 & HH4==1040500101 & inlist(interview__key,"47-68-81-94")

list HH1 HH2 HH4 HH8 if HH8=="0113" & HH1==104 & HH2==10405 & HH4==1040500101 & inlist(interview__key,"47-68-81-94")



preserve


keep if HH8=="0113" & HH1==104 & HH2==10405 & HH4==1040500101 & inlist(interview__key,"47-68-81-94")



save "$base_brute_denom_inter\Base_fusion_menage_INDENIE_DJUABLIN_0113.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_INDENIE_DJUABLIN_0113.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_INDENIE_DJUABLIN_0113_18032025_16h22.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE PINVORO    ZD=6006




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6006" & HH1==111 & HH2==11120 & HH4==1112001504 & inlist(interview__key,"25-73-53-58")

list HH1 HH2 HH4 HH8 if HH8=="6006" & HH1==111 & HH2==11120 & HH4==1112001504 & inlist(interview__key,"25-73-53-58")



preserve


keep if HH8=="6006" & HH1==111 & HH2==11120 & HH4==1112001504 & inlist(interview__key,"25-73-53-58")



save "$base_brute_denom_inter\Base_fusion_menage_PINVORO_6006.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_PINVORO_6006.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_PINVORO_6006_19032025_13h54.csv", delimiter(";") datafmt replace




**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE WOROFLA    ZD=6050




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6050" & HH1==113 & HH2==11314 & HH4==1131403908 & inlist(interview__key,"52-54-28-60")

list HH1 HH2 HH4 HH8 if HH8=="6050" & HH1==113 & HH2==11314 & HH4==1131403908 & inlist(interview__key,"52-54-28-60")


preserve


keep if HH8=="6050" & HH1==113 & HH2==11314 & HH4==1131403908 & inlist(interview__key,"52-54-28-60")



save "$base_brute_denom_inter\Base_fusion_menage_WOROFLA_6050.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_WOROFLA_6050.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_WOROFLA_6050_20032025_09h55.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Booko    ZD=6024




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6024" & HH1==113 & HH2==11319 & HH4==1131908201 & inlist(interview__key,"53-84-08-12")

list HH1 HH2 HH4 HH8 if HH8=="6024" & HH1==113 & HH2==11319 & HH4==1131908201 & inlist(interview__key,"53-84-08-12")


preserve


keep if HH8=="6024" & HH1==113 & HH2==11319 & HH4==1131908201 & inlist(interview__key,"53-84-08-12")



save "$base_brute_denom_inter\Base_fusion_menage_BOOKO_6024.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BOOKO_6024.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_BOOKO_6024_21032025_15h11.csv", delimiter(";") datafmt replace




**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE PROUKRO    ZD=6007




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6007" & HH1==108 & HH2==10811 & HH4==1081105303 & inlist(interview__key,"99-17-36-59")

list HH1 HH2 HH4 HH8 if HH8=="6007" & HH1==108 & HH2==10811 & HH4==1081105303 & inlist(interview__key,"99-17-36-59")



preserve


keep if HH8=="6007" & HH1==108 & HH2==10811 & HH4==1081105303 & inlist(interview__key,"99-17-36-59")




save "$base_brute_denom_inter\Base_fusion_menage_PROUKRO_6007.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_PROUKRO_6007.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_PROUKRO_6007_01042025_12h31.csv", delimiter(";") datafmt replace




**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE GABIADJI     ZD=6075




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6075" & HH1==103 & HH2==10309 & HH4==1030903703 & inlist(interview__key,"02-16-89-11")

list HH1 HH2 HH4 HH8 if HH8=="6075" & HH1==103 & HH2==10309 & HH4==1030903703 & inlist(interview__key,"02-16-89-11")



preserve


keep if HH8=="6075" & HH1==103 & HH2==10309 & HH4==1030903703 & inlist(interview__key,"02-16-89-11")




save "$base_brute_denom_inter\Base_fusion_menage_GABIADJI_6075.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_GABIADJI_6075.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_GABIADJI_6075_01042025_13h01.csv", delimiter(";") datafmt replace




**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Banhana     ZD=6017




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6017" & HH1==113 & HH2==11314 & HH4==1131403905 & inlist(interview__key,"50-42-27-44")

list HH1 HH2 HH4 HH8  if HH8=="6017" & HH1==113 & HH2==11314 & HH4==1131403905 & inlist(interview__key,"50-42-27-44")



preserve


keep  if HH8=="6017" & HH1==113 & HH2==11314 & HH4==1131403905 & inlist(interview__key,"50-42-27-44")




save "$base_brute_denom_inter\Base_fusion_menage_Banhana_6017.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Banhana_6017.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_Banhana_6017_02042025_14h01.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE BOUAKE  ZD=6002




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6034" & HH1==112 & HH2==11204 & HH4==1120401301 & inlist(interview__key,"66-59-99-25","53-33-25-13")

list HH1 HH2 HH4 HH8  if HH8=="6034" & HH1==112 & HH2==11204 & HH4==1120401301 & inlist(interview__key,"66-59-99-25","53-33-25-13")



preserve


keep  if HH8=="6034" & HH1==112 & HH2==11204 & HH4==1120401301 & inlist(interview__key,"66-59-99-25","53-33-25-13")




save "$base_brute_denom_inter\Base_fusion_menage_BOUAKE_6034.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BOUAKE_6034.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_BOUAKE_6034_02042025_17h25.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE MARA  ZD=6022




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6022" & HH1==111 & HH2==11103 & HH4==1110307501 & inlist(interview__key,"02-54-74-87","23-46-63-85","93-40-90-20")

list HH1 HH2 HH4 HH8  if HH8=="6022" & HH1==111 & HH2==11103 & HH4==1110307501 & inlist(interview__key,"02-54-74-87","23-46-63-85","93-40-90-20")



preserve


keep  if HH8=="6022" & HH1==111 & HH2==11103 & HH4==1110307501 & inlist(interview__key,"02-54-74-87","23-46-63-85","93-40-90-20")




save "$base_brute_denom_inter\Base_fusion_menage_MARA_6022.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_MARA_6022.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_MARA_6022_03042025_07h49.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE ABEVE  ZD=6009




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6009" & HH1==109 & HH2==10916 & HH4==1091604503 & inlist(interview__key,"45-67-19-74","35-17-76-00")

list HH1 HH2 HH4 HH8  if HH8=="6009" & HH1==109 & HH2==10916 & HH4==1091604503 & inlist(interview__key,"45-67-19-74","35-17-76-00")


preserve


keep  if HH8=="6009" & HH1==109 & HH2==10916 & HH4==1091604503 & inlist(interview__key,"45-67-19-74","35-17-76-00")




save "$base_brute_denom_inter\Base_fusion_menage_ABEVE_6009.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_ABEVE_6009.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_ABEVE_6009_03042025_08h08.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE KORA-AKISSIKRO   ZD=6012




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6012" & HH1==108 & HH2==10829 & HH4==1082903303 & inlist(interview__key,"20-56-68-72","67-57-86-18")

list HH1 HH2 HH4 HH8  if HH8=="6012" & HH1==108 & HH2==10829 & HH4==1082903303 & inlist(interview__key,"20-56-68-72","67-57-86-18")



preserve


keep  if HH8=="6012" & HH1==108 & HH2==10829 & HH4==1082903303 & inlist(interview__key,"20-56-68-72","67-57-86-18")





save "$base_brute_denom_inter\Base_fusion_menage_KORA_AKISSIKRO_6012.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_KORA_AKISSIKRO_6012.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_KORA_AKISSIKRO_6012_03042025_12h00.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Kridy    ZD=6073 




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6073" & HH1==110 & HH2==11018 & HH4==1101802602 & inlist(interview__key,"23-22-00-06")

list HH1 HH2 HH4 HH8  if HH8=="6073" & HH1==110 & HH2==11018 & HH4==1101802602 & inlist(interview__key,"23-22-00-06")




preserve


keep  if HH8=="6073" & HH1==110 & HH2==11018 & HH4==1101802602 & inlist(interview__key,"23-22-00-06")




save "$base_brute_denom_inter\Base_fusion_menage_Kridy_6073.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Kridy_6073.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_Kridy_6073_03042025_13h00.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE FANGAYOGO   ZD=0057 




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0057" & HH1==111 & HH2==11120 & HH4==1112001502 & inlist(interview__key,"09-72-60-00")

list HH1 HH2 HH4 HH8  if HH8=="0057" & HH1==111 & HH2==11120 & HH4==1112001502 & inlist(interview__key,"09-72-60-00")




preserve


keep  if HH8=="0057" & HH1==111 & HH2==11120 & HH4==1112001502 & inlist(interview__key,"09-72-60-00")




save "$base_brute_denom_inter\Base_fusion_menage_FANGAYOGO_0057.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_FANGAYOGO_0057.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_FANGAYOGO_0057_03042025_16h30.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE GNANDI_BOMENEDA   ZD=6003 




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6003" & HH1==106 & HH2==10617 & HH4==1061703501 & inlist(interview__key,"80-62-82-76","73-11-67-86")

list HH1 HH2 HH4 HH8  if HH8=="6003" & HH1==106 & HH2==10617 & HH4==1061703501 & inlist(interview__key,"80-62-82-76","73-11-67-86")




preserve


keep  if HH8=="6003" & HH1==106 & HH2==10617 & HH4==1061703501 & inlist(interview__key,"80-62-82-76","73-11-67-86")




save "$base_brute_denom_inter\Base_fusion_menage_GNANDI_BOMENEDA_6003.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_GNANDI_BOMENEDA_6003.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_GNANDI_BOMENEDA_6003_03042025_22h18.csv", delimiter(";") datafmt replace




**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Meagui   ZD=6003 




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0021" & HH1==103 & HH2==10331 & HH4==1033110402 & inlist(interview__key,"45-72-90-47")

list HH1 HH2 HH4 HH8  if HH8=="0021" & HH1==103 & HH2==10331 & HH4==1033110402 & inlist(interview__key,"45-72-90-47")




preserve


keep  if HH8=="0021" & HH1==103 & HH2==10331 & HH4==1033110402 & inlist(interview__key,"45-72-90-47")




save "$base_brute_denom_inter\Base_fusion_menage_Meagui_0021.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Meagui_0021.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_Meagui_0021_04042025_14h58.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE Migarbavogo    ZD=0018  




use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0018" & HH1==111 & HH2==11132 & HH4==1113208603 & inlist(interview__key,"82-95-02-59")

list HH1 HH2 HH4 HH8  if HH8=="0018" & HH1==111 & HH2==11132 & HH4==1113208603 & inlist(interview__key,"82-95-02-59")




preserve


keep  if HH8=="0018" & HH1==111 & HH2==11132 & HH4==1113208603 & inlist(interview__key,"82-95-02-59")




save "$base_brute_denom_inter\Base_fusion_menage_Migarbavogo_0018.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Migarbavogo_0018.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT12025_menage_BEYO_6040_24012025_10h56.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT12025_menage_Migarbavogo_0018_06042025_17h26.csv", delimiter(";") datafmt replace














