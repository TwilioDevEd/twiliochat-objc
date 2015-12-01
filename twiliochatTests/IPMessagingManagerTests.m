#import <XCTest/XCTest.h>
#import <Parse/Parse.h>
#import <OCMock/OCMock.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>
/*
#import "IPMessagingManager.h"

@interface IPMessagingManager (Test)
- (void)connectClient:(void(^)(BOOL succeeded, NSError *error))handler;
@end

@interface IPMessagingManagerTests : XCTestCase
@property (strong, nonatomic) id pfCloudMock;
@property (strong, nonatomic) id pfUserMock;
@property (strong, nonatomic) id clientMock;
@property (strong, nonatomic) NSString *token;
@end

@implementation IPMessagingManagerTests

- (void)setUp {
    [super setUp];
    
    self.pfUserMock = OCMClassMock([PFUser class]);
    self.pfCloudMock = OCMClassMock([PFCloud class]);
    self.clientMock = OCMClassMock([TwilioIPMessagingClient class]);
    
    self.token = @"test-token";
    
    OCMExpect([self.clientMock ipMessagingClientWithToken:self.token delegate:nil]).andReturn(self.clientMock);
}

- (void)tearDown {
    [super tearDown];
    [self.pfCloudMock stopMocking];
    [self.pfUserMock stopMocking];
    [self.clientMock stopMocking];
}

- (void)testConnectClient {
    NSDictionary *serviceData = @{@"token": self.token};
    id cloudBlock = [OCMArg invokeBlockWithArgs:serviceData, [OCMArg defaultValue], nil];
    OCMExpect([self.pfCloudMock callFunctionInBackground:@"token" withParameters:[OCMArg any] block:cloudBlock]);
    
    [[IPMessagingManager sharedManager] connectClient:^(BOOL succeeded, NSError *error) {
        XCTAssertTrue(succeeded, @"Registration should be successful");
    }];
    
    OCMVerifyAll(self.pfCloudMock);
    OCMVerifyAll(self.clientMock);
}

- (void)testFailedConnectClient {
    NSError *error = [NSError errorWithDomain:@"" code:-1000 userInfo:nil];
    id cloudBlock = [OCMArg invokeBlockWithArgs:[OCMArg defaultValue], error, nil];
    OCMExpect([self.pfCloudMock callFunctionInBackground:@"token" withParameters:[OCMArg any] block:cloudBlock]);
    
    [[IPMessagingManager sharedManager] connectClient:^(BOOL succeeded, NSError *error) {
        XCTAssertFalse(succeeded, @"Registration should fail");
    }];
    
    OCMVerifyAll(self.pfCloudMock);
}

@end
 */
