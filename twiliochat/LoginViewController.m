#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic) BOOL isSigningUp;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isSigningUp = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginButtonTouched:(UIButton *)sender {
    if (self.isSigningUp) {
        [self registerUser];
    }
}
- (IBAction)createAccountButtonTouched:(UIButton *)sender {
    [self toggleSignUpMode];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

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

- (void)registerUser {
    PFUser *user = [PFUser user];
    user.username = self.usernameTextField.text;
    user.password = self.passwordTextField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            //If success
        }
        else {
            //If any error
        }
    }];
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

@end
