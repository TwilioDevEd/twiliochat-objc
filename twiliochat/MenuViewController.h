#import <UIKit/UIKit.h>
#import <TwilioChatClient/TwilioChatClient.h>

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, TwilioChatClientDelegate>
- (void)deselectSelectedChannel;
- (void)reloadChannelList;
@end
