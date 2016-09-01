//
//  SHPSignInTVC.h
//  Sogliano Cavour
//
//  Created by dario de pascalis on 27/03/15.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;
@class SHPUser;
@class MBProgressHUD;

@interface SHPSignInTVC : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    int USERNAME_MIN_LENGTH;
    int PASSWORD_MIN_LENGTH;
    int NAME_MIN_LENGTH;
    NSString *usernameValue;
    NSString *nameValue;
    NSString *emailValue;
    NSString *passwordValue;
    NSString *currentValidationError;
    
    NSURLConnection *currentConnection;
    NSMutableData *receivedData;
    NSInteger statusCode;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPUser *userFB;
@property (strong, nonatomic) NSString *emailUser;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (strong, nonatomic) NSString *fbUserEmail;
@property (strong, nonatomic) NSString *fbName;
@property (strong, nonatomic) NSString *fbUserId;
@property (strong, nonatomic) NSString *fbUsername;
@property (strong, nonatomic) NSString *fbPictureUrl;
@property (strong, nonatomic) UIImage *fbProfileImage;
@property (strong, nonatomic) NSString *fbAccessToken;

// TAKE PHOTO SECTION
@property (nonatomic, strong) UIActionSheet *takePhotoMenu;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIImagePickerController *photoLibraryController;
@property (nonatomic, strong) UIImage *image;

@property (weak, nonatomic) IBOutlet UIView *viewError;
@property (weak, nonatomic) IBOutlet UILabel *labelError;
@property (weak, nonatomic) IBOutlet UIView *viewHeader;
@property (weak, nonatomic) IBOutlet UIImageView *imageFirstBackground;
@property (weak, nonatomic) IBOutlet UIImageView *imageBackground;
@property (weak, nonatomic) IBOutlet UIView *viewPhotoUser;
@property (weak, nonatomic) IBOutlet UIImageView *imageProfile;
@property (weak, nonatomic) IBOutlet UILabel *labelPhoto;
@property (weak, nonatomic) IBOutlet UIImageView *imageEmail;
@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UIImageView *imageUsername;
@property (weak, nonatomic) IBOutlet UITextField *textUsername;
@property (weak, nonatomic) IBOutlet UIImageView *imagePassword;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UIImageView *imageNameComplete;
@property (weak, nonatomic) IBOutlet UITextField *textNameComplete;
@property (weak, nonatomic) IBOutlet UITextField *textTelephone;
@property (weak, nonatomic) IBOutlet UISwitch *switchPrivacy;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonNext;
@property (weak, nonatomic) IBOutlet UIButton *buttonPrivacy;


- (IBAction)actionPrivacyWebPage:(id)sender;
- (IBAction)actionNext:(id)sender;
- (IBAction)actionPrivacy:(id)sender;
- (IBAction)actionPrevious:(id)sender;
@end
