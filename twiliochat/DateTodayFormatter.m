#import "DateTodayFormatter.h"

@implementation DateTodayFormatter

- (NSString*)stringFromDate:(NSDate *)date {
    NSDate *messageDate = [self roundDateToDay:date];
    NSDate *todayDate = [self roundDateToDay:[NSDate date]];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    
    if ([messageDate compare:todayDate] == NSOrderedSame) {
        format.dateFormat = @"'Today' - hh:mma";
    }
    else
    {
        format.dateFormat = @"MMM. dd - hh:mma";
    }
    
    return [format stringFromDate:date];
}

- (NSDate *)roundDateToDay:(NSDate *)date {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components: NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                               fromDate:date];
    return [calendar dateFromComponents:components];
}

@end
