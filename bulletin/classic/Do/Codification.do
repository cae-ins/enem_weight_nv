
//==============  Creation fictive des variables sur la branche car elle n'existe pas encore dans la base. Nous conservons le vrai code à utiliser quand les données sur les branches seront disponibles avec la codifications






// Création du fichier des codifications

preserve

import excel "${Base_Cod}\PRINCIPAL EP2a1 et EP2b1.xlsx", sheet("Feuil1") firstrow clear


keep interview__key membres__id CODE_ACTIVITE LIB_ACTIVITE code_produit lib_produit

save "${Base_Cod}\codif_branche_t2.dta", replace

use "${Base}\individu.dta" , clear
cap drop _merge 
merge 1:1 interview__key membres__id using "${Base_Cod}\codif_branche_t2.dta" , keepus(CODE_ACTIVITE)

cap drop _merge 

cap drop Code_1er
gen Code_1er=substr(CODE_ACTIVITE,1,1) 

cap drop branche2
gen branche2=99 if Code_1er != ""

replace branche2=1  if Code_1er=="A"
replace branche2=2  if Code_1er=="B"
replace branche2=2  if Code_1er=="C"
replace branche2=2  if Code_1er=="D"
replace branche2=2  if Code_1er=="E"
replace branche2=2  if Code_1er=="F"
replace branche2=3  if Code_1er=="G"
replace branche2=3  if Code_1er=="H"
replace branche2=3  if Code_1er=="I"
replace branche2=3  if Code_1er=="J"
replace branche2=3  if Code_1er=="K"
replace branche2=3  if Code_1er=="L"
replace branche2=3  if Code_1er=="M"
replace branche2=3  if Code_1er=="N"
replace branche2=3  if Code_1er=="O"
replace branche2=3  if Code_1er=="P"
replace branche2=3  if Code_1er=="Q"
replace branche2=3  if Code_1er=="R"
replace branche2=3  if Code_1er=="S"
replace branche2=3  if Code_1er=="T"

lab var branche2 "Brache d'activité 2"
		cap label drop branche
		label define branche 1 "Secteur primaire" 2 "Secteur secondaire" ///
			3 "Secteur tertiaire" 99 "Non-classés"
		label values branche2 branche
		
		
cap drop branche1
gen branche1=4 if Code_1er != ""

replace branche1=1  if Code_1er=="A"
replace branche1=2  if Code_1er=="B"
replace branche1=2  if Code_1er=="C"
replace branche1=3  if Code_1er=="G"


lab var branche1 "Brache d'activité 1"
		cap label drop branche1
		label define branche1 1 "Agriculture" 2 "Industrie" ///
			3 "Commerce" 4 "Autre service"
		label values branche1 branche1
		
*save "${Base_Cod}\Base_Cod.dta", replace

*use "${BT_Temp}\Base_Travail_BT.dta", replace

*cap drop _merge	

*merge 1:1  interview__key membres__id using "${Base_Cod}\Base_Cod.dta"

save "${Base}\individu.dta" , replace

restore


/*============ FORMATAGE DES TABLEAUX ==========================
** Generer les variables sit_emp et branche2 de manière fictive

cap drop N
gen N=_n
cap drop branche1
gen branche1 =.
replace branche1 = 1 if inrange(N,1,2257)
replace branche1 = 2 if inrange(N,2258,11608)
replace branche1 = 3 if inrange(N,11609,15000)
replace branche1 = 4 if inrange(N,15001,22568)


cap drop branche2
gen branche2 =.
replace branche2 = 1 if inrange(N,1,5643)
replace branche2 = 2 if inrange(N,5644,11285)
replace branche2 = 3 if inrange(N,11286,22568)


label define branche1 1 "Agriculture" 2 "Industrie" ///
			3 "Commerce" 4 "Autre service"
		label values branche1 branche1
		
label define branche 1 "Secteur primaire" 2 "Secteur secondaire" ///
			3 "Secteur tertiaire"
		label values branche2 branche*/


