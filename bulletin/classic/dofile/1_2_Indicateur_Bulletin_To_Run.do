

*		 		==================================					*
*			Structure de la population en âge de travailler			*
*				==================================					*


*========== 		Population en âge de travailler		============*
cap drop PAT
gen PAT= (age>=16 & age<.)
		lab var PAT "population en âge de travailler selon le BIT"
		cap label drop PAT
		lab define PAT 1 "Oui" 0 "Non"
		label values PAT PAT
tab PAT		/* PAT:  19 */

* Note: Etre sûr que tous les individus de la base ont un age dé


*=======         Population en emploi: pop_emploi     ==============*

*** Emploi present
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
tab PAT, nolab

*** Emploi absent
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
		

// *** Pop_emploi
// cap drop pop_emp
// gen pop_emp = 1 if emp_present == 1 & PAT == 1	
// 	replace pop_emp = 2 if emp_absent == 1 & PAT == 1
// 		label var pop_emp "Population en emploi"
// 		cap label drop pop_emp
// 		lab define pop_emp 1 "Emploi présent" 2 "Emploi absent"
// 		label values pop_emp pop_emp
// ta pop_emp		/* pop emploi: 4 	*/

*** Pop_emploi
cap drop pop_emp
gen pop_emp = 0 if PAT == 1
replace pop_emp = 1 if emp_present == 1 & PAT == 1	
replace pop_emp = 2 if emp_absent == 1 & PAT == 1
		label var pop_emp "Population en emploi"
		cap label drop pop_emp
		lab define pop_emp 1 "Emploi présent" 2 "Emploi absent"
		label values pop_emp pop_emp
ta pop_emp		/* pop emploi: 4 	*/

/* Variable dichotomique sur l'emploi*/
cap drop pop_emp_dich
recode pop_emp (1 2=1) ,gen(pop_emp_dich)
label values pop_emp_dich PAT

tab pop_emp_dich

// *========== 		Situation d'activité			==============*
// cap drop sit_act
// gen sit_act= 0 if PAT == 1 
// 	replace sit_act=1 if emp_present == 1 | emp_absent == 1
// 		cap label drop sit_act
// 		lab def sit_act 1 "En emploi" 0 "Sans emploi"
// 		lab val sit_act sit_act 





*================= Secteur institutionnel   ============================*
/*revoir :*/

// *=============== Creation du secteur instituionnel plutot ici au lieu de le faire dans le dofile 1_1 car la creation utilise la variable pop_emp qui est crée dans ce dofile. 

*** Secteur institutionnel au sens de la comptabilité nationale			
*pop_emploi_16_plus
cap drop secteur_institutionnel
gen secteur_institutionnel = 1*(EP11==1 | EP11==2) + 2*(EP11==3|EP11==4) + 3*(EP11==7 | EP11==8) + 4*(EP11==9)+ 5*(EP11==6) if (pop_emp_dich ==1	& EP11 !=.)  
// les secteurs institutionneL
*NB:dans le version finale de l'enquête, une question doit préciser le statut (fiancièr ou non financièr) des entreprises privées non agricoles

label var secteur_institutionnel "Secteur institutionnel"
cap label define secteur_institutionnel 1 " Administration publique" 2 "Societé non financière" 3 "Institution sans but lucratif" 4 "Menage" 5 "Reste du monde"
label values secteur_institutionnel secteur_institutionnel



*** Secteur instituionnel 2

cap drop secteur_institionnel2
gen secteur_institionnel2 = 1 if  pop_emp_dich ==1 
replace secteur_institionnel2 = 2 if inlist(EP11,3,4,6) &  pop_emp_dich ==1 
replace secteur_institionnel2 = 3 if EP11 ==8 & pop_emp_dich ==1 

lab var secteur_institionnel2 "Secteur institutionnel"
lab define secteur_institionnel2 1 "Public" 2 "Privé" 3 "Menage"
lab values secteur_institionnel2 secteur_institionnel2


*** Secteur instituionnel3
recode  EP11 (1 2 =1) (3=2) (4=3) (5=4) (6 7=5) (8=6), gen(secteur_institutionnel3)
lab var secteur_institutionnel3 "Secteur institutionnel"
lab define secteur_institutionnel3 1 "Public/parapublic" 2 "Entreprise privée non agricole" 3 "Entreprise agricole" 4 "Organisation internationale" 5 "ONG/eglise" 6 "Ménage"
lab values secteur_institutionnel3 secteur_institutionnel3





//
 *** Secteur instituionnel 2
 cap drop secteur_institionnel2
 gen secteur_institionnel2 = 2 if PAT==1 & inlist(pop_emp_dich,1,2)
 replace secteur_institionnel2 = 1 if inlist(EP11,1,2) & PAT==1 & inlist(pop_emp_dich,1,2)
 replace secteur_institionnel2 = 3 if EP11 ==8 & PAT==1 & inlist(pop_emp_dich,1,2)
 cap label drop secteur_institionnel2
 lab var secteur_institionnel2 "Secteur institutionnel"
 lab define secteur_institionnel2 1 "Public" 2 "Privé" 3 "Menage"
 lab values secteur_institionnel2 secteur_institionnel2

 *** Secteur instituionnel3
 cap drop secteur_institutionnel3
 recode  EP11 (1 2 =1) (3=2) (4=3) (5=4) (6 7=5) (8=6), gen(secteur_institutionnel3)
 lab var secteur_institutionnel3 "Secteur institutionnel"
 cap label drop secteur_institutionnel3
 lab define secteur_institutionnel3 1 "Public/parapublic" 2 "Entreprise privée non agricole" 3 "Entreprise agricole" 4 "Organisation internationale" 5 "ONG/eglise" 6 "Ménage"
 lab values secteur_institutionnel3 secteur_institutionnel3


*=============    Population au Chômage         ===================*
cap drop aucun_emp
gen aucun_emp = (pop_emp_dich==0 & ((SRH1 ==1 | SRH2==1) & SRH11 == 1) & PAT == 1)

	// Personne n'ayant aucun emploi
		label var aucun_emp "Chômeur qui n'ont pas de promesse"
		label values aucun_emp PAT

cap drop futures_staters
*gen futures_staters = ((SRH1 ==1 | SRH2==1) & SRH12A__18 == 1 & SRH11 == 1 & !inlist(pop_emp,1,2) & PAT == 1) // Ancienne syntaxe fausse 
gen futures_staters = ( SRH1 == 2 &  SRH2 == 2 &  SRH2A == 2 & SRH7==18 & SRH9 == 1 & !inlist(pop_emp,1,2) & PAT == 1) // Nouvelle syntaxe correcte 
		label var futures_staters "Recherchent pas un emploi car ils en ont déjà trouvé un et sont disponibles pour commencer un emploi"
		label values futures_staters PAT

cap drop pop_chomage
gen pop_chomage = 1 if (aucun_emp == 1 & pop_emp_dich==0 & PAT == 1) // revoie bien la creation de cette variable.
	replace pop_chomage = 2 if futures_staters == 1 & pop_emp_dich==0 & PAT == 1
		lab var pop_chomage "Population au chômage"
		cap label drop pop_chomga
		lab define pop_chomga 1 "Auncune d'emploi sans promesse" 2 "Futures staters"
		label values pop_chomage pop_chomage
ta pop_chomage

/* Variable dichotomique sur le chomage*/
cap drop pop_chomage_dich
recode pop_chomage (1 2=1) ,gen(pop_chomage_dich)
label values pop_chomage_dich PAT


// cap drop futures_staters
// gen futures_staters = ((SRH1 ==1 | SRH2==1) & SRH12A__18 == 1 & SRH11 == 1 & !inlist(pop_emp,1,2) & PAT == 1) // Chômeur qui a une promesse d'emploi
// 		label var futures_staters "Recherchent pas un emploi car ils en ont déjà trouvé un et sont disponibles pour commencer un emploi"
// 		label values futures_staters PAT

// cap drop pop_chomage
// gen pop_chomage = 1 if aucun_emp == 1 & !inlist(pop_emp,1,2) & PAT == 1
// 	replace pop_chomage = 2 if futures_staters == 1 & !inlist(pop_emp,1,2) & PAT == 1
// 		lab var pop_chomage "Population au chômage"
// 		cap label drop pop_chomga
// 		lab define pop_chomga 1 "Auncune promesse d'emploi" 2 "Futures staters"
// 		label values pop_chomage pop_chomage
// ta pop_chomage	/* pop_chomage: 1	*/



**======	 Statut de la population en age de travailler  ==========*
cap drop statut_MO
gen statut_MO = 3 if PAT == 1
	replace statut_MO = 1 if pop_emp_dich==1 &PAT == 1
	replace statut_MO = 2 if pop_chomage_dich==1 & PAT == 1 
		lab var statut_MO "Statut de la population en age de travailler"
		cap label drop statut_MO
		lab define statut_MO 1 "Population en emploi" 2 "Population au chomage" ///
				3 "Population hors main d'oeuvre"
		label values statut_MO statut_MO
ta statut_MO	/* statut_MO: 19	*/

		
		
*===============		   Main d'oeuvre	   =================*
cap drop MO
gen MO = 1 if PAT == 1 & statut_MO == 1
	replace MO = 2 if PAT == 1 & statut_MO == 2
		lab var MO "Main d'oeuvre 2"
		cap label drop MO
		lab define MO 1 "Population en emploi" 2 "Population au chômage"
		lab values MO MO
ta MO		/* MO: 5 */

/* Variable dichotomique sur la main d'oeuvre*/
cap drop MO_dich
recode MO (1 2=1) ,gen(MO_dich)
label values MO_dich PAT


*=================   Main d'oeuvre potentielle    ==============*

// cap drop Non_dispo
// gen Non_dispo =  (PAT == 1 & inlist(pop_emp,1,2) & (SRH1 == 1 | SRH2 == 1) & SRH11 == 2) // Personne sans emploi, recherchant un emploi et pas disponible à travailler
// 		lab var Non_dispo "Personne non disponibles"
// 		lab values Non_dispo PAT
//
// cap drop aucune_rech
// gen aucune_rech = (PAT == 1 & inlist(pop_emp,1,2) & (SRH1 == 2 & SRH2 == 2) & SRH11 == 1) // Disponible mais ne cherchant pas d'emploi
// 		lab var aucune_rech "Aucune recherche"
// 		lab values aucune_rech PAT


cap drop Non_dispo
gen Non_dispo =  PAT == 1 & !inlist(pop_emp,1,2) & !inlist(pop_chomage,1,2) & ((SRH1 == 1 | (SRH1== 2 & SRH2 == 1)) & SRH11 == 2) 


// Personne sans emploi, recherchant un emploi et pas disponible à travailler
		lab var Non_dispo "Personne non disponibles"
		lab values Non_dispo PAT

cap drop aucune_rech
gen aucune_rech = (PAT == 1 & !inlist(pop_emp,1,2) & !inlist(pop_chomage,1,2) & (SRH1 == 2 & SRH2 == 2) & SRH11 == 1) // Disponible mais ne cherchant pas d'emploi
		lab var aucune_rech "Aucune recherche"
		lab values aucune_rech PAT
		

cap drop MOPOT
gen MOPOT = 1 if PAT == 1 & Non_dispo==1
	replace MOPOT = 2 if PAT == 1 & aucune_rech == 1
		lab var MOPOT "Main d'oeuvre potentielle"
		cap label drop MOPOT
		lab define MOPOT 1 "Non disponible" 2 "Aucune recherche"
		label values MOPOT MOPOT
ta MOPOT 	/* MOPOT: 0	*/

/* Variable dichotomique sur la MOPOT*/
cap drop MOPOT_dich
recode MOPOT (1 2=1) ,gen(MOPOT_dich)
label values MOPOT_dich PAT


// je viens de creer
cap drop MOPOT_bis
recode MOPOT (1 2=1) ,gen(MOPOT_bis)
replace MOPOT_bis=0 if MOPOT_bis!=1 & statut_MO==3

*============ Main d'oeuvre élargie: MOE    ===================*
cap drop MOE 
gen MOE = 1 if PAT == 1 & inlist(MO,1,2)
	replace MOE = 2 if PAT == 1 & inlist(MOPOT,1,2) // modifier car il faut plutot prendre MOPOT_dich afin d'inclure et les non disponible et ceux qui n'ont pas rechercher
		lab var MOE "Main d'oeuvre élargie"
		cap label drop MOE
		lab define MOE 1 "Main d'oeuvre" 2 "Main d'oeuvre potentielle"
		lab values MOE MOE
ta MOE		/* MOE: 5 */

/* Variable dichotomique sur la main d'oeuvre élargie*/
cap drop MOE_dich
recode MOE (1 2=1) ,gen(MOE_dich)
label values MOE_dich PAT		
		
				
*				=================================			  *
*			 	Sous utilisation de la main d'oeuvre (Revoir)		  *
*				=================================			  *
/*
*======== Horaire habituelle dans l'emploi principal  ==========*

*** Approche 1
gen hor_EP_hab1 = WKT1 if WKT1 != 997 & WKT1 <.
	replace hor_EP_hab1 = WKT2*WKT3 if WKT1 == 997 
		lab var hor_EP_hab "Nombre d'heures habituelles de travail hebdomadaire dans l'emploi principal"
		
*** Approche 2
gen hor_EP_hab2 = WKT9 if WKT9 != 997
	replace hor_EP_rel = hor_EP_hab1 if WKT9 == 997 & WT7 == 1					// Si heure réelle non déclarée, prendre les heures habituelles n'ont pas changées
	replace hor_EP_rel = hor_EP_hab1 + hor_EP_sup - hor_EP_abs if hor_EP_rel ==. // Si heure réelle non déclarée et heure habituelle differente de celui de la semaine passée, prendre les heures habituelles en tenant compte des heures supplementaires et absente


*** Approche 3
gen hor_EP_hab3 = WTK_HAB if WKT16 == 1
	replace hor_EP_hab3 = WKT17 if WKT16 == 2 & != 997
	
	
*====== Horaire supplementaire dans l'emploi  principal  =====*
gen hor_EP_sup = WKT6 if WKT5 == 1
		lab var hor_EP_sup "Nombre d'heures supplementaires"

*======  Horaire d'absence dans l'emploi principal ===========*
gen hor_EP_abs = WKT6A if WKT4 == 1
	replace hor_EP_abs = 0 if WKT8 == 2
		lab var hor_EP_abs "Nombre d'heures d'absence de travail"
 


*======= Horaire habituelle dans les autres emplois  =========*

*** Premier emploi principal
gen hor_ES1_hab1 = WKT10 if WKT10 !=997 & WKT10 <.
	replace hor_ES1 = WKT12 if WKT11 == 2 | WKT10 == 997
		lab var hor_ES1 "nombre d'heures de travail hebdomadaire dans l'emploi secondaire"

*** Autres emplois secondaires
gen hor_ES2_hab1 = WKT13 if WKT13 != 997
	replace hor_ES2 = WKT15 if WKT14 == 2 | WKT13 == 997
		lab var hor_ES2 "nombre d'heures de travail hebdomadaire dans les autres emplois secondaires"

*** Horaire totale dans les emplois secondaires
gen hor_ES_hab1 = hor_ES1_hab1 + hor_ES2_hab1
		lab var ES_hab1 "nombre d'heures habituelles de travail hebdomadaire dans les emplois secondaires"

		
*========  Horaire totale habituelle de travail  ============*
gen hor_hab = hor_EP_hab3 + hor_ES_hab1
		lab var hor_hab1 "nombre d'heures habituelles de travail hebdomadaire"

/* Pour le total des heures habituelles de travail, il faut choisir entre hor_EP_hab2, hor_EP_hab2 et hor_EP_hab2 en fonction de la qualité des reponses */

*/


*========   Heures effectives de travail	  ===============*
cap drop hor_eff
gen hor_eff = NB_HEURE_TRAVAIL_TOTAL if WKT17A == 1 & inlist(pop_emp,1,2)
	replace hor_eff = WKT18 if WKT17A == 2
		lab var hor_eff "Nombre effective de travail"
ta hor_eff
		

	
*=========  Sous utilisation de la main d'oeuvre =============*

cap drop sous_emp
gen sous_emp =0 if (PAT == 1 & inlist(pop_emp,1,2))
replace sous_emp =1 if (PAT == 1 & inlist(pop_emp,1,2)& hor_eff < 40 & WKI4 == 1 & WKI5 == 1) 


		lab var sous_emp " Sous emploi lié au temps de travail"
		lab values sous_emp PAT
ta sous_emp		/* Aucun sous emploi 	*/	
		
		
*=====================  Taux de chômage SU1    =================*
cap drop SU1
gen SU1 = 0 if inlist(MO,1,2)& PAT==1
	replace SU1 = 1 if pop_chomage_dich==1 & PAT==1 & inlist(MO,1,2)
		lab var SU1 "Taux de chômage SU1"
		lab values SU1 PAT
ta SU1		/* SU1: 4,07%	*/


* Taux de chômage combiné à la sous utilisation de la main d'oeuvre SU2
cap drop SU2
gen SU2 = 0 if PAT == 1 & inlist(MO,1,2)
	replace SU2 = 1 if (pop_chomage_dich==1 | sous_emp == 1) & PAT == 1 & inlist(MO,1,2) 
		lab var SU2 "Taux de chômage lié à la durée du travail"
		lab values SU2 PAT
ta SU2		/* SU2: 11,53% 	*/


*== Taux chomage combiné à la main d'oeuvre potentielle : SU3 ==* 
cap drop SU3
gen SU3 = 0 if PAT == 1 & inlist(MOE,1,2)
	replace SU3 = 1 if (pop_chomage_dich==1 | inlist(MOPOT,1,2)) & PAT == 1 & inlist(MOE,1,2)
		lab var SU3 "Taux de chômage combiné à la main d'oeuvre potentielle"
		lab values SU3 PAT
ta SU3	/* SU3:  14.18%	*/


* Mesure composite de la sous-utilisation de la main-d'œuvre: SU4*
cap drop SU4 
gen SU4 = 0 if PAT == 1 & inlist(MOE,1,2)
	replace SU4 = 1 if (pop_chomage_dich==1 | inlist(MOPOT,1,2) | sous_emp == 1) & PAT == 1 & inlist(MOE,1,2)
		lab var SU4 "Taux de chômage SU4"
		lab values SU4 PAT
ta SU4	/* SU4: 20.86% 	*/


*			===========================================			*
*	Classification Internationale selon la situation dans l'emploi 
*					Assignation et réassignation 				*
*			===========================================			*

*============		 Emploi principal		====================*
cap drop sit_empEP 
gen sit_empEP = 99 if inlist(pop_emp,1,2) & PAT == 1

/* A. Première Assignation */

/* I - Employeurs - 1*/
replace sit_empEP=11 if inlist(EP3,2,4) & (inlist(EP11,1,2,5) | inlist(EP11,3,4,6,7) & EP14B==1) & inlist(pop_emp,1,2) & PAT==1 
/// Employeurs en entreprise légalement constituée
replace sit_empEP=12 if inlist(EP3,2,4) & (inlist(EP11,3,4,6,7,8) & inlist(EP14B,2,9998)) & inlist(pop_emp,1,2) & PAT==1 
/// Employeurs en entreprise non légalement constituée

/* II - Travailleurs pour compte propre- 2*/
replace sit_empEP=21 if EP3==3 & (inlist(EP11,3,4,6,7) & EP14B==1) & inlist(pop_emp,1,2) & PAT==1 // Travailleurs pour compte propre en entreprise légalement constituée 

replace sit_empEP=22 if EP3==3 & (EP11==8 | inlist(EP11,3,4,6,7) & inlist(EP14B,2,9998)) & inlist(pop_emp,1,2) & PAT==1 // Travailleurs pour compte propre en entreprise non légalement constituée

/* III- Contractuel dépendant 3*/
replace sit_empEP=3 if EP3==1 & EP6a!=1 & EP37==2 & EP10c!=1 & inlist(pop_emp,1,2) & PAT == 1

/* IV- Les employés 4 */

* IV.a - Employés permanents
replace sit_empEP=41 if (EP3==1 & inlist(EP29,3,4))|(EP3==1 & EP37==1) & inlist(pop_emp,1,2) & PAT == 1

//* Calcul durée du contrat *//
cap drop duree_contrat
gen duree_contrat = EP30 if EP30b==3 // Conversion jour en jour
replace duree_contrat=EP30*365 if EP30b==2 // Conversion Annee en jours
replace duree_contrat=EP30*30 if EP30b==1 // Conversion mois en jours
label variable duree_contrat "Duree du contrat de travail en jour"

* IV.b - Employés en contrat à durée déterminée
replace sit_empEP=42 if EP3==1 & (inlist(EP29,1,2) & duree_contrat>= 365 | (EP28==9998 & EP37==1)) & inlist(pop_emp,1,2) & PAT == 1

* IV.c - Employés temporaires
replace sit_empEP=43 if EP3==1 & ((inlist(EP29,1,2) & duree_contrat<365) | (EP28==9998)) & inlist(pop_emp,1,2) & PAT == 1

* IV.d - Apprenti ou stagiare payé
replace sit_empEP=44 if inlist(EP3,8,9)
 
 * V - Travailleurs familiaux 5 */
replace sit_empEP=5 if inlist(EP3,5,6)

//  * VI - Membre coopérative 6 */
// replace sit_empEP=6 if EP3==4

 * VII - Non classé 7 */
replace sit_empEP=7 if EP3==10

label var sit_empEP "Situation dans l'emploi (ICSEa 18)"
		cap label drop sit_empEP
		lab define sit_empEP 11 "Employeurs en entreprise légalement constituée" ///
							12 "Employeurs en entreprise non légalement constituée" ///
							21 "Travailleurs pour compte propre en entreprise légalement constituée" ///
							22 "Travailleurs pour compte propre en entreprise non légalement constituée" ///
							3 "Contractuel dépendant" ///
							41 "Employés permanents" ///
							42 "Employés en contrat à durée déterminée" ///
							43 "Employés temporaires" ///
							44 "Apprenti ou stagiare payé" ///
							5 "Travailleurs familiaux" ///
							7 "Non classé" ///
								
		label values sit_empEP sit_empEP
		
		

// *============		 Emploi principal aggregé en 7 modalités		====================*
// cap drop sit_empEP2 
//
// recode sit_empEP (11 12 = 1)(21 22=2) (3=3) (41 42 43 44=4) (5 = 5) (6 = 6) (7 = 7) ,gen(sit_empEP2)
// 		lab var sit_empEP2 " Situation dans l'emploi agrégé en 7 modalités"
// 		cap label drop sit_empEP2
// 		label define sit_empEP2 1 "Employeurs" /// 
// 								2 "Travailleurs pour compte propre" ///
// 								3 "Contractuel dépendant" ///
// 								4 "Employés" /// 
// 								5 "Travailleurs familiaux" ///
// 								6 "Membre coopérative" ///
// 								7 "Non classé" ///
// 		label values sit_empEP2 sit_empEP2
//
// ta sit_empEP2,m /* Situation dans l'emploi aggregé en 7 modalités: 7 */

*============		 Emploi principal aggregé en 7 modalités (A revoir)		====================*
cap drop sit_empEP3

gen sit_empEP3=1 if inlist(sit_empEP,11,12) // Employeurs
	replace sit_empEP3=2 if inlist(sit_empEP,21,22) // Travailleurs indépendants sans employés
	replace sit_empEP3=3 if sit_empEP==3 // Contractuel dépendant
	replace sit_empEP3=4 if inlist(sit_empEP,41,42,43,44) // Employés
	replace sit_empEP3=5 if sit_empEP==5 // Travailleurs familiaux
	replace sit_empEP3=7 if sit_empEP==7 // Non classé
	
	lab var sit_empEP3 " Situation dans l'emploi selon agrégé en 5 modalités (ICSEa 18_5 ou ICSE 13)"
	cap label drop sit_empEP3
	label define sit_empEP3 1 "Employeurs" /// 
							2 "Travailleurs pour compte propre ou Travailleurs indépendants sans employés" ///
							3 "Contractuel dépendant" ///
							4 "Employés" /// 
							5 "Travailleurs familiaux" ///
							7 "Non classé" ///

	label values sit_empEP3 sit_empEP3

ta sit_empEP3,m /* Situation dans l'emploi aggregé en 5 modalités: 7 */


*============		 regroupement de la situation dans l'emploi selon le dégré d'autorités (Travailleurs indépendants & Travailleurs dépendant)		====================*
cap drop sit_empEP_Autorite

gen sit_empEP_Autorite=1 if inlist(sit_empEP,11,12,21,22) // Travailleurs indépendants
	replace sit_empEP_Autorite=2 if inlist(sit_empEP,3,41,42,43,44,5) // Travailleurs dépendants
	replace sit_empEP_Autorite=4 if sit_empEP==7 // Non classé
	
	lab var sit_empEP_Autorite " regroupement de la situation dans l'emploi selon le dégré d'autorité"
	cap label drop sit_empEP_Autorite
	label define sit_empEP_Autorite 1 "Travailleurs indépendants" /// 
							2 "Travailleurs dépendants" ///
							4 "Non classé" ///

	label values sit_empEP_Autorite sit_empEP_Autorite

ta sit_empEP_Autorite,m /* Situation dans l'emploi selon le dégré d'autorités: */


*============		 regroupement de la situation dans l'emploi selon le type de risque économique (Travailleurs indépendants & Travailleurs dépendant)		====================*

cap drop sit_empEP_risk
gen sit_empEP_risk=1 if inlist(sit_empEP,12,22,3,5) // Travailleurs employés pour le profit (Workers in employment for profit)
	replace sit_empEP_risk=2 if inlist(sit_empEP,11,21,41,42,43,44) // Travailleurs employés contre rémunération (Workers in employment for pay)
	replace sit_empEP_risk=4 if inlist(sit_empEP,7) // Non classé
		lab var sit_empEP_risk " regroupement  de la situation dans l'emploi selon le type de risque économique"
		cap label drop sit_empEP_risk
		label define sit_empEP_risk 1 "Travailleurs employés pour le profit" /// 
								2 "Travailleurs employés contre rémunération" ///
								4 "Non classé" ///

		label values sit_empEP_risk sit_empEP_risk

ta sit_empEP_risk,m /* ituation dans l'emploi selon le dégré d'autorités: */





*				======================							*
*				  Qualité de l'emploi							*							
*				======================							*

/*================= Formalité du secteur ========================*
cap drop form_sect
gen form_sect = 3  if PAT == 1 & EP11 == 8 & PAT==1 // Menage
	replace form_sect = 2 if EP11 != 8 & (inlist(EP3,2,3) | (inlist(EP3,1,8,9) & inlist(EP11,1,2,5))) & PAT==1 // Univers de la formalité du secteur
	replace form_sect = 1 if (inlist(EP3,1,8,9) & inlist(EP11,1,2,5)) & PAT==1 // Les salariés de l'Administration publique , parapublique et institution internationale
	replace form_sect = 1 if inlist(EP3,2,3) & EP14B==1 & PAT==1 //Unité de production dans le secteur privé avec forme juridique définie
	replace form_sect = 1 if inlist(EP3,2,3) & (EP20 == 1 | EP22 ==1) & PAT==1 // Déclaration registre de commerce ou à la DGI
	replace form_sect = 1 if inlist(EP3,2,3) & (EP24__1==1 | EP24__2==1) & PAT==1 // Comptabilité formelle OHADA ou Autre (EP25)
							 
	lab var form_sect "Formalité du secteur"
	cap label drop form_sect
	lab define form_sect 1 "Secteur formel" 2 "Secteur informel" 3 "Ménage"
	lab values form_sect form_sect
	
ta form_sect	/* Sect form: 1; sect infor:1; men: 0	*/


*=============       Formalité de l'emploi		=================*

*** Emploi principal
cap drop form_empEP
gen form_empEP = 0 if inlist(pop_emp,1,2) & PAT == 1

	replace form_empEP = 1 if sit_empEP_Autorite==1 & form_sect==1 & inlist(pop_emp,1,2) & PAT == 1 // Travailleurs indépendants formel
	
	replace form_empEP = 1 if sit_empEP3==3 & form_sect==1 & (EP37==1 | EP38 == 1 | EP39 ==1 | EP44==1) & inlist(pop_emp,1,2) & PAT == 1 // Contractuel dépendant formel
	
	replace form_empEP = 1 if sit_empEP3==4 & (EP37==1 | EP38 == 1 | EP39 ==1 | EP44==1) & inlist(pop_emp,1,2) & PAT == 1 // Salarié formel
	
	replace form_empEP = 1 if inlist(sit_empEP,5,6,7) & form_sect==1 & (EP37==1 | EP38 == 1 | EP39 ==1 | EP44==1) & inlist(pop_emp,1,2) & PAT == 1 // travailleurs indépendants, coopérative et non classé formel
	
	replace form_empEP = 1 if  form_sect==3 & (EP37==1 | EP38 == 1 | EP39 ==1 | EP44==1) & inlist(pop_emp,1,2) & PAT == 1 // Ménage formel
	
	replace form_empEP = 1 if (EP37==1 | EP38 == 1 | EP39 ==1 | EP44==1) & inlist(pop_emp,1,2) & PAT == 1 // Autre emploi formel
	
ta form_empEP	/* Infor: 3; form:1	*/

		lab var form_empEP "Statut de l'emploi principal"
		cap label drop form_empEP
		lab define form_empEP 1 "Emploi formel" 0 " Emploi informel"
		lab values form_empEP form_empEP
		
ta form_empEP	/* Infor: 3; form:1	*/ */
	
		
*======= 	 		Emploi vulnerable  		==================*
cap drop emp_vul
gen emp_vul = 0 if PAT == 1 & inlist(pop_emp,1,2)
	replace emp_vul = 1 if inlist(EP3,3,5) & PAT == 1 & inlist(pop_emp,1,2)
		lab var emp_vul "Taux d'emploi vulnerable"
		lab values emp_vul PAT
ta emp_vul		/* Emp vul: 1	*/


*================      Emploi précaire     ====================*
/// C'est un poxi le temps de pouvoir tenir compte de la situation occasionnelle dans le travail de l'individu

cap drop emp_prec
gen emp_prec = 0 if PAT == 1 & inlist(pop_emp,1,2)
	replace emp_prec = 1 if inlist(EP29,1,2,4) & PAT == 1 & inlist(pop_emp,1,2)
		lab var emp_prec "Emploi précaire"
		lab values emp_prec PAT
ta emp_prec		/* Emp precaire: 1	*/

		
		

*					==========================					*     	
*							NEETS      							*
*					==========================					*

*============ 	   Pas en education 			 ===============*
cap drop no_education
gen no_education =0 if  AgeAnnee >= 3
	replace no_education = 1 if (EF6!=1 | EF1==2) & AgeAnnee >= 3	// pas en fréquentation actuelle ou n'a Jamais été scolarisé
//	replace no_education = 1 if EF1 == 1 & EF4 <= 3 							// Ne fréquente pas pendant l'année scolaire en cours
	lab var no_education "Personne pas en education au moment de l'enquête"
		cap label drop no_education
		label define no_education 0 "En education actuellement" 1 "Pas en education actuellement"
		label values no_education no_education
ta no_education, m	/* Pas en education: 3	*/


*============  		Pas en formation			================*
// revoir : pour on ne prends pas les formtion terminé

cap drop no_formation
gen no_formation =0 if  AgeAnnee >= 6
	replace no_formation =1 if (FP1==2 | (FP1==1 & FP6!=2)) & AgeAnnee >= 6
	lab var no_formation "Personne pas en formation au moment de l'enquête"
		cap label drop no_formation
		label define no_formation 0 "En formation actuellement" 1 "Pas en formation actuellement"
		label values no_formation no_formation


// Formation professionnelle
cap drop Formation_pro
gen Formation_pro = 1 if ((FP1 == 1 & FP6==2)|FP1 == 2)
lab var Formation_pro "Suivez vous actuellement une formation professionnelle?"
label values Formation_pro PAT_16_plus 


*============				Neets			===================*

cap drop NEETs
gen NEETs= (!inlist(pop_emp,1,2) & no_education == 1 & no_formation == 1)
lab var NEETs "Neet"
cap lab define NEETs 1 "Neet" 0 " non Neet"
lab values NEETs NEETs
 
cap drop NEET15_24 NEET15_35 NEET15_40
clonevar NEET15_24 = NEETs if jeune15_24
clonevar NEET15_35 = NEETs if jeune15_35
clonevar NEET15_40 = NEETs if jeune15_40 


cap drop NEET15_24_bis 
cap drop NEET15_35_bis 
cap drop NEET15_40_bis

gen NEET15_24_bis=1 if NEET15_24 ==1
replace NEET15_24_bis=0 if jeune15_24==1 & NEET15_24_bis!=1


gen NEET15_35_bis=1 if NEET15_35 ==1
replace NEET15_35_bis=0 if jeune15_35==1 & NEET15_35_bis!=1

gen NEET15_40_bis=1 if NEET15_40 ==1
replace NEET15_40_bis=0 if jeune15_40==1 & NEET15_40_bis!=1


*============	Pluriactivité		===================*

cap drop pluriactivite
gen pluriactivite=0 if pop_emp_dich==1 & PAT==1
replace pluriactivite=1 if (PL1==1 | (PL1==2 & PL2==1)) & PAT==1 & pop_emp_dich==1
 
lab var pluriactivite "Personne en emploi avec plus d'un activte"
lab values pluriactivite PAT


*			===========================================			*
*	Classification Internationale selon la situation dans l'emploi 
*					Assignation et réassignation 				*
*			===========================================			*

*============		 Emploi principal		====================*
cap drop sit_empEP 
gen sit_empEP = 99 if inlist(pop_emp,1,2) & PAT == 1

/* A. Première Assignation */

/* I - Employeurs - 1*/
replace sit_empEP=11 if EP3==2 & (inlist(EP11,1,2,5) | inlist(EP11,3,4,6,7) & EP14B==1) & inlist(pop_emp,1,2) & PAT==1 
/// Employeurs en entreprise légalement constituée
replace sit_empEP=12 if EP3==2 & (inlist(EP11,3,4,6,7,8) & inlist(EP14B,2,9998)) & inlist(pop_emp,1,2) & PAT==1 
/// Employeurs en entreprise non légalement constituée

/* II - Travailleurs pour compte propre- 2*/
replace sit_empEP=21 if EP3==3 & (inlist(EP11,3,4,6,7) & EP14B==1) & inlist(pop_emp,1,2) & PAT==1 // Travailleurs pour compte propre en entreprise légalement constituée 

replace sit_empEP=22 if EP3==3 & (EP11==8 | inlist(EP11,3,4,6,7) & inlist(EP14B,2,9998)) & inlist(pop_emp,1,2) & PAT==1 // Travailleurs pour compte propre en entreprise non légalement constituée

/* III- Contractuel dépendant 3*/
replace sit_empEP=3 if EP3==1 & EP6a!=1 & EP37==2 & EP10c!=1 & inlist(pop_emp,1,2) & PAT == 1

/* IV- Les employés 4 */

* IV.a - Employés permanents
replace sit_empEP=41 if (EP3==1 & inlist(EP29,3,4))|(EP3==1 & EP37==1) & inlist(pop_emp,1,2) & PAT == 1

//* Calcul durée du contrat *//
cap drop duree_contrat
gen duree_contrat = EP30 if EP30b==3 // Conversion jour en jour
replace duree_contrat=EP30*365 if EP30b==2 // Conversion Annee en jours
replace duree_contrat=EP30*30 if EP30b==1 // Conversion mois en jours
label variable duree_contrat "Duree du contrat de travail en jour"

* IV.b - Employés en contrat à durée déterminée
replace sit_empEP=42 if EP3==1 & (inlist(EP29,1,2) & duree_contrat>= 365 | (EP28==9998 & EP37==1)) & inlist(pop_emp,1,2) & PAT == 1

* IV.c - Employés temporaires
replace sit_empEP=43 if EP3==1 & ((inlist(EP29,1,2) & duree_contrat<365) | (EP28==9998)) & inlist(pop_emp,1,2) & PAT == 1

* IV.d - Apprenti ou stagiare payé
replace sit_empEP=44 if inlist(EP3,8,9)
 
 * V - Travailleurs familiaux 5 */
replace sit_empEP=5 if inlist(EP3,5,6)

 * VI - Membre coopérative 6 */
replace sit_empEP=6 if EP3==4

 * VII - Non classé 7 */
replace sit_empEP=7 if EP3==10

label var sit_empEP "Situation dans l'emploi (ICSEa 18)"
		cap label drop sit_empEP
		lab define sit_empEP 11 "Employeurs en entreprise légalement constituée" ///
							12 "Employeurs en entreprise non légalement constituée" ///
							21 "Travailleurs pour compte propre en entreprise légalement constituée" ///
							22 "Travailleurs pour compte propre en entreprise non légalement constituée" ///
							3 "Contractuel dépendant" ///
							41 "Employés permanents" ///
							42 "Employés en contrat à durée déterminée" ///
							43 "Employés temporaires" ///
							44 "Apprenti ou stagiare payé" ///
							5 "Travailleurs familiaux" ///
							6 "Membre coopérative" ///
							7 "Non classé" ///
								
		label values sit_empEP sit_empEP
		
		

cap drop sit_empEP2

gen sit_empEP2=1 if inlist(sit_empEP,11,12) // Employeurs
	replace sit_empEP2=2 if inlist(sit_empEP,21,22) // Travailleurs indépendants sans employés
	replace sit_empEP2=3 if sit_empEP==3 // Contractuel dépendant
	replace sit_empEP2=4 if inlist(sit_empEP,41,42,43,44) // Employés
	replace sit_empEP2=5 if sit_empEP==5 // Travailleurs familiaux
	replace sit_empEP2=6 if sit_empEP==6 // Membre coopérative
	replace sit_empEP2=7 if sit_empEP==7 // Non classé
	
	lab var sit_empEP2 " Situation dans l'emploi agrégé en 7 modalités (ICSEa 18_5 ou ICSE 13)"
	cap label drop sit_empEP2
	label define sit_empEP2 1 "Employeurs" /// 
							2 "Travailleurs pour compte propre ou Travailleurs indépendants sans employés" ///
							3 "Contractuel dépendant" ///
							4 "Employés" /// 
							5 "Travailleurs familiaux" ///
							6 "Membre coopérative" ///
							7 "Non classé" ///

	label values sit_empEP2 sit_empEP2

ta sit_empEP2,m /* Situation dans l'emploi aggregé en 7 modalités: 7 */


*============		 Emploi principal aggregé en 2 modalités (Travailleurs indépendants & Travailleurs dépendant)		====================*
cap drop sit_empEP3

gen sit_empEP3=1 if inlist(sit_empEP,11,12,21,22) // Travailleurs indépendants
	replace sit_empEP3=2 if inlist(sit_empEP,3,41,42,43,44,5) // Travailleurs dépendants
	replace sit_empEP3=3 if sit_empEP==6 // Membre coopérative
	replace sit_empEP3=4 if sit_empEP==7 // Non classé
	
	lab var sit_empEP3 " Situation dans l'emploi agrégé en 2 modalités (...)"
	cap label drop sit_empEP3
	label define sit_empEP3 1 "Travailleurs indépendants" /// 
							2 "Travailleurs dépendants" ///
							3 "Membre coopérative" ///
							4 "Non classé" ///

	label values sit_empEP3 sit_empEP3

ta sit_empEP3,m /* Situation dans l'emploi aggregé en 5 modalités: 7 */


/*/ *=============== Creation du secteur instituionnel plutot ici au lieu de le faire dans le dofile 1_1 car la creation utilise la variable pop_emp qui est crée dans ce dofile. 


*** Secteur instituionnel 2
cap drop secteur_institionnel2
gen secteur_institionnel2 = 2 if PAT==1 & inlist(pop_emp,1,2)
replace secteur_institionnel2 = 1 if inlist(EP11,1,2) & PAT==1 & inlist(pop_emp,1,2)
replace secteur_institionnel2 = 3 if EP11 ==8 & PAT==1 & inlist(pop_emp,1,2)
cap label drop secteur_institionnel2
lab var secteur_institionnel2 "Secteur institutionnel"
lab define secteur_institionnel2 1 "Public" 2 "Privé" 3 "Menage"
lab values secteur_institionnel2 secteur_institionnel2

*** Secteur instituionnel3
cap drop secteur_institionnel3
recode  EP11 (1 2 =1) (3=2) (4=3) (5=4) (6 7=5) (8=6), gen(secteur_institutionnel3)
lab var secteur_institutionnel3 "Secteur institutionnel"
cap label drop instituionnel3
lab define secteur_institutionnel3 1 "Public/parapublic" 2 "Entreprise privée non agricole" 3 "Entreprise agricole" 4 "Organisation internationale" 5 "ONG/eglise" 6 "Ménage"
lab values secteur_institutionnel3 secteur_institutionnel3 */

