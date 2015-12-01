#import <UIKit/UIKit.h>
#import <SLKTextViewController.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

@interface MainChatViewController : SLKTextViewController <UITableViewDataSource, UITableViewDelegate, TWMChannelDelegate>
@property (strong, nonatomic) TWMChannel *channel;
@end
