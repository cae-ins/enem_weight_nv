/*
echantillon de 5% pour la banque mondiale 
*/ 


/**************************************************************************************/
/* 1. DEFINITION / CREATION DES DOSSIERS DE TRAVAIL */
/**************************************************************************************/
 
/* Définition du dossier de travail principal - Analyse*/

global Pilote_Analyse    = "E:\INS_CAE_ISE\Indicateurs_ENE\T4\Bulletin_Trimestriel"

/* Définition du dossier de travail du bulletin trimestriel */
global Bulletin_Trimestriel = "${Pilote_Analyse}"

/* Creation & Définition du dossier bases de travail */
global Base = "${Bulletin_Trimestriel}\Base"

/* Creation & Définition du dossier des dofiles*/
global Do = "${Bulletin_Trimestriel}\Do"

/* Creation & Définition du dossier des resultats et données temporaires */

cap mkdir "${Bulletin_Trimestriel}\Temp"
global BT_Temp = "${Bulletin_Trimestriel}\Temp"

/* Creation & Définition du dossier des resultats excel des tableaux */

cap mkdir "${Bulletin_Trimestriel}\Resultats_Tab"
global Resultats_Tab = "${Bulletin_Trimestriel}\Resultats_Tab"

global Base_Cod = "$Base\BaseCod"

******Menage******


*T2

use "${Base}\menage_T2.dta", clear

gen random = runiform()
gen byte sample = 0

levelsof HH2, local(regions)

foreach r of local regions {
    preserve
    keep if HH2 == `r'
    count
    local n = round(r(N) * 0.05)
    sort random
    gen byte temp_select = 0
    replace temp_select = 1 in 1/`n'
    
    tempfile temp_`r'
    save `temp_`r'' // Save the selected subset
    
    restore
    merge 1:1 interview__key /* membres__id */ using `temp_`r'', keepusing(temp_select) nogen
    
    replace sample = 1 if temp_select == 1
    drop temp_select
}

keep if sample == 1
drop random sample

save "$Pilote_Analyse/echantillon_5pct_par_region_T2_menage.dta", replace
 

*T3

use "${Base}\menage_T3_T2.dta", clear

gen random = runiform()
gen byte sample = 0

levelsof HH2, local(regions)

foreach r of local regions {
    preserve
    keep if HH2 == `r'
    count
    local n = round(r(N) * 0.05)
    sort random
    gen byte temp_select = 0
    replace temp_select = 1 in 1/`n'
    
    tempfile temp_`r'
    save `temp_`r'' // Save the selected subset
    
    restore
    merge 1:1 interview__key /* membres__id */ using `temp_`r'', keepusing(temp_select) nogen
    
    replace sample = 1 if temp_select == 1
    drop temp_select
}

keep if sample == 1
drop random sample

save "$Pilote_Analyse/echantillon_5pct_par_region_T3_menage.dta", replace


*T4

use "${Base}\qx_eec_vf_T4.dta", clear

gen random = runiform()
gen byte sample = 0

levelsof HH2, local(regions)

foreach r of local regions {
    preserve
    keep if HH2 == `r'
    count
    local n = round(r(N) * 0.05)
    sort random
    gen byte temp_select = 0
    replace temp_select = 1 in 1/`n'
    
    tempfile temp_`r'
    save `temp_`r'' // Save the selected subset
    
    restore
    merge 1:1 interview__key /* membres__id */ using `temp_`r'', keepusing(temp_select) nogen
    
    replace sample = 1 if temp_select == 1
    drop temp_select
}

keep if sample == 1
drop random sample

save "$Pilote_Analyse/echantillon_5pct_par_region_T4_menage.dta", replace


**Individu**

*T2

use "${Base}\individu_T2.dta", clear

// En raison de l'absence de certaines variables clés comme la région le département le milieu de residence, nous effectuons une fusion avec les données ménages afin de récupérer ces variables
cap drop _merge
merge m:1 interview__key using "${Base}\menage_T2.dta", keepusing(HH1 HH2 HH3 HH4 HH6 HH8 HH8A HH7 HH8B rghab rgmen V1MODINTR trimestreencours mois annee Reference Date1 anneeScolairePassee anneeScolaireEnCours HH9 HH9_1  V1interviewkey V1hha MODINTR L1 L3 L4 L5)

keep if _merge==3

gen random = runiform()
gen byte sample = 0

levelsof HH2, local(regions)

foreach r of local regions {
    preserve
    keep if HH2 == `r'
    count
    local n = round(r(N) * 0.05)
    sort random
    gen byte temp_select = 0
    replace temp_select = 1 in 1/`n'
    
    tempfile temp_`r'
    save `temp_`r'' // Save the selected subset
    
    restore
    merge 1:1 interview__key membres__id  using `temp_`r'', keepusing(temp_select) nogen
    
    replace sample = 1 if temp_select == 1
    drop temp_select
}

keep if sample == 1
drop random sample

save "$Pilote_Analyse/echantillon_5pct_par_region_T2_individu.dta", replace
 

*T3

use "${Base}\individu_T3_T2.dta", clear

// En raison de l'absence de certaines variables clés comme la région le département le milieu de residence, nous effectuons une fusion avec les données ménages afin de récupérer ces variables

cap drop _merge 
merge m:1 interview__key using "${Base}\menage_T3_T2.dta", keepusing(HH1 HH2 HH3 HH4 HH6 HH8 HH8A HH7 HH8B rghab rgmen V1MODINTR trimestreencours mois annee Reference Date1 anneeScolairePassee anneeScolaireEnCours HH9 HH9_1  V1interviewkey V1hha MODINTR L1 L3 L4 L5)


keep if _merge==3


gen random = runiform()
gen byte sample = 0

levelsof HH2, local(regions)

foreach r of local regions {
    preserve
    keep if HH2 == `r'
    count
    local n = round(r(N) * 0.05)
    sort random
    gen byte temp_select = 0
    replace temp_select = 1 in 1/`n'
    
    tempfile temp_`r'
    save `temp_`r'' // Save the selected subset
    
    restore
    merge 1:1 interview__key membres__id  using `temp_`r'', keepusing(temp_select) nogen
    
    replace sample = 1 if temp_select == 1
    drop temp_select
}

keep if sample == 1
drop random sample

save "$Pilote_Analyse/echantillon_5pct_par_region_T3_individu.dta", replace


*T4

use "${Base}\membres_T4.dta", clear

cap drop _merge
// En raison de l'absence de certaines variables clés comme la région le département le milieu de residence, nous effectuons une fusion avec les données ménages afin de récupérer ces variables
merge m:1 interview__key using "${Base}\qx_eec_vf_T4.dta", keepusing(HH1 HH2 HH3 HH4 HH6 HH8 HH8A HH7 HH8B rghab rgmen V1MODINTR trimestreencours mois annee Reference Date1 anneeScolairePassee anneeScolaireEnCours HH9 HH9_1  V1interviewkey V1hha MODINTR L1 L3 L4 L5)

keep if _merge==3

gen random = runiform()
gen byte sample = 0

levelsof HH2, local(regions)

foreach r of local regions {
    preserve
    keep if HH2 == `r'
    count
    local n = round(r(N) * 0.05)
    sort random
    gen byte temp_select = 0
    replace temp_select = 1 in 1/`n'
    
    tempfile temp_`r'
    save `temp_`r'' // Save the selected subset
    
    restore
    merge 1:1 interview__key membres__id  using `temp_`r'', keepusing(temp_select) nogen
    
    replace sample = 1 if temp_select == 1
    drop temp_select
}

keep if sample == 1
drop random sample

save "$Pilote_Analyse/echantillon_5pct_par_region_T4_individu.dta", replace

