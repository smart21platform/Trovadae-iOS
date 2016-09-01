//
//  SHPChatSelectGroupMembers.h
//  Smart21
//
//  Created by Andrea Sponziello on 26/03/15.
//
//

#import <UIKit/UIKit.h>
#import "SHPUserDC.h"
#import "SHPImageDownloader.h"
#import "SHPModalCallerDelegate.h"

@class SHPImageCache;
@class SHPApplicationContext;

@interface SHPChatSelectGroupMembers : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, SHPUserDCDelegate, SHPImageDownloaderDelegate>

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPUser *userSelected;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) NSMutableArray *members;

@property (strong, nonatomic) SHPUserDC *userDC;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

@property (strong, nonatomic) id <SHPModalCallerDelegate> modalCallerDelegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
- (IBAction)createGroupAction:(id)sender;

@property (strong, nonatomic) NSString *searchBarPlaceholder;
@property (strong, nonatomic) NSString *textToSearch;
@property (strong, nonatomic) NSTimer *searchTimer;
@property (strong, nonatomic) NSString *lastUsersTextSearch;

@property (nonatomic, strong) SHPImageCache *imageCache;

-(void)networkError;

@end
