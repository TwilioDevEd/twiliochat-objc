#import <Parse/Parse.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>
#import "MainChatViewController.h"
#import "SWRevealViewController.h"
#import "ChatTableCell.h"
#import "NSDate+ISO8601Parser.h"

@interface MainChatViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;

@property (strong, nonatomic) NSMutableOrderedSet *messages;

@end

static NSString *ChatCellIdentifier = @"ChatTableCell";
static NSString *ChatStatusCellIdentifier = @"ChatStatusTableCell";

@implementation MainChatViewController

#pragma mark Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    SWRevealViewController *revealViewController = self.revealViewController;
    self.revealViewController.rearViewRevealOverdraw = 0.f;
    
    if ( revealViewController )
    {
        [self.revealButtonItem setTarget: self.revealViewController];
        [self.revealButtonItem setAction: @selector( revealToggle: )];
        [self.navigationController.navigationBar addGestureRecognizer: self.revealViewController.panGestureRecognizer];
    }

    self.bounces = YES;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = YES;
    
    UINib *cellNib = [UINib nibWithNibName:ChatCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib
         forCellReuseIdentifier:ChatCellIdentifier];
    
    UINib *cellStatusNib = [UINib nibWithNibName:ChatStatusCellIdentifier bundle:nil];
    [self.tableView registerNib:cellStatusNib
         forCellReuseIdentifier:ChatStatusCellIdentifier];
    
    self.textInputbar.autoHideRightButton = YES;
    self.textInputbar.maxCharCount = 256;
    self.textInputbar.counterStyle = SLKCounterStyleSplit;
    self.textInputbar.counterPosition = SLKCounterPositionTop;
    
    UIFont *font = [UIFont fontWithName:@"Avenir-Light" size:14];
    [self.textView setFont:font];
    
    [self.rightButton setTitleColor:[UIColor colorWithRed:0.973 green:0.557 blue:0.502 alpha:1]
                           forState:UIControlStateNormal];
    
    font = [UIFont fontWithName:@"Avenir-Heavy" size:17];
    [self.navigationController.navigationBar setTitleTextAttributes:
     @{NSFontAttributeName:font}];
    
    self.tableView.estimatedRowHeight = 70;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (NSMutableOrderedSet *)messages {
    if (!_messages) {
        _messages = [[NSMutableOrderedSet alloc] init];
    }
    return _messages;
}

- (void)setChannel:(TMChannel *)channel {
    _channel = channel;
    self.title = self.channel.friendlyName;
    self.channel.delegate = self;
    [self loadMessages];
    
    /*
    NSArray *array = [NSMutableArray arrayWithArray:@[@"One d f asdf as df asd fa sdf a sdf ads f sadf a sdf a sdf asd f asdf asd f asdf as df", @"Two", @"*Mario Celli", @"*Hello"]];
    
    NSArray *reversed = [[array reverseObjectEnumerator] allObjects];
    self.chatEntries = [[NSMutableArray alloc] initWithArray:reversed];
    
    [self.tableView reloadData];
     */
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TMMessage *message = [self.messages objectAtIndex:indexPath.row];
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:ChatCellIdentifier forIndexPath:indexPath];
    
    ChatTableCell *chatCell = (ChatTableCell *)cell;
    chatCell.user = message.author;
    chatCell.date = [NSDate dateWithISO8601String:message.timestamp];
    chatCell.message = message.body;
    
    cell.transform = self.tableView.transform;
    
    return cell;
}

- (void)didPressRightButton:(id)sender {
    [self.textView refreshFirstResponder];
    [self sendMessage: [self.textView.text copy]];
    [super didPressRightButton:sender];
}

#pragma mark Chat Service
- (void)sendMessage: (NSString *)inputMessage {
    TMMessage *message = [self.channel.messages createMessageWithBody:inputMessage];
    [self.channel.messages sendMessage:message
                            completion:^(TMResultEnum result) {
                                if (result == TMResultFailure) {
                                    NSLog(@"send message error");
                                }
                            }];
}



- (void)addMessages:(NSArray<TMMessage *> *)messages {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0
                                                inSection:0];
    UITableViewScrollPosition scrollPosition = self.inverted ? UITableViewScrollPositionBottom : UITableViewScrollPositionTop;

    [self.messages addObjectsFromArray:messages];
    [self sortMessages];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        if (self.messages.count > 0) {
            [self scrollToBottomMessage];
        }
    });
    /*[self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationRight];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:scrollPosition animated:YES];*/
}

- (void)sortMessages {
    [self.messages sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"timestamp"
                                                                      ascending:NO]]];
}

- (void)scrollToBottomMessage {
    if (self.messages.count == 0) {
        return;
    }
    
    NSIndexPath *bottomMessageIndex = [NSIndexPath indexPathForRow:[self.tableView numberOfRowsInSection:0] - 1
                                                         inSection:0];
    [self.tableView scrollToRowAtIndexPath:bottomMessageIndex
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:NO];
}

- (void)loadMessages {
    [self.messages removeAllObjects];
    [self addMessages:self.channel.messages.allObjects];
}

#pragma mark - TMMessage delegate

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client
                  channel:(TMChannel *)channel
             messageAdded:(TMMessage *)message {
    [self addMessages:@[message]];
}
@end
