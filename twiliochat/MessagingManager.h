#import <UIKit/UIKit.h>
#import <TwilioChatClient/TwilioChatClient.h>
#import "ChannelManager.h"

typedef void (^StatusWithErrorHandler) (BOOL succeeded, NSError *);
typedef void (^StatusWithTokenHandler) (BOOL succeeded, NSString *);

@interface MessagingManager : NSObject <TwilioChatClientDelegate>
@property (strong, nonatomic, readonly) TwilioChatClient *client;
@property (nonatomic, readonly) BOOL isLoggedIn;
@property (weak, nonatomic) ChannelManager<TwilioChatClientDelegate> *delegate;

+ (instancetype)sharedManager;
- (void)presentRootViewController;
- (NSString *)userIdentity;
- (void)loginWithUsername:(NSString *)username
               completion:(void(^)(BOOL succeeded, NSError *error))completion;
- (void)logout;
- (void)presentLaunchScreen;
@end
