//
//  SHPShopDataViewController.m
//  Dressique
//
//  Created by andrea sponziello on 25/02/13.
//
//

#import "SHPShopDataViewController.h"
#import "SHPShop.h"
#import "SHPShopDC.h"
#import "SHPObjectCache.h"
#import "SHPApplicationContext.h"
#import <QuartzCore/QuartzCore.h>
#import "SHPMapperViewController.h"
#import "SHPComponents.h"
//#import "SVPullToRefresh.h"

@interface SHPShopDataViewController ()

@end

@implementation SHPShopDataViewController

@synthesize shopDC;
@synthesize shop;
@synthesize applicationContext;
@synthesize annotationPoint;
//@synthesize phoneAlertView;

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
    
	UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadShop) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    [self initViewComponents];
    
//    UIColor *bgColor = [UIColor colorWithRed:216.0f/255.0f green:220.0f/255.0f blue:230.0f/255.0f alpha:1.0];
//    self.view.backgroundColor = bgColor;
    
    [self setupShopOnLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    // if tapped the popover view disappears. This forces the popover to appear again.
    if (self.annotationPoint) {
        [self.mapView selectAnnotation:self.annotationPoint animated:YES];
    }
}

-(void)viewWillDisappear:(BOOL)animated {
    // pop out (disposing) isMovingFromParent = 1
    // push in isMovingFromParent = 0
    if (self.isMovingFromParentViewController) {
        if (self.shopDC) {
            [self.shopDC cancelDownload];
        }
    }
}

-(void)customizeTitle:(NSString *)title {
    if(title == nil){
        UIImage *logo = [UIImage imageNamed:@"title-logo"];
        UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logo];
        self.navigationItem.titleView = titleLogo;
        self.navigationItem.title=nil;
    }else{
        [SHPComponents titleLogoForViewController:self];
        self.navigationItem.title = title;
    }
}

//-(void)customizeTitle:(NSString *)title {
//    self.navigationItem.title = title;
//}

-(void)setupShopOnLoad {
    NSLog(@"Shop setup...");
    SHPShop *cachedShop = (SHPShop *)[self.applicationContext.objectsCache getObject:self.shop.oid];
    NSLog(@"SHOP IN CACHE %@", cachedShop);
    if (cachedShop) {
        self.shop = cachedShop;
    }
    if (!self.shop.loaded) {
        self.routeToButton.enabled = NO;
        
        [self fieldButton:self.phoneButton withTitle:@""];
        self.phoneButton.enabled = NO;
        
        [self fieldButton:self.emailButton withTitle:@""];
        self.emailButton.enabled = NO;
        
        [self fieldButton:self.websiteButton withTitle:@""];
        self.websiteButton.enabled = NO;
        
        [self loadShop];
//        self.tableView.hidden = YES;
    } else {
        [self updateView];
    }
}

-(void)loadShop {
    self.shopDC = [[SHPShopDC alloc] init];
    [self.shopDC setShopsLoadedDelegate:self];
    [self.shopDC searchByShopId:self.shop.oid];
}

// SHOP DELEGATE
- (void)shopsLoaded:(NSArray *)shops {
    NSLog(@"Nr of Shops in delegate: %d", [shops count]);
    [self.refreshControl endRefreshing];
    if(shops.count > 0) {
        self.shop = [shops objectAtIndex:0];
        NSLog(@"ADDING SHOP TO OBJECTS CACHE");
        [self.applicationContext.objectsCache addObject:self.shop withKey:self.shop.oid];
        NSLog(@"SHOP LOADED: %@ ", self.shop);
        [self customizeTitle:nil];//
//        [self.tableView reloadData];
        [self updateView];
    } else {
        NSLog(@"Shop not found!");
    }
}

-(void)updateView {
    [self customizeTitle:self.shop.name];
    
    if (self.shop.lat == 0 && self.shop.lon == 0) {
        self.routeToButton.enabled = NO;
    } else {
        [self addTapToMap];
        self.routeToButton.enabled = YES;
    }
    
    if (self.shop.phone && ![self.shop.phone isEqualToString:@""]) {
        [self fieldButton:self.phoneButton withTitle:self.shop.phone];
        self.phoneButton.enabled = YES;
    } else {
        [self fieldButton:self.phoneButton withTitle:NSLocalizedString(@"NotAvailableLKey", nil)];
        self.phoneButton.enabled = NO;
    }
    
    if (self.shop.email && ![self.shop.email isEqualToString:@""]) {
        [self fieldButton:self.emailButton withTitle:self.shop.email];
        self.emailButton.enabled = YES;
    } else {
        [self fieldButton:self.emailButton withTitle:NSLocalizedString(@"NotAvailableLKey", nil)];
        self.emailButton.enabled = NO;
    }
    
    if (self.shop.website && ![self.shop.website isEqualToString:@""]) {
        [self fieldButton:self.websiteButton withTitle:self.shop.website];
        self.websiteButton.enabled = YES;
    } else {
        [self fieldButton:self.websiteButton withTitle:NSLocalizedString(@"NotAvailableLKey", nil)];
        self.websiteButton.enabled = NO;
    }
    
    if (self.shop.theDescription && ![self.shop.theDescription isEqualToString:@""]) {
        self.descriptionLabel.text = self.shop.theDescription;
    } else {
        self.descriptionLabel.text = NSLocalizedString(@"NotAvailableLKey", nil);
    }
    
    // map
    if (self.shop.lat != 0 && self.shop.lon != 0) {
        CLLocationCoordinate2D annotationCoord;
        annotationCoord.latitude = self.shop.lat;
        annotationCoord.longitude = self.shop.lon;
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        self.annotationPoint = [[MKPointAnnotation alloc] init];
        self.annotationPoint.coordinate = annotationCoord;
        self.annotationPoint.title = [[NSString alloc] initWithFormat:@"%@, %@", self.shop.city, self.shop.address ];
        
        //    self.annotation = annotationPoint;
        // annotationPoint.subtitle = @"Description";
        [self.mapView addAnnotation:self.annotationPoint];
        
        // Zooming on current position
        MKCoordinateSpan span = MKCoordinateSpanMake(0.2, 0.2);
        MKCoordinateRegion region = MKCoordinateRegionMake(self.annotationPoint.coordinate, span);
        [self.mapView setRegion:region animated:NO];
        NSLog(@"SELECTING ANNOTATION %@", self.annotationPoint);
        [self.mapView selectAnnotation:self.annotationPoint animated:YES];
    }
    
    // description size
    CGSize sizeInto = CGSizeMake(self.descriptionLabel.frame.size.width, 1001);

    
    CGSize labelSize = [self.descriptionLabel.text sizeWithFont:self.descriptionLabel.font
                                constrainedToSize:sizeInto
                                    lineBreakMode:NSLineBreakByWordWrapping];
    
    CGFloat labelHeight = labelSize.height;
    CGRect dframe = self.descriptionLabel.frame;
    if (labelHeight > dframe.size.height) {
        dframe.size.height = labelHeight;
        self.descriptionLabel.frame = dframe;
        UIView *descSuperView = self.descriptionLabel.superview;
        CGRect superviewFrame = descSuperView.frame;
        float dframe_top = dframe.origin.y;
        superviewFrame.size.height = dframe_top + dframe.size.height + dframe_top;
        descSuperView.frame = superviewFrame;
    }
    
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 6) {
        UIView *descSuperView = self.descriptionLabel.superview;
        float top = descSuperView.frame.origin.y;
        return top + descSuperView.frame.size.height + top;
    } else {
        float h;
        switch (indexPath.row) {
            case 0:
                h = 123;
                break;
            case 1:
                h = 61;
                break;
            case 2:
                h = 61;
                break;
            case 3:
                h = 61;
                break;
            case 4:
                h = 61;
                break;
            case 5:
                h = 44;
                break;
            default:
                h = 44;
                break;
        }
        return h;
//        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
//        NSLog(@"cell: %@", cell);
//        return cell.frame.size.height;
    }
}

-(void)fieldButton:(UIButton *)button withTitle:(NSString *)title {
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateHighlighted];
    
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
}

-(void)initViewComponents {
    // background
//    UIColor *bgColor = [UIColor colorWithRed:216.0f/255.0f green:220.0f/255.0f blue:230.0f/255.0f alpha:1.0];
//    self.tableView.backgroundColor = bgColor;
//    self.tableView.separatorColor = bgColor;
    
    // fields' corners
    UIView *superView = self.phoneButton.superview;
    [self styleFieldView:superView];
    
    superView = self.emailButton.superview;
    [self styleFieldView:superView];
    
    superView = self.websiteButton.superview;
    [self styleFieldView:superView];
    
    superView = self.routeToButton.superview;
    [self styleFieldView:superView];
    
    superView = self.descriptionLabel.superview;
    [self styleFieldView:superView];
    
    // description label specific
    self.descriptionLabel.numberOfLines = 0; // auto calculate number of lines
    self.descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    // labels
    [self fieldButton:self.routeToButton withTitle:NSLocalizedString(@"GetRouteLKey", nil)];
    self.phoneNumberLabel.text = NSLocalizedString(@"PhoneNumberLKey", nil);
    self.emailLabel.text = NSLocalizedString(@"EmailLKey", nil);
    self.websiteLabel.text = NSLocalizedString(@"WebsiteLKey", nil);
    self.infoTitleLabel.text = NSLocalizedString(@"InfoLKey", nil);
    
    // map
    [self initMiniMap];
}

-(void)styleFieldView:(UIView *)fieldView {
    CALayer * layer = [fieldView layer];
    [layer setMasksToBounds:YES];
    [layer setBorderWidth:1.0];
    layer.cornerRadius = 6.0;
    layer.borderColor = [UIColor colorWithRed:200.0f/255.0f green:202.0f/255.0f blue:210.0f/255.0f alpha:1.0].CGColor;
    fieldView.backgroundColor = [UIColor whiteColor];
//    [mapLayer setBorderColor:[UIColor lightGrayColor].CGColor];
}

-(void)initMiniMap {
    CALayer * mapLayer = [self.mapView layer];
    [mapLayer setMasksToBounds:YES];
    [mapLayer setBorderWidth:0.5];
    mapLayer.cornerRadius = 6.0;
    mapLayer.borderColor = [UIColor colorWithRed:201.0f/255.0f green:200.0f/255.0f blue:199.0f/255.0f alpha:1.0].CGColor;
    self.mapView.scrollEnabled = NO;
    self.mapView.zoomEnabled = NO;
}

-(void)addTapToMap {
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(didTapMap)];
    [self.mapView addGestureRecognizer:tapRec];
}

-(void)didTapMap {
    [self performSegueWithIdentifier:@"ShopOnMap" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewDidUnload {
//    [self setMapView:nil];
//    [self setShopInfoLabel:nil];
//    [self setPhoneNumberLabel:nil];
//    [self setPhoneButton:nil];
//    [self setEmailButton:nil];
//    [self setWebsiteButton:nil];
//    [self setRouteToButton:nil];
//    [self setEmailLabel:nil];
//    [self setWebsiteLabel:nil];
//    [self setInfoTitleLabel:nil];
//    [self setDescriptionLabel:nil];
//    [super viewDidUnload];
//}

//- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"selected s:%d i:%d", indexPath.section, indexPath.row);
//    if (indexPath.section == 1 && indexPath.row == 0) {
//        NSLog(@"call a number");
//        phoneAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"CallTitleLKey", nil) message:self.shop.phone delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) otherButtonTitles:@"OK", nil];
//        [phoneAlertView show];
//    } else if (indexPath.section == 1 && indexPath.row == 1) {
//        NSLog(@"send email");
//        if (self.shop.email && ![self.shop.email isEqualToString:@""]) {
//            NSString *url = [NSString stringWithFormat:@"mailto:%@", self.shop.email];
//            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
//        }
//    } else if (indexPath.section == 1 && indexPath.row == 2) {
//        NSLog(@"show website");
//        if (self.shop.website && ![self.shop.website isEqualToString:@""]) {
//            NSString *url = self.shop.website;
//            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
//        }
//    }
//    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
//}
//
//- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
//    NSLog(@"ActionSheet %@", actionSheet);
//    if (actionSheet == phoneAlertView) {
//        switch (buttonIndex) {
//            case 0:
//            {
//                break;
//            }
//            case 1:
//            {
//                NSString *telURL = [[NSString alloc] initWithFormat:@"tel://%@", self.shop.phone];
//                telURL = [telURL stringByReplacingOccurrencesOfString:@" " withString:@""];
//                NSLog(@"Sto chiamando %@...", telURL);
//                NSURL *url = [NSURL URLWithString:telURL];
//                [[UIApplication sharedApplication] openURL:url];
//                break;
//            }
//        }
//    }
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"ShopOnMap"]) {
        SHPMapperViewController *map = [segue destinationViewController];
        map.applicationContext = self.applicationContext;
        map.lat = self.shop.lat;
        map.lon = self.shop.lon;
        map.placeHolderTitle = self.shop.name;
    }
}

- (IBAction)phoneAction:(id)sender {
    NSString *telURL = [[NSString alloc] initWithFormat:@"tel://%@", self.shop.phone];
    telURL = [telURL stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSLog(@"Sto chiamando %@...", telURL);
    NSURL *url = [NSURL URLWithString:telURL];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)emailAction:(id)sender {
    NSLog(@"send email");
    if (self.shop.email && ![self.shop.email isEqualToString:@""]) {
        NSString *url = [NSString stringWithFormat:@"mailto:%@", self.shop.email];
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}

- (IBAction)websiteAction:(id)sender {
    NSLog(@"show website");
    if (self.shop.website && ![self.shop.website isEqualToString:@""]) {
        NSString *url = self.shop.website;
        [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
    }
}

- (IBAction)routeToAction:(id)sender {
    [self didTapMap];
}

@end
