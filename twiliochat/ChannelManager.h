#import <Foundation/Foundation.h>
#import <TwilioChatClient/TwilioChatClient.h>
#import "MenuViewController.h"

typedef void (^SucceedHandler) (BOOL succeeded);
typedef void (^ChannelsListHandler) (BOOL success, TCHChannels *);
typedef void (^ChannelHandler) (BOOL success, TCHChannel *);

@interface ChannelManager : NSObject <TwilioChatClientDelegate>
+ (instancetype)sharedManager;
- (void)populateChannels;
- (void)createChannelWithName:(NSString *)name completion:(ChannelHandler)completion;
- (void)joinGeneralChatRoomWithCompletion:(SucceedHandler)completion;
@property (strong, nonatomic) TCHChannels *channelsList;
@property (strong, nonatomic) NSMutableOrderedSet *channels;
@property (weak, nonatomic) MenuViewController<TwilioChatClientDelegate> *delegate;
@property (strong, nonatomic, readonly) TCHChannel *generalChannel;

@end
