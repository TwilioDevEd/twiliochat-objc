#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface TokenRequestHandler : NSObject
+ (void)fetchTokenWithParams:(NSDictionary *)params;
@end
