#import "ChannelManager.h"
#import "IPMessagingManager.h"

@interface ChannelManager ()
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

- (void)joinGeneralChatRoomWithBlock:(void(^)(BOOL succeeded))block {
    [self populateChannelsWithBlock:^(BOOL succeeded) {
        self.generalChatroom = [self.channelsList channelWithUniqueName:defaultChannelUniqueName];
        if (self.generalChatroom) {
            [self joinGeneralChatRoomWithUniqueName:nil block:block];
        }
        else {
            [self createGeneralChatRoomWithBlock:^(BOOL succeeded) {
                if (succeeded) {
                    [self joinGeneralChatRoomWithUniqueName:defaultChannelUniqueName block:block];
                    return;
                }
                if (block) block(YES);
            }];
        }
    }];
}

- (void)joinGeneralChatRoomWithUniqueName:(NSString *)uniqueName block:(void(^)(BOOL succeeded))block {
    [self.generalChatroom joinWithCompletion:^(TWMResult result) {
        if (result == TWMResultSuccess) {
            if (uniqueName) {
                [self setGeneralChatRoomUniqueNameWithBlock:block];
                return;
            }
        }
        if (block) block(result == TWMResultSuccess);
    }];
}

- (void)createGeneralChatRoomWithBlock:(void(^)(BOOL succeeded))block {
    [self.channelsList createChannelWithFriendlyName:defaultChannelName
                                                type:TWMChannelTypePublic
                                          completion:^(TWMResult result, TWMChannel *channel) {
                                              if (result == TWMResultSuccess) {
                                                  self.generalChatroom = channel;
                                              }
                                              if (block) block(result == TWMResultSuccess);
                                          }];
}

- (void)setGeneralChatRoomUniqueNameWithBlock:(void(^)(BOOL succeeded))block {
    [self.generalChatroom setUniqueName:defaultChannelUniqueName completion:^(TWMResult result) {
        if (block) block(result == TWMResultSuccess);
    }];
}

#pragma mark Populate channels

- (void)populateChannelsWithBlock:(void(^)(BOOL succeeded))block {
    self.channels = nil;
    
    [self loadChannelListWithBlock:^(BOOL succeeded, TWMChannels *channelsList) {
        if (!succeeded) {
            self.channelsList = nil;
            self.channels = nil;
            if (block) block(succeeded);
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
                    if (block) block(succeeded);
                });
            }];
        });
    }];
}

- (void)loadChannelListWithBlock:(void(^)(BOOL succeeded, TWMChannels *channelsList))block {
    self.channelsList = nil;

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[IPMessagingManager sharedManager].client channelsListWithCompletion:^(TWMResult result, TWMChannels *channelsList) {
            if (result == TWMResultSuccess) {
                self.channelsList = channelsList;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (block) block(result == TWMResultSuccess, self.channelsList);
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

- (void)createChannelWithName:(NSString *)name block:(void(^)(BOOL succeeded, TWMChannel *channel))block {
    if ([name isEqualToString:defaultChannelName]) {
        if (block) block(NO, nil);
        return;
    }
    
    if (!self.channelsList)
    {
        [self loadChannelListWithBlock:^(BOOL succeeded, TWMChannels *channelsList) {
            if (succeeded) {
                [self createChannelWithName:name block:block];
            }
            else {
                if (block) block(succeeded, nil);
            }
        }];
        return;
    }
    
    [self.channelsList createChannelWithFriendlyName:name
                                                type:TWMChannelTypePublic
                                          completion:^(TWMResult result, TWMChannel *channel) {
                                              if (block) block(result == TWMResultSuccess, channel);
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
