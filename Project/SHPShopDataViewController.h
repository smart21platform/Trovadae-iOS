//
//  SHPShopDataViewController.h
//  Dressique
//
//  Created by andrea sponziello on 25/02/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "SHPShopsLoadedDCDelegate.h"

@class SHPShopDC;
@class SHPShop;
@class SHPApplicationContext;

@interface SHPShopDataViewController : UITableViewController <SHPShopsLoadedDCDelegate>

@property (strong, nonatomic) SHPShopDC *shopDC;
@property(strong, nonatomic) SHPShop *shop;
@property(strong, nonatomic) SHPApplicationContext *applicationContext;

@property (weak, nonatomic) IBOutlet UILabel *shopInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *websiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *routeToButton;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) MKPointAnnotation *annotationPoint;

//@property (strong, nonatomic) UIAlertView *phoneAlertView;

- (IBAction)phoneAction:(id)sender;
- (IBAction)emailAction:(id)sender;
- (IBAction)websiteAction:(id)sender;
- (IBAction)routeToAction:(id)sender;

@end
