#import <UIKit/UIKit.h>

@class TextFieldFormHandler;

@protocol TextFieldFormHandlerDelegate <NSObject>
@optional
- (void)textFieldFormHandlerDoneEnteringData:(TextFieldFormHandler *)handler;
@end

@interface TextFieldFormHandler : NSObject <UITextFieldDelegate>
- (instancetype)initWithTextFields:(NSArray<UITextField *> *)textfields topContainer:(UIView *)view;
- (void)cleanUp;
- (void)setTextFieldAtIndexAsFirstResponder:(NSInteger)index;
- (void)resetScroll;
@property (nonatomic, readonly) NSInteger firstResponderIndex;
@property (weak, nonatomic) id<TextFieldFormHandlerDelegate> delegate;
@property (strong, nonatomic) UITextField *lastTextField;
@end
