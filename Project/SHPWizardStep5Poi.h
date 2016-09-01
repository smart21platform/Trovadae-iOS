//
//  SHPWizardStep5Poi.h
//  Galatina
//
//  Created by dario de pascalis on 18/02/15.
//
//

#import <UIKit/UIKit.h>
#import "SHPModalCallerDelegate.h"
#import "SHPShopsLoadedDCDelegate.h"

@class SHPCategory;
@class SHPApplicationContext;
@class SHPShop;

@interface SHPWizardStep5Poi : UITableViewController <SHPModalCallerDelegate, SHPShopsLoadedDCDelegate>{
    NSDictionary *typeDictionary;
    NSString *typeSelected;
    //NSDictionary *dictionaryNextStep;
}
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (strong, nonatomic) NSMutableDictionary *wizardDictionary;
@property (strong, nonatomic) SHPShop *selectedShop;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedShopLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopAddress;
@property (weak, nonatomic) IBOutlet UIButton *buttonCellNext;
@property (weak, nonatomic) IBOutlet UIButton *buttonChange;

- (IBAction)actionButtonCellNext:(id)sender;
- (IBAction)actionButtonChange:(id)sender;
- (IBAction)actionNext:(id)sender;

- (IBAction)unwindToWizardStep5Poi:(UIStoryboardSegue*)sender;
@end
