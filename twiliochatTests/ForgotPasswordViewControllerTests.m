//
//  ForgotPasswordViewControllerTests.m
//  twiliochat
//
//  Created by Juan Carlos Pazmiño on 11/25/15.
//  Copyright © 2015 Twilio. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Parse/Parse.h>
#import "ForgotPasswordViewController.h"
#import "AlertDialogController.h"

@interface ForgotPasswordViewController (Test)
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@end

@interface ForgotPasswordViewControllerTests : XCTestCase
@property (strong, nonatomic) id viewControllerMock;
@property (strong, nonatomic) NSString *email;
@end

@implementation ForgotPasswordViewControllerTests

- (void)setUp {
    [super setUp];
    self.email = @"email@domain.com";
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ForgotPasswordViewController *viewController = (ForgotPasswordViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"ForgotPasswordViewController"];
    [viewController loadView];
    
    self.viewControllerMock = OCMPartialMock(viewController);
    
    [self.viewControllerMock emailTextField].text = self.email;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSendRecoveryEmail {
    id mockPFUser = OCMClassMock([PFUser class]);
    id mockAlertDialogController = OCMClassMock([AlertDialogController class]);
    
    OCMStub([mockAlertDialogController alloc]).andReturn(mockAlertDialogController);
    OCMExpect([mockPFUser requestPasswordResetForEmailInBackground:self.email]);
    OCMExpect([mockAlertDialogController showAlertWithMessage:@"We've sent you an email with further instructions" title:nil presenter:self.viewControllerMock handler:[OCMArg any]]);
    
    [[self.viewControllerMock sendButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerifyAll(mockPFUser);
    OCMVerifyAll(mockAlertDialogController);
}

@end
