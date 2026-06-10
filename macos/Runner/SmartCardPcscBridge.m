//
//  SmartCardPcscBridge.m
//  Runner
//
//  Created by Jean claude Brucher on 08/06/2026.
//


#import "SmartCardPcscBridge.h"
#import <PCSC/winscard.h>
#import <PCSC/wintypes.h>
#import "VitaleIdentityProvider.h"

@implementation SmartCardPcscBridge

+ (NSDictionary *)getStatus {
    SCARDCONTEXT context;
    LONG status = SCardEstablishContext(
        SCARD_SCOPE_SYSTEM,
        NULL,
        NULL,
        &context
    );

    if (status != SCARD_S_SUCCESS) {
        return @{
            @"readerDetected": @NO,
            @"cardDetected": @NO,
            @"error": [NSString stringWithFormat:@"SCardEstablishContext failed: %d", status]
        };
    }

    DWORD readersLength = 0;

    status = SCardListReaders(
        context,
        NULL,
        NULL,
        &readersLength
    );

    if (status != SCARD_S_SUCCESS || readersLength == 0) {
        SCardReleaseContext(context);

        return @{
            @"readerDetected": @NO,
            @"cardDetected": @NO,
            @"error": @"Aucun lecteur PC/SC détecté"
        };
    }

    char *readersBuffer = malloc(readersLength);

    if (readersBuffer == NULL) {
        SCardReleaseContext(context);

        return @{
            @"readerDetected": @NO,
            @"cardDetected": @NO,
            @"error": @"Allocation mémoire impossible"
        };
    }

    status = SCardListReaders(
        context,
        NULL,
        readersBuffer,
        &readersLength
    );

    if (status != SCARD_S_SUCCESS) {
        free(readersBuffer);
        SCardReleaseContext(context);

        return @{
            @"readerDetected": @NO,
            @"cardDetected": @NO,
            @"error": [NSString stringWithFormat:@"SCardListReaders failed: %d", status]
        };
    }

    NSString *readerName = [NSString stringWithUTF8String:readersBuffer];

    free(readersBuffer);

    if (readerName == nil || readerName.length == 0) {
        SCardReleaseContext(context);

        return @{
            @"readerDetected": @NO,
            @"cardDetected": @NO,
            @"error": @"Nom de lecteur vide"
        };
    }

    SCARDHANDLE card;
    DWORD activeProtocol = 0;

    status = SCardConnect(
        context,
        [readerName UTF8String],
        SCARD_SHARE_SHARED,
        SCARD_PROTOCOL_T0 | SCARD_PROTOCOL_T1,
        &card,
        &activeProtocol
    );

    if (status != SCARD_S_SUCCESS) {
        SCardReleaseContext(context);

        return @{
            @"readerDetected": @YES,
            @"cardDetected": @NO,
            @"readerName": readerName,
            @"error": [NSString stringWithFormat:@"Lecteur détecté, carte absente ou inaccessible: %d", status]
        };
    }

    char readerBuffer[256];
    DWORD readerBufferLength = sizeof(readerBuffer);

    DWORD state = 0;
    DWORD protocol = 0;

    BYTE atr[MAX_ATR_SIZE];
    DWORD atrLength = sizeof(atr);

    status = SCardStatus(
        card,
        readerBuffer,
        &readerBufferLength,
        &state,
        &protocol,
        atr,
        &atrLength
    );

    if (status != SCARD_S_SUCCESS) {
        SCardDisconnect(card, SCARD_LEAVE_CARD);
        SCardReleaseContext(context);

        return @{
            @"readerDetected": @YES,
            @"cardDetected": @YES,
            @"readerName": readerName,
            @"error": [NSString stringWithFormat:@"SCardStatus failed: %d", status]
        };
    }

    NSMutableString *atrHex = [NSMutableString string];

    for (DWORD i = 0; i < atrLength; i++) {
        [atrHex appendFormat:@"%02X", atr[i]];
    }

    SCardDisconnect(card, SCARD_LEAVE_CARD);
    SCardReleaseContext(context);

    return @{
        @"readerDetected": @YES,
        @"cardDetected": @YES,
        @"readerName": readerName,
        @"atr": atrHex,
        @"protocol": @(activeProtocol)
    };
}
+ (NSDictionary *)testApdu {
    SCARDCONTEXT context;
    LONG status = SCardEstablishContext(
        SCARD_SCOPE_SYSTEM,
        NULL,
        NULL,
        &context
    );

    if (status != SCARD_S_SUCCESS) {
        return @{
            @"success": @NO,
            @"error": [NSString stringWithFormat:@"SCardEstablishContext failed: %d (0x%08X)", status, status]
        };
    }

    DWORD readersLength = 0;
    status = SCardListReaders(context, NULL, NULL, &readersLength);

    if (status != SCARD_S_SUCCESS || readersLength == 0) {
        SCardReleaseContext(context);
        return @{
            @"success": @NO,
            @"error": @"Aucun lecteur PC/SC détecté"
        };
    }

    char *readersBuffer = malloc(readersLength);
    if (readersBuffer == NULL) {
        SCardReleaseContext(context);
        return @{
            @"success": @NO,
            @"error": @"Allocation mémoire impossible"
        };
    }

    status = SCardListReaders(context, NULL, readersBuffer, &readersLength);

    if (status != SCARD_S_SUCCESS) {
        free(readersBuffer);
        SCardReleaseContext(context);
        return @{
            @"success": @NO,
            @"error": [NSString stringWithFormat:@"SCardListReaders failed: %d (0x%08X)", status, status]
        };
    }

    NSString *readerName = [NSString stringWithUTF8String:readersBuffer];
    free(readersBuffer);

    if (readerName == nil || readerName.length == 0) {
        SCardReleaseContext(context);
        return @{
            @"success": @NO,
            @"error": @"Nom de lecteur vide"
        };
    }

    SCARDHANDLE card;
    DWORD activeProtocol = 0;

    status = SCardConnect(
        context,
        [readerName UTF8String],
        SCARD_SHARE_EXCLUSIVE,
        SCARD_PROTOCOL_T0,
        &card,
        &activeProtocol
    );

    if (status != SCARD_S_SUCCESS) {
        SCardReleaseContext(context);
        return @{
            @"success": @NO,
            @"readerName": readerName,
            @"error": [NSString stringWithFormat:@"Carte absente ou inaccessible: %d (0x%08X)", status, status]
        };
    }
    
    status = SCardReconnect(
        card,
        SCARD_SHARE_EXCLUSIVE,
        SCARD_PROTOCOL_T0,
        SCARD_RESET_CARD,
        &activeProtocol
    );

    if (status != SCARD_S_SUCCESS) {
        SCardDisconnect(card, SCARD_LEAVE_CARD);
        SCardReleaseContext(context);

        return @{
            @"success": @NO,
            @"readerName": readerName,
            @"protocol": @(activeProtocol),
            @"error": [NSString stringWithFormat:
                @"SCardReconnect failed: %d (0x%08X)",
                status,
                (unsigned int)status]
        };
    }

    status = SCardBeginTransaction(card);

    if (status != SCARD_S_SUCCESS) {
        SCardDisconnect(card, SCARD_LEAVE_CARD);
        SCardReleaseContext(context);

        return @{
            @"success": @NO,
            @"readerName": readerName,
            @"protocol": @(activeProtocol),
            @"error": [NSString stringWithFormat:
                @"SCardBeginTransaction failed: %d (0x%08X)",
                status,
                (unsigned int)status]
        };
    }

    const SCARD_IO_REQUEST *sendPci = SCARD_PCI_T0;

    BYTE command[] = {
        0xBC, 0xA4, 0x00, 0x00, 0x02, 0x3F, 0x00
    };
    
    BYTE response[258];
    DWORD responseLength = sizeof(response);


    SCARD_IO_REQUEST recvPci;
    recvPci.dwProtocol = activeProtocol;
    recvPci.cbPciLength = sizeof(SCARD_IO_REQUEST);

    status = SCardTransmit(
        card,
        sendPci,
        command,
        sizeof(command),
        &recvPci,
        response,
        &responseLength
    );

    NSMutableString *commandHex = [NSMutableString string];
    for (NSUInteger i = 0; i < sizeof(command); i++) {
        [commandHex appendFormat:@"%02X", command[i]];
    }

    NSMutableString *responseHex = [NSMutableString string];
    if (status == SCARD_S_SUCCESS) {
        for (DWORD i = 0; i < responseLength; i++) {
            [responseHex appendFormat:@"%02X", response[i]];
        }
    }

    SCardEndTransaction(card, SCARD_LEAVE_CARD);
    SCardDisconnect(card, SCARD_LEAVE_CARD);
    SCardReleaseContext(context);

    if (status != SCARD_S_SUCCESS) {
        return @{
            @"success": @NO,
            @"readerName": readerName,
            @"protocol": @(activeProtocol),
            @"command": commandHex,
            @"error": [NSString stringWithFormat:@"SCardTransmit failed: %d (0x%08X)", status, status]
        };
    }

    return @{
        @"success": @YES,
        @"readerName": readerName,
        @"protocol": @(activeProtocol),
        @"command": commandHex,
        @"response": responseHex,
        @"responseLength": @(responseLength)
    };
}

// TODO Carte Vitale réelle : remplacer ce stub par l'appel à l'API officielle Lecture Vitale.
// Données attendues : lastName, firstName, birthDate, sexCode.
// Le workflow Flutter est déjà validé avec le stub_test.

+ (NSDictionary *)readVitaleIdentity {
    return [VitaleIdentityProvider readIdentity];
}

// TODO suppression après migration vers VitaleIdentityProvider
+ (NSDictionary *)_readVitaleIdentityStub {
    return @{
        @"success": @YES,
        @"implemented": @NO,
        @"source": @"stub_test",
        @"identity": @{
            @"lastName": @"TEST",
            @"firstName": @"Carte Vitale",
            @"birthDate": @"1980-01-15",
            @"sexCode": @"U",
            @"source": @"stub_test"
        }
    };
}

// TODO suppression après migration vers VitaleIdentityProvider
+ (NSDictionary *)_readVitaleIdentityOfficialApi {
    return @{
        @"success": @NO,
        @"implemented": @NO,
        @"source": @"official_api",
        @"error": @"API Lecture Vitale non encore intégrée"
    };
}

@end
