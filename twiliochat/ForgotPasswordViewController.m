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
    if (![self.emailTextField.text isEqualToString:@""]) {
        return YES;
    }
    [AlertDialogController showAlertWithMessage:@"Your email is required"
                                         title:nil
                                     presenter:self];
    return NO;
}

#pragma mark - UITextFieldDelegate

- (void)textFieldFormHandlerDoneEnteringData:(TextFieldFormHandler *)handler {
    [self startPasswordRecoveryProccess];
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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

SINGLE_ORIENTATON_ON_IPHONE (Portrait)

@end
