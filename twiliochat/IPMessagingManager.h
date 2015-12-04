#import <Foundation/Foundation.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

@interface IPMessagingManager : NSObject <TwilioAccessManagerDelegate>
@property (nonatomic, strong, readonly) TwilioIPMessagingClient *client;
@property (nonatomic, readonly) BOOL hasIdentity;

+ (instancetype)sharedManager;
- (void)presentRootViewController;
- (NSString *)userIdentity;

- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
                    fullName:(NSString *)fullName
                       email:(NSString *)email
                     handler:(void(^)(BOOL succeeded, NSError *error))handler;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password
                  handler:(void(^)(BOOL succeeded, NSError *error))handler;

- (void)logout;

- (void)presentLaunchScreen;
@end
