//
//  ChannelManager.h
//  twiliochat
//
//  Created by Juank on 11/24/15.
//  Copyright © 2015 Twilio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

@interface ChannelManager : NSObject <TwilioIPMessagingClientDelegate>
+ (instancetype)sharedManager;
- (void)populateChannelsWithBlock:(void(^)(TWMResult result))block;
- (void)createChannelWithName:(NSString *)name block:(void(^)(TWMResult result, TWMChannel *channel))block;
- (void)createGeneralChatRoomWithBlock:(void(^)(TWMResult result, TWMChannel *channel))block;
@property (strong, nonatomic) TWMChannels *channelsList;
@property (strong, nonatomic) NSMutableOrderedSet *channels;
@property (weak, nonatomic) id<TwilioIPMessagingClientDelegate> delegate;
@property (strong, nonatomic) TWMChannel *generalChatroom;

@end
