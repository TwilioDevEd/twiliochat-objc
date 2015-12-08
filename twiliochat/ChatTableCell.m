#import "ChatTableCell.h"

@interface ChatTableCell ()
@property (weak, nonatomic) UILabel *userLabel;
@property (weak, nonatomic) UILabel *messageLabel;
@property (weak, nonatomic) UILabel *dateLabel;
@end

static NSInteger const TWCUserLabelTag = 200;
static NSInteger const TWCDateLabelTag = 201;
static NSInteger const TWCMessageLabelTag = 202;

@implementation ChatTableCell

- (void)setUser:(NSString *)user {
  self.userLabel.text = user;
}

- (NSString *)user {
  return self.userLabel.text;
}

- (void)setMessage:(NSString *)message {
  self.messageLabel.text = message;
}

- (NSString *)message {
  return self.messageLabel.text;
}

- (void)setDate:(NSString *)date {
  self.dateLabel.text = date;
}

- (NSString *)date {
  return self.messageLabel.text;
}

- (void)awakeFromNib {
  self.userLabel = (UILabel *)[self viewWithTag:TWCUserLabelTag];
  self.dateLabel = (UILabel *)[self viewWithTag:TWCDateLabelTag];
  self.messageLabel = (UILabel *)[self viewWithTag:TWCMessageLabelTag];
}

@end
