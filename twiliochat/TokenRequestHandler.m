#import "TokenRequestHandler.h"
#import <AFNetworking/AFNetworking.h>

@implementation TokenRequestHandler
+ (void)fetchTokenWithParams:(NSDictionary *)params
    completion:(void (^)(NSDictionary *, NSError *))completion {
  NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle]
    pathForResource:@"Keys" ofType:@"plist"]];

  NSString *URLString = [dictionary objectForKey:@"TokenRequestUrl"];

  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration
    defaultSessionConfiguration];
  AFURLSessionManager *manager = [[AFURLSessionManager alloc]
    initWithSessionConfiguration:configuration];

  NSURLRequest *request = [[AFHTTPRequestSerializer serializer]
      requestWithMethod:@"POST" URLString:URLString parameters:params error:nil];

  NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request
      completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
    if (error) {
      NSLog(@"Error: %@", error);
      completion(nil, error);
    } else {
      completion(responseObject, nil);
    }
  }];
  [dataTask resume];
}
@end
