//
//  VitaleIdentityProvider.m
//  Runner
//
//  Created by Jean Claude Brucher on 09/06/2026.
//

#import "VitaleIdentityProvider.h"

#pragma mark - API de Lecture Vitale

extern unsigned short Hn_Init(
        unsigned char *pcChemin,
        unsigned short *pusMode,
        unsigned short *pusCodeErreur
);

extern unsigned short Hn_LectureVitaleDonneesIdentification(
        short sTempsAttente,
        char *pcDataOut,
        unsigned int *puiLgDataOut,
        short *psEtatCarte,
        unsigned short *pusCodeErreur
);

extern unsigned short Hn_Finir(
        unsigned short *pusCodeErreur
);

#pragma mark - Constantes

static const unsigned int kVitaleXmlBufferSize = 65536;
static const short kVitaleWaitingTimeSeconds = 30;

#pragma mark - Implémentation

@implementation VitaleIdentityProvider

+ (NSDictionary *)readIdentity {
    unsigned short mode = 0;

    unsigned short codeErreurInitialisation = 0;
    unsigned short codeErreurLecture = 0;
    unsigned short codeErreurFermeture = 0;

    short etatCarte = 0;

    const char *configurationPath =
            "/Library/Application Support/santesocial/apilec/";

    NSLog(@"========================================");
    NSLog(@"Début lecture identité Carte Vitale");
    NSLog(@"Configuration : %s", configurationPath);

    /*
     * 1. Initialisation de l'API
     */

    NSLog(@"➡️ Appel Hn_Init");

    unsigned short retourInitialisation = Hn_Init(
            (unsigned char *)configurationPath,
            &mode,
            &codeErreurInitialisation
    );

    NSLog(@"⬅️ Retour Hn_Init");
    NSLog(@"   retour = %hu", retourInitialisation);
    NSLog(@"   mode   = %hu", mode);
    NSLog(@"   erreur = %hu", codeErreurInitialisation);

    if (retourInitialisation != 0) {
        NSLog(@"❌ Échec de l'initialisation");
        NSLog(@"========================================");

        return @{
                @"success": @NO,
                @"implemented": @YES,
                @"source": @"api_lec",
                @"stage": @"initialization",
                @"returnCode": @(retourInitialisation),
                @"errorCode": @(codeErreurInitialisation),
                @"mode": @(mode),
                @"message": @"Échec de l'initialisation de l'API de Lecture."
        };
    }

    /*
     * 2. Allocation du tampon XML
     */

    char *xmlBuffer = calloc(
            kVitaleXmlBufferSize,
            sizeof(char)
    );

    if (xmlBuffer == NULL) {
        NSLog(@"❌ Impossible d'allouer le tampon XML");
        NSLog(@"➡️ Appel Hn_Finir après échec d'allocation");

        unsigned short retourFermeture = Hn_Finir(
                &codeErreurFermeture
        );

        NSLog(@"⬅️ Retour Hn_Finir");
        NSLog(@"   retour = %hu", retourFermeture);
        NSLog(@"   erreur = %hu", codeErreurFermeture);
        NSLog(@"========================================");

        return @{
                @"success": @NO,
                @"implemented": @YES,
                @"source": @"api_lec",
                @"stage": @"buffer_allocation",
                @"mode": @(mode),
                @"finalizationReturnCode": @(retourFermeture),
                @"finalizationErrorCode": @(codeErreurFermeture),
                @"message": @"Impossible d'allouer la mémoire nécessaire à la lecture."
        };
    }

    unsigned int longueurXml = kVitaleXmlBufferSize;

    /*
     * 3. Lecture des données d'identification
     */

    NSLog(@"➡️ Appel Hn_LectureVitaleDonneesIdentification");
    NSLog(
            @"   attente maximale = %hd seconde(s)",
            kVitaleWaitingTimeSeconds
    );
    NSLog(@"   taille tampon = %u octets", longueurXml);

    unsigned short retourLecture =
            Hn_LectureVitaleDonneesIdentification(
                    kVitaleWaitingTimeSeconds,
                    xmlBuffer,
                    &longueurXml,
                    &etatCarte,
                    &codeErreurLecture
            );

    NSLog(@"⬅️ Retour Hn_LectureVitaleDonneesIdentification");
    NSLog(@"   retour       = %hu", retourLecture);
    NSLog(@"   erreur       = %hu", codeErreurLecture);
    NSLog(@"   état carte   = %hd", etatCarte);
    NSLog(@"   longueur XML = %u", longueurXml);

    /*
     * 4. Copie des octets XML avant libération du tampon
     */

    NSData *xmlData = nil;

    if (retourLecture == 0 && longueurXml > 0) {
        NSUInteger longueurValide = MIN(
                (NSUInteger)longueurXml,
                (NSUInteger)kVitaleXmlBufferSize
        );

        xmlData = [NSData dataWithBytes:xmlBuffer
                                 length:longueurValide];
    }

    free(xmlBuffer);
    xmlBuffer = NULL;

    /*
     * 5. Fermeture systématique de l'API
     */

    NSLog(@"➡️ Appel Hn_Finir");

    unsigned short retourFermeture = Hn_Finir(
            &codeErreurFermeture
    );

    NSLog(@"⬅️ Retour Hn_Finir");
    NSLog(@"   retour = %hu", retourFermeture);
    NSLog(@"   erreur = %hu", codeErreurFermeture);

    /*
     * 6. Vérification du résultat de lecture
     */

    if (retourLecture != 0) {
        NSLog(@"❌ Échec de la lecture de la Carte Vitale");
        NSLog(@"========================================");

        return @{
                @"success": @NO,
                @"implemented": @YES,
                @"source": @"api_lec",
                @"stage": @"identity_reading",
                @"returnCode": @(retourLecture),
                @"errorCode": @(codeErreurLecture),
                @"cardState": @(etatCarte),
                @"mode": @(mode),
                @"xmlLength": @(longueurXml),
                @"finalizationReturnCode": @(retourFermeture),
                @"finalizationErrorCode": @(codeErreurFermeture),
                @"message": @"La lecture des données d'identification a échoué."
        };
    }

    if (xmlData == nil || xmlData.length == 0) {
        NSLog(@"❌ Aucun XML reçu");
        NSLog(@"========================================");

        return @{
                @"success": @NO,
                @"implemented": @YES,
                @"source": @"api_lec",
                @"stage": @"xml_data",
                @"returnCode": @(retourLecture),
                @"errorCode": @(codeErreurLecture),
                @"cardState": @(etatCarte),
                @"mode": @(mode),
                @"xmlLength": @(longueurXml),
                @"finalizationReturnCode": @(retourFermeture),
                @"finalizationErrorCode": @(codeErreurFermeture),
                @"message": @"La lecture a réussi, mais aucun document XML n'a été reçu."
        };
    }

    /*
     * 7. Conversion du XML en chaîne
     *
     * Le XML est transmis brut à Flutter. Son analyse est réalisée par
     * VitaleXmlParser.parseAll(), commun à Windows et macOS.
     */

    NSString *xmlString = [[NSString alloc]
            initWithData:xmlData
                encoding:NSISOLatin1StringEncoding
    ];

    if (xmlString == nil || xmlString.length == 0) {
        NSLog(@"❌ Impossible de convertir le XML");
        NSLog(@"========================================");

        return @{
                @"success": @NO,
                @"implemented": @YES,
                @"source": @"api_lec",
                @"stage": @"xml_conversion",
                @"returnCode": @(retourLecture),
                @"errorCode": @(codeErreurLecture),
                @"cardState": @(etatCarte),
                @"mode": @(mode),
                @"xmlLength": @(longueurXml),
                @"finalizationReturnCode": @(retourFermeture),
                @"finalizationErrorCode": @(codeErreurFermeture),
                @"message": @"Le document XML reçu n'a pas pu être converti."
        };
    }

    /*
     * 8. Vérification de la fermeture
     */

    if (retourFermeture != 0) {
        NSLog(@"❌ La lecture a réussi, mais la fermeture a échoué");
        NSLog(@"========================================");

        return @{
                @"success": @NO,
                @"implemented": @YES,
                @"source": @"api_lec",
                @"stage": @"finalization",
                @"returnCode": @(retourFermeture),
                @"errorCode": @(codeErreurFermeture),
                @"cardState": @(etatCarte),
                @"mode": @(mode),
                @"message": @"Les données ont été lues, mais la fermeture de l'API a échoué."
        };
    }

    /*
     * 9. Succès
     */

    NSLog(@"✅ XML Carte Vitale reçu");
    NSLog(@"   longueur XML = %lu", (unsigned long)xmlData.length);
    NSLog(@"✅ Lecture Carte Vitale terminée");
    NSLog(@"========================================");

    /*
     * 10. Retour du XML brut vers Flutter
     */

    return @{
            @"success": @YES,
            @"implemented": @YES,
            @"source": @"api_lec",
            @"stage": @"identity_reading",
            @"returnCode": @(retourLecture),
            @"errorCode": @(codeErreurLecture),
            @"cardState": @(etatCarte),
            @"mode": @(mode),
            @"xmlLength": @(longueurXml),
            @"finalizationReturnCode": @(retourFermeture),
            @"finalizationErrorCode": @(codeErreurFermeture),
            @"xml": xmlString,
            @"message": @"Les données Carte Vitale ont été lues avec succès."
    };
}

@end
