clear    
cls

/**************************************************************************************/
			*Tabulation du Bulletin Trimestriel*
/**************************************************************************************/


/**************************************************************************************/
/* 0. DESCRIPTION DU DO FILE */
/**************************************************************************************/

*Cette syntaxe permet de construire les tableaux du 
*Bulletin Trimestriel

*Dossiers de Travail :
	* - Principal : Refonte Enquête Emploi_ Equipe Technique - Fichiers\1_Composante_Menages\12_Operation_pilote\Double_passage\Passage2\Analyse
	* - Sous-Dossier Actif : Bulletin_Trimestriel

*Input: 
	* - Base Apurée Menage : Base_menage.dta
	* - Base Apurée Individu : Base_Individu_VF.dta
	* - Do File de creation des variables objectives : Var_objectives_to_run.do
	* - Do File de creation des indicateurs : Indicateur_Bulletin_To_Run.do
	* - Plan de Tabulation en version excel : Analyse\Plan_tabulation\Plan_tabulation_bulletin_trimestriel_VF.xlsx
	
*Output : 
	* - Dossier Résultat : Analyse\Bulletin_Trimestriel\Resultats_Tab
	* - Serie de fichiers excel non listés contenus dans le dossier Resultat_Tab à raison d'un fichier excel par tableau
							
/***************************************************************************************/

//ATTENTION, nous avons retirer les branches d'activités dans la repartition des indicateurs car la variables sur les branches d'activité n'existe pas encore dans les données actuelles à l'état non apurée
 
/**************************************************************************************/
/* 1. DEFINITION / CREATION DES DOSSIERS DE TRAVAIL */
/**************************************************************************************/
 
/* Définition du dossier de travail principal - Analyse*/

global Pilote_Analyse    = "C:\ENE-M_T3_2024\Bulletin_Trimestriel"

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
/**************************************************************************************/
/* 2. SELECTION DES BASES DE TRAVAIL ET TRAVAUX PRELIMINAIRES */
/**************************************************************************************/

/* Selection de la base de travail */

// Pour ces travaux nous utiliserons la base individu  (base fusionée et apurée)
use "${Base}\membres_valide.dta", clear
cap drop _merge
// En raison de l'absence de certaines variables clés comme la région le département le milieu de residence, nous effectuons une fusion avec les données ménages afin de récupérer ces variables
merge m:1 interview__key using "${Base}\qx_eec_vf_valide_poids.dta", keepusing(HH1 HH2 HH3 HH4 HH6 HH8 HH8A HH7 HH8B rghab rgmen V1MODINTR trimestreencours mois annee Reference Date1 anneeScolairePassee anneeScolaireEnCours HH9 HH9_1  V1interviewkey V1hha MODINTR L1 L3 L4 L5)


keep if _merge==3

gen trimestre = "T3"

do "${Do}\Codification.do" 

append using "${Base}\individu.dta"

drop if missing(poids_men_vf)


replace trimestre = "T2" if trimestre == ""


*drop if inlist(M5,.,.a) // Suppression si le sexe de l'individu est absent ou s'il est un visiteur
*drop if inlist(AgeAnnee,.,.a,-9998) // suppression des ages incoherents. A mettre en commentaire quand les bases seront appurées
*drop if AgeAnnee > 105 // // suppression des ages incoherents. A mettre en commentaire quand les bases seront appurées

*tab _merge // revoir: car certains individus n'ont pas de lien au niveau menages.
*keep if _merge==3 //revoir

// definition des poids

svyset [pw=poids_men_vf]


/* Préambule */

// Creation des variables objectives (variables de croisement, sous-variables clées, etc.)
do "${Do}\1_1_Var_objectives_to_run.do", nostop

// Creation des indicateurs du bulletin trimestriel 
do "${Do}\1_2_Indicateur_Bulletin_To_Run.do", nostop

// Creation des indicateurs du bulletin trimestriel 
*do "${Do}\Bulletin_trimestriel.do", nostop

// Creation des indicateurs de la CISE_18 
do "${Do}\Revision_CISE_12112024.do", nostop

// Sauvegarde d'une base temporaire de travail

save "${BT_Temp}\Base_Travail_BT.dta", replace	

*do "${Do}\Codification.do"

/**************************************************************************************/
/* 3. CREATION DES TABLEAUX */
/**************************************************************************************/
/* 3.1. Population en âge de travailler */

		*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/

/* Colonne des effectifs */

**T3
mat define RESU = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
total i.PAT [pw=poids_men_vf] if trimestre =="T3" , over(milieu_resid2)  
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),4..6])'


/* Sexe */
mat RESU = RESU \ (.)
total i.PAT [pw=poids_men_vf] if trimestre =="T3", over(sexe) 
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),3..4]')

/* Niveau d'instruction */
mat RESU = RESU \ (.)
total i.PAT [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG3)
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),6..10])'

/* Ensemble */
total i.PAT [pw=poids_men_vf] if trimestre =="T3"
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),2])'

**T2
mat define RESU_ = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
total i.PAT [pw=poids_men_vf] if trimestre =="T2" , over(milieu_resid2)  
mat list e(b)
mat RESU_ = RESU_ \ (r(table)[rownumb(r(table),"b"),4..6])'


/* Sexe */
mat RESU_ = RESU_ \ (.)
total i.PAT [pw=poids_men_vf] if trimestre =="T2", over(sexe) 
mat list e(b)
mat RESU_ = RESU_ \ (r(table)[rownumb(r(table),"b"),3..4]')

/* Niveau d'instruction */
mat RESU_ = RESU_ \ (.)
total i.PAT [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG3)
mat list e(b)
mat RESU_ = RESU_ \ (r(table)[rownumb(r(table),"b"),6..10])'

/* Ensemble */
total i.PAT [pw=poids_men_vf] if trimestre =="T2"
mat list e(b)
mat RESU_ = RESU_ \ (r(table)[rownumb(r(table),"b"),2])'
		
/* Colonne pourcentage profil colonne */
**T3
mat define RESU1 = (.)  //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion milieu_resid2  [pw=poids_men_vf] if age >= 16 & trimestre =="T3", over(PAT) 
mat list e(b)
*mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),1] * 100),(r(table)[rownumb(r(table),"b"),2] * 100)',(r(table)[rownumb(r(table),"b"),3] * 100))'

mat RESU1 = RESU1 \ (e(b)*100)'
/* Sexe */
mat RESU1 = RESU1 \ (.)
proportion sexe [pw=poids_men_vf] if age >= 16 & trimestre =="T3", over(PAT) 
mat list e(b)
*mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100))'

mat RESU1 = RESU1 \ (e(b)*100)'

/* Niveau d'Instruction */
mat RESU1 = RESU1 \ (.)
proportion Niv_inst_AG3 [pw=poids_men_vf] if age >= 16 &  trimestre =="T3", over(PAT)
mat list e(b)
*mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100),(r(table)[rownumb(r(table),"b"),10] * 100))'

mat RESU1 = RESU1 \ (e(b)*100)'

/* Ensemble */
proportion 1.PAT [pw=poids_men_vf] if trimestre =="T3"
mat list e(b)
*mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),2] * 100)')

mat RESU1 = RESU1 \ (e(b)*100)'

**T2
mat define RESU1_ = (.)  //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion milieu_resid2  [pw=poids_men_vf] if age >= 16 & trimestre =="T2", over(PAT) 
mat list e(b)
*mat RESU1_ = RESU1_ \ ((r(table)[rownumb(r(table),"b"),1] * 100),(r(table)[rownumb(r(table),"b"),2] * 100)',(r(table)[rownumb(r(table),"b"),3] * 100))'

mat RESU1_ = RESU1_ \ (e(b)*100)'
/* Sexe */
mat RESU1_ = RESU1_ \ (.)
proportion sexe [pw=poids_men_vf] if age >= 16 & trimestre =="T2", over(PAT) 
mat list e(b)
*mat RESU1_ = RESU1_ \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100))'

mat RESU1_ = RESU1_ \ (e(b)*100)'

/* Niveau d'Instruction */
mat RESU1_ = RESU1_ \ (.)
proportion Niv_inst_AG3 [pw=poids_men_vf] if age >= 16 & trimestre =="T2", over(PAT)
mat list e(b)
*mat RESU1_ = RESU1_ \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100),(r(table)[rownumb(r(table),"b"),10] * 100))'

mat RESU1_ = RESU1_ \ (e(b)*100)'

/* Ensemble */
proportion 1.PAT [pw=poids_men_vf] if trimestre =="T2"
mat list e(b)
*mat RESU1_ = RESU1_ \ ((r(table)[rownumb(r(table),"b"),2] * 100)')

mat RESU1_ = RESU1_ \ (e(b)*100)'

/* Colonne pourcentage profil ligne */
**T3
mat define RESU2 = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion 1.PAT  [pw=poids_men_vf] if trimestre =="T3", over(milieu_resid2) 
mat list e(b)
mat RESU2 = RESU2 \ (e(b)* 100)'

/* Sexe */
mat RESU2 = RESU2 \ (.)
proportion 1.PAT [pw=poids_men_vf] if trimestre =="T3", over(sexe) 
mat list e(b)
mat RESU2 = RESU2 \ (e(b)* 100)'

/* Niveau d'Instruction */
mat RESU2 = RESU2 \ (.)
proportion 1.PAT [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG3)
mat list e(b)
mat RESU2 = RESU2 \ (e(b)* 100)'

/* Ensemble */
proportion 1.PAT [pw=poids_men_vf] if trimestre =="T3"
mat list e(b)
mat RESU2 = RESU2 \ (e(b)* 100)'

**T2
mat define RESU2_ = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion 1.PAT  [pw=poids_men_vf] if trimestre =="T2", over(milieu_resid2) 
mat list e(b)
mat RESU2_ = RESU2_ \ (e(b)* 100)'

/* Sexe */
mat RESU2_ = RESU2_ \ (.)
proportion 1.PAT [pw=poids_men_vf] if trimestre =="T2", over(sexe) 
mat list e(b)
mat RESU2_ = RESU2_ \ (e(b)* 100)'

/* Niveau d'Instruction */
mat RESU2_ = RESU2_ \ (.)
proportion 1.PAT [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG3)
mat list e(b)
mat RESU2_ = RESU2_ \ (e(b)* 100)'

/* Ensemble */
proportion 1.PAT [pw=poids_men_vf] if trimestre =="T2"
mat list e(b)
mat RESU2_ = RESU2_ \ (e(b)* 100)'

/* fusion des colonnes  */

mat RESU = RESU_, RESU, RESU2_, RESU2, RESU1_, RESU1


		*b. Mise en forme du Tableau 
		/*---------------------------*/
	
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = "Milieu de Residence" "Abidjan" "Autre Urbain" "Rural" "Sexe" "Masculin" "Feminin"  "Niveau d'Instruction"  "Aucun" "Primaire" "Secondaire  1er Cycle" "Secondaire  2nd Cycle" "Superieure" "Ensemble"

*Colonnes 

matrix colnames RESU = "Effectif T2" "Effectif T3" "(% profil ligne T2)" "(% profil ligne T3)" "(% profil colonne T2)" "(% profil colonne T3)"

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Pop_age_travail") modify



putexcel B5 = matrix(RESU[1..14,1..2]), nformat(number_d2)

putexcel save
putexcel close





/* Mise en forme */
putexcel B4 = matrix(RESU), colnames  nformat(number_d2)
putexcel A5 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau 1  : Répartition de la population en âge de travailler selon les caractéristiques des individus"
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Population en âge de travailler"
putexcel (B3:C3), merge

*En tête ligne du Tableau
putexcel A3 = "Caractéristiques Socio Demographiques"

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close


/* 3.2. Population en âge de travailler */

/* 3.3. Population au chômage */
/* Variables impliquées 
SU1 : emplois vulnérables
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG3 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/
		
/* 3.2. Population au chomage */

/* Colonne des effectifs */

**T3

mat define RESU1 = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
total i.SU1 [pw=poids_men_vf] if trimestre == "T3", over(milieu_resid2) 
mat list e(b)
mat RESU1 = RESU1 \ (r(table)[rownumb(r(table),"b"),4..6])'

/* Sexe */
mat RESU1 = RESU1 \ (.)
total i.SU1 [pw=poids_men_vf] if trimestre == "T3", over(sexe) 
mat list e(b)
mat RESU1 = RESU1 \ (r(table)[rownumb(r(table),"b"),3..4]')

/*Groupe d'Age */
mat RESU1 = RESU1 \ (.)
total i.SU1 [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4)
mat list e(b)
mat RESU1 = RESU1 \ (r(table)[rownumb(r(table),"b"),5..8] )'

/* Niveau d'instruction */
mat RESU1 = RESU1 \ (.)
total i.SU1 [pw=poids_men_vf] if trimestre == "T3", over(Niv_inst_AG3)
mat list e(b)
mat RESU1 = RESU1 \ (r(table)[rownumb(r(table),"b"),6..10])'

/* Ensemble */
total i.SU1 [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU1 = RESU1 \ (r(table)[rownumb(r(table),"b"),2])'

mat RESU = RESU1

**T2

mat define RESU1_ = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
total i.SU1 [pw=poids_men_vf] if trimestre == "T2", over(milieu_resid2) 
mat list e(b)
mat RESU1_ = RESU1_ \ (r(table)[rownumb(r(table),"b"),4..6])'

/* Sexe */
mat RESU1_ = RESU1_ \ (.)
total i.SU1 [pw=poids_men_vf] if trimestre == "T2", over(sexe) 
mat list e(b)
mat RESU1_ = RESU1_ \ (r(table)[rownumb(r(table),"b"),3..4]')

/*Groupe d'Age */
mat RESU1_ = RESU1_ \ (.)
total i.SU1 [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4)
mat list e(b)
mat RESU1_ = RESU1_ \ (r(table)[rownumb(r(table),"b"),5..8] )'

/* Niveau d'instruction */
mat RESU1_ = RESU1_ \ (.)
total i.SU1 [pw=poids_men_vf] if trimestre == "T2", over(Niv_inst_AG3)
mat list e(b)
mat RESU1_ = RESU1_ \ (r(table)[rownumb(r(table),"b"),6..10])'

/* Ensemble */
total i.SU1 [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU1_ = RESU1_ \ (r(table)[rownumb(r(table),"b"),2])'

mat RESU_ = RESU1_

/* Colonne pourcentage ligne */
**T3
mat define RESU1 = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion 1.SU1 [pw=poids_men_vf] if age >= 16 & trimestre == "T3" , over(milieu_resid2) 
mat list e(b)

mat RESU1 = RESU1 \ e(b)'*100

/* Sexe */
mat RESU1 = RESU1 \ (.)
proportion 1.SU1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(sexe) 
mat list e(b)
mat RESU1 = RESU1 \ e(b)'*100


/*Groupe d'Age */
mat RESU1 = RESU1 \ (.)
proportion 1.SU1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4)
mat list e(b)
mat RESU1 = RESU1 \ e(b)'*100

/* Niveau d'Instruction */
mat RESU1 = RESU1 \ (.)
proportion 1.SU1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(Niv_inst_AG3)
mat list e(b)
mat RESU1 = RESU1 \ e(b)'*100

/* Ensemble */
proportion 1.SU1 [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU1 = RESU1 \ e(b)'*100

**T2
mat define RESU1_ = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion 1.SU1 [pw=poids_men_vf] if age >= 16 & trimestre == "T2" , over(milieu_resid2) 
mat list e(b)

mat RESU1_ = RESU1_ \ e(b)'*100

/* Sexe */
mat RESU1_ = RESU1_ \ (.)
proportion 1.SU1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(sexe) 
mat list e(b)
mat RESU1_ = RESU1_ \ e(b)'*100


/*Groupe d'Age */
mat RESU1_ = RESU1_ \ (.)
proportion 1.SU1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4)
mat list e(b)
mat RESU1_ = RESU1_ \ e(b)'*100

/* Niveau d'Instruction */
mat RESU1_ = RESU1_ \ (.)
proportion 1.SU1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(Niv_inst_AG3)
mat list e(b)
mat RESU1_ = RESU1_ \ e(b)'*100

/* Ensemble */
proportion 1.SU1 [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU1_ = RESU1_ \ e(b)'*100

		
/* Colonne pourcentage profil colonne */
**T3
mat define RESU2 = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion milieu_resid2  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(SU1) 
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100))'

/* Sexe */
mat RESU2 = RESU2 \ (.)
proportion sexe [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(SU1) 
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100))'

/*Groupe d'Age */
mat RESU2 = RESU2 \ (.)
proportion groupe_age4 [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(SU1)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100))'
/* Niveau d'Instruction */
mat RESU2 = RESU2 \ (.)
proportion Niv_inst_AG3 [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(SU1)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100),(r(table)[rownumb(r(table),"b"),10] * 100))'
/* Ensemble */
proportion SU1 [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),2] * 100)')

**T2
mat define RESU2_ = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion milieu_resid2  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(SU1) 
mat list e(b)
mat RESU2_ = RESU2_ \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100))'

/* Sexe */
mat RESU2_ = RESU2_ \ (.)
proportion sexe [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(SU1) 
mat list e(b)
mat RESU2_ = RESU2_ \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100))'

/*Groupe d'Age */
mat RESU2_ = RESU2_ \ (.)
proportion groupe_age4 [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(SU1)
mat list e(b)
mat RESU2_ = RESU2_ \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100))'
/* Niveau d'Instruction */
mat RESU2_ = RESU2_ \ (.)
proportion Niv_inst_AG3 [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(SU1)
mat list e(b)
mat RESU2_ = RESU2_ \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100),(r(table)[rownumb(r(table),"b"),10] * 100))'
/* Ensemble */
proportion SU1 [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU2_ = RESU2_ \ ((r(table)[rownumb(r(table),"b"),2] * 100)')

/* Fusion des deux colonnes */

mat RESU = RESU_, RESU, RESU1_, RESU1, RESU2_, RESU2


		*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = "Milieu de Residence" "Abidjan" "Autre Urbain" "Rural" "Sexe" "Masculin" "Feminin" "Groupe d'Age" "16-24 ans" "25-35 ans" "36-64 ans" "65 ans et plus"  "Niveau d'Instruction"  "Aucun" "Primaire" "Secondaire  1er Cycle" "Secondaire  2nd Cycle" "Superieur" "Ensemble"

*Colonnes 

matrix colnames RESU = "Effectif T2" "Effectif T3" "(% Profil Ligne T2)" "(% Profil Ligne T3)" "(% Profil Colonne T2)" "(% Profil Colonne T3)"

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Pop_au_chomage") modify
/* Mise en forme */
putexcel B4 = matrix(RESU), colnames  nformat(number_d2)
putexcel A5 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Répartition de la population au chômage selon les caractéristiques des individus "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Population au chômage"
putexcel (B3:C3), merge

*En tête ligne du Tableau
putexcel A3 = "Caractéristiques Socio Demographiques"
putexcel (A3:A4), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

/* DEBUT */

/* 3.x. Sous-Utilisation de la main d'oeuvre */

/* Variables impliquées 
SU1 : 
SU2 : 
SU3 : 
SU4 :
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG3 : Niveau d'instruction en 5 modalités
*/

************ Matrice profil colonnes

**T3

local i = 0
local SU SU1 SU2 SU3 SU4
foreach SU in SU1 SU2 SU3 SU4 {
local i = `i' + 1
dis `i'
dis "`SU'"

mat define RESU`i' = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion milieu_resid2  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(`SU') 
mat list e(b)
mat RESU`i' = RESU`i' \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100))'

/* Sexe */
mat RESU`i' = RESU`i' \ (.)
proportion sexe [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(`SU') 
mat list e(b)
mat RESU`i' = RESU`i' \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100))'

/*Groupe d'Age */
mat RESU`i' = RESU`i' \ (.)
proportion groupe_age4 [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(`SU')
mat list e(b)
mat RESU`i' = RESU`i' \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100))'
/* Niveau d'Instruction */
mat RESU`i' = RESU`i' \ (.)
proportion Niv_inst_AG3 [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(`SU')
mat list e(b)
mat RESU`i' = RESU`i' \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100),(r(table)[rownumb(r(table),"b"),10] * 100))'
/* Ensemble */
proportion `SU' [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU`i' = RESU`i' \ ((r(table)[rownumb(r(table),"b"),2] * 100)')
}

**T2

local i = 0
local SU SU1 SU2 SU3 SU4
foreach SU in SU1 SU2 SU3 SU4 {
local i = `i' + 1
dis `i'
dis "`SU'"

mat define RESU_`i' = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion milieu_resid2  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(`SU') 
mat list e(b)
mat RESU_`i' = RESU_`i' \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100))'

/* Sexe */
mat RESU_`i' = RESU_`i' \ (.)
proportion sexe [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(`SU') 
mat list e(b)
mat RESU_`i' = RESU_`i' \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100))'

/*Groupe d'Age */
mat RESU_`i' = RESU_`i' \ (.)
proportion groupe_age4 [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(`SU')
mat list e(b)
mat RESU_`i' = RESU_`i' \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100))'
/* Niveau d'Instruction */
mat RESU_`i' = RESU_`i' \ (.)
proportion Niv_inst_AG3 [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(`SU')
mat list e(b)
mat RESU_`i' = RESU_`i' \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100),(r(table)[rownumb(r(table),"b"),10] * 100))'
/* Ensemble */
proportion `SU' [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU_`i' = RESU_`i' \ ((r(table)[rownumb(r(table),"b"),2] * 100)')
}

/* Fusion des colonnes */

mat RESU_colonne = RESU1,RESU2,RESU3,RESU4,RESU_1,RESU_2,RESU_3,RESU_4


************ Matrice profil ligne

**T3
local i = 4
local SU SU1 SU2 SU3 SU4
foreach SU in SU1 SU2 SU3 SU4 {
local i = `i' + 1
dis `i'
dis "`SU'"

mat define RESU`i' = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion 1.`SU' [pw=poids_men_vf] if age >= 16 & trimestre == "T3" , over(milieu_resid2) 
mat list e(b)
mat RESU`i' = RESU`i' \ e(b)'*100

/* Sexe */
mat RESU`i' = RESU`i' \ (.)
proportion 1.`SU' [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(sexe) 
mat list e(b)
mat RESU`i' = RESU`i' \ e(b)'*100

/*Groupe d'Age */
mat RESU`i' = RESU`i' \ (.)
proportion 1.`SU' [pw=poids_men_vf] if age >= 16 & trimestre == "T3" , over(groupe_age4)
mat list e(b)
mat RESU`i' = RESU`i' \ e(b)'*100

/* Niveau d'Instruction */
mat RESU`i' = RESU`i' \ (.)
proportion 1.`SU' [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(Niv_inst_AG3)
mat list e(b)
mat RESU`i' = RESU`i' \ e(b)'*100

/* Ensemble */
proportion 1.`SU' [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU`i' = RESU`i' \ e(b)'*100
}

**T2
local i = 4
local SU SU1 SU2 SU3 SU4
foreach SU in SU1 SU2 SU3 SU4 {
local i = `i' + 1
dis `i'
dis "`SU'"

mat define RESU_`i' = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion 1.`SU' [pw=poids_men_vf] if age >= 16 & trimestre == "T2" , over(milieu_resid2) 
mat list e(b)
mat RESU_`i' = RESU_`i' \ e(b)'*100

/* Sexe */
mat RESU_`i' = RESU_`i' \ (.)
proportion 1.`SU' [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(sexe) 
mat list e(b)
mat RESU_`i' = RESU_`i' \ e(b)'*100

/*Groupe d'Age */
mat RESU_`i' = RESU_`i' \ (.)
proportion 1.`SU' [pw=poids_men_vf] if age >= 16 & trimestre == "T2" , over(groupe_age4)
mat list e(b)
mat RESU_`i' = RESU_`i' \ e(b)'*100

/* Niveau d'Instruction */
mat RESU_`i' = RESU_`i' \ (.)
proportion 1.`SU' [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(Niv_inst_AG3)
mat list e(b)
mat RESU_`i' = RESU_`i' \ e(b)'*100

/* Ensemble */
proportion 1.`SU' [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU_`i' = RESU_`i' \ e(b)'*100
}



/* Fusion des colonnes */

mat RESU_ligne = RESU5,RESU6,RESU7,RESU8,RESU_5,RESU_6,RESU_7,RESU_8

****Matrice sous_utilisation finale

mat RESU= RESU_5,RESU_1,  RESU5,RESU1, RESU_6,RESU_2,  RESU6,RESU2, RESU_7,RESU_3, RESU7,RESU3, RESU_8,RESU_4, RESU8,RESU4

		*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = "Milieu de Residence" "Abidjan" "Autre Urbain" "Rural" "Sexe" "Masculin" "Feminin" "Groupe d'Age" "16-24 ans" "25-35 ans" "36-64 ans" "65 ans et plus"  "Niveau d'Instruction"  "Aucun" "Primaire" "Secondaire  1er Cycle" "Secondaire  2nd Cycle" "Superieure" "Ensemble"

*Colonnes 

matrix colnames RESU = "(% Profil Ligne T2)" "(% Profil Colonne T2)" "(% Profil Ligne T3)" "(% Profil Colonne T3)" "(% Profil Ligne T2)" "(% Profil Colonne T2)" "(% Profil Ligne T3)" "(% Profil Colonne T3)" "(% Profil Ligne T2)" "(% Profil Colonne T2)"  "(% Profil Ligne T3)" "(% Profil Colonne T3)" "(% Profil Ligne T2)" "(% Profil Colonne T2)" "(% Profil Ligne T3)" "(% Profil Colonne T3)"   

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Sous_utilisation") modify

//putexcel set "${Resultats_Tab}\Tableau_Sous_Utilisation_Main_d_oeuvre", replace

/* Mise en forme */
putexcel B4 = matrix(RESU), colnames  nformat(number_d2)
putexcel A5 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Répartition des indicateurs d'analyse de la sous-utilisation de la main d'œuvre par caractéristiques socio-démographiques"
putexcel B1, bold border(bottom)


putexcel B3="Taux de chômage T3"
putexcel(B3:C3), merge

putexcel D3="Taux de chômage T2"
putexcel(D3:E3), merge

putexcel F3="SU2 T3"
putexcel(F3:G3), merge

putexcel H3="SU2 T2"
putexcel(H3:I3), merge

putexcel J3="SU3 T3"
putexcel(J3:K3), merge

putexcel L3="SU3 T2"
putexcel(L3:M3), merge

putexcel N3="SU4 T3"
putexcel(N3:O3), merge

putexcel P3="SU4 T2"
putexcel(P3:Q3), merge



*En tête ligne du Tableau
putexcel A3 = "Caractéristiques Socio Demographiques"
putexcel (A3:A4), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

/* FIN */


/* 3.x. Proportion d'emplois vulnérables selon les caractéristiques des individus */

/* Variables impliquées 
emp_vul : emplois vulnérables
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG3 : Niveau d'instruction en 5 modalités
*/

		*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/


/* Colonne */

/* DEBUT */

/* 3.x. Proportion d'emplois vulnérables selon les caractéristiques des individus */

/* Variables impliquées 
emp_vul : emplois vulnérables
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG3 : Niveau d'instruction en 5 modalités
*/

		*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/

*T3

/* Colonne */

mat define RESU = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion emp_vul  [pw=poids_men_vf] if age >= 16 & trimestre == "T3" , over(milieu_resid2) 
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),4..6] * 100)')

/* Sexe */
mat RESU = RESU \ (.)
proportion emp_vul [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(sexe) 
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),3..4] * 100)')

/*Groupe d'Age */
mat RESU = RESU \ (.)
proportion emp_vul [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4)
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),5..8] * 100)')

/* Niveau d'Instruction */
mat RESU = RESU \ (.)
proportion emp_vul [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(Niv_inst_AG3)
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),6..10] * 100)')


/* Ensemble */
proportion emp_vul [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),2] * 100)')

*T2

/* Colonne */

mat define RESU_ = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion emp_vul  [pw=poids_men_vf] if age >= 16 & trimestre == "T2" , over(milieu_resid2) 
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),4..6] * 100)')

/* Sexe */
mat RESU_ = RESU_ \ (.)
proportion emp_vul [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(sexe) 
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),3..4] * 100)')

/*Groupe d'Age */
mat RESU_ = RESU_ \ (.)
proportion emp_vul [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4)
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),5..8] * 100)')

/* Niveau d'Instruction */
mat RESU_ = RESU_ \ (.)
proportion emp_vul [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(Niv_inst_AG3)
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),6..10] * 100)')


/* Ensemble */
proportion emp_vul [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),2] * 100)')


****Matrice sous_utilisation finale

mat RESU= RESU_ , RESU
		*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = "Milieu de Residence" "Abidjan" "Autre Urbain" "Rural" "Sexe" "Masculin"  "Feminin" "Groupe d'Age" "16-24 ans" "25-35 ans" "36-64 ans" "65 ans et plus"  "Niveau d'Instruction"  "Aucun" "Primaire" "Secondaire  1er Cycle" "Secondaire  2nd Cycle" "Superieure" "Ensemble"

*Colonnes 

matrix colnames RESU = "Pourcentage (%) T2" "Pourcentage (%) T3"

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Emploi_vulnerable") modify
//putexcel set "${Resultats_Tab}\Tableau_Emploi_Vulnerable", replace

/* Mise en forme */
putexcel B4 = matrix(RESU), colnames  nformat(number_d2)
putexcel A5 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Proportion  d'emploi vulnérable selon les caractéristiques des individus"
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Proportion d'Emploi vulnérable (%)"
putexcel (B3:D3), merge

*En tête ligne du Tableau
putexcel A3 = "Caractéristiques Socio Demographiques"
putexcel (A3:A4), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

/* Fin */




/* 3.x. Répartition de l'emploi par nature selon les caractéristiques */

/* Variables impliquées 
form_empEP : Formalité de l'emploi principal
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG3 : Niveau d'instruction en 5 modalités
*/

		*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/

/* Colonne */
**T3
mat define RESU = (.,.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion form_empEP  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(milieu_resid2) 
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1..3] * 100)',(r(table)[rownumb(r(table),"b"),4..6] * 100)')

/* Sexe */
mat RESU = RESU \ (.,.) 
proportion form_empEP [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(sexe) 
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1..2] * 100)',(r(table)[rownumb(r(table),"b"),3..4] * 100)')

/*Groupe d'Age */
mat RESU = RESU \ (.,.)
proportion form_empEP [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4)
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8]* 100)')

/* Niveau d'Instruction */
mat RESU = RESU \ (.,.)
proportion form_empEP [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(Niv_inst_AG3)
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1..5] * 100)',(r(table)[rownumb(r(table),"b"),6..10]* 100)')


/* Ensemble */
proportion form_empEP [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1] * 100)',(r(table)[rownumb(r(table),"b"),2]* 100)')

**T2
mat define RESU_ = (.,.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion form_empEP  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(milieu_resid2) 
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1..3] * 100)',(r(table)[rownumb(r(table),"b"),4..6] * 100)')

/* Sexe */
mat RESU_ = RESU_ \ (.,.) 
proportion form_empEP [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(sexe) 
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1..2] * 100)',(r(table)[rownumb(r(table),"b"),3..4] * 100)')

/*Groupe d'Age */
mat RESU_ = RESU_ \ (.,.)
proportion form_empEP [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4)
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8]* 100)')

/* Niveau d'Instruction */
mat RESU_ = RESU_ \ (.,.)
proportion form_empEP [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(Niv_inst_AG3)
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1..5] * 100)',(r(table)[rownumb(r(table),"b"),6..10]* 100)')


/* Ensemble */
proportion form_empEP [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1] * 100)',(r(table)[rownumb(r(table),"b"),2]* 100)')

mat RESU = RESU_[1..19,1], RESU[1..19,1], RESU_[1..19,2], RESU[1..19,2]


*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = "Milieu de Residence" "Abidjan" "Autre Urbain" "Rural" "Sexe" "Masculin"  "Feminin" "Groupe d'Age" "16-24 ans" "25-35 ans" "36-64 ans" "65 ans et plus"  "Niveau d'Instruction"  "Aucun" "Primaire" "Secondaire  1er Cycle" "Secondaire  2nd Cycle" "Superieure" "Ensemble"

*Colonnes 

matrix colnames RESU = "Emploi Informel T2" "Emploi Informel T3" "Emploi Formel T2" "Emploi Formel T3"

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Formalite_emploi") modify


/* Mise en forme */
putexcel B4 = matrix(RESU), colnames  nformat(number_d2)
putexcel A5 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Répartition de l'emploi par nature selon les caractéristiques"
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Proportion d'Emploi vulnérable (%)"
putexcel (B3:E3), merge

*En tête ligne du Tableau
putexcel A3 = "Caractéristiques Socio Demographiques"
putexcel (A3:A4), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close




/* 3.5. Main d'oeuvre */
/* Main d'oeuvre
MO : Population en emploi
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG2 : Niveau d'instruction en 5 modalités


*/



		*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/

/* Colonne */
**T3
mat define RESU = (.,.) //matrice qui reçoit les résultats de la colonne
matrix list RESU

/* Milieu de résidence */
proportion MO  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(milieu_resid2) 
mat list e(b)
matrix list r(table)
/*
matrix part1 = r(table)[rownumb(r(table), "b"), 1..3] * 100
matrix part2 = r(table)[rownumb(r(table), "b"), 4..6] * 100

matrix list part1
matrix list part2
matrix list part3
*/

mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1..3] * 100)',(r(table)[rownumb(r(table),"b"),4..6] * 100)')

matrix list RESU



/* Sexe */
mat RESU = RESU \ (.,.)
proportion MO [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(sexe) 
mat list e(b)
matrix list r(table)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1..2] * 100)',(r(table)[rownumb(r(table),"b"),3..4] * 100)')

matrix list RESU

/*Groupe d'Age */
mat RESU = RESU \ (.,.)
proportion MO [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4)
mat list e(b)
matrix list r(table)

mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8]* 100)')

matrix list RESU

/* Niveau d'Instruction */
mat RESU = RESU \ (.,.)
proportion MO [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8]* 100)')

matrix list RESU

/* Ensemble */
proportion MO [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1] * 100)',(r(table)[rownumb(r(table),"b"),2]* 100)')

matrix list RESU

**T2
mat define RESU_ = (.,.) //matrice qui reçoit les résultats de la colonne
matrix list RESU_

/* Milieu de résidence */
proportion MO  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(milieu_resid2) 
mat list e(b)
matrix list r(table)
/*
matrix part1 = r(table)[rownumb(r(table), "b"), 1..3] * 100
matrix part2 = r(table)[rownumb(r(table), "b"), 4..6] * 100

matrix list part1
matrix list part2
matrix list parT2
*/

mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1..3] * 100)',(r(table)[rownumb(r(table),"b"),4..6] * 100)')

matrix list RESU_



/* Sexe */
mat RESU_ = RESU_ \ (.,.)
proportion MO [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(sexe) 
mat list e(b)
matrix list r(table)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1..2] * 100)',(r(table)[rownumb(r(table),"b"),3..4] * 100)')

matrix list RESU_

/*Groupe d'Age */
mat RESU_ = RESU_ \ (.,.)
proportion MO [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4)
mat list e(b)
matrix list r(table)

mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8]* 100)')

matrix list RESU_

/* Niveau d'Instruction */
mat RESU_ = RESU_ \ (.,.)
proportion MO [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8]* 100)')

matrix list RESU_

/* Ensemble */
proportion MO [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1] * 100)',(r(table)[rownumb(r(table),"b"),2]* 100)')

matrix list RESU_

mat RESU = RESU_[1..18,1], RESU[1..18,1] , RESU_[1..18,2], RESU[1..18,2]


*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */
matrix list RESU

*Lignes 

matrix rownames RESU = "Milieu de Residence" "Abidjan" "Autre Urbain" "Rural" "Sexe" "Masculin" "Feminin" "Groupe d'Age" "16-24 ans" "25-35 ans" "36-64 ans" "65 ans et plus"  "Niveau d'Instruction"  "Aucun" "Primaire" "Secondaire" "Superieure" "Ensemble"

*Colonnes 

matrix colnames RESU = "Population en emploi T2"  "Population en emploi T3"   "Population au chômage T2" "Population au chômage T3"

matrix list RESU

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Main_d'oeuvre") modify


/* Mise en forme */
putexcel B4 = matrix(RESU), colnames  nformat(number_d2)
putexcel A5 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau 1 : Structure de la main d'œuvre selon les caractéristiques des individus "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
// putexcel B3 = "Proportion de population Emploi vulnérable (%)"
// putexcel (B3:C3), merge

*En tête ligne du Tableau
putexcel A3 = "Caractéristiques Socio Demographiques"
putexcel (A3:A4), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close



/* DEBUT */

/* 3.4. Main d'oeuvre potentielle */
/* Variables impliquées 
statut_MO : Population en emploi
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG2 : Niveau d'instruction en 5 modalités
secteur_institionnel2: Secteur en trois activité à savoir 1 "Public" 2 "Privé" 3 "Menage"

*/

		*a. Calcul des valeurs et Affectation dans des matrices
		

/* Colonne */
**T3
mat define RESU = (.,.,.) //matrice qui reçoit les résultats de la colonne
matrix list RESU

/* Milieu de résidence */
proportion statut_MO  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(milieu_resid2) 
mat list e(b)
matrix list r(table)


mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1..3] * 100)',(r(table)[rownumb(r(table),"b"),4..6] * 100)',(r(table)[rownumb(r(table),"b"),7..9] * 100)')

matrix list RESU


/* Sexe */
mat RESU = RESU \ (.,.,.)
proportion statut_MO [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(sexe) 
mat list e(b)
matrix list r(table)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1..2] * 100)',(r(table)[rownumb(r(table),"b"),3..4] * 100)', (r(table)[rownumb(r(table),"b"),5..6] * 100)')

matrix list RESU



/*Groupe d'Age */
mat RESU = RESU \ (.,.,.)
proportion statut_MO [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4)
mat list e(b)
matrix list r(table)

mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8]* 100)',(r(table)[rownumb(r(table),"b"),9..12]* 100)')

matrix list RESU



/* Niveau d'Instruction */
mat RESU = RESU \ (.,.,.)
proportion statut_MO [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8]* 100)',(r(table)[rownumb(r(table),"b"),9..12]* 100)')

matrix list RESU

/* Secteur institutionnel 

mat RESU = RESU \ (.,.,.)
proportion statut_MO [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(secteur_institionnel2)
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1..3] * 100)',(r(table)[rownumb(r(table),"b"),4..6]* 100)',(r(table)[rownumb(r(table),"b"),7..9]* 100)') */

matrix list RESU

/* Ensemble */
proportion statut_MO [pw=poids_men_vf] if age >= 16 & trimestre == "T3"
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1] * 100)',(r(table)[rownumb(r(table),"b"),2]* 100)',(r(table)[rownumb(r(table),"b"),3]* 100)')

matrix list RESU

**T2
mat define RESU_ = (.,.,.) //matrice qui reçoit les résultats de la colonne
matrix list RESU_

/* Milieu de résidence */
proportion statut_MO  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(milieu_resid2) 
mat list e(b)
matrix list r(table)


mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1..3] * 100)',(r(table)[rownumb(r(table),"b"),4..6] * 100)',(r(table)[rownumb(r(table),"b"),7..9] * 100)')

matrix list RESU_


/* Sexe */
mat RESU_ = RESU_ \ (.,.,.)
proportion statut_MO [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(sexe) 
mat list e(b)
matrix list r(table)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1..2] * 100)',(r(table)[rownumb(r(table),"b"),3..4] * 100)', (r(table)[rownumb(r(table),"b"),5..6] * 100)')

matrix list RESU_



/*Groupe d'Age */
mat RESU_ = RESU_ \ (.,.,.)
proportion statut_MO [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4)
mat list e(b)
matrix list r(table)

mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8]* 100)',(r(table)[rownumb(r(table),"b"),9..12]* 100)')

matrix list RESU_



/* Niveau d'Instruction */
mat RESU_ = RESU_ \ (.,.,.)
proportion statut_MO [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8]* 100)',(r(table)[rownumb(r(table),"b"),9..12]* 100)')

matrix list RESU_

/* Secteur institutionnel 

mat RESU_ = RESU_ \ (.,.,.)
proportion statut_MO [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(secteur_institionnel2)
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1..3] * 100)',(r(table)[rownumb(r(table),"b"),4..6]* 100)',(r(table)[rownumb(r(table),"b"),7..9]* 100)') */

matrix list RESU_

/* Ensemble */
proportion statut_MO [pw=poids_men_vf] if age >= 16 & trimestre == "T2"
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1] * 100)',(r(table)[rownumb(r(table),"b"),2]* 100)',(r(table)[rownumb(r(table),"b"),3]* 100)')

matrix list RESU_

mat RESU = RESU_[1..18,1], RESU[1..18,1], RESU_[1..18,2], RESU[1..18,2] , RESU_[1..18,3], RESU[1..18,3]


*b. Mise en forme du Tableau 
		
		
/* Définition des entête de lignes et colonnes */
matrix list RESU

*Lignes RESU

matrix rownames RESU = "Milieu de Residence" "Abidjan" "Autre Urbain" "Rural" "Sexe" "Masculin" "Feminin" "Groupe d'Age" "16-24 ans" "25-35 ans" "36-64 ans" "65 ans et plus"  "Niveau d'Instruction"  "Aucun" "Primaire" "Secondaire" "Superieure" "Ensemble"

*Colonnes RESU

matrix colnames RESU = "Population en emploi T2" "Population en emploi T3" "Population au chomage T2"  "Population au chomage T3" "Population hors main d'oeuvre T2" "Population hors main d'oeuvre T3"


/* Colonne par colonne

mat RESU_col_1=RESU[1..22,1]
mat RESU_col_2=RESU[1..22,2]
mat RESU_col_3=RESU[1..22,3]

* Création d'une colonne pour la somme des pourcentages
matrix RESU_Pourc_tot= RESU_col_1+RESU_col_2+ RESU_col_3

*Colonnes RESU_Pourc_tot

matrix colnames RESU_Pourc_tot = "TOTAL"

* Ajout de la colonne total des pourcentages
mat RESU = RESU, RESU_Pourc_tot

*Afficher la matrice finale
mat list RESU */


/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Age_travail_repar") modify 


/* Mise en forme */
putexcel B5 = matrix(RESU), colnames  nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel A1 = "Tableau 1 : Répartition de la population en age de travailler selon les caractéristiques des individus "
putexcel A1, bold border(bottom)

/*En tête colonne du Tableau
putexcel B5 = "Population en emploi (%)"
putexcel C5 = "Proportion (%)"
putexcel D5 = "Proportion (%)" 
*/

// *Concatener les lignes des noms des variables de désagrégation
// putexcel (A6:F6), merge
// putexcel (A10:F10), merge
// putexcel (A13:F13), merge
// putexcel (A18:F18), merge

*En tête ligne du Tableau
putexcel A4 = "Caractéristiques Socio Demographiques"
// putexcel (A4:A5), merge
// putexcel (F4:F5), merge
// putexcel (D4:E4),merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

/* FIN */






/* 3.x. Répartition de l'emploi par branche d'activité selon les caractéristiques des individus */

/* Variables impliquées 
form_empEP : Formalité de l'emploi principal
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG3 : Niveau d'instruction en 5 modalités
*/





/* Repartition Main_d'oeuvre_potentielle */


**T3
mat define RESU = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion MOPOT_bis  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(milieu_resid2) 
mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),4..6] * 100)')

/* Sexe */
mat RESU = RESU \ (.) 

proportion MOPOT_bis  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(sexe) 

mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),3..4] * 100)')

/*Groupe d'Age */
mat RESU = RESU \ (.)
proportion MOPOT_bis  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4) 

mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),5..8] * 100)')

/* Niveau d'Instruction */
mat RESU = RESU \ (.)
proportion MOPOT_bis  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(Niv_inst_AG2) 

mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),5..8] * 100)')


/* Ensemble */
proportion MOPOT_bis  [pw=poids_men_vf] if age >= 16 & trimestre == "T3"

mat list e(b)
mat RESU = RESU \ ((r(table)[rownumb(r(table),"b"),1] * 100)')

**T2
mat define RESU_ = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion MOPOT_bis  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(milieu_resid2) 
mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),4..6] * 100)')

/* Sexe */
mat RESU_ = RESU_ \ (.) 

proportion MOPOT_bis  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(sexe) 

mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),3..4] * 100)')

/*Groupe d'Age */
mat RESU_ = RESU_ \ (.)
proportion MOPOT_bis  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4) 

mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),5..8] * 100)')

/* Niveau d'Instruction */
mat RESU_ = RESU_ \ (.)
proportion MOPOT_bis  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(Niv_inst_AG2) 

mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),5..8] * 100)')


/* Ensemble */
proportion MOPOT_bis  [pw=poids_men_vf] if age >= 16 & trimestre == "T2"

mat list e(b)
mat RESU_ = RESU_ \ ((r(table)[rownumb(r(table),"b"),1] * 100)')

/* Pour les proportions 


mat define RESU1 = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
total MOPOT_bis  [pw=poids_men_vf] if age >= 16, over(milieu_resid2) 
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),1..3] )')

/* Sexe */
mat RESU1 = RESU1 \ (.) 

total MOPOT_bis  [pw=poids_men_vf] if age >= 16, over(sexe) 

mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),1..2] )')

/*Groupe d'Age */
mat RESU1 = RESU1 \ (.)
total MOPOT_bis  [pw=poids_men_vf] if age >= 16, over(groupe_age4) 

mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),1..4] )')

/* Niveau d'Instruction */
mat RESU1 = RESU1 \ (.)
total MOPOT_bis  [pw=poids_men_vf] if age >= 16, over(Niv_inst_AG2) 

mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),1..4] )')


/* Ensemble */
total MOPOT_bis  [pw=poids_men_vf] if age >= 16

mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),1] )') */

mat RESU= RESU_, RESU




*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = "Milieu de Residence" "Abidjan" "Autre Urbain" "Rural" "Sexe" "Masculin" "Feminin" "Groupe d'Age" "16-24 ans" "25-35 ans" "36-64 ans" "65 ans et plus"  "Niveau d'Instruction"  "Aucun" "Primaire" "Secondaire" "Superieure" "Ensemble"

*Colonnes 

matrix colnames RESU = "Main d'oeuvre potentielle T2" "Main d'oeuvre potentielle T3"

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("MOP_repartition") modify


/* Mise en forme */
//putexcel B4 = matrix(RESU), colnames  nformat(number_d2)
putexcel B4 = matrix(RESU), colnames nformat(number_d2)
putexcel A5 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau 8 : Répartition de la main d'oeuvre potentielle selon les caractéristiques des individus"
putexcel B1, bold border(bottom)

putexcel save

*Fermeture du fichier
putexcel close



/* X.x. Jeune de 15-24 ans ni en emploi, ni en éducation et ni en formation (Neets) */

/* Variables impliquées 
NEET15_24 : 
sexe : sexe
Niv_inst_AG2 : Niveau d'instruction en 4 modalités
milieu_resid2: Milieu de résidence
*/

/* Colonne des effectifs */

***T3
mat define RESU = (.,.) //matrice qui reçoit les résultats de la colonne

mat define RESU1 = (.)
mat define RESU2 = (.)
/* Milieu de Résidence */

proportion NEET15_24_bis [pw=poids_men_vf] if trimestre =="T3", over(milieu_resid2)
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table), "b"), 4..6] * 100)')

total NEET15_24 [pw=poids_men_vf] if trimestre =="T3", over(milieu_resid2)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table), "b"), 1..3])')

/* Sexe */

mat RESU1 = RESU1 \ (.)
mat RESU2 = RESU2 \ (.)
proportion sexe  [pw=poids_men_vf] if trimestre =="T3", over(NEET15_24)  

proportion NEET15_24_bis [pw=poids_men_vf] if trimestre =="T3", over(sexe) 
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),3..4] * 100)')


total NEET15_24 [pw=poids_men_vf] if trimestre =="T3", over(sexe)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),1..2])')

/* Groupe d'age 6 */
mat RESU1 = RESU1 \ (.)
proportion NEET15_24_bis [pw=poids_men_vf] if trimestre =="T3", over(groupe_age6) 
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),3..4] * 100)')
mat RESU1 = RESU1 \ (.)
mat RESU1 = RESU1 \ (.)
mat RESU1 = RESU1 \ (.)
mat RESU1 = RESU1 \ (.)


mat RESU2 = RESU2 \ (.)
total NEET15_24 [pw=poids_men_vf], over(groupe_age6)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),1..2])')
mat RESU2 = RESU2 \ (.)
mat RESU2 = RESU2 \ (.)
mat RESU2 = RESU2 \ (.)
mat RESU2 = RESU2 \ (.)

/* Niveau d'Instruction */
mat RESU1 = RESU1 \ (.)
proportion NEET15_24_bis [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG2) 
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),5..8] * 100)')

mat RESU2 = RESU2 \ (.)
total NEET15_24 [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),1..4])')



/* Ensemble */
proportion 1.NEET15_24_bis [pw=poids_men_vf] if trimestre =="T3"
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table), "b"), 1] * 100)')

total 1.NEET15_24 [pw=poids_men_vf] if trimestre =="T3"
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table), "b"), 1])')
mat RESU =  RESU2,RESU1

matrix colnames RESU = "Effectif T3" "% T3"

mat RESU_Def=RESU

***T2
mat define RESU_ = (.,.) //matrice qui reçoit les résultats de la colonne

mat define RESU_1 = (.)
mat define RESU_2 = (.)
/* Milieu de Résidence */

proportion NEET15_24_bis [pw=poids_men_vf] if trimestre =="T2", over(milieu_resid2)
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table), "b"), 4..6] * 100)')

total NEET15_24 [pw=poids_men_vf] if trimestre =="T2", over(milieu_resid2)
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table), "b"), 1..3])')

/* Sexe */

mat RESU_1 = RESU_1 \ (.)
mat RESU_2 = RESU_2 \ (.)
proportion sexe  [pw=poids_men_vf] if trimestre =="T2", over(NEET15_24)  

proportion NEET15_24_bis [pw=poids_men_vf] if trimestre =="T2", over(sexe) 
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),3..4] * 100)')


total NEET15_24 [pw=poids_men_vf] if trimestre =="T2", over(sexe)
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table),"b"),1..2])')

/* Groupe d'age 6 */
mat RESU_1 = RESU_1 \ (.)
proportion NEET15_24_bis [pw=poids_men_vf] if trimestre =="T2", over(groupe_age6) 
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),3..4] * 100)')
mat RESU_1 = RESU_1 \ (.)
mat RESU_1 = RESU_1 \ (.)
mat RESU_1 = RESU_1 \ (.)
mat RESU_1 = RESU_1 \ (.)


mat RESU_2 = RESU_2 \ (.)
total NEET15_24 [pw=poids_men_vf], over(groupe_age6)
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table),"b"),1..2])')
mat RESU_2 = RESU_2 \ (.)
mat RESU_2 = RESU_2 \ (.)
mat RESU_2 = RESU_2 \ (.)
mat RESU_2 = RESU_2 \ (.)

/* Niveau d'Instruction */
mat RESU_1 = RESU_1 \ (.)
proportion NEET15_24_bis [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG2) 
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),5..8] * 100)')

mat RESU_2 = RESU_2 \ (.)
total NEET15_24 [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table),"b"),1..4])')



/* Ensemble */
proportion 1.NEET15_24_bis [pw=poids_men_vf] if trimestre =="T2"
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table), "b"), 1] * 100)')

total 1.NEET15_24 [pw=poids_men_vf] if trimestre =="T2"
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table), "b"), 1])')
mat RESU_ =  RESU_2,RESU_1

matrix colnames RESU_ = "Effectif T2" "% T2"

mat RESU__Def=RESU_

*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 



		







/* X.x. Jeune de 15-35 ans ni en emploi, ni en éducation et ni en formation (Neets) */

/* Variables impliquées 
NEET15_35 : 
sexe : sexe
Niv_inst_AG2 : Niveau d'instruction en 4 modalités
milieu_resid2: Milieu de résidence
*/

/* Colonne des effectifs */

**T3
mat define RESU = (.,.) //matrice qui reçoit les résultats de la colonne

/* Milieu de Résidence */
mat define RESU1 = (.)

proportion NEET15_35_bis [pw=poids_men_vf] if trimestre=="T3", over(milieu_resid2)
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table), "b"), 4..6] * 100)')


mat define RESU2 = (.)
total NEET15_35 [pw=poids_men_vf] if trimestre=="T3", over(milieu_resid2)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table), "b"), 1..3])')

/* Sexe */
mat RESU1 = RESU1 \ (.)
proportion NEET15_35_bis [pw=poids_men_vf] if trimestre=="T3", over(sexe) 
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),3..4] * 100)')

mat RESU2 = RESU2 \ (.)
total NEET15_35 [pw=poids_men_vf] if trimestre=="T3", over(sexe)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),1..2])')

/* Groupe d'age 6 */
mat RESU1 = RESU1 \ (.)
proportion 1.NEET15_35_bis [pw=poids_men_vf] if trimestre=="T3", over(groupe_age6) 
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)')
mat RESU1 = RESU1 \ (.)
mat RESU1 = RESU1 \ (.)

mat RESU2 = RESU2 \ (.)
total 1.NEET15_35 [pw=poids_men_vf] if trimestre=="T3", over(groupe_age6)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),1..4])')
mat RESU2 = RESU2 \ (.)
mat RESU2 = RESU2 \ (.)

/* Niveau d'Instruction */
mat RESU1 = RESU1 \ (.)
proportion NEET15_35_bis [pw=poids_men_vf] if trimestre=="T3", over(Niv_inst_AG2) 
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),5..8] * 100)')

mat RESU2 = RESU2 \ (.)
total NEET15_35 [pw=poids_men_vf] if trimestre=="T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),1..4])')


/* Ensemble */
proportion 1.NEET15_35_bis if trimestre=="T3" [pw=poids_men_vf]
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table), "b"), 1] * 100)')

total 1.NEET15_35 [pw=poids_men_vf] if trimestre=="T3"
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table), "b"), 1])')
mat RESU =  RESU2,RESU1

matrix colnames RESU = "Effectif T3" "% T3"
mat RESU_Def=RESU_Def,RESU

**T2
mat define RESU_ = (.,.) //matrice qui reçoit les résultats de la colonne

/* Milieu de Résidence */
mat define RESU_1 = (.)

proportion NEET15_35_bis [pw=poids_men_vf] if trimestre=="T2", over(milieu_resid2)
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table), "b"), 4..6] * 100)')


mat define RESU_2 = (.)
total NEET15_35 [pw=poids_men_vf] if trimestre=="T2", over(milieu_resid2)
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table), "b"), 1..3])')

/* Sexe */
mat RESU_1 = RESU_1 \ (.)
proportion NEET15_35_bis [pw=poids_men_vf] if trimestre=="T2", over(sexe) 
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),3..4] * 100)')

mat RESU_2 = RESU_2 \ (.)
total NEET15_35 [pw=poids_men_vf] if trimestre=="T2", over(sexe)
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table),"b"),1..2])')

/* Groupe d'age 6 */
mat RESU_1 = RESU_1 \ (.)
proportion 1.NEET15_35_bis [pw=poids_men_vf] if trimestre=="T2", over(groupe_age6) 
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)')
mat RESU_1 = RESU_1 \ (.)
mat RESU_1 = RESU_1 \ (.)

mat RESU_2 = RESU_2 \ (.)
total 1.NEET15_35 [pw=poids_men_vf] if trimestre=="T2", over(groupe_age6)
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table),"b"),1..4])')
mat RESU_2 = RESU_2 \ (.)
mat RESU_2 = RESU_2 \ (.)

/* Niveau d'Instruction */
mat RESU_1 = RESU_1 \ (.)
proportion NEET15_35_bis [pw=poids_men_vf] if trimestre=="T2", over(Niv_inst_AG2) 
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),5..8] * 100)')

mat RESU_2 = RESU_2 \ (.)
total NEET15_35 [pw=poids_men_vf] if trimestre=="T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table),"b"),1..4])')


/* Ensemble */
proportion 1.NEET15_35_bis if trimestre=="T2" [pw=poids_men_vf]
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table), "b"), 1] * 100)')

total 1.NEET15_35 [pw=poids_men_vf] if trimestre=="T2"
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table), "b"), 1])')
mat RESU_ =  RESU_2,RESU_1

matrix colnames RESU_ = "Effectif T2" "% T2"
mat RESU__Def=RESU__Def,RESU_

*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

/* X.x. Jeune de 15-40 ans ni en emploi, ni en éducation et ni en formation (Neets) */

/* Variables impliquées 
NEET15_40 : 
sexe : sexe
Niv_inst_AG2 : Niveau d'instruction en 4 modalités
milieu_resid2: Milieu de résidence
*/

/* Colonne des effectifs */
**T3
mat define RESU = (.,.) //matrice qui reçoit les résultats de la colonne


/* Milieu de Résidence */
mat define RESU1 = (.)
proportion NEET15_40_bis [pw=poids_men_vf] if trimestre=="T3", over(milieu_resid2)
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table), "b"), 4..6] * 100)')

mat define RESU2 = (.)
total NEET15_40 [pw=poids_men_vf] if trimestre=="T3", over(milieu_resid2)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table), "b"), 1..3])')

/* Sexe */

mat RESU1 = RESU1 \ (.)

proportion NEET15_40_bis [pw=poids_men_vf] if trimestre=="T3", over(sexe) 
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),3..4] * 100)')

mat RESU2 = RESU2 \ (.)

total NEET15_40 [pw=poids_men_vf] if trimestre=="T3", over(sexe)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),1..2])')

/* Groupe d'age 7 */
mat RESU1 = RESU1 \ (.)
proportion 1.NEET15_40_bis [pw=poids_men_vf] if trimestre=="T3", over(groupe_age7) 
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),1..3] * 100)')
mat RESU1 = RESU1 \ (.)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),4..5] * 100)')

mat RESU2 = RESU2 \ (.)
total 1.NEET15_40 [pw=poids_men_vf] if trimestre=="T3", over(groupe_age7)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),1..3])')
mat RESU2 = RESU2 \ (.)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),4..5])')

/* Niveau d'Instruction */
mat RESU1 = RESU1 \ (.)
proportion NEET15_40_bis [pw=poids_men_vf] if trimestre=="T3", over(Niv_inst_AG2) 
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),5..8] * 100)')

mat RESU2 = RESU2 \ (.)
total NEET15_40 [pw=poids_men_vf] if trimestre=="T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),1..4])')

/* Ensemble */
proportion 1.NEET15_40_bis [pw=poids_men_vf] if trimestre=="T3"
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table), "b"), 1] * 100)')

total 1.NEET15_40 [pw=poids_men_vf] if trimestre=="T3"
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table), "b"), 1])')
mat RESU =  RESU2,RESU1

matrix colnames RESU = "Effectif T3" "% T3"
mat RESU_Def=RESU_Def,RESU

**T2
mat define RESU_ = (.,.) //matrice qui reçoit les résultats de la colonne


/* Milieu de Résidence */
mat define RESU_1 = (.)
proportion NEET15_40_bis [pw=poids_men_vf] if trimestre=="T2", over(milieu_resid2)
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table), "b"), 4..6] * 100)')

mat define RESU_2 = (.)
total NEET15_40 [pw=poids_men_vf] if trimestre=="T2", over(milieu_resid2)
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table), "b"), 1..3])')

/* Sexe */

mat RESU_1 = RESU_1 \ (.)

proportion NEET15_40_bis [pw=poids_men_vf] if trimestre=="T2", over(sexe) 
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),3..4] * 100)')

mat RESU_2 = RESU_2 \ (.)

total NEET15_40 [pw=poids_men_vf] if trimestre=="T2", over(sexe)
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table),"b"),1..2])')

/* Groupe d'age 7 */
mat RESU_1 = RESU_1 \ (.)
proportion 1.NEET15_40_bis [pw=poids_men_vf] if trimestre=="T2", over(groupe_age7) 
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),1..3] * 100)')
mat RESU_1 = RESU_1 \ (.)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),4..5] * 100)')

mat RESU_2 = RESU_2 \ (.)
total 1.NEET15_40 [pw=poids_men_vf] if trimestre=="T2", over(groupe_age7)
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table),"b"),1..3])')
mat RESU_2 = RESU_2 \ (.)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table),"b"),4..5])')

/* Niveau d'Instruction */
mat RESU_1 = RESU_1 \ (.)
proportion NEET15_40_bis [pw=poids_men_vf] if trimestre=="T2", over(Niv_inst_AG2) 
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),5..8] * 100)')

mat RESU_2 = RESU_2 \ (.)
total NEET15_40 [pw=poids_men_vf] if trimestre=="T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table),"b"),1..4])')

/* Ensemble */
proportion 1.NEET15_40_bis [pw=poids_men_vf] if trimestre=="T2"
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table), "b"), 1] * 100)')

total 1.NEET15_40 [pw=poids_men_vf] if trimestre=="T2"
mat list e(b)
mat RESU_2 = RESU_2 \ ((r(table)[rownumb(r(table), "b"), 1])')
mat RESU_ =  RESU_2,RESU_1

matrix colnames RESU_ = "Effectif T2" "% T2"
mat RESU__Def=RESU__Def,RESU_

mat RESU_Def = RESU__Def[1..20,1], RESU_Def[1..20,1], RESU__Def[1..20,2], RESU_Def[1..20,2], RESU__Def[1..20,3], RESU_Def[1..20,3], RESU__Def[1..20,4], RESU_Def[1..20,4], RESU__Def[1..20,5], RESU_Def[1..20,5], RESU__Def[1..20,6], RESU_Def[1..20,6]

matrix rownames RESU_Def ="Milieu de Résidence" "Abidjan" "Autre urbain" "Rural" "Sexe" "Masculin" "Feminin" "Groupe d'age" "15-19 ans" "20-24 ans" "25-29 ans" "30-35 ans" "30-34 ans" "35-40 ans" "Niveau d' Instruction" "Aucun" "Primaire" "Secondaire" "Superieure" "Ensemble"
	

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Jeunes_15-40_NEET") modify	
/* Titre du tableau */
putexcel A2 = "Tableau 9 : Caractéristiques des jeunes ni à l'école, ni en formation, ni en emploi (Neets)"
putexcel A2, bold border(bottom)

*En tête colonne du Tableau
putexcel B4 = "Jeune de 15-24 ans ni en emploi, ni en éducation et ni en formation (Neets)"
putexcel (B4:E4), merge

*En tête colonne du Tableau
putexcel F4 = "Jeune de 15-35 ans ni en emploi, ni en éducation et ni en formation (Neets)"
putexcel (F4:I4), merge

*En tête colonne du Tableau
putexcel J4 = "Jeune de 15-40 ans ni en emploi, ni en éducation et ni en formation (Neets)"
putexcel (J4:M4), merge


*En tête ligne du Tableau
putexcel A4 = "Caractéristiques Socio Demographiques"
putexcel (A4:A5), merge



/* Mise en forme */
putexcel B5 = matrix(RESU_Def), colnames  nformat(number_d2)
putexcel A6 = matrix(RESU_Def), rownames



*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close



/* X.x. Taux d'emploi précaire selon les caractéristiques */

/* Variables impliquées 
emp_prec : 
cat_profEP : statut socio professionnel
milieu_resid2 : Milieu de résidence
Niv_inst_AG2 : Niveau d'instruction en 5 modalités
: Branche d'activité principale agrégée en 4 de l'emploi
*/

/* Colonne des effectifs */
**T3
mat define RESU = (.) //matrice qui reçoit les résultats de la colonne

/* Statut socio professionnel */
proportion emp_prec [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(cat_profEP) 
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"se"),8..14] * 100)'
mat RESU = RESU \ (.)

/* Milieu de résidence*/
mat RESU = RESU \ (.)
proportion emp_prec [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(milieu_resid2) 
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),4..6] * 100)'
mat RESU = RESU \ (.)

/* Milieu de résidence*/
mat RESU = RESU \ (.)
proportion emp_prec [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(Niv_inst_AG2) 
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),5..8] * 100)'
mat RESU = RESU \ (.)

/* Branche d'activité // A reactiver quand les données seront codifier */
mat RESU = RESU \ (.)
proportion 1.emp_prec [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(branche1) 
mat list e(b)
mat RESU = RESU \e(b)'* 100 

mat RESU = RESU \ (.) 

**T2
mat define RESU_ = (.) //matrice qui reçoit les résultats de la colonne

/* Statut socio professionnel */
proportion emp_prec [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(cat_profEP) 
mat list e(b)
mat RESU_ = RESU_ \ (r(table)[rownumb(r(table),"se"),8..14] * 100)'
mat RESU_ = RESU_ \ (.)

/* Milieu de résidence*/
mat RESU_ = RESU_ \ (.)
proportion emp_prec [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(milieu_resid2) 
mat list e(b)
mat RESU_ = RESU_ \ (r(table)[rownumb(r(table),"b"),4..6] * 100)'
mat RESU_ = RESU_ \ (.)

/* Milieu de résidence*/
mat RESU_ = RESU_ \ (.)
proportion emp_prec [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(Niv_inst_AG2) 
mat list e(b)
mat RESU_ = RESU_ \ (r(table)[rownumb(r(table),"b"),5..8] * 100)'
mat RESU_ = RESU_ \ (.)

/*Branche d'activité // A reactiver quand les données seront codifier */
mat RESU_ = RESU_ \ (.)
proportion 1.emp_prec [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(branche1) 
mat list e(b)
mat RESU_ = RESU_ \e(b)'* 100 

mat RESU_ = RESU_ \ (.)

mat RESU =  RESU_, RESU

*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

matrix rownames RESU = "Statut Socio Professionnel" "Cadre superieur" "Cadre moyen, agent de maîtrise" "Employe/ouvrier qualifie" "Employe/ouvrier semi qualifie" "Manœuvre" "Apprenti ou stagiaire paye" "Domestique" "TOTAL" "Milieu de Residence" "Abidjan" "Autre urbain" "Rural" "TOTAL" "Niveau d'instruction" "Aucun niveau" "Primaire" "Secondaire" "Superieur" "TOTAL" "Branche d'activité" "Agriculture" "Industrie" "Commerce" "Autre service"
*Colonnes 

matrix colnames RESU = "Emploi précaire T2 (%)" "Emploi précaire T3 (%) "

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Taux_emploi_précaire") modify

/* Mise en forme */
putexcel B4 = matrix(RESU), colnames  nformat(number_d2)
putexcel A5 = matrix(RESU), rownames // Gérer le Total

/* Titre du tableau */
putexcel A2 = "Tableau 1 : Proportion d'emploi précaire selon la CSP, le milieu de résidence, niveau d'étude (et branches d'activités Principales agrégées en 4 de l'emploi principal)"
putexcel A2, bold border(bottom)

*En tête colonne du Tableau
*putexcel C4 = "Proportion d'emploi précaire (%)"
//putexcel (B3:C3), merge

*En tête ligne du Tableau
putexcel A4 = "Caractéristiques Socio Demographiques"
//putexcel (A4:B4), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close




/* 3.4. pluriactivite */
/* Variables impliquées
pluriactivite : Personne en emploi avec plus d'un emploi
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG2 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/

/* Colonne des effectifs */

**T3
mat define RESU = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
total 1.pluriactivite [pw=poids_men_vf] if trimestre == "T3", over(milieu_resid2) 
mat list e(b)

mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),1..3])'

/* Sexe */
mat RESU = RESU \ (.)
total 1.pluriactivite [pw=poids_men_vf] if trimestre == "T3", over(sexe) 
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),1..2]')

/*Groupe d'Age */
mat RESU = RESU \ (.)
total 1.pluriactivite [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4)
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),1..4] )'

/* Niveau d'instruction */
mat RESU = RESU \ (.)
total 1.pluriactivite [pw=poids_men_vf] if trimestre == "T3", over(Niv_inst_AG3)
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),1..5])'

/* Ensemble */
total 1.pluriactivite [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),1])'
		
		
/* Colonne pourcentage profil colonne */

mat define RESU1 = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion milieu_resid2  [pw=poids_men_vf] if age >= 16 &  trimestre == "T3", over(pluriactivite) 
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100))'

/* Sexe */
mat RESU1 = RESU1 \ (.)
proportion sexe [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(pluriactivite) 
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100))'

/*Groupe d'Age */
mat RESU1 = RESU1 \ (.)
proportion groupe_age4 [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(pluriactivite)
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100))'

/* Niveau d'Instruction */
mat RESU1 = RESU1 \ (.)
proportion Niv_inst_AG3 [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(pluriactivite)
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100),(r(table)[rownumb(r(table),"b"),10] * 100))'
/* Ensemble */
proportion pluriactivite [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),2] * 100)')

/* Colonne pourcentage profil ligne */

mat define RESU2 = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion 1.pluriactivite [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(milieu_resid2) 
mat list e(b)
mat RESU2 = RESU2 \ (e(b)* 100)'

/* Sexe */
mat RESU2 = RESU2 \ (.)
proportion 1.pluriactivite [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(sexe) 
mat list e(b)
mat RESU2 = RESU2 \ (e(b)* 100)'

/*Groupe d'Age */
mat RESU2 = RESU2 \ (.)
proportion 1.pluriactivite [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4)
mat list e(b)
mat RESU2 = RESU2 \ (e(b)* 100)'

/* Niveau d'Instruction */
mat RESU2 = RESU2 \ (.)
proportion 1.pluriactivite [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(Niv_inst_AG3)
mat list e(b)
mat RESU2 = RESU2 \ (e(b)* 100)'

/* Ensemble */
proportion 1.pluriactivite [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU2 = RESU2 \ (e(b)* 100)'

**T2
mat define RESU_ = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
total 1.pluriactivite [pw=poids_men_vf] if trimestre == "T2", over(milieu_resid2) 
mat list e(b)

mat RESU_ = RESU_ \ (r(table)[rownumb(r(table),"b"),1..3])'

/* Sexe */
mat RESU_ = RESU_ \ (.)
total 1.pluriactivite [pw=poids_men_vf] if trimestre == "T2", over(sexe) 
mat list e(b)
mat RESU_ = RESU_ \ (r(table)[rownumb(r(table),"b"),1..2]')

/*Groupe d'Age */
mat RESU_ = RESU_ \ (.)
total 1.pluriactivite [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4)
mat list e(b)
mat RESU_ = RESU_ \ (r(table)[rownumb(r(table),"b"),1..4] )'

/* Niveau d'instruction */
mat RESU_ = RESU_ \ (.)
total 1.pluriactivite [pw=poids_men_vf] if trimestre == "T2", over(Niv_inst_AG3)
mat list e(b)
mat RESU_ = RESU_ \ (r(table)[rownumb(r(table),"b"),1..5])'

/* Ensemble */
total 1.pluriactivite [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU_ = RESU_ \ (r(table)[rownumb(r(table),"b"),1])'
		
		
/* Colonne pourcentage profil colonne */

mat define RESU_1 = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion milieu_resid2  [pw=poids_men_vf] if age >= 16 &  trimestre == "T2", over(pluriactivite) 
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100))'

/* Sexe */
mat RESU_1 = RESU_1 \ (.)
proportion sexe [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(pluriactivite) 
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100))'

/*Groupe d'Age */
mat RESU_1 = RESU_1 \ (.)
proportion groupe_age4 [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(pluriactivite)
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100))'

/* Niveau d'Instruction */
mat RESU_1 = RESU_1 \ (.)
proportion Niv_inst_AG3 [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(pluriactivite)
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),2] * 100),(r(table)[rownumb(r(table),"b"),4] * 100)',(r(table)[rownumb(r(table),"b"),6] * 100),(r(table)[rownumb(r(table),"b"),8] * 100),(r(table)[rownumb(r(table),"b"),10] * 100))'
/* Ensemble */
proportion pluriactivite [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU_1 = RESU_1 \ ((r(table)[rownumb(r(table),"b"),2] * 100)')

/* Colonne pourcentage profil ligne */

mat define RESU_2 = (.) //matrice qui reçoit les résultats de la colonne

/* Milieu de résidence */
proportion 1.pluriactivite [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(milieu_resid2) 
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b)* 100)'

/* Sexe */
mat RESU_2 = RESU_2 \ (.)
proportion 1.pluriactivite [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(sexe) 
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b)* 100)'

/*Groupe d'Age */
mat RESU_2 = RESU_2 \ (.)
proportion 1.pluriactivite [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b)* 100)'

/* Niveau d'Instruction */
mat RESU_2 = RESU_2 \ (.)
proportion 1.pluriactivite [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(Niv_inst_AG3)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b)* 100)'

/* Ensemble */
proportion 1.pluriactivite [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b)* 100)'

/* Fusion des deux colonnes */

mat RESU = RESU_, RESU, RESU_2, RESU2 ,RESU_1, RESU1

		*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = "Milieu de Residence" "Abidjan" "Autre Urbain" "Rural" "Sexe" "Masculin" "Feminin" "Groupe d'Age" "16-24 ans" "25-35 ans" "36-64 ans" "65 ans et plus"  "Niveau d'Instruction" "Aucun Niveau" "Primaire" "Secondaire  1er Cycle" "Secondaire  2nd Cycle" "Superieur" "Ensemble"

*Colonnes 

matrix colnames RESU = "Effectif T2" "Effectif T3" "(% profil ligne) T2" "(% profil ligne) T3" "(% profil colonne) T2" "(% profil colonne) T3"

/* Exportation sur Excel dans le dossier Resultats_Tab*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Pluriactivite") modify
/* Mise en forme */
putexcel B4 = matrix(RESU), colnames  nformat(number_d2)
putexcel A5 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Répartition des travailleurs en pluriactivité selon les caractéristiques des individus  "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Travailleur en pluriactivé"
putexcel (B3:C3), merge

*En tête ligne du Tableau
putexcel A3 = "Caractéristiques Socio Demographiques"
putexcel (A3:A4), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close




/* X.x. Situation dans l'emploi */
/* Variables impliquées
Stat_emp : Personne en emploi avec plus d'un emploi
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG2 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/

/* Colonne des effectifs */
// mat define RESU = (.,.)
**T3
mat define RESU1 = (.)
proportion sit_empEP_Autorite [pw=poids_men_vf] if pop_emp_dich==1 & trimestre == "T3"


mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat define RESU2 = (.)
total 1.pop_emp [pw=poids_men_vf] if trimestre == "T3", over(sit_empEP_Autorite)
mat list e(b)
mat RESU2 = RESU2 \ (e(b))'

**T2
mat define RESU_1 = (.)
proportion sit_empEP_Autorite [pw=poids_men_vf] if pop_emp_dich==1 & trimestre == "T2"


mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat define RESU_2 = (.)
total 1.pop_emp [pw=poids_men_vf] if trimestre == "T2", over(sit_empEP_Autorite)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b))'

mat RESU = RESU_2, RESU2, RESU_1, RESU1

*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = " Dégré d'autorité" "Travailleurs indépendants" "Travailleurs dépendants"  "Non classé"

	
*Colonnes 

matrix colnames RESU = "Effectif T2" "Effectif T3" "% Categorie T2" "% Categorie T3"

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Situation_Emp") modify

/* Mise en forme */
putexcel B5 = matrix(RESU), colnames  nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel A2 = "Tableau 1 : Répartition de la population en emploi selon la situation en emploi"
putexcel A2, bold border(bottom)

*En tête ligne du Tableau
putexcel A4 = "Situation en emploi"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close


/*

/* X.x. Situation dans l'emploi Profil Colonne*/
/* Variables impliquées
sit_emp : situation en emploi
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
branche2: Branche d'activité
Niv_inst_AG2 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/

mat define RESU = (.,.,.)


/* Sexe */

mat define RESU1 = (.)
proportion 1.sit_empEP_Autorite [pw=poids_men_vf], over(sexe)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat define RESU2 = (.)
proportion 2.sit_empEP_Autorite [pw=poids_men_vf], over(sexe)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat define RESU3 = (.)
proportion 4.sit_empEP_Autorite [pw=poids_men_vf], over(sexe)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

// mat define RESU4 = (.)
// proportion 4.sit_empEP3 [pw=poids_men_vf], over(sexe)
// mat list e(b)
// mat RESU4 = RESU4 \ (e(b) * 100)'
//
// mat define RESU5 = (.)
// proportion 5.sit_empEP2 [pw=poids_men_vf], over(sexe)
// mat list e(b)
// mat RESU5 = RESU5 \ (e(b) * 100)'
//
// mat define RESU6 = (.)
// proportion 6.sit_empEP2 [pw=poids_men_vf], over(sexe)
// mat list e(b)
// mat RESU6 = RESU6 \ (e(b) * 100)'
//
// mat define RESU7 = (.)
// proportion 7.sit_empEP2 [pw=poids_men_vf], over(sexe)
// mat list e(b)
// mat RESU7 = RESU7 \ (e(b) * 100)'
//

/* milieur de residence */
mat RESU1 = RESU1 \ (.)
proportion 1.sit_empEP_Autorite [pw=poids_men_vf], over(milieu_resid2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.sit_empEP_Autorite [pw=poids_men_vf], over(milieu_resid2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 4.sit_empEP_Autorite [pw=poids_men_vf], over(milieu_resid2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

// mat RESU4 = RESU4 \ (.)
// proportion 4.sit_empEP3 [pw=poids_men_vf], over(milieu_resid2)
// mat list e(b)
// mat RESU4 = RESU4 \ (e(b) * 100)'
//
// mat RESU5 = RESU5 \ (.)
// proportion 5.sit_empEP2 [pw=poids_men_vf], over(milieu_resid2)
// mat list e(b)
// mat RESU5 = RESU5 \ (e(b) * 100)'
//
// mat RESU6 = RESU6 \ (.)
// proportion 6.sit_empEP2 [pw=poids_men_vf], over(milieu_resid2)
// mat list e(b)
// mat RESU6 = RESU6 \ (e(b) * 100)'
//
// mat RESU7 = RESU7 \ (.)
// proportion 7.sit_empEP2 [pw=poids_men_vf], over(milieu_resid2)
// mat list e(b)
// mat RESU7 = RESU7 \ (e(b) * 100)'

/* Niveau d'Instruction */

mat RESU1 = RESU1 \ (.)
proportion 1.sit_empEP_Autorite [pw=poids_men_vf], over(Niv_inst_AG2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.sit_empEP_Autorite [pw=poids_men_vf], over(Niv_inst_AG2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 4.sit_empEP_Autorite [pw=poids_men_vf], over(Niv_inst_AG2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

// mat RESU4 = RESU4 \ (.)
// proportion 4.sit_empEP3 [pw=poids_men_vf], over(Niv_inst_AG2)
// mat list e(b)
// mat RESU4 = RESU4 \ (e(b) * 100)'
// //
// mat RESU5 = RESU5 \ (.)
// proportion 5.sit_empEP2 [pw=poids_men_vf], over(Niv_inst_AG2)
// mat list e(b)
// mat RESU5 = RESU5 \ (e(b) * 100)'
//
// mat RESU6 = RESU6 \ (.)
// proportion 6.sit_empEP2 [pw=poids_men_vf], over(Niv_inst_AG2)
// mat list e(b)
// mat RESU6 = RESU6 \ (e(b) * 100)'
//
// mat RESU7 = RESU7 \ (.)
// proportion 7.sit_empEP2 [pw=poids_men_vf], over(Niv_inst_AG2)
// mat list e(b)
// mat RESU7 = RESU7 \ (e(b) * 100)'

/* Branche d'activité */

mat RESU1 = RESU1 \ (.)
proportion 1.sit_empEP_Autorite [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.sit_empEP_Autorite [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 4.sit_empEP_Autorite [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

// mat RESU4 = RESU4 \ (.)
// proportion 4.sit_empEP3 [pw=poids_men_vf], over(branche2)
// mat list e(b)
// mat RESU4 = RESU4 \ (e(b) * 100)'
//
// mat RESU5 = RESU5 \ (.)
// proportion 5.sit_empEP2 [pw=poids_men_vf], over(branche2)
// mat list e(b)
// mat RESU5 = RESU5 \ (e(b) * 100)'
//
// mat RESU6 = RESU6 \ (.)
// proportion 6.sit_empEP2 [pw=poids_men_vf], over(branche2)
// mat list e(b)
// mat RESU6 = RESU6 \ (e(b) * 100)'
//
// mat RESU7 = RESU7 \ (.)
// proportion 7.sit_empEP2 [pw=poids_men_vf], over(branche2)
// mat list e(b)
// mat RESU7 = RESU7 \ (e(b) * 100)'

/* Consolidation de la matrice finale */
mat RESU = RESU1, RESU2, RESU3

*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = ///
    "Sexe" ///
        "Masculin" ///
        "Feminin" ///
	"Milieu de Résidence" ///
		"Abidjan" ///
		"Autre urbain" ///
		"Rural" ///
	"Niveau d'Instruction" ///
        "Aucun" ///
        "Primaire" ///
        "Secondaire" ///
        "Superieure" ///
	"Branche d'Activité'" ///
		"Secteur primaire" ///
		"Secteur secondaire" ///
		"Secteur tertiaire" ///
	
*Colonnes 

matrix colnames RESU = "Travailleurs indépendants" "Travailleurs dépendants" "Non classé"
			
/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Situation_Emp_PC") modify

/* Mise en forme */
putexcel B5 = matrix(RESU), colnames  nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel A2 = "Tableau 1 : Situation en Emploi selon les caractéristiques"
putexcel A2, bold border(bottom)


*En tête ligne du Tableau
putexcel A4 = "Caractéristiques Socio Demographiques"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

*/


		/*------------------------------------------------------*/
/* X.x. Classifition internationale du statut dans l'emploi : Situation dans l'emploi Profil Colonne*/
/* Variables impliquées
CISE_18_new : situation en emploi 5 modalités
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
branche2: Branche d'activité
Niv_inst_AG2 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/
**T3	
mat define RESU = (.,.,.,.,.)


/* Sexe */

mat define RESU1 = (.)
proportion 1.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(sexe)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat define RESU2 = (.)
proportion 2.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(sexe)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat define RESU3 = (.)
proportion 3.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(sexe)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'
	
mat define RESU4 = (.)
proportion 4.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(sexe)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'

mat define RESU5 = (.)
proportion 5.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(sexe)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'


/* Milieu de residence */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(milieu_resid2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(milieu_resid2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(milieu_resid2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

mat RESU4 = RESU4 \ (.)
proportion 4.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(milieu_resid2)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'
	
mat RESU5 = RESU5 \ (.)
proportion 5.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(milieu_resid2)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'

	
/* Niveau d'Instruction */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

mat RESU4 = RESU4 \ (.)
proportion 4.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'
	
mat RESU5 = RESU5 \ (.)
proportion 5.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'
	
	
/*Branche d'activité // à remettre quand les données seront codifier*/

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(branche2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(branche2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(branche2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

mat RESU4 = RESU4 \ (.)
proportion 4.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(branche2)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'

mat RESU5 = RESU5 \ (.)
proportion 5.CISE_18_new [pw=poids_men_vf] if trimestre == "T3", over(branche2)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'

**T2	
mat define RESU_ = (.,.,.,.,.)


/* Sexe */

mat define RESU_1 = (.)
proportion 1.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(sexe)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat define RESU_2 = (.)
proportion 2.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(sexe)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'

mat define RESU_3 = (.)
proportion 3.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(sexe)
mat list e(b)
mat RESU_3 = RESU_3 \ (e(b) * 100)'
	
mat define RESU_4 = (.)
proportion 4.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(sexe)
mat list e(b)
mat RESU_4 = RESU_4 \ (e(b) * 100)'

mat define RESU_5 = (.)
proportion 5.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(sexe)
mat list e(b)
mat RESU_5 = RESU_5 \ (e(b) * 100)'


/* Milieu de residence */

mat RESU_1 = RESU_1 \ (.)
proportion 1.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(milieu_resid2)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat RESU_2 = RESU_2 \ (.)
proportion 2.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(milieu_resid2)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'

mat RESU_3 = RESU_3 \ (.)
proportion 3.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(milieu_resid2)
mat list e(b)
mat RESU_3 = RESU_3 \ (e(b) * 100)'

mat RESU_4 = RESU_4 \ (.)
proportion 4.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(milieu_resid2)
mat list e(b)
mat RESU_4 = RESU_4 \ (e(b) * 100)'
	
mat RESU_5 = RESU_5 \ (.)
proportion 5.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(milieu_resid2)
mat list e(b)
mat RESU_5 = RESU_5 \ (e(b) * 100)'

	
/* Niveau d'Instruction */

mat RESU_1 = RESU_1 \ (.)
proportion 1.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat RESU_2 = RESU_2 \ (.)
proportion 2.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'

mat RESU_3 = RESU_3 \ (.)
proportion 3.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_3 = RESU_3 \ (e(b) * 100)'

mat RESU_4 = RESU_4 \ (.)
proportion 4.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_4 = RESU_4 \ (e(b) * 100)'
	
mat RESU_5 = RESU_5 \ (.)
proportion 5.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_5 = RESU_5 \ (e(b) * 100)'
	
	
/*Branche d'activité // à remettre quand les données seront codifier */

mat RESU_1 = RESU_1 \ (.)
proportion 1.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(branche2)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat RESU_2 = RESU_2 \ (.)
proportion 2.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(branche2)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'

mat RESU_3 = RESU_3 \ (.)
proportion 3.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(branche2)
mat list e(b)
mat RESU_3 = RESU_3 \ (e(b) * 100)'

mat RESU_4 = RESU_4 \ (.)
proportion 4.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(branche2)
mat list e(b)
mat RESU_4 = RESU_4 \ (e(b) * 100)'

mat RESU_5 = RESU_5 \ (.)
proportion 5.CISE_18_new [pw=poids_men_vf] if trimestre == "T2", over(branche2)
mat list e(b)
mat RESU_5 = RESU_5 \ (e(b) * 100)'
	
/* Consolidation de la matrice finale */
mat RESU = RESU_1, RESU1, RESU_2, RESU2, RESU_3, RESU3, RESU_4, RESU4, RESU_5, RESU5
	
*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = ///
    "Sexe" ///
        "Masculin" ///
        "Feminin" ///
	"Milieu de Résidence" ///
		"Abidjan" ///
		"Autre urbain" ///
		"Rural" ///
	"Niveau d'Instruction" ///
        "Aucun" ///
        "Primaire" ///
        "Secondaire" ///
        "Superieure" ///
	"Branche d'Activité'" ///
		"Secteur primaire" ///
		"Secteur secondaire" ///
		"Secteur tertiaire" ///
	
*Colonnes 

matrix colnames RESU = "Employeur T2" "Employeur T3" "indépendants sans employ T2" "indépendants sans employ T3"  "Entrepreneurs Non-salar dépe T2" "Entrepreneurs Non-salar dépe T3" "Employés T2" "Employés T3" "Travailleurs familiaux T2" "Travailleurs familiaux T3"

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Situation_Emp_PC") modify

/* Mise en forme */
putexcel B5 = matrix(RESU), colnames  nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel A2 = "Tableau 1 : Situation en Emploi selon les caractéristiques"
putexcel A2, bold border(bottom)


*En tête ligne du Tableau
putexcel A4 = "Caractéristiques Socio Demographiques"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close



/*------------------------------------------------------*/
/* X.x. Classifition internationale du statut dans l'emploi : Situation dans l'emploi Profil Colonne*/
/* Variables impliquées
CISE_18_niv2 : situation en emploi 10 modalités
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
branche2: Branche d'activité
Niv_inst_AG2 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/
**T3
mat define RESU = (.,.,.,.,.,.,.,.,.,.)


/* Sexe */

mat define RESU1 = (.)
proportion 1.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(sexe)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat define RESU2 = (.)
proportion 2.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(sexe)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat define RESU3 = (.)
proportion 3.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(sexe)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'
	
mat define RESU4 = (.)
proportion 4.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(sexe)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'

mat define RESU5 = (.)
proportion 5.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(sexe)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'

mat define RESU6 = (.)
proportion 6.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(sexe)
mat list e(b)
mat RESU6 = RESU6 \ (e(b) * 100)'

	
mat define RESU7 = (.)
proportion 7.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(sexe)
mat list e(b)
mat RESU7 = RESU7 \ (e(b) * 100)'
	
	
mat define RESU8 = (.)
proportion 8.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(sexe)
mat list e(b)
mat RESU8 = RESU8 \ (e(b) * 100)'
	

	mat define RESU9 = (.)
proportion 9.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(sexe)
mat list e(b)
mat RESU9 = RESU9 \ (e(b) * 100)'

	
mat define RESU10 = (.)
proportion 10.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(sexe)
mat list e(b)
mat RESU10 = RESU10 \ (e(b) * 100)'
	
	
/* Milieu de residence */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(milieu_resid2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(milieu_resid2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(milieu_resid2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

mat RESU4 = RESU4 \ (.)
proportion 4.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(milieu_resid2)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'
	
mat RESU5 = RESU5 \ (.)
proportion 5.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(milieu_resid2)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'
	
	
mat RESU6 = RESU6 \ (.)
proportion 6.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(milieu_resid2)
mat list e(b)
mat RESU6 = RESU6 \ (e(b) * 100)'
	
	
mat RESU7 = RESU7 \ (.)
proportion 7.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(milieu_resid2)
mat list e(b)
mat RESU7 = RESU7 \ (e(b) * 100)'

	
	
mat RESU8 = RESU8 \ (.)
proportion 8.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(milieu_resid2)
mat list e(b)
mat RESU8 = RESU8 \ (e(b) * 100)'
	
	
mat RESU9 = RESU9 \ (.)
proportion 9.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(milieu_resid2)
mat list e(b)
mat RESU9 = RESU9 \ (e(b) * 100)'
	
	
mat RESU10 = RESU10 \ (.)
proportion 10.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(milieu_resid2)
mat list e(b)
mat RESU10 = RESU10 \ (e(b) * 100)'

	
	/* Niveau d'Instruction */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

mat RESU4 = RESU4 \ (.)
proportion 4.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'
	
mat RESU5 = RESU5 \ (.)
proportion 5.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'

mat RESU6 = RESU6 \ (.)
proportion 6.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU6 = RESU6 \ (e(b) * 100)'

	
mat RESU7 = RESU7 \ (.)
proportion 7.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU7 = RESU7 \ (e(b) * 100)'

	
mat RESU8 = RESU8 \ (.)
proportion 8.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU8 = RESU8 \ (e(b) * 100)'


mat RESU9 = RESU9 \ (.)
proportion 9.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU9 = RESU9 \ (e(b) * 100)'


mat RESU10 = RESU10 \ (.)
proportion 10.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU10 = RESU10 \ (e(b) * 100)'


/* Branche d'activité */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

mat RESU4 = RESU4 \ (.)
proportion 4.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'

mat RESU5 = RESU5 \ (.)
proportion 5.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'


mat RESU6 = RESU6 \ (.)
proportion 6.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU6 = RESU6 \ (e(b) * 100)'


mat RESU7 = RESU7 \ (.)
proportion 7.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU7 = RESU7 \ (e(b) * 100)'


mat RESU8 = RESU8 \ (.)
proportion 8.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU8 = RESU8 \ (e(b) * 100)'


mat RESU9 = RESU9 \ (.)
proportion 9.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU9 = RESU9 \ (e(b) * 100)'

mat RESU10 = RESU10 \ (.)
proportion 10.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU10 = RESU10 \ (e(b) * 100)'

**T2
mat define RESU_ = (.,.,.,.,.,.,.,.,.,.)


/* Sexe */

mat define RESU_1 = (.)
proportion 1.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(sexe)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat define RESU_2 = (.)
proportion 2.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(sexe)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'

mat define RESU_3 = (.)
proportion 3.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(sexe)
mat list e(b)
mat RESU_3 = RESU_3 \ (e(b) * 100)'
	
mat define RESU_4 = (.)
proportion 4.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(sexe)
mat list e(b)
mat RESU_4 = RESU_4 \ (e(b) * 100)'

mat define RESU_5 = (.)
proportion 5.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(sexe)
mat list e(b)
mat RESU_5 = RESU_5 \ (e(b) * 100)'

mat define RESU_6 = (.)
proportion 6.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(sexe)
mat list e(b)
mat RESU_6 = RESU_6 \ (e(b) * 100)'

	
mat define RESU_7 = (.)
proportion 7.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(sexe)
mat list e(b)
mat RESU_7 = RESU_7 \ (e(b) * 100)'
	
	
mat define RESU_8 = (.)
proportion 8.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(sexe)
mat list e(b)
mat RESU_8 = RESU_8 \ (e(b) * 100)'
	

	mat define RESU_9 = (.)
proportion 9.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(sexe)
mat list e(b)
mat RESU_9 = RESU_9 \ (e(b) * 100)'

	
mat define RESU_10 = (.)
proportion 10.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(sexe)
mat list e(b)
mat RESU_10 = RESU_10 \ (e(b) * 100)'
	
	
/* Milieu de residence */

mat RESU_1 = RESU_1 \ (.)
proportion 1.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(milieu_resid2)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat RESU_2 = RESU_2 \ (.)
proportion 2.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(milieu_resid2)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'

mat RESU_3 = RESU_3 \ (.)
proportion 3.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(milieu_resid2)
mat list e(b)
mat RESU_3 = RESU_3 \ (e(b) * 100)'

mat RESU_4 = RESU_4 \ (.)
proportion 4.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(milieu_resid2)
mat list e(b)
mat RESU_4 = RESU_4 \ (e(b) * 100)'
	
mat RESU_5 = RESU_5 \ (.)
proportion 5.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(milieu_resid2)
mat list e(b)
mat RESU_5 = RESU_5 \ (e(b) * 100)'
	
	
mat RESU_6 = RESU_6 \ (.)
proportion 6.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(milieu_resid2)
mat list e(b)
mat RESU_6 = RESU_6 \ (e(b) * 100)'
	
	
mat RESU_7 = RESU_7 \ (.)
proportion 7.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(milieu_resid2)
mat list e(b)
mat RESU_7 = RESU_7 \ (e(b) * 100)'

	
	
mat RESU_8 = RESU_8 \ (.)
proportion 8.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(milieu_resid2)
mat list e(b)
mat RESU_8 = RESU_8 \ (e(b) * 100)'
	
	
mat RESU_9 = RESU_9 \ (.)
proportion 9.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(milieu_resid2)
mat list e(b)
mat RESU_9 = RESU_9 \ (e(b) * 100)'
	
	
mat RESU_10 = RESU_10 \ (.)
proportion 10.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(milieu_resid2)
mat list e(b)
mat RESU_10 = RESU_10 \ (e(b) * 100)'

	
	/* Niveau d'Instruction */

mat RESU_1 = RESU_1 \ (.)
proportion 1.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat RESU_2 = RESU_2 \ (.)
proportion 2.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'

mat RESU_3 = RESU_3 \ (.)
proportion 3.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_3 = RESU_3 \ (e(b) * 100)'

mat RESU_4 = RESU_4 \ (.)
proportion 4.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_4 = RESU_4 \ (e(b) * 100)'
	
mat RESU_5 = RESU_5 \ (.)
proportion 5.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_5 = RESU_5 \ (e(b) * 100)'

mat RESU_6 = RESU_6 \ (.)
proportion 6.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_6 = RESU_6 \ (e(b) * 100)'

	
mat RESU_7 = RESU_7 \ (.)
proportion 7.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_7 = RESU_7 \ (e(b) * 100)'

	
mat RESU_8 = RESU_8 \ (.)
proportion 8.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_8 = RESU_8 \ (e(b) * 100)'


mat RESU_9 = RESU_9 \ (.)
proportion 9.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_9 = RESU_9 \ (e(b) * 100)'


mat RESU_10 = RESU_10 \ (.)
proportion 10.CISE_18_niv2 [pw=poids_men_vf] if trimestre =="T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_10 = RESU_10 \ (e(b) * 100)'


/*Branche d'activité */

mat RESU_1 = RESU_1 \ (.)
proportion 1.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat RESU_2 = RESU_2 \ (.)
proportion 2.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'

mat RESU_3 = RESU_3 \ (.)
proportion 3.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU_3 = RESU_3 \ (e(b) * 100)'

mat RESU_4 = RESU_4 \ (.)
proportion 4.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU_4 = RESU_4 \ (e(b) * 100)'

mat RESU_5 = RESU_5 \ (.)
proportion 5.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU_5 = RESU_5 \ (e(b) * 100)'


mat RESU_6 = RESU_6 \ (.)
proportion 6.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU_6 = RESU_6 \ (e(b) * 100)'


mat RESU_7 = RESU_7 \ (.)
proportion 7.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU_7 = RESU_7 \ (e(b) * 100)'


mat RESU_8 = RESU_8 \ (.)
proportion 8.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU_8 = RESU_8 \ (e(b) * 100)'


mat RESU_9 = RESU_9 \ (.)
proportion 9.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU_9 = RESU_9 \ (e(b) * 100)'

mat RESU_10 = RESU_10 \ (.)
proportion 10.CISE_18_niv2 [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU_10 = RESU_10 \ (e(b) * 100)'

/* Consolidation de la matrice finale */
mat RESU = RESU_1, RESU1, RESU_2, RESU2, RESU_3, RESU3, RESU_4, RESU4, RESU_5, RESU5,RESU_6, RESU6, RESU_7, RESU7, RESU_8, RESU8, RESU_9, RESU9, RESU_10, RESU10
	
*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = ///
    "Sexe" ///
        "Masculin" ///
        "Feminin" ///
	"Milieu de Résidence" ///
		"Abidjan" ///
		"Autre urbain" ///
		"Rural" ///
	"Niveau d'Instruction" ///
        "Aucun" ///
        "Primaire" ///
        "Secondaire" ///
        "Superieure" ///
	"Branche d'Activité'" ///
		"Secteur primaire" ///
		"Secteur secondaire" ///
		"Secteur tertiaire" ///
	
*Colonnes 

matrix colnames RESU =  "Employeur entreprise/société T2" "Employeur entreprise/société T3" "Travailleur indép ménage T2" "Travailleur indép ménage T3"  "Trav indép sans employés T2" "Trav indép sans employés T3" "Trav indép entrep familiales T2" "Trav indép entrep familiales T3" "Travailleur familiaux T2" " Travailleur familiaux T3" "Contractuel dépendant T2" "Contractuel dépendant T3" "Apprenti, stagiaire rémunéré T2" "Apprenti, stagiaire rémunéré T3" "Employé permanent T2" "Employé permanent T3" "Employé à durée déterminée T2" "Employé à durée déterminée T3" "Employé temp et occa T2" "Employé temp et occa T3"

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Situation_Emp_PC_1") modify

/* Mise en forme */
putexcel B5 = matrix(RESU), colnames  nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel A2 = "Tableau 1 : Situation en Emploi avec les 10 modalités selon les caractéristiques"
putexcel A2, bold border(bottom)


*En tête ligne du Tableau
putexcel A4 = "Caractéristiques Socio Demographiques"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close



/*------------------------------------------------------*/
/* X.x. Classifition internationale du statut dans l'emploi : Situation dans l'emploi Profil Colonne*/
/* Variables impliquées
CISE_18_informel : Secteur (formel/informel/menage) 3 modalités
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
branche2: Branche d'activité
Niv_inst_AG2 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/
**T3
mat define RESU = (.,.,.)


/* Sexe */

mat define RESU1 = (.)
proportion 1.CISE_18_informel [pw=poids_men_vf] if trimestre == "T3", over(sexe)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat define RESU2 = (.)
proportion 2.CISE_18_informel [pw=poids_men_vf] if trimestre == "T3", over(sexe)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat define RESU3 = (.)
proportion 3.CISE_18_informel [pw=poids_men_vf] if trimestre == "T3", over(sexe)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'


/* Milieu de residence */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_informel [pw=poids_men_vf] if trimestre == "T3", over(milieu_resid2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_informel [pw=poids_men_vf] if trimestre == "T3", over(milieu_resid2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_informel [pw=poids_men_vf] if trimestre == "T3", over(milieu_resid2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'


	/* Niveau d'Instruction */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_informel [pw=poids_men_vf] if trimestre == "T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_informel [pw=poids_men_vf] if trimestre == "T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_informel [pw=poids_men_vf] if trimestre == "T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'


/*Branche d'activité*/

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_informel [pw=poids_men_vf] if trimestre == "T3", over(branche2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_informel [pw=poids_men_vf] if trimestre == "T3", over(branche2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_informel [pw=poids_men_vf] if trimestre == "T3", over(branche2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

**T2
mat define RESU_ = (.,.,.)


/* Sexe */

mat define RESU_1 = (.)
proportion 1.CISE_18_informel [pw=poids_men_vf] if trimestre == "T2", over(sexe)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat define RESU_2 = (.)
proportion 2.CISE_18_informel [pw=poids_men_vf] if trimestre == "T2", over(sexe)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'

mat define RESU_3 = (.)
proportion 3.CISE_18_informel [pw=poids_men_vf] if trimestre == "T2", over(sexe)
mat list e(b)
mat RESU_3 = RESU_3 \ (e(b) * 100)'


/* Milieu de residence */

mat RESU_1 = RESU_1 \ (.)
proportion 1.CISE_18_informel [pw=poids_men_vf] if trimestre == "T2", over(milieu_resid2)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat RESU_2 = RESU_2 \ (.)
proportion 2.CISE_18_informel [pw=poids_men_vf] if trimestre == "T2", over(milieu_resid2)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'

mat RESU_3 = RESU_3 \ (.)
proportion 3.CISE_18_informel [pw=poids_men_vf] if trimestre == "T2", over(milieu_resid2)
mat list e(b)
mat RESU_3 = RESU_3 \ (e(b) * 100)'


	/* Niveau d'Instruction */

mat RESU_1 = RESU_1 \ (.)
proportion 1.CISE_18_informel [pw=poids_men_vf] if trimestre == "T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat RESU_2 = RESU_2 \ (.)
proportion 2.CISE_18_informel [pw=poids_men_vf] if trimestre == "T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'

mat RESU_3 = RESU_3 \ (.)
proportion 3.CISE_18_informel [pw=poids_men_vf] if trimestre == "T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_3 = RESU_3 \ (e(b) * 100)'


/*Branche d'activité*/ 

mat RESU_1 = RESU_1 \ (.)
proportion 1.CISE_18_informel [pw=poids_men_vf] if trimestre == "T2", over(branche2)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat RESU_2 = RESU_2 \ (.)
proportion 2.CISE_18_informel [pw=poids_men_vf] if trimestre == "T2", over(branche2)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'

mat RESU_3 = RESU_3 \ (.)
proportion 3.CISE_18_informel [pw=poids_men_vf] if trimestre == "T2", over(branche2)
mat list e(b)
mat RESU_3 = RESU_3 \ (e(b) * 100)'


/* Consolidation de la matrice finale */
mat RESU = RESU_1, RESU1, RESU_2, RESU2, RESU_3, RESU3


*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = ///
    "Sexe" ///
        "Masculin" ///
        "Feminin" ///
	"Milieu de Résidence" ///
		"Abidjan" ///
		"Autre urbain" ///
		"Rural" ///
	"Niveau d'Instruction" ///
        "Aucun" ///
        "Primaire" ///
        "Secondaire" ///
        "Superieure" ///
	"Branche d'Activité'" ///
		"Secteur primaire" ///
		"Secteur secondaire" ///
		"Secteur tertiaire" ///
	
*Colonnes 

matrix colnames RESU =  "Secteur Formel T2" "Secteur Formel T3"  "Secteur Informel T2" "Secteur Informel T3" "Ménages T2" "Ménages T3"


/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Situation_Emp_PC_2") modify

/* Mise en forme */
putexcel B5 = matrix(RESU), colnames  nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel A2 = "Tableau 1 : Situation en Emploi avec les Secteurs formel/informel/menage selon les caractéristiques"
putexcel A2, bold border(bottom)


*En tête ligne du Tableau
putexcel A4 = "Caractéristiques Socio Demographiques"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close




/*------------------------------------------------------*/
/* X.x. Classifition internationale du statut dans l'emploi : Formalite de l'emploi Profil Colonne*/
/* Variables impliquées
CISE_18_informel : Emploi formel/informel 2 modalités
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
branche2: Branche d'activité
Niv_inst_AG2 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/
**T3
mat define RESU = (.,.,.)


/* Sexe */

mat define RESU1 = (.)
proportion 1.CISE_18_informel_Emp [pw=poids_men_vf] if trimestre== "T3", over(sexe)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat define RESU2 = (.)
proportion 2.CISE_18_informel_Emp [pw=poids_men_vf] if trimestre== "T3", over(sexe)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'


/* Milieu de residence */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_informel_Emp [pw=poids_men_vf] if trimestre== "T3", over(milieu_resid2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_informel_Emp [pw=poids_men_vf] if trimestre== "T3", over(milieu_resid2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'


	/* Niveau d'Instruction */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_informel_Emp [pw=poids_men_vf] if trimestre== "T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_informel_Emp [pw=poids_men_vf] if trimestre== "T3", over(Niv_inst_AG2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'



/* Branche d'activité */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_informel_Emp [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_informel_Emp [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)' 

**T2
mat define RESU_ = (.,.,.)


/* Sexe */

mat define RESU_1 = (.)
proportion 1.CISE_18_informel_Emp [pw=poids_men_vf] if trimestre== "T2", over(sexe)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat define RESU_2 = (.)
proportion 2.CISE_18_informel_Emp [pw=poids_men_vf] if trimestre== "T2", over(sexe)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'


/* Milieu de residence */

mat RESU_1 = RESU_1 \ (.)
proportion 1.CISE_18_informel_Emp [pw=poids_men_vf] if trimestre== "T2", over(milieu_resid2)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat RESU_2 = RESU_2 \ (.)
proportion 2.CISE_18_informel_Emp [pw=poids_men_vf] if trimestre== "T2", over(milieu_resid2)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'


	/* Niveau d'Instruction */

mat RESU_1 = RESU_1 \ (.)
proportion 1.CISE_18_informel_Emp [pw=poids_men_vf] if trimestre== "T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat RESU_2 = RESU_2 \ (.)
proportion 2.CISE_18_informel_Emp [pw=poids_men_vf] if trimestre== "T2", over(Niv_inst_AG2)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)'



/* Branche d'activité */

mat RESU_1 = RESU_1 \ (.)
proportion 1.CISE_18_informel_Emp [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU_1 = RESU_1 \ (e(b) * 100)'

mat RESU_2 = RESU_2 \ (.)
proportion 2.CISE_18_informel_Emp [pw=poids_men_vf], over(branche2)
mat list e(b)
mat RESU_2 = RESU_2 \ (e(b) * 100)' 

/* Consolidation de la matrice finale */
mat RESU = RESU_1, RESU1, RESU_2, RESU2


*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = ///
    "Sexe" ///
        "Masculin" ///
        "Feminin" ///
	"Milieu de Résidence" ///
		"Abidjan" ///
		"Autre urbain" ///
		"Rural" ///
	"Niveau d'Instruction" ///
        "Aucun" ///
        "Primaire" ///
        "Secondaire" ///
        "Superieure" ///
	"Branche d'Activité'" ///
		"Secteur primaire" ///
		"Secteur secondaire" ///
		"Secteur tertiaire" ///
	
*Colonnes 

matrix colnames RESU =  "Emploi Formel T2" "Emploi Formel T3" "Emploi Informel T2"  "Emploi Informel T3" 


/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Situation_Emp_PC_3") modify

/* Mise en forme */
putexcel B5 = matrix(RESU), colnames  nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel A2 = "Tableau 1 : Formalité de l'emploi formel/informel selon les caractéristiques"
putexcel A2, bold border(bottom)


*En tête ligne du Tableau
putexcel A4 = "Caractéristiques Socio Demographiques"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close





























/*


/* X.x. Situation dans l'emploi Profil Ligne*/
/* Variables impliquées
sit_emp : situation en emploi
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
branche2: Branche d'activité
Niv_inst_AG2 : Niveau d'instruction en 5 modalités
*/



*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------ une modalité n'esiste pas*/

mat define RESU = (.,.,.)


/* Sexe */
proportion sexe [pw=poids_men_vf], over(sit_empEP_Autorite)
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),1..3] * 100)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),4..6] * 100)


/* Milieu de résidence */
mat RESU = RESU \ (.,.,.)
proportion milieu_resid2 [pw=poids_men_vf], over(sit_empEP_Autorite)
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),1..3] * 100)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),4..6] * 100)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),7..9] * 100)

/* Niveau d'Instruction */
mat RESU = RESU \ (.,.,.)
proportion Niv_inst_AG2 [pw=poids_men_vf], over(sit_empEP_Autorite)
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),1..3] * 100)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),4..6] * 100)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),7..9] * 100)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),10..12] * 100)

/* Branche d'activité */
mat RESU = RESU \ (.,.,.)
proportion branche2 [pw=poids_men_vf], over(sit_empEP_Autorite)
mat list e(b)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),1..3] * 100)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),4..6] * 100)
mat RESU = RESU \ (r(table)[rownumb(r(table),"b"),7..9] * 100)

*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = ///
    "Sexe" ///
        "Masculin" ///
        "Feminin" ///
	"Milieu de Résidence" ///
		"Abidjan" ///
		"Autre urbain" ///
		"Rural" ///
	"Niveau d'Instruction" ///
        "Aucun" ///
        "Primaire" ///
        "Secondaire" ///
        "Superieure" ///
	"Branche d'Activité'" ///
		"Secteur primaire" ///
		"Secteur secondaire" ///
		"Secteur tertiaire" ///
	
*Colonnes 

matrix colnames RESU = "Travailleurs indépendants" "Travailleurs dépendants"  "Non classé"
			
/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Situation_Emp_PL") modify

/* Mise en forme */
putexcel B5 = matrix(RESU), colnames  nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel A2 = "Tableau 1 : Situation en Emploi selon les caractéristiques (Profil Ligne)"
putexcel A2, bold border(bottom)


*En tête ligne du Tableau
putexcel A4 = "Caractéristiques Socio Demographiques"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

 
*/

* 3.2. Branche d'activité */

/* 3.3. Branche d'activité */
/* Variables impliquées 
branche1 : branche d'activité à quatre modalités
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
groupe_age4 : groupe d'âge d'âge en 4 modalités
Niv_inst_AG3 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/
		
/* 3.2. Population au chomage */

/* Colonne des effectifs */

**T3

/* Milieu de résidence */
total i.branche1 [pw=poids_men_vf] if trimestre == "T3", over(milieu_resid2) 
mat list e(b)
mat define RESU1 = ((r(table)[rownumb(r(table),"b"),1..3])', (r(table)[rownumb(r(table),"b"),4..6])', (r(table)[rownumb(r(table),"b"),7..9])', (r(table)[rownumb(r(table),"b"),10..12])')
mat RESU1 = J(1,4,.)\RESU1

/* Sexe */
mat RESU1 = RESU1 \ J(1,4,.)
total i.branche1 [pw=poids_men_vf] if trimestre == "T3", over(sexe) 
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),1..2])', (r(table)[rownumb(r(table),"b"),3..4])', (r(table)[rownumb(r(table),"b"),5..6])', (r(table)[rownumb(r(table),"b"),7..8])')

/*Groupe d'Age */
mat RESU1 = RESU1 \ J(1,4,.)
total i.branche1 [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4)
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),1..4])', (r(table)[rownumb(r(table),"b"),5..8])', (r(table)[rownumb(r(table),"b"),9..12])', (r(table)[rownumb(r(table),"b"),13..16])')

/* Niveau d'instruction */
mat RESU1 = RESU1 \ J(1,4,.)
total i.branche1 [pw=poids_men_vf] if trimestre == "T3", over(Niv_inst_AG3)
mat list e(b)
mat RESU1 = RESU1 \ ((r(table)[rownumb(r(table),"b"),1..5])', (r(table)[rownumb(r(table),"b"),6..10])', (r(table)[rownumb(r(table),"b"),11..15])', (r(table)[rownumb(r(table),"b"),16..20])')
mat list RESU1

/* Ensemble */
mat RESU1 = RESU1 \ J(1,4,.)
total i.branche1 [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU1 = RESU1 \ (r(table)[rownumb(r(table),"b"),1..4])
mat list RESU1

mat RESU = RESU1

**T2

/* Milieu de résidence */
total i.branche1 [pw=poids_men_vf] if trimestre == "T2", over(milieu_resid2) 
mat list e(b)
mat define RESU1_ = ((r(table)[rownumb(r(table),"b"),1..3])', (r(table)[rownumb(r(table),"b"),4..6])', (r(table)[rownumb(r(table),"b"),7..9])', (r(table)[rownumb(r(table),"b"),10..12])')

mat RESU1_ = J(1,4,.) \ RESU1_

/* Sexe */
mat RESU1_ = RESU1_ \ J(1,4,.)
total i.branche1 [pw=poids_men_vf] if trimestre == "T2", over(sexe) 
mat list e(b)
mat RESU1_ = RESU1_ \ ((r(table)[rownumb(r(table),"b"),1..2])', (r(table)[rownumb(r(table),"b"),3..4])', (r(table)[rownumb(r(table),"b"),5..6])', (r(table)[rownumb(r(table),"b"),7..8])')


/*Groupe d'Age */
mat RESU1_ = RESU1_ \ J(1,4,.)
total i.branche1 [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4)
mat list e(b)
mat RESU1_ = RESU1_ \ ((r(table)[rownumb(r(table),"b"),1..4])', (r(table)[rownumb(r(table),"b"),5..8])', (r(table)[rownumb(r(table),"b"),9..12])', (r(table)[rownumb(r(table),"b"),13..16])')

/* Niveau d'instruction */
mat RESU1_ = RESU1_ \ J(1,4,.)
total i.branche1 [pw=poids_men_vf] if trimestre == "T2", over(Niv_inst_AG3)
mat list e(b)
mat RESU1_ = RESU1_ \ ((r(table)[rownumb(r(table),"b"),1..5])', (r(table)[rownumb(r(table),"b"),6..10])', (r(table)[rownumb(r(table),"b"),11..15])', (r(table)[rownumb(r(table),"b"),16..20])')

/* Ensemble */
mat RESU1_ = RESU1_ \ J(1,4,.)
total i.branche1 [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU1_ = RESU1_ \ (r(table)[rownumb(r(table),"b"),1..4])

mat RESU_ = RESU1_

/* Colonne pourcentage ligne */
**T3

/* Milieu de résidence */
proportion 1.branche1 [pw=poids_men_vf] if age >= 16 & trimestre == "T3" , over(milieu_resid2) 
mat define RESU1 = e(b)'*100

proportion 2.branche1 [pw=poids_men_vf] if age >= 16 & trimestre == "T3" , over(milieu_resid2) 
mat RESU1 = RESU1, e(b)'*100

proportion 3.branche1 [pw=poids_men_vf] if age >= 16 & trimestre == "T3" , over(milieu_resid2) 
mat RESU1 = RESU1, e(b)'*100

proportion 4.branche1 [pw=poids_men_vf] if age >= 16 & trimestre == "T3" , over(milieu_resid2) 
mat RESU1 = RESU1, e(b)'*100

mat RESU1 = J(1,4,.) \ RESU1


/* Sexe */
proportion 1.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(sexe) 
mat list e(b)
mat define RESU1__S = e(b)'*100

proportion 2.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(sexe) 
mat list e(b)
mat RESU1__S = RESU1__S, e(b)'*100

proportion 3.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(sexe) 
mat list e(b)
mat RESU1__S = RESU1__S, e(b)'*100


proportion 4.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(sexe) 
mat list e(b)
mat RESU1__S = RESU1__S, e(b)'*100

mat RESU1 = RESU1 \ J(1,4,.)
mat RESU1 = RESU1 \ RESU1__S


/*Groupe d'Age */
proportion 1.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4) 
mat list e(b)
mat define RESU1__GrpeAge = e(b)'*100

proportion 2.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4) 
mat list e(b)
mat RESU1__GrpeAge = RESU1__GrpeAge, e(b)'*100

proportion 3.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4) 
mat list e(b)
mat RESU1__GrpeAge = RESU1__GrpeAge, e(b)'*100


proportion 4.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(groupe_age4) 
mat list e(b)
mat RESU1__GrpeAge = RESU1__GrpeAge, e(b)'*100

mat RESU1 = RESU1 \ J(1,4,.)
mat RESU1 = RESU1 \ RESU1__GrpeAge

/* Niveau d'Instruction */
proportion 1.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(Niv_inst_AG3) 
mat list e(b)
mat define RESU1__NivInst = e(b)'*100

proportion 2.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(Niv_inst_AG3) 
mat list e(b)
mat RESU1__NivInst = RESU1__NivInst, e(b)'*100

proportion 3.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(Niv_inst_AG3) 
mat list e(b)
mat RESU1__NivInst = RESU1__NivInst, e(b)'*100


proportion 4.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(Niv_inst_AG3) 
mat list e(b)
mat RESU1__NivInst = RESU1__NivInst, e(b)'*100

mat RESU1 = RESU1 \ J(1,4,.)
mat RESU1 = RESU1 \ RESU1__NivInst

/* Ensemble */
proportion 1.branche1 [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat define RESU1__Ens = e(b)'*100

proportion 2.branche1 [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU1__Ens = RESU1__Ens, e(b)'*100

proportion 3.branche1 [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU1__Ens = RESU1__Ens, e(b)'*100

proportion 4.branche1 [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU1__Ens = RESU1__Ens, e(b)'*100

mat RESU1 = RESU1 \ J(1,4,.)
mat RESU1 = RESU1 \ RESU1__Ens

**T2
/* Milieu de résidence */
proportion 1.branche1 [pw=poids_men_vf] if age >= 16 & trimestre == "T2" , over(milieu_resid2) 
mat define RESU1_ = e(b)'*100

proportion 2.branche1 [pw=poids_men_vf] if age >= 16 & trimestre == "T2" , over(milieu_resid2) 
mat RESU1_ = RESU1_, e(b)'*100

proportion 3.branche1 [pw=poids_men_vf] if age >= 16 & trimestre == "T2" , over(milieu_resid2) 
mat RESU1_ = RESU1_, e(b)'*100

proportion 4.branche1 [pw=poids_men_vf] if age >= 16 & trimestre == "T2" , over(milieu_resid2) 
mat RESU1_ = RESU1_, e(b)'*100

mat RESU1_ = J(1,4,.) \ RESU1_


/* Sexe */
proportion 1.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(sexe) 
mat list e(b)
mat define RESU1__S = e(b)'*100

proportion 2.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(sexe) 
mat list e(b)
mat RESU1__S = RESU1__S, e(b)'*100

proportion 3.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(sexe) 
mat list e(b)
mat RESU1__S = RESU1__S, e(b)'*100


proportion 4.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(sexe) 
mat list e(b)
mat RESU1__S = RESU1__S, e(b)'*100

mat RESU1_ = RESU1_ \ J(1,4,.)
mat RESU1_ = RESU1_ \ RESU1__S


/*Groupe d'Age */
proportion 1.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4) 
mat list e(b)
mat define RESU1__GrpeAge = e(b)'*100

proportion 2.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4) 
mat list e(b)
mat RESU1__GrpeAge = RESU1__GrpeAge, e(b)'*100

proportion 3.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4) 
mat list e(b)
mat RESU1__GrpeAge = RESU1__GrpeAge, e(b)'*100


proportion 4.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(groupe_age4) 
mat list e(b)
mat RESU1__GrpeAge = RESU1__GrpeAge, e(b)'*100

mat RESU1_ = RESU1_ \ J(1,4,.)
mat RESU1_ = RESU1_ \ RESU1__GrpeAge

/* Niveau d'Instruction */
proportion 1.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(Niv_inst_AG3) 
mat list e(b)
mat define RESU1__NivInst = e(b)'*100

proportion 2.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(Niv_inst_AG3) 
mat list e(b)
mat RESU1__NivInst = RESU1__NivInst, e(b)'*100

proportion 3.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(Niv_inst_AG3) 
mat list e(b)
mat RESU1__NivInst = RESU1__NivInst, e(b)'*100


proportion 4.branche1  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(Niv_inst_AG3) 
mat list e(b)
mat RESU1__NivInst = RESU1__NivInst, e(b)'*100

mat RESU1_ = RESU1_ \ J(1,4,.)
mat RESU1_ = RESU1_ \ RESU1__NivInst

/* Ensemble */
proportion 1.branche1 [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat define RESU1__Ens = e(b)'*100

proportion 2.branche1 [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU1__Ens = RESU1__Ens, e(b)'*100

proportion 3.branche1 [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU1__Ens = RESU1__Ens, e(b)'*100

proportion 4.branche1 [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU1__Ens = RESU1__Ens, e(b)'*100

mat RESU1_ = RESU1_ \ J(1,4,.)
mat RESU1_ = RESU1_ \ RESU1__Ens

		
/* Colonne pourcentage profil colonne */
**T3

/* Milieu de résidence */
proportion milieu_resid2  [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(branche1) 
mat list e(b)
mat define RESU2 = ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8] * 100)',(r(table)[rownumb(r(table),"b"),9..12] * 100)')'
mat RESU2 = J(1,4,.) \ RESU2


/* Sexe */
mat RESU2 = RESU2 \ J(1,4,.)
proportion sexe [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(branche1) 
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8] * 100)')'

/*Groupe d'Age */
mat RESU2 = RESU2 \ J(1,4,.)
proportion groupe_age4 [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(branche1)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8] * 100)',(r(table)[rownumb(r(table),"b"),9..12] * 100)',(r(table)[rownumb(r(table),"b"),13..16] * 100)')'

/* Niveau d'Instruction */
mat RESU2 = RESU2 \ J(1,4,.)
proportion Niv_inst_AG3 [pw=poids_men_vf] if age >= 16 & trimestre == "T3", over(branche1)
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8] * 100)',(r(table)[rownumb(r(table),"b"),9..12] * 100)',(r(table)[rownumb(r(table),"b"),13..16] * 100)',(r(table)[rownumb(r(table),"b"),17..20] * 100)')'
/* Ensemble */
mat RESU2 = RESU2 \ J(1,4,.)
proportion branche1 [pw=poids_men_vf] if trimestre == "T3"
mat list e(b)
mat RESU2 = RESU2 \ ((r(table)[rownumb(r(table),"b"),1..4] * 100))

**T2

/* Milieu de résidence */
proportion milieu_resid2  [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(branche1) 
mat list e(b)
mat define RESU2_ = ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8] * 100)',(r(table)[rownumb(r(table),"b"),9..12] * 100)')'
mat RESU2_ = J(1,4,.) \ RESU2_


/* Sexe */
mat RESU2_ = RESU2_ \ J(1,4,.)
proportion sexe [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(branche1) 
mat list e(b)
mat RESU2_ = RESU2_ \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8] * 100)')'

/*Groupe d'Age */
mat RESU2_ = RESU2_ \ J(1,4,.)
proportion groupe_age4 [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(branche1)
mat list e(b)
mat RESU2_ = RESU2_ \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8] * 100)',(r(table)[rownumb(r(table),"b"),9..12] * 100)',(r(table)[rownumb(r(table),"b"),13..16] * 100)')'

/* Niveau d'Instruction */
mat RESU2_ = RESU2_ \ J(1,4,.)
proportion Niv_inst_AG3 [pw=poids_men_vf] if age >= 16 & trimestre == "T2", over(branche1)
mat list e(b)
mat RESU2_ = RESU2_ \ ((r(table)[rownumb(r(table),"b"),1..4] * 100)',(r(table)[rownumb(r(table),"b"),5..8] * 100)',(r(table)[rownumb(r(table),"b"),9..12] * 100)',(r(table)[rownumb(r(table),"b"),13..16] * 100)',(r(table)[rownumb(r(table),"b"),17..20] * 100)')'
/* Ensemble */
mat RESU2_ = RESU2_ \ J(1,4,.)
proportion branche1 [pw=poids_men_vf] if trimestre == "T2"
mat list e(b)
mat RESU2_ = RESU2_ \ ((r(table)[rownumb(r(table),"b"),1..4] * 100))
/* Fusion des deux colonnes */

mat RESU__ = RESU_, RESU, RESU1_, RESU1, RESU2_, RESU2

mat RESU = RESU_[1...,1], RESU[1...,1], RESU1_[1...,1], RESU1[1...,1], RESU2_[1...,1], RESU2[1...,1],  RESU_[1...,2], RESU[1...,2], RESU1_[1...,2], RESU1[1...,2], RESU2_[1...,2], RESU2[1...,2],  RESU_[1...,3], RESU[1...,3], RESU1_[1...,3], RESU1[1...,3], RESU2_[1...,3], RESU2[1...,3],  RESU_[1...,4], RESU[1...,4], RESU1_[1...,4], RESU1[1...,4], RESU2_[1...,4], RESU2[1...,4]


		*b. Mise en forme du Tableau 
		/*---------------------------*/
		
/* Définition des entête de lignes et colonnes */

*Lignes 

matrix rownames RESU = "Milieu de Residence" "Abidjan" "Autre Urbain" "Rural" "Sexe" "Masculin" "Feminin" "Groupe d'Age" "16-24 ans" "25-35 ans" "36-64 ans" "65 ans et plus"  "Niveau d'Instruction"  "Aucun" "Primaire" "Secondaire  1er Cycle" "Secondaire  2nd Cycle" "Superieur" "Total" "Ensemble"

matrix rownames RESU__ = "Milieu de Residence" "Abidjan" "Autre Urbain" "Rural" "Sexe" "Masculin" "Feminin" "Groupe d'Age" "16-24 ans" "25-35 ans" "36-64 ans" "65 ans et plus"  "Niveau d'Instruction"  "Aucun" "Primaire" "Secondaire  1er Cycle" "Secondaire  2nd Cycle" "Superieur" "Total" "Ensemble"

*Colonnes 

matrix colnames RESU = "Effectif T2" "Effectif T3" "(% Profil Ligne T2)" "(% Profil Ligne T3)" "(% Profil Colonne T2)" "(% Profil Colonne T3)" "Effectif T2" "Effectif T3" "(% Profil Ligne T2)" "(% Profil Ligne T3)" "(% Profil Colonne T2)" "(% Profil Colonne T3)" "Effectif T2" "Effectif T3" "(% Profil Ligne T2)" "(% Profil Ligne T3)" "(% Profil Colonne T2)" "(% Profil Colonne T3)" "Effectif T2" "Effectif T3" "(% Profil Ligne T2)" "(% Profil Ligne T3)" "(% Profil Colonne T2)" "(% Profil Colonne T3)"

matrix colnames RESU__ = "Agriculture" "Industrie" "Commerce" "Autres Services" "Agriculture" "Industrie" "Commerce" "Autres Services" "Agriculture" "Industrie" "Commerce" "Autres Services" "Agriculture" "Industrie" "Commerce" "Autres Services" "Agriculture" "Industrie" "Commerce" "Autres Services" "Agriculture" "Industrie" "Commerce" "Autres Services"

/* Exportation sur Excel dans le dossier Resultats_Tab de RESU*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Branche_activite") modify
/* Mise en forme */
putexcel B5 = matrix(RESU), colnames  nformat(number_d2)
putexcel A6 = matrix(RESU), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Répartition des branches d'activité selon les caractéristiques des individus "
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Branches d'activité'"
putexcel (B3:Y3), merge

*En tête des branches
putexcel B4 = "Agriculture"
putexcel (B4:G4), merge

putexcel H4 = "Industrie"
putexcel (H4:M4), merge

putexcel N4 = "Commerce"
putexcel (N4:S4), merge

putexcel T4 = "Autre service"
putexcel (T4:Y4), merge

*En tête ligne du Tableau
putexcel A4 = "Caractéristiques Socio Demographiques"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close

/* Exportation sur Excel dans le dossier Resultats_Tab de RESU__*/


putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Branche_activite2") modify
/* Mise en forme */
putexcel B5 = matrix(RESU__), colnames  nformat(number_d2)
putexcel A6 = matrix(RESU__), rownames

/* Titre du tableau */
putexcel B1 = "Tableau : Répartition des branches d'activité selon les caractéristiques des individus"
putexcel B1, bold border(bottom)

*En tête colonne du Tableau
putexcel B3 = "Branches d'activité'"
putexcel (B3:Y3), merge

*En tête des branches
putexcel B4 = "Effectif T2"
putexcel (B4:E4), merge

putexcel F4 =  "Effectif T3"
putexcel (F4:I4), merge

putexcel J4 = "(% Profil Ligne T2)"
putexcel (J4:M4), merge

putexcel N4 = "(% Profil Ligne T3)"
putexcel (N4:Q4), merge

putexcel R4 = "(% Profil Colonne T2)"
putexcel (R4:U4), merge

putexcel V4 = "(% Profil Colonne T3)"
putexcel (V4:Y4), merge

*En tête ligne du Tableau
putexcel A4 = "Caractéristiques Socio Demographiques"
putexcel (A4:A5), merge

*Sauvegarde définitive du Tableau
putexcel save

*Fermeture du fichier
putexcel close


