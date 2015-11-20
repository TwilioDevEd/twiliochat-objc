#import <Parse/Parse.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>
#import "IPMessagingManager.h"

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
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName: @"Main" bundle: [NSBundle mainBundle]];
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    if ([self hasIdentity]) {
        if (self.connecting) {
            window.rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"RevealViewController"];
        }
        else {
            [self connectClient:^(BOOL success, NSError *error) {
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
                                block:^(NSArray *results, NSError *error) {
                                    self.connecting = YES;
                                    
                                    NSDictionary *data = results[0];
                                    NSString *token = [data objectForKey:@"token"];
                                    BOOL errorCondition = error || !data || !token;
                                    
                                    if (!errorCondition) {
                                        NSLog(@"%@",results);
                                        self.client = [TwilioIPMessagingClient ipMessagingClientWithToken:token
                                                                                                 delegate:nil];
                                    }
                                    if (handler) handler(!error, error);
                                    self.connecting = YES;
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
