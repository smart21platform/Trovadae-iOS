//
//  SHPHomeProfileTVC.m
//  Italiacamp
//
//  Created by dario de pascalis on 08/05/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import "SHPHomeProfileTVC.h"
#import "SHPAppDelegate.h"
#import "SHPImageUtil.h"
#import "SHPUser.h"
#import "SHPApplicationContext.h"
#import "MBProgressHUD.h"
#import "SHPProfileListProducts.h"
#import "SHPImageRequest.h"
#import "SHPImageUtil.h"
#import "ChatManager.h"
#import "SHPConversationsVC.h"
#import "SHPAuthenticationVC.h"
#import "SHPServiceUtil.h"
#import "SHPStringUtil.h"
#import "SHPConstants.h"
#import "SHPModifyProfileTVC.h"
#import "MessagesViewController.h"
#import "ChatRootNC.h"

@interface SHPHomeProfileTVC ()
@end

@implementation SHPHomeProfileTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    SHPAppDelegate *appDelegate = (SHPAppDelegate *)[[UIApplication sharedApplication] delegate];
    if(!self.applicationContext){
        self.applicationContext = appDelegate.applicationContext;
    }
    loggedUser = self.applicationContext.loggedUser;
    self.loaderUser = [[SHPUserDC alloc]init];
    self.loaderUser.delegate = self;
    isLoadingData = NO;
    
    NSLog(@"=== SHPHomeProfileTVC === %@ - %@", self.applicationContext.loggedUser.properties, self.applicationContext.loggedUser.httpBase64Auth);
    DC = [[CZAuthenticationDC alloc] init];
    DC.delegate = self;
    
    [self buildMenuWithRemovePhotoButton];
    
    NSDictionary *settingsDictionary = [self.applicationContext.plistDictionary objectForKey:@"Settings"];
    publicUpload = [[settingsDictionary valueForKey:@"publicUpload"] boolValue];
    if(!self.user.canUploadProducts){
        [self loadPermission];
    }
    else if(publicUpload > 0 && (self.user.canUploadProducts == YES)){
        self.applicationContext.permissionUpload = true;
    }
    
    UIColor *itemColor = [SHPImageUtil colorWithHexString:@"111111"];
    [self.navigationItem.titleView setTintColor:itemColor];
    self.navigationItem.title = @"Profilo";
    
    defaultH = self.imageBckDw.frame.size.height;
    //[self configNavigationBar];
    //[self customBackButton];
    
    self.imageViewProfile.userInteractionEnabled = TRUE;
    NSLog(@"loggedUser: %@ - user: %@",loggedUser,self.user);
    if(self.user == loggedUser){
        UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(didTapImage)];
        [self.imageViewProfile addGestureRecognizer:tapRec];
    }
    self.labelCreati.text = NSLocalizedString(@"ProductsCreatedButtonLKey", nil);
    self.labelPiaciuti.text = NSLocalizedString(@"ProductsLikedButtonLKey", nil);
    self.labelHookFacebook.text = NSLocalizedString(@"Aggancia a Facebook", nil);
    self.labelModificaProfilo.text = NSLocalizedString(@"Modifica nome utente", nil);
    self.labelChangePsw.text = NSLocalizedString(@"Modifica password", nil);
    self.labelLogout.text = NSLocalizedString(@"Esci", nil);
    self.labelNumberCreated.text = @"...";
    self.labelNumberLiked.text = @"...";
    self.labelTelefono.text = @"Telefono: ";

    
    // 1 - verifico i permessi di upload in background
    //[self loadPermission];
    // 2 - carico array rows voci di menu dal plist
    [self setMenuProfile];
    // 3 - aggiorno profilo in background
    [self setupUser]; // reload table
    [self completeProfile];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    //se sono qui sono sicuramente loggato
    //[self initImageCache];
    //[self initialize];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:NO];
    //ripristino navbar
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
   
    self.user.photoImage = self.imageViewProfile.image;
    NSLog(@"\n viewWillDisappear : %@ - %@", self.user, self.user.photoImage);
    //self.applicationContext.loggedUser = self.user;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialize {
    [self completeProfile];
    [self customImageProfile];
}


//----------------------------------------------------------------//
//START FUNCTION VIEW
//----------------------------------------------------------------//

-(void)setMenuProfile{
    NSLog(@"\n === setMenuProfile ===");
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"settingsProfile" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    menuDictionary = [plistDictionary objectForKey:@"Menu"];
    NSLog(@"\n === menuDictionary === %@", menuDictionary);
    //[self.tableView reloadData];
}

-(void)configNavigationBar{
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new]
                                                  forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.contentMode = UIViewContentModeScaleAspectFill;
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.view.backgroundColor = [UIColor clearColor];
    
    //self.imageViewBckUP.image = [DC blur:self.imageViewBckUP.image radius:16];
}

-(void)customBackButton{
    UIImage *faceImage = [UIImage imageNamed:@"buttonArrowLeft.png"];
    UIButton *face = [UIButton buttonWithType:UIButtonTypeCustom];
    face.bounds = CGRectMake( 0, 0, faceImage.size.width, faceImage.size.height );
    [face addTarget:self action:@selector(goToBack) forControlEvents:UIControlEventTouchUpInside];
    [face setImage:faceImage forState:UIControlStateNormal];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:face];
    self.navigationItem.leftBarButtonItem = backButton;
}

//-(void)initImageCache {
//    // cache setup
//    self.imageCache = (ChatImageCache *)[self.applicationContext getVariable:@"chatUserIcons"];
//    if (!self.imageCache) {
//        self.imageCache = [[ChatImageCache alloc] init];
//        self.imageCache.cacheName = @"chatUserIcons";
//        // test
//        //        [self.imageCache listAllImagesFromDisk];
//        //        [self.imageCache empty];
//        [self.applicationContext setVariable:@"chatUserIcons" withValue:self.imageCache];
//    }
//}


-(BOOL)checkIdCell:(NSString *)idCell{
    for (NSDictionary *itemMenu in menuDictionary) {
        NSString *idCellItem = [itemMenu valueForKey:@"id"];
        //NSLog(@"\n === idCellItem === %@",[itemMenu valueForKey:@"id"]);
        if([idCellItem isEqualToString:idCell]){
            //NSLog(@"\n -------- checkIdCell %@ - %@", idCell, idCellItem);
            return YES;
        }
    }
    return NO;
}

-(NSDictionary *)returnCell:(NSString *)idCell{
    for (NSDictionary *itemMenu in menuDictionary) {
        NSString *idCellItem = [itemMenu valueForKey:@"id"];
        if([idCellItem isEqualToString:idCell]){
            return itemMenu;
        }
    }
    return NULL;
}


-(void)customImageProfile
{
    [SHPImageUtil arroundImage:(self.imageViewProfile.frame.size.height/2) borderWidth:0.0 layer:[self.imageViewProfile layer]];
    UIColor *borderColor = [SHPImageUtil colorWithHexString:@"FFFFFF"];
    [[self.imageViewProfile layer] setBorderColor:[borderColor CGColor]];
    self.imageViewProfile.hidden = YES;
    
    
    NSString *imageURL = [SHPUser photoUrlByUsername:self.user.username];
    UIImage *cached_image = [self.applicationContext.smallImagesCache getImage:imageURL];
    
    if(!cached_image) {
        [self loadImageProfile];
    } else {
        NSLog(@"\n\n\n cached_image: %@",cached_image);
        [self changeProfilePhoto:cached_image];
//        self.imageBckDw.image = cached_image;
//        self.imageBckUp.image = [SHPImageUtil blur:cached_image radius:14];
//        //self.imageBckUp.contentMode = UIViewContentModeScaleAspectFill;
//        self.imageViewProfile.image = cached_image;
//        self.imageViewProfile.hidden = NO;
//        self.imageViewProfile.alpha = 1.0;
//        self.imageBckDw.alpha = 1;
//        self.imageBckUp.alpha = 1;
//        [self.tableView reloadData];
    }
}

-(void)completeProfile{
    NSLog(@"self.user::: %@ - %@ - %@", self.user.properties, self.user.photoUrl, self.user.productsCreatedByCount);
    
    self.labelUserNameComplete.text = self.user.fullName;
    self.labelUsername.text = self.user.username;
     self.labelTelefono.text = [NSString stringWithFormat:@"Telefono: %@",self.user.numberPhone];
    if(self.user.username == self.applicationContext.loggedUser.username){
        NSLog(@"facebookAccessToken: %@",self.applicationContext.loggedUser.facebookAccessToken);
        if(self.applicationContext.loggedUser.facebookAccessToken){
            self.labelHookFacebook.text = NSLocalizedString(@"Sgancia da Facebook", nil);
            //[self loadImageCoverFB:self.applicationContext.loggedUser.facebookAccessToken];
        }
    }
    if(self.user.productsCreatedByCount){
        self.labelNumberCreated.text = self.user.productsCreatedByCount;
    }
    if(self.user.productsLikesCount){
        self.labelNumberLiked.text = self.user.productsLikesCount;
    }
    [self.tableView reloadData];
}

-(void)agganciaSganciaFacebook
{
    NSLog(@"agganciaSganciaFacebook - self.applicationContext.loggedUser.facebookAccessToken::: %@",self.applicationContext.loggedUser.facebookAccessToken);
    if(self.applicationContext.loggedUser.facebookAccessToken){
        //sgancia
        [self showWaiting:NSLocalizedString(@"operazione in corso...", nil)];
        [self.loaderUser facebookDisconnect:self.applicationContext.loggedUser];
    }else{
        //aggancia
        [self showWaiting:NSLocalizedString(@"operazione in corso...", nil)];
        [self.loaderUser facebookConnect:self.applicationContext.loggedUser];
    }
}

-(void)showWaiting:(NSString *)label {
    if (!hud) {
        hud = [[MBProgressHUD alloc] initWithWindow:self.view.window];
        [self.view.window addSubview:hud];
    }
    hud.center = self.view.center;
    hud.labelText = label;
    hud.animationType = MBProgressHUDAnimationZoom;
    [hud show:YES];
}

-(void)hideWaiting {
    [hud hide:YES];
}
//----------------------------------------------------------------//
//END FUNCTION VIEW
//----------------------------------------------------------------//



//----------------------------------------------------------------//
//START SCROLL VIEW CONTROLLER
//----------------------------------------------------------------//
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSLog(@"\n startAlphaTrasparentBckBlack: %f",startAlphaTrasparentBckBlack);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollView: %@",scrollView);
    
    CGFloat scrollOffset = scrollView.contentOffset.y;
    CGRect headerImageFrame = self.imageBckUp.frame;
   
    self.viewBoxImage.alpha = 1+(scrollOffset+0)/120;
    self.imageBckUp.alpha = 1+(scrollOffset+0)/120;
    self.imageBckDw.alpha = -(scrollOffset+0)/100;
    self.labelUsername.alpha = 1+(scrollOffset+0)/120;
    self.labelUserNameComplete.alpha = 1+(scrollOffset+0)/120;
    
    if (scrollOffset < 0) {
        headerImageFrame.origin.y = (scrollOffset+0);
        headerImageFrame.size.height = defaultH-(scrollOffset+0);
    }
    else{
        if(scrollOffset==0){
           self.viewBoxImage.hidden = NO;
           self.viewBoxImage.alpha = 1;
        }
    }
    self.imageBckDw.frame = headerImageFrame;
    self.imageBckUp.frame = headerImageFrame;
}
//----------------------------------------------------------------//
//END SCROLL VIEW CONTROLLER
//----------------------------------------------------------------//


//--------------------------------------------------------------------//
//START SETUP USER self.loaderUser facebookConnect e facebookDisconnect
//--------------------------------------------------------------------//
-(void)setupUser {
    //userHeaderInitialized = NO;
    [self.loaderUser findByUsername:self.user.username];
}
//********************************************************************//
//DELEGATE loaderUser
//********************************************************************//
-(void)usersDidLoad:(NSArray *)__users error:(NSError *)error
{
    NSLog(@"\n  usersDidLoad::: %@ - %@",__users, error);
    SHPUser *tmp_user;
    if(__users.count > 0) {
        tmp_user = [__users objectAtIndex:0];
        self.user.fullName = tmp_user.fullName;
        self.user.email = tmp_user.email;
        self.user.productsCreatedByCount = tmp_user.productsCreatedByCount;
        self.user.productsLikesCount = tmp_user.productsLikesCount;
        self.user.isRivenditore = tmp_user.isRivenditore;
        self.user.properties = tmp_user.properties;
        self.user.numberPhone = tmp_user.numberPhone;
        [self initialize];
    }
}
//---------------------------------------------------------------------//
//END SETUP USER
//---------------------------------------------------------------------//



//---------------------------------------------------------------------//
//START FUNCTION ON PRESS BUTTON MENU
//---------------------------------------------------------------------//

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
        {
            break;
        }
        case 1:
        {
            NSLog(@"ESCI");
            [self.applicationContext signout];
            //START LOGOUT CHAT
            ChatManager *chat = [ChatManager getSharedInstance];
            [chat logout];
            //END LOGOUT CHAT
            self.user = nil;
            self.applicationContext.loggedUser = nil;
            self.imageViewProfile = nil;
            self.imageBckDw = nil;
            self.imageBckUp = nil;
            [self goToBack];
            //[self.navigationController popViewControllerAnimated:YES];
        }
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
        conversationsVC.selectedRecipient = self.user.username;
        tabController.selectedIndex = messages_tab_index;
        //        [conversationsVC openConversationWithUser:self.user.username];
        
    }
}
 */

-(void)sendMessage
{
    UIViewController *backVC = [self backViewController];
    NSLog(@">>>>>> Back VC Class: %@", NSStringFromClass(backVC.class));
    if([backVC isKindOfClass:[MessagesViewController class]]) {
        NSLog(@"IS MESSAGES!!!!");
        [self.navigationController popViewControllerAnimated:YES];
        return;
    } else {
        NSLog(@"NOT MESSAGES");
    }
    // COME IL SENDMESSAGE DI PRODUCT-DETAIL
    int chat_tab_index = [SHPApplicationContext tabIndexByName:@"ChatController" context:self.applicationContext];
    // move to the converstations tab
    if (chat_tab_index >= 0) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        UITabBarController *tabController = (UITabBarController *)window.rootViewController;
        NSArray *controllers = [tabController viewControllers];
        ChatRootNC *nc = [controllers objectAtIndex:chat_tab_index];
        SHPConversationsVC *vc = nc.viewControllers[0];
        if (vc.presentedViewController) {
            NSLog(@"THERE IS A MODAL PRESENTED! NOT SWITCHING TO ANY CONVERSATION VIEW.");
        } else {
            NSLog(@"SWITCHING TO CONVERSATION VIEW. DISABLED.");
            // IF YOU ENABLE THIS IS MANDATORY TO FIND A WAY TO DISMISS OR HANDLE THE CURRENT MODAL VIEW
            [nc popToRootViewControllerAnimated:NO];
            [vc openConversationWithRecipient:self.user.username];
            tabController.selectedIndex = chat_tab_index;
        }
    }
}


- (UIViewController *)backViewController
{
    NSInteger numberOfViewControllers = self.navigationController.viewControllers.count;
    
    if (numberOfViewControllers < 2)
        return nil;
    else
        return [self.navigationController.viewControllers objectAtIndex:numberOfViewControllers - 2];
}

//---------------------------------------------------------------------//
//START FUNCTION ON PRESS BUTTON MENU
//---------------------------------------------------------------------//



//---------------------------------------------------------------------//
//START FUNCTION LOAD PERMISSION UPLOAD USER
//---------------------------------------------------------------------//
-(void)loadPermission{
    SHPVerifyUploadPermissionsDC *verify = [[SHPVerifyUploadPermissionsDC alloc]init];
    verify.delegate=self;
    verify.applicationContext=self.applicationContext;
    NSLog(@"3 PERMISSION UPLOAD DI = %d", self.user.canUploadProducts);
    [verify verifyUploadPermission];
}
//********************************************//
//START DELEGATE verifyUploadPermission
//********************************************//
- (void)permissionCheck:(BOOL)permission{
    self.applicationContext.permissionUpload=permission;
    self.user.canUploadProducts=permission;
    NSLog(@"4 PERMISSION UPLOAD DI = %d",  self.user.canUploadProducts);
    [self.tableView reloadData];
}
//---------------------------------------------------------------------//
//END FUNCTION LOAD PERMISSION UPLOAD USER
//---------------------------------------------------------------------//



//-------------------------------------------------------------------//
// **** START USER PHOTO MENU ****
//-------------------------------------------------------------------//

-(void)didTapImage {
    NSLog(@"tapped 2");
    [self.takePhotoMenu showInView:self.view];
}

-(void)resetUserPhoto {
    self.userImage = nil;
    self.imageViewProfile.image = nil;
    self.imageBckUp.image = nil;
    [self setProfilePhoto:[UIImage imageNamed:@"avatar.png"]];
    [self buildMenuWithoutRemovePhotoButton];
    [self sendUserPhoto];
}

-(void)buildMenuWithRemovePhotoButton {
    self.takePhotoMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"TakePhotoLKey", nil), NSLocalizedString(@"PhotoFromGalleryLKey", nil), NSLocalizedString(@"RemoveProfilePhotoLKey", nil), nil];
    self.takePhotoMenu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
}

-(void)buildMenuWithoutRemovePhotoButton {
    self.takePhotoMenu = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"TakePhotoLKey", nil), NSLocalizedString(@"PhotoFromGalleryLKey", nil), nil];
    self.takePhotoMenu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Alert Button!");
    NSString *option = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([option isEqualToString:NSLocalizedString(@"TakePhotoLKey", nil)]) {
        NSLog(@"Take Photo");
        [self takePhoto];
    }
    else if ([option isEqualToString:NSLocalizedString(@"PhotoFromGalleryLKey", nil)]) {
        NSLog(@"Choose from Gallery");
        [self chooseExisting];
    }
    else if ([option isEqualToString:NSLocalizedString(@"RemoveProfilePhotoLKey", nil)]) {
        NSLog(@"Choose from Gallery");
        [self resetUserPhoto];
    }
}

// TAKE PHOTO SECTION

- (void)takePhoto {
    if (self.imagePickerController == nil) {
        [self initializeCamera];
    }
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (void)chooseExisting {
    if (self.photoLibraryController == nil) {
        [self initializePhotoLibrary];
    }
    [self presentViewController:self.photoLibraryController animated:YES completion:nil];
}

-(void)initializeCamera {
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePickerController.allowsEditing = YES;
}

-(void)initializePhotoLibrary {
    self.photoLibraryController = [[UIImagePickerController alloc] init];
    self.photoLibraryController.delegate = self;
    self.photoLibraryController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    self.photoLibraryController.allowsEditing = YES;
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion: ^{
        self.backupUserImage = self.imageViewProfile.image;
        self.userImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        // enable to crop
        self.userImage = [info objectForKey:@"UIImagePickerControllerEditedImage"];
        if (!self.userImage) {
            UIImage *photo = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            CGSize size = CGSizeMake(320, 320); // using facebook type=large image size.
            self.userImage = [SHPImageUtil scaleImage:photo toSize:size];
            //        self.image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        }
        [self sendUserPhoto];
        // adds the remove photo option to the menu.
        [self buildMenuWithRemovePhotoButton];
    }];
}

-(void)removeUserPhoto {
    self.userImage = nil;
    //    self.userImageView.image = [UIImage imageNamed:@"no-profile"];
    [self setProfilePhoto:[UIImage imageNamed:@"avatar"]];
    //    self.backupUserImage = self.applicationContext.loggedUser.photoImage;
    // service to remove user-photo?
    [self sendUserPhoto];
}

//-------------------------------------------------------------------//
// **** END USER PHOTO MENU ****
//-------------------------------------------------------------------//


-(void)setProfilePhoto:(UIImage *)image {
    self.imageBckDw.image = image;
    self.imageBckUp.image = [SHPImageUtil blur:image radius:14];
    self.imageViewProfile.image = image;
    self.imageViewProfile.hidden = NO;
    self.imageViewProfile.alpha = 0.0;
}

-(void)changeProfilePhoto:(UIImage *)image
{
    if(!image)image = [UIImage imageNamed:@"avatar.png"];
    [self.applicationContext.smallImagesCache addImage:image withKey:self.user.photoUrl];
    self.imageBckDw.image = self.imageBckUp.image;
    self.imageBckDw.alpha = 1.0;
    self.imageBckUp.alpha = 0.0;
    self.imageBckUp.contentMode = UIViewContentModeScaleAspectFill;
    self.imageBckUp.image = [SHPImageUtil blur:image radius:14];
    self.viewBoxImage.alpha = 1.0;
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.imageBckUp.alpha = 1.0;
                         self.imageBckDw.alpha = 0.0;
                         self.viewBoxImage.alpha = 0.0;
                     }
                     completion:^(BOOL finished){
                         self.imageBckDw.contentMode = UIViewContentModeScaleAspectFill;
                         self.imageBckDw.image = image;
                         self.imageBckDw.alpha = 0.0;
                         self.imageViewProfile.image = image;
                         self.imageViewProfile.hidden = NO;
                         self.imageViewProfile.alpha = 1.0;
                         [UIView animateWithDuration:1.0
                                          animations:^{
                                              self.viewBoxImage.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished){
                                          }];
                     }];
}

-(void)loadImageProfile
{
    NSLog(@"loadImageProfile %@", self.user.photoUrl);
    SHPImageRequest *imageRquest = [[SHPImageRequest alloc] init];
    [imageRquest downloadImage:self.user.photoUrl
             completionHandler:
     ^(UIImage *image, NSString *imageURL, NSError *error) {
         if (image) {
             [self.applicationContext.smallImagesCache addImage:image withKey:imageURL];
             self.imageBckDw.alpha = 0;
             self.imageBckUp.alpha = 0;
             self.imageViewProfile.alpha = 0;
             
             self.imageBckDw.image = image;
             self.imageBckDw.contentMode = UIViewContentModeScaleAspectFill;
             
             self.imageBckUp.image = [SHPImageUtil blur:image radius:14];
             self.imageBckUp.contentMode = UIViewContentModeScaleAspectFill;

             [UIView animateWithDuration:1.0
                              animations:^{
                
                                  self.imageBckUp.alpha = 1.0;
                                  self.imageViewProfile.alpha = 0.0;
                              }
                              completion:^(BOOL finished){
                                  self.imageViewProfile.image = image;
                                  self.imageViewProfile.hidden = NO;
                                  [UIView animateWithDuration:1.0
                                                   animations:^{
                                                       self.imageViewProfile.alpha = 1.0;
                                                   }
                                                   completion:^(BOOL finished){
                                                   }];
                              }];
         } else {
             // optionally put an image that indicates an error
         }
     }];
}
//-------------------------------------------------------------------//
//END FUNCTION IMAGE PROFILE
//-------------------------------------------------------------------//


// -------------------------------------
// ******* UPLOAD PHOTO SECTION ********
// -------------------------------------

-(void)sendUserPhoto {
    [self showWaiting:@"Sto salvando..."];
    
    NSString *actionUrl = [SHPServiceUtil serviceUrl:@"service.uploaduserphoto"];
    NSLog(@"Change user photo. Action url: %@", actionUrl);
    
    NSString * boundaryFixed = SHPCONST_POST_FORM_BOUNDARY;
    NSString *randomString = [SHPStringUtil randomString:16];
    //    NSLog(@"randomString: -%@-", randomString);
    NSString *boundary = [[NSString alloc] initWithFormat:@"%@%@", boundaryFixed, randomString];
    NSString * boundaryString = [NSString stringWithFormat:@"\r\n--%@\r\n", boundary];
    NSString * boundaryStringFinal = [NSString stringWithFormat:@"\r\n--%@--", boundary];
    
    UIImage *imageEXIFAdjusted = [SHPImageUtil adjustEXIF:self.userImage];
    NSData *imageData = UIImageJPEGRepresentation(imageEXIFAdjusted, 90);
    
    UIImage *scaledImage = [SHPImageUtil scaleImage:imageEXIFAdjusted toSize:CGSizeMake(self.applicationContext.settings.uploadImageSize, self.applicationContext.settings.uploadImageSize)];
    NSLog(@"SCALED IMAGE w:%f h:%f", scaledImage.size.width, scaledImage.size.height);
    
    //    NSLog(@"IMAGE DATA::::::::::::::::::::::::::::::::::::::::::::::::::: %@", imageData);
    NSMutableData *postData = [NSMutableData dataWithCapacity:[imageData length] + 1024];
    //    NSLog(@"POST DATA:::::: %@", postData);
    
    
    [postData appendData:[boundaryString dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"photo_file\"; filename=\"photofile.jpeg\"\r\nContent-Type: image/jpeg\r\nContent-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:imageData];
    [postData appendData:[boundaryStringFinal dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableURLRequest * theRequest=(NSMutableURLRequest*)[NSMutableURLRequest requestWithURL:[NSURL URLWithString:actionUrl] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    //    [theRequest addValue:@"www.theshopper.com" forHTTPHeaderField:@"Host"];
    NSString * dataLength = [NSString stringWithFormat:@"%lu", [postData length]];
    [theRequest addValue:dataLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:(NSData*)postData];
    
    // auth
   // SHPUser *__user = self.applicationContext.loggedUser;
   
    NSString *httpAuthFieldValue = [[NSString alloc] initWithFormat:@"Basic %@", self.user.httpBase64Auth];
    [theRequest setValue:httpAuthFieldValue forHTTPHeaderField:@"Authorization"];
    
    NSLog(@"\n httpAuthFieldValue: %@ - %@ - %@", httpAuthFieldValue, self.user, self.user.httpBase64Auth);
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    self.currentConnection = conn;
    if (conn) {
        self.receivedData = [NSMutableData data];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    } else {
        NSLog(@"Could not connect to the network");
    }
}

-(NSString *)stringParameter:(NSString *)name withValue:(NSString *)value {
    NSString *part = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@", name, value];
    return part;
}

- (void)cancelConnection {
    NSLog(@"Canceling service for Product ");
    [self.currentConnection cancel];
    //    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    self.currentConnection = nil;
}


// CONNECTION DELEGATE
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"Response ready to be received.");
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    //    NSDictionary* headers = [(NSHTTPURLResponse *)response allHeaderFields];
    //    for (NSString *key in headers) {
    //        NSLog(@"field: %@ value: %@", key, [headers objectForKey:key]);
    //    }
    long code = [(NSHTTPURLResponse*) response statusCode];
    self.statusCode = code;
    [self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"Received data.");
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [self.receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    NSLog(@"Error!");
    [self hideWaiting];
    // receivedData is declared as a method instance elsewhere
    self.receivedData = nil;
    
    if (self.backupUserImage) {
        NSLog(@"BACKUPPING OLD USER IMAGE");
        self.userImage = self.backupUserImage;
        [self setProfilePhoto:self.userImage];
        //        self.userImageView.image = self.userImage;
    } else {
        NSLog(@"BACKUPPING OLD USER IMAGE");
        self.userImage = nil;
        [self setProfilePhoto:[UIImage imageNamed:@"avatar"]];
        // self.userImageView.image = [UIImage imageNamed:@"no-profile"];
    }
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@ %ld",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey],
          error.code);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // show alert!
    NSString *title = NSLocalizedString(@"NetworkErrorTitleLKey", nil);
    NSString *msg = NSLocalizedString(@"NetworkErrorLKey", nil);
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self hideWaiting];
    //    NSLog(@"Succeeded! Received %d bytes of data",[self.receivedData length]);
    
    //NSString* text;
    //text = [[NSString alloc] initWithData:self.receivedData encoding:NSASCIIStringEncoding];
    
    // the json charset encoding
    NSString *responseString = [[NSString alloc] initWithData:self.receivedData encoding:NSISOLatin1StringEncoding];
    NSLog(@"Response: %@", responseString);
    
    //    self.applicationContext.loggedUser.photoImage = self.userImage; //???
    //[self.imageCache addImage:self.userImage withKey:self.user.photoUrl];
    [self changeProfilePhoto:self.userImage];

}

- (NSString *)httpBase64FromJson:(NSData *)jsonData {
    NSError* error;
    NSDictionary *objects = [NSJSONSerialization
                             JSONObjectWithData:jsonData
                             options:kNilOptions
                             error:&error];
    NSString *basicAuth64 = [objects valueForKey:@"basicAuth"];
    return basicAuth64;
}

// --------------------------------------
// ******** SEND USER PHOTO END *********
// --------------------------------------





//----------------------------------------------------------------//
//START BUILD TABLEVIEW
//----------------------------------------------------------------//

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 1){
        //return 70;
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section==1){
        //return @"ASSISTENZA";
    }
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *identifierCell = [cell reuseIdentifier];
    
    
    if([identifierCell isEqualToString:@"idCellPhone"]){
        if(!self.user.numberPhone || [self.user.numberPhone isEqualToString:@""] ){
            //self.user.productsCreatedByCount == 0 ||
            //if (!listProductsCreated || listProductsCreated == 0 ){
            return 0.0;
        }
    }

    //NSLog(@"\n === heightForRowAtIndexPath === %@ - %d", identifierCell, [self checkIdCell:@"idCellCreated"]);
    if([identifierCell isEqualToString:@"idCellCreated"]){
        if(![self checkIdCell:@"idCellCreated"]){ //self.user.productsCreatedByCount == 0 ||
            //if (!listProductsCreated || listProductsCreated == 0 ){
            return 0.0;
        }
    }
    if([identifierCell isEqualToString:@"idCellLiked"]){
        if(![self checkIdCell:@"idCellLiked"]){//self.user.productsCreatedByCount == 0 ||
            //if (!listProductsCreated || listProductsCreated == 0 ){
            return 0.0;
        }
    }
    
    if([identifierCell isEqualToString:@"idCellModify"]){
        if (![self.applicationContext.loggedUser.username isEqualToString:self.user.username] || ![self checkIdCell:@"idCellModify"]){
            return 0.0;
        }
    }
    if([identifierCell isEqualToString:@"idCellChangePsw"]){
        if (![self.applicationContext.loggedUser.username isEqualToString:self.user.username] || ![self checkIdCell:@"idCellChangePsw"]){
            return 0.0;
        }
    }
    if([identifierCell isEqualToString:@"idCellChat"]){
        if ([self.applicationContext.loggedUser.username isEqualToString:self.user.username] || ![self checkIdCell:@"idCellChat"]){
            return 0.0;
        }
    }
    if([identifierCell isEqualToString:@"idCellFacebook"]){
        if (![self.applicationContext.loggedUser.username isEqualToString:self.user.username] || ![self checkIdCell:@"idCellFacebook"]){
            return 0.0;
        }
    }
    if([identifierCell isEqualToString:@"idCellLogout"]){
        if (![self.applicationContext.loggedUser.username isEqualToString:self.user.username] || ![self checkIdCell:@"idCellLogout"]){
            return 0.0;
        }
    }
    if([identifierCell isEqualToString:@"idCellHelp"]){
        if (![self checkIdCell:@"idCellHelp"]){
            return 0.0;
        }
    }

    if([identifierCell isEqualToString:@"idCellTerms"]){
        if (![self checkIdCell:@"idCellTerms"]){
            return 0.0;
        }
    }

    if([identifierCell isEqualToString:@"idCellPrivacy"] ){
        if ( ![self checkIdCell:@"idCellPrivacy"]){
            return 0.0;
        }
    }

    CGFloat height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    //NSLog(@"Section h %f", rowHeight);
    return height;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell=(UITableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"identifier: %@",[cell reuseIdentifier]);
    NSString *theString = [cell reuseIdentifier];
    
    if([theString isEqualToString:@"idCellUser"]){
        //[self performSegueWithIdentifier:@"toProfileUser" sender:self];
    }
    else if([theString isEqualToString:@"idCellProfile"]){
       // [self didTapImage];
    }
    else if([theString isEqualToString:@"idCellCreated"]){
        listMode = @"CREATED";
        rowSelected =  self.labelCreati.text;
        listProducts = listProductsCreated;
        [self performSegueWithIdentifier:@"toProfileListProducts" sender:self];
    }
    else if([theString isEqualToString:@"idCellLiked"]){
        listMode = @"LIKED";
        rowSelected =  self.labelPiaciuti.text;
        listProducts = listProductsLiked;
        [self performSegueWithIdentifier:@"toProfileListProducts" sender:self];
    }
    else if([theString isEqualToString:@"idCellFacebook"]){
        //[self agganciaSganciaFacebook];
    }
    else if([theString isEqualToString:@"idCellChat"]){
        if (self.applicationContext.loggedUser){
            [self sendMessage];
        }else{
            [self goToAuthentication];
        }
    }
    else if([theString isEqualToString:@"idCellLogout"]){
        NSLog(@"LOGOUT");
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"SignoutAlertLKey", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"CancelLKey", nil) otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    else if([theString isEqualToString:@"idCellPhone"]){
        [self callTelephone];
    }
}


-(void)callTelephone{
    if(self.user.numberPhone!=nil && self.user.numberPhone.length>0){
        NSString *phoneNumber = [@"telprompt://" stringByAppendingString:self.user.numberPhone];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"toProfileListProducts"]) {
        SHPProfileListProducts *vc = (SHPProfileListProducts *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.user = self.user;
        vc.titleView = rowSelected;
        vc.listMode = listMode;
        vc.listAllProducts = listProducts;
    }
    else if ([[segue identifier] isEqualToString:@"toChangePassword"]) {
        SHPModifyProfileTVC *vc = (SHPModifyProfileTVC *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.user = self.user;
        vc.modifyType = @"password";
    }
    else if ([[segue identifier] isEqualToString:@"toModifyFullName"]) {
        SHPModifyProfileTVC *vc = (SHPModifyProfileTVC *)[segue destinationViewController];
        vc.applicationContext = self.applicationContext;
        vc.user = self.user;
        vc.modifyType = @"fullName";
    }
}
//----------------------------------------------------------------//
//END BUILD TABLEVIEW
//----------------------------------------------------------------//
-(void)goToBack{
    NSLog(@"\n goToBack");
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
}


-(void)goToAuthentication{
    //NSLog(@"goToAuthentication");
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Authentication" bundle:nil];
    SHPAuthenticationVC *vc = (SHPAuthenticationVC *)[sb instantiateViewControllerWithIdentifier:@"StartAuthentication"];
    vc.applicationContext = self.applicationContext;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;//UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:NULL];
}


- (IBAction)unwindToHomeProfileTVC:(UIStoryboardSegue*)sender{
    self.labelUserNameComplete.text = self.user.fullName;
    [self.tableView reloadData];
    if ([sender isKindOfClass:[SHPModifyProfileTVC class]]) {
        NSLog(@"unwindToHomeProfileTVC: %@ ", sender);
    }
}

-(void)dealloc {
    NSLog(@"SIGNIN DEALLOCATING");
    [self.loaderUser setDelegate:nil];
    //[self.verify setDelegate:nil];
}

@end
