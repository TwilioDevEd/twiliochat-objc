#import <UIKit/UIKit.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

typedef void (^StatusWithErrorHandler) (BOOL succeeded, NSError *);
typedef void (^StatusWithTokenHandler) (BOOL succeeded, NSString *);

@interface IPMessagingManager : NSObject <TwilioAccessManagerDelegate>
@property (strong, nonatomic, readonly) TwilioIPMessagingClient *client;
@property (nonatomic, readonly) BOOL isLoggedIn;

+ (instancetype)sharedManager;
- (void)presentRootViewController;
- (NSString *)userIdentity;
- (void)loginWithUsername:(NSString *)username
               completion:(void(^)(BOOL succeeded, NSError *error))completion;
- (void)logout;
- (void)presentLaunchScreen;
@end
