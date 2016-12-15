#import <SWRevealViewController/SWRevealViewController.h>
#import "MenuViewController.h"
#import "MenuTableCell.h"
#import "InputDialogController.h"
#import "MainChatViewController.h"
#import "MessagingManager.h"
#import "AlertDialogController.h"
#import "ChannelManager.h"
#import "SessionManager.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) TWMChannel *recentlyAddedChannel;
@end

static NSString * const TWCOpenChannelSegue = @"OpenChat";
static NSInteger const TWCRefreshControlXOffset = 120;


@implementation MenuViewController

#pragma mark Initialization

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home-bg"]];
  bgImage.frame = self.tableView.frame;
  self.tableView.backgroundView = bgImage;
  
  self.usernameLabel.text = [SessionManager getUsername];
  
  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.tableView addSubview:self.refreshControl];
  [self.refreshControl addTarget:self
                          action:@selector(refreshChannels)
                forControlEvents:UIControlEventValueChanged];
  self.refreshControl.tintColor = [UIColor whiteColor];
  
  CGRect frame = self.refreshControl.frame;
  frame.origin.x = CGRectGetMinX(frame) - TWCRefreshControlXOffset;
  self.refreshControl.frame = frame;
  
  [ChannelManager sharedManager].delegate = self;
  [self reloadChannelList];
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

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  TWMChannel *channel = [[ChannelManager sharedManager].channels objectAtIndex:indexPath.row];
  return channel != [ChannelManager sharedManager].generalChannel;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    TWMChannel *channel = [[ChannelManager sharedManager].channels objectAtIndex:indexPath.row];
    [channel destroyWithCompletion:^(TWMResult *result) {
      if ([result isSuccessful]) {
        [tableView reloadData];
      }
      else {
        [AlertDialogController showAlertWithMessage:@"You can not delete this channel" title:nil presenter:self];
      }
    }];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self performSegueWithIdentifier:TWCOpenChannelSegue sender:indexPath];
}

#pragma mark - Internal methods

- (UITableViewCell *)loadingCellForTableView:(UITableView *)tableView {
  return [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
}

- (UITableViewCell *)channelCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath {
  MenuTableCell *menuCell = (MenuTableCell *)[tableView dequeueReusableCellWithIdentifier:@"channelCell" forIndexPath:indexPath];
  
  TWMChannel *channel = [[ChannelManager sharedManager].channels objectAtIndex:indexPath.row];
  NSString *friendlyName = channel.friendlyName;
  if (channel.friendlyName.length == 0) {
    friendlyName = @"(no friendly name)";
  }
  menuCell.channelName = friendlyName;
  
  return menuCell;
}

- (void)reloadChannelList {
  [self.tableView reloadData];
  [self.refreshControl endRefreshing];
}

- (void)refreshChannels {
  [self.refreshControl beginRefreshing];
  [self reloadChannelList];
}

- (void)deselectSelectedChannel {
  NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];

  if (selectedRow) {
    [self.tableView deselectRowAtIndexPath:selectedRow animated:YES];
  }
}

#pragma mark - Channel

- (void)createNewChannelDialog {
  [InputDialogController showWithTitle:@"New Channel"
                               message:@"Enter a name for this channel."
                           placeholder:@"Name"
                             presenter:self handler:^(NSString *text) {
                               [[ChannelManager sharedManager] createChannelWithName:text completion:^(BOOL success, TCHChannel *channel) {
                                 if (success) {
                                   [self refreshChannels];
                                 }
                               }];
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
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
    message:@"You are about to Logout." preferredStyle:UIAlertControllerStyleAlert];
  
  UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
    style:UIAlertActionStyleCancel handler:nil];

  UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"Confirm"
    style:UIAlertActionStyleDefault
    handler:^(UIAlertAction *action) {
      [self logOut];
    }];

  [alert addAction:cancelAction];
  [alert addAction:confirmAction];
  [self presentViewController:alert animated:YES completion:nil];
}

- (void)logOut {
  [[MessagingManager sharedManager] logout];
  [[MessagingManager sharedManager] presentRootViewController];
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
  if ([segue.identifier isEqualToString:TWCOpenChannelSegue]) {
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
