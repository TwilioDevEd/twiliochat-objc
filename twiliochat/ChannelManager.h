#import <Foundation/Foundation.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

@interface ChannelManager : NSObject <TwilioIPMessagingClientDelegate>
+ (instancetype)sharedManager;
- (void)populateChannelsWithBlock:(void(^)(TWMResult result))block;
- (void)createChannelWithName:(NSString *)name block:(void(^)(TWMResult result, TWMChannel *channel))block;
- (void)joinGeneralChatRoomWithBlock:(void(^)(TWMResult result, TWMChannel *generalChatRoom))block;
@property (strong, nonatomic) TWMChannels *channelsList;
@property (strong, nonatomic) NSMutableOrderedSet *channels;
@property (weak, nonatomic) id<TwilioIPMessagingClientDelegate> delegate;
@property (strong, nonatomic) TWMChannel *generalChatroom;

@end
