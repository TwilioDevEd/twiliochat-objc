#import "MessagingManager.h"
#import "ChannelManager.h"
#import "SessionManager.h"
#import "TokenRequestHandler.h"

@interface MessagingManager ()
@property (strong, nonatomic) TwilioChatClient *client;
@property (nonatomic, getter=isConnected) BOOL connected;
@end

static NSString * const TWCLoginViewControllerName = @"LoginViewController";
static NSString * const TWCMainViewControllerName = @"RevealViewController";

static NSString * const TWCTokenKey = @"token";

@implementation MessagingManager
+ (instancetype)sharedManager {
  static MessagingManager *sharedMyManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedMyManager = [[self alloc] init];
  });
  return sharedMyManager;
}

- (instancetype)init {
  self.delegate = [ChannelManager sharedManager];
  return self;
}

# pragma mark Present view controllers

- (void)presentRootViewController {
  if (!self.isLoggedIn) {
    [self presentViewControllerByName:TWCLoginViewControllerName];
    return;
  }
  if (!self.isConnected) {
    [self connectClientWithCompletion:^(BOOL success, NSError *error) {
      if (success) {
          NSLog(@"Successfully connected chat client");
      }
    }];
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

- (BOOL)isLoggedIn {
  return [SessionManager isLoggedIn];
}

- (void)loginWithUsername:(NSString *)username
    completion:(StatusWithErrorHandler)completion {
  [SessionManager loginWithUsername:username];
  [self connectClientWithCompletion:^(BOOL success, NSError *error) {
    if (success) {
      [self presentViewControllerByName:TWCMainViewControllerName];
    }
    completion(success, error);
  }];
}

- (void)logout {
  [SessionManager logout];
  self.connected = NO;

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    [self.client shutdown];
    self.client = nil;
  });
}

# pragma mark Twilio Client

- (void)connectClientWithCompletion:(StatusWithErrorHandler)completion {
  if (self.client) {
    [self logout];
  }

  [self requestTokenWithCompletion:^(BOOL succeeded, NSString *token) {
    if (succeeded) {
      [self initializeClientWithToken:token];
      if (completion) completion(succeeded, nil);
    }
    else {
      NSError *error = [self errorWithDescription:@"Could not get access token" code:301];
      if (completion) completion(succeeded, error);
    }
  }];
}

- (void)initializeClientWithToken:(NSString *)token {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

  [TwilioChatClient chatClientWithToken:token
                               properties:nil
                                 delegate:self
                             completion:^(TCHResult * _Nonnull result, TwilioChatClient * _Nullable chatClient) {
                                 if (result.isSuccessful) {
                                     self.client = chatClient;
                                     self.connected = YES;

                                 }
                             }];
}

- (void)requestTokenWithCompletion:(StatusWithTokenHandler)completion {
  NSString *uuid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
  NSDictionary *parameters = @{@"device": uuid, @"identity": [SessionManager getUsername]};

  [TokenRequestHandler fetchTokenWithParams:parameters completion:^(NSDictionary *results, NSError *error) {
    NSString *token = [results objectForKey:TWCTokenKey];
    BOOL errorCondition = error || !token;

    if (completion) completion(!errorCondition, token);
  }];
}

- (void)loadGeneralChatRoomWithCompletion:(StatusWithErrorHandler)completion {
  [[ChannelManager sharedManager] joinGeneralChatRoomWithCompletion:^(BOOL succeeded) {
    if (succeeded)
    {
      if (completion) completion(succeeded, nil);
    }
    else {
      NSError *error = [self errorWithDescription:@"Could not join General channel" code:300];
      if (completion) completion(succeeded, error);
    }
  }];
}

- (NSError *)errorWithDescription:(NSString *)description code:(NSInteger)code {
  NSDictionary *userInfo = @{NSLocalizedDescriptionKey: description};
  NSError *error = [NSError errorWithDomain:@"app" code:code userInfo:userInfo];
  return error;
}

#pragma mark Internal helpers

- (NSString *)userIdentity {
  return [SessionManager getUsername];
}

- (void)refreshChatToken:(TwilioChatClient*)client {
    [self requestTokenWithCompletion:^(BOOL succeeded, NSString *token) {
      if (succeeded) {
          [client updateToken:token completion:^(TCHResult * _Nonnull result) {
              if (result.isSuccessful) {
                  
              }
          }];
      }
      else {
        NSLog(@"Error while trying to get new access token");
      }
    }];
}

#pragma mark TwilioChatClientDelegate

- (void)chatClient:(TwilioChatClient *)client channelAdded:(TCHChannel *)channel {
  [self.delegate chatClient:client channelAdded:channel];
}

- (void)chatClient:(TwilioChatClient *)client channelDeleted:(TCHChannel *)channel {
  [self.delegate chatClient:client channelDeleted:channel];
}

- (void)chatClient:(TwilioChatClient *)client synchronizationStatusUpdated:(TCHClientSynchronizationStatus)status {
  if (status == TCHClientSynchronizationStatusCompleted) {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [ChannelManager sharedManager].channelsList = client.channelsList;
    [[ChannelManager sharedManager] populateChannels];
    [self loadGeneralChatRoomWithCompletion:^(BOOL success, NSError *error) {
        if (success) {
            [self presentViewControllerByName:TWCMainViewControllerName];
        }
    }];
  }
  [self.delegate chatClient:client synchronizationStatusUpdated:status];
}

- (void)chatClientTokenWillExpire:(TwilioChatClient *)client {
    [self refreshChatToken:client];
}

- (void)chatClientTokenExpired:(TwilioChatClient *)client {
    [self refreshChatToken:client];
}

@end
