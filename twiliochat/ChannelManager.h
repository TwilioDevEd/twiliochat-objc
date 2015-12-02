#import <Foundation/Foundation.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

@interface ChannelManager : NSObject <TwilioIPMessagingClientDelegate>
+ (instancetype)sharedManager;
- (void)populateChannelsWithBlock:(void(^)(BOOL succeeded))block;
- (void)createChannelWithName:(NSString *)name block:(void(^)(BOOL succeeded, TWMChannel *channel))block;
- (void)joinGeneralChatRoomWithBlock:(void(^)(BOOL succeeded))block;
@property (strong, nonatomic) TWMChannels *channelsList;
@property (strong, nonatomic) NSMutableOrderedSet *channels;
@property (weak, nonatomic) id<TwilioIPMessagingClientDelegate> delegate;
@property (strong, nonatomic) TWMChannel *generalChatroom;

@end
