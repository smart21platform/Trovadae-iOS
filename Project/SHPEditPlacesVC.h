//
//  SHPEditPlacesVC.h
//  Salve Smart
//
//  Created by Dario De Pascalis on 29/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPProductUploaderDC.h"

@class SHPApplicationContext;
@class MBProgressHUD;
@class SHPProduct;

@interface SHPEditPlacesVC:UIViewController<SHPProductUploaderDelegate>{
    NSInteger maxNumberPlaces;
    MBProgressHUD *hud;
    NSString *properties;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPProduct *product;
@property (strong, nonatomic) NSString *numberPlaceAvailable;
@property (strong, nonatomic) SHPProductUploaderDC *uploaderDC;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerViewPlaces;
@property (strong, nonatomic) IBOutlet UILabel *labelHeader;
@property (strong, nonatomic) IBOutlet UILabel *labelNumberPlaces;
@property (strong, nonatomic) IBOutlet UIButton *buttonSalva;
@property (strong, nonatomic) IBOutlet UIButton *buttonAnnulla;
- (IBAction)actionAnnulla:(id)sender;
- (IBAction)actionSalva:(id)sender;


@end
