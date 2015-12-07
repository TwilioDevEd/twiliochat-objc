#import <Parse/Parse.h>
#import "ForgotPasswordViewController.h"
#import "AlertDialogController.h"
#import "defines.h"

@interface ForgotPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (strong, nonatomic) TextFieldFormHandler *textFieldFormHandler;
@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.textFieldFormHandler = [[TextFieldFormHandler alloc] initWithTextFields:@[self.emailTextField]
                                                                  topContainer:self.view];
  self.textFieldFormHandler.delegate = self;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

- (BOOL)validateUserData {
  if (self.emailTextField.text.length) {
    return YES;
  }
  [AlertDialogController showAlertWithMessage:@"Your email is required"
                                        title:nil
                                    presenter:self];
  return NO;
}

#pragma mark - TextFieldFormHandlerDelegate

- (void)textFieldFormHandlerDoneEnteringData:(TextFieldFormHandler *)handler {
  [self startPasswordRecoveryProccess];
}

- (void)startPasswordRecoveryProccess {
  if ([self validateUserData]) {
    self.view.userInteractionEnabled = NO;
    
    [PFUser requestPasswordResetForEmailInBackground:self.emailTextField.text block:^(BOOL succeeded, NSError *error) {
      if (succeeded) {
        [AlertDialogController showAlertWithMessage:@"We've sent you an email with further instructions"
                                              title:nil
                                          presenter:self
                                            handler:^{
                                              [self performSegueWithIdentifier:@"BackToLogin"
                                                                        sender:self];
                                            }];
      }
      else {
        [AlertDialogController showAlertWithMessage:[error localizedDescription]
                                              title:nil
                                          presenter:self];
        self.view.userInteractionEnabled = YES;
      }
    }];
  }
}

- (IBAction)sendButtonTouched:(id)sender {
  [self startPasswordRecoveryProccess];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
  return UIStatusBarStyleLightContent;
}

SINGLE_ORIENTATON_ON_IPHONE (Portrait)

@end
