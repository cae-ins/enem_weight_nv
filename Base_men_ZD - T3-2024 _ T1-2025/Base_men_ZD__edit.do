************************************************************************************************************************************************************************

	*EXTRACTION DE LA BASE DE DONNEES MENAGE POUR LE DENOMBREMENT

*Importation de la base ménage 

global  base_brute_denom "C:\Users\e_koffie\Documents\Ponderations_ENE\ENE_SURVEY_WEIGHTS\data\02_cleaned\Denombrement\T3_2024"

*Exportation de la base batiment
use "$base_brute_denom\menage.dta", clear


*Merge avec entre la base Menage et la base batiment


cap drop _merge
merge m:1 interview_key ilot_id batiment_id using "$base_brute_denom\batiment.dta", keepusing( gps_latitude	gps_longitude	gps_accuracy	gps_altitude	gps_timestamp	adresse	bat_habite	nom_0 nb_men_num_bat	nb_men_a_num)
 drop if _merge!=3

*Merge entre la base obtenu (base Menage et la base batiment) avec la base ilot, pour recuperer les codes ilots 

cap drop _merge

merge m:1 interview_key ilot_id  using "$base_brute_denom\ilot.dta", keepusing( code_ilot)
 drop if _merge!=3

*Merge entre la base obtenu  avec la base ilot, pour recuperer les informations sur la région

cap drop _merge

merge m:1 interview_key   using "$base_brute_denom\ENEM_T3_2024_DENOM.dta", keepusing(hh01 hh0	hh2a hh1	hh2	hh3	hh4	hh6	hh8	hh8a	hh7	hh8b	trimestreencours	mois_en_cours hh12	hh13)
 drop if _merge!=3

* Transformer la variable numérique 'gps_Latitude gpsLongitude gpsAccuracy gpsAltitude gps_Timestamp' en une variable de type chaîne de caractères
tostring gps_latitude, generate(gps_Latitude_str)
tostring gps_longitude, generate(gps_Longitude_str)
tostring gps_accuracy, generate(gps_Accuracy_str) force
tostring gps_altitude, generate(gps_Altitude_str) force



save "$base_brute_denom\Base_fusion_menage_globale.dta", replace

export delimited interview_key code_ilot  ilot_id	batiment_id	menage_id adresse_menage adresse_menage1  adresse gps_Longitude_str nb_men_num_bat nom hh01 hh0 hh2a gps_timestamp gps_Latitude_str gps_Longitude_str gps_Accuracy_str gps_Altitude_str   hh01 hh0	hh2a hh1	hh2	hh3	hh4	hh6	hh8	hh8a	hh7	hh8b	trimestreencours	mois_en_cours hh12	hh1 adresse	bat_habite	nom_0 nb_men_num_bat	nb_men_a_num using taille "$base_brute_denom\Base_fusion_menage_globale.csv", delimiter(";") datafmt replace



***** Déterminer le nombre d'entretient valider par l'équipe de veille par région

export excel  HH1 HH2 HH3 HH4 HH6 HH8  HH13  using "$Point_collecte_AT\Resu1T2_2025_denombrement_global_National.xlsx", sheet("National")  firstrow(varlabels) sheetreplace