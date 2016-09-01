//
//  SHPShopProductsLoader.m
//  Dressique
//
//  Created by andrea sponziello on 27/02/13.
//
//

#import "SHPShopProductsLoader.h"
#import "SHPProductDC.h"
#import "SHPShop.h"

@implementation SHPShopProductsLoader

@synthesize shop;

- (id) init
{
    self = [super init];
    
    if (self != nil) {
        self.productDC = [[SHPProductDC alloc] init];
    }
    return self;
}

// extends
-(void)loadProducts {
    NSLog(@"SHPShopProductsLoader.h");
    [self.productDC searchByShop:self.shop.oid page:self.searchStartPage pageSize:self.searchPageSize withUser:nil];
//    [self.productDC searchByText:self.textToSearch location:self.searchLocation page:self.searchStartPage pageSize:self.searchPageSize withUser:nil];
    //    [self.productDC search:searchLocation categoryId:nil page:self.searchStartPage pageSize:self.searchPageSize withUser:nil];
}

@end
