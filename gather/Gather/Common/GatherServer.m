#import "GatherRequest.h"
#import "GatherRequestDelegate.h"
#import "GatherServer.h"
#import "SessionData.h"

@interface GatherServer ()
- (void)addActiveRequest:(GatherRequest *)request;
- (NSURL *)urlForMethod:(NSString *)method;
- (NSDictionary *)signedParamsWithParams:(NSDictionary *)params;
@end

@implementation GatherServer
@synthesize sessionData = sessionData_;

- (id)init {
  self = [super init];
  if (self) {
    sessionData_ = [[SessionData alloc] init];
  }
  return self;
}

- (void)addActiveRequest:(GatherRequest *)request {
  [activeRequests_ addObject:request];
  [request startRequest];
}

- (void)removeFromActiveRequests:(GatherRequest *)request {
  [activeRequests_ removeObject:request];
}

- (NSUInteger) requestsInProgress {
  return [activeRequests_ count];
}

#pragma mark Base
- (NSURL *)urlForMethod:(NSString *)method {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSString *apiUrl = [defaults stringForKey:@"serverURL"];
  
  NSString * _str =
      [NSString stringWithFormat:@"%@api/1/%@", apiUrl, method];
  return [NSURL URLWithString:_str];
}

- (NSDictionary *)signedParamsWithParams:(NSDictionary *)params {
  NSMutableDictionary *newParams =
      [NSMutableDictionary dictionaryWithDictionary:params];
  if ([sessionData_ loggedIn]) {
    [newParams setObject:[sessionData_ token]
                  forKey:@"token"];
    [newParams setObject:[sessionData_ verification]
                  forKey:@"verification"];
  }
  return newParams;
}

#pragma mark API Calls
- (GatherRequest *)requestTokenWithPhoneNumber:(NSString *)phoneNumber
    withDelegate:(id<GatherRequestDelegate>)delegate {
  NSURL *url = [self urlForMethod:@"tokens"];
  NSMutableDictionary *params = [NSMutableDictionary dictionary];
  [params setObject:phoneNumber forKey:@"phone_number"];
  [params setObject:[sessionData_ deviceToken] forKey:@"device_udid"];
  [params setObject:[sessionData_ deviceType] forKey:@"device_type"];
  
  GatherRequest *request =
      [[GatherRequest alloc] initWithGatherServer:self
                                           andURL:url
                                        andParams:params
                                   andRequestType:kGatherRequestTypePost
                              andExpectedDataType:kGatherExpectedDataTypeJson
                                      andDelegate:delegate];
  [self addActiveRequest:request];
  return [request autorelease];
}

- (void) dealloc {
  [activeRequests_ release];
  [sessionData_ release];
  [super dealloc];
}
@end
