#import <Parse/Parse.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>
#import "IPMessagingManager.h"

@interface IPMessagingManager ()
@property (nonatomic, strong) TwilioIPMessagingClient *client;
@property (nonatomic, strong) NSData *lastToken;
@property (nonatomic, strong) NSDictionary *lastNotification;
@property (nonatomic) BOOL justLoggedIn;
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
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName: @"Main" bundle: [NSBundle mainBundle]];
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    if ([self hasIdentity]) {
        if (self.justLoggedIn) {
            window.rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"RevealViewController"];
        }
        else {
            [self initializeClient:^(BOOL success, NSError *error) {
                [self presentRootViewController];
            }];
        }
    }
    else {
        window.rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    }
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
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        self.justLoggedIn = YES;
        if (succeeded) {
            [self initializeClient:^(BOOL succeeded, NSError *error) {
                handler(succeeded, error);
            }];
        }
        else {
            handler(succeeded, error);
        }
        self.justLoggedIn = NO;
    }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
                  handler:(void(^)(BOOL succeeded, NSError *error))handler {
    [PFUser logInWithUsernameInBackground:username
                                 password:password
                                    block:^(PFUser *user, NSError *error) {
                                        self.justLoggedIn = YES;
                                        if (!error) {
                                            [self initializeClient:^(BOOL success, NSError *error) {
                                                handler(success, error);
                                            }];
                                        }
                                        else {
                                            handler(!error, error);
                                        }
                                        self.justLoggedIn = NO;
                                    }];
}

- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
                     handler:(void(^)(BOOL succeeded, NSError *error))handler {
    [self registerWithUsername:username password:password fullName:@"" email:@"" handler:handler];
}

- (void)initializeClient:(void(^)(BOOL succeeded, NSError *error))handler {
    if (self.client) {
        [self logout];
    }
    
    [PFCloud callFunctionInBackground:@"token"
                       withParameters:@{@"device": [[UIDevice currentDevice] identifierForVendor].UUIDString}
                                block:^(NSArray *results, NSError *error) {
                                    if (!error) {
                                        NSLog(@"%@",results);
                                        self.client = [TwilioIPMessagingClient ipMessagingClientWithToken:results[0][@"token"]
                                                                                                 delegate:nil];
                                    }
                                    handler(!error, error);
                                }];
}

- (void)logout {
    [PFUser logOut];
    [self.client shutdown];
    self.client = nil;
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
