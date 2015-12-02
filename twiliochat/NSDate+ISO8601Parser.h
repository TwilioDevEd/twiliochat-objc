//
//  NSDate+ISO8601Parser.h
//  twiliochat
//
//  Created by Juan Carlos Pazmiño on 11/23/15.
//  Copyright © 2015 Twilio. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ISO8601Parser)
+ (NSDate *)dateWithISO8601String:(NSString *)dateString;
+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)dateFormat;
@end
