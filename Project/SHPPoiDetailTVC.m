//
//  CZProvaTVC.m
//  AboutMe
//
//  Created by Dario De pascalis on 02/05/15.
//  Copyright (c) 2015 Dario De Pascalis. All rights reserved.
//

#import "SHPPoiDetailTVC.h"
#import "SHPShop.h"
#import "SHPImageCache.h"
#import "SHPImageRequest.h"
#import "SHPApplicationContext.h"
#import "SHPObjectCache.h"
#import "SHPComponents.h"
#import "SHPPoiCollectionVC.h"
#import "SHPMapperViewController.h"
#import "SHPAppDelegate.h"


@interface SHPPoiDetailTVC ()
@end

@implementation SHPPoiDetailTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    NSLog(@"LOADING FOR SHOP %f...", self.shop.lon);
    if(!self.shop){
        self.shop = [[SHPShop alloc] init];
    }
    [SHPComponents titleLogoForViewController:self];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadShop) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    self.imageCoverUp.image = nil;
    
    self.hideOtherProducts = YES;
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self setContainer];
    [self initialize];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self.tableView reloadData];
}

-(void)setContainer{
    SHPPoiCollectionVC *containerVC;
    containerVC = [self.childViewControllers objectAtIndex:0];
    containerVC.applicationContext = self.applicationContext;
    containerVC.shop = self.shop;
    NSLog(@"setContainer--------------------------------------------------------%@", containerVC);
    [containerVC loadProducts];
    //[containerVC.collectionView reloadData];
}

-(void)initialize
{
    NSLog(@"Initializing...");
    [self initializeImages];
    if(![self.applicationContext.objectsCache getObject:self.shop.oid]){
        [self loadShop];
    }else{
        self.shop = (SHPShop *)[self.applicationContext.objectsCache getObject:self.shop.oid];
    }
    self.labelDistanceToYou.text = @"";
    self.labelShopName.text = self.shop.name;
    self.labelCity.text = self.shop.city;
    [self.labelCity sizeToFit];
    if(self.distance){
        self.labelDistanceToYou.text = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"toKey", nil), self.distance];
    }
    self.labelAddress.text=@"";
    if(self.shop.formattedAddress){
        self.labelAddress.text = self.shop.formattedAddress;
    }
    self.labelTelephone.text=@"";
    if(self.shop.phone){
        self.labelTelephone.text = self.shop.phone;
    }
//    self.labelSmartphone.text=@"";
//    if(self.shop.smartphone){
//        self.labelSmartphone.text = self.shop.smartphone;
//    }
//    self.labelFax.text=@"";
//    if(self.shop.fax){
//        self.labelFax.text = self.shop.fax;
//    }
    self.labelEmail.text=@"";
    if(self.shop.email){
        self.labelEmail.text = self.shop.email;
    }
    self.labelWebsite.text=@"";
    if(self.shop.website){
        self.labelWebsite.text = self.shop.website;
    }
    self.labelDescription.text=@"";
    if(self.shop.theDescription){
        self.labelDescription.text = self.shop.theDescription;
        //self.labelDescription.numberOfLines = 0;
        //[self.labelDescription sizeToFit];
    }
    
//    if(self.imageMap){
//        self.imageViewMap.image = self.imageMap;
//    }
//    
//    if(self.shop.coverImage){
//        [self animationImage:self.shop.coverImage];
//    }
    
    [self.tableView reloadData];
}


-(void)initializeImages
{
    if(self.imageMap){
        self.imageViewMap.image = self.imageMap;
    }else{
        [self initializeMapImage];
    }
    if(!self.imageCoverUp.image){
        [self setCoverImage];
    }
}

-(void)loadShop{
    NSLog(@"loadShop****** %@", self.shop.oid);
    if(!self.shop.oid || [self.shop.oid isEqualToString:@""]){
        NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
        self.shop.oid = [settingsDictionary objectForKey:@"shopOid"];
    }
    if(!self.shop.oid || [self.shop.oid isEqualToString:@""])[self.refreshControl endRefreshing];
    else[self setupShop];
}


//-------------------------------------------------------------//
//START LOAD IMAGES
//-------------------------------------------------------------//
-(void)setCoverImage
{
    NSLog(@"setCoverImage");
    if(self.shop.coverImage){
        [self animationImage:self.shop.coverImage];
    }else{
        [self updateCover];
    }
}

-(void)updateCover
{
    NSLog(@"updateCover");
    NSString *imageURL = self.shop.coverImageURL;
    SHPImageCache *imageCache = self.applicationContext.mainListImageCache;
    UIImage *coverImage = [imageCache getImage:imageURL];
    if(coverImage){
        [self animationImage:coverImage];
    }else{
        SHPImageRequest *imageRequest = [[SHPImageRequest alloc] init];
         __weak SHPPoiDetailTVC *weakSelf = self;
        [imageRequest downloadImage:imageURL
              completionHandler:
        ^(UIImage *image, NSString *imageURL, NSError *error) {
             if (image) {
                 NSLog(@"Cover image loaded");
                 [weakSelf.applicationContext.mainListImageCache addImage:image withKey:imageURL];
                 weakSelf.shop.coverImage = image;
                 [weakSelf animationImage:image];
                 //[weakSelf.tableView reloadData];
             } else {
              NSLog(@"Cover image not loaded!");
              // put an image that indicates "no image"
            }
        }];
    }
}

-(void)initializeMapImage {
    NSLog(@"INITIALIZING MAP IMAGE...%@",self.imageMap);
    NSString *location = [[NSString alloc] initWithFormat:@"%f,%f", self.shop.lat, self.shop.lon];
    NSString *urlImgPoiMap = [[NSString alloc] initWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=16&size=640x300&maptype=roadmap&markers=color:blue|label:|%@",location,location];
    if(![self.applicationContext.productDetailImageCache getImage:urlImgPoiMap]) {
        self.imageMap = nil;
        //loadImageMap = YES;
        [self startImageMap:urlImgPoiMap];
    } else {
        self.imageMap = [self.applicationContext.productDetailImageCache getImage:urlImgPoiMap];
        self.imageViewMap.image = self.imageMap;
        //[self.tableView reloadData];
    }
}
- (void)startImageMap:(NSString*)detailImageURL {
    NSLog(@"startImageMap................. %@", detailImageURL);
    detailImageURL = [detailImageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SHPImageRequest *imageRequest = [[SHPImageRequest alloc] init];
    __weak SHPPoiDetailTVC *weakSelf = self;
    [imageRequest downloadImage:detailImageURL
              completionHandler:
     ^(UIImage *image, NSString *imageURL, NSError *error) {
         if (image) {
             [weakSelf.applicationContext.productDetailImageCache addImage:image withKey:imageURL];
             weakSelf.imageMap = image;
             weakSelf.imageViewMap.image = self.imageMap;
             //loadImageMap = NO;
             [self.tableView reloadData];
             NSLog(@"reloadData................startImageMap ");
         } else {
             NSLog(@"reloadData..........startImageMap error: %@", error);
             // put an image that indicates "no image profile"
         }
     }];
}
//-------------------------------------------------------------//
//END LOAD IMAGES
//-------------------------------------------------------------//


-(void)animationImage:(UIImage *)image {
    NSLog(@"animationImage");
    self.imageCoverUp.alpha = 0.0;
    self.imageCoverUp.image = image;
    [UIView animateWithDuration:0.5
                     animations:^(void) {
                         self.imageCoverUp.alpha = 1.0;
                     } completion:^(BOOL finished) {
                         //                                      //show shopInfo
                         //                                      [UIView animateWithDuration:delay
                         //                                                       animations:^(void) {
                         //                                                           shopInfoView.alpha = 0.6;
                         //                                                       } completion:^(BOOL finished) {}
                         //                                       ];
                     }];
}


//- (void)viewDidLoad {
//    [super viewDidLoad];
//    DC = [[CZAuthenticationDC alloc] init];
//    DC.delegate = self;
//    
//    //self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars = NO;
//    self.automaticallyAdjustsScrollViewInsets = NO;
//    
//        [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
//                                                      forBarMetrics:UIBarMetricsDefault];
//        self.navigationController.navigationBar.contentMode = UIViewContentModeScaleAspectFill;
//        self.navigationController.navigationBar.shadowImage = [UIImage new];
//        self.navigationController.navigationBar.translucent = YES;
//        self.navigationController.view.backgroundColor = [UIColor clearColor];
//    
//    defaultH = self.imageBck.frame.size.height;
//    self.imageBck.image = [DC blur:self.imageBck.image radius:16];
//    [CZAuthenticationDC arroundImage:(self.imageProfile.frame.size.height/2) borderWidth:0.0 layer:[self.imageProfile layer]];
//    //self.imageProfile.image = image;
//    //self.imageBackground.alpha = 0;
//    
//    // Uncomment the following line to preserve selection between presentations.
//    // self.clearsSelectionOnViewWillAppear = NO;
//    
//    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



//---------------------------------------------------------------//
//-----------START LOAD SHOP
//---------------------------------------------------------------//
-(void)setupShop {
    NSLog(@"setupShop");
    self.shopDC = [[SHPShopDC alloc] init];
    [self.shopDC setShopsLoadedDelegate:self];
    [self.shopDC searchByShopId:self.shop.oid];
}

//DELEGATE setupShop
- (void)shopsLoaded:(NSArray *)shops {
    NSLog(@"Nr of Shops in delegate: %lu", (unsigned long)[shops count]);
    if(shops.count > 0) {
        self.shop = [shops objectAtIndex:0];
        [self.applicationContext.objectsCache addObject:self.shop withKey:self.shop.oid];
        [self.refreshControl endRefreshing];
        [self initialize];
    } else {
        NSLog(@"Shop not found!");
    }
}
//---------------------------------------------------------------//
//------------ END LOAD SHOP
//---------------------------------------------------------------//



//---------------------------------------------------------------//
//------------ START TABLEVIEW FUNCTIONS
//---------------------------------------------------------------//
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [super tableView:tableView numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    //UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifierCell = [cell reuseIdentifier];
    NSLog(@"heightForRowAtIndexPath..%@ - %@", indexPath, identifierCell);
    if([identifierCell isEqualToString:@"idCellTelephone"] && !self.shop.phone){
        return 0;
    }
    if([identifierCell isEqualToString:@"idCellCellulare"]){// && !self.shop.cell){
        return 0;
    }
    if([identifierCell isEqualToString:@"idCellFax"]){ //&& !self.shop.fax){
        return 0;
    }
    if([identifierCell isEqualToString:@"idCellEmail"] && [self.labelEmail.text isEqualToString:@""]){
        return 0;
    }
    if([identifierCell isEqualToString:@"idCellWebSite"] && [self.labelWebsite.text isEqualToString:@""]){
        return 0;
    }
    if([identifierCell isEqualToString:@"idCellDescription"] && [self.labelDescription.text isEqualToString:@""]){
        return 0;
    }
    if([identifierCell isEqualToString:@"idCellOther"] && self.hideOtherProducts == YES){
        return 0;
    }
    return UITableViewAutomaticDimension;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
//    //cell.backgroundColor = [UIColor clearColor];
//    return cell;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@" didSelectRowAtIndexPath identifier: %@",[cell reuseIdentifier]);
    NSString *identifierCell = [cell reuseIdentifier];
    if([identifierCell isEqualToString:@"idShowOnMap"]){
        [self performSegueWithIdentifier: @"toMap" sender: self];
    }
    else if([identifierCell isEqualToString:@"idAddress"]){
        NSURL *testURL = [NSURL URLWithString:@"http://maps.apple.com/"];
        if ([[UIApplication sharedApplication] canOpenURL:testURL]) {
            NSString *sampleUrl = self.shop.formattedAddress;
            NSString *encodedUrl = [sampleUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *directionsRequest = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@&directionsmode=driving&x-success=sourceapp://?resume=true&x-source=AirApp", encodedUrl];
            NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
            [[UIApplication sharedApplication] openURL:directionsURL];
            NSLog(@"url string: %@",directionsRequest);
        } else {
            NSLog(@"Can't use comgooglemaps-x-callback:// on this device.");
        }
    }
    else if([identifierCell isEqualToString:@"idCellTelephone"] || [identifierCell isEqualToString:@"idCellCellulare"]){
        NSString *telURL = [[NSString alloc] initWithFormat:@"tel://%@", self.shop.phone];
        telURL = [telURL stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSLog(@"Sto chiamando %@...", telURL);
        NSURL *url = [NSURL URLWithString:telURL];
        [[UIApplication sharedApplication] openURL:url];
    }
    else if([identifierCell isEqualToString:@"idCellEmail"]){
        if (self.shop.email && ![self.shop.email isEqualToString:@""]) {
            NSString *url = [NSString stringWithFormat:@"mailto:%@", self.shop.email];
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
        }
    }
    else if([identifierCell isEqualToString:@"idCellWebSite"]){
        if (self.shop.website && ![self.shop.website isEqualToString:@""]) {
            NSString *url = self.shop.website;
            [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
        }
    }
}




- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    NSString * segueName = segue.identifier;
//    if ([[segue identifier] isEqualToString:@"idEmbedPoiCollectionVC"]) {
//        SHPPoiCollectionVC *embed = segue.destinationViewController;
//        embed.shop = self.shop;
//        embed.applicationContext = self.applicationContext;
//    }
//    else
    if([[segue identifier] isEqualToString:@"toMap"]) {
        SHPMapperViewController *map = [segue destinationViewController];
        map.applicationContext = self.applicationContext;
        map.lat = self.shop.lat;
        map.lon = self.shop.lon;
        map.address = self.shop.formattedAddress;
        map.placeHolderTitle = self.shop.name;
    }
}
//---------------------------------------------------------------//
//------------ END TABLEVIEW
//---------------------------------------------------------------//
-(void)terminatePendingConnections {
    [self.shopDC setShopsLoadedDelegate:nil];
}

-(void)dealloc {
    NSLog(@"SHOP DETAIL DEALLOCATING...");
    [self terminatePendingConnections];
}

@end
