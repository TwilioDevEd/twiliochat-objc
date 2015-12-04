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
                  completion:(void(^)(BOOL succeeded, NSError *error))completion;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password
               completion:(void(^)(BOOL succeeded, NSError *error))completion;

- (void)logout;

- (void)presentLaunchScreen;
@end
