//
//  SHPMapperViewController.h
//  Shopper
//
//  Created by andrea sponziello on 04/09/12.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class SHPApplicationContext;

@interface SHPMapperViewController : UIViewController <MKMapViewDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *externalMapButton;

@property (strong, nonatomic) NSString *placeHolderTitle;
@property (strong, nonatomic) NSString *address;
@property (assign, nonatomic) float lat;
@property (assign, nonatomic) float lon;
@property (strong, nonatomic) MKPointAnnotation *annotation;
@property (strong, nonatomic) CLLocation *userLocation;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;

- (IBAction)externalMapAction:(id)sender;
- (IBAction)actionClose:(id)sender;

@end
