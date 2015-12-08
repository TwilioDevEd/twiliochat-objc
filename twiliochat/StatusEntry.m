#import "StatusEntry.h"

@implementation StatusEntry
+ (instancetype)statusEntryWithMember:(TWMMember *)member status:(TWCMemberStatus)status {
  return [[StatusEntry alloc] initWithMember:member status:status];
}

- (instancetype)initWithMember:(TWMMember *)member status:(TWCMemberStatus)status {
  self = [self init];
  if (self)
  {
    self.member = member;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
    dateFormatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    self.timestamp = [dateFormatter stringFromDate:[NSDate date]];
    self.status = status;
  }
  return self;
}
@end
