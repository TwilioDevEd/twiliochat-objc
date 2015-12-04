#import <Foundation/Foundation.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

@interface ChannelManager : NSObject <TwilioIPMessagingClientDelegate>
+ (instancetype)sharedManager;
- (void)populateChannelsWithCompletion:(void(^)(BOOL succeeded))completion;
- (void)createChannelWithName:(NSString *)name completion:(void(^)(BOOL succeeded, TWMChannel *channel))completion;
- (void)joinGeneralChatRoomWithCompletion:(void(^)(BOOL succeeded))completion;
@property (strong, nonatomic) TWMChannels *channelsList;
@property (strong, nonatomic) NSMutableOrderedSet *channels;
@property (weak, nonatomic) id<TwilioIPMessagingClientDelegate> delegate;
@property (strong, nonatomic) TWMChannel *generalChatroom;

@end
