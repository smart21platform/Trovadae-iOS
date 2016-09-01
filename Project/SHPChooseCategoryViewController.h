//
//  SHPChooseCategoryViewController.h
//  Shopper
//
//  Created by andrea sponziello on 09/08/12.
//
//

#import <UIKit/UIKit.h>
#import "SHPModalCallerDelegate.h"
#import "SHPCategoryDCDelegate.h"
#import "SHPActivityViewController.h"
#import "SHPNetworkErrorViewController.h"

@class SHPCategoryDC;
@class SHPCategory;
@class SHPApplicationContext;

@interface SHPChooseCategoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) id <SHPModalCallerDelegate> modalCallerDelegate;
//@property (strong, nonatomic) SHPCategoryDC *categoryDC;
@property (strong, nonatomic) NSMutableArray *categories;
@property (assign, nonatomic) BOOL showCategoryAll;
@property (strong, nonatomic) SHPCategory *selectedCategory;
@property (strong, nonatomic) SHPActivityViewController *activityController;
@property (strong, nonatomic) SHPNetworkErrorViewController *errorController;
@property (weak, nonatomic) SHPApplicationContext *applicationContext;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;

- (IBAction)dismissAction:(id)sender;

@end
