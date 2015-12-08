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
  
  NSString *email = @"email@domain.com";
  [self.viewControllerMock emailTextField].text = email;
  
  OCMExpect([mockPFUser requestPasswordResetForEmailInBackground:email block:[OCMArg any]]);
  
  [[self.viewControllerMock sendButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
  
  OCMVerifyAll(mockPFUser);
}

- (void)testInvalidEmailMessage {
  id mockPFUser = OCMClassMock([PFUser class]);
  
  [self.viewControllerMock emailTextField].text = @"";
  
  [[mockPFUser reject] requestPasswordResetForEmailInBackground:[OCMArg any] block:[OCMArg any]];
  
  [[self.viewControllerMock sendButton] sendActionsForControlEvents:UIControlEventTouchUpInside];
  
  OCMVerifyAll(mockPFUser);
}

@end
