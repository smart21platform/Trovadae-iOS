//
//  SHPWizardLandingPageTVC.h
//  Mercatino
//
//  Created by Dario De Pascalis on 18/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
#import "SHPProductUploaderDC.h"
@class SHPApplicationContext;
@class SHPCategory;

@interface SHPWizardLandingPageTVC : UITableViewController<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate>{
    NSDictionary *configDictionary;
    NSString *tenantName;
    NSString *otypeReport;
    UIActionSheet *takePhotoMenu;
    MBProgressHUD *hud;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (strong, nonatomic) SHPProductUploaderDC *uploaderDC;
//@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImagePickerController *photoLibraryController;
@property (nonatomic, strong) UIImage *scaledImage;
@property (strong, nonatomic) UIImage *bigImage;
@property (weak, nonatomic) IBOutlet UITextField *textFieldPrice;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDescription;
@property (weak, nonatomic) IBOutlet UITextView *textViewDescription;
@property (weak, nonatomic) IBOutlet UITextField *textFieldTel;
@property (weak, nonatomic) IBOutlet UILabel *labelCity;
@property (weak, nonatomic) IBOutlet UILabel *labelCategory;


@property (weak, nonatomic) IBOutlet UITextField *textFieldTitle;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewPhoto;
@property (weak, nonatomic) IBOutlet UIButton *buttonAddPhoto;
@property (weak, nonatomic) IBOutlet UISwitch *switchFBAccount;
@property (weak, nonatomic) IBOutlet UIButton *buttonUpload;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonPublish;
- (IBAction)actionBarButtonPublish:(id)sender;
- (IBAction)actionAddPhoto:(id)sender;
- (IBAction)actionUpload:(id)sender;
- (IBAction)actionClose:(id)sender;
- (IBAction)unwindToWizardLandingPageTVC:(UIStoryboardSegue *)segue;

@end
