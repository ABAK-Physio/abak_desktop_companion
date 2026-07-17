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

#pragma mark - Analyseur XML privé

@interface VitaleIdentityXmlParser : NSObject <NSXMLParserDelegate>

@property(nonatomic, strong) NSMutableString *currentText;

@property(nonatomic, copy, nullable) NSString *lastName;
@property(nonatomic, copy, nullable) NSString *firstName;
@property(nonatomic, copy, nullable) NSString *birthDateRaw;
@property(nonatomic, copy, nullable) NSString *sexRaw;
@property(nonatomic, copy, nullable) NSString *nirRaw;

@property(nonatomic, assign) BOOL insideIdentity;
@property(nonatomic, assign) BOOL parseSucceeded;

@end

@implementation VitaleIdentityXmlParser

- (instancetype)init {
    self = [super init];

    if (self) {
        _currentText = [NSMutableString string];
        _insideIdentity = NO;
        _parseSucceeded = NO;
    }

    return self;
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    self.parseSucceeded = NO;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    self.parseSucceeded = YES;
}

- (void)parser:(NSXMLParser *)parser
didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qualifiedName
    attributes:(NSDictionary<NSString *, NSString *> *)attributeDict {

    [self.currentText setString:@""];

    if ([elementName isEqualToString:@"ident"]) {
        self.insideIdentity = YES;
    }
}

- (void)parser:(NSXMLParser *)parser
foundCharacters:(NSString *)string {

    [self.currentText appendString:string];
}

- (void)parser:(NSXMLParser *)parser
  didEndElement:(NSString *)elementName
   namespaceURI:(NSString *)namespaceURI
  qualifiedName:(NSString *)qualifiedName {

    NSString *value = [
        self.currentText
        stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]
    ];

    if (value.length > 0) {
        /*
         * Les données d'état civil se trouvent dans le bloc <ident>.
         */
        if (self.insideIdentity) {
            if ([elementName isEqualToString:@"nomUsuel"]) {
                self.lastName = value;
            } else if ([elementName isEqualToString:@"prenomUsuel"]) {
                self.firstName = value;
            } else if ([elementName isEqualToString:@"dateNaissance"]) {
                self.birthDateRaw = value;
            } else if (
                [elementName isEqualToString:@"sexe"] ||
                [elementName isEqualToString:@"codeSexe"] ||
                [elementName isEqualToString:@"genre"]
            ) {
                self.sexRaw = value;
            }
        }

        /*
         * Le NIR se trouve normalement dans le bloc <amo>,
         * donc en dehors du bloc <ident>.
         */
        if ([elementName isEqualToString:@"nir"]) {
            self.nirRaw = value;
        }
    }

    if ([elementName isEqualToString:@"ident"]) {
        self.insideIdentity = NO;
    }

    [self.currentText setString:@""];
}

- (void)parser:(NSXMLParser *)parser
parseErrorOccurred:(NSError *)parseError {

    self.parseSucceeded = NO;

    NSLog(
        @"❌ Erreur d'analyse XML : %@",
        parseError.localizedDescription
    );
}

@end

#pragma mark - Fonctions privées

static NSString *VitaleFormatBirthDate(NSString *rawDate) {
    if (rawDate == nil || rawDate.length == 0) {
        return @"";
    }

    NSString *trimmedDate = [
        rawDate
        stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]
    ];

    /*
     * Format habituellement retourné par l'API :
     * JJMMYYYY
     *
     * Exemple :
     * 01081950 -> 1950-08-01
     */
    if (trimmedDate.length == 8) {
        NSString *day =
            [trimmedDate substringWithRange:NSMakeRange(0, 2)];

        NSString *month =
            [trimmedDate substringWithRange:NSMakeRange(2, 2)];

        NSString *year =
            [trimmedDate substringWithRange:NSMakeRange(4, 4)];

        return [NSString stringWithFormat:@"%@-%@-%@",
                                          year,
                                          month,
                                          day];
    }

    /*
     * En cas de format inattendu, on conserve la valeur reçue.
     */
    return trimmedDate;
}

static NSString *VitaleNormalizeSexCode(NSString *rawSex) {
    if (rawSex == nil || rawSex.length == 0) {
        return @"U";
    }

    NSString *normalized = [[
        rawSex
        stringByTrimmingCharactersInSet:
            [NSCharacterSet whitespaceAndNewlineCharacterSet]
    ] uppercaseString];

    if (
        [normalized isEqualToString:@"1"] ||
        [normalized isEqualToString:@"M"] ||
        [normalized isEqualToString:@"H"] ||
        [normalized isEqualToString:@"MASCULIN"] ||
        [normalized isEqualToString:@"HOMME"]
    ) {
        return @"M";
    }

    if (
        [normalized isEqualToString:@"2"] ||
        [normalized isEqualToString:@"F"] ||
        [normalized isEqualToString:@"FEMININ"] ||
        [normalized isEqualToString:@"FÉMININ"] ||
        [normalized isEqualToString:@"FEMME"]
    ) {
        return @"F";
    }

    return @"U";
}

static NSString *VitaleNormalizeNir(NSString *rawNir) {
    if (rawNir == nil || rawNir.length == 0) {
        return @"";
    }

    /*
     * Suppression des espaces et séparateurs éventuels.
     *
     * On conserve les caractères alphanumériques, car certaines
     * cartes de test peuvent contenir des lettres dans le NIR.
     */
    NSMutableString *normalized = [NSMutableString string];

    NSCharacterSet *allowedCharacters =
        [NSCharacterSet alphanumericCharacterSet];

    for (NSUInteger index = 0; index < rawNir.length; index++) {
        unichar character = [rawNir characterAtIndex:index];

        if ([allowedCharacters characterIsMember:character]) {
            [normalized appendFormat:@"%C", character];
        }
    }

    return [normalized uppercaseString];
}

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
     * 4. Copie du XML
     *
     * NSXMLParser lira directement les octets et respectera
     * l'encodage déclaré dans le document XML.
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
     * 7. Analyse du XML
     */

    VitaleIdentityXmlParser *identityParser =
        [[VitaleIdentityXmlParser alloc] init];

    NSXMLParser *xmlParser =
        [[NSXMLParser alloc] initWithData:xmlData];

    xmlParser.delegate = identityParser;

    BOOL parsingResult = [xmlParser parse];

    if (!parsingResult || !identityParser.parseSucceeded) {
        NSLog(@"❌ Impossible d'analyser le XML");
        NSLog(@"========================================");

        return @{
            @"success": @NO,
            @"implemented": @YES,
            @"source": @"api_lec",
            @"stage": @"xml_parsing",
            @"returnCode": @(retourLecture),
            @"errorCode": @(codeErreurLecture),
            @"cardState": @(etatCarte),
            @"mode": @(mode),
            @"xmlLength": @(longueurXml),
            @"finalizationReturnCode": @(retourFermeture),
            @"finalizationErrorCode": @(codeErreurFermeture),
            @"message": @"Le document XML reçu n'a pas pu être analysé."
        };
    }

    /*
     * 8. Normalisation des informations extraites
     */

    NSString *lastName = identityParser.lastName ?: @"";
    NSString *firstName = identityParser.firstName ?: @"";

    NSString *birthDate =
        VitaleFormatBirthDate(identityParser.birthDateRaw);

    NSString *sexCode =
        VitaleNormalizeSexCode(identityParser.sexRaw);

    NSString *nir =
        VitaleNormalizeNir(identityParser.nirRaw);

    /*
     * 9. Vérification des informations indispensables
     */

    if (
        lastName.length == 0 ||
        firstName.length == 0 ||
        birthDate.length == 0 ||
        nir.length == 0
    ) {
        NSLog(@"❌ Identité incomplète dans le XML");
        NSLog(
            @"   nom présent = %@",
            lastName.length > 0 ? @"oui" : @"non"
        );
        NSLog(
            @"   prénom présent = %@",
            firstName.length > 0 ? @"oui" : @"non"
        );
        NSLog(
            @"   date présente = %@",
            birthDate.length > 0 ? @"oui" : @"non"
        );
        NSLog(
            @"   NIR présent = %@",
            nir.length > 0 ? @"oui" : @"non"
        );
        NSLog(@"========================================");

        return @{
            @"success": @NO,
            @"implemented": @YES,
            @"source": @"api_lec",
            @"stage": @"identity_extraction",
            @"returnCode": @(retourLecture),
            @"errorCode": @(codeErreurLecture),
            @"cardState": @(etatCarte),
            @"mode": @(mode),
            @"xmlLength": @(longueurXml),
            @"finalizationReturnCode": @(retourFermeture),
            @"finalizationErrorCode": @(codeErreurFermeture),
            @"message": @"Le document XML ne contient pas une identité complète."
        };
    }

    /*
     * 10. Vérification de la fermeture
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
            @"message": @"L'identité a été lue, mais la fermeture de l'API a échoué."
        };
    }

    /*
     * 11. Succès
     *
     * Aucune donnée d'identité n'est écrite dans les journaux.
     * La valeur du NIR ne doit notamment jamais être journalisée.
     */

    NSLog(@"✅ XML analysé");
    NSLog(@"✅ Nom détecté");
    NSLog(@"✅ Prénom détecté");
    NSLog(@"✅ Date de naissance détectée");
    NSLog(@"✅ NIR détecté");
    NSLog(
        @"Sexe disponible dans le XML : %@",
        [sexCode isEqualToString:@"U"] ? @"non" : @"oui"
    );
    NSLog(@"✅ Lecture d'identité terminée");
    NSLog(@"========================================");

    /*
     * 12. Retour des données vers Flutter
     */

    return @{
        @"success": @YES,
        @"implemented": @YES,
        @"source": @"api_lec",
        @"stage": @"identity_extraction",
        @"returnCode": @(retourLecture),
        @"errorCode": @(codeErreurLecture),
        @"cardState": @(etatCarte),
        @"mode": @(mode),
        @"lastName": lastName,
        @"firstName": firstName,
        @"birthDate": birthDate,
        @"sexCode": sexCode,
        @"nir": nir,
        @"message": @"L'identité Carte Vitale a été lue avec succès."
    };
}

@end
