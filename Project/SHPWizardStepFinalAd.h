//
//  SHPWizardStepFinalAd.h
//  Salve Smart
//
//  Created by Dario De Pascalis on 22/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPApplicationContext.h"
#import "MBProgressHUD.h"
#import "SHPProductUploaderDC.h"
#import "SHPProductUpdateDC.h"
#import <CoreLocation/CoreLocation.h>

@class SHPCategory;

@interface SHPWizardStepFinalAd : UITableViewController <UITextViewDelegate, UITextFieldDelegate,CLLocationManagerDelegate>
{
    NSDictionary *typeDictionary;
    BOOL opened;
    NSString *typeSelected;
    NSString *kPlaceholderDescription;
    NSString *descriptionPost;
    NSString *titlePost;
    BOOL selectingDate;
    BOOL selectingDuration;
    NSDateFormatter *dateFormatter;
    MBProgressHUD *hud;
    NSString *placeholderDuration;
    NSString *placeholderDate;
    NSString *properties;
    NSString *lat;
    NSString *lon;
    NSString *dateEnd;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;
@property (strong, nonatomic) SHPProductUploaderDC *uploaderDC;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UILabel *labelHeaderDescription;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadButton;
@property (weak, nonatomic) IBOutlet UITextField *telephoneNumberTextField;
@property (weak, nonatomic) IBOutlet UITextField *textFieldEmail;
@property (weak, nonatomic) IBOutlet UILabel *telephoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonCellNext;
@property (weak, nonatomic) IBOutlet UILabel *labelDate;

@property (weak, nonatomic) IBOutlet UITextField *textFieldPartenza;
@property (weak, nonatomic) IBOutlet UITextField *textFieldDestinazione;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerDuration;
@property (weak, nonatomic) IBOutlet UILabel *labelDuration;

- (IBAction)actionDatePicker:(id)sender;
- (IBAction)actionDatePickerDuration:(id)sender;
- (IBAction)actionPubblica:(id)sender;
- (IBAction)actionPubblicaUp:(id)sender;

@end
