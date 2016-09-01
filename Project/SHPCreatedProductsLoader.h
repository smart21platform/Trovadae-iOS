//
//  SHPCreatedProductsLoader.h
//  Shopper
//
//  Created by andrea sponziello on 22/09/12.
//
//

#import "SHPProductsLoaderStrategy.h"

@class SHPUser;

@interface SHPCreatedProductsLoader : SHPProductsLoaderStrategy

@property (strong, nonatomic) SHPUser *createdByUser;
//@property (strong, nonatomic) SHPUser *authUser;

-(void)loadProducts;
@end
