#import "AlertDialogController.h"

@implementation AlertDialogController
+ (void)showAlertWithMessage:(NSString *)message title:(NSString *)title presenter:(UIViewController *)presenter {
    [[[AlertDialogController alloc] init] showAlertWithMessage:message title:title presenter:presenter handler:nil];
}

+ (void)showAlertWithMessage:(NSString *)message title:(NSString *)title presenter:(UIViewController *)presenter handler:(void(^)(void))handler {
    [[[AlertDialogController alloc] init] showAlertWithMessage:message title:title presenter:presenter handler:handler];
}

- (void)showAlertWithMessage:(NSString *)message title:(NSString *)title presenter:(UIViewController *)presenter handler:(void(^)(void))handler {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Ok"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              if (handler) handler();
                                                          }];
    
    [alert addAction:defaultAction];
    [presenter presentViewController:alert animated:YES completion:nil];
}

@end
