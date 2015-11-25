#import "ChannelManager.h"
#import "IPMessagingManager.h"

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


- (void)loadChannelListWithBlock:(void(^)(TMResultEnum result, TMChannels *channelsList))block {
    self.channelsList = nil;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[IPMessagingManager sharedManager].client channelsListWithCompletion:^(TMResultEnum result, TMChannels *channelsList) {
            if (result) {
                self.channelsList = channelsList;
            }
            else {
                // Show error
            }
            if (block) block(result, self.channelsList);
        }];
    });
}

- (void)populateChannelsWithBlock:(void(^)(TMResultEnum result))block {
    self.channels = nil;
    
    [self loadChannelListWithBlock:^(TMResultEnum result, TMChannels *channelsList) {
        if (result == TMResultSuccess) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.channelsList loadChannelsWithCompletion:^(TMResultEnum result) {
                    if (result == TMResultSuccess) {
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

- (void)createChannelWithName:(NSString *)name block:(void(^)(TMResultEnum result, TMChannel *channel))block {
    if (!self.channelsList)
    {
        [self loadChannelListWithBlock:^(TMResultEnum result, TMChannels *channelsList) {
            if (result == TMResultSuccess) {
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
                                                type:TMChannelTypePublic
                                          completion:^(TMResultEnum result, TMChannel *channel) {
                                              __weak TMChannel *ch = channel;
                                              if (result == TMResultSuccess) {
                                                  [channel joinWithCompletion:^(TMResultEnum result) {
                                                      [channel setAttributes:@{@"owner": [[IPMessagingManager sharedManager] userIdentity]}
                                                                  completion:^(TMResultEnum result) {
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

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client channelAdded:(TMChannel *)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.channels addObject:channel];
        [self sortChannels];
        [self.delegate ipMessagingClient:client channelAdded:channel];
    });
}

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client channelChanged:(TMChannel *)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate ipMessagingClient:client channelChanged:channel];
    });
}

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client channelDeleted:(TMChannel *)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[ChannelManager sharedManager].channels removeObject:channel];
        [self.delegate ipMessagingClient:client channelDeleted:channel];
    });
}


@end
