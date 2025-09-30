***** ENEM 2024 *****************************************
** CALCUL DES INDICATEURS DE TRANSITION T2 - T3
***********************************************************

/**************************************************************************************/
/* 1. DEFINITION / CREATION DES DOSSIERS DE TRAVAIL */
/**************************************************************************************/
 
/* Définition du dossier de travail principal - Analyse*/

global Pilote_Analyse    = "C:\Users\Dell\OneDrive\Documents\DOCS\ENQUETE_ENE_KOFFIE\ATELIER_ENE_T3\Indicateurs\Bulletin_Trimestriel"

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

/*definition du global vers la codif branche activité de T2*/

cap mkdir  "${Base}\BaseCod"
global Base_Cod = "${Base}\BaseCod"

/**************************************************************************************/
/* 2. SELECTION DES BASES DE TRAVAIL ET TRAVAUX PRELIMINAIRES */
/**************************************************************************************/

/* Accommodation de la base individu T3 */
use "${Base}\membres.dta", clear

cap drop _merge
merge m:1 interview__key using "${Base}\qx_eec_vf.dta"
keep if _merge==3
cap drop _merge
destring membre_id_v1, replace force
keep if membre_id_v1 != .

/* Construction de la variable status de l'emploi base individu T3 */
// Creation des variables objectives (variables de croisement, sous-variables clées, etc.)
do "${Do}\1_1_Var_objectives_to_run.do"
// Creation des indicateurs du bulletin trimestriel 
do "${Do}\1_2_Indicateur_Bulletin_To_Run.do"
// Creation des indicateurs de la CISE_18 
do "${Do}\Revision_CISE_090924.do"
*do "${Do}\Codification.do" // 

* Create a list of variables to exclude
local exclude V1interviewkey membre_id_v1

* Loop over all variables in the dataset
foreach var of varlist * {
    * Check if the variable is not in the exclude list
    if "`var'" != "V1interviewkey" & "`var'" != "membre_id_v1" {
        * Rename the variable by adding the _t2 suffix
        rename `var' `var'_t3
    }
}


* Sauvegarde de la nouvelle base individu T3
save "${Base}\membres_v2.dta", replace 

/* Accommodation de la base individu T2 */

do "${Do}\Codification.do" // 

use "${Base}\individu.dta", clear


* Accommodation des variables de la base individu T2
* avec celles de la base indvidu T3
cap drop _merge
cap drop membre_id_v1 V1interviewkey
rename membres__id membre_id_v1
rename interview__key V1interviewkey
/* Construction de la variable status de l'emploi base individu T2 */
// Creation des variables objectives (variables de croisement, sous-variables clées, etc.)
do "${Do}\1_1_Var_objectives_to_run.do"
// Creation des indicateurs du bulletin trimestriel 
do "${Do}\1_2_Indicateur_Bulletin_To_Run.do"
// Creation des indicateurs de la CISE_18 
do "${Do}\Revision_CISE_090924.do"


* Create a list of variables to exclude
local exclude V1interviewkey membre_id_v1

* Loop over all variables in the dataset
foreach var of varlist * {
    * Check if the variable is not in the exclude list
    if "`var'" != "V1interviewkey" & "`var'" != "membre_id_v1" {
        * Rename the variable by adding the _t2 suffix
        rename `var' `var'_t2
    }
}

/* Construction de la variable status de l'emploi base individu T2 */

merge 1:m V1interviewkey membre_id_v1 using "${Base}\membres_v2.dta"
keep if _merge==3

* Imputation de la variable sexe_t3 grâce aux valeurs
* de la variable sexe_t2
replace sexe_t3 = 1 if sexe_t2 == 1 //Remplacer ceux qui sont de sexe feminin au t3 alors qu'ils étaient de sexe masculin au t2 
replace sexe_t3 = 2 if sexe_t2 == 2 // Remplacer ceux qui sont de sexe masculin au t3 alors qu'ils étaient de sexe feminin au t2

// Ajout d'une variable de pondération fictive
cap drop poids
gen poids = 1
svyset [pw=poids]

/**************************************************************************************/
/* 3. CALCUL DES INDICATEURS DE TRANSITION */
/**************************************************************************************/

/* 3.3. situation dans l'emploi T3 x situation dans l'emploi T2 */
/* Variables impliquées 
sit_empEP_t2 : situation dans l'emploi au trimestre 2
sit_empEP_t3 : situation dans l'emploi au trimestre 3
milieu_resid2 : Milieu de résidence à trois modalités
sexe_t2 : Sexe au trimestre 2 (censé être identique qu trimestre 3)
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG3 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/
		
/* par sexe */

* Masculin
proportion CISE_18_new_t3 [pw=poids] if sexe_t2==1, over(CISE_18_new_t2)
mat list e(b)
mat define RESU__M = ((r(table)[rownumb(r(table), "b"), 1..5]*100)', (r(table)[rownumb(r(table), "b"), 6..10]*100)', (r(table)[rownumb(r(table), "b"), 11..15]*100)', (r(table)[rownumb(r(table), "b"), 16..20]*100)', (r(table)[rownumb(r(table), "b"), 21..25]*100)')

* Feminin
proportion CISE_18_new_t3 [pw=poids] if sexe_t2==2 & sit_empEP_t3 != 99 & sit_empEP_t2 !=99, over(CISE_18_new_t2)
mat list e(b)
mat define RESU__F = ((r(table)[rownumb(r(table), "b"), 1..5]*100)', (r(table)[rownumb(r(table), "b"), 6..10]*100)', (r(table)[rownumb(r(table), "b"), 11..15]*100)', (r(table)[rownumb(r(table), "b"), 16..20]*100)', (r(table)[rownumb(r(table), "b"), 21..25]*100)')

** Agrégation
mat RESU = RESU__M, RESU__F

matrix rownames RESU = "Employeur" "Travailleurs indépendants sans emp." "Non-salariés dépendants" "Employés" "Travailleurs familiaux"

*mat RESU = J(1, 10, .) \ RESU

matrix colnames RESU = "Employeur" "Travailleurs indépendants sans emp." "Non-salariés dépendants" "Employés" "Travailleurs familiaux" "Employeur" "Travailleurs indépendants sans emp." "Non-salariés dépendants" "Employés" "Travailleurs familiaux"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("sit_emp_sexe") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la situation dans l'emploi entre le trimestre 2 et le trimestre 3, par sexe "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Situation dans l'emploi au trimestre 3"
putexcel (B3:K3), merge

*Ajout des modalités du sexe
putexcel B4 = "Masculin"
putexcel (B4:F4), merge

putexcel G4 = "Feminin"
putexcel (G4:K4), merge

*En tête ligne du Tableau
putexcel A4 = "Situation dans l'emploi au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close



/* par milieu de residence */

* Abidjan
proportion CISE_18_new_t3 [pw=poids] if milieu_resid2_t2==1 , over(CISE_18_new_t2)
mat list e(b)
mat define RESU__Abidjan = ((.,.,.,.,.)', (r(table)[rownumb(r(table), "b"), 1..5]*100)', (r(table)[rownumb(r(table), "b"), 6..10]*100)', (r(table)[rownumb(r(table), "b"), 11..15]*100)', (r(table)[rownumb(r(table), "b"), 16..20]*100)')


* RESU__Autre_urbain 
proportion CISE_18_new_t3 [pw=poids] if milieu_resid2_t2==2 , over(CISE_18_new_t2)
mat list e(b)
mat define RESU__AutreUrbain = ((r(table)[rownumb(r(table), "b"), 1..5]*100)', (r(table)[rownumb(r(table), "b"), 6..10]*100)', (r(table)[rownumb(r(table), "b"), 11..15]*100)', (r(table)[rownumb(r(table), "b"), 16..20]*100)', (r(table)[rownumb(r(table), "b"), 21..25]*100)')

* RESU__Rural
proportion CISE_18_new_t3 [pw=poids] if milieu_resid2_t2==3 , over(CISE_18_new_t2)
mat list e(b)
mat define RESU__Rural = ((r(table)[rownumb(r(table), "b"), 1..5]*100)', (r(table)[rownumb(r(table), "b"), 6..10]*100)', (r(table)[rownumb(r(table), "b"), 11..15]*100)', (r(table)[rownumb(r(table), "b"), 16..20]*100)', (r(table)[rownumb(r(table), "b"), 21..25]*100)')


** Agrégation
mat RESU = RESU__Abidjan, RESU__AutreUrbain, RESU__Rural

matrix rownames RESU = "Employeur" "Travailleurs indépendants sans emp." "Non-salariés dépendants" "Employés" "Travailleurs familiaux"

*mat RESU = J(1, 15, .) \ RESU

matrix colnames RESU = "Employeur" "Travailleurs indépendants sans emp." "Non-salariés dépendants" "Employés" "Travailleurs familiaux" "Employeur" "Travailleurs indépendants sans emp." "Non-salariés dépendants" "Employés" "Travailleurs familiaux" "Employeur" "Travailleurs indépendants sans emp." "Non-salariés dépendants" "Employés" "Travailleurs familiaux"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("sit_emp_residence") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la situation dans l'emploi entre le trimestre 2 et le trimestre 3, par milieu de résidence "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Situation dans l'emploi au trimestre 3"
putexcel (B3:P3), merge

*Ajout des modalités du sexe
putexcel B4 = "Milieu - Abidjan"
putexcel (B4:F4), merge

putexcel G4 = "Milieu - Autre Urbain"
putexcel (G4:K4), merge

putexcel L4 = "Milieu - Rural"
putexcel (L4:P4), merge

*En tête ligne du Tableau
putexcel A4 = "Situation dans l'emploi au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

** Groupe d'Âge 

/* par Groupe d'Âge  */

* 16_24 ans
proportion CISE_18_new_t3 [pw=poids] if groupe_age4_t2==1 , over(CISE_18_new_t2)
mat list e(b)
mat define RESU__GrpAge16_24 = ((r(table)[rownumb(r(table), "b"), 1..5]*100)', (r(table)[rownumb(r(table), "b"), 6..10]*100)', (r(table)[rownumb(r(table), "b"), 11..15]*100)', (r(table)[rownumb(r(table), "b"), 16..20]*100)', (r(table)[rownumb(r(table), "b"), 21..25]*100)')

* 25_35 ans
proportion CISE_18_new_t3 [pw=poids] if groupe_age4_t2==2, over(CISE_18_new_t2)
mat list e(b)
mat define RESU__GrpAge25_35 = ((r(table)[rownumb(r(table), "b"), 1..5]*100)', (r(table)[rownumb(r(table), "b"), 6..10]*100)', (r(table)[rownumb(r(table), "b"), 11..15]*100)', (r(table)[rownumb(r(table), "b"), 16..20]*100)', (r(table)[rownumb(r(table), "b"), 21..25]*100)')

* 36_64 ans
proportion CISE_18_new_t3 [pw=poids] if groupe_age4_t2==3 , over(CISE_18_new_t2)
mat list e(b)
mat define RESU__GrpAge36_64 = ((r(table)[rownumb(r(table), "b"), 1..5]*100)', (r(table)[rownumb(r(table), "b"), 6..10]*100)', (r(table)[rownumb(r(table), "b"), 11..15]*100)', (r(table)[rownumb(r(table), "b"), 16..20]*100)', (r(table)[rownumb(r(table), "b"), 21..25]*100)')

* 65ans et plus
proportion CISE_18_new_t3 [pw=poids] if groupe_age4_t2==4 , over(CISE_18_new_t2)
mat list e(b)
mat define RESU__GrpAge65_plus = ((r(table)[rownumb(r(table), "b"), 1..4]*100)', (r(table)[rownumb(r(table), "b"), 5..8]*100)', (r(table)[rownumb(r(table), "b"), 9..12]*100)', (r(table)[rownumb(r(table), "b"), 13..16]*100)', (.,.,.,.)')
mat RESU__GrpAge65_plus = RESU__GrpAge65_plus \ (.,.,.,.,.)


** Agrégation
mat RESU = RESU__GrpAge16_24, RESU__GrpAge25_35, RESU__GrpAge36_64, RESU__GrpAge65_plus
mat list RESU

matrix rownames RESU = "Employeur" "Travailleurs indépendants sans emp." "Non-salariés dépendants" "Employés" "Travailleurs familiaux"

*mat RESU = J(1, 20, .) \ RESU

matrix colnames RESU = "Employeur" "Travailleurs indépendants sans emp." "Non-salariés dépendants" "Employés" "Travailleurs familiaux" "Employeur" "Travailleurs indépendants sans emp." "Non-salariés dépendants" "Employés" "Travailleurs familiaux" "Employeur" "Travailleurs indépendants sans emp." "Non-salariés dépendants" "Employés" "Travailleurs familiaux"

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("sit_emp_grpe_age") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la situation dans l'emploi entre le trimestre 2 et le trimestre 3, par groupe d'age "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Situation dans l'emploi au trimestre 3"
putexcel (B3:U3), merge

*Ajout des modalités du sexe
putexcel B4 = "16 - 24 ans"
putexcel (B4:F4), merge

putexcel G4 = "25 - 35 ans"
putexcel (G4:K4), merge

putexcel L4 = "36 - 64 ans"
putexcel (L4:P4), merge

putexcel Q4 = "65 ans et plus"
putexcel (Q4:U4), merge

*En tête ligne du Tableau
putexcel A4 = "Situation dans l'emploi au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close



/* 3.3. population en emploi T3 x situation dans l'emploi T2 */
/* Variables impliquées 
pop_emp_t2 : population en emploi au trimestre 2
pop_emp_t3 : population en emploi au trimestre 3
milieu_resid2 : Milieu de résidence à trois modalités
sexe_t2 : Sexe au trimestre 2 (censé être identique qu trimestre 3)
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG3 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/

* Supression des individus au chomage de la variable
replace pop_emp_t2 = . if pop_emp_t2 == 0
replace pop_emp_t3 = . if pop_emp_t3 == 0
		
/* par sexe  */


* Masculin
proportion pop_emp_t3 [pw=poids] if sexe_t2==1, over(pop_emp_t2)
mat list e(b)
mat define RESU__M = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')

* Feminin
proportion pop_emp_t3 [pw=poids] if sexe_t2==2, over(pop_emp_t2)
mat list e(b)
mat define RESU__F = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')

** Agrégation
mat RESU = RESU__M, RESU__F

matrix rownames RESU = "Emploi présent" "Emploi absent"

matrix colnames RESU = "Emploi présent" "Emploi absent" "Emploi présent" "Emploi absent"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("pop_emp_sexe") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la population en emploi entre le trimestre 2 et le trimestre 3, par sexe "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Population en emploi au trimestre 3"
putexcel (B3:E3), merge

*Ajout des modalités du sexe
putexcel B4 = "Masculin"
putexcel (B4:C4), merge

putexcel D4 = "Feminin"
putexcel (D4:E4), merge

*En tête ligne du Tableau
putexcel A4 = "Population en emploi au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close


/* Milieu de residence */

* Abidjan
mat define RESU_Abidjan = (.,.)
mat define RESU__Abidjan_1 = (.)
proportion pop_emp_t3 [pw=poids] if milieu_resid2_t2==1, over(pop_emp_t2)
mat list e(b)
mat RESU__Abidjan_1 = RESU__Abidjan_1 \ ((r(table)[rownumb(r(table), "b"), 1]*100)')

/* Combler les écarts*/
mat define RESU__Abidjan_2 = J(2, 1, .)
mat RESU__Abidjan = RESU__Abidjan_1, RESU__Abidjan_2

* Autre_Urbain
proportion pop_emp_t3 [pw=poids] if milieu_resid2_t2==2, over(pop_emp_t2)
mat list e(b)
mat define RESU__AutreUrbain = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')

* Rural
proportion pop_emp_t3 [pw=poids] if milieu_resid2_t2==3, over(pop_emp_t2)
mat list e(b)
mat define RESU__Rural = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')


** Agrégation
mat RESU = RESU__Abidjan, RESU__AutreUrbain, RESU__Rural

matrix rownames RESU = "Emploi présent" "Emploi absent"

matrix colnames RESU = "Emploi présent" "Emploi absent" "Emploi présent" "Emploi absent" "Emploi présent" "Emploi absent"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("pop_emp_residence") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la population en emploi entre le trimestre 2 et le trimestre 3, par milieu de résidence"
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Population en emploi au trimestre 3"
putexcel (B3:G3), merge

*Ajout des modalités du sexe
putexcel B4 = "Milieu - Abidjan"
putexcel (B4:C4), merge

putexcel D4 = "Milieu - Autre Urbain"
putexcel (D4:E4), merge

putexcel F4 = "Milieu - Rural"
putexcel (F4:G4), merge

*En tête ligne du Tableau
putexcel A4 = "Population en emploi au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close


/* Groupe d'Age */

* 16 - 24 ans
proportion pop_emp_t3 [pw=poids] if groupe_age4_t2==1, over(pop_emp_t2)
mat list e(b)
mat define RESU__16_24 = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')


* 25 - 35 ans
proportion pop_emp_t3 [pw=poids] if groupe_age4_t2==2, over(pop_emp_t2)
mat list e(b)
mat define RESU__25_35 = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')

* 35 - 64 ans
proportion pop_emp_t3 [pw=poids] if groupe_age4_t2==3, over(pop_emp_t2)
mat list e(b)
mat define RESU__35_64 = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')

* 65 ans et plus
proportion pop_emp_t3 [pw=poids] if groupe_age4_t2==4, over(pop_emp_t2)
mat list e(b)
mat define RESU__65_plus = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')


** Agrégation
mat RESU = RESU__16_24, RESU__25_35, RESU__35_64, RESU__65_plus

matrix rownames RESU = "Emploi présent" "Emploi absent"

matrix colnames RESU = "Emploi présent" "Emploi absent" "Emploi présent" "Emploi absent" "Emploi présent" "Emploi absent" "Emploi présent" "Emploi absent"


mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("pop_emp_grpe_age") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la population en emploi entre le trimestre 2 et le trimestre 3, par groupe d'âge "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Population en emploi au trimestre 3"
putexcel (B3:I3), merge

*Ajout des modalités du sexe
putexcel B4 = "16 - 24 ans"
putexcel (B4:C4), merge

putexcel D4 = "25 - 35 ans"
putexcel (D4:E4), merge

putexcel F4 = "36 - 64 ans"
putexcel (F4:G4), merge

putexcel H4 = "65 ans et plus"
putexcel (H4:I4), merge

*En tête ligne du Tableau
putexcel A4 = "Population en emploi au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close



/* 3.3. secteur institutionnel T3 x secteur institutionnel T2 */
/* Variables impliquées 
secteur_institutionnel_t2 : secteur institutionnel au trimestre 2
secteur_institutionnel_t3 : secteur institutionnel au trimestre 3
milieu_resid2 : Milieu de résidence à trois modalités
sexe_t2 : Sexe au trimestre 2 (censé être identique qu trimestre 3)
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG3 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/
		
/* par sexe  */


* Masculin
proportion secteur_institionnel2_t3 [pw=poids] if sexe_t2==1, over(secteur_institionnel2_t2)
mat list e(b)
mat define RESU__M = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')

* Feminin
proportion secteur_institionnel2_t3 [pw=poids] if sexe_t2==2, over(secteur_institionnel2_t2)
mat list e(b)
mat define RESU__F = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')

** Agrégation
mat RESU = RESU__M, RESU__F

matrix rownames RESU = "Public" "Privé" "Menage"

matrix colnames RESU = "Public" "Privé" "Menage" "Public" "Privé" "Menage"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("secteur_insti_sexe") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution du secteur institutionnel entre le trimestre 2 et le trimestre 3, par sexe "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Secteur institutionnel au trimestre 3"
putexcel (B3:G3), merge

*Ajout des modalités du sexe
putexcel B4 = "Masculin"
putexcel (B4:D4), merge

putexcel E4 = "Feminin"
putexcel (E4:G4), merge

*En tête ligne du Tableau
putexcel A4 = "Secteur institutionnel au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close



/* Milieu de residence */

* Abidjan
proportion secteur_institionnel2_t3 [pw=poids] if milieu_resid2_t2==1, over(secteur_institionnel2_t2)
mat list e(b)
mat define RESU__Abidjan = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)', (.,.)')
mat RESU__Abidjan = RESU__Abidjan \ (.,.,.)


* Autre_Urbain
proportion secteur_institionnel2_t3 [pw=poids] if milieu_resid2_t2==2, over(secteur_institionnel2_t2)
mat list e(b)
mat define RESU__AutreUrbain = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')

* Rural
proportion secteur_institionnel2_t3 [pw=poids] if milieu_resid2_t2==3, over(secteur_institionnel2_t2)
mat list e(b)
mat define RESU__Rural = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')


** Agrégation
mat RESU = RESU__Abidjan, RESU__AutreUrbain, RESU__Rural

matrix rownames RESU = "Public" "Privé" "Menage"

matrix colnames RESU = "Public" "Privé" "Menage" "Public" "Privé" "Menage" "Public" "Privé" "Menage"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("secteur_insti_residence") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution du secteur institutionnel entre le trimestre 2 et le trimestre 3, par milieu de résidence"
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Secteur institutionnel au trimestre 3"
putexcel (B3:J3), merge

*Ajout des modalités du sexe
putexcel B4 = "Milieu - Abidjan"
putexcel (B4:D4), merge

putexcel E4 = "Milieu - Autre Urbain"
putexcel (E4:G4), merge

putexcel H4 = "Milieu - Rural"
putexcel (H4:J4), merge

*En tête ligne du Tableau
putexcel A4 = "Secteur institutionnel au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

/* Groupe d'Age */

* 16 - 24 ans
proportion secteur_institionnel2_t3 [pw=poids] if groupe_age4_t2==1, over(secteur_institionnel2_t2)
mat list e(b)
mat define RESU__16_24 = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')


* 25 - 35 ans
proportion secteur_institionnel2_t3 [pw=poids] if groupe_age4_t2==2, over(secteur_institionnel2_t2)
mat list e(b)
mat define RESU__25_35 = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')

* 35 - 64 ans
proportion secteur_institionnel2_t3 [pw=poids] if groupe_age4_t2==3, over(secteur_institionnel2_t2)
mat list e(b)
mat define RESU__35_64 = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')

* 65 ans et plus
proportion secteur_institionnel2_t3 [pw=poids] if groupe_age4_t2==4, over(secteur_institionnel2_t2)
mat list e(b)
mat define RESU__65_plus = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (.,.)', (.,.)')
mat RESU__65_plus = RESU__65_plus \ (.,.,.)


** Agrégation
mat define RESU = RESU__16_24, RESU__25_35, RESU__35_64, RESU__65_plus

matrix rownames RESU = "Public" "Privé" "Menage"

matrix colnames RESU = "Public" "Privé" "Menage" "Public" "Privé" "Menage" "Public" "Privé" "Menage" "Public" "Privé" "Menage"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("secteur_insti_grpe_age") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution du secteur institutionnel entre le trimestre 2 et le trimestre 3, par groupe d'âge "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Secteur institutionnel au trimestre 3"
putexcel (B3:M3), merge

*Ajout des modalités du sexe
putexcel B4 = "16 - 24 ans"
putexcel (B4:D4), merge

putexcel E4 = "25 - 35 ans"
putexcel (E4:G4), merge

putexcel H4 = "36 - 64 ans"
putexcel (H4:J4), merge

putexcel K4 = "65 ans et plus"
putexcel (K4:M4), merge

*En tête ligne du Tableau
putexcel A4 = "Secteur institutionnel au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close






/* 3.3. Formalité de l'emploi T3 x Formalité de l'emploi T2 */
/* Variables impliquées 
secteur_institutionnel_t2 : Formalité de l'emploi au trimestre 2
secteur_institutionnel_t3 : Formalité de l'emploi au trimestre 3
milieu_resid2 : Milieu de résidence à trois modalités
sexe_t2 : Sexe au trimestre 2 (censé être identique qu trimestre 3)
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG3 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/
		
/* par sexe  */


* Masculin
proportion form_empEP_t3 [pw=poids] if sexe_t2==1, over(form_empEP_t2)
mat list e(b)
mat define RESU__M = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')

* Feminin
proportion form_empEP_t3 [pw=poids] if sexe_t2==2, over(form_empEP_t2)
mat list e(b)
mat define RESU__F = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')

** Agrégation
mat RESU = RESU__M, RESU__F

matrix rownames RESU = "Emploi informel" "Emploi formel"

matrix colnames RESU = "Emploi informel" "Emploi formel" "Emploi informel" "Emploi formel"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("formalite_emp_sexe") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la formalité de l'emploi entre le trimestre 2 et le trimestre 3, par sexe "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Formalité de l'emploi au trimestre 3"
putexcel (B3:E3), merge

*Ajout des modalités du sexe
putexcel B4 = "Masculin"
putexcel (B4:C4), merge

putexcel D4 = "Feminin"
putexcel (D4:E4), merge

*En tête ligne du Tableau
putexcel A4 = "Formalité de l'emploi au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

/* Milieu de residence */

* Abidjan
proportion form_empEP_t3 [pw=poids] if milieu_resid2_t2==1, over(form_empEP_t2)
mat list e(b)
mat define RESU__Abidjan = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')


* Autre_Urbain
proportion form_empEP_t3 [pw=poids] if milieu_resid2_t2==2, over(form_empEP_t2)
mat list e(b)
mat define RESU__AutreUrbain = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')

* Rural
proportion form_empEP_t3 [pw=poids] if milieu_resid2_t2==3, over(form_empEP_t2)
mat list e(b)
mat define RESU__Rural = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')


** Agrégation
mat RESU = RESU__Abidjan, RESU__AutreUrbain, RESU__Rural

matrix rownames RESU = "Emploi informel" "Emploi formel"

matrix colnames RESU = "Emploi informel" "Emploi formel" "Emploi informel" "Emploi formel" "Emploi informel" "Emploi formel"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("formalite_emp_residence") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la formalité de l'emploi entre le trimestre 2 et le trimestre 3, par milieu de résidence"
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Formalité de l'emploi au trimestre 3"
putexcel (B3:G3), merge

*Ajout des modalités du sexe
putexcel B4 = "Milieu - Abidjan"
putexcel (B4:C4), merge

putexcel D4 = "Milieu - Autre Urbain"
putexcel (D4:E4), merge

putexcel F4 = "Milieu - Rural"
putexcel (F4:G4), merge

*En tête ligne du Tableau
putexcel A4 = "Formalité de l'emploi au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

/* Groupe d'Age */

* 16 - 24 ans
proportion form_empEP_t3 [pw=poids] if groupe_age4_t2==1, over(form_empEP_t2)
mat list e(b)
mat define RESU__16_24 = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')


* 25 - 35 ans
proportion form_empEP_t3 [pw=poids] if groupe_age4_t2==2, over(form_empEP_t2)
mat list e(b)
mat define RESU__25_35 = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')

* 35 - 64 ans
proportion form_empEP_t3 [pw=poids] if groupe_age4_t2==3, over(form_empEP_t2)
mat list e(b)
mat define RESU__35_64 = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')

* 65 ans et plus
proportion form_empEP_t3 [pw=poids] if groupe_age4_t2==4, over(form_empEP_t2)
mat list e(b)
mat define RESU__65_plus = ((r(table)[rownumb(r(table), "b"), 1..2]*100)', (r(table)[rownumb(r(table), "b"), 3..4]*100)')


** Agrégation
mat define RESU = RESU__16_24, RESU__25_35, RESU__35_64, RESU__65_plus

matrix rownames RESU = "Emploi informel" "Emploi formel"

matrix colnames RESU = "Emploi informel" "Emploi formel" "Emploi informel" "Emploi formel" "Emploi informel" "Emploi formel" "Emploi informel" "Emploi formel"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("formalite_emp_grpe_age") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la formalité de l'emploi entre le trimestre 2 et le trimestre 3, par groupe d'âge "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Formalité de l'emploi au trimestre 3"
putexcel (B3:I3), merge

*Ajout des modalités du sexe
putexcel B4 = "16 - 24 ans"
putexcel (B4:C4), merge

putexcel D4 = "25 - 35 ans"
putexcel (D4:E4), merge

putexcel F4 = "36 - 64 ans"
putexcel (F4:G4), merge

putexcel H4 = "65 ans et plus"
putexcel (H4:I4), merge

*En tête ligne du Tableau
putexcel A4 = "Formalité de l'emploi au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close




/* 3.3. Branche d'activité 1 T3 x Branche d'activité 1 T2 */
/* Variables impliquées 
branche1_t2 : branche d'activité au trimestre 2
branche1_t3 : branche d'activité au trimestre 3
milieu_resid2 : Milieu de résidence à trois modalités
sexe_t2 : Sexe au trimestre 2 (censé être identique qu trimestre 3)
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG3 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/
		
/* par sexe  */


* Masculin
proportion branche1_t3 [pw=poids] if sexe_t2==1, over(branche1_t2)
mat list e(b)
mat define RESU__M = ((r(table)[rownumb(r(table), "b"), 1..4]*100)', (r(table)[rownumb(r(table), "b"), 5..8]*100)', (r(table)[rownumb(r(table), "b"), 9..12]*100)', (r(table)[rownumb(r(table), "b"), 13..16]*100)')

* Feminin
proportion branche1_t3 [pw=poids] if sexe_t2==2, over(branche1_t2)
mat list e(b)
mat define RESU__F = ((r(table)[rownumb(r(table), "b"), 1..4]*100)', (r(table)[rownumb(r(table), "b"), 5..8]*100)', (r(table)[rownumb(r(table), "b"), 9..12]*100)', (r(table)[rownumb(r(table), "b"), 13..16]*100)')
** Agrégation
mat RESU = RESU__M, RESU__F

matrix rownames RESU = "Agriculture" "Industrie" "Commerce" "Autre service"

matrix colnames RESU = "Agriculture" "Industrie" "Commerce" "Autre service" "Agriculture" "Industrie" "Commerce" "Autre service"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("branche_desag_sexe") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la branche d'activité entre le trimestre 2 et le trimestre 3, par sexe "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Branche d'activité au trimestre 3"
putexcel (B3:I3), merge

*Ajout des modalités du sexe
putexcel B4 = "Masculin"
putexcel (B4:E4), merge

putexcel F4 = "Feminin"
putexcel (F4:I4), merge

*En tête ligne du Tableau
putexcel A4 = "Branche d'activité au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close


/* Milieu de residence */

* Abidjan
proportion branche1_t3 [pw=poids] if milieu_resid2_t2==1, over(branche1_t2)
mat list e(b)
mat define RESU__Abidjan = ((r(table)[rownumb(r(table), "b"), 1..4]*100)', (r(table)[rownumb(r(table), "b"), 5..8]*100)', (r(table)[rownumb(r(table), "b"), 9..12]*100)', (r(table)[rownumb(r(table), "b"), 13..16]*100)')


* Autre_Urbain
proportion branche1_t3 [pw=poids] if milieu_resid2_t2==2, over(branche1_t2)
mat list e(b)
mat define RESU__AutreUrbain = ((r(table)[rownumb(r(table), "b"), 1..4]*100)', (r(table)[rownumb(r(table), "b"), 5..8]*100)', (r(table)[rownumb(r(table), "b"), 9..12]*100)', (r(table)[rownumb(r(table), "b"), 13..16]*100)')

* Rural
proportion branche1_t3 [pw=poids] if milieu_resid2_t2==3, over(branche1_t2)
mat list e(b)
mat define RESU__Rural = ((r(table)[rownumb(r(table), "b"), 1..4]*100)', (r(table)[rownumb(r(table), "b"), 5..8]*100)', (r(table)[rownumb(r(table), "b"), 9..12]*100)', (r(table)[rownumb(r(table), "b"), 13..16]*100)')


** Agrégation
mat RESU = RESU__Abidjan, RESU__AutreUrbain, RESU__Rural

matrix rownames RESU = "Agriculture" "Industrie" "Commerce" "Autre service"

matrix colnames RESU = "Agriculture" "Industrie" "Commerce" "Autre service" "Agriculture" "Industrie" "Commerce" "Autre service" "Agriculture" "Industrie" "Commerce" "Autre service"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("branche_desag_residence") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la branche d'activité entre le trimestre 2 et le trimestre 3, par milieu de résidence"
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Branche d'activité au trimestre 3"
putexcel (B3:M3), merge

*Ajout des modalités du sexe
putexcel B4 = "Milieu - Abidjan"
putexcel (B4:E4), merge

putexcel F4 = "Milieu - Autre Urbain"
putexcel (F4:I4), merge

putexcel J4 = "Milieu - Rural"
putexcel (J4:M4), merge

*En tête ligne du Tableau
putexcel A4 = "Branche d'activité au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

/* Groupe d'Age */

* 16 - 24 ans
proportion branche1_t3 [pw=poids] if groupe_age4_t2==1, over(branche1_t2)
mat list e(b)
mat define RESU__16_24 = ((r(table)[rownumb(r(table), "b"), 1..4]*100)', (r(table)[rownumb(r(table), "b"), 5..8]*100)', (r(table)[rownumb(r(table), "b"), 9..12]*100)', (r(table)[rownumb(r(table), "b"), 13..16]*100)')


* 25 - 35 ans
proportion branche1_t3 [pw=poids] if groupe_age4_t2==2, over(branche1_t2)
mat list e(b)
mat define RESU__25_35 = ((r(table)[rownumb(r(table), "b"), 1..4]*100)', (r(table)[rownumb(r(table), "b"), 5..8]*100)', (r(table)[rownumb(r(table), "b"), 9..12]*100)', (r(table)[rownumb(r(table), "b"), 13..16]*100)')

* 35 - 64 ans
proportion branche1_t3 [pw=poids] if groupe_age4_t2==3, over(branche1_t2)
mat list e(b)
mat define RESU__35_64 = ((r(table)[rownumb(r(table), "b"), 1..4]*100)', (r(table)[rownumb(r(table), "b"), 5..8]*100)', (r(table)[rownumb(r(table), "b"), 9..12]*100)', (r(table)[rownumb(r(table), "b"), 13..16]*100)')

* 65 ans et plus
proportion branche1_t3 [pw=poids] if groupe_age4_t2==4, over(branche1_t2)
mat list e(b)
mat define RESU__65_plus = ((r(table)[rownumb(r(table), "b"), 1..4]*100)', (r(table)[rownumb(r(table), "b"), 5..8]*100)', (r(table)[rownumb(r(table), "b"), 9..12]*100)', (r(table)[rownumb(r(table), "b"), 13..16]*100)')

** Agrégation
mat define RESU = RESU__16_24, RESU__25_35, RESU__35_64, RESU__65_plus

matrix rownames RESU = "Agriculture" "Industrie" "Commerce" "Autre service"

matrix colnames RESU = "Agriculture" "Industrie" "Commerce" "Autre service" "Agriculture" "Industrie" "Commerce" "Autre service" "Agriculture" "Industrie" "Commerce" "Autre service" "Agriculture" "Industrie" "Commerce" "Autre service"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("branche_desag_grpe_age") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la branche d'activité entre le trimestre 2 et le trimestre 3, par groupe d'âge "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Branche d'activité au trimestre 3"
putexcel (B3:Q3), merge

*Ajout des modalités du sexe
putexcel B4 = "16 - 24 ans"
putexcel (B4:E4), merge

putexcel F4 = "25 - 35 ans"
putexcel (F4:I4), merge

putexcel J4 = "36 - 64 ans"
putexcel (J4:M4), merge

putexcel N4 = "65 ans et plus"
putexcel (N4:Q4), merge

*En tête ligne du Tableau
putexcel A4 = "Branche d'activité au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close



/* 3.3. Branche d'activité 2 T3 x Branche d'activité 2 T2 */
/* Variables impliquées 
branche2_t2 : branche d'activité au trimestre 2
branche2_t3 : branche d'activité au trimestre 3
milieu_resid2 : Milieu de résidence à trois modalités
sexe_t2 : Sexe au trimestre 2 (censé être identique qu trimestre 3)
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG3 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/
		
/* par sexe  */


* Masculin
proportion branche2_t3 [pw=poids] if sexe_t2==1, over(branche2_t2)
mat list e(b)
mat define RESU__M = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')

* Feminin
proportion branche2_t3 [pw=poids] if sexe_t2==2, over(branche2_t2)
mat list e(b)
mat define RESU__F = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')
** Agrégation
mat RESU = RESU__M, RESU__F

matrix rownames RESU = "Secteur primaire" "Secteur secondaire " "Secteur tertiaire"
matrix colnames RESU = "Secteur primaire" "Secteur secondaire " "Secteur tertiaire" "Secteur primaire" "Secteur secondaire " "Secteur tertiaire"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("branche_ag_sexe") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la branche d'activité entre le trimestre 2 et le trimestre 3, par sexe "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Branche d'activité au trimestre 3"
putexcel (B3:G3), merge

*Ajout des modalités du sexe
putexcel B4 = "Masculin"
putexcel (B4:D4), merge

putexcel E4 = "Feminin"
putexcel (E4:G4), merge

*En tête ligne du Tableau
putexcel A4 = "Branche d'activité au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

/* Milieu de residence */

* Abidjan
proportion branche2_t3 [pw=poids] if milieu_resid2_t2==1, over(branche2_t2)
mat list e(b)
mat define RESU__Abidjan = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')


* Autre_Urbain
proportion branche2_t3 [pw=poids] if milieu_resid2_t2==2, over(branche2_t2)
mat list e(b)
mat define RESU__AutreUrbain = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')

* Rural
proportion branche2_t3 [pw=poids] if milieu_resid2_t2==3, over(branche2_t2)
mat list e(b)
mat define RESU__Rural = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')


** Agrégation
mat RESU = RESU__Abidjan, RESU__AutreUrbain, RESU__Rural

matrix rownames RESU = "Secteur primaire" "Secteur secondaire " "Secteur tertiaire"
matrix colnames RESU = "Secteur primaire" "Secteur secondaire " "Secteur tertiaire" "Secteur primaire" "Secteur secondaire " "Secteur tertiaire" "Secteur primaire" "Secteur secondaire " "Secteur tertiaire"

mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("branche_ag_residence") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la branche d'activité entre le trimestre 2 et le trimestre 3, par milieu de résidence"
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Branche d'activité au trimestre 3"
putexcel (B3:J3), merge

*Ajout des modalités du sexe
putexcel B4 = "Milieu - Abidjan"
putexcel (B4:D4), merge

putexcel E4 = "Milieu - Autre Urbain"
putexcel (E4:G4), merge

putexcel H4 = "Milieu - Rural"
putexcel (H4:J4), merge

*En tête ligne du Tableau
putexcel A4 = "Branche d'activité au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

/* Groupe d'Age */

* 16 - 24 ans
proportion branche2_t3 [pw=poids] if groupe_age4_t2==1, over(branche2_t2)
mat list e(b)
mat define RESU__16_24 = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')


* 25 - 35 ans
proportion branche2_t3 [pw=poids] if groupe_age4_t2==2, over(branche2_t2)
mat list e(b)
mat define RESU__25_35 = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')

* 35 - 64 ans
proportion branche2_t3 [pw=poids] if groupe_age4_t2==3, over(branche2_t2)
mat list e(b)
mat define RESU__35_64 = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')

* 65 ans et plus
proportion branche2_t3 [pw=poids] if groupe_age4_t2==4, over(branche2_t2)
mat list e(b)
mat define RESU__65_plus = ((r(table)[rownumb(r(table), "b"), 1..3]*100)', (r(table)[rownumb(r(table), "b"), 4..6]*100)', (r(table)[rownumb(r(table), "b"), 7..9]*100)')

** Agrégation
mat define RESU = RESU__16_24, RESU__25_35, RESU__35_64, RESU__65_plus

matrix rownames RESU = "Secteur primaire" "Secteur secondaire " "Secteur tertiaire"

matrix rownames RESU = "Secteur primaire" "Secteur secondaire " "Secteur tertiaire"
matrix colnames RESU = "Secteur primaire" "Secteur secondaire " "Secteur tertiaire" "Secteur primaire" "Secteur secondaire " "Secteur tertiaire" "Secteur primaire" "Secteur secondaire " "Secteur tertiaire" "Secteur primaire" "Secteur secondaire " "Secteur tertiaire"
mat list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Croisement.xlsx", sheet("branche_desag_grpe_age") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Évolution de la branche d'activité entre le trimestre 2 et le trimestre 3, par groupe d'âge "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Branche d'activité au trimestre 3"
putexcel (B3:M3), merge

*Ajout des modalités du sexe
putexcel B4 = "16 - 24 ans"
putexcel (B4:D4), merge

putexcel E4 = "25 - 35 ans"
putexcel (E4:G4), merge

putexcel H4 = "36 - 64 ans"
putexcel (H4:J4), merge

putexcel K4 = "65 ans et plus"
putexcel (K4:M4), merge

*En tête ligne du Tableau
putexcel A4 = "Branche d'activité au trimestre 2"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close