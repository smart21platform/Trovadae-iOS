//
//  SHPUsersTableList.m
//  Dressique
//
//  Created by andrea sponziello on 17/01/13.
//
//

#import "SHPUsersTableList.h"
#import "SHPUserDC.h"
#import "SHPUsersLoaderStrategy.h"
#import "SHPUser.h"
#import "SHPComponents.h"
#import "SHPApplicationContext.h"
#import "SHPApplicationSettings.h"

@implementation SHPUsersTableList

@synthesize applicationContext;
@synthesize masterView;
@synthesize loader;

@synthesize tableView;
@synthesize tableViewDelegate;

@synthesize selectedIndex;
@synthesize imageCache;
@synthesize columnsNumber;
//@synthesize totalRows;
//@synthesize userDC;
@synthesize users;
@synthesize searchStartPage;
@synthesize searchPageSize;
@synthesize imageDownloadsInProgress;
@synthesize isLoadingData;
@synthesize currentlyShown;
@synthesize isNetworkError;
@synthesize noMoreData;

- (void)initialize {
    NSLog(@"INITIALIZING TABLE LIST!");
    self.users = nil;
    //    self.totalRows = 0;
    
    self.columnsNumber = 2;
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    self.searchStartPage = 0;
    self.noMoreData = FALSE;
    self.isNetworkError = NO;
    
    self.loader.searchStartPage = self.searchStartPage;
    self.loader.userDC.delegate = self;
}

-(void)searchUsers {
    self.isLoadingData = YES;
    [self.loader loadUsers];
}

- (NSInteger)numberOfRows {
    if(self.users && self.users.count > 0) {
        NSInteger num = self.users.count;
        num = num + 1; // add "more button" cell
        return num;
    }
    else {
        return 1; // loading cell || no products cell
    }
}

- (CGFloat)heightForRow:(NSInteger)row {
    return 44;
}

- (UITableViewCell *)cellForRow:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    cell = [self gridCellForIndexPath:indexPath];
    return cell;
}

-(UITableViewCell *)gridCellForIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (self.users.count == 0 && self.isLoadingData) { // initial load cell
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"ActivityCell"];
        UIActivityIndicatorView *activityView = (UIActivityIndicatorView *) [cell viewWithTag:20];
        [activityView startAnimating];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        return cell;
    }
    else if (self.users.count == 0) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"NoItemsCell2"];
        UILabel *label = (UILabel *)[cell viewWithTag:10];
        label.text = NSLocalizedString(@"NoUserFoundLKey", nil);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        return cell;
    }
    else if (self.users && self.users.count > 0 && indexPath.row <= self.users.count - 1) {
        int userIndex = (int)indexPath.row;
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserCell"];
        NSLog(@"CELL:::::::::::: %@", cell);
        //        cell.contentView.backgroundColor = [UIColor whiteColor];
        SHPUser *user = [self.users objectAtIndex:userIndex];
        NSLog(@"USER:::::::::::::::::: %@", user);
        UILabel *fullnameLabel = (UILabel *) [cell viewWithTag:2];
//        NSLog(@"LABEL::::::: %@", usernameLabel);
        fullnameLabel.text = user.fullName;
        
        UILabel *usernameLabel = (UILabel *) [cell viewWithTag:3];
        usernameLabel.text = user.username;
        
        UIImageView *iv = (UIImageView *) [cell viewWithTag:1];
        NSString *imageURL = [self userImageURL:user];
        if(![self.imageCache getImage:imageURL]) {
            [self startIconDownload:user forIndexPath:indexPath];
            // if a download is deferred or in progress, return a placeholder image
            iv.image = [UIImage imageNamed:@"grid-big-empty-image.png"];
            //                    iv.image = nil;
        } else {
            iv.image = [self.imageCache getImage:imageURL];
        }
        
    } else if (indexPath.row == self.users.count) { // last cell
        NSLog(@"RENDERING LAST CELL!");
        NSLog(@"CREATING LAST CELL");
        cell = [SHPComponents MainListMoreResultsCell:self.applicationContext.settings.mainListBgColor withTarget:self settings:self.applicationContext.settings];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = NO;
        [self updateMoreButtonCell:cell];
    }
    return cell;
}

-(SHPUser *)userAtIndexPath:(NSIndexPath *)indexPath {
    return [self.users objectAtIndex:indexPath.row];
}

// DC delegate

- (void)usersDidLoad:(NSArray *)users error:(NSError *)error {
    NSLog(@"USERS LOADED OK!");
    self.isLoadingData = NO;
    if (error) {
        self.isNetworkError = YES;
        if ([self.tableViewDelegate respondsToSelector:@selector(networkError)]) {
            [self.tableViewDelegate performSelector:@selector(networkError)];
        } else {
            NSLog(@"NO networkError Selector is impemented for the tableViewDelegate!");
        }
    }
    UITableViewCell *moreCell = [self moreButtonCell];
    [self updateMoreButtonCell:moreCell];
    if (!self.users) {
        self.users = [[NSMutableArray alloc] init];
    }
    [self.users addObjectsFromArray:users];
    if (users.count == 0 || users.count < self.loader.searchPageSize) {
        self.noMoreData = TRUE;
    }
    [self reloadTable];
}


-(void)networkError {
    NSLog(@"NETWORK ERROR!");
    self.isLoadingData = NO;
    self.isNetworkError = YES;
    if ([self.tableViewDelegate respondsToSelector:@selector(networkError)]) {
        [self.tableViewDelegate performSelector:@selector(networkError)];
    } else {
        NSLog(@"NO networkError Selector is impemented for the tableViewDelegate!");
    }
}

-(void)reloadTable {
    if ([self.tableViewDelegate respondsToSelector:@selector(reloadTable)]) {
        NSLog(@"RELOADING TABLE...");
		[self.tableViewDelegate performSelector:@selector(reloadTable) withObject:self];
	} else {
        NSLog(@"no reload table selector");
    }
}

// END DC DELEGATE

// IMAGE HANDLING

-(void)terminatePendingImageConnections {
    NSLog(@"''''''''''''''''''''''   Terminate all pending IMAGE connections...");
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    NSLog(@"total downloads: %d", (int)allDownloads.count);
    for(SHPImageDownloader *obj in allDownloads) {
        obj.delegate = nil;
    }
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

- (void)startIconDownload:(SHPUser *)user forIndexPath:(NSIndexPath *)indexPath
{
    NSString *imageURL = [self userImageURL:user];
    SHPImageDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:imageURL];
    //    NSLog(@"IconDownloader..%@", iconDownloader);
    if (iconDownloader == nil)
    {
        iconDownloader = [[SHPImageDownloader alloc] init];
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [options setObject:indexPath forKey:@"indexPath"];
        iconDownloader.options = options;
        
//        NSString *imageURL = [self userImageURL:shop];
        
        iconDownloader.imageURL = imageURL;
        //        iconDownloader.imageWidth = SHPCONST_SHOP_DETAIL_gridImageWidth;
        //        iconDownloader.imageHeight = 500;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:imageURL];
        //        NSLog(@"DOWNLOADS IN PROGRESS: %d", self.imageDownloadsInProgress.count);
        [iconDownloader startDownload];
    }
}

-(NSString *)userImageURL:(SHPUser *)user {
    NSString *_url = [SHPUser photoUrlByUsername:user.username];
    return _url;
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(UIImage *)image withURL:(NSString *)imageURL downloader:(SHPImageDownloader *)downloader
{
    [self.imageCache addImage:image withKey:imageURL];
    NSDictionary *options = downloader.options;
    NSIndexPath *indexPath = [options objectForKey:@"indexPath"];
    // if the cell for the image is visible updates the cell
    // but only if this subtable is visible
    if (self.currentlyShown) {
        NSArray *indexes = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *index in indexes) {
            if (index.row == indexPath.row && index.section == indexPath.section) {
                UITableViewCell *cell = [(UITableView *)self.tableView cellForRowAtIndexPath:index];
                UIImageView *iv = (UIImageView *)[cell viewWithTag:1];
                iv.image = image;
            }
        }
    }
    [self.imageDownloadsInProgress removeObjectForKey:imageURL];
}

-(void)moreButtonPressed:(id)sender
{
    NSLog(@"More Button pressed");
    self.searchStartPage = self.searchStartPage + 1;
    self.loader.searchStartPage = self.searchStartPage;
    [self searchUsers];
    UITableViewCell *moreCell = [self moreButtonCell];
    if (moreCell) {
        [self updateMoreButtonCell:moreCell];
    }
}

// if visible, returns the cell of the moreButton (the last cell)
-(UITableViewCell *)moreButtonCell {
    if (!self.users) {
        return nil;
    }
    // we can also test this: if last cell.identifier == LastCellIdent...
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.row == self.users.count) {
            UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:index];
            return cell;
        }
    }
    return nil;
}

-(void)updateMoreButtonCell:(UITableViewCell *)cell {
    NSLog(@"???? updateMoreButtonCell networkerror %d", self.isNetworkError);
    if (!cell) {
        return;
    }
    UIButton *button = (UIButton *)[cell viewWithTag:10];
    UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)[cell viewWithTag:20];
    if (self.isLoadingData && !self.isNetworkError) {
        button.hidden = YES;
        spinner.hidden = NO;
        [spinner startAnimating];
    }
    //    else if (self.isNetworkError) {
    //        button.hidden = NO;
    //        spinner.hidden = YES;
    //        [spinner stopAnimating];
    //        if (self.noMoreData) {
    //            [button setTitle:NSLocalizedString(@"NetworkErrorTitleLKey", nil) forState:UIControlStateNormal];
    //            [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    //            button.enabled = NO;
    //        }
    ////        else {
    ////            [button setTitle:NSLocalizedString(@"MoreResultsLKey", nil) forState:UIControlStateNormal];
    ////            [button setTitleColor:self.applicationContext.settings.moreResultsButtonColor forState:UIControlStateNormal];
    ////            button.enabled = YES;
    ////        }
    //    }
    else if (!self.isNetworkError) {
        button.hidden = NO;
        spinner.hidden = YES;
        [spinner stopAnimating];
        if (self.noMoreData) {
            [button setTitle:NSLocalizedString(@"NoMoreResultsLKey", nil) forState:UIControlStateNormal];
            [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            button.enabled = NO;
        } else {
            [button setTitle:NSLocalizedString(@"MoreResultsLKey", nil) forState:UIControlStateNormal];
            [button setTitleColor:self.applicationContext.settings.moreResultsButtonColor forState:UIControlStateNormal];
            button.enabled = YES;
        }
    } else if (self.isNetworkError) {
        button.hidden = YES;
        spinner.hidden = YES;
    }
    //    NSLog(@"</updateMoreButtonCell");
}

//- (void)tapImage:(UITapGestureRecognizer *)gesture {
//    UIImageView* imageView = (UIImageView*)gesture.view;
//    self.selectedIndex = [(NSNumber*)imageView.property integerValue];
//    SHPShop *selectedShop = [self.shops objectAtIndex:self.selectedIndex];
//    self.tapHandler(selectedShop, self.selectedIndex);
//}


// END TABLEVIEW

-(void)disposeResources {
    NSLog(@"...........>>>>>> DISPOSING LIST USERS <<<<<<..........");
    self.loader.userDC.delegate = nil;
    [self.loader cancelOperation];
    [self terminatePendingImageConnections];
}

-(void)dealloc {
    NSLog(@"...........DEALLOCATING USERS TABLE LIST.......");
}

@end
