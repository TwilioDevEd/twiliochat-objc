#import "MainChatViewController.h"

@interface MainChatViewController ()
@property (weak, nonatomic) IBOutlet UIBarButtonItem *revealButtonItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *chatEntries;

@end

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

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.estimatedRowHeight = 70;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
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
        cell = [tableView dequeueReusableCellWithIdentifier:@"chatStatusCell" forIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell.contentView viewWithTag:200];
        label.text = entry;
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"chatEntryCell" forIndexPath:indexPath];
        
        ChatTableCell *chatCell = (ChatTableCell *)cell;
        chatCell.user = [PFUser currentUser].username;
        chatCell.date = [NSDate date];
        chatCell.message = entry;
    }
    
    return cell;
}

@end
