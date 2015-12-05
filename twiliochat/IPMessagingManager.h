#import <Foundation/Foundation.h>
#import <TwilioIPMessagingClient/TwilioIPMessagingClient.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^StatusWithErrorHandler) (BOOL succeeded, NSError * _Nullable);
typedef void (^StatusWithTokenHandler) (BOOL succeeded, NSString * _Nullable);

@interface IPMessagingManager : NSObject <TwilioAccessManagerDelegate>
@property (nonatomic, strong, readonly, nullable) TwilioIPMessagingClient *client;
@property (nonatomic, readonly) BOOL hasIdentity;

+ (instancetype)sharedManager;
- (void)presentRootViewController;
- (nullable NSString *)userIdentity;

- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
                    fullName:(NSString *)fullName
                       email:(NSString *)email
                  completion:(void(^)(BOOL succeeded, NSError *error))completion;
- (void)loginWithUsername:(NSString *)username password:(NSString *)password
               completion:(void(^)(BOOL succeeded, NSError *error))completion;

- (void)logout;

- (void)presentLaunchScreen;
@end
NS_ASSUME_NONNULL_END
