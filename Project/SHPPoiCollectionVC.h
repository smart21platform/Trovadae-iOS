//
//  SHPPoiCollectionVC.h
//  Italiacamp
//
//  Created by dario de pascalis on 05/05/15.
//  Copyright (c) 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPProductDC.h"

@class SHPApplicationContext;
@class SHPShop;
@class SHPProduct;

@interface SHPPoiCollectionVC : UICollectionViewController<SHPProductDCDelegate>{
    NSInteger searchStartPage;
    NSInteger searchPageSize;
    BOOL isLoadingData;
    BOOL noMoreData;
    NSMutableArray *listProducts;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPProductDC *loader;
@property (strong, nonatomic) SHPShop *shop;
@property (strong, nonatomic) SHPProduct *product;

-(void)loadProducts;

@end
