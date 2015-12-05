#import "ChannelManager.h"
#import "IPMessagingManager.h"

@interface ChannelManager ()
{
    TWMChannel *_generalChatroom;
}
@end

NSString *defaultChannelUniqueName = @"general";
NSString *defaultChannelName = @"General Channel";

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

#pragma mark General channel

- (TWMChannel *)generalChatroom {
    return _generalChatroom;
}

- (void)joinGeneralChatRoomWithCompletion:(nonnull SucceedHandler)completion {
    [self populateChannelsWithCompletion:^(BOOL succeeded) {
        _generalChatroom = [self.channelsList channelWithUniqueName:defaultChannelUniqueName];
        if (_generalChatroom) {
            [self joinGeneralChatRoomWithUniqueName:nil completion:completion];
        }
        else {
            [self createGeneralChatRoomWithCompletion:^(BOOL succeeded) {
                if (succeeded) {
                    [self joinGeneralChatRoomWithUniqueName:defaultChannelUniqueName completion:completion];
                    return;
                }
                completion(NO);
            }];
        }
    }];
}

- (void)joinGeneralChatRoomWithUniqueName:(NSString *)uniqueName completion:(nonnull SucceedHandler)completion {
    [_generalChatroom joinWithCompletion:^(TWMResult result) {
        if (result == TWMResultSuccess) {
            if (uniqueName) {
                [self setGeneralChatRoomUniqueNameWithCompletion:completion];
                return;
            }
        }
        completion(result == TWMResultSuccess);
    }];
}

- (void)createGeneralChatRoomWithCompletion:(nonnull SucceedHandler)completion {
    [self.channelsList createChannelWithFriendlyName:defaultChannelName
                                                type:TWMChannelTypePublic
                                          completion:^(TWMResult result, TWMChannel *channel) {
                                              if (result == TWMResultSuccess) {
                                                  _generalChatroom = channel;
                                              }
                                              completion(result == TWMResultSuccess);
                                          }];
}

- (void)setGeneralChatRoomUniqueNameWithCompletion:(nonnull SucceedHandler)completion {
    [_generalChatroom setUniqueName:defaultChannelUniqueName completion:^(TWMResult result) {
        completion(result == TWMResultSuccess);
    }];
}

#pragma mark Populate channels

- (void)populateChannelsWithCompletion:(nonnull SucceedHandler)completion {
    self.channels = nil;
    
    [self loadChannelListWithCompletion:^(BOOL succeeded, TWMChannels *channelsList) {
        if (!succeeded) {
            self.channelsList = nil;
            self.channels = nil;
            completion(succeeded);
            return;
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.channelsList loadChannelsWithCompletion:^(TWMResult result) {
                if (result == TWMResultSuccess) {
                    self.channels = [[NSMutableOrderedSet alloc] init];
                    [self.channels addObjectsFromArray:[self.channelsList allObjects]];
                    [self sortChannels];
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(succeeded);
                });
            }];
        });
    }];
}

- (void)loadChannelListWithCompletion:(nonnull ChannelsListHandler)completion {
    self.channelsList = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[IPMessagingManager sharedManager].client channelsListWithCompletion:^(TWMResult result, TWMChannels *channelsList) {
            if (result == TWMResultSuccess) {
                self.channelsList = channelsList;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(result == TWMResultSuccess, self.channelsList);
            });
        }];
    });
}

- (void)sortChannels {
    SEL sortSelector = @selector(localizedCaseInsensitiveCompare:);
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"friendlyName"
                                                               ascending:YES
                                                                selector:sortSelector];
    [self.channels sortUsingDescriptors:@[descriptor]];
}

# pragma mark Create channel

- (void)createChannelWithName:(NSString *)name completion:(nullable ChannelHandler)completion {
    if ([name isEqualToString:defaultChannelName]) {
        completion(NO, nil);
        return;
    }
    
    if (!self.channelsList)
    {
        [self loadChannelListWithCompletion:^(BOOL succeeded, TWMChannels *channelsList) {
            if (succeeded) {
                [self createChannelWithName:name completion:completion];
            }
            else if(completion) {
                completion(succeeded, nil);
            }
        }];
        return;
    }
    
    [self.channelsList createChannelWithFriendlyName:name
                                                type:TWMChannelTypePublic
                                          completion:^(TWMResult result, TWMChannel *channel) {
                                              completion(result == TWMResultSuccess, channel);
                                          }];
}

# pragma mark TwilioIPMessagingClientDelegate

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
