//
//  SHPMapInViewController.h
//  Shopper
//
//  Created by andrea sponziello on 10/09/12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

typedef void (^SHPMapInCompletionHandler)(CLLocation *selectedLocation, BOOL canceled);

@interface SHPMapInViewController : UIViewController

//- (IBAction)cancel:(id)sender;
- (IBAction)doneAction:(id)sender;
- (IBAction)currentLocationAction:(id)sender;

//@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) MKPointAnnotation *selectedAnnotation;
//@property (assign, nonatomic) BOOL useCurrentLocation;
@property (assign, nonatomic) CLLocationCoordinate2D selectedLocation;
@property (copy, nonatomic) SHPMapInCompletionHandler completionHandler;

@end
