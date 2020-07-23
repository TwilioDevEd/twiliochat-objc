#import <Foundation/Foundation.h>
#import <TwilioChatClient/TwilioChatClient.h>

typedef NS_ENUM(NSInteger, TWCMemberStatus) {
  TWCMemberStatusJoined,
  TWCMemberStatusLeft
};

@interface StatusEntry : NSObject
+ (instancetype)statusEntryWithMember:(TCHMember *)member status:(TWCMemberStatus)status;
- (instancetype)initWithMember:(TCHMember *)member status:(TWCMemberStatus)status;
@property (copy, nonatomic) NSString *sid;
@property (strong, nonatomic) TCHMember *member;
@property (copy, nonatomic) NSString *dateCreated;
@property (nonatomic) TWCMemberStatus status;
@end
