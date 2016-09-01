//
//  SHPCreatedProductsLoader.m
//  Shopper
//
//  Created by andrea sponziello on 22/09/12.
//
//

#import "SHPCreatedProductsLoader.h"
#import "SHPProductDC.h"
#import "SHPUser.h"

@implementation SHPCreatedProductsLoader

@synthesize createdByUser;
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
//    NSLog(@"productsCreatedBy...");
//    NSLog(@"createdby %@", self.createdByUser.username);
//    NSLog(@"auth %@", self.authUser.username);
    [self.productDC productsCreatedBy:self.createdByUser page:self.searchStartPage pageSize:self.searchPageSize withUser:self.authUser];
}

@end
