//
//  SHPExploreHomeViewController.h
//  Shopper
//
//  Created by andrea sponziello on 06/10/12.
//
//

#import <UIKit/UIKit.h>
#import "SHPModalCallerDelegate.h"
//#import "SHPCategoryDCDelegate.h"
#import "SHPActivityViewController.h"
#import "SHPNetworkErrorViewController.h"
#import <CoreLocation/CoreLocation.h>

//@class SHPCategoryDC;
@class SHPCategory;
@class SHPApplicationContext;
@class SHPProduct;
@class MBProgressHUD;

@interface SHPExploreHomeViewController : UITableViewController <UISearchBarDelegate>{
    BOOL searchAround;
    BOOL singlePoi;
    NSString *urlBoxLink;
}//UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate>

@property (strong, nonatomic) id <SHPModalCallerDelegate> modalCallerDelegate;
//@property (strong, nonatomic) SHPCategoryDC *categoryDC;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) NSMutableArray *subCategories;

@property (assign, nonatomic) BOOL showCategoryAll;
@property (strong, nonatomic) SHPCategory *selectedCategory;
//@property (strong, nonatomic) SHPActivityViewController *activityController;
//@property (strong, nonatomic) SHPNetworkErrorViewController *errorController;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (assign, nonatomic) BOOL lastLocationStatusEnabled;
@property (strong, nonatomic) NSTimer *locationEnabledTimer;

//@property (assign, nonatomic) BOOL isNetworkError;
//@property (assign, nonatomic) BOOL isLoading;

@property (weak, nonatomic) IBOutlet UIView *viewBoxLink;
@property (strong, nonatomic) SHPProduct *productSelected;
@property (weak, nonatomic) IBOutlet UILabel *labelTitleContainer;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
//@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UISearchBar *searchBar2;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


- (IBAction)searchAction:(id)sender;



@property (strong, nonatomic) CLGeocoder *geocoder;

@property(nonatomic, strong) MBProgressHUD *hud;

//- (IBAction)searchAction:(id)sender;
//- (IBAction)searchButtonAction:(id)sender;

//- (void) hideSearchController: (UIViewController*) controller;

//- (IBAction)dismissAction:(id)sender;
- (IBAction)actionSearch:(id)sender;

@end