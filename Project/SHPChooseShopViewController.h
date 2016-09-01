//
//  SHPChooseShopViewController.h
//  Shopper
//
//  Created by andrea sponziello on 19/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPShopsLoadedDCDelegate.h"
#import <CoreLocation/CoreLocation.h>
#import "SHPModalCallerDelegate.h"

@class SHPShopDC;
@class SHPShop;
@class SHPApplicationContext;

static NSString *const TIMED_OUT = @"Timed out";

@interface SHPChooseShopViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SHPShopsLoadedDCDelegate, CLLocationManagerDelegate, SHPModalCallerDelegate> {
    
    // http://stackoverflow.com/questions/2158660/why-doesnt-objective-c-support-private-methods/2159027#2159027
    CGRect overlayInactiveRect;
    CGRect overlayActiveRect;
    SHPShop *selectedShop;
    NSString *typeSelected;
}
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;
@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (strong, nonatomic) id <SHPModalCallerDelegate> modalCallerDelegate;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPShopDC *shopDCNearest;
@property (strong, nonatomic) SHPShopDC *shopDCSearch;
@property (strong, nonatomic) NSArray *shops;
@property (strong, nonatomic) NSArray *shopsByUserSearch;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *locationMeasurements;
@property (strong, nonatomic) CLLocation *bestEffortAtLocation;
@property (strong, nonatomic) NSTimer *searchTimer;
@property (assign, nonatomic) Boolean viewModeSearch;
@property (strong, nonatomic) NSArray *lastUsedShops;
@property (assign, nonatomic) BOOL isLoadingNearest;
@property (assign, nonatomic) BOOL networkError;

@property (strong, nonatomic) NSString *category;
@property (nonatomic, strong) UIImageView *titleLogo;


@property (strong, nonatomic) NSString *chooseShopLKey;
@property (strong, nonatomic) NSString *searchOrAddShopPlaceholderLKey;
@property (strong, nonatomic) NSString *recentlyUsedShopsLKey;
@property (strong, nonatomic) NSString *nearestShopsLKey;
@property (strong, nonatomic) NSString *loadingNearestShopsLKey;
@property (strong, nonatomic) NSString *noShopFoundLKey;
@property (strong, nonatomic) NSString *nearestShopsLocationNotAvailableLKey;





@property (strong, nonatomic) UIView *disableViewOverlay;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *searchTableView;
@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;

- (IBAction)dismissAction:(id)sender;


- (void)setupViewController:(UIViewController *)controller didFinishSetupWithInfo:(NSDictionary *)setupInfo;
- (void)setupViewController:(UIViewController *)controller didCancelSetupWithInfo:(NSDictionary *)setupInfo;

@end
