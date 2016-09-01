//
//  SHPLikesViewController.h
//  Ciaotrip
//
//  Created by Dario De Pascalis on 14/02/14.
//
//

#import <UIKit/UIKit.h>
#import "SHPUserDC.h"
#import "SHPImageDownloader.h"

@class SHPUsersLoaderStrategy;
@class SHPProduct;
@class SHPApplicationContext;
@class SHPUser;

@interface SHPLikesViewController : UITableViewController <SHPUserDCDelegate, SHPImageDownloaderDelegate>

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property(strong, nonatomic) NSMutableArray *users;
@property(strong, nonatomic) SHPUsersLoaderStrategy *loader;
@property(assign, nonatomic) BOOL isLoadingData;
@property(assign, nonatomic) BOOL isNetworkError;
@property(strong, nonatomic) SHPUser *selectedUser;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;

@end
