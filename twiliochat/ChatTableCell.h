#import <UIKit/UIKit.h>

@interface ChatTableCell : UITableViewCell
@property(copy, nonatomic) NSString *user;
@property(copy, nonatomic) NSString *message;
@property(copy, nonatomic) NSString *date;
@end
