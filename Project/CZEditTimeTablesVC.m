//
//  CZEditTimeTablesVC.m
//  TrovaDAE
//
//  Created by Dario De Pascalis on 10/06/16.
//  Copyright © 2016 Frontiere21. All rights reserved.
//

#import "CZEditTimeTablesVC.h"
#import "SHPApplicationContext.h"
#import "SHPProduct.h"
#import "CZEditTimeTablesTVC.h"
#import "CZInsertTimeTablesVC.h"
#import "SHPComponents.h"
#import "SHPProduct.h"
#import "SHPProductDetail.h"


@interface CZEditTimeTablesVC ()

@end

@implementation CZEditTimeTablesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.plan = @"1>09:00-13:00;16:00-20:00|2>09:00-13:00;16:00-20:00|4>09:00-13:05;14:50-18:00;19:50-22:00|6>09:00-10:27;17:00-19:00"; // 1: Sunday, 2: Monday, 3: Tuesday
    NSLog(@"::::::::::::::::::::: self.plan %@ ::::::::::::::::\n",self.plan);
    arrayDictionaryDay = [[NSMutableArray alloc] init];
    self.arrayWeekDay = @[@"Domenica",@"Lunedì", @"Martedì", @"Mercoledì", @"Giovedì", @"Venerdì", @"Sabato"];
    for (NSString *day in self.arrayWeekDay) {
        NSDictionary *nwQuestion = @{@"giorno" : day, @"orari" : @""};
        [arrayDictionaryDay addObject:nwQuestion];
    }
    [self setArrayTimeTables:self.plan];
    
    NSLog(self.modalView?@"Yes" : @"No");
    if(self.modalView == YES){
        self.buttonSave.alpha = 0;
        self.labelTitle.text = @"Orari di apertura settimanali";
    }else{
        self.buttonSave.alpha = 1;
        self.labelTitle.text = @"Seleziona il giorno per modificare gli orari di apertura";
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setContainer];
}

- (void)setContainer {
    containerTVC = (CZEditTimeTablesTVC *)[self.childViewControllers objectAtIndex:0];
    containerTVC.vc = self;
    containerTVC.arrayDictionaryDay= arrayDictionaryDay;
    containerTVC.arrayWeekDay= self.arrayWeekDay;
    [containerTVC refreshTable];
}

- (void)setArrayTimeTables:(NSString *)stringPlan{
    NSArray *arrayTimeTableDay = [self.plan componentsSeparatedByString: @"|"];
    for (NSString *timeTableDay in arrayTimeTableDay) {
        NSInteger numberDay = [[timeTableDay substringToIndex:1] intValue]-1;
        NSString *dayWeek = self.arrayWeekDay[numberDay];
        NSDictionary *nwDictionary = @{@"giorno" : dayWeek, @"orari" : timeTableDay};
        [arrayDictionaryDay replaceObjectAtIndex:numberDay withObject:nwDictionary];
    }
}

- (void)setStringTimeTables{
    NSMutableArray *arrayPlan = [[NSMutableArray alloc] init];
    for (NSDictionary *timeTableDay in arrayDictionaryDay) {
        NSString *orarioGiorno = [timeTableDay valueForKey:@"orari"];
        if(orarioGiorno.length>0) [arrayPlan addObject:orarioGiorno];
    }
    self.plan = [arrayPlan componentsJoinedByString:@"|"];
}

//------------------------------------//
// START UPDATE POST
//------------------------------------//
-(void)sendMetadataForUpdate{
    //Show progress
    hud = [MBProgressHUD showHUDAddedTo:self.view.superview animated:YES];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = NSLocalizedString(@"SavingLKey", nil);
    [hud show:YES];
    [self sendPhotoWithMetadata];
}

-(void)sendPhotoWithMetadata
{
    self.uploaderDC = [[SHPProductUploaderDC alloc] init];
    self.uploaderDC.delegate = self;
    self.uploaderDC.applicationContext = self.applicationContext;
    //---------------------------------------------------//
    [self setProperties];
    //---------------------------------------------------//
    [self.uploaderDC setMetadata:nil
                           brand:nil
                     categoryOid:self.product.category
                         shopOid:self.product.shop
                      shopSource:nil
                             lat:nil
                             lon:nil
       shopGooglePlacesReference:nil
                           title:self.product.title
                     description:self.product.longDescription
                           price:nil
                      startprice:nil
                       telephone:nil
                       startDate:nil
                         endDate:nil
                      properties:properties];
    [self.uploaderDC sendUpdate:self.product.oid];
}

-(void)setProperties
{
    //genero self.orari da array arrayDictionaryDay
    arrayDictionaryDay = containerTVC.arrayDictionaryDay;
    [self setStringTimeTables];
   
    NSDictionary *newDicProperties = [self replaceID:self.product.properties];
    NSMutableDictionary *finalData=[NSMutableDictionary dictionary];
    [finalData addEntriesFromDictionary:newDicProperties];
     NSLog(@"******************* PLAN ::: %@", newDicProperties);
    
    NSString *stringOrari = [self.plan stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(stringOrari && ![stringOrari isEqualToString:@""]){
        NSArray *values = @[stringOrari];
        NSDictionary *propertyPhoneDictionary = [SHPProduct setProperties:@"orari" displayName:@"orari" oid:@"orari" values:values];
        [finalData addEntriesFromDictionary:[SHPComponents mergeDictionaries:finalData second:propertyPhoneDictionary]];
        
        //finalData = [SHPComponents mergeDictionaries:finalData second:propertyPhoneDictionary];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:finalData options:NSJSONWritingPrettyPrinted error:nil];
    properties = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSLog(@"\n--------------------\n %@ \n--------------------\n",properties);
}

- (NSDictionary *)replaceID:(NSDictionary *)old_properties{
    NSMutableDictionary *newDictionary = [[NSMutableDictionary alloc]init];
    for (NSString *key in old_properties) {
        NSDictionary *phoneDictionary = (NSDictionary *)[old_properties valueForKey:key];
        NSString *valueId = [phoneDictionary valueForKey:@"id"];
        NSString *valueDisplayName = [phoneDictionary valueForKey:@"displayName"];
        NSString *valueValues = [phoneDictionary valueForKey:@"values"];
        NSDictionary *normalDict = [[NSDictionary alloc]initWithObjectsAndKeys:valueId,@"_id",valueDisplayName,@"displayName",valueValues,@"values",nil];
        //[dict setObject:valueId forKey:@"_id"];
        //[dict setObject:valueDisplayName forKey:@"displayName"];
        //[dict setObject:valueValues forKey:@"values"];
        [newDictionary setObject:normalDict forKey:key];
    }
    return newDictionary;
}
//------------------------------------//
// END UPDATE POST
//------------------------------------//

//******************************************************************************//
// DELEGATE SAVE AND UPDATE POST
//******************************************************************************//
-(void)productUploaded:(NSString *)error{
    [hud hide:YES];
    if(error==nil){
        [self performSegueWithIdentifier: @"unwindToProductDetail" sender: self];
    }else{
        UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"error-update-reload", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertError show];
    }
}
//******************************************************************************//



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"toInsertTime"]) {
        UINavigationController *nc = [segue destinationViewController];
        CZInsertTimeTablesVC *vc = (CZInsertTimeTablesVC *)[[nc viewControllers] objectAtIndex:0];
        //CZInsertTimeTablesVC *vc = (CZInsertTimeTablesVC *)[segue destinationViewController];
        vc.orari = self.orari;
        vc.numberDay = self.numberDay;
        vc.day = self.arrayWeekDay[self.numberDay];
    }
    else if ([[segue identifier] isEqualToString:@"unwindToProductDetail"]) {
        SHPProductDetail *VC = [segue destinationViewController];
        NSLog(@"unwindToProductDetail self.orari:: %@",self.plan);
        VC.orariApertura = self.plan;
    }
}



- (void)goToInsertTime {
    NSLog(@"goToInsertTime");
    [self performSegueWithIdentifier: @"toInsertTime" sender: self];
}

- (IBAction)actionClose:(id)sender {
     NSLog(@"actionClose");
    //[self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionSave:(id)sender {
    [self sendMetadataForUpdate];
}


- (IBAction)unwindToCZEditTimeTablesVC:(UIStoryboardSegue*)sender{
    NSLog(@"unwindToCZEditTimeTablesVC  self.orari::%@",  self.orari);
    NSString *dayWeek = self.arrayWeekDay[self.numberDay];
    NSDictionary *nwDictionary = @{@"giorno" : dayWeek, @"orari" : self.orari};
    NSLog(@"nwDictionary::%@ - %ld",  nwDictionary,(long)self.numberDay);
    [arrayDictionaryDay replaceObjectAtIndex:self.numberDay withObject:nwDictionary];
    [self setContainer];
}
@end
