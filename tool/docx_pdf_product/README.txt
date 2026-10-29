Contrôle DOCX ciblé autorisé le 18/10/2026

verify_offline.sh reçoit un dossier de preuve neuf, un DOCX synthétique généré
par ABAK, une copie officielle signée de LibreOffice et les références CDA locales.
Il n’installe ni ne lance l’application utilisateur ; les données sont synthétiques.
Il compile un hôte signé pour le service XPC réel et emploie l’écran Documents.
La conversion et veraPDF sont réels ; seules les données/attestations sont fictives.
Trois cas seulement : conversion et revue ; modification et nouvelle validation ;
DOCX vide refusé. La réouverture vérifie la validation et la retenue conservées.
Ne pas élargir ni relancer cette recette sans nécessité liée à une modification
et sans respecter l’autorisation limitée donnée par l’utilisateur.

Dépendances : macOS 13+, LibreOffice officiel valide, Java/veraPDF déjà installés,
références archivées, SDK Flutter et identité de signature Apple locaux.
Le profil LibreOffice reste privé ; aucune CPS, connexion externe, donnée réelle
ou tentative de dépôt n’est utilisée. Les sockets Unix permis par le service sont
limités à son propre dossier privé ; OSL_SOCKET_PATH n’accède pas à une autre instance.

Les conversions produisent un PDF/A-1b vérifié. Elles ne signent pas le PDF et
ne remplacent pas la validation médicale ni la signature XAdES du lot CPS.
