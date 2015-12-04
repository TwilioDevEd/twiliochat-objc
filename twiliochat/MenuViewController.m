#import <Parse/Parse.h>
#import <SWRevealViewController/SWRevealViewController.h>
#import "MenuViewController.h"
#import "MenuTableCell.h"
#import "InputDialogController.h"
#import "MainChatViewController.h"
#import "IPMessagingManager.h"
#import "AlertDialogController.h"
#import "ChannelManager.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) TWMChannel *recentlyAddedChannel;
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
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self
                            action:@selector(refreshChannels)
                  forControlEvents:UIControlEventValueChanged];
    self.refreshControl.tintColor = [UIColor whiteColor];
    
    CGRect frame = self.refreshControl.frame;
    frame.origin.x -= 120;
    self.refreshControl.frame = frame;
    
    [ChannelManager sharedManager].delegate = self;
    [self populateChannels];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![ChannelManager sharedManager].channels) {
        return 1;
    }
    
    return [ChannelManager sharedManager].channels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (![ChannelManager sharedManager].channels) {
        cell = [self loadingCellForTableView:tableView];
    }
    else {
        cell = [self channelCellForTableView:tableView atIndexPath:indexPath];
    }
    [cell layoutIfNeeded];
    
    return cell;
}

#pragma mark - Internal methods

- (UITableViewCell *)loadingCellForTableView:(UITableView *)tableView {
    return [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
}

- (UITableViewCell *)channelCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
    MenuTableCell *menuCell = (MenuTableCell *)[tableView dequeueReusableCellWithIdentifier:@"channelCell" forIndexPath:indexPath];
    
    TWMChannel *channel = [[ChannelManager sharedManager].channels objectAtIndex:indexPath.row];
    NSString *nameLabel = channel.friendlyName;
    if (channel.friendlyName.length == 0) {
        nameLabel = @"(no friendly name)";
    }
    if (channel.type == TWMChannelTypePrivate) {
        nameLabel = [nameLabel stringByAppendingString:@" (private)"];
    }
    menuCell.channelName = nameLabel;
    
    return menuCell;
}

- (void)refreshChannels {
    [self.refreshControl beginRefreshing];
    [self populateChannels];
}

- (void)populateChannels {
    [[ChannelManager sharedManager] populateChannelsWithBlock:^(BOOL succeeded) {
        if (!succeeded) {
            [AlertDialogController showAlertWithMessage:@"Failed to load channels."
                                                  title:@"IP Messaging Demo"
                                              presenter:self];
        }
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    }];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    TWMChannel *channel = [[ChannelManager sharedManager].channels objectAtIndex:indexPath.row];
    return channel != [ChannelManager sharedManager].generalChatroom;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        TWMChannel *channel = [[ChannelManager sharedManager].channels objectAtIndex:indexPath.row];
        [channel destroyWithCompletion:^(TWMResult result) {
            if (result == TWMResultSuccess) {
                [tableView reloadData];
            }
            else {
                [AlertDialogController showAlertWithMessage:@"You can not delete this channel" title:nil presenter:self];
            }
        }];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"OpenChat" sender:indexPath];
}

#pragma mark - Channel

- (void)createNewChannelDialog {
    [InputDialogController showWithTitle:@"New Channel"
                                 message:@"Enter a name for this channel."
                             placeholder:@"Name"
                               presenter:self handler:^(NSString *text) {
                                   [[ChannelManager sharedManager] createChannelWithName:text block:nil];
                               }];
}

#pragma mark - TwilioIPMessagingClientDelegate delegate

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client channelAdded:(TWMChannel *)channel {
    [self.tableView reloadData];
}

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client channelChanged:(TWMChannel *)channel {
    [self.tableView reloadData];
}

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client channelDeleted:(TWMChannel *)channel {
    [self.tableView reloadData];
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
    [[IPMessagingManager sharedManager] logout];
    [[IPMessagingManager sharedManager] presentRootViewController];
}

#pragma mark Actions

- (IBAction)logoutButtonTouched:(UIButton *)sender {
    [self promtpLogout];
}

- (IBAction)newChannelButtonTouched:(UIButton *)sender {
    [self createNewChannelDialog];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"OpenChat"]) {
        NSIndexPath *indexPath = (NSIndexPath *)sender;
        
        TWMChannel *channel = [[ChannelManager sharedManager].channels objectAtIndex:indexPath.row];
        UINavigationController *navigationController = [segue destinationViewController];
        MainChatViewController *chatViewController = (MainChatViewController *)[navigationController visibleViewController];
        chatViewController.channel = channel;
    }
}

#pragma mark Style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
