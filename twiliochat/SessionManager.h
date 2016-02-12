#import <Foundation/Foundation.h>

@interface SessionManager : NSObject
+ (void)loginWithUsername:(NSString *)username;
+ (void)logout;
+ (BOOL)isLoggedIn;
+ (NSString*)getUsername;
@end
