//
//  SHPChatSelectGroupMembers.m
//  Smart21
//
//  Created by Andrea Sponziello on 26/03/15.
//
//

#import "SHPChatSelectGroupMembers.h"
#import "SHPSearchUsersLoader.h"
#import "SHPApplicationContext.h"
#import "SHPUserDC.h"
#import "SHPUser.h"
#import "SHPImageDownloader.h"
#import "SHPModalCallerDelegate.h"
#import "SHPImageUtil.h"
#import "SHPCaching.h"
#import "UIView+Property.h"

@implementation SHPChatSelectGroupMembers

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Aggiungi Membri";
    self.users = nil;
    
    self.imageCache = self.applicationContext.smallImagesCache;
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    NSLog(@"tableView %@", self.tableView);
    
    self.searchBar.delegate = self;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self restoreMembers];
    NSLog(@"Current RECENTS...");
    for (SHPUser *u in self.members) {
        NSLog(@"recent-user %@", u.username);
    }
    
    [self.searchBar becomeFirstResponder];
    
    [self enableCreateButton];
}

//-(void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
//    NSLog(@"VIEW WILL DISAPPEAR...");
//    if (self.isMovingFromParentViewController) {
//        NSLog(@"VIEW WILL DISAPPEAR...DISMISSING..");
//        [self disposeResources];
//    }
}

-(void)disposeResources {
    self.userDC.delegate = nil;
    NSLog(@"Disposing userDC...");
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
        NSLog(@"rows %ld", num);
        return num;
    } else if (self.members && self.members > 0) {
        NSInteger num = self.members.count;
        NSLog(@"rows %ld", num);
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
        
        UIImageView *iv = (UIImageView *) [cell viewWithTag:1];
        NSString *imageURL = [SHPUser photoUrlByUsername:user.username];
        if(![self.imageCache getImage:imageURL]) {
            [self startIconDownload:user forIndexPath:indexPath];
            // if a download is deferred or in progress, return a placeholder image
            //            iv.image = [UIImage imageNamed:@"grid-big-empty-image.png"];
            iv.image = nil;
        } else {
            iv.image = [self.imageCache getImage:imageURL];
        }
        
        // is just a member'
        
        if(![self userIsMember:user])
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.userInteractionEnabled = YES;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
        }
        
    } else {
        // show members
        
        long userIndex = indexPath.row;
        SHPUser *user = [self.members objectAtIndex:userIndex];
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserMemberCell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        //remove member button
        UIButton *removeButton = (UIButton *)[cell viewWithTag:4];
        NSLog(@"REMOVE BUTTON %@", removeButton);
        [removeButton addTarget:self action:@selector(removeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        removeButton.property = user.username; //[NSNumber numberWithInt:(int)indexPath.row];
        
        UILabel *fullnameLabel = (UILabel *) [cell viewWithTag:2];
        UILabel *usernameLabel = (UILabel *) [cell viewWithTag:3];
        fullnameLabel.text = user.fullName;
        usernameLabel.text = user.username;
        
        UIImageView *iv = (UIImageView *) [cell viewWithTag:1];
        NSString *imageURL = [SHPUser photoUrlByUsername:user.username];
        if(![self.imageCache getImage:imageURL]) {
            [self startIconDownload:user forIndexPath:indexPath];
            // if a download is deferred or in progress, return a placeholder image
            //            iv.image = [UIImage imageNamed:@"grid-big-empty-image.png"];
            iv.image = nil;
        } else {
            iv.image = [self.imageCache getImage:imageURL];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger userIndex = indexPath.row;
    SHPUser *selectedUser = nil;
    if (self.users) {
        selectedUser = [self.users objectAtIndex:userIndex];
        [self addGroupMember:selectedUser];
        [self dismissUsersMode];
//        self.users = nil; // dismiss users list & show members list
//        [self.tableView reloadData];
//        self.searchBar.text = @"";
    }
}

-(void)dismissUsersMode {
    self.users = nil; // dismiss users list & enable show members list
    [self.tableView reloadData];
    self.searchBar.text = @"";
    self.tableView.allowsSelection = NO;
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
        self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(userPaused:) userInfo:nil repeats:NO];
    } else {
        // test reset. show "members" or nothing
        NSLog(@"show members...");
        [self dismissUsersMode];
//        self.users = nil;
//        [self.tableView reloadData];
    }
}

-(void) userPaused:(NSTimer *)timer {
    NSLog(@"(SHPSearchViewController) userPaused:");
    NSString *text = self.searchBar.text;
    self.textToSearch = [self prepareTextToSearch:text];
    NSLog(@"timer on userPaused: searching for %@", self.textToSearch);
    
    self.userDC = [[SHPUserDC alloc] init];
    self.userDC.delegate = self;
    [self.userDC searchByText:self.textToSearch location:nil page:0 pageSize:30 withUser:self.applicationContext.loggedUser];
}

-(NSString *)prepareTextToSearch:(NSString *)text {
    return [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}
// DC delegate

- (void)usersDidLoad:(NSMutableArray *)__users error:(NSError *)error {
    NSLog(@"USERS LOADED OK!");
    if (error) {
        NSLog(@"Error loading users!");
    }
    // remove group's admin
//    int i = 0;
//    for (SHPUser *user in __users) {
//        if ([user.username isEqualToString:self.applicationContext.loggedUser.username]) {
//            NSLog(@"Admin user %@ removed.", user.username);
//            [__users removeObjectAtIndex:i];
//        }
//        i++;
//    }
    for (int i=0; i < __users.count; i++) {
        SHPUser *user = [__users objectAtIndex:i];
        if ([user.username isEqualToString:self.applicationContext.loggedUser.username]) {
            NSLog(@"Admin user %@ removed.", user.username);
            [__users removeObjectAtIndex:i];
            break;
        }
    }
    self.users = __users;
    self.tableView.allowsSelection = YES;
    [self.tableView reloadData];
}

-(void)networkError {
    NSString *title = NSLocalizedString(@"NetworkErrorTitleLKey", nil);
    NSString *msg = NSLocalizedString(@"NetworkErrorLKey", nil);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


// dismiss modal

- (IBAction)CancelAction:(id)sender {
    NSLog(@"dismiss %@", self.modalCallerDelegate);
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

- (void)startIconDownload:(SHPUser *)user forIndexPath:(NSIndexPath *)indexPath
{
    NSString *imageURL = [SHPUser photoUrlByUsername:user.username];
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

// members

-(void)restoreMembers {
    self.members = (NSMutableArray *) [self.applicationContext getVariable:@"groupMembers"];
    if (!self.members) {
        self.members = [[NSMutableArray alloc] init];
        [self.applicationContext setVariable:@"groupMembers" withValue:self.members];
    }
}

-(void)addGroupMember:(SHPUser *)user {
    NSLog(@"............ADDING.... member %@", user.username);
    [self.members addObject:user];
    [self enableCreateButton];
}

-(BOOL)userIsMember:(SHPUser *) user {
    for (SHPUser *u in self.members) {
        if ([u.username isEqualToString:user.username]) {
            return YES;
        }
    }
    return NO;
}

-(void)removeButtonPressed:(id)sender {
    NSLog(@"removeButtonPressed!");
    
    UIButton *button = (UIButton *)sender;
    NSString *username = (NSString *)button.property;
    
    int username_found_at_index = -1;
    int index = 0;
    for (SHPUser *u in self.members) {
        if ([u.username isEqualToString:username]) {
            NSLog(@"usr found at index %d", index);
            username_found_at_index = index;
        }
        index++;
    }
    
    if (username_found_at_index >= 0) {
        [self.members removeObjectAtIndex:username_found_at_index];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:username_found_at_index inSection:0];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
        [self enableCreateButton];
    }
    else {
        NSLog(@"ERROR: username_found_at_index can't be -1");
    }
    
}

-(void)enableCreateButton {
    if (self.members.count == 0) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

// scroll delegate

// Somewhere in your implementation file:
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

// end

-(void)dealloc {
    NSLog(@"SEARCH USERS VIEW DEALLOCATING...");
}

- (IBAction)createGroupAction:(id)sender {
    NSLog(@"Creating group... %@", self.applicationContext);
    
    NSLog(@"Creating group... %@", [self.applicationContext getVariable:@"groupName"]);
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    [options setObject:self.members forKey:@"groupMembers"];
    [options setObject:[self.applicationContext getVariable:@"groupName"] forKey:@"groupName"];
    [self.applicationContext removeVariable:@"groupMembers"];
    [self.applicationContext removeVariable:@"groupName"];
    [self.view endEditing:YES]; // or [self.searchBar resignFirstResponder];
    [self.modalCallerDelegate setupViewController:self didFinishSetupWithInfo:options];
}

@end
