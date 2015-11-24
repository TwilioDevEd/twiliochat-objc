#import <UIKit/UIKit.h>

@interface AlertDialogController : NSObject
+ (void)showAlertWithMessage:(NSString *)message title:(NSString *)title presenter:(UIViewController *)presenter;
+ (void)showAlertWithMessage:(NSString *)message title:(NSString *)title presenter:(UIViewController *)presenter handler:(void(^)(void))handler;
@end
