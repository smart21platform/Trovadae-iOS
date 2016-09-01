//
//  SHPWizardStepStartReport.h
//  Salve Smart
//
//  Created by Dario De Pascalis on 19/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPApplicationContext.h"
#import "SHPCategory.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SHPShop.h"

@interface SHPWizardStepStartReport : UIViewController<CLLocationManagerDelegate>{
    NSArray *categories;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (strong, nonatomic) NSString *typeSelected;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) SHPShop *selectedShop;
@property (strong, nonatomic) MKPointAnnotation *selectedAnnotation;
@property (strong, nonatomic) CLLocation *locationSelected;

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelHeader;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *buttonCancel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonNext;

- (IBAction)actionCancel:(id)sender;
- (IBAction)actionNext:(id)sender;


- (IBAction)unwindToSHPWizardStepStartReport:(UIStoryboardSegue *)segue;
@end
