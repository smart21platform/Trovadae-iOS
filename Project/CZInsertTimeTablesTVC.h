//
//  CZInsertTimeTablesTVC.h
//  TrovaDAE
//
//  Created by Dario De Pascalis on 14/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CZInsertTimeTablesVC;

@interface CZInsertTimeTablesTVC : UITableViewController{
    NSInteger currentSelection;
    CGFloat newCellHeight;
}

@property (weak, nonatomic) CZInsertTimeTablesVC *vc;
@property (strong, nonatomic) NSString *orari;
@property (assign, nonatomic) NSInteger numberDay;
@property (strong, nonatomic) NSMutableArray *dateArray;
@property (weak, nonatomic) IBOutlet UILabel *labelAddCancelTime;

@property (weak, nonatomic) IBOutlet UILabel *labelDalleStep1;
@property (weak, nonatomic) IBOutlet UILabel *labelAlleStep1;
@property (weak, nonatomic) IBOutlet UILabel *labelDalleStep2;
@property (weak, nonatomic) IBOutlet UILabel *labelAlleStep2;
@property (weak, nonatomic) IBOutlet UILabel *labelDalle;
@property (weak, nonatomic) IBOutlet UILabel *labelAlle;

@property (weak, nonatomic) IBOutlet UIDatePicker *dataPikerDalleStep1;
@property (weak, nonatomic) IBOutlet UIDatePicker *dataPikerAlleStep2;
@property (weak, nonatomic) IBOutlet UIDatePicker *dataPikerDalleStep2;
@property (weak, nonatomic) IBOutlet UIDatePicker *dataPikerAlleStep1;
@property (weak, nonatomic) IBOutlet UIButton *buttonAdd;

- (IBAction)actionAdd:(id)sender;
- (IBAction)actionDelete:(id)sender;

- (void)refreshTable;
- (void)intArrayOrari;
- (void)createStringOrari;
- (void)removeLastObjectArrayOrari;
- (void)addNewObjectArrayOrari;
@end
