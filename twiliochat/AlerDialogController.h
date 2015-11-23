#import <UIKit/UIKit.h>

@interface AlerDialogController : NSObject
+ (void)showAlertWithMessage:(NSString *)message title:(NSString *)title presenter:(UIViewController *)presenter;
@end
