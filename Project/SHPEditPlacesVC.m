//
//  SHPEditPlacesVC.m
//  Salve Smart
//
//  Created by Dario De Pascalis on 29/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import "SHPEditPlacesVC.h"
#import "SHPApplicationContext.h"
#import "SHPConnectionsController.h"
#import "MBProgressHUD.h"
#import "SHPProductUpdateDC.h"
#import "SHPComponents.h"
#import "SHPProduct.h"
#import "SHPProductDetail.h"


@interface SHPEditPlacesVC ()
@end

@implementation SHPEditPlacesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.pickerViewPlaces.delegate = self;
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
    NSDictionary *plistDictionary = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    NSDictionary *viewDictionary = [plistDictionary objectForKey:@"View"];
    viewDictionary = [viewDictionary objectForKey:@"ProductDetail"];
    maxNumberPlaces = [[viewDictionary objectForKey:@"maxNumberPlaces"] intValue];
    if(maxNumberPlaces<=0)maxNumberPlaces = 500;
    
    //SHPProductDetail *vc = (SHPProductDetail *) self.presentingViewController;
    NSLog(@"parentViewController ---------- %@",self.presentingViewController);
    [self initialize];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initialize{
    self.labelNumberPlaces.text = self.numberPlaceAvailable;
    [self.pickerViewPlaces selectRow:[self.numberPlaceAvailable intValue] inComponent:0 animated:NO];
    self.labelHeader.text = [[NSString alloc] initWithString:NSLocalizedString(@"labelHeaderEditPlaces", nil)];
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
//    SHPProductUpdateDC *productUpload = [[SHPProductUpdateDC alloc]init];
//    productUpload.delegateViewController = self;
//    productUpload.applicationContext = self.applicationContext;
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
//------------------------------------//
// END UPDATE POST
//------------------------------------//



//******************************************************************************//
// DELEGATE SAVE AND UPDATE POST
//******************************************************************************//
-(void)productUploaded:(NSString *)error{
    [hud hide:YES];
    if(error==nil){
        //SHPProductDetail *vc = (SHPProductDetail *) self.presentingViewController;
        //[vc changeNumberPlaces:self.labelNumberPlaces.text];
        //[self dismissViewControllerAnimated:YES completion:nil];
         [self performSegueWithIdentifier: @"unwindToProductDetail" sender: self];
    }else{
        UIAlertView *alertError = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"error-update-reload", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertError show];
    }
}
//******************************************************************************//



-(void)setProperties{
    NSDictionary *finalData = [[NSDictionary alloc]init];
    NSString *number = [self.labelNumberPlaces.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(number && ![number isEqualToString:@""]){
        NSArray *values = @[number];
        NSDictionary *propertyPhoneDictionary = [SHPProduct setProperties:@"posti" displayName:@"posti" oid:@"posti" values:values];
        finalData = [SHPComponents mergeDictionaries:finalData second:propertyPhoneDictionary];
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:finalData options:NSJSONWritingPrettyPrinted error:nil];
    properties = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSLog(@"\n--------------------\n %@ \n--------------------\n",properties);
}

//----------------------------------------------------------------//
// START FUNCTIONS PICKER
//----------------------------------------------------------------//
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return maxNumberPlaces;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    //    NSLog(@"Row %d: %@", (int)row, self.daysNames[row]);
    NSString *num = [[NSString alloc] initWithFormat:@"%d posti", (int)row];
    return num;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.labelNumberPlaces.text = [[NSString alloc] initWithFormat:@"%d", (int)row];
}
//----------------------------------------------------------------//
// END FUNCTIONS PICKER
//----------------------------------------------------------------//


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"unwindToProductDetail"]) {
        SHPProductDetail *VC = [segue destinationViewController];
        VC.numberPlaces = self.self.labelNumberPlaces.text;
    }
}



- (IBAction)actionAnnulla:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)actionSalva:(id)sender {
    [self sendMetadataForUpdate];
}
@end
