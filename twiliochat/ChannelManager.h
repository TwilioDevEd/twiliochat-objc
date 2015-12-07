#import <Foundation/Foundation.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

typedef void (^SucceedHandler) (BOOL succeeded);
typedef void (^ChannelsListHandler) (BOOL success, TWMChannels *);
typedef void (^ChannelHandler) (BOOL success, TWMChannel *);

@interface ChannelManager : NSObject <TwilioIPMessagingClientDelegate>
+ (instancetype)sharedManager;
- (void)populateChannelsWithCompletion:(SucceedHandler)completion;
- (void)createChannelWithName:(NSString *)name completion:(ChannelHandler)completion;
- (void)joinGeneralChatRoomWithCompletion:(SucceedHandler)completion;
@property (strong, nonatomic) TWMChannels *channelsList;
@property (strong, nonatomic) NSMutableOrderedSet *channels;
@property (weak, nonatomic) id<TwilioIPMessagingClientDelegate> delegate;
@property (strong, nonatomic, readonly) TWMChannel *generalChatroom;

@end
