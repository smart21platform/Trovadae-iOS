//
//  SHPProductsLoader.m
//  Shopper
//
//  Created by andrea sponziello on 22/09/12.
//
//

#import "SHPProductsLoaderStrategy.h"
#import "SHPProductDC.h"

@implementation SHPProductsLoaderStrategy

//@synthesize productDCDelegate;
@synthesize productDC;
@synthesize searchPageSize;
@synthesize searchStartPage;
@synthesize authUser;

// abstract
-(void)loadProducts {
}

-(void)cancelOperation {
    NSLog(@"(SHPProductsLoaderStrategy) Canceling operation on %@", self.productDC);
    [self.productDC cancelDownload];
}

@end
