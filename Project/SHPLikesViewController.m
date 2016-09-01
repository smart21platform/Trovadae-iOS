//
//  SHPLikesViewController.m
//  Ciaotrip
//
//  Created by Dario De Pascalis on 14/02/14.
//
//

#import "SHPLikesViewController.h"
#import "SHPUsersLoaderStrategy.h"
#import "SHPUser.h"
#import "SHPApplicationContext.h"
#import "SHPImageDownloader.h"
#import "SHPComponents.h"
#import "SHPHomeProfileTVC.h"

@interface SHPLikesViewController ()

@end

@implementation SHPLikesViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [SHPComponents titleLogoForViewController:self];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    [self loadUsers];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self disposeResources];
}

-(void)loadUsers {
    self.isLoadingData = YES;
    self.isNetworkError = NO;
    [self.loader loadUsers];
}

- (void)usersDidLoad:(NSArray *)__users error:(NSError *)error {
    NSLog(@"USERS LOADED OK!");
    self.isLoadingData = NO;
    if (error) {
        self.isNetworkError = YES;
    }
    if (!self.users) {
        self.users = [[NSMutableArray alloc] init];
    }
    [self.users addObjectsFromArray:__users];
    // if paging active...
//    if (__users.count == 0 || __users.count < self.loader.searchPageSize) {
//        self.noMoreData = TRUE;
//    }
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.users) {
        return self.users.count;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *userCell = @"userCell";
    static NSString *infoCell = @"infoCell";
    UITableViewCell *cell;
    if (self.users && self.users.count > 0) {
        NSLog(@"A");
        SHPUser *user = [self.users objectAtIndex:indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:userCell forIndexPath:indexPath];
        UIImageView *imgv = (UIImageView *)[cell viewWithTag:1];
        CALayer * layer = [imgv layer];
        [layer setMasksToBounds:YES];
        layer.cornerRadius = 5.0;
        
        NSString *imageURL = [SHPUser photoUrlByUsername:user.username];
        UIImage *cached_image = [self.applicationContext.smallImagesCache getImage:imageURL];
        if(!cached_image) {
            [self startIconDownload:user forIndexPath:indexPath];
            // if a download is deferred or in progress, return a placeholder image
            //  imgv.image = [UIImage imageNamed:@"grid-big-empty-image.png"];
        } else {
            imgv.image = cached_image;
        }
        UILabel *username = (UILabel *)[cell viewWithTag:2];
        username.text = user.username;
        UILabel *fullName = (UILabel *)[cell viewWithTag:3];
        fullName.text = user.fullName;
    } else if (self.users && self.users.count == 0) {
        NSLog(@"B");
        cell = [tableView dequeueReusableCellWithIdentifier:infoCell forIndexPath:indexPath];
        UILabel *msgLabel = (UILabel *)[cell viewWithTag:1];
        msgLabel.text = @"TRANSLATE: Empty users";
    } else if (self.isLoadingData) {
        NSLog(@"C");
        cell = [tableView dequeueReusableCellWithIdentifier:infoCell forIndexPath:indexPath];
        UILabel *msgLabel = (UILabel *)[cell viewWithTag:1];
        msgLabel.text = NSLocalizedString(@"LoadingLKey", nil);
    } else { // error
        NSLog(@"D");
        cell = [tableView dequeueReusableCellWithIdentifier:infoCell forIndexPath:indexPath];
        UILabel *msgLabel = (UILabel *)[cell viewWithTag:1];
        msgLabel.text = NSLocalizedString(@"NetworkErrorTitleLKey", nil);
    }
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedUser = [self.users objectAtIndex:indexPath.row];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.users && self.users.count > 0) {
            UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
            UINavigationController *nc = [sb instantiateViewControllerWithIdentifier:@"navigationProfile"];
            SHPHomeProfileTVC *VC = (SHPHomeProfileTVC *)[[nc viewControllers] objectAtIndex:0];
            VC.applicationContext = self.applicationContext;
            VC.user = self.selectedUser;
            [self.navigationController pushViewController:VC animated:YES];
    }
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

// IMAGE HANDLING

-(void)terminatePendingImageConnections {
    NSLog(@"''''''''''''''''''''''   Terminate all pending IMAGE connections...");
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    for(SHPImageDownloader *obj in allDownloads) {
        obj.delegate = nil;
    }
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(UIImage *)image withURL:(NSString *)imageURL downloader:(SHPImageDownloader *)downloader
{
    [self.applicationContext.smallImagesCache addImage:image withKey:imageURL];
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

-(void)disposeResources {
    self.loader.userDC.delegate = nil;
    [self.loader cancelOperation];
    [self terminatePendingImageConnections];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
}


@end
