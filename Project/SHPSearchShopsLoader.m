//
//  SHPSearchShopsLoader.m
//  Dressique
//
//  Created by andrea sponziello on 14/01/13.
//
//

#import "SHPSearchShopsLoader.h"
#import "SHPShopDC.h"
#import "SHPStringUtil.h"

@implementation SHPSearchShopsLoader

@synthesize searchLocation;
@synthesize textToSearch;

- (id) init
{
    self = [super init];
    
    if (self != nil) {
        self.shopDC = [[SHPShopDC alloc] init];
    }
    return self;
}

// extends
-(void)loadShops {
//    NSString *fulltextQuery;
//    if (self.allowSearchAll) {
//        fulltextQuery = self.textToSearch;
//    } else {
//        fulltextQuery = [SHPStringUtil fulltextQuery:self.textToSearch];
//    }
    
    [self.shopDC searchByText:self.textToSearch location:self.searchLocation page:self.searchStartPage pageSize:self.searchPageSize withUser:nil];
}

@end
