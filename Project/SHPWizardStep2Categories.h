//
//  SHPWizardStep2Categories.h
//  Galatina
//
//  Created by dario de pascalis on 17/02/15.
//
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;
@class SHPCategory;

@interface SHPWizardStep2Categories : UITableViewController{
    NSDictionary *configDictionary;
    NSString *tenantName;
    UIColor *selectedCellBGColor;
    NSString *typeSelected;
    NSString *otypeReport;
}
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (assign, nonatomic) NSUInteger levelCategory;
@property (assign,nonatomic) BOOL backActionClose;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *buttonBack;

@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;


@end
