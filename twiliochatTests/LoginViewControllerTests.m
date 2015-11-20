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
@property (strong, nonatomic) id viewControllerMock;
@property (strong, nonatomic) id messagingManagerMock;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@end

@implementation LoginViewControllerTests

- (void)setUp {
    [super setUp];
    
    self.messagingManagerMock = OCMClassMock([IPMessagingManager class]);
    OCMStub([self.messagingManagerMock sharedManager]).andReturn(self.messagingManagerMock);
   
    self.username = @"hello";
    self.password = @"123";
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    LoginViewController *viewController = (LoginViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    [viewController loadView];
    
    self.viewControllerMock = OCMPartialMock(viewController);
    
    [self.viewControllerMock usernameTextField].text = self.username;
    [self.viewControllerMock passwordTextField].text = self.password;
}

- (void)tearDown {
    [super tearDown];
    [self.viewControllerMock stopMocking];
}

- (void)testRegisterUser {
    id handler = [OCMArg invokeBlockWithArgs:OCMOCK_VALUE((BOOL){YES}), [OCMArg defaultValue], nil];
    OCMExpect([self.messagingManagerMock registerWithUsername:self.username
                                                     password:self.password
                                                      handler:handler]);
    OCMExpect([self.messagingManagerMock presentRootViewController]);
    
    [[self.viewControllerMock createAccountButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    [[self.viewControllerMock loginButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerifyAll(self.messagingManagerMock);
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
