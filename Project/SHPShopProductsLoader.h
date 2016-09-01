//
//  SHPShopProductsLoader.h
//  Dressique
//
//  Created by andrea sponziello on 27/02/13.
//
//

#import <Foundation/Foundation.h>
#import "SHPProductsLoaderStrategy.h"

@class SHPShop;

@interface SHPShopProductsLoader : SHPProductsLoaderStrategy

@property (strong, nonatomic) SHPShop *shop;

@end