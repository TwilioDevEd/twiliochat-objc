#import "ViewControllerFlowManager.h"

@implementation ViewControllerFlowManager
+ (void)showSessionBasedViewController {
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
