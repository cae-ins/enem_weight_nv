
*TRIMESTRE 4
**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE KABADOUGOU  ODIENNE ZD=0004

*Nombre de batiment dans la ZD=0004


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0004" & HH1==105 & HH2==10510 & HH4==1051003404

list HH1 HH2 HH4 HH8 if HH8=="0004" & HH1==105 & HH2==10510 & HH4==1051003404

preserve


keep if HH8=="0004" & HH1==105 & HH2==10510 & HH4==1051003404


save "$base_brute_denom_inter\Base_fusion_menage_KABADOUGOU_ODIENNE_0004.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_KABADOUGOU_ODIENNE_0004.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_KABADOUGOU_ODIENNE_0004_22102024_08h01.xlsx", sheetreplace firstrow(variables) 


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE ODIENNE  BAFING ZD=0004

*Nombre de batiment dans la ZD=0004


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0004" & HH1==113 & HH2==11319 & HH4==1131904604

list HH1 HH2 HH4 HH8 if HH8=="0004" & HH1==113 & HH2==11319 & HH4==1131904604

preserve


keep if HH8=="0004" & HH1==113 & HH2==11319 & HH4==1131904604


save "$base_brute_denom_inter\Base_fusion_menage_ODIENNE_BAFING_0004.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_ODIENNE_BAFING_0004.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_ODIENNE_BAFING_0004_22102024_08h01.xlsx", sheetreplace firstrow(variables) 

**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE BAGOUE  KOUTO ZD=0020

*Nombre de batiment dans la ZD=0020


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0020" & HH1==111 & HH2==11120 & HH4==1112008304

list HH1 HH2 HH4 HH8 if HH8=="0020" & HH1==111 & HH2==11120 & HH4==1112008304


preserve


keep if HH8=="0020" & HH1==111 & HH2==11120 & HH4==1112008304



save "$base_brute_denom_inter\Base_fusion_menage_BAGOUE_KOUTO_0020.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BAGOUE_KOUTO_0020.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE KORHOGO  PORO ZD=0141

*Nombre de batiment dans la ZD=0141


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0141" & HH1==111 & HH2==11103 & HH4==1110302906

list HH1 HH2 HH4 HH8 if HH8=="0141" & HH1==111 & HH2==11103 & HH4==1110302906


preserve


keep if HH8=="0141" & HH1==111 & HH2==11103 & HH4==1110302906


save "$base_brute_denom_inter\Base_fusion_menage_KORHOGO_PORO_0141.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_KORHOGO_PORO_0141.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_KORHOGO_PORO_0141_26102024_11h19.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE FOLON  KANIASSO ZD=6017

*Nombre de batiment dans la ZD=6017


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6017" & HH1==105 & HH2==10524 & HH4==1052408103

list HH1 HH2 HH4 HH8 if HH8=="6017" & HH1==105 & HH2==10524 & HH4==1052408103


preserve


keep if HH8=="6017" & HH1==105 & HH2==10524 & HH4==1052408103

save "$base_brute_denom_inter\Base_fusion_menage_FOLON_KANIASSO_6017.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_FOLON_KANIASSO_6017.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_FOLON_KANIASSO_6017_30102024_14h11.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE BAGOUE  TENGRELA ZD=0043

*Nombre de batiment dans la ZD=0043


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0043" & HH1==111 & HH2==11120 & HH4==1112004404

list HH1 HH2 HH4 HH8 if HH8=="0043" & HH1==111 & HH2==11120 & HH4==1112004404


preserve


keep if HH8=="0043" & HH1==111 & HH2==11120 & HH4==1112004404

save "$base_brute_denom_inter\Base_fusion_menage_BAGOUE_TENGRELA_0043.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BAGOUE_TENGRELA_0043.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_TENGRELA_0043_14112024_10h47.csv", delimiter(";") datafmt replace





**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE IFFOU  PRIKRO ZD=6032

*Nombre de batiment dans la ZD=6032


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6032" & HH1==108 & HH2==10829 & HH4==1082906405

list HH1 HH2 HH4 HH8 if HH8=="6032" & HH1==108 & HH2==10829 & HH4==1082906405


preserve


keep if HH8=="6032" & HH1==108 & HH2==10829 & HH4==1082906405

save "$base_brute_denom_inter\Base_fusion_menage_IFFOU_PRIKRO_6032.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_IFFOU_PRIKRO_6032.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_IFFOU_PRIKRO_6032_28112024_18h56.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE DUEKOUE  DOUMBIADOUGOU ZD=6092

*Nombre de batiment dans la ZD=6092


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6092" & HH1==110 & HH2==11027 & HH4==1102702202

list HH1 HH2 HH4 HH8 if HH8=="6092" & HH1==110 & HH2==11027 & HH4==1102702202


preserve


keep if HH8=="6092" & HH1==110 & HH2==11027 & HH4==1102702202

save "$base_brute_denom_inter\Base_fusion_menage_DUEKOUE_DOUMBIADOUGOU_6092.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_DUEKOUE_DOUMBIADOUGOU_6092.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_DUEKOUE_DOUMBIADOUGOU_6092_01122024_16h53.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE YAMOUSSOUKRO  ZONE_ADMINISTRATIVE ZD=0225

*Nombre de batiment dans la ZD=0225


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0225" & HH1==102 & HH2==10207 & HH4==1020704902

list HH1 HH2 HH4 HH8 if HH8=="0225" & HH1==102 & HH2==10207 & HH4==1020704902


preserve


keep if HH8=="0225" & HH1==102 & HH2==10207 & HH4==1020704902

save "$base_brute_denom_inter\Base_fusion_menage_YAMOUSSOUKRO_ZONE_ADMINISTRATIVE_0225.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_YAMOUSSOUKRO_ZONE_ADMINISTRATIVE_0225.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_YAMOUSSOUKRO_ZONE_ADMINISTRATIVE_0225_01122024_16h53.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE NIAKARAMADOUGOU  KOULOKAHA ZD=6003

*Nombre de batiment dans la ZD=6003


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6003" & HH1==112 & HH2==11228 & HH4==1122808504

list HH1 HH2 HH4 HH8 if HH8=="6003" & HH1==112 & HH2==11228 & HH4==1122808504


preserve


keep if HH8=="6003" & HH1==112 & HH2==11228 & HH4==1122808504

save "$base_brute_denom_inter\Base_fusion_menage_NIAKARAMADOUGOU_KOULOKAHA_6003.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_NIAKARAMADOUGOU_KOULOKAHA_6003.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_NIAKARAMADOUGOU_KOULOKAHA_6003_08122024_14h23.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE MARAHOUE  YAOKRO ZD=6018

*Nombre de batiment dans la ZD=6018


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6018" & HH1==107 & HH2==10712 & HH4==1071204004

list HH1 HH2 HH4 HH8 HH8A if HH8=="6018" & HH1==107 & HH2==10712 & HH4==1071204004

preserve


keep if HH8=="6018" & HH1==107 & HH2==10712 & HH4==1071204004

save "$base_brute_denom_inter\Base_fusion_menage_MARAHOUE_YAOKRO_6018.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_MARAHOUE_YAOKRO_6018.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_MARAHOUE_YAOKRO_6018_11122024_09h31.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE IFFOU  KRINDJABO ZD=6018

*Nombre de batiment dans la ZD=6005


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6005" & HH1==108 & HH2==10829 & HH4==1082911103

list HH1 HH2 HH4 HH8 HH8A if HH8=="6005" & HH1==108 & HH2==10829 & HH4==1082911103

preserve


keep if HH8=="6005" & HH1==108 & HH2==10829 & HH4==1082911103

save "$base_brute_denom_inter\Base_fusion_menage_IFFOU_KRINDJABO_6005.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_IFFOU_KRINDJABO_6005.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_IFFOU_KRINDJABO_6005_13122024_12h50.csv", delimiter(";") datafmt replace

**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE IFFOU  KRINDJABO ZD=6018

*Nombre de batiment dans la ZD=6005


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6005" & HH1==108 & HH2==10829 & HH4==1082911103

list HH1 HH2 HH4 HH8 HH8A if HH8=="6005" & HH1==108 & HH2==10829 & HH4==1082911103

preserve


keep if HH8=="6005" & HH1==108 & HH2==10829 & HH4==1082911103

save "$base_brute_denom_inter\Base_fusion_menage_IFFOU_KRINDJABO_6005.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_IFFOU_KRINDJABO_6005.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_IFFOU_KRINDJABO_6005_13122024_12h50.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   BAFING Booko ZD=6008

*Nombre de batiment dans la ZD=6008


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6008" & HH1==113 & HH2==11319 & HH4==1131908201

list HH1 HH2 HH4 HH8 HH8A if HH8=="6008" & HH1==113 & HH2==11319 & HH4==1131908201

preserve


keep if HH8=="6008" & HH1==113 & HH2==11319 & HH4==1131908201

save "$base_brute_denom_inter\Base_fusion_menage_BAFING_BOOKO_6008.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BAFING_BOOKO_6008.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_BAFING_BOOKO_6008_19122024_12h01.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   WORODOUGOU MANKONO ZD=6031

*Nombre de batiment dans la ZD=6031


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6031" & HH1==113 & HH2==11314 & HH4==1131403908

list HH1 HH2 HH4 HH8 HH8A if HH8=="6031" & HH1==113 & HH2==11314 & HH4==1131403908

preserve


keep if HH8=="6031" & HH1==113 & HH2==11314 & HH4==1131403908

save "$base_brute_denom_inter\Base_fusion_menage_WORODOUGOU_MANKONO_6031.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_WORODOUGOU_MANKONO_6031.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_WORODOUGOU_MANKONO_6031_20122024_08h36.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   BAFING BOOKO ZD=6008

*Nombre de batiment dans la ZD=6008


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6008" & HH1==113 & HH2==11319 & HH4==1131908201

list HH1 HH2 HH4 HH8 HH8A if HH8=="6008" & HH1==113 & HH2==11319 & HH4==1131908201

preserve


keep if HH8=="6008" & HH1==113 & HH2==11319 & HH4==1131908201

save "$base_brute_denom_inter\Base_fusion_menage_BAFING_BOOKO_6008.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BAFING_BOOKO_6008.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_BAFING_BOOKO_6008_20122024_15h05.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   Folon Goulia ZD=6014

*Nombre de batiment dans la ZD=6014


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6014" & HH1==105 & HH2==10524 & HH4==1052408101

list HH1 HH2 HH4 HH8 HH8A if HH8=="6014" & HH1==105 & HH2==10524 & HH4==1052408101

preserve


keep if HH8=="6014" & HH1==105 & HH2==10524 & HH4==1052408101

save "$base_brute_denom_inter\Base_fusion_menage_FOLON_GOULIA_6014.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_FOLON_GOULIA_6014.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom_0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_FOLON_GOULIA_6014_24122024_09h05.csv", delimiter(";") datafmt replace




**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   Akoupe    ZD=6042

*Nombre de batiment dans la ZD=6042
SEG_BaseT4_menage_AKOUPE_6042_25122024_10h05

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6042" & HH1==109 & HH2==10930 & HH4==1093006002

list HH1 HH2 HH4 HH8 HH8A if HH8=="6042" & HH1==109 & HH2==10930 & HH4==1093006002

preserve


keep if HH8=="6042" & HH1==109 & HH2==10930 & HH4==1093006002

save "$base_brute_denom_inter\Base_fusion_menage_AKOUPE_6042.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_AKOUPE_6042.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_AKOUPE_6042_25122024_10h05.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   Glike   ZD=6077

*Nombre de batiment dans la ZD=6077


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6077" & HH1==103 & HH2==10309 & HH4==1030903704

list HH1 HH2 HH4 HH8 HH8A if HH8=="6077" & HH1==103 & HH2==10309 & HH4==1030903704

preserve


keep if HH8=="6077" & HH1==103 & HH2==10309 & HH4==1030903704

save "$base_brute_denom_inter\Base_fusion_menage_Glike_6077.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Glike_6077.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_Glike_6077_25122024_21h05.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   AHOUANOU   ZD=4006

*Nombre de batiment dans la ZD=4006


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="4006" & HH1==109 & HH2==10926 & HH4==1092602501

list HH1 HH2 HH4 HH8 HH8A if HH8=="4006" & HH1==109 & HH2==10926 & HH4==1092602501

preserve


keep if HH8=="4006" & HH1==109 & HH2==10926 & HH4==1092602501

save "$base_brute_denom_inter\Base_fusion_menage_AHOUANOU_4006.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_AHOUANOU_4006.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_AHOUANOU_4006_29122024_14h55.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   MAHANDIANA-SOKOURANI   ZD=6028

*Nombre de batiment dans la ZD=6028


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6028" & HH1==105 & HH2==10524 & HH4==1052408103

list HH1 HH2 HH4 HH8 HH8A if HH8=="6028" & HH1==105 & HH2==10524 & HH4==1052408103

preserve


keep if HH8=="6028" & HH1==105 & HH2==10524 & HH4==1052408103

save "$base_brute_denom_inter\Base_fusion_menage_MAHANDIANA_SOKOURANI_6028.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_MAHANDIANA_SOKOURANI_6028.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_MAHANDIANA_SOKOURANI_6028_30122024_12h09.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   TEHINI   ZD=6016

*Nombre de batiment dans la ZD=6016


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6016" & HH1==114 & HH2==11423 & HH4==1142309102

list HH1 HH2 HH4 HH8 HH8A if HH8=="6016" & HH1==114 & HH2==11423 & HH4==1142309102

preserve


keep if HH8=="6028" & HH1==114 & HH2==11423 & HH4==1142309102

save "$base_brute_denom_inter\Base_fusion_menage_TEHINI_6016.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_TEHINI_6016.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_TEHINI_6016_30122024_19h30.csv", delimiter(";") datafmt replace


/*
**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   BRAFFEDON   ZD=6027

*Nombre de batiment dans la ZD=6027


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6027" & HH1==109 & HH2==10926 & HH4==1092602504

list HH1 HH2 HH4 HH8 HH8A if HH8=="6027" & HH1==109 & HH2==10926 & HH4==1092602504

preserve


keep if HH8=="6027" & HH1==109 & HH2==10926 & HH4==1092602504

save "$base_brute_denom_inter\Base_fusion_menage_BRAFFEDON_6027.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BRAFFEDON_6027.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_BRAFFEDON_6027_31122024_19h30.csv", delimiter(";") datafmt replace

*/
**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   GUINTEGUELA   ZD=6028

*Nombre de batiment dans la ZD=6028. La ZD & été denombrer 2 fois. La permiere la ZD c'est fait partiellement (4 ménages obtenu). Une demande a été faite fait au agent pour la reprise total de la ZD avec un nouvelle entretiens==26-80-45-90.


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6028" & HH1==113 & HH2==11319 & HH4==1131904603 & interview__key=="26-80-45-90"

list HH1 HH2 HH4 HH8 HH8A if HH8=="6028" & HH1==113 & HH2==11319 & HH4==1131904603

preserve


keep if HH8=="6028" & HH1==113 & HH2==11319 & HH4==1131904603

save "$base_brute_denom_inter\Base_fusion_menage_GUINTEGUELA_6028.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_GUINTEGUELA_6028.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_GUINTEGUELA_6028_31122024_19h30.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   TABAKORONI   ZD=6015

*Nombre de batiment dans la ZD=6015. La ZD & été denombrer 2 fois. La permiere la ZD c'est fait partiellement (4 ménages obtenu). Une demande a été faite fait au agent pour la reprise total de la ZD avec un nouvelle entretiens==26-80-45-90.


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6015" & HH1==111 & HH2==11120 & HH4==1112008304 

list HH1 HH2 HH4 HH8 HH8A if HH8=="6015" & HH1==111 & HH2==11120 & HH4==1112008304 

preserve


keep if HH8=="6015" & HH1==111 & HH2==11120 & HH4==1112008304 

save "$base_brute_denom_inter\Base_fusion_menage_TABAKORONI_6015.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_TABAKORONI_6015.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_TABAKORONI_6015_030102025_20h40.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   Assadin   ZD=6047

*Nombre de batiment dans la ZD=6015. La ZD & été denombrer 2 fois. La permiere la ZD c'est fait partiellement (4 ménages obtenu). Une demande a été faite fait au agent pour la reprise total de la ZD avec un nouvelle entretiens==26-80-45-90.


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6047" & HH1==101 & HH2==10101 & HH4==1010100205 

list HH1 HH2 HH4 HH8 HH8A if HH8=="6047" & HH1==101 & HH2==10101 & HH4==1010100205 

preserve


keep if HH8=="6047" & HH1==101 & HH2==10101 & HH4==1010100205 

save "$base_brute_denom_inter\Base_fusion_menage_Assadin_6047.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Assadin_6047.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_Assadin_6047_030102025_16h12.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   Djoroplo   ZD=6014 

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6014" & HH1==103 & HH2==10325 & HH4==1032503806 

list HH1 HH2 HH4 HH8 HH8A if HH8=="6014" & HH1==103 & HH2==10325 & HH4==1032503806  

preserve


keep if HH8=="6014" & HH1==103 & HH2==10325 & HH4==1032503806 

save "$base_brute_denom_inter\Base_fusion_menage_Djoroplo_6014.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Djoroplo_6014.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_Djoroplo_6014_13012025_16h12.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   LUENOUFLA   ZD=6070 

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6070" & HH1==103 & HH2==10325 & HH4==1032503806 

list HH1 HH2 HH4 HH8 HH8A if HH8=="6014" & HH1==103 & HH2==10325 & HH4==1032503806  

preserve


keep if HH8=="6014" & HH1==103 & HH2==10325 & HH4==1032503806 

save "$base_brute_denom_inter\Base_fusion_menage_Djoroplo_6014.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Djoroplo_6014.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_Djoroplo_6014_13012025_16h12.csv", delimiter(";") datafmt replace


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   Zouan   ZD=6020

*Nombre de batiment dans la ZD=6020. 


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6020" & HH1==110 & HH2==11018 & HH4==1101802602 & inlist(interview__key,"00-59-12-30","28-40-82-41")


list HH1 HH2 HH4 HH8 HH8A if HH8=="6020" & HH1==110 & HH2==11018 & HH4==1101802602

preserve


keep if HH8=="6020" & HH1==110 & HH2==11018 & HH4==1101802602

save "$base_brute_denom_inter\Base_fusion_menage_Zouan_6020.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_Zouan_6020.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT4_menage_Zouan_6020_13012024_15h39.csv", delimiter(";") datafmt replace



**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE   NIELLE   ZD=0018 : ZD DE RATTRAPAGE

*Nombre de batiment dans la ZD=0018. 


use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0018" & HH1==111 & HH2==11132 & HH4==1113208603 & inlist(interview__key,"17-19-90-16")


list HH1 HH2 HH4 HH8 HH8A if HH8=="0018" & HH1==111 & HH2==11132 & HH4==1113208603 & inlist(interview__key,"17-19-90-16")

preserve


keep if HH8=="0018" & HH1==111 & HH2==11132 & HH4==1113208603 & inlist(interview__key,"17-19-90-16")

save "$base_brute_denom_inter\Base_fusion_menage_NIELLE_0018.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_NIELLE_0018.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\BaseT4_menage_BAGOUE_KOUTO_0020_26102024_08h12.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\BaseT3_RattrapagesurT4_menage_NIELLE_0018_15012024_10h04.csv", delimiter(";") datafmt replace

