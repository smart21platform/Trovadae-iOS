//
//  CZEditTimeTablesVC.h
//  TrovaDAE
//
//  Created by Dario De Pascalis on 10/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SHPProductUploaderDC.h"
@class SHPApplicationContext;
@class SHPProduct;
@class CZEditTimeTablesTVC;

@interface CZEditTimeTablesVC : UIViewController<SHPProductUploaderDelegate>{
    CZEditTimeTablesTVC *containerTVC;
    NSMutableArray *arrayDictionaryDay;
    MBProgressHUD *hud;
    NSString *properties;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPProduct *product;
@property (strong, nonatomic) NSString *plan;
@property (strong, nonatomic) NSString *orari;
@property (assign, nonatomic) NSInteger numberDay;
@property (strong, nonatomic) NSArray *arrayWeekDay;
@property (strong, nonatomic) SHPProductUploaderDC *uploaderDC;
@property (assign, nonatomic) BOOL modalView;

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;
@property (weak, nonatomic) IBOutlet UIButton *buttonClose;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonClose;


- (void)goToInsertTime;

- (IBAction)actionClose:(id)sender;
- (IBAction)actionSave:(id)sender;
- (IBAction)unwindToCZEditTimeTablesVC:(UIStoryboardSegue*)sender;

@end
