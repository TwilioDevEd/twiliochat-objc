//
//  StatusEntry.h
//  twiliochat
//
//  Created by Juan Carlos Pazmiño on 11/25/15.
//  Copyright © 2015 Twilio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

typedef enum {
    MemberStatusJoined,
    MemberStatusLeft
} MemberStatus;

@interface StatusEntry : NSObject
+ (StatusEntry *)statusEntryWithMember:(TMMember *)member status:(MemberStatus)status;
- (instancetype)initWithMember:(TMMember *)member status:(MemberStatus)status;
@property (strong, nonatomic) TMMember *member;
@property (strong, nonatomic) NSString *timestamp;
@property (nonatomic) MemberStatus status;
@end
