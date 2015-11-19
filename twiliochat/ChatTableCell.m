#import "ChatTableCell.h"

@interface ChatTableCell ()
{
    NSDate *_date;
}
@property (weak, nonatomic) UILabel *userLabel;
@property (weak, nonatomic) UILabel *messageLabel;
@property (weak, nonatomic) UILabel *dateLabel;
@end

@implementation ChatTableCell

@synthesize date = _date;

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

- (void)setDate:(NSDate *)date {
    _date = date;
    self.dateLabel.text = [self formattedDate];
}

- (NSString*)formattedDate {
    NSDate *messageDate = [self roundDateToDay:_date];
    NSDate *todayDate = [self roundDateToDay:[NSDate date]];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    
    if ([messageDate compare:todayDate] == NSOrderedSame) {
        format.dateFormat = @"'Today' - hh:mma";
    }
    else
    {
        format.dateFormat = @"MMM. dd - hh:mma";
    }
    
    return [format stringFromDate:_date];
}

- (NSDate *)roundDateToDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                               fromDate:_date];
    return [calendar dateFromComponents:components];
}

- (void)awakeFromNib {
    self.userLabel = (UILabel *)[self viewWithTag:200];
    self.dateLabel = (UILabel *)[self viewWithTag:201];
    self.messageLabel = (UILabel *)[self viewWithTag:202];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    /*[super setSelected:selected animated:animated];
    
    if (selected) {
        self.label.textColor = [UIColor colorWithRed:0.22 green:0.024 blue:0.016 alpha:1];
        self.contentView.backgroundColor = [UIColor colorWithRed:0.969 green:0.902 blue:0.894 alpha:1];
    }
    else {
        self.label.textColor = [UIColor colorWithRed:0.973 green:0.557 blue:0.502 alpha:1];
        self.contentView.backgroundColor = [UIColor clearColor];
    }*/
}

@end
