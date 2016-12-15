#import "ChannelManager.h"
#import "MessagingManager.h"

#define _ Underscore

@interface ChannelManager ()
@property (strong, nonatomic) TCHChannel *generalChannel;
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
  [self.channelsList channelWithSidOrUniqueName:TWCDefaultChannelUniqueName completion:^(TCHResult *result, TCHChannel *channel) {
    if ([result isSuccessful]) {
      self.generalChannel = channel;
    }

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
  }];
}

- (void)joinGeneralChatRoomWithUniqueName:(NSString *)uniqueName completion:(SucceedHandler)completion {
  [self.generalChannel joinWithCompletion:^(TCHResult *result) {
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
  NSDictionary *options = [
                           NSDictionary
                           dictionaryWithObjectsAndKeys:TWCDefaultChannelName,
                           TCHChannelOptionFriendlyName,
                           TCHChannelTypePublic,
                           TCHChannelOptionType,
                           nil
                           ];

  [self.channelsList createChannelWithOptions:options
    completion:^(TCHResult *result, TCHChannel *channel) {
      if ([result isSuccessful]) {
        self.generalChannel = channel;
      }
      if (completion) completion([result isSuccessful]);
    }];
}

- (void)setGeneralChatRoomUniqueNameWithCompletion:(SucceedHandler)completion {
  [self.generalChannel setUniqueName:TWCDefaultChannelUniqueName
                          completion:^(TCHResult *result) {
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

  NSDictionary *options = [
                           NSDictionary
                           dictionaryWithObjectsAndKeys:name,
                           TCHChannelOptionFriendlyName,
                           TCHChannelTypePublic,
                           TCHChannelOptionType,
                           nil
                           ];
  [self.channelsList
    createChannelWithOptions:options
    completion:^(TCHResult *result, TCHChannel *channel) {
      if (completion) completion([result isSuccessful], channel);
    }];
}

# pragma mark TwilioChatClientDelegate

- (void)chatClient:(TwilioChatClient *)client channelAdded:(TCHChannel *)channel{
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.channels addObject:channel];
    [self sortAndDedupeChannels];
    [self.delegate chatClient:client channelAdded:channel];
  });
}

- (void)chatClient:(TwilioChatClient *)client channelChanged:(TCHChannel *)channel {
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.delegate chatClient:client channelChanged:channel];
  });
}

- (void)chatClient:(TwilioChatClient *)client channelDeleted:(TCHChannel *)channel {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[ChannelManager sharedManager].channels removeObject:channel];
    [self.delegate chatClient:client channelDeleted:channel];
  });
}

- (void)chatClient:(TwilioChatClient *)client synchronizationStatusChanged:(TCHClientSynchronizationStatus)status {
}

@end
