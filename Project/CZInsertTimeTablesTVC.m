//
//  CZInsertTimeTablesTVC.m
//  TrovaDAE
//
//  Created by Dario De Pascalis on 14/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "CZInsertTimeTablesTVC.h"
#import "CZInsertTimeTablesVC.h"
#import "SHPImageUtil.h"

@interface CZInsertTimeTablesTVC ()

@end

@implementation CZInsertTimeTablesTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    currentSelection = -1;
    self.dataPikerDalleStep1.tag = 1;
    self.dataPikerAlleStep1.tag = 2;
    self.dataPikerDalleStep2.tag = 3;
    self.dataPikerAlleStep2.tag = 4;
    [self.dataPikerDalleStep1 addTarget:self action:@selector(dateChanged:)forControlEvents:UIControlEventValueChanged];
    [self.dataPikerAlleStep1 addTarget:self action:@selector(dateChanged:)forControlEvents:UIControlEventValueChanged];
    [self.dataPikerDalleStep2 addTarget:self action:@selector(dateChanged:)forControlEvents:UIControlEventValueChanged];
    [self.dataPikerAlleStep2 addTarget:self action:@selector(dateChanged:)forControlEvents:UIControlEventValueChanged];
    //[self intArrayOrari];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)refreshTable {
    [self checkStatusButton];
    [self.tableView reloadData];
}

- (void)intArrayOrari{
    NSLog(@"intArrayOrari orari %@", self.orari);
    if(self.orari.length>0){
        NSString *orariApertura = [self.orari substringWithRange: NSMakeRange(2, self.orari.length-2)];
        self.dateArray = [NSMutableArray arrayWithArray:[orariApertura componentsSeparatedByString: @";"]];
        NSLog(@" intArrayOrari dateArray:: %@",self.dateArray);
        [self setValueDataPiker];
    }else{
        self.dateArray = [[NSMutableArray alloc]init];
    }
}

- (void)removeLastObjectArrayOrari{
    [self.dateArray removeLastObject];
    [self createStringOrari];
     NSLog(@" removeLastObjectArrayOrari dateArray:: %@",self.dateArray);
     [self refreshTable];
}

- (void)addNewObjectArrayOrari{
    NSString *newObject = [NSString stringWithFormat:@"00:00-00:00"];
    [self.dateArray addObject:newObject];
    NSLog(@"addNewObjectArrayOrari dateArray:: %@",self.dateArray);
    [self.dataPikerDalleStep2 setDate:self.dataPikerAlleStep1.date];
    [self.dataPikerAlleStep2 setDate:self.dataPikerDalleStep2.date];
    [self setMinimumDate:0];
    [self createStringOrari];
    [self refreshTable];
}


- (void)setValueDataPiker {
    //self.plan = @"09:00-13:00;16:00-20:00";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setLocale:[NSLocale currentLocale]];
    [dateFormat setDateFormat:@"yyyy:MM:dd HH:mm"];
    int i = 0;
    for (NSString *intervallo in self.dateArray) {
        NSArray *timeArray = [intervallo componentsSeparatedByString: @"-"];
        NSString *fake_day = @"2000:01:01";
        NSString *timeDalle = [[NSString alloc] initWithFormat:@"%@ %@", fake_day, timeArray[0]];
        NSString *timeAlle = [[NSString alloc] initWithFormat:@"%@ %@", fake_day, timeArray[1]];
        NSDate *dateDalle = [dateFormat dateFromString:timeDalle];
        NSDate *dateAlle = [dateFormat dateFromString:timeAlle];
        NSLog(@"timeDalle %@ - timeAlle %@",dateDalle,dateAlle);
        switch (i) {
            case 0:
            {
                [self.dataPikerDalleStep1 setDate:dateDalle animated:YES];
                [self.dataPikerAlleStep1 setDate:dateAlle animated:YES];
                //self.buttonAdd.alpha = 1;
                break;
            }
            case 1:
            {
                [self.dataPikerDalleStep2 setDate:dateDalle animated:YES];
                [self.dataPikerAlleStep2 setDate:dateAlle animated:YES];
                //self.buttonAdd.alpha = 0;
                break;
            }
            default:
                break;
        }
        i++;
    }
    [self createStringOrari];
}

- (void)setMinimumDate:(NSInteger)tag{
    NSLog(@"setMinimumDate %ld", (long)tag);
     NSLog(@"\n dataPikerDalleStep1 : %@",self.dataPikerDalleStep1.date);
     NSLog(@"\n dataPikerAlleStep1  : %@",self.dataPikerAlleStep1.date);
    
    if (([self.dataPikerAlleStep1.date compare:self.dataPikerDalleStep1.date] == NSOrderedAscending) && tag <= 1){
        NSLog(@"%@ > %@",self.dataPikerAlleStep1.date, self.dataPikerDalleStep1.date);
        [self.dataPikerAlleStep1 setMinimumDate:self.dataPikerDalleStep1.date];
        [self.dataPikerAlleStep1 setDate:self.dataPikerDalleStep1.date animated:NO];
    }
    
    if (([self.dataPikerDalleStep2.date compare:self.dataPikerAlleStep1.date] == NSOrderedAscending) && tag <= 2){
         NSLog(@"%@ > %@",self.dataPikerDalleStep2.date, self.dataPikerAlleStep1.date);
        [self.dataPikerDalleStep2 setMinimumDate:self.dataPikerAlleStep1.date];
        [self.dataPikerDalleStep2 setDate:self.dataPikerAlleStep1.date animated:NO];
    }
    
    if (([self.dataPikerAlleStep2.date compare:self.dataPikerDalleStep2.date] == NSOrderedAscending) && tag <= 3){
        NSLog(@"%@ > %@",self.dataPikerAlleStep2.date, self.dataPikerDalleStep2.date);
        [self.dataPikerAlleStep2 setMinimumDate:self.dataPikerDalleStep2.date];
        [self.dataPikerAlleStep2 setDate:self.dataPikerDalleStep2.date animated:NO];
    }
}

- (void)dateChanged:(id)sender{
    NSLog(@"dateChanged   : %@",self.dataPikerAlleStep1.date);
    UIDatePicker *dataPicker = (UIDatePicker *) sender;
    NSInteger tag = dataPicker.tag;
    [self setMinimumDate: tag];
    [self createStringOrari];
    [self refreshTable];
}

- (void)createStringOrari {
    NSLog(@"createStringOrari %lu",(unsigned long)self.dateArray.count);
    self.orari = [NSString stringWithFormat:@"%ld>",(long)self.numberDay+1];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    if(self.dateArray.count >= 1){
        NSString *dalleStep1 = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:self.dataPikerDalleStep1.date]];
        NSString *alleStep1 = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:self.dataPikerAlleStep1.date]];
        self.orari = [NSString stringWithFormat:@"%@%@-%@",self.orari,dalleStep1,alleStep1];
        self.labelDalleStep1.text = dalleStep1;
        self.labelAlleStep1.text = alleStep1;
    }
    if(self.dateArray.count >= 2){
        NSString *dalleStep2 = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:self.dataPikerDalleStep2.date]];
        NSString *alleStep2 = [NSString stringWithFormat:@"%@",[dateFormat stringFromDate:self.dataPikerAlleStep2.date]];
        self.orari = [NSString stringWithFormat:@"%@;%@-%@",self.orari,dalleStep2,alleStep2];
        self.labelDalleStep2.text = dalleStep2;
        self.labelAlleStep2.text = alleStep2;
    }

    NSLog(@"self.orari %@",self.orari);
    self.vc.orari = self.orari;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"numberOfRowsInSection self.dateArray ::%@",self.dateArray);
    if(self.dateArray.count>0)return 5;
    else return 0;
    //self.dateArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] >2 && self.dateArray.count<2){
        return 0;
    }
    else if ([indexPath row] == currentSelection && [indexPath row]!=2) {
        return  160;
    }
    else return 44;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // set selection
    if(indexPath.row == currentSelection){
        currentSelection = -1;
    }else{
         currentSelection = indexPath.row;
    }
    // animate
    [tableView beginUpdates];
    [tableView endUpdates];
}

-(void)checkStatusButton{
    if(self.dateArray.count<2){
        [self.buttonAdd setTitle:@"+" forState:UIControlStateNormal];
        UIColor *itemColor = [SHPImageUtil colorWithHexString:@"56AE18"];
        [self.buttonAdd setBackgroundColor:itemColor];
        self.labelAddCancelTime.text = @"aggiungi intervallo";
    }
    else{
        [self.buttonAdd setTitle:@"-" forState:UIControlStateNormal];
        UIColor *itemColor = [SHPImageUtil colorWithHexString:@"B20000"];
        [self.buttonAdd setBackgroundColor:itemColor];
        self.labelAddCancelTime.text = @"elimina intervallo";
    }
}

- (IBAction)actionAdd:(id)sender {
    if(self.dateArray.count<2){
        [self addNewObjectArrayOrari];
    }
    else{
        [self removeLastObjectArrayOrari];
    }
    [self checkStatusButton];
}

- (IBAction)actionDelete:(id)sender {
    [self removeLastObjectArrayOrari];
    self.buttonAdd.alpha = 1;
    [self refreshTable];
}


@end
