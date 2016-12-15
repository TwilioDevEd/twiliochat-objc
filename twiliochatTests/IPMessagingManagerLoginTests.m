#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "MessagingManager.h"
#import "SessionManager.h"

@interface MessagingManager (Test)
- (void)connectClientWithCompletion:(void(^)(BOOL succeeded, NSError *error))handler;
@end

@interface MessagingManagerLoginTests : XCTestCase
@property (strong, nonatomic) id messagingManagerMock;
@property (strong, nonatomic) id sessionManagerMock;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *token;
@property (strong, nonatomic) NSError *error;
@end

@implementation MessagingManagerLoginTests

- (void)setUp {
  [super setUp];
  
  self.messagingManagerMock = OCMPartialMock([MessagingManager sharedManager]);
  self.sessionManagerMock = self.sessionManagerMock = OCMClassMock([SessionManager class]);

  self.username = @"hello";

  self.error = [NSError errorWithDomain:@"" code:400 userInfo:nil];
  
  self.token = @"test-token";
}

- (void)tearDown {
  [super tearDown];
  [self.sessionManagerMock stopMocking];
  [self.messagingManagerMock stopMocking];
}

- (void)testLoginUser {
  [self prepareLoginWithSuccessStatus:YES clientStatus:YES];
  [self.messagingManagerMock loginWithUsername:self.username
                                    completion:^(BOOL succeeded, NSError *error) {
                                      XCTAssertTrue(succeeded, @"Login should be successful");
                                    }];
  OCMVerifyAll(self.sessionManagerMock);
  OCMVerifyAll(self.messagingManagerMock);
}

- (void)testLoginUserWithFailedClient {
  [self prepareLoginWithSuccessStatus:YES clientStatus:NO];
  [self.messagingManagerMock loginWithUsername:self.username
                                    completion:^(BOOL succeeded, NSError *error) {
                                      XCTAssertNotNil(error, @"Login should fail");
                                    }];
  OCMVerifyAll(self.sessionManagerMock);
  OCMVerifyAll(self.messagingManagerMock);
}

- (void)prepareLoginWithSuccessStatus:(BOOL)status clientStatus:(BOOL)clientStatus {  
  if (status) {
    [self prepareClientConnectStatus:clientStatus];
  }
  
  OCMExpect([self.sessionManagerMock loginWithUsername:self.username]);
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
