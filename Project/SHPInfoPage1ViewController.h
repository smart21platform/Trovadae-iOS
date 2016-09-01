//
//  SHPInfoPage1ViewController.h
//  Dressique
//
//  Created by andrea sponziello on 21/03/13.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;

@interface SHPInfoPage1ViewController : UIViewController{
    NSString *urlWebSite;
    UIColor *tintColor;
    UIColor *colorBackground;
    NSString *claim;
    NSString *email;
    NSString *phoneNumber;
    NSString *smartphoneNumber;
    NSString *copyright;
    NSString *urlMoreInfo;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

- (IBAction)DoneAction:(id)sender;
- (IBAction)CloseButtonAction:(id)sender;

@property (weak, nonatomic) IBOutlet UIImageView *imageLogo;
@property (weak, nonatomic) IBOutlet UILabel *labelCopyright;
@property (weak, nonatomic) IBOutlet UILabel *labelVersion;
@property (weak, nonatomic) IBOutlet UIButton *buttonCell1;
@property (weak, nonatomic) IBOutlet UIButton *buttonCell2;
@property (weak, nonatomic) IBOutlet UIButton *buttonEmail;
@property (weak, nonatomic) IBOutlet UIButton *buttonWebPage;
@property (weak, nonatomic) IBOutlet UIButton *buttonWebSiteApp;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *close;
@property (weak, nonatomic) IBOutlet UILabel *labelClaim;
@property (weak, nonatomic) IBOutlet UIButton *labelMoreInfo;

- (IBAction)actionPhoneNumber1:(id)sender;
- (IBAction)actionPhoneNumber2:(id)sender;

- (IBAction)actionToWebSite:(id)sender;
- (IBAction)actionMoreInfo:(id)sender;

- (IBAction)emailAction:(id)sender;
- (IBAction)websiteAction:(id)sender;
@end
