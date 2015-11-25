#import <Parse/Parse.h>
#import "ForgotPasswordViewController.h"
#import "AlertDialogController.h"

@interface ForgotPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@end

@implementation ForgotPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.emailTextField.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)validateUserData {
    if (![self.emailTextField.text isEqualToString:@""]) {
        return YES;
    }
    [AlertDialogController showAlertWithMessage:@"Your email is required"
                                         title:nil
                                     presenter:self];
    return NO;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self startPasswordRecoveryProccess];
    [textField resignFirstResponder];
    return YES;
}

- (void)startPasswordRecoveryProccess {
    if ([self validateUserData]) {
        [PFUser requestPasswordResetForEmailInBackground:self.emailTextField.text];
        [AlertDialogController showAlertWithMessage:@"We've sent you an email with further instructions"
                                              title:nil
                                          presenter:self
                                            handler:^{
                                                [self performSegueWithIdentifier:@"BackToLogin"
                                                                          sender:self];
                                            }];
    }
}

- (IBAction)sendButtonTouched:(id)sender {
    [self startPasswordRecoveryProccess];
}

#pragma mark - Style

- (IBAction)backgroundTap:(id)sender {
    [self.emailTextField resignFirstResponder];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return UIInterfaceOrientationMaskAll;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return UIInterfaceOrientationUnknown;
    }
    return UIInterfaceOrientationPortrait;
}


@end
