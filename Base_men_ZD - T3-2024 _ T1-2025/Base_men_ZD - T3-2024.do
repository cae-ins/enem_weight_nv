

**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE ABIDJAN YOPOUGON ZD=1248

*Nombre de batiment dans la ZD=1248

global Base_denomb_T3_2024 "C:\Users\e_koffie\Documents\Ponderations_ENE\ENE_SURVEY_WEIGHTS\Base_men_ZD - T3-2024 _ T1-2025\Base_denomb_T3_2024"

use "$base_brute_denom\Base_fusion_menage_globale.dta", clear


count if hh8=="1248" & hh1==101 & hh2==10101 & hh4==1010100220

list hh1 hh2 hh4 hh8 if hh8=="1248" & hh1==101 & hh2==10101 & hh4==1010100220

preserve


keep if  hh8=="1248" & hh1==101 & hh2==10101 & hh4==1010100220

save "$Base_denomb_T3_2024\Base_fusion_menage_Abidjan_Yopougon_1248.dta", replace

restore


use "$Base_denomb_T3_2024\Base_fusion_menage_Abidjan_Yopougon_1248.dta", clear



export excel interview_key code_ilot  ilot_id	batiment_id	menage_id adresse_menage adresse_menage1  adresse gps_Longitude_str nb_men_num_bat nom hh01 hh0 hh2a gps_timestamp gps_Latitude_str gps_Longitude_str gps_Accuracy_str gps_Altitude_str   hh01 hh0	hh2a hh1	hh2	hh3	hh4	hh6	hh8	hh8a	hh7	hh8b	trimestreencours	mois_en_cours hh12	hh1 adresse	bat_habite	nom_0 nb_men_num_bat	nb_men_a_num  using "$Base_denomb_T3_2024\Base_menage_Abidjan_Yopougon_1248_05092024_10h04.xlsx", sheetreplace firstrow(variables) 

**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE ABIDJAN YOPOUGON ZD=6043

*Nombre de batiment dans la ZD=1248

global Base_denomb_T3_2024 "C:\Users\e_koffie\Documents\Ponderations_ENE\ENE_SURVEY_WEIGHTS\Base_men_ZD - T3-2024 _ T1-2025\Base_denomb_T3_2024"

use "$base_brute_denom\Base_fusion_menage_globale.dta", clear


count if hh8=="6043" & hh1==113 & hh2==11322 & hh4==1132206902

list hh1 hh2 hh4 hh8 if hh8=="6043" & hh1==113 & hh2==11322 & hh4==1132206902

preserve


keep if  hh8=="6043" & hh1==113 & hh2==11322 & hh4==1132206902

save "$Base_denomb_T3_2024\Base_fusion_menage_Bere_Sonozo_Koura_6043.dta", replace

restore


use "$Base_denomb_T3_2024\Base_fusion_menage_Bere_Sonozo_Koura_6043.dta", clear



export excel interview_key code_ilot  ilot_id	batiment_id	menage_id adresse_menage adresse_menage1  adresse gps_Longitude_str nb_men_num_bat nom hh01 hh0 hh2a gps_timestamp gps_Latitude_str gps_Longitude_str gps_Accuracy_str gps_Altitude_str   hh01 hh0	hh2a hh1	hh2	hh3	hh4	hh6	hh8	hh8a	hh7	hh8b	trimestreencours	mois_en_cours hh12	hh1 adresse	bat_habite	nom_0 nb_men_num_bat	nb_men_a_num  using "$Base_denomb_T3_2024\Base_menage_Bere_Sonozo_Koura_6043.xlsx", sheetreplace firstrow(variables) 


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE MANKONO TOMONO ZD=6059

*Nombre de batiment dans la ZD=6059


*Nombre de batiment dans la ZD=6059

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6059" & HH1==113 & HH2==11322 & HH4==1132203202

list HH1 HH2 HH4 HH8 if HH8=="6059" & HH1==113 & HH2==11322 & HH4==1132203202

preserve


keep if  HH8=="6059" & HH1==113 & HH2==11322 & HH4==1132203202


save "$base_brute_denom_inter\Base_fusion_menage_MANKONO_TOMONO_6059.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_MANKONO_TOMONO_6059.dta", clear

export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_MANKONO_TOMONO_6059_13092024_11h13.xlsx", sheetreplace firstrow(variables) 


**********************************************************************************************************
************** EXTRACTION DE BASE MENAGE FOLON KANIASSO ZD=6014

*Nombre de batiment dans la ZD=6014


*Nombre de batiment dans la ZD=6014

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6014" & HH1==105 & HH2==10524 & HH4==1052408102

list HH1 HH2 HH4 HH8 if HH8=="6014" & HH1==105 & HH2==10524 & HH4==1052408102

preserve


keep if  HH8=="6014" & HH1==105 & HH2==10524 & HH4==1052408102


save "$base_brute_denom_inter\Base_fusion_menage_FOLON_KANIASSO_6014.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_FOLON_KANIASSO_6014.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_FOLON_KANIASSO_6014_13092024_11h23.xlsx", sheetreplace firstrow(variables) 



************** EXTRACTION DE BASE MENAGE BAFING ouaninou ZD=6020

*Nombre de batiment dans la ZD=6020


*Nombre de batiment dans la ZD=6020

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6020" & HH1==113 & HH2==11319 & HH4==1131908704

list HH1 HH2 HH4 HH8 if HH8=="6020" & HH1==113 & HH2==11319 & HH4==1131908704

preserve


keep if  HH8=="6020" & HH1==113 & HH2==11319 & HH4==1131908704


save "$base_brute_denom_inter\Base_fusion_menage_BAFING_OUANINOU_6020.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BAFING_OUANINOU_6020.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_BAFING_OUANINOU_6020_15092024_19h02.xlsx", sheetreplace firstrow(variables) 


************** EXTRACTION DE BASE MENAGE ABIDJAN Koumassi ZD=0202

*Nombre de batiment dans la ZD=0202


*Nombre de batiment dans la ZD=0202

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0202" & HH1==101 & HH2==10101 & HH4==1010100215

list HH1 HH2 HH4 HH8 if HH8=="0202" & HH1==101 & HH2==10101 & HH4==1010100215

preserve


keep if  HH8=="0202" & HH1==101 & HH2==10101 & HH4==1010100215


save "$base_brute_denom_inter\Base_fusion_menage_ABIDJAN_KOUMASS_0202.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_ABIDJAN_KOUMASS_0202.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_ABIDJAN_KOUMASS_0202_17092024_12h17.xlsx", sheetreplace firstrow(variables) 



************** EXTRACTION DE BASE MENAGE IFFOU OUELLE ZD=6058

*Nombre de batiment dans la ZD=6019


*Nombre de batiment dans la ZD=6019

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6019" & HH1==108 & HH2==10829 & HH4==1082911103

list HH1 HH2 HH4 HH8 if HH8=="6019" & HH1==108 & HH2==10829 & HH4==1082911103

preserve


keep if  HH8=="6019" & HH1==108 & HH2==10829 & HH4==1082911103


save "$base_brute_denom_inter\Base_fusion_menage_IFFOU_OUELLE_6019.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_IFFOU_OUELLE_6019.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_IFFOU_OUELLE_6019_17092024_12h17.xlsx", sheetreplace firstrow(variables) 


************** EXTRACTION DE BASE MENAGE SOUBRE LILIYO ZD=6058

*Nombre de batiment dans la ZD=6058


*Nombre de batiment dans la ZD=6058

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6058" & HH1==103 & HH2==10331 & HH4==1033104102

list HH1 HH2 HH4 HH8 if HH8=="6058" & HH1==103 & HH2==10331 & HH4==1033104102

preserve


keep if  HH8=="6058" & HH1==103 & HH2==10331 & HH4==1033104102


save "$base_brute_denom_inter\Base_fusion_menage_SOUBRE_LILIYO_6058.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_SOUBRE_LILIYO_6058.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_SOUBRE_LILIYO_6058_19092024_23h29.xlsx", sheetreplace firstrow(variables) 



************** EXTRACTION DE BASE MENAGE FOLON KANIASSO GOULIA ZD=6008

*Nombre de batiment dans la ZD=6008


*Nombre de batiment dans la ZD=6008

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6008" & HH1==105 & HH2==10524 & HH4==1052408101

list HH1 HH2 HH4 HH8 if HH8=="6008" & HH1==105 & HH2==10524 & HH4==1052408101

preserve


keep if  HH8=="6008" & HH1==105 & HH2==10524 & HH4==1052408101


save "$base_brute_denom_inter\Base_fusion_menage_KANIASSO_GOULIA_6008.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_KANIASSO_GOULIA_6008.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_KANIASSO_GOULIA_6008_24092024_22h01.xlsx", sheetreplace firstrow(variables) 


************** EXTRACTION DE BASE MENAGE BOUKANI DOROPO ZD=6012

*Nombre de batiment dans la ZD=6012


*Nombre de batiment dans la ZD=6012

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6012" & HH1==114 & HH2==11423 & HH4==1142307602

list HH1 HH2 HH4 HH8 if HH8=="6012" & HH1==114 & HH2==11423 & HH4==1142307602

preserve


keep if  HH8=="6012" & HH1==114 & HH2==11423 & HH4==1142307602


save "$base_brute_denom_inter\Base_fusion_menage_BOUKANI_DOROPO_6012.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BOUKANI_DOROPO_6012.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_BOUKANI_DOROPO_6012_25092024_11h27.xlsx", sheetreplace firstrow(variables) 



************** EXTRACTION DE BASE MENAGE ADZOPE YAKASSEME ZD=4004

*Nombre de batiment dans la ZD=4004


*Nombre de batiment dans la ZD=4004

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="4004" & HH1==109 & HH2==10930 & HH4==1093000406

list HH1 HH2 HH4 HH8 if HH8=="4004" & HH1==109 & HH2==10930 & HH4==1093000406

preserve


keep if  HH8=="4004" & HH1==109 & HH2==10930 & HH4==1093000406


save "$base_brute_denom_inter\Base_fusion_menage_ADZOPE_YAKASSEME_4004.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_ADZOPE_YAKASSEME_4004.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_ADZOPE_YAKASSEME_4004_25092024_20h13.xlsx", sheetreplace firstrow(variables) 




************** EXTRACTION DE BASE MENAGE OUANGOLODOUGOU NIELLE ZD=0009

*Nombre de batiment dans la ZD=0009


*Nombre de batiment dans la ZD=0009

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0009" & HH1==111 & HH2==11132 & HH4==1113208603

list HH1 HH2 HH4 HH8 if HH8=="0009" & HH1==111 & HH2==11132 & HH4==1113208603

preserve


keep if  HH8=="0009" & HH1==111 & HH2==11132 & HH4==1113208603


save "$base_brute_denom_inter\Base_fusion_menage_OUANGOLODOUGOU_NIELLE_0009.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_OUANGOLODOUGOU_NIELLE_0009.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_OUANGOLODOUGOU_NIELLE_0009_28092024_07h30.xlsx", sheetreplace firstrow(variables) 


************** EXTRACTION DE BASE MENAGE GUEMON DUEKOUE ZD=6075

*Nombre de batiment dans la ZD=6075


*Nombre de batiment dans la ZD=6075

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6075" & HH1==110 & HH2==11027 & HH4==1102702202

list HH1 HH2 HH4 HH8 if HH8=="6075" & HH1==110 & HH2==11027 & HH4==1102702202

preserve


keep if HH8=="6075" & HH1==110 & HH2==11027 & HH4==1102702202


save "$base_brute_denom_inter\Base_fusion_menage_GUEMON_DUEKOUE_6075.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_GUEMON_DUEKOUE_6075.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_GUEMON_DUEKOUE_6075_08102024_21h33.xlsx", sheetreplace firstrow(variables) 




************** EXTRACTION DE BASE MENAGE IFFOU APKOUBOUE ZD=6029

*Nombre de batiment dans la ZD=6029


*Nombre de batiment dans la ZD=6029

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6029" & HH1==108 & HH2==10829 & HH4==1082903303

list HH1 HH2 HH4 HH8 if HH8=="6029" & HH1==108 & HH2==10829 & HH4==1082903303

preserve


keep if HH8=="6029" & HH1==108 & HH2==10829 & HH4==1082903303


save "$base_brute_denom_inter\Base_fusion_menage_IFFOU_APKOUBOUE_6029.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_IFFOU_APKOUBOUE_6029.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_IFFOU_APKOUBOUE_6029_09102024_12h14.xlsx", sheetreplace firstrow(variables) 




************** EXTRACTION DE BASE MENAGE BOUAKE GBEKE ZD=6052

*Nombre de batiment dans la ZD=6052


*Nombre de batiment dans la ZD=6052

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6052" & HH1==112 & HH2==11204 & HH4==1120401301

list HH1 HH2 HH4 HH8 if HH8=="6052" & HH1==112 & HH2==11204 & HH4==1120401301

preserve


keep if HH8=="6052" & HH1==112 & HH2==11204 & HH4==1120401301


save "$base_brute_denom_inter\Base_fusion_menage_BOUAKE_GBEKE_6052.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BOUAKE_GBEKE_6052.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_BOUAKE_GBEKE_6052_09102024_17h01.xlsx", sheetreplace firstrow(variables) 






************** EXTRACTION DE BASE MENAGE WORODOUGOU WOROFLA ZD=6004

*Nombre de batiment dans la ZD=6004


*Nombre de batiment dans la ZD=6004

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6004" & HH1==113 & HH2==11314 & HH4==1131403908

list HH1 HH2 HH4 HH8 if HH8=="6004" & HH1==113 & HH2==11314 & HH4==1131403908

preserve


keep if HH8=="6004" & HH1==113 & HH2==11314 & HH4==1131403908


save "$base_brute_denom_inter\Base_fusion_menage_WORODOUGOU_WOROFLA_6004.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_WORODOUGOU_WOROFLA_6004.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_WORODOUGOU_WOROFLA_6004_10102024_13h34.xlsx", sheetreplace firstrow(variables) 



************** EXTRACTION DE BASE MENAGE ODIENNE Guinteguela ZD=6019

*Nombre de batiment dans la ZD=6019


*Nombre de batiment dans la ZD=6019

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6019" & HH1==113 & HH2==11319 & HH4==1131904603

list HH1 HH2 HH4 HH8 if HH8=="6019" & HH1==113 & HH2==11319 & HH4==1131904603

preserve


keep if HH8=="6019" & HH1==113 & HH2==11319 & HH4==1131904603


save "$base_brute_denom_inter\Base_fusion_menage_ODIENNE_Guinteguela_6019.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_ODIENNE_Guinteguela_6019.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_ODIENNE_Guinteguela_6019_12102024_09h10.xlsx", sheetreplace firstrow(variables) 



************** EXTRACTION DE BASE MENAGE CAVALLY DOMOBLY ZD=6007

*Nombre de batiment dans la ZD=6007


*Nombre de batiment dans la ZD=6007

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6007" & HH1==110 & HH2==11018 & HH4==1101802602

list HH1 HH2 HH4 HH8 if HH8=="6007" & HH1==110 & HH2==11018 & HH4==1101802602

preserve


keep if HH8=="6007" & HH1==110 & HH2==11018 & HH4==1101802602


save "$base_brute_denom_inter\Base_fusion_menage_CAVALLY_GUIGLO_6007.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_CAVALLY_GUIGLO_6007.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_CAVALLY_GUIGLO_6007_16102024_05h19.xlsx", sheetreplace firstrow(variables) 


************** EXTRACTION DE BASE MENAGE BAGOUE LAFI ZD=6011

*Nombre de batiment dans la ZD=6011


*Nombre de batiment dans la ZD=6011

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6011" & HH1==111 & HH2==11120 & HH4==1112001504

list HH1 HH2 HH4 HH8 if HH8=="6011" & HH1==111 & HH2==11120 & HH4==1112001504

preserve


keep if HH8=="6011" & HH1==111 & HH2==11120 & HH4==1112001504


save "$base_brute_denom_inter\Base_fusion_menage_BAGOUE_LAFI_6011.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BAGOUE_LAFI_6011.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_BAGOUE_LAFI_6011_14102024_12h46.xlsx", sheetreplace firstrow(variables) 



************** EXTRACTION DE BASE MENAGE HAMBOL DABAKALA ZD=0028

*Nombre de batiment dans la ZD=0028


*Nombre de batiment dans la ZD=0028

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="0028" & HH1==112 & HH2==11228 & HH4==1122801603

list HH1 HH2 HH4 HH8 if HH8=="0028" & HH1==112 & HH2==11228 & HH4==1122801603

preserve


keep if HH8=="0028" & HH1==112 & HH2==11228 & HH4==1122801603


save "$base_brute_denom_inter\Base_fusion_menage_HAMBOL_DABAKALA_0028.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_HAMBOL_DABAKALA_0028.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_HAMBOL_DABAKALA_0028_15102024_07h54.xlsx", sheetreplace firstrow(variables) 



************** EXTRACTION DE BASE MENAGE DABOU TOUPAH ZD=4010

*Nombre de batiment dans la ZD=4010


*Nombre de batiment dans la ZD=4010

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="4010" & HH1==109 & HH2==10926 & HH4==1092605403

list HH1 HH2 HH4 HH8 if HH8=="4010" & HH1==109 & HH2==10926 & HH4==1092605403

preserve


keep if HH8=="4010" & HH1==109 & HH2==10926 & HH4==1092605403


save "$base_brute_denom_inter\Base_fusion_menage_DABOU_TOUPAH_4010.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_DABOU_TOUPAH_4010.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_DABOU_TOUPAH_4010_19102024_10h39.xlsx", sheetreplace firstrow(variables) 


************** EXTRACTION DE BASE MENAGE BOUKANI BOUNA ZD=6028

*Nombre de batiment dans la ZD=4010


*Nombre de batiment dans la ZD=4010

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6028" & HH1==114 & HH2==11423 & HH4==1142301402

list HH1 HH2 HH4 HH8 if HH8=="6028" & HH1==114 & HH2==11423 & HH4==1142301402

preserve


keep if HH8=="6028" & HH1==114 & HH2==11423 & HH4==1142301402


save "$base_brute_denom_inter\Base_fusion_menage_BOUNKANI_BOUNA_6028.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BOUNKANI_BOUNA_6028.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_BOUNKANI_BOUNA_6028_19102024_16h54.xlsx", sheetreplace firstrow(variables) 



************** EXTRACTION DE BASE MENAGE KABADOUGOU  ODIENNE ZD=0004

*Nombre de batiment dans la ZD=0004


*Nombre de batiment dans la ZD=0004

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6028" & HH1==114 & HH2==11423 & HH4==1142301402

list HH1 HH2 HH4 HH8 if HH8=="6028" & HH1==114 & HH2==11423 & HH4==1142301402

preserve


keep if HH8=="6028" & HH1==114 & HH2==11423 & HH4==1142301402


save "$base_brute_denom_inter\Base_fusion_menage_BOUNKANI_BOUNA_6028.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_BOUNKANI_BOUNA_6028.dta", clear


export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_BOUNKANI_BOUNA_6028_19102024_16h54.xlsx", sheetreplace firstrow(variables) 


************** EXTRACTION DE BASE MENAGE HAUT-SASSANDRA  VAVOUA ZD=6034

*Nombre de batiment dans la ZD=6048


*Nombre de batiment dans la ZD=6048

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6048" & HH1==107 & HH2==10702 & HH4==1070204803

list HH1 HH2 HH4 HH8 if HH8=="6048" & HH1==107 & HH2==10702 & HH4==1070204803

preserve


keep if HH8=="6048" & HH1==107 & HH2==10702 & HH4==1070204803


save "$base_brute_denom_inter\Base_fusion_menage_HAUT_SASSANDRA_VAVOUA_6048.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_HAUT_SASSANDRA_VAVOUA_6048.dta", clear


*export excel interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num  using "$Resultat_segmentation_tirage\Base_menage_HAUT_SASSANDRA_VAVOUA_6048_25102024_17h34.xlsx", sheetreplace firstrow(variables) 


export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\Base_menage_HAUT_SASSANDRA_VAVOUA_6048_25102024_17h34.csv", delimiter(";") datafmt replace

************** EXTRACTION DE BASE MENAGE TCHOLOGO  KAOUARA ZD=6013

*Nombre de batiment dans la ZD=6013


*Nombre de batiment dans la ZD=6013

use "$base_brute_denom_inter\Base_fusion_menage_globale.dta", clear


count if HH8=="6013" & HH1==111 & HH2==11132 & HH4==1113208602

list HH1 HH2 HH4 HH8 if HH8=="6013" & HH1==111 & HH2==11132 & HH4==1113208602

preserve


keep if HH8=="6013" & HH1==111 & HH2==11132 & HH4==1113208602

save "$base_brute_denom_inter\Base_fusion_menage_TCHOLOGO_KAOUARA_6013.dta", replace

restore


use "$base_brute_denom_inter\Base_fusion_menage_TCHOLOGO_KAOUARA_6013.dta", clear

export delimited interview__key code_ilot  ilot__id batiment__id menage__id  adresse_menage adresse_menage1  adresse nb_men_num_bat nom__0 HH01 HH0 HH2A gps__Timestamp gps__Latitude_str gps__Longitude_str gps__Accuracy_str gps__Altitude_str gps__Timestamp  HH01 HH0	HH2A HH1	HH2	HH3	HH4	HH6	HH8	HH8A	HH7	HH8B	trimestreencours	mois_en_cours HH12	HH1 adresse	bat_habite	nom__0 nb_men_num_bat	nb_men_a_num using "$Resultat_segmentation_tirage\Base_fusion_menage_TCHOLOGO_KAOUARA_6013_27102024_08h34.csv", delimiter(";") datafmt replace


