#import <Parse/Parse.h>
#import "IPMessagingManager.h"
#import "ChannelManager.h"

@interface IPMessagingManager ()
@property (nonatomic, strong) TwilioIPMessagingClient *client;
@property (nonatomic, strong) NSData *lastToken;
@property (nonatomic, strong) NSDictionary *lastNotification;
@property (nonatomic) BOOL connecting;
@end

@implementation IPMessagingManager
+ (instancetype)sharedManager {
    static IPMessagingManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (void)presentRootViewController {
    if ([self hasIdentity]) {
        if (self.connecting) {
            [self presentViewController:@"RevealViewController"];
        }
        else {
            [self connectClient:^(BOOL success, NSError *error) {
                if (success) {
                    [self presentViewController:@"RevealViewController"];
                }
                else {
                    [self presentViewController:@"LoginViewController"];
                }
            }];
        }
    }
    else {
        [self presentViewController:@"LoginViewController"];
    }
}

- (void)presentViewController:(NSString *)viewController {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName: @"Main" bundle: [NSBundle mainBundle]];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    window.rootViewController = [storyBoard instantiateViewControllerWithIdentifier:viewController];
}

- (void)presentLaunchScreen {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName: @"LaunchScreen" bundle: [NSBundle mainBundle]];
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    window.rootViewController = [storyBoard instantiateInitialViewController];
}

- (BOOL)hasIdentity {
    return [PFUser currentUser] && [[PFUser currentUser] isAuthenticated];
}

- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
                    fullName:(NSString *)fullName
                       email:(NSString *)email
                     handler:(void(^)(BOOL succeeded, NSError *error))handler {
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    user.email = email;
    user[@"fullName"] = fullName;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self connectClient:^(BOOL succeeded, NSError *error) {
                if (handler) handler(succeeded, error);
            }];
        }
        else {
            if (handler) handler(succeeded, error);
        }
    }];
}

- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
                     handler:(void(^)(BOOL succeeded, NSError *error))handler {
    [self registerWithUsername:username password:password fullName:@"" email:@"" handler:handler];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
                  handler:(void(^)(BOOL succeeded, NSError *error))handler {
    [PFUser logInWithUsernameInBackground:username
                                 password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (!error) {
                                            [self connectClient:^(BOOL succeeded, NSError *error) {
                                                if (handler) handler(succeeded, error);
                                            }];
                                        }
                                        else {
                                            if (handler) handler(!error, error);
                                        }
                                    }];
}

- (void)connectClient:(void(^)(BOOL succeeded, NSError *error))handler {
    if (self.client) {
        [self logout];
    }
    
    [PFCloud callFunctionInBackground:@"token"
                       withParameters:@{@"device": [[UIDevice currentDevice] identifierForVendor].UUIDString}
                                block:^(NSDictionary *results, NSError *error) {
                                    NSString *token = [results objectForKey:@"token"];
                                    BOOL errorCondition = error || !token;
                                    
                                    if (!errorCondition) {
                                        NSLog(@"%@",results);
                                        self.client = [TwilioIPMessagingClient ipMessagingClientWithToken:token
                                                                                                 delegate:nil];
                                        [self loadGeneralChatRoom:handler];
                                    }
                                    else {
                                        if (handler) handler(!error, error);
                                    }
                                }];
}

- (void)loadGeneralChatRoom:(void(^)(BOOL succeeded, NSError *error))handler {
    [[ChannelManager sharedManager] loadGeneralChatRoomWithBlock:^(TMResultEnum result, TMChannel *channel) {
        self.connecting = YES;
        if (result == TMResultSuccess)
        {
            if (handler) handler(YES, nil);
        }
        else {
            if (handler) handler(NO, [NSError errorWithDomain:@"channel" code:1000 userInfo:nil]);
        }
        self.connecting = NO;
    }];
}

- (void)logout {
    [PFUser logOut];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.client shutdown];
        self.client = nil;
    });
}

- (void)updatePushToken:(NSData *)token {
    self.lastToken = token;
    [self updateIpMessagingClient];
}

- (void)receivedNotification:(NSDictionary *)notification {
    self.lastNotification = notification;
    [self updateIpMessagingClient];
}


#pragma mark Push functionality

- (void)updateIpMessagingClient {
    if (self.lastToken) {
        [self.client registerWithToken:self.lastToken];
        self.lastToken = nil;
    }
    
    if (self.lastNotification) {
        [self.client handleNotification:self.lastNotification];
        self.lastNotification = nil;
    }
}

#pragma mark Internal helpers

- (NSString *)userIdentity {
    return [[PFUser currentUser] username];
}

@end
