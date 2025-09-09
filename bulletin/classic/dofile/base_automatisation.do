/*
Dofile pour creer la base trimestrielle à utiliser sur R_markdown
*/


***definition des globals***

global donnees    = "E:\INS_CAE_ISE\Bulletin_ENE\donnees"
global dofile     = "E:\INS_CAE_ISE\Bulletin_ENE\dofile"


*** Exemple : Trimestre 3 : 2025*****

**charger les bases de T3***

use "$donnees\Individu\individu_T3_T2.dta", clear 
cap drop _merge 
merge m:1 interview__key using "$donnees\Menage\menage_T3_T2.dta", keepusing(HH1 HH2 HH3 HH4 HH6 HH8 HH8A HH7 HH8B rghab rgmen V1MODINTR trimestreencours mois annee Reference Date1 anneeScolairePassee anneeScolaireEnCours HH9 HH9_1  V1interviewkey V1hha MODINTR L1 L3 L4 L5)

**calcul des variables intermediaire**

do "$dofile\1_1_Var_objectives_to_run.do", nostop
do "$dofile\1_2_Indicateur_Bulletin_To_Run.do", nostop
do "$dofile\Revision_CISE_12112024.do", nostop

**Enregistrement de la base à utiliser sur R pour le bulletin automatique

save "$donnees\base_T3.dta", replace