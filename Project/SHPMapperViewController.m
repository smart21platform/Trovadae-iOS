//
//  SHPMapperViewController.m
//  Shopper
//
//  Created by andrea sponziello on 04/09/12.
//
//

#import "SHPMapperViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SHPComponents.h"

@interface SHPMapperViewController ()
@end

@implementation SHPMapperViewController

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [SHPComponents titleLogoForViewController:self];
    
    self.mapView.delegate = self;
    
//    self.lat = 40.187890;
//    self.lon = 18.226190;
    NSLog(@"viewDidLoad");
    
    CLLocationCoordinate2D annotationCoord;
    annotationCoord.latitude = self.lat;
    annotationCoord.longitude = self.lon;
    
    MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
    annotationPoint.coordinate = annotationCoord;
    annotationPoint.title = self.placeHolderTitle;
    self.annotation = annotationPoint;
    // annotationPoint.subtitle = @"Description";
    [self.mapView addAnnotation:annotationPoint];
    
    // Zooming on current position
    MKCoordinateSpan span = MKCoordinateSpanMake(0.3, 0.3);
    MKCoordinateRegion region = MKCoordinateRegionMake(self.annotation.coordinate, span);
    [self.mapView setRegion:region animated:NO];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.annotation) {
        [self.mapView selectAnnotation:self.annotation animated:YES];
    }
}


//- (void)viewDidUnload
//{
//    [self setCloseButton:nil];
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    [self setMapView:nil];
//    [self setExternalMapButton:nil];
//    self.annotation = nil;
//    self.userLocation = nil;
//    self.placeHolderTitle = nil;
//    self.annotation = nil;
//    self.applicationContext = nil;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"DID RECEIVE MOMORY WARNING INSIDE MKMAPVIEW");
}


// MAP DELEGATE

// THIS PRODUCES A MEMORY WARNING DUE TO ZOOMING...PROBABLY A BUG...
- (void)mapView:(MKMapView *)mapView_ didAddAnnotationViews:(NSArray *)views {
     NSLog(@"didAddAnnotationViews");
    for (MKAnnotationView *annotationView in views) {
        if (annotationView.annotation == self.annotation) {
            MKCoordinateSpan span = MKCoordinateSpanMake(0.3, 0.3);
            MKCoordinateRegion region = MKCoordinateRegionMake(self.annotation.coordinate, span);
            [mapView_ setRegion:region animated:NO];
        }
        //        if (annotationView.annotation == mapView_.userLocation) {
        //            MKCoordinateSpan span = MKCoordinateSpanMake(0.3, 0.3);
        //            CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.lat longitude:self.lon];
        //            MKCoordinateRegion region = MKCoordinateRegionMake(loc.coordinate, span);
        //            [mapView_ setRegion:region animated:YES];
        //        }
    }
    for (MKPinAnnotationView *pinView in views) {
        pinView.animatesDrop = YES;
    }
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id )__annotation
{
    NSLog(@"viewForAnnotation");
    MKPinAnnotationView *newAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:__annotation reuseIdentifier:@"annotation1"];
//    newAnnotation.pinColor = MKPinAnnotationColorGreen;
    newAnnotation.animatesDrop = YES;
    newAnnotation.canShowCallout = YES;
    [newAnnotation setSelected:YES animated:YES];
    return newAnnotation;
}

//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation_ {
//    // TODO
////    self.userLocation...
//}


// ACTIONS



- (IBAction)externalMapAction:(id)sender {
    NSLog(@"self.address: %@",self.address);
    NSURL *testURL = [NSURL URLWithString:@"http://maps.apple.com/"];
    if ([[UIApplication sharedApplication] canOpenURL:testURL]) {
        //NSString *sampleUrl = self.address;
        //NSString *encodedUrl = [sampleUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //NSString *directionsRequest = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@&directionsmode=driving&x-success=sourceapp://?resume=true&x-source=AirApp", encodedUrl];
        NSString *directionsRequest = [NSString stringWithFormat:@"http://maps.apple.com/maps?q=%f,%f", self.lat, self.lon];
        NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
        [[UIApplication sharedApplication] openURL:directionsURL];
        NSLog(@"url string: %@",directionsRequest);
    } else {
        NSLog(@"Can't use comgooglemaps-x-callback:// on this device.");
        NSLog(@"EXTERNAL MAP");
        //    NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f", 40.46, 16.78, self.lat, self.lon]];
        NSString *latlong = [[NSString alloc] initWithFormat:@"%f,%f", self.lat, self.lon]; //@"-56.568545,1.256281";
        NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?q=%@",
                         [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        
        // in native google maps app
        //    [[MKMapItem mapItemForCurrentLocation] openInMapsWithLaunchOptions:nil];
        
        //    NSURL *myURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f", self.lat, self.lon]];
        //	[[UIApplication sharedApplication] openURL:myURL];

    }
}

- (IBAction)actionClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc {
    NSLog(@"MAPPER DEALLOCATING...");
}


@end
