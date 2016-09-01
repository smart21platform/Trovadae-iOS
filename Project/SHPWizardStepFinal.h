//
//  SHPWizardStepFinal.h
//  Galatina
//
//  Created by dario de pascalis on 21/02/15.
//
//

#import <UIKit/UIKit.h>
#import "SHPShopsLoadedDCDelegate.h"

@class SHPApplicationContext;
@class SHPCategory;
@class SHPProductUploaderDC;
@class SHPShop;
@class SHPShopDC;
@class MBProgressHUD;

@interface SHPWizardStepFinal : UITableViewController <SHPShopsLoadedDCDelegate, UITextViewDelegate, UITextFieldDelegate>{
    NSDictionary *typeDictionary;
    NSString *typeSelected;
    NSDictionary *dictionaryNextStep;
    BOOL opened;
    BOOL singlePoi;
    
    NSString *shopOid;
    MBProgressHUD *hud;
    NSString *titlePost;
    NSString *descriptionPost;
    NSString *labelDurate;
    
    NSNumber *startPriceNum;
    NSString *price_text_start;
    NSNumber *endPriceNum;
    NSString *price_text_end;
    NSString *kPlaceholderDescription;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;

@property (strong, nonatomic) SHPShop *selectedShop;
@property (strong, nonatomic) SHPShopDC *shopDC;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (weak, nonatomic) IBOutlet UILabel *labelHeader;
@property (strong, nonatomic) SHPProductUploaderDC *uploaderDC;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *buttonAddDescription;

@property (weak, nonatomic) IBOutlet UILabel *labelValidita;
@property (weak, nonatomic) IBOutlet UILabel *ShopAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *shopLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *startPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *dealLabel;
@property (weak, nonatomic) IBOutlet UILabel *endPriceLabel;

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateStartLabel;

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
//@property (weak, nonatomic) IBOutlet UISwitch *facebookSwitch;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadButton;
//@property (weak, nonatomic) IBOutlet UIButton *changeFacebookAccountButton;
@property (weak, nonatomic) IBOutlet UISwitch *switchFBAccount;

@property (weak, nonatomic) IBOutlet UIImageView *fbImageView;
@property (weak, nonatomic) IBOutlet UITextField *telephoneNumberTextField;
@property (strong, nonatomic) NSString *telephoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *telephoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *shareOnLabel;

@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;

@property (nonatomic, strong) UIImageView *titleLogo;
@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonCellNext;

- (IBAction)uploadAction:(id)sender;
- (IBAction)actionButtonCellNext:(id)sender;
- (IBAction)actionButtonAddDescription:(id)sender;
- (IBAction)actionSwitchFBAccount:(id)sender;



@end
