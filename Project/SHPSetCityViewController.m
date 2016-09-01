//
//  SHPSetCityViewController.m
//  Ciaotrip
//
//  Created by Dario De Pascalis on 19/02/14.
//
//

#import "SHPSetCityViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "SHPApplicationContext.h"
#import "SHPAppDelegate.h"
#import "SHPGoogleReferenceRequest.h"

@interface SHPSetCityViewController ()
@end

NSString *googleMapKey;//=@"AIzaSyCUj4kGjW7_vW1wsGV2Fx_owE3h2ivmt78";
float radius;
NSString *language;



@implementation SHPSetCityViewController

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
    
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    self.applicationContext = appDelegate.applicationContext;

    self.arraySearch = [[NSMutableArray alloc] init];
    self.searchDisplayController.searchResultsDelegate=self;
    //[self.searchDisplayController setDisplaysSearchBarInNavigationBar:NO];
    
    /***********************************************************************************/
    UIImage *logo = [UIImage imageNamed:@"title-logo"];
    UIImageView *titleLogo = [[UIImageView alloc] initWithImage:logo];
        self.navigationItem.titleView = titleLogo;
    /***********************************************************************************/
    NSLog(@"latitude: %@",self.applicationContext.lastLocation);
    

    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    googleMapKey=[settingsDictionary objectForKey:@"googleMapKey"];
    radius = [[settingsDictionary objectForKey:@"radius"] integerValue];
    
    
    
//    NSLog(@"longitude: %f",self.applicationContext.lastLocation.coordinate.longitude);
    
//    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
//    googleMapKey = [thisBundle localizedStringForKey:@"googleMapKey" value:@"KEY NOT FOUND" table:@"setting"];
//    radius = [[thisBundle localizedStringForKey:@"radius" value:@"KEY NOT FOUND" table:@"setting"] floatValue];
    
    //googleMapKey = @"AIzaSyAdoL7ygwPNDM47ikqbEVgZ0ZObX_Nt9f0";//AIzaSyCfnGRoO9lrJSB65LXrFRB8JuVq8L47tbI";//@"AIzaSyCUj4kGjW7_vW1wsGV2Fx_owE3h2ivmt78";//
    //radius = 100.000000;
    language = [NSString stringWithFormat:@"%@_%@", [[NSLocale preferredLanguages] objectAtIndex:0], [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode]];
    NSLog(@"-------------------------------------------- key: %@ - radius: %f - lang: %@",googleMapKey,radius,language);
    //NSString *language =@"it_IT";
    
    // init searchbar
    [self.searchDisplayController.searchBar becomeFirstResponder];
    [self.searchDisplayController setActive:YES];
    [self.searchBar setDelegate:self];
    [self.searchBar becomeFirstResponder];
    self.searchBar.showsCancelButton = YES;
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication ] setStatusBarStyle : UIStatusBarStyleDefault];
}

- (void)didReceiveMemoryWarning{
    NSLog(@"didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//searchbar delegate


-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"CANCELED");
    [[UIApplication sharedApplication ] setStatusBarStyle : UIStatusBarStyleLightContent];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"searchBar");
    [self fetchPlaceDetail];
}

- (void)fetchPlaceDetail{
    NSLog(@"fetchPlaceDetail");
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self googleURLString]]];
    self.googleConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.responseData = [[NSMutableData alloc] init];
}

- (NSString *)googleURLString {
    float latitude = self.applicationContext.lastLocation.coordinate.latitude;
    float longitude = self.applicationContext.lastLocation.coordinate.longitude;
    //https://maps.googleapis.com/maps/api/place/details/json?reference=CmRYAAAAciqGsTRX1mXRvuXSH2ErwW-jCINE1aLiwP64MCWDN5vkXvXoQGPKldMfmdGyqWSpm7BEYCgDm-iv7Kc2PF7QA7brMAwBbAcqMr5i1f4PwTpaovIZjysCEZTry8Ez30wpEhCNCXpynextCld2EBsDkRKsGhSLayuRyFsex6JA6NPh9dyupoTH3g&sensor=true&key=AddYourOwnKeyHere
      NSString *textSearch = [[NSString alloc] init];
//    if([self.searchBar.text isEqual:@""]){
//        NSLog(@"searchBar: %@",self.searchBar.text); 
//        textSearch=@"a";
//    }else {
        textSearch = self.searchBar.text;
    //}
   
    NSMutableString *url = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&sensor=true&key=%@&location=%f,%f&radius=%f&language=%@",
                            textSearch, googleMapKey, latitude, longitude, radius, language];
    
    NSLog(@"googleURLString: %@",url);
    return url;
}




- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse");
    if (connection == self.googleConnection) {
        [self.responseData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connnection didReceiveData:(NSData *)data {
    NSLog(@"didReceiveData");
    if (connnection == self.googleConnection) {
        [self.responseData appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError %@", error);
    if (connection == self.googleConnection) {
        
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSString *responseString = [[NSString alloc] initWithData:self.responseData encoding:NSISOLatin1StringEncoding];
    //NSLog(@"response: %@", responseString);
    if (connection == self.googleConnection) {
        NSError *error = nil;
        NSDictionary *response = [NSJSONSerialization JSONObjectWithData:self.responseData options:kNilOptions error:&error];
        if (error) {
             //[self failWithError:error];
            return;
        }
        if ([[response objectForKey:@"status"] isEqualToString:@"ZERO_RESULTS"]) {
            //[self succeedWithPlaces:[NSArray array]];
            return;
        }
        if ([[response objectForKey:@"status"] isEqualToString:@"OK"]) {
            [self succeedWithPlaces:[response objectForKey:@"predictions"]];
            return;
        }
    }
}

- (void)succeedWithPlaces:(NSArray *)places {
    NSLog(@"succeedWithPlaces");
    [self.arraySearch removeAllObjects];
    for (NSDictionary *place in places) {
            NSLog(@"place: %@", place);
            [self.arraySearch addObject:place];
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"numberOfSectionsInTableView: 2");
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
   
    if(section==0) {
        NSLog(@"numberOfRowsInSection 0");
        return 1;
    }else{
        NSLog(@"numberOfRowsInSection 1");
        return self.arraySearch.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"section: %d - %d", (int)indexPath.section, (int)indexPath.row);
    static NSString *CellIdentifier;
    CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if(indexPath.section==0){
        cell.imageView.image = [UIImage imageNamed:@"location_icon_mini"];
        cell.textLabel.text = NSLocalizedString(@"Posizione attuale", nil);
    }else{
    //if (tableView == self.searchDisplayController.searchResultsTableView) {
        //this is where i give the name but it's not working.
        cell.imageView.image = [UIImage imageNamed:@"location_icon_pin"];
        cell.textLabel.text = [NSString stringWithFormat:@"%@",[[self.arraySearch objectAtIndex:indexPath.row] objectForKey:@"description"]];
    //} else {
        //cell.textLabel.text = [self.arraySearch objectAtIndex:indexPath.row];
    //}
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"dismetto la vista e passo le coordiate");
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section==0){
        self.applicationContext.searchLocation = nil;
        self.applicationContext.searchLocationName = nil;
        [SHPApplicationContext deleteSearchLocationInfo];
        [[UIApplication sharedApplication ] setStatusBarStyle : UIStatusBarStyleLightContent];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        NSString *nameCity = [[self.arraySearch objectAtIndex:indexPath.row] objectForKey:@"description"];
        NSLog(@"SELECTED CITY!!!!! %@",nameCity);
        self.applicationContext.searchLocationName = nameCity;
        [SHPApplicationContext saveSearchLocationName:nameCity];
        [self getReferenceObject:[[self.arraySearch objectAtIndex:indexPath.row] objectForKey:@"reference"]];
    }
}

-(void)getReferenceObject:(NSString *)reference {
    NSLog(@"44");
    SHPGoogleReferenceRequest *req = [[SHPGoogleReferenceRequest alloc] init];
    req.api_key = googleMapKey;
    [req download:reference completionHandler:^(NSDictionary *dictionary, NSError *error) {
        if (!error) {
//            OBJECT > RESULT > GEOMETRY > LOCATION > LAT|LON
            NSDictionary *locationD = [[[dictionary objectForKey:@"result"] objectForKey:@"geometry"] objectForKey:@"location"];
            NSString *_lat = [locationD objectForKey:@"lat"];
            NSString *_lng = [locationD objectForKey:@"lng"];
            NSLog(@"LAT: %@", _lat);
            NSLog(@"LNG: %@", _lng);
            
            double lat = [_lat doubleValue];
            double lng = [_lng doubleValue];
            
            CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
            
            self.applicationContext.searchLocation= location;
            NSLog(@"location: %@", self.applicationContext.searchLocation);
            [SHPApplicationContext saveSearchLocation:location];
            [[UIApplication sharedApplication ] setStatusBarStyle : UIStatusBarStyleLightContent];
            [self dismissViewControllerAnimated:YES completion:nil];
        } else {
            // TODO alert
        }
    }];
}



- (void)reverseGeocode:(CLLocation *)location {
    [self.geocoder reverseGeocodeLocation:location
    completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"reverseGeocodeLocation:completionHandler:");
        if (error) {
            NSLog(@"Geocode failed with error: %@", error);
            return;
        }
        if(placemarks && placemarks.count > 0) {
            CLPlacemark *topResult = [placemarks objectAtIndex:0];
            NSString *addressTxt = [NSString stringWithFormat:@"%@", [topResult locality]];
            self.applicationContext.searchLocationName=addressTxt;
        }
    }];
}



- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}




@end