# 📝 RUWTHS : R Unified Weighting Treatment Harmonized System

**RUWTHS** *(prononcé "Ruth's")* est un système modulaire développé en **R** pour le traitement harmonisé des pondérations dans les enquêtes statistiques.
Ce projet consiste en une refonte du dispositif de calcule des différentes types de pondérations dans le cadre de l'Enquête Nationale sur l'Emploi auprès des Ménages (ENE-M).
Il est en phase de test mais est déjà fortement stable. Il est écrit entièrement en R pour tirer avantage des solutions Open Source.

---

## 🧭 Objectif

RUWTHS vise à :

- Unifier les étapes de pondération dans des enquêtes répétées ou longitudinales
- Standardiser le traitement des non-réponses, ajustements, calages et calibration (la calibration est réalisée à partir de **Rgenesees**)
- Produire des fichiers de pondérations robustes, traçables et reproductibles
- Générer automatiquement des diagnostics d'erreur et d'incohérences dans les données.

---

1. **Générer le fichier de dénombrement consolidé**  
2. **Générer le fichier de dénombrement consolidé par trimestre**  
3. **Copier les fichiers `ménages` et `individus appariés`**
   - Les placer dans le dossier `data/` ou dans les dossiers **trimestriels** de l’enquête  
   - Respecter la **nomenclature** en vigueur  
4. **Ajouter la variable `finalnumtrimestre`**  
5. **Lancer le code de calcul des fichiers de tracking**  
6. **Lancer le code de calcul des colonnes pour le trimestre**  
7. **Lancer le code de calcul des poids par segment**  
8. **Lancer le code des non-réponses par segment**  
9. **Lancer le code d’ajustement des pondérations pour la réinterrogation**
