//
//  VitaleIdentityProvider.m
//  Runner
//
//  Created by Jean claude Brucher on 09/06/2026.
//

#import "VitaleIdentityProvider.h"

@implementation VitaleIdentityProvider

+ (NSDictionary *)readIdentity {
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

@end
