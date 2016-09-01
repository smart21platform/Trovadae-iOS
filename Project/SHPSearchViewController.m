//
//  SHPSearchViewController.m
//  Dressique
//
//  Created by andrea sponziello on 04/01/13.
//
//

#import "SHPSearchViewController.h"
#import "SHPAppDelegate.h"
#import "SHPApplicationContext.h"
#import "SHPProductsTableList.h"
#import "SHPShopsTableList.h"
#import "SHPUsersTableList.h"
#import "SHPSearchProductsLoader.h"
#import "SHPSearchShopsLoader.h"
#import "SHPSearchUsersLoader.h"
#import "SHPComponents.h"
#import "SHPProductDetail.h"
//#import "SHPUserProfileViewController.h"
#import "SHPExploreHomeViewController.h"
#import "SHPProductDC.h"
#import "SHPShopDC.h"
#import <QuartzCore/QuartzCore.h>
#import "SHPImageUtil.h"
#import "SHPPoiDetailTVC.h"

@interface SHPSearchViewController () {
//    BOOL userHeaderInitialized;
//    UIView *buttonsSectionView;
    UIButton *productsButton;
    UIButton *shopsButton;
    UIButton *usersButton;
    float animDuration;
    UIView *tapToDismissKeyboardView;
    BOOL dismissingAnimationStarted;
}

@end

@implementation SHPSearchViewController
BOOL singlePoi;
UIColor *tintColor;

@synthesize applicationContext;
@synthesize productSelected;
@synthesize shopSelected;
@synthesize userSelected;
@synthesize listMode;

@synthesize searchBar;
//@synthesize buttonsView;
//@synthesize buttonsViewHidden;

@synthesize textToSearch;
@synthesize searchTimer;
@synthesize lastProductsTextSearch;
@synthesize lastShopsTextSearch;
@synthesize lastUsersTextSearch;

@synthesize aProductWasDeleted;

// tableView
@synthesize tableView;
@synthesize listProducts;
@synthesize listShops;
@synthesize listUsers;
@synthesize tapDismissController;

//static NSString *TYPE_APP_RESTAURANT = @"restaurant";
//NSString *typeApp;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

enum {
    PRODUCTS_LIST_MODE = 10,
    SHOPS_LIST_MODE = 20,
    USERS_LIST_MODE = 30
};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"laclassegiusta2?");
    
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    singlePoi=[[settingsDictionary objectForKey:@"singlePoi"] boolValue];
    
    NSDictionary *navigationBarDictionary = [self.applicationContext.plistDictionary  objectForKey:@"BarTab"];
    tintColor = [SHPImageUtil colorWithHexString:[navigationBarDictionary valueForKey:@"tintColor"]];
    [self.segmentedButtons setTintColor:tintColor];

    
   // NSLog(@"View Did Load...%@ - color: %@",self.applicationContext.plistDictionary, tintColor);
    animDuration = 0.2;
    
    // dismiss view controller
//    self.tapDismissController = [[UITapGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(dismissController)];
//    self.tapDismissController.cancelsTouchesInView = YES; // YES = tap on buttons is captured by the view
//    [self.view addGestureRecognizer:self.tapDismissController];
//    self.tapDismissController.enabled = YES;
    
    // init tableView
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    
//    [self.view addSubview:self.tableView];
    [self.tableView registerNib:[UINib nibWithNibName:@"ActivityCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ActivityCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"NoProductsCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NoItemsCell2"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ShopCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"ShopCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"UserCell"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.hidden = YES;
    
   
    
    NSLog(@"2");
//    self.tableView.allowsSelection = NO;
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorColor = [UIColor whiteColor];
    
    
    self.textToSearch = @"";
    self.lastProductsTextSearch = @"";
    
    // init the initial list-mode
    NSLog(@"self.listMode : %d ",(int)self.listMode);
    if (self.listMode == 0 || self.listMode == PRODUCTS_LIST_MODE) {
        self.listMode = PRODUCTS_LIST_MODE;
        self.segmentedButtons.selectedSegmentIndex = 0;
    } else if (self.listMode == SHOPS_LIST_MODE) {
        self.segmentedButtons.selectedSegmentIndex = 1;
    } else if (self.listMode == USERS_LIST_MODE) {
        self.segmentedButtons.selectedSegmentIndex = 2;
    }
    NSLog(@"4");
//    // init search bar. the searchbar is added to navbar in viewWillAppear
    
//    self.searchBarView = [SHPComponents viewByXibName:@"SearchBar"];
//    self.searchBar = (UISearchBar *) [self.searchBarView viewWithTag:1];
//    self.searchBar = [[UISearchBar alloc] initWithFrame:self.navigationController.navigationBar.frame];
////    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]]; // active button color
////    [self.navigationController.navigationBar setBarTintColor:[UIColor lightGrayColor]];
//    
//    
////    self.searchBar.tintColor = self.applicationContext.settings.appColor;
//    self.searchBar.delegate = self;
//    self.searchBar.placeholder = self.searchBarPlaceholder; //NSLocalizedString(@"SearchProductsShopsUsersLKey", nil);
//    self.navigationItem.titleView = self.searchBar;
//    self.buttonsView = [SHPComponents searchButtonsSectionHeaderWithTarget:self];
//    self.buttonsView.backgroundColor = self.applicationContext.settings.appColor;
//    [self.view addSubview:self.searchBarView];
//    [self.view addSubview:self.buttonsView];
//    [self.view bringSubviewToFront:self.searchBarView];
//    // references are to change the background color on selection
//    productsButton = (UIButton *)[self.buttonsView viewWithTag:10];
//    shopsButton = (UIButton *)[self.buttonsView viewWithTag:20];
//    usersButton = (UIButton *)[self.buttonsView viewWithTag:30];
    
//    [self checkListModeButton];
    
//    self.textToSearch = @"a";
//    [self changeListMode:self.listMode];
    if(singlePoi){
        [self.segmentedButtons setHidden:YES];
        [self.segmentedButtons removeSegmentAtIndex:1 animated:NO];
        //[self.segmentedButtons removeSegmentAtIndex:1 animated:NO];
    } else {
        [self.segmentedButtons setTitle:NSLocalizedString(@"SearchProductsButtonLKey", nil) forSegmentAtIndex:0];
        [self.segmentedButtons setTitle:NSLocalizedString(@"SearchShopsButtonLKey", nil) forSegmentAtIndex:1];
        [self.segmentedButtons setTitle:NSLocalizedString(@"SearchUsersButtonLKey", nil) forSegmentAtIndex:2];
    }
    

//    // segmented control colors
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                [UIFont boldSystemFontOfSize:17], UITextAttributeFont,
//                                [UIColor blackColor], UITextAttributeTextColor,
//                                nil];
//    [self.segmentedButtons setTitleTextAttributes:attributes forState:UIControlStateNormal];
//    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
//    [self.segmentedButtons setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
    NSLog(@"SETTING DELEGATE! SEARCH %@", self.searchBar);
    self.searchBar.delegate = self;
    NSLog(@"SEARCH delegate %@", self.searchBar.delegate);
    self.navigationItem.titleView = self.searchBar;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isMovingToParentViewController) {
        [self.searchBar becomeFirstResponder];
    }
    self.searchBar.placeholder = self.searchBarPlaceholder;
    NSString *trackerName = [[NSString alloc] initWithFormat:@"SearcPage: %@", self.searchBar.text];
    //[SHPComponents trackerGoogleAnalytics:trackerName];
}


//-(void)viewWillAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
////    if (buttonsView.frame.origin.y > 0) {
////        NSLog(@"VIEW RETURN FROM A DETAIL VIEW!");
////        [self.navigationController setNavigationBarHidden:YES animated:YES];
////    }
//}

//-(void)viewDidAppear:(BOOL)animated {
//    // NSLog(@"VIEW DID APPEAR!!!!");
//    NSLog(@"NAVBAR HIDDEN? %d", self.navigationController.navigationBar.hidden);
//    
//    // if appeared back from a detail view
//    [self deselectCurrentRow];
//    
//    // if appeared back from a detail view where the product was deleted
//    if (aProductWasDeleted) {
//        [self.listProducts.products delete:aProductWasDeleted];
//        [self reloadTable];
//    }
//    if (buttonsView.frame.origin.y > 0) {
//        NSLog(@"VIEW DID APPEAR RETURN! NO ANIMATION!");
//        return;
//    }
//    NSLog(@"VIEW DID APPEAR CONTINUE!");
//    
//    // else animate the view initial layout
//    
//    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
//    
////    self.searchBarView.hidden = NO;
//    
//    CGRect searchBarFrame = self.searchBarView.frame;
//    searchBarFrame.origin.y = 0;
//    self.searchBarView.frame = searchBarFrame;
//    CGRect buttonsFrame = self.buttonsView.frame;
//    buttonsFrame.origin.y = 0;
//    if (self.buttonsViewHidden) {
//        buttonsFrame.size.height = 0;
//    }
////    buttonsFrame.origin.y = self.searchBarView.frame.origin.y + self.searchBarView.frame.size.height;
//    buttonsView.frame = buttonsFrame;
//    self.searchBarView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
//    
//    // tableView size & position
//    CGRect tableFrame = self.tableView.frame;
//    CGRect navBarFrame = self.navigationController.navigationBar.frame;
//    NSLog(@">>>> NAVBAR FRAME HEIGHT %f", navBarFrame.size.height);
//    NSLog(@">>>> VIEW HEIGHT %f", self.view.frame.size.height);
//    float topDistance = self.searchBarView.frame.size.height - navBarFrame.size.height;
//    NSLog(@">>>> TOP DISTANCE %f", topDistance);
//    tableFrame.size.height = self.view.frame.size.height - topDistance;
//    tableFrame.origin.y = topDistance;
//    self.tableView.frame = tableFrame;
//    NSLog(@">>>> TABLE VIEW FINALE HEIGHT %f", self.tableView.frame.size.height);
//    
//    [self.searchBar setShowsCancelButton:YES animated:YES];
//    
////    [self startAnimationShow:animDuration completionHandler:nil];
//}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //    NSLog(@"(SHPShopDetailViewController) viewWillDisappear");
    //    NSLog(@"%d", self.isMovingFromParentViewController);
    if (self.isMovingFromParentViewController) {
        [self disposeLists];
    }
    // pop out (disposing) isMovingFromParent = 1
    // push in isMovingFromParent = 0
}

-(void)deselectCurrentRow {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)dismissKeyboard {
    [self.searchBar becomeFirstResponder];
    [self.searchBar resignFirstResponder];
    [self enableSearchBarCancelButton];
}

-(void)enableSearchBarCancelButton {
    for(id subview in [self.searchBar subviews])
    {
        if ([subview isKindOfClass:[UIButton class]]) {
            [subview setEnabled:YES];
        }
    }
}

//-(void)dismissController {
//    NSLog(@"(SHPSearchViewController) dismissing controller...");
//    
//    dismissingAnimationStarted = YES;
//    
//    // this was moved on startAnimationClose completionHandler:
//    // [self disposeLists];
//    // [(SHPExploreHomeViewController *)self.parentViewController hideSearchController:self];
//    [self dismissKeyboard];
//    [self.searchBar setShowsCancelButton:NO animated:YES];
//    [self startAnimationClose:animDuration completionHandler:nil];
//}

-(void)disposeLists {
    [self.listProducts disposeResources];
    [self.listShops disposeResources];
    [self.listUsers disposeResources];
}

-(void)productDetail {
    NSLog(@"STORYBOARD: %@",  self.storyboard);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SHPProductDetail *productViewController = [storyboard instantiateViewControllerWithIdentifier:@"ProductDetailStoryboardID"];
    productViewController.product = self.productSelected;
    productViewController.applicationContext = self.applicationContext;
    [self.navigationController pushViewController:productViewController animated:YES];
}

//-(void)shopDetail {
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//    SHPPoiDetailTVC *shopVC = [storyboard instantiateViewControllerWithIdentifier:@"ShopDetailStoryboardID"];
//    shopVC.shop = self.shopSelected;
//    shopVC.applicationContext = self.applicationContext;
//    [self.navigationController pushViewController:shopVC animated:YES];
//}

-(void)userDetail {
    NSLog(@"STORYBOARD: %@",  self.storyboard);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SHPUserProfileViewController *profileVC = [storyboard instantiateViewControllerWithIdentifier:@"UserProfileStoryboardID"];
    //profileVC.user = self.userSelected;
    //profileVC.applicationContext = self.applicationContext;
    [self.navigationController pushViewController:profileVC animated:YES];
}

-(void)setupProductsList {
    SHPSearchProductsLoader *searchProductsLoader = [[SHPSearchProductsLoader alloc] init];
    searchProductsLoader.authUser = self.applicationContext.loggedUser;
    searchProductsLoader.searchPageSize = self.applicationContext.settings.productsTablePageSize;
    
    self.listProducts = [[SHPProductsTableList alloc] init];
    self.listProducts.loader = searchProductsLoader;
//    [self setupList:self.listProducts];
    self.listProducts.imageCache = self.applicationContext.smallImagesCache;
    self.listProducts.tableView = self.tableView;
    __weak SHPSearchViewController *weakSelf = self;
    self.listProducts.tableViewDelegate = weakSelf;
    self.listProducts.applicationContext = self.applicationContext;
    self.listProducts.tapHandler = ^(SHPProduct *_productSelected, NSInteger onIndex) {
        weakSelf.productSelected = _productSelected;
//        [weakSelf performSegueWithIdentifier:@"ProductDetail" sender:weakSelf];
        [weakSelf productDetail];
    };
    [self.listProducts initialize];
}

-(void)setupShopsList {
    SHPSearchShopsLoader *loader = [[SHPSearchShopsLoader alloc] init];
    loader.searchPageSize = self.applicationContext.settings.productsTablePageSize;
    
    self.listShops = [[SHPShopsTableList alloc] init];
    self.listShops.loader = loader;
    self.listShops.imageCache = self.applicationContext.smallImagesCache;
    self.listShops.tableView = self.tableView;
    __weak SHPSearchViewController *weakSelf = self;
    self.listShops.tableViewDelegate = weakSelf;
    self.listShops.applicationContext = self.applicationContext;
    [self.listShops initialize];
}

-(void)setupUsersList {
    SHPSearchUsersLoader *loader = [[SHPSearchUsersLoader alloc] init];
    loader.searchPageSize = self.applicationContext.settings.productsTablePageSize;
    
    self.listUsers = [[SHPUsersTableList alloc] init];
    self.listUsers.loader = loader;
    self.listUsers.imageCache = self.applicationContext.smallImagesCache;
    self.listUsers.tableView = self.tableView;
    __weak SHPSearchViewController *weakSelf = self;
    self.listUsers.tableViewDelegate = weakSelf;
    self.listUsers.applicationContext = self.applicationContext;
    [self.listUsers initialize];
}

//// called only once, on view initialization
//-(void)loadList:(SHPProductsTableList *) list {
////    [list initialize];
//    [list searchProducts];
//    [self reloadTable]; // initial load to show the initial status (loading activity)
//}

- (void)viewDidUnload
{
    NSLog(@"UNLOADING PROFILE...");
    [self setSearchBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self setTableView:nil];
    self.applicationContext = nil;
    [self.listProducts disposeResources];
    self.listProducts = nil;
    [self.listShops disposeResources];
    self.listShops = nil;
    [self.listUsers disposeResources];
    self.listUsers = nil;
    self.productSelected = nil;
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARNING INSIDE SEARCH VIEW!!!!");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Section1: Shop Header, Section2: products grid
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger rows = 0;
    switch (self.listMode) {
        case PRODUCTS_LIST_MODE:
            if (self.listProducts) {
                rows = self.listProducts.numberOfRows;
            } else {
                rows = 0;
            }
            break;
        case SHOPS_LIST_MODE:
            if (self.listShops) {
                rows = self.listShops.numberOfRows;
                //NSLog(@"SHOP LIST TOTAL ROWS %d", rows);
            } else {
                rows = 0;
            }
            break;
        case USERS_LIST_MODE:
            if (self.listUsers) {
                rows = self.listUsers.numberOfRows;
                //NSLog(@"USERS LIST TOTAL ROWS %d", rows);
            } else {
                rows = 0;
            }
            break;
    }
    return rows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger rowHeight = 44;
//    if (indexPath.section == 0) {
//        rowHeight = 44.0;
//    } else {
        switch (self.listMode) {
            case PRODUCTS_LIST_MODE:
                rowHeight = [self.listProducts heightForRow:indexPath.row];
                break;
            case SHOPS_LIST_MODE:
                rowHeight = [self.listShops heightForRow:indexPath.row];
                break;
            case USERS_LIST_MODE:
                rowHeight = [self.listUsers heightForRow:indexPath.row];
                break;
        }
//    }
    return rowHeight;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    if (section == 1) {
//        if (!buttonsSectionView) {
//            buttonsSectionView = [SHPComponents searchButtonsSectionHeaderWithTarget:self];
//            buttonsSectionView.backgroundColor = [UIColor whiteColor];
//            productsButton = (UIButton *)[buttonsSectionView viewWithTag:10];
//            shopsButton = (UIButton *)[buttonsSectionView viewWithTag:20];
//            usersButton = (UIButton *)[buttonsSectionView viewWithTag:30];
//            [self checkListModeButton];
//        }
//        return buttonsSectionView;
//    }
//    return nil;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView_ cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    switch (self.listMode) {
        case PRODUCTS_LIST_MODE:
            cell = [self.listProducts cellForRow:indexPath];
            break;
        case SHOPS_LIST_MODE:
            cell = [self.listShops cellForRow:indexPath];
            break;
        case USERS_LIST_MODE:
            cell = [self.listUsers cellForRow:indexPath];
            break;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected s:%d i:%d", (int)indexPath.section, (int)indexPath.row);
    switch (self.listMode) {
        case PRODUCTS_LIST_MODE:
            break;
        case SHOPS_LIST_MODE:
            NSLog(@"SELECTED OP FOR SHOP");
            self.shopSelected = [self.listShops shopAtIndexPath:indexPath];
            [self performSegueWithIdentifier:@"toShopDetail" sender:self];
            break;
        case USERS_LIST_MODE:
            NSLog(@"SELECTED OK FOR USER");
            self.userSelected = [self.listUsers userAtIndexPath:indexPath];
            [self userDetail];
            break;
    }
}

-(void)reloadTable {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView reloadData];
    });
}

// END DC DELEGATE

-(void) productsListModePressed
{
    if (self.listMode == PRODUCTS_LIST_MODE) {
        return;
    }
    [self changeListMode: PRODUCTS_LIST_MODE];
}

-(void) shopsListModePressed
{
    if (self.listMode == SHOPS_LIST_MODE) {
        return;
    }
    [self changeListMode: SHOPS_LIST_MODE];
}

-(void) usersListModePressed
{
    if (self.listMode == USERS_LIST_MODE) {
        return;
    }
    [self changeListMode: USERS_LIST_MODE];
}

-(void)changeListMode:(int)newListMode {
    NSLog(@"CHANGE LIST MODE ");
    self.listMode = newListMode;
    switch (self.listMode) {
        case PRODUCTS_LIST_MODE: {
            NSLog(@"MODE CHANGED TO PRODUCTS");
            NSLog(@"self.textToSearch = %@", self.textToSearch);
            NSLog(@"self.lastProductsTextSearch = %@", self.lastProductsTextSearch);
            self.tableView.allowsSelection = NO;
            self.tableView.separatorColor = [UIColor whiteColor];
            if (![self.textToSearch isEqualToString:@""] && ![self.textToSearch isEqualToString:self.lastProductsTextSearch]) {
//                [self.listProducts.loader cancelOperation];
//                self.listProducts.loader.productDC.delegate = nil;
                [self.listProducts disposeResources]; // cancel all connections
                self.listProducts = nil;
                NSLog(@"INITIALIZING PRODUCTS LIST");
                [self setupProductsList];
                SHPSearchProductsLoader *loader = (SHPSearchProductsLoader *) self.listProducts.loader;
                loader.textToSearch = self.textToSearch;
                loader.searchLocation = self.applicationContext.lastLocation;
//                [self loadList:self.listProducts];
                [self.listProducts searchProducts];
                [self reloadTable];
            } else if ([self.textToSearch isEqualToString:@""]) {
                [self.listProducts disposeResources]; // cancel all connections
                self.listProducts = nil;
                // [self reloadTable];
            } else {
                [self reloadTable];
            }
            self.lastProductsTextSearch = self.textToSearch;
            
            self.listProducts.currentlyShown = YES;
            self.listShops.currentlyShown = NO;
            self.listUsers.currentlyShown = NO;
            break;
        }
        case SHOPS_LIST_MODE: {
            NSLog(@"MODE CHANGED TO SHOPS");
            NSLog(@"self.textToSearch = %@", self.textToSearch);
            NSLog(@"self.lastShopsTextSearch = %@", self.lastShopsTextSearch);
            self.tableView.allowsSelection = YES;
            self.tableView.separatorColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
            if (![self.textToSearch isEqualToString:@""] && ![self.textToSearch isEqualToString:self.lastShopsTextSearch]) {
//                [self.listShops.loader cancelOperation];
//                self.listShops.loader.shopDC.shopsLoadedDelegate = nil;
                [self.listShops disposeResources]; // cancel all connections
                self.listShops = nil;
                NSLog(@"INITIALIZING SHOPS LIST");
                [self setupShopsList];
                SHPSearchShopsLoader *loader = (SHPSearchShopsLoader *) self.listShops.loader;
                loader.textToSearch = self.textToSearch;
                loader.searchLocation = self.applicationContext.lastLocation;
                [self.listShops searchShops];
                [self reloadTable];
            } else if ([self.textToSearch isEqualToString:@""]) {
                [self.listShops disposeResources]; // cancel all connections
                self.listShops = nil;
                //[self reloadTable];
            } else {
                [self reloadTable];
            }
            self.lastShopsTextSearch = self.textToSearch;
            
            self.listProducts.currentlyShown = NO;
            self.listShops.currentlyShown = YES;
            self.listUsers.currentlyShown = NO;
            break;
        }
        case USERS_LIST_MODE: {
            NSLog(@"MODE CHANGED TO USERS");
            NSLog(@"self.textToSearch = %@", self.textToSearch);
            NSLog(@"self.lastUsersTextSearch = %@", self.lastUsersTextSearch);
            self.tableView.allowsSelection = YES;
            self.tableView.separatorColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:1.0];
            if (![self.textToSearch isEqualToString:@""] && ![self.textToSearch isEqualToString:self.lastUsersTextSearch]) {
//                [self.listUsers.loader cancelOperation];
//                self.listUsers.loader.userDC.delegate = nil;
                [self.listUsers disposeResources]; // cancel all connections
                self.listUsers = nil;
                NSLog(@"INITIALIZING USERS LIST");
                [self setupUsersList];
                SHPSearchUsersLoader *loader = (SHPSearchUsersLoader *) self.listUsers.loader;
                loader.textToSearch = self.textToSearch;
                loader.searchLocation = self.applicationContext.lastLocation;
                [self.listUsers searchUsers];
                [self reloadTable];
            } else if ([self.textToSearch isEqualToString:@""]) {
                [self.listUsers disposeResources]; // cancel all connections
                self.listUsers = nil;
                //[self reloadTable];
            } else {
                [self reloadTable];
            }
            self.lastUsersTextSearch = self.textToSearch;
            
            self.listProducts.currentlyShown = NO;
            self.listShops.currentlyShown = NO;
            self.listUsers.currentlyShown = YES;
            break;
        }
        default:
            break;
    }
//    [self reloadTable];
//    [self checkListModeButton];
}

//-(void)checkListModeButton {
//    UIColor *selectedColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
//    UIColor *unselectedColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
//    switch (self.listMode) {
//        case PRODUCTS_LIST_MODE:
//        {
//            productsButton.selected = YES;
//            productsButton.backgroundColor = selectedColor;
//            shopsButton.selected = NO;
//            shopsButton.backgroundColor = unselectedColor;
//            usersButton.selected = NO;
//            usersButton.backgroundColor = unselectedColor;
//            break;
//        }
//        case SHOPS_LIST_MODE:
//        {
//            productsButton.selected = NO;
//            productsButton.backgroundColor = unselectedColor;
//            shopsButton.selected = YES;
//            shopsButton.backgroundColor = selectedColor;
//            usersButton.selected = NO;
//            usersButton.backgroundColor = unselectedColor;
//            break;
//        }
//        case USERS_LIST_MODE:
//        {
//            productsButton.selected = NO;
//            productsButton.backgroundColor = unselectedColor;
//            shopsButton.selected = NO;
//            shopsButton.backgroundColor = unselectedColor;
//            usersButton.selected = YES;
//            usersButton.backgroundColor = selectedColor;
//            break;
//        }
//    }
//}

typedef void (^SHPStopAnimationHandler)();

//- (void)startAnimationShow:(NSTimeInterval)delay completionHandler:(SHPStopAnimationHandler)afterAnimationHandler {
////    UIView *navBarView = self.navigationController.navigationBar;
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    [UIView animateWithDuration:delay
//                         animations:^(void) {
////                             [navBarView setFrame:CGRectMake(navBarView.frame.origin.x, navBarView.frame.origin.y - navBarView.frame.size.height, navBarView.frame.size.width, navBarView.frame.size.height)];
////                             [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y - navBarView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height + navBarView.frame.size.height)];
//                             
//                             self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.7];
////                             CGRect buttonsFrame = self.buttonsView.frame;
//                             
//                             CGRect buttonsFrame = self.buttonsView.frame;
//                             buttonsFrame.origin.y = self.searchBarView.frame.origin.y + self.searchBarView.frame.size.height;
//                             self.buttonsView.frame = buttonsFrame;
////                             NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>> Button y %f", self.buttonsView.frame.origin.y);
//                             
//                         } completion:^(BOOL finished) {
//                             [self.searchBar becomeFirstResponder];
//                             CGRect tableFrame = self.tableView.frame;
//                             NSLog(@"-----> %f", self.buttonsView.frame.size.height);
//                             tableFrame.origin.y = buttonsView.frame.origin.y + self.buttonsView.frame.size.height;
//                             tableFrame.size.height = tableFrame.size.height - self.buttonsView.frame.size.height;
//                             self.tableView.frame = tableFrame;
//                         }
//     ];
//}

//- (void)startAnimationClose:(NSTimeInterval)delay completionHandler:(SHPStopAnimationHandler)afterAnimationHandler
//{
////    UIView *navBarView = self.navigationController.navigationBar;
//    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    [UIView animateWithDuration:delay
//                         animations:^(void) {
////                             [navBarView setFrame:CGRectMake(navBarView.frame.origin.x, navBarView.frame.origin.y + navBarView.frame.size.height, navBarView.frame.size.width, navBarView.frame.size.height)];
////                             [self.view setFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + navBarView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - navBarView.frame.size.height)];
//                             
//                             self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0];
//                             self.tableView.alpha = 0.0;
//                             CGRect buttonsFrame = self.buttonsView.frame;
//                             buttonsFrame.origin.y = self.searchBarView.frame.origin.y; // = 0
//                             self.buttonsView.frame = buttonsFrame;
//                             
//                         } completion:^(BOOL finished) {
//                             [self disposeLists];
//                             [(SHPExploreHomeViewController *)self.parentViewController hideSearchController:self];
//                         }
//     ];
//}

// UISEARCHBAR DELEGATE

// interesting: http://jduff.github.com/2010/03/01/building-a-searchview-with-uisearchbar-and-uitableview/

//-(void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar {
- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar {
    NSLog(@"start editing....................... %@ self.searchbar %@!", _searchBar, self.searchBar );
    NSString *preparedText = [_searchBar.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![preparedText isEqualToString:@""]) {
        [self addTapToDismissKeyboard];
    }
    
//    [self performSegueWithIdentifier:@"Explore" sender:self];
}

//- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
////    [theTextField resignFirstResponder];
//    NSLog(@"KEYBOARD RETURNED!");
//    [self removeTapToDismissKeyboard];
//    return YES;
//}

//- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
//    NSLog(@"cancel editing");
////    self.searchBar.text=@"";
//    
////    [self.searchBar setShowsCancelButton:NO animated:YES];
////    [self.searchBar resignFirstResponder];
////    self.tableView.allowsSelection = YES;
////    self.tableView.scrollEnabled = YES;
//    [self dismissController];
//}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	NSLog(@"SEARCH BUTTON PRESSED!");
    [self useResultsTable];
    
//    [self.searchBar resignFirstResponder];
//    [self removeTapToDismissKeyboard];
    
//    self.theTableView.allowsSelection = YES;
//    self.theTableView.scrollEnabled = YES;
//    [self.tableData removeAllObjects];
//    [self.tableData addObjectsFromArray:results];
//    [self.theTableView reloadData];
}

//-(void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)text {
-(void)searchBar:(UISearchBar*)_searchBar textDidChange:(NSString*)text {
    NSLog(@"_searchBar textDidChange");
    if (self.searchTimer) {
        if ([self.searchTimer isValid]) { [self.searchTimer invalidate]; }
        self.searchTimer = nil;
        //        NSLog(@"Canceled previous search...");
    }
    NSLog(@"Scheduling new search for: %@", text);
    NSString *preparedText = [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![preparedText isEqualToString:@""]) {
        self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(userPaused:) userInfo:nil repeats:NO];
    } else {
        self.tableView.hidden = YES;
        [self removeTapToDismissKeyboard];
        self.tapDismissController.enabled = YES;
    }
}

-(void)userPaused:(NSTimer *)timer {
    NSLog(@"(SHPSearchViewController) userPaused:");
    if (dismissingAnimationStarted) {
        NSLog(@"(SHPSearchViewController) The controller is dismissing animated. Stop userPaused:");
        return;
    }
    NSString *text = self.searchBar.text;
    self.textToSearch = [self prepareTextToSearch:text];
    NSLog(@"timer on userPaused: searching for %@", self.textToSearch);
    if (![self.textToSearch isEqualToString:@""]) {
        self.tableView.hidden = NO;
        [self addTapToDismissKeyboard];
        self.tapDismissController.enabled = NO;
        [self changeListMode:(int)self.listMode];
    }
}

-(void)addTapToDismissKeyboard {
    NSLog(@"------------ tapToDismissKeyboardView %@", tapToDismissKeyboardView);
    if (!tapToDismissKeyboardView) {
//        NSLog(@"CREATING: tapToDismissKeyboardView");
        tapToDismissKeyboardView = [[UIView alloc] initWithFrame:self.tableView.frame];
//        NSLog(@"x %f, y %f, w %f, h %f", self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
        // dismiss keyboard & use the table tap
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(useResultsTable)];
        tap.cancelsTouchesInView = YES; // without this, tap on buttons is captured by the view
        [tapToDismissKeyboardView addGestureRecognizer:tap];
//        tapToDismissKeyboardView.backgroundColor = [UIColor blackColor];
//        tapToDismissKeyboardView.alpha = 1.0;
        [self.view addSubview:tapToDismissKeyboardView];
        [self.view bringSubviewToFront:tapToDismissKeyboardView];
    }
}

-(void)useResultsTable {
    [self removeTapToDismissKeyboard];
    [self dismissKeyboard];
}

-(void)removeTapToDismissKeyboard {
    NSLog(@"tapToDismissKeyboardView was %@", tapToDismissKeyboardView);
    [tapToDismissKeyboardView removeFromSuperview];
    tapToDismissKeyboardView = nil;
}

-(NSString *)prepareTextToSearch:(NSString *)text {
    return [text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void)networkError {
    NSString *title = NSLocalizedString(@"NetworkErrorTitleLKey", nil);
    NSString *msg = NSLocalizedString(@"NetworkErrorLKey", nil);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    [self.tableView reloadData];
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toShopDetail"]) {
        NSLog(@"goToPoiDetail");
        SHPPoiDetailTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.shop = self.shopSelected;
        //VC.imageMap = self.imageMap;
        //VC.distance = self.product.distance;
    }
}



- (IBAction)segmentValueChanged:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *) sender;
    NSInteger selectedSegment = segmentedControl.selectedSegmentIndex;
    
    if (selectedSegment == 0) {
        NSLog(@"Button 0");
        [self productsListModePressed];
    }
    else if (selectedSegment == 1 && singlePoi) {
        NSLog(@"Button 1 %d",singlePoi);
        [self usersListModePressed];
    }
    else if (selectedSegment == 1) {
        NSLog(@"Button 1 %d",singlePoi);
        [self shopsListModePressed];
    }
    else {
        NSLog(@"Button 2");
        [self usersListModePressed];
    }

}

-(void)dealloc {
    NSLog(@"SEARCH VIEW DEALLOCATING...");
}
@end
