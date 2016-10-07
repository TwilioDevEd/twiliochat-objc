#import "ChannelManager.h"
#import "IPMessagingManager.h"

@interface ChannelManager ()
@property (strong, nonatomic) TWMChannel *generalChannel;
@end

static NSString * const TWCDefaultChannelUniqueName = @"general";
static NSString * const TWCDefaultChannelName = @"General Channel";

static NSString * const TWCFriendlyNameKey = @"friendlyName";

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
  return self;
}

#pragma mark General channel

- (void)joinGeneralChatRoomWithCompletion:(SucceedHandler)completion {
  self.generalChannel = [self.channelsList channelWithUniqueName:TWCDefaultChannelUniqueName];
  if (self.generalChannel) {
    [self joinGeneralChatRoomWithUniqueName:nil completion:completion];
  }
  else {
    [self createGeneralChatRoomWithCompletion:^(BOOL succeeded) {
      if (succeeded) {
        [self joinGeneralChatRoomWithUniqueName:TWCDefaultChannelUniqueName completion:completion];
        return;
      }
      if (completion) completion(NO);
    }];
  };
}

- (void)joinGeneralChatRoomWithUniqueName:(NSString *)uniqueName completion:(SucceedHandler)completion {
  [self.generalChannel joinWithCompletion:^(TWMResult *result) {
    if ([result isSuccessful]) {
      if (uniqueName) {
        [self setGeneralChatRoomUniqueNameWithCompletion:completion];
        return;
      }
    }
    if (completion) completion([result isSuccessful]);
  }];
}

- (void)createGeneralChatRoomWithCompletion:(SucceedHandler)completion {
  NSDictionary *options = [NSDictionary
    dictionaryWithObjectsAndKeys:TWCDefaultChannelName, TWMChannelOptionFriendlyName, TWMChannelTypePublic, TWMChannelOptionType, nil];
  [self.channelsList createChannelWithOptions:options
    completion:^(TWMResult *result, TWMChannel *channel) {
      if ([result isSuccessful]) {
        self.generalChannel = channel;
      }
      if (completion) completion([result isSuccessful]);
    }];
}

- (void)setGeneralChatRoomUniqueNameWithCompletion:(SucceedHandler)completion {
  [self.generalChannel setUniqueName:TWCDefaultChannelUniqueName completion:^(TWMResult *result) {
    if (completion) completion([result isSuccessful]);
  }];
}

#pragma mark Populate channels

- (void)populateChannels {
  self.channels = [[NSMutableOrderedSet alloc] init];
  [self.channels addObjectsFromArray:[self.channelsList allObjects]];
  [self sortChannels];
  if (self.delegate) {
    [self.delegate reloadChannelList];
  }
}

- (void)sortChannels {
  SEL sortSelector = @selector(localizedCaseInsensitiveCompare:);
  NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:TWCFriendlyNameKey
                                                             ascending:YES
                                                              selector:sortSelector];
  [self.channels sortUsingDescriptors:@[descriptor]];
}

# pragma mark Create channel

- (void)createChannelWithName:(NSString *)name completion:(ChannelHandler)completion {
  if ([name isEqualToString:TWCDefaultChannelName]) {
    if (completion) completion(NO, nil);
    return;
  }

  NSDictionary *options = [NSDictionary
                           dictionaryWithObjectsAndKeys:name, TWMChannelOptionFriendlyName, TWMChannelTypePublic, TWMChannelOptionType, nil];
  [self.channelsList
    createChannelWithOptions:options
    completion:^(TWMResult *result, TWMChannel *channel) {
      if (completion) completion([result isSuccessful], channel);
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

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client synchronizationStatusChanged:(TWMClientSynchronizationStatus)status {
}

@end
