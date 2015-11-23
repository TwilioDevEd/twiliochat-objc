#import <XCTest/XCTest.h>
#import <Parse/Parse.h>
#import <OCMock/OCMock.h>
#import "IPMessagingManager.h"
#import "AppDelegate.h"

@interface IPMessagingManager (Test)
- (void)connectClient:(void(^)(BOOL succeeded, NSError *error))handler;
@end

@interface IPMessagingManagerPresentTests : XCTestCase
@property (strong, nonatomic) id pfCloudMock;
@property (strong, nonatomic) id pfUserMock;
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
    
    self.pfCloudMock = OCMClassMock([PFCloud class]);
    self.pfUserMock = OCMClassMock([PFUser class]);
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
    [self.pfCloudMock stopMocking];
    [self.pfUserMock stopMocking];
    [self.windowMock stopMocking];
    [self.appDelegateMock stopMocking];
    [self.appMock stopMocking];
    [self.storyboardMock stopMocking];
    [self.messagingManagerMock stopMocking];
}

- (void)testLoggedInFlow {
    [self presentWithUser:self.pfUserMock
      expectingIdentifier:@"RevealViewController"
            connectStatus:YES];
}

- (void)testNotLoggedInFlow {
    [self presentWithUser:nil
      expectingIdentifier:@"LoginViewController"
            connectStatus:YES];
}

- (void)testLoggedInWithErrorFlow {
    [self presentWithUser:self.pfUserMock
      expectingIdentifier:@"LoginViewController"
            connectStatus:NO];
}

- (void)presentWithUser:(id)user expectingIdentifier:(NSString *)identifier connectStatus:(BOOL)status {
    OCMStub([self.pfUserMock currentUser]).andReturn(user);
    
    id connectBlock = nil;
    
    if (status) {
        connectBlock = [OCMArg invokeBlockWithArgs:OCMOCK_VALUE((BOOL){YES}), [OCMArg defaultValue], nil];
    }
    else {
        NSError *error = [NSError errorWithDomain:@"" code:-1000 userInfo:nil];
        connectBlock = [OCMArg invokeBlockWithArgs:OCMOCK_VALUE((BOOL){NO}), error, nil];
    }

    if (user) {
        OCMExpect([self.messagingManagerMock connectClient:connectBlock]);
        OCMExpect([self.pfUserMock isAuthenticated]).andReturn(YES);
    }
    
    OCMExpect([self.storyboardMock instantiateViewControllerWithIdentifier:[OCMArg any]]).andReturn(self.viewControllerMock);
    OCMExpect([self.windowMock setRootViewController:self.viewControllerMock]);
    
    [self.messagingManagerMock presentRootViewController];
    OCMVerifyAll(self.storyboardMock);
    OCMVerifyAll(self.windowMock);
    OCMVerifyAll(self.messagingManagerMock);
}

@end