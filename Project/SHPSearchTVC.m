//
//  SHPSearchTVC.m
//  MyDolly2
//
//  Created by dario de pascalis on 03/06/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import "SHPSearchTVC.h"
#import "SHPAppDelegate.h"
#import "SHPApplicationContext.h"
#import "SHPComponents.h"
#import "SHPUser.h"
#import "SHPProduct.h"
#import "SHPShop.h"
#import "SHPStringUtil.h"
#import "SHPConstants.h"
#import "SHPImageUtil.h"
#import "SHPHomeProfileTVC.h"
#import "SHPPoiDetailTVC.h"
#import "SHPProductDetail.h"

@interface SHPSearchTVC ()
@end

@implementation SHPSearchTVC
NSInteger TAG_IMAGE_CELL = 104;

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    [self initSearchController];
    self.arraySearch = [[NSMutableArray alloc]init];
    searchStartPage = 0;
    searchPageSize = 20;
    isLoadingData = NO;
    noMoreData = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"SHPSearchTVC----------------- viewDidAppear %@", self.searchController.searchBar);
    //[self.searchController.searchBar becomeFirstResponder];
    //[self searchBarTextDidBeginEditing:self.searchController.searchBar];
    self.searchController.active = YES;
//    [self.searchController becomeFirstResponder];
//    [self.searchController.searchBar becomeFirstResponder];
//    
    //self.searchController.searchBar.placeholder = self.searchBarPlaceholder;
    //NSString *trackerName = [[NSString alloc] initWithFormat:@"SearcPage: %@", self.searchBar.text];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
}

-(void)initSearchController{
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    singlePoi=[[settingsDictionary objectForKey:@"singlePoi"] boolValue];
    NSDictionary *navigationBarDictionary = [self.applicationContext.plistDictionary  objectForKey:@"BarTab"];
    tintColor = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"tintColor"]];
    
    NSMutableArray *arrayButtonTitles =  [[NSMutableArray alloc] init];
    [arrayButtonTitles addObject:NSLocalizedString(@"SearchProductsButtonLKey",nil)];
    if(singlePoi == NO){
        [arrayButtonTitles addObject:NSLocalizedString(@"SearchShopsButtonLKey",nil)];
    }
    [arrayButtonTitles addObject:NSLocalizedString(@"SearchUsersButtonLKey",nil)];
   
    
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    // TODO movetosettings
//    self.searchController.searchBar.scopeButtonTitles = arrayButtonTitles;
    self.searchController.searchBar.delegate = self;
    self.searchController.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    
    
    [self.searchController.searchBar setScopeBarButtonTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:tintColor, NSForegroundColorAttributeName, nil] forState:UIControlStateNormal];
    [self.searchController.searchBar setScopeBarButtonTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, nil] forState:UIControlStateSelected];
    
    [self.searchController.searchBar setScopeBarButtonBackgroundImage:[SHPImageUtil imageWithColor:tintColor] forState:UIControlStateSelected];
    [self.searchController.searchBar setScopeBarButtonBackgroundImage:[SHPImageUtil imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
    
    [self.searchController.searchBar setScopeBarButtonDividerImage:[SHPImageUtil imageWithColor:tintColor] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal];
    
    if(singlePoi){
        self.searchBarPlaceholder = NSLocalizedString(@"SearchPlaceholderLKey", nil);
    }
    else {
        self.searchBarPlaceholder = NSLocalizedString(@"SearchProductsShopsUsersLKey", nil);
    }
    self.searchController.searchBar.placeholder = self.searchBarPlaceholder;
    
}



- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    NSLog(@"----------------- selectedScopeButtonIndexDidChange:: %@",self.searchController.searchBar.text);
    [self updateSearchResultsForSearchController:self.searchController];
}

- (void)didPresentSearchController:(UISearchController *)searchController
{
    [self.searchController.searchBar becomeFirstResponder];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    NSLog(@"----------------- searchBarTextDidBeginEditing");
    //self.UISearchController.searchBar.text = @"";
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"----------------- CITY textDidChange: %@",searchText);
    if(searchText.length >1){
        [self searchForText];
    }
    else{
        [self stopDelegate];
        self.arraySearch = [[NSMutableArray alloc]init];
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"----------------- CITY searchBarCancelButtonClicked: %@",searchBar);
    [self stopDelegate];
    self.arraySearch = [[NSMutableArray alloc]init];
    [self.tableView reloadData];
    self.navigationItem.hidesBackButton = NO;
}


//----------------------------------------------------------------//
//START TABLEVIEW
//----------------------------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"------------------------ numberOfRowsInSection: %d",(int)self.arraySearch.count+1);
    NSString *text = [self prepareTextToSearch:self.searchController.searchBar.text];
    if(text.length>1){
        return self.arraySearch.count+1;
    }
    return self.arraySearch.count;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(listMode == 0){
        return 55.0;
    }
    else if(listMode == 1 && singlePoi == NO){
        return 44.0;
    }
    else {
        return 44.0;
    }
    //CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    //NSLog(@"Section h %f", rowHeight);
    //return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier;
    UITableViewCell *cell;
    if(self.arraySearch.count==0 && isLoadingData == YES){
        //cella nessun risultato
        NSLog(@"CellLoading %d",(int)self.arraySearch.count );
        CellIdentifier = @"CellLoading";
    }
    else if(self.arraySearch.count==0){
        //cella nessun risultato
        NSLog(@"CellNoItems %d",(int)self.arraySearch.count );
        CellIdentifier = @"CellNoItems";
    }
    else if(self.arraySearch.count > indexPath.row){
        //celle risultati
        listMode = self.searchController.searchBar.selectedScopeButtonIndex;
        if(listMode == 0){
            //SEARCH PRODUCTS
            CellIdentifier = @"CellProduct";
            //END SEARH PRODUCTS
        }
        else if(listMode == 1 && singlePoi == NO){
            //SEARCH SHOPS
            CellIdentifier = @"CellShop";
            //END SEARH SHOPS
        }
        else {
            //SEARCH USERS
            CellIdentifier = @"CellUser";
            //END SEARH USERS
        }
    }
    else if(noMoreData == YES){
        //cella fine
        NSLog(@"CellLast %d - %d - %d",(int)self.arraySearch.count, (int)indexPath.row, noMoreData  );
        CellIdentifier = @"CellLast";
    }
    else{
        //cella more
        NSLog(@"CellMore %d",(int)self.arraySearch.count );
        CellIdentifier = @"CellMore";
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    //cell.textLabel.text = [NSString stringWithFormat:@"%@",titleText];
    if([CellIdentifier isEqualToString:@"CellLoading"]){
        //cella nessun risultato
        UIActivityIndicatorView *loading = (UIActivityIndicatorView *)[cell viewWithTag:101];
        [loading startAnimating];
    }
    else if([CellIdentifier isEqualToString:@"CellNoItems"]){
        //cella nessun risultato
        NSString *titleText;
        UILabel *noItemsLabel = (UILabel *)[cell viewWithTag:101];
        titleText = NSLocalizedString(@"NoItemsLKey", nil);
        noItemsLabel.text = titleText;
    }
    else if([CellIdentifier isEqualToString:@"CellProduct"]){
        //SEARCH PRODUCTS
        NSString *titleText;
        
        UILabel *title = (UILabel *)[cell viewWithTag:101];
        UILabel *distance = (UILabel *)[cell viewWithTag:102];
        UILabel *price = (UILabel *)[cell viewWithTag:103];
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:TAG_IMAGE_CELL];
        
        SHPProduct *product = [self.arraySearch objectAtIndex:indexPath.row];
        if(product.title.length>0){
            titleText = [[NSString alloc]  initWithFormat:@"%@", [SHPStringUtil stringWithSentenceCapitalization:product.title]];
        }else{
            if(product.longDescription.length>MAX_CHARACTERS_TITLE){
                NSString *newTitle = [product.longDescription substringToIndex:MAX_CHARACTERS_TITLE];
                titleText = [[NSString alloc]  initWithFormat:@"%@", [SHPStringUtil stringWithSentenceCapitalization:newTitle]];
                titleText = [titleText stringByAppendingString:@"..."];
            }else{
                titleText = [[NSString alloc]  initWithFormat:@"%@", [SHPStringUtil stringWithSentenceCapitalization:product.longDescription]];
            }
        }
        title.text = titleText;
        distance.text = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"toKey", nil), product.distance];
        price.text = @"";
        NSString *trimmedStartPrice = [product.startprice stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if([trimmedStartPrice floatValue]>0){
            NSString *currency = product.currency ? NSLocalizedString(product.currency, nil) : NSLocalizedString(@"euro", nil);
            NSString *startPrice = [[NSString alloc] initWithFormat:@"( %@ %.2f )",currency, [trimmedStartPrice floatValue]];
            price.text = startPrice;
        }
        //******************* IMAGE ****************
        UIImage *cached_image = [self.applicationContext.smallImagesCache getImage:product.imageURL];
        if(!cached_image) {
            imageView.image = nil;
            CGFloat width = imageView.frame.size.width;
            CGFloat height = imageView.frame.size.width;
            NSDictionary *sizeImage = @{@"width" : [NSNumber numberWithInt:width], @"height" : [NSNumber numberWithInt:height]};
            [self startIconProductDownload:product forIndexPath:indexPath sizeImage:sizeImage];
        } else {
            imageView.image = cached_image;
        }
        //END SEARH PRODUCTS
    }
    else if([CellIdentifier isEqualToString:@"CellShop"]){
        //SEARCH SHOPS
        NSString *titleText;
        NSString *addressText;
        //NSString *distanceText;
        UILabel *title = (UILabel *)[cell viewWithTag:101];
        UILabel *address = (UILabel *)[cell viewWithTag:102];
        SHPShop *shop = [self.arraySearch objectAtIndex:indexPath.row];
        if(shop.name.length>0){
            titleText = [[NSString alloc]  initWithFormat:@"%@", [SHPStringUtil stringWithSentenceCapitalization:shop.name]];
        }
        if(shop.formattedAddress.length>0){
            addressText = [[NSString alloc]  initWithFormat:@"%@", [SHPStringUtil stringWithSentenceCapitalization:shop.formattedAddress]];
        }
        title.text = titleText;
        address.text = addressText;
        //END SEARH SHOPS
    }
    else if([CellIdentifier isEqualToString:@"CellUser"]){
        //SEARCH USERS
        NSString *fullnameText;
        NSString *usernameText;
        UILabel *fullname = (UILabel *)[cell viewWithTag:101];
        UILabel *username = (UILabel *)[cell viewWithTag:102];
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:TAG_IMAGE_CELL];
        SHPUser *user = [self.arraySearch objectAtIndex:indexPath.row];
        if(user.username.length>0){
            usernameText = [[NSString alloc]  initWithFormat:@"%@", [SHPStringUtil stringWithSentenceCapitalization:user.username]];
        }
        if(user.fullName.length>0){
            fullnameText = [[NSString alloc]  initWithFormat:@"%@", [SHPStringUtil stringWithSentenceCapitalization:user.fullName]];
        }
        fullname.text = fullnameText;
        username.text = usernameText;
        //******************* IMAGE ****************
        CALayer * layer = [imageView layer];
        [layer setMasksToBounds:YES];
        layer.cornerRadius = 5.0;
        
        NSString *imageURL = [SHPUser photoUrlByUsername:user.username];
        UIImage *cached_image = [self.applicationContext.smallImagesCache getImage:imageURL];
        if(!cached_image) {
            imageView.image = nil;
            CGFloat width = imageView.frame.size.width;
            CGFloat height = imageView.frame.size.width;
            NSDictionary *sizeImage = @{@"width" : [NSNumber numberWithInt:width], @"height" : [NSNumber numberWithInt:height]};
            [self startIconUserDownload:user forIndexPath:indexPath sizeImage:sizeImage];
        } else {
            imageView.image = cached_image;
        }
        //END SEARH USERS
    }
    else if([CellIdentifier isEqualToString:@"CellLast"]){
        //cella fine
        //NSLog(@"CellLast %d - %d - %d",(int)self.arraySearch.count, (int)indexPath.row, noMoreData  );
    }
    else{
        //cella more
        //NSLog(@"CellMore %d",(int)self.arraySearch.count );
        NSString *titleText;
        UILabel *moreLabel = (UILabel *)[cell viewWithTag:101];
        titleText = NSLocalizedString(@"MoreResultsLKey", nil);
        moreLabel.text = titleText;
    }

    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    //NSLog(@"----------------- didSelectRowAtIndexPath: %@ - %@",indexPath, [cell reuseIdentifier]);
    NSString *identifier = [cell reuseIdentifier];
    selectedIndex=indexPath.row;
    if([identifier isEqualToString:@"CellMore"]){
        [self searchMore];
    }
    else if([identifier isEqualToString:@"CellProduct"]){
        [self performSegueWithIdentifier:@"toProductDetail" sender:self];
    }
    else if([identifier isEqualToString:@"CellShop"]){
        [self performSegueWithIdentifier:@"toShopDetail" sender:self];
    }
    else if([identifier isEqualToString:@"CellUser"]){
        //NSLog(@"OK toProfileUser");
        //[self performSegueWithIdentifier:@"toProfileUser" sender:self];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
        UINavigationController *nc = [sb instantiateViewControllerWithIdentifier:@"navigationProfile"];
        SHPHomeProfileTVC *VC = (SHPHomeProfileTVC *)[[nc viewControllers] objectAtIndex:0];
        VC.applicationContext = self.applicationContext;
        VC.user = [self.arraySearch objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:VC animated:YES];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"[segue identifier]: %@",[segue identifier]);
    if ([[segue identifier] isEqualToString:@"toShopDetail"]) {
       
        SHPShop *shop = [[SHPShop alloc] init];
        shop = [self.arraySearch objectAtIndex:selectedIndex];
        //shop.coverImage = [self.applicationContext.mainListImageCache getImage:shop.coverImageURL];
        //NSLog(@"toShopDetail %@ - %@", shop, shop.coverImageURL);
        SHPPoiDetailTVC *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.shop = shop;
    }
    else if ([[segue identifier] isEqualToString:@"toProductDetail"]) {
        //NSLog(@"toProductDetail");
        SHPProduct *product = [[SHPProduct alloc] init];
        product = [self.arraySearch objectAtIndex:selectedIndex];
        SHPProductDetail *vc = [segue destinationViewController];
        vc.product = product;
        NSLog(@"product %@ - %f:%f", product, product.shopLat, product.shopLon);
        vc.applicationContext = self.applicationContext;
    }
}
//----------------------------------------------------------------//
//END TABLEVIEW
//----------------------------------------------------------------//



//----------------------------------------------------------------//
//START FUNCTIONS SEARCH
//----------------------------------------------------------------//

-(NSString *)prepareTextToSearch:(NSString *)text {
    return [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    //NSLog(@"----------------- updateSearchResultsForSearchController:: %d",(int)self.searchController.searchBar.selectedScopeButtonIndex);
    if(self.searchController.searchBar.text.length>1){
        [self searchForText];
    }else{
        [self stopDelegate];
        self.arraySearch = [[NSMutableArray alloc]init];
        [self.tableView reloadData];
    }
}

-(void)searchForText{
    NSString *text = [self prepareTextToSearch:self.searchController.searchBar.text];
    [self stopDelegate];
    self.arraySearch = [[NSMutableArray alloc]init];
    searchStartPage = 0;
    [self checkMode:text];
}

-(void)searchMore{
    NSString *text = [self prepareTextToSearch:self.searchController.searchBar.text];
    //NSLog(@"searchMode %d",(int)listMode);
    [self stopDelegate];
    searchStartPage = searchStartPage + 1;
    [self checkMode:text];
}

-(void)checkMode:(NSString*)text{
    listMode = self.searchController.searchBar.selectedScopeButtonIndex;
    if(listMode == 0){
        [self searchProducts:text];
    }
    else if(listMode == 1 && singlePoi == NO){
        [self searchShops:text];
    }
    else if(listMode == 1 && singlePoi == YES){
        [self searchUsers:text];
    }
    else if(listMode == 2){
        [self searchUsers:text];
    }
    [self.tableView reloadData];
}
//----------------------------------------------------------------//
//END FUNCTIONS SEARCH
//----------------------------------------------------------------//

//-----------------------------------------------------------------//
//START LOAD PRODUCTS
//-----------------------------------------------------------------//
-(void)searchProducts:text {
    //NSLog(@"searchProducts");
    isLoadingData = YES;
    self.productDC = [[SHPProductDC alloc] init];
    self.productDC.delegate = self;
    if (self.applicationContext.searchLocation) {
        searchLocation = self.applicationContext.searchLocation;
    } else {
        searchLocation = self.applicationContext.lastLocation;
    }
    authUser = self.applicationContext.loggedUser;
    searchPageSize = self.applicationContext.settings.productsTablePageSize;
    [self.productDC searchByText:text location:searchLocation page:searchStartPage pageSize:searchPageSize withUser:authUser];
}

//DELEGATE searchProducts
- (void)loaded:(NSArray *)loadedProducts {
    noMoreData = NO;
    isLoadingData = NO;
    //NSLog(@"loadedProducts: %@",loadedProducts);
    if (loadedProducts.count > 0) {
        if (!self.arraySearch) {
            self.arraySearch = [[NSMutableArray alloc] init];
        }
        [self.arraySearch addObjectsFromArray:loadedProducts];
        if (loadedProducts.count < searchPageSize) {
            noMoreData = YES;
            //NSLog(@"noMoreData...");
        }
        [self.tableView reloadData];
    }
    else if(loadedProducts.count == 0 && self.arraySearch.count == 0) {
        if (!self.arraySearch) {
            self.arraySearch = [[NSMutableArray alloc] init];
        }
        [self.tableView reloadData];
    }
    else if (loadedProducts.count == 0) {
        noMoreData = YES;
    }
    //[self updateMoreButtonCell:moreCell];
    [self.tableView reloadData];
}

-(void)networkError {
    //[self.refreshControl endRefreshing];
//    if (!self.products) {
//        self.products = [[NSMutableArray alloc] init];
//    }
//    [self.tableView reloadData];
    
    NSString *title = NSLocalizedString(@"NetworkErrorTitleLKey", nil);
    NSString *msg = NSLocalizedString(@"NetworkErrorLKey", nil);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    isLoadingData = NO;
    searchStartPage = searchStartPage - 1;
    if(searchStartPage<0){
        searchStartPage = 0;
    }
    // reset to previous page
    //UITableViewCell *moreCell = [self moreButtonCell];
    //[self updateMoreButtonCell:moreCell];
}
//----------------------------------------------------------------//
//END LOAD PRODUCTS
//----------------------------------------------------------------//

//-----------------------------------------------------------------//
//START LOAD SHOPS
//-----------------------------------------------------------------//
-(void)searchShops:text {
    //NSLog(@"searchProducts");
    isLoadingData = YES;
    self.shopDC = [[SHPShopDC alloc] init];
    self.shopDC.shopsLoadedDelegate = self;
    if (self.applicationContext.searchLocation) {
        searchLocation = self.applicationContext.searchLocation;
    } else {
        searchLocation = self.applicationContext.lastLocation;
    }
    searchPageSize = self.applicationContext.settings.productsTablePageSize;
    [self.shopDC searchByText:text location:searchLocation page:searchStartPage pageSize:searchPageSize withUser:nil];
}

//DELEGATE searchShops
- (void)shopsLoaded:(NSArray *)loadedShops {
    isLoadingData = NO;
    noMoreData = NO;
    //NSLog(@"loadedShops: %@",loadedShops);
    if (loadedShops.count > 0) {
        if (!self.arraySearch) {
            self.arraySearch = [[NSMutableArray alloc] init];
        }
        [self.arraySearch addObjectsFromArray:loadedShops];
        if (loadedShops.count < searchPageSize) {
            noMoreData = YES;
            //NSLog(@"noMoreData...");
        }
        [self.tableView reloadData];
    }
    else if(loadedShops.count == 0 && self.arraySearch.count == 0) {
        if (!self.arraySearch) {
            self.arraySearch = [[NSMutableArray alloc] init];
        }
        [self.tableView reloadData];
    }
    else if (loadedShops.count == 0) {
        noMoreData = YES;
    }
    //[self updateMoreButtonCell:moreCell];
    [self.tableView reloadData];
}
//----------------------------------------------------------------//
//END LOAD SHOPS
//----------------------------------------------------------------//


//-----------------------------------------------------------------//
//START LOAD USERS
//-----------------------------------------------------------------//
-(void)searchUsers:text {
    isLoadingData = YES;
    self.userDC = [[SHPUserDC alloc] init];
    self.userDC.delegate = self;
    if (self.applicationContext.searchLocation) {
        searchLocation = self.applicationContext.searchLocation;
    } else {
        searchLocation = self.applicationContext.lastLocation;
    }
    searchPageSize = self.applicationContext.settings.productsTablePageSize;
    [self.userDC searchByText:text location:searchLocation page:searchStartPage pageSize:searchPageSize withUser:nil];
}

//DELEGATE searchUsers
-(void)usersDidLoad:(NSArray *)users error:(NSError *)error {
    isLoadingData = NO;
    noMoreData = NO;
    //NSLog(@"usersDidLoad: %@",users);
    if (users.count > 0) {
        if (!self.arraySearch) {
            self.arraySearch = [[NSMutableArray alloc] init];
        }
        [self.arraySearch addObjectsFromArray:users];
        if (users.count < searchPageSize) {
            noMoreData = YES;
            //NSLog(@"noMoreData...");
        }
        [self.tableView reloadData];
    }
    else if(users.count == 0 && self.arraySearch.count == 0) {
        if (!self.arraySearch) {
            self.arraySearch = [[NSMutableArray alloc] init];
        }
        [self.tableView reloadData];
    }
    else if (users.count == 0) {
        noMoreData = YES;
    }
    //[self updateMoreButtonCell:moreCell];
    [self.tableView reloadData];
}
//----------------------------------------------------------------//
//END LOAD USERS
//----------------------------------------------------------------//

//----------------------------------------------------------------//
//START LOAD IMAGE PRODUCT
//----------------------------------------------------------------//
//iconProductDownloader.imageWidth = (int)self.applicationContext.settings.mainListImageWidth;
//iconProductDownloader.imageHeight = (int)self.applicationContext.settings.mainListImageHeight;

- (void)startIconUserDownload:(SHPUser *)user forIndexPath:(NSIndexPath *)indexPath sizeImage:(NSDictionary *)sizeImage
{
    NSString *imageURL = [SHPUser photoUrlByUsername:user.username];
    iconUserDownloader = [imageDownloadsInProgress objectForKey:imageURL];
    if (iconUserDownloader == nil)
    {
        iconUserDownloader = [[SHPImageDownloader alloc] init];
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [options setObject:indexPath forKey:@"indexPath"];
        iconUserDownloader.options = options;
        iconUserDownloader.imageURL = imageURL;
        iconUserDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconUserDownloader forKey:imageURL];
        iconUserDownloader.imageWidth = [[sizeImage objectForKey:@"width"] floatValue];
        iconUserDownloader.imageHeight = [[sizeImage objectForKey:@"height"] floatValue];
        [iconUserDownloader startDownload];
    }
}


- (void)startIconProductDownload:(SHPProduct *)product forIndexPath:(NSIndexPath *)indexPath sizeImage:(NSDictionary *)sizeImage
{
    iconProductDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconProductDownloader == nil)
    {
        iconProductDownloader = [[SHPImageDownloader alloc] init];
        NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
        [options setObject:indexPath forKey:@"indexPath"];
        iconProductDownloader.options = options;
        iconProductDownloader.imageURL = product.imageURL;
        iconProductDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconProductDownloader forKey:indexPath];
        iconProductDownloader.imageWidth = [[sizeImage objectForKey:@"width"] floatValue];
        iconProductDownloader.imageHeight = [[sizeImage objectForKey:@"height"] floatValue];
        //NSLog(@"iconProductDownloader.imageWidth: %d - iconProductDownloader.imageHeight: %d", iconProductDownloader.imageWidth, iconProductDownloader.imageHeight);
        [iconProductDownloader startDownload];
    }
}

// DELEGATE startIconUserDownload and startIconProductDownload when an icon is ready to be displayed
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
            UIImageView *iv = (UIImageView *)[cell viewWithTag:TAG_IMAGE_CELL];
            iv.image = image;
            // animate fade image set
            [UIView transitionWithView:iv
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{iv.image = image;}
                            completion:NULL];
        }
    }
    [imageDownloadsInProgress removeObjectForKey:imageURL];
}

//----------------------------------------------------------------//
//END LOAD IMAGE PRODUCT
//----------------------------------------------------------------//



-(void)stopDelegate{
    [self.shopDC setShopsLoadedDelegate:nil];
    self.productDC.delegate = nil;
    self.userDC.delegate = nil;
    iconProductDownloader.delegate = nil;
    iconUserDownloader.delegate = nil;
    [imageDownloadsInProgress removeAllObjects];
    //[imageUserDownloadsInProgress removeAllObjects];
}

-(void)dealloc{
    NSLog(@"DEALLOC");
    self.searchController.searchBar.delegate = nil;
    [self stopDelegate];
}

@end
