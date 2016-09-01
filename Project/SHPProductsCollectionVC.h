//
//  SHPProductsCollectionVC.h
//  Coricciati MG
//
//  Created by Dario De Pascalis on 08/10/15.
//  Copyright © 2015 Frontiere21. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHPProductDC.h"
#import "SHPIconDownloader.h"

@class SHPApplicationContext;
@class SHPUser;
@class SHPProduct;

@interface SHPProductsCollectionVC : UICollectionViewController<SHPProductDCDelegate, SHPIconDownloaderDelegate>{
    NSInteger searchStartPage;
    NSInteger searchPageSize;
    NSMutableArray *listProducts;
    BOOL isLoadingData;
    BOOL noMoreData;
    SHPProduct *productSelected;
    NSMutableDictionary *imageDownloadsInProgress;
}

@property (strong, nonatomic) SHPApplicationContext *applicationContext;
@property (strong, nonatomic) SHPProductDC *loader;
@property (strong, nonatomic) SHPUser *author;
@property (strong, nonatomic) NSString *idProduct;
//@property (assign, nonatomic) BOOL startLoading;

-(void)loadProducts;

@end
