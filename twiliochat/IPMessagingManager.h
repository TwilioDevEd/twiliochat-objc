#import <Foundation/Foundation.h>

@interface IPMessagingManager : NSObject
+ (instancetype)sharedManager;
- (void)presentRootViewController;
- (NSString *)userIdentity;
- (BOOL)hasIdentity;

- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
                    fullName:(NSString *)fullName
                       email:(NSString *)email
                     handler:(void(^)(BOOL succeeded, NSError *error))handler;
- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
                     handler:(void(^)(BOOL succeeded, NSError *error))handler;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password
                  handler:(void(^)(BOOL succeeded, NSError *error))handler;

- (void)logout;

- (void)updatePushToken:(NSData *)token;
- (void)receivedNotification:(NSDictionary *)notification;
@end
