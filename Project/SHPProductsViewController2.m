//
//  SHPProductsViewController2.m
//  Ciaotrip
//
//  Created by andrea sponziello on 30/12/13.
//
//
#import "SHPProductsViewController2.h"
#import "SHPProductDC.h"
#import "SHPProduct.h"
#import "SHPBackgroundView.h"
#import <CoreLocation/CoreLocation.h>
#import <QuartzCore/QuartzCore.h>
#import "UIView+Property.h"
#import "SHPIconDownloader.h"
#import "SHPProductDetail.h"
//#import "SHPActivityViewController.h"
//#import "SVPullToRefresh.h"
#import <UIKit/UIKit.h>
#import "SHPApplicationContext.h"
#import "SHPComponents.h"
#import "SHPConstants.h"
#import "SHPStringUtil.h"
#import "SHPLikeDC.h"
#import "SHPImageUtil.h"
//#import "SHPLoginHomeViewController.h"
#import "SHPChooseCategoryViewController.h"
#import "SHPCategory.h"
#import "SHPCaching.h"
//#import "UIViewController+WelcomePanel.h"
//#import "SHPMapInViewController.h"
#import "SHPImageRequest.h"
#import "SHPUser.h"
//#import "SHPInfoPage1ViewController.h"
#import "SHPProductsLoaderStrategy.h"
#import "SHPTimelineProductsLoader.h"
//#import "SHPInfoViewController.h"
#import "SHPSetCityViewController.h"
#import "SHPAppDelegate.h"
#import "SHPLoadInitialDataViewController.h"
#import "SHPWebViewNotification.h"
//#import "SHPProductDetailDealEatTVC.h"
#import "SHPShop.h"
#import "SHPProductsOnMapVC.h"
//#import "SHPCategoriesStepWizardTVC.h"
#import "SHPInfoFirstLoadVC.h"
#import "SHPMiniWebBrowserVC.h"
#import "SHPAuthenticationVC.h"
#import "SHPPoiDetailTVC.h"
#import "SHPLikesViewController.h"
#import "SHPLikedToLoader.h"
#import "SHPPOIOpenStatus.h"
#import "SHPUserInterfaceUtil.h"



typedef void (^SHPStopAnimationHandler)();

@interface SHPProductsViewController2 ()
@end

@implementation SHPProductsViewController2


@synthesize categoryButton;
@synthesize locateButton;
@synthesize products;
@synthesize selectedProduct;
@synthesize locationManager = _locationManager;
@synthesize locationMeasurements = _locationMeasurements;
@synthesize bestEffortAtLocation = _bestEffortAtLocation;
@synthesize bgColor = _bgColor;
@synthesize showMenuButtonView;
@synthesize imageDownloadsInProgress = _imageDownloadsInProgress;
@synthesize likesInProgress;
@synthesize selectedCategory;
@synthesize selectedIndex = _selectedIndex;
@synthesize hud;
@synthesize applicationContext;
@synthesize locationServicesDisabledError;
@synthesize aProductWasDeleted;

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
    NSLog(@"CLASS NAME: %@", NSStringFromClass([self class]));
    productSelected = [[SHPProduct alloc] init];
    self.selectedIndex = -1;
    
    [SHPComponents titleLogoForViewController:self];
    self.navigationController.title = nil;
    
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    
    searchStartPage = 0;
    searchPageSize = self.applicationContext.settings.mainListSearchPageSize;
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
    self.likesInProgress = [[NSMutableDictionary alloc] init];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageHeader)];
    singleTap.numberOfTapsRequired = 1;
    self.imageHeader.userInteractionEnabled = YES;
    [self.imageHeader addGestureRecognizer:singleTap];
    
    settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    [self setRightBarButtonItem];

    NSDictionary *viewDictionary = [self.applicationContext.plistDictionary objectForKey:@"View"];
    NSDictionary *productsListDictionary = [viewDictionary objectForKey:@"ProductsList"];
    CELL_STYLE = [productsListDictionary objectForKey:@"CELL_STYLE"];
    NSLog(@"CELL_STYLE: %@",CELL_STYLE);
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background-1.png"]];
    [self.tableView setBackgroundView:imageView];
    [self.tableView.backgroundView.layer setZPosition:0];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(initializeData) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    isLoadingData = NO;
    self.showMenuButtonView = [SHPComponents MainListShowMenuButton:self settings:self.applicationContext.settings];
    
    
    if(self.applicationContext.isFirstLaunch){
        //[self firstLaunch];
    }
    else if (![self.applicationContext getVariable:LAST_LOADED_CATEGORIES]) {
        //NSLog(@"PRIMA APPARIZIONE!!!!! CARICO CATEGORIE!");
        [self waitToLoadData];
        //[self performSegueWithIdentifier:@"waitToLoadData" sender:self];
    }
    else {
        NSLog(@"INIZIALIZZO LA LISTA.");
        [self firstLoad:self.applicationContext];
    }
}

-(void)setRightBarButtonItem
{
    BOOL singlePoi=[[settingsDictionary objectForKey:@"singlePoi"] boolValue];
    
    if(!singlePoi){
        UIImage *faceImage1= [UIImage imageNamed:@"icon_light_poi.png"];
        UIButton *face1 = [UIButton buttonWithType:UIButtonTypeSystem];//UIButtonTypeCustom
        face1.bounds = CGRectMake( 0, 0, 30, 30 );
        [face1 addTarget:self action:@selector(goToMap) forControlEvents:UIControlEventTouchUpInside];
        [face1 setImage:faceImage1 forState:UIControlStateNormal];
        UIBarButtonItem *backButton1 = [[UIBarButtonItem alloc] initWithCustomView:face1];
        self.navigationItem.rightBarButtonItem = backButton1;
        [self.navigationItem.rightBarButtonItem setEnabled:FALSE];
    }else{
        self.navigationItem.rightBarButtonItem = nil;
    }

}

-(void)updateViewTitle:(NSString *)title {
    UILabel *navTitleLabel = [[UILabel alloc] init];
    navTitleLabel.text = title;
    navTitleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    navTitleLabel.backgroundColor = [UIColor clearColor];
    navTitleLabel.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    navTitleLabel.textAlignment = NSTextAlignmentCenter;
    navTitleLabel.textColor =[UIColor whiteColor];
    [navTitleLabel sizeToFit];
    self.navigationItem.titleView = navTitleLabel;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //resetta ip prodotto attivato quando viene inviata una notifica con riferimento a un post.
    self.selectedProductID = nil;
    // if appeared back from a detail view where the product was deleted
    if (aProductWasDeleted) {
        //        NSLog(@"Start products count: %d", self.products.count);
        for (int i = 0; i < self.products.count; i++) {
            SHPProduct *p = (SHPProduct *)[self.products objectAtIndex:i];
            if ([p.oid isEqualToString:aProductWasDeleted.oid]) {
                [self.products removeObject:p];
            }
        }
        //        NSLog(@"End products count: %d", self.products.count);
        self.aProductWasDeleted = nil;
        [self reloadTable];
    }
    
    
    if(self.applicationContext.isFirstLaunch){
        [self firstLaunch];
    }
    else if (![self.applicationContext getVariable:LAST_LOADED_CATEGORIES]) {
        NSLog(@"PRIMA APPARIZIONE!!!!! CARICO CATEGORIE!");
        //DISATTIVO IL PRECARICAMENTO DELLE CATEGORIE
        //[self waitToLoadData];
        //E ATTIVO IL CARICAMENTO DELLA TIMELINE
        [self initializeData];
    }
    
    //    // arrow back button
    //    int n = (int) [self.navigationController.viewControllers count];
    //    //    NSLog(@"NNNNNNNNNNNNNNNNNN %d", n);
    //    if (n >= 2) {
    //        UIBarButtonItem *backButton = [SHPComponents backButtonWithTarget:self settings:self.applicationContext.settings];
    //        [self.navigationItem setLeftBarButtonItem:backButton];
    //    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // if back from product-detail-view then updates the visible cells state
    if (self.selectedIndex > -1) {
        [self.tableView reloadData];
        // works also this way...
        //        NSLog(@"selected!!!!!");
        //        SHPProduct *p = [self.products objectAtIndex:self.selectedIndex];
        //        NSString *state = p.userLiked ? SHPCONST_UNLIKE_COMMAND : SHPCONST_LIKE_COMMAND;
        //        NSLog(@"%@", state);
        //        [self updateLikeButtonWithState:state product:p];
    }
//    NSString *className = NSStringFromClass([self class]);
//    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
//    [tracker set:kGAIScreenName value:className];
//    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    //NSString *trackerName = [[NSString alloc] initWithFormat:@"HomePage"];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
}


-(void)firstLaunch {
    // welcome view
    NSLog(@"IS FIRST LAUNCH? .....");
    if ([self.applicationContext isFirstLaunch]) {
        NSLog(@"YES .....");
        [self.applicationContext setFirstLaunchDone];
        [self toInfoFirstLoad];
        //[self performSegueWithIdentifier:@"ProductTour" sender:self];
    }
}


-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    NSLog(@"(SHPProductsViewController) viewWillDisappear. Dismissing? %d", [self isBeingDismissed]);
    //    NSLog(@"(SHPProductsViewController) viewWillDisappear. is Removing? %d", self.isMovingFromParentViewController);
    // pop out (disposing) isMovingFromParent = true (1)
}

-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    //    NSLog(@"(SHPProductsViewController) viewDidDisappear. is Removing? %d", self.isMovingFromParentViewController);
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        NSLog(@"CANCELING PENDING CONNECTIONS");
        //        [self.productDC cancelDownload];
        //        self.productDC.delegate = nil;
        [self.loader cancelOperation];
        [self terminatePendingConnections];
    }
}


-(void)alert:(NSString *)message {
    NSString *title = nil;
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void)firstLoad:(SHPApplicationContext *)applicationContextWithCategories {
    NSLog(@"FIRST LOAD.................%@",applicationContextWithCategories);
    self.applicationContext = applicationContextWithCategories;
    //    [self.tableView.pullToRefreshView startAnimating];
    //    CGPoint newOffset = CGPointMake(0, -[self.tableView contentInset].top);
    
    //    [self.tableView setContentOffset:newOffset animated:YES];
    [self.refreshControl beginRefreshing];
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:NO];
    
    //    [self showActivityView];
    [self initializeData];
}

-(void)initializeData {
    [self.categoryButton setEnabled:NO];
    [self resetData];
    [self searchFirst];
    //[self updateLocationInfo];
}



-(void)resetData {
    NSLog(@"RESETTING DATA");
    self.bestEffortAtLocation = nil;
    self.products = nil;
    searchStartPage = 0;
    self.loader.searchStartPage = searchStartPage;
    noMoreData = NO;
    [self terminatePendingConnections];
    [self.imageDownloadsInProgress removeAllObjects];
    //    for (NSString* key in self.imageDownloadsInProgress) {
    //        NSLog(@"found: %@", [self.imageDownloadsInProgress objectForKey:key]);
    //    }
}



//-(Boolean)locationServicesActive {
//    //    NSLog(@"Checking location services...");
//    if ([CLLocationManager locationServicesEnabled] == NO) {
//        NSString *alertMessage = NSLocalizedString(@"LocDisabledMessageLKey", nil);
//        self.locationServicesDisabledError = YES;
//        [self showMessageView:alertMessage];
//        return FALSE;
//    }
//    //    NSLog(@"Location services enabled: OK");
//    return TRUE;
//}

-(void)viewControllerDidBecomeActive {
    //    NSLog(@"viewControllerDidBecomeActive...");
    if (self.locationServicesDisabledError && [CLLocationManager locationServicesEnabled] == YES) {
        self.locationServicesDisabledError = NO; // reset error
        //        [self hideTopView];
        //        self.locationManager = [[CLLocationManager alloc] init];
        //        [self.locationManager startUpdatingLocation];
        //        [self showActivityView];
        [self initializeData];
    }
}

//- (IBAction)infoAction:(id)sender {
//    //    [self performSegueWithIdentifier:@"InfoSegue" sender:self];
//    //    [self performSegueWithIdentifier:@"InfoSegue" sender:self];
//    //    NSLog(@"CLLocationManager locationServicesEnabled? %d", [CLLocationManager locationServicesEnabled]);
//    if ([CLLocationManager locationServicesEnabled] == NO) {
//        //        NSLog(@"CLLocationManager locationServices Disabled");
//        NSString *alertMessage = NSLocalizedString(@"LocDisabledMessageLKey", nil);
//        [self alert:alertMessage];
//    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
//        //        NSLog(@"CLLocationManager locationServices Disabled for this App");
//        NSString *alertMessage = NSLocalizedString(@"LocationNotAvailableLKey", nil);
//        [self alert:alertMessage];
//    } else if (self.applicationContext.lastLocation.coordinate.latitude == 0 && self.applicationContext.lastLocation.coordinate.longitude == 0) {
//        NSString *alertMessage = NSLocalizedString(@"NoLocMessageLKey", nil);
//        [self alert:alertMessage];
//    }
//}

//- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    //    [self hideAllAccessoryViews];
////    [self showLocationErrorView];
//    if (actionSheet == categoriesAlertView) {
//        [self loadCategories];
//    }
//}

-(void)showNoItemsView {
    UIView *view = [SHPComponents viewByXibName:@"NoItems"];
    UILabel *label = (UILabel *) [view viewWithTag:1];
    label.text = NSLocalizedString(@"NoItemsLKey", nil);
    
    CGRect frame = self.view.frame;
    view.frame = frame;
    [self.view addSubview:view];
}

//-(void)showActivityView {
//    [self hideAccessoryView];
//    if (activityController == nil) {
//        activityController = [[SHPActivityViewController alloc] initWithFrame:[self theSuperviewFor].bounds];
//        activityController.view.tag = 1003;
//    }
//    //    [self.view insertSubview:activityController.view aboveSubview:self.view];
//    [[self theSuperviewFor] addSubview:activityController.view];
//    [[self theSuperviewFor] bringSubviewToFront:activityController.view];
//    [activityController startAnimating];
//}

-(void)showMessageView:(NSString *)message {
    [self hideAccessoryView];
    UIView *messageView = [SHPComponents viewByXibName:@"MessageView"];
    messageView.frame = [[self theSuperviewFor] bounds];
    messageView.tag = 1003;
    UILabel *messageLabel = (UILabel *)[messageView viewWithTag:10];
    messageLabel.text = message;
    [[self theSuperviewFor] addSubview:messageView];
    [[self theSuperviewFor] bringSubviewToFront:messageView];
}

-(UIView *)theSuperviewFor {
    //    NSLog(@"self.view class %@", NSStringFromClass([self.view class]));
    //    NSLog(@"self.view.superview class %@", NSStringFromClass([self.view.superview class]));
    ////    NSLog(@"self.view.superview.superview %@ class %@", self.view.superview.superview, NSStringFromClass([self.view.superview.superview class]));
    //
    //    UIView *theViewWhereAddMessages = nil;
    //    for(UIView *view in self.navigationController.view.subviews) {
    //        NSLog(@"subview class %@", NSStringFromClass([view class]));
    //        NSLog(@"frame x: %f y: %f w: %f h: %f", view.frame.origin.x, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
    ////        if(![view isKindOfClass:[UITabBar class]]) {
    ////            theViewWhereAddMessages = view; // the transiotion view
    ////        }
    //    }
    return self.view;
}

-(void)hideAccessoryView {
    //    [self.tableView.pullToRefreshView stopAnimating];
    [self.refreshControl endRefreshing];
    //    UIView *topView = [[self theSuperviewFor] viewWithTag:1003];
    //    if (topView) {
    //        [topView removeFromSuperview];
    //    }
}

//-(void)hideActivityView {
//    [activityController.view removeFromSuperview];
//    [activityController stopAnimating];
//}

//-(void)showErrorView {
//    [self hideAccessoryView];
//    if (errorController == nil) {
//        errorController = [[SHPNetworkErrorViewController alloc] initWithFrame:self.tableView.frame];
//        //        errorController.target = self;
//        [errorController setTargetAndSelector:self buttonSelector:@selector(retryDataButtonPressed:)];
//        NSString *errorMessage = NSLocalizedString(@"ConnectionErrorLKey", nil);
//        //        NSLog(@"ERROR MESSAGE: %@", errorMessage);
//        errorController.message = errorMessage;
//        errorController.view.tag = 1003;
//    }
//    [self.view addSubview:errorController.view];
//}

//-(void)hideAllAccessoryViews {
//    [self hideActivityView];
//    [self hideErrorView];
//}

//-(void)showLocationErrorView {
//    [self hideAccessoryView];
//
//    if (errorController == nil) {
//        errorController = [[SHPNetworkErrorViewController alloc] initWithFrame:self.view.superview.bounds];
//        [errorController setTargetAndSelector:self buttonSelector:@selector(retryLocationButtonPressed:)];
//        NSString *errorMessage = NSLocalizedString(@"location error", nil);
//        errorController.message = errorMessage;
//        errorController.view.tag = 1003;
//    }
//    [self.view addSubview:errorController.view];
//}

//-(void)hideErrorView {
//    [errorController.view removeFromSuperview];
//}

//-(void)retryDataButtonPressed:(id)sender {
//    //    [self hideErrorView];
//    //    [self hideAccessoryView];
//    //    self.tableView.showsPullToRefresh = NO;
//    [self showActivityView];
//
//    [self initializeData];
//}

//-(void)retryLocationButtonPressed:(id)sender {
//    //    [self hideErrorView];
//    [self showActivityView];
//    //    [self startLocationManager];
//
//    [self initializeData];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARNING INSIDE PRODUCTS' LIST!");
    [self terminatePendingConnections];
}

-(void)terminatePendingConnections {
    NSLog(@"Terminating pending connections...");
    [self.geocoder cancelGeocode];
    // terminate all pending image download connections
    //    NSLog(@"(SHPProductsViewController) Canceling image pending connections...");
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    //    NSLog(@"(SHPProductsViewController) Total connections: %d", allDownloads.count);
    for(SHPImageDownloader *obj in allDownloads) {
        //        NSLog(@"(SHPProductsViewController) Canceling: %@", obj);
        obj.delegate = nil;
        [obj cancelDownload];
    }
    [self.imageDownloadsInProgress removeAllObjects];
    
    // terminate all pending likeDC connections
    //    NSLog(@"(SHPProductsViewController) Canceling likeDC pending connections...");
    NSArray *allLikesDC = [self.likesInProgress allValues];
    //    NSLog(@"(SHPProductsViewController) Total connections: %d", allLikesDC.count);
    for(SHPLikeDC *obj in allLikesDC) {
        //        NSLog(@"(SHPProductsViewController) Canceling: %@", obj);
        obj.likeDelegate = nil;
        [obj cancelConnection];
    }
    [self.likesInProgress removeAllObjects];
    
    // [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}












#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    // Return the number of sections.
    //return 2;
    return 1;
}

-(NSString *)tableView:(UITableView *)_tableView titleForHeaderInSection:(NSInteger)section {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.products && self.products.count > 0) {
        return [self.products count] + 1;
    } else if (self.products && self.products.count == 0) {
        NSLog(@"ONE ROW. NOPRODUCTS CELL.");
        return 1; // the NoProductsCell
    }
    return 0;
}

// Tap on row accessory
//- (void) tableView: (UITableView *) tableView accessoryButtonTappedForRowWithIndexPath: (NSIndexPath *) indexPath {
//    NSLog(@"tapped on row 2!");
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.products && self.products.count == 0) {
        NSLog(@"NO PRODDUCTS CELL HEIGHT");
        return 278;
        //return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    if (indexPath.row <= [self.products count] - 1) {
        SHPProduct *p = [self.products objectAtIndex:indexPath.row];
            p.imageURL = [p.imageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSArray *explodeUrl = [p.imageURL componentsSeparatedByString:@"?url="];
            if(explodeUrl.count<1 || [explodeUrl[1] isEqualToString:@""]){
                p.image = [UIImage imageNamed:@"place-holder-NO-IMAGE@2X.png"];
                return 200;
                //[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"place-holder-salve-passaggio@2X.png"]];
            }
        
        
        CGSize intoSize = CGSizeMake(self.applicationContext.settings.mainListImageWidth, self.applicationContext.settings.mainListImageHeight);
        //NSLog(@"resized:::2");
        CGSize resized = [SHPImageUtil imageSizeForProduct:p constrainedInto:intoSize];
        if([CELL_STYLE[0] isEqualToString:@"groupon"]){
            return resized.height;
        }else if([CELL_STYLE[0] isEqualToString:@"fancy"]){
            return resized.height+50;
        }
        else{
            //return 250;
            CGSize maxSize = CGSizeMake(SHPCONST_MAIN_LIST_DESCRIPTION_WIDTH, 99999);
            NSString *longDescriptionText;
            NSArray *urls = [SHPStringUtil extractUrlsFromText:p.longDescription];
            if(![urls[1] isEqualToString:@""]){
                longDescriptionText = urls[0];
            }else{
                longDescriptionText = p.longDescription;
            }
            CGRect labelRect = [longDescriptionText boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil];
            float descriptionHeight = labelRect.size.height;
            return [SHPComponents mainCellHeightForImageSize:resized descriptionHeight:descriptionHeight];
        }
    }else {
        return 44; //last cell (loading next page)
    }
}

- (UITableViewCell *)tableView:(UITableView *)__tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
        CellIdentifier = SHPCONST_MAIN_LIST_GROUPON_CELL_LIKE_ID;//SHPCONST_MAIN_LIST_GROUPON_CELL_LIKE_ID;
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
    cell = [__tableView dequeueReusableCellWithIdentifier:CellIdentifier];
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
        UILabel *titleLabel = (UILabel *)[cell.contentView viewWithTag:103];
        UILabel *cityLabel = (UILabel *)[cell.contentView viewWithTag:104];
        
        //******************* LABEL FIRST ****************
        UIView *viewFirst = (UIView *)[cell.contentView viewWithTag:200];
        UILabel *labelFirst = (UILabel *)[cell.contentView viewWithTag:201];
        labelFirst.text = NSLocalizedString(@"NearestProductLKey", nil);
        if(indexPath.row == 0)viewFirst.hidden = NO;
        else viewFirst.hidden = YES;
        
        //******************* IMAGE ****************
        NSLog(@"----------- STEP IMAGE __________");
        imageView.property = [NSNumber numberWithInt:((int)indexPath.row)];
        if(product.image){
            [UIView transitionWithView:imageView
                              duration:0.5f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                imageView.image = product.image;
                            }
                            completion:NULL];

        }
        else if(![self.applicationContext.mainListImageCache getImage:product.imageURL]) {
            BOOL scrollPaused = self.tableView.dragging == NO && self.tableView.decelerating == NO;
            if ( scrollPaused || !isScrollingFast ) {
                [self startIconDownload:product forIndexPath:indexPath];
                // imageView.image = [UIImage imageNamed:@"first.png"];
            }
            imageView.image = nil;
        } else {
            imageView.image = [self.applicationContext.mainListImageCache getImage:product.imageURL];
        }
        //******************* TAP LIKE ****************
        UIButton *buttonHeart = (UIButton *)[cell.contentView viewWithTag:107];
        [buttonHeart addTarget:self action:@selector(callTelephon:) forControlEvents:UIControlEventTouchUpInside];
        buttonHeart.property = [NSNumber numberWithInt:(int)indexPath.row];
        //************* COUNT LIKE *******************
//        UIButton *likeButton = (UIButton *)[cell.contentView viewWithTag:105];
//        NSLog(@"----------- STEP LIKE __________");
//        if(product.userLiked==NO) {
//            [buttonHeart setImage:[UIImage imageNamed:@"icon_like_white_60X60"] forState:UIControlStateNormal];
//        } else {
//            [buttonHeart setImage:[UIImage imageNamed:@"icon_like_red_60X60"] forState:UIControlStateNormal];
//        }
//        [likeButton addTarget:self action:@selector(goToListLikes:) forControlEvents:UIControlEventTouchUpInside];
//        likeButton.property = [NSNumber numberWithInt:(int)indexPath.row];
//        NSString *countLiked =[NSString stringWithFormat:@"%ld %@", (long)product.likesCount, NSLocalizedString(@"LikeLKey", nil)];
//        [likeButton setTitle:countLiked  forState:UIControlStateNormal];
        
        
        //***************** TELEPHONE *******************;
        NSLog(@"----------- STEP TELEPHONE __________");
        product = [self setPhoneNumber:product];
        UIButton *buttonCell = (UIButton *)[cell.contentView viewWithTag:50];
        //NSLog(@"\n product::: %@ ",product);
        if(!product.phoneNumber){
            buttonCell.enabled = NO;
        }
        else {
            buttonCell.property = [NSString stringWithFormat:@"%@",product.phoneNumber];
            [buttonCell addTarget:self action:@selector(buttonCallPhone:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        
        //***************** PLAN *******************;
        NSLog(@"----------- STEP PLAN __________");
        UILabel *labelPlan = (UILabel *)[cell.contentView viewWithTag:105];
        UIImageView *imageStatus = (UIImageView *)[cell viewWithTag:106];
        //labelPlan.text = [self setPlan:product.properties];
        
        [SHPUserInterfaceUtil applyTitleString:[self setPlan:product.properties] toAttributedLabel:labelPlan];
        if([labelPlan.text isEqualToString:@""]){
            imageStatus.image = [UIImage imageNamed:@"icon_open"];
        }else if(![labelPlan.text isEqualToString:@"Orari non disponibili"]){
            imageStatus.image = [UIImage imageNamed:@"icon_closed"];
        }else{
            imageStatus.image = nil;
        }
            
        

        
        //***************** PRICE *******************;
        NSLog(@"----------- STEP PRICE __________");
        UIView *viewPrice = (UIView *)[cell.contentView viewWithTag:300];
        UILabel *labelPrice = (UILabel *)[cell.contentView viewWithTag:301];
        UILabel *labelCurrency = (UILabel *)[cell.contentView viewWithTag:302];
        NSString *currency = product.currency ? NSLocalizedString(product.currency, nil) : NSLocalizedString(@"euro", nil);
        labelCurrency.text = [NSString stringWithString:currency];
        NSString *trimmedPrice = [product.price stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (!product.price || [trimmedPrice isEqualToString:@""]) {
            viewPrice.hidden = YES;
        }
        else if ([trimmedPrice isEqualToString:@"0.0"]) {
            viewPrice.hidden = NO;
            labelPrice.text = [[NSString alloc] initWithFormat:@"%@",NSLocalizedString(@"freePriceLKey", nil)];
        }
        else{
            viewPrice.hidden = NO;
            labelPrice.text = [[NSString alloc] initWithFormat:@"%.2f",[trimmedPrice floatValue]];
        }
       
        
//        //UILabel *priceStartLabel = (UILabel *)[cell.contentView viewWithTag:101];
//        UILabel *dealLabel = (UILabel *)[cell.contentView viewWithTag:106];
//        UILabel *shopLabel = (UILabel *)[cell.contentView viewWithTag:108];
//        shopLabel.hidden = YES;
//       
//        dealLabel.text = @"";
//               NSString *momentaryPrice = product.price;
//        NSString *momentaryStartPrice = product.startprice;
//        NSString *prezzosubunitario = [product returnProperty:@"prezzosubunitario"];
//        NSString *prezzosubunitariolistino = [product returnProperty:@"prezzosubunitariolistino"];
//        
//        if(prezzosubunitario && prezzosubunitario.length>0){
//            priceLabel.text = prezzosubunitario;
//            priceStartLabel.text = prezzosubunitariolistino;
//            priceStartLabel.attributedText = [SHPStringUtil strikethroughText:prezzosubunitariolistino color:[SHPImageUtil colorWithHexString:@"555555"]];
//        }else{
        //           NSString *trimmedStartPrice = [momentaryStartPrice stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
//        if (!momentaryStartPrice || [trimmedStartPrice isEqualToString:@""]){
//            priceStartLabel.hidden = YES;
//        }
//        else if ([trimmedStartPrice isEqualToString:@"0.0"] || [momentaryStartPrice isEqualToString:trimmedPrice]) {
//            priceStartLabel.hidden = YES;
//        }
//        else{
//            NSString *startPrice = [[NSString alloc] initWithFormat:@"( %.2f %@ )", [trimmedStartPrice floatValue],currency];
//            priceStartLabel.text = startPrice;//= [[NSString alloc] initWithFormat:@"%@ %.2f",currency, [trimmedStartPrice floatValue]];
//            priceStartLabel.hidden = NO;
//            priceStartLabel.attributedText = [SHPStringUtil strikethroughText:startPrice color:[SHPImageUtil colorWithHexString:@"555555"]];
//            //LABEL DEAL PERCENT
//            float perc = (1-([trimmedPrice floatValue]/[trimmedStartPrice floatValue]))*100;
//            int percRound = (int) round(perc);
//            dealLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d%% %@",nil), percRound, NSLocalizedString(@"di sconto",nil)];
//        }

//        }
        
        //************* TITLE *******************
        NSLog(@"----------- STEP TITLE __________");
        NSString *titleText = @"";
        if(product.title.length>0){
            //titleText = [[NSString alloc] initWithFormat:@"%@", [SHPStringUtil stringWithSentenceCapitalization:product.title]];
            titleText = product.title;
        }else{
            titleText = product.longDescription;
//            if(product.longDescription.length>MAX_CHARACTERS_TITLE){
//                NSString *newTitle = [product.longDescription substringToIndex:MAX_CHARACTERS_TITLE];
//                titleText = [[NSString alloc]  initWithFormat:@"%@", [SHPStringUtil stringWithSentenceCapitalization:newTitle]];
//                titleText = [titleText stringByAppendingString:@"..."];
//                
//            }else{
//                NSLog(@"----------- 2 END TITLE __________%@.", product.longDescription);
//                if(product.longDescription.length>0){
//                    titleText = [[NSString alloc]  initWithFormat:@"%@", [SHPStringUtil stringWithSentenceCapitalization:product.longDescription]];
//                }
//            }
        }
        NSLog(@"----------- END TITLE __________%@", titleText);
        titleLabel.text = titleText;
        //[titleLabel sizeToFit];
        //**************** CITY ******************
        NSLog(@"----------- STEP CITY __________");
        NSString *cityText;
        NSString *shopText;
        if (product.city && ![product.city isEqualToString:@""]) {
            cityText =  [[NSString alloc] initWithFormat:@"- %@",product.city];
        } else {
            cityText = @"";
        }
        if(!self.applicationContext.lastLocation){
            cityText = [[NSString alloc] initWithFormat:@"%@", product.city];
        }else{
            cityText = [[NSString alloc] initWithFormat:@"%@ %@  %@", [NSLocalizedString(@"toKey", nil) capitalizedString], product.distance, product.city];
        }
        if(![product.shopName isEqualToString:@""] && product.shopName){
            shopText = product.shopName;
        }
        //shopLabel.text = shopText;
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


//-(void)createCell:(UITableViewCell *)cell product:(SHPProduct *)p indexPath:(NSIndexPath *)indexPath{
//}


-(NSString *)setPlan:(NSDictionary *)properties{
    NSDictionary *planDictionary = (NSDictionary *)[properties valueForKey:@"orari"];
    NSArray *values = (NSArray *)[planDictionary valueForKey:@"values"];
    NSString *plan = [[NSString alloc] init];
    NSString *status = @"Orari non disponibili";
    if (values.count > 0) {
        plan = [values objectAtIndex:0];
        NSDate *dateNow = [NSDate date];
        NSDictionary *dictionaryPlan = [SHPPOIOpenStatus compile:plan];
        UIColor *itemColor;
        if (dictionaryPlan) {
            BOOL isOpenNow = [SHPPOIOpenStatus isOpenForPlan:dictionaryPlan onDate:dateNow];
            if (isOpenNow) {
                NSLog(@"OPEN!");
                status = @"";//@"APERTO";
                itemColor = [SHPImageUtil colorWithHexString:@"56AE18"];
            } else {
                NSLog(@"CLOSED!");
                itemColor = [SHPImageUtil colorWithHexString:@"B20000"];
                //status = @"CHIUSO";
                NSDate *next_open_hour = [SHPPOIOpenStatus nextOpenHourForPlan:dictionaryPlan onDate:dateNow];
                if (next_open_hour) {
                    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
                    [hourFormatter setDateFormat:@"HH:mm"];
                    status = [[NSString alloc] initWithFormat:@"apre alle %@", [hourFormatter stringFromDate:next_open_hour]];
                    
                    //NSLog(@"Next open hour: %@", [hourFormatter stringFromDate:next_open_hour]);
                } else {
                    NSDictionary *next_open_day_time = [SHPPOIOpenStatus nextOpenWeekDayForPlan:dictionaryPlan onDate:dateNow];
                    NSLog(@"next_open_day_time: %@", next_open_day_time);
                    NSInteger weekNumberDay = [[next_open_day_time valueForKey:@"weekday"] integerValue]-1;
                    NSString *weekDay = [SHPPOIOpenStatus returnWeekDay:weekNumberDay];
                    NSString *start = [next_open_day_time valueForKey:@"start"];
                    status = [[NSString alloc] initWithFormat:@"apre %@ alle %@", weekDay, start];
                }
            }
        }
    }
    return status;
}




- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"DID SELECT ROW AT INDEX PATH!!!!!");
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifier = [cell reuseIdentifier];
    
    if([identifier isEqualToString:SHPCONST_MAIN_LIST_GROUPON_CELL_LIKE_ID]){ //SHPCONST_MAIN_LIST_GROUPON_CELL_LIKE_ID
        self.selectedIndex=indexPath.row;
        productSelected = [self.products objectAtIndex:self.selectedIndex];
        [self performSegueWithIdentifier: @"toProductDetail" sender:self];
    }
    else if([identifier isEqualToString:@"CellMore"]){
        [self searchMore];
    }
}



- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:self.bgColor];
}




// TOO SEE CELL
-(UITableViewCell *) renderToSeeCell:(UITableView *)__tableView atIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [__tableView dequeueReusableCellWithIdentifier:SHPCONST_MAIN_LIST_PRODUCT_CELL_ID];
    if (!cell) {
        cell = [SHPComponents MainListCell:self.applicationContext.settings withTarget:self];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    SHPProduct *product = [self.products objectAtIndex:indexPath.row];
    // resize cell height
    //self.applicationContext.settings.mainListImageWidth
    CGSize intoSize = CGSizeMake((self.applicationContext.settings.mainListImageWidth-20), self.applicationContext.settings.mainListImageHeight);
     NSLog(@"resized:::1");
    CGSize resized = [SHPImageUtil imageSizeForProduct:product constrainedInto:intoSize];
    
    // resize also with descriptionLabel.height
    NSString *longDescriptionText = @"";
    NSArray *urls = [SHPStringUtil extractUrlsFromText:product.longDescription];
    if(![urls[1] isEqualToString:@""]){
        longDescriptionText = urls[0];
    }else{
        longDescriptionText = product.longDescription;
    }
    [SHPComponents adjustCell:cell forImageSize:resized withDescription:longDescriptionText];
    NSLog(@"descriptionLabel::: %@",longDescriptionText);
    //[SHPComponents adjustCell:cell forImageSize:resized withDescription:product.longDescription];
    // resize end
    
    UIView *contentView = cell.contentView;
    
    UIView *backView = [cell.contentView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_BACK_VIEW_TAG];
    backView.property = [NSNumber numberWithInt:((int)indexPath.row)];
    
    UIButton *likeButton = (UIButton *)[contentView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_BUTTON_LIKE];
    likeButton.property = [NSNumber numberWithInt:(int)indexPath.row];
    
    UILabel *usernameLabel = (UILabel *)[cell.contentView viewWithTag:1];
    usernameLabel.text = product.createdBy;
    usernameLabel.textColor = self.applicationContext.settings.mainListTextUsernameColor;
    
    // price label
    UILabel *priceLabel = (UILabel *)[cell.contentView viewWithTag:2];
    NSString *currency = product.currency ? NSLocalizedString(product.currency, nil) : NSLocalizedString(@"euro", nil);
    priceLabel.text = [[NSString alloc] initWithFormat:@"%.2f %@",[product.price floatValue], currency];
    NSString *trimmedPrice = [product.price stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSLog(@"XXXXXXXXXX  NSString *trimmedPrice: %@", trimmedPrice);
    if ([trimmedPrice isEqualToString:@""]) {
        priceLabel.hidden = YES;
    }
    else if ([trimmedPrice isEqualToString:@"0.0"]) {
        priceLabel.text = [[NSString alloc] initWithFormat:@"%@",NSLocalizedString(@"freePriceLKey", nil)];
        priceLabel.hidden = NO;
    }
    else {
        priceLabel.hidden = NO;
    }
    
    
    UILabel *shopLabel = (UILabel *)[cell.contentView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_SHOP_LABEL_TAG];
    NSString *shopText = [[NSString alloc]  initWithFormat:@"%@", [SHPStringUtil stringWithSentenceCapitalization:product.shopName]];
    shopLabel.textColor = self.applicationContext.settings.mainListTextShopColor;
    //            UILabel *distanceLabel = (UILabel *)[cell.contentView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_DISTANCE_LABEL_TAG];
    //            distanceLabel.text = product.distance;
    //            distanceLabel.textColor = self.applicationContext.settings.mainListTextDistanceColor;
    shopLabel.text = shopText;
    
    UILabel *cityLabel = (UILabel *)[cell.contentView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_CITY_VIEW_TAG];
    NSLog(@"CITY LABEL .... %@", cityLabel);
    NSString *cityText;
    if (product.city && ![product.city isEqualToString:@""]) {
        cityText = [[NSString alloc] initWithFormat:@"%@ ", product.city];
    } else {
        cityText = @"... ";
    }
    NSLog(@"City text.......... %@", cityText);
    NSLog(@".................lastLocation.......... %@", self.applicationContext.lastLocation);
    if(self.applicationContext.lastLocation){
        cityText = [[NSString alloc] initWithFormat:@"%@ - %@", cityText, product.distance];
    }else{
        cityText = [[NSString alloc] initWithFormat:@"%@", cityText];
    }
    cityLabel.text = cityText;
    
    UILabel *sponsoredLabel = (UILabel *)[cell.contentView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_SPONSORED_VIEW_TAG];
    if (product.sponsored) {
        NSString *sponsoredText = @"Sponsored";
        sponsoredLabel.text = sponsoredText;
        sponsoredLabel.hidden = NO;
    } else {
        sponsoredLabel.hidden = YES;
    }
    
    UILabel *likesCountLabel = (UILabel *)[cell.contentView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_LIKESCOUNT_VIEW_TAG];
    likesCountLabel.text = [NSString stringWithFormat:@"%d", (int)product.likesCount];
    //        NSLog(@">>>>>>>>>>>>>>>>> Updating likeButton for userLiked %d", product.userLiked);
    if (product.userLiked) {
        //            NSLog(@">>>>>>>>>>>>>>>>> likeButton ON");
        [SHPComponents setLikeButton:likeButton withState:SHPCONST_UNLIKE_COMMAND];
    } else {
        //            NSLog(@">>>>>>>>>>>>>>>>> likeButton OFF");
        [SHPComponents setLikeButton:likeButton withState:SHPCONST_LIKE_COMMAND];
    }
    
    // image
    UIImageView *imageView = (UIImageView *)[contentView viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_IMAGE_VIEW_TAG];
    imageView.property = [NSNumber numberWithInt:((int)indexPath.row)];
    // Only load cached images; defer new downloads until scrolling ends
    //        NSLog(@"LOADING IMAGE... %@", product.imageURL);
    //        NSLog(@"image: %@", [self.applicationContext.mainListImageCache getImage:product.imageURL]);
    if(![self.applicationContext.mainListImageCache getImage:product.imageURL]) {
        BOOL scrollPaused = self.tableView.dragging == NO && self.tableView.decelerating == NO;
        if ( scrollPaused || !isScrollingFast ) {
            [self startIconDownload:product forIndexPath:indexPath];
            // if a download is deferred or in progress, return a placeholder image
            // imageView.image = [UIImage imageNamed:@"first.png"];
        }
        imageView.image = nil;
    } else {
        //            NSLog(@"image already exists, so setting it...");
        imageView.image = [self.applicationContext.mainListImageCache getImage:product.imageURL];
    }
    
    //CENTRA IMMAGINE
    //    NSLog(@"IMAGE CENTER");
    //    [imageView setContentMode:UIViewContentModeScaleAspectFill];
    return cell;
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %ld",(long)self.selectedIndex);
    NSLog(@"[segue identifier]: %@",[segue identifier]);
   
    
    if ([[segue identifier] isEqualToString:@"toProductDetail"]) {
        SHPProductDetail *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        //ogni volta che viene richiamato il dettaglio di un prodotto da una notifica e la app risulta chiusa si passa da qui
        //presumo che se selectedProductID esiste e solo perchè è arrivata una notifica DA VERIFICARE
        NSLog(@"selectedProductID: %@",self.selectedProductID);
        if(self.selectedProductID){
            SHPProduct *product = [[SHPProduct alloc] init];
            product.oid = self.selectedProductID;
            vc.product = product;
        }else{
            vc.product = productSelected;
            UIImage *image = [self.applicationContext.mainListImageCache getImage:productSelected.imageURL];
            vc.productImage = [[UIImageView alloc] initWithImage:image];
            vc.product.image = image;
            NSLog(@"selectedProductID: pi:%@ - p:%@ - %@ - %@",vc.productImage, vc.product, image, vc.productImage.image);
        }
    }
    else if ([[segue identifier] isEqualToString:@"toShopDetail"]) {
        NSLog(@"toShopDetail");
        SHPProduct *product = [[SHPProduct alloc] init];
        product = [self.products objectAtIndex:self.selectedIndex];
        SHPShop *shop = [[SHPShop alloc] init];
        shop.oid = product.shop;
        if(![self.applicationContext.mainListImageCache getImage:product.imageURL]) {
            shop.coverImage = nil;
            shop.coverImageURL = product.imageURL;
        } else {
            shop.coverImage = [self.applicationContext.mainListImageCache getImage:product.imageURL];
        }
        SHPPoiDetailTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.shop = shop;
        //VC.imageMap = self.imageMap;
        VC.distance = product.distance;
    }
    else if ([[segue identifier] isEqualToString:@"toLogin"]) {
        [self goToAuthentication];        
    }
    else if ([[segue identifier] isEqualToString:@"ChooseCategory"]) {
        SHPChooseCategoryViewController *chooseCatVC = [segue destinationViewController];
        chooseCatVC.modalCallerDelegate = self;
        chooseCatVC.showCategoryAll = YES;
        chooseCatVC.categories = (NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES];
        chooseCatVC.selectedCategory = self.selectedCategory;
    } else if ([[segue identifier] isEqualToString:@"InfoSegue"]) {
        
        //        UINavigationController *navigationController = [segue destinationViewController];
        //        SHPPageViewController *infovc = (SHPPageViewController *)[[navigationController viewControllers] objectAtIndex:0];
        //        infovc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"waitToLoadData"]) {
        SHPLoadInitialDataViewController *vc = (SHPLoadInitialDataViewController *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.caller = self;
        NSLog(@"CALLER %@", vc.caller);
    }
    else if ([[segue identifier] isEqualToString:@"setSearchCity"]) {
        SHPSetCityViewController *vc = (SHPSetCityViewController *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"ProductTour"]) {
    }
    else if ([[segue identifier] isEqualToString:@"ProductUrl"]) {
        SHPWebViewNotification *vc = (SHPWebViewNotification *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.urlNotification = self.urlNotification;
    }
    else if ([[segue identifier] isEqualToString:@"toMap"]) {
        NSLog(@"------> toMap");
        UINavigationController *navigationController = [segue destinationViewController];
        SHPProductsOnMapVC *vc = (SHPProductsOnMapVC *)[[navigationController viewControllers] objectAtIndex:0];
        //SHPProductsOnMapVC *vc = (SHPProductsOnMapVC *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.products =self.products;
    }
    else if ([segue.identifier isEqualToString:@"toWebViewNav"]) {
        NSLog(@"Opening toWebViewNav...%@",self.applicationContext);
        /***************************************************************************************************************/
        UINavigationController *navigationController = [segue destinationViewController];
        SHPMiniWebBrowserVC *vc = (SHPMiniWebBrowserVC *)[[navigationController viewControllers] objectAtIndex:0];
        vc.applicationContext = self.applicationContext;
        vc.hiddenToolBar = false;
        vc.titlePage = @"BPP-Digibank";
        vc.urlPage = @"https://www.csebanking.it/mobile/deviceRecognitionAction.do?abi=05262";
        NSLog(@"urlPageConsole:  %@",vc.urlPage);
        /***************************************************************************************************************/
    }
    else if([[segue identifier] isEqualToString:@"toLiked"]) {
        SHPLikesViewController * vc = (SHPLikesViewController *)[segue destinationViewController];
        SHPLikedToLoader *loader = [[SHPLikedToLoader alloc] init];
        SHPProduct *product = [[SHPProduct alloc] init];
        product = [self.products objectAtIndex:self.selectedIndex];
        NSLog(@"Preparing Segue for Product %@", product.title);
        loader.product = product;
        loader.userDC.delegate = vc;
        vc.applicationContext = self.applicationContext;
        vc.loader = loader;
    }

}

-(void)goToMap{
    [self performSegueWithIdentifier: @"toMap" sender: self];
}

-(void)didFinishProductTour {
    NSLog(@"FINITO PRODUCT TOUR");
    if (![self.applicationContext getVariable:LAST_LOADED_CATEGORIES]) {
        NSLog(@"LOADING CATEGORIES...");
        //[self waitToLoadData];
        //[self performSegueWithIdentifier:@"waitToLoadData" sender:self];
    } else {
        // categories can be loaded also by SHPProductDetailView if the application is launched
        // with a tap on a post's notification. Coming back on this view directly launches
        // loading.
        [self firstLoad:self.applicationContext];
    }
    
    // TODO CREARE DIALOG CON MESSAGGIO: “Per ottenere la distanza dalle offerte nella tua zona, Ciaotrip ti chiederà di accedere ai servizi di Localizzazione del tuo smartphone. Puoi attivare i servizi successivamente nella sezione Impostazioni > Privacy > Localizzazione.”
    // se SI chiamare
    //    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    //    [appDelegate initializeLocation];
}

-(void)reloadTable {
    // useful, but not if called from the nsurlconnection delegate (that auto-runs messages to the delegate on the calling thread)
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView reloadData];
    });
}





//#pragma mark LOCATION MANAGER INTERACTIONS
//
//
//
//
//
//-(void) startLocationManager {
//    //    NSLog(@"Start updating location...");
//    // Create the manager object
//    self.locationManager = [[CLLocationManager alloc] init];
//    self.locationManager.delegate = self;
//    // This is the most important property to set for the manager. It ultimately determines how the manager will
//    // attempt to acquire location and thus, the amount of power that will be consumed.
//    self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
//    // Once configured, the location manager must be "started".
//    [self.locationManager startUpdatingLocation];
//    //    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(userPaused:) userInfo:nil repeats:NO];
//
//    [self performSelector:@selector(stopUpdatingLocation:) withObject:TIMED_OUT afterDelay:self.applicationContext.settings.locationTimeout];
//}
//
///*
// * We want to get and store a location measurement that meets the desired accuracy. For this example, we are going to use horizontal accuracy as the deciding factor. In other cases, you may wish to use vertical accuracy, or both together.
// */
//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
//    [self.locationMeasurements addObject:newLocation];
//    if (newLocation.horizontalAccuracy < 0) return;
//    if (self.bestEffortAtLocation == nil || self.bestEffortAtLocation.horizontalAccuracy > newLocation.horizontalAccuracy) {
//        self.bestEffortAtLocation = newLocation;
//        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
//            //            NSLog(@"Location: lat: %f, lon: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
//            [self stopUpdatingLocation:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
//            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:TIMED_OUT];
//            // call the remote service
//            //            double lat = self.bestEffortAtLocation.coordinate.latitude;
//            //            double lon = self.bestEffortAtLocation.coordinate.longitude;
//            //            [self.productDC searchByLocation:lat lon:lon];
//            [self searchProducts];
//            //        [self.productDC searchByLocation:40.187890 lon:18.226190];
//        }
//    }
//    [self.tableView reloadData];
//}
//
//- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    // The location "unknown" error simply means the manager is currently unable to get the location.
//    // We can ignore this error for the scenario of getting a single location fix, because we already have a
//    // timeout that will stop the location manager to save power.
//    if ([error code] == kCLErrorDenied) {
//        //        NSLog(@"Location services still disabled!!!!!!!!!!!!");
//        NSString *alertMessage = NSLocalizedString(@"LocDisabledMessageLKey", nil);
//        self.locationServicesDisabledError = YES;
//        [self showMessageView:alertMessage];
//        return;
//    }
//    if ([error code] != kCLErrorLocationUnknown) {
//        [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
//    }
//}
//
//- (void)stopUpdatingLocation:(NSString *)state {
//    //    NSLog(@"Location State: %@", state);
//    if (self.locationServicesDisabledError) {
//        return;
//    }
//    [self.locationManager stopUpdatingLocation];
//    self.locationManager.delegate = nil;
//    if ([state isEqualToString:TIMED_OUT]) {
//        //        NSLog(@"Location unavailable.");
//        //        NSLog(@"Asking around the dummy location 40.187890 / 18.226190");
//        //        [self searchProducts];
//        // or Try Again...
//        //        [self hideAllAccessoryViews];
////        [self showLocationErrorView];
//    } else if ([state isEqualToString:@"Error"]) {
//        //        NSLog(@"Error!!!! Location is active for the app?");
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:TIMED_OUT];
////        [self showLocationErrorView];
//    }
//}


//-----------------------------------------------------------------//
//START LOAD PRODUCTS
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
    if (!self.loader.searchLocation){
        if(self.applicationContext.searchLocation) {
            self.loader.searchLocation = self.applicationContext.searchLocation;
        } else {
            self.loader.searchLocation = self.applicationContext.lastLocation;
        }
    }
    self.loader.authUser = self.applicationContext.loggedUser;
    self.loader.searchStartPage = searchStartPage;
    self.loader.searchPageSize = self.applicationContext.settings.mainListSearchPageSize;
    
    NSLog(@"self.loader.searchLocation %@", self.loader.searchLocation);
    [self.loader loadProducts];
}

// DC delegate
- (void)loaded:(NSArray *)loadedProducts {
    [self.refreshControl endRefreshing];
    isLoadingData = NO;
    noMoreData = NO;
//    UITableViewCell *moreCell = [self moreButtonCell];
//    [self updateMoreButtonCell:moreCell];
//    [self hideAccessoryView];
    
    for (SHPProduct *product in loadedProducts) {
        //NSLog(@"category OID: %@",product.category);
        NSDictionary *arrayOidTypeCategories = (NSDictionary *)[self.applicationContext getVariable:DICTIONARY_CATEGORIES];
        product.categoryType=[arrayOidTypeCategories valueForKey:product.category];
        //NSLog(@"category TYPE: %@",product.categoryType);
    }
    
    if (loadedProducts.count > 0) {
        //NSLog(@"loadedProducts...%d - searchPageSize: %d",loadedProducts.count, searchPageSize);
        [self.navigationItem.rightBarButtonItem setEnabled:TRUE];
        if (!self.products) {
            self.products = [[NSMutableArray alloc] init];
        }
        [self.products addObjectsFromArray:loadedProducts];
        if (loadedProducts.count < searchPageSize) {
            noMoreData = YES;
            NSLog(@"noMoreData...1");
        }
        [self reloadTable];
    }
    else if (loadedProducts.count == 0 && self.products.count == 0) {
        NSLog(@"NO ITEMSSSSSS!!!!!!!!!!!!!");
        if (!self.products) {
            self.products = [[NSMutableArray alloc] init];
        }
        [self reloadTable];
    }
    else if (loadedProducts.count == 0) {
        noMoreData = YES;
        NSLog(@"noMoreData...2");
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
//END LOAD PRODUCTS
//-----------------------------------------------------------------//



#pragma mark -
#pragma mark Table cell asynch image support

- (void)startIconDownload:(SHPProduct *)product forIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"started startIconDownload for indexPath: %d [%@]", indexPath.row, product.longDescription);
    SHPIconDownloader *iconDownloader = [self.imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader == nil)
    {
        NSLog(@"Starting IconDownloader for product %@ - %@", product.longDescription, product.imageURL);
        iconDownloader = [[SHPIconDownloader alloc] init];
        iconDownloader.imageURL = product.imageURL;
        iconDownloader.imageWidth = (int)self.applicationContext.settings.mainListImageWidth;
        iconDownloader.imageHeight = (int)self.applicationContext.settings.mainListImageHeight;
        iconDownloader.imageCache = self.applicationContext.mainListImageCache;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [self.imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
    }
    //    NSLog(@"End StartIconDownloader...");
}

// called by our ImageDownloader when an icon is ready to be displayed
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
            
            //            UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[cell.contentView viewWithTag:201];
            //            [activityIndicator stopAnimating];
            //            activityIndicator.hidden = YES;
            //imageView.image = image;
        }
    }
    [self.imageDownloadsInProgress removeObjectForKey:indexPath];
}


//#pragma mark -
//#pragma mark Deferred image loading (UIScrollViewDelegate)
//
// Load images for all onscreen rows when scrolling is finished
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

-(void)moreButtonPressed:(id)sender
{
    //    NSLog(@"More Button pressed");
    searchStartPage = searchStartPage + 1;
    self.loader.searchStartPage = searchStartPage;
    [self searchMore];
    UITableViewCell *moreCell = [self moreButtonCell];
    if (moreCell) {
        [self updateMoreButtonCell:moreCell];
    }
}

// if visible, returns the cell of the moreButton
-(UITableViewCell *)moreButtonCell {
    if (self.products && self.products.count > 0) {
        // we can also test this: if last cell.identifier == LastCellIdent...
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


-(void)updateMoreButtonCell:(UITableViewCell *)cell {
    [SHPComponents updateMoreButtonCell:cell noMoreData:noMoreData isLoadingData:isLoadingData];
}



- (void)didTapImageHeader{
    NSLog(@"TO WEB ****************");
    [self performSegueWithIdentifier:@"toWebViewNav" sender:self];
}



- (void)tapImage:(UITapGestureRecognizer *)gesture {
    NSLog(@"TAP IMAGE AT INDEX PATH!!!!!");
    UIImageView* imageView = (UIImageView*)gesture.view;
    self.selectedIndex = [(NSNumber*)imageView.property intValue];
    SHPProduct *product = [self.products objectAtIndex:self.selectedIndex];
    //NSLog(@" --------------- %@ -- %d",product.categoryType , self.selectedIndex);
    if ([self isMenuHidden]) { // is hidden then show
        _beforeLastContentOffset = 0;
        _lastContentOffset = 0;
    }
    NSLog(@"categoryType %@",product.categoryType);
    if([product.categoryType isEqualToString:CATEGORY_TYPE_COVER]){
        [self performSegueWithIdentifier: @"toShopDetail" sender: self];
    }else{
        [self performSegueWithIdentifier: @"toProductDetail" sender: self];
    }
}


// MENU HIDING SECTION

-(BOOL)isMenuHidden {
    UIView *tabBarView = self.tabBarController.tabBar;
    if (tabBarView.frame.origin.y > _tabBarY) { // is hidden
        return TRUE;
    }
    return FALSE;
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
                //                NSLog(@"Image is nil for product %@", product.longDescription);
            }
        }
    }
}


//-(void)labelTapped:(UITapGestureRecognizer *)gestureRecognizer
//{
//    UIImageView *theTappedImageView = (UIImageView *)gestureRecognizer.view;
//    //NSInteger tag = theTappedImageView.property;
//    //Plant *myPlant = [myPlants objectAtIndex:tag-32];
//    NSLog(@"gestureRecognizer! %@",theTappedImageView.property);
//    NSNumber *_index = (NSNumber *)theTappedImageView.property;
//    NSInteger index = [_index intValue];
//    SHPLikeDC *dc = [[SHPLikeDC alloc] init];
//    dc.likeDelegate = self;
//    SHPProduct *product = [self.products objectAtIndex:index];
//    SHPLikeDC *oldLikeTask = [self.likesInProgress objectForKey:product.oid];
//    NSLog(@"+++++++++++5");
//    if (oldLikeTask) {
//        NSLog(@"oldLikeTask!");
//        [oldLikeTask cancelConnection];
//        [self.likesInProgress removeObjectForKey:product.oid];
//    } else {
//        NSLog(@"OLD LIKE TASK NOT FOUND!");
//    }
//    [self.likesInProgress setObject:dc forKey:product.oid];
//    
//    //UILabel *likesCountLabel = (UILabel *)[button.superview viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_LIKESCOUNT_VIEW_TAG];
//    //UILabel *likesCountLabel = (UILabel *)[button.superview viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_LIKESCOUNT_VIEW_TAG];
//    if(product.userLiked) {
//        NSLog(@"was Unlike changing to Like");
//        product.likesCount--;
//        //likesCountLabel.text = [NSString stringWithFormat:@"%d", (int)product.likesCount];
//        //[SHPComponents setLikeButton:button withState:SHPCONST_LIKE_COMMAND];
//        [dc unlike:product withUser:self.applicationContext.loggedUser];
//        [self showLikeHUD:NO];
//    } else {
//        NSLog(@"was Like changing to Unlike");
//        product.likesCount++;
//        //likesCountLabel.text = [NSString stringWithFormat:@"%d", (int)product.likesCount];
//        //[SHPComponents setLikeButton:button withState:SHPCONST_UNLIKE_COMMAND];
//        [dc like:product withUser:self.applicationContext.loggedUser];
//        [self showLikeHUD:YES];
//    }
//    product.userLiked = !product.userLiked;
//    //[self.tableView reloadData];
//}


// LIKE DELEGATE & LIKE-BUTTON-HANDLER
//-(void)cellButtonLikePressed:(id)sender {
//    NSLog(@"cellButtonLikePressed!");
//    if (!self.applicationContext.loggedUser) {
//        [self performSegueWithIdentifier:@"toLogin" sender:self];
//        return;
//    }
//    UIButton *button = (UIButton *)sender;
//    NSNumber *_index = (NSNumber *)button.property;
//    NSInteger index = [_index intValue];
//    
//    SHPLikeDC *dc = [[SHPLikeDC alloc] init];
//    dc.likeDelegate = self;
//    SHPProduct *product = [self.products objectAtIndex:index];
//    SHPLikeDC *oldLikeTask = [self.likesInProgress objectForKey:product.oid];
//    NSLog(@"+++++++++++5");
//    if (oldLikeTask) {
//        NSLog(@"oldLikeTask!");
//        [oldLikeTask cancelConnection];
//        [self.likesInProgress removeObjectForKey:product.oid];
//    } else {
//        NSLog(@"OLD LIKE TASK NOT FOUND!");
//    }
//    [self.likesInProgress setObject:dc forKey:product.oid];
//    
//    
//    UILabel *likesCountLabel = (UILabel *)[button.superview viewWithTag:SHPCONST_MAIN_LIST_PRODUCT_LIKESCOUNT_VIEW_TAG];
//    if(product.userLiked) {
//        NSLog(@"was Unlike changing to Like");
//        product.likesCount--;
//        likesCountLabel.text = [NSString stringWithFormat:@"%d", (int)product.likesCount];
//        [SHPComponents setLikeButton:button withState:SHPCONST_LIKE_COMMAND];
//        [dc unlike:product withUser:self.applicationContext.loggedUser];
//        [self showLikeHUD:NO];
//    } else {
//        NSLog(@"was Like changing to Unlike");
//        product.likesCount++;
//        likesCountLabel.text = [NSString stringWithFormat:@"%d", (int)product.likesCount];
//        [SHPComponents setLikeButton:button withState:SHPCONST_UNLIKE_COMMAND];
//        [dc like:product withUser:self.applicationContext.loggedUser];
//        [self showLikeHUD:YES];
//    }
//    product.userLiked = !product.userLiked;
//}



//---------------------------------------------------//
// START FUNCTIONS LIKE
//---------------------------------------------------//
// LIKE LIST PAGE
-(void)goToListLikes:(id)sender {
    NSLog(@"goToListLikes!");
    UIButton *button = (UIButton *)sender;
    self.selectedIndex = [(NSNumber *)button.property intValue];
    SHPProduct *product = [[SHPProduct alloc] init];
    product = [self.products objectAtIndex:self.selectedIndex];
    if(product.likesCount>0){
        [self performSegueWithIdentifier:@"toLiked" sender:self];
    }
}

-(void)cellButtonLikePressedBig:(id)sender {
    NSLog(@"cellButtonLikePressedBig!");
    if (!self.applicationContext.loggedUser) {
        NSLog(@"self.applicationContext.loggedUser NULL!");
        [self performSegueWithIdentifier:@"toLogin" sender:self];
        return;
    }
    NSLog(@"self.applicationContext.loggedUser OK!");
    UIButton *button = (UIButton *)sender;
    NSInteger index = [(NSNumber *)button.property intValue];
    
    SHPLikeDC *dc = [[SHPLikeDC alloc] init];
    dc.likeDelegate = self;
    SHPProduct *product = [self.products objectAtIndex:index];
    SHPLikeDC *oldLikeTask = [self.likesInProgress objectForKey:product.oid];
    
    if (oldLikeTask) {
        NSLog(@"oldLikeTask!");
        [oldLikeTask cancelConnection];
        [self.likesInProgress removeObjectForKey:product.oid];
    } else {
        NSLog(@"OLD LIKE TASK NOT FOUND!");
    }
    [self.likesInProgress setObject:dc forKey:product.oid];
    
    if(product.userLiked) {
        NSLog(@"was Like changing to Unlike");
        product.likesCount--;
        //NSString *likesCountLabel = [NSString stringWithFormat:@"%d %@", (int)product.likesCount, NSLocalizedString(@"LikeLKey", nil)];
        //[button setTitle:likesCountLabel forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"icon_like_white_60X60"] forState:UIControlStateNormal];
        [dc unlike:product withUser:self.applicationContext.loggedUser];
        [self showLikeHUD:NO];
    } else {
        NSLog(@"was Unlike changing to Like");
        product.likesCount++;
        //NSString *likesCountLabel = [NSString stringWithFormat:@"%d %@", (int)product.likesCount, NSLocalizedString(@"LikeLKey", nil)];
        //[button setTitle:likesCountLabel forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"icon_like_red_60X60"] forState:UIControlStateNormal];
        [dc like:product withUser:self.applicationContext.loggedUser];
        [self showLikeHUD:YES];
    }
    product.userLiked = !product.userLiked;
}

-(void)showLikeHUD:(BOOL)liked {
    NSLog(@"showLikeHUD %d - %@", liked, self.hud);
    [self.hud hide:YES];
    if (liked) {
        self.hud.labelText = NSLocalizedString(@"LikedLKey", nil);
        self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkbox-circle"]];
    } else {
        self.hud.labelText = NSLocalizedString(@"UnlikedLKey", nil);
        self.hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkbox-circle"]];
    }
    self.hud.animationType = MBProgressHUDAnimationZoom;
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.center = self.view.center;
    [self.hud show:YES];
    [self.hud hide:YES afterDelay:0.7];
}

// enforces button value
-(void)updateLikeButtonWithState:(NSString *)state product:(SHPProduct *)p {
    NSLog(@"updateLikeButtonWithState %@", p);
    UITableViewCell *cell = [self cellForProduct:p];
    if (cell) {
        UIButton *buttonHeart= (UIButton *)[cell viewWithTag:107];
        if(p.userLiked==NO) {
            [buttonHeart setImage:[UIImage imageNamed:@"icon_like_white_60X60"] forState:UIControlStateNormal];
        } else {
            [buttonHeart setImage:[UIImage imageNamed:@"icon_like_red_60X60"] forState:UIControlStateNormal];
        }
        UIButton *buttonLike = (UIButton *)[cell viewWithTag:105];
        NSString *countLiked =[NSString stringWithFormat:@"%ld %@", (long)p.likesCount, NSLocalizedString(@"LikeLKey", nil)];
        [buttonLike setTitle:countLiked  forState:UIControlStateNormal];
    }
}
//---------------------------------------------------//
// END FUNCTIONS LIKE
//---------------------------------------------------//

//*****************************************************//
//START DELEGATE DC LIKE SHPLikeDC
//*****************************************************//
-(void)likeDCLiked:(SHPProduct *)product {
    //    NSLog(@"Liked product %@", product.oid);
    [self.likesInProgress removeObjectForKey:product.oid];
    [self updateLikeButtonWithState:SHPCONST_UNLIKE_COMMAND product:product];
    //    NSLog(@"End Liked callback");
}

-(void)likeDCUnliked:(SHPProduct *)product {
    //    NSLog(@"Unliked product %@", product.oid);
    [self.likesInProgress removeObjectForKey:product.oid];
    [self updateLikeButtonWithState:SHPCONST_LIKE_COMMAND product:product];
    //    NSLog(@"End Unliked callback");
}

-(void)likeDCErrorForProduct:(SHPProduct *)product withCode:(NSString *)code {
    NSLog(@"Like-servce network error for product %@ with error %@", product.oid, code);
}
//*****************************************************//
//END DELEGATE DC LIKE SHPLikeDC
//*****************************************************//



-(UITableViewCell *)cellForProduct:(SHPProduct *)p {
    NSLog(@"CELL FOR PRODUCT");
    NSArray *indexes = [self.tableView indexPathsForVisibleRows];
    for (NSIndexPath *index in indexes) {
        if (index.row <= self.products.count - 1) { // index.row can also include the last cell (next page cell) - that was to go in a separate section. But it's too late :)
            SHPProduct *prodForIndex = [self.products objectAtIndex:index.row];
            if ([prodForIndex.oid isEqualToString:p.oid]) {
                //                NSLog(@"PROD FOUND AT INDEX %d!", index.row);
                UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:index];
                return cell;
            }
        }
    }
    return nil;
}

// MODAL DELEGATE

//////// MODAL DELEGATE

//static NSString *LAST_LOADED_CATEGORIES = @"lastLoadedCategories";
static NSString *CATEGORIES_KEY = @"categories";

- (void)setupViewController:(UIViewController *)controller didFinishSetupWithInfo:(NSDictionary *)setupInfo {
    if ([setupInfo objectForKey:CATEGORIES_KEY]) {
        [self updateViewForCategory:[setupInfo objectForKey:@"category"]];
        [self.applicationContext setVariable:LAST_LOADED_CATEGORIES withValue:[setupInfo objectForKey:CATEGORIES_KEY]];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateViewForCategory:(SHPCategory *)category {
    if (self.selectedCategory) {
        if (![category.oid isEqualToString:self.selectedCategory.oid]) {
            self.selectedCategory = category;
            //            self.selectedCategory = [category.oid isEqualToString:@"/"] ? nil : category;
            [self saveSelectedCategory];
            [self updateViewTitle:self.selectedCategory.name];
            //            ((UILabel *)self.navigationItem.titleView).text = self.selectedCategory.name;
            [self initializeData];
        } // else nothing because the categorie didn't change
    } else {
        self.selectedCategory = category;
        [self saveSelectedCategory];
        [self updateViewTitle:self.selectedCategory.name];
        //        ((UILabel *)self.navigationItem.titleView).text = self.selectedCategory.name;
        [self initializeData];
    }
}

-(void)saveSelectedCategory {
    //    NSLog(@"Saving last selected category!");
    [self.applicationContext.onDiskData setObject:self.selectedCategory forKey:LAST_SELECTED_CATEGORY_KEY];
    //    NSLog(@"selectedCategory %@", [self.applicationContext.onDiskData objectForKey:LAST_SELECTED_CATEGORY_KEY]);
    [self.applicationContext saveOnDiskData];
    
    //    [SHPCaching saveDictionary:self.applicationContext.onDiskData inFile:SHPCONST_LAST_DATA_FILE_NAME];
}

- (void)setupViewController:(UIViewController *)controller didCancelSetupWithInfo:(NSDictionary *)setupInfo {
    //    NSLog(@"Cancel pressed!");
    if ([setupInfo objectForKey:CATEGORIES_KEY]) {
        NSArray *lastLoadedCategories = [setupInfo objectForKey:CATEGORIES_KEY];
        if (lastLoadedCategories) {
            [self.applicationContext setVariable:LAST_LOADED_CATEGORIES withValue:[setupInfo objectForKey:CATEGORIES_KEY]];
        }
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

// called by UIView + WelcomePanel Category
-(void)reloadAfterSignin {
    //    [self showActivityView];
    [self initializeData];
}

// called by UIView + WelcomePanel Category
-(void)reloadAfterRegistration {
    NSLog(@"Reloading after Registration!!!!!!!!!!!!!!!!!!!!!!!!!");
    //    [self showActivityView];
    //    [self initializeData];
}


-(void)goToAuthentication{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    SHPAuthenticationVC *vc = (SHPAuthenticationVC *)[sb instantiateViewControllerWithIdentifier:@"StartAuthentication"];
    vc.applicationContext = self.applicationContext;
    //vc.disableButtonClose = YES;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:NULL];
}
//// ************ LOAD CATEGORIES **************
//
//-(void)showWaiting:(NSString *)label {
//    SHPAppDelegate *app = (SHPAppDelegate *) [UIApplication sharedApplication].delegate;
//    NSLog(@"SHOW WAITING... ... ... ... %@ %@", app.window, self.loadingHud);
//    if (!self.loadingHud) {
//        self.loadingHud = [[MBProgressHUD alloc] initWithWindow:app.window];
//        [app.window addSubview:self.loadingHud];
//        self.loadingHud.center = app.window.center;
//        self.loadingHud.animationType = MBProgressHUDAnimationZoom;
//    }
//    self.loadingHud.labelText = label;
//    [self.loadingHud show:YES];
//}
//
//-(void)loadCategories {
////    [self showWaiting:@"Loading..."];
//    [self performSegueWithIdentifier:@"waitToLoadData" sender:self];
////    SHPCategoryDC *categoryDC = [[SHPCategoryDC alloc] init];
////    categoryDC.delegate = self;
////    [categoryDC getAll];
//}
//
////static NSString *LAST_LOADED_CATEGORIES = @"lastLoadedCategories";
////static NSString *CATEGORIES_KEY = @"categories";
//
//-(void)categoriesLoaded:(NSMutableArray *)_categories error:(NSError *)error {
//    [self.loadingHud hide:YES];
//    if (error) {
//        NSLog(@"ERROR LOADING CATEGORIES!");
//        categoriesAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkErrorTitleLKey", nil) message:NSLocalizedString(@"NetworkErrorLKey", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"TryAgainLKey", nil) otherButtonTitles:nil];
//        [categoriesAlertView show];
//    } else {
//        NSLog(@"CATEGORIES LOADED!!!!!");
//        for (SHPCategory *c in _categories) {
//            NSLog(@"================== Category: %@", c);
//            [self.applicationContext setVariable:LAST_LOADED_CATEGORIES withValue:_categories];
//        }
//
//        [self firstLoad];
//        //    if (self.showCategoryAll) {
//        //        SHPCategory *categoryAll = [[SHPCategory alloc] init];
//        //        categoryAll.oid = @"/";
//        //        categoryAll.name = NSLocalizedString(@"CategoryAllLKey", nil);
//        //        [self.categories insertObject:categoryAll atIndex:0];
//        //        [self.applicationContext setVariable:LAST_LOADED_CATEGORIES withValue:self.categories];
//        //    }
//        //    [self.tableView reloadData];
//    }
//}
//
//// *******************


-(void)dealloc {
    NSLog(@"MAIN LIST DEALLOCATING...");
}



- (IBAction)returnProductsVC:(UIStoryboardSegue *)segue {
    NSLog(@"from segue id: %@", segue.identifier);
    if ([segue.sourceViewController isKindOfClass:[SHPSetCityViewController class]]) {
        NSLog(@"from view controller SHPSetCityViewController");
        SHPSetCityViewController *vc = segue.sourceViewController;
        vc.applicationContext = self.applicationContext;
    }
}


///function for notification
-(void)openViewForProductID:(NSString *)contentURI {
    [self.navigationController popToRootViewControllerAnimated:NO];
    NSArray *listItems = [contentURI componentsSeparatedByString:@"://"];
    if (listItems.count < 2) {
        NSLog(@"Error splitting contentURI %@", contentURI);
        return;
    }
    //NSString *uri_type = [listItems objectAtIndex:0]; // not used for the moment
    NSString *productID = [listItems objectAtIndex:1];
    //    NSString* productID = [contentURI stringByReplacingOccurrencesOfString:@"deal://" withString:@""];
    NSLog(@"Content URI: %@", contentURI);
    NSLog(@"opening view for ProductID: %@",productID);
    self.selectedProductID = productID;
    [self performSegueWithIdentifier:@"toProductDetail" sender:self];
}


-(void)openAlertMessage:(NSString *)message{
    NSLog(@"openAlertMessage: %@",message);
    UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertMessage show];
}


-(void)openWebViewForURL:(NSString *)url {
    [self.navigationController popToRootViewControllerAnimated:NO];
    NSLog(@"openWebViewForURL: %@",url);
    self.urlNotification = url;
    [self performSegueWithIdentifier:@"ProductUrl" sender:self];
}

-(void)waitToLoadData{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SHPLoadInitialDataViewController *viewController = (SHPLoadInitialDataViewController *)[storyboard instantiateViewControllerWithIdentifier:@"waitToLoadData"];
    viewController.applicationContext=self.applicationContext;
    viewController.caller = self;
    //UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"waitToLoadData"];
    //[self.navigationController pushViewController: viewController animated:YES];
    [self.navigationController presentViewController:viewController animated:NO completion:nil];
}
- (void)toInfoFirstLoad{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Info" bundle:nil];
    SHPInfoFirstLoadVC *vc = (SHPInfoFirstLoadVC *)[sb instantiateViewControllerWithIdentifier:@"infoFirstLoad"];
    //UINavigationController *navigationController = [sb instantiateViewControllerWithIdentifier:@"infoFirstLoad"];//[segue destinationViewController];
    //SHPInfoFirstLoadVC *vc = (SHPInfoFirstLoadVC *)[[navigationController viewControllers] objectAtIndex:0];
    vc.applicationContext = self.applicationContext;
    //navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:NULL];
}

- (IBAction)unwindToProductsVC:(UIStoryboardSegue*)sender{
    NSLog(@"unwindToProductsVC: %@ ", sender);
    [self initializeData];
}



- (IBAction)buttonCallPhone:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSLog(@" \n clicked.tag %@",button.property);
    NSString *stringNumber = (NSString *)button.property;
    NSString *phoneNumber = [@"telprompt://" stringByAppendingString:stringNumber];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

-(SHPProduct *)setPhoneNumber:(SHPProduct*)product {
    NSDictionary *properties = product.properties;
    NSDictionary *phoneDictionary = (NSDictionary *)[properties valueForKey:@"phone"];
    NSArray *values = (NSArray *)[phoneDictionary valueForKey:@"values"];
    if (values.count > 0) {
        product.phoneNumber = [values objectAtIndex:0];
    }
    product.phoneNumber = [product.phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return product;
}


@end

