#import "GatherAppDelegate.h"
#import "GatherAppState.h"
#import "GatherServer.h"
#import "LoginVC.h"
#import "PhoneNumberFormatter.h"
#import "SessionData.h"
#import "SlideNavigationController.h"
#import "SlideViewController.h"
#import "ValidateVC.h"

@implementation LoginVC
@synthesize ctx = ctx_;

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    
  }
  return self;
}

- (void)dealloc {
  [ctx_ release];
  [phoneNumberField_ release];
  [instructionsLabel_ release];
  [phoneNumberLabel_ release];
  [super dealloc];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [phoneNumberLabel_ setFont:[UIFont fontWithName:@"UniversLTStd-UltraCn"
                                             size:60]];

  [instructionsLabel_ setFont:[UIFont fontWithName:@"UniversLTStd-UltraCn"
                                              size:20]];
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void) viewDidAppearInSlideNavigation {
    [super viewDidAppearInSlideNavigation];
    [phoneNumberField_ becomeFirstResponder];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [phoneNumberField_ resignFirstResponder];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
    replacementString:(NSString *)string {
  NSCharacterSet * set =
      [[NSCharacterSet characterSetWithCharactersInString:@"0123456789"]
          invertedSet];
  if ([string rangeOfCharacterFromSet:set].location != NSNotFound) {
    return FALSE;
  } else {
    NSString * post =
        [[textField text] stringByReplacingCharactersInRange:range
                                                  withString:string];
      
    PhoneNumberFormatter * pn = [[PhoneNumberFormatter alloc] init];
    phoneNumberLabel_.text = [pn format:post withLocale:@"us"];
      
    if ([post length] == 10 &&
      [[[phoneNumberLabel_ text] substringToIndex:1] isEqualToString:@"("]) {
      instructionsLabel_.text = @"SWIPE LEFT TO LOG IN";
      phoneNumberLabel_.textColor = [UIColor colorWithRed:1.0
                                                    green:93.0/255.0
                                                     blue:53.0/255.0
                                                    alpha:1.0];
      
      [ctx_.server.sessionData setPhoneNumber:post];
      ctx_.appState = kGatherAppStateLoggedOutHasPhoneNumber;
      
      ValidateVC *new = [[ValidateVC alloc] initWithNibName:@"ValidateVC"
                                                     bundle:nil];
      new.ctx = ctx_;
      
      [self.slideNavigation addNewPage:new];
      [new release];
    } else {
      instructionsLabel_.text = @"HELLO. WHAT IS YOUR CELL PHONE NUMBER?";
      phoneNumberLabel_.textColor = [UIColor blackColor];
        
      ctx_.appState = kGatherAppStateLoggedOutNeedsPhoneNumber;
      
      [ctx_.server.sessionData setPhoneNumber:nil];
    }
    [pn release];
    return TRUE;
  }
}

@end
