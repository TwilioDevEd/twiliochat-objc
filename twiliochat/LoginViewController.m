#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic) BOOL isSigningUp;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (nonatomic) NSInteger animationOffset;

@end

@implementation LoginViewController

#pragma mark Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isSigningUp = NO;
    self.usernameTextField.delegate = self;
    self.passwordTextField.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Actions

- (IBAction)loginButtonTouched:(UIButton *)sender {
    [self signUpOrLoginUser];
}

- (IBAction)createAccountButtonTouched:(UIButton *)sender {
    [self toggleSignUpMode];
}

#pragma mark Login

- (void)toggleSignUpMode {
    self.isSigningUp = !self.isSigningUp;
    if (self.isSigningUp) {
        [self.createAccountButton setTitle:@"Back to login" forState:UIControlStateNormal];
        [self.loginButton setTitle:@"Register" forState:UIControlStateNormal];
    }
    else {
        [self.createAccountButton setTitle:@"Create account" forState:UIControlStateNormal];
        [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    }
}

- (void)signUpOrLoginUser {
    if ([self validateUserData]) {
        self.loginButton.enabled = NO;
        self.createAccountButton.enabled = NO;
        
        if (self.isSigningUp) {
            [self registerUser];
        }
        else {
            [self loginUser];
        }
    }
}

- (void)registerUser {
    PFUser *user = [PFUser user];
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            [self performSegueWithIdentifier:@"ShowRevealController" sender:self];
        }
        else {
            [self showAlertWithMessage:@"Error while signing up"];
            self.loginButton.enabled = YES;
            self.createAccountButton.enabled = YES;
        }
    }];
}

- (void)loginUser {
    PFUser *user = [PFUser user];
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;
    
    [PFUser logInWithUsernameInBackground:self.usernameTextField.text
                                 password:self.passwordTextField.text
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            [self performSegueWithIdentifier:@"ShowRevealController" sender:self];
                                        }
                                        else {
                                            [self showAlertWithMessage:@"Login failed, please verify your credentials"];
                                            self.loginButton.enabled = YES;
                                            self.createAccountButton.enabled = YES;
                                        }
                                    }];
}

- (BOOL)validateUserData {
    if ([self.usernameTextField.text isEqualToString: @""] || [self.passwordTextField.text isEqualToString: @""] ) {
        [self showAlertWithMessage:@"Username name and Password are required"];
        return NO;
    }
    return YES;
}

#pragma mark Alerts

- (void)showAlertWithMessage: (NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark Animation

- (void)moveScreenUp
{
    [self shiftScreenYPosition:-self.animationOffset withDuration:0.30 curve: UIViewAnimationCurveLinear];
}

- (void)moveScreenDown
{
    [self shiftScreenYPosition:0 withDuration:0.20 curve: UIViewAnimationCurveLinear];
}

- (void)shiftScreenYPosition: (NSInteger)position withDuration: (CGFloat) duration curve: (UIViewAnimationCurve) curve {
    [UIView beginAnimations:@"moveUp" context:NULL];
    [UIView setAnimationCurve:curve];
    [UIView setAnimationDuration:duration];
    
    CGRect rect = self.view.frame;
    rect.origin.y = position;
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameTextField) {
        [self.passwordTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
        [self signUpOrLoginUser];
        [self moveScreenDown];
    }
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.animationOffset = MIN(keyboardSize.height, keyboardSize.width);
    [self moveScreenUp];
}

#pragma mark Screen Options

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
    [self moveScreenDown];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
