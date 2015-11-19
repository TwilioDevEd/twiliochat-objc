#import <Foundation/Foundation.h>

@interface IPMessagingManager : NSObject
+ (instancetype)sharedManager;
- (void)presentRootViewController;
@end
