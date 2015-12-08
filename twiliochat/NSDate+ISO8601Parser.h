#import <Foundation/Foundation.h>

@interface NSDate (ISO8601Parser)
+ (instancetype)dateWithISO8601String:(NSString *)dateString;
+ (instancetype)dateFromString:(NSString *)dateString withFormat:(NSString *)dateFormat;
@end
