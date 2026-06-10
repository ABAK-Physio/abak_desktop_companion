# ABAK Desktop Companion — Carte Vitale

## Objectif limité

Lire uniquement les informations d’identité utiles au dossier patient :

- nom
- prénom
- date de naissance
- sexe

L’intégration complète SESAM-Vitale n’est pas l’objectif.

## Matériel validé

- Lecteur : ACS ACR39U-U1
- macOS détecte le lecteur
- Carte Vitale détectée
- ATR lu :

```text
3F6525002209699000

Architecture validée
Flutter Desktop
→ MethodChannel abak.smart_card
→ AppDelegate.swift
→ SmartCardPcscBridge.m
→ PC/SC macOS
→ ACS ACR39U
→ Carte Vitale

Points techniques validés
SCardEstablishContext OK
SCardListReaders OK
SCardConnect OK
SCardStatus OK
SCardTransmit OK après correction

Configuration nécessaire pour SCardTransmit :

SCARD_PROTOCOL_T0
SCARD_PCI_T0
recvPci obligatoire
APDU testées
00A40000023F00 → 6E00
BCA40000023F00 → 6D00

Conclusion : le dialogue carte fonctionne, mais les APDU ISO classiques ne permettent pas directement la lecture identité.

Workflow Flutter validé
Bouton Carte Vitale
→ VitaleIdentityScreen
→ readVitaleIdentity()
→ identité stub
→ formulaire patient prérempli
→ validation kiné
→ création patient
→ rattachement dossier mobile
Architecture actuelle
+ (NSDictionary *)readVitaleIdentity {
    return [self _readVitaleIdentityStub];
}

La future intégration réelle devra remplacer l’appel par :

+ (NSDictionary *)readVitaleIdentity {
    return [self _readVitaleIdentityOfficialApi];
}
Décision

La lecture réelle doit passer par l’API officielle Lecture Vitale, pas par exploration APDU empirique.

À faire
Obtenir le package API Lecture Vitale officielle
Étudier l’interface C fournie
Implémenter _readVitaleIdentityOfficialApi
Conserver inchangé le workflow Flutter déjà validé
