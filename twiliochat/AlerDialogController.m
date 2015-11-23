#import "AlerDialogController.h"

@implementation AlerDialogController
+ (void)showAlertWithMessage:(NSString *)message title:(NSString *)title presenter:(UIViewController *)presenter {
    [[[AlerDialogController alloc] init] showAlertWithMessage:message title:title presenter:presenter];
}

- (void)showAlertWithMessage:(NSString *)message title:(NSString *)title presenter:(UIViewController *)presenter {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    
    [alert addAction:defaultAction];
    [presenter presentViewController:alert animated:YES completion:nil];
}

@end
