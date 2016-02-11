#import <Foundation/Foundation.h>

@interface TokenRequestHandler : NSObject
+ (void)fetchTokenWithParams:(NSDictionary *)params
                  completion:(void(^)(NSDictionary *results, NSError *error))completion;
@end
