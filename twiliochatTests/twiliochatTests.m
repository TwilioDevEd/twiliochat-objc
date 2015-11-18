#import <XCTest/XCTest.h>
#import "LoginViewController.h"
#import <Parse/Parse.h>
#import <OCMock/OCMock.h>

@interface LoginViewController (Test)
@property (weak, nonatomic) UITextField *usernameTextField;
@property (weak, nonatomic) UITextField *passwordTextField;
@property (weak, nonatomic) UIButton *loginButton;
@property (weak, nonatomic) UIButton *createAccountButton;
@end

@interface twiliochatTests : XCTestCase

@end

@implementation twiliochatTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testRegisterUser {
    id pfUserMock = OCMClassMock([PFUser class]);
    
    OCMStub([pfUserMock user]).andReturn((PFUser *)pfUserMock);
    
    OCMStub([pfUserMock signUpInBackgroundWithBlock:[OCMArg any]]);
    OCMStub([pfUserMock setUsername:[OCMArg isKindOfClass:[NSString class]]]);
    OCMStub([pfUserMock setPassword:[OCMArg isKindOfClass:[NSString class]]]);

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LoginViewController *viewController = (LoginViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [viewController loadView];
    
    NSString *username = @"hello";
    NSString *password = @"123";
    
    [viewController.createAccountButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    viewController.usernameTextField.text = username;
    viewController.passwordTextField.text = password;
    [viewController.loginButton sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerify([pfUserMock signUpInBackgroundWithBlock:[OCMArg any]]);
    OCMVerify([pfUserMock setUsername:username]);
    OCMVerify([pfUserMock setPassword:password]);
}

@end
