//
//  SHPLoadInitialDataViewController.h
//  Ciaotrip
//
//  Created by andrea sponziello on 25/02/14.
//
//

#import <UIKit/UIKit.h>
#import "SHPCategoryDCDelegate.h"
#import "SHPShopsLoadedDCDelegate.h"
#import "SHPVerifyUploadPermissionsDC.h"

@class SHPApplicationContext;
@class SHPShop;
@class SHPShopDC;

@protocol UIViewController
- (void)firstLoad:(SHPApplicationContext *)applicationContextWithCategories;
@end

@interface SHPLoadInitialDataViewController : UIViewController <SHPCategoryDCDelegate, SHPShopsLoadedDCDelegate> //SHPVerifyUploadPermissionsDCDelegate

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) UIViewController *caller;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) SHPShopDC *shopDC;
@property (strong, nonatomic) SHPShop *shop;

- (void)shopsLoaded:(NSArray *)shops;
@end
