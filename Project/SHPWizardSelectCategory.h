//
//  SHPWizardSelectCategory.h
//  Mercatino
//
//  Created by Dario De Pascalis on 19/01/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SHPApplicationContext;
@class SHPCategory;

@interface SHPWizardSelectCategory : UITableViewController{
    NSDictionary *configDictionary;
    NSString *tenantName;
    UIColor *selectedCellBGColor;
    NSString *typeSelected;
    NSString *otypeReport;
    NSArray *cachedCategories;
}
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (weak, nonatomic) IBOutlet UILabel *topMessageLabel;

@end
