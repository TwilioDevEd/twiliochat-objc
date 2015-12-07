#import <Parse/Parse.h>
#import "IPMessagingManager.h"
#import "ChannelManager.h"

@interface IPMessagingManager ()
@property (nonatomic, strong) TwilioIPMessagingClient *client;
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
    if (!self.hasIdentity) {
        [self presentViewControllerByName:@"LoginViewController"];
        return;
    }
    if (!self.connected) {
        [self connectClientWithCompletion:^(BOOL success, NSError *error) {
            NSString *viewController = success ? @"RevealViewController" : @"LoginViewController";
            [self presentViewControllerByName:viewController];
        }];
        return;
    }
    [self presentViewControllerByName:@"RevealViewController"];
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
                  completion:(nonnull StatusWithErrorHandler)completion {
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    user.email = email;
    user[@"fullName"] = fullName;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self connectClientWithCompletion:completion];
            return;
        }
        completion(succeeded, error);
    }];
}

- (void)loginWithUsername:(NSString *)username password:(NSString *)password
               completion:(nonnull StatusWithErrorHandler)completion {
    [PFUser logInWithUsernameInBackground:username
                                 password:password
                                    block:^(PFUser *user, NSError *error) {
                                        if (!error) {
                                            [self connectClientWithCompletion:completion];
                                            return;
                                        }
                                        completion(!error, error);
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

- (void)connectClientWithCompletion:(nonnull StatusWithErrorHandler)completion {
    if (self.client) {
        [self logout];
    }
    
    [self requestTokenWithCompletion:^(BOOL succeeded, NSString *token) {
        if (succeeded) {
            [self initializeClientWithToken: token];
            [self loadGeneralChatRoomWithCompletion:completion];
        }
        else {
            NSError *error = [self errorWithDescription:@"Could not get access token" code:301];
            completion(succeeded, error);
        }
    }];
}

- (void)initializeClientWithToken:(NSString *)token {
    TwilioAccessManager *accessManager = [TwilioAccessManager accessManagerWithToken:token delegate: self];
    self.client = [TwilioIPMessagingClient ipMessagingClientWithAccessManager:accessManager delegate:nil];
}

- (void)loadGeneralChatRoomWithCompletion:(nonnull StatusWithErrorHandler)completion {
    [[ChannelManager sharedManager] joinGeneralChatRoomWithCompletion:^(BOOL succeeded) {
        if (succeeded)
        {
            self.connected = YES;
            completion(succeeded, nil);
        }
        else {
            NSError *error = [self errorWithDescription:@"Could not join General channel" code:300];
            completion(succeeded, error);
        }
    }];
}

- (void)requestTokenWithCompletion:(nonnull StatusWithTokenHandler)completion {
    NSString *uuid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    NSDictionary *parameters = @{@"device": uuid};
    
    [PFCloud callFunctionInBackground:@"token"
                       withParameters:parameters
                                block:^(NSDictionary *results, NSError *error) {
                                    NSString *token = [results objectForKey:@"token"];
                                    BOOL errorCondition = error || !token;
                                    
                                    completion(!errorCondition, token);
                                }];
    
}

- (NSError *)errorWithDescription:(NSString *)description code:(NSInteger)code {
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description};
    NSError *error = [NSError errorWithDomain:@"app"
                                         code:code
                                     userInfo:userInfo];
    return error;
}

# pragma mark TwilioAccessManagerDelegate

- (void)accessManagerTokenExpired:(TwilioAccessManager *)accessManager {
    [self requestTokenWithCompletion:^(BOOL succeeded, NSString *token) {
        if (succeeded) {
            [accessManager updateToken:token];
        }
        else {
            NSLog(@"Error while trying to get new access token");
        }
    }];
}

- (void)accessManager:(TwilioAccessManager *)accessManager error:(NSError *)error {
    NSLog(@"Access manager error: %@", [error localizedDescription]);
}

#pragma mark Internal helpers

- (NSString *)userIdentity {
    return [[PFUser currentUser] username];
}

@end
