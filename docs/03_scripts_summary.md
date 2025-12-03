## Résumé des scripts R du projet

Ce document fournit un résumé lisible du fichier `docs/scripts_summary.csv` (liste des scripts R, rôle court, packages, entrées, sorties, fonctions détectées). Le CSV contient les chemins complets et une courte description. Le but est d'avoir un index exploitable pour la revue de code et la génération de documentation.

Principaux points

- Emplacement CSV : `docs/scripts_summary.csv` (machine‑readable, colonne séparée par virgules).
- Contenu : pour chaque script R listé, colonnes : `path, short_role, packages, inputs, outputs, functions`.
- Couverture immédiate :
  - `scripts/01_utils/` — utilitaires et traitement des fichiers ménage/denombrement (déjà documentés en détail dans `01_scripts_R.md`).
  - `scripts/02_base_weights/` — préparation des colonnes, calculs des probabilités et poids de base.
  - `scripts/03_nonresponse/` — ajustement non-réponse et matrices de suivi.
  - `scripts/04_calibration/QUARTERLY_WEIGHTING/2025/T1/` — designs `180X_1D`, `312X_1D`, `444X_1D` (entrées 00..05 + 04f mapping). Ces scripts sont détaillés dans `01_scripts_R.md` (extraits et fonctions inline).

Remarques et recommandations

- Le CSV contient les scripts déjà analysés et les principales fonctions détectées. Le repository contient ~470 scripts R; j'ai priorisé ceux documentés dans `01_scripts_R.md` et tous les scripts de calibration T1_2025.
- Si vous voulez un export complet et strict (colonnes remplies automatiquement pour chaque script), je peux :
  1) Extraire automatiquement les 1ères ~200 lignes (en-têtes + commentaires) de chaque `scripts/**/*.R` dans `docs/headers/` (un fichier par script), ou
  2) Exécuter un parse plus avancé qui tente d'extraire `@imports`, `@param`, `@return` et les fonctions nommées pour toutes les R files et remplir le CSV complètement.

Comment utiliser

- Ouvrez `docs/scripts_summary.csv` dans Excel, LibreOffice ou un éditeur de texte pour une vue tabulaire.
- Pour la lecture humaine rapide, utilisez ce fichier MD (ceux-ci sont des résumés, pas des remplacements des scripts originaux).

Prochaine action suggérée (optionnelle)

- Générer `docs/headers/` (extraction des premiers 200 lignes par script) — utile pour les revues rapides.
- Intégrer ces métadonnées directement dans `01_scripts_R.md` si vous préférez centraliser toute la doc en un seul fichier.

- Mettre à jour régulièrement `docs/scripts_summary.csv` via un script automatisé (par exemple, un script R qui scanne `scripts/` et régénère le CSV).
