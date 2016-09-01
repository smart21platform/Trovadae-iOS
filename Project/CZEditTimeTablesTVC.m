//
//  CZEditTimeTablesTVC.m
//  TrovaDAE
//
//  Created by Dario De Pascalis on 10/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "CZEditTimeTablesTVC.h"

@interface CZEditTimeTablesTVC ()

@end

@implementation CZEditTimeTablesTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.plan = @"1>09:00-13:00;16:00-20:00|2>09:00-13:00;16:00-20:00|4>09:00-13:05;14:50-18:00;19:50-22:00|6>09:00-10:27;17:00-19:00"; // 1: Sunday, 2: Monday, 3: Tuesday
    NSLog(@"arrayDictionaryDay::: %@",self.arrayDictionaryDay);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initialize{
    
}

- (void)refreshTable{
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellDay" forIndexPath:indexPath];
    NSInteger index = indexPath.row;
    UILabel *labelDay = (UILabel *)[cell viewWithTag:10];
    labelDay.text = [self.arrayWeekDay objectAtIndex:index];
    UILabel *labelOrari = (UILabel *)[cell viewWithTag:11];
    NSString *orariApretura = [self replaceTimesTable:[self getTimeTable:index]];
    labelOrari.text = orariApretura;
    if(self.vc.modalView == YES){
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSLog(@"PREMO %@", indexPath);
    if(self.vc.modalView == NO){
        NSInteger index = indexPath.row;
        self.vc.orari = [self getTimeTable:index];
        self.vc.numberDay = index;
        [self.vc goToInsertTime];
    }
}





- (NSString *)replaceTimesTable:(NSString *)timeTableDay{
    if([timeTableDay isEqualToString:@""]){
        timeTableDay = @"CHIUSO";
    }else{
        timeTableDay = [timeTableDay substringWithRange: NSMakeRange(1, timeTableDay.length-1)];
        timeTableDay = [timeTableDay stringByReplacingOccurrencesOfString:@">" withString:@"aperto dalle "];
        timeTableDay = [timeTableDay stringByReplacingOccurrencesOfString:@"-" withString:@" alle "];
        timeTableDay = [timeTableDay stringByReplacingOccurrencesOfString:@";" withString:@" e dalle "];
    }
    return timeTableDay;
}

- (NSString *)getTimeTable:(NSInteger)index{
    NSDictionary *times = self.arrayDictionaryDay[index];
    return [times valueForKey:@"orari"];
}



@end
