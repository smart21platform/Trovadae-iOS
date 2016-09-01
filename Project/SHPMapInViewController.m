//
//  SHPMapInViewController.m
//  Shopper
//
//  Created by andrea sponziello on 10/09/12.
//
//

#import "SHPMapInViewController.h"

@interface SHPMapInViewController ()

@end

@implementation SHPMapInViewController

@synthesize mapView;
@synthesize messageLabel;
@synthesize message;
@synthesize selectedAnnotation;
@synthesize selectedLocation;



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
    NSLog(@"map loaded!");
	// Do any additional setup after loading the view.
    self.messageLabel.text = self.message;
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    UITapGestureRecognizer *lpgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.3; // if 0.0 conflicts with pan actions on the map.
    [self.mapView addGestureRecognizer:lpgr];
    [self localizeLabels];
    [self initialLocation];
}

-(void)localizeLabels {
//    self.navBar.topItem.title = NSLocalizedString(@"LocationTitleLKey", nil);
    self.cancelButton.title = NSLocalizedString(@"CancelLKey", nil);
    self.doneButton.title = NSLocalizedString(@"DoneLKey", nil);
    self.navigationItem.title = NSLocalizedString(@"PositionDetailTitleLKey", nil);
}

-(void)initialLocation {
    if (self.selectedLocation.latitude != 0) {
        
//        CLLocationCoordinate2D touchMapCoordinate =
//        [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
        if (self.selectedAnnotation) {
            [self.mapView removeAnnotation:self.selectedAnnotation];
        }
        self.selectedAnnotation = [[MKPointAnnotation alloc] init];
        self.selectedAnnotation.coordinate = self.selectedLocation;
        [self.mapView addAnnotation:self.selectedAnnotation];
        
        // Zooming on current position
        MKCoordinateSpan span = MKCoordinateSpanMake(0.005, 0.005);
        MKCoordinateRegion region = MKCoordinateRegionMake(self.selectedAnnotation.coordinate, span);
        [self.mapView setRegion:region animated:YES];
    }
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateBegan)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    if (self.selectedAnnotation) {
        [self.mapView removeAnnotation:self.selectedAnnotation];
    }
    self.selectedAnnotation = [[MKPointAnnotation alloc] init];
    self.selectedAnnotation.coordinate = touchMapCoordinate;
    [self.mapView addAnnotation:self.selectedAnnotation];
}

//- (void)viewDidUnload
//{
//    [self setMessageLabel:nil];
//    [self setDoneButton:nil];
//    [self setCancelButton:nil];
//    [self setNavBar:nil];
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    [self setMapView:nil];
//    self.selectedAnnotation = nil;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

//- (IBAction)cancel:(id)sender {
//    self.completionHandler(nil, YES);
//}

- (IBAction)doneAction:(id)sender {
    if (self.selectedAnnotation) {
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:self.selectedAnnotation.coordinate.latitude longitude:self.selectedAnnotation.coordinate.longitude];
        if(self.completionHandler){
            self.completionHandler(loc, NO);
            [self goBack];
        }
        else{
            [self performSegueWithIdentifier:@"unwindToSHPWizardStepStartReport" sender:self];
        }
       
        
    } else {
        NSString *alertMessage = @"Please select a position on the Map"; //NSLocalizedString(@"LocDisabledMessageLKey", nil);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)currentLocationAction:(id)sender {
//    self.completionHandler(nil, YES, NO);
}

-(void)goBack {
    
    [self.navigationController popViewControllerAnimated:YES];
    //    [self.navigationController popToRootViewControllerAnimated:TRUE];
}

-(void)dealloc {
    NSLog(@"DEALLOCATING MAP-IN");
}

@end
