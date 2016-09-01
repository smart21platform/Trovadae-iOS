//
//  SHPHomeProfileTVC.h
//  Italiacamp
//
//  Created by dario de pascalis on 08/05/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPUserDC.h"
#import "SHPVerifyUploadPermissionsDC.h"
#import "CZAuthenticationDC.h"
//#import "ChatImageCache.h"
//#import "ChatImageWrapper.h"

@class SHPApplicationContext;
@class SHPUser;
@class MBProgressHUD;

@interface SHPHomeProfileTVC : UITableViewController<CZAuthenticationDelegate, SHPUserDCDelegate, SHPVerifyUploadPermissionsDCDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
{
    CZAuthenticationDC *DC;
    NSString *listMode;
    NSString *rowSelected;
    BOOL isLoadingData;
    NSMutableArray *listProducts;
    NSMutableArray *listProductsLiked;
    NSMutableArray *listProductsCreated;
    MBProgressHUD *hud;
    CGFloat defaultH;
    NSDictionary *menuDictionary;
    BOOL publicUpload;
    CGFloat startAlphaTrasparentBckBlack;
    SHPUser *loggedUser;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPUser *user;
@property (strong, nonatomic) SHPUserDC *loaderUser;

// user photo section
//@property (strong, nonatomic) ChatImageCache *imageCache;
@property (strong, nonatomic) UIImage *userImage;
@property (strong, nonatomic) UIImage *backupUserImage;
@property (strong, nonatomic) UIActionSheet *takePhotoMenu;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImagePickerController *photoLibraryController;
@property (nonatomic, strong) NSURLConnection *currentConnection;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (weak, nonatomic) IBOutlet UIView *viewBoxImage;
@property (nonatomic, assign) NSInteger statusCode;
// end user photo section
@property (weak, nonatomic) IBOutlet UILabel *labelChangePsw;

@property (weak, nonatomic) IBOutlet UILabel *labelCreati;
@property (weak, nonatomic) IBOutlet UILabel *labelNumberCreated;
@property (weak, nonatomic) IBOutlet UILabel *labelPiaciuti;
@property (weak, nonatomic) IBOutlet UILabel *labelNumberLiked;
@property (weak, nonatomic) IBOutlet UILabel *labelHookFacebook;
@property (weak, nonatomic) IBOutlet UILabel *labelModificaProfilo;
@property (weak, nonatomic) IBOutlet UILabel *labelLogout;
@property (weak, nonatomic) IBOutlet UIImageView *imageBckDw;
@property (weak, nonatomic) IBOutlet UIImageView *imageBckUp;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelUserNameComplete;
@property (weak, nonatomic) IBOutlet UILabel *labelUsername;
@property (weak, nonatomic) IBOutlet UILabel *labelChat;
@property (weak, nonatomic) IBOutlet UILabel *labelTelefono;

@property (strong, nonatomic) SHPUser *otherUser;

- (IBAction)unwindToHomeProfileTVC:(UIStoryboardSegue*)sender;
@end
