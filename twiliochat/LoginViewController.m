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
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) BOOL isSigningUp;
@property (strong, nonatomic) TextFieldFormHandler *textFieldFormHandler;

// Constraints
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullNameHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fullNameTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailTopConstraint;
@property (strong, nonatomic) NSArray *constraints;
@property (strong, nonatomic) NSArray *constraintValues;

@property (strong, nonatomic, readonly) NSString *createAccountButtonTitle;
@property (strong, nonatomic, readonly) NSString *loginButtonTitle;

@end

@implementation LoginViewController

#pragma mark - Initialization

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isSigningUp = NO;
    [self.activityIndicator stopAnimating];
    
    [self initializeConstraints];
    [self initializeTextFields];
    [self refreshSignUpControls];
}

- (void)initializeTextFields {
    self.textFieldFormHandler = [[TextFieldFormHandler alloc] initWithTextFields:@[self.usernameTextField,
                                                                                   self.passwordTextField,
                                                                                   self.fullNameTextField,
                                                                                   self.emailTextField]
                                                                    topContainer:self.view];
    self.textFieldFormHandler.delegate = self;
}

- (void)initializeConstraints {
    self.constraints = @[self.fullNameHeightConstraint,
                         self.fullNameTopConstraint,
                         self.emailHeightConstraint,
                         self.emailTopConstraint];
    
    NSMutableArray *values = [NSMutableArray array];
    [self.constraints enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLayoutConstraint *constraint = (NSLayoutConstraint *)obj;
        [values addObject:[NSNumber numberWithFloat:constraint.constant]];
    }];
    self.constraintValues = [NSArray arrayWithArray:values];
}

- (void)refreshSignUpControls {
    [self.createAccountButton setTitle:self.createAccountButtonTitle forState:UIControlStateNormal];
    [self.loginButton setTitle:self.loginButtonTitle forState:UIControlStateNormal];
    
    self.textFieldFormHandler.lastTextField = self.isSigningUp? nil : self.passwordTextField;
    
    [self.constraints enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLayoutConstraint *constraint = (NSLayoutConstraint *)obj;
        constraint.constant = self.isSigningUp? [(NSNumber *)self.constraintValues[idx] floatValue] : 0.f;
    }];
    
    [self resetFirstResponderOnSignUpModeChange];
}

- (NSString *)createAccountButtonTitle {
    return self.isSigningUp? @"Back to login" : @"Create account";
}

- (NSString *)loginButtonTitle {
    return self.isSigningUp? @"Register" : @"Login";
}


- (void)resetFirstResponderOnSignUpModeChange {
    [self.view layoutSubviews];
    NSInteger index = self.textFieldFormHandler.firstResponderIndex;
    
    if (index != NSNotFound) {
        if (index > 1) {
            [self.textFieldFormHandler setFirstResponderAtIndex:1];
        }
        else {
            [self.textFieldFormHandler performScroll];
        }
    }
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
    [self signUpOrLoginUser];
}

- (IBAction)createAccountButtonTouched:(UIButton *)sender {
    [self toggleSignUpMode];
}

#pragma mark - TextFieldFormHandlerDelegate

- (void)textFieldFormHandlerDoneEnteringData:(TextFieldFormHandler *)handler {
    [self signUpOrLoginUser];
}

#pragma mark - Login

- (void)toggleSignUpMode {
    self.isSigningUp = !self.isSigningUp;
    [self refreshSignUpControls];
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
    if (self.usernameTextField.text.length && self.passwordTextField.text.length) {
        if (self.isSigningUp) {
            if (self.fullNameTextField.text.length && self.emailTextField.text.length) {
                return YES;
            }
        }
        else {
            return YES;
        }
    }
    [self showError:@"All fields are required"];
    return NO;
}

#pragma mark - UITextFieldDelegate

- (void)doneEnteringData {
    [self signUpOrLoginUser];
}

#pragma mark - Style

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
