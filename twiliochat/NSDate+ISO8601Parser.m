#import "NSDate+ISO8601Parser.h"

@implementation NSDate (ISO8601Parser)
+ (instancetype)dateWithISO8601String:(NSString *)dateString
{
  if (!dateString) return nil;
  if ([dateString hasSuffix:@"Z"]) {
    dateString = [[dateString substringToIndex:(dateString.length-1)] stringByAppendingString:@"-0000"];
  }
  return [self dateFromString:dateString
                   withFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
}

+ (instancetype)dateFromString:(NSString *)dateString
                withFormat:(NSString *)dateFormat
{
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  dateFormatter.dateFormat = dateFormat;
  
  NSLocale *locale = [[NSLocale alloc]
                      initWithLocaleIdentifier:@"en_US_POSIX"];
  dateFormatter.locale = locale;
  
  NSDate *date = [dateFormatter dateFromString:dateString];
  return date;
}
@end

