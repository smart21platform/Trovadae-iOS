//
//  SHPSelectUserVC.m
//  Smart21
//
//  Created by Andrea Sponziello on 18/02/15.
//
//

#import "SHPSelectUserVC.h"
#import "SHPSearchUsersLoader.h"
#import "SHPApplicationContext.h"
#import "SHPUserDC.h"
#import "SHPUser.h"
#import "SHPImageDownloader.h"
#import "SHPModalCallerDelegate.h"
#import "SHPImageUtil.h"
#import "SHPCaching.h"
#import "ChatImageCache.h"
#import "ChatImageWrapper.h"

@interface SHPSelectUserVC ()

@end

@implementation SHPSelectUserVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.users = nil;
    self.navigationItem.title = NSLocalizedString(@"NewMessage", nil);
//    self.imageCache = self.applicationContext.smallImagesCache;
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    NSLog(@"tableView %@", self.tableView);
    
    self.searchBar.delegate = self;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    //[self deleteRecents]; // TEST ONLY
    [self restoreRecents];
    if (self.recentUsers.count == 0) {
        [self loadFirstUsers];
    }
    
    NSLog(@"Current RECENTS...");
    for (SHPUser *u in self.recentUsers) {
        NSLog(@"recent-user %@", u.username);
    }
    
    [self initImageCache];
    [self.searchBar becomeFirstResponder];
}

-(void)initImageCache {
    // cache setup
    self.imageCache = (ChatImageCache *) [self.applicationContext getVariable:@"chatUserIcons"];
    if (!self.imageCache) {
        self.imageCache = [[ChatImageCache alloc] init];
        self.imageCache.cacheName = @"chatUserIcons";
        // test
        // [self.imageCache listAllImagesFromDisk];
        // [self.imageCache empty];
        [self.applicationContext setVariable:@"chatUserIcons" withValue:self.imageCache];
    }
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    NSLog(@"AAA viewDidDisappear...isMoving: %d, isBeingDismissed: %d", self.isMovingFromParentViewController, self.isBeingDismissed);
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    NSLog(@"SEARCH USERS VIEW WILL DISAPPEAR...isMoving: %d, isBeingDismissed: %d", self.isMovingFromParentViewController, self.isBeingDismissed);
//    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
//        NSLog(@"SEARCH USERS VIEW WILL DISAPPEAR...DISMISSING..");
//        [self disposeResources];
//    }
}

-(void)disposeResources {
    NSLog(@"Disposing firstUsersDC...");
    self.firstUsersDC.delegate = nil;
    [self.firstUsersDC cancelConnection];
    NSLog(@"Disposing userDC...");
    self.userDC.delegate = nil;
    [self.userDC cancelConnection];
    NSLog(@"Disposing pending image connections...");
    [self terminatePendingImageConnections];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection");
    if(self.users && self.users.count > 0) {
        NSInteger num = self.users.count;
//        NSLog(@"rows %ld", num);
        return num;
    } else if (self.recentUsers && self.recentUsers > 0) {
        NSInteger num = self.recentUsers.count;
//        NSLog(@"rows %ld", num);
        return num;
    }
    else {
        NSLog(@"0 rows.");
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (self.users && self.users.count > 0) {
        long userIndex = indexPath.row;
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        //        cell.contentView.backgroundColor = [UIColor whiteColor];
        SHPUser *user = [self.users objectAtIndex:userIndex];
//        NSLog(@"USER:::::::::::::::::: %@", user);
        UILabel *fullnameLabel = (UILabel *) [cell viewWithTag:2];
        UILabel *usernameLabel = (UILabel *) [cell viewWithTag:3];
        //        NSLog(@"LABEL::::::: %@", usernameLabel);
        fullnameLabel.text = user.fullName;
        usernameLabel.text = user.username;
        
        
        // USER IMAGE
        UIImageView *image_view = (UIImageView *)[cell viewWithTag:1];
        NSString *imageURL = [SHPUser photoUrlByUsername:user.username];
        ChatImageWrapper *cached_image_wrap = (ChatImageWrapper *)[self.imageCache getImage:imageURL];
        UIImage *user_image = cached_image_wrap.image;
        if(!cached_image_wrap) { // user_image == nil if image saving gone wrong!
            //NSLog(@"USER %@ IMAGE NOT CACHED. DOWNLOADING...", conversation.conversWith);
            [self startIconDownload:user.username forIndexPath:indexPath];
            // if a download is deferred or in progress, return a placeholder image
            UIImage *circled = [SHPImageUtil circleImage:[UIImage imageNamed:@"avatar"]];
            image_view.image = circled;
        } else {
            //NSLog(@"USER IMAGE CACHED. %@", conversation.conversWith);
            image_view.image = [SHPImageUtil circleImage:user_image];
            // update too old images
            double now = [[NSDate alloc] init].timeIntervalSince1970;
            double reload_timer_secs = 86400; // one day
            if (now - cached_image_wrap.createdTime.timeIntervalSince1970 > reload_timer_secs) {
                //NSLog(@"EXPIRED image for user %@. Created: %@ - Now: %@. Reloading...", conversation.conversWith, cached_image_wrap.createdTime, [[NSDate alloc] init]);
                [self startIconDownload:user.username forIndexPath:indexPath];
            } else {
                //NSLog(@"VALID image for user %@. Created %@ - Now %@", conversation.conversWith, cached_image_wrap.createdTime, [[NSDate alloc] init]);
            }
        }
        
        // DEPRECATED
//        UIImageView *iv = (UIImageView *) [cell viewWithTag:1];
//        NSString *imageURL = [SHPUser photoUrlByUsername:user.username];
//        if(![self.imageCache getImage:imageURL]) {
//            [self startIconDownload:user forIndexPath:indexPath];
//            iv.image = nil;
//        } else {
//            iv.image = [self.imageCache getImage:imageURL];
//        }
        // END DEPRECATED
        
    } else {
        // show recents
        long userIndex = indexPath.row;
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        SHPUser *user = [self.recentUsers objectAtIndex:userIndex];
        UILabel *fullnameLabel = (UILabel *) [cell viewWithTag:2];
        UILabel *usernameLabel = (UILabel *) [cell viewWithTag:3];
        fullnameLabel.text = user.fullName;
        usernameLabel.text = user.username;
        
        // USER IMAGE
        UIImageView *image_view = (UIImageView *)[cell viewWithTag:1];
        NSString *imageURL = [SHPUser photoUrlByUsername:user.username];
        ChatImageWrapper *cached_image_wrap = (ChatImageWrapper *)[self.imageCache getImage:imageURL];
        UIImage *user_image = cached_image_wrap.image;
        if(!cached_image_wrap) { // user_image == nil if image saving gone wrong!
            //NSLog(@"USER %@ IMAGE NOT CACHED. DOWNLOADING...", conversation.conversWith);
            [self startIconDownload:user.username forIndexPath:indexPath];
            // if a download is deferred or in progress, return a placeholder image
            UIImage *circled = [SHPImageUtil circleImage:[UIImage imageNamed:@"avatar"]];
            image_view.image = circled;
        } else {
            //NSLog(@"USER IMAGE CACHED. %@", conversation.conversWith);
            image_view.image = [SHPImageUtil circleImage:user_image];
            // update too old images
            double now = [[NSDate alloc] init].timeIntervalSince1970;
            double reload_timer_secs = 86400; // one day
            if (now - cached_image_wrap.createdTime.timeIntervalSince1970 > reload_timer_secs) {
                //NSLog(@"EXPIRED image for user %@. Created: %@ - Now: %@. Reloading...", conversation.conversWith, cached_image_wrap.createdTime, [[NSDate alloc] init]);
                [self startIconDownload:user.username forIndexPath:indexPath];
            } else {
                //NSLog(@"VALID image for user %@. Created %@ - Now %@", conversation.conversWith, cached_image_wrap.createdTime, [[NSDate alloc] init]);
            }
        }
        
        // DEPRECATED
//        UIImageView *iv = (UIImageView *) [cell viewWithTag:1];
//        NSString *imageURL = [SHPUser photoUrlByUsername:user.username];
//        if(![self.imageCache getImage:imageURL]) {
//            [self startIconDownload:user forIndexPath:indexPath];
//            // if a download is deferred or in progress, return a placeholder image
//            //            iv.image = [UIImage imageNamed:@"grid-big-empty-image.png"];
//            iv.image = nil;
//        } else {
//            iv.image = [self.imageCache getImage:imageURL];
//        }
        // END DEPRECATED
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger userIndex = indexPath.row;
    SHPUser *selectedUser = nil;
    if (self.users) {
        selectedUser = [self.users objectAtIndex:userIndex];
    } else {
        selectedUser = [self.recentUsers objectAtIndex:userIndex];
    }
    [self updateRecentUsersWith:selectedUser];
    [self saveRecents];
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:selectedUser forKey:@"user"];
    [self.modalCallerDelegate setupViewController:self didFinishSetupWithInfo:options];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// UISEARCHBAR DELEGATE

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar {
    NSLog(@"start editing.");
}

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
//    NSLog(@"SEARCH BUTTON PRESSED!");
//}

//-(void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)text {
-(void)searchBar:(UISearchBar*)_searchBar textDidChange:(NSString*)text {
    NSLog(@"_searchBar textDidChange");
    if (self.searchTimer) {
        if ([self.searchTimer isValid]) {
            [self.searchTimer invalidate];
        }
        self.searchTimer = nil;
        [self.userDC cancelConnection];
        //        NSLog(@"Canceled previous search...");
    }
    NSLog(@"Scheduling new search for: %@", text);
    NSString *preparedText = [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![preparedText isEqualToString:@""]) {
        self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(userPaused:) userInfo:nil repeats:NO];
    } else {
        // test reset. show "recents" (when supported) or nothing
        NSLog(@"show recents...");
        self.users = nil;
        [self.tableView reloadData];
    }
//    else {
//        self.tableView.hidden = YES;
//        [self removeTapToDismissKeyboard];
//        self.tapDismissController.enabled = YES;
//    }
}

-(void) userPaused:(NSTimer *)timer {
    NSLog(@"(SHPSearchViewController) userPaused:");
    NSString *text = self.searchBar.text;
    self.textToSearch = [self prepareTextToSearch:text];
    NSLog(@"timer on userPaused: searching for %@", self.textToSearch);
    
    self.userDC = [[ChatUsersDC alloc] init];
    self.userDC.delegate = self;
    [self.userDC findByText:self.textToSearch page:0 pageSize:30 withUser:self.applicationContext.loggedUser];
}

-(NSString *)prepareTextToSearch:(NSString *)text {
    return [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
// DC delegate

- (void)usersDidLoad:(NSArray *)__users usersDC:usersDC error:(NSError *)error {
    NSLog(@"USERS LOADED OK!");
    if (error) {
        NSLog(@"Error loading users!");
    }
    if (usersDC == self.userDC) {
        self.users = __users;
        [self.tableView reloadData];
    } else {
        self.recentUsers = [__users mutableCopy];
        [self saveRecents];
        [self.tableView reloadData];
    }
    
}

-(void)networkError {
    NSString *title = NSLocalizedString(@"NetworkErrorTitleLKey", nil);
    NSString *msg = NSLocalizedString(@"NetworkErrorLKey", nil);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


// dismiss modal

- (IBAction)CancelAction:(id)sender {
    NSLog(@"dismissing %@", self.modalCallerDelegate);
    [self disposeResources];
    [self.modalCallerDelegate setupViewController:self didCancelSetupWithInfo:nil];
}

// IMAGE HANDLING

-(void)terminatePendingImageConnections {
    NSLog(@"''''''''''''''''''''''   Terminate all pending IMAGE connections...");
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    NSLog(@"total downloads: %ld", (long)allDownloads.count);
    for(SHPImageDownloader *obj in allDownloads) {
        obj.delegate = nil;
    }
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

- (void)startIconDownload:(NSString *)username forIndexPath:(NSIndexPath *)indexPath
{
    NSString *imageURL = [SHPUser photoUrlByUsername:username];
    //    NSLog(@"START DOWNLOADING IMAGE: %@ imageURL: %@", username, imageURL);
    SHPImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageURL];
    //    NSLog(@"IconDownloader..%@", iconDownloader);
    if (iconDownloader == nil)
    {
        iconDownloader = [[SHPImageDownloader alloc] init];
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [options setObject:indexPath forKey:@"indexPath"];
        iconDownloader.options = options;
        iconDownloader.imageURL = imageURL;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:imageURL];
        [iconDownloader startDownload];
    }
}

//- (void)startIconDownload:(SHPUser *)user forIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *imageURL = [SHPUser photoUrlByUsername:user.username];
//    SHPImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageURL];
//    //    NSLog(@"IconDownloader..%@", iconDownloader);
//    if (iconDownloader == nil)
//    {
//        iconDownloader = [[SHPImageDownloader alloc] init];
//        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
//        [options setObject:indexPath forKey:@"indexPath"];
//        iconDownloader.options = options;
//        iconDownloader.imageURL = imageURL;
//        iconDownloader.delegate = self;
//        [self.imageDownloadsInProgress setObject:iconDownloader forKey:imageURL];
//        [iconDownloader startDownload];
//    }
//}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(UIImage *)image withURL:(NSString *)imageURL downloader:(SHPImageDownloader *)downloader
{
    image = [SHPImageUtil circleImage:image];
    [self.imageCache addImage:image withKey:imageURL];
    NSDictionary *options = downloader.options;
    NSIndexPath *indexPath = [options objectForKey:@"indexPath"];
    // if the cell for the image is visible updates the cell
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.row == indexPath.row && index.section == indexPath.section) {
            UITableViewCell *cell = [(UITableView *)self.tableView cellForRowAtIndexPath:index];
            UIImageView *iv = (UIImageView *)[cell viewWithTag:1];
            iv.image = image;
        }
    }
    [self.imageDownloadsInProgress removeObjectForKey:imageURL];
}

// recent users

static NSString* const chatRecentUsers = @"chatRecentUsers";

-(void)saveRecents {
    [SHPCaching saveArray:self.recentUsers inFile:chatRecentUsers];
}

-(void)deleteRecents {
    [SHPCaching deleteFile:chatRecentUsers];
}

-(void)restoreRecents {
    self.recentUsers = [SHPCaching restoreArrayFromFile:chatRecentUsers];
    if (!self.recentUsers) {
        self.recentUsers = [[NSMutableArray alloc] init];
    }
}

-(void)updateRecentUsersWith:(SHPUser *)user {
    NSLog(@"............ADDING.... user %@", user.username);
    for (SHPUser *u in self.recentUsers) {
        NSLog(@"recent-user %@", u.username);
    }
//    BOOL found = NO;
    int index = 0;
    for (SHPUser *u in self.recentUsers) {
        if([u.username isEqualToString: user.username]) {
//            found = YES;
            NSLog(@"Found this user AT INDEX %d. Removing.", index);
            [self.recentUsers removeObjectAtIndex:index];
            break;
        }
        index++;
    }
//    if (!found) {
        NSLog(@"user NOT FOUND, adding on top");
        [self.recentUsers insertObject:user atIndex:0];
//    }
    NSLog(@"AFTER");
    for (SHPUser *u in self.recentUsers) {
        NSLog(@"recent-user %@", u.username);
    }
}

-(void)loadFirstUsers {
    NSLog(@"Loading first users base...");
    NSString *text = @"*";
    
    self.firstUsersDC = [[ChatUsersDC alloc] init];
    self.firstUsersDC.delegate = self;
    [self.firstUsersDC findByText:text page:0 pageSize:40 withUser:self.applicationContext.loggedUser];
}

// scroll delegate

// Somewhere in your implementation file:
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
//    NSLog(@"Will begin dragging");
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    NSLog(@"Did Scroll");
//}

// end

-(void)dealloc {
    NSLog(@"SEARCH USERS VIEW DEALLOCATING...");
}


@end
