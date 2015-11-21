#import <XCTest/XCTest.h>
#import <Parse/Parse.h>
#import <OCMock/OCMock.h>
#import "LoginViewController.h"
#import "IPMessagingManager.h"

@interface LoginViewController (Test)
@property (weak, nonatomic) UITextField *usernameTextField;
@property (weak, nonatomic) UITextField *passwordTextField;
@property (weak, nonatomic) UITextField *fullNameTextField;
@property (weak, nonatomic) UITextField *emailTextField;
@property (weak, nonatomic) UIButton *loginButton;
@property (weak, nonatomic) UIButton *createAccountButton;
- (BOOL)showAlertWithMessage:(NSString *)message;
@end

@interface LoginViewControllerTests : XCTestCase
@property (strong, nonatomic) id viewControllerMock;
@property (strong, nonatomic) id messagingManagerMock;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *fullName;
@property (strong, nonatomic) NSString *email;
@end

@implementation LoginViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.messagingManagerMock = OCMClassMock([IPMessagingManager class]);
    OCMStub([self.messagingManagerMock sharedManager]).andReturn(self.messagingManagerMock);
   
    self.username = @"hello";
    self.password = @"123";
    self.fullName = @"Name";
    self.email = @"email@domain.com";
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LoginViewController *viewController = (LoginViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [viewController loadView];
    
    self.viewControllerMock = OCMPartialMock(viewController);
    
    [self.viewControllerMock usernameTextField].text = self.username;
    [self.viewControllerMock passwordTextField].text = self.password;
    [self.viewControllerMock fullNameTextField].text = self.fullName;
    [self.viewControllerMock emailTextField].text = self.email;
}

- (void)tearDown {
    [super tearDown];
    [self.viewControllerMock stopMocking];
    [self.messagingManagerMock stopMocking];
}

- (void)testRegisterUser {
    id handler = [OCMArg invokeBlockWithArgs:OCMOCK_VALUE((BOOL){YES}), [OCMArg defaultValue], nil];
    OCMExpect([self.messagingManagerMock registerWithUsername:self.username
                                                     password:self.password
                                                     fullName:self.fullName
                                                        email:self.email
                                                      handler:handler]);
    OCMExpect([self.messagingManagerMock presentRootViewController]);
    
    [[self.viewControllerMock createAccountButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    [[self.viewControllerMock loginButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerifyAll(self.messagingManagerMock);
}

- (void)testEmptyUsernameError {
    [self.viewControllerMock usernameTextField].text = nil;
    [self runUpEmptyFieldTest];
}

- (void)testEmptyPasswordError {
    [self.viewControllerMock passwordTextField].text = nil;
    [self runUpEmptyFieldTest];
}

- (void)testEmptyFullNameError {
    [self.viewControllerMock fullNameTextField].text = nil;
    [self runUpEmptyFieldTest];
}

- (void)testEmptyEmailError {
    [self.viewControllerMock emailTextField].text = nil;
    [self runUpEmptyFieldTest];
}

- (void)runUpEmptyFieldTest {
    OCMExpect([self.viewControllerMock showAlertWithMessage:@"All fields are required"]);
    
    
    [[self.viewControllerMock createAccountButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    [[self.viewControllerMock loginButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerifyAll(self.messagingManagerMock);
    OCMVerifyAll(self.viewControllerMock);
}

- (void)testLoginUser {
    id handler = [OCMArg invokeBlockWithArgs:OCMOCK_VALUE((BOOL){YES}), [OCMArg defaultValue], nil];
    OCMExpect([self.messagingManagerMock loginWithUsername:self.username
                                                  password:self.password
                                                   handler:handler]);
    OCMExpect([self.messagingManagerMock presentRootViewController]);
    
    [[self.viewControllerMock loginButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerifyAll(self.messagingManagerMock);
}

@end
