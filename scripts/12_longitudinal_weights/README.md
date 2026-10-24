# Probabilités de retour et poids longitudinaux

Ce module estime les probabilités nécessaires à la correction de l’attrition du panel ENE-M. Il reprend la logique du papier sur les transitions du marché du travail — correction IPW, winsorisation et recalage ultérieur — mais reconstruit les cibles de réponse directement à partir du schéma de rotation observé.

## Fenêtres estimées

Pour un individu \(i\), une vague d’origine \(t\) et une destination \(t+h\), la cible vaut

\[
R_{i,t,h}=\mathbf{1}\{i\text{ est observé au rang attendu à }t+h\}.
\]

Les trois transitions admises sont :

- rang 1 vers rang 2, avec \(h=1\) trimestre ;
- rang 3 vers rang 4, avec \(h=1\) trimestre ;
- rang 1 vers rang 3, avec \(h=4\) trimestres.

Une origine n’entre dans le modèle que si le trimestre de destination existe dans la base complète. Les observations situées à la fin de la période disponible ne sont donc pas classées artificiellement comme attrition.

Un logit distinct est estimé dans chaque fenêtre :

\[
\widehat p_{i,t,h}=\Pr(R_{i,t,h}=1\mid X_{i,t}),
\qquad
\operatorname{logit}(\widehat p_{i,t,h})=X_{i,t}'\widehat\beta_{t,h}.
\]

Toutes les covariables sont mesurées à l’origine. Les agrégats calculés sur l’ensemble des vagues d’un ménage, comme `rempli_mng_moy`, `part_complets` et la version historique de `cm_repondu`, sont volontairement exclus : ils contiennent de l’information postérieure à la vague d’origine.

Pour les répondants à la destination, le poids avant recalage est

\[
w^{L,\mathrm{brut}}_{i,t,h}=\frac{w^{CS}_{i,t}}{\widehat p_{i,t,h}},
\]

où \(w^{CS}_{i,t}\) est le poids transversal calibré à l’origine. Le module fournit aussi une version winsorisée au 99e centile, séparément dans chaque fenêtre. Le recalage 180X sur les marges de la vague d’origine constitue l’étape suivante ; il ne doit pas être remplacé par la winsorisation.

## Exécution

```powershell
Rscript scripts/12_longitudinal_weights/01_estimate_return_probabilities.R `
  --input "C:/chemin/base_empilee.dta"
```

Le chemin peut aussi être fourni par `ENE_LONGITUDINAL_INPUT`. La configuration se trouve dans `config/longitudinal_propensity.yml`.

## Sorties

Les sorties sont placées par défaut dans `data/04_weights/longitudinal/` et ne doivent pas être versionnées :

- `return_probabilities.parquet` : cibles, probabilités, facteurs IPW et poids avant recalage ;
- `return_probability_diagnostics.parquet` : diagnostics par fenêtre ;
- `propensity_models.rds` : objets des modèles, recette de préparation et configuration.

Le Parquet est la sortie analytique. Le RDS ne stocke que les objets nécessaires à l’audit et à la reproduction des probabilités.
