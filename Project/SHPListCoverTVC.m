//
//  SHPListCoverTVC.m
//  MyDolly2
//
//  Created by dario de pascalis on 27/05/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import "SHPListCoverTVC.h"
#import "SHPComponents.h"
#import "SHPAppDelegate.h"
#import "SHPApplicationContext.h"
#import "MBProgressHUD.h"
#import "SHPUser.h"
#import "SHPCategory.h"
#import "SHPProduct.h"
#import "SHPShop.h"
#import "SHPImageUtil.h"
#import "SHPConstants.h"
#import "SHPIconDownloader.h"
#import "SHPStringUtil.h"
#import "SHPComponents.h"
#import "SHPPoiDetailTVC.h"
#import "SHPProductsOnMapVC.h"
#import "SHPLikesViewController.h"
#import "SHPLikedToLoader.h"


@interface SHPListCoverTVC ()
@end

@implementation SHPListCoverTVC



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    //NSLog(@"CLASS NAME: %@", NSStringFromClass([self class]));
    
    [SHPComponents titleLogoForViewController:self];
    self.navigationController.title = nil;
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    searchStartPage = 0;
    searchPageSize = self.applicationContext.settings.mainListSearchPageSize;
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(initializeData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;

    isLoadingData = NO;
//    self.showMenuButtonView = [SHPComponents MainListShowMenuButton:self settings:self.applicationContext.settings];
    
    [self initializeData];
}




-(void)initializeData {
    [self resetData];
    [self initializeCategories];
    [self searchFirst];
}

-(void)resetData {
    NSLog(@"RESETTING DATA");
    self.products = [[NSMutableArray alloc] init];
    categoryId = nil;
    searchStartPage = 0;
    searchPageSize = self.applicationContext.settings.mainListSearchPageSize;
    noMoreData = NO;
    
    [self terminatePendingConnections];
}

//-----------------------------------------------------------------//
//START LOAD CATEGORY 'COVER'
//-----------------------------------------------------------------//
-(void)initializeCategories {
    NSLog(@"initializeCategories");
    self.categories = [[NSMutableArray alloc] init];
    
    NSArray *cachedCategories = [(NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES] copy];
    if (cachedCategories && cachedCategories.count > 0) {
        for (SHPCategory *cat in cachedCategories) {
            NSLog(@"cachedCategories %@ - %@", cat.oid, cat.type);
            if ([cat.type isEqualToString:@"cover"]) {
                NSLog(@"OID - cover %@", cat.oid);
                categoryId=cat.oid;
                return;
            }
        }
    }else{
        [self loadCategories];
    }
}

-(void)loadCategories {
    self.categoryDC = [[SHPCategoryDC alloc] init];
    self.categoryDC.delegate = self;
    [self.categoryDC getAll];
}

//DELEGATE loadCategories
-(void)categoriesLoaded:(NSMutableArray *)categories error:(NSError *)error {
    if (error) {
        NSLog(@"ERROR LOADING CATEGORIES!");
    }
    else {
        NSLog(@"CATEGORIES LOADED!!!!! CALLER");
        NSMutableDictionary *dictionaryCategories = [[NSMutableDictionary alloc]init];
        for (SHPCategory *c in categories) {
            NSLog(@"================== Category: %@ %@ %@", c.oid, c.name, c.type);
            [dictionaryCategories setValue:c.type forKey:c.oid];
        }
        [self.applicationContext setVariable:LAST_LOADED_CATEGORIES withValue:categories];
        [self.applicationContext setVariable:DICTIONARY_CATEGORIES withValue:dictionaryCategories];

        [self initializeData];
    }
}
//-----------------------------------------------------------------//
//END LOAD CATEGORY 'COVER'
//-----------------------------------------------------------------//


//-----------------------------------------------------------------//
//START LOAD PRODUCTS COVER
//-----------------------------------------------------------------//
-(void)searchFirst {
    NSLog(@"searchProducts");
    searchStartPage = 0;
    [self searchProducts];
}
-(void)searchMore {
    NSLog(@"searchMore");
    searchStartPage = searchStartPage + 1;
    [self searchProducts];
}

-(void)searchProducts {
    isLoadingData = YES;
    self.productDC = [[SHPProductDC alloc] init];
    self.productDC.delegate = self;
    if (self.applicationContext.searchLocation) {
        searchLocation = self.applicationContext.searchLocation;
    } else {
        searchLocation = self.applicationContext.lastLocation;
    }
    authUser = self.applicationContext.loggedUser;
    [self.productDC search:searchLocation categoryId:categoryId page:searchStartPage pageSize:searchPageSize withUser:authUser];
}
//DELEGATE searchShops
- (void)loaded:(NSArray *)loadedProducts {
    NSLog(@"loaded");
    [self.refreshControl endRefreshing];
    isLoadingData = NO;
    noMoreData = NO;
//    UITableViewCell *moreCell = [self moreButtonCell];
//    [self updateMoreButtonCell:moreCell];

    arrayShops = [[NSMutableArray alloc] init];
    arrayProducts = [[NSMutableArray alloc] init];
    NSMutableArray *arrayOidShop = [[NSMutableArray alloc] init];
    for (SHPProduct *productTemp in loadedProducts) {
        NSLog(@"shop OID: %@ - %@",productTemp.shop ,productTemp );
        if (![arrayOidShop containsObject:productTemp.shop]){
            [arrayOidShop addObject:productTemp.shop];
            SHPShop *nwShop = [[SHPShop alloc] init];
            nwShop.oid = productTemp.shop;
            nwShop.city = productTemp.city;
            nwShop.name = productTemp.shopName;
            nwShop.lat = productTemp.shopLat;
            nwShop.lon = productTemp.shopLon;
            nwShop.distance = [productTemp.distance intValue];
            nwShop.coverImageURL = productTemp.imageURL;
            [arrayShops addObject:nwShop];
            [arrayProducts addObject:productTemp];
        }
    }
    NSLog(@"arrayShops: %@",arrayShops);
    
    if (arrayProducts.count > 0) {
        if (!self.products) {
            self.products = [[NSMutableArray alloc] init];
        }
        [self.products addObjectsFromArray:arrayProducts];
        if (arrayProducts.count < searchPageSize) {
            noMoreData = YES;
            NSLog(@"noMoreData...");
        }
        [self reloadTable];
    }
    else if (arrayProducts.count == 0 && self.products.count == 0) {
        if (!self.products) {
            self.products = [[NSMutableArray alloc] init];
        }
        [self reloadTable];
    }
    else if (arrayProducts.count == 0) {
        noMoreData = YES;
    }
    [self reloadTable];
}

-(void)networkError {
    [self.refreshControl endRefreshing];
    if (!self.products) {
        self.products = [[NSMutableArray alloc] init];
    }
    [self reloadTable];
    
    NSString *title = NSLocalizedString(@"NetworkErrorTitleLKey", nil);
    NSString *msg = NSLocalizedString(@"NetworkErrorLKey", nil);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    isLoadingData = NO;
    searchStartPage = searchStartPage - 1; // reset to previous page
    if(searchStartPage<0){
        searchStartPage = 0;
    }
}

//-----------------------------------------------------------------//
//END LOAD PRODUCTS COVER
//-----------------------------------------------------------------//



//----------------------------------------------------------------//
//START GESTIONE TABLEVIEW
//----------------------------------------------------------------//
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.products && self.products.count > 0 && isLoadingData == NO) {
        return [self.products count] + 1;
    } else if (self.products && self.products.count == 0 && isLoadingData == NO) {
        NSLog(@"ONE ROW. NOPRODUCTS CELL.");
        return 1; // the NoProductsCell
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.products && self.products.count == 0) {
        NSLog(@"NO PRODDUCTS CELL HEIGHT");
        return 278;
    }
    if (indexPath.row <= [self.products count] - 1) {
        SHPProduct *p = [self.products objectAtIndex:indexPath.row];
        CGSize intoSize = CGSizeMake(self.applicationContext.settings.mainListImageWidth, self.applicationContext.settings.mainListImageHeight);
        CGSize resized = [SHPImageUtil imageSizeForProduct:p constrainedInto:intoSize];
        return resized.height;
    }else {
        return 44; //last cell (loading next page)
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"self.products: %@ - self.products.count: %d", self.products, (int)self.products.count);
    UITableViewCell *cell = nil;
    static NSString *CellIdentifier;
    if(self.products.count==0 && isLoadingData == YES){
        //cella nessun risultato
        CellIdentifier = @"CellLoading";
    }
    else if(self.products.count==0){
        //cella nessun risultato
        CellIdentifier = @"CellNoItems";
    }
    else if(self.products.count > indexPath.row){
        CellIdentifier = SHPCONST_MAIN_LIST_GROUPON_CELL_LIKE_ID;
    }
    else if(noMoreData == YES){
        //cella fine
        CellIdentifier = @"CellLast";
    }
    else{
        //cella more
        CellIdentifier = @"CellMore";
    }
    
    NSLog(@":::::::CellIdentifier::::::: %@", CellIdentifier);
    
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

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

    else if([CellIdentifier isEqualToString:SHPCONST_MAIN_LIST_GROUPON_CELL_LIKE_ID]){ //SHPCONST_MAIN_LIST_GROUPON_CELL_LIKE_ID
        SHPProduct *product = [self.products objectAtIndex:indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //******************* CELL ****************
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];//70
        //UILabel *priceStartLabel = (UILabel *)[cell.contentView viewWithTag:101];
        //UILabel *priceLabel = (UILabel *)[cell.contentView viewWithTag:102];
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:103];
        UILabel *cityLabel = (UILabel *)[cell.contentView viewWithTag:104];
        UIButton *likeButton = (UIButton *)[cell.contentView viewWithTag:105];
        //UILabel *dealLabel = (UILabel *)[cell.contentView viewWithTag:106];
        UIButton *buttonLiked = (UIButton *)[cell.contentView viewWithTag:107];
        UILabel *shopLabel = (UILabel *)[cell.contentView viewWithTag:108];
        shopLabel.hidden = YES;
        //******************* IMAGE ****************
        //imageView.property = [NSNumber numberWithInt:((int)indexPath.row)];
        if(![self.applicationContext.mainListImageCache getImage:product.imageURL]) {
            //BOOL scrollPaused = self.tableView.dragging == NO && self.tableView.decelerating == NO;
            //if ( scrollPaused || !isScrollingFast ) {
            [self startIconDownload:product forIndexPath:indexPath];
            //}
            imageView.image = nil;
        } else {
            imageView.image = [self.applicationContext.mainListImageCache getImage:product.imageURL];
        }
        //************* COUNT LIKE *******************
        NSString *countLiked =[NSString stringWithFormat:@"%ld %@", (long)product.likesCount, NSLocalizedString(@"LikeLKey", nil)];
        [buttonLiked setTitle:countLiked  forState:UIControlStateNormal];
        //************* LIKE *******************
        //[likeButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        if(product.userLiked==NO) {
            [likeButton setImage:[UIImage imageNamed:@"icon_like_white_60X60"] forState:UIControlStateNormal];
        } else {
            [likeButton setImage:[UIImage imageNamed:@"icon_like_red_60X60"] forState:UIControlStateNormal];
        }
        [likeButton setTitle:countLiked  forState:UIControlStateNormal];
        //likeButton.tag = indexPath.row;
       
        likeButton.imageView.tag = indexPath.row;
        [likeButton addTarget:self action:@selector(buttonLikedClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        //************* TITLE *******************
        NSString *titleText;
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
        NSLog(@"TITLE LABEL ...%@ - %d",titleText, (int)indexPath.row );
        titleLabel.text = titleText;
        //**************** CITY ******************
        NSString *cityText;
        NSString *shopText;
        NSLog(@"CITY LABEL .... %@", cityLabel);
        if (product.city && ![product.city isEqualToString:@""]) {
            cityText =  [[NSString alloc] initWithFormat:@"- %@",product.city];
        } else {
            cityText = @"";
        }
        NSLog(@".................lastLocation.......... %@", self.applicationContext.lastLocation);
        if(!self.applicationContext.lastLocation){
            cityText = [[NSString alloc] initWithFormat:@"%@", product.city];
        }else{
            cityText = [[NSString alloc] initWithFormat:@"%@ %@  %@", [NSLocalizedString(@"toKey", nil) capitalizedString], product.distance, product.city];
        }
        if(![product.shopName isEqualToString:@""] && product.shopName){
            shopText = product.shopName;
        }
        shopLabel.text = shopText;
        cityLabel.text = cityText;
        //**************** END CELL ****************************
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"DID SELECT ROW AT INDEX PATH!!!!!");
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifier = [cell reuseIdentifier];
    selectedIndex=indexPath.row;
    
    if([identifier isEqualToString:SHPCONST_MAIN_LIST_GROUPON_CELL_LIKE_ID]){ //SHPCONST_MAIN_LIST_GROUPON_CELL_LIKE_ID
        selectedIndex=indexPath.row;
        [self performSegueWithIdentifier: @"toShopDetail" sender:self];
    }
    else if([identifier isEqualToString:@"CellMore"]){
        [self searchMore];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"[segue identifier]: %@",[segue identifier]);
    if ([[segue identifier] isEqualToString:@"toShopDetail"]) {
        NSLog(@"toShopDetail");
        SHPShop *shop = [[SHPShop alloc] init];
        shop = [arrayShops objectAtIndex:selectedIndex];
        shop.coverImage = [self.applicationContext.mainListImageCache getImage:shop.coverImageURL];
        SHPPoiDetailTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.shop = shop;
    }
    else if ([[segue identifier] isEqualToString:@"toShowOnMap"]) {
        NSLog(@"toShowOnMap");
        UINavigationController *navigationController = [segue destinationViewController];
        SHPProductsOnMapVC *vc = (SHPProductsOnMapVC *)[[navigationController viewControllers] objectAtIndex:0];
        vc.applicationContext = self.applicationContext;
        vc.products =self.products;
        vc.categoryType = @"cover";
    }
    else if([[segue identifier] isEqualToString:@"toLiked"]) {
        SHPLikesViewController * vc = (SHPLikesViewController *)[segue destinationViewController];
        SHPLikedToLoader *loader = [[SHPLikedToLoader alloc] init];
        SHPProduct *product = [[SHPProduct alloc] init];
        product = [arrayProducts objectAtIndex:selectedIndex];
        NSLog(@"Preparing Segue for Product %@", product.title);
        loader.product = product;
        loader.userDC.delegate = vc;
        vc.applicationContext = self.applicationContext;
        vc.loader = loader;
    }
}

-(void)reloadTable {
    // useful, but not if called from the nsurlconnection delegate (that auto-runs messages to the delegate on the calling thread)
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView reloadData];
    });
}

-(void)buttonLikedClicked:(UIButton*)sender
{
    NSLog(@"BUTTON LIKED TAG: %@", sender.imageView);
    selectedIndex = sender.imageView.tag;
    SHPProduct *product = [[SHPProduct alloc] init];
    product = [self.products objectAtIndex:selectedIndex];
    if(product.likesCount>0){
        [self performSegueWithIdentifier: @"toLiked" sender:self];
    }
}

//----------------------------------------------------------------//
//END GESTIONE TABLEVIEW
//----------------------------------------------------------------//



//----------------------------------------------------------------//
//START CONFIG MORE BUTTON
//----------------------------------------------------------------//
-(void)updateMoreButtonCell:(UITableViewCell *)cell {
    [SHPComponents updateMoreButtonCell:cell noMoreData:noMoreData isLoadingData:isLoadingData];
}

-(UITableViewCell *)moreButtonCell {
    if (self.products && self.products.count > 0) {
        NSArray *indexes = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *index in indexes) {
            if (index.row == [self.products count]) {
                UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:index];
                return cell;
            }
        }
    }
    return nil;
}

-(void)moreButtonPressed:(id)sender
{
    searchStartPage = searchStartPage + 1;
    [self searchProducts];
    UITableViewCell *moreCell = [self moreButtonCell];
    if (moreCell) {
        [self updateMoreButtonCell:moreCell];
    }
}
//----------------------------------------------------------------//
//START CONFIG MORE BUTTON
//----------------------------------------------------------------//



//----------------------------------------------------------------//
//START LOAD IMAGE PRODUCT
//----------------------------------------------------------------//
- (void)startIconDownload:(SHPProduct *)product forIndexPath:(NSIndexPath *)indexPath
{
    self.iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (self.iconDownloader == nil)
    {
        NSLog(@"Starting IconDownloader for product %@", product.imageURL);
        self.iconDownloader = [[SHPIconDownloader alloc] init];
        self.iconDownloader.imageURL = product.imageURL;
        self.iconDownloader.imageWidth = (int)self.applicationContext.settings.mainListImageWidth;
        self.iconDownloader.imageHeight = (int)self.applicationContext.settings.mainListImageHeight;
        self.iconDownloader.imageCache = self.applicationContext.mainListImageCache;
        self.iconDownloader.indexPathInTableView = indexPath;
        self.iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:self.iconDownloader forKey:indexPath];
        [self.iconDownloader startDownload];
    }
}
// DELEGATE ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    SHPIconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    // if the cell for the image is visible update the cell
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.row == indexPath.row) {
            UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:index];
            UIView *contentView = cell.contentView; //[cell.contentView viewWithTag:backViewTag];
            UIImageView *imageView = (UIImageView *)[contentView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];
            UIImage *image = [self.applicationContext.mainListImageCache getImage:iconDownloader.imageURL];
            // animate fade image set
            [UIView transitionWithView:imageView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{imageView.image = image;}
                            completion:NULL];
        }
    }
    [self.imageDownloadsInProgress removeObjectForKey:indexPath];
}
//----------------------------------------------------------------//
//END LOAD IMAGE PRODUCT
//----------------------------------------------------------------//


//----------------------------------------------------------------//
//START GESTIONE CARICAMENTO IMMAGINI SULLO SCROLLVIEW E DRAGGING
//----------------------------------------------------------------//
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"END DRAGGING");
    if (!decelerate)
    {
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"END DECELERATING");
    [self loadImagesForOnscreenRows];
}

-(void)loadImagesForOnscreenRows {
    if (self.products.count <= 0) {
        return;
    }
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.row <= self.products.count - 1) { // != last cell
            UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:index];
            UIView *contentView = cell.contentView; //[cell.contentView viewWithTag:backViewTag];
            UIImageView *imageView = (UIImageView *)[contentView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];
            if (!imageView.image) {
                SHPProduct *product = [self.products objectAtIndex:index.row];
                [self startIconDownload:product forIndexPath:index];
            }
        }
    }
}
//----------------------------------------------------------------//
//END GESTIONE CARICAMENTO IMMAGINI SULLO SCROLLVIEW E DRAGGING
//----------------------------------------------------------------//






-(void)terminatePendingConnections {
    NSLog(@"Terminating pending connections...");
//     NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
//    for(SHPImageDownloader *obj in allDownloads) {
//        obj.delegate = nil;
//        [obj cancelDownload];
//    }
    [self.imageDownloadsInProgress removeAllObjects];
    self.iconDownloader.delegate = nil;
    self.productDC.delegate = nil;
    self.categoryDC.delegate = nil;
}

- (IBAction)actionBarButtonMap:(id)sender {
    if(self.products && self.products>0){
        [self performSegueWithIdentifier: @"toShowOnMap" sender: self];
    }
}

-(void)dealloc {
    NSLog(@"MAIN LIST DEALLOCATING...");
    [self terminatePendingConnections];
}

@end
