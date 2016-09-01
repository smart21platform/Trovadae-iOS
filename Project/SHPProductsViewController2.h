//
//  SHPProductsViewController2.h
//  Ciaotrip
//
//  Created by andrea sponziello on 30/12/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SHPProductDCDelegate.h"
#import "SHPIconDownloader.h"
#import "SHPLikeDCDelegate.h"
#import "MBProgressHUD.h"
#import "SHPModalCallerDelegate.h"
#import "SHPImageCache.h"
#import "SHPCategoryDCDelegate.h"
#import "SHPActivityViewController.h"
#import "SHPNetworkErrorViewController.h"



@class SHPApplicationContext;
//@class SHPProductDC;
@class SHPCategory;
@class SHPProductsLoaderStrategy;

//static NSString *const TIMED_OUT = @"Timed out";

@interface SHPProductsViewController2 : UITableViewController <SHPProductDCDelegate, CLLocationManagerDelegate, SHPIconDownloaderDelegate, UIAlertViewDelegate, SHPLikeDCDelegate, SHPModalCallerDelegate>{
    BOOL isLoadingData;
    BOOL noMoreData;
    SHPActivityViewController *activityController;
    SHPNetworkErrorViewController *errorController;
    NSInteger _lastContentOffset;
    NSInteger _beforeLastContentOffset;
    float _tabBarHeight;
    float _tabBarY;
    float _transitionViewHeight;
    float _transitionViewY;
    float _navBarHeight;
    BOOL _isTabBarAnimatingShow;
    BOOL _isTabBarAnimatingHide;
    UIView *_transitionView;
    // scroll speed
    CGPoint lastOffset;
    NSTimeInterval lastOffsetCapture;
    BOOL isScrollingFast;
    UIAlertView *categoriesAlertView;
    NSDictionary *settingsDictionary;
    NSArray *CELL_STYLE;
    NSInteger searchStartPage;
    NSInteger searchPageSize;
    SHPProduct *productSelected;
}

//@property (strong, nonatomic) SHPProductDC *productDC;
@property (strong, nonatomic) NSMutableArray *products;

@property (strong, nonatomic) SHPProductsLoaderStrategy *loader;

@property (strong, nonatomic) SHPProduct *selectedProduct;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *locationMeasurements;
@property (strong, nonatomic) MBProgressHUD *hud;
//@property (strong, nonatomic) MBProgressHUD *loadingHud;
@property (strong, nonatomic) CLLocation *bestEffortAtLocation;
//@property (strong, nonatomic) NSString *searchCategory;
@property (strong, nonatomic) UIColor *bgColor;
@property(strong, nonatomic) UIView *showMenuButtonView;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSMutableDictionary *likesInProgress;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (nonatomic, assign) NSInteger selectedIndex;
//@property (nonatomic, assign) NSInteger searchStartPage;
//@property (nonatomic, assign) NSInteger searchPageSize;
//@property (nonatomic, assign) BOOL isLoadingData;
//@property (nonatomic, assign) BOOL noMoreData;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (assign, nonatomic) BOOL locationServicesDisabledError;

@property (strong, nonatomic) SHPProduct *aProductWasDeleted;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *categoryButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *locateButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageHeader;

@property (strong, nonatomic) CLGeocoder *geocoder;
@property (strong, nonatomic) NSString *selectedProductID;
@property (strong, nonatomic) NSString *urlNotification;



-(void)openViewForProductID:(NSString *)productID;
-(void)openWebViewForURL:(NSString *)url;
-(void)openAlertMessage:(NSString *)message;
-(void)firstLoad:(SHPApplicationContext *)applicationContextWithCategories;
-(void)viewControllerDidBecomeActive;
- (IBAction)unwindToProductsVC:(UIStoryboardSegue*)sender;

@end
