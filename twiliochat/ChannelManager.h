#import <Foundation/Foundation.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

@interface ChannelManager : NSObject <TwilioIPMessagingClientDelegate>
+ (instancetype)sharedManager;
- (void)populateChannelsWithBlock:(void(^)(TMResultEnum result))block;
- (void)createChannelWithName:(NSString *)name block:(void(^)(TMResultEnum result, TMChannel *channel))block;
- (void)loadGeneralChatRoomWithBlock:(void(^)(TMResultEnum result, TMChannel *channel))block;
@property (strong, nonatomic) TMChannels *channelsList;
@property (strong, nonatomic) NSMutableOrderedSet *channels;
@property (weak, nonatomic) id<TwilioIPMessagingClientDelegate> delegate;
@property (strong, nonatomic) TMChannel *generalChatroom;

@end
