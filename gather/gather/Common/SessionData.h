#import <UIKit/UIKit.h>


@interface SessionData : NSObject {
	BOOL loggedIn_;
	NSString *token_;
	NSString *verification_;
	NSString *username_;
	NSString *phoneNumber_;
  NSString *deviceToken_;
	int currentUserId_;
	BOOL syncing_;
}

- (void)needsSync;
- (void)syncWithServer;
- (void)clear;
- (void)saveSession;

@property (nonatomic) BOOL loggedIn;
@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSString *verification;
@property (nonatomic, retain) NSString *phoneNumber;
@property (nonatomic, readonly) NSString *deviceToken;
@property (nonatomic, readonly) NSString *deviceType;
@property (nonatomic) int currentUserId;
@property (nonatomic) BOOL syncing;
@end
