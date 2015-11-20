#import <XCTest/XCTest.h>
#import <Parse/Parse.h>
#import <OCMock/OCMock.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>
#import "IPMessagingManager.h"
#import "AppDelegate.h"
#import "LoginViewController.h"

@interface LoginViewController (Test)
@property (weak, nonatomic) UITextField *usernameTextField;
@property (weak, nonatomic) UITextField *passwordTextField;
@property (weak, nonatomic) UIButton *loginButton;
@property (weak, nonatomic) UIButton *createAccountButton;
@end

@interface IPMessagingManagerLoginTests : XCTestCase
@property (strong, nonatomic) id pfCloudMock;
@property (strong, nonatomic) id pfUserMock;
@property (strong, nonatomic) id clientMock;
@property (strong, nonatomic) IPMessagingManager *messagingManager;
@property (strong, nonatomic) NSString *username;
@property (strong, nonatomic) NSString *password;
@property (strong, nonatomic) NSString *token;
@end

@implementation IPMessagingManagerLoginTests

- (void)setUp {
    [super setUp];
    
    self.pfUserMock = OCMClassMock([PFUser class]);
    self.pfCloudMock = OCMClassMock([PFCloud class]);
    self.clientMock = OCMClassMock([TwilioIPMessagingClient class]);
    self.messagingManager = [IPMessagingManager sharedManager];
    
    self.username = @"hello";
    self.password = @"123";
    
    self.token = @"test-token";
    OCMExpect([self.clientMock ipMessagingClientWithToken:self.token delegate:nil]).andReturn(self.clientMock);
}

- (void)tearDown {
    [super tearDown];
    [self.pfCloudMock stopMocking];
    [self.pfUserMock stopMocking];
    [self.clientMock stopMocking];
}

- (void)testRegisterUser {
    [self prepareRegistrationWithSuccessStatus:YES];
    [self.messagingManager registerWithUsername:self.username
                                       password:self.password
                                        handler:^(BOOL succeeded, NSError *error) {
                                            XCTAssertTrue(succeeded, @"Registration should be successful");
                                        }];
    OCMVerifyAll(self.pfUserMock);
}

- (void)testFailedRegisterUser {
    [self prepareRegistrationWithSuccessStatus:NO];
    [self.messagingManager registerWithUsername:self.username
                                       password:self.password
                                        handler:^(BOOL succeeded, NSError *error) {
                                            XCTAssertFalse(succeeded, @"Registration should be successful");
                                        }];
    OCMVerifyAll(self.pfUserMock);
    OCMVerifyAll(self.clientMock);
}

- (void)prepareRegistrationWithSuccessStatus:(BOOL)status {
    OCMStub([self.pfUserMock user]).andReturn(self.pfUserMock);
    
    id arg = [OCMArg invokeBlockWithArgs:OCMOCK_VALUE((BOOL){status}), [OCMArg defaultValue], nil];
    OCMExpect([self.pfUserMock signUpInBackgroundWithBlock:arg]);
    OCMExpect([self.pfUserMock setUsername:self.username]);
    OCMExpect([self.pfUserMock setPassword:self.password]);
    
    if(status) {
        [self expectClientSetup];
    }
}

- (void)expectClientSetup {
    NSArray *serviceData = @[@{@"token": self.token}];
    /*id cloudBlock = [OCMArg invokeBlockWithArgs:serviceData, [OCMArg defaultValue], nil];
    OCMExpect([self.pfCloudMock callFunctionInBackground:@"token" withParameters:[OCMArg any] block:cloudBlock]);*/
}

- (void)testLoginUser {
    /*[self prepareLoginWithSuccessStatus:YES];
    [self.messagingManager loginWithUsername:self.username
                                    password:self.password
                                     handler:^(BOOL succeeded, NSError *error) {
                                         XCTAssertTrue(succeeded, @"Login should be successful");
                                     }];
    OCMVerifyAll(self.pfUserMock);*/
}

- (void)testFailedLoginUser {
   /* [self prepareLoginWithSuccessStatus:NO];
    [self.messagingManager loginWithUsername:self.username
                                    password:self.password
                                     handler:^(BOOL succeeded, NSError *error) {
                                         XCTAssertNotNil(error, @"Login should end up in error");
                                     }];
    OCMVerifyAll(self.pfUserMock);
    OCMVerifyAll(self.clientMock);*/
}

- (void)prepareLoginWithSuccessStatus:(BOOL)status {
    /*id arg = nil;
    
    if(status) {
        arg = [OCMArg invokeBlockWithArgs:self.pfUserMock, [OCMArg defaultValue], nil];
        [self expectClientSetup];
    }
    else {
        NSError *error = [NSError errorWithDomain:@"" code:-1000 userInfo:nil];
        arg = [OCMArg invokeBlockWithArgs:[OCMArg defaultValue], error, nil];
    }
    OCMExpect([self.pfUserMock logInWithUsernameInBackground:self.username password:self.password block:arg]);*/
}

@end
