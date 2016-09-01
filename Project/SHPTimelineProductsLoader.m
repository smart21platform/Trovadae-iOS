//
//  SHPTimelineProductsLoader.m
//  Dressique
//
//  Created by andrea sponziello on 15/05/13.
//
//

#import "SHPTimelineProductsLoader.h"
#import "SHPProductDC.h"

@implementation SHPTimelineProductsLoader

@synthesize searchLocation;
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
    NSLog(@"loadProducts timeline %@", self.productDC);
    [self.productDC timelineForUser:self.authUser location:self.searchLocation page:self.searchStartPage pageSize:self.searchPageSize];
}

@end
