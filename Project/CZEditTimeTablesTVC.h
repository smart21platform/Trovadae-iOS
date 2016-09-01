//
//  CZEditTimeTablesTVC.h
//  TrovaDAE
//
//  Created by Dario De Pascalis on 10/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CZEditTimeTablesVC.h"

@interface CZEditTimeTablesTVC : UITableViewController{
    
}


@property (weak, nonatomic) CZEditTimeTablesVC *vc;
@property (strong, nonatomic) NSMutableArray *arrayDictionaryDay;
@property (strong, nonatomic) NSArray *arrayWeekDay;


- (void)initialize;
- (void)refreshTable;
@end
