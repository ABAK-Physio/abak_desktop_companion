# Banc PDF final isolé

Aucune intégration aux écrans ou au stockage métier. Aucun transport réseau, CPS,
INSi, certificat ou signature. Exécution obligatoire sous sandbox macOS sans
réseau (y compris loopback). Dépendances locales déjà installées uniquement.

`final_pdf_bench.dart` importe une copie adressée par empreinte SHA-256, produit
un aperçu PNG de toutes les pages via Poppler et conserve un journal atomique.
L'approbation explicite couvre les pages, le contenu clinique déclaré par le
relecteur, le patient synthétique, l'auteur, le contexte et la version source.
Les tests simulent ce relecteur : ils ne constituent pas une validation médicale.
L'absence de texte extractible ne permet pas de décider automatiquement qu'une
page est cliniquement vide. La revue doit le décider, ou refuser l'approbation.

La copie n'est pas une protection contre un administrateur malveillant : son
empreinte est contrôlée à chaque validation/traitement. Les octets capturés après
contrôle sont les seuls utilisés. Les aperçus sont également vérifiés.
Une tentative réservée bloque le renvoi même après interruption ou réouverture.
Les fichiers du banc ne doivent pas être restaurés séparément pour reprendre une
tentative ; la restauration globale de production reste hors périmètre.

L'enveloppe JSON obtenue est fictive et non conforme DMP par construction ; elle
sert à contrôler l'identité exacte des octets. Aucun contrôle PDF/A ou CDA n'est
prétendu. Limites : 20 Mio, 40 pages, revue humaine simulée et identifiants SIM-*.
L'API n'est pas une autorisation de traitement métier et ne remplace pas TD0.2.

Lancer `verify_offline.sh` avec le répertoire des fixtures préparées, un nouveau
répertoire de résultats, le binaire Dart et le répertoire Poppler local. Les cas
C22/C23 nécessitent abak_bilan.pdf, abak_rapport.pdf et generateurs_ok.json.
`generate_docx.dart` appelle les générateurs existants d'ABAK sur des modèles
synthétiques injectés. Il s'exécute avec flutter_tester --disable-vm-service après
compilation locale frontend_server ; PDF_BENCH_OUTPUT désigne exclusivement le
répertoire de fixtures. Conversion DOCX → PDF par LibreOffice local.
Les correspondants masqués, tableaux, notes injectées et médias sont contrôlés ;
la sélection des données depuis une base patient réelle n'est pas exécutée.

Sortie : Resultats_26.json et journaux séparés par scénario/variante. Aucune
application compilée pour installation ou lancée en mode utilisateur.

## Écran de démonstration

Paramètres > Configuration > DMP — PDF final simulé.
`PdfDemoScreen` n’offre aucun sélecteur de fichier utilisateur. Il charge six PDF
synthétiques embarqués et leurs aperçus pré-calculés par le banc natif. Le cache
est indexé par l’empreinte exacte du PDF ; chaque PNG est contrôlé. Un autre PDF
est refusé. L’écran installé ne lance pas Poppler, ne télécharge rien et ne
requiert aucun outil externe ; `BundledPdfInspector` remplace seulement la
production des aperçus pour ces fixtures connues. La copie figée, l’approbation,
les réservations et le journal restent ceux de `FinalPdfBench`.

Stockage : racine dédiée dmp-pdf-demo-v1/exercises, pointeur atomique vers
l’exercice actif. Une reprise incohérente ne recrée pas silencieusement le
journal ; le bouton Nouvel exercice conserve les exercices précédents.
La revue des pages n’est pas rétablie comme une nouvelle déclaration lors de la
réouverture ; l’approbation déjà enregistrée reste liée à la même version.

`verify_screen.dart` rend le véritable widget avec flutter_tester sans VM service
et sans réseau (y compris loopback). Il actionne les callbacks des contrôles,
remonte l’écran depuis le stockage et capture des images. Ce test automatisé
ne remplace pas le contrôle manuel du kiné ni une validation médicale réelle.
Les variables PDF_SCREEN_OUTPUT et PDF_SCREEN_FIXTURES désignent uniquement un
répertoire neuf de preuves et assets/dmp_local/pdf_demo. Le processus nécessite
--run-forever jusqu’à son exit explicite ; un simple code retour 0 sans le fichier
Resultats_ecran.json ne prouve pas que les contrôles ont été achevés.
