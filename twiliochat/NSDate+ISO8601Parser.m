#import "NSDate+ISO8601Parser.h"

@implementation NSDate (ISO8601Parser)
+ (NSDate *)dateWithISO8601String:(NSString *)dateString
{
    if (!dateString) return nil;
    if ([dateString hasSuffix:@"Z"]) {
        NSInteger dotIndex = [dateString rangeOfString:@"."].location;
        if (dotIndex == NSNotFound) {
            dateString = [dateString stringByAppendingString:@".0"];
        }
        else {
            dateString = [dateString substringToIndex:dotIndex + 2];
        }
        dateString = [dateString stringByAppendingString:@"-0000"];
    }
    return [self dateFromString:dateString
                     withFormat:@"yyyy-MM-dd'T'HH:mm:ss.SZ"];
}

+ (NSDate *)dateFromString:(NSString *)dateString
                withFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];

    NSLocale *locale = [[NSLocale alloc]
                        initWithLocaleIdentifier:@"en_US_POSIX"];
    [dateFormatter setLocale:locale];
    
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}
@end

