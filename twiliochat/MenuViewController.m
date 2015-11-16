#import "MenuViewController.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *channels;
@end

@implementation MenuViewController
- (IBAction)logoutButtonTouched:(UIButton *)sender {
    [PFUser logOut];
    
    [ViewControllerFlowManager showSessionBasedViewController];
}
- (IBAction)newChannelButtonTouched:(UIButton *)sender {
    [self createNewChannel];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect tableFrame = self.tableView.frame;

    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home-bg"]];
    [bgImage setFrame:tableFrame];
    self.tableView.backgroundView = bgImage;

    self.usernameLabel.text = [PFUser currentUser].username;
    self.channels = [NSMutableArray arrayWithArray:@[@"TNG-fans",@"San Diego Brewers",@"General chat"]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.channels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MenuTableCell *cell = (MenuTableCell *)[tableView dequeueReusableCellWithIdentifier:@"channelCell" forIndexPath:indexPath];
    
    NSString *channel = [self.channels objectAtIndex:indexPath.row];
    cell.channelName = channel;
    
    return cell;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)createNewChannel {
    [InputDialogController showWithTitle:@"New Channel"
                                 message:@"Enter a name for this channel."
                               presenter:self handler:^(NSString *text) {
                                   [self.channels addObject:text];
                                   [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow: self.channels.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                               }];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *channel = [self.channels objectAtIndex:indexPath.row];
    UINavigationController *navigationController = (UINavigationController *) self.revealViewController.frontViewController;
    MainChatViewController *chatViewController = (MainChatViewController *) [navigationController visibleViewController];
    chatViewController.channel = channel;
    [self.revealViewController revealToggleAnimated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

@end
