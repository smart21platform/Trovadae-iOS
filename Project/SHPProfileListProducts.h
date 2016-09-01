//
//  SHPProfileListProducts.h
//  Italiacamp
//
//  Created by dario de pascalis on 22/04/15.
//
//

#import <UIKit/UIKit.h>
#import "SHPProductDC.h"

@class SHPApplicationContext;
@class SHPUser;


@interface SHPProfileListProducts : UITableViewController<SHPProductDCDelegate>{
    BOOL isLoadingData;
    BOOL noMoreData;
    NSInteger searchStartPage;
    NSInteger searchPageSize;
    NSMutableArray *listProducts;
    NSInteger selectedProductID;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPUser *user;
@property (strong, nonatomic) SHPProductDC *loader;
@property (strong, nonatomic) NSString *listMode;
@property (strong, nonatomic) NSString *titleView;
@property (strong, nonatomic) NSMutableArray *listAllProducts;

@end
