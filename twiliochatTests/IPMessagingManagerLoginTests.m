#import <XCTest/XCTest.h>
#import <Parse/Parse.h>
#import <OCMock/OCMock.h>
#import "IPMessagingManager.h"

@interface IPMessagingManager (Test)
- (void)connectClientWithCompletion:(void(^)(BOOL succeeded, NSError *error))handler;
@end

@interface IPMessagingManagerLoginTests : XCTestCase
@property (strong, nonatomic) id pfUserMock;
@property (strong, nonatomic) id messagingManagerMock;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *fullName;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *token;
@property (strong, nonatomic) NSError *error;
@end

@implementation IPMessagingManagerLoginTests

- (void)setUp {
  [super setUp];
  
  self.pfUserMock = OCMClassMock([PFUser class]);
  self.messagingManagerMock = OCMPartialMock([IPMessagingManager sharedManager]);
  
  self.username = @"hello";
  self.password = @"123";
  self.fullName = @"Name";
  self.email = @"email@domain.com";
  
  self.error = [NSError errorWithDomain:@"" code:400 userInfo:nil];
  
  self.token = @"test-token";
}

- (void)tearDown {
  [super tearDown];
  [self.pfUserMock stopMocking];
  [self.messagingManagerMock stopMocking];
}

- (void)testRegisterUser {
  [self prepareRegistrationWithSuccessStatus:YES clientStatus:YES];
  [self.messagingManagerMock registerWithUsername:self.username
                                         password:self.password
                                         fullName:self.fullName
                                            email:self.email
                                       completion:^(BOOL succeeded, NSError *error) {
                                         XCTAssertTrue(succeeded, @"Registration should be successful");
                                       }];
  OCMVerifyAll(self.pfUserMock);
  OCMVerifyAll(self.messagingManagerMock);
}

- (void)testFailedRegisterUser {
  [self prepareRegistrationWithSuccessStatus:NO clientStatus:YES];
  [self.messagingManagerMock registerWithUsername:self.username
                                         password:self.password
                                         fullName:self.fullName
                                            email:self.email
                                       completion:^(BOOL succeeded, NSError *error) {
                                         XCTAssertFalse(succeeded, @"Registration should fail");
                                       }];
  OCMVerifyAll(self.pfUserMock);
}

- (void)testRegisterUserWithFailedClient {
  [self prepareRegistrationWithSuccessStatus:YES clientStatus:NO];
  [self.messagingManagerMock registerWithUsername:self.username
                                         password:self.password
                                         fullName:self.fullName
                                            email:self.email
                                       completion:^(BOOL succeeded, NSError *error) {
                                         XCTAssertFalse(succeeded, @"Registration should fail");
                                       }];
  OCMVerifyAll(self.pfUserMock);
  OCMVerifyAll(self.messagingManagerMock);
}

- (void)prepareRegistrationWithSuccessStatus:(BOOL)status clientStatus:(BOOL)clientStatus {
  OCMStub([self.pfUserMock user]).andReturn(self.pfUserMock);
  
  id arg = [OCMArg invokeBlockWithArgs:OCMOCK_VALUE((BOOL){status}), [OCMArg defaultValue], nil];
  OCMExpect([self.pfUserMock signUpInBackgroundWithBlock:arg]);
  OCMExpect([self.pfUserMock setUsername:self.username]);
  OCMExpect([self.pfUserMock setPassword:self.password]);
  OCMExpect([self.pfUserMock setObject:self.fullName forKeyedSubscript:@"fullName"]);
  OCMExpect([self.pfUserMock setEmail:self.email]);
  
  if (status) {
    [self prepareClientConnectStatus:clientStatus];
  }
}

- (void)testLoginUser {
  [self prepareLoginWithSuccessStatus:YES clientStatus:YES];
  [self.messagingManagerMock loginWithUsername:self.username
                                      password:self.password
                                    completion:^(BOOL succeeded, NSError *error) {
                                      XCTAssertTrue(succeeded, @"Login should be successful");
                                    }];
  OCMVerifyAll(self.pfUserMock);
  OCMVerifyAll(self.messagingManagerMock);
}

- (void)testFailedLoginUser {
  [self prepareLoginWithSuccessStatus:NO clientStatus:YES];
  [self.messagingManagerMock loginWithUsername:self.username
                                      password:self.password
                                    completion:^(BOOL succeeded, NSError *error) {
                                      XCTAssertNotNil(error, @"Login should fail");
                                    }];
  OCMVerifyAll(self.pfUserMock);
}

- (void)testLoginUserWithFailedClient {
  [self prepareLoginWithSuccessStatus:YES clientStatus:NO];
  [self.messagingManagerMock loginWithUsername:self.username
                                      password:self.password
                                    completion:^(BOOL succeeded, NSError *error) {
                                      XCTAssertNotNil(error, @"Login should fail");
                                    }];
  OCMVerifyAll(self.pfUserMock);
  OCMVerifyAll(self.messagingManagerMock);
}

- (void)prepareLoginWithSuccessStatus:(BOOL)status clientStatus:(BOOL)clientStatus {
  id loginBlock = nil;
  
  if (status) {
    loginBlock = [OCMArg invokeBlockWithArgs:self.pfUserMock, [OCMArg defaultValue], nil];
    [self prepareClientConnectStatus:clientStatus];
  }
  else {
    loginBlock = [OCMArg invokeBlockWithArgs:[OCMArg defaultValue], self.error, nil];
  }
  
  OCMExpect([self.pfUserMock logInWithUsernameInBackground:self.username password:self.password block:loginBlock]);
}

- (void)prepareClientConnectStatus:(BOOL)status {
  id connectBlock = nil;
  
  if (status) {
    connectBlock = [OCMArg invokeBlockWithArgs:OCMOCK_VALUE((BOOL){YES}), [OCMArg defaultValue], nil];
  }
  else {
    connectBlock = [OCMArg invokeBlockWithArgs:OCMOCK_VALUE((BOOL){NO}), self.error, nil];
  }
  
  OCMExpect([self.messagingManagerMock connectClientWithCompletion:connectBlock]);
}

@end
