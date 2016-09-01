//
//  SHPProductDetail.m
//  BPP.it
//
//  Created by dario de pascalis on 27/02/15.
//
//

#import "SHPProductDetail.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Social/Social.h>
#import "SHPComponents.h"
#import "MBProgressHUD.h"
#import "SHPApplicationContext.h"
#import "SHPProduct.h"
#import "SHPObjectCache.h"
#import "SHPConstants.h"
#import "SHPStringUtil.h"
#import "SHPImageUtil.h"
#import "SHPShop.h"
#import "SHPImageRequest.h"
#import "SHPUserInterfaceUtil.h"
#import "SHPUser.h"
#import "SHPMapperViewController.h"
#import "SHPReportViewController.h"
#import "SHPLikesViewController.h"
#import "SHPLikedToLoader.h"
#import "SHPLoadInitialDataViewController.h"
#import "SHPMiniWebBrowserVC.h"
//#import "SHPAddObjectToCart.h"
#import "SHPImageDetailViewController.h"
#import "SHPMapperViewController.h"
#import "SHPAuthenticationVC.h"
#import "SHPHomeProfileTVC.h"
#import "SHPPoiDetailTVC.h"
#import "SHPListCoverTVC.h"
#import "SHPAppDelegate.h"
#import "SHPImageUtil.h"
#import "SHPConversationsVC.h"
//#import "SHPActivity.h"
#import "SHPSearchCategoriesNearPoiTVC.h"
#import "SHPProductsCollectionVC.h"
#import "SHPFirstStepWizardTVC.h"
#import "SHPWizardStep1Types.h"
#import "SHPUser.h"
#import "SHPEditPlacesVC.h"
#import "ChatRootNC.h"
#import "SHPSendMessageDialog.h"
#import "CustomActivityItemProvider.h"
#import <pop/POP.h>
#import "CZEditTimeTablesVC.h"
#import "SHPPOIOpenStatus.h"


@interface SHPProductDetail ()
@end

@implementation SHPProductDetail

- (void)viewDidLoad {
    [super viewDidLoad];
     NSLog(@" 1 - DetailPage: %@ (%@)", self.product.title, self.product.properties);
    
    if(!self.applicationContext){
        SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
        self.applicationContext = appDelegate.applicationContext;
    }
    
    [SHPComponents titleLogoForViewController:self];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(loadProduct) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    //SET PLIST VALUES
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    publicUpload=[[settingsDictionary objectForKey:@"publicUpload"] boolValue];
    multiStore=[[settingsDictionary objectForKey:@"multiStore"] boolValue];
    
    NSDictionary *viewDictionary = [self.applicationContext.plistDictionary objectForKey:@"View"];
    NSDictionary *productsListDictionary = [viewDictionary objectForKey:@"ProductDetail"];
    hideAuthor = [[productsListDictionary objectForKey:@"hideAuthor"] boolValue];
    hideShop = [[productsListDictionary objectForKey:@"hideShop"] boolValue];
    hideMap = [[productsListDictionary objectForKey:@"hideMap"] boolValue];
    hideCity = [[productsListDictionary objectForKey:@"hideCity"] boolValue];
    hideAddress = [[productsListDictionary objectForKey:@"hideAddress"] boolValue];
    hideReport = [[productsListDictionary objectForKey:@"hideReport"] boolValue];
    self.hideOtherProducts = YES;
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    // TEMP - BUG CRASH APPLE IOS 9.3.2
    self.navigationItem.rightBarButtonItem = nil;
    
    [self setContainer];
    [self initializeView];
    [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    NSLog(@"categoryType %@ ",self.product.categoryType);
    //if([self.product.categoryType isKindOfClass:[NSNull class]]){
    if(!self.product.categoryType){
        NSDictionary *arrayOidTypeCategories = (NSDictionary *)[self.applicationContext getVariable:DICTIONARY_CATEGORIES];
        NSLog(@"categoryType %@ -  CATEGORY_TYPE_COVER %@",self.applicationContext,arrayOidTypeCategories);
        self.product.categoryType=[arrayOidTypeCategories valueForKey:self.product.category];
    }
    //NSLog(@"categoryType %@ -  CATEGORY_TYPE_COVER %@",self.product.categoryType,CATEGORY_TYPE_COVER);
    //if([self.product.categoryType isEqualToString:CATEGORY_TYPE_COVER])[self setMenu];
    
    NSLog(@"2 PERMISSION UPLOAD DI = %d",  (int)self.applicationContext.loggedUser.canUploadProducts);
    if (!self.applicationContext.loggedUser) {
        [self loadPermission];
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // NSLog(@"self.navigationController.view:  %@ ",self.navigationController.view);
    [viewBackground removeFromSuperview];
    [stack removeFromSuperview];
}

//-(void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//}
//
//-(void)viewDidDisappear:(BOOL)animated {
//    [super viewDidDisappear:animated];
//}

//-------------------------------------------------------//
//START LOAD PERMISSION
//-------------------------------------------------------//
-(void)loadPermission{
     NSLog(@"3 PERMISSION UPLOAD DI = %d", self.applicationContext.loggedUser.canUploadProducts);
    verify = [[SHPVerifyUploadPermissionsDC alloc]init];
    verify.delegate=self;
    verify.applicationContext=self.applicationContext;
    [verify verifyUploadPermission];
}

//DELEGATE loadPermission
- (void)permissionCheck:(BOOL)permission{
    self.applicationContext.permissionUpload=permission;
    self.applicationContext.loggedUser.canUploadProducts=permission;
    NSLog(@"4 PERMISSION UPLOAD DI = %d",  self.applicationContext.loggedUser.canUploadProducts);
    [self.tableView reloadData];
}
//-------------------------------------------------------//
//END LOAD PERMISSION
//-------------------------------------------------------//


-(void)initializeView
{
    loadedProduct = NO;
    loadedShop = NO;
    loadingShop = NO;
    loadingProduct = NO;
    loadingProductImage = NO;
    loadingImageMap = NO;
    loadingImageUser = NO;
    
    //SET PHONE NUMBER
    [self setPhoneNumber];
    
    //SET EMAIL PRODUCT
    [self setEmail];
    
    //SET PLACES PRODUCT
    [self setNumberPlaces];
    
    //SET PLAN PRODUCT
    [self setPlan];
    
    
    //SET REMAINING TIME
    [self setRemainingTime];
    
   //SET PROGRESS VIEW
    self.progressView.hidden = YES;
    
    //SET BUTTON GO TO WIZARD ADD PRODUCT
    arrayButtonsAddProduct = [NSArray arrayWithObjects:CATEGORY_TYPE_PHOTO,CATEGORY_TYPE_EVENT,CATEGORY_TYPE_DEAL, nil];
}

-(void)setContainer{
    SHPProductsCollectionVC *containerVC;
    containerVC = [self.childViewControllers objectAtIndex:0];
    containerVC.applicationContext = self.applicationContext;
    containerVC.idProduct = self.product.oid;
    SHPUser *authorProfile = [[SHPUser alloc] init];
    authorProfile.username = self.product.createdBy;
    authorProfile.photoImage = self.userImage;
    containerVC.author = authorProfile;
    [containerVC loadProducts];
    //containerVC.startLoading = YES;
     NSLog(@"setContainer--------------------------------------------------------%@", containerVC.author);
    //[containerVC.collectionView reloadData];
}


-(void)initialize{
    NSLog(@"initialize--------------------------------------------------------%@", self.product.imageURL);
    self.product.title = [self.product.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    descriptionClean = [SHPStringUtil cleanTextFromUrls:self.product.longDescription];
    descriptionClean = [descriptionClean stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    arrayUrlsDescription = [SHPStringUtil extractUrlsInText:self.product.longDescription];
    //----------------------------------------------------------------//
    //controllo se esiste un url image valido prima di caricare l'immagine
    if(self.product.imageURL){//!self.productImage.image &&
        self.product.imageURL = [self.product.imageURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *explodeUrl = [self.product.imageURL componentsSeparatedByString:@"?url="];
        if(explodeUrl.count<1 || [explodeUrl[1] isEqualToString:@""]){
            self.product.imageURL = nil;
            //UIImage *placeHolderImg = [SHPImageUtil scaleImage:[UIImage imageNamed:@"place-holder-salve-passaggio@2X.png"] toSize:CGSizeMake(self.tableView.frame.size.width,150)];
            self.productImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"place-holder-NO-IMAGE@2X.png"]];
        }else{
            detailImageURL = [[NSString alloc] initWithFormat:@"%@&w=%ld", self.product.imageURL, (long)self.view.frame.size.width];
            self.productImage = [[UIImageView alloc] initWithImage:[self.applicationContext.productDetailImageCache getImage:detailImageURL]];
        }
    }
    NSLog(@"startImageDownload %@:%@:%@",self.productImage.image, self.product.imageURL, detailImageURL);
    //----------------------------------------------------------------//
    if(self.product.shopLat && self.product.shopLon){
        [self getCityName];
    }
    
    if (loadingProductImage == NO && !self.productImage.image && detailImageURL) {
        [self startImageDownload];
    }
    //NSLog(@"initializeMapImage %d:%@",loadingImageMap,self.imageMap);
    if(loadingImageMap == NO && !self.imageMap){
        [self initializeMapImage];
    }
    //NSLog(@"loadProduct %d:%d",loadingProduct,loadedProduct);
    if(loadingProduct == NO && loadedProduct == NO){
        [self loadProduct];
    }
    //NSLog(@"setupShop %d:%d",loadingShop,loadedShop);
    if(loadingShop == NO && loadedShop == NO){
        [self setupShop];
    }
    //NSLog(@"initializeUserImage %d:%@",loadingImageUser,self.userImage);
    if(loadingImageUser == NO && !self.userImage){
        [self initializeUserImage];
    }
    
    
    if(loadingProductImage == NO && loadingImageMap == NO && loadingProduct == NO && loadingShop == NO && loadingImageUser == NO){
        contentProductsVC = [self.childViewControllers objectAtIndex:0];
        //contentProductsVC.delegate = self;
        SHPUser *authorProfile = [[SHPUser alloc] init];
        authorProfile.username = self.product.createdBy;
        authorProfile.photoImage = self.userImage;
        contentProductsVC.author = authorProfile;
        contentProductsVC.applicationContext = self.applicationContext;
        contentProductsVC.idProduct = self.product.oid;
        [contentProductsVC loadProducts];
        [self.tableView reloadData];
    }
    
    
}

-(void)setPhoneNumber{
    NSDictionary *properties = self.product.properties;
    NSDictionary *phoneDictionary = (NSDictionary *)[properties valueForKey:@"phone"];
    NSArray *values = (NSArray *)[phoneDictionary valueForKey:@"values"];
    if (values.count > 0) {
        self.product.phoneNumber = [values objectAtIndex:0];
    }
    self.product.phoneNumber = [self.product.phoneNumber stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    //NSLog(@"\n ------------------------ \n self.product.properties %@\n",self.product.properties);
}

-(void)setEmail{
    NSDictionary *properties = self.product.properties;
    NSDictionary *phoneDictionary = (NSDictionary *)[properties valueForKey:@"email"];
    NSArray *values = (NSArray *)[phoneDictionary valueForKey:@"values"];
    if (values.count > 0) {
        emailProduct = [[values objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    }
}

-(void)setNumberPlaces{
    NSDictionary *properties = self.product.properties;
    NSDictionary *phoneDictionary = (NSDictionary *)[properties valueForKey:@"posti"];
    NSArray *values = (NSArray *)[phoneDictionary valueForKey:@"values"];
    if (values.count > 0) {
       self.numberPlaces  = [values objectAtIndex:0];
    }
}

-(void)setPlan{
    NSDictionary *properties = self.product.properties;
    NSDictionary *planDictionary = (NSDictionary *)[properties valueForKey:@"orari"];
    NSArray *values = (NSArray *)[planDictionary valueForKey:@"values"];
    if (values.count > 0) {
        self.plan  = [values objectAtIndex:0];
    }
}

-(void)setRemainingTime{
    //NSLog(@"self.product.endDate:: %@",self.product.endDate);
    //if(self.product.endDate){
        NSDate *now = [[NSDate alloc] init];
        remainingTime = [SHPStringUtil differentBetweenDates:now endDate:(NSDate *)self.product.endDate];
    //}
}
//********************************************************************//
//START LOAD PRODUCTS AND DELEGATE productDC
//********************************************************************//
-(void)loadProduct {
    loadingProduct = YES;
    self.productDC = [[SHPProductDC alloc] init];
    self.productDC.delegate = self;
    //NSLog(@"loadProduct!!!!!! %@", self.productDC.delegate);
    [self.productDC searchById:self.product.oid location:self.applicationContext.lastLocation withUser:self.applicationContext.loggedUser];
}

//DELEGATE loaded
- (void)loaded:(NSArray *)products {
    loadingProduct = NO;
    loadedProduct = YES;
    self.productDC = nil;
    [self.refreshControl endRefreshing];
    if (products.count > 0) {
        NSString *distanceToShop = self.product.distance;
        self.product = [products objectAtIndex:0];
        [self setPhoneNumber];
        [self setEmail];
        [self setNumberPlaces];
        [self setPlan];
        [self setRemainingTime];

        if(![self.product.distance isEqualToString:distanceToShop]){
            self.product.distance = distanceToShop;
        }
        NSDictionary *arrayOidTypeCategories = (NSDictionary *)[self.applicationContext getVariable:DICTIONARY_CATEGORIES];
        self.product.categoryType=[arrayOidTypeCategories valueForKey:self.product.category];
        [self initialize];
    }
}
//********************************************************************//
//END LOAD PRODUCT AND DELEGATE productDC
//********************************************************************//

//********************************************************************//
//START DELETE PRODUCT AND DELEGATE SHPProductDeleteDC
//********************************************************************//
-(void)deleteProduct {
    //NSLog(@"deleteProduct!!!!!! %@", self.product.oid);
    [self showWaiting];
    productDeleteDC = [[SHPProductDeleteDC alloc] init];
    productDeleteDC.delegate = self;
    [productDeleteDC deleteProduct:self.product.oid withUser:self.applicationContext.loggedUser];
}

//DELEGATE SHPProductDeleteDC
-(void)productDeleted:(NSString *)responce {
    [self hideWaiting];
    [self performSegueWithIdentifier: @"unwindToProductsVC" sender: self];
}

-(void)networkError {
    //NSLog(@"Network Error loading product!");
    [self hideWaiting];
    [self.refreshControl endRefreshing];
    NSString *title = NSLocalizedString(@"NetworkErrorTitleLKey", nil);
    NSString *msg = NSLocalizedString(@"NetworkErrorLKey", nil);
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alertView.tag = 0;
    [alertView show];
}
//********************************************************************//
//END DELETE PRODUCT AND DELEGATE SHPProductDeleteDC
//********************************************************************//


//********************************************************************//
//START LOAD SHOP AND DELEGATE shopDC
//********************************************************************//
-(void)setupShop {
    if(self.product.shop && ![self.product.shop isEqualToString:@""]){
        loadingShop = YES;
        self.shopDC = [[SHPShopDC alloc] init];
        [self.shopDC setShopsLoadedDelegate:self];
        //NSLog(@"self.product.shop!!!!!! %@", self.product);
        [self.shopDC searchByShopId:self.product.shop];
    }
}

//DELEGATE setupShop
- (void)shopsLoaded:(NSArray *)shops {
    loadingShop = NO;
    loadedShop = YES;
    //NSLog(@"shops!!!!!! %@", shops);
    //NSLog(@"SHOP LOADED!!!!!!!!..............: %lu", (unsigned long)[shops count]);
    if(shops.count > 0) {
        self.shop = [shops objectAtIndex:0];
        [self.applicationContext.objectsCache addObject:self.shop withKey:self.shop.oid];
        [self initialize];
    } else {
        //NSLog(@"Shop not found!");
    }
}
//********************************************************************//
//START LOAD SHOP AND DELEGATE shopDC
//********************************************************************//

//********************************************************************//
//START LIKE DELEGATE likeDC
//********************************************************************//
-(void)updateLike
{
    likeDC = [[SHPLikeDC alloc] init];
    likeDC.likeDelegate = nil;
    SHPProduct *theProduct = self.product;
    NSString *oid = theProduct.oid;
    SHPLikeDC *oldLikeTask = [self.likesInProgress objectForKey:oid];
    if (oldLikeTask) {
        [oldLikeTask cancelConnection];
        [self.likesInProgress removeObjectForKey:oid];
    } else {
        //NSLog(@"OLD LIKE TASK NOT FOUND!");
    }
    // now add the new task
    [self.likesInProgress setObject:likeDC forKey:oid];
    if(theProduct.userLiked) {
        self.product.likesCount--;
        [likeDC unlike:theProduct withUser:self.applicationContext.loggedUser];
        //[self showLikeHUD:NO];
        [buttonLike setImage:[UIImage imageNamed:@"icon_like_red_60X60"] forState:UIControlStateNormal];
    } else {
        //NSLog(@"was Like changing to Unlike");
        self.product.likesCount++;
        [likeDC like:self.product withUser:self.applicationContext.loggedUser];
        //[self showLikeHUD:YES];
        [buttonLike setImage:[UIImage imageNamed:@"icon_like_white_60X60"] forState:UIControlStateNormal];
        [self animateLike];
    }
    [self.tableView reloadData];
    theProduct.userLiked = !theProduct.userLiked;
}

-(void)animateLike {
    POPSpringAnimation *sprintAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
    sprintAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.4, 1.4)];
    sprintAnimation.springBounciness = 20.f;
    sprintAnimation.autoreverses = YES;
    [buttonLike pop_addAnimation:sprintAnimation forKey:@"springAnimation"];
}

//DELEGATE
-(void)likeDCErrorForProduct:(SHPProduct *)product withCode:(NSString *)code{}
//********************************************************************//
//START LOAD SHOP AND DELEGATE shopDC
//********************************************************************//


//---------------------------------------------------------------//
//------------ START LOAD IMAGE
//---------------------------------------------------------------//

- (void)startImageDownload {
    loadingProductImage = YES;
    NSLog(@"startImageDownload................. %@", detailImageURL);
    self.progressView.hidden = NO;
    self.progressView.progress = 0.1;
    SHPImageRequest *imageRequest = [[SHPImageRequest alloc] init];
            imageRequest.progressView = self.progressView;
            __weak SHPProductDetail *weakSelf = self;
            [imageRequest downloadImage:detailImageURL
                   completionHandler:
            ^(UIImage *image, NSString *imageURL, NSError *error) {
              if (image) {
                  [weakSelf.applicationContext.productDetailImageCache addImage:image withKey:detailImageURL];
                  weakSelf.product.image = image;
                  self.productImage.image = image;
                  //NSLog(@"reloadData................startImageDownload %@", self.productImage.image);
                  weakSelf.progressView.hidden = YES;
                  loadingProductImage = NO;
                  [weakSelf initialize];
                  //[weakSelf.tableView reloadData];
              } else {
                   //NSLog(@"!image");
                  loadingProductImage = NO;
                  //[weakSelf initialize];
                  [weakSelf.tableView reloadData];
                  // put an image that indicates "no image profile"
              }

     }];
}
//---------------------------------------------------------------//
//------------ END LOAD IMAGE
//---------------------------------------------------------------//

-(void)initializeMapImage {
    if(self.product.shopLat && self.product.shopLon){
        NSString *location = [[NSString alloc] initWithFormat:@"%f,%f", self.product.shopLat, self.product.shopLon];
        urlImgPoiMap = [[NSString alloc] initWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?center=%@&zoom=16&size=640x300&maptype=roadmap&markers=color:blue|label:|%@",location,location];
        if(![self.applicationContext.productDetailImageCache getImage:urlImgPoiMap]) {
            self.imageMap = nil;
            [self startImageMap:urlImgPoiMap];
        } else {
            self.imageMap = [self.applicationContext.productDetailImageCache getImage:urlImgPoiMap];;
        }
    }
}


- (void)startImageMap:(NSString*)mapImageURL {
    loadingImageMap = YES;
    //NSLog(@"startImageMap................. %@", mapImageURL);
    mapImageURL = [mapImageURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    SHPImageRequest *imageRequest = [[SHPImageRequest alloc] init];
    __weak SHPProductDetail *weakSelf = self;
    [imageRequest downloadImage:mapImageURL
              completionHandler:
     ^(UIImage *image, NSString *imageURL, NSError *error) {
         if (image) {
             [weakSelf.applicationContext.productDetailImageCache addImage:image withKey:imageURL];
             weakSelf.imageMap = image;
             loadingImageMap = NO;
             
             //[weakSelf.tableView reloadData];
             //NSLog(@"reloadData................startImageMap ");
            [weakSelf initialize];
         } else {
             //NSLog(@"reloadData..........startImageMap error: %@", error);
             loadingImageMap = NO;
             //[weakSelf initialize];
             [weakSelf.tableView reloadData];
         }
     }];
}

-(void)initializeUserImage {
    NSString *userPhotoURL = [SHPUser photoUrlByUsername:self.product.createdBy];
    if(![self.applicationContext.smallImagesCache getImage:userPhotoURL]) {
        self.userImage = nil;
        [self startImageUser:userPhotoURL];
    } else {
        self.userImage = [self.applicationContext.smallImagesCache getImage:userPhotoURL];
    }
}

-(void)startImageUser:(NSString*)userPhotoURL {
    loadingImageUser = YES;
    SHPImageRequest *imageRequest = [[SHPImageRequest alloc] init];
    __weak SHPProductDetail *weakSelf = self;
    //[self.imageDownloadsInProgress setObject:imageRequest forKey:userPhotoURL];
    [imageRequest downloadImage:userPhotoURL
              completionHandler:
     ^(UIImage *image, NSString *imageURL, NSError *error) {
         if (image) {
             [self.applicationContext.smallImagesCache addImage:image withKey:imageURL];
             weakSelf.userImage = image;
             //NSLog(@"reloadData......startImageUser");
             loadingImageUser = NO;
            [weakSelf initialize];
             //[weakSelf.tableView reloadData];
         } else {
             //NSLog(@"reloadData..........error: %@", error);
             loadingImageUser = NO;
             //[weakSelf initialize];
             [weakSelf.tableView reloadData];
         }
     }];
}

//----------------------------------------------------------//
//START GESTIONE MENU
//----------------------------------------------------------//

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            //NSLog(@"Conferma");
            if(actionSheet.tag == 0){
                //NSLog(@"Reload");
                [self initialize];
            }
            else if(actionSheet.tag == 1){
                //NSLog(@"Deleting");
                [self deleteProduct];
            }
            break;
        }
        case 1:
        {
            //NSLog(@"Annulla");
            break;
        }
    }
}
//----------------------------------------------------------//
//END GESTIONE MENU
//----------------------------------------------------------//


//----------------------------------------------------------//
//START FUNZIONI VIEW
//----------------------------------------------------------//

-(void)imageTap {
    if (!self.productImage.image) {
        return;
    }
    //SHPImageDetailViewController *imageController = [[SHPImageDetailViewController alloc] initWithNibName:@"toImageDetail" bundle:nil];
    //vc.image = self.product.image;
    //[self displayViewController:imageController];
    [self performSegueWithIdentifier: @"toImageDetail" sender: self];
}

-(void)showWaiting {
    if (!self.hud) {
        self.hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        [self.view.window addSubview:self.hud];
    }
    //hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"first.png"]];
    //hud.mode = MBProgressHUDModeCustomView;
    //self.hud.labelText = NSLocalizedString(@"RegisteringLKey", nil);
    self.hud.center = self.view.center;
    
    self.hud.animationType = MBProgressHUDAnimationZoom;
    [self.hud show:YES];
}

-(void)hideWaiting {
    [self.hud hide:YES];
}

-(void)callTelephone{
    if(self.product.phoneNumber!=nil && self.product.phoneNumber.length>0){
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:self.product.phoneNumber];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

-(void)sendEmail {
    NSString *url = [NSString stringWithFormat:@"mailto:%@", emailProduct];
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

//-(void)sendMessage {
//    int chat_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController" context:self.applicationContext];
//    // move to the converstations tab
//    if (chat_tab_index >= 0) {
//        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
//        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
//        NSArray *controllers = [tabController viewControllers];
//        ChatRootNC *nc = [controllers objectAtIndex:chat_tab_index];
//        SHPConversationsVC *vc = nc.viewControllers[0];
//        if (vc.presentedViewController) {
//            NSLog(@"THERE IS A MODAL PRESENTED! NOT SWITCHING TO ANY CONVERSATION VIEW.");
//        } else {
//            NSLog(@"SWITCHING TO CONVERSATION VIEW. DISABLED.");
//            // IF YOU ENABLE THIS IS MANDATORY TO FIND A WAY TO DISMISS OR HANDLE THE CURRENT MODAL VIEW
//            [nc popToRootViewControllerAnimated:NO];
//            [vc openConversationWithRecipient:self.product.createdBy];
//            tabController.selectedIndex = chat_tab_index;
//        }
//    }
//}

-(void)sendMessage:(NSString *)message toUser:(NSString *)user {
    
    // user = self.product.createdBy
    
    // ANDREBBE INSERITO NELL’APPLICATION-CONTEXT
    int chat_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController" context:self.applicationContext];
    NSLog(@"chat tab index %d", chat_tab_index);
    // move to the converstations tab
    if (chat_tab_index >= 0) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
        NSArray *controllers = [tabController viewControllers];
        ChatRootNC *nc = [controllers objectAtIndex:chat_tab_index];
        NSLog(@"nc:: %@", nc);
        [nc popToRootViewControllerAnimated:NO];
        [nc openConversationWithRecipient:user sendText:message];
        tabController.selectedIndex = chat_tab_index;
    }
}

/*
-(void)sendMessage {
    // find conversations tab
    NSDictionary *tabBarDictionary = [self.applicationContext.plistDictionary objectForKey:@"BarTab"];
    NSArray *tabBarMenuItems = [tabBarDictionary objectForKey:@"Menu"];
    
    NSInteger messages_tab_index = -1;
    int index = 0;
    for (NSDictionary *tabBarConfig in tabBarMenuItems) {
        NSString *StoryboardControllerID = [tabBarConfig objectForKey:@"StoryboardControllerID"];
        NSLog(@"StoryboardControllerID: %@", StoryboardControllerID);
        if ([StoryboardControllerID isEqualToString:@"ChatController"]) {
            messages_tab_index = index;
        }
        index++;
    }
    
    // move to the converstations tab
    if (messages_tab_index >= 0) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
        NSArray *controllers = [tabController viewControllers];
        UINavigationController *nc = [controllers objectAtIndex:messages_tab_index];
        
        SHPConversationsVC *conversationsVC = [[nc viewControllers] objectAtIndex:0];
        // reset the view controller to root view
        [conversationsVC.navigationController popToRootViewControllerAnimated:NO];
        conversationsVC.selectedRecipient = self.product.createdBy;
        tabController.selectedIndex = messages_tab_index;
        //        [conversationsVC openConversationWithUser:self.user.username];
        
    }
}
*/
-(void)getCityName{
    if (!geocoder) {
        geocoder = [[CLGeocoder alloc] init];
    }
    CLLocation *locationProduct = [[CLLocation alloc] initWithLatitude:self.product.shopLat longitude:self.product.shopLon];
    [geocoder reverseGeocodeLocation:locationProduct
                        completionHandler:^(NSArray *placemarks, NSError *error) {
                            if (error) {
                                NSLog(@"Geocode failed with error: %@", error);
                                return;
                            }
                            if(placemarks && placemarks.count > 0) {
                                //do something
                                CLPlacemark *topResult = [placemarks objectAtIndex:0];
                                NSString *addressTxt = [NSString stringWithFormat:@"%@", [topResult locality]];
                                if ([CLLocationManager locationServicesEnabled] == NO) {
                                    NSLog(@"locationServicesEnabled NO");
                                }
                                cityProduct = addressTxt;
                                [self.tableView reloadData];
                            }
                        }];
}

//----------------------------------------------------------//
//END FUNZIONI VIEW
//----------------------------------------------------------//


//----------------------------------------------------------//
//START TABLEVIEW
//----------------------------------------------------------//
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
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if([cell.reuseIdentifier isEqualToString:@"idAdvertising"]) {
        return 0;
//        if(publicUpload == NO){
//            return 0;
//        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idZoomImage"]) {
        if((self.productImage.image || loadingProductImage == YES) && self.product.imageURL){
            CGSize intoSize = CGSizeMake(self.applicationContext.settings.mainListImageWidth, self.applicationContext.settings.mainListImageHeight);
            CGSize resized = [SHPImageUtil imageSizeForProduct:self.product constrainedInto:intoSize];
//            NSLog(@"RESIZE IMAGE");// ----------------
            return resized.height;
        }else{
            self.progressView.hidden = YES;
            return 150.0;
            //return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idLike"]) {
//        if(!self.productImage.image && loadingProductImage == NO){
            return 0;
//        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idPrice"]) {
//        if(!self.product.price || [self.product.price isEqualToString:@""]){
//            return 0;
//        }
        return 0;
    }
    if([cell.reuseIdentifier isEqualToString:@"idRemainingTime"]) {
        //NSLog(@"---------> remainingTime: %@",remainingTime);
        if(!remainingTime || [remainingTime isEqualToString:@""]){
            return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idShowLink"]) {
        return 44*arrayUrlsDescription.count;
    }
    if([cell.reuseIdentifier isEqualToString:@"idTitle"]) {
        if(!self.product.title || [self.product.title isEqualToString:@""]){
            return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idDescription"]) {
        if(!descriptionClean || [descriptionClean isEqualToString:@""]){
            return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idDate"]) {
        if(!self.product.startDate || !self.product.endDate || [self.product.endDate isEqualToDate:self.product.endDate]){
            return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idTelephon"]) {
        if(!self.product.phoneNumber || self.product.phoneNumber.length<=0){
            return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idEmail"]) {
        if(!emailProduct || emailProduct.length<=0){
            return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idCart"]) {
        return 0;
    }
    
    if([cell.reuseIdentifier isEqualToString:@"idShopDetail"]) {
        if(hideShop == YES || [self.product.shop isEqualToString:@""]){//|| !self.product.shopLat || !self.product.shopLon){
            return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idSearchNear"]) {
        if(hideShop == YES || (loadingImageMap == NO && !self.imageMap)){
            return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idShowOnMap"]) {
        if(hideMap == YES || (loadingImageMap == NO && !self.imageMap)){
            return 0;
        }
        return 150;
    }
    if([cell.reuseIdentifier isEqualToString:@"idCity"]) {
        if(hideCity == YES || !cityProduct || [cityProduct isEqualToString:@""] ){
            return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idAddress"]) {
        if(hideAddress == YES || !self.product.shop || [self.product.shop isEqualToString:@""] ){
            return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idProfile"]) {
        if(hideAuthor == YES){
            return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idChat_old"]) {
        return 0;
    }
    if([cell.reuseIdentifier isEqualToString:@"idContainer"]) {
        //NSLog(@"idContainer %d - %d",hideAuthor,self.hideOtherProducts);
        if(hideAuthor == YES || self.hideOtherProducts == YES){
            return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idMultiStore"]) {
        if(multiStore == NO){
            return 0;
        }
    }
    if([cell.reuseIdentifier isEqualToString:@"idAddCart"]){
        return 0;
    }
    
    if([cell.reuseIdentifier isEqualToString:@"idPriceSubUnitario"]){
        return 0;
    }
    if([cell.reuseIdentifier isEqualToString:@"idPriceRivenditore"]){
        return 0;
    }
    
    if([cell.reuseIdentifier isEqualToString:@"idEditPlaces"]) {
        if ([self.product.category hasSuffix:@"/parcheggi"] && ([self.applicationContext.loggedUser.username isEqualToString:self.product.createdBy] || self.applicationContext.loggedUser.canUploadProducts == YES)){
            //self.applicationContext.loggedUser.canUploadProducts) {
        }else{
            return 0;
        }
    }
    
    if([cell.reuseIdentifier isEqualToString:@"idEditPlan"]) {
        if ([self.product.category hasSuffix:@"/dae"] && ([self.applicationContext.loggedUser.username isEqualToString:self.product.createdBy] || self.applicationContext.loggedUser.canUploadProducts == YES)){
            //self.applicationContext.loggedUser.canUploadProducts) {
        }else{
            return 0;
        }
    }
    
    if([cell.reuseIdentifier isEqualToString:@"idViewPlan"]) {
        if(!self.plan || self.plan.length<=0){
            return 0;
        }else{
            return 80;
        }
    }

    if([cell.reuseIdentifier isEqualToString:@"idNumberPlaces"]) {
        if (![self.product.category hasSuffix:@"/parcheggi"]){
            return 0;
        }
    }
    
    

    if([cell.reuseIdentifier isEqualToString:@"idLastCell"]) {
         if (![self.applicationContext.loggedUser.username isEqualToString:self.product.createdBy] && hideReport == YES) {
            return 0;
        }
    }
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier;
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    CellIdentifier = cell.reuseIdentifier;
    //NSLog(@"cellForRowAtIndexPath:(NSIndexPath *)indexPath : %d - %@",(int)indexPath.row, CellIdentifier);
    //IMAGE
    if([CellIdentifier isEqualToString:@"idAdvertising"]) {
        UILabel *labelMessage = (UILabel *)[cell viewWithTag:10];
        UILabel *labelPlus = (UILabel *)[cell viewWithTag:11];
        labelPlus.layer.cornerRadius = 20;
        labelPlus.layer.borderWidth = 1.0f;
        labelPlus.layer.borderColor = [[UIColor whiteColor] CGColor];
        //labelPlus.layer.borderColor = (__bridge CGColorRef _Nullable)([UIColor whiteColor]);
        labelMessage.text = NSLocalizedString(@"labelAdvertising", nil);
    }
    else if([CellIdentifier isEqualToString:@"idZoomImage"]) {
        if(self.productImage.image){
            UIImageView *imageDetail = (UIImageView *)[cell viewWithTag:10];
            imageDetail.alpha = 1.0;
            imageDetail.image = self.productImage.image;
        }
        buttonLike = (UIButton *)[cell viewWithTag:11];
        if(self.product.userLiked) {
            [buttonLike setImage:[UIImage imageNamed:@"icon_like_red_60X60"] forState:UIControlStateNormal];
        }else{
            [buttonLike setImage:[UIImage imageNamed:@"icon_like_white_60X60"] forState:UIControlStateNormal];
        }
        UIView *boxPrice = (UIView *)[cell viewWithTag:12];
        UILabel *price = (UILabel *)[cell viewWithTag:13];
        UILabel *valuta = (UILabel *)[cell viewWithTag:14];
        if(self.product.price && ![self.product.price isEqualToString:@""]){
            NSString *trimmedPrice = [self.product.price stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *currency = self.product.currency ? NSLocalizedString(self.product.currency, nil) : NSLocalizedString(@"euro", nil);
            if ([trimmedPrice isEqualToString:@"0.0"]) {
                price.text = [[NSString alloc] initWithFormat:@"%@",NSLocalizedString(@"freePriceLKey", nil)];
                valuta.hidden = YES;
            }
            else {
                price.text = [NSString stringWithFormat:@"%.2f",[trimmedPrice floatValue]];
                valuta.text = [NSString stringWithString:currency];
            }
        }else{
            [boxPrice setHidden:YES];
        }
    }

    //LIKE & LIKED
    else if([CellIdentifier isEqualToString:@"idLike"]) {
        UILabel *labelLiked = (UILabel *)[cell viewWithTag:10];
        NSString *persone = [NSString stringWithString:NSLocalizedString(@"PeopleLKey", nil)];
        if(self.product.likesCount == 1){
            persone = [NSString stringWithString:NSLocalizedString(@"PersonLKey", nil)];
        }
        NSString *countLiked =[NSString stringWithFormat:@"%@ %ld %@", NSLocalizedString(@"LikeToLKey", nil),(long)self.product.likesCount, persone];
        labelLiked.text = countLiked;
    }

    // LABEL PRICE
    else if([CellIdentifier isEqualToString:@"idPrice"]) {
        UILabel *labelDeal = (UILabel *)[cell viewWithTag:10];
        UILabel *labelStartPrice = (UILabel *)[cell viewWithTag:11];
        UILabel *labelPrice = (UILabel *)[cell viewWithTag:12];
        float price_num = 0.00;
        float start_price_num = 0.00;
        NSString *currency = self.product.currency ? NSLocalizedString(self.product.currency, nil) : NSLocalizedString(@"euro", nil);
        NSString *trimmedPrice = [self.product.price stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if(!self.product.price || [self.product.price isEqualToString:@""]){
            labelPrice.hidden = YES;
            labelStartPrice.hidden = YES;
        }
        else if ([trimmedPrice isEqualToString:@"0.0"]) {
            labelPrice.text = [[NSString alloc] initWithFormat:@"%@",NSLocalizedString(@"freePriceLKey", nil)];
            labelPrice.hidden = NO;
            labelStartPrice.hidden = YES;
        }
        else {
            labelPrice.text = [NSString stringWithFormat:@"%.2f%@",[trimmedPrice floatValue],currency];
            labelPrice.hidden = NO;
            price_num = [trimmedPrice floatValue];
            
            NSString *trimmedStartPrice = [self.product.startprice stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if (!self.product.startprice || [trimmedStartPrice isEqualToString:@""]){
                labelStartPrice.hidden = YES;
            }
            else if ([trimmedStartPrice isEqualToString:@"0.0"] || [trimmedStartPrice isEqualToString:trimmedPrice]) {
                labelStartPrice.hidden = YES;
            }
            else{
                NSString *startPrice = [[NSString alloc] initWithFormat:@"%@ %.2f",currency, [trimmedStartPrice floatValue]];
                labelStartPrice.text = startPrice;
                labelStartPrice.hidden = NO;
                labelStartPrice.attributedText = [SHPStringUtil strikethroughText:startPrice color:[SHPImageUtil colorWithHexString:@"555555"]];
                start_price_num = [trimmedStartPrice floatValue];
            }
        }
        
        //LABEL DEAL PERCENT
        labelDeal.text = @"";
        if(start_price_num>0 && price_num>0 && price_num!=start_price_num){
            float perc = (1-(price_num/start_price_num))*100;
            int percRound = (int) round(perc);
            float sconto = ([self.product.startprice floatValue] - [self.product.price floatValue]);
            //NSString *trimmedStartPrice = [sconto stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *startPrice = [[NSString alloc] initWithFormat:@" (%@%.2f)",currency, sconto];
            labelDeal.text = [NSString stringWithFormat:NSLocalizedString(@"%d%% %@ %@",nil), percRound, NSLocalizedString(@"di sconto",nil), startPrice];
        }
    }

    //REMAINING TIME
    else if([CellIdentifier isEqualToString:@"idRemainingTime"]) {
        UILabel *labelHeaderRemainingTime = (UILabel *)[cell viewWithTag:10];
        UILabel *labelRemainingTime = (UILabel *)[cell viewWithTag:11];
        labelHeaderRemainingTime.text = @"";
        //NSDate *now = [[NSDate alloc] init];
        //remainingTime=[SHPStringUtil differentBetweenDates:now endDate:(NSDate *)self.product.endDate];
        
        if(![remainingTime isEqualToString:@""] && remainingTime){
            labelHeaderRemainingTime.text = [NSString stringWithFormat:NSLocalizedString(@"remaining_time",nil)];
            labelRemainingTime.text = [[NSString alloc] initWithFormat:@"%@", remainingTime];
        }else if(self.product.endDate){
//            remainingTime = [NSString stringWithString:  NSLocalizedString(@"ScadutoLKey", nil)];
//            labelRemainingTime.text = [[NSString alloc] initWithFormat:@"%@", remainingTime];
        }
        
    }

    //TITLE
    else if([CellIdentifier isEqualToString:@"idTitle"]) {
        UILabel *textLabel = (UILabel *)[cell viewWithTag:10];
        //NSLog(@"title: %@",self.product.title);
        textLabel.text = self.product.title;
    }
    
    // DESCRIPTION LABEL
    else if([CellIdentifier isEqualToString:@"idDescription"]) {
        UITextView *textDescription = (UITextView *)[cell viewWithTag:10];
        //NSString *descriptionClean = [SHPStringUtil cleanTextFromUrls:self.product.longDescription];
        textDescription.text = descriptionClean;
        [textDescription sizeToFit];
        //heightDescription = textDescription.layer.frame.size.height+textDescription.frame.origin.y*2;
        //NSLog(@"maxSize: %d - %d",(int)heightDescription, (int)textDescription.frame.size.height);
    }
    //END DESCRIPTION LABEL


    //DESCRIPTION SHOW LINK
    else if([CellIdentifier isEqualToString:@"idShowLink"]){
        //NSLog(@"idShowLink: %d",(int)arrayUrlsDescription.count);
        for(UIView *subview in cell.contentView.subviews)
        {
            [subview removeFromSuperview];
        }
        UIView *separatore = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
        [separatore setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        separatore.tag = 10;
        [cell.contentView addSubview:separatore];
        for (int i=0; i<(int)arrayUrlsDescription.count; i++) {
            UIButton *buttonLink = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [buttonLink setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
            buttonLink.tag = i;
            [buttonLink addTarget:self action:@selector(openUrlInBrowser:) forControlEvents:UIControlEventTouchUpInside];
            NSArray *url = [SHPStringUtil extractUrl:arrayUrlsDescription[i]];
            if(url.count>1){
                [buttonLink setTitle:(NSString *)url[1] forState:UIControlStateNormal];
            }else{
                [buttonLink setTitle:(NSString *)url[0] forState:UIControlStateNormal];
            }
            int posY = 44*i;
            UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(5, posY+4, 36, 36)];
            imgView.image = [UIImage imageNamed:@"ico_poi_sito.png"];
            [imgView setContentMode:UIViewContentModeScaleAspectFit];
            imgView.tag = i;
            [cell.contentView addSubview:imgView];
            
            buttonLink.frame = CGRectMake(45, posY, self.view.frame.size.width-90, 44);
            [cell.contentView addSubview:buttonLink];
            
            int posX = self.view.frame.size.width-30;
            UIImageView *imgViewArrow = [[UIImageView alloc] initWithFrame:CGRectMake(posX, posY+12, 20, 20)];
            imgViewArrow.image = [UIImage imageNamed:@"button_navbar_disabled.png"];
            [imgViewArrow setContentMode:UIViewContentModeScaleAspectFit];
            imgViewArrow.tag = i;
            [cell.contentView addSubview:imgViewArrow];
            
            UIView *separatore = [[UIView alloc] initWithFrame:CGRectMake(0, posY+43, self.view.frame.size.width, 1)];
            [separatore setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
            separatore.tag = i;
            [cell.contentView addSubview:separatore];
        }
    }

    //DATE
    else if([CellIdentifier isEqualToString:@"idDate"]){
        UILabel *labelStartEndDate = (UILabel *)[cell viewWithTag:10];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZZ";
        NSDate *dateStart = [dateFormatter dateFromString:@"1970-01-01 00:00:00 +0000"];
        NSDate *dateEnd = [dateFormatter dateFromString:@"2927-12-31 23:00:00 +0000"];
        if(![self.product.startDate isEqualToDate:dateStart] || ![self.product.endDate isEqualToDate:dateEnd]){
            //self.labelHeaderDate.text = NSLocalizedString(@"validLKey", nil);
            NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"dd MMMM"];
            [dateFormat setTimeZone:[NSTimeZone localTimeZone]];
            NSString *dateStart = [[dateFormat stringFromDate:self.product.startDate] capitalizedString];
            NSString *dateEnd = [[dateFormat stringFromDate:self.product.endDate] capitalizedString];
            //NSLog(@"Data inizio %@, data fine %@",self.product.startDate,self.product.endDate);
            labelStartEndDate.text = @"";
            if([self.product.startDate isEqual:self.product.endDate ]){
                //NSLog(@"DATE uguali");
                labelStartEndDate.text = [[NSString alloc] initWithFormat:@"%@ ",dateStart];
            }else if(self.product.endDate==nil){
                //NSLog(@"end data null");
                labelStartEndDate.text = [[NSString alloc] initWithFormat:@"%@ %@",NSLocalizedString(@"fromLKey", nil),dateStart];
            }else{
                //NSLog(@"date diverse");
                NSString *labelDurate = [[NSString alloc] initWithFormat:@"%@ %@ %@ %@",NSLocalizedString(@"fromLKey", nil),dateStart,NSLocalizedString(@"toLKey", nil),dateEnd];
                [SHPUserInterfaceUtil applyTitleString:(NSString *)labelDurate toAttributedLabel:labelStartEndDate];
            }
        }
    }
    //END DATE

    //CELL PHONE
    else if([CellIdentifier isEqualToString:@"idTelephon"]){
        UILabel *labelChiama = (UILabel *)[cell viewWithTag:11];
        UILabel *labelNumberTelephon = (UILabel *)[cell viewWithTag:12];
        labelChiama.text = [NSString stringWithString:NSLocalizedString(@"labelChiama", nil)];
        
        UIImageView *imgCall = (UIImageView *)[cell viewWithTag:10];
        imgCall.layer.cornerRadius = imgCall.frame.size.height/2;
        imgCall.layer.borderWidth = 0;
        //imgCall.image = [imgCall.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        //[imgCall setTintColor:[UIColor darkGrayColor]];
        if(self.product.phoneNumber==nil || self.product.phoneNumber.length<1){
            imgCall.alpha = 0.5;
            labelNumberTelephon.text = [NSString stringWithString:NSLocalizedString(@"labelTelephoNotAvailable", nil)];
        } else {
            imgCall.alpha = 1.0;
            labelNumberTelephon.text = [NSString stringWithString:self.product.phoneNumber];
        }
    }
    //END CELL PHONE
    
    //CELL EMAIL
    else if([CellIdentifier isEqualToString:@"idEmail"]){
        UILabel *labelEmail= (UILabel *)[cell viewWithTag:11];
        labelEmail.text = [NSString stringWithString:NSLocalizedString(@"labelEmail", nil)];
        UIImageView *imgCall = (UIImageView *)[cell viewWithTag:10];
        imgCall.layer.cornerRadius = imgCall.frame.size.height/2;
        imgCall.layer.borderWidth = 0;
        imgCall.image = [imgCall.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [imgCall setTintColor:[UIColor darkGrayColor]];
    }
    //END CELL EMAIL

    
    //CELL CHAT
    else if([CellIdentifier isEqualToString:@"idChat"]){
        UIImageView *imgChat = (UIImageView *)[cell viewWithTag:10];
        UILabel *labelChatta = (UILabel *)[cell viewWithTag:11];
        labelChatta.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"labelOfferta", nil), self.product.createdBy];
//        imgChat.layer.cornerRadius = imgChat.frame.size.height/2;
//        imgChat.layer.borderWidth = 0;
        imgChat.image = [imgChat.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [imgChat setTintColor:[UIColor blackColor]];
    }
    //END CELL CHAT

    //SHOP
    else if([CellIdentifier isEqualToString:@"idShopDetail"]){
        //UILabel *labelCity = (UILabel *)[cell viewWithTag:10];
        UILabel *labelShopName = (UILabel *)[cell viewWithTag:11];
        UILabel *labelDistanceToYou = (UILabel *)[cell viewWithTag:12];
        labelDistanceToYou.text = @"";
        labelShopName.text = self.product.shopName;
        //labelCity.text = self.product.city;
        //NSLog(@"::: PRODUCT DISTANCE ::: %@",self.product.distance);
        if(self.product.distance){
            self.shop.distance = [self.product.distance intValue];
            labelDistanceToYou.text = [[NSString alloc] initWithFormat:@"%@ %@ %@ %@",self.product.city, NSLocalizedString(@"toKey", nil), self.product.distance, NSLocalizedString(@"labelDaTe", nil)];
        }
    }
    
    //MAP
    else if([CellIdentifier isEqualToString:@"idShowOnMap"]){
        UIImageView *imageViewMap = (UIImageView *)[cell viewWithTag:10];
        imageViewMap.image = self.imageMap;
//        if(self.imageMap){
//            imageViewMap.image = self.imageMap;
//        }else if(loadingImageMap == NO){
//            [self startImageMap:urlImgPoiMap];
//        }
    }
    
    //CITY
    else if([CellIdentifier isEqualToString:@"idCity"]){
        UILabel *labelCity = (UILabel *)[cell viewWithTag:10];
        labelCity.text=@"";
        if(cityProduct){
            labelCity.text = cityProduct;
        }
    }
    
    //ADDRESS
    else if([CellIdentifier isEqualToString:@"idAddress"]){
        UILabel *addressLabel = (UILabel *)[cell viewWithTag:10];
        addressLabel.text=@"";
        if(self.shop.formattedAddress){
            addressLabel.text = self.shop.formattedAddress;
        }
    }
    
    //MULTISTORE
    else if([CellIdentifier isEqualToString:@"idMultiStore"]){
        UILabel *labelMultiStore = (UILabel *)[cell viewWithTag:11];
        labelMultiStore.text = NSLocalizedString(@"multiStoreLKey", nil);
    }
    
    //AUTHOR
    else if([CellIdentifier isEqualToString:@"idProfile"]){
        UIImageView *userImageV = (UIImageView *)[cell viewWithTag:10];
        UILabel *labelUploadBy = (UILabel *)[cell viewWithTag:11];
        UILabel *labelNameProfile = (UILabel *)[cell viewWithTag:12];
        //NSLog(@"ID PROFILE IMAGE: %@",self.userImage);
        if(self.userImage){
            userImageV.image = self.userImage;
        }
        //userImageV.layer.borderWidth = 2;
        //userImageV.layer.borderColor=[[UIColor whiteColor] CGColor];
        userImageV.layer.cornerRadius = userImageV.frame.size.height/2;
        //userImageV.layer.masksToBounds = YES;
        
        labelNameProfile.text = self.product.createdBy;
        labelUploadBy.text = [[NSString alloc] initWithFormat:@"%@ %@ %@", NSLocalizedString(@"UploadedDateLKey", nil), [SHPStringUtil timeFromNowToString:self.product.createdOn], NSLocalizedString(@"byLKey", nil)];
    }
    
    //CONTAINER ALTRI POST AUTHOR
    else if([CellIdentifier isEqualToString:@"idContainer"]){
        UILabel *labelHeader = (UILabel *)[cell viewWithTag:10];
        labelHeader.text = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"OtherPosts", nil), self.product.createdBy];
    }
    
    //NUMBER PLACES
    else if([CellIdentifier isEqualToString:@"idNumberPlaces"]){
        UILabel *labelHeader = (UILabel *)[cell viewWithTag:10];
        NSString *label = [[NSString alloc] initWithFormat:@"%@: *%@*", NSLocalizedString(@"NumberPlacesAvailable", nil), self.numberPlaces];
        [SHPUserInterfaceUtil applyTitleString:label toAttributedLabel:labelHeader];
    }
    
    //ORARIO PLAN
    else if([CellIdentifier isEqualToString:@"idViewPlan"]){
        UILabel *labelHeader = (UILabel *)[cell viewWithTag:10];
        UILabel *labelText = (UILabel *)[cell viewWithTag:11];
        UIImageView *imageStatus = (UIImageView *)[cell viewWithTag:12];
        NSDate *dateNow = [NSDate date];
        NSDictionary *dictionaryPlan = [SHPPOIOpenStatus compile:self.plan];
        NSString *status;
        UIColor *itemColor;
        labelHeader.text = @"";
        if (dictionaryPlan) {
            BOOL isOpenNow = [SHPPOIOpenStatus isOpenForPlan:dictionaryPlan onDate:dateNow];
            if (isOpenNow) {
                NSLog(@"OPEN!");
                status = @"APERTO";
                itemColor = [SHPImageUtil colorWithHexString:@"56AE18"];
                labelText.text = @"";
                imageStatus.image = [UIImage imageNamed:@"icon_open"];
            } else {
                NSLog(@"CLOSED!");
                itemColor = [SHPImageUtil colorWithHexString:@"B20000"];
                status = @"CHIUSO";
                imageStatus.image = [UIImage imageNamed:@"icon_closed"];
                NSDate *next_open_hour = [SHPPOIOpenStatus nextOpenHourForPlan:dictionaryPlan onDate:dateNow];
                NSString *stringNextOpen = @"";
                if (next_open_hour) {
                    NSDateFormatter *hourFormatter = [[NSDateFormatter alloc] init];
                    [hourFormatter setDateFormat:@"HH:mm"];
                    stringNextOpen = [[NSString alloc] initWithFormat:@"apre alle *%@*", [hourFormatter stringFromDate:next_open_hour]];
                    NSLog(@"Next open hour: %@", [hourFormatter stringFromDate:next_open_hour]);
                } else {
                    NSDictionary *next_open_day_time = [SHPPOIOpenStatus nextOpenWeekDayForPlan:dictionaryPlan onDate:dateNow];
                    NSLog(@"next_open_day_time: %@", next_open_day_time);
                    NSInteger weekNumberDay = [[next_open_day_time valueForKey:@"weekday"] integerValue]-1;
                    NSString *weekDay = [SHPPOIOpenStatus returnWeekDay:weekNumberDay];
                    NSString *start = [next_open_day_time valueForKey:@"start"];
                    stringNextOpen = [[NSString alloc] initWithFormat:@"prossima apertura *%@* alle *%@*", weekDay, start];
                }
               [SHPUserInterfaceUtil applyTitleString:stringNextOpen toAttributedLabel:labelText];
            }
            labelHeader.textColor = itemColor;
            // NSString *label = [[NSString alloc] initWithFormat:@"*%@*", status];
            //[SHPUserInterfaceUtil applyTitleString:label toAttributedLabel:labelHeader];
        }
    }
    
    //EDIT PLACES
    else if([CellIdentifier isEqualToString:@"idEditPlaces"]){
        UILabel *labelHeader = (UILabel *)[cell viewWithTag:10];
        labelHeader.text = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"EditPlaces", nil)];
    }
    
    //EDIT PLAN
    else if([CellIdentifier isEqualToString:@"idEditPlan"]){
        UILabel *labelHeader = (UILabel *)[cell viewWithTag:10];
        labelHeader.text = [[NSString alloc] initWithFormat:@"%@", NSLocalizedString(@"EditPlan", nil)];
    }
    
    //LASTCELL
    else if([CellIdentifier isEqualToString:@"idLastCell"]){
        UILabel *labelAzione = (UILabel *)[cell viewWithTag:10];
        if ([self.applicationContext.loggedUser.username isEqualToString:self.product.createdBy]) {
            labelAzione.text = [[NSString alloc] initWithString:NSLocalizedString(@"DeleteProductLKey", nil)];
        }else{
            labelAzione.text = [[NSString alloc] initWithString:NSLocalizedString(@"ReportLKey", nil)];
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@" didSelectRowAtIndexPath identifier: %@",[cell reuseIdentifier]);
    NSString *identifierCell = [cell reuseIdentifier];   // The one we want to switch on
    
    if([identifierCell isEqualToString:@"idProfile"]){
        [self goToProfile];
    }
    else if([identifierCell isEqualToString:@"idAdvertising"]){
       [self goToWizard:CATEGORY_TYPE_COVER];
    }
    else if([identifierCell isEqualToString:@"idZoomImage"]){
        //[self imageTap];
    }
    else if([identifierCell isEqualToString:@"idShopDetail"]){
        //[self goToPoiDetail];
        [self performSegueWithIdentifier: @"toShopDetail" sender: self];
    }
    else if([identifierCell isEqualToString:@"idShowOnMap"]){
        NSLog(@"ShowOnMap2");
        [self performSegueWithIdentifier: @"ShowOnMap2" sender: self];
    }
    else if([identifierCell isEqualToString:@"idAddress"]){
        NSURL *testURL = [NSURL URLWithString:@"http://maps.apple.com/"];
        if ([[UIApplication sharedApplication] canOpenURL:testURL]) {
            NSString *sampleUrl = self.shop.formattedAddress;
            NSString *encodedUrl = [sampleUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *directionsRequest = [NSString stringWithFormat:@"http://maps.apple.com/?daddr=%@&directionsmode=driving&x-success=sourceapp://?resume=true&x-source=AirApp", encodedUrl];
            NSURL *directionsURL = [NSURL URLWithString:directionsRequest];
            [[UIApplication sharedApplication] openURL:directionsURL];
            //NSLog(@"url string: %@",directionsRequest);
        } else {
            NSLog(@"Can't use comgooglemaps-x-callback:// on this device.");
        }
        
    }
    else if([identifierCell isEqualToString:@"idShowLink"]){
    }
    else if([identifierCell isEqualToString:@"idAddCart"] && self.applicationContext.loggedUser){
        [self performSegueWithIdentifier: @"toAddCart" sender: self];
    }
    else if([identifierCell isEqualToString:@"idAddCart"]){
        [self goToAuthentication];
        //[self performSegueWithIdentifier:@"Login" sender:self];
    }
    else if([identifierCell isEqualToString:@"idTelephon"]){
       [self callTelephone];
    }
    else if([identifierCell isEqualToString:@"idEmail"]){
        [self sendEmail];
    }
    else if([identifierCell isEqualToString:@"idChat"]){
        // animate label on pressure
        POPSpringAnimation *sprintAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewScaleXY];
        sprintAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(0.9, 0.9)];
        sprintAnimation.velocity = [NSValue valueWithCGPoint:CGPointMake(0.5, 0.5)];
        sprintAnimation.springSpeed = 10.0;
        sprintAnimation.autoreverses = YES;
        [[cell viewWithTag:11] pop_addAnimation:sprintAnimation forKey:@"basicAnimation"];
        
        if (self.applicationContext.loggedUser) {
            [self openMessageDialog];
        }else{
            [self goToAuthentication];
        }
    }
    else if([identifierCell isEqualToString:@"idMultiStore"]){
        [self performSegueWithIdentifier: @"toMultiStore" sender: self];
    }
    else if([identifierCell isEqualToString:@"idLastCell"]){
        if ([self.applicationContext.loggedUser.username isEqualToString:self.product.createdBy]) {
             //[self deleteProduct];
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"DeleteProductAlertTitleLKey", nil) message:NSLocalizedString(@"DeleteProductAlertMessageLKey", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles:NSLocalizedString(@"CancelLKey", nil), nil];
            alertView.tag = 1;
            [alertView show];
        }else{
            [self performSegueWithIdentifier:@"toReport" sender:self];
        }
    }
    else if([identifierCell isEqualToString:@"idSearchNear"]){
        [self performSegueWithIdentifier: @"toSearchNear" sender: self];
    }
    else if([identifierCell isEqualToString:@"idLike"]){
        [self performSegueWithIdentifier: @"toLiked" sender: self];
    }
    else if([identifierCell isEqualToString:@"idEditPlaces"]){
        [self performSegueWithIdentifier: @"toEditPlaces" sender: self];
    }
    else if([identifierCell isEqualToString:@"idEditPlan"]){
        [self performSegueWithIdentifier: @"toEditPlan" sender: self];
    }
    else if([identifierCell isEqualToString:@"idViewPlan"]){
        [self performSegueWithIdentifier: @"toViewPlan" sender: self];
    }
    
    
}


//----------------------------------------------------------//
//END TABLEVIEW
//----------------------------------------------------------//

-(void)openMessageDialog {
    [self performSegueWithIdentifier:@"messageDialogSegue" sender:self];
}

//----------------------------------------------------------//
//START PREPARE FOR SEGUE
//----------------------------------------------------------//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toShopDetail"]) {
        //NSLog(@"goToPoiDetail");
        SHPPoiDetailTVC *VC = [segue destinationViewController];
        VC.applicationContext = self.applicationContext;
        VC.shop = self.shop;
        VC.imageMap = self.imageMap;
        VC.distance = self.product.distance;
    }
    else if ([[segue identifier] isEqualToString:@"Login"]) {
        [self goToAuthentication];
    }
    else if ([[segue identifier] isEqualToString:@"toProfile"]) {
        
    }
    else if([[segue identifier] isEqualToString:@"ShowOnMap2"]) {
        SHPMapperViewController *map = [segue destinationViewController];
        map.applicationContext = self.applicationContext;
        map.lat = self.product.shopLat;
        map.lon = self.product.shopLon;
        map.address = self.shop.formattedAddress;
        map.placeHolderTitle = self.product.shopName;
        
    }
    else if([[segue identifier] isEqualToString:@"toReport"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SHPReportViewController *reportVC = (SHPReportViewController *)[[navigationController viewControllers] objectAtIndex:0];
        //SHPReportViewController *reportVC = [segue destinationViewController];
        reportVC.modalCallerDelegate = self;
        reportVC.applicationContext = self.applicationContext;
        reportVC.product = self.product;
    }
    else if([[segue identifier] isEqualToString:@"toLiked"]) {
        //NSLog(@"Preparing Segue for Product %@", self.product.oid);
        SHPLikesViewController * vc = (SHPLikesViewController *)[segue destinationViewController];
        SHPLikedToLoader *loader = [[SHPLikedToLoader alloc] init];
        loader.product = self.product;
        loader.userDC.delegate = vc;
        vc.applicationContext = self.applicationContext;
        vc.loader = loader;
    }
    else if ([[segue identifier] isEqualToString:@"waitToLoadData"]) {
        SHPLoadInitialDataViewController *vc = (SHPLoadInitialDataViewController *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.caller = self;
    }
    else if ([[segue identifier] isEqualToString:@"toWebView"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        SHPMiniWebBrowserVC *vc = (SHPMiniWebBrowserVC *)[[navigationController viewControllers] objectAtIndex:0];
        vc.applicationContext = self.applicationContext;
        vc.urlPage = urlLink;
        vc.hiddenToolBar = YES;
        vc.titlePage = nameLink;
        //NSLog(@"urlPage: %@ - nameLink: %@", urlLink, nameLink);
    }
    else if ([[segue identifier] isEqualToString:@"toAddCart"]) {
    }
    else if ([[segue identifier] isEqualToString:@"toImageDetail"]) {
        SHPImageDetailViewController *vc = (SHPImageDetailViewController *)[segue destinationViewController];
        vc.image = self.productImage.image;
    }
    else if ([[segue identifier] isEqualToString:@"toMultiStore"]) {
        //UINavigationController *navigationController = [segue destinationViewController];
        //SHPListCoverTVC *vc = (SHPListCoverTVC *)[[navigationController viewControllers] objectAtIndex:0];
        SHPListCoverTVC *vc = (SHPListCoverTVC *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
    }
    else if ([[segue identifier] isEqualToString:@"toSearchNear"]) {
        SHPSearchCategoriesNearPoiTVC *vc = (SHPSearchCategoriesNearPoiTVC *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.nearPoi = self.shop;
    }
    else if ([[segue identifier] isEqualToString:@"toEditPlaces"]) {
        SHPEditPlacesVC *vc = (SHPEditPlacesVC *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.numberPlaceAvailable = self.numberPlaces;//[NSString stringWithFormat:@"%ld",(long)numberPlaces];
        vc.product = self.product;
    }
    else if ([[segue identifier] isEqualToString:@"toEditPlan"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        CZEditTimeTablesVC *vc = (CZEditTimeTablesVC *)[[navigationController viewControllers] objectAtIndex:0];
        vc.applicationContext = self.applicationContext;
        vc.product = self.product;
        vc.plan = self.plan;
    }
    else if ([[segue identifier] isEqualToString:@"toViewPlan"]) {
        UINavigationController *navigationController = [segue destinationViewController];
        CZEditTimeTablesVC *vc = (CZEditTimeTablesVC *)[[navigationController viewControllers] objectAtIndex:0];
        vc.applicationContext = self.applicationContext;
        vc.product = self.product;
        vc.plan = self.plan;
        vc.modalView = YES;
    }
    
    
    
    else if ([[segue identifier] isEqualToString:@"messageDialogSegue"]) {
        UINavigationController *navigationController = [segue destinationViewController];
//        SHPMiniWebBrowserVC *vc = (SHPMiniWebBrowserVC *)[[navigationController viewControllers] objectAtIndex:0];
        SHPSendMessageDialog *vc = (SHPSendMessageDialog *)[[navigationController viewControllers] objectAtIndex:0];
        vc.image = self.product.image;
        vc.productDescription = self.product.longDescription;
        NSLog(@"DESC %@ IMAGE %@", self.product.description, self.product.image);
        vc.username = self.product.createdBy;
    }
}


-(void)goToAuthentication{
    //NSLog(@"goToAuthentication");
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    SHPAuthenticationVC *vc = (SHPAuthenticationVC *)[sb instantiateViewControllerWithIdentifier:@"StartAuthentication"];
    vc.applicationContext = self.applicationContext;
    //vc.disableButtonClose = YES;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:NULL];
}

-(void)goToPoiDetail{
    //NSLog(@"goToPoiDetail");
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"PoiDetail" bundle:nil];
    UINavigationController *nc = [sb instantiateViewControllerWithIdentifier:@"navigationPoi"];
    SHPPoiDetailTVC *VC = (SHPPoiDetailTVC *)[[nc viewControllers] objectAtIndex:0];
    //SHPShop *shop = [[SHPShop alloc] init];
    //shop.coverImage = self.shop.coverImage;
    VC.applicationContext = self.applicationContext;
    VC.shop = self.shop;
    VC.imageMap = self.imageMap;
    VC.distance = self.product.distance;
    [self.navigationController pushViewController:VC animated:YES];
    //[self performSegueWithIdentifier: @"toProfile" sender: self];
}

-(void)goToProfile{
    //NSLog(@"goToProfile");
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Profile" bundle:nil];
    UINavigationController *nc = [sb instantiateViewControllerWithIdentifier:@"navigationProfile"];
    SHPHomeProfileTVC *VC = (SHPHomeProfileTVC *)[[nc viewControllers] objectAtIndex:0];
    VC.applicationContext = self.applicationContext;
    SHPUser *authorProfile = [[SHPUser alloc] init];
    authorProfile.username = self.product.createdBy;
    authorProfile.photoImage = self.userImage;
    VC.user = authorProfile;
    [self.navigationController pushViewController:VC animated:YES];
    //[self performSegueWithIdentifier: @"toProfile" sender: self];
}

-(void)goToWizard:(NSString *)typeSelected{
    NSMutableDictionary *wizardDictionary = [[NSMutableDictionary alloc] init];
    [self.applicationContext setVariable:WIZARD_DICTIONARY_KEY withValue:wizardDictionary];
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"WizardStoryboard" bundle:nil];
    UINavigationController *nc = [sb instantiateViewControllerWithIdentifier:@"start"];//[segue destinationViewController];
    SHPWizardStep1Types *vc = (SHPWizardStep1Types *)[[nc viewControllers] objectAtIndex:0];
    vc.applicationContext = self.applicationContext;
    vc.typeSelected = typeSelected;
    //nc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:nc animated:YES completion:NULL];
}

//----------------------------------------------------------//
//END PREPARE FOR SEGUE
//----------------------------------------------------------//



//----------------------------------------------------------//
//START STACK MENU
//----------------------------------------------------------//
-(void)setMenu
{
    contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [contentView setBackgroundColor:[SHPImageUtil colorWithHexString:@"CD2D2A"]];
    [contentView.layer setCornerRadius:contentView.frame.size.width/2];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_standard_plus.png"]];
    icon.image = [icon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [icon setTintColor:[UIColor whiteColor]];
    [icon setContentMode:UIViewContentModeScaleAspectFit];
    [icon setFrame:CGRectInset(contentView.frame, 10, 10)];
    [contentView addSubview:icon];
    viewBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    viewBackground.backgroundColor = [UIColor blackColor];
    viewBackground.alpha = 0.0;
    viewBackground.tag = 100;
    [super.navigationController.view insertSubview:viewBackground atIndex:(int)[self.view.subviews count]];
    [self changeDemo:nil];
}


- (IBAction)changeDemo:(id)sender
{
    //NSLog(@"stack : %@",stack);
    if(stack)[stack removeFromSuperview];
    stack = [[UPStackMenu alloc] initWithContentView:contentView];
    [stack setCenter:CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2 + 20)];
    [stack setDelegate:self];
    UIImage *img1 = [UIImage imageNamed:@"icon_type_photo.png"];
    img1 = [SHPImageUtil scaleImage:img1 toSize:CGSizeMake(50, 50)];
    UIImage *img2 = [UIImage imageNamed:@"icon_type_event.png"];
    img2 = [SHPImageUtil scaleImage:img2 toSize:CGSizeMake(50, 50)];
    UIImage *img4 = [UIImage imageNamed:@"icon_type_deal.png"];
    img4 = [SHPImageUtil scaleImage:img4 toSize:CGSizeMake(50, 50)];

    NSString *labelButtonPhoto = [NSString stringWithFormat:@"type-%@",CATEGORY_TYPE_PHOTO];
    NSString *labelButtonEvent = [NSString stringWithFormat:@"type-%@",CATEGORY_TYPE_EVENT];
    NSString *labelButtonDeal = [NSString stringWithFormat:@"type-%@",CATEGORY_TYPE_DEAL];
    UPStackMenuItem *photoItem = [[UPStackMenuItem alloc] initWithImage:img1 highlightedImage:nil title:NSLocalizedString(labelButtonPhoto, nil)];
    UPStackMenuItem *eventItem = [[UPStackMenuItem alloc] initWithImage:img2 highlightedImage:nil title:NSLocalizedString(labelButtonEvent, nil)];
    UPStackMenuItem *dealItem = [[UPStackMenuItem alloc] initWithImage:img4 highlightedImage:nil title:NSLocalizedString(labelButtonDeal, nil)];
//    photoItem.tag = 0;
//    eventItem.tag = 1;
//    dealItem.tag = 2;
    NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:photoItem, eventItem, dealItem, nil];
    [items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
        [item setTitleColor:[UIColor whiteColor]];
    }];
    
    NSUInteger index = sender ? [(UISegmentedControl*)sender selectedSegmentIndex] : 0;
    switch (index) {
        case 0:
            [stack setAnimationType:UPStackMenuAnimationType_progressive];
            [stack setStackPosition:UPStackMenuStackPosition_up];
            [stack setOpenAnimationDuration:.4];
            [stack setCloseAnimationDuration:.4];
            [items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
                [item setLabelPosition:UPStackMenuItemLabelPosition_right];
                [item setLabelPosition:UPStackMenuItemLabelPosition_left];
            }];
            break;
            
        case 1:
            [stack setAnimationType:UPStackMenuAnimationType_linear];
            [stack setStackPosition:UPStackMenuStackPosition_down];
            [stack setOpenAnimationDuration:.3];
            [stack setCloseAnimationDuration:.3];
            [items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
                [item setLabelPosition:UPStackMenuItemLabelPosition_right];
            }];
            break;
            
        case 2:
            [stack setAnimationType:UPStackMenuAnimationType_progressiveInverse];
            [stack setStackPosition:UPStackMenuStackPosition_up];
            [stack setOpenAnimationDuration:.4];
            [stack setCloseAnimationDuration:.4];
            [items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
                if(idx%2 == 0)
                    [item setLabelPosition:UPStackMenuItemLabelPosition_left];
                else
                    [item setLabelPosition:UPStackMenuItemLabelPosition_right];
            }];
            break;
            
        default:
            break;
    }
    //NSLog(@"self.view.subviews count : %d - %@",(int)[self.view.subviews count], self.view.subviews);
    [stack addItems:items];
    
    CGRect f = stack.frame;
    f.origin.x = self.view.frame.size.width-f.size.width-10; // new x
    f.origin.y = self.tabBarController.tabBar.frame.origin.y-f.size.height-10; // new y
    stack.frame = f;
    stack.tag = 101;
    [self.navigationController.view  insertSubview:stack atIndex:[self.view.subviews count]+1];
    //NSLog(@"self.view.subviews count : %d - %d - %d - %d ",(int)self.view.frame.origin.y,(int)self.navigationController.navigationBar.frame.origin.y,(int)self.navigationController.navigationBar.frame.size.height ,(int)self.tabBarController.tabBar.frame.size.height);
    //[self.view addSubview:stack];
    [self setStackIconClosed:YES];
}


- (void)setStackIconClosed:(BOOL)closed
{
    UIImageView *icon = [[contentView subviews] objectAtIndex:0];
    float angle = closed ? 0 : (M_PI * (135) / 180.0);
    [UIView animateWithDuration:0.3 animations:^{
        [icon.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, angle)];
    }];
}


#pragma mark - UPStackMenuDelegate

- (void)stackMenuWillOpen:(UPStackMenu *)menu
{
    [self animationChangeView:viewBackground alphaEnd:0.8];
    if([[contentView subviews] count] == 0)
        return;
    [self setStackIconClosed:NO];
}

- (void)stackMenuWillClose:(UPStackMenu *)menu
{
    //NSLog(@"stackMenuWillClose count : %@", menu);
    [self animationChangeView:viewBackground alphaEnd:0.0];
    if([[contentView subviews] count] == 0)
        return;
    [self setStackIconClosed:YES];
}

- (void)stackMenu:(UPStackMenu *)menu didTouchItem:(UPStackMenuItem *)item atIndex:(NSUInteger)index
{
    //NSLog(@" didTouchItem %@ - %lu",item,index);
    if (!self.applicationContext.loggedUser) {
        [self goToAuthentication];
    }else{
        [self addProduct:arrayButtonsAddProduct[index]];
    }
    
    
//    NSString *message = [NSString stringWithFormat:@"Item touched : %@", item.title];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message
//                                                    message:nil
//                                                   delegate:nil
//                                          cancelButtonTitle:@"Ok"
//                                          otherButtonTitles:nil];
//    [alert show];
}

-(void)addProduct:(NSString *)typeSelected{
    if (!self.applicationContext.loggedUser) {
        [self goToAuthentication];
    }else{
        [self goToWizard:typeSelected];
    }
}


-(void)animationChangeView:(UIView *)view alphaEnd:(float)alphaEnd
{
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: (UIViewAnimationCurveEaseInOut|UIViewAnimationOptionAllowUserInteraction)
                     animations:^{
                         view.alpha = alphaEnd;
                     }
                     completion:nil];
}

//----------------------------------------------------------//
//END STACK MENU
//----------------------------------------------------------//



//----------------------------------------------------------//
//START ACTION BUTTTON
//----------------------------------------------------------//
-(void)changeNumberPlaces {
    //:(NSString *)number{
    //numberPlaces = number;
    NSLog(@"numberPlaces---------------------->%@",self.numberPlaces);
    [self.tableView reloadData];
}

-(void)openUrlInBrowser:(id)sender{
    UIButton *clicked = (UIButton *) sender;
    //NSLog(@"%d",(int)clicked.tag);//Here you know which button has pressed
    int indexTag = (int)clicked.tag;
    if(indexTag >0 || indexTag == 0){
        NSArray *url = [SHPStringUtil extractUrl:arrayUrlsDescription[indexTag]];
        if(url.count>1){
            urlLink = (NSString *)url[0];
            nameLink = (NSString *)url[1];
        }else{
            urlLink = (NSString *)url[0];
            nameLink = @"";
        }
        [self performSegueWithIdentifier: @"toWebView" sender: self];
    }
}

- (IBAction)showActionSheet:(id)sender {
    //NSLog(@"showActionSheet!");
    [self.menuSheet showInView:self.view];
}

- (IBAction)actionCallChat:(id)sender {
}

- (IBAction)actionCallTelephon:(id)sender {
    [self callTelephone];
    
}


- (IBAction)actionLikePressed:(id)sender {
    if (!self.applicationContext.loggedUser) {
        [self goToAuthentication];
        return;
    }
    [self updateLike];
}

- (IBAction)share:(id)sender
{
    //NSLog(@"xxx share");
    NSMutableArray *objectsToShare = [[NSMutableArray alloc] init];
    self.product.title = [self.product.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    self.product.longDescription = [self.product.longDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *testo = [NSString stringWithFormat:@"%@\n%@",self.product.title,self.product.longDescription];
    NSString *testoTwitt = testo;
    if(testo.length>91)testoTwitt = [testo substringToIndex:91];
//    [objectsToShare addObject:testoTwitt];
    
    //NSURL *product_URL = [NSURL URLWithString:self.product.httpTinyURL];
    // TODO movetosettings
    NSString *secondamano_url = [[NSString alloc] initWithFormat:@"http://vacanzeinpuglia.smart21.it/dettaglio.php?id=%@", self.product.oid];
    NSURL *contentURL = [NSURL URLWithString:secondamano_url];
//    [objectsToShare addObject:contentURL];
    
//    if (self.productImage.image){
        //[objectsToShare addObject:self.productImage.image];
        //se aggiungo l'immagine whatsapp passa solo l'img e non più l'url
//    }
    
    CustomActivityItemProvider *activityItemProvider =
    [[CustomActivityItemProvider alloc] initWithText:testo twitText:testoTwitt urlText:contentURL image:self.product.image emailSubject:self.product.title];
    [objectsToShare addObject:activityItemProvider];
//    [objectsToShare addObject:testo];
    [objectsToShare addObject:contentURL];
    
    UIActivityViewController * avc = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[
                                    UIActivityTypeAirDrop,
                                    //UIActivityTypePostToTwitter,
                                    //UIActivityTypePostToFacebook,
                                    UIActivityTypePostToWeibo,
//                                    UIActivityTypeMessage,
//                                    UIActivityTypeMail,
                                    UIActivityTypePrint,
                                    //UIActivityTypeCopyToPasteboard,
                                    UIActivityTypeAssignToContact,
                                    //UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypeAddToReadingList,
                                    UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo,
                                    UIActivityTypePostToTencentWeibo];
    avc.excludedActivityTypes = excludedActivities;
    
    //[self presentViewController:avc animated:YES completion:nil];
    [self presentViewController:avc animated:YES completion:^{
        //NSLog(@"Presented %@!", avc);
    }];
}


//----------------------------------------------------------//
//END ACTION BUTTTON
//----------------------------------------------------------//

-(void)goBack {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)waitToLoadData{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    SHPLoadInitialDataViewController *viewController = (SHPLoadInitialDataViewController *)[storyboard instantiateViewControllerWithIdentifier:@"waitToLoadData"];
    viewController.applicationContext=self.applicationContext;
    viewController.caller = self;
    //UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"waitToLoadData"];
    //[self.navigationController pushViewController: viewController animated:YES];
    [self.navigationController presentViewController:viewController animated:NO completion:nil];
}

- (IBAction)unwindToProductDetail:(UIStoryboardSegue*)sender{
    NSLog(@"SENDER: %@", sender);
    UIViewController *sourceVC = sender.sourceViewController;
    NSLog(@"unwindToProductDetail: %@ ", sourceVC);
    if ([sourceVC isKindOfClass:[SHPEditPlacesVC class]]) {
        [self changeNumberPlaces];
    }
    else if ([sourceVC isKindOfClass:[SHPSendMessageDialog class]]) {
        NSLog(@"SENDING MESSAGE...");
        SHPSendMessageDialog *dialog = (SHPSendMessageDialog *)sourceVC;
        if (!dialog.canceled) {
            NSLog(@"NOT CANCELED.");
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.transitionCoordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
                 {
                     // Segue animation complete
                     NSLog(@"ANIMATION COMPLETED.");
                     NSString *userMessage = dialog.userMessage;
                     NSString *message = [[NSString alloc] initWithFormat:@"%@\n\nIl tuo annuncio è:\n\n\"%@\"",userMessage, self.product.longDescription];
                     [self sendMessage:message toUser:self.product.createdBy];
                 }];
            });
        } else {
            NSLog(@"CANCELED.");
        }
    }
    else{
        [self initializeView];
        [self initialize];
    }
}

-(void)terminatePendingConnections {
     //NSLog(@"Canceling pending connections...");
    self.productDC.delegate = nil;
    productDeleteDC.delegate = nil;
//    [self.productDC setDelegate:nil];
    [self.shopDC setShopsLoadedDelegate:nil];
//    [productDeleteDC setDelegate:nil];
}

- (void)dealloc {
     //NSLog(@"****************** DEALLOC");
    [self terminatePendingConnections];
}

@end
