#import "InputDialogController.h"

@interface InputDialogController()
@property (strong, nonatomic) UIAlertAction *saveAction;
@end

@implementation InputDialogController

+ (void)showWithTitle:(NSString *)title message:(NSString *)message presenter:(UIViewController *)presenter handler:(void (^)(NSString *))handler {
    [[[InputDialogController alloc] init] showWithTitle:title message:message presenter:presenter handler:handler];
}

-(void)showWithTitle:(NSString *)title message:(NSString *)message presenter:(UIViewController *)presenter handler:(void (^)(NSString *))handler {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction *action) {
                                                              [self removeTextFieldObserver];
                                                          }];
    self.saveAction = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self removeTextFieldObserver];
        NSString *textFieldText = [[alert textFields][0] text];
        handler(textFieldText);
    }];
    
    self.saveAction.enabled = NO;
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleTextFieldTextDidChangeNotification:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:nil];
    }];
    [alert addAction:defaultAction];
    [alert addAction:self.saveAction];
    [presenter presentViewController:alert animated:YES completion:nil];
}

- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = (UITextField *)notification.object;
    self.saveAction.enabled = textField.text.length > 0;
}

- (void)removeTextFieldObserver {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
