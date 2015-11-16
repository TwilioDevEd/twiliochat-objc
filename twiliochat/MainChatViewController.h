#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SWRevealViewController.h"

@interface MainChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) NSString *channel;
@end
