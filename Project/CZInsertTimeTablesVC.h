//
//  CZInsertTimeTablesVC.h
//  TrovaDAE
//
//  Created by Dario De Pascalis on 10/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CZInsertTimeTablesTVC;

@interface CZInsertTimeTablesVC : UIViewController{
    CZInsertTimeTablesTVC *containerTVC;
}

@property (strong, nonatomic) NSString *orari;
@property (strong, nonatomic) NSString *day;
@property (assign, nonatomic) NSInteger numberDay;
//@property (assign, nonatomic) NSInteger numberInterval;

@property (weak, nonatomic) IBOutlet UILabel *labelDay;
@property (weak, nonatomic) IBOutlet UILabel *labelStatus;
@property (weak, nonatomic) IBOutlet UISwitch *switchOpen;


- (IBAction)actionSwitchOpen:(UISwitch *)sender;
- (IBAction)actionClose:(id)sender;


@end
