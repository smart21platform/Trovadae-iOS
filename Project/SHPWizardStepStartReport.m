//
//  SHPWizardStepStartReport.m
//  Salve Smart
//
//  Created by Dario De Pascalis on 19/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import "SHPWizardStepStartReport.h"
#import "SHPComponents.h"
#import "SHPConstants.h"
#import "SHPUserInterfaceUtil.h"
#import "SHPMapInViewController.h"
#import "SHPConstants.h"
#import "SHPWizardStep3Photo.h"

@interface SHPWizardStepStartReport ()

@end

@implementation SHPWizardStepStartReport

- (void)viewDidLoad {
    [super viewDidLoad];
    // SET TITLE NAV BAR
    [SHPComponents customizeTitle:nil vc:self];
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(didTapMap)];
    [self.mapView addGestureRecognizer:tapRec];
    [self initialize];
    [self initializeLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)initialize{
    //INIT TOP MESSAGE
    self.wizardDictionary = (NSMutableDictionary *) [self.applicationContext getVariable:WIZARD_DICTIONARY_KEY];
    self.labelHeader.text = NSLocalizedString(@"header-step-start-report", nil);
    self.labelTitle.text = NSLocalizedString(@"TapTheMapLKey", nil);
    [self.buttonNext setTitle:NSLocalizedString(@"wizardNextButton", nil)];
    [self.buttonCancel setTitle:NSLocalizedString(@"CancelLKey", nil) forState:UIControlStateNormal];
    [self.wizardDictionary setObject:self.typeSelected forKey:WIZARD_TYPE_KEY];
    self.selectedShop = [[SHPShop alloc] init];
    if(!self.selectedCategory)[self goToStepCategory];
}

-(void)initializeLocation {
    NSLog(@"INITIALIZING LOCATION! XXXXXX");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    //self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    
    //++++++++++++++++++++++++++++++++++++++++++++++++//
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    NSLog(@"self.locationManager %@",self.locationManager.location);
    //++++++++++++++++++++++++++++++++++++++++++++++++//
    //[self enableLocationServices];
    self.locationSelected = [[CLLocation alloc] initWithLatitude:self.locationManager.location.coordinate.latitude longitude:self.locationManager.location.coordinate.longitude];
    [self initMiniMap];
}


-(void)initMiniMap {
    if (!self.locationSelected ) {
        return;
    }
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = self.locationSelected.coordinate.latitude;
    annotationCoord.longitude = self.locationSelected.coordinate.longitude;
    
    [self.mapView removeAnnotations:self.mapView.annotations];
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = annotationCoord;
    [self.mapView addAnnotation:annotationPoint];
    
    // Zooming on current position
    MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
    MKCoordinateRegion region = MKCoordinateRegionMake(annotationPoint.coordinate, span);
    [self.mapView setRegion:region animated:NO];
    
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
}

-(void)goToStepCategory
{
    categories = [self getCategories];
    if(categories.count>1){
        //aggiungo uno step per selezionare la categoria
        //[self performSegueWithIdentifier:@"toStepLocation" sender:self];
    }
    if(categories.count>0){
        //considero che esiste una sola cat di tipo report
        self.selectedCategory = [categories objectAtIndex:0];
    }
}

-(NSMutableArray *)getCategories {
    NSArray *cachedCategories = [(NSMutableArray *)[self.applicationContext getVariable:LAST_LOADED_CATEGORIES] copy];
    NSMutableArray *categoriesTemp = [[NSMutableArray alloc] init];
    if (cachedCategories && cachedCategories.count > 0) {
        for (SHPCategory *cat in cachedCategories) {
            if([cat.allowUserContentCreation boolValue]==YES && [cat.type isEqualToString:self.typeSelected]){
                NSUInteger numberOfOccurrences = [[cat.parent componentsSeparatedByString:@"/"] count] - 1;
                NSLog(@"cat: %@ - %d", cat.parent, (int)numberOfOccurrences);
                if (numberOfOccurrences==1) {
                    [categoriesTemp addObject:cat];
                }
            }
        }
    }
    return categoriesTemp;
}

-(void)didTapMap {
    NSLog(@"map tapped!");
    [self performSegueWithIdentifier:@"Locate" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [self.wizardDictionary setObject:self.selectedCategory forKey:WIZARD_CATEGORY_KEY];
    [self.wizardDictionary setObject:self.selectedCategory forKey:WIZARD_ICON_CATEGORY_KEY];
    self.selectedShop.lat = self.locationSelected.coordinate.latitude;
    self.selectedShop.lon = self.locationSelected.coordinate.longitude;
    [self.wizardDictionary setObject:self.selectedShop forKey:WIZARD_POI_KEY];
    [self.applicationContext setVariable:WIZARD_DICTIONARY_KEY withValue:self.wizardDictionary];
    
    if ([[segue identifier] isEqualToString:@"Locate"]) {
        SHPMapInViewController *vc = [segue destinationViewController];
        CLLocationCoordinate2D shopCoord;
        shopCoord.latitude = self.locationSelected.coordinate.latitude;
        shopCoord.longitude = self.locationSelected.coordinate.longitude;
        vc.selectedLocation = shopCoord;
        vc.message = NSLocalizedString(@"PlaceTheShopOnTheMapLKey", nil);
    }
    else if ([[segue identifier] isEqualToString:@"toStepPhoto"]) {
        SHPWizardStep3Photo *vc = (SHPWizardStep3Photo *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.caller = self;
    }
}


- (IBAction)actionCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionNext:(id)sender {
    [self performSegueWithIdentifier:@"toStepPhoto" sender:self];
}

- (IBAction)unwindToSHPWizardStepStartReport:(UIStoryboardSegue *)segue{
    if ([segue.sourceViewController isKindOfClass:[SHPMapInViewController class]]) {
        SHPMapInViewController *child = (SHPMapInViewController *) segue.sourceViewController;
        self.selectedAnnotation = child.selectedAnnotation;
        self.locationSelected  = [[CLLocation alloc] initWithLatitude:self.selectedAnnotation.coordinate.latitude longitude:self.selectedAnnotation.coordinate.longitude];
        [self initMiniMap];
    }
}
@end
