//
//  SHPProductsLoaderStrategy.h
//  Shopper
//
//  Created by andrea sponziello on 22/09/12.
//
//

#import <Foundation/Foundation.h>
#import "SHPProductDCDelegate.h"

@class  CLLocation;
@class SHPUser;
@class SHPProductDC;

@interface SHPProductsLoaderStrategy : NSObject

@property (strong, nonatomic) SHPProductDC *productDC; // TOTO move down in hierarchy
@property (strong, nonatomic) CLLocation *searchLocation;
@property (nonatomic, assign) NSInteger searchStartPage;
@property (nonatomic, assign) NSInteger searchPageSize;
@property (strong, nonatomic) SHPUser *authUser;

-(void)loadProducts;
-(void)cancelOperation;

@end
