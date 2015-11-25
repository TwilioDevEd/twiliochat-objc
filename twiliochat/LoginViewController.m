#import <Parse/Parse.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>
#import "LoginViewController.h"
#import "IPMessagingManager.h"
#import "AlertDialogController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *fullNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic) BOOL isSigningUp;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (nonatomic) NSInteger keyboardSize;
@property (nonatomic) NSInteger animationOffset;
@property (strong, nonatomic) NSArray *textFields;
@property (weak, nonatomic) UITextField *currentTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullNameHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullNameTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailTopConstraint;
@property (strong, nonatomic) NSArray *constraints;
@property (strong, nonatomic) NSArray *constraintValues;

@end

@implementation LoginViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isSigningUp = NO;
    [self.activityIndicator stopAnimating];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    self.constraints = @[self.fullNameHeightConstraint,
                         self.fullNameTopConstraint,
                         self.emailHeightConstraint,
                         self.emailTopConstraint];
    [self storeConstraintValues];
    [self initializeTextFields];
}

- (void)initializeTextFields {
    self.textFields = @[self.usernameTextField,
                        self.passwordTextField,
                        self.fullNameTextField,
                        self.emailTextField];
    
    [self.textFields enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UITextField *textField = (UITextField *)obj;
        textField.delegate = self;
    }];
}

- (void)storeConstraintValues {
    NSMutableArray *values = [NSMutableArray array];
    [self.constraints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLayoutConstraint *constraint = (NSLayoutConstraint *)obj;
        [values addObject:[NSNumber numberWithFloat:constraint.constant]];
        constraint.constant = 0.f;
    }];
    self.constraintValues = [NSArray arrayWithArray:values];
}

- (void)hideSignInControls {
    [self.createAccountButton setTitle:@"Create account" forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    
    [self setTextField:self.passwordTextField returnKeyType:UIReturnKeyDone];
    
    [self.constraints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLayoutConstraint *constraint = (NSLayoutConstraint *)obj;
        constraint.constant = 0.f;
    }];
}

- (void)showSignInControls {
    [self.createAccountButton setTitle:@"Back to login" forState:UIControlStateNormal];
    [self.loginButton setTitle:@"Register" forState:UIControlStateNormal];
    
    [self setTextField:self.passwordTextField returnKeyType:UIReturnKeyNext];
    
    [self.constraints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLayoutConstraint *constraint = (NSLayoutConstraint *)obj;
        constraint.constant = [(NSNumber *)[self.constraintValues objectAtIndex:idx] floatValue];
    }];
}

- (void)setTextField:(UITextField *)textField returnKeyType:(UIReturnKeyType)type {
    if ([self.passwordTextField isFirstResponder]) {
        [self.passwordTextField resignFirstResponder];
        self.passwordTextField.returnKeyType = type;
        [self.passwordTextField becomeFirstResponder];
    }
    else {
        self.passwordTextField.returnKeyType = type;
    }
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

#pragma mark - Actions

- (IBAction)loginButtonTouched:(UIButton *)sender {
    [self signUpOrLoginUser];
}

- (IBAction)createAccountButtonTouched:(UIButton *)sender {
    [self toggleSignUpMode];
}

#pragma mark - Login

- (void)toggleSignUpMode {
    self.isSigningUp = !self.isSigningUp;
    if (self.isSigningUp) {
        [self showSignInControls];
    }
    else {
        [self hideSignInControls];
    }
}

- (void)signUpOrLoginUser {
    if ([self validateUserData]) {
        self.loginButton.enabled = NO;
        self.createAccountButton.enabled = NO;
        [self.activityIndicator startAnimating];
        
        if (self.isSigningUp) {
            [self registerUser];
        }
        else {
            [self loginUser];
        }
    }
}

- (void)registerUser {
    IPMessagingManager *manager = [IPMessagingManager sharedManager];
    
    [manager registerWithUsername:self.usernameTextField.text
                         password:self.passwordTextField.text
                         fullName:self.fullNameTextField.text
                            email:self.emailTextField.text
                          handler:^(BOOL succeeded, NSError *error) {
                              [self.activityIndicator stopAnimating];
                              if (succeeded) {
                                  [manager presentRootViewController];
                              }
                              else {
                                  NSLog(@"%@", error);
                                  [self showError:[error localizedDescription]];
                              }
                          }];
}

- (void)loginUser {
    IPMessagingManager *manager = [IPMessagingManager sharedManager];
    [manager loginWithUsername:self.usernameTextField.text
                      password:self.passwordTextField.text
                       handler:^(BOOL succeeded, NSError *error) {
                           [self.activityIndicator stopAnimating];
                           if (succeeded) {
                               [manager presentRootViewController];
                           }
                           else {
                               [self showError:@"Login failed, please verify your credentials"];
                           }
                       }];
}

- (void)showError:(NSString *)message {
    [AlertDialogController showAlertWithMessage:message
                                              title:nil
                                          presenter:self];
    self.loginButton.enabled = YES;
    self.createAccountButton.enabled = YES;
}

- (BOOL)validateUserData {
    if (![self.usernameTextField.text isEqualToString: @""] &&
        ![self.passwordTextField.text isEqualToString: @""]) {
        if (self.isSigningUp) {
            if (![self.fullNameTextField.text isEqualToString:@""] &&
                ![self.emailTextField.text isEqualToString:@""]) {
                return YES;
            }
        }
        else {
            return YES;
        }
    }
    [AlertDialogController showAlertWithMessage:@"Your email is required"
                                         title:nil
                                     presenter:self];
    return NO;
}

#pragma mark - Animation

- (void)moveScreenUp
{
    [self shiftScreenYPosition:-self.keyboardSize - self.animationOffset withDuration:0.30 curve: UIViewAnimationCurveEaseInOut];
}

- (void)moveScreenDown
{
    [self shiftScreenYPosition:0 withDuration:0.20 curve: UIViewAnimationCurveEaseInOut];
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

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger index = [self.textFields indexOfObject:textField];
    
    if (self.isSigningUp)
    {
        if (index == self.textFields.count - 1) {
            [self doneEnteringDataWithTextField:textField];
            return YES;
        }
    }
    else {
        if (index == 1) {
            [self doneEnteringDataWithTextField:textField];
            return YES;
        }
    }
    
    UITextField *nextTextField = (UITextField *)[self.textFields objectAtIndex:index + 1];
    [nextTextField becomeFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    CGFloat screenHeight = [[UIScreen mainScreen] bounds].size.height;
    CGFloat textFieldHeight = textField.superview.frame.size.height;
    CGFloat textFieldY = [textField.superview.superview convertPoint:textField.superview.frame.origin toView:self.view].y;
    self.animationOffset = -screenHeight + textFieldY + textFieldHeight;
    if (self.keyboardSize != 0) {
        [self moveScreenUp];
    }
    return YES;
}

- (void)doneEnteringDataWithTextField:(UITextField *)lastTextField {
    [lastTextField resignFirstResponder];
    [self signUpOrLoginUser];
    [self moveScreenDown];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    self.keyboardSize = MIN(keyboardSize.height, keyboardSize.width);
    [self moveScreenUp];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Style

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
    [self moveScreenDown];
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
