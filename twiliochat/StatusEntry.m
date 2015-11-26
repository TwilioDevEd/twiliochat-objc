#import "StatusEntry.h"

@implementation StatusEntry
+ (StatusEntry *)statusEntryWithMember:(TMMember *)member status:(MemberStatus)status {
    return [[StatusEntry alloc] initWithMember:member status:status];
}

- (instancetype)initWithMember:(TMMember *)member status:(MemberStatus)status {
    self = [self init];
    if (self)
    {
        self.member = member;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        self.timestamp = [dateFormatter stringFromDate:[NSDate date]];
        self.status = status;
    }
    return self;
}
@end
