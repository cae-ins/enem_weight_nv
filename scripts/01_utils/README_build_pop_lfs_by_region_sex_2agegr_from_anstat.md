# Construction `POP_LFS_BY_REGION_SEX_2AGEGR` depuis ANStat

Script associe :

```text
scripts/01_utils/build_pop_lfs_by_region_sex_2agegr_from_anstat.py
```

## Objectif

Construire le fichier Excel :

```text
POP_LFS_BY_REGION_SEX_2AGEGR_<annee>_<trimestre>.xlsx
```

a partir du fichier source :

```text
ANStat_Trimestre_<annee>.xlsx
```

Le script utilise les feuilles `TAB2`, par defaut :

```text
TAB2_<trimestre>_<annee>
```

`TAB1` n'est pas utilise comme source de donnees. Il sert uniquement de controle final du total quand la feuille existe.

## Processus

Le script :

1. lit `TAB2_<trimestre>_<annee>` dans `ANStat_Trimestre_<annee>.xlsx` ;
2. recupere les noms de regions exacts et les codes `Domain` depuis un fichier gabarit `POP_LFS...` ;
3. reconstruit les groupes d'age attendus ;
4. ecrit uniquement l'Excel cible, sans creer de `.RData` ;
5. applique l'arrondi ;
6. corrige les marges regionales pour matcher le niveau national ;
7. lance les controles de coherence.

## Formules

Dans `TAB2`, les colonnes `0-15` et `15 ans et plus` / `15+` se chevauchent sur les personnes de 15 ans.

Le script reconstruit donc les groupes de cette facon :

```text
total_all = 0-15 + 16-19 + 20-24 + ... + 65+
0_14     = total_all - 15+
15_plus  = 15+
15_19    = 15+ - (20-24 + 25-29 + ... + 65+)
```

Pour les lignes regionales :

```text
Region x Sexe x {0_14, 15_plus}
```

avec `Milieu` vide.

Pour les lignes nationales :

```text
NATIONAL x Sexe x Milieu x {0_14, 15_19, 20_24, ..., 65_plus}
```

## Noms de regions et codes `Domain`

Les noms de regions et les codes `Domain` ne viennent pas de `ANStat`.

Ils sont repris depuis le fichier gabarit passe a `--template`, afin de conserver exactement :

- les libelles utilises par les scripts de calibration ;
- l'ordre des regions ;
- les codes `Domain`.

Le script fait seulement un mapping technique pour retrouver les regions dans `ANStat`, notamment :

```text
DISTRICT AUTONOME D'ABIDJAN        -> ABIDJAN
DISTRICT AUTONOME DE YAMOUSSOUKRO  -> YAMOUSSOUKRO
LOH-DJIBOUA                        -> LÔH-DJIBOUA
GOH                                -> GÔH
GRANDS-PONTS                       -> GRAND-PONTS
Ensemble                           -> NATIONAL
```

## Controle de coherence

Le script verifie que les deltas sont nuls pour :

- total regions vs national ;
- total par sexe ;
- total par age agrege ;
- total par sexe x age agrege ;
- total national par milieu ;
- total national par sexe x milieu ;
- total final contre `TAB1`, si la feuille `TAB1_<trimestre>_<annee>` existe.

Si un delta non nul est detecte, le script echoue et n'ecrit pas de fichier valide.

## Exemple en lecture seule

Pour tester sans ecrire l'Excel :

```powershell
python scripts\01_utils\build_pop_lfs_by_region_sex_2agegr_from_anstat.py `
  --year 2026 `
  --quarter T1 `
  --template data\06_POPULATION_ESTIMATES\2026\T1\POP_LFS_BY_REGION_SEX_2AGEGR_2026_T1.xlsx `
  --dry-run
```

Le `dry-run` doit afficher des controles avec delta `0`, par exemple :

```text
Total: regional=32693790 national=32693790 delta=0 OK
Sexe 1: regional=17066158 national=17066158 delta=0 OK
Sexe 2: regional=15627632 national=15627632 delta=0 OK
Age 0_14: regional=12332180 national=12332180 delta=0 OK
Age 15_plus: regional=20361610 national=20361610 delta=0 OK
```

## Exemple de generation

Pour generer un prochain trimestre, par exemple `T2_2026` :

```powershell
python scripts\01_utils\build_pop_lfs_by_region_sex_2agegr_from_anstat.py `
  --year 2026 `
  --quarter T2 `
  --template data\06_POPULATION_ESTIMATES\2026\T1\POP_LFS_BY_REGION_SEX_2AGEGR_2026_T1.xlsx `
  --backup-existing
```

Par defaut, la sortie sera :

```text
data/06_POPULATION_ESTIMATES/<annee>/<trimestre>/POP_LFS_BY_REGION_SEX_2AGEGR_<annee>_<trimestre>.xlsx
```

## Options utiles

```text
--anstat <path>       Chemin explicite vers le fichier ANStat.
--sheet <name>        Feuille TAB2 explicite, si le nom ne suit pas le defaut.
--template <path>     Fichier POP_LFS utilise comme gabarit obligatoire.
--output <path>       Chemin de sortie explicite.
--dry-run             Teste le processus sans ecrire l'Excel.
--backup-existing     Renomme une sortie existante avant d'ecrire.
--overwrite           Remplace une sortie existante.
```

## Point important

Le script ne cree pas de `.RData`. Les scripts R existants peuvent ensuite lire l'Excel genere et produire les objets R necessaires.
