#import "MenuTableCell.h"
#import "InputDialogController.h"
#import "MainChatViewController.h"

@interface MenuTableCell ()
@property (weak, nonatomic) UILabel *label;
@property (weak, nonatomic, readonly) UIColor *selectedBackgroundColor;
@property (weak, nonatomic, readonly) UIColor *labelHighlightedTextColor;
@property (weak, nonatomic, readonly) UIColor *labelTextColor;
@end

@implementation MenuTableCell

- (void)setChannelName:(NSString *)channelName {
    self.label.text = channelName;
}

- (NSString *)channelName {
    return self.label.text;
}

- (void)awakeFromNib {
    self.label = (UILabel *)[self viewWithTag:200];
    self.selectedBackgroundView.backgroundColor = self.selectedBackgroundColor;
    self.label.highlightedTextColor = self.labelHighlightedTextColor;
}

- (UIColor *)selectedBackgroundColor {
    return [UIColor colorWithRed:0.969 green:0.902 blue:0.894 alpha:1];
}

- (UIColor *)labelHightlightedTextColor {
    return [UIColor colorWithRed:0.22 green:0.024 blue:0.016 alpha:1];
}

- (UIColor *)labelTextColor {
    return [UIColor colorWithRed:0.973 green:0.557 blue:0.502 alpha:1];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.label.highlightedTextColor = self.labelHighlightedTextColor;
    }
    else {
        self.label.textColor = self.labelTextColor;
    }
}

@end
