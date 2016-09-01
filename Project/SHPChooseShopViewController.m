//
//  SHPChooseShopViewController.m
//  Shopper
//
//  Created by andrea sponziello on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPChooseShopViewController.h"
#import "SHPShopDC.h"
#import "SHPShop.h"
#import "SHPActivityViewController.h"
#import "SHPNetworkErrorViewController.h"
//#import "SHPAddProductViewController.h"
#import "SHPAddShopViewController.h"
#import "SHPComponents.h"
#import "SHPApplicationContext.h"
#import "SHPWizardStep5Poi.h"
#import "SHPConstants.h"
#import "SHPUserInterfaceUtil.h"

@interface SHPChooseShopViewController () {

    SHPActivityViewController *activityController;
    SHPNetworkErrorViewController *errorController;
    CGRect overlayStartRect;
    CGRect overlayStopRect;
}

@property (nonatomic, assign) CGRect overlayInactiveRect;
@property (nonatomic, assign) CGRect overlayActiveRect;

@end

@implementation SHPChooseShopViewController

@synthesize modalCallerDelegate;
@synthesize applicationContext;
@synthesize shopDCNearest;
@synthesize shopDCSearch;
@synthesize shops;
@synthesize locationManager = _locationManager;
@synthesize locationMeasurements = _locationMeasurements;
@synthesize bestEffortAtLocation = _bestEffortAtLocation;
@synthesize searchTimer;
@synthesize navigationBar;
@synthesize tableView;
@synthesize searchBar;
@synthesize searchTableView;
@synthesize disableViewOverlay;
@synthesize shopsByUserSearch;
@synthesize viewModeSearch;
@synthesize lastUsedShops;
@synthesize networkError;

// private
@synthesize overlayActiveRect;
@synthesize overlayInactiveRect;


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    typeSelected = (NSString *) [self.wizardDictionary objectForKey:WIZARD_TYPE_KEY];
    self.viewModeSearch = NO;
    
    
    self.searchBar.showsCancelButton = NO;
    self.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
//    self.searchBar.tintColor = self.applicationContext.settings.appColor;
    
    
    // init tableView
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = YES;
    self.tableView.hidden = NO;
    
    // setup the pull-to-refresh view
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.tintColor = [UIColor grayColor];
    [refreshControl addTarget:self action:@selector(initializeData) forControlEvents:UIControlEventValueChanged];
    //self.refreshControl = refreshControl;
    
    
    // init searchTableView
    self.searchTableView.userInteractionEnabled = NO;
    self.searchTableView.delegate = self;
    self.searchTableView.dataSource = self;
    self.searchTableView.bounces = YES;
    self.searchTableView.hidden = YES;
    
    // init overlayView
    // http://jduff.github.com/2010/03/01/building-a-searchview-with-uisearchbar-and-uitableview/
    
    self.overlayInactiveRect = CGRectMake(self.tableView.frame.origin.x,self.tableView.frame.origin.y + self.searchBar.frame.size.height,self.view.frame.size.width,self.tableView.frame.size.height);
    self.overlayActiveRect = CGRectMake(0.0f,self.searchBar.frame.size.height,self.view.frame.size.width,self.tableView.frame.size.height);
    self.disableViewOverlay = [[UIView alloc] initWithFrame:self.overlayInactiveRect];
    self.disableViewOverlay.backgroundColor = [UIColor blackColor];
    // dismissi overlay tap
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissSearchView)];
    tap.cancelsTouchesInView = YES; // without this, tap on buttons is captured by the view
    //[self.disableViewOverlay addGestureRecognizer:tap];
    [self.viewHeader addGestureRecognizer:tap];
    
    [self localizeLabels];
    [self initializeData];
}

-(void)dismissSearchView {
    NSLog(@"dismissSearchView End...");
    //[self dismissKeyboard];
    if([self.searchBar isFirstResponder]){
        [self searchBarCancelButtonClicked:self.searchBar];
    }
}


-(void)localizeLabels{
    NSString *headerLabel = [[NSString alloc] initWithFormat:@"header-step-chooseShop-%@", typeSelected];
    NSString *textHeader = NSLocalizedString(headerLabel, nil);
    [SHPUserInterfaceUtil applyTitleString:(NSString *)textHeader toAttributedLabel:self.topMessageLabel];
    NSString *labelPlaceholderSearch = [[NSString alloc] initWithFormat:@"searchPlaceholder-step-chooseShop-%@", typeSelected];
    [self customizeTitle:NSLocalizedString(@"ChooseShopLKey", nil)];
    self.cancelButton.title = NSLocalizedString(@"CancelLKey", nil);
    self.searchBar.placeholder = NSLocalizedString(labelPlaceholderSearch, nil);
}

-(void)customizeTitle:(NSString *)title{
    self.navigationItem.title = title;
    self.navigationBar.topItem.title = title;
    UILabel *navTitleLabel = [SHPComponents appTitleLabel:title withSettings:self.applicationContext.settings];
    self.navigationBar.topItem.titleView = navTitleLabel;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)_tableView
{
    // Return the number of sections.
    if(_tableView == self.tableView) {
        return 2;
    } else {
        return 1;
    }
}

-(NSString *)tableView:(UITableView *)_tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if(_tableView == self.tableView) {
        if(section == 0 && [self.lastUsedShops count] > 0) {
            title = NSLocalizedString(@"RecentlyUsedShopsLKey", nil);
        } else if(section == 1) {
            title = NSLocalizedString(@"NearestShopsLKey", nil);
        }
    }
    return title;
}

- (NSInteger)tableView:(UITableView *)_tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    NSLog(@"numberOfRowsInSection: %d", section);
    NSInteger num = 0;
    if(_tableView == self.tableView) {
        if(section == 0) {
            num = self.lastUsedShops ? [self.lastUsedShops count] : 0;
        } else if (self.shops.count > 0 ) {
            num = [self.shops count];
        } else {
            num = 1;
        }
    } else if(_tableView == self.searchTableView) {
//        NSLog(@"searchTableView.numberOfRowsInSection!");
        num = self.shopsByUserSearch ? [self.shopsByUserSearch count] + 1 : 1;
    }
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)_tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (_tableView == self.tableView ) {
        static NSString *shopCellId = @"ShopCell";
        static NSString *activityCellId = @"ActivityCell";
        if(indexPath.section == 0) {
            cell = [_tableView dequeueReusableCellWithIdentifier:shopCellId];
            // lastUsedShops Section
            NSInteger shopIndex = indexPath.row;
            SHPShop *shop = [self.lastUsedShops objectAtIndex:shopIndex];
            cell.textLabel.text = shop.name;
            cell.detailTextLabel.text = shop.formattedAddress;
        }
        else if (indexPath.section == 1 && self.shops.count > 0 ) {
            cell = [_tableView dequeueReusableCellWithIdentifier:shopCellId];
            NSInteger shopIndex = indexPath.row;
            SHPShop *shop = [self.shops objectAtIndex:shopIndex];
            cell.textLabel.text = shop.name;
            cell.detailTextLabel.text = shop.formattedAddress;
        }
        else if (indexPath.section == 1 && self.isLoadingNearest) {
            cell = [_tableView dequeueReusableCellWithIdentifier:activityCellId];
            [cell setUserInteractionEnabled:NO];
            UILabel *loadingLabel = (UILabel *) [cell viewWithTag:1];
            loadingLabel.text = NSLocalizedString(@"LoadingNearestShopsLKey", nil);
            // NON SI VEDE...MAH!
//            UIActivityIndicatorView *indicator = (UIActivityIndicatorView *) [cell viewWithTag:1];
//            NSLog(@"ACTIVITY INDICATOR %@", indicator);
//            [indicator startAnimating];
        }
        else if (indexPath.section == 1 && self.networkError) {
            cell = [_tableView dequeueReusableCellWithIdentifier:activityCellId];
            [cell setUserInteractionEnabled:NO];
            UILabel *loadingLabel = (UILabel *) [cell viewWithTag:1];
            loadingLabel.text = NSLocalizedString(@"NetworkErrorTitleLKey", nil);
        }
        else if (indexPath.section == 1) {
            // shops.count == 0
            cell = [_tableView dequeueReusableCellWithIdentifier:activityCellId];
            [cell setUserInteractionEnabled:NO];
            UILabel *loadingLabel = (UILabel *) [cell viewWithTag:1];
            loadingLabel.text = self.noShopFoundLKey;
        }
    } else if(_tableView == self.searchTableView) {
        NSLog(@"searchTableView.cellForRowAtIndexPath!");
        static NSString *searchShopCellId = @"SearchShopCell";
        static NSString *addShopCellId = @"AddShopCell";
        if(indexPath.row == 0) { // the Add Shop Cell
            cell = [_tableView dequeueReusableCellWithIdentifier:addShopCellId];
            cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@ \"%@\"...",NSLocalizedString(@"AddLKey", nil), self.searchBar.text != nil ? [self.searchBar.text capitalizedString] : @""];
            cell.imageView.image = [UIImage imageNamed:@"new-shop.png"];
        } else {
            cell = [_tableView dequeueReusableCellWithIdentifier:searchShopCellId];
            NSInteger shopIndex = indexPath.row - 1;
            SHPShop *shop = [self.shopsByUserSearch objectAtIndex:shopIndex];
            cell.textLabel.text = shop.name;
            cell.detailTextLabel.text = shop.formattedAddress;
            NSLog(@"shop.formattedAddress %@", shop.formattedAddress);
//            [[cell detailTextLabel] setText:[[NSString alloc] initWithFormat:@"%d m", shop.distance]];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(_tableView == self.tableView) {
        //SHPShop *selectedShop = nil;
        selectedShop = nil;
        if (indexPath.section == 0) {
            NSLog(@"self.lastUsedShops %@", self.lastUsedShops);
            selectedShop = [self.lastUsedShops objectAtIndex:indexPath.row];
            NSLog(@"selectedShop %@ ADRESS %@", selectedShop, selectedShop.formattedAddress);
        } else {
            selectedShop = [self.shops objectAtIndex:indexPath.row];
        }
        [self stopLastNearestShopsAction];
        [self performSegueWithIdentifier:@"returnToWizardStep5Poi" sender:self];
//        [self.shopDCNearest cancelDownload];
    } else if(_tableView == self.searchTableView) {
        if(indexPath.row == 0) {
            NSLog(@"searchTableView.didSelectRowAtIndexPath!");
            [self performSegueWithIdentifier:@"AddShop" sender:self];
            NSIndexPath* selection = [self.searchTableView indexPathForSelectedRow];
            if (selection) [self.searchTableView deselectRowAtIndexPath:selection animated:YES];
        } else {
            NSInteger shopIndex = indexPath.row - 1;
            selectedShop = [self.shopsByUserSearch objectAtIndex:shopIndex];
            [self performSegueWithIdentifier:@"returnToWizardStep5Poi" sender:self];
        }
    }
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"AddShop"]) {
        SHPAddShopViewController *addShopVC = [segue destinationViewController];
        //        addShopVC.delegate = self;
        SHPShop *shop = [[SHPShop alloc] init];
        shop.name = [self.searchBar.text capitalizedString];
        shop.lat = self.applicationContext.lastLocation.coordinate.latitude;
        shop.lon = self.applicationContext.lastLocation.coordinate.longitude;
        addShopVC.shop = shop;
        addShopVC.applicationContext = self.applicationContext;
        addShopVC.modalCallerDelegate = self;
    }
    else if([[segue identifier] isEqualToString:@"returnToWizardStep5Poi"]){
        SHPWizardStep5Poi *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.selectedShop = selectedShop;
    }
}

// Modal delegate
- (void)setupViewController:(UIViewController *)controller didFinishSetupWithInfo:(NSDictionary *)setupInfo {
    NSLog(@"dict %@", setupInfo);
    SHPShop *shop = [setupInfo objectForKey:@"shop"];
    NSLog(@"...selected shop %@", shop.name);
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    if (self.shops) {
        // selected shops cannot still be loaded (localization routine is long waiting)
        [options setObject:self.shops forKey:@"shops"];
    }
    [options setObject:shop forKey:@"shop"];
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.modalCallerDelegate setupViewController:self didFinishSetupWithInfo: options];
}

- (void)setupViewController:(UIViewController *)controller didCancelSetupWithInfo:(NSDictionary *)setupInfo {
    //    NSLog(@"dict %@", setupInfo);
    //    SHPShop *shop = [setupInfo objectForKey:@"shop"];
    //    NSLog(@"selected shop %@", shop.name);
    //    self.selectedShop = [setupInfo objectForKey:@"shop"];
//    self.modalViewNearestShops = [setupInfo objectForKey:@"shops"];
    [self dismissViewControllerAnimated:YES completion:nil];
}



// DataController delegate


- (void)shopsLoaded:(NSArray *)_shops {
    NSLog(@"Shops Loaded Delegate!");
    if (self.viewModeSearch == NO) {
        self.isLoadingNearest = NO;
        // results are for the self.tableView
        //[self.refreshControl endRefreshing];
//        [self hideActivityView];
        // the nsurlconnection initWith... send messages on the same thread that launched initWith... so there is no need to preserve the execution of this thread on the Main-UI-Thread simply because we are just on the UI Thread! (From NSURLConnection:initWithRequest documentation.
        self.shops = _shops;
        [self.tableView reloadData];
    } else {
        // results are for self.seacrchTableView
        NSLog(@"Shops received: %@", _shops);
        self.shopsByUserSearch = _shops;
        [self.searchTableView reloadData];
    }
//    [self reloadTable];
}

-(void)shopDCNetworkError:(SHPShopDC *)dc {
    // reset
    self.isLoadingNearest = NO;
     //[self.refreshControl endRefreshing];
    
    self.networkError = YES;
    // alert
    NSString *title = NSLocalizedString(@"NetworkErrorTitleLKey", nil);
    NSString *msg = NSLocalizedString(@"NetworkErrorLKey", nil);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
    NSLog(@"Network ERROR! %d", self.networkError);
    [self.tableView reloadData];
}

//-(void)reloadTable {
//    dispatch_async(dispatch_get_main_queue(), ^(void) {
//        [self.tableView reloadData];
//    });
//}

- (IBAction)dismissAction:(id)sender {
    NSLog(@"DISMISSION!");
    NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    NSLog(@"self.shopDCNearest: %@", self.shopDCNearest);
    [self stopLastNearestShopsAction];
//    [self.shopDCNearest cancelDownload];
    if(self.shops) {
        [options setObject:self.shops forKey:@"shops"];
    }
    [self.modalCallerDelegate setupViewController:self didCancelSetupWithInfo: options];
}



// UISearchBar delegate




-(void)searchBar:(UISearchBar*)_searchBar textDidChange:(NSString*)text {
    if(text.length == 0) {
        // hides the table of search results and shows the semitrasparent view behind
        self.searchTableView.userInteractionEnabled = NO;
        self.searchTableView.hidden = YES;
        // reset the table so it will reappear empty
        self.shopsByUserSearch = nil;
        [self.searchTableView reloadData];
        return;
    } else if (self.searchTableView.hidden == YES) {
        NSLog(@"text != 0 & bar hidden");
        self.searchTableView.userInteractionEnabled = YES;
        self.searchTableView.hidden = NO;
    }
    if (self.searchTimer) {
        if ([self.searchTimer isValid]) { [self.searchTimer invalidate]; }
        self.searchTimer = nil;
//        NSLog(@"Canceled previous search...");
    }
    NSLog(@"Scheduling new search for: %@", text);
    self.searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.0 target:self selector:@selector(userPaused:) userInfo:nil repeats:NO];
    // fast reload the first cell content (Add Shop)
    NSIndexPath *ipFirstCell = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.searchTableView beginUpdates];
    [self.searchTableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:ipFirstCell, nil] withRowAnimation:UITableViewRowAnimationNone];
    [self.searchTableView endUpdates];
}

-(void)userPaused:(NSTimer *)timer {
    NSString *text = self.searchBar.text;
    NSLog(@"timer on userPaused: searching for %@", text);
    if (self.shopDCSearch) {
        [self.shopDCSearch cancelDownload];
    }
    self.shopDCSearch = [[SHPShopDC alloc] init];
    self.shopDCSearch.shopsLoadedDelegate = self;
    if (self.applicationContext.lastLocation) {
        double lat = self.applicationContext.lastLocation.coordinate.latitude;
        double lon = self.applicationContext.lastLocation.coordinate.longitude;
        [self.shopDCSearch searchByName:text lat:lat lon:lon];
    } else {
        [self.shopDCSearch searchByName:text];
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    NSLog(@"Begin editing...");
    if(self.viewModeSearch) return;
    
    [self.tableView setContentOffset:CGPointMake(0,0)];
    // Fading in the disableViewOverlay
    self.disableViewOverlay.alpha = 0;
    [self.view insertSubview:self.disableViewOverlay belowSubview:self.searchBar];
    
    [UIView beginAnimations:@"Appears Animation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endAnimationActive:finished:context:)];
    
    self.disableViewOverlay.alpha = 0.6;
    NSLog(@"y: %f", self.searchBar.frame.origin.y);
    
    CGRect frameNav = CGRectMake(0, -self.navigationBar.frame.size.height, self.navigationBar.frame.size.width, self.navigationBar.frame.size.height);
    self.navigationBar.frame = frameNav;
    
    [UIView commitAnimations];
    
    [self.searchBar setShowsCancelButton:YES animated:TRUE];
    self.tableView.allowsSelection = NO;
    self.tableView.scrollEnabled = NO;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    NSLog(@"End editing...");
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
     NSLog(@"searchBarCancelButtonClicked..");
    self.viewModeSearch = NO;
    self.searchBar.text=@"";
    self.searchTableView.hidden = YES;
    
    [UIView beginAnimations:@"Disappears Animation" context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(endAnimationInactive:finished:context:)];
    
    self.disableViewOverlay.alpha = 0;
    self.disableViewOverlay.frame = self.overlayInactiveRect;//CGRectMake(0.0f,87.0f,320.0f,416.0f);
    
    CGRect frameSearch = CGRectMake(0, self.navigationBar.frame.size.height, self.view.frame.size.width, self.tableView.frame.size.height);
    self.tableView.frame = frameSearch;
    
    CGRect frameNav = CGRectMake(0, 0, self.navigationBar.frame.size.width, self.navigationBar.frame.size.height);
    self.navigationBar.frame = frameNav;
    
    [UIView commitAnimations];
    
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.searchBar resignFirstResponder];
    self.tableView.allowsSelection = YES;
    self.tableView.scrollEnabled = YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    NSLog(@"searchBarSearchButtonClicked..");
    [self dismissKeyboard];
}

-(void)dismissKeyboard {
    NSLog(@"dismissing keyboard");
    [self.view endEditing:YES];
}

- (void)endAnimationInactive:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
//    NSLog(@"end animation inactive");
    [self.disableViewOverlay removeFromSuperview];
    self.viewModeSearch = NO;
}

- (void)endAnimationActive:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
//    NSLog(@"end animation active");
    NSLog(@"::::::::: %f", self.overlayActiveRect.origin.y);
    self.searchTableView.frame = self.overlayActiveRect;
    NSLog(@"::::::::: %f", self.searchTableView.frame.origin.y);
    [self.view bringSubviewToFront:self.searchTableView];
    self.viewModeSearch = YES;
}

-(void)initializeData {
    [self startLocationManager];
}

-(void)loadShops {
    NSLog(@"LOAD SHOPS---...");
    self.networkError = NO;
    if (self.applicationContext.lastLocation) {
        if (self.shopDCNearest) {
            [self.shopDCNearest cancelDownload];
        }
        double lat = self.applicationContext.lastLocation.coordinate.latitude;
        double lon = self.applicationContext.lastLocation.coordinate.longitude;
        self.shopDCNearest = [[SHPShopDC alloc] init];
        self.shopDCNearest.shopsLoadedDelegate = self;
        [self.shopDCNearest searchByLocation:lat lon:lon];
    } else {
        NSLog(@"LOCATION SERVICES NOT AVAILABLE!");
        //[self.refreshControl endRefreshing];
        // Nearest Shops are not available because of a Location error.
        [self alert:self.nearestShopsLocationNotAvailableLKey];
    }
}

-(void)alert:(NSString *)message {
    NSString *title = nil;
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

// ********* NETWORK AND LOCATION *********




//-(Boolean)locationServicesActive {
//    if ([CLLocationManager locationServicesEnabled] == NO) {
//        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all Location Services for this device disabled. Nearest Shops are not available." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [servicesDisabledAlert show];
//        return FALSE;
//    }
//    return TRUE;
//}

//-(void)showErrorMessage:(NSString *)message {
//}

//-(void)showActivityView {
//    if (activityController == nil) {
//        activityController = [[SHPActivityViewController alloc] initWithFrame:self.tableView.bounds];
//    }
//    NSLog(@"show: loading view");
//    [self.view addSubview:activityController.view];
//    [activityController startAnimating];
//}

//-(void)hideActivityView {
//    [activityController.view removeFromSuperview];
//    [activityController stopAnimating];
//}

//-(void)showErrorView {
//    if (errorController == nil) {
//        errorController = [[SHPNetworkErrorViewController alloc] initWithFrame:self.view.superview.bounds];
//        //        errorController.target = self;
//        [errorController setTargetAndSelector:self buttonSelector:@selector(retryDataButtonPressed:)];
//        NSString *errorMessage = NSLocalizedString(@"ConnectionErrorLKey", nil);
//        NSLog(@"ERROR MESSAGE: %@", errorMessage);
//        errorController.message = errorMessage;
//    }
//    [self.view.superview insertSubview:errorController.view aboveSubview:self.view];
//}

//-(void)showLocationErrorView {
//    // TODO it's better an unblocking bottom (animated) alert view
//    UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Error" message:@"Nearest Shops are not available because of a Location error." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [servicesDisabledAlert show];
//}

-(void)hideErrorView {
    [errorController.view removeFromSuperview];
}

-(void)retryDataButtonPressed:(id)sender {
    [self hideErrorView];
    [self initializeData];
}

//-(void)retryLocationButtonPressed:(id)sender {
//    [self hideErrorView];
//    [self showActivityView];
//    [self startLocationManager];
//}


// ******** LOCATION SERVICES ********


-(void)startLocationManager {
    self.isLoadingNearest = YES;
    // http://iphonedevsdk.com/forum/iphone-sdk-development/86522-updating-location-every-x.html
    NSLog(@"Start updating location...");
    // Create the manager object
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    // This is the most important property to set for the manager. It ultimately determines how the manager will
    // attempt to acquire location and thus, the amount of power that will be consumed.
    self.locationManager.desiredAccuracy = 100.0;
    // Once configured, the location manager must be "started".
    [self.locationManager startUpdatingLocation];
    [self performSelector:@selector(stopUpdatingLocation:) withObject:TIMED_OUT afterDelay:self.applicationContext.settings.locationTimeout];
}

/** We want to get and store a location measurement that meets the desired accuracy. For this example, we are going to use horizontal accuracy as the deciding factor. In other cases, you may wish to use vertical accuracy, or both together.
*/
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    [self.locationMeasurements addObject:newLocation];
    NSLog(@"Location updated %@", newLocation);
    NSLog(@"newLocation.horizontalAccuracy: %f", newLocation.horizontalAccuracy);
    NSLog(@"desired horizontalAccuracy: %f", self.locationManager.desiredAccuracy);
    NSLog(@"bestEffortLocation %@", self.bestEffortAtLocation);
    NSLog(@"bestEffortAtLocation.horizontalAccuracy %f", self.bestEffortAtLocation.horizontalAccuracy);
    if (newLocation.horizontalAccuracy < 0) {
        return;
    }
//    if (self.bestEffortAtLocation == nil || newLocation.horizontalAccuracy <= self.bestEffortAtLocation.horizontalAccuracy) {
        self.bestEffortAtLocation = newLocation;
        if (newLocation.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
            NSLog(@">>>>>> Location: lat: %f, lon: %f", newLocation.coordinate.latitude, newLocation.coordinate.longitude);
            [self stopUpdatingLocation:NSLocalizedString(@"Acquired Location", @"Acquired Location")];
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:TIMED_OUT];
            // call the remote service
//            double lat = self.bestEffortAtLocation.coordinate.latitude;
//            double lon = self.bestEffortAtLocation.coordinate.longitude;
            self.applicationContext.lastLocation = self.bestEffortAtLocation;
            [self loadShops];
//            [self.shopDC searchByLocation:lat lon:lon];
            //        [self.shopDC searchByLocation:40.187890 lon:18.226190];
        } else {
            NSLog(@"Bad accuracy. Discarding Location.");
        }
//    } else {
//        NSLog(@"bestEffort is nil || bestEffort has better accuracy of newLocation");
//    }
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    // The location "unknown" error simply means the manager is currently unable to get the location.
    // We can ignore this error for the scenario of getting a single location fix, because we already have a 
    // timeout that will stop the location manager to save power.
    if ([error code] != kCLErrorLocationUnknown) {
        [self stopUpdatingLocation:NSLocalizedString(@"Error", @"Error")];
    }
}

- (void)stopUpdatingLocation:(NSString *)state {
    NSLog(@"Location State: %@", state);
    NSLog(@"stopUpdatingLocation!!!!!!!");
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    if ([state isEqualToString:@"Error"] || [state isEqualToString:TIMED_OUT]) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:TIMED_OUT];
        [self loadShops];
    }
}

-(void)stopLastNearestShopsAction {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopUpdatingLocation:) object:TIMED_OUT];
    [self.locationManager stopUpdatingLocation];
    [self.shopDCNearest cancelDownload];
}

-(void)dealloc {
    NSLog(@"CHOOSE_SHOP DEALLOCATING");
}

@end
