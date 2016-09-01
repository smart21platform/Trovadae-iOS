//
//  CZProvaTVC.h
//  AboutMe
//
//  Created by Dario De pascalis on 02/05/15.
//  Copyright (c) 2015 Dario De Pascalis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPShopDC.h"

@class SHPShop;
@class SHPApplicationContext;


@interface SHPPoiDetailTVC : UITableViewController<SHPShopsLoadedDCDelegate>{
    CGFloat defaultH;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPShop *shop;
@property (strong, nonatomic) UIImage *imageMap;
@property (strong, nonatomic) SHPShopDC *shopDC;
@property (nonatomic, strong) NSString *distance;
@property (assign, nonatomic) BOOL hideOtherProducts;
@property (weak, nonatomic) IBOutlet UIImageView *imageCoverDown;
@property (weak, nonatomic) IBOutlet UIImageView *imageCoverUp;
@property (weak, nonatomic) IBOutlet UILabel *labelShopName;
@property (weak, nonatomic) IBOutlet UILabel *labelCity;
@property (weak, nonatomic) IBOutlet UILabel *labelDistanceToYou;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewMap;
@property (weak, nonatomic) IBOutlet UILabel *labelAddress;
@property (weak, nonatomic) IBOutlet UILabel *labelTelephone;
@property (weak, nonatomic) IBOutlet UILabel *labelSmartphone;
@property (weak, nonatomic) IBOutlet UILabel *labelFax;
@property (weak, nonatomic) IBOutlet UILabel *labelEmail;
@property (weak, nonatomic) IBOutlet UILabel *labelWebsite;
@property (weak, nonatomic) IBOutlet UILabel *labelDescription;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;


@end
