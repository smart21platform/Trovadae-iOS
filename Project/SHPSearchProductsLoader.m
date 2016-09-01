//
//  SHPSearchProductsLoader.m
//  Dressique
//
//  Created by andrea sponziello on 04/01/13.
//
//

#import "SHPSearchProductsLoader.h"
#import "SHPProductDC.h"
#import "SHPStringUtil.h"

@implementation SHPSearchProductsLoader

@synthesize searchLocation;
@synthesize textToSearch;
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
    NSLog(@"SHPSearchProductsLoader.h");
//    NSString *fulltextQuery = [SHPStringUtil fulltextQuery:self.textToSearch];
    [self.productDC searchByText:self.textToSearch location:self.searchLocation page:self.searchStartPage pageSize:self.searchPageSize withUser:self.authUser];
//    [self.productDC search:searchLocation categoryId:nil page:self.searchStartPage pageSize:self.searchPageSize withUser:nil];
}

@end
