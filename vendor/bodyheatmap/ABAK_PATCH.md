# Modification locale ABAK

Base : bodyheatmap 1.0.0, copie de l’archive conservée dans `review/package`.
Licence MIT conservée dans LICENSE.

Correction du découpage : `leg-back-mid-right` est associé à
`back-leg-left` au lieu de `back-leg-right`. Ce tracé est à x=242–247,5,
à droite de la silhouette dorsale (axe x=239), donc sur la cuisse droite du
patient. Le groupe original mélangeait les deux côtés.

Les identifiants techniques d’origine restent inchangés. Les libellés français
et la convention patient sont gérés dans l’application, dans `lib/regions.dart`.
Ne pas déduire le côté anatomique des suffixes anglais des identifiants.

Correction de compatibilité avec l’éditeur : l’attribut SVG `transform` est
écrit explicitement dans la balise, avec interpolation de sa seule valeur.
La matrice identité est utilisée hors activation. Cela évite le faux attribut
`Dart_string_template_placeholder` généré par l’analyse XML des chaînes Dart,
sans changer les coordonnées ni le comportement de sélection.
