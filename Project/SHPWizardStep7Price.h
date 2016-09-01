//
//  SHPWizardStep7Price.h
//  Galatina
//
//  Created by dario de pascalis on 20/02/15.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;
@class  SHPCategory;

@interface SHPWizardStep7Price : UITableViewController <UITextFieldDelegate, UIAlertViewDelegate>
{
    NSDictionary *typeDictionary;
    NSString *typeSelected;
    NSDictionary *dictionaryNextStep;
    float price_num;
    float start_price_num;
    BOOL opened;
    BOOL valid;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;
@property (strong, nonatomic) UIImageView *titleLogo;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UILabel *freeLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelPriceText;
@property (weak, nonatomic) IBOutlet UILabel *labelStartPriceText;
@property (weak, nonatomic) IBOutlet UITextField *priceTextView;
@property (weak, nonatomic) IBOutlet UITextField *startPriceTextView;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *adviceMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *percPrice;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *currencyDiscountLabel;
@property (weak, nonatomic) IBOutlet UIButton *buttonCellNext;
@property (weak, nonatomic) IBOutlet UIButton *buttonAddDiscount;

- (IBAction)actionAddDiscount:(id)sender;

- (IBAction)actionButtonCellNext:(id)sender;
//- (IBAction)priceEditingChanged:(id)sender;
//- (IBAction)nextAction:(id)sender;
@end