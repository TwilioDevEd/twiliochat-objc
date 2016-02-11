#import "SessionManager.h"

static NSString * const UsernameKey = @"username";
static NSString * const IsLoggedInKey = @"loggedIn";

@implementation SessionManager
+ (void)loginWithUsername:(NSString *)username {
  [[NSUserDefaults standardUserDefaults] setValue:username forKey:UsernameKey];
  [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsLoggedInKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)logout {
  [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:UsernameKey];
  [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IsLoggedInKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isLoggedIn {
  BOOL isLoggedIn = [[NSUserDefaults standardUserDefaults] boolForKey:IsLoggedInKey];
  if (!isLoggedIn) {
    return NO;
  }
  return isLoggedIn;
}

+ (NSString*)getUsername {
  return [[NSUserDefaults standardUserDefaults] stringForKey:UsernameKey];
}
@end
