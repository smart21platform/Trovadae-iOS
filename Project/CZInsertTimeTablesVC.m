//
//  CZInsertTimeTablesVC.m
//  TrovaDAE
//
//  Created by Dario De Pascalis on 10/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "CZInsertTimeTablesVC.h"
#import "SHPImageUtil.h"
#import "SHPPOIOpenStatus.h"
#import "CZEditTimeTablesVC.h"
#import "CZInsertTimeTablesTVC.h"

@interface CZInsertTimeTablesVC ()

@end

@implementation CZInsertTimeTablesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.labelDay.text = self.day;
    NSLog(@"viewDidLoad!, %@",self.orari);
    [self setTrasparentBackground:self.navigationController];
    [self setContainer];
    [self initializeDate];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    NSLog(@"\n \n viewWillAppear :: %ld", (long)self.navigationController.navigationBar.barStyle);
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"\n \n viewWillDisappear :: %ld", (long)self.navigationController.navigationBar.barStyle);
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
}

-(void)setTrasparentBackground:(UINavigationController *)navigationController
{
    navigationController.navigationBar.translucent = YES;
    navigationController.navigationBar.shadowImage = [UIImage new];
    navigationController.view.backgroundColor = [UIColor clearColor];
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    navigationController.navigationBar.backgroundColor = [UIColor clearColor];
    navigationController.navigationBar.userInteractionEnabled = NO;
}

- (void)initializeDate{
    if(self.orari && ![self.orari isEqualToString:@""] ) {
        NSLog(@"OPEN!, %@",self.orari);
         //1>09:00-13:00;16:00-20:00
    }
    else {
        NSLog(@"CLOSED!");
        [self.switchOpen setOn:NO animated:NO];
        [self changeLabelState:NO];
    }
    [containerTVC intArrayOrari];
    [containerTVC refreshTable];
}


- (void)setContainer {
    containerTVC = (CZInsertTimeTablesTVC *)[self.childViewControllers objectAtIndex:0];
    containerTVC.vc = self;
    containerTVC.orari = self.orari;
    containerTVC.numberDay = self.numberDay;
}




- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"unwindToCZEditTimeTablesVC"]) {
        NSLog(@"prepareForSegue unwindToCZEditTimeTablesVC");
        CZEditTimeTablesVC *vc = [segue destinationViewController];
        vc.orari = self.orari;
        vc.numberDay = self.numberDay;
        NSLog(@"orari   : %@",self.orari);
    }
}


- (void)changeLabelState:(BOOL)flag{
    if(flag){
        NSLog(@"aperto");
        self.labelStatus.text = @"APERTO";
        UIColor *itemColor = [SHPImageUtil colorWithHexString:@"56AE18"];
        self.labelStatus.backgroundColor = itemColor;
        if(self.orari.length>0){
             NSLog(@"orari");
            containerTVC.orari = self.orari;
            [containerTVC intArrayOrari];
        }
        else{
           [containerTVC addNewObjectArrayOrari];
        }
        
    }else{
        NSLog(@"chiuso");
        //self.orari = @"";
        self.labelStatus.text = @"CHIUSO";
        UIColor *itemColor = [SHPImageUtil colorWithHexString:@"B20000"];
        self.labelStatus.backgroundColor = itemColor;
        containerTVC.orari = @"";
        [containerTVC intArrayOrari];
    }
    [containerTVC refreshTable];
}


- (IBAction)actionSwitchOpen:(UISwitch *)sender {
    BOOL flag = sender.on;
    [self changeLabelState:flag];
   // NSLog(@"actionSwitchOpen %lu",(unsigned long)flag);
}



- (IBAction)actionClose:(id)sender {
    NSLog(@"actionClose %lu",(unsigned long)self.switchOpen.isOn);
    NSLog(@"containerTVC.orari %@",containerTVC.orari);
    if(self.switchOpen.isOn){
        self.orari = containerTVC.orari;
    }else{
        self.orari = @"";
    }
    [self performSegueWithIdentifier: @"unwindToCZEditTimeTablesVC" sender: self];
    //[self dismissViewControllerAnimated:YES completion:nil];
}


@end
