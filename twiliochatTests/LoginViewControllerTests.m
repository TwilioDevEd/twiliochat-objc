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
- (BOOL)showError:(NSString *)message;
@end

@interface LoginViewControllerTests : XCTestCase
@property (strong, nonatomic) id viewControllerMock;
@property (strong, nonatomic) id messagingManagerMock;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *fullName;
@property (copy, nonatomic) NSString *email;
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

- (void)testEmptyUsernameError {
  [self.viewControllerMock usernameTextField].text = @"";
  [self runUpEmptyFieldTest];
}

- (void)runUpEmptyFieldTest {
  OCMExpect([self.viewControllerMock showError:@"All fields are required"]);
  
  
  [[self.viewControllerMock loginButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
  
  OCMVerifyAll(self.messagingManagerMock);
  OCMVerifyAll(self.viewControllerMock);
}

- (void)testLoginUser {
  id handler = [OCMArg invokeBlockWithArgs:OCMOCK_VALUE((BOOL){YES}), [OCMArg defaultValue], nil];
  OCMExpect([self.messagingManagerMock loginWithUsername:self.username
                                                password:self.password
                                              completion:handler]);
  OCMExpect([self.messagingManagerMock presentRootViewController]);
  
  [[self.viewControllerMock loginButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
  
  OCMVerifyAll(self.messagingManagerMock);
}

@end
