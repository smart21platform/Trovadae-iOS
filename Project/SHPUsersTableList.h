//
//  SHPUsersTableList.h
//  Dressique
//
//  Created by andrea sponziello on 17/01/13.
//
//

#import <Foundation/Foundation.h>
#import "SHPUserDC.h"
#import "SHPImageDownloader.h"

@class SHPUsersLoaderStrategy;
@class SHPApplicationContext;
@class SHPImageCache;
@class SHPUser;

@interface SHPUsersTableList : NSObject <SHPUserDCDelegate, SHPImageDownloaderDelegate>

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) UIViewController *masterView;
@property (strong, nonatomic) SHPUsersLoaderStrategy *loader;
//@property (copy, nonatomic) SHPShopTableTapHandler tapHandler;

@property (assign, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) UIViewController *tableViewDelegate;
@property (assign, nonatomic) NSInteger selectedIndex;
@property (nonatomic, strong) SHPImageCache *imageCache;
@property (nonatomic, assign) NSInteger columnsNumber;
//@property (nonatomic, assign) NSInteger totalRows;
//@property (strong, nonatomic) SHPUserDC *userDC;
@property (strong, nonatomic) NSMutableArray *users;
@property (nonatomic, assign) NSInteger searchStartPage;
@property (nonatomic, assign) NSInteger searchPageSize;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, assign) BOOL isLoadingData;
@property (nonatomic, assign) BOOL currentlyShown;
@property (nonatomic, assign) BOOL isNetworkError;
@property (nonatomic, assign) BOOL noMoreData;

-(void)initialize;
-(void)searchUsers;

-(NSInteger)numberOfRows;
-(CGFloat)heightForRow:(NSInteger)row;
-(UITableViewCell *)cellForRow:(NSIndexPath *)indexPath;

-(SHPUser *)userAtIndexPath:(NSIndexPath *)indexPath;

-(void)disposeResources;

@end
