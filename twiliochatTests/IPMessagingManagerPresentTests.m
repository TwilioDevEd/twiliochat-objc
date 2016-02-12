#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "IPMessagingManager.h"
#import "TokenRequestHandler.h"
#import "SessionManager.h"
#import "AppDelegate.h"

@interface IPMessagingManager (Test)
- (void)connectClientWithCompletion:(void(^)(BOOL succeeded, NSError *error))handler;
@end

@interface IPMessagingManagerPresentTests : XCTestCase
@property (strong, nonatomic) id tokenRequestMock;
@property (strong, nonatomic) id sessionManagerMock;
@property (strong, nonatomic) id storyboardMock;
@property (strong, nonatomic) id windowMock;
@property (strong, nonatomic) id viewControllerMock;
@property (strong, nonatomic) id messagingManagerMock;
@property (strong, nonatomic) id appDelegateMock;
@property (strong, nonatomic) id appMock;
@end

@implementation IPMessagingManagerPresentTests

- (void)setUp {
  [super setUp];
  
  self.tokenRequestMock = OCMClassMock([TokenRequestHandler class]);
  self.sessionManagerMock = OCMClassMock([SessionManager class]);
  self.appMock = OCMClassMock([UIApplication class]);
  self.appDelegateMock = OCMClassMock([AppDelegate class]);
  self.windowMock = OCMClassMock([UIWindow class]);
  self.storyboardMock = OCMClassMock([UIStoryboard class]);
  
  self.viewControllerMock = [[NSObject alloc] init];
  self.messagingManagerMock = OCMPartialMock([IPMessagingManager sharedManager]);
  
  OCMStub([self.appMock sharedApplication]).andReturn(self.appMock);
  OCMStub([self.appMock delegate]).andReturn(self.appDelegateMock);
  OCMStub([self.appDelegateMock window]).andReturn(self.windowMock);
  OCMStub([self.storyboardMock storyboardWithName:[OCMArg any] bundle:[OCMArg any]]).andReturn(self.storyboardMock);
}

- (void)tearDown {
  [super tearDown];
  [self.tokenRequestMock stopMocking];
  [self.sessionManagerMock stopMocking];
  [self.windowMock stopMocking];
  [self.appDelegateMock stopMocking];
  [self.appMock stopMocking];
  [self.storyboardMock stopMocking];
  [self.messagingManagerMock stopMocking];
}

- (void)testLoggedInFlow {
  [self presentWithUserLoggedIn:YES
            expectingIdentifier:@"RevealViewController"
                  connectStatus:YES];
}

- (void)testNotLoggedInFlow {
  [self presentWithUserLoggedIn:NO
            expectingIdentifier:@"LoginViewController"
                  connectStatus:YES];
}

- (void)testLoggedInWithErrorFlow {
  [self presentWithUserLoggedIn:YES
            expectingIdentifier:@"LoginViewController"
                  connectStatus:NO];
}

- (void)presentWithUserLoggedIn:(BOOL)loggedIn expectingIdentifier:(NSString *)identifier connectStatus:(BOOL)status {
  OCMStub([self.sessionManagerMock isLoggedIn]).andReturn(loggedIn);
  
  id connectBlock = nil;
  
  if (status) {
    connectBlock = [OCMArg invokeBlockWithArgs:OCMOCK_VALUE((BOOL){YES}), [OCMArg defaultValue], nil];
  }
  else {
    NSError *error = [NSError errorWithDomain:@"" code:400 userInfo:nil];
    connectBlock = [OCMArg invokeBlockWithArgs:OCMOCK_VALUE((BOOL){NO}), error, nil];
  }
  
  if (loggedIn) {
    OCMExpect([self.messagingManagerMock connectClientWithCompletion:connectBlock]);
  }
  
  OCMExpect([self.storyboardMock instantiateViewControllerWithIdentifier:[OCMArg any]]).andReturn(self.viewControllerMock);
  OCMExpect([self.windowMock setRootViewController:self.viewControllerMock]);
  
  [self.messagingManagerMock presentRootViewController];
  OCMVerifyAll(self.storyboardMock);
  OCMVerifyAll(self.windowMock);
  OCMVerifyAll(self.messagingManagerMock);
}

@end
