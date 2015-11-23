#import <Parse/Parse.h>
#import <SWRevealViewController/SWRevealViewController.h>
#import "MenuViewController.h"
#import "MenuTableCell.h"
#import "InputDialogController.h"
#import "MainChatViewController.h"
#import "IPMessagingManager.h"
#import "AlerDialogController.h"

@interface MenuViewController ()
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) TMChannels *channelsList;
@property (strong, nonatomic) NSMutableOrderedSet *channels;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

@property (strong, nonatomic) TMChannel *recentlyAddedChannel;
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
    
    TwilioIPMessagingClient *client = [[IPMessagingManager sharedManager] client];
    if (client) {
        client.delegate = self;
        [self populateChannels];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (!self.channels) {
        return 1;
    }
    
    return self.channels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if (!self.channels) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"loadingCell"];
    }
    else {
        MenuTableCell *menuCell = (MenuTableCell *)[tableView dequeueReusableCellWithIdentifier:@"channelCell" forIndexPath:indexPath];
        cell = menuCell;
        
        TMChannel *channel = [self.channels objectAtIndex:indexPath.row];
        NSString *nameLabel = channel.friendlyName;
        if (channel.friendlyName.length == 0) {
            nameLabel = @"(no friendly name)";
        }
        if (channel.type == TMChannelTypePrivate) {
            nameLabel = [nameLabel stringByAppendingString:@" (private)"];
        }
        menuCell.channelName = nameLabel;
    }
    
    [cell layoutIfNeeded];

    return cell;
}

- (void)populateChannels {
    self.channelsList = nil;
    self.channels = nil;
    [self.tableView reloadData];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[IPMessagingManager sharedManager] client] channelsListWithCompletion:^(TMResultEnum result, TMChannels *channelsList) {
            if (result == TMResultSuccess) {
                self.channelsList = channelsList;
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self.channelsList loadChannelsWithCompletion:^(TMResultEnum result) {
                        if (result == TMResultSuccess) {
                            self.channels = [[NSMutableOrderedSet alloc] init];
                            [self.channels addObjectsFromArray:[self.channelsList allObjects]];
                            [self sortChannels];
                            [NSThread sleepForTimeInterval:1.0f];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                                [self.refreshControl endRefreshing];
                            });
                        }
                        else {
                            //[DemoHelpers displayToastWithMessage:@"Channel list load failed." inView:self.view];
                        }
                    }];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"IP Messaging Demo" message:@"Failed to load channels." preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
                    [self presentViewController:alert animated:YES completion:nil];
                    
                    self.channelsList = nil;
                    [self.channels removeAllObjects];
                    
                    [self.tableView reloadData];
                });
            }
        }];
    });
}

#pragma mark - Internal methods

- (void)sortChannels {
    [self.channels sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"friendlyName"
                                                                      ascending:YES
                                                                       selector:@selector(localizedCaseInsensitiveCompare:)]]];
}

- (void)refreshChannels {
    [self.refreshControl beginRefreshing];
    [self populateChannels];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        TMChannel *channel = [self.channels objectAtIndex:indexPath.row];
        [channel destroyWithCompletion:^(TMResultEnum result) {
            if (result == TMResultSuccess) {
                [tableView reloadData];
            }
            else {
                [AlerDialogController showAlertWithMessage:@"You can not delete this channel" title:nil presenter:self];
            }
        }];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TMChannel *channel = [self.channels objectAtIndex:indexPath.row];
    UINavigationController *navigationController = (UINavigationController *) self.revealViewController.frontViewController;
    MainChatViewController *chatViewController = (MainChatViewController *) [navigationController visibleViewController];
    chatViewController.channel = channel;
    [self.revealViewController revealToggleAnimated:YES];
}

#pragma mark - Channel

- (void)createNewChannelDialog {
    [InputDialogController showWithTitle:@"New Channel"
                                 message:@"Enter a name for this channel."
                             placeholder:@"Name"
                               presenter:self handler:^(NSString *text) {
                                   [self createChannelWithName:text];
                               }];
}

- (void)createChannelWithName:(NSString *)name {
    [self.channelsList createChannelWithFriendlyName:name
                                                type:TMChannelTypePublic
                                          completion:^(TMResultEnum result, TMChannel *channel) {
                                              if (result == TMResultSuccess) {
                                                  [channel joinWithCompletion:^(TMResultEnum result) {
                                                      [channel setAttributes:@{@"owner": [[IPMessagingManager sharedManager] userIdentity]}
                                                                  completion:^(TMResultEnum result) {

                                                                  }];
                                                  }];
                                              }
                                              else {
                                                  NSLog(@"Error creating channel");
                                              }
                                          }];
}

#pragma mark - TwilioIPMessagingClientDelegate delegate

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client channelAdded:(TMChannel *)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.channels addObject:channel];
        NSLog(@"IPAttr: %@", channel.attributes);
        [self sortChannels];
        [self.tableView reloadData];
    });
}

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client channelChanged:(TMChannel *)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)ipMessagingClient:(TwilioIPMessagingClient *)client channelDeleted:(TMChannel *)channel {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.channels removeObject:channel];
        [self.tableView reloadData];
    });
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

}

#pragma mark Style

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


@end
