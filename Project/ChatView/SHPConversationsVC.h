//
//  SHPConversationsVC.h
//  Soleto
//
//  Created by Andrea Sponziello on 07/11/14.
//
//

#import <UIKit/UIKit.h>
#import "SHPFirebaseTokenDelegate.h"
#import <Firebase/Firebase.h>
#import "SHPConversationsViewDelegate.h"
#import "ChatPresenceHandler.h"
#import "SHPImageDownloader.h"
#import "SHPModalCallerDelegate.h"
#import "SHPPushNotification.h"
#import "SHPPushNotificationService.h"
#import "SHPUserDC.h"

@class SHPApplicationContext;
//@class FirebaseCustomAuthHelper;
@class SHPUser;
@class ChatConversationsHandler;
@class ChatGroupsHandler;
@class ChatImageCache;
@class ChatPresenceHandler;
@class SHPUserDC;

@interface SHPConversationsVC : UITableViewController <SHPUserDCDelegate, SHPConversationsViewDelegate, ChatPresenceViewDelegate, SHPImageDownloaderDelegate, UIActionSheetDelegate, SHPModalCallerDelegate>

- (IBAction)newGroupAction:(id)sender;
- (IBAction)testAction:(id)sender;
- (IBAction)printAction:(id)sender;
- (IBAction)printGroupsAction:(id)sender;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSString *selectedConversationId;
@property (strong, nonatomic) NSString *selectedRecipient;
@property (strong, nonatomic) NSString *selectedRecipientTextToSend;
@property (assign, nonatomic) BOOL groupsMode;
@property (strong, nonatomic) NSString *selectedGroupId;
@property (strong, nonatomic) NSString *selectedGroupName;
@property (strong, nonatomic) NSString *me;
@property (strong, nonatomic) NSIndexPath *removingConversationAtIndexPath;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) ChatImageCache *imageCache;
@property (assign, nonatomic) int unread_count;

// connection status
@property (strong, nonatomic) Firebase *connectedRef;
@property (assign, nonatomic) FirebaseHandle connectedRefHandle;
@property (strong, nonatomic) UIButton *usernameButton;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

// user thumbs
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

// user info
@property (strong, nonatomic) SHPUserDC *userLoader;

@property (strong, nonatomic) ChatConversationsHandler *conversationsHandler;
@property (strong, nonatomic) ChatPresenceHandler *presenceHandler;

//-(void)openConversationWithUser:(NSString *)user;
-(void)initializeWithSignedUser; // call this on every signin
-(void)resetCurrentConversation;

//- (IBAction)newMessageAction:(id)sender;
- (IBAction)actionNewMessage:(id)sender;

-(void)openConversationWithRecipient:(NSString *)username;

@end

