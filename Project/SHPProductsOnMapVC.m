//
//  SHPProductsOnMapVC.m
//  Soleto
//
//  Created by dario de pascalis on 05/11/14.
//
//

#import "SHPProductsOnMapVC.h"
#import "SHPProduct.h"
#import "SHPMapAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import "SHPProductDetail.h"
#import "SHPComponents.h"
#import "SHPConstants.h"
#import "SHPApplicationContext.h"
#import "SHPAppDelegate.h"
#import "SHPCategory.h"
#import "SHPShop.h"
#import "SHPPoiDetailTVC.h"

//#define METERS_PER_MILE 1609.344

@interface SHPProductsOnMapVC ()
@end

@implementation SHPProductsOnMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    self.mapView.delegate = self;
    //self.mapView.mapType = MKMapTypeStandard;
    self.mapView.showsUserLocation = YES;
    //self.mapView.zoomEnabled = YES;
    //self.mapView.scrollEnabled = YES;
    
    NSLog(@"Prodotto -- : %@", self.products[0]);
    [SHPComponents titleLogoForViewController:self];
    [self addPointOnMap];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //[UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    //[UIApplication sharedApplication].statusBarHidden = NO;
}

//-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
//    //self.searchButton.hidden = NO;
//}
//
//-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
//    [self.mapView setCenterCoordinate:userLocation.coordinate animated:YES];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)addPointOnMap{
    NSMutableArray *annotationPoints = [[NSMutableArray alloc] init];
    NSMutableArray *arrayLat = [[NSMutableArray alloc] init];
    NSMutableArray *arrayLon = [[NSMutableArray alloc] init];
    
    for (SHPProduct *product in self.products) {
//        NSLog(@"prodotto: %@", product);
//        NSLog(@"title: %@", product.title);
//        NSLog(@"description: %@", product.description);
        NSNumber *latitude = [NSNumber numberWithFloat:product.shopLat];
        NSNumber *longitude = [NSNumber numberWithFloat:product.shopLon];
        NSString *title = [[NSString alloc] init];
        if([product.title isEqualToString:@""]){
            title = product.longDescription;
        }else{
            title = product.title;
        }
        
        //Create coordinates from the latitude and longitude values
        CLLocationCoordinate2D coord;
        coord.latitude = [latitude floatValue];
        coord.longitude = [longitude floatValue];
        [arrayLat addObject:latitude];
        [arrayLon addObject:longitude];
        
        // Add the annotation to our map view
        //MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        SHPMapAnnotation *annotation = [[SHPMapAnnotation alloc] init];
        annotation.coordinate = coord;
        annotation.title = title;
        annotation.oid = product.oid;
        //SHPMapAnnotation *newAnnotation = [[SHPMapAnnotation alloc] initWithTitle:title andCoordinate:coord];
        [annotationPoints addObject:annotation];
    }
    [self.mapView addAnnotations:annotationPoints];
    
    CLLocationCoordinate2D coordMedia;
    NSNumber *maxLat=[arrayLat valueForKeyPath:@"@max.self"];
    NSNumber *minLat=[arrayLat valueForKeyPath:@"@min.self"];
    float mediaLat = (maxLat.floatValue+minLat.floatValue)/2;
    coordMedia.latitude = mediaLat;
    
    NSNumber *maxLon=[arrayLon valueForKeyPath:@"@max.self"];
    NSNumber *minLon=[arrayLon valueForKeyPath:@"@min.self"];
    float mediaLon = (maxLon.floatValue+minLon.floatValue)/2;
    coordMedia.longitude = mediaLon;
    
    CLLocation *coordLat = [[CLLocation alloc] initWithLatitude:maxLat.floatValue longitude:mediaLon];
    CLLocation *coordLon = [[CLLocation alloc] initWithLatitude:mediaLat longitude:maxLon.floatValue];
    CLLocation *centerPoint = [[CLLocation alloc] initWithLatitude:mediaLat longitude:mediaLon];

    CLLocationDistance metersX = [coordLat distanceFromLocation:centerPoint]*3;
    CLLocationDistance metersY = [coordLon distanceFromLocation:centerPoint]*3;
    
    NSLog(@"coordLat: %@ - coordLon: %@ - centerPoint: %@ - metersX: %f - metersY: %f",coordLat,coordLon,centerPoint,metersX,metersY);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordMedia, metersX, metersY);

    region.center.latitude = mediaLat;
    region.center.longitude = mediaLon;
//    region.span.latitudeDelta = metersX * 3;
//    region.span.longitudeDelta = metersY * 3;
    
    [self.mapView setRegion:region animated:YES];
    [self.mapView regionThatFits:region];
    

    //viewRegion = [self.mapView regionThatFits:region];
    //[self.mapView setRegion:viewRegion animated:YES];
}

- (MKAnnotationView *)mapView:(MKMapView *)sender viewForAnnotation:(id < MKAnnotation >)annotation
{
    if (annotation == self.mapView.userLocation)
    {
        return nil;
    }
    else
    {
        static NSString *reuseId = @"StandardPin";
        MKPinAnnotationView *aView = (MKPinAnnotationView *)[sender dequeueReusableAnnotationViewWithIdentifier:reuseId];
        if (aView == nil)
        {
            aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseId];
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            //[rightButton setFrame:CGRectMake(0,10,32,32)];
            aView.rightCalloutAccessoryView = rightButton;//[UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            aView.canShowCallout = YES;
        }
        aView.annotation = annotation;
        return aView;
    }
}


// Add the following method
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if([self.categoryType isEqualToString:@"cover"]){
         [self performSegueWithIdentifier:@"toShopDetail" sender:view];
    }
    else if([(SHPMapAnnotation *)[view annotation] oid]){
        [self performSegueWithIdentifier:@"toProductDetail" sender:view];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toProductDetail"])
    {
        NSString *prodOid = [(SHPMapAnnotation *)[sender annotation] oid];
        NSLog(@"infoDarkButton for oid: %@ and title: %@",
              [(SHPMapAnnotation *)[sender annotation] oid],
              [[sender annotation] title]);
        SHPProductDetail *vc = [segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        NSLog(@"selectedProductID: %@",prodOid);
        if(prodOid){
            SHPProduct *product = [[SHPProduct alloc] init];
            product.oid = prodOid;
            vc.product = product;
        }
    }
    else if ([segue.identifier isEqualToString:@"toShopDetail"])
    {
        NSLog(@"toShopDetail");
        for (SHPProduct *product in self.products){
            if([(SHPMapAnnotation *)[sender annotation] oid] == product.oid){
                SHPShop *shop = [[SHPShop alloc] init];
                shop.oid = product.shop;
                shop.city = product.city;
                shop.name = product.shopName;
                shop.lat = product.shopLat;
                shop.lon = product.shopLon;
                shop.distance = [product.distance intValue];
                shop.coverImageURL = product.imageURL;
                shop.coverImage = [self.applicationContext.mainListImageCache getImage:shop.coverImageURL];
                
                SHPPoiDetailTVC *VC = [segue destinationViewController];
                VC.applicationContext = self.applicationContext;
                VC.shop = shop;
            }
        }
    }
}


- (IBAction)actionClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
