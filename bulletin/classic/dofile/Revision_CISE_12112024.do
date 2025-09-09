

***** ENEM 2024 *****************************************
** PRISE EN COMPTE DE LA 20e et la 21e 
** CALCUL ICSE 18 et FORMALITE DE L'EMPLOI ET DU SECTEUR
***********************************************************


/*

cap drop age
gen age = M4Confirm if AgeAnnee >= 13 
	replace age = AgeAnnee if AgeAnnee < 13
		lab var age "Age de l'individu"
ta age, mis


*========== 		Population en âge de travailler		============*
cap drop PAT
gen PAT= (age>=16 & age<.)
		lab var PAT "population en âge de travailler selon le BIT"
		cap label drop PAT
		lab define PAT 1 "Oui" 0 "Non"
		label values PAT PAT
tab PAT		/* PAT:  19 */

* Note: Etre sûr que tous les individus de la base ont un age dé




cap drop PAT
gen PAT= (M4Confirm>=16 & M4Confirm<.)
		lab var PAT "population en âge de travailler selon le BIT"
		cap label drop PAT
		lab define PAT 1 "Oui" 0 "Non"
		label values PAT PAT
tab PAT		/* PAT:  19 */

cap drop emp_present
gen emp_present = 0 if PAT == 1
	replace emp_present = 1 if SE1==1 & PAT == 1	// Individus ayant travaillé en échange d'une rémunération
	replace emp_present = 1 if (SE1 == 2 & inrange(SE2, 1, 9)) & PAT == 1 // Individus ayant exercé une activité particulière 
	replace emp_present = 1 if (SE2 == 10 & inrange(SE3, 1, 2))& PAT == 1 // Apprentis et stagiaires payés
	replace emp_present = 1 if (inrange(SE3, 3, 5) & SE4==1)& PAT == 1 // Activité économique ou agricole rémunérée
	replace emp_present = 1 if (SE4 == 2 & SE5 == 1 & inlist(SE7, 1, 2))& PAT == 1 // Travailleurs familiaux

		lab var emp_present "Population en emploi présent"
		lab values emp_present PAT
tab emp_present


cap drop emp_absent
gen emp_absent = 0 if PAT == 1 
	replace emp_absent = 1 if ((SE5==2 | inlist(SE7, 3, 4)) & (SE8==1 & inrange(SE9,1,4))) & PAT == 1
	tab emp_absent
					// Travailleurs en congés classiques 
	replace emp_absent = 1 if ((SE5==2 | inlist(SE7, 3, 4)) & (SE8==1 & SE9==10 & SE9A==1)) & PAT == 1
	tab emp_absent // Fin de campagne agricole (basse saison mais reste en activité)
	replace emp_absent = 1 if ((SE5==2 | inlist(SE7, 3, 4)) & (SE8==1 & SE9==14 & SE9B==1))& PAT == 1 
	tab emp_absent // Congés sabbatiques mais en activité
	replace emp_absent = 1 if ((SE5==2 | inlist(SE7, 3, 4)) & (SE8==1 & (inrange(SE9, 5,9) | inlist(SE9, 11, 12, 15, 16, 17)) & SE10==1))& PAT == 1 
	tab emp_absent // Travailleurs en congés non conventionnels dont la durée n'excedera pas 3 mois
	replace emp_absent = 1 if ((SE5==2 | inlist(SE7, 3, 4)) & (SE8==1 & (inrange(SE9, 5,9) | inlist(SE9, 11, 12, 15, 16, 17)) & SE10==2 & SE11==1)) & PAT == 1 
	tab emp_absent // Travailleurs en congés non conventionnels excédant 3 mois mais qui continue d'être rémunéré
	
		lab var emp_absent "Population absent à leur poste de travail"
		lab values emp_absent PAT

*/

cap drop pop_emp_dich
gen pop_emp_dich = 0 if PAT == 1
replace pop_emp_dich = 1 if emp_present == 1 & PAT == 1	
replace pop_emp_dich = 1 if emp_absent == 1 & PAT == 1
		label var pop_emp_dich "Population en emploi"
		cap label drop pop_emp_dich
		lab define pop_emp_dich 1 "Emploi " 2 "Pas en Emploi"
		label values pop_emp_dich pop_emp_dich
ta pop_emp_dich		/* pop emploi: 4 	*/


/*

 CREATION DE LA VARIABLE STATUS IN EMPLOYMENT CISE 18
 LES MODALITES SONT :
 1. EMPLOYERS
 2. INDEPENDENT WORKERS WITHOUT EMPLOYEES
 3. DEPENDENT CONTRACTORS
 4. EMPLOYEES
 5. CONTRIBUTING FAMILY WORKERS
 
 
*/

cap drop CISE_18_new
gen CISE_18_new =. 


*Modalité 1 == EMPLOYERS / Employeurs

replace CISE_18_new=1 if inlist(EP3,2,3,4,10) &  inlist(EP5,1) & PAT ==1 & pop_emp_dich == 1 // EMPLOYERS

replace CISE_18_new=1 if inlist(EP3,5) &   inlist(EP4,1,2) & inlist(EP5,1) & PAT ==1 & pop_emp_dich == 1 // EMPLOYERS


*Modalité 2 == INDEPENDENT WORKERS WITHOUT EMPLOYEES / Travailleurs indépendants sans employés

replace CISE_18_new=2 if inlist(EP3,2,3,4,10) & !inlist(EP5,1) & PAT ==1 & pop_emp_dich == 1 // INDEPENDENT WORKERS WITHOUT EMPLOYEES

replace CISE_18_new=2 if inlist(EP3,5) & inlist(EP4,1,2) & !inlist(EP5,1) & PAT ==1 & pop_emp_dich == 1 // INDEPENDENT WORKERS WITHOUT EMPLOYEES

*Modalité 3 == Non-salariés dependent

replace CISE_18_new=3 if inlist(EP3,1,8,9,4,10) & EP6__1!=1 & EP37!=1 & EP10c!=1 & PAT ==1 & pop_emp_dich == 1 // 3 - Dependent workers - self declared employees


		  replace CISE_18_new=3 if CISE_18_new==2 & ((EP26A==2 & inlist(EP27A,1,2)) | (EP26B==2 & inlist(EP27B,1,2))) & PAT ==1 & pop_emp_dich == 1                  // 3 - Dependent workers - self declared self-employed
		  

*Modalité 4 ==   EMPLOYEES


replace CISE_18_new=4 if ((inlist(EP3,4,5,6,10) & !inlist(EP4,1,2)) & (EP6__1==1 | EP37==1 | EP10c==1)) & PAT ==1 & pop_emp_dich == 1       // EMPLOYEES

replace CISE_18_new=4 if (inlist(EP3,1,4,10) & (EP6__1==1 | EP37==1 | EP10c==1)) & PAT ==1 & pop_emp_dich == 1  // EMPLOYEES

replace CISE_18_new=4 if inlist(EP3,8,9,10) & PAT ==1 & pop_emp_dich == 1 // EMPLOYEES


*Modalité 5 ==  CONTRIBUTING  FAMILY WORKERS

replace CISE_18_new=5 if inlist(EP3,4,5,10) & !inlist(EP4,1,2) & EP6__1!=1 & PAT ==1 & pop_emp_dich == 1 // CONTRIBUTING  FAMILY WORKERS

replace CISE_18_new=5 if inlist(EP3,4,6,10) &  EP6__1!=1 & PAT ==1 & pop_emp_dich == 1 // CONTRIBUTING  FAMILY WORKERS


ta CISE_18_new

	lab var CISE_18_new " Classifition internationale du statut dans l'emploi "
	cap label drop CISE_18_new
	label define CISE_18_new 1 "Employeur" 							2 "Travailleurs indépendants sans employés" 3 "Non-salariés (Entrepreneurs) dépendants" 4 "Employés" 5 " Travailleurs familiaux" ///

	label values CISE_18_new CISE_18_new


/*
		/*------------------------------------------------------*/
/* X.x. Classifition internationale du statut dans l'emploi : Situation dans l'emploi Profil Colonne*/
/* Variables impliquées
CISE_18_new : situation en emploi
milieu_resid2 : Milieu de résidence à trois modalités
sexe : Sexe 
branche2: Branche d'activité
Niv_inst_AG2 : Niveau d'instruction en 5 modalités
*/

*a. Calcul des valeurs et Affectation dans des matrices
		/*------------------------------------------------------*/

	
mat define RESU = (.,.,.,.,.)


/* Sexe */

mat define RESU1 = (.)
proportion 1.CISE_18_new [pw=poids], over(sexe)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat define RESU2 = (.)
proportion 2.CISE_18_new [pw=poids], over(sexe)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat define RESU3 = (.)
proportion 3.CISE_18_new [pw=poids], over(sexe)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'
	
mat define RESU4 = (.)
proportion 4.CISE_18_new [pw=poids], over(sexe)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'

mat define RESU5 = (.)
proportion 5.CISE_18_new [pw=poids], over(sexe)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'


/* Milieu de residence */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_new [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_new [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_new [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

mat RESU4 = RESU4 \ (.)
proportion 4.CISE_18_new [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'
	
mat RESU5 = RESU5 \ (.)
proportion 5.CISE_18_new [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'

	
/* Niveau d'Instruction */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_new [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_new [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_new [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

mat RESU4 = RESU4 \ (.)
proportion 4.CISE_18_new [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'
	
mat RESU5 = RESU5 \ (.)
proportion 5.CISE_18_new [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'
	
	
/* Branche d'activité */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_new [pw=poids], over(branche2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_new [pw=poids], over(branche2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_new [pw=poids], over(branche2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

mat RESU4 = RESU4 \ (.)
proportion 4.CISE_18_new [pw=poids], over(branche2)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'

mat RESU5 = RESU5 \ (.)
proportion 5.CISE_18_new [pw=poids], over(branche2)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'
	
	
/* Consolidation de la matrice finale */
mat RESU = RESU1, RESU2, RESU3, RESU4, RESU5
	
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

*matrix colnames RESU = "Employeur" "Travailleurs indépendants_sans_employés" "Non-salariés (Entrepreneurs) dépendants" "Employés" "Travailleurs familiaux"

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
	
	
/*

* DECOMPOSITION DES INDICATEURS DE LA CISE_18_new EN 10 MODALITES

 CREATION DE LA VARIABLE STATUS IN EMPLOYMENT CISE 18
 LES MODALITES SONT :
 1. Employeurs dans des entreprises/ sociétés
 2. Employeurs dans les entreprises de marché des ménages
 3. Travailleurs indépendants sans employés
 4. Travailleurs indépendants dans des entreprises marchandes familiales
 5. Travailleurs familiaux contributeurs
 6. Contractuels dépendants
 7. Paid apprentices, trainees and interns
 8. Employés permanents
 9. Fixed-term employees
 10.Short-term and casual employees
 
 
*/
	

cap drop CISE_18_niv2
gen CISE_18_niv2 =.

***** Création de la modalités : 1  **** **Employeurs dans des entreprises/ sociétés***
 
replace CISE_18_niv2 = 1 if ( CISE_18_new==1 & EP14B==1 & PAT ==1 & pop_emp_dich == 1) // Employeur  ou Membre de coopératives de producteurs employant des travailleurs sur une base réguliere 


***** Création de la modalités : 2  **** **Employeurs dans les entreprises de marché des ménages***


replace CISE_18_niv2 = 2 if (PAT ==1 & pop_emp_dich == 1 & CISE_18_new==1 & EP14B!=1) // Employeurs dans les entreprises de marché des ménages


***** Création de la modalités : 3  **** ***Travailleurs indépendants sans employés.****

replace CISE_18_niv2 = 3 if ( CISE_18_new==2 & EP14B==1 & PAT ==1 & pop_emp_dich == 1) // travailleurs independants sans employés ayant une existence legale 

***** Création de la modalités : 4  **** ***Travailleurs indépendants dans des entreprises marchandes familiales****


replace CISE_18_niv2 = 4 if (EP14B != 1) & PAT ==1 & pop_emp_dich == 1 & CISE_18_new==2
/// Travailleurs à compte propre n'étant érigé en société, n'ayant pas de matricule, n'ayant pas une existance legale


***** Création de la modalités : 5  **** ***Travailleurs familiaux contributeurs****

replace CISE_18_niv2 = 5 if CISE_18_new == 5 & PAT ==1 & pop_emp_dich == 1

***** Création de la modalités : 6  **** ********** Contractuels dépendants ****

replace CISE_18_niv2 = 6 if CISE_18_new == 3 & PAT ==1 & pop_emp_dich == 1

***** Création de la modalités : 7  **** ********** Paid apprentices, trainees and interns ****

*replace CISE_18_niv2 = 7 if CISE_18_new == 4 & inlist(EP3,8,9) & PAT ==1 & pop_emp_dich == 1 //Paid apprentices, trainees and interns

replace CISE_18_niv2 = 7 if CISE_18_new == 4 & !inlist(EP29,3,4) & EP31__2==1 & PAT ==1 & pop_emp_dich == 1 & !inlist(EP3,8,9) //Paid apprentices, trainees and interns

replace CISE_18_niv2 = 7 if CISE_18_new == 4 & inlist(EP3,8,9) & PAT ==1 & pop_emp_dich == 1  //Paid apprentices, trainees and interns



***** Création de la modalités : 10  **** ********** Short-term and casual employees ****

replace CISE_18_niv2 = 10 if CISE_18_new == 4 & PAT ==1 & pop_emp_dich == 1  & !inlist(EP3,8,9)   //Short-term and casual employees

***** Création de la modalités : 8  **** ********** Permanent employees ****

replace CISE_18_niv2 = 8 if CISE_18_new == 4 & (inlist(EP29,3,4) & EP33==1) & PAT ==1 & pop_emp_dich == 1 & !inlist(EP3,8,9) //Permanent employees


replace CISE_18_niv2 = 8 if CISE_18_new == 4 & (inlist(EP29,3,4) & EP33!=1 & EP35==1) & PAT ==1 & pop_emp_dich == 1 &  !inlist(EP3,8,9) //Permanent employees



replace CISE_18_niv2 = 8 if CISE_18_new == 4 & (!inlist(EP29,3,4) & (EP31__3==1 | EP31__4==1 | EP31__5==1) & EP32==1 & EP33==1) & PAT ==1 & pop_emp_dich == 1 & !inlist(EP3,8,9) //Permanent employees


replace CISE_18_niv2 = 8 if CISE_18_new == 4 & (!inlist(EP29,3,4) & (EP31__3==1 | EP31__4==1 | EP31__5==1) & EP32==1 & EP33!=1 & EP35==1) & PAT ==1 & pop_emp_dich == 1 & !inlist(EP3,8,9) //Permanent employees

***** Création de la modalités : 9  **** ********** Fixed-term employees ****


replace CISE_18_niv2 = 9 if CISE_18_new == 4 & (!inlist(EP29,3,4) & !inlist(EP30c,1,2,3,8) & EP31__1==1 & EP33!=1 & EP35!=2) & PAT ==1 & pop_emp_dich == 1 & !inlist(EP3,8,9) //Fixed-term employees


replace CISE_18_niv2 = 9 if CISE_18_new == 4 & (!inlist(EP29,3,4) & !inlist(EP30c,1,2,3,8) & EP31__1==1 & EP33!=2) & PAT ==1 & pop_emp_dich == 1  & !inlist(EP3,8,9)  //Fixed-term employees


replace CISE_18_niv2 = 9 if CISE_18_new == 4 & !inlist(EP29,3,4) & !inlist(EP30c,1,2,3,8) & (EP31__3==1 | EP31__4==1 | EP31__5==1) &   EP32!=1 & EP33!=2 & PAT ==1 & pop_emp_dich == 1 &  !inlist(EP3,8,9)    
//Fixed-term employees


replace CISE_18_niv2 = 9 if CISE_18_new == 4 & (!inlist(EP29,3,4) & !inlist(EP30c,1,2,3,8) & (EP31__3==1 | EP31__4==1 | EP31__5==1) & EP32!=1 & EP33!=1 & EP35!=2) & PAT ==1 & pop_emp_dich == 1  & !inlist(EP3,8,9) //Fixed-term employees




	lab var CISE_18_niv2 " Classifition internationale du statut dans lemploi avec les 10 modalités "
	cap label drop CISE_18_niv2
	label define CISE_18_niv2 1 "Employeurs dans des entreprises/ sociétés" 							2 "Employeurs dans les entreprises de marché des ménages" 3 "Travailleurs indépendants sans employés" 4 "Travailleurs indépendants dans des entreprises marchandes familiales" 5 " Travailleurs familiaux" 6 " Contractuels dépendants" 7 "Apprentis, stagiaires et internes rémunérés"   8   "Employés permanents"  9 "Employés à durée déterminée"  10 "Employés temporaires et occasionnels" ///

	label values CISE_18_niv2 CISE_18_niv2
	ta CISE_18_niv2
	ta CISE_18_new
	
/*
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
	
mat define RESU = (.,.,.,.,.,.,.,.,.,.)


/* Sexe */

mat define RESU1 = (.)
proportion 1.CISE_18_niv2 [pw=poids], over(sexe)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat define RESU2 = (.)
proportion 2.CISE_18_niv2 [pw=poids], over(sexe)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat define RESU3 = (.)
proportion 3.CISE_18_niv2 [pw=poids], over(sexe)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'
	
mat define RESU4 = (.)
proportion 4.CISE_18_niv2 [pw=poids], over(sexe)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'

mat define RESU5 = (.)
proportion 5.CISE_18_niv2 [pw=poids], over(sexe)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'

mat define RESU6 = (.)
proportion 6.CISE_18_niv2 [pw=poids], over(sexe)
mat list e(b)
mat RESU6 = RESU6 \ (e(b) * 100)'

	
mat define RESU7 = (.)
proportion 7.CISE_18_niv2 [pw=poids], over(sexe)
mat list e(b)
mat RESU7 = RESU7 \ (e(b) * 100)'
	
	
mat define RESU8 = (.)
proportion 8.CISE_18_niv2 [pw=poids], over(sexe)
mat list e(b)
mat RESU8 = RESU8 \ (e(b) * 100)'
	

	mat define RESU9 = (.)
proportion 9.CISE_18_niv2 [pw=poids], over(sexe)
mat list e(b)
mat RESU9 = RESU9 \ (e(b) * 100)'

	
mat define RESU10 = (.)
proportion 10.CISE_18_niv2 [pw=poids], over(sexe)
mat list e(b)
mat RESU10 = RESU10 \ (e(b) * 100)'
	
	
/* Milieu de residence */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_niv2 [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_niv2 [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_niv2 [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

mat RESU4 = RESU4 \ (.)
proportion 4.CISE_18_niv2 [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'
	
mat RESU5 = RESU5 \ (.)
proportion 5.CISE_18_niv2 [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'
	
	
mat RESU6 = RESU6 \ (.)
proportion 6.CISE_18_niv2 [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU6 = RESU6 \ (e(b) * 100)'
	
	
mat RESU7 = RESU7 \ (.)
proportion 7.CISE_18_niv2 [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU7 = RESU7 \ (e(b) * 100)'

	
	
mat RESU8 = RESU8 \ (.)
proportion 8.CISE_18_niv2 [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU8 = RESU8 \ (e(b) * 100)'
	
	
mat RESU9 = RESU9 \ (.)
proportion 9.CISE_18_niv2 [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU9 = RESU9 \ (e(b) * 100)'
	
	
mat RESU10 = RESU10 \ (.)
proportion 10.CISE_18_niv2 [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU10 = RESU10 \ (e(b) * 100)'

	
	/* Niveau d'Instruction */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_niv2 [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_niv2 [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_niv2 [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

mat RESU4 = RESU4 \ (.)
proportion 4.CISE_18_niv2 [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'
	
mat RESU5 = RESU5 \ (.)
proportion 5.CISE_18_niv2 [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'

mat RESU6 = RESU6 \ (.)
proportion 6.CISE_18_niv2 [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU6 = RESU6 \ (e(b) * 100)'

	
mat RESU7 = RESU7 \ (.)
proportion 7.CISE_18_niv2 [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU7 = RESU7 \ (e(b) * 100)'

	
mat RESU8 = RESU8 \ (.)
proportion 8.CISE_18_niv2 [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU8 = RESU8 \ (e(b) * 100)'


mat RESU9 = RESU9 \ (.)
proportion 9.CISE_18_niv2 [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU9 = RESU9 \ (e(b) * 100)'


mat RESU10 = RESU10 \ (.)
proportion 10.CISE_18_niv2 [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU10 = RESU10 \ (e(b) * 100)'


/* Branche d'activité */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_niv2 [pw=poids], over(branche2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_niv2 [pw=poids], over(branche2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_niv2 [pw=poids], over(branche2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'

mat RESU4 = RESU4 \ (.)
proportion 4.CISE_18_niv2 [pw=poids], over(branche2)
mat list e(b)
mat RESU4 = RESU4 \ (e(b) * 100)'

mat RESU5 = RESU5 \ (.)
proportion 5.CISE_18_niv2 [pw=poids], over(branche2)
mat list e(b)
mat RESU5 = RESU5 \ (e(b) * 100)'


mat RESU6 = RESU6 \ (.)
proportion 6.CISE_18_niv2 [pw=poids], over(branche2)
mat list e(b)
mat RESU6 = RESU6 \ (e(b) * 100)'


mat RESU7 = RESU7 \ (.)
proportion 7.CISE_18_niv2 [pw=poids], over(branche2)
mat list e(b)
mat RESU7 = RESU7 \ (e(b) * 100)'


mat RESU8 = RESU8 \ (.)
proportion 8.CISE_18_niv2 [pw=poids], over(branche2)
mat list e(b)
mat RESU8 = RESU8 \ (e(b) * 100)'


mat RESU9 = RESU9 \ (.)
proportion 9.CISE_18_niv2 [pw=poids], over(branche2)
mat list e(b)
mat RESU9 = RESU9 \ (e(b) * 100)'

mat RESU10 = RESU10 \ (.)
proportion 10.CISE_18_niv2 [pw=poids], over(branche2)
mat list e(b)
mat RESU10 = RESU10 \ (e(b) * 100)'


/* Consolidation de la matrice finale */
mat RESU = RESU1, RESU2, RESU3, RESU4, RESU5, RESU6, RESU7, RESU8, RESU9, RESU10
	
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

matrix colnames RESU =  "Employeurs entreprises/sociétés" "Travailleurs indép ménages" "Travailleurs indép sans employés" "Trav indép entrep familiales" " Travailleurs familiaux" " Contractuels dépendants" "Apprentis, stagiaires rémunérés"    "Employés permanents"  "Employés à durée déterminée"   "Employés temp et occa"

/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Situation_Emp_PC") modify

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


*/

/*

* DECOMPOSITION DES INDICATEURS DE LA CISE_18_new selon les 3 secteurs (menage, formel et informel) ****


 CREATION DE LA VARIABLE CLASSIFICATION FORMAL SECTOR for INDEPENDENT WORKERS CISE 18
 LES MODALITES SONT :
 1. Secteur des ménages
 2. Secteur formel
 3. Secteur informel 
 
*/
	
	
	
**** Secteur formel et informel ****


		***** Secteur des ménages *****
		*******************************
		*******************************

cap drop CISE_18_informel
gen CISE_18_informel=.

replace CISE_18_informel=2 if PAT ==1 & pop_emp_dich == 1 & !missing(EP3) & !missing(EP11)

replace CISE_18_informel =3 if CISE_18_niv2==5 & inlist(EP11,8) & PAT ==1 & pop_emp_dich == 1  // HOUSEHOLD SECTOR

replace CISE_18_informel =3 if CISE_18_new==4 & inlist(EP11,8) & PAT ==1 & pop_emp_dich == 1  // HOUSEHOLD SECTOR


replace CISE_18_informel =3 if CISE_18_new==3 & inlist(EP11,8) & PAT ==1 & pop_emp_dich == 1  // HOUSEHOLD SECTOR

ta CISE_18_informel

		***** Secteur formel *****
		**************************
		**************************
		
	*CONTRIBUTING FAMILY WORKERS AND EMPLOYEE
	
*EP11==1,2,5
replace CISE_18_informel=1 if inlist(CISE_18_new,4) & inlist(EP11,1,2,5) & PAT ==1 & pop_emp_dich == 1 // FORMAL SECTOR 

*EP11==4,3,6,7
replace CISE_18_informel=1 if inlist(CISE_18_new,4,5) & inlist(EP11,4,3,6,7) & (inlist(EP14B,1) | EP20 == 1 | EP22 ==1) & PAT ==1 & pop_emp_dich == 1 // FORMAL SECTOR 

ta CISE_18_informel

***** Entrepreneurs dépendant pas autodéclares comme salariés ou pas CISE_18_new==3 & EP3 ==1 


*EP11==1,2,5
replace CISE_18_informel=1 if CISE_18_new==3 & EP3 ==1 & inlist(EP11,1,2,5) & PAT ==1 & pop_emp_dich == 1 // FORMAL SECTOR 

*EP11==4,3,6,7
replace CISE_18_informel=1 if CISE_18_new==3 & inlist(EP11,4,3,6,7) & (inlist(EP14B,1) | EP20 == 1 | EP22 ==1) & PAT ==1 & pop_emp_dich == 1 // FORMAL SECTOR 

ta CISE_18_informel

***** Travailleurs indépendants
*EP11==4,3,6,7
replace CISE_18_informel=1 if inlist(CISE_18_new,1,2) & inlist(EP11,4,3,6,7) & (inlist(EP14B,1) | EP20 == 1 | EP22 ==1) & PAT ==1 & pop_emp_dich == 1 // FORMAL SECTOR 

	lab var CISE_18_informel " Formalité du secteur "
	cap label drop CISE_18_informel
	label define CISE_18_informel 1 "Secteur Formel " 2 "Secteur Informel" 3 "Ménages"  ///

	label values CISE_18_informel CISE_18_informel

ta CISE_18_informel




/*
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

mat define RESU = (.,.,.)


/* Sexe */

mat define RESU1 = (.)
proportion 1.CISE_18_informel [pw=poids], over(sexe)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat define RESU2 = (.)
proportion 2.CISE_18_informel [pw=poids], over(sexe)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat define RESU3 = (.)
proportion 3.CISE_18_informel [pw=poids], over(sexe)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'


/* Milieu de residence */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_informel [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_informel [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_informel [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'


	/* Niveau d'Instruction */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_informel [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_informel [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_informel [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'


/* Branche d'activité */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_informel [pw=poids], over(branche2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_informel [pw=poids], over(branche2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'

mat RESU3 = RESU3 \ (.)
proportion 3.CISE_18_informel [pw=poids], over(branche2)
mat list e(b)
mat RESU3 = RESU3 \ (e(b) * 100)'


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

matrix colnames RESU =  "Secteur Formel " "Secteur Informel" "Ménages" 


/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Situation_Emp_PC") modify

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



*/

********************Formalité de l'emploi**********


/*

* CREATION DE L'INDICATEUR SUR LA FORMALITE DE L'EMPLOI ****


 CREATION DE LA VARIABLE 
 LES MODALITES SONT :
 1. Emploi Formel
 2. Emploi Informel
 
*/



cap drop CISE_18_informel_Emp
gen CISE_18_informel_Emp=2 if PAT ==1 & pop_emp_dich == 1 & !missing(EP3) & !missing(EP11) 

*Employés
replace CISE_18_informel_Emp=1 if CISE_18_new==4  & EP10c==1 & PAT ==1 & pop_emp_dich == 1

replace CISE_18_informel_Emp=1 if CISE_18_new==4  & !inlist(EP10c,1,2,3) & (EP38==1 | EP39==1) & PAT ==1 & pop_emp_dich == 1

** Employeurs et travailleurs pour compte propre
replace CISE_18_informel_Emp=1 if inlist(CISE_18_new,1,2)   & CISE_18_informel==1 & PAT ==1 & pop_emp_dich == 1

**Entrepreneurs dépendants
*replace CISE_18_informel_Emp=1 if CISE_18_new==3 & CISE_18_informel==1 & PAT ==1 & pop_emp_dich == 1
replace CISE_18_informel_Emp=1 if CISE_18_new==3 & CISE_18_informel==1 & EP10c==2  & PAT ==1 & pop_emp_dich == 1


lab var CISE_18_informel_Emp " Formalité de l'emploi "
	cap label drop CISE_18_informel_Emp
	label define CISE_18_informel_Emp 1 "Emploi Formel " 2 "Emploi Informel"  ///

	label values CISE_18_informel_Emp CISE_18_informel_Emp

ta CISE_18_informel_Emp


/*

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

mat define RESU = (.,.,.)


/* Sexe */

mat define RESU1 = (.)
proportion 1.CISE_18_informel_Emp [pw=poids], over(sexe)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat define RESU2 = (.)
proportion 2.CISE_18_informel_Emp [pw=poids], over(sexe)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'


/* Milieu de residence */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_informel_Emp [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_informel_Emp [pw=poids], over(milieu_resid2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'


	/* Niveau d'Instruction */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_informel_Emp [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_informel_Emp [pw=poids], over(Niv_inst_AG2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'



/* Branche d'activité */

mat RESU1 = RESU1 \ (.)
proportion 1.CISE_18_informel_Emp [pw=poids], over(branche2)
mat list e(b)
mat RESU1 = RESU1 \ (e(b) * 100)'

mat RESU2 = RESU2 \ (.)
proportion 2.CISE_18_informel_Emp [pw=poids], over(branche2)
mat list e(b)
mat RESU2 = RESU2 \ (e(b) * 100)'


/* Consolidation de la matrice finale */
mat RESU = RESU1, RESU2


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

matrix colnames RESU =  "Emploi Formel "  "Emploi Informel" 


/* Exportation sur Excel dans le dossier Resultats_Tab*/

putexcel set "${Resultats_Tab}\Tableau_Emploi_Ensemble.xlsx", sheet("Situation_Emp_PC") modify

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


*/









