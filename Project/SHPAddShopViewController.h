//
//  SHPAddShopViewController.h
//  Shopper
//
//  Created by andrea sponziello on 21/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPShopsLoadedDCDelegate.h"
#import "SHPModalCallerDelegate.h"
#import <MapKit/MapKit.h>

@class SHPApplicationContext;
@class MBProgressHUD;

@interface SHPAddShopViewController : UIViewController <SHPShopsLoadedDCDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *tapTheMapLabel;
@property (strong, nonatomic) id <SHPModalCallerDelegate> modalCallerDelegate;
@property (strong, nonatomic) SHPShop *shop;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;

@property (weak, nonatomic) IBOutlet UIView *separatorView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *shopNameTextField;

@property (strong, nonatomic) MBProgressHUD *hud;

- (IBAction)dismissAction:(id)sender;
- (IBAction)saveAction:(id)sender;


@end
