#import "MenuTableCell.h"
#import "InputDialogController.h"
#import "MainChatViewController.h"

@interface MenuTableCell ()
@property (weak, nonatomic) UILabel *label;
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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.label.textColor = [UIColor colorWithRed:0.22 green:0.024 blue:0.016 alpha:1];
        self.contentView.backgroundColor = [UIColor colorWithRed:0.969 green:0.902 blue:0.894 alpha:1];
    }
    else {
        self.label.textColor = [UIColor colorWithRed:0.973 green:0.557 blue:0.502 alpha:1];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

@end
