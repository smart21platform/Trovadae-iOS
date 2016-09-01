//
//  SHPInfoFirstLoadVC.m
//  Anima e Cuore
//
//  Created by dario de pascalis on 02/12/14.
//
//

#import "SHPInfoFirstLoadVC.h"
#import "SHPAppDelegate.h"
#import "SHPApplicationContext.h"

@interface SHPInfoFirstLoadVC ()
@end

NSDictionary *viewproductTour;
NSMutableArray *arrayPages;
NSDictionary *viewDictionary;

@implementation SHPInfoFirstLoadVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.applicationContext = appDelegate.applicationContext;
    self.locationManager = [[CLLocationManager alloc] init];
    
    [self.labelButtonContinue setTitle:NSLocalizedString(@"Continue", nil) forState:UIControlStateNormal];
    NSString *bundleName = [NSString stringWithFormat:@"%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey]];
    viewDictionary = [self.applicationContext.plistDictionary objectForKey:@"View"];
    viewproductTour = [viewDictionary objectForKey:@"ProductTour"];
    arrayPages = [viewproductTour objectForKey:@"Pages"];
    self.labelTitleInfo.text = arrayPages[0][@"title"];
    NSString *localizedString = arrayPages[0][@"text"];
    self.labelTextInfo.text = [NSString localizedStringWithFormat:localizedString, bundleName, bundleName];
    self.iconLocation.image = [UIImage imageNamed:arrayPages[0][@"icon"]];
    self.imageBackground.image = [UIImage imageNamed:arrayPages[0][@"image"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initializeLocation {
    NSLog(@"INITIALIZING LOCATION! XXXXXX");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    //++++++++++++++++++++++++++++++++++++++++++++++++//
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    //++++++++++++++++++++++++++++++++++++++++++++++++//
    //[self enableLocationServices];
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"self.locationManager.location %@", self.locationManager.location);
    if (self.locationManager.location) {
        self.applicationContext.lastLocation = self.locationManager.location;
        self.applicationContext.searchLocation = self.locationManager.location;
    }
//    NSLog(@"significantLocationChangeMonitoringAvailable? %d", [CLLocationManager significantLocationChangeMonitoringAvailable]);
//    self.location = locations.lastObject;
//    self.coordinateLat.text = [NSString stringWithFormat:@"%f", self.location.coordinate.latitude];
//    self.coordinateLon.text = [NSString stringWithFormat:@"%f", self.location.coordinate.longitude];
//    self.altitude.text = [NSString stringWithFormat:@"%f", self.location.altitude];
//    self.hAccuracy.text = [NSString stringWithFormat:@"%f", self.location.horizontalAccuracy];
//    self.vAccuracy.text = [NSString stringWithFormat:@"%f", self.location.verticalAccuracy];
//    self.timestamp.text = [NSString stringWithFormat:@"%@", self.location.timestamp];
//    self.speed.text = [NSString stringWithFormat:@"%f", self.location.speed];
//    self.course.text = [NSString stringWithFormat:@"%f", self.location.course];
    [self dismissionController];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"XXXXXXXXX--- didFailWithError %@", error);
    [self dismissionController];
}

-(void)dismissionController{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
}


- (IBAction)actionButtonContinue:(id)sender {
    [self initializeLocation];
}
@end
