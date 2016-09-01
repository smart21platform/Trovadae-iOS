//
//  SHPProductsTableList.h
//  Shopper
//
//  Created by andrea sponziello on 22/09/12.
//
//

#import <Foundation/Foundation.h>
#import "SHPProductDCDelegate.h"
#import "SHPImageDownloader.h"
#import "SHPApplicationContext.h"
#import "SHPProductsLoaderStrategy.h"

@class SHPImageCache;
@class SHPProductDC;
@class SHPUserProfileViewController;

typedef void (^SHPProductTableTapHandler)(SHPProduct *product, NSInteger onIndex);

@interface SHPProductsTableList : NSObject <SHPProductDCDelegate, SHPImageDownloaderDelegate>

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
//@property (strong, nonatomic) SHPUser *user;
@property (strong, nonatomic) UIColor *bgColor;
@property (strong, nonatomic) UIViewController *masterView;
@property (strong, nonatomic) SHPProductsLoaderStrategy *loader;
@property (copy, nonatomic) SHPProductTableTapHandler tapHandler;

@property (assign, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) UIViewController *tableViewDelegate;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) SHPImageCache *imageCache;
@property (nonatomic, assign) NSInteger columnsNumber;
@property (nonatomic, assign) NSInteger totalRows;
//@property (strong, nonatomic) SHPProductDC *productDC;
@property (strong, nonatomic) NSMutableArray *products;
@property (nonatomic, assign) NSInteger searchStartPage;
@property (nonatomic, assign) NSInteger searchPageSize;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, assign) BOOL isLoadingData;
@property (nonatomic, assign) BOOL currentlyShown;
@property (nonatomic, assign) BOOL isNetworkError;
@property (nonatomic, assign) BOOL noMoreData;

-(void)initialize;
-(void)removeProduct:(NSString *)oid;
-(void)searchProducts;

-(NSInteger)numberOfRows;
-(CGFloat)heightForRow:(NSInteger)row;
-(UITableViewCell *)cellForRow:(NSIndexPath *)indexPath;

-(void)disposeResources;

-(void)networkError;

@end
