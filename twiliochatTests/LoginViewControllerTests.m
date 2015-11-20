#import <XCTest/XCTest.h>
#import <Parse/Parse.h>
#import <OCMock/OCMock.h>
#import "LoginViewController.h"
#import "IPMessagingManager.h"

@interface LoginViewController (Test)
@property (weak, nonatomic) UITextField *usernameTextField;
@property (weak, nonatomic) UITextField *passwordTextField;
@property (weak, nonatomic) UIButton *loginButton;
@property (weak, nonatomic) UIButton *createAccountButton;
@end

@interface LoginViewControllerTests : XCTestCase
@property (strong, nonatomic) id pfUserMock;
@property (strong, nonatomic) id pfCloudMock;
@property (strong, nonatomic) id viewControllerMock;
@property (strong, nonatomic) id messagingManagerMock;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@end

@implementation LoginViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.pfUserMock = OCMClassMock([PFUser class]);
    self.pfCloudMock = OCMClassMock([PFCloud class]);
    self.messagingManagerMock = OCMClassMock([IPMessagingManager class]);
    OCMStub([self.messagingManagerMock presentRootViewController]);
   
    self.username = @"hello";
    self.password = @"123";
    
    // Create LoginViewController mock
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LoginViewController *viewController = (LoginViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [viewController loadView];
    
    self.viewControllerMock = OCMPartialMock(viewController);
    
    id cloudBlock = [OCMArg invokeBlockWithArgs:[OCMArg any], [OCMArg defaultValue], nil];
    OCMStub([self.pfCloudMock callFunctionInBackground:[OCMArg any] withParameters:[OCMArg any] block:cloudBlock]);
    OCMStub([self.pfCloudMock callFunctionInBackground:[OCMArg any] withParameters:[OCMArg any] block:cloudBlock]);
    
    [self.viewControllerMock usernameTextField].text = self.username;
    [self.viewControllerMock passwordTextField].text = self.password;
}

- (void)tearDown {
    [super tearDown];
    [self.pfUserMock stopMocking];
    [self.pfCloudMock stopMocking];
}

- (void)testRegisterUser {
    OCMStub([self.pfUserMock user]).andReturn(self.pfUserMock);
    
    id arg = [OCMArg invokeBlockWithArgs:OCMOCK_VALUE((BOOL){YES}), [OCMArg defaultValue], nil];
    OCMStub([self.pfUserMock signUpInBackgroundWithBlock:arg]);
    OCMStub([self.pfUserMock setUsername:[OCMArg isKindOfClass:[NSString class]]]);
    OCMStub([self.pfUserMock setPassword:[OCMArg isKindOfClass:[NSString class]]]);
    
    
    [[self.viewControllerMock createAccountButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    [[self.viewControllerMock loginButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerify([self.pfUserMock setUsername:self.username]);
    OCMVerify([self.pfUserMock setPassword:self.password]);
    OCMVerify([self.messagingManagerMock presentRootViewController]);
}

- (void)testLoginUser {
    id arg = [OCMArg invokeBlockWithArgs:[OCMArg any], [OCMArg defaultValue], nil];
    OCMStub([self.pfUserMock logInWithUsernameInBackground:self.username password:self.password block:arg]);
    
    [[self.viewControllerMock loginButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerify([self.messagingManagerMock presentRootViewController]);
}

@end
