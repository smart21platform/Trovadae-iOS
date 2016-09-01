//
//  SHPListCoverTVC.h
//  MyDolly2
//
//  Created by dario de pascalis on 27/05/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPProductDC.h"
#import "SHPCategoryDC.h"
#import "SHPIconDownloader.h"

@class MBProgressHUD;
@class SHPApplicationContext;
@class SHPUser;

@interface SHPListCoverTVC : UITableViewController<SHPCategoryDCDelegate, SHPProductDCDelegate, SHPIconDownloaderDelegate>{
    NSInteger searchStartPage;
    NSInteger searchPageSize;
    BOOL isLoadingData;
    BOOL noMoreData;
    BOOL isScrollingFast;
    CLLocation *searchLocation;
    NSString *categoryId;
    SHPUser *authUser;
    NSMutableArray *arrayShops;
    NSMutableArray *arrayProducts;
    NSInteger selectedIndex;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSMutableArray *categories;
@property (strong, nonatomic) SHPProductDC *productDC;
@property (strong, nonatomic) SHPCategoryDC *categoryDC;
@property (strong, nonatomic) SHPIconDownloader *iconDownloader;
@property (strong, nonatomic) NSMutableArray *products;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

- (IBAction)actionBarButtonMap:(id)sender;

@end
