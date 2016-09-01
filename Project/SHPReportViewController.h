//
//  SHPReportViewController.h
//  Dressique
//
//  Created by andrea sponziello on 24/01/13.
//
//

#import <UIKit/UIKit.h>
#import "SHPModalCallerDelegate.h"
#import "SHPReportDC.h"

@class SHPProduct;
@class SHPApplicationContext;
@class SHPReportAbuseItem;
@class MBProgressHUD;

@interface SHPReportViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, SHPReportDCDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (strong, nonatomic) id modalCallerDelegate;
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPProduct *product;
@property (strong, nonatomic) SHPReportDC *dc;

@property (strong, nonatomic) NSMutableArray *reportItems;
@property (strong, nonatomic) SHPReportAbuseItem *selectedItem;
@property (strong, nonatomic) NSString *selectedItemText;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *ReportButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *CancelButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) MBProgressHUD *hud;

- (IBAction)ReportAction:(id)sender;
- (IBAction)CancelAction:(id)sender;

@end
