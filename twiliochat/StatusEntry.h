#import <Foundation/Foundation.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

typedef enum {
  MemberStatusJoined,
  MemberStatusLeft
} MemberStatus;

@interface StatusEntry : NSObject
+ (StatusEntry *)statusEntryWithMember:(TWMMember *)member status:(MemberStatus)status;
- (instancetype)initWithMember:(TWMMember *)member status:(MemberStatus)status;
@property (strong, nonatomic) NSString *sid;
@property (strong, nonatomic) TWMMember *member;
@property (strong, nonatomic) NSString *timestamp;
@property (nonatomic) MemberStatus status;
@end
