#import <TwilioChatClient/TwilioChatClient.h>
#import "MainChatViewController.h"
#import "ChatTableCell.h"
#import "NSDate+ISO8601Parser.h"
#import "SWRevealViewController.h"
#import "ChannelManager.h"
#import "StatusEntry.h"
#import "DateTodayFormatter.h"
#import "MenuViewController.h"

@interface MainChatViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionButtonItem;

@property (strong, nonatomic) NSMutableOrderedSet *messages;

@end

static NSString * const TWCChatCellIdentifier = @"ChatTableCell";
static NSString * const TWCChatStatusCellIdentifier = @"ChatStatusTableCell";

static NSString * const TWCOpenGeneralChannelSegue = @"OpenGeneralChat";
static NSInteger const TWCLabelTag = 200;

@implementation MainChatViewController

#pragma mark Initialization

- (void)viewDidLoad {
  [super viewDidLoad];
  
  if (self.revealViewController)
  {
    [self.revealButtonItem setTarget: self.revealViewController];
    [self.revealButtonItem setAction: @selector( revealToggle: )];
    [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    self.revealViewController.rearViewRevealOverdraw = 0.f;
  }
  
  self.bounces = YES;
  self.shakeToClearEnabled = YES;
  self.keyboardPanningEnabled = YES;
  self.shouldScrollToBottomAfterKeyboardShows = NO;
  self.inverted = YES;
  
  UINib *cellNib = [UINib nibWithNibName:TWCChatCellIdentifier bundle:nil];
  [self.tableView registerNib:cellNib
       forCellReuseIdentifier:TWCChatCellIdentifier];
  
  UINib *cellStatusNib = [UINib nibWithNibName:TWCChatStatusCellIdentifier bundle:nil];
  [self.tableView registerNib:cellStatusNib
       forCellReuseIdentifier:TWCChatStatusCellIdentifier];
  
  self.textInputbar.autoHideRightButton = YES;
  self.textInputbar.maxCharCount = 256;
  self.textInputbar.counterStyle = SLKCounterStyleSplit;
  self.textInputbar.counterPosition = SLKCounterPositionTop;
  
  UIFont *font = [UIFont fontWithName:@"Avenir-Light" size:14];
  self.textView.font = font;
  
  [self.rightButton setTitleColor:[UIColor colorWithRed:0.973 green:0.557 blue:0.502 alpha:1]
                         forState:UIControlStateNormal];
  
  font = [UIFont fontWithName:@"Avenir-Heavy" size:17];
  self.navigationController.navigationBar.titleTextAttributes = @{NSFontAttributeName:font};

  self.tableView.allowsSelection = NO;
  self.tableView.estimatedRowHeight = 70;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  
  if (!self.channel) {
    id generalChannel = [ChannelManager sharedManager].generalChannel;
      if (generalChannel) {
          self.channel = generalChannel;
      } else {
          [[ChannelManager sharedManager] joinGeneralChatRoomWithCompletion:^(BOOL succeeded) {
              if (succeeded) {
                  self.channel = [ChannelManager sharedManager].generalChannel;
              }
          }];
      }
  }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self.textInputbar bringSubviewToFront:self.textInputbar.textView];
    [self.textInputbar bringSubviewToFront:self.textInputbar.leftButton];
    [self.textInputbar bringSubviewToFront:self.textInputbar.rightButton];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self scrollToBottomMessage];
}

- (NSMutableOrderedSet *)messages {
  if (!_messages) {
    _messages = [[NSMutableOrderedSet alloc] init];
  }
  return _messages;
}

- (void)setChannel:(TCHChannel *)channel {
  if ([channel isKindOfClass:[TCHChannelDescriptor class]]) {
    TCHChannelDescriptor *channelDescriptor = (TCHChannelDescriptor*)channel;
    [channelDescriptor channelWithCompletion:^(TCHResult *success, TCHChannel *channel) {
      if (success) {
        [self actuallySetChannel:channel];
      }
    }];
  } else {
    [self actuallySetChannel:channel];
  }
}

- (void)actuallySetChannel:(TCHChannel *)channel {
  _channel = channel;
  self.title = self.channel.friendlyName;
  self.channel.delegate = self;
  
  if (self.channel == [ChannelManager sharedManager].generalChannel) {
    self.navigationItem.rightBarButtonItem = nil;
  }
  
  [self setViewOnHold:YES];
  
  if (self.channel.status != TCHChannelStatusJoined) {
    [self.channel joinWithCompletion:^(TCHResult* result) {
      NSLog(@"%@", @"Channel Joined");
    }];
  }
  if (self.channel.synchronizationStatus == TCHChannelSynchronizationStatusAll) {
    [self loadMessages];
    [self setViewOnHold:NO];
  }
}

// Disable user input and show activity indicator
- (void)setViewOnHold:(BOOL)onHold {
  self.textInputbarHidden = onHold;
  [UIApplication sharedApplication].networkActivityIndicatorVisible = onHold;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = nil;
  
  id message = [self.messages objectAtIndex:indexPath.row];
  
  if ([message isKindOfClass:[TCHMessage class]]) {
    cell = [self getChatCellForTableView:tableView forIndexPath:indexPath message:message];
  }
  else {
    cell = [self getStatusCellForTableView:tableView forIndexPath:indexPath message:message];
  }
  
  cell.transform = tableView.transform;
  return cell;
}

- (ChatTableCell *)getChatCellForTableView:(UITableView *)tableView
                              forIndexPath:(NSIndexPath *)indexPath
                                   message:(TCHMessage *)message {
  UITableViewCell *cell = [self.tableView
    dequeueReusableCellWithIdentifier:TWCChatCellIdentifier forIndexPath:indexPath];

  ChatTableCell *chatCell = (ChatTableCell *)cell;
  chatCell.user = message.author;
  chatCell.date = [[[DateTodayFormatter alloc] init]
    stringFromDate:[NSDate dateWithISO8601String:message.timestamp]];

  chatCell.message = message.body;
  
  return chatCell;
}

- (UITableViewCell *)getStatusCellForTableView:(UITableView *)tableView
                                 forIndexPath:(NSIndexPath *)indexPath
                                      message:(StatusEntry *)message {
  UITableViewCell *cell = [self.tableView
    dequeueReusableCellWithIdentifier:TWCChatStatusCellIdentifier forIndexPath:indexPath];
  
  UILabel *label = [cell viewWithTag:TWCLabelTag];
  label.text = [NSString stringWithFormat:@"User %@ has %@",
     message.member.identity, (message.status == TWCMemberStatusJoined) ? @"joined" : @"left"];
  
  return cell;
}

- (void)didPressRightButton:(id)sender {
  [self.textView refreshFirstResponder];
  [self sendMessage: [self.textView.text copy]];
  [super didPressRightButton:sender];
}

#pragma mark Chat Service
- (void)sendMessage: (NSString *)inputMessage {
    TCHMessageOptions *messageOptions = [[[TCHMessageOptions alloc] init] withBody:inputMessage];
    [self.channel.messages sendMessageWithOptions:messageOptions
                                       completion:nil];
}



- (void)addMessages:(NSArray *)messages {
  [self.messages addObjectsFromArray:messages];
  [self sortMessages];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self.tableView reloadData];
    if (self.messages.count > 0) {
      [self scrollToBottomMessage];
    }
  });
}


- (void)sortMessages {
  [self.messages sortUsingDescriptors:@[[[NSSortDescriptor alloc]
    initWithKey:@"timestamp" ascending:NO]]];
}

- (void)scrollToBottomMessage {
  if (self.messages.count == 0) {
    return;
  }
  
  NSIndexPath *bottomMessageIndex = [NSIndexPath indexPathForRow:0
                                                       inSection:0];
  [self.tableView scrollToRowAtIndexPath:bottomMessageIndex
    atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)loadMessages {
  [self.messages removeAllObjects];
  if (self.channel.synchronizationStatus == TCHChannelSynchronizationStatusAll) {
    [self.channel.messages
     getLastMessagesWithCount:100
     completion:^(TCHResult *result, NSArray *messages) {
      if ([result isSuccessful]) {
        [self addMessages: messages];
      }
    }];
  }
}

- (void)leaveChannel {
  [self.channel leaveWithCompletion:^(TCHResult* result) {
    if ([result isSuccessful]) {
      [(MenuViewController *)self.revealViewController.rearViewController deselectSelectedChannel];
      [self.revealViewController.rearViewController
        performSegueWithIdentifier:TWCOpenGeneralChannelSegue sender:nil];
    }
  }];
}

#pragma mark - TMMessageDelegate

- (void)chatClient:(TwilioChatClient *)client
                  channel:(TCHChannel *)channel
             messageAdded:(TCHMessage *)message {
  if (![self.messages containsObject:message]) {
    [self addMessages:@[message]];
  }
}

- (void)chatClient:(TwilioChatClient *)client
           channelDeleted:(TCHChannel *)channel {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (channel == self.channel) {
      [self.revealViewController.rearViewController
        performSegueWithIdentifier:TWCOpenGeneralChannelSegue sender:nil];
    }
  });
}

- (void)chatClient:(TwilioChatClient *)client
                  channel:(TCHChannel *)channel
             memberJoined:(TCHMember *)member {
  [self addMessages:@[[StatusEntry statusEntryWithMember:member status:TWCMemberStatusJoined]]];
}

- (void)chatClient:(TwilioChatClient *)client
                  channel:(TCHChannel *)channel
               memberLeft:(TCHMember *)member {
  [self addMessages:@[[StatusEntry statusEntryWithMember:member status:TWCMemberStatusLeft]]];
}

- (void)chatClient:(TwilioChatClient *)client channel:(TCHChannel *)channel synchronizationStatusChanged:(TCHChannelSynchronizationStatus)status {
  if (status == TCHChannelSynchronizationStatusAll) {
    [self loadMessages];
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.tableView reloadData];
      [self setViewOnHold:NO];
    });
  }
}

#pragma mark - Actions

- (IBAction)actionButtonTouched:(UIBarButtonItem *)sender {
  [self leaveChannel];
}

- (IBAction)revealButtonTouched:(UIBarButtonItem *)sender {
  [self.revealViewController revealToggleAnimated:YES];
}

@end
