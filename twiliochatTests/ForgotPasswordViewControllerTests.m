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
@end

@implementation ForgotPasswordViewControllerTests

- (void)setUp {
    [super setUp];
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ForgotPasswordViewController *viewController = (ForgotPasswordViewController *)[storyBoard instantiateViewControllerWithIdentifier:@"ForgotPasswordViewController"];
    [viewController loadView];
    
    self.viewControllerMock = OCMPartialMock(viewController);
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSendRecoveryEmail {
    id mockPFUser = OCMClassMock([PFUser class]);
    id mockAlertDialogController = OCMClassMock([AlertDialogController class]);
    
    NSString *email = @"email@domain.com";
    [self.viewControllerMock emailTextField].text = email;
    
    OCMStub([mockAlertDialogController alloc]).andReturn(mockAlertDialogController);
    OCMExpect([mockPFUser requestPasswordResetForEmailInBackground:email]);
    OCMExpect([mockAlertDialogController showAlertWithMessage:@"We've sent you an email with further instructions" title:nil presenter:self.viewControllerMock handler:[OCMArg any]]);
    
    [[self.viewControllerMock sendButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerifyAll(mockPFUser);
    OCMVerifyAll(mockAlertDialogController);
}

- (void)testInvalidEmailMessage {
    id mockPFUser = OCMClassMock([PFUser class]);
    id mockAlertDialogController = OCMClassMock([AlertDialogController class]);
    
    [self.viewControllerMock emailTextField].text = @"";
    
    OCMStub([mockAlertDialogController alloc]).andReturn(mockAlertDialogController);
    [[mockPFUser reject] requestPasswordResetForEmailInBackground:[OCMArg any]];
    OCMExpect([mockAlertDialogController showAlertWithMessage:@"Your email is required" title:nil presenter:self.viewControllerMock handler:[OCMArg any]]);
    
    [[self.viewControllerMock sendButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
    
    OCMVerifyAll(mockPFUser);
    OCMVerifyAll(mockAlertDialogController);
}

@end
