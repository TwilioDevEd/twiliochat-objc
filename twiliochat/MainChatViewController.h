#import <UIKit/UIKit.h>
#import <SLKTextViewController.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

@interface MainChatViewController : SLKTextViewController <TWMChannelDelegate>
@property (strong, nonatomic) TWMChannel *channel;
@end
