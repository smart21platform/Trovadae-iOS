//
//  MessagesViewController.h
//  Soleto
//
//  Created by Andrea Sponziello on 26/11/14.
//
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>
#import "SHPFirebaseTokenDelegate.h"
#import "SHPChatDelegate.h"
#import "SHPImageDownloader.h"
#import "QBPopupMenu.h"
#import <AudioToolbox/AudioToolbox.h>

@class SHPApplicationContext;
@class FAuthData;
@class FirebaseCustomAuthHelper;
@class Firebase;
@class SHPUser;
@class ChatConversationHandler;
@class SHPConversationsVC;
@class  QBPopupMenu;
@class SHPHomeProfileTVC;
@class ChatImageCache;

@interface MessagesViewController : UIViewController <UIGestureRecognizerDelegate, SHPChatDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, QBPopupMenuDelegate> { // , SHPImageDownloaderDelegate>
    BOOL keyboardShow;
    CGFloat heightTable;
    CGFloat originalViewHeight;
    NSLayoutConstraint *currentViewHeightConstraint;
    //NSDate *previewData;
}

//UI
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
- (IBAction)menuAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (assign, nonatomic) BOOL bottomReached;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *connectionStatusItem;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutConstraintBottomTableTopBarMessage;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *layoutContraintBottomBarMessageBottomView;
@property (strong, nonatomic) SHPConversationsVC *conversationsVC;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSString *recipient;
@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *textToSendAsChatOpens;

// GROUP_MOD
@property (strong, nonatomic) NSString *groupId;
@property (strong, nonatomic) NSString *groupName;

// user thumbs
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

@property (strong, nonatomic) NSString *conversationId;
@property (strong, nonatomic) ChatConversationHandler *conversationHandler;

@property (strong, nonatomic) UIActionSheet *menuSheet;

// imagepicker
@property (strong, nonatomic) UIActionSheet *photoMenuSheet;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImagePickerController *photoLibraryController;
@property (nonatomic, strong) UIImage *scaledImage;
@property (strong, nonatomic) UIImage *bigImage;

@property (strong, nonatomic) UITableViewCell *cellWithMenu;
@property (strong, nonatomic) QBPopupMenu *popupMenu;
@property (strong, nonatomic) NSString *selectedText;
@property (strong, nonatomic) UITapGestureRecognizer *tapToDismissKB;
@property (strong, nonatomic) UIBarButtonItem *backButton;
@property (strong, nonatomic) UIStoryboard *profileSB;
@property (strong, nonatomic) UINavigationController *profileNC;
@property (strong, nonatomic) SHPHomeProfileTVC *profileVC;
@property (assign, nonatomic) int unread_count;
@property (strong, nonatomic) UILabel *unreadLabel;
@property (strong, nonatomic) ChatImageCache *imageCache;

// connection status
@property (strong, nonatomic) Firebase *connectedRef;
@property (assign, nonatomic) FirebaseHandle connectedRefHandle;
@property (strong, nonatomic) UIButton *usernameButton;
@property (strong, nonatomic) UILabel *statusLabel;
@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

// sound
@property (strong, nonatomic) NSTimer *soundTimer;
@property (assign, nonatomic) BOOL playingSound;
@property (assign, nonatomic) double lastPlayedSoundTime;

- (IBAction)sendAction:(id)sender;
- (IBAction)prindb:(id)sender;
-(void)updateUnreadMessagesCount;

@end
