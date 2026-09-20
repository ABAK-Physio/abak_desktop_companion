# Modification locale ABAK

Base : bodyheatmap 1.0.0, copie de l’archive conservée dans `review/package`.
Licence MIT conservée dans LICENSE.

Une seule modification du composant : `leg-back-mid-right` est associé à
`back-leg-left` au lieu de `back-leg-right`. Ce tracé est à x=242–247,5,
à droite de la silhouette dorsale (axe x=239), donc sur la cuisse droite du
patient. Le groupe original mélangeait les deux côtés.

Les identifiants techniques d’origine restent inchangés. Les libellés français
et la convention patient sont gérés dans l’application, dans `lib/regions.dart`.
Ne pas déduire le côté anatomique des suffixes anglais des identifiants.
