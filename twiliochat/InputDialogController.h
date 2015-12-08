#import <UIKit/UIKit.h>

@interface InputDialogController : NSObject
+ (void)showWithTitle:(NSString *)title
              message:(NSString *)message
          placeholder:(NSString *)placeholder
            presenter:(UIViewController *)presenter
              handler:(void (^)(NSString *))handler;
@end
