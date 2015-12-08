#import <Foundation/Foundation.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

typedef NS_ENUM(NSInteger, TWCMemberStatus) {
  TWCMemberStatusJoined,
  TWCMemberStatusLeft
};

@interface StatusEntry : NSObject
+ (instancetype)statusEntryWithMember:(TWMMember *)member status:(TWCMemberStatus)status;
- (instancetype)initWithMember:(TWMMember *)member status:(TWCMemberStatus)status;
@property (copy, nonatomic) NSString *sid;
@property (strong, nonatomic) TWMMember *member;
@property (copy, nonatomic) NSString *timestamp;
@property (nonatomic) TWCMemberStatus status;
@end
