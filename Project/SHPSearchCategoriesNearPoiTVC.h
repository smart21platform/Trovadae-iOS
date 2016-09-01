//
//  SHPSearchCategoriesNearPoiTVC.h
//  Coricciati MG
//
//  Created by Dario De Pascalis on 06/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPApplicationContext.h"
#import "SHPShop.h"
#import "SHPCategory.h"

@interface SHPSearchCategoriesNearPoiTVC : UITableViewController{
    NSMutableArray *categories;
    SHPCategory *selectedCategory;
    CLLocation *nearLocation;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPShop *nearPoi;
@property (weak, nonatomic) IBOutlet UILabel *labelHeader;

@end
