*******************************************************************
******  	Enquête Emploi Continu: Bulletin trimestriel	*******
*******************************************************************

/* Si vous desirez exécuter ce dofile de façon indépendante, veuillez  retirer le commentaire de la variable <<global>> et adapeter le chemin d'acès 

global wd "E:\CAE-INS\Refonte_enquête_emploi\Pilote"

*/

claer all
cls	  
	  
gl wd "D:\CAE-INS\Refonte_enquête_emploi\Pilote"	  
gl base_brute "$wd\Pilote_2\Production_Indicateurs\Base\Base_brute\Interview"
gl base_finale "$wd\Pilote_2\Production_Indicateurs\Base\Base_finale"


use "$base_finale\Base_finale.dta", clear



*		 		===============================					*
*		Structure de la population en âge de travailler			*
*			   ================================					*

*========= 		Population en âge de travailler		============*
gen PAT= (age>=15 & age<.)
		lab var PAT "population en âge de travailler selon le BIT"
		lab define 1 "Oui" 0 "Non"
		label values PAT PAT
tab PAT		/* PAT:  19 */


*======         Population en emploi: pop_emploi     ===========*

*** Emploi present
gen emp_present = 0 if PAT == 1
	replace emp_present = 1 if act_rem==1|inrange(otr_act,1,9) | act_eco==1 | inlist(stag_app,1,2) // Personne présente au poste de travail
	replace emp_present = 1 if aid_rem==1 & inlist(dest_prod,1,2) 						// Travailleurs familiaux
		lab var emp_present "Population en emploi présent"
		lab values emp_present PAT

*** Emploi absent
gen emp_absent = 0 if PAT == 1 
	replace emp_absent = 1 if emp_hab==1 & inrange(rais_abs,1,4)							// Travailleurs en congés autorisé 
	replace emp_absent = 1 if emp_hab==1 & rais_abs ==10 & bas_sais ==1						// Travailleurs absents qui retrouvera son poste en moins de 3 mois
	replace emp_absent = 1 if emp_hab==1 & inrange(rais_abs,5,9) & tps_rep==1				// Travailleurs absents qui perçoivent un revenu
	replace emp_absent = 1 if emp_hab==1 & inlist(rais_abs,11,12,13,15) & tps_rep==1 		// Travailleurs absents qui perçoivent un revenu
	replace emp_absent = 1 if emp_hab==1 & inrange(rais_abs,5,9) & inlist(tps_rep,2,3) & rem_cont==1 // Travailleurs absents qui perçoivent un revenu
	replace emp_absent = 1 if emp_hab==1 & rais_abs ==10 & bas_sais ==2 & inlist(tps_rep,2,3) & rem_cont==1 	// Travailleurs absents qui perçoivent un revenu
	replace emp_absent = 1 if emp_hab== 1 & inlist(rais_abs,11,12,13,15) & inlist(tps_rep,2,3) & rem_cont==1	// Travailleurs absents durant plus de 3 mois et perçevant un revenu
	replace emp_absent = 1 if emp_hab==1 & rais_abs==14 & cong_sab==1						// Congés sabbatique exerçant une autre activité remunérée
	replace emp_absent = 1 if emp_hab==1 & rais_abs==14 & cong_sab==2 & rem_cont == 1			// Congés sabbatique perçevant un revenu
	replace emp_absent = 1 if emp_hab==1 & rais_abs==14 & cong_sab==2 & tps_rep == 1			// Congés sabbatique revenant à moins de 3 mois
		lab var emp_absent "Population absent à leur poste de travail"
		lab values emp_absent PAT
		

*** Pop_emploi
gen pop_emp = 1 if emp_present == 1 & PAT == 1	
	replace pop_emp = 2 if emp_absent == 1 & PAT == 1
		label var pop_emp "Population en emploi"
		lab define pop_emp 1 "Emploi présent" 2 "Emploi absent"
		label values pop_emp pop_emp
ta pop_emp		/* pop emploi: 4 	*/



*=============    Population au Chômage         ================*
gen aucun_emp =  0 if PAT == 1
	replace aucun_emp = 1 if ((rech_empS ==1 | rech_empI==1) & dispo == 1) & !inlist(pop_emp,1,2)	// Personne n'ayant aucun emploi
		label var aucun_emp "Chômeur qui n'ont pas d'emploi"
		label values aucun_emp PAT

gen futures_staters =  0 if PAT == 1
	replace futures_staters = 1 if (rech_empS ==1 | rech_empI==1) & SRH12A__18 == 1///
							& dispo == 1 & !inlist(pop_emp,1,2)  				// Chômeur qui a une promesse d'emploi
		label var futures_staters "Recherchent pas un emploi car ils en ont déjà trouvé un et sont disponibles pour commencer un emploi"
		label values futures_staters PAT

gen pop_chomage = 1 if aucun_emp == 1 & !inlist(pop_emp,1,2) & PAT == 1
	replace pop_chomage = 2 if futures_staters == 1 & !inlist(pop_emp,1,2) & PAT == 1
		lab var pop_chomage "Population au chômage"
		lab define pop_chomage 1 "Auncune recherche d'emploi" 2 "Futures staters"
		label values pop_chomage pop_chomage
ta pop_chomage	/* pop_chomage: 1	*/



**======	 Statut de la population en age de travailler  ==========*
gen statut_MO = 3 if PAT == 1
	replace statut_MO = 1 if inlist(pop_emp,1,2)
	replace statut_MO = 2 if inlist(pop_chomage,1,2) 
		lab var statut_MO "Statut de la population en age de travailler"
		lab define statut_MO 1 "Population en emploi" 2 "Population au chomage" ///
				3 "Population hors main d'oeuvre"
		label values statut_MO statut_MO
ta statut_MO	/* statut_MO: 19	*/

		
		
*===============		   Main d'oeuvre	   =================*
gen MO = 1 if PAT == 1 & inlist(pop_emp,1,2)
	replace MO = 2 if PAT == 1 & inlist(pop_chomage,1,2)
		lab var MO "Main d'oeuvre 2"
		lab define MO 1 "Population en emploi" 2 "Population au chômage"
		lab values MO MO
ta MO		/* MO: 5 */



*=================   Main d'oeuvre potentielle    ==============*
gen Non_dispo =  (PAT == 1 & !inlist(pop_emp,1,2) & !inlist(pop_chomage,1,2) & (rech_empS == 1 | rech_empI == 1) & dispo == 2) // Personne sans emploi, recherchant un emploi et pas disponible à travailler
		lab var Non_dispo "Personne non disponibles"
		lab values Non_dispo PAT

gen aucune_rech = (PAT == 1 & !inlist(pop_emp,1,2) & !inlist(pop_chomage,1,2) & (rech_empS == 2 & rech_empI == 2) & dispo == 1) // Disponible mais ne cherchant pas d'emploi
		lab var aucune_rech "Aucune recherche"
		lab values aucune_rech PAT

gen MOPOT = 1 if PAT == 1 & Non_dispo==1
	replace MOPOT = 2 if PAT == 1 & aucune_rech == 1
		lab var MOPOT "Main d'oeuvre potentielle"
		lab define MOPOT 1 "Non disponible" 2 "Aucune recherche"
		label values MOPOT PAT
ta MOPOT 	/* MOPOT: 0	*/


*============ Main d'oeuvre élargie: MOE    ===================*
gen MOE = 1 if PAT == 1 & inlist(MO,1,2)
	replace MOE = 2 if PAT == 1 & MOPOT == 1
		lab var MOE "Main d'oeuvre élargie"
		lab define MOE 1 "Main d'oeuvre" 2 "Main d'oeuvre potentielle"
		lab values MOE MOE
ta MOE		/* MOE: 5 */

		
		
				
*				=================================			  *
*			 	Sous utilisation de la main d'oeuvre		  *
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
gen hor_eff = NB_HEURE_TRAVAIL_TOTAL if  tps_tvr == 1 & inlist(pop_emp,1,2)
	replace hor_eff = WKT18 if  tps_tvr == 2
		lab var hor_eff "Nombre effectif de travail"
ta hor_eff
		

	
*=========  Sous utilisation de la main d'oeuvre =============*
gen sous_emp = (PAT == 1 & inlist(pop_emp,1,2) & hor_eff < 40 & WKI4 == 1 & WKI5 == 1)
		lab var sous_emp " Sous emploi lié au temps de travail"
		lab values sous_emp PAT
ta sous_emp		/* Aucun sous emploi 	*/

		
		
*=====================  Taux de chômage SU1    =================*
gen SU1 = 0 if inlist(MO,1,2)
	replace SU1 = 1 if inlist(pop_chomage,1,2)
		lab var SU1 "Taux de chômage SU1"
		lab values SU1 PAT
ta SU1		/* SU1: 20%	*/


* Taux de chômage combiné à la sous utilisation de la durée de travail SU2
gen SU2 = 0 if PAT == 1 & inlist(MO,1,2)
	replace SU2 = 1 if (inlist(pop_chomage,1,2) | sous_emp == 1) 
		lab var SU2 "Taux de chômage lié à la durée du travail"
		lab values SU2 PAT
ta SU2		/* SU2: 20% 	*/


*== Taux chomage combiné à la main d'oeuvre potentielle : SU3 ==* 
gen SU3 = 0 if PAT == 1 & inlist(MOE,1,2)
	replace SU3 = 1 if (inlist(pop_chomage,1,2) | inlist(MOPOT,1,2))
		lab var SU3 "Taux de chômage combiné à la main d'oeuvre potentielle"
		lab values SU3 PAT
ta SU3	/* SU3: 20%	*/


* Mesure composite de la sous-utilisation de la main-d'œuvre: SU4*
gen SU4 = 0 if PAT == 1 & inlist(MOE,1,2)
	replace SU4 = 1 if (inlist(pop_chomage,1,2) | inlist(MOPOT,1,2) | sous_emp == 1)
		lab var SU4 "Taux de chômage SU4"
		lab values SU4 PAT
ta SU4	/* SU4: 20% 	*/

		
		


*				======================							*
*				  Qualité de l'emploi							*							
*				======================							*

*================= Formalité du secteur ========================*
gen form_sect = 3  if PAT == 1 & inlist(pop_emp,1,2) & nat_ent == 8
	replace form_sect = 2 if inlist(nat_ent,3,4,6,7)
	replace form_sect = 1 if inlist(nat_ent,1,2,5)
	replace form_sect = 1 if inlist(nat_ent,3,4,6,7) & ( ///
							(EP17<3  &  sys_comp <3) | ///
							(EP20 == 1 | EP21 == 1 | EP22 ==1))
		lab var form_sect "Nature de l'unité économique"
		lab define form_sect 1 "Secteur formel" 2 "Secteur informel" 3 "Ménage"
		lab values form_sect form_sect
ta form_sect	/* Sect form: 1; sect infor:1; men: 0	*/


*=============       Formalité de l'emploi		=================*

*** Emploi principal
gen form_empEP = 0 if PAT == 1 &  inlist(pop_emp,1,2)
	replace form_empEP = 1 if inrange( stat_emp,2,4) & form_sect ==1
	replace form_empEP = 1 if ( stat_emp ==1 | inrange( stat_emp, 5,10)) & ///
				(EP37 == 1 | EP38 == 1 | EP39 ==1)
		lab var form_empEP "Statut de l'emploi principal"
		lab define form_empEP 1 "Emploi formel" 0 " Emploi informel"
		lab values form_empEP form_empEP
ta form_empEP	/* Infor: 3; form:1	*/


**** Emplois secondaires
gen form_empES = 0 if PAT == 1 & inlist(pop_emp,1,2)
	replace form_empES = 1 if inrange( stat_empS,2,4) & form_sect ==1
	replace form_empES = 1 if ( stat_empS ==1 | inrange( stat_empS, 5,10)) & ///
				(ES37 == 1 | ES38 == 1 | ES39 ==1)
		lab var form_empES "Statut de l'emploi secondaire"
		lab values form_empES form_empEP
ta form_empES	/* Infor: 4	*/
		

*======= 	 		Emploi vulnerable  		==================*
gen emp_vul = 0 if PAT == 1 & inlist(pop_emp,1,2)
	replace emp_vul = 1 if inlist( stat_emp,3,5)
		lab var emp_vul "Taux d'emploi vulnerable"
		lab values emp_vul PAT
ta emp_vul		/* Emp vul: 1	*/


*================      Emploi précaire     ====================*
gen emp_prec = 0 if PAT == 1 & inlist(pop_emp,1,2)
	replace emp_prec = 1 if inlist(EP29,1,2,4)
		lab var emp_prec "Emploi précaire"
		lab values emp_prec PAT
ta emp_prec		/* Emp precaire: 1	*/

		
		

*					==========================					*     	
*							NEETS      							*
*					==========================					*

*============ 	   Pas en education 			 ===============*
gen no_education = 0 if  AgeAnnee >= 3
	replace no_education = 1 if freq_ecol == 2										// Jamais scolarisé
	replace no_education = 1 if freq_ecol == 1 & freq_scol == 2 							// Ne fréquente pas pendant l'année scolaire en cours
		lab var no_education "Personne ni en education"
		label values no_education PAT
ta no_education		/* Pas en education: 3	*/


*============  		Pas en formation			================*
gen form_informelle = 0 if age >= 3 & age <.
	replace form_informelle = 1 if (FP1 == 1 & FP6 ==2)
		lab var form_informelle "Suivez vous actuellement une formation professionnelle informelle?"
		label values form_informelle PAT
ta form_informelle


*============				Neets			===================*
/* Impossible de construire les Neets du fait qu'on arrive pas à capter la formation professionnelle */

gen NEETs= 0 if PAT == 1
	replace NEETs = 1 if !inlist(pop_emp,1,2) & no_education == 1 & form_informelle == 0
		lab var NEETs "Neet"
		lab values NEETs PAT
 
clonevar NEET15_24 = NEETs if jeune15_24
clonevar NEET15_35 = NEETs if jeune15_35
clonevar NEET15_40 = NEETs if jeune15_40 




save "$base_finale\Base_finale.dta", replace

exit