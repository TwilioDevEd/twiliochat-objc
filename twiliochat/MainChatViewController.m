#import <Parse/Parse.h>
#import "MainChatViewController.h"
#import "SWRevealViewController.h"
#import "ChatTableCell.h"

@interface MainChatViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;

@property (strong, nonatomic) NSMutableArray *chatEntries;

@end

static NSString *ChatCellIdentifier = @"ChatTableCell";
static NSString *ChatStatusCellIdentifier = @"ChatStatusTableCell";

@implementation MainChatViewController

#pragma mark Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    SWRevealViewController *revealViewController = self.revealViewController;
    
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
    self.inverted = NO;
    
    UINib *cellNib = [UINib nibWithNibName:ChatCellIdentifier bundle:nil];
    [self.tableView registerNib:cellNib
         forCellReuseIdentifier:ChatCellIdentifier];
    
    UINib *cellStatusNib = [UINib nibWithNibName:ChatStatusCellIdentifier bundle:nil];
    [self.tableView registerNib:cellStatusNib
         forCellReuseIdentifier:ChatStatusCellIdentifier];
    
    self.tableView.estimatedRowHeight = 70;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

-(void)setChannel:(NSString *)channel {
    self.title = channel;
    self.chatEntries = [NSMutableArray arrayWithArray:@[@"One d f asdf as df asd fa sdf a sdf ads f sadf a sdf a sdf asd f asdf asd f asdf as df", @"Two", @"*Mario Celli", @"*Hello"]];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chatEntries.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *entry = [self.chatEntries objectAtIndex:indexPath.row];
    UITableViewCell *cell = nil;
    
    if ([entry hasPrefix:@"*"]) {
        cell = [tableView dequeueReusableCellWithIdentifier:ChatStatusCellIdentifier forIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:200];
        label.text = entry;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:ChatCellIdentifier forIndexPath:indexPath];
        
        ChatTableCell *chatCell = (ChatTableCell *)cell;
        chatCell.user = [PFUser currentUser].username;
        chatCell.date = [NSDate date];
        chatCell.message = entry;
    }
    
    return cell;
}

#pragma mark Chat Service
-(void)addMessage:(NSString *)message {
    self.messageTextField.text = [NSString string];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.chatEntries.count
                                                inSection:0];
    [self.chatEntries addObject:message];
    
    [self.tableView insertRowsAtIndexPaths:@[indexPath]
                          withRowAnimation:UITableViewRowAnimationRight];
}

#pragma mark Actions

- (IBAction)sendButtonTapped:(UIButton *)sender {
    [self addMessage:self.messageTextField.text];
}

@end
