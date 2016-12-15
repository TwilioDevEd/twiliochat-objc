#import <TwilioChatClient/TwilioChatClient.h>
#import "LoginViewController.h"
#import "MessagingManager.h"
#import "AlertDialogController.h"
#import "defines.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) TextFieldFormHandler *textFieldFormHandler;

@end

@implementation LoginViewController

#pragma mark - Initialization

- (void)viewDidLoad {
  [super viewDidLoad];
  [self.activityIndicator stopAnimating];
  
  [self initializeTextFields];
}

- (void)initializeTextFields {
  self.textFieldFormHandler = [[TextFieldFormHandler alloc]
                               initWithTextFields:@[self.usernameTextField]
                               topContainer:self.view];
  self.textFieldFormHandler.delegate = self;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  [self.textFieldFormHandler cleanUp];
}

#pragma mark - Actions

- (IBAction)loginButtonTouched:(UIButton *)sender {
  [self loginUser];
}

#pragma mark - TextFieldFormHandlerDelegate

- (void)textFieldFormHandlerDoneEnteringData:(TextFieldFormHandler *)handler {
  [self loginUser];
}

#pragma mark - Login

- (void)loginUser {
  if ([self validateUserData]) {
    self.view.userInteractionEnabled = NO;
    [self.activityIndicator startAnimating];
    MessagingManager *manager = [MessagingManager sharedManager];
    [manager loginWithUsername:self.usernameTextField.text
                    completion:^(BOOL succeeded, NSError *error) {
                      [self handleResponse:succeeded error:error];
                    }];
  }
}

- (void)handleResponse:(BOOL)succeeded error:(NSError *)error {
  [self.activityIndicator stopAnimating];
  if (!succeeded) {
    [self showError:[error localizedDescription]];
    [self.activityIndicator stopAnimating];
  }
  self.view.userInteractionEnabled = YES;
}

- (void)showError:(NSString *)message {
  [AlertDialogController showAlertWithMessage:message
                                        title:nil
                                    presenter:self];
}

- (BOOL)validateUserData {
  if (self.usernameTextField.text.length) {
    return YES;
  }
  [self showError:@"All fields are required"];
  return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

SINGLE_ORIENTATON_ON_IPHONE (Portrait)

@end
