//
//  SHPExploreSubLevelTableViewController.h
//  AnimaeCuore
//
//  Created by Dario De Pascalis on 12/06/14.
//
//

#import <UIKit/UIKit.h>

@class SHPApplicationContext;
@class SHPCategory;

@interface SHPExploreSubLevelTableViewController : UITableViewController

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) UIViewController *callerViewController;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) SHPCategory *selectedCategory;

@end
