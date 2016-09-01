//
//  SHPSetCityViewController.h
//  Ciaotrip
//
//  Created by Dario De Pascalis on 19/02/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@class SHPApplicationContext;
@interface SHPSetCityViewController : UIViewController<UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate,UISearchBarDelegate>


@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSMutableArray *arraySearch;
@property (nonatomic, strong) NSURLConnection *googleConnection;
@property (nonatomic, strong) NSMutableData *responseData;

@property (strong, nonatomic) CLLocation *location;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) MKPointAnnotation *selectedAnnotation;
@property (strong, nonatomic) CLGeocoder *geocoder;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
- (IBAction)cancelAction:(id)sender;


@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
