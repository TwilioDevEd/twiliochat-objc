#import <Parse/Parse.h>
#import <SWRevealViewController/SWRevealViewController.h>
#import "MenuViewController.h"
#import "MenuTableCell.h"
#import "InputDialogController.h"
#import "MainChatViewController.h"
#import "IPMessagingManager.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *channels;
@end

@implementation MenuViewController

#pragma mark Initialization

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

#pragma mark - Channel

- (void)createNewChannel {
    [InputDialogController showWithTitle:@"New Channel"
                                 message:@"Enter a name for this channel."
                             placeholder:@"Name"
                               presenter:self handler:^(NSString *text) {
                                   [self.channels addObject:text];
                                   [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow: self.channels.count - 1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                               }];
}

#pragma mark - Logout

- (void)promtpLogout {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"You are about to Logout."
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *action) {
                                                           [self logOut];
                                                       }];
    
    [alert addAction:defaultAction];
    [alert addAction:confirmAction];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) logOut {
    [PFUser logOut];
    [[IPMessagingManager sharedManager] presentRootViewController];
}

#pragma mark Actions

- (IBAction)logoutButtonTouched:(UIButton *)sender {
    [self promtpLogout];
}

- (IBAction)newChannelButtonTouched:(UIButton *)sender {
    [self createNewChannel];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

}

#pragma mark Style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
