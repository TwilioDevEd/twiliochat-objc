#import <Parse/Parse.h>
#import "IPMessagingManager.h"

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
    PFUser *currentUser = [PFUser currentUser];
    
    UIWindow *window = [[UIApplication sharedApplication].delegate window];
    if (currentUser) {
        window.rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"RevealViewController"];
    }
    else {
        window.rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    }
}
@end
