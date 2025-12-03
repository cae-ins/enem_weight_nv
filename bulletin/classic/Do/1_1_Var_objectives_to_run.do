
*		================================					*
*                       Age									*
*		================================					*

* ===================       Age      =======================*
cap drop age
gen age = M4Confirm if AgeAnnee >= 13 
	replace age = AgeAnnee if AgeAnnee < 13
		lab var age "Age de l'individu"
ta age, mis

drop if inlist(age,.,.a) // Suppression des individu sans age
// revoir: on voit que certains individus ont des ages vide ou -9998, on attent le retour de l'appurement.


*=================      Groupe d'âge	 	================*

*** Groupe d'âge 1
cap drop grp_age
gen grp_age = 1*(age<15) + 2*(age >= 15 & age <= 24) ///
		+ 3*(age > 24 & age <= 35) + 4*(age > 35 & age <= 64) ///
		+ 5*(age > 64) if age<.              

		lab var grp_age "Groupe d'âge"
		cap label drop grp_age
		label define grp_age 1 " moins de 15 ans " 2 "15 à 24 ans" ///
		3 "25 à 35 ans" 4 " 36 à 64 ans" 5 " 65 ans et plus"
		label values grp_age grp_age
ta grp_age, m


*** Groupe d'age cinquenaux
cap drop grpe_age5
gen grpe_age5 = 1*(age <= 4) + 2*(age > 4 & age <= 9) ///
		 + 3*(age > 9 & age <= 14) + 4*(age > 14 & age <= 19) ///
		 + 5*(age > 19 & age <= 24) + 6*(age > 24 & age <= 29) ///
		 + 7*(age > 29 & age <= 34) + 8*(age > 34 & age <= 39) ///
		 + 9*(age > 39 & age <= 44) + 10*(age > 44 & age <= 49) ///
		 + 11*(age > 49 & age <= 54) + 12*(age> 54 & age <= 59) ///
		 + 13*(age > 59 & age <= 64) + 14*(age > 64) if age <.        
		
		cap label drop grpe_age5
		lab var grpe_age5 "Groupe d'âge cinquénaux"
		label define grpe_age5 1 "Moins de 5 ans" ///
					2 "5 à 9 ans" 3 "10 à 14 ans" ///
					4 "15 à 19 ans" 5 "20 à 24 ans " ///
					6 "25 a 29 ans" 7 "30 à 34 ans" ///
					8 "35 à 39 ans" 9 "40 à 44 ans" ///
					10 "45 à 49 ans" 11 "50 à 54 ans" ///
					12 "55 à 59 ans" 13 "60 à 64 ans" ///
					14 "65 ans et plus"
		label values grpe_age5 grpe_age5
ta grpe_age5, m

*** Groupe d'âge 3
cap drop grp_age3
gen grp_age3 = 1*(age<15) + 2*(age >= 15 & age <= 24) + 3*(age > 24 & age <= 64) ///
				+ 4*(age > 64) if age<. 
		lab var grp_age3 "Groupe d'âge 3"
		cap label drop grp_age3
		lab def grp_age3 1 "Moins de 15 ans" 2 "15 à 24 ans" 3 "25 à 64 ans" ///
						4 "65 ans et plus"
		lab val grp_age3 grp_age3
ta grp_age3, m
	
*** Groupe d'Age 4
cap drop groupe_age4
gen groupe_age4 = 1 * (age >= 16 & age<=24) + 2 * (age >= 25 & age<=35) + 3 * (age >= 36 & age<=64) + 4 * (age >= 65 )
cap label drop groupe_age4
label define groupe_age4 1 "16-24 ans" 2 "25-35 ans" 3 "36-64 ans" 4 "65 ans et plus"
label values groupe_age4 groupe_age4
label var groupe_age4 "Groupe d'Âge 4"
ta groupe_age4, m



*** Groupe d'Age 5
cap drop groupe_age5
gen groupe_age5 = 1 * (age >= 16 & age<=35) + 2 * (age >= 36 & age<=64) + 3 * (age >= 65 )
cap label drop groupe_age5
label define groupe_age5 1 "16-35 ans" 2 "36-64 ans" 3 "65 ans et plus"
label values groupe_age5 groupe_age5
label var groupe_age5 "Groupe d'Âge 5"
ta groupe_age5, m


*** Groupe d'Age 6
cap drop groupe_age6
gen groupe_age6 = 1 * (age >= 15 & age<=19) + 2 * (age >= 20 & age<=24) + 3 * (age >= 25 & age<=29) + 4 * (age >= 30 & age<=35) + 5 * (age >= 36 & age<=40)
cap label drop groupe_age6
label define groupe_age6 1 "15-19 ans" 2 "20-24 ans" 3 "25-29 ans" 4 "30-35 ans" 5 "36-40 ans"
label values groupe_age6 groupe_age6
label var groupe_age6 "Groupe d'Âge 6"
ta groupe_age6, m

*** Groupe d'Age 6
cap drop groupe_age7
gen groupe_age7 = 1 * (age >= 15 & age<=19) + 2 * (age >= 20 & age<=24) + 3 * (age >= 25 & age<=29) + 4 * (age >= 30 & age<=34) + 5 * (age >= 35 & age<=40)
cap label drop groupe_age7
label define groupe_age7 1 "15-19 ans" 2 "20-24 ans" 3 "25-29 ans" 4 "30-34 ans" 5 "35-40 ans"
label values groupe_age7 groupe_age7
label var groupe_age7 "Groupe d'Âge 7"
ta groupe_age7, m


		
*===================  Groupe d'age spécifique  ==================*
cap drop jeune15_24
gen jeune15_24 = (age >=15 & age <=24)											// jeune BIT
		lab var jeune15_24 "Jeune de 15 à 24 ans"
		cap label drop jeune15_24
		lab define jeune15_24 1 "Oui" 0 "Pas concerné"
		lab values jeune15_24 jeune15_24
ta jeune15_24, m

cap drop jeune15_35
gen jeune15_35 = (age >=15 & age <=35)											// Jeune Côte d'Ivoire adapté au BIT
		lab var jeune15_35 "Jeune au niveau international"
		lab values jeune15_35 jeune15_24
ta jeune15_35, m


cap drop jeune15_40
gen jeune15_40 = (age >=15 & age <=40)											// Jeune AEJ adapté au BIT
		lab var jeune15_40 "Jeune selon l'Agence Emploi Jeune"
		lab values jeune15_40 jeune15_24
ta jeune15_40, m
		

*=================        Sexe      ============================*
cap drop sexe
clonevar sexe = M5
		lab var sexe "Sexe de l'individu"

ta sexe, m



*                    ==============================						*
*                             EDUCATION         						*
*                    ================================                   *

*==================  Individu jamais scolarisé =========================*

cap drop scolarise
gen scolarise = .
	replace scolarise = 1 if (age >= 3 & (EF1 == 2))
	replace scolarise = 0 if (age >= 3 & EF1 == 1 )
		lab var scolarise "Jamais été scolarisé"
		cap label drop scolarise
		lab define scolarise 1 "Jamais scolarisé" 0 "Déjà scolarisé"
		lab values scolarise scolarise
ta scolarise, m


*==================  Niveau d'instruction    ==========================*
cap drop niveau_instruction
gen niveau_instruction = -99 if EF1 == 2 & age >= 3					// Jamais scolarisé
	replace niveau_instruction = EF7 if EF6 == 1 & EF1 == 1 & age >= 3 // Personnes ayant fréquenté durant l'année scolaire en cours	
	replace niveau_instruction = EF11 if EF10 == 1 & EF6!=1 & EF1 == 1 & age >= 3 // Personnes ayant fréquenté l'année passée mais pas cette année
	replace niveau_instruction = EF3 if EF6 != 1 & EF10 != 1 & EF1 == 1 & age >= 3 // Personnes qui n'ont pas fréquenté les deux dernières années
		lab var niveau_instruction " Niveau d'instruction"
		cap label drop niveau_instruction
		label define niveau_instruction -99 "Aucun niveau" 1 "Préscolaire" ///
				2 "Primaire" 3 "Secondaire général cycle I" ///
				4 "Sécondaire technique/profesionnelle cycle I" ///
				5 "Sécondaire général cycle II" 6 "secondaire technique/professionnelle II" 7 "Supérieur  cycle court" ///
				8 "Licence" 9 "Maitrise/ Master 1" ///
				10 " Master 2 /DEA/DESS " 11 "Doctorat" 12 "Post Doctorat"
				
				
		label values niveau_instruction niveau_instruction

ta niveau_instruction, m	/* Niv instr: 4 */

// revoir: il arrive que certains individu de plus de 3 ans n'ont pas de niveau instruction, ce qui n'est pas normal. on doit verfier dans la base.
// ed interview__key age niveau_instruction Statut_Res if (niveau_instruction==. | niveau_instruction==.a) & age>=3 & age!=.ç


*================== Niveau d'instruction agrégé 1 ====================*
cap drop Niv_inst_AG1
recode niveau_instruction (1 -99=1)(2=2) (3 4=3) (5 6=4) (7 8= 5) (9 10 = 6) (11 12 = 7) ///
							,gen(Niv_inst_AG1)
		lab var Niv_inst_AG1 " Niveau d'instruction agrégé en 7 modalités"
		cap label drop Niv_inst_AG1
		label define Niv_inst_AG1 1 "Aucun niveau" 2 "Primaire" ///
			3 "Secondaire premier cycle" 4 "Secondaire deuxième cycle" ///
			5 "Superieur premier cycle" 6 "Superieur deuxième cycle" ///
			7 "Superieur troisième cycle"
		label values Niv_inst_AG1 Niv_inst_AG1

ta Niv_inst_AG1,m /* Niv instr agrégé en 7 modalités: 7 */



*==================   Niveau d'instruction agrégé 2  =================*
cap drop Niv_inst_AG2
recode niveau_instruction (1=1) (-99=1)(2=2) (3/6=3) (7/12 = 4), gen(Niv_inst_AG2)
		lab var Niv_inst_AG2 " Niveau d'instruction agrégé en 4 modalités"
		cap label drop  Niv_inst_AG2
		label define Niv_inst_AG2 1 "Aucun niveau" 2 "Primaire" 3 "Secondaire" 4 "Superieur"
		label values Niv_inst_AG2 Niv_inst_AG2

ta Niv_inst_AG2, m 	/* Niv instr agrégé en 4 modalités: 4 */

*==================   Niveau d'instruction agrégé 3  =================*
cap drop Niv_inst_AG3
recode Niv_inst_AG1 (1 =1) (2=2) (3=3) (4=4) (5/7 = 5), gen(Niv_inst_AG3)
		lab var Niv_inst_AG3 " Niveau d'instruction agrégé en 5 modalités"
		cap label drop Niv_inst_AG3
		label define Niv_inst_AG3 1 "Aucun niveau" 2 "Primaire" 3 "Secondaire premier cycle" 4 "Secondaire deuxième cycle" ///
			5 "Superieur"
		label values Niv_inst_AG3 Niv_inst_AG3

ta Niv_inst_AG3, m 	/* Niv instr agrégé en 5 modalités: 5 */


*================  			Classe atteint  =======================*
cap drop classe_atteint
gen classe_atteint = -99 if EF1 == 2 & age >= 3		// Jamais scolarisé
	replace classe_atteint = EF8 if EF6 == 1 & EF1 == 1 & age >= 3				// Personnes ayant fréquenté durant l'année scolaire en cours	
	
	replace classe_atteint = EF12 if EF10 == 1 & EF6 != 1 & EF1 == 1 & age >= 3 // Personnes ayant fréquenté l'année passée mais pas cette année
	replace classe_atteint = EF4 if EF10 != 1 & EF6 != 1 & EF1 == 1 & age >= 3  // Personnes qui n'ont pas fréquenté les deux dernières années
		lab var classe_atteint "Dernière classe achevée avec succès"
		cap label drop classe_atteint
		label define classe_atteint -99 "Aucun niveau" 1 "Petite section" ///
				2 "Moyenne session" 3 "Grande session" 4 "CP1" 5 "CP2" 6 "CE1" ///
				7 "CE2" 8 "CM1" 9 "CM2" 10 " 6ème;UM ;AAP;CQP1" 11 "5ème;FPC;CQP2" ///
				12 "4ème" 13 "3ème;CAP1;BEP1" 14 "2nde;2sd G1, G2,F1,F2,B,E, H;CAP2;BT1" ///
				15 "1ère;1ere G1, G2,F1,F2,B,E, H;CAP3;BEP2;1èreAnné ed'adaptation;BT2" ///
				16 "le,BACC,A1,A2, D;BAC G1" 17 "BAC+1;BP;BTS 1" 18 "BAC+2;BTS 2; DUT" ///
				19 "BAC+3" 20 "BAC+4IngénieurTechnique" 21 "BAC+5IngénieurdeconceptionMaster" ///
				22 "Doctorat ou plus"
		label values classe_atteint classe_atteint

ta classe classe_atteint, m 	/* Classe atteint: 4 */


*=========== Nombre d'années d'etudes reussies avec succès ========*
cap drop nbr_annee_etude
recode classe_atteint (-99=0) (1/4 = 0) (5=1) (6=2) (7=3) (8=4) (9=5) (10=6) ///
					(11=7) (12=8) (13=9) (14=10 ) (15=11) (16=12) (17=13) ///
					(18=14) (19=15) (20=16) (21=17) (22=18), gen(nbr_annee_etude)
		lab var nbr_annee_etude "Nombre d'années d'études suivies avec succès"
ta nbr_annee_etude, m	/* 4 repondants */


*================== Nombre moyen d'années d'études  ===============*
mean nbr_annee_etude


*=================  Plus haut diplome     =========================*
cap drop haut_diplome
clonevar haut_diplome = EF4_1 if age >=3
		lab var haut_diplome "Plus haut diplome obtenu"
ta haut_diplome




*						===================						  *
*				         MILIEU DE RESIDENCE    				  *
*						===================     				  *

*====================  Milieu de residence =======================*
cap drop milieu_residence
clonevar  milieu_residence = HH6
ta milieu_residence 		/* 13 menages */


*=================   Milieu de residence désagrégé ==============*
cap drop milieu_resid2
gen milieu_resid2 = 2 if HH6 == 1
	replace milieu_resid2 = 1 if HH6 == 1 & inlist(HH4,1010100211, 1010100212, 1010100213, 1010100214, 1010100215, 1010100216, 1010100217, 1010100218, 1010100219, 1010100220) // revoir: utilisation de HH4 pour les communes d'Abidjan
	replace milieu_resid2 = 3 if HH6 == 2
		lab var milieu_resid2 "milieu de residence désagrégé"
		cap label drop milieu_resid2
		lab define milieu_resid2 1 "Abidjan" 2 "Autre urbain" 3 " Rural"
		lab values milieu_resid2 milieu_resid2
ta milieu_resid2 	/* 13, conforme au milieu  de residence */



*================    	 Region 			====================*
cap drop region
clonevar region = HH2
ta region 


*===============		District			====================*
cap drop district
clonevar district = HH1
ta district


/*Nous creons le secteur institutionnel plutot dans le dofile 1_2 car il utilise la variable pop_emp qui n'est crée que labas  
*================= Secteur institutionnel   ============================*
/*revoir :*/

*** Secteur institutionnel au sens de la comptabilité nationale			
*pop_emploi_16_plus
cap drop secteur_institutionnel
gen secteur_institutionnel = 1*(EP11==1 | EP11==2) + 2*(EP11==3|EP11==4) + 3*(EP11==7 | EP11==8) + 4*(EP11==9)+ 5*(EP11==6) if (pop_emp	==1	& EP11 !=.)  
// les secteurs institutionneL
*NB:dans le version finale de l'enquête, une question doit préciser le statut (fiancièr ou non financièr) des entreprises privées non agricoles

label var secteur_institutionnel "Secteur institutionnel"
cap label define secteur_institutionnel 1 " Administration publique" 2 "Societé non financière" 3 "Institution sans but lucratif" 4 "Menage" 5 "Reste du monde"
label values secteur_institutionnel secteur_institutionnel



*** Secteur instituionnel 2

cap drop secteur_institionnel2
gen secteur_institionnel2 = 1 if  pop_emp ==1 
replace secteur_institionnel2 = 2 if inlist(EP11,3,4,6) &  pop_emp ==1 
replace secteur_institionnel2 = 3 if EP11 ==8 & pop_emp ==1 

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

*               ==============================                     *
*                Caractéristiques du logement                      *
*              ================================					   *

*===================  Type du batiment  ===========================*
cap drop type_logement
clonevar type_logement = L1
lab var type_logement "Type de logement"
ta type_logement


*==================     Nature des murs    ========================*
cap drop nature_murs
clonevar nature_murs = L3
lab var nature_murs "Nature des murs"
ta nature_murs


*==================    Statut d'occupation  ======================*
cap drop statut_occupation
clonevar statut_occupation = L5
lab var statut_occupation "Statut d'occupation"
ta statut_occupation


*==================  	Mode d'éclairage  		=================*
cap drop mode_eclairage
clonevar mode_eclairage = L4
lab var mode_eclairage "Mode d'eclairage"
ta mode_eclairage


*				====================================					*
*                 Categorie socio-professionnelle						*
*				====================================					*
cap drop cat_profEP
clonevar cat_profEP = EP13														// Dans l'emploi principal
ta cat_profEP

cap drop cat_profES
clonevar cat_profES = ES13														// Dans l'emploi principal
ta cat_profES
		
