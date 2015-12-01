#import "ChannelManager.h"
#import "IPMessagingManager.h"

@interface ChannelManager ()
@end

NSString *defaultChannelUniqueName = @"general23";
NSString *defaultChannelName = @"General23";

@implementation ChannelManager

+ (instancetype)sharedManager {
    static ChannelManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init {
    
    self.channels = [[NSMutableOrderedSet alloc] init];
    [IPMessagingManager sharedManager].client.delegate = self;
    return self;
}

- (void)createGeneralChatRoomWithBlock:(void(^)(TWMResult result, TWMChannel *channel))block {
    [self populateChannelsWithBlock:^(TWMResult result) {
        if (result == TWMResultSuccess) {
            self.generalChatroom = [self.channelsList channelWithUniqueName:defaultChannelUniqueName];
            if (self.generalChatroom) {
                [self joinGeneralChatRoomWithBlock:block];
            }
            else {
                [self.channelsList createChannelWithFriendlyName:defaultChannelName
                                                            type:TWMChannelTypePublic
                                                      completion:^(TWMResult result, TWMChannel *channel) {
                                                          self.generalChatroom = channel;
                                                          if (result == TWMResultSuccess) {
                                                              self.generalChatroom = channel;
                                                              [self joinGeneralChatRoomWithUniqueName:defaultChannelUniqueName block:block];
                                                              block(result, self.generalChatroom);
                                                          }
                                                          else {
                                                              block(result, nil);
                                                          }
                                                      }];
            }
        }
        else {
            block(result, nil);
        }
    }];
}

- (void)joinGeneralChatRoomWithBlock:(void(^)(TWMResult result, TWMChannel *channel))block {
    [self joinGeneralChatRoomWithUniqueName:nil block:block];
}

- (void)joinGeneralChatRoomWithUniqueName:(NSString *)uniqueName block:(void(^)(TWMResult result, TWMChannel *channel))block {
    __weak TWMChannel *weakGeneralChatRoom = self.generalChatroom;
    [self.generalChatroom joinWithCompletion:^(TWMResult result) {
        if (result == TWMResultSuccess) {
            if (uniqueName) {
                [self.generalChatroom setUniqueName:defaultChannelUniqueName completion:^(TWMResult result) {
                    if (result == TWMResultSuccess) {
                        block(result, weakGeneralChatRoom);
                    }
                    else {
                        block(result, nil);
                    }
                }];
            }
            else {
                block(result, self.generalChatroom);
            }
        }
        else {
            block(result, nil);
        }
    }];
}

- (void)loadChannelListWithBlock:(void(^)(TWMResult result, TWMChannels *channelsList))block {
    self.channelsList = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[IPMessagingManager sharedManager].client channelsListWithCompletion:^(TWMResult result, TWMChannels *channelsList) {
            if (result == TWMResultSuccess) {
                self.channelsList = channelsList;
            }
            else {
                // Show error
            }
            if (block) block(result, self.channelsList);
        }];
    });
}

- (void)populateChannelsWithBlock:(void(^)(TWMResult result))block {
    self.channels = nil;
    
    [self loadChannelListWithBlock:^(TWMResult result, TWMChannels *channelsList) {
        if (result == TWMResultSuccess) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.channelsList loadChannelsWithCompletion:^(TWMResult result) {
                    if (result == TWMResultSuccess) {
                        self.channels = [[NSMutableOrderedSet alloc] init];
                        [self.channels addObjectsFromArray:[self.channelsList allObjects]];
                        [self sortChannels];                        
                    }
                    else {
                        NSLog(@"Error creating channel");
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (block) block(result);
                    });
                }];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Error creating channel");
                self.channelsList = nil;
                self.channels = nil;
                if (block) block(result);
            });
        }
    }];
}

- (void)sortChannels {
    [self.channels sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"friendlyName"
                                                                      ascending:YES
                                                                       selector:@selector(localizedCaseInsensitiveCompare:)]]];
}

- (void)createChannelWithName:(NSString *)name block:(void(^)(TWMResult result, TWMChannel *channel))block {
    if ([name isEqualToString:defaultChannelName]) {
        if (block) block(TWMResultFailure, nil);
        return;
    }
    
    if (!self.channelsList)
    {
        [self loadChannelListWithBlock:^(TWMResult result, TWMChannels *channelsList) {
            if (result == TWMResultSuccess) {
                [self createChannelWithName:name block:block];
            }
            else {
                NSLog(@"Error creating channel");
                if (block) block(result, nil);
            }
        }];
        return;
    }
    
    [self.channelsList createChannelWithFriendlyName:name
                                                type:TWMChannelTypePublic
                                          completion:^(TWMResult result, TWMChannel *channel) {
                                              __weak TWMChannel *ch = channel;
                                              if (result == TWMResultSuccess) {
                                                  [channel joinWithCompletion:^(TWMResult result) {
                                                      [channel setAttributes:@{@"owner": [[IPMessagingManager sharedManager] userIdentity]}
                                                                  completion:^(TWMResult result) {
                                                                      if (block) block(result, ch);
                                                                  }];
                                                  }];
                                              }
                                              else {
                                                  NSLog(@"Error creating channel");
                                                  if (block) block(result, nil);
                                              }
                                          }];
}

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client channelAdded:(TWMChannel *)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.channels addObject:channel];
        [self sortChannels];
        [self.delegate ipMessagingClient:client channelAdded:channel];
    });
}

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client channelChanged:(TWMChannel *)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate ipMessagingClient:client channelChanged:channel];
    });
}

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client channelDeleted:(TWMChannel *)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ChannelManager sharedManager].channels removeObject:channel];
        [self.delegate ipMessagingClient:client channelDeleted:channel];
    });
}


@end
