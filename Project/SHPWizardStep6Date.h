//
//  SHPWizardStep6Date.h
//  Galatina
//
//  Created by dario de pascalis on 19/02/15.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;
@class SHPCategory;
@class SHPWizardHelper;

@interface SHPWizardStep6Date : UITableViewController<UIPickerViewDelegate, UIPickerViewDataSource>{
    NSDictionary *typeDictionary;
    NSString *typeSelected;
    NSDictionary *dictionaryNextStep;
}
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;
@property (strong, nonatomic) SHPWizardHelper *wh;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *startDateValueLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UILabel *endDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *endDateValueLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *durationPicker;
@property (weak, nonatomic) IBOutlet UILabel *durationValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageStartDate;
@property (weak, nonatomic) IBOutlet UIImageView *imageEndDate;
@property (weak, nonatomic) IBOutlet UIButton *buttonCellNext;

@property (strong, nonatomic) NSString *errorMessage;
@property (strong, nonatomic) NSString *selectedStartDateAsStringToSend;
@property (strong, nonatomic) NSString *selectedEndDateAsStringToSend;
@property (strong, nonatomic) NSDate *selectedStartDateAsDate;
@property (strong, nonatomic) NSDate *selectedEndDateAsDate;
@property (strong, nonatomic) NSDate *prevStartDate;
@property (nonatomic, strong) UIImageView *titleLogo;

- (IBAction)dateAction:(id)sender;
- (IBAction)nextAction:(id)sender;
- (IBAction)actionButtonCellNext:(id)sender;
@end
