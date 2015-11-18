#import <UIKit/UIKit.h>
#import <SLKTextViewController.h>

@interface MainChatViewController : SLKTextViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSString *channel;
@end
