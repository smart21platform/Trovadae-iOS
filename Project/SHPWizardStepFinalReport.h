//
//  SHPWizardStepFinalReport.h
//  Salve Smart
//
//  Created by Dario De Pascalis on 20/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPShopsLoadedDCDelegate.h"
#import "MBProgressHUD.h"
#import "SHPProductUpdateDC.h"
#import "SHPProductUploaderDC.h"


@class SHPApplicationContext;
@class SHPCategory;
@class SHPShop;

@interface SHPWizardStepFinalReport : UITableViewController <SHPShopsLoadedDCDelegate, UITextViewDelegate, UITextFieldDelegate>{
    NSString *typeSelected;
    NSString *kPlaceholderDescription;
    NSString *descriptionPost;
    BOOL opened;
    NSString *urlImgPoiMap;
    MBProgressHUD *hud;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;

@property (strong, nonatomic) SHPShop *selectedShop;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSString *telephoneNumber;
@property (strong, nonatomic) UIImage *imageMap;

@property (strong, nonatomic) SHPProductUploaderDC *uploaderDC;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UIButton *buttonAddDescription;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewMap;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *uploadButton;
@property (weak, nonatomic) IBOutlet UITextField *telephoneNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *telephoneNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonCellNext;

- (IBAction)uploadAction:(id)sender;
- (IBAction)actionButtonCellNext:(id)sender;
- (IBAction)actionButtonAddDescription:(id)sender;




@end

