#import <Parse/Parse.h>
#import "IPMessagingManager.h"
#import "ChannelManager.h"

@interface IPMessagingManager ()
@property (nonatomic, strong) TwilioIPMessagingClient *client;
@property (nonatomic, strong) NSData *lastToken;
@property (nonatomic, strong) NSDictionary *lastNotification;
@property (nonatomic) BOOL connected;
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

# pragma mark Present view controllers

- (void)presentRootViewController {
    if ([self hasIdentity]) {
        if (self.connected) {
            [self presentViewControllerByName:@"RevealViewController"];
        }
        else {
            [self connectClient:^(BOOL success, NSError *error) {
                if (success) {
                    [self presentViewControllerByName:@"RevealViewController"];
                }
                else {
                    [self presentViewControllerByName:@"LoginViewController"];
                }
            }];
        }
    }
    else {
        [self presentViewControllerByName:@"LoginViewController"];
    }
}

- (void)presentViewControllerByName:(NSString *)viewController {
    [self presentViewController:[[self storyboardWithName:@"Main"] instantiateViewControllerWithIdentifier:viewController]];
}

- (void)presentLaunchScreen {
    [self presentViewController:[[self storyboardWithName:@"LaunchScreen"] instantiateInitialViewController]];
}

- (void)presentViewController:(UIViewController *)viewController {
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    window.rootViewController = viewController;
}

- (UIStoryboard *)storyboardWithName:(NSString *)name {
    return [UIStoryboard storyboardWithName: name bundle: [NSBundle mainBundle]];
}

# pragma mark User and session management

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
            [self connectClient:handler];
        }
        else {
            if (handler) handler(succeeded, error);
        }
    }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
                  handler:(void(^)(BOOL succeeded, NSError *error))handler {
    [PFUser logInWithUsernameInBackground:username
                                 password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (!error) {
                                            [self connectClient:handler];
                                        }
                                        else {
                                            if (handler) handler(!error, error);
                                        }
                                    }];
}

- (void)logout {
    [PFUser logOut];
    self.connected = NO;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.client shutdown];
        self.client = nil;
    });
}

# pragma mark Twilio Client

- (void)connectClient:(void(^)(BOOL succeeded, NSError *error))handler {
    if (self.client) {
        [self logout];
    }
    
    NSString *uuid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    NSDictionary *parameters = @{@"device": uuid};
    
    [PFCloud callFunctionInBackground:@"token"
                       withParameters:parameters
                                block:^(NSDictionary *results, NSError *error) {
                                    NSString *token = [results objectForKey:@"token"];
                                    BOOL errorCondition = error || !token;
                                    
                                    if (!errorCondition) {
                                        [self initializeClientWithToken: token];
                                        [self loadGeneralChatRoom:handler];
                                    }
                                    else {
                                        if (handler) handler(!error, error);
                                    }
                                }];
}

- (void) initializeClientWithToken:(NSString *)token {
    self.client = [TwilioIPMessagingClient ipMessagingClientWithToken:token
                                                             delegate:nil];
}

- (void)loadGeneralChatRoom:(void(^)(BOOL succeeded, NSError *error))handler {
    [[ChannelManager sharedManager] joinGeneralChatRoomWithBlock:^(BOOL succeeded) {
        if (succeeded)
        {
            self.connected = YES;
            if (handler) handler(succeeded, nil);
        }
        else if (handler) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"Could not join General channel"};
            NSError *error = [NSError errorWithDomain:@"app"
                                                 code:300
                                             userInfo:userInfo];
            if (handler) handler(succeeded, error);
        }
    }];
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
