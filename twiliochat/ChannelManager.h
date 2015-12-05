#import <Foundation/Foundation.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^SucceedHandler) (BOOL succeeded);
typedef void (^ChannelsListHandler) (BOOL success, TWMChannels * _Nullable);
typedef void (^ChannelHandler) (BOOL success, TWMChannel * _Nullable);

@interface ChannelManager : NSObject <TwilioIPMessagingClientDelegate>
+ (nullable instancetype)sharedManager;
- (void)populateChannelsWithCompletion:(SucceedHandler)completion;
- (void)createChannelWithName:(NSString *)name completion:(nullable ChannelHandler)completion;
- (void)joinGeneralChatRoomWithCompletion:(SucceedHandler)completion;
@property (strong, nonatomic, nullable) TWMChannels *channelsList;
@property (strong, nonatomic, nullable) NSMutableOrderedSet *channels;
@property (weak, nonatomic, nullable) id<TwilioIPMessagingClientDelegate> delegate;
@property (strong, nonatomic, readonly, nullable) TWMChannel *generalChatroom;
NS_ASSUME_NONNULL_END

@end
