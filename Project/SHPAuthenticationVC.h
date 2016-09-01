//
//  SHPAuthenticationVC.h
//  Sogliano Cavour
//
//  Created by dario de pascalis on 26/03/15.
//
//

#import <UIKit/UIKit.h>
#import "SHPSigninServiceDC.h"
#import "SHPAuthServiceDCDelegate.h"


@class SHPApplicationContext;
@class MBProgressHUD;
@class SHPAuthServiceDC;
@class SHPUser;

@protocol UIViewController
-(void)authServiceDCErrorWithCode:(NSString *)code;
@end

@interface SHPAuthenticationVC : UIViewController <UITextFieldDelegate, SHPSigninServiceDCDelegate, SHPAuthServiceDCDelegate>

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
@property (weak, nonatomic) IBOutlet UITextField *textUsername;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UIButton *buttonRemember;
@property (weak, nonatomic) IBOutlet UIButton *buttonFacebook;
@property (weak, nonatomic) IBOutlet UIButton *buttonEnter;
@property (weak, nonatomic) IBOutlet UIView *viewError;
@property (weak, nonatomic) IBOutlet UILabel *labelError;
@property (weak, nonatomic) IBOutlet UIButton *buttonClose;

- (IBAction)actionFacebook:(id)sender;
- (IBAction)actionRemember:(id)sender;
- (IBAction)actionIscriviti:(id)sender;
- (IBAction)actionEnter:(id)sender;
- (IBAction)actionClose:(id)sender;

- (IBAction)unwindToAuthentication:(UIStoryboardSegue *)segue;
@end
