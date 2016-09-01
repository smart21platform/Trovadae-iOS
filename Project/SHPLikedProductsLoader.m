//
//  SHPLikedProductsLoader.m
//  Shopper
//
//  Created by andrea sponziello on 22/09/12.
//
//

#import "SHPLikedProductsLoader.h"
#import "SHPProductDC.h"

@implementation SHPLikedProductsLoader

@synthesize likedToUser;
//@synthesize authUser;

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
    NSLog(@"SEARCHING LIKED PRODUCTS WITH AUTH USER: %@", self.authUser);
    [self.productDC productsLikedTo:self.likedToUser page:self.searchStartPage pageSize:self.searchPageSize withUser:self.authUser];
}

@end
