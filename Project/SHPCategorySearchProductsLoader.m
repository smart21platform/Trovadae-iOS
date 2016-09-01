//
//  SHPCategorySearchProductsLoader.m
//  Dressique
//
//  Created by andrea sponziello on 15/05/13.
//
//

#import "SHPCategorySearchProductsLoader.h"
#import "SHPProductDC.h"

@implementation SHPCategorySearchProductsLoader

@synthesize searchLocation;
//@synthesize authUser;
@synthesize categoryId;

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
    NSLog(@"................SEARCH LOCATION %@", self.categoryId);
    [self.productDC search:searchLocation categoryId:self.categoryId page:self.searchStartPage pageSize:self.searchPageSize withUser:self.authUser];
}

@end
