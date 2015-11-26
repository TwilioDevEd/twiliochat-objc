#import <Foundation/Foundation.h>

@interface NSDate (ISO8601Parser)
+ (NSDate *)dateWithISO8601String:(NSString *)dateString;
+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)dateFormat;

@end
