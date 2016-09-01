//
//  SHPAddShopViewController.m
//  Shopper
//
//  Created by andrea sponziello on 21/07/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SHPAddShopViewController.h"
#import "SHPShopDC.h"
#import "SHPShop.h"
#import "MBProgressHUD.h"
#import "SHPApplicationContext.h"
#import <QuartzCore/QuartzCore.h>
#import "SHPMapInViewController.h"
#import "SHPComponents.h"
#import "SHPWizardStep5Poi.h"

@interface SHPAddShopViewController ()

@end

@implementation SHPAddShopViewController

@synthesize backView;
@synthesize modalCallerDelegate;
@synthesize shop;
@synthesize applicationContext;
@synthesize separatorView;
@synthesize mapView;
@synthesize shopNameLabel;
@synthesize shopNameTextField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.shopNameTextField.text = self.shop.name;
    
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(didTapMap)];
    [self.mapView addGestureRecognizer:tapRec];
    
    [self styleForm];
    [self initMiniMap];
    [self localizeLabels];
    
}

-(void)localizeLabels {
//    self.navItem.topItem.title = NSLocalizedString(@"AddShopLKey", nil);
    [self customizeTitle:NSLocalizedString(@"AddShopLKey", nil)];
    self.shopNameLabel.text = NSLocalizedString(@"ShopNameLKey", nil);
    self.tapTheMapLabel.text = NSLocalizedString(@"TapTheMapLKey", nil);
    self.shopNameTextField.placeholder = NSLocalizedString(@"RequiredPlaceholderLKey", nil);
    self.saveButton.title = NSLocalizedString(@"DoneLKey", nil);
    self.cancelButton.title = NSLocalizedString(@"CancelLKey", nil);
}

-(void)customizeTitle:(NSString *)title {
    self.navigationItem.title = title;
    UILabel *navTitleLabel = [SHPComponents appTitleLabel:title withSettings:self.applicationContext.settings];
    self.navItem.topItem.titleView = navTitleLabel;
}

-(void)styleForm {
    UIColor *borderColor = separatorView.backgroundColor;
    CGRect frame = separatorView.frame;
    frame.size.height = 0.5;
    separatorView.frame = frame;
    separatorView.backgroundColor = borderColor;
    CALayer * layer = [backView layer];
    [layer setMasksToBounds:YES];
    [layer setBorderWidth:1.0];
    layer.cornerRadius = 5.0;
    [layer setBorderColor:borderColor.CGColor];
    
    CALayer * mapLayer = [mapView layer];
    [mapLayer setMasksToBounds:YES];
    [mapLayer setBorderWidth:1.0];
    mapLayer.cornerRadius = 5.0;
    [mapLayer setBorderColor:borderColor.CGColor];
}

-(void)initMiniMap {
    if (self.shop.lat == 0 && self.shop.lon == 0) {
        return;
    }
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = self.shop.lat;
    annotationCoord.longitude = self.shop.lon;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = annotationCoord;
//    annotationPoint.title = self.placeHolderTitle;
//    self.annotation = annotationPoint;
    // annotationPoint.subtitle = @"Description";
    [self.mapView addAnnotation:annotationPoint];
    
    // Zooming on current position
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    MKCoordinateRegion region = MKCoordinateRegionMake(annotationPoint.coordinate, span);
    [self.mapView setRegion:region animated:NO];
    
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
}

-(void)didTapMap {
    NSLog(@"map tapped!");
    [self performSegueWithIdentifier:@"Locate" sender:self];
}

//- (void)viewDidUnload
//{
//    [self setShopNameLabel:nil];
//    [self setMapView:nil];
//    [self setBackView:nil];
//    [self setSeparatorView:nil];
//    [self setTapTheMapLabel:nil];
//    [self setTapTheMapLabel:nil];
//    [self setSaveButton:nil];
//    [self setCancelButton:nil];
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    [self setShopNameTextField:nil];
//    self.applicationContext = nil;
//    self.shop = nil;
//    self.modalCallerDelegate = nil;
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Locate"]) {
        SHPMapInViewController *locateVC = [segue destinationViewController];
        CLLocationCoordinate2D shopCoord;
        shopCoord.longitude = self.shop.lon;
        shopCoord.latitude = self.shop.lat;
        locateVC.selectedLocation = shopCoord;
        locateVC.message = NSLocalizedString(@"PlaceTheShopOnTheMapLKey", nil);
        locateVC.completionHandler = ^(CLLocation *selectedLocation, BOOL canceled) {
            NSLog(@"selected location %@", selectedLocation);
            if (!canceled) {
//                [self dismissViewControllerAnimated:YES completion:nil];
                if (selectedLocation) {
                    // add saved location
//                    [self.applicationContext.onDiskData setObject:selectedLocation forKey:@"exploreLocation"];
                    CLLocationCoordinate2D selectedCoordinate = selectedLocation.coordinate;
                    self.shop.lat = selectedCoordinate.latitude;
                    self.shop.lon = selectedCoordinate.longitude;
                    [self initMiniMap];
                }
            }
//            else {
//                NSLog(@"Map canceled");
//                [self dismissViewControllerAnimated:YES completion:nil];
//            }
        };
    }
    else if ([[segue identifier] isEqualToString:@"unwindToWizardStep5Poi"]) {
        SHPWizardStep5Poi *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        //[options setObject:_shop forKey:@"shop"];
        VC.selectedShop = self.shop;
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)dismissAction:(id)sender {
//    [self.modalCallerDelegate setupViewController:self didFinishSetupWithInfo:nil];
    [self.modalCallerDelegate setupViewController:self didCancelSetupWithInfo:nil];
//    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)saveAction:(id)sender {
    NSLog(@"saving...");
    // eventually removes the keyboard
    [self.shopNameTextField resignFirstResponder];
    
    NSString *trimmedName = [self.shopNameTextField.text stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if([trimmedName isEqualToString:@""] ) {
        UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:nil message:@"The shop name is required!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [userAdviceAlert show];
        return;
    } else if (self.shop.lat == 0 && self.shop.lon == 0) {
        UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:nil message:@"Place the shop on the map!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [userAdviceAlert show];
        return;
    }
    
    // http://blog.elucidcode.com/2011/03/using-a-hud-to-display-alerts-in-ios/
    self.hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
//    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"first.png"]];
//    hud.mode = MBProgressHUDModeCustomView;
    [self.view addSubview:self.hud];
    self.hud.labelText = NSLocalizedString(@"SavingLKey", nil);
    self.hud.animationType = MBProgressHUDAnimationZoom;
    [self.hud show:YES];
//    hud.hidden = YES;
//    [hud hide:YES afterDelay:1.0];
    
    self.shop.name = self.shopNameTextField.text;
    SHPShopDC *dc = [[SHPShopDC alloc] init];
    dc.shopsLoadedDelegate = self;
    [dc create:self.shop withUser:self.applicationContext.loggedUser];
}

// delegate
-(void)shopCreated:(SHPShop *)nwShop {
    NSLog(@"shop created in delegate! %@",nwShop.oid);
    //NSMutableDictionary *options = [[NSMutableDictionary alloc] init];
    //[options setObject:nwShop forKey:@"shop"];
    self.shop = nwShop;
    [self performSegueWithIdentifier:@"unwindToWizardStep5Poi" sender:self];
    //[self.modalCallerDelegate setupViewController:self didFinishSetupWithInfo:options];
}

-(void)networkError {
    [self.hud hide:YES];
    UIAlertView *userAdviceAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NetworkErrorTitleLKey", nil) message:NSLocalizedString(@"NetworkErrorLKey", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [userAdviceAlert show];
}

-(void)dealloc {
    NSLog(@"DEALLOCATING ADD-SHOP");
}

@end
