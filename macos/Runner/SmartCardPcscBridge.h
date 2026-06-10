#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SmartCardPcscBridge : NSObject

+ (NSDictionary *)getStatus;
+ (NSDictionary *)testApdu;
+ (NSDictionary *)readVitaleIdentity;

@end

NS_ASSUME_NONNULL_END
