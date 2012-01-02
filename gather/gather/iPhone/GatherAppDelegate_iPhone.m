#import "AppContext.h"
#import "FontManager.h"
#import "GatherAppDelegate_iPhone.h"
#import "GatherServer.h"
#import "LoginVC.h"
#import "SessionData.h"
#import "SlideNavigationController.h"
#import "SlideViewController.h"
#import "SplitListViewController.h"

@implementation GatherAppDelegate_iPhone
@synthesize slideView = slideView_;
@synthesize appState = appState_;

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [ctx_ release];
  [slideView_ release];
	[super dealloc];
}

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *appDefaults =
      [NSDictionary dictionaryWithObject:@"http://dev.gather.mdor.co/"
                                  forKey:@"serverURL"];
  [defaults registerDefaults:appDefaults];
  [defaults synchronize];
  
  GatherServer *server = [[GatherServer alloc] init];
  FontManager *fontManager = [[FontManager alloc] init];
  ctx_ = [[AppContext alloc] initWithServer:server
                            withFontManager:fontManager];
  [server release];
  [fontManager release];
  
  slideView_ = [[SlideNavigationController alloc] init];
  slideView_.view.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
  self.window.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
  self.window.rootViewController = slideView_;
  
  [[NSNotificationCenter defaultCenter]
       addObserver:self
       selector:@selector(resetNavigationForAuthState)
       name:@"authStateDidChange"
       object:nil];
  [self resetNavigationForAuthState];
    
  return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
  NSString * _stripped =
      [[url absoluteString] stringByReplacingOccurrencesOfString:@"gather://"
                                                      withString:@""];
  NSArray * uriSegments = [_stripped componentsSeparatedByString:@"/"];

  if ([[uriSegments objectAtIndex:0] isEqualToString:@"verify"]) {
    NSLog(@"Verify with code %@", [uriSegments objectAtIndex:1]);

    if (ctx_.appState == kGatherAppStateLoggedOutNeedsVerification) {
      NSMutableDictionary * _userData =
          [[[NSMutableDictionary alloc] init] autorelease];
      [_userData setObject:[uriSegments objectAtIndex:1] forKey:@"verification"];
        
      [[NSNotificationCenter defaultCenter]
          postNotificationName:@"verification_from_link"
                        object:nil
                      userInfo:_userData];
    }

    return YES;
  }

  return NO;
}

- (void)resetNavigationForAuthState {
  if (![ctx_.server.sessionData loggedIn]) {
    LoginVC *newPage = [[LoginVC alloc] initWithNibName:@"LoginVC" bundle:nil];
    newPage.ctx = ctx_;
    [slideView_ resetWithPage:newPage];
    [self setAppState:kGatherAppStateLoggedOutNeedsPhoneNumber];
    [newPage release];
  } else {
    SplitListViewController *newSplit = [[SplitListViewController alloc] init];
    newSplit.ctx = ctx_;
    [slideView_ resetWithPage:newSplit];
    [self setAppState:kGatherAppStateLoggedIn];
    [newSplit release];
  }
}

@end
