//
//  SHPSelectUserVC.h
//  Smart21
//
//  Created by Andrea Sponziello on 18/02/15.
//
//

#import <UIKit/UIKit.h>
#import "ChatUsersDC.h"
#import "SHPImageDownloader.h"
#import "SHPModalCallerDelegate.h"

@class SHPImageCache;
@class SHPApplicationContext;
@class ChatImageCache;

@interface SHPSelectUserVC : UIViewController <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, ChatUsersDCDelegate, SHPImageDownloaderDelegate>

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPUser *userSelected;
@property (strong, nonatomic) NSArray *users;
@property (strong, nonatomic) NSMutableArray *recentUsers;

@property (strong, nonatomic) ChatUsersDC *userDC;
@property (strong, nonatomic) ChatUsersDC *firstUsersDC;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

@property (strong, nonatomic) id <SHPModalCallerDelegate> modalCallerDelegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) NSString *searchBarPlaceholder;
@property (strong, nonatomic) NSString *textToSearch;
@property (strong, nonatomic) NSTimer *searchTimer;
@property (strong, nonatomic) NSString *lastUsersTextSearch;

//@property (nonatomic, strong) SHPImageCache *imageCache;
@property (strong, nonatomic) ChatImageCache *imageCache;

-(void)networkError;
- (IBAction)CancelAction:(id)sender;

@end
