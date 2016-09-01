//
//  SHPWizardStep1Categories.h
//  Galatina
//
//  Created by dario de pascalis on 16/02/15.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;
@class SHPCategory;

@interface SHPWizardStep1Types : UITableViewController{
    NSDictionary *configDictionary;
    NSString *tenantName;
    UIColor *selectedCellBGColor;
    NSMutableArray *arrayType;
    NSString *otypeReport;
}
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (assign, nonatomic) NSUInteger levelCategory;
@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonCancel;
@property (strong, nonatomic) NSString *typeSelected;

- (IBAction)actionCancel:(id)sender;
@end
