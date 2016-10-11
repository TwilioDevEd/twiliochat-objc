#import <UIKit/UIKit.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, TwilioIPMessagingClientDelegate>
- (void)deselectSelectedChannel;
- (void)reloadChannelList;
@end
