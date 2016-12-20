#import <UIKit/UIKit.h>
#import <SLKTextViewController.h>
#import <TwilioChatClient/TwilioChatClient.h>

@interface MainChatViewController : SLKTextViewController <TCHChannelDelegate>
@property (strong, nonatomic) TCHChannel *channel;
@end
