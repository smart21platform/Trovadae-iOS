//
//  SHPExploreHomeViewController.m
//  Shopper
//
//  Created by andrea sponziello on 06/10/12.
//
//

#import "SHPExploreHomeViewController.h"
#import "SHPCategory.h"
#import "SHPProductsViewController2.h"
#import <CoreLocation/CoreLocation.h>
#import "SHPComponents.h"
#import "SHPImageRequest.h"
#import "SHPServiceUtil.h"
#import "SHPApplicationContext.h"
#import "SHPAppDelegate.h"
#import "SHPSearchViewController.h"
#import "SHPCategorySearchProductsLoader.h"
#import "SHPProductDC.h"
#import "SHPLoadInitialDataViewController.h"
#import "SHPExploreSubLevelTableViewController.h"
#import "SHPCaching.h"
#import "SHPSearchTVC.h"
#import "SHPProductsCollectionVC.h"
#import "SHPInfoFirstLoadVC.h"
#import "SHPConstants.h"
#import "SHPCategoryDC.h"

@interface SHPExploreHomeViewController ()
@end

@implementation SHPExploreHomeViewController

//static UIColor *selectedCellBGColor;
//static NSString *LAST_LOADED_CATEGORIES = @"lastLoadedCategories";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@" +++++++++ viewDidLoad +++++++");
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.applicationContext = appDelegate.applicationContext;

    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    searchAround=[[settingsDictionary objectForKey:@"searchAround"] boolValue];
    singlePoi = [[settingsDictionary objectForKey:@"singlePoi"] boolValue];
    
    
    //selectedCellBGColor = [[UIColor alloc] initWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
    [self customizeTitle:nil];
    self.searchBar.delegate = self;
    
    if(self.applicationContext.isFirstLaunch){
        [self firstLaunch];
    }
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self inizialize];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear %@",self.applicationContext.searchLocationName);
    [self deselectCurrentRow];
    [self.tableView reloadData];
    [self updateLocationInfo];
}

-(void)viewDidDisappear:(BOOL)animated {
}

-(void)inizialize
{
    NSDictionary *exploreHomeDictionary = [self.applicationContext.plistDictionary objectForKey:@"View"];
    exploreHomeDictionary = [exploreHomeDictionary objectForKey:@"ExploreHome"];
    BOOL viewBoxLink = [[exploreHomeDictionary objectForKey:@"viewBoxLink"] boolValue];
    urlBoxLink = [exploreHomeDictionary objectForKey:@"urlBoxLink"];
    NSLog(@"viewBoxLink:: %d",viewBoxLink);
    self.viewBoxLink.hidden = YES;
    if(viewBoxLink == YES){
        self.viewBoxLink.hidden = NO;
        UITapGestureRecognizer *tapBoxBanner = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self action:@selector(actionTapBoxBanner)];
        [self.viewBoxLink addGestureRecognizer:tapBoxBanner];
    }
    
    self.labelTitleContainer.text = NSLocalizedString(@"LabelTitleContainerLKey", nil);
    [self setContainer];
    
    // PRELOADED CATEGORIES
    BOOL preloaded_categories = YES; // get from settings
    if (preloaded_categories && ![self.applicationContext getVariable:LAST_LOADED_CATEGORIES]) {
        NSLog(@"Categories are preloaded. Loading from file...");
        NSString *filePath = [[[NSBundle mainBundle] resourcePath]
                                   stringByAppendingPathComponent:@"preloaded-categories"];
        NSData *data = [[NSFileManager defaultManager] contentsAtPath:filePath];
        NSArray *_categories_array = [SHPCategoryDC jsonToCategories:data];
        NSMutableDictionary *dictionaryCategories = [[NSMutableDictionary alloc]init];
        for (SHPCategory *c in _categories_array) {
            NSLog(@"================== Category: %@ %@ %@ %d", c.oid, c.name, c.type, (int)c.visibility);
            [dictionaryCategories setValue:c.type forKey:c.oid];
        }
        [self.applicationContext setVariable:LAST_LOADED_CATEGORIES withValue:_categories_array];
        [self.applicationContext setVariable:DICTIONARY_CATEGORIES withValue:dictionaryCategories];
        [self firstLoad:self.applicationContext];
    }
    // END PRELOADED CATEGORIES
    
    else if (![self.applicationContext getVariable:LAST_LOADED_CATEGORIES]) {
        NSLog(@"PRIMA APPARIZIONE!!!!! CARICO CATEGORIE!");
        [self waitToLoadData];
    }
    else {
        NSLog(@"INIZIALIZZO LA LISTA.");
        [self firstLoad:self.applicationContext];
    }
    
//    // json test
//    // jsontest
//    NSString *filePath = [[[NSBundle mainBundle] resourcePath]
//                          stringByAppendingPathComponent:@"jsonsearch.json.txt"];
//    NSData *jsonData = [[NSFileManager defaultManager] contentsAtPath:filePath];
//    NSError* error;
//    NSDictionary *objects = [NSJSONSerialization
//                             JSONObjectWithData:jsonData
//                             options:kNilOptions
//                             error:&error];
//    
//    NSLog(@"ERROR JSON? %@", error);
//    NSLog(@"OBJECTS: %@", objects);

}

//-(void)didFinishProductTour {
//    NSLog(@"FINITO PRODUCT TOUR");
//    [self firstLoad:self.applicationContext];
//}

-(void)firstLaunch {
    NSLog(@"IS FIRST LAUNCH? .....");
    if ([self.applicationContext isFirstLaunch]) {
        [self.applicationContext setFirstLaunchDone];
        [self toInfoFirstLoad];
    }
}

-(void)firstLoad:(SHPApplicationContext *)applicationContextWithCategories {
    NSLog(@"FIRST LOAD.................%@",applicationContextWithCategories);
    self.applicationContext = applicationContextWithCategories;
    //self.categories = (NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES];
    [self initializeCategories];
    if(singlePoi){
        self.searchBar.placeholder = NSLocalizedString(@"SearchPlaceholderLKey", nil);
    }
    else {
        NSLog(@"navigationItem.");
        self.searchBar.placeholder = NSLocalizedString(@"SearchProductsShopsUsersLKey", nil);
        //self.searchBar2.hidden=TRUE;
    }

//    UITextField *searchField = [self.searchBar valueForKey:@"_searchField"];
//    [searchField setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
//    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_linear_gray_cerca"]];
//    icon.image = [icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
//    [icon setTintColor:[UIColor whiteColor]];
//    [self.searchBar setImage:icon.image forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
    
    self.searchBar2=self.searchBar;
    self.showCategoryAll = NO;
    self.lastLocationStatusEnabled = [self locationServicesEnabled];
    NSLog(@"========>>>>>>>> %@", [SHPApplicationContext restoreSearchLocation]);
    NSLog(@"searchLocationName: %@ %@",self.applicationContext.searchLocationName,self.applicationContext.searchLocation);
    [self setupLocationEnabledCountTimer];
}


-(void)initializeCategories {
    self.categories = [[NSMutableArray alloc] init];
    NSString *oidParent;
    NSArray *cachedCategories = [(NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES] copy];
    NSLog(@"cachedCategories: %@", cachedCategories);
    if (cachedCategories && cachedCategories.count > 0) {
        for (SHPCategory *cat in cachedCategories) {
            BOOL visibility = [cat getVisibility:CATEGORY_VISIBILITY_SEARCH];
             NSLog(@"visibility %@ - %d - %d", cat.name, (int)cat.visibility, visibility);
            if (![cat.oid isEqualToString:@"/"] && visibility == YES) { // if present do-not-add "all" category
                NSLog(@"adding %@", cat.oid);
                if(![self controlCategory:cat.oid] ){
                    oidParent=cat.oid;
                    [self.categories addObject:cat];
                }
            }
        }
    }
}


-(BOOL)controlCategory:(NSString *)oid {
    NSString *oidSearch = [NSString stringWithFormat:@"%@/",oid];
    if (self.categories && self.categories.count > 0) {
        for (SHPCategory *cat in self.categories) {
            //oidParent=[NSString stringWithFormat:@"%@/",cat.oid];
            NSLog(@"OID %@ - %@", cat.oid, oidSearch);
            if ([oidSearch hasPrefix:cat.oid]) {
                NSLog(@"ESISTE %@", cat.oid);
                return YES;
            }
        }
    }
    return NO;
}


-(BOOL)controlSubCategory:(NSString *)oid {
    NSString *oidSearch = [NSString stringWithFormat:@"%@/",oid];
    NSArray *cachedCategories = [(NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES] copy];
    if (cachedCategories && cachedCategories.count > 0) {
        for (SHPCategory *cat in cachedCategories) {
            NSLog(@"OID %@ - %@", cat.oid, oidSearch);
            if ([cat.oid hasPrefix:oidSearch]) {
                NSLog(@"ESISTE %@", cat.oid);
                return YES;
            }
        }
    }
    return NO;
}

-(void)initializeSubCategories:(SHPCategory *)selectedCategory {
    self.subCategories = [[NSMutableArray alloc] init];
    NSString *oidParent;
    NSArray *cachedCategories = [(NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES] copy];
    for (SHPCategory *cat in cachedCategories) {
        oidParent=[NSString stringWithFormat:@"%@/",selectedCategory.oid];
        BOOL visibility = [cat getVisibility:CATEGORY_VISIBILITY_SEARCH];
        if ([cat.oid isEqualToString:selectedCategory.oid]){
            [self.subCategories addObject:cat];
        }
        else if ([cat.oid hasPrefix:oidParent] && visibility == YES){
            NSLog(@"adding %@", cat.oid);
            [self.subCategories addObject:cat];
        }
    }
    NSLog(@"subCategories %@", self.subCategories);
}

-(void)setContainer{
    NSLog(@"XXXXXXXXXXXXX   ->  setContainer");
    SHPProductsCollectionVC *containerVC;
    containerVC = [self.childViewControllers objectAtIndex:0];
    containerVC.applicationContext = self.applicationContext;
    containerVC.author = self.applicationContext.loggedUser;
    [containerVC loadProducts];
    //[containerVC.collectionView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    //[self fetchPlaceDetail];
}


-(void)initInfoButton {
    NSLog(@"INFO BUTTON %@", self.navigationItem.rightBarButtonItem);
    if (!self.navigationItem.rightBarButtonItem) {
        return;
    }
    UIBarButtonItem *barButton = [SHPComponents positionInfoButton:self];
    [self.navigationItem setRightBarButtonItem:barButton];
}

-(void)updateLocationInfo {
    if (self.applicationContext.lastLocation.coordinate.latitude == 0 && self.applicationContext.lastLocation.coordinate.latitude == 0) {
        // error
        UIColor *locColor = [UIColor redColor];
        [self setLocationInfoText:NSLocalizedString(@"locationInfoErrorLKey", nil) color:locColor];
    }
    else {
        if (!self.geocoder) {
            self.geocoder = [[CLGeocoder alloc] init];
        }
        [self.geocoder reverseGeocodeLocation:self.applicationContext.lastLocation
                            completionHandler:^(NSArray *placemarks, NSError *error) {
                                //NSLog(@"reverseGeocodeLocation:completionHandler:");
                                if (error) {
                                    NSLog(@"Geocode failed with error: %@", error);
                                    return;
                                }
                                if(placemarks && placemarks.count > 0) {
                                    //do something
                                    CLPlacemark *topResult = [placemarks objectAtIndex:0];
                                    // 30-39 via ciro menotti, soleto puglia
                                    //                           NSString *addressTxt = [NSString stringWithFormat:@"%@ %@,%@ %@",
                                    //                                                   [topResult subThoroughfare],[topResult thoroughfare],
                                    //                                                   [topResult locality], [topResult administrativeArea]];
                                    NSString *addressTxt = [NSString stringWithFormat:@"%@", [topResult locality]];
                                    if ([CLLocationManager locationServicesEnabled] == NO) {
                                        //                           locColor = [UIColor redColor];
                                        NSLog(@"locationServicesEnabled NO");
                                    }
                                    self.applicationContext.lastLocationName = addressTxt;
                                    [self.tableView reloadData];
                                }
                            }];
    }
}

-(void)setLocationInfoText:(NSString *)text color:(UIColor *)color {
    UIButton *button = (UIButton *) self.navigationItem.rightBarButtonItem.customView;
    [button setTitle:text forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
}

-(void)customizeTitle:(NSString *)title {
    if(title == nil){
        NSLog(@"title1 %@", title);
        UIImage *logo = [UIImage imageNamed:@"title-logo"];
        UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logo];
        self.navigationItem.titleView = titleLogo;
        self.navigationItem.title=nil;
    }else{
        NSLog(@"title2 %@", title);
        [SHPComponents titleLogoForViewController:self];
        self.navigationItem.title = title;
    }
}

- (void)infoAction:(id)sender {
    NSLog(@"CLLocationManager locationServicesEnabled? %d", [CLLocationManager locationServicesEnabled]);
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"CLLocationManager locationServices Disabled");
        NSString *alertMessage = NSLocalizedString(@"LocDisabledMessageLKey", nil);
        [self alert:alertMessage];
    } else if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        NSLog(@"CLLocationManager locationServices Disabled for this App");
        NSString *alertMessage = NSLocalizedString(@"LocationNotAvailableLKey", nil);
        [self alert:alertMessage];
    } else if (self.applicationContext.lastLocation.coordinate.latitude == 0 && self.applicationContext.lastLocation.coordinate.longitude == 0) {
        NSString *alertMessage = NSLocalizedString(@"NoLocMessageLKey", nil);
        [self alert:alertMessage];
    }
}


-(void)setupLocationEnabledCountTimer {
    NSLog(@"START TIMERRRRRRR");
    self.locationEnabledTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(updatedLocationMessageError:) userInfo:nil repeats:YES];
}

-(void)updatedLocationMessageError:(NSTimer *)timer {
    if ([self locationServicesEnabled] != self.lastLocationStatusEnabled) {
        [self.tableView reloadData];
    }
    self.lastLocationStatusEnabled = [self locationServicesEnabled];
}

-(void)alert:(NSString *)message {
    NSString *title = nil;
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

-(void)deselectCurrentRow {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)initializeData {
    NSLog(@"Init category view controller");
    [self.geocoder cancelGeocode];
    self.selectedCategory = nil;
}

-(BOOL)locationServicesEnabled {
    if([CLLocationManager locationServicesEnabled]){
//        NSLog(@"Location Services Enabled");
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied) {
//            alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
//                                               message:@"To re-enable, please go to Settings and turn on Location Service for this app."
//                                              delegate:nil
//                                     cancelButtonTitle:@"OK"
//                                     otherButtonTitles:nil];
//            [alert show];
            return NO;
        }
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





#pragma mark - Table view data source

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && searchAround == YES) {
        return 77;
    } else {
        return 82;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    //if ([typeApp isEqualToString:TYPE_APP_RESTAURANT]){
    if(searchAround == NO){
        //NSLog(@"numberOfSectionsInTableView searchAround:%hhd",searchAround);
        return 1;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger num;
    if( section == 0 && searchAround == YES){
        //NSLog(@"numberOfRowsInSection");
        num = 1;
    }
    else {
         //NSLog(@"numberOfRowsInSection %d",self.categories.count);
        num = self.categories ? self.categories.count : 0;
    }
    return num;// + 1; // + 1 is the searchBar
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"rendering index   %d self.categories %@", indexPath.row, self.categories);
    UITableViewCell *cell = nil;
    static NSString *positionCellId = @"PositionCell";
    static NSString *shopCellId = @"CategoryCell";
    
    if (indexPath.section == 0 && searchAround == YES) {
        cell = [_tableView dequeueReusableCellWithIdentifier:positionCellId];
        if (![self locationServicesEnabled] && !self.applicationContext.searchLocationName) {
            UILabel *textLabel = (UILabel *)[cell viewWithTag:10];
            UILabel *cityLabel = (UILabel *)[cell viewWithTag:11];
            UILabel *errorLabel = (UILabel *)[cell viewWithTag:12];
            UILabel *selectCityLabel = (UILabel *)[cell viewWithTag:14];
            UIButton *infoButton = (UIButton *) [cell viewWithTag:15];
            [infoButton addTarget:self action:@selector(locationInfo) forControlEvents:UIControlEventTouchUpInside];
            
            UIImageView *pinIcon = (UIImageView *)[cell viewWithTag:3];
            textLabel.hidden = YES;
            cityLabel.hidden = YES;
            pinIcon.hidden = YES;
            errorLabel.hidden = NO;
            selectCityLabel.hidden = NO;
            infoButton.hidden = NO;
            errorLabel.text = @"Localizzazione disattivata. Cerca intorno ad una Città.";
        } else {
            UILabel *textLabel = (UILabel *)[cell viewWithTag:10];
            UILabel *cityLabel = (UILabel *)[cell viewWithTag:11];
            UIImageView *pinIcon = (UIImageView *)[cell viewWithTag:3];
            UILabel *errorLabel = (UILabel *)[cell viewWithTag:12];
            UILabel *selectCityLabel = (UILabel *)[cell viewWithTag:14];
            UIButton *infoButton = (UIButton *) [cell viewWithTag:15];
            textLabel.hidden = NO;
            cityLabel.hidden = NO;
            pinIcon.hidden = NO;
            errorLabel.hidden = YES;
            selectCityLabel.hidden = YES;
            infoButton.hidden = YES;
                
            if (self.applicationContext.searchLocationName) {
                self.applicationContext.searchLocation=[SHPApplicationContext restoreSearchLocation];
                pinIcon.image = [UIImage imageNamed:@"marker-06"];
                textLabel.text = NSLocalizedString(@"SearchAround", nil);
                cityLabel.text = self.applicationContext.searchLocationName;
            } else {
                pinIcon.image = [UIImage imageNamed:@"marker-07"];
                textLabel.text = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"SearchAround", nil), NSLocalizedString(@"you", nil)];
                cityLabel.text = self.applicationContext.lastLocationName;
            }
        }
        
    } else {
        cell = [_tableView dequeueReusableCellWithIdentifier:shopCellId];
        NSInteger catIndex = indexPath.row;
        SHPCategory *cat = [self.categories objectAtIndex:catIndex];
        UILabel *textLabel = (UILabel *)[cell viewWithTag:10];
        textLabel.text = [cat localName];
        
        // selected color
//        UIView *myBackView = [[UIView alloc] initWithFrame:cell.frame];
//        myBackView.backgroundColor = selectedCellBGColor;
//        cell.selectedBackgroundView = myBackView;
        
        
        UIImageView *iconView = (UIImageView *)[cell viewWithTag:20];
        [self customIcon:iconView];
        NSString *categoryIconURL = [cat iconURL];
        //REGOLE UPLOAD IMAGES CATEGORIES:
        // 1- carico image dalla cache se presente in cache
        // SALTO 2- carico image dal disco se salvata in memoria e aggiungo alla cache
        // 3- carico image, salvo su disco e aggiungo alla cache
        // 4- carico image di default
        UIImage *cacheIcon = [self.applicationContext.categoryIconsCache getImage:categoryIconURL];
        UIImage *archiveIcon = [SHPCaching restoreImage:categoryIconURL];
        //UIImage *staticIcon = [cat getStaticIconFromDisk];
        if (cacheIcon) {
            iconView.image = cacheIcon;
        }
        //else if (archiveIcon) {
          //  NSLog(@"archiveIcon");
          //  iconView.image = archiveIcon;
        //}
//        else if (staticIcon) {
//            NSLog(@"staticIcon");
//            iconView.image = staticIcon;
//        }
        else {
            if (archiveIcon) {
                NSLog(@"archiveIcon");
                iconView.image = archiveIcon;
            }
            NSLog(@"imageRquest %@", categoryIconURL);
            
            SHPImageRequest *imageRquest = [[SHPImageRequest alloc] init];
            [imageRquest downloadImage:categoryIconURL
             completionHandler:
             ^(UIImage *image, NSString *imageURL, NSError *error) {
                 if (image) {
                     NSLog(@"Image LOADED");
                     [SHPCaching saveImage:image inFile:imageURL];
                     [self.applicationContext.categoryIconsCache addImage:image withKey:imageURL];
                     
                     NSArray *indexes = [self.tableView indexPathsForVisibleRows];
                     for (NSIndexPath *index in indexes) {
                         if (index.row == indexPath.row) {
                             UITableViewCell *cell = (UITableViewCell *)[(UITableView *)self.tableView cellForRowAtIndexPath:index];
                             UIImageView *iconV= (UIImageView *)[cell viewWithTag:20];
                             iconV.image = image;
                         }
                     }
                     
                 } else {
                    NSLog(@"Image not loaded!");
                     // put an image that indicates "no image"?
                     UIImage *icon = [UIImage imageNamed:@"category_icon__default"];
                     iconView.image = icon;
                     //iconView.image = nil;
                 }
             }];
        }
    }
    return cell;
}


-(void)customIcon:(UIImageView *)iconImage{
    iconImage.layer.cornerRadius = iconImage.frame.size.height/2;
    iconImage.layer.masksToBounds = YES;
    iconImage.layer.borderWidth = 0.1;
}


-(void)locationInfo {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Localizzazione disattivata"
                                        message:@"Se vuoi cercare intorno alla tua posizione devi attivare i servizi di localizzazione in Impostazioni > Privacy > Localizzazione. Oppure imposta la ricerca attorno ad una Città."
                                        delegate:nil
                                        cancelButtonTitle:@"OK"
                                         otherButtonTitles:nil];
    [alert show];
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected s:%ld i:%ld", (long)indexPath.section, (long)indexPath.row);
//    if (indexPath.row == 0 && indexPath.section == 0) {
//        [self startSearchController];
//    } else
    if (indexPath.section == 0 && searchAround == YES) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performSegueWithIdentifier:@"SelectPosition" sender:self];
    }
    else { //if (indexPath.section == 1) {
        NSInteger catIndex = indexPath.row;// - 1;
        if (catIndex >= 0 && catIndex < self.categories.count) {
            self.selectedCategory = [self.categories objectAtIndex:catIndex];
            if([self controlSubCategory:self.selectedCategory.oid]){
                [self initializeSubCategories:self.selectedCategory];
                [self performSegueWithIdentifier:@"toSubLevel" sender:self];
            }
            else{
                [self performSegueWithIdentifier:@"Explore" sender:self];
            }
        } else {
            NSLog(@"(SHPExploreHomeViewController) Error on cell index 0!! Read comments in this code snippet.");
        }
    }
}

// SEARCH BAR DELEGATE
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"--------------------------start editing!!!!!!!!!!!!!!!!");
    [self startSearchController];
    //UITextField *txfSearchField = [self.searchBar valueForKey:@"_searchField"];
    //txfSearchField.backgroundColor = [UIColor darkGrayColor];
    return NO;
}



-(void)startSearchController {
    // resetting the searchbox position to be completly visible
//    [self.tableView setContentOffset:CGPointMake(0,0) animated:NO];
//    SHPSearchViewController *searchController = [[SHPSearchViewController alloc] init];
//    searchController.buttonsViewHidden = NO;
//    searchController.searchBarPlaceholder = NSLocalizedString(@"SearchProductsShopsUsersLKey", nil);
//    [self displaySearchController:searchController];
    [self performSegueWithIdentifier:@"toSearch" sender:self];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    NSLog(@"Segue.......");
    if ([[segue identifier] isEqualToString:@"Explore"]) {
        NSLog(@"------------------ ??????? °°°°°°°°° Explore!!!!");
        SHPProductsViewController2 *productsViewController = [segue destinationViewController];
        productsViewController.selectedCategory = self.selectedCategory;
        //productViewController.detailImageCache = self.detailImageCache;
        productsViewController.applicationContext = self.applicationContext;
        // products loader
        SHPCategorySearchProductsLoader *loader = [[SHPCategorySearchProductsLoader alloc] init];
        loader.categoryId = self.selectedCategory.oid;
        loader.authUser = self.applicationContext.loggedUser;
        loader.searchStartPage = 0;
        loader.searchPageSize = self.applicationContext.settings.mainListSearchPageSize;
        if (self.applicationContext.searchLocation) {
            loader.searchLocation = self.applicationContext.searchLocation;
        } else {
            loader.searchLocation = self.applicationContext.lastLocation;
        }
        loader.productDC.delegate = productsViewController;
        productsViewController.loader = loader;
    }
    else if ([[segue identifier] isEqualToString:@"waitToLoadData"]) {
        NSLog(@"------------------ ??????? °°°°°°°°° waitToLoadData!!!!");
        SHPLoadInitialDataViewController *vc = (SHPLoadInitialDataViewController *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.caller = self;
    }
    else if ([[segue identifier] isEqualToString:@"Search"]) {
        NSLog(@"CERCO!");
        SHPSearchViewController *searchController = [segue destinationViewController];
//        searchController.buttonsViewHidden = NO;
        searchController.applicationContext = self.applicationContext;
        if(singlePoi){
            searchController.searchBarPlaceholder = NSLocalizedString(@"SearchPlaceholderLKey", nil);
            searchController.listMode = 10;
        }
        else {
            searchController.searchBarPlaceholder = NSLocalizedString(@"SearchProductsShopsUsersLKey", nil);
            searchController.listMode = 10;
        }
    }
    else if ([[segue identifier] isEqualToString:@"toSearch"]) {
    //    SHPSearchTVC *searchController = [segue destinationViewController];
        //searchController.applicationContext = self.applicationContext;
//        if(singlePoi){
//            searchController.searchBarPlaceholder = NSLocalizedString(@"SearchPlaceholderLKey", nil);
//            searchController.listMode = 10;
//        }
//        else {
//            searchController.searchBarPlaceholder = NSLocalizedString(@"SearchProductsShopsUsersLKey", nil);
//            searchController.listMode = 10;
//        }
    }
    else if ([[segue identifier] isEqualToString:@"ProductTour"]) {
//        SHPInfoViewController *vc = (SHPInfoViewController *)[segue destinationViewController];
//        vc.applicationContext = self.applicationContext;
//        vc.callerViewController = self;
//        NSLog(@"CALLED PRODUCT TOUR %@", vc.callerViewController);
    }
    else if ([[segue identifier] isEqualToString:@"toSubLevel"]) {
        SHPExploreSubLevelTableViewController *vc = (SHPExploreSubLevelTableViewController *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.callerViewController = self;
        vc.categories=self.subCategories;
        vc.selectedCategory = self.selectedCategory;
        NSLog(@"CALLED toSubLevel %@", self.subCategories);
    }

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"MEMORY WARNING INSIDE EXPORE BY CATEGORIES!");
}

//- (IBAction)searchAction:(id)sender {
////    SHPSearchViewController *searchController = [[SHPSearchViewController alloc] initWithNibName:@"SearchView" bundle:[NSBundle mainBundle]];
//    SHPSearchViewController *searchController = [[SHPSearchViewController alloc] init];
//    [self displaySearchController:searchController];
//}


//- (IBAction)actionSearch:(id)sender {
//    [self performSegueWithIdentifier:@"Search" sender:self];
//}

-(void)actionTapBoxBanner{
    NSLog(@"show website %@", urlBoxLink);
    NSString *url;
    if (urlBoxLink  && ![urlBoxLink  isEqualToString:@""]) {
        if(![urlBoxLink hasPrefix:@"http"]){
            url = [NSString stringWithFormat:@"http://%@", urlBoxLink];
        }else{
            url = urlBoxLink;
        }
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
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

-(void)waitToLoadData{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SHPLoadInitialDataViewController *viewController = (SHPLoadInitialDataViewController *)[storyboard instantiateViewControllerWithIdentifier:@"waitToLoadData"];
    viewController.applicationContext=self.applicationContext;
    viewController.caller = self;
    //UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"waitToLoadData"];
    //[self.navigationController pushViewController: viewController animated:YES];
    [self.navigationController presentViewController:viewController animated:NO completion:nil];
}
- (IBAction)searchAction:(id)sender {
    [self startSearchController];
}

@end
