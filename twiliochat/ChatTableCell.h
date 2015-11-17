//
//  ChatTableCell.h
//  twiliochat
//
//  Created by Juan Carlos Pazmiño on 11/17/15.
//  Copyright © 2015 Twilio. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatTableCell : UITableViewCell
@property(strong, nonatomic) NSString *user;
@property(strong, nonatomic) NSString *message;
@property(strong, nonatomic) NSDate *date;
@end
