#import <UIKit/UIKit.h>

@class TextFieldFormHandler;

@protocol TextFieldFormHandlerDelegate <NSObject>
@optional
- (void)textFielfFormHandlerDoneEnteringData:(TextFieldFormHandler *)handler;
@end

@interface TextFieldFormHandler : NSObject <UITextFieldDelegate>
- (instancetype)initWithTextFields:(NSArray<UITextField *> *)textfields topContainer:(UIView *)view;
- (void)cleanUp;
- (void)setFirstResponderAtIndex:(NSInteger)index;
- (void)performScroll;
@property (nonatomic, readonly) NSInteger firstResponderIndex;
@property (weak, nonatomic) id<TextFieldFormHandlerDelegate> delegate;
@property (strong, nonatomic) UITextField *lastTextField;
@end
