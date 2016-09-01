//
//  SHPSignInStepEmailVC.h
//  Sogliano Cavour
//
//  Created by dario de pascalis on 30/03/15.
//
//

#import <UIKit/UIKit.h>
#import "SHPAuthServiceDCDelegate.h"

@class SHPApplicationContext;
@class MBProgressHUD;
@class SHPUser;
@class SHPAuthServiceDC;

@interface SHPSignInStepEmailVC : UIViewController <UITextFieldDelegate, SHPAuthServiceDCDelegate>

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) SHPAuthServiceDC *authDC;
@property (strong, nonatomic) SHPUser *userFB;
@property (assign, nonatomic) BOOL disableButtonClose;

@property (strong, nonatomic) NSString *fbUserEmail;
@property (strong, nonatomic) NSString *fbName;
@property (strong, nonatomic) NSString *fbUserId;
@property (strong, nonatomic) NSString *fbUsername;
@property (strong, nonatomic) NSString *fbPictureUrl;
@property (strong, nonatomic) UIImage *fbProfileImage;
@property (strong, nonatomic) NSString *fbAccessToken;

@property (weak, nonatomic) IBOutlet UILabel *labelHeaderTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelHeaderDescription;
@property (weak, nonatomic) IBOutlet UIButton *buttonIscriviti;
@property (weak, nonatomic) IBOutlet UIButton *buttonAccedi;
@property (weak, nonatomic) IBOutlet UITextField *textEmail;
@property (weak, nonatomic) IBOutlet UIView *viewError;
@property (weak, nonatomic) IBOutlet UILabel *labelError;
@property (weak, nonatomic) IBOutlet UIButton *buttonFacebook;
@property (weak, nonatomic) IBOutlet UIButton *buttonNext;
@property (weak, nonatomic) IBOutlet UIButton *buttonClose;

- (IBAction)actionAccedi:(id)sender;
- (IBAction)actionNext:(id)sender;
- (IBAction)actionFacebook:(id)sender;
- (IBAction)actionIscriviti:(id)sender;

- (IBAction)actionClose:(id)sender;
@end
