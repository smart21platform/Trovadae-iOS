//
//  SHPProductsOnMapVC.h
//  Soleto
//
//  Created by dario de pascalis on 05/11/14.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class SHPApplicationContext;

@interface SHPProductsOnMapVC : UIViewController <MKMapViewDelegate>
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSMutableArray *products;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSString *categoryType;
- (IBAction)actionClose:(id)sender;

@end
