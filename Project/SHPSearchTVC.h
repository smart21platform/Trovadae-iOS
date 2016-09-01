//
//  SHPSearchTVC.h
//  MyDolly2
//
//  Created by dario de pascalis on 03/06/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPProductDC.h"
#import "SHPShopDC.h"
#import "SHPUserDC.h"
#import "SHPImageDownloader.h"

@class SHPApplicationContext;
@class SHPUser;

@interface SHPSearchTVC : UITableViewController<UISearchResultsUpdating, UISearchBarDelegate, SHPProductDCDelegate, SHPShopsLoadedDCDelegate, SHPUserDCDelegate, SHPImageDownloaderDelegate, UISearchControllerDelegate>{
    NSInteger listMode;
    BOOL singlePoi;
    NSInteger searchStartPage;
    NSInteger searchPageSize;
    BOOL isLoadingData;
    BOOL noMoreData;
    CLLocation *searchLocation;
    SHPUser *authUser;
    NSArray *loadItems;
    SHPImageDownloader *iconProductDownloader;
    SHPImageDownloader *iconUserDownloader;
    NSMutableDictionary *imageDownloadsInProgress;
    UIColor *tintColor;
    NSInteger selectedIndex;
    CGFloat widthImageProduct;
    CGFloat heightImageProduct;
    CGFloat widthImageUser;
    CGFloat heightImageUser;
}
@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) UISearchController *searchController;
@property (strong, nonatomic) NSMutableArray *arraySearch;
@property (strong, nonatomic) NSString *searchBarPlaceholder;
@property (strong, nonatomic) SHPProductDC *productDC;
@property (strong, nonatomic) SHPShopDC *shopDC;
@property (strong, nonatomic) SHPUserDC *userDC;


@property (weak, nonatomic) IBOutlet UISearchBar *sb;

@end
