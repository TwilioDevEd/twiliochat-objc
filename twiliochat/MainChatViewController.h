#import <UIKit/UIKit.h>
#import <SLKTextViewController.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

@interface MainChatViewController : SLKTextViewController <UITableViewDataSource, UITableViewDelegate, TMChannelDelegate>
@property (strong, nonatomic) TMChannel *channel;
@end
