//
//  SHPShopsTableList.h
//  Dressique
//
//  Created by andrea sponziello on 15/01/13.
//
//

#import <Foundation/Foundation.h>
#import "SHPImageDownloader.h"
#import "SHPApplicationContext.h"
#import "SHPShopsLoaderStrategy.h"
#import "SHPShopsLoadedDCDelegate.h"

@class SHPShop;
@class SHPImageCache;
@class SHPUserProfileViewController;

//typedef void (^SHPShopTableTapHandler)(SHPShop *shop, NSInteger onIndex);

@interface SHPShopsTableList : NSObject <SHPShopsLoadedDCDelegate, SHPImageDownloaderDelegate>

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) UIViewController *masterView;
@property (strong, nonatomic) SHPShopsLoaderStrategy *loader;
//@property (copy, nonatomic) SHPShopTableTapHandler tapHandler;

@property (assign, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) UIViewController *tableViewDelegate;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) SHPImageCache *imageCache;
@property (nonatomic, assign) NSInteger columnsNumber;
//@property (nonatomic, assign) NSInteger totalRows;
//@property (strong, nonatomic) SHPShopDC *shopDC;
@property (strong, nonatomic) NSMutableArray *shops;
@property (nonatomic, assign) NSInteger searchStartPage;
@property (nonatomic, assign) NSInteger searchPageSize;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, assign) BOOL isLoadingData;
@property (nonatomic, assign) BOOL currentlyShown;
@property (nonatomic, assign) BOOL isNetworkError;
@property (nonatomic, assign) BOOL noMoreData;

-(void)initialize;
-(void)searchShops;

-(NSInteger)numberOfRows;
-(CGFloat)heightForRow:(NSInteger)row;
-(UITableViewCell *)cellForRow:(NSIndexPath *)indexPath;

-(SHPShop *)shopAtIndexPath:(NSIndexPath *)indexPath;

-(void)disposeResources;

@end
