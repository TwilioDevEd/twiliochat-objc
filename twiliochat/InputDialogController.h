#import <UIKit/UIKit.h>

@interface InputDialogController : NSObject
+ (void)showWithTitle:(NSString *)title message:(NSString *)message presenter:(UIViewController *)presenter handler:(void (^)(NSString *))handler;
@end
